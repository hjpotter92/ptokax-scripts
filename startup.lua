function OnStartup()
	tConfig = {
		sBotName = SetMan.GetString( 21 ),
		sAsBot = "<"..( SetMan.GetString(21) or "PtokaX" ).."> ",
		sPath = "/root/PtokaX/scripts/files/",
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
	if not sCommand then
		return false
	end
	sCommand = sCommand:lower()
	if sCommand == "check" then
		sData = sData:lower()
		if sData:len() == 0 then
			Core.SendToUser( tUser, tConfig.sAsBot.."No argument passed." )
			return false
		elseif sData == "lnf" or sData == "lostnfound" then
			Core.SendToUser( tUser, tConfig.sAsBot..SendFile("lostnfound") )
			return true
		elseif sData == "notice" or sData == "notices" then
			Core.SendToUser( tUser, tConfig.sAsBot..SendFile("notices") )
			return true
		elseif sData == "tnp" then
			Core.SendToUser( tUser, tConfig.sAsBot..SendFile("trainplace") )
			return true
		end

	elseif sCommand == "addto" then
		if sData:len() == 0 then
			Core.SendToUser( tUser, tConfig.sAsBot.."No argument passed." )
			return false
		end
		local tBreak = Explode( sData )
		sData = tBreak[1]:lower()
		if not tBreak[2] then
			Core.SendToUser( tUser, tConfig.sAsBot.."No message was provided." )
			return false
		end
		if sData == "lnf" or sData == "lostnfound" then
			StoreMessage( "lostnfound", table.concat(tBreak, " ", 2) )
		elseif sData == "notice" or sData == "notices" then
			StoreMessage( "notices", table.concat(tBreak, " ", 2) )
		elseif sData == "tnp" then
			StoreMessage( "trainplace", table.concat(tBreak, " ", 2) )
		end
		Core.SendToUser( tUser, tConfig.sAsBot.."Added new message" )
		return true

	elseif sCommand == "removefrom" then
		if sData:len() == 0 then
			Core.SendToUser( tUser, tConfig.sAsBot.."No argument passed." )
			return false
		end
		local tBreak = Explode( sData )
		sData = tBreak[1]:lower()
		if not tonumber(tBreak[2]) then
			Core.SendToUser( tUser, tConfig.sAsBot.."No ID was passed." )
			return false
		end
		tBreak[2] = tonumber(tBreak[2])
		if sData == "lnf" or sData == "lostnfound" then
			RemoveMessage( "lostnfound", tBreak[2] )
		elseif sData == "notice" or sData == "notices" then
			RemoveMessage( "notices", tBreak[2] )
		elseif sData == "tnp" then
			RemoveMessage( "trainplace", tBreak[2] )
		end
		Core.SendToUser( tUser, tConfig.sAsBot.."Removed message from ID "..tostring(tBreak[2]).."." )
		return true

	end
end

function ToArrival( tUser, sMessage )
	local sTo = sMessage:match( "^$To: (%S+) From:" )
	if sTo ~= tConfig.sBotName or not tConfig.sAllowedProfiles:find( tUser.iProfile ) then
		return false
	end
	return ChatArrival( tUser, sMessage:match("%b$$(.*)") )
end
