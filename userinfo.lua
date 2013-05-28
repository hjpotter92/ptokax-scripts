function OnStartup()
	tConfig = {
		sPath = "/root/Ptokax/scripts/files/",
		sTextPath = "texts/",
		sDependent = "dependency/",
		sFunctionsFile = "users.lua",
		sDateFormat = tConfig.sDateFormat,
		sBotName = SetMan.GetString( 21 ) or "PtokaX",
		sAllowed = "01234",
		sPassiveBanPass = "01236",
	}
	dofile( tConfig.sPath..tConfig.sDependent..tConfig.sFunctionsFile )
	tUsers = Core.GetOnlineRegs()
	for i,v in ipairs(tUsers) do
		local tSend = {}
		tSend["sDate"] = os.date( tConfig.sDateFormat, Core.GetUserValue(v, 25) )
		tSend["sIP"] = v.sIP
		tSend["iIPID"] = tFunction.ipstat( tSend )
		tSend["sNick"] = SQLCon:escape(v.sNick)
		tFunction.ipnstat( tSend )
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
			tSend["iNickID"] = tFunction.nickstat( tSend )
		end
		tFunction.login( tSend.iNickID, tSend.sIP, tSend.sDate )
	end

end

function UserConnected( tUser )
	local tSend = {}
	tSend["sDate"] = os.date( tConfig.sDateFormat )
	tSend["sIP"] = tUser.sIP
	tSend["iIPID"] = tFunction.ipstat( tSend )
	tSend["sNick"] = SQLCon:escape(tUser.sNick)
	tFunction.ipnstat( tSend )
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
		tSend["iNickID"] = tFunction.nickstat( tSend )
	end
	tFunction.login( tSend.iNickID, tSend.sIP, tSend.sDate )
end

function UserDisconnected( tUser )
	local tSend = {
		sDate = os.date( tConfig.sDateFormat ),
		sIP = tUser.sIP,
		sNick = SQLCon:escape(tUser.sNick)
	}
	tFunction.logout( tSend )
end

OpConnected, RegConnected, OpDisconnected, RegDisconnected = UserConnected, UserConnected, UserDisconnected, UserDisconnected

function ChatArrival( tUser, sMessage )
	local _, _, sCmd, sData = sMessage:find( "%b<> [%/%*%-%+%#%?%.%!](%S+)%s+(%S+)|" )
	if not sCmd and not sData then return false end
	if tProfiles.allowed[tUser.iProfile] == 0 then return false end
	if string.lower(sCmd) == "ui" or string.lower(sCmd) == "userinfo" then
		tCmds.ui( sData, tUser.sNick )
		return true
	elseif string.lower(sCmd) == "ii" or string.lower(sCmd) == "ipinfo" then
		tCmds.ii( sData, tUser.sNick )
		return true
	end
end

function ToArrival( tUser, sMessage )
	local sTo = sMessage:match( "^\$To: (%S+) From" )
	if sTo ~= tConfig.sBotName or not tConfig.sAllowed:find( tUser.iProfile ) then
		return false
	end
	local sCmd, sData = sMessage:match( "%b\$\$%b<> [%/%*%-%+%#%?%.%!](%w+)%s+(%S+)|" )
	if not sCmd and not sData then return false end
	if string.lower(sCmd) == "ui" or string.lower(sCmd) == "userinfo" then
		tCmds.ui( sData, tUser.sNick )
		return true
	end
	if string.lower(sCmd) == "ii" or string.lower(sCmd) == "ipinfo" then
		tCmds.ii( sData, tUser.sNick )
		return true
	end
end
