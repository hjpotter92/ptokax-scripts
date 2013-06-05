function OnStartup()
	tConfig = {
		sPath = "/root/Ptokax/scripts/files/",
		sTextPath = "texts/",
		sDependent = "dependency/",
		sFunctionsFile = "users.lua",
		sDateFormat = "%Y-%m-%d %H:%M:%S",
		sBotName = SetMan.GetString( 21 ) or "PtokaX",
		sAllowed = "01234",
		sPassiveBanPass = "01236",
		iPassiveBanTime = 15,		-- Time in minutes.
	}
	dofile( tConfig.sPath..tConfig.sDependent..tConfig.sFunctionsFile )
	tFunction.Connect()
	tUsers = Core.GetOnlineRegs()
	for iIndex, tUser in ipairs(tUsers) do
		local tSend = {}
		tSend.sDate = os.date( tConfig.sDateFormat, Core.GetUserValue(tUser, 25) )
		tSend.sIP = tUser.sIP
		tSend.sNick = tUser.sNick
		tSend.iProfile = tUser.iProfile
		if Core.GetUserAllData( tUser ) then
			tSend.sMode = tUser.sMode or "S"
			if tUser.sMode == "P" and not tConfig.sPassiveBanPass:find( tUser.iProfile ) then
				BanMan.TempBan( tUser, tConfig.iPassiveBanTime, "Connection with passive mode is not allowed.", sMainBot, false )
				Core.Disconnect( tUser )
			end
			tSend.sMail = ( tUser.sEmail and ("'%s'"):format(SQLCon:escape(tUser.sEmail)) or "NULL" )
			tSend.sDesc = ( tUser.sDescription and ("'%s'"):format(SQLCon:escape(tUser.sDescription)) or "NULL" )
			tSend.sTag = tUser.sTag or "NULL TAG"
			tSend.iShare = tostring(tUser.iShareSize) or 0
			tSend.sClient = string.format( "%s %s", tUser.sClient or "N/A", tUser.sClientVersion or "N/A" )
			tSend.iSlots = tUser.iSlots or 0
			tSend.iHubs = tUser.iHubs or 0
		end
	end

end

function UserConnected( tUser )
	local tSend = {}
	tSend.sIP = tUser.sIP
	tSend.iIPID = tFunction.ipstat( tSend )
	tSend.sNick = tUser.sNick
	tFunction.ipnstat( tSend )
	tSend.iProfile = tUser.iProfile
	if Core.GetUserAllData( tUser ) then
		tSend.sMode = tUser.sMode or "S"
		if tUser.sMode == "P" and not tProfiles.passive[tUser.iProfile] then
			BanMan.TempBan( tUser, 15, "Connection with passive mode is not allowed.", sMainBot, false )
			Core.Disconnect( tUser )
		end
		tSend.sMail = (tUser.sEmail and string.format("'%s'", SQLCon:escape(tUser.sEmail)) or "NULL")
		tSend.sDesc = (tUser.sDescription and string.format("'%s'", SQLCon:escape(tUser.sDescription)) or "NULL")
		tSend.sTag = tUser.sTag or "N/A"
		tSend.iShare = tostring(tUser.iShareSize)
		tSend.sClient = string.format( "%s %s", tUser.sClient or "N/A", tUser.sClientVersion or " N/A" )
		tSend.iSlots = tUser.iSlots or 0
		tSend.iHubs = tUser.iHubs or 0
		tSend.iNickID = tFunction.nickstat( tSend )
	end
	tFunction.login( tSend.iNickID, tSend.sIP, tSend.sDate )
end

function UserDisconnected( tUser )
	local tSend = {
		sIP = tUser.sIP,
		sNick = SQLCon:escape(tUser.sNick),
	}
	tFunction.logout( tSend )
end

OpConnected, RegConnected, OpDisconnected, RegDisconnected = UserConnected, UserConnected, UserDisconnected, UserDisconnected

function ChatArrival( tUser, sMessage )
	local sCmd, sData = sMessage:match( "%b<> [%/%*%-%+%#%?%.%!](%S+)%s+(%S+)|" )
	if not sCmd and not sData then return false end
	if not tConfig.sAllowed:find( tUser.iProfile ) then return false end
	sCmd = sCmd:lower()
	if sCmd == "ui" or sCmd == "userinfo" then
		tCommands.ui( sData, tUser.sNick )
		return true
	elseif sCmd == "ii" or sCmd == "ipinfo" then
		tCommands.ii( sData, tUser.sNick )
		return true
	end
end

function ToArrival( tUser, sMessage )
	local sTo = sMessage:match( "^\$To: (%S+) From" )
	if sTo ~= tConfig.sBotName or not tConfig.sAllowed:find( tUser.iProfile ) then
		return false
	end
	local sCmd, sData = sMessage:match( "^%b$$%b<> [%/%*%-%+%#%?%.%!](%S+)%s+(%S+)|" )
	if not sCmd and not sData then return false end
	if not tConfig.sAllowed:find( tUser.iProfile ) then return false end
	sCmd = sCmd:lower()
	if sCmd == "ui" or sCmd == "userinfo" then
		tCommands.ui( sData, tUser.sNick )
		return true
	elseif sCmd == "ii" or sCmd == "ipinfo" then
		tCommands.ii( sData, tUser.sNick )
		return true
	end
end
