function OnStartup()
	tConfig = {
		sPath = Core.GetPtokaXPath().."scripts/files/",
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
	local tOnlineUsers = Core.GetOnlineUsers(true)
	for iIndex, tUser in ipairs(tOnlineUsers) do
		repeat
			if CheckUserMode( tUser.sNick, tUser.sMode, tUser.iProfile ) then
				break
			end
			tUser.sDate = os.date( tConfig.sDateFormat, tUser.iLoginTime )
			tUser.iShare = tostring(tUser.iShareSize) or 0
			tFunction.LogIn( tUser )
		until true
	end
	tOnlineUsers = nil

end

function UserConnected( tUser )
	Core.GetUserAllData( tUser )
	if CheckUserMode( tUser.sNick, tUser.sMode, tUser.iProfile ) then
		break
	end
	tUser.sDate = os.date( tConfig.sDateFormat, tUser.iLoginTime )
	tUser.iShare = tostring(tUser.iShareSize) or 0
	tFunction.LogIn( tUser )
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
	local sTo = sMessage:match( "To: (%S+) From:" )
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

local function CheckUserMode( sNick, sMode, iProfile )
	if sMode == "P" and not tConfig.sPassiveBanPass:find( iProfile ) then
		BanMan.TempBanNick( sNick, tConfig.iPassiveBanTime, "Connection with passive mode is not allowed.", tConfig.sBotName, false )
		Core.Disconnect( sNick )
		return true
	end
	return false
end
