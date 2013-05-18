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
	local tFileHandles = {
		fGeneral = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.sGeneralMenu, "r+" ),
		fOffliner = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.tIndividualMenu["[BOT]Offliner"], "r+" ),
		fInfo = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.tIndividualMenu["[BOT]Info"], "r+" ),
		fGameServer = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.tIndividualMenu["[BOT]GameServer"], "r+" ),
		fChatrooms = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.tIndividualMenu["#[ChatRoom]"], "r+" )
	}
	tMenuText = {
		["[BOT]Offliner"] = tFileHandles.fOffliner:read("*a"):gsub("%%%[bot%]", "[BOT]Offliner"),
		["[BOT]Info"] = tFileHandles.fInfo:read("*a"):gsub("%%%[bot%]", "[BOT]Info"),
		["[BOT]GameServer"] = tFileHandles.fGameServer:read("*a"),
		["#[ChatRoom]"] = tFileHandles.fChatrooms:read("*a"),
		sGeneral = tFileHandles.fGeneral:read("*a")
	}
	for _, fHandle in pairs(tFileHandles) do
		fHandle:close()
	end
	tFileHandles, tConfig.tIndividualMenu = nil, nil
	Core.SendToAll( tMenuText.sGeneral )	
	Core.SendToAll( tMenuText["[BOT]Offliner"] )
	Core.SendToAll( tMenuText["[BOT]Info"] )
	Core.SendToAll( tMenuText["[BOT]GameServer"] )
	Core.SendToAll( tMenuText["#[ChatRoom]"] )
	Core.SendPmToNick("Brick","hhh",tMenuText["[BOT]Offliner"] )
end

function UserConnected( tUser )
	Core.SendToUser( tUser,tMenuText.sGeneral )
	Core.SendToUser( tUser,tMenuText["[BOT]Offliner"])
	Core.SendToUser( tUser,tMenuText["[BOT]Info"])
	Core.SendToUser( tUser,tMenuText["[BOT]GameServer"])
	Core.SendToUser( tUser,tMenuText["#[ChatRoom]"] )
end

OpConnected, RegConnected = UserConnected, UserConnected
