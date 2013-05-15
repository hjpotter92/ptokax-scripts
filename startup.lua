function OnStartup()
	tConfig = {
		sBotName = SetMan.GetString( 21 ),
		sPath = "/root/PtokaX/scripts/files/",
		sTextPath = "texts/",
		tIndividualMenu = {
			["[BOT]Offliner"] = "offlinerMenu.txt",
			["[BOT]Info"] = "infoMenu.txt",
			["[BOT]GameServer"] = "gameServerMenu.txt",
		},
		sGeneralMenu = "clickMenu.txt",
		sReply = "HiT Hi FiT Hai ( %s ) RightClick commands have been sent to your client!"
	}
	local tFileHandles = {
		fGeneral = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.sGeneralMenu, "r+" ),
		fOffliner = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.tIndividualMenu["[BOT]Offliner"], "r+" ),
		fInfo = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.tIndividualMenu["[BOT]Info"], "r+" ),
		fGameServer = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.tIndividualMenu["[BOT]GameServer"], "r+" )
	}
	tMenuText = {
		["[BOT]Offliner"] = tFileHandles.fOffliner:read("*a"):gsub("%%%[bot%]", "[BOT]Offliner"),
		["[BOT]Info"] = tFileHandles.fInfo:read("*a"):gsub("%%%[bot%]", "[BOT]Info"),
		["[BOT]GameServer"] = tFileHandles.fGameServer:read("*a"),
		sGeneral = tFileHandles.fGeneral:read("*a")
	}
	for fHandle in pairs(tFileHandles) do
		fHandle:close()
	end
	tFileHandles = nil
	Core.SendToAll( tMenuText.sGeneral )
end

function ToArrival( tUser, sMessage )
	local sTo, sCmd = sMessage:match( "$To: (%S+) From: %S+ $%b<>%s+[%!%#%?%.%+%-](%a+)%s?.*|" )
	if sCmd and sCmd:lower() == "getrightclick" and tMenuText[sTo] then
		Core.SendToUser( tUser, tMenuText[sTo] )
		Core.SendToUser( tUser, "<"..tConfig.sBotName.."> "..tConfig.sReply:format(sTo) )
		return true
	end
	return false
end
