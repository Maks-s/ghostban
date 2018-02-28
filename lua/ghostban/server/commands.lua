concommand.Add("ghostban_setpos", function(ply)
	if !ply:IsAdmin() then return end
	GhostBan.setPos = ply:GetPos() + Vector(0,0,5)
	file.Write("ghostban_config.txt", util.TableToJSON(GhostBan))
	ply:PrintMessage(HUD_PRINTCONSOLE,"Position set")
end)

concommand.Add("ghostban_unsetpos",function(ply)
	if !ply:IsAdmin() then return end
	GhostBan.setPos = Vector()
	file.Write("ghostban_config.txt", util.TableToJSON(GhostBan))
	ply:PrintMessage(HUD_PRINTCONSOLE,"Position unset")
end)

if file.Exists("ulib","LUA") then return end
-- You don't use ulx eh ? Well we don't need it after all

GhostBan = GhostBan or {}
GhostBan.bans = GhostBan.bans or {}

local function timeToString(time)
	if time <= 0 then 
		return GhostBan.Translation[GhostBan.Language]["eternity"]
	end
	local returnString = ""
	if time >= 31536000 then -- years
		returnString = math.floor(time / 31536000) .. " " .. GhostBan.Translation[GhostBan.Language]["year"]
		time = time % 31536000
	end
	if time >= 86400 then -- days
		returnString = returnString .. " " .. math.floor(time / 86400) .. " " .. GhostBan.Translation[GhostBan.Language]["days"]
		time = time % 86400
	end
	if time >= 3600 then -- hours
		returnString = returnString .. " " .. math.floor(time / 3600) .. " " .. GhostBan.Translation[GhostBan.Language]["hours"]
		time = time % 3600
	end
	if time >= 60 then -- minutes
		returnString = returnString .. " " .. math.floor(time / 60) .. " " .. GhostBan.Translation[GhostBan.Language]["minutes"]
		time = time % 60
	end
	if time > 0 then -- seconds
		returnString = returnString .. " " .. time .. " " .. GhostBan.Translation[GhostBan.Language]["seconds"]
	end 
	return string.Trim(returnString)
end

local function parseText(text, time, reason, callingNick, targetNick)
	if time then
		text = string.Replace(text, "{time}", timeToString(time))
	end
	if reason then
		text = string.Replace(text, "{reason}", reason)
	end
	if callingNick then
		text = string.Replace(text, "{caller}", callingNick)
	end
	if targetNick then
		text = string.Replace(text, "{target}", targetNick)
	end
	return text
end

hook.Add("PlayerSay", "GhostBan_ChattyPlayer", function(ply, text)
	text = string.Trim(text)
	if text == "!ban" then
		ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["ban_usage"])
		return
	elseif text == "!unban" then
		ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["unban_usage"])
		return
	end
	if string.StartWith(text, "!ban ") then 
		ply:ConCommand("gh_ban"..string.TrimLeft(text,"!ban"))
	elseif string.StartWith(text, "!unban ") then
		ply:ConCommand("gh_unban"..string.TrimLeft(text,"!unban"))		
	end
end)

concommand.Add("gh_ban", function(ply, _, args, argStr)
	if ply:IsValid() && !ply:IsAdmin() then return end
	if #args == 0 then
		if IsValid(ply) then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["ban_usage"])
		else
			print(GhostBan.Translation[GhostBan.Language]["ghban_usage"])
		end
		return
	end

	args[1] = args[1]:lower()
	
	local target_ply
	local plys = player.GetHumans()
	for i=1, #plys do
		if string.lower(plys[i]:Nick()):find(args[1]) then
			target_ply = plys[i]
			break
		end
	end
	if !IsValid(target_ply) then
		if IsValid(ply) then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["404"])
		else
			print(GhostBan.Translation[GhostBan.Language]["404"])
		end
		return
	end
	local time = args[2]
	if time then
		time = tonumber(time) * 60
	else
		time = 0
		args[2] = ""
	end
	local tReason = string.Trim(string.Replace(string.Implode(" ",args), args[1] .. " " ..args[2]))

	if !tReason || tReason == "" then 
		tReason = GhostBan.Translation[GhostBan.Language]["noreason"]
	end
	GhostBan.bans[target_ply:SteamID()] = {
		unban = (time == 0) && 0 || os.time() + time,
		reason = tReason
	}
	file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))
	target_ply:Ghostban(false, time, tReason)
	local finalStr = "(GhostBan) {caller} banned {target}"
	if time > 0 then 
		finalStr = finalStr .. " for {time}"
	else
		finalStr = finalStr .. " permanently"
	end
	if tReason && tReason ~= "" then finalStr = finalStr .. " ({reason})" end

	local textToDisplay = parseText(finalStr, time, tReason, (IsValid(ply)) && ply:Nick() || "Console", target_ply:Nick())
	PrintMessage(HUD_PRINTTALK, textToDisplay)
	print(textToDisplay)
end)

concommand.Add("gh_unban", function(ply, _, args)
	if ply:IsValid() && !ply:IsAdmin() then return end
	if #args ~= 1 then
		if IsValid(ply) then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["unban_usage"])
		else
			print(GhostBan.Translation[GhostBan.Language]["ghunban_usage"])
		end
		return
	end

	args[1] = args[1]:lower()

	local target_ply
	local plys = player.GetHumans()
	for i=1, #plys do
		if string.lower(plys[i]:Nick()):find(args[1]) then
			target_ply = plys[i]
			break
		end
	end
	if !target_ply then
		if ply:IsValid() then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["404"])
		else
			print(GhostBan.Translation[GhostBan.Language]["404"])
		end
		return
	end
	if !GhostBan.ghosts[target_ply] then
		if IsValid(ply) then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["404"])
		else
			print(GhostBan.Translation[GhostBan.Language]["404"])
		end
		return
	end
	GhostBan.bans[target_ply:SteamID()] = nil
	file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))
	target_ply:Ghostban(true)

	local textToDisplay = parseText("{caller} unbanned {target}", nil, nil, (IsValid(ply)) && ply:Nick() || "Console", target_ply:Nick() )
	PrintMessage(HUD_PRINTTALK, textToDisplay)
	print(textToDisplay)
end)

concommand.Add("gh_banid", function(ply, _, args, argStr)
	if ply:IsValid() and not ply:IsSuperAdmin() then return end
	if #args == 0 then
		if ply:IsValid() then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["ghbanid_usage"])
		else
			print(GhostBan.Translation[GhostBan.Language]["ghbanid_usage"])
		end
		return
	end

	args[1] = (args[1]):upper()

	if not args[1]:match( "^STEAM_%d:%d:%d+$" ) then
		if ply:IsValid() then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["invalidSteamid"])
		else
			print(GhostBan.Translation[GhostBan.Language]["invalidSteamid"])
		end
		return
	end

	local time = args[2]
	if time then
		time = tonumber(time) * 60
	else
		time = 0
		args[2] = ""
	end
	local tReason = string.Trim(string.Replace(string.Implode(" ",args), args[1] .. " " ..args[2]))

	if not tReason or tReason == "" then
		tReason = GhostBan.Translation[GhostBan.Language]["noreason"]
	end

	GhostBan.bans[args[1]] = {
		unban = (time == 0) && 0 || os.time() + time,
		reason = tReason
	}
	file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))

	local plys = player.GetHumans()
	for i=1, #plys do
		if plys[i]:SteamID() == args[1] then
			plys[i]:Ghostban(false, time, tReason)
			break
		end
	end

	local finalStr = "(GhostBan) {caller} banned steamid {target}"
	if time > 0 then 
		finalStr = finalStr .. " for {time}"
	else
		finalStr = finalStr .. " permanently"
	end
	if tReason && tReason ~= "" then finalStr = finalStr .. " ({reason})" end
	local textToDisplay = parseText(finalStr, time, tReason, ply:IsValid() && ply:Nick() || "Console", args[1])
	PrintMessage(HUD_PRINTTALK, textToDisplay)
	print(textToDisplay)
end)

concommand.Add("gh_unbanid", function(ply, _, args)
	if ply:IsValid() and not ply:IsSuperAdmin() then return end
	if #args == 0 then
		if ply:IsValid() then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["unghbanid_usage"])
		else
			print(GhostBan.Translation[GhostBan.Language]["unghbanid_usage"])
		end
		return
	end

	args[1] = args[1]:upper()
	if not args[1]:match( "^STEAM_%d:%d:%d+$" ) then
		if ply:IsValid() then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["invalidSteamid"])
		else
			print(GhostBan.Translation[GhostBan.Language]["invalidSteamid"])
		end
		return
	end

	GhostBan.bans[args[1]] = nil
	file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))

	local plys = player.GetHumans()
	for i=1, #plys do
		if plys[i]:SteamID() == args[1] then
			plys[i]:Ghostban(true)
			break
		end
	end
	if tReason and tReason ~= "" then finalStr = finalStr .. " ({reason})" end

	local textToDisplay = parseText("(GhostBan) {caller} unbanned steamid {target}", nil, nil, ply:IsValid() && ply:Nick() || "Console", args[1])
	PrintMessage(HUD_PRINTTALK, textToDisplay)
	print(textToDisplay)
end)