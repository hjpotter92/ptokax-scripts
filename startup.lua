function OnStartup()
	tConfig = {
		sBotName = SetMan.GetString( 21 ),
		sAsBot = "<"..( SetMan.GetString(21) or "PtokaX" ).."> ",
		sPath = "/root/PtokaX/scripts/files/",
		sTextPath = "texts/",
		sFunctionsPath = "functions/",
		sGeneralMenu = "clickMenu.txt",
		sPickleFile = "pickle.lua",
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
	local sTempPath = tConfig.sPath..tConfig..sTextPath
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
	for sAbout, sCommand in pairs(tMenuText) do
		Core.SendToAll( sCommand )
	end
end

function Explode( sInput )
	local t = {}
	for word in sInput:gmatch( "(%S+)" ) do
		table.insert( t, x )
	end
	return t
end

function CreateMessage( tInput )
	if not tInput or not tInput.sTitle then
		return "ERROR", false
	end
	local sReply, sTemplate, tTemp = tInput.sTitle:upper().."\n"..("="):rep(24).."\n\n", "ID: %d \t\t\t Date added: \t %s \nMessage: %s", {}
	for iIndex, tBody in pairs( tInput.tMain ) do
		table.insert( tTemp, sTemplate:format(iIndex, tBody.sDate, tBody.sBody) )
	end
	return ( sReply..table.concat(tTemp, ("-"):rep(100).."\n\n") )
end

function SendFile( sName )
	local tTemp = {}
	if not tConfig.tFiles[sName] then
		return "ERROR", false
	end
	local fHandle = io.open( tConfig.sPath..tConfig.sTextPath..tConfig.tFiles[sName], "r+" )
	if fHandle then
		assert( dofile(tConfig.sPath..tConfig.sTextPath..tConfig.tFiles[sName]) )
		fHandle:close()
		return CreateMessage( tTemp )
	end
end

function UserConnected( tUser )
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
		tBreak = Explode( sData )
		sData = tBreak[1]:lower()
		if not tBreak[2] then
			Core.SendToUser( tUser, tConfig.sAsBot.."No message was provided." )
			return false
		end
		if sData == "lnf" or sData == "lostnfound" then
			return true
		elseif sData == "notice" or sData == "notices" then
			return true
		elseif sData == "tnp" then
			return true
		end
		Core.SendToUser( tUser, tConfig.sAsBot.."Added new message" )
		return true

	elseif sCommand == "removefrom" then
		if sData:len() == 0 then
			Core.SendToUser( tUser, tConfig.sAsBot.."No argument passed." )
			return false
		end
		tBreak = Explode( sData )
		sData = tBreak[1]:lower()
		if not tonumber(tBreak[2]) then
			Core.SendToUser( tUser, tConfig.sAsBot.."No ID was passed." )
			return false
		end
		if sData == "lnf" or sData == "lostnfound" then
			Core.SendToUser( tUser, tConfig.sAsBot..SendFile("lostnfound") )
			return true
		elseif sData == "notice" or sData == "notices" then
			Core.SendToUser( tUser, tConfig.sAsBot..SendFile("notices") )
			return true
		elseif sData == "tnp" then
			Core.SendToUser( tUser, tConfig.sAsBot..SendFile("trainplace") )
			return true
		end

	end
end

function ToArrival( tUser, sMessage )
	local sTo = sMessage:match( "^$To: (%S+) From:" )
	if sTo ~= tConfig.sBotName or not tConfig.sAllowedProfiles:find( tUser.iProfile ) then
		return false
	end
	return ChatArrival( tUser, sMessage:match("%b$$(.*)") )
end
