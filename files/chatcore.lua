local tChatRooms = {
	sGlobalPath = "/www/ChatLogs/",
	["#[ModzChat]"] = {
		iMaxProfile = 4,		-- The maximum profile number allowed to access this chatroom.
		sFileName = "ModsChat.txt"
	},
	["#[VIPChat]"] = {
		iMaxProfile = 3,
		sFileName = "VIPChat.txt"
	},
	["#[Hub-Feed]"] = {
		iMaxProfile = 3,
		sFileName = "HubFeed.txt"
	}
}

function SaveToFile( sChatMessage, sRoom )
	local sStoreMessage = os.date("[%Y-%m-%d %H:%M:%S]").." "..sChatMessage
	local fWrite = io.open( tChatRooms.sGlobalPath..os.date( "%Y/%m/" )..tChatRooms[sRoom].sFileName, "a+" )
	fWrite:write( sStoreMessage.."\n" )
	fWrite:flush()
	fWrite:close()
end

function SendToRoom( sUser, sMessage, sRoom, iCustomProfile )
	local iLim, sPM = iCustomProfile or tChatRooms[sRoom].iMaxProfile, "<"..sUser.."> "..sMessage
	for iToProfile = 0, iLim do
		local tUsers = Core.GetOnlineUsers( iToProfile )
		if tUsers then
			for iIndex, tRecipient in ipairs( tUsers ) do
				Core.SendToUser( tRecipient, "$To: "..tRecipient.sNick.." From: "..sRoom.." $"..sPM.."|" )
			end
		end
	end
	SaveToFile( sPM, sRoom )
	return true
end
