util.AddNetworkString("ghost_ban_net")
GhostBan = GhostBan or {}
GhostBan.ghosts = GhostBan.ghosts or {}

local function loadConfig(settings)
	if settings then
		GhostBan.CanHurt = settings["hurt"]
		GhostBan.CanSpawnProps = settings["spawnprop"]
		GhostBan.CanProperty = settings["property"]
		GhostBan.CanTool = settings["tool"]
		GhostBan.CanTalkVoice = settings["voice"]
		GhostBan.CanTalkChat = settings["tChat"]
		GhostBan.Loadouts = settings["loadout"]
		GhostBan.CanPickupItem = settings["item"]
		GhostBan.CanPickupWep = settings["wep"]
		GhostBan.CanEnterVehicle = settings["vehicle"]
		GhostBan.CanSuicide = settings["suicide"]
		GhostBan.CanCollide = settings["collide"]
		GhostBan.DisplayReason = settings["lowHud"]
		GhostBan.CanOpenContextMenu = settings["mContext"]
		GhostBan.CanOpenPropsMenu = settings["mProps"]
		GhostBan.CanOpenGameMenu = settings["mGame"]
		GhostBan.DisplayCyanGhost = settings["ghostText"]
		GhostBan.Language = settings["lang"]
		GhostBan.freezeGhost = settings["freezer"]
		GhostBan.jailMode = settings["jailmode"]
		GhostBan.CantSeeMe = settings["seeme"]
		GhostBan.material = settings["material"]
		-- GhostBan.SuperHot = settings["superhot"]
		GhostBan.percentKick = tonumber(settings["kPercent"])
		if settings["repDEF"] then
			GhostBan.replaceDefBan = settings["repDEF"]
		end
		if settings["changejob"] then
			GhostBan.canChangeJob = settings["changejob"]
		end
		file.Write("ghostban_config.txt", util.TableToJSON(GhostBan))
		if #player.GetHumans() == 0 then return end
		net.Start("ghost_ban_net")
		net.WriteUInt(3,2)
		net.WriteTable({
			GhostBan.CanHurt,
			GhostBan.CanSpawnProps,
			GhostBan.CanProperty,
			GhostBan.CanTalkVoice,
			GhostBan.CanTalkChat,
			GhostBan.Loadouts,
			GhostBan.CanPickupItem,
			GhostBan.CanPickupWep,
			GhostBan.CanEnterVehicle,
			GhostBan.CanSuicide,
			GhostBan.CanCollide,
			GhostBan.DisplayReason,
			GhostBan.CanOpenContextMenu,
			GhostBan.CanOpenPropsMenu,
			GhostBan.CanOpenGameMenu,
			GhostBan.DisplayCyanGhost,
			GhostBan.Language,
			GhostBan.replaceDefBan,
			GhostBan.CanTool,
			GhostBan.freezeGhost,
			GhostBan.jailMode,
			GhostBan.canChangeJob,
			GhostBan.CantSeeMe,
			GhostBan.material,
			GhostBan.percentKick,
			-- GhostBan.SuperHot
		})
		net.Broadcast()
	else
		if file.Exists("ghostban_config.txt","DATA") then
			local settings = util.JSONToTable(file.Read("ghostban_config.txt"))
			if settings.ghosts then settings.ghosts = nil end
			table.Merge(GhostBan, settings)
		end
	end
end
loadConfig()

hook.Add("PlayerInitialSpawn","GhostBan_PISCheck",function(ply)
	local timeToBan, reason
	if ULib && !GhostBan.jailMode then
		local banData = ULib.bans[ ply:SteamID() ]
		if !banData then return end -- not banned
		if banData.unban && tonumber(banData.unban) > 0 then
			timeToBan = tonumber(banData.unban) - os.time()
		end
		reason = banData.reason
	elseif Clockwork && !GhostBan.jailMode then
		local banData = Clockwork.bans.stored[ply:IPAddress()] || Clockwork.bans.stored[ply:SteamID()]
		if !banData then return end -- not banned
		if banData.unbanTime && tonumber(banData.unbanTime) > 0 then
			timeToBan = tonumber(banData.unban) - os.time()
		end
		reason = banData.reason
	else
		local banData = GhostBan.bans[ ply:SteamID() ]
		if !banData then return end -- not banned
		if banData.unban && tonumber(banData.unban) > 0 then
			timeToBan = tonumber(banData.unban) - os.time()
			if timeToBan <= 0 then
				GhostBan.bans[ply:SteamID()] = nil
				file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))
				return
			end
		end
		reason = banData.reason
	end
	local ghostSentence = GhostBan.Translation[GhostBan.Language]["ghostingS"]
	ghostSentence = string.Replace(ghostSentence, "{nick}", ply:Nick())
	ghostSentence = string.Replace(ghostSentence, "{steamid}", ply:SteamID())
	ghostSentence = string.Replace(ghostSentence, "{steamid64}", ply:SteamID64())
	Msg(ghostSentence)
	ply:Ghostban(false, timeToBan, reason)
end)

hook.Add("Initialize", "GhostBan_HookInit", function()
	if ULib && !GhostBan.jailMode then
		hook.Remove("CheckPassword", "ULibBanCheck")
		hook.Add("ULibPlayerBanned", "GhostBan_RemoveSourceBan", function(steamid)
			game.ConsoleCommand("removeid " .. steamid .. ";writeid\n")
		end)
	elseif Clockwork && !GhostBan.jailMode then
		GAMEMODE.CheckPassword = function() end
	else
		if file.Exists("ghostban_bans.txt", "DATA") then
			GhostBan.bans = util.JSONToTable( file.Read("ghostban_bans.txt") ) or {}
		else
			GhostBan.bans = {}
		end
	end
end)

timer.Create("GhostBan_CheckGhostsTMR", 1, 0, function()
	for ply, time in pairs(GhostBan.ghosts) do
		if time == 1 || time < 0 then
			GhostBan.ghosts[ply] = nil
			if !ULib || !Clockwork then
				GhostBan.bans[ply:SteamID()] = nil
				file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))
			end
			ply:Ghostban(true)
			continue
		elseif time == 0 then
			continue
		end
		GhostBan.ghosts[ply] = time - 1
	end
end)

hook.Add("PlayerAuthed", "GhostBan_TellEmSettings", function(ply)
	net.Start("ghost_ban_net")
	net.WriteUInt(3,2)
	net.WriteTable({
		GhostBan.CanHurt,
		GhostBan.CanSpawnProps,
		GhostBan.CanProperty,
		GhostBan.CanTalkVoice,
		GhostBan.CanTalkChat,
		GhostBan.Loadouts,
		GhostBan.CanPickupItem,
		GhostBan.CanPickupWep,
		GhostBan.CanEnterVehicle,
		GhostBan.CanSuicide,
		GhostBan.CanCollide,
		GhostBan.DisplayReason,
		GhostBan.CanOpenContextMenu,
		GhostBan.CanOpenPropsMenu,
		GhostBan.CanOpenGameMenu,
		GhostBan.DisplayCyanGhost,
		GhostBan.Language,
		GhostBan.replaceDefBan,
		GhostBan.CanTool,
		GhostBan.freezeGhost,
		GhostBan.jailMode,
		GhostBan.canChangeJob,
		GhostBan.CantSeeMe,
		GhostBan.material,
		GhostBan.percentKick,
		-- GhostBan.SuperHot,
	})
	net.Send(ply)
end)

net.Receive("ghost_ban_net", function(_, ply)
	if !ply:IsAdmin() then return end
	loadConfig(net.ReadTable())
end)