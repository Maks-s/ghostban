GhostBan = GhostBan or {}

local function escapeOrNull( str )
	if !str then 
		return "NULL"
	else 
		return sql.SQLStr(str) 
	end
end

--[[-------------------------------------------------------------------------
	Ghostban player
---------------------------------------------------------------------------]]

local function ghostban( calling_ply, target_ply, time, reason )
	if target_ply:IsBot() && !GhostBan.jailMode then
		ULib.tsayError( calling_ply, "This player is immune to ghostbanning", true )
		return
	end
	if GhostBan.ghosts[target_ply] then
		ULib.tsayError( calling_ply, "This player is already a ghost", true )
		return
	end

	time = time * 60
	local tReason = (reason && reason ~= "") && reason || GhostBan.Translation[GhostBan.Language]["noreason"]
	-- write ban
	if GhostBan.jailMode then
		GhostBan.bans[target_ply:SteamID()] = {
			unban = (time == 0) && 0 || os.time() + time,
			reason = tReason
		}
		file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))
	else
		local callplyName = ( calling_ply:IsValid() and calling_ply:Nick() ) or "Console"
		sql.Query(
				"REPLACE INTO ulib_bans (steamid, time, unban, reason, name, admin, modified_admin, modified_time) " ..
				string.format( "VALUES (%s, %i, %i, %s, %s, %s, %s, %s)",
					target_ply:SteamID64(),
					os.time(),
					(time == 0) && 0 || os.time() + time,
					escapeOrNull( tReason ),
					escapeOrNull( target_ply:Nick() ),
					escapeOrNull( callplyName ),
					"NULL",
					"NULL"
				)
		)
		ULib.bans[target_ply:SteamID()] = {
			['reason'] = tReason,
			['time'] = os.time(),
			['unban'] = (time == 0) && 0 || os.time() + time,
			['admin'] = callplyName,
			['name'] = target_ply:Nick()
		}
	end
	target_ply:Ghostban(false, time, tReason)
	local str = "#A ghostbanned #T"
	if time > 0 then 
		str = str .. " for #s"
		time = ULib.secondsToStringTime( time )
	else
		str = str .. " #s"
		time = "permanently"
	end
	if reason && reason ~= "" then str = str .. " (#s)" end
	ulx.fancyLogAdmin( calling_ply, str, target_ply, time, reason )
end

if GhostBan.ReplaceULXBan then
	timer.Simple(0, function()
		local ghostbanCmd = ulx.command( "Ghostban", "ulx ban", ghostban, "!ban", false, false, true )
		ghostbanCmd:addParam{ type=ULib.cmds.PlayerArg }
		ghostbanCmd:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
		ghostbanCmd:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
		ghostbanCmd:defaultAccess( ULib.ACCESS_ADMIN )
		ghostbanCmd:help( "Ghostban target" )
	end)
else
	local ghostbanCmd = ulx.command( "Ghostban", "ulx ghostban", ghostban, "!ghostban", false, false, true )
	ghostbanCmd:addParam{ type=ULib.cmds.PlayerArg }
	ghostbanCmd:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
	ghostbanCmd:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
	ghostbanCmd:defaultAccess( ULib.ACCESS_ADMIN )
	ghostbanCmd:help( "Ghostban target" )
end

--[[-------------------------------------------------------------------------
	Ghostban player by SteamID
---------------------------------------------------------------------------]]

local function ghostbanid( calling_ply, steamid, time, reason )
	steamid = steamid:upper()
	if not ULib.isValidSteamID(steamid) then
		ULib.tsayError(calling_ply, "Invalid steamid.")
		return
	end

	local name, target_ply
	local plys = player.GetAll()
	for i=1, #plys do
		if plys[i]:SteamID() == steamid then
			target_ply = plys[i]
			name = target_ply:Nick()
			break
		end
	end

	if target_ply and GhostBan.ghosts[target_ply] then
		ULib.tsayError(calling_ply, "This player is already a ghost", true)
		return
	end

	time = time * 60
	local tReason = (reason && reason ~= "") && reason || GhostBan.Translation[GhostBan.Language]["noreason"]
	-- write ban
	if GhostBan.jailMode then
		GhostBan.bans[steamid] = {
			unban = (time == 0) && 0 || os.time() + time,
			reason = tReason
		}
		file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))
	else
		local callplyName = ( calling_ply:IsValid() and calling_ply:Nick() ) or "Console"
		sql.Query(
				"REPLACE INTO ulib_bans (steamid, time, unban, reason, name, admin, modified_admin, modified_time) " ..
				string.format( "VALUES (%s, %i, %i, %s, %s, %s, %s, %s)",
					util.SteamIDTo64(steamid),
					os.time(),
					(time == 0) && 0 || os.time() + time,
					escapeOrNull( tReason ),
					escapeOrNull( name ),
					escapeOrNull( callplyName ),
					"NULL",
					"NULL"
				)
		)
		ULib.bans[steamid] = {
			['reason'] = tReason,
			['time'] = os.time(),
			['unban'] = (time == 0) && 0 || os.time() + time,
			['admin'] = callplyName,
			['name'] = name
		}
	end
	local str = "#A ghostbanned steamid #s"
	if target_ply then
		target_ply:Ghostban(false, time, tReason)
		steamid = steamid .. " (" .. name .. ")"
	end
	if time > 0 then 
		str = str .. " for #s"
		time = ULib.secondsToStringTime( time )
	else
		str = str .. " #s"
		time = "permanently"
	end
	if reason && reason ~= "" then str = str .. " (#s)" end
	ulx.fancyLogAdmin( calling_ply, str, steamid, time, reason )
end

if GhostBan.ReplaceULXBan then
	timer.Simple(0, function()
		local ghostbanidCmd = ulx.command( "Ghostban", "ulx banid", ghostbanid, nil, false, false, true )
		ghostbanidCmd:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
		ghostbanidCmd:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
		ghostbanidCmd:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
		ghostbanidCmd:defaultAccess( ULib.ACCESS_SUPERADMIN )
		ghostbanidCmd:help( "Ghostban target steamid" )
	end)
else
	local ghostbanidCmd = ulx.command( "Ghostban", "ulx ghostbanid", ghostbanid, nil, false, false, true )
	ghostbanidCmd:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
	ghostbanidCmd:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
	ghostbanidCmd:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
	ghostbanidCmd:defaultAccess( ULib.ACCESS_SUPERADMIN )
	ghostbanidCmd:help( "Ghostban target steamid" )
end

--[[-------------------------------------------------------------------------
	Unghostban player
---------------------------------------------------------------------------]]

local function unghostban( calling_ply, target_ply )
	if !GhostBan.ghosts[target_ply] then
		ULib.tsayError( calling_ply, "This player is not a ghost", true )
		return
	end
	if GhostBan.jailMode then
		GhostBan.bans[target_ply:SteamID()] = nil
		file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))
	else
		ULib.unban(target_ply:SteamID())
	end
	target_ply:Ghostban(true)
	ulx.fancyLogAdmin( calling_ply, "#A unghostbanned #T", target_ply )
end

if GhostBan.ReplaceULXBan then
	timer.Simple(0, function()
		local unghostbanCmd = ulx.command( "Ghostban", "ulx unban", unghostban, "!unban", false, false, true )
		unghostbanCmd:addParam{ type=ULib.cmds.PlayerArg }
		unghostbanCmd:defaultAccess( ULib.ACCESS_ADMIN )
		unghostbanCmd:help( "Unghostban target" )
	end)
else
	local unghostbanCmd = ulx.command( "Ghostban", "ulx unghostban", unghostban, "!unghostban", false, false, true )
	unghostbanCmd:addParam{ type=ULib.cmds.PlayerArg }
	unghostbanCmd:defaultAccess( ULib.ACCESS_ADMIN )
	unghostbanCmd:help( "Unghostban target" )
end

--[[-------------------------------------------------------------------------
	Unghostban player by SteamID
---------------------------------------------------------------------------]]

local function unghostbanid( calling_ply, steamid )
	steamid = steamid:upper()
	if not ULib.isValidSteamID(steamid) then
		ULib.tsayError(calling_ply, "Invalid steamid.")
		return
	end

	if not ( ULib.bans[steamid] or GhostBan.bans[steamid] ) then
		ULib.tsayError(calling_ply, "Player not banned")
		return
	end

	if GhostBan.jailMode then
		GhostBan.bans[steamid] = nil
		file.Write("ghostban_bans.txt", util.TableToJSON(GhostBan.bans))
	else
		ULib.unban(steamid)
	end

	local plys = player.GetAll()
	for i=1, #plys do
		if plys[i]:SteamID() == steamid then
			plys[i]:Ghostban(true)
			steamid = steamid .. " (" .. plys[i]:Nick() .. ")"
			break
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A unghostbanned steamid #s", steamid )
end

if GhostBan.ReplaceULXBan then
	timer.Simple(0, function()
		local unghostbanidCmd = ulx.command( "Ghostban", "ulx unbanid", unghostbanid, nil, false, false, true )
		unghostbanidCmd:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
		unghostbanidCmd:defaultAccess( ULib.ACCESS_SUPERADMIN )
		unghostbanidCmd:help( "Unghostban target steamid" )
	end)
else
	local unghostbanidCmd = ulx.command( "Ghostban", "ulx unghostbanid", unghostbanid, nil, false, false, true )
	unghostbanidCmd:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
	unghostbanidCmd:defaultAccess( ULib.ACCESS_SUPERADMIN )
	unghostbanidCmd:help( "Unghostban target steamid" )
end

--[[-------------------------------------------------------------------------
	Detour fancyLog function so ghosts can't annoy players with psay or asay
---------------------------------------------------------------------------]]

local defaultFancyLog = ulx.fancyLog
function ulx.fancyLog(...)
	local ply = { ... }
	if ply[3] and ply[3]:IsPlayer() and GhostBan.ghosts[ply[3]] and not GhostBan.CanTalkChat then return end
	defaultFancyLog(...)
end