concommand.Add("ghostban_setpos", function(ply)
	if !ply:IsAdmin() then return end
	GhostBan.setPos = ply:GetPos() + Vector(0,0,5)
	ply:PrintMessage(HUD_PRINTCONSOLE,"Position set")
end)

concommand.Add("ghostban_unsetpos",function(ply)
	if !ply:IsAdmin() then return end
	GhostBan.setPos = Vector()
	ply:PrintMessage(HUD_PRINTCONSOLE,"Position unset")
end)

if file.Exists("ulib","LUA") then return end
if file.Exists("gamemodes/clockwork","GAME") || Clockwork then return end

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
	return string.TrimLeft(returnString)
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
	if text == "!ghostban" then
		ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["ban_usage"])
		return
	elseif text == "!unghostban" then
		ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["unban_usage"])
		return
	end
	if string.StartWith(text, "!ghostban ") then 
		ply:ConCommand("gh_ban"..string.TrimLeft(text,"!ghostban"))
	elseif string.StartWith(text, "!unban ") then
		ply:ConCommand("gh_unban"..string.TrimLeft(text,"!unghostban"))		
	end
end)

concommand.Add("gh_ban", function(ply, _, args, argStr)
	if IsValid(ply) && !ply:IsAdmin() then return end
	if #args == 0 then
		if IsValid(ply) then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["ban_usage"])
		else
			Msg(GhostBan.Translation[GhostBan.Language]["ghban_usage"] .. "\n")
		end
		return
	end
	local target_ply
	for _, v in pairs(player.GetHumans()) do
		if string.lower(v:Nick()):find(args[1]) then
			target_ply = v
			break
		end
	end
	if !IsValid(target_ply) then
		if IsValid(ply) then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["404"])
		else
			Msg(GhostBan.Translation[GhostBan.Language]["404"] .. "\n")
		end
		return
	end
	local time = args[2]
	if !time then
		time = 0
		args[2] = ""
	else
		time = tonumber(time) * 60
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
	PrintMessage(HUD_PRINTTALK, parseText(finalStr, time, tReason, (IsValid(ply)) && ply:Nick() || "Console", target_ply:Nick()) )
end)

concommand.Add("gh_unban", function(ply, _, args)
	if IsValid(ply) && !ply:IsAdmin() then return end
	if #args ~= 1 then
		if IsValid(ply) then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["unban_usage"])
		else
			Msg(GhostBan.Translation[GhostBan.Language]["ghunban_usage"] .. "\n")
		end
		return
	end
	local target_ply
	for _, v in pairs(player.GetHumans()) do
		if string.lower(v:Nick()):find(args[1]) then
			target_ply = v
			break
		end
	end
	if !IsValid(target_ply) then
		if IsValid(ply) then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["404"])
		else
			Msg(GhostBan.Translation[GhostBan.Language]["404"] .. "\n")
		end
		return
	end
	if !GhostBan.ghosts[target_ply] then
		if IsValid(ply) then
			ply:ChatPrint(GhostBan.Translation[GhostBan.Language]["404"])
		else
			Msg(GhostBan.Translation[GhostBan.Language]["404"] .. "\n")
		end
		return
	end
	GhostBan.bans[target_ply:SteamID()] = nil
	file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))
	target_ply:Ghostban(true)
	PrintMessage(HUD_PRINTTALK, parseText("{caller} unbanned {target}", nil, nil, (IsValid(ply)) && ply:Nick() || "Console", target_ply:Nick() ) )
end)