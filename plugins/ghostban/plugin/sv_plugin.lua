--[[-------------------------------------------------------------------------
Add /ghostban as a clockwork command
---------------------------------------------------------------------------]]

local COMMAND = Clockwork.command:New("ghostban")

COMMAND.tip = "Open Ghostban config menu"
COMMAND.access = "o"

function COMMAND:OnRun(ply)
	net.Start("GhostBan_Clockwork_Commands")
	net.Send(ply)
end

COMMAND:Register()

if !GhostBan.replaceDefBan then return end

--[[-------------------------------------------------------------------------
Replace default plyBan command
---------------------------------------------------------------------------]]

local function addBan(identifier, duration, reason, Callback) -- copy of Clockwork.bans:Add
	local playerGet = Clockwork.player:FindByID(identifier)
	local bansTable = Clockwork.config:Get("mysql_bans_table"):Get()
	local schemaFolder = Clockwork.kernel:GetSchemaFolder()
	local playersTable = Clockwork.config:Get("mysql_players_table"):Get()

	if IsValid( playerGet ) && playerGet:IsPlayer() then
		playerGet:Ghostban(false, duration, reason)
	end
	
	if (string.find(identifier, "STEAM_(%d+):(%d+):(%d+)")) then
		local queryObj = Clockwork.database:Select(playersTable)
		queryObj:AddWhere("_SteamID = ?", identifier)
		queryObj:SetCallback(function(result)
			local steamName = identifier
			
			if Clockwork.database:IsResult(result) then
				steamName = result[1]._SteamName
			end
				
			if duration == 0 then
				Clockwork.bans.stored[identifier] = {
					unbanTime = 0,
					steamName = steamName,
					duration = duration,
					reason = reason
				}
			else
				Clockwork.bans.stored[identifier] = {
					unbanTime = os.time() + duration,
					steamName = steamName,
					duration = duration,
					reason = reason
				}
			end
			
			local insertObj = Clockwork.database:Insert(bansTable)
				insertObj:SetValue("_Identifier", identifier)
				insertObj:SetValue("_UnbanTime", Clockwork.bans.stored[identifier].unbanTime)
				insertObj:SetValue("_SteamName", steamName)
				insertObj:SetValue("_Duration", duration)
				insertObj:SetValue("_Reason", reason)
				insertObj:SetValue("_Schema", schemaFolder)
			insertObj:Push()
			
			if Callback then
				Callback(steamName, duration, reason)
			end
		end)
		queryObj:Pull()
		
		return
	end
	
	--[[ In this case we're banning them by their IP address. --]]
	if (string.find(identifier, "%d+%.%d+%.%d+%.%d+")) then
		local queryObj = Clockwork.database:Select(playersTable)	
			queryObj:SetCallback(function(result)
				local steamName = identifier
				
				if Clockwork.database:IsResult(result) then
					steamName = result[1]._SteamName
				end
				
				if (duration == 0) then
					Clockwork.bans.stored[identifier] = {
						unbanTime = 0,
						steamName = steamName,
						duration = duration,
						reason = reason
					}
				else
					Clockwork.bans.stored[identifier] = {
						unbanTime = os.time() + duration,
						steamName = steamName,
						duration = duration,
						reason = reason
					}
				end
				
				local insertObj = Clockwork.database:Insert(bansTable)
					insertObj:SetValue("_Identifier", identifier)
					insertObj:SetValue("_UnbanTime", Clockwork.bans.stored[identifier].unbanTime)
					insertObj:SetValue("_SteamName", steamName)
					insertObj:SetValue("_Duration", sduration)
					insertObj:SetValue("_Reason", reason)
					insertObj:SetValue("_Schema", schemaFolder)
				insertObj:Push()
				
				if Callback then
					Callback(steamName, duration, reason)
				end
			end)
			queryObj:AddWhere("_IPAddress = ?", identifier)
		queryObj:Pull()
		
		return
	end
	
	if duration == 0 then
		Clockwork.bans.stored[identifier] = {
			unbanTime = 0,
			steamName = nil,
			duration = duration,
			reason = reason
		}
	else
		Clockwork.bans.stored[identifier] = {
			unbanTime = os.time() + duration,
			steamName = nil,
			duration = duration,
			reason = reason
		}
	end
	
	local queryObj = Clockwork.database:Insert(bansTable)
		queryObj:SetValue("_Identifier", identifier)
		queryObj:SetValue("_UnbanTime", Clockwork.bans.stored[identifier].unbanTime)
		queryObj:SetValue("_SteamName", nil)
		queryObj:SetValue("_Duration", duration)
		queryObj:SetValue("_Reason", reason)
		queryObj:SetValue("_Schema", schemaFolder)
	queryObj:Push()
	
	if Callback then
		Callback(nil, duration, reason)
	end
end

local function removeBan(identifier)
	local bansTable = Clockwork.config:Get("mysql_bans_table"):Get()
	local schemaFolder = Clockwork.kernel:GetSchemaFolder()
	local playerGet = Clockwork.player:FindByID(identifier)

	if IsValid(playerGet) && playerGet:IsPlayer() then
		playerGet:Ghostban(true)
	end

	if Clockwork.bans.stored[identifier] then
		Clockwork.bans.stored[identifier] = nil
		
		local queryObj = Clockwork.database:Delete(bansTable)
			queryObj:AddWhere("_Schema = ?", schemaFolder)
			queryObj:AddWhere("_Identifier = ?", identifier)
		queryObj:Push()
	end
end

hook.Add("Initialize", "GhostBan_ReplaceClockwork", function()

-- replace plyBan

local COMMAND = Clockwork.command:New("PlyBan")

COMMAND.tip = "Ban a player from the server."
COMMAND.text = "<string Name|SteamID|IPAddress> <number Minutes> [string Reason]"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local schemaFolder = Clockwork.kernel:GetSchemaFolder()
	local duration = tonumber(arguments[2])
	local reason = table.concat(arguments, " ", 3)
	
	if !reason or string.Trim(reason) == "" then
		reason = GhostBan.Translation[GhostBan.Language]["noreason"]
	end
	
	if Clockwork.player:IsProtected(arguments[1]) then
		local target = Clockwork.player:FindByID(arguments[1])
		if target then
			Clockwork.player:Notify(player, {"PlayerHasProtectionStatus", target:Name()})
		else
			Clockwork.player:Notify(player, {"PlayerHasProtectionOffline"})
		end
	end

	if !duration then
		Clockwork.player:Notify(player, {"DurationNotValid"})
		return
	end
	addBan(string.upper(arguments[1]), duration * 60, reason, function(steamName, duration, reason)
		if !IsValid(player) then return end
		if !steamName then
			Clockwork.player:Notify(player, {"IdentifierIsNotValid", steamName})
			return
		end
		if duration <= 0 then
			Clockwork.player:NotifyAll({"PlayerBannedPlayerPerma", player:Name(), steamName, reason})
			return
		end
		local hours = math.Round(duration / 3600)
		if hours >= 1 then
			Clockwork.player:NotifyAll({"PlayerBannedPlayerHours", player:Name(), steamName, hours, reason})
			return
		end
		Clockwork.player:NotifyAll({"PlayerBannedPlayerMinutes", player:Name(), steamName, math.Round(duration / 60), reason})
	end)
end

COMMAND:Register()

--[[-------------------------------------------------------------------------
Replace default plyUnban command
---------------------------------------------------------------------------]]

COMMAND = Clockwork.command:New("PlyUnban")

COMMAND.tip = "Unban a Steam ID from the server."
COMMAND.text = "<string SteamID|IPAddress>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playersTable = Clockwork.config:Get("mysql_players_table"):Get()
	local schemaFolder = Clockwork.kernel:GetSchemaFolder()
	local identifier = string.upper(arguments[1])
	
	if Clockwork.bans.stored[identifier] then
		Clockwork.player:NotifyAll({"PlayerUnbannedPlayer", player:Name(), Clockwork.bans.stored[identifier].steamName})
		removeBan(identifier)
		return
	end
	Clockwork.player:Notify(player, {"ThereAreNoBannedPlayersWithID", identifier})
end

COMMAND:Register()

end)
