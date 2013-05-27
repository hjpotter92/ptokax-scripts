local tFunction, tCmds, sMainBot, tProfiles = {}, {}, SetMan.GetString(21), {
		allowed = {
			[-1] = 0,
			[0] = 1,
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 0,
			[5] = 0,
			[6] = 0,
			[7] = 0
		},
		names = {
			[-1] = "Regular",
			[0] = "Admin/Master",
			[1] = "Gods",
			[2] = "Operators",
			[3] = "VIP",
			[4] = "Moderator",
			[5] = "Registered",
			[6] = "sVIP",
			[7] = "Gymkhana"
		},
		passive = {
			[-1] = false,
			[0] = true,
			[1] = true,
			[2] = true,
			[3] = true,
			[4] = false,
			[5] = false,
			[6] = true,
			[7] = false
		}
	}

tCmds["ui"] = function( Con, sNick, sFrom )
	local sNick, iNum = sNick:gsub( "%*", "%%" )
	if iNum == 0 then sNickQuery = "='%s' "
	else sNickQuery = " LIKE '%s' " end
	local sQuery = [[SELECT *
			FROM `nickstats`
			WHERE `nick`]]..sNickQuery..[[
			LIMIT 5 ]]
	sQuery = string.format( sQuery, Con:escape(sNick) )
	Cur = assert( Con:execute(sQuery) )
	tRowUser = Cur:fetch( {}, "a" )
	while tRowUser do
		sIPQuery = [[SELECT `ip`, `login`, `logout`
			FROM `nickstats_login`
			WHERE `nickstats_id`=%d
			ORDER BY `login` DESC
			LIMIT 25 ]]
		sIPQuery = string.format( sIPQuery, tonumber(tRowUser.id) )
		CurIP = assert( Con:execute(sIPQuery) )
		tRowIP = CurIP:fetch( {}, "a" )
		local sCompleteUserData = "\n"..string.rep("-",100).."\n&#124; Showing information on: "..tRowUser.nick.." \n"..string.rep("-",100).."\n"
		sCompleteUserData = sCompleteUserData.."&#124; General Information:\n&#124;  User: "..tRowUser.nick
		if tRowUser.online == "y" and Core.GetUser(tRowUser.nick) then
			sCompleteUserData = sCompleteUserData..string.rep(" ", 8).."(Online)\n&#124;  IP: "..tRowIP.ip.."\n"
		elseif tRowUser.online == "n" then
			sCompleteUserData = sCompleteUserData..string.rep(" ", 8).."(Offline since "..tRowUser.last_used..")\n"
		end
		sCompleteUserData = sCompleteUserData.."&#124;  Profile: "..tProfiles.names[tonumber(tRowUser.profile)].."\n"
		if tRowUser.email then
			sCompleteUserData = sCompleteUserData.."&#124;  Email: "..tRowUser.email.."\n"
		end if tRowUser.description then
			sCompleteUserData = sCompleteUserData.."&#124;  Description: "..tRowUser.description.."\n"
		end
		sCompleteUserData = sCompleteUserData.."&#124;  Mode: "..tRowUser.mode.."\n\n"
		sCompleteUserData = sCompleteUserData.."&#124;  Sharesize: "..tFunction.GetSize(tRowUser.sharesize).." (Exact Share: "..tRowUser.sharesize.." B)\n"
		sCompleteUserData = sCompleteUserData.."&#124;  Tag: "..tRowUser.tag.."\n"
		sCompleteUserData = sCompleteUserData.."&#124;  Client: "..tRowUser.client.."\n"
		sCompleteUserData = sCompleteUserData.."&#124;  Slots: "..tRowUser.slots.."\n\n&#124; IP History:\n"
		while tRowIP do
			sCompleteUserData = sCompleteUserData..string.format("&#124;  %s          From: %s          To: %s\n", tRowIP.ip, tRowIP.login, tRowIP.logout or "Still connected")
			tRowIP = CurIP:fetch( {}, "a" )
		end
		CurIP:close()
		Core.SendPmToNick( sFrom, sMainBot, sCompleteUserData )
		tRowUser = Cur:fetch( {}, "a" )
	end
end

tCmds["ii"] = function( Con, sIP, sFrom )
	local sCompleteUserData = "\n"..string.rep("-",100).."\n~ Showing information for: "..sIP
	local sIP, iNum = sIP:gsub( "%*", "%%" )
	if iNum == 0 then sIPQuery = "='%s' "
	else sIPQuery = " LIKE '%s' " end
	local sQuery = [[SELECT *
			FROM `ipstats`
			WHERE `ip`]]..sIPQuery..[[
			LIMIT 200 ]]
	sQuery = string.format( sQuery, Con:escape(sIP) )
	Cur = assert( Con:execute(sQuery) )
	tRowIP = Cur:fetch( {}, "a" )
	sCompleteUserData = sCompleteUserData.." \n~ Total results found were "..tostring( Cur:numrows() ).." (Limit 200)\n"..string.rep("-",100).."\n"
	while tRowIP do
		sQueryIPStats = [[SELECT `nick`, `used_times`, `last_used`
			FROM `ipstats_nicks`
			WHERE `ipstats_id` = %d
			ORDER BY `used_times` DESC
			LIMIT 2 ]]
		sQueryIPStats = string.format( sQueryIPStats, tonumber(tRowIP.id) )
		CurIP = assert( Con:execute(sQueryIPStats) )
		tRowIPStats = CurIP:fetch( {}, "a" )
		while tRowIPStats do
			sCompleteUserData = sCompleteUserData..string.format("~  %s    \t    %s (%d times used)    \t    Last Usage: %s\n", tRowIP.ip, tRowIPStats.nick, tRowIPStats.used_times, tRowIPStats.last_used)
			tRowIPStats = CurIP:fetch( {}, "a" )
		end
		CurIP:close()
		tRowIP = Cur:fetch( {}, "a" )
	end
	Core.SendPmToNick( sFrom, sMainBot, sCompleteUserData )
end

tFunction["ipstat"] = function( Con, tInput )
	local sQueryIPStat = [[INSERT INTO `ipstats` (`ip`, `last_used`)
			VALUES ( '%s', '%s' )
			ON DUPLICATE KEY
			UPDATE `online` = 'y', `last_used` = '%s' ]]
	sQueryIPStat = string.format( sQueryIPStat, tInput.sIP, tInput.sDate, tInput.sDate )
	SQLCur = assert( Con:execute(sQueryIPStat) )
	return Con:getlastautoid()
end

tFunction["ipnstat"] = function( Con, tInput )
	local sQueryIPNStat = [[INSERT INTO `ipstats_nicks` (`ipstats_id`, `nick`, `last_used`)
			VALUES ( %d, '%s', '%s' )
			ON DUPLICATE KEY
			UPDATE `last_used` = '%s', `online` = 'y', `used_times` = `used_times`+1 ]]
	sQueryIPNStat = string.format( sQueryIPNStat, tInput.iIPID, tInput.sNick, tInput.sDate, tInput.sDate )
	SQLCur = assert( Con:execute(sQueryIPNStat) )
end

tFunction["nickstat"] = function( Con, tInput )
	local sQueryIPNStat = [[INSERT INTO `nickstats` (`nick`, `mode`, `description`, `email`, `sharesize`, `profile`, `tag`, `client`, `hubs`, `slots`, `last_used`)
			VALUES ( '%s', '%s', %s, %s, '%s', %d, '%s', '%s', %d, %d, '%s' )
			ON DUPLICATE KEY
			UPDATE `last_used` = '%s', `online` = 'y', `mode` = '%s', `description` = %s, `email` = %s,
				`sharesize` = '%s', `profile` = '%d', `hubs` = '%d', `slots` = '%d', `tag` = '%s', `client` = '%s' ]]
	sQueryIPNStat = string.format( sQueryIPNStat, tInput.sNick, tInput.sMode, tInput.sDesc, tInput.sMail, tInput.iShare, tInput.iProfile, Con:escape(tInput.sTag), Con:escape(tInput.sClient), tInput.iHubs, tInput.iSlots, tInput.sDate, tInput.sDate, tInput.sMode, tInput.sDesc, tInput.sMail, tInput.iShare, tInput.iProfile, tInput.iHubs, tInput.iSlots, Con:escape(tInput.sTag), Con:escape(tInput.sClient) )
	SQLCur = assert( Con:execute(sQueryIPNStat) )
	return Con:getlastautoid()
end

tFunction["login"] = function( Con, iID, sIP, sDate )
	local sQueryLogin= [[INSERT INTO `nickstats_login` (`nickstats_id`, `ip`, `login`)
			VALUES ( %d, '%s', '%s' ) ]]
	sQueryLogin = string.format( sQueryLogin, iID, sIP, sDate )
	SQLCur = assert( Con:execute(sQueryLogin) )
end

tFunction["logout"] = function( Con, tInput )
	local sQueryLogout = [[SET @updt_id = 0;]]
	SQLCur = assert( Con:execute(sQueryLogout) )
	sQueryLogout = [[UPDATE `ipstats`
			SET `online`='n', `last_used` = ']]..tInput.sDate..[[', id = (SELECT @updt_id := id)
			WHERE `ip`=']]..tInput.sIP..[[' LIMIT 1;]]
	SQLCur = assert( Con:execute(sQueryLogout) )
	sQueryLogout = [[SELECT @updt_id AS id; ]]
	SQLCur = assert( Con:execute(sQueryLogout) )
	tInput["iIPID"] = tonumber( SQLCur:fetch() )
	sQueryLogout = [[UPDATE `ipstats_nicks`
			SET `online` = 'n', `last_used` = ']]..tInput.sDate..[['
			WHERE `ipstats_id` = ]]..tostring(tInput.iIPID)..[[
				AND `nick` = ']]..tInput.sNick..[[' ]]
	SQLCur = assert( Con:execute(sQueryLogout) )
	local sQueryLogout = [[SET @updt_id = 0;]]
	SQLCur = assert( Con:execute(sQueryLogout) )
	sQueryLogout = [[UPDATE `nickstats`
			SET `online`='n', `last_used` = ']]..tInput.sDate..[[', id = (SELECT @updt_id := id)
			WHERE `nick`=']]..tInput.sNick..[[' LIMIT 1;]]
	SQLCur = assert( Con:execute(sQueryLogout) )
	sQueryLogout = [[SELECT @updt_id AS id; ]]
	SQLCur = assert( Con:execute(sQueryLogout) )
	tInput["iID"] = tonumber( SQLCur:fetch() )
	sQueryLogout = [[UPDATE `nickstats_login`
			SET `logout` = ']]..tInput.sDate..[['
			WHERE `nickstats_id` = ]]..tostring(tInput.iID)..[[
				AND `ip` = ']]..tInput.sIP..[['
			ORDER BY `login` DESC
			LIMIT 1 ]]
	SQLCur = assert( Con:execute(sQueryLogout) )
end

tFunction["GetSize"] = function( iSize )
	local iSizeTemp, sPrefix, i = tonumber(iSize) or 0, {"", "Ki", "Mi", "Gi", "Ti", "Pi"}, 1
	while iSizeTemp > 1024 do
		iSizeTemp, i = iSizeTemp/1024, i+1
	end
	return string.format( "%.2f %sB", iSizeTemp, sPrefix[i] )
end

function OnStartup()
	local luasql = require "luasql.mysql"
	SQLEnv = assert( require luasql.mysql() )
	SQLCon = assert( SQLEnv:connect("ptokax", "root", "mysql@hhfh", "localhost", "3306") )
	tUsers = Core.GetOnlineRegs()
	for i,v in ipairs(tUsers) do
		local tSend = {}
		tSend["sDate"] = os.date( "%Y-%m-%d %H:%M:%S", Core.GetUserValue(v, 25) )
		tSend["sIP"] = v.sIP
		tSend["iIPID"] = tFunction.ipstat( SQLCon, tSend )
		tSend["sNick"] = SQLCon:escape(v.sNick)
		tFunction.ipnstat( SQLCon, tSend )
		tSend["iProfile"] = v.iProfile
		if Core.GetUserAllData( v ) then
			tSend["sMode"] = v.sMode or "S"
			if v.sMode == "P" and not tProfiles.passive[v.iProfile] then
				BanMan.TempBan( v, 15, "Connection with passive mode is not allowed.", sMainBot, false )
				Core.Disconnect( v )
			end
			tSend["sMail"] = (v.sEmail and string.format("'%s'", SQLCon:escape(v.sEmail)) or "NULL")
			tSend["sDesc"] = (v.sDescription and string.format("'%s'", SQLCon:escape(v.sDescription)) or "NULL")
			tSend["sTag"] = v.sTag or "NULL TAG"
			tSend["iShare"] = tostring(v.iShareSize) or 0
			tSend["sClient"] = string.format( "%s%s", v.sClient or "N/A", v.sClientVersion or "N/A" )
			tSend["iSlots"] = v.iSlots or 0
			tSend["iHubs"] = v.iHubs or 0
			tSend["iNickID"] = tFunction.nickstat( SQLCon, tSend )
		end
		tFunction.login( SQLCon, tSend.iNickID, tSend.sIP, tSend.sDate )
	end

end

function OnExit()
	SQLCon:close()
	SQLEnv:close()
end

function UserConnected( tUser )
	local tSend = {}
	tSend["sDate"] = os.date( "%Y-%m-%d %H:%M:%S" )
	tSend["sIP"] = tUser.sIP
	tSend["iIPID"] = tFunction.ipstat( SQLCon, tSend )
	tSend["sNick"] = SQLCon:escape(tUser.sNick)
	tFunction.ipnstat( SQLCon, tSend )
	tSend["iProfile"] = tUser.iProfile
	if Core.GetUserAllData( tUser ) then
		tSend["sMode"] = tUser.sMode or "S"
		if tUser.sMode == "P" and not tProfiles.passive[tUser.iProfile] then
			BanMan.TempBan( tUser, 15, "Connection with passive mode is not allowed.", sMainBot, false )
			Core.Disconnect( tUser )
		end
		tSend["sMail"] = (tUser.sEmail and string.format("'%s'", SQLCon:escape(tUser.sEmail)) or "NULL")
		tSend["sDesc"] = (tUser.sDescription and string.format("'%s'", SQLCon:escape(tUser.sDescription)) or "NULL")
		tSend["sTag"] = tUser.sTag or "N/A"
		tSend["iShare"] = tostring(tUser.iShareSize)
		tSend["sClient"] = string.format( "%s%s", tUser.sClient or "N/A", tUser.sClientVersion or " N/A" )
		tSend["iSlots"] = tUser.iSlots or 0
		tSend["iHubs"] = tUser.iHubs or 0
		tSend["iNickID"] = tFunction.nickstat( SQLCon, tSend )
	end
	tFunction.login( SQLCon, tSend.iNickID, tSend.sIP, tSend.sDate )
end

function UserDisconnected( tUser )
	local tSend = {
		sDate = os.date( "%Y-%m-%d %H:%M:%S" ),
		sIP = tUser.sIP,
		sNick = SQLCon:escape(tUser.sNick)
	}
	tFunction.logout( SQLCon, tSend )
end

OpConnected, RegConnected, OpDisconnected, RegDisconnected = UserConnected, UserConnected, UserDisconnected, UserDisconnected

function ChatArrival( tUser, sMessage )
	local _, _, sCmd, sData = sMessage:find( "%b<> [%/%*%-%+%#%?%.%!](%S+)%s+(%S+)|" )
	if not sCmd and not sData then return false end
	if tProfiles.allowed[tUser.iProfile] == 0 then return false end
	if string.lower(sCmd) == "ui" or string.lower(sCmd) == "userinfo" then
		tCmds.ui( SQLCon, sData, tUser.sNick )
		return true
	elseif string.lower(sCmd) == "ii" or string.lower(sCmd) == "ipinfo" then
		tCmds.ii( SQLCon, sData, tUser.sNick )
		return true
	end
end

function ToArrival( tUser, sMessage )
	local _, _, sTo = sMessage:find( "^\$To: (%S+) From.*" )
	if sTo ~= sMainBot or tProfiles.allowed[tUser.iProfile] == 0 then
		return false
	end
	local _, _, sCmd, sData = sMessage:find( "%b\$\$%b<> [%/%*%-%+%#%?%.%!](%w+)%s+(%S+)|" )
	if not sCmd and not sData then return false end
	if string.lower(sCmd) == "ui" or string.lower(sCmd) == "userinfo" then
		tCmds.ui( SQLCon, sData, tUser.sNick )
		return true
	end
	if string.lower(sCmd) == "ii" or string.lower(sCmd) == "ipinfo" then
		tCmds.ii( SQLCon, sData, tUser.sNick )
		return true
	end
end
