GhostBan = GhostBan or {}
GhostBan.ghosts = GhostBan.ghosts or {}

local function timeToString(time)
	if time == 0 then 
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
	if time >= 0 then -- seconds
		returnString = returnString .. " " .. time .. " " .. GhostBan.Translation[GhostBan.Language]["seconds"]
	end 
	return string.TrimLeft(returnString)
end

local function parseText(text, time, reason)
	local ply = LocalPlayer()
	text = string.Replace(text, "{nick}", ply:Nick())
	text = string.Replace(text, "{steamid}", ply:SteamID())
	text = string.Replace(text, "{steamid64}", ply:SteamID64())
	if time then
		text = string.Replace(text, "{timeleft}", timeToString(time))
	end
	if reason then
		text = string.Replace(text, "{reason}", reason)
	end
	return text
end

local function ghostYourself(time, reason)
	-- diplay beautiful hud
	if reason ~= "" then
		local scrh = ScrH()
		local scrw = ScrW()
		surface.CreateFont("GhostBan_Font", {
			font = "Arial",
			size = 40
		})
		hook.Add("HUDPaint", "GhostBan_HUD", function()
			draw.RoundedBox(0, 0, scrh * 0.82, scrw, scrh * 0.28, Color(0,0,0,220))
			draw.SimpleText(parseText(GhostBan.Translation[GhostBan.Language]["urban1"], time, reason), "GhostBan_Font", scrw * 0.5, scrh * 0.84, Color(255,255,255), TEXT_ALIGN_CENTER)
			draw.SimpleText(parseText(GhostBan.Translation[GhostBan.Language]["urban2"], time, reason), "GhostBan_Font", scrw * 0.5, scrh * 0.89, Color(255,40,40), TEXT_ALIGN_CENTER)
			draw.SimpleText(parseText(GhostBan.Translation[GhostBan.Language]["urban3"], time, reason), "GhostBan_Font", scrw * 0.5, scrh * 0.94, Color(255,255,255), TEXT_ALIGN_CENTER)
		end)
	end
	if time > 0 then
		timer.Create("GhostBan_TimeCooldown", 1, 0, function()
			if time == 0 then
				hook.Remove("HUDPaint", "GhostBan_HUD")
				hook.Remove("Think", "GhostBan_ThinkDifferent")
				hook.Remove("OnSpawnMenuOpen", "GhostBan_NoProps4U")
				hook.Remove("ContextMenuOpen", "GhostBan_NoContext4U")
				hook.Remove("PlayerStartVoice", "GhostBan_MuteNotify")
				hook.Remove("HUDShouldDraw", "GhostBan_NoHUD4U")
				return
			end
			time = time - 1
		end)
	end
	-- ghost player...

	-- can't quit
	if !GhostBan.CanOpenGameMenu then
		hook.Add("Think", "GhostBan_ThinkDifferent", function()
			gui.HideGameUI()
		end)
	end

	local function preventSomething() return false end
	-- can't open menu
	if !GhostBan.CanOpenContextMenu then
		hook.Add("OnSpawnMenuOpen", "GhostBan_NoProps4U", preventSomething)
	end

	-- can't open context menu
	if !GhostBan.CanOpenPropsMenu then
		hook.Add("ContextMenuOpen", "GhostBan_NoContext4U", preventSomething)
	end

	-- know they're mute
	if !GhostBan.CanTalkVoice then
		hook.Add("PlayerStartVoice", "GhostBan_MuteNotify", function(ply)
			if ply == LocalPlayer() then
				chat.AddText(parseText(GhostBan.Translation[GhostBan.Language]["mute"]))
			end
		end)
	end
end

net.Receive("ghost_ban_net",function()
	local mode = net.ReadUInt(2)
	if mode == 0 then
		local reason = ""
		if GhostBan.DisplayReason then
			reason = util.Decompress(net.ReadData(net.ReadUInt(16)))
		end
		local time = net.ReadUInt(16)
		ghostYourself(time, reason)
	elseif mode == 1 then
		if timer.Exists("GhostBan_TimeCooldown") then
			timer.Remove("GhostBan_TimeCooldown")
		end
		hook.Remove("HUDPaint", "GhostBan_HUD")
		hook.Remove("Think", "GhostBan_ThinkDifferent")
		hook.Remove("OnSpawnMenuOpen", "GhostBan_NoProps4U")
		hook.Remove("ContextMenuOpen", "GhostBan_NoContext4U")
		hook.Remove("PlayerStartVoice", "GhostBan_MuteNotify")
		hook.Remove("HUDShouldDraw", "GhostBan_NoHUD4U")
	elseif mode == 2 then
		if net.ReadBool() then
			GhostBan.ghosts[Entity(net.ReadUInt(7) + 1)] = true
		else
			GhostBan.ghosts[Entity(net.ReadUInt(7) + 1)] = nil
		end
	elseif mode == 3 then
		local settings = net.ReadTable()
		GhostBan.CanHurt = settings[1]
		GhostBan.CanSpawnProps = settings[2]
		GhostBan.CanProperty = settings[3]
		GhostBan.CanTalkVoice = settings[4]
		GhostBan.CanTalkChat = settings[5]
		GhostBan.Loadouts = settings[6]
		GhostBan.CanPickupItem = settings[7]
		GhostBan.CanPickupWep = settings[8]
		GhostBan.CanEnterVehicle = settings[9]
		GhostBan.CanSuicide = settings[10]
		GhostBan.CanCollide = tonumber(settings[11])
		GhostBan.DisplayReason = settings[12]
		GhostBan.CanOpenContextMenu = settings[13]
		GhostBan.CanOpenPropsMenu = settings[14]
		GhostBan.CanOpenGameMenu = settings[15]
		GhostBan.DisplayCyanGhost = settings[16]
		GhostBan.ReplaceULXBan = settings[17]
		GhostBan.Language = settings[18]
		GhostBan.ReplaceULXBan = settings[19]
		GhostBan.CanTool = settings[20]

		-- ghost can't collide
		if GhostBan.CanCollide ~= 2 then
			hook.Add("ShouldCollide", "GhostBan_CantTouchThis", function(ent1, ent2)
				if GhostBan.ghosts[ent1] || GhostBan.ghosts[ent2] then
					if GhostBan.CanCollide then
						return false
					elseif ent1:IsPlayer() && ent2:IsPlayer() then
						return false
					end
				end
			end)
		else
			hook.Remove("ShouldCollide", "GhostBan_CantTouchThis")
		end
		if GhostBan.DisplayCyanGhost then
			surface.CreateFont("GhostBan_PlyFont", {
				font = "Arial",
				size = 200,
				weight = 625
			})
			hook.Add("PostPlayerDraw", "GhostBan_MarkTheGhost", function(ply)
				if GhostBan.ghosts[ply] && IsValid(ply) && ply ~= LocalPlayer() && ply:GetPos():DistToSqr(LocalPlayer():GetPos()) < 500000 then
					local _, plyHeight = ply:GetModelRenderBounds()
					local plyPos = ply:GetPos() + Vector(0, 0, plyHeight.z + 12)
					cam.Start3D2D(plyPos, Angle(0, EyeAngles().y - 90, 90), 0.09)
						draw.DrawText(GhostBan.Translation[GhostBan.Language]["ghostText"], "GhostBan_PlyFont", 0, 0, Color(25, 255, 255), TEXT_ALIGN_CENTER)
					cam.End3D2D()
				end
			end)
		else
			hook.Remove("PostPlayerDraw", "GhostBan_MarkTheGhost")
		end
	end
end)