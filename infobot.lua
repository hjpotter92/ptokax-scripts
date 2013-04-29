function OnStartup()
	tCfg = {
		sBotName = "[BOT]Info",
		sBotDescription = "All informatory works are performed.",
		sBotEmail = "do-not@mail.me",
		sFunctionsFile = "botinfo.lua",
		sHelpFile = "ihelp.txt",
		sPath = "/root/PtokaX/scripts/files/",
		sChatFile = "chatcore.lua",
		sReportBot = "#[Hub-Feed]",
		sHelp = "",
		sAllCategories = "",
		iModProfile = 4,
		iRegProfile = 5
	}
	tProfiles = {
		AllowVIP = {
			[0] = true,			-- Admin
			[1] = true,			-- God
			[2] = true,			-- OP
			[3] = true			-- VIP
		},
		AllowMods = {
			[0] = true,			-- Admin
			[1] = true,			-- God
			[2] = true,			-- OP
			[3] = true,			-- VIP
			[4] = true			-- Mods
		}
	}
	dofile( tCfg.sPath..tCfg.sFunctionsFile )
	dofile( tCfg.sPath..tCfg.sChatFile )
	local fHelp = io.open( tCfg.sPath..tCfg.sHelpFile )
	if fHelp then
		tCfg.sHelp = fHelp:read( "*a" )
		fHelp:close()
	end
	Core.RegBot( tCfg.sBotName, tCfg.sBotDescription, tCfg.sBotEmail, true )
	tCfg.sAllCategories = tFunction.Connect()
end

function ToArrival( tUser, sMessage )
	local _, _, sTo = sMessage:find( "%$To: (%S+) From:" )
	if sTo ~= tCfg.sBotName then return false end
	local _, _, sCmd, sData = sMessage:find( "%b<>%s[%+%-%*%/%!%#%?](%w+)%s?(.*)|" )
	if not sCmd then return false end
	if sData and sData:len() > 250 then
		Core.SendPmToUser( tUser, tCfg.sBotName, "All command length must be below 250 characters." )
	end
	return ExecuteCommand( tUser, sCmd:lower(), sData )
end

function ExecuteCommand( tUser, sCommand, sData )
	if sCommand == "h" or sCommand == "help" then
		Core.SendPmToUser( tUser, tCfg.sBotName, tCfg.sHelp )
		return false

	elseif sCommand == "readall" or sCommand == "rall" then
		if ( not sData ) or ( sData and not tonumber(sData) ) then
			iLimit = 15
		else
			iLimit = ( tonumber(sData) > 35 and 35 ) or tonumber(sData)
		end
		local sList = tInfobot.readAll( iLimit )
		if sList then
			Core.SendPmToUser( tUser, tCfg.sBotName, sList )
		end
		sList = nil
		return true

	elseif sCommand == "readreq" or sCommand == "rreq" then
		if ( not sData ) or ( sData and not tonumber(sData) ) then
			iLimit = 15
		else
			iLimit = ( tonumber(sData) > 50 and 50 ) or tonumber(sData)
		end
		local sList = tInfobot.readOne( "requests", iLimit )
		if sList then
			Core.SendPmToUser( tUser, tCfg.sBotName, sList )
			sList = nil
		end
		return true

	elseif sCommand == "readbuysell" or sCommand == "rbsell" then
		if ( not sData ) or ( sData and not tonumber(sData) ) then
			iLimit = 15
		else
			iLimit = ( tonumber(sData) > 50 and 50 ) or tonumber(sData)
		end
		local sList = tInfobot.readOne( "buynsell", iLimit )
		if sList then
			Core.SendPmToUser( tUser, tCfg.sBotName, sList )
			sList = nil
		end
		return true

	elseif sCommand == "readsug" or sCommand == "rsg" then
		if ( not sData ) or ( sData and not tonumber(sData) ) then
			iLimit = 15
		else
			iLimit = ( tonumber(sData) > 50 and 50 ) or tonumber(sData)
		end
		local sList = tInfobot.readOne( "suggestions", iLimit )
		if sList then
			Core.SendPmToUser( tUser, tCfg.sBotName, sList )
		end
		sList = nil
		return true

	elseif sCommand == "readgst" or sCommand == "rgst" then
		if ( not sData ) or ( sData and not tonumber(sData) ) then
			iLimit = 15
		else
			iLimit = ( tonumber(sData) > 50 and 50 ) or tonumber(sData)
		end
		local sList = tInfobot.readOne( "guestbook", iLimit )
		if sList then
			Core.SendPmToUser( tUser, tCfg.sBotName, sList )
		end
		sList = nil
		return true

	elseif sCommand == "readnws" or sCommand == "rn" then
		if ( not sData ) or ( sData and not tonumber(sData) ) then
			iLimit = 15
		else
			iLimit = ( tonumber(sData) > 50 and 50 ) or tonumber(sData)
		end
		local sList = tInfobot.readOne( "news", iLimit )
		if sList then
			Core.SendPmToUser( tUser, tCfg.sBotName, sList )
		end
		sList = nil
		return true
	end

	if sData:len() == 0 then
		Core.SendPmToUser( tUser, tCfg.sBotName, "You did not pass anything as argument." )
		return false
	end

	local tInsertData, iLastID, sAdditionNotify = { sMsg = sData, sTable = "all" }, 0, "New %s has been added to [ %s ] table. Use %s for more information."

	if not tInsertData.sMsg then
		Core.SendPmToUser( tUser, tCfg.sBotName, "No message provided." )
		return false
	elseif tInsertData.sMsg:len() > 200 then
		Core.SendPmToUser( tUser, tCfg.sBotName, "Too long text!" )
		return false
	end

	if sCommand == "areq" or sCommand == "ar" then
		local tBreak = tFunction.Explode( sData )
		if tFunction.CheckCategory( tBreak[1] ) then
			tInsertData.sCtg = tBreak[1]
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "Wrong category! "..tCfg.sAllCategories )
			return false
		end
		tInsertData.sMsg, tInsertData.sTable = table.concat( tBreak, " ", 2 ), "requests"
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
			return false
		end
		local sChatMessage = sAdditionNotify:format( ("%s: %s"):format(tInsertData.sCtg:upper(), tInsertData.sMsg), tInsertData.sTable:upper(), tCfg.sBotName )
		SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot, tCfg.iModProfile )
		tFunction.SendToAll( tUser.sNick, sChatMessage )
		sChatMessage = nil
		Core.SendPmToUser( tUser, tCfg.sBotName, "Request has been added at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "asug" or sCommand == "asg" then
		local tBreak = tFunction.Explode( sData )
		if tFunction.CheckCategory( tBreak[1] ) then
			tInsertData.sCtg = tBreak[1]:lower()
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "Wrong category! "..tCfg.sAllCategories )
			return false
		end
		tInsertData.sMsg, tInsertData.sTable = table.concat( tBreak, " ", 2 ), "suggestions"
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
			return false
		end
		local sChatMessage = sAdditionNotify:format( ("%s: %s"):format(tInsertData.sCtg:upper(), tInsertData.sMsg), tInsertData.sTable:upper(), tCfg.sBotName )
		SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot )
		tFunction.SendToAll( tUser.sNick, sChatMessage )
		sChatMessage = nil
		Core.SendPmToUser( tUser, tCfg.sBotName, "Suggestion has been added at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "anws" or sCommand == "an" then
		tInsertData.sTable = "news"
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
			return false
		end
		local sChatMessage = sAdditionNotify:format( tInsertData.sMsg, tInsertData.sTable:upper(), tCfg.sBotName )
		SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot )
		tFunction.SendToAll( tUser.sNick, sChatMessage )
		sChatMessage = nil
		Core.SendPmToUser( tUser, tCfg.sBotName, "News has been added at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "agst" or sCommand == "ag" then
		tInsertData.sTable = "guestbook"
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
			return false
		end
		local sChatMessage = sAdditionNotify:format( tInsertData.sMsg, tInsertData.sTable:upper(), tCfg.sBotName )
		SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot )
		tFunction.SendToAll( tUser.sNick, sChatMessage )
		sChatMessage = nil
		Core.SendPmToUser( tUser, tCfg.sBotName, "Your comment has been recorded at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "adel" or sCommand == "ad" then
		tInsertData.sTable = "deletions"
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
			return false
		end
		local sChatMessage = sAdditionNotify:format( tInsertData.sMsg, tInsertData.sTable:upper(), tCfg.sBotName )
		SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot, tCfg.iModProfile )
		tFunction.SendToAll( tUser.sNick, sChatMessage )
		sChatMessage = nil
		Core.SendPmToUser( tUser, tCfg.sBotName, "Deletion info has been added at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "addbns" or sCommand == "absell" then
		local tBreak = tFunction.Explode( sData )
		local _, sError = tFunction.CheckBnS( string.lower(tBreak[1]) )
		if _ then
			tInsertData.sType = _
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "Wrong category! Available ones are \n"..sError )
			return false
		end
		tInsertData.sMsg, tInsertData.sTable = table.concat( tBreak, " ", 2 ), "buynsell"
--~ 		if tInsertData.sMsg:lower():find( "[%[buy|sell%]]" ) then
--~ 			Core.SendPmToUser( tUser, tCfg.sBotName, "You don't need to separately tag the thread." )
--~ 			return false
--~ 		end
		iLastID = tInfobot.add( tUser, tInsertData )
		if ( not tonumber(iLastID) ) or ( tonumber(iLastID) == 0 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
			return false
		end
		local sChatMessage = sAdditionNotify:format( ("%s: %s"):format(tBreak[1]:upper(), tInsertData.sMsg), tInsertData.sTable:upper(), tCfg.sBotName )
		SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot )
		tFunction.SendToAll( tUser.sNick, sChatMessage )
		sChatMessage = nil
		Core.SendPmToUser( tUser, tCfg.sBotName, "Buy and sell entry has been added at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "addreply" or sCommand == "amsg" then
		local tBreak = tFunction.Explode( sData )
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return false
		end
		tInsertData.sMsg, tInsertData.iID, tInsertData.sTable = table.concat( tBreak, " ", 2 ), tonumber( tBreak[1], 10 ), "replies"
		local tRow = tFunction.FetchRow( "buynsell", tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
			return false
		end
		iLastID = tInfobot.add( tUser, tInsertData )
		if ( not tonumber(iLastID) ) or ( tonumber(iLastID) == 0 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
			return false
		end
		tInfobot.StoreMessage( tUser.sNick, tRow.nick, "I've replied to your buy and sell thread. ID#"..tostring(tInsertData.iID).." - "..tRow.msg.."." )
		local sReply = ("Your reply to buy and sell thread#%d has been added at ID #%d. %s will be notified with your message. Keep checking the thread for further replies."):format( tInsertData.iID, iLastID, tRow.nick )
		Core.SendPmToUser( tUser, tCfg.sBotName, sReply )
		return true

	elseif sCommand == "fill" or sCommand == "freq" then
		local tBreak, sReply = tFunction.Explode( sData ), "You filled the request \n\tID#%d. [%s] - %s (Added by %s)\n\nThe requesting user will be notified with message ID#%d when they connect."
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return false
		end
		tInsertData.sMsg, tInsertData.iID = nil, tonumber( tBreak[1], 10 )
		local tRow = tFunction.FetchRow( "requests", tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
			return false
		end
		local iOfflineMessageID = tInfobot.StoreMessage( tUser.sNick, tRow.nick, "I've filled your request ID#"..tostring(tInsertData.iID).." - "..tRow.msg.."." ), tInfobot.fill( tUser, tonumber(tBreak[1], 10) )
		Core.SendPmToUser( tUser, tCfg.sBotName, sReply:format(tInsertData.iID, tRow.ctg, tRow.msg, tRow.nick, tonumber(iOfflineMessageID)) )
		return true

	elseif tProfiles.AllowMods[tUser.iProfile] and ( sCommand == "close" or sCommand == "creq" ) then
		local tBreak, sReply = tFunction.Explode( sData ), "You closed the request \n\tID#%d. [%s] - %s (Added by %s)\n\nThe requesting user will be notified with message ID#%d when they connect."
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return false
		end
		tInsertData.sMsg, tInsertData.iID = nil, tonumber( tBreak[1], 10 )
		local tRow = tFunction.FetchRow( "requests", tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
			return false
		end
		local iOfflineMessageID = tInfobot.StoreMessage( tUser.sNick, tRow.nick, "I've closed your request ID#"..tostring(tInsertData.iID).." - "..tRow.msg.."." )
		tInfobot.fill( tUser, tInsertData.iID, true )
		Core.SendPmToUser( tUser, tCfg.sBotName, sReply:format(tInsertData.iID, tRow.ctg, tRow.msg, tRow.nick, tonumber(iOfflineMessageID)) )
		return true

	elseif sCommand == "switch" then
		local tBreak, sReply = tFunction.Explode( sData ), "You switched the status of thread \n\tID#%d. [%s] - %s (Added by %s)\n\nThe requesting user will be notified with message ID#%d when they connect."
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return false
		end
		tInsertData.sMsg, tInsertData.iID = nil, tonumber( tBreak[1], 10 )
		local tRow = tFunction.FetchRow( "buynsell", tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
			return false
		end
		if tRow.type:lower() ~= "buy" and tRow.type:lower() ~= "sell" then
			Core.SendPmToUser( tUser, tCfg.sBotName, "The thread is of [ "..tRow.type.." ] type. Can not switch its status." )
			return false
		end
		if tUser.sNick:lower() == tRow.nick:lower() or tProfiles.AllowMods[tUser.iProfile] then
			tInfobot.switch( tInsertData.iID )
			if tUser.sNick:lower() ~= tRow.nick:lower() then
				local iOfflineMessageID = tInfobot.StoreMessage( tUser.sNick, tRow.nick, "I've switched your buy and sell thread ID#"..tostring(tInsertData.iID).." - "..tRow.msg.."." )
				Core.SendPmToUser( tUser, tCfg.sBotName, sReply:format(tInsertData.iID, tRow.type, tRow.msg, tRow.nick, tonumber(iOfflineMessageID)) )
			else
				Core.SendPmToUser( tUser, tCfg.sBotName, "Status switched successfully." )
			end
			return true
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "You do not have sufficient privileges or you didn't start the thread." )
			return false
		end

	elseif sCommand == "delreq" or sCommand == "dr" then
		local tBreak = tFunction.Explode( sData )
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return false
		end
		tInsertData.sMsg, tInsertData.iID, tInsertData.sTable = nil, tonumber( tBreak[1], 10 ), "requests"
		local tRow = tFunction.FetchRow( tInsertData.sTable, tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
			return false
		end
		if tProfiles.AllowVIP[tUser.iProfile] or tRow.nick:lower() == tUser.sNick:lower() then
			local sTemporary = "The following entry has been deleted:\n\tID#%d. [%s] - %s (Added by %s)"
			Core.SendPmToUser( tUser, tCfg.sBotName, sTemporary:format(tInsertData.iID, tRow.ctg, tRow.msg, tRow.nick) )
			tInfobot.del( tUser, tInsertData )
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "You are not allowed to delete that request." )
		end
		return true

	elseif sCommand == "delsug" or sCommand == "dsg" then
		local tBreak = tFunction.Explode( sData )
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return false
		end
		tInsertData.sMsg, tInsertData.iID, tInsertData.sTable = nil, tonumber( tBreak[1], 10 ), "suggestions"
		local tRow = tFunction.FetchRow( tInsertData.sTable, tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
			return false
		end
		if tProfiles.AllowVIP[tUser.iProfile] or tRow.nick:lower() == tUser.sNick:lower() then
			local sTemporary = "The following entry has been deleted:\n\t%d. [%s] - %s (Added by %s)"
			Core.SendPmToUser( tUser, tCfg.sBotName, sTemporary:format(tInsertData.iID, tRow.ctg, tRow.msg, tRow.nick) )
			tInfobot.del( tUser, tInsertData )
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "You are not allowed to delete that suggestion field." )
			return false
		end
		return true

	elseif sCommand == "delnws" or sCommand == "dn" then
		local tBreak = tFunction.Explode( sData )
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
		end
		tInsertData.sMsg, tInsertData.iID, tInsertData.sTable = nil, tonumber( tBreak[1], 10 ), "news"
		local tRow = tFunction.FetchRow( tInsertData.sTable, tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
			return false
		end
		if tProfiles.AllowVIP[tUser.iProfile] or tRow.nick:lower() == tUser.sNick:lower() then
			local sTemporary = "The following entry has been deleted:\n\t%d. %s (Added by %s)"
			Core.SendPmToUser( tUser, tCfg.sBotName, sTemporary:format(tInsertData.iID, tRow.msg, tRow.nick) )
			tInfobot.del( tUser, tInsertData )
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "You are not allowed to delete that news content." )
			return false
		end
		return true

	elseif sCommand == "delbns" or sCommand == "dbsell" then
		local tBreak = tFunction.Explode( sData )
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return false
		end
		tInsertData.sMsg, tInsertData.iID, tInsertData.sTable = nil, tonumber( tBreak[1], 10 ), "buynsell"
		local tRow = tFunction.FetchRow( tInsertData.sTable, tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
			return false
		end
		if tProfiles.AllowVIP[tUser.iProfile] or tRow.nick:lower() == tUser.sNick:lower() then
			local sTemporary = "The following entry has been deleted:\n\tID#%d. [%s] - %s (Added by %s)"
			Core.SendPmToUser( tUser, tCfg.sBotName, sTemporary:format(tInsertData.iID, tRow.type, tRow.msg, tRow.nick) )
			tInfobot.del( tUser, tInsertData )
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "You are not allowed to delete that thread." )
		end
		return true

	elseif sCommand == "delmsg" or sCommand == "dmsg" then
		local tBreak = tFunction.Explode( sData )
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return false
		end
		tInsertData.sMsg, tInsertData.iID, tInsertData.sTable = nil, tonumber( tBreak[1], 10 ), "replies"
		local tRow = tFunction.FetchRow( tInsertData.sTable, tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No reply with that ID." )
			return false
		end
		if tProfiles.AllowVIP[tUser.iProfile] or tRow.nick:lower() == tUser.sNick:lower() then
			local sTemporary = "The following reply has been deleted:\n\tID#%d. %s (Added by %s)"
			Core.SendPmToUser( tUser, tCfg.sBotName, sTemporary:format(tInsertData.iID, tRow.msg, tRow.nick) )
			tInfobot.del( tUser, tInsertData )
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "You are not allowed to delete that reply." )
		end
		return true

	end
end
