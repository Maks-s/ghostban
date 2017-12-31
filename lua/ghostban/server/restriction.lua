GhostBan = GhostBan or {}
GhostBan.ghosts = GhostBan.ghosts or {}

-- ghost player...

-- can't hurt
if !GhostBan.CanHurt then
	hook.Add("EntityTakeDamage", "GhostBan_NoHurting", function(_, dmginfo)
		local attacker = dmginfo:GetAttacker()
		if attacker && GhostBan.ghosts[attacker] then return true end
	end)
end

-- can't spawn anything
if !GhostBan.CanSpawnProps then
	hook.Add("PlayerSpawnEffect", "GhostBan_NoSpawn", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
	hook.Add("PlayerSpawnNPC", "GhostBan_NoSpawn", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
	hook.Add("PlayerSpawnObject", "GhostBan_NoSpawn", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
	hook.Add("PlayerSpawnProp", "GhostBan_NoSpawn", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
	hook.Add("PlayerSpawnRagdoll", "GhostBan_NoSpawn", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
	hook.Add("PlayerSpawnSENT", "GhostBan_NoSpawn", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
	hook.Add("PlayerSpawnSWEP", "GhostBan_NoSpawn", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
	hook.Add("PlayerSpawnVehicle", "GhostBan_NoSpawn", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
end

-- can't property
if !GhostBan.CanProperty then
	hook.Add("CanProperty", "GhostBan_NoProperty", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
end

-- can't toolgun
if !GhostBan.CanTool then
	hook.Add("CanTool", "GhostBan_NoTool", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
end

-- can't talk
if !GhostBan.CanTalkVoice then
	hook.Add("PlayerCanHearPlayersVoice", "GhostBan_MuteGhost", function(listener, talker)
		if GhostBan.ghosts[talker] then return false end
	end)
end
if !GhostBan.CanTalkChat then
	hook.Add("PlayerSay", "GhostBan_MutePlayer", function(sender)
		if GhostBan.ghosts[sender] then return "" end
	end, HOOK_LOW)
end

-- don't have weapons
if !GhostBan.Loadouts then
	hook.Add("PlayerLoadout", "GhostBan_DefenselessGhost", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
end

-- can't pickup things
if !GhostBan.CanPickupItem then
	hook.Add("PlayerCanPickupItem", "GhostBan_NoPickyGhost", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
end
if !GhostBan.CanPickupWep then
	hook.Add("PlayerCanPickupWeapon", "GhostBan_DefenselessGhost", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
end

-- can't enter vehicles
if !GhostBan.CanEnterVehicle then
	hook.Add("PlayerEnteredVehicle", "GhostBan_GhostCantDrive", function(ply)
		if GhostBan.ghosts[ply] then
			ply:ExitVehicle()
		end
	end)
end

-- can't suicide
if !GhostBan.CanSuicide then
	hook.Add("CanPlayerSuicide", "GhostBan_GhostsAreAlreadyDead", function(ply)
		if GhostBan.ghosts[ply] then return false end
	end)
end

-- disappear when disconnect
hook.Add("PlayerDisconnected", "GhostBan_NoGhostNoKey", function(ply)
	if GhostBan.ghosts[ply] then GhostBan.ghosts[ply] = nil end
end)

-- can't collide
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
end

if !GhostBan.canChangeJob && DarkRP then
	hook.Add("playerCanChangeTeam", "GhostBan_CantChangeJob",function(ply, jobName)
		if GhostBan.ghosts[ply] then
			return false, "Ghosts are ghosts, not " .. team.GetName(jobName)
		end
	end)
end