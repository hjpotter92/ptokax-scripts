function OnStartup()
	tConfig = {
		sMainBot = SetMan.GetString( 21 ),
		sReportBot = "#[VIPChat]",
		sPrefixes = "[%/%*%-%+%?%#%!%.]",
		sChatFilePath = "/root/PtokaX/scripts/files/chatcore.lua"
	}
	dofile( tConfig.sChatFilePath )
	local fCommand = io.open( "/root/PtokaX/scripts/files/command.txt", "r+" )
	sFileCommand = fCommand:read( "*a" )
	fCommand:close()
	Core.SendToAll( sFileCommand )
end

function ToArrival( tUser, sMessage )
	local _, _, sTo, cPrefix = sMessage:find( "^%$To: (%S+) From:.-%b<>%s("..tConfig.sPrefixes..")" )
	if sTo == tConfig.sMainBot and cPrefix then
		local _, _, sMessage = sMessage:find( "%b$$(.*)" )
		ChatArrival( tUser, sMessage )
	end
	return false
end

function ChatArrival( tUser, sMessage )
	local _, _, sCommand, sReport = sMessage:find( "%b<>%s"..tConfig.sPrefixes.."(%w+)%s?(.*)|" )
	if sCommand and string.lower( sCommand ) == "report" then
		if sReport then
			local sReport = "(Report): "..sReport
			SendToRoom( tUser.sNick, sReport, tConfig.sReportBot )
			return true
		else
			return false
		end
	end
	return false
end

function UserConnected( tUser )
	Core.SendToUser( tUser, sFileCommand )
end

RegConnected, OpConnected = UserConnected, UserConnected
