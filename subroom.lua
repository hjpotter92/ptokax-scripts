function OnStartup()
	tConfig = {
		sPath = "/root/PtokaX/scripts/files/",
		sPickleFile = "pickle.lua",
		sLogPath = "/www/ChatLogs/"..os.date( "%Y/" )
	}
	tRooms = {
		["#[Gamers]"] = {
			sBotDescription = "Chatroom for discusssions about games.",
			sBotEmail = "donot@mail.me",
			sLogFile = "games.txt",
			sSubscribersFile = "gameSub.txt",
			tSubscribers = { tModerators = {} }
		},
		["#[QuizRoom]"] = {
			sBotDescription = "Chatroom where quizzes are hosted.",
			sBotEmail = "do-not@mail.me",
			sLogFile = nil,
			sSubscribersFile = "quizSub.txt",
			tSubscribers = { tModerators = {} }
		},
		["#[Anime]"] = {
			sBotDescription = "Chatroom for discusssing anime and manga",
			sBotEmail = "do.not@mail.me",
			sLogFile = "anime.txt",
			sSubscribersFile = "animSub.txt",
			tSubscribers = { tModerators = {} }
		},
		["#[NSFW]"] = {
			sBotDescription = "Chatroom for NSFW.",
			sBotEmail = "do.not@mail.me",
			sLogFile = "nsfw.txt",
			sSubscribersFile = "nsfwSub.txt",
			tSubscribers = { tModerators = {} }
		}
	}
	dofile( tConfig.sPath.."functions/"..tConfig.sPickleFile )
	for sBotName, tInfo in pairs( tRooms ) do
		Core.RegBot( sBotName, tInfo.sBotDescription, tInfo.sBotEmail, true )
		if io.open( tConfig.sPath.."texts/"..tInfo.sSubscribersFile, "r" ) then
			dofile( tConfig.sPath.."texts/"..tInfo.sSubscribersFile )
			tInfo.tSubscribers = tTemp
			tTemp = nil
		end
	end
end

function ToArrival( tUser, sMessage )
	local _, _, sTo = sMessage:find( "%$To: (%S+) From:" )
	if not tRooms[sTo] then return false end
	local _, _, sCmd, sData = sMessage:find( "%b<>%s[%+%!%?%-%*%#](%w+)%s?(.*)|" )
	SaveToFile( sTo, sMessage:match("%b$$(.*)|") )
	if FindSubscription( tRooms[sTo].tSubscribers, tUser.sNick ) and not sCmd then
		SendToSubscribers( tUser.sNick, sTo, sMessage )
		return true
	end
	if sData and sData:len() == 0 then sData = nil end
	if sCmd:lower() == "join" or sCmd:lower() == "subscribe" then
		if FindSubscription( tRooms[sTo].tSubscribers, tUser.sNick ) then
			Core.SendPmToUser( tUser, sTo, "You are already subscribed to this chatroom." )
			return false
		end
		table.insert( tRooms[sTo].tSubscribers, tUser.sNick )
		Core.SendPmToUser( tUser, sTo, "Your subscription was successful." )
		pickle.store( tConfig.sPath.."texts/"..tRooms[sTo].sSubscribersFile, {tTemp = tRooms[sTo].tSubscribers} )
		return true
	elseif sCmd:lower() == "leave" or sCmd:lower() == "unsubscribe" then
		if FindSubscription( tRooms[sTo].tSubscribers, tUser.sNick ) then
			table.remove( tRooms[sTo].tSubscribers, FindSubscription(tRooms[sTo].tSubscribers, tUser.sNick) )
			Core.SendPmToUser( tUser, sTo, "Your unsubscription was successful." )
			pickle.store( tConfig.sPath.."texts/"..tRooms[sTo].sSubscribersFile, {tTemp = tRooms[sTo].tSubscribers} )
		else
			Core.SendPmToUser( tUser, sTo, "You are not a part of this room yet." )
		end
		return true
	elseif sCmd:lower() == "kick" then
		local sKicked = sData and sData:match( "^(%w+)" )
		if not sKicked then
			Core.SendPmToUser( tUser, sTo, "No nickname was provided." )
			return false
		end
		if not FindSubscription( tRooms[sTo].tSubscribers, sKicked ) then
			Core.SendPmToUser( tUser, sTo, sKicked.." is not subscribed to this room." )
			return false
		end
		if tUser.iProfile ~= 0 and not FindSubscription( tRooms[sTo].tSubscribers.tModerators, tUser.sNick ) then
			Core.SendPmToUser( tUser, sTo, "You do not have access to this command. Kicked for abusing." )
			table.remove( tRooms[sTo].tSubscribers, FindSubscription(tRooms[sTo].tSubscribers, tUser.sNick) )
			pickle.store( tConfig.sPath.."texts/"..tRooms[sTo].sSubscribersFile, {tTemp = tRooms[sTo].tSubscribers} )
			return false
		else
			Core.SendPmToUser( tUser, sTo, "Kicking "..sKicked.." from "..sTo.." chatroom." )
			table.remove( tRooms[sTo].tSubscribers, FindSubscription(tRooms[sTo].tSubscribers, sKicked) )
			pickle.store( tConfig.sPath.."texts/"..tRooms[sTo].sSubscribersFile, {tTemp = tRooms[sTo].tSubscribers} )
			return false
		end
	elseif sCmd:lower() == "invite" then
		local sGuest = sData and sData:match( "^(%w+)" )
		if not sGuest then
			Core.SendPmToUser( tUser, sTo, "No nickname was provided." )
			return false
		end
		if Core.GetUser( sGuest ) then
			table.insert( tRooms[sTo].tSubscribers, sGuest )
			Core.SendPmToUser( tUser, sTo, sGuest.." has been invited to "..sTo.." chatroom." )
			return true
		else
			Core.SendPmToUser( tUser, sTo, "User with nick "..sGuest.." is no currently online." )
			return false
		end
	elseif sCmd:lower() == "l" or sCmd:lower() == "list" then
		Core.SendPmToUser( tUser, sTo, "The current subscribers are:\n\n\t"..table.concat(tRooms[sTo].tSubscribers, ", ") )
	elseif sCmd:lower() == "h" or sCmd:lower() == "help" then
		if tUser.iProfile ~= 0 and not FindSubscription( tRooms[sTo].tSubscribers.tModerators, tUser.sNick ) then
			Core.SendPmToUser( tUser, sTo, "The commands available are: help, list, join, invite and leave" )
			return true
		else
			Core.SendPmToUser( tUser, sTo, "The commands available are: help, list, join, invite, kick and leave" )
			return true
		end
	else
		if FindSubscription( tRooms[sTo].tSubscribers, tUser.sNick ) then
			SendToSubscribers( tUser.sNick, sTo, sMessage )
			return true
		else
			Core.SendPmToUser( tUser, sTo, "You are not a part of this chatroom. Please join in to participate." )
			return false
		end
	end
	return true
end

function OnExit()
	for sBotName, tInfo in pairs( tRooms ) do
		Core.UnregBot( sBotName )
	end
end

function SaveToFile( sRoomName, sChatMessage )
	if not tRooms[sRoomName].sLogFile then
		return false
	end
	local sStoreMessage, fWrite = os.date("[%Y-%m-%d %H:%M:%S] ")..sChatMessage, io.open( tConfig.sLogPath..os.date("%m/")..tRooms[sRoomName].sLogFile, "a" )
	fWrite:write( sStoreMessage.."\n" )
	fWrite:flush()
	fWrite:close()
	return true
end

function SendToSubscribers( sSelfNick, sRoomName, sIncoming )
	local _, _, sIncoming = sIncoming:find( "%b$$(.*)|" )
	if sRoomName == "#[NSFW]" then
		sIncoming = "<Anonymous>"..sIncoming:match( "%b<>(.*)" )
	end
	for iIndex, sNick in ipairs( tRooms[sRoomName].tSubscribers ) do
		if sNick:lower() ~= sSelfNick:lower() then
			Core.SendToNick( sNick, "$To: "..sNick.." From: "..sRoomName.." $"..sIncoming.."|" )
		end
	end
	return true
end

function FindSubscription( tInputTable, sNick )
	for iIndex, sName in ipairs( tInputTable ) do
		if sNick:lower() == sName:lower() then
			return iIndex
		end
	end
	return false
end
