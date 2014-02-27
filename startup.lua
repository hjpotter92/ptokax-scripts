function OnStartup()
	tConfig = {
		sBotName = SetMan.GetString( 21 ),
		sAsBot = "<"..( SetMan.GetString(21) or "PtokaX" ).."> ",
		sPath = Core.GetPtokaXPath().."scripts/files/",
		sTextPath = "texts/",
		sFunctionsPath = "dependency/",
		sExternalPath = "external/",
		sFunctionsFile = "functions.lua",
		sGeneralMenu = "clickMenu.txt",
		sPickleFile = "pickle.lua",
		sNotifyFunctionFile = "notify.lua",
		sAllowedProfiles = "0237",
		tIndividualMenu = {
			["[BOT]Offliner"] = "offlinerMenu.txt",
			["[BOT]Info"] = "infoMenu.txt",
			["[BOT]GameServer"] = "gameServerMenu.txt",
			["#[ChatRoom]"] = "roomsMenu.txt",
		},
		tFiles = {
			lostnfound = "lost.txt",
			notices = "notice.txt",
			trainplace = "tnp.txt",
		}
	}
	local sTextPath, sFunctionsPath = tConfig.sPath..tConfig.sTextPath, tConfig.sPath..tConfig.sFunctionsPath
	dofile( sFunctionsPath..tConfig.sFunctionsFile )
	dofile( sFunctionsPath..tConfig.sPickleFile )
	dofile( tConfig.sPath..tConfig.sExternalPath..tConfig.sNotifyFunctionFile )
	local tFileHandles = {
		fGeneral = io.open( sTextPath..tConfig.sGeneralMenu, "r+" ),
		fOffliner = io.open( sTextPath..tConfig.tIndividualMenu["[BOT]Offliner"], "r+" ),
		fInfo = io.open( sTextPath..tConfig.tIndividualMenu["[BOT]Info"], "r+" ),
		fGameServer = io.open( sTextPath..tConfig.tIndividualMenu["[BOT]GameServer"], "r+" ),
		fChatrooms = io.open( sTextPath..tConfig.tIndividualMenu["#[ChatRoom]"], "r+" )
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
	for sAbout, sCommand in pairs(tMenuText) do
		Core.SendToAll( sCommand )
	end
end

function UserConnected( tUser )
	for sName, sFile in pairs( tConfig.tFiles ) do
		local fHandle = io.open( tConfig.sPath..tConfig.sTextPath..sFile, "r+" )
		if fHandle then
			dofile(tConfig.sPath..tConfig.sTextPath..tConfig.tFiles[sName])
			fHandle:close()
			Core.SendPmToUser( tUser, tConfig.sBotName, CreateMessage(tTemp) )
			tTemp = nil
		end
	end
	Core.SendToUser( tUser, sGeneral )
	for sAbout, sCommand in pairs(tMenuText) do
		Core.SendToUser( tUser, sCommand )
	end
end

OpConnected, RegConnected = UserConnected, UserConnected

function ChatArrival( tUser, sMessage )
	local sCommand, sData = sMessage:match( "%b<> [%!%#%?%.%+%-%/%*](%w+)%s?(.*)|" )
	if not sCommand or not ( sCommand == "check" or sCommand == "addto" or sCommand == "removefrom" ) then
		return false
	end
	local tBreak, Result, sError = Explode( sData ), nil, nil
	if not tBreak[1] then
		Core.SendToUser( tUser, tConfig.sAsBot.."No argument passed." )
		return false
	end
	sCommand = sCommand:lower()
	tBreak[1] = tBreak[1]:lower()
	if sCommand == "check" then
		if tBreak[1] == "lnf" or tBreak[1] == "lostnfound" then
			Result, sError = SendFile("lostnfound")
		elseif tBreak[1] == "notice" or tBreak[1] == "notices" then
			Result, sError = SendFile("notices")
		elseif tBreak[1] == "tnp" then
			Result, sError = SendFile("trainplace")
		end

	elseif sCommand == "addto" then
		if not tBreak[2] then
			Core.SendToUser( tUser, tConfig.sAsBot.."No message was provided." )
			return false
		end
		if tBreak[1] == "lnf" or tBreak[1] == "lostnfound" then
			Result, sError = StoreMessage( "lostnfound", table.concat(tBreak, " ", 2) )
		elseif tBreak[1] == "notice" or tBreak[1] == "notices" then
			Result, sError = StoreMessage( "notices", table.concat(tBreak, " ", 2) )
		elseif tBreak[1] == "tnp" then
			Result, sError = StoreMessage( "trainplace", table.concat(tBreak, " ", 2) )
		end

	elseif sCommand == "removefrom" then
		if not tonumber(tBreak[2]) then
			Core.SendToUser( tUser, tConfig.sAsBot.."No ID was passed." )
			return false
		end
		tBreak[2] = tonumber(tBreak[2])
		if tBreak[1] == "lnf" or tBreak[1] == "lostnfound" then
			Result, sError = RemoveMessage( "lostnfound", tBreak[2] )
		elseif tBreak[1] == "notice" or tBreak[1] == "notices" then
			Result, sError = RemoveMessage( "notices", tBreak[2] )
		elseif tBreak[1] == "tnp" then
			Result, sError = RemoveMessage( "trainplace", tBreak[2] )
		end

	end
	if sError then
		Core.SendToUser( tUser, tConfig.sAsBot..sError )
		return true
	end
	if Result then
		Core.SendToUser( tUser, tConfig.sAsBot..Result )
		InformAll()
		return true
	end
	return false
end

function ToArrival( tUser, sMessage )
	local sTo = sMessage:match( "^$To: (%S+) From:" )
	if sTo ~= tConfig.sBotName or not tConfig.sAllowedProfiles:find( tUser.iProfile ) then
		return false
	end
	return ChatArrival( tUser, sMessage:match("%b$$(.*)") )
end
