local tConfig = {
	sDatabase = "latest",
	sMySQLUser = "offliner",
	sMySQLPass = "latest@hhfh",
	sBotName = "[BOT]Offliner",
	sHub = SetMan.GetString( 2 ) or "localhost"
}
tConfig.sHubFAQ = "http://"..tConfig.sHub.."/faq.php?code=%s&num=%s"
tConfig.sLatestPage = "http://"..tConfig.sHub.."/latest/"

function OnError( sError )
	Core.SendPmToNick( "hjpotter92", "lol", "OFF: "..sError )
end

_G.tFunction = {
	Connect = function()
		local luasql
		if not luasql then
			luasql = require "luasql.mysql"
		end
		_G.SQLEnv = assert( luasql.mysql() )
		_G.SQLCon = assert( SQLEnv:connect( tConfig.sDatabase, tConfig.sMySQLUser, tConfig.sMySQLPass, "localhost", "3306") )
		return tFunction.CheckModerator(), tFunction.CheckCategory()
	end,

	Explode = function( sData )
		if not sData then
			return {}
		end
		local tReturn = {}
		string.gsub( sData, "(%S+)", function( sGrab )
			table.insert( tReturn, sGrab )
		end )
		return tReturn
	end,

	Report = function( sErrorCode, iErrorNumber )
		local sReturn = "ERROR (%s#%04d): You should check %s for more information."
		return sReturn:format( sErrorCode:upper(), iErrorNumber, tConfig.sHubFAQ:format(sErrorCode:upper(), iErrorNumber) )
	end,

	CreateLatestReading = function( tEntry )
		local sMagnets = tFunction.FetchMagnets( tonumber(tEntry.id) )
		local sEntry = string.format( "%d. [%s] - %s (Added by %s on %s)", tEntry.id, tEntry.ctg, tEntry.msg, tEntry.nick, tEntry.date )
		if sMagnets then
			return sEntry.."\n\t"..sMagnets
		else
			return sEntry
		end
	end,

	GetCategories = function()
		local tReturn, sCategoryQuery = {}, [[SELECT `name` FROM `ctgtable`]]
		local SQLCur = assert( SQLCon:execute(sCategoryQuery) )
		local tRow = SQLCur:fetch( {}, "a" )
		while tRow do
			table.insert( tReturn, tRow.name )
			tRow = SQLCur:fetch( {}, "a" )
		end
		SQLCur:close()
		return tReturn
	end,

	GetSize = function( iSize )
		local iSizeTemp, sPrefix, i = tonumber(iSize) or 0, {"", "Ki", "Mi", "Gi", "Ti", "Pi"}, 1
		while iSizeTemp > 1024 do
			iSizeTemp, i = iSizeTemp/1024, i+1
		end
		return string.format( "%.2f %sB", iSizeTemp, sPrefix[i] )
	end,

	GetModerators = function()
		local tReturn, sCategoryQuery = {}, "SELECT `nick` FROM `modtable` WHERE `active` = 'Y' AND `deletions` < 6 ORDER BY `id` ASC"
		local SQLCur = assert( SQLCon:execute(sCategoryQuery) )
		local tRow = SQLCur:fetch( {}, "a" )
		while tRow do
			table.insert( tReturn, tRow.nick )
			tRow = SQLCur:fetch( {}, "a" )
		end
		SQLCur:close()
		return tReturn
	end,

	FetchRow = function( iID )
		local tReturn, sQuery = {}, string.format( "SELECT * FROM `entries` WHERE `id` = %d LIMIT 1", iID )
		local SQLCur = assert( SQLCon:execute(sQuery) )
		tReturn = SQLCur:fetch( {}, "a" )
		SQLCur:close()
		return tReturn
	end,

	FetchMagnetRow = function( iMID )
		local tReturn, sQuery = {}, string.format( "SELECT * FROM `magnets` WHERE id = %d LIMIT 1", iMID )
		local SQLCur = assert( SQLCon:execute(sQuery) )
		tReturn = SQLCur:fetch( {}, "a" )
		SQLCur:close()
		return tReturn
	end,

	FetchMagnets = function( iEID )
		local tReturn, sQuery = {}, "SELECT `id`, `tth`, `size`, `nick`, `date` FROM `magnets` WHERE `eid` = %d ORDER BY `date` DESC LIMIT 5"
		local SQLCur = assert( SQLCon:execute(string.format( sQuery, iEID )) )
		if SQLCur:numrows() == 0 then
			return nil
		end
		local tRow = SQLCur:fetch( {}, "a" )
		while tRow do
			table.insert( tReturn, string.format("%d. [%s] magnet:?xt=urn:tree:tiger:%s&xl=%.0f (Added by %s on %s)", tRow.id, tFunction.GetSize(tRow.size), tRow.tth, tRow.size, tRow.nick, tRow.date) )
			tRow = SQLCur:fetch( {}, "a" )
		end
		return table.concat( tReturn, "\n\t" )
	end,

	SendToAll = function( sAsUser, sMessage )
		local sFileName = "/www/ChatLogs/"..os.date( "%Y/%m/%d_%m_%Y" )..".txt"
		local fWrite = io.open( sFileName, "a" )
		local sChatLine = "<"..sAsUser.."> "..sMessage
		if fWrite then
			fWrite:write( os.date("[%I:%M:%S %p]").." "..sChatLine.."\n" )
			fWrite:flush()
			fWrite:close()
		end
		Core.SendToAll( sChatLine )
		return sChatLine
	end
}

tFunction.CheckCategory = function( sInput )
	local sReturn, tTemporary, bFlag = "The following %02d categories are allowed: ", tFunction.GetCategories(), false
	sReturn = sReturn:format( #tTemporary )..table.concat( tTemporary, ", " ).."\n"
	if not sInput then return sReturn end
	for iIndex, sValues in ipairs( tTemporary ) do
		if sValues:lower() == sInput:lower() then
			bFlag = true
			break
		end
	end
	if bFlag then
		return bFlag
	else
		return bFlag, sReturn
	end
end

tFunction.CheckModerator = function( sInput )
	local sReturn, tTemporary, bFlag = "There are %02d moderators active: \n\n", tFunction.GetModerators(), false
	sReturn = sReturn:format( #tTemporary )..table.concat( tTemporary, ", " ).."\n"
	if not sInput then return sReturn end
	if sInput then
		for iIndex, sValues in ipairs( tTemporary ) do
			if sValues:lower() == sInput:lower() then
				bFlag = true
				break
			end
		end
	end
	if bFlag then
		return bFlag
	else
		return bFlag, sReturn
	end
end

_G.tOffliner = {
	l = function( tUser, iLimit, sCategory )
		local sLatestQuery, tTemporary, sSuffix = [[SELECT `id`,
			`ctg`,
			`msg`,
			`nick`,
			`date`
		FROM ( SELECT `id`,
				`ctg`,
				`msg`,
				`nick`,
				`date`
			FROM `entries`
			WHERE `ctg` %s
			ORDER BY `id` DESC
			LIMIT %d ) AS `temp`
		ORDER BY `id` ASC ]], {}, "get_latest.php"
		local sPMToUser = "Welcome to HiT Hi FiT Hai - The IIT Kgp's Official hub.\n\n\t[BOT]Offliner fetched following information:\n\n"
		if not iLimit and not sCategory then
			iLimit = 35
                        sCategory = "<> 'sdmovie' OR (`ctg` = 'sdmovie' AND `msg` REGEXP 'DVDRIP')"

		else
			if iLimit > 50 or iLimit < 5 then
				iLimit = 5
			else
				iLimit = iLimit
			end
			if not sCategory then
				sCategory = "<> 'sdmovie' OR (`ctg` = 'sdmovie' AND `msg` REGEXP 'DVDRIP')"
			else
				if not tFunction.CheckCategory(sCategory) then
				   sCategory = "<> 'sdmovie' OR (`ctg` = 'sdmovie' AND `msg` REGEXP 'DVDRIP')"
				else
					sSuffix = sCategory
					sCategory = "= '"..sCategory.."'"
				end
			end
		end
		sSuffix = tConfig.sLatestPage..sSuffix
		sLatestQuery = string.format( sLatestQuery, sCategory, iLimit )
		local SQLCur = assert( SQLCon:execute(sLatestQuery) )
		if SQLCur:numrows() == 0 then
			Core.SendPmToUser( tUser, tConfig.sBotName, sPMToUser.."No result was obtained for your query.|" )
			return
		end
		local tRow = SQLCur:fetch( {}, "a" )
		while tRow do
			table.insert( tTemporary, tFunction.CreateLatestReading(tRow) )
			tRow = SQLCur:fetch( {}, "a" )
		end
		sPMToUser = sPMToUser..table.concat( tTemporary, "\n\n" )
		Core.SendPmToUser( tUser, tConfig.sBotName, sPMToUser.."\n\nThese results are displayed on the hub-webpage: "..sSuffix.."|" )
		if type(SQLCur) ~= "number" then SQLCur:close() end
		return true
	end,

	s = function( tUser, sSearchString )
		local sSearchQuery, tTemporary, sSuffix = [[SELECT *
		FROM ( SELECT `id`,
				`ctg`,
				`msg`,
				`nick`,
				`date`
			FROM `entries`
			WHERE `msg` REGEXP '%s'
			ORDER BY `id` DESC
			LIMIT 20 ) AS `temp`
		ORDER BY `id` ASC ]], {}, "s/"
		local sPMToUser = "Welcome to HiT Hi FiT Hai - The IIT Kgp's Official hub.\n\n\t[BOT]Offliner fetched following information for the search:\n\n"
		sSearchQuery = string.format( sSearchQuery, SQLCon:escape(sSearchString:gsub("%(", "\\("):gsub("%[", "\\["):gsub("%{", "\\{")) )
		local SQLCur = assert( SQLCon:execute(sSearchQuery) )
		if SQLCur:numrows() == 0 then
			Core.SendPmToUser( tUser, tConfig.sBotName, sPMToUser.."No result was obtained for your query.|" )
			return
		end
		sSuffix = tConfig.sLatestPage..sSuffix..sSearchString:gsub( "%s+", "+" )
		local tRow = SQLCur:fetch( {}, "a" )
		while tRow do
			table.insert( tTemporary, tFunction.CreateLatestReading(tRow) )
			tRow = SQLCur:fetch( {}, "a" )
		end
		sPMToUser = sPMToUser..table.concat( tTemporary, "\n\n" )
		Core.SendPmToUser( tUser, tConfig.sBotName, sPMToUser.."\n\nThese search results are linked to: "..sSuffix.."|" )
		if type(SQLCur) ~= "number" then SQLCur:close() end
		return true
	end,

	al = function( tUser, tInput )
		local sCategory, sContent, sAdditionQuery = tInput[1], table.concat( tInput, " ", 2 ), [[INSERT INTO `entries`(`ctg`,`msg`,`nick`,`date`)
		VALUES( '%s', '%s', '%s', NOW() ) ]]
		local sMagnetQuery = [[INSERT INTO `magnets`(`eid`,`tth`,`size`,`nick`,`date`)
		VALUES( %d, '%s', %.0f, '%s', NOW() ) ]]
		local sEntry, sTTH = sContent:match( "(.*) magnet%:%?xt=urn%:tree%:tiger%:(%w+)" )
		local iSize = sContent:match( "xl=(%d+)&" )
		if not (sTTH and iSize) or sTTH:len() ~= 39 then
			Core.SendPmToUser( tUser, tConfig.sBotName, tFunction.Report("off", 80) )
			return false
		end
		sEntry, sNick = SQLCon:escape( sEntry ), SQLCon:escape( tUser.sNick )
		sAdditionQuery = string.format( sAdditionQuery, sCategory:lower(), sEntry, sNick )
		local SQLCur = assert( SQLCon:execute(sAdditionQuery) )
		local iID = SQLCon:getlastautoid()
		sMagnetQuery = string.format( sMagnetQuery, iID, sTTH, tonumber(iSize), sNick )
		SQLCur = assert( SQLCon:execute(sMagnetQuery) )
		if type(SQLCur) ~= "number" then SQLCur:close() end
		Core.SendPmToUser( tUser, tConfig.sBotName, "Your message has been added to database. Your addition entry: #"..tostring(iID).." and magnet entry #"..tostring(SQLCon:getlastautoid()) )
		return true
	end,

	dl = function( tUser, iID )
		local sDeleteQuery, sModNick = string.format( [[DELETE e.*, m.*
		FROM `entries` e
		LEFT JOIN `magnets` m
			ON m.`eid` = e.`id`
		WHERE e.`id` = %d]], tonumber(iID) ), tFunction.FetchRow(iID).nick
		local SQLCur = assert( SQLCon:execute(sDeleteQuery) )
		if sModNick:lower() ~= tUser.sNick:lower() then
			local SQLCur = assert( SQLCon:execute("UPDATE `modtable` SET `deletions` = `deletions` + 1 WHERE `nick`='"..SQLCon:escape(sModNick).."'") )
		end
		if type(SQLCur) ~= "number" then SQLCur:close() end
		return true
	end,

	ul = function( tUser, tInput )
		local iID, sContent, sUpdateQuery = tonumber(tInput[1]), table.concat(tInput, " ", 2), [[UPDATE `entries`
		SET `msg` = '%s'
		WHERE `id` = %d ]]
		sUpdateQuery = string.format( sUpdateQuery, SQLCon:escape(sContent), iID )
		if not sContent:find( "magnet%:%?" ) then
			local SQLCur = assert( SQLCon:execute(sUpdateQuery) )
			if type(SQLCur) ~= "number" then SQLCur:close() end
			return true
		else
			Core.SendPmToUser( tUser, tConfig.sBotName, "Sorry! You must remove magnet when updating." )
		end
	end,

	addmod = function( tUser, sModNick )
		local sAddModerator = [[INSERT INTO `modtable`(`nick`, `added_by`, `active`, `date`)
		VALUES( '%s', '%s', 'Y', NOW() )
		ON DUPLICATE KEY
		UPDATE
			`active` = 'Y',
			`added_by` = '%s',
			`deletions` = 0,
			`date` = NOW() ]]
		sAddModerator = string.format( sAddModerator, SQLCon:escape(sModNick), SQLCon:escape(tUser.sNick), SQLCon:escape(tUser.sNick) )
		local SQLCur = assert( SQLCon:execute(sAddModerator) )
		if type(SQLCur) ~= "number" then SQLCur:close() end
		return true
	end,

	delmod = function( tUser, sModNick )
		local sRemoveModerator = [[UPDATE `modtable`
		SET `active` = 'N',
			`deletions` = 50,
			`date` = NOW()
		WHERE `nick` = '%s' ]]
		sRemoveModerator = string.format( sRemoveModerator, SQLCon:escape(sModNick) )
		local SQLCur = assert( SQLCon:execute(sRemoveModerator) )
		return true
	end,

	addctg = function( tUser, sCategory )
		local sAddCategory = string.format( "INSERT INTO `ctgtable`(`name`) VALUES( '%s')", SQLCon:escape(sCategory) )
		local SQLCur = assert( SQLCon:execute(sAddCategory))
		if type(SQLCur) ~= "number" then SQLCur:close() end
		return true
	end,

	delctg = function( tUser, sCategory )
		local sRemoveCategory = "DELETE FROM `ctgtable` WHERE `ctg` = '"..sCategory.."'"
		local SQLCur = assert( SQLCon:execute(sRemoveCategory))
		if type(SQLCur) ~= "number" then SQLCur:close() end
		return true
	end,

	am = function( tUser, tInput )
		local iID, sContent = tInput[1], tInput[2]
		local sMagnetQuery = [[INSERT INTO `magnets`(`eid`,`tth`,`size`,`nick`,`date`)
		VALUES( %d, '%s', %.0f, '%s', NOW() ) ]]
		local sTTH, iSize = sContent:match( "tree%:tiger%:(%w+)&xl=(%d+)&" )
		if not (sTTH and iSize) or sTTH:len() ~= 39 then
			Core.SendPmToUser( tUser, tConfig.sBotName, tFunction.Report("off", 80) )
			return false
		end
		sMagnetQuery = string.format( sMagnetQuery, iID, sTTH, tonumber(iSize), SQLCon:escape(tUser.sNick) )
		local SQLCur = assert( SQLCon:execute(sMagnetQuery) )
		if type(SQLCur) ~= "number" then SQLCur:close() end
		Core.SendPmToUser( tUser, tConfig.sBotName, "The magnet to entry #"..tostring(iID).." has been added. The magnet ID is #"..tostring(SQLCon:getlastautoid()).."." )
		return true
	end,

	em = function( tUser, tInput )
		local iMID, sContent = tInput[1], tInput[2]
		local sMagnetQuery = [[UPDATE `magnets`
		SET `tth` = '%s',
			`size` = %.0f,
			`nick` = '%s',
			`date` = NOW()
		WHERE `id` = %d ]]
		local sTTH, iSize = sContent:match( "tree%:tiger%:(%w+)&xl=(%d+)&" )
		if not (sTTH and iSize) or sTTH:len() ~= 39 then
			Core.SendPmToUser( tUser, tConfig.sBotName, tFunction.Report("off", 80) )
			return false
		end
		sMagnetQuery = string.format( sMagnetQuery, sTTH, tonumber(iSize), SQLCon:escape(tUser.sNick), iMID )
		local SQLCur = assert( SQLCon:execute(sMagnetQuery) )
		if type(SQLCur) ~= "number" then SQLCur:close() end
		Core.SendPmToUser( tUser, tConfig.sBotName, "The magnet entry #"..tostring(iMID).." has been updated." )
		return true
	end,

	rm = function( tUser, iMID )
		local sMagnetQuery = string.format( [[DELETE FROM `magnets`
		WHERE `id` = %d
		LIMIT 1]], iMID )
		local SQLCur = assert( SQLCon:execute(sMagnetQuery) )
		if type(SQLCur) ~= "number" then SQLCur:close() end
		Core.SendPmToUser( tUser, tConfig.sBotName, "The magnet ID: #"..tostring(SQLCon:getlastautoid()).." was removed." )
		return true
	end,

	StoreMessage = function( sSender, sRecipient, sMessage )
		local sStorageQuery = [[INSERT INTO `messages`(`message`, `from`, `to`, `dated`)
		VALUES ( '%s', '%s', '%s', NOW() ) ]]
		sStorageQuery = sStorageQuery:format( SQLCon:escape(sMessage), SQLCon:escape(sSender), SQLCon:escape(sRecipient) )
		local SQLCur = assert( SQLCon:execute(sStorageQuery) )
		Core.SendPmToNick( sSender, tConfig.sBotName, "The message has been stored with ID: #"..tostring(SQLCon:getlastautoid())..". It'll be delivered to "..sRecipient.." when they connect to hub." )
		return true
	end,

	PassMessage = function( sNick )
		local sSearchUserQuery = [[SELECT `id`,
			`from`,
			`dated`,
			`message`
		FROM `messages`
		WHERE `to` = '%s'
			AND `delivered` = 'N' ]]
		sSearchUserQuery = sSearchUserQuery:format( SQLCon:escape(sNick) )
		local SQLCur = assert( SQLCon:execute(sSearchUserQuery) )
		if SQLCur:numrows() == 0 then
			return false
		end
		local tRow, sMessage, sEditMessage = SQLCur:fetch( {}, "a" ), "An offline message with ID #%04d was sent to you by %s on %s. The message is: \n\t%s\n\n\tThank you for using offline message services.", "UPDATE `messages` SET `delivered` = 'Y' WHERE `id` = %d"
		while tRow do
			local SQLTemp = assert( SQLCon:execute(sEditMessage:format(tRow.id)) )
			Core.SendPmToNick( sNick, tConfig.sBotName, sMessage:format(tRow.id, tRow.from, tRow.dated, tRow.message) )
			tRow = SQLCur:fetch( {}, "a" )
			SQLTemp = nil
		end
		tRow = nil
		SQLCur:close()
	end
}

function OnExit()
	Core.UnregBot( tConfig.sBotName )
	SQLCon:close()
	SQLEnv:close()
end
