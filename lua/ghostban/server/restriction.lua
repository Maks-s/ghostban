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
	hook.Add("PlayerSay", "GhostBan_MutePlayer", function(sender, text)
		if GhostBan.ghosts[sender] then return "" end
	end, 2)

	hook.Add("DarkRPFinishedLoading","GhostBan_DetourFAdminCommand",function()
		timer.Simple(1, function() -- detour admin command
			local defaultAdmin = FAdmin.Commands.List["//"] and FAdmin.Commands.List["//"].callback
			if not defaultAdmin then return end
			local function detour(ply, cmd, args)
				if GhostBan.ghosts[ply] then return true end
				return defaultAdmin(ply, cmd, args)
			end
			FAdmin.Commands.List["//"].callback = detour
			FAdmin.Commands.List["adminhelp"].callback = detour
		end)
	end)
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

if not GhostBan.canChangeJob then
	hook.Add("playerCanChangeTeam", "GhostBan_CantChangeJob",function(ply, jobName)
		if GhostBan.ghosts[ply] then
			return false, "Ghosts are ghosts, not " .. team.GetName(jobName)
		end
	end)
end

if GhostBan.setPos ~= Vector() then
	hook.Add("PlayerSpawn","GhostBan_ReturnToPos",function(ply)
		timer.Simple(0, function() -- prevent bug
			if GhostBan.ghosts[ply] then
				ply:SetPos(GhostBan.setPos)
			end
		end)
	end)
end
