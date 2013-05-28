function OnStartup()
	tConfig = {
		sBotName = SetMan.GetString( 21 ),
		sPath = "/root/PtokaX/scripts/files/",
		sTextPath = "texts/",
		tIndividualMenu = {
			["[BOT]Offliner"] = "offlinerMenu.txt",
			["[BOT]Info"] = "infoMenu.txt",
			["[BOT]GameServer"] = "gameServerMenu.txt",
			["#[ChatRoom]"] = "roomsMenu.txt",
		},
		sGeneralMenu = "clickMenu.txt",
		sReply = "HiT Hi FiT Hai ( %s ) RightClick commands have been sent to your client!"
	}
	local sTempPath = sTempPath
	local tFileHandles = {
		fGeneral = io.open( sTempPath..tConfig.sGeneralMenu, "r+" ),
		fOffliner = io.open( sTempPath..tConfig.tIndividualMenu["[BOT]Offliner"], "r+" ),
		fInfo = io.open( sTempPath..tConfig.tIndividualMenu["[BOT]Info"], "r+" ),
		fGameServer = io.open( sTempPath..tConfig.tIndividualMenu["[BOT]GameServer"], "r+" ),
		fChatrooms = io.open( sTempPath..tConfig.tIndividualMenu["#[ChatRoom]"], "r+" )
	}
	sGeneral, tMenuText = tFileHandles.fGeneral:read("*a"), {
		["[BOT]Offliner"] = tFileHandles.fOffliner:read("*a"):gsub("%%%[bot%]", "[BOT]Offliner"),
		["[BOT]Info"] = tFileHandles.fInfo:read("*a"):gsub("%%%[bot%]", "[BOT]Info"),
		["[BOT]GameServer"] = tFileHandles.fGameServer:read("*a"),
		["#[ChatRoom]"] = tFileHandles.fChatrooms:read("*a"),
	}
	for _, fHandle in pairs(tFileHandles) do
		fHandle:close()
	end
	tFileHandles, tConfig.tIndividualMenu, sTempPath = nil, nil, nil
	Core.SendToAll( sGeneral )
	for sAbout, sCommands in pairs(tMenuText) do
		Core.SendToAll( sCommands )
	end
end

function UserConnected( tUser )
	Core.SendToUser( tUser, sGeneral )
	for sAbout, sCommands in pairs(tMenuText) do
		Core.SendToUser( tUser, sCommands )
	end
end

OpConnected, RegConnected = UserConnected, UserConnected

function ChatArrival( tUser, sMessage )

end

function ToArrival( tUser, sMessage )

end
