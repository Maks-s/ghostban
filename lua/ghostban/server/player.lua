GhostBan = GhostBan or {}
GhostBan.ghosts = GhostBan.ghosts or {}

local meta = FindMetaTable("Player")

function meta:Ghostban(unghost, time, reason)
	if !unghost then
		local ghostSentence = GhostBan.Translation[GhostBan.Language]["ghostingS"]
		ghostSentence = string.Replace(ghostSentence, "{nick}", self:Nick())
		ghostSentence = string.Replace(ghostSentence, "{steamid}", self:SteamID())
		ghostSentence = string.Replace(ghostSentence, "{steamid64}", self:SteamID64())
		print(ghostSentence)
		if !GhostBan.jailMode && GhostBan.percentKick ~= 0 && #player.GetAll() / game.MaxPlayers() >= GhostBan.percentKick / 100 then
			self:Kick("You're banned for the following reason :\n" .. (reason || GhostBan.Translation[GhostBan.Language]["TooMuch4U"]))
			return
		end
		net.Start("ghost_ban_net")
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
		net.WriteUInt(time, 32)
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
		if GhostBan.freezeGhost then
			self:Freeze(true)
		end
		net.Start("ghost_ban_net")
		net.WriteUInt(2,2)
		net.WriteBool(true)
		net.WriteUInt(self:EntIndex() - 1,7)
		net.Broadcast()
		if !(GhostBan.material == "" || GhostBan.CantSeeMe) then
			self:SetMaterial(GhostBan.material)
		end
		if GhostBan.CantSeeMe then
			self:DrawShadow(false)
		end
		if GhostBan.setPos ~= Vector() then
			self:SetPos(GhostBan.setPos)
		end
	else
		GhostBan.ghosts[self] = nil
		net.Start("ghost_ban_net")
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
		if GhostBan.CantSeeMe then
			self:DrawShadow(true)
		end
		if self.ghostbanCustColl then
			self.ghostbanCustColl = nil
			return
		end
		if GhostBan.freezeGhost && self:IsFlagSet(FL_FROZEN) then
			self:Freeze(false)
		end
		self:SetCustomCollisionCheck(false)
		if !(GhostBan.material == "" || GhostBan.CantSeeMe) then
			self:SetMaterial()
		end
		if GhostBan.setPos ~= Vector() then
			self:Respawn()
		end
	end
end

hook.Add("PlayerConnect", "GhostBan_APlayerIsJoining", function()
	if table.Count(GhostBan.ghosts) > 0 && !GhostBan.jailMode && GhostBan.percentKick ~= 0 && #player.GetAll() / game.MaxPlayers() >= GhostBan.percentKick / 100 then
		local _, victim = table.Random(GhostBan.ghosts)
		victim:Kick(GhostBan.Translation[GhostBan.Language]["TooMuch4U"])
	end
end)

if GhostBan.percentKick ~= 0 then
	hook.Add("CheckPassword","GhostBan_CheckP455w0rd", function(steamid64)
		if #player.GetAll() / game.MaxPlayers() <= GhostBan.percentKick / 100 then return end
		if ULib then
			local banData = ULib.bans[ util.SteamIDFrom64(steamid64) ]
			if !banData then return end
			reason = banData.reason || GhostBan.Translation[GhostBan.Language]["TooMuch4U"]
		else
			local banData = GhostBan.bans[ util.SteamIDFrom64(steamid64) ]
			if !banData then return end
			reason = banData.reason || GhostBan.Translation[GhostBan.Language]["TooMuch4U"]
		end
		return false, "You're banned for the following reason :\n" .. reason
	end)
end