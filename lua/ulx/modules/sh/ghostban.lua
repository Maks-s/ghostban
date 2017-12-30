GhostBan = GhostBan or {}

local function escapeOrNull( str )
	if !str then 
		return "NULL"
	else 
		return sql.SQLStr(str) 
	end
end

local function ghostban( calling_ply, target_ply, time, reason )
	if target_ply:IsBot() then
		ULib.tsayError( calling_ply, "This player is immune to ghostbanning", true )
		return
	end
	if GhostBan.ghosts[target_ply] then
		ULib.tsayError( calling_ply, "This player is already a ghost", true )
		return	
	end
	time = time * 60
	-- write ban
	local tReason = (reason && reason ~= "") && reason || GhostBan.Translation[GhostBan.Language]["noreason"]
	sql.Query(
			"REPLACE INTO ulib_bans (steamid, time, unban, reason, name, admin, modified_admin, modified_time) " ..
			string.format( "VALUES (%s, %i, %i, %s, %s, %s, %s, %s)",
				target_ply:SteamID64(),
				os.time(),
				(time == 0) && 0 || os.time() + time,
				escapeOrNull( tReason ),
				escapeOrNull( target_ply:Nick() ),
				escapeOrNull( calling_ply:Nick() ),
				"NULL",
				"NULL"
			)
	)
	ULib.bans[target_ply:SteamID()] = {
		['reason'] = tReason,
		['time'] = os.time(),
		['unban'] = (time == 0) && 0 || os.time() + time,
		['admin'] = calling_ply:Nick()
	}
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

local ghostbanCmd
if GhostBan.ReplaceULXBan then
	timer.Simple(0, function()
		ghostbanCmd = ulx.command( "Utility", "ulx ban", ghostban, "!ban", false, false, true )
		ghostbanCmd:addParam{ type=ULib.cmds.PlayerArg }
		ghostbanCmd:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
		ghostbanCmd:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
		ghostbanCmd:defaultAccess( ULib.ACCESS_ADMIN )
		ghostbanCmd:help( "Ghostban target" )
	end)
else
	ghostbanCmd = ulx.command( "Utility", "ulx ghostban", ghostban, "!ghostban", false, false, true )
	ghostbanCmd:addParam{ type=ULib.cmds.PlayerArg }
	ghostbanCmd:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
	ghostbanCmd:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
	ghostbanCmd:defaultAccess( ULib.ACCESS_ADMIN )
	ghostbanCmd:help( "Ghostban target" )
end

local function unghostban( calling_ply, target_ply )
	if !GhostBan.ghosts[target_ply] then
		ULib.tsayError( calling_ply, "This player is not a ghost", true )
		return
	end
	ULib.bans[target_ply:SteamID()] = nil
	sql.Query( "DELETE FROM ulib_bans WHERE steamid=" .. target_ply:SteamID64() )
	target_ply:Ghostban(true)
	ulx.fancyLogAdmin( calling_ply, "#A unghostbanned #T", target_ply )
end

local unghostbanCmd
if GhostBan.ReplaceULXBan then
	timer.Simple(0, function()
		unghostbanCmd = ulx.command( "Utility", "ulx unban", unghostban, "!unban", false, false, true )
		unghostbanCmd:addParam{ type=ULib.cmds.PlayerArg }
		unghostbanCmd:defaultAccess( ULib.ACCESS_ADMIN )
		unghostbanCmd:help( "Unghostban target" )
	end)
else
	unghostbanCmd = ulx.command( "Utility", "ulx unghostban", unghostban, "!unghostban", false, false, true )
	unghostbanCmd:addParam{ type=ULib.cmds.PlayerArg }
	unghostbanCmd:defaultAccess( ULib.ACCESS_ADMIN )
	unghostbanCmd:help( "Unghostban target" )
end