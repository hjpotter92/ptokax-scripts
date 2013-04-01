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
		iModProfile = 4,
		iRegProfile = 5
	}
	tProfiles = {
		AllowVIP = {
			[0] = true,			-- Admin
			[1] = true,			-- God
			[2] = true,			-- OP
			[3] = true,			-- VIP
			[4] = false,		-- Mods
			[5] = false,		-- Reg
			[6] = false,		-- sVIP
			[7] = false			-- gymkhana
		},
		AllowAdmin = {
			[0] = true,			-- Admin
			[1] = false,			-- God
			[2] = true,			-- OP
			[3] = false,			-- VIP
			[4] = false,		-- Mods
			[5] = false,		-- Reg
			[6] = false,		-- sVIP
			[7] = false			-- gymkhana
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
	sAllModerators, sAllCategories = tFunction.Connect()
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
		local sList = tInfobot.readAll( "all", iLimit )
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

	local tInsertData, iLastID = { sMsg = sData, sTable = "all" }, 0

	if sCommand == "areq" or sCommand == "ar" then
		local tBreak = tFunction.Explode( sData )
		if tFunction.CheckCategory( tBreak[1] ) then
			tInsertData.sCtg = tBreak[1]
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "Wrong category!" )
		end
		tInsertData.sMsg, tInsertData.sTable = table.concat( tBreak, " ", 2 ), "requests"
		if not tInsertData.sMsg then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No message provided." )
			return false
		elseif tInsertData.sMsg:len() > 200 then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Too long text!" )
			return false
		end
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
		end
		Core.SendPmToUser( tUser, tCfg.sBotName, "Request has been added at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "asug" or sCommand == "asg" then
		local tBreak = tFunction.Explode( sData )
		if tFunction.CheckCategory( tBreak[1] ) then
			tInsertData.sCtg = tBreak[1]
		else
			Core.SendPmToUser( tUser, tCfg.sBotName, "Wrong category!" )
		end
		tInsertData.sMsg, tInsertData.sTable = table.concat( tBreak, " ", 2 ), "suggestions"
		if not tInsertData.sMsg then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No message provided." )
			return false
		elseif tInsertData.sMsg:len() > 200 then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Too long text!" )
			return false
		end
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
		end
		Core.SendPmToUser( tUser, tCfg.sBotName, "Suggestion has been added at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "anws" or sCommand == "an" then
		tInsertData.sTable = "news"
		if not tInsertData.sMsg then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No message provided." )
			return false
		elseif tInsertData.sMsg:len() > 200 then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Too long text!" )
			return false
		end
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
		end
		Core.SendPmToUser( tUser, tCfg.sBotName, "News has been added at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "agst" or sCommand == "ag" then
		tInsertData.sTable = "guestbook"
		if not tInsertData.sMsg then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No message provided." )
			return false
		elseif tInsertData.sMsg:len() > 200 then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Too long text!" )
			return false
		end
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
		end
		Core.SendPmToUser( tUser, tCfg.sBotName, "Your comment has been recorded at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "adel" or sCommand == "ad" then
		tInsertData.sTable = "deletions"
		if not tInsertData.sMsg then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No message provided." )
			return false
		elseif tInsertData.sMsg:len() > 200 then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Too long text!" )
			return false
		end
		iLastID = tInfobot.add( tUser, tInsertData )
		if not iLastID then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Something went wrong." )
		end
		Core.SendPmToUser( tUser, tCfg.sBotName, "Deletion info has been added at ID #"..tostring(iLastID).."." )
		return true

	elseif sCommand == "fill" then
		local tBreak, sReply = tFunction.Explode( sData ), "You filled the request #%d - %s. The requesting user will be notified with message ID#%d when they connect."
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "The ID must be numerical!" )
		end
		tInsertData.sMsg, tInsertData.iID = nil, tonumber( tBreak[1], 10 )
		local tRow = tFunction.FetchRow( "requests", tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
		end
		local iOfflineMessageID = tInfobot.StoreMessage( tUser.sNick, tRow.nick, "I've filled your request ID#"..tostring(tRow.id).." - "..tRow.msg.."." ), tInfobot.fill( tUser, tonumber(tBreak[1], 10) )
		Core.SendPmToUser( tUser, tCfg.sBotName, sReply:format(tonumber(tRow.id), tRow.msg, tonumber(iOfflineMessageID)) )
		return true

	elseif sCommand == "delreq" or sCommand == "dr" then
		local tBreak = tFunction.Explode( sData )
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "The ID must be numerical!" )
		end
		tInsertData.sMsg, tInsertData.iID, tInsertData.sTable = nil, tonumber( tBreak[1], 10 ), "requests"
		local tRow = tFunction.FetchRow( "requests", tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
		end
		tInfobot.del( tUser, "requests", tInsertData )
		return true

	elseif sCommand == "delsug" or sCommand == "dsg" then
		local tBreak = tFunction.Explode( sData )
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "The ID must be numerical!" )
		end
		tInsertData.sMsg, tInsertData.iID, tInsertData.sTable = nil, tonumber( tBreak[1], 10 ), "suggestions"
		local tRow = tFunction.FetchRow( "suggestions", tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
		end
		tInfobot.del( tUser, tInsertData )
		return true

	elseif sCommand == "delnws" or sCommand == "dn" then
		local tBreak = tFunction.Explode( sData )
		if not tonumber( tBreak[1], 10 ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "The ID must be numerical!" )
		end
		tInsertData.sMsg, tInsertData.iID, tInsertData.sTable = nil, tonumber( tBreak[1], 10 ), "news"
		local tRow = tFunction.FetchRow( "news", tInsertData.iID )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No entry with that ID." )
		end
		tInfobot.del( tUser, tInsertData )
		return true

	end
end
