GhostBan = GhostBan or {}
GhostBan.ghosts = GhostBan.ghosts or {}

local meta = FindMetaTable("Player")

function meta:Ghostban(unghost, time, reason)
	net.Start("ghost_ban_net")
	if !unghost then
		net.WriteUInt(0,2)
		if GhostBan.DisplayReason then -- don't send reason when we don't need it
			local compReason = util.Compress( (reason && reason ~= "") && reason || GhostBan.Translation[GhostBan.Language]["noreason"] )
			net.WriteUInt(string.len(compReason), 16)
			net.WriteData(compReason, string.len(compReason))
		end
		if !time || !isnumber(time) || time < 0 then
			time = 0
		end
		GhostBan.ghosts[self] = time
		net.WriteUInt(time, 16)
		net.Send(self)
		if !GhostBan.Loadouts then
			self:StripWeapons()
		end
		if self:GetCustomCollisionCheck() then -- don't want to messup others addons with customCollisionCheck
			self.ghostbanCustColl = true
		else
			self:SetCustomCollisionCheck(true)
		end
		if !self:GetAvoidPlayers() then
			self.ghostbanAvoPly = true
		else
			self:SetAvoidPlayers(false)
		end
		net.Start("ghost_ban_net")
		net.WriteUInt(2,2)
		net.WriteBool(true)
		net.WriteUInt(self:EntIndex() - 1,7)
		net.Broadcast()
		self:SetMaterial("models/props_combine/portalball001_sheet")
	else
		GhostBan.ghosts[self] = nil
		net.WriteUInt(1,2)
		net.Send(self)
		net.Start("ghost_ban_net")
		net.WriteUInt(2,2)
		net.WriteBool(false)
		net.WriteUInt(self:EntIndex() - 1,7)
		net.Broadcast()
		if !GhostBan.Loadouts then
			hook.Run("PlayerLoadout", self)
		end
		if self.ghostbanAvoPly then
			self.ghostbanAvoPly = nil
		else
			self:SetAvoidPlayers(true)
		end
		if self.ghostbanCustColl then
			self.ghostbanCustColl = nil
			return
		end
		self:SetCustomCollisionCheck(false)
		self:SetMaterial()
	end
end

hook.Add("PlayerConnect", "GhostBan_APlayerIsJoining", function()
	if #player.GetAll() + 2 >= game.MaxPlayers() then
		GhostBan.ghosts[math.random(#GhostBan.ghosts)]:Kick(GhostBan.Translation[GhostBan.Language]["TooMuch4U"])
	end
end)