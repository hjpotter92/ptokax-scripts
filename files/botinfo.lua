local tConfig = {
	sDatabase = "latest",
	sMySQLUser = "offliner",
	sMySQLPass = "latest@hhfh",
	sBotName = "[BOT]Info",
	sHub = SetMan.GetString( 2 ) or "localhost"
}
tConfig.sHubFAQ = "http://"..tConfig.sHub.."/faq.php?code=%s&num=%s"
tConfig.sLatestPage = "http://"..tConfig.sHub.."/latest/"

function OnError( sErrorCode )
	local _, _, sCode, sNum = sErrorCode:find( "^(%w+)%#(%w+)$" )
	Core.SendPmToNick( "hjpotter92", "lol", "INFO: "..sErrorCode )
end

_G.tFunction = {
	Connect = function()
		if not luasql then
			luasql = require "luasql.mysql"
		end
		_G.SQLEnv = assert( luasql.mysql() )
		_G.SQLCon = assert( SQLEnv:connect( tConfig.sDatabase, tConfig.sMySQLUser, tConfig.sMySQLPass, "localhost", "3306") )
		return tFunction.CheckCategory()
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

	FetchRow = function( sTable, iID )
		local sFields, sQuery, tReturn = "`msg`, `nick`", "SELECT %s FROM `%s` WHERE `id` = %d LIMIT 1", {}
		if sTable == "requests" or sTable == "suggestions" then
			sFields = "`ctg`, "..sFields
		end
		sQuery = sQuery:format( sFields, sTable, iID )
		local SQLCur = assert( SQLCon:execute(sQuery) )
		tReturn = SQLCur:fetch( {}, "a" )
		SQLCur:close()
		return tReturn
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
	local sReturn, tTemporary, bFlag = "The possible categories are: ", tFunction.GetCategories(), false
	sReturn = sReturn..table.concat( tTemporary, ", " ).."\n"
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

--[[ tFunction.CheckModerator = function( sInput )
	local sReturn, tTemporary, bFlag = "The current moderators are: \n\n", tFunction.GetModerators(), false
	sReturn = sReturn..table.concat( tTemporary, ", " ).."\n"
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
end ]]--

_G.tInfobot = {
	readAll = function( sTable, iLimit )
		local sEntireList, tAllTables, sFields, sReadQuery, tList = "Welcome to HiT Hi FiT Hai - The IIT Kgp's Official hub.\n The following list was fetched by "..tConfig.sBotName.."\n\n", { "requests", "suggestions", "deletions", "guestbook", "news" }, "`msg`, `nick`, `dated`", [[SELECT %s
			FROM (
				SELECT %s
				FROM `%s`
				ORDER BY `id` DESC
				LIMIT %d
			) `temp`
			ORDER BY `id` ASC]], {}
		for iIndex, sTableName in pairs( tAllTables ) do
			local sList = tInfobot.readOne( sTableName:lower(), 15 )
			if sList then
				table.insert( tList, sList )
				sList = nil
			end
		end
		return table.concat( tList, "\n\n" )
	end,

	readOne = function( sTable, iLimit )
		local sReturnList, sFields, sReadQuery, tTemporary, sEntry = "Welcome to HiT Hi FiT Hai - The IIT Kgp's Official hub.\n The following list was fetched by "..tConfig.sBotName.."\n\nTable: "..sTable:upper().."\t\t\tLimit: "..tostring(iLimit).."\n\n", "`id`, `msg`, `nick`, `dated`", [[SELECT *
			FROM (
				SELECT %s
				FROM `%s`
				ORDER BY `id` DESC
				LIMIT %d
			) `temp`
			ORDER BY `id` ASC]], {}, "%d. %s (Added by %s on %s)"
		if sTable == "suggestions" then
			sFields = "`ctg`, "..sFields
			SQLCur = assert( SQLCon:execute(sReadQuery:format( sFields, sTable, iLimit )) )
			local tRow = SQLCur:fetch( {}, "a" )
			while tRow do
				table.insert( tTemporary, sEntry:format(tRow.id, ("[%s] - %s"):format(tRow.ctg, tRow.msg), tRow.nick, tRow.dated) )
				tRow = SQLCur:fetch( {}, "a" )
			end

		elseif sTable == "requests" then
			sFields = sFields..", `ctg`, CASE `filled` WHEN 'Y' THEN UPPER('filled') WHEN 'N' THEN UPPER('empty') WHEN 'C' THEN UPPER('closed') END `filled`"
			sReadQuery = sReadQuery:format( sFields, sTable, iLimit )
			SQLCur = assert( SQLCon:execute(sReadQuery) )
			local tRow = SQLCur:fetch( {}, "a" )
			while tRow do
				table.insert( tTemporary, sEntry:format(tRow.id, ("[%s] [%s] - %s"):format(tRow.filled, tRow.ctg, tRow.msg), tRow.nick, tRow.dated) )
				tRow = SQLCur:fetch( {}, "a" )
			end
		else
			SQLCur = assert( SQLCon:execute(sReadQuery:format( sFields, sTable, iLimit )) )
			local tRow = SQLCur:fetch( {}, "a" )
			while tRow do
				table.insert( tTemporary, sEntry:format(tRow.id, tRow.msg, tRow.nick, tRow.dated) )
				tRow = SQLCur:fetch( {}, "a" )
			end
		end

		return ( sReturnList..table.concat(tTemporary, "\n") )
	end,

	add = function( tUser, tInput )
		local sFields, sValues = "`msg`, `nick`, `dated`", ("'%s', '%s', NOW()"):format( SQLCon:escape(tInput.sMsg), SQLCon:escape(tUser.sNick) )
		if tInput.sTable:lower() == "requests" or tInput.sTable:lower() == "suggestions" then
			sFields, sValues = "`ctg`, "..sFields, ("'%s', %s"):format( SQLCon:escape(tInput.sCtg), sValues )
		end
		local sQuery = [[INSERT IGNORE INTO `%s`(%s)
			VALUES (%s) ]]
		sQuery = sQuery:format( tInput.sTable, sFields, sValues )
		local SQLCur = assert( SQLCon:execute(sQuery) )
		if type(SQLCur) ~= "number" then
			SQLCur:close()
		else
			SQLCur = nil
		end
		return SQLCon:getlastautoid()
	end,

	StoreMessage = function( sSender, sRecipient, sMessage )
		local sStorageQuery = [[INSERT INTO `messages`(`message`, `from`, `to`, `dated`)
			VALUES ( '%s', '%s', '%s', NOW() ) ]]
		sStorageQuery = sStorageQuery:format( SQLCon:escape(sMessage), SQLCon:escape(sSender), SQLCon:escape(sRecipient) )
		local SQLCur = assert( SQLCon:execute(sStorageQuery) )
		return SQLCon:getlastautoid()
	end,

	del = function( tUser, tInput )
		local sDeleteQuery = string.format( "DELETE FROM `%s` WHERE `id` = %d", SQLCon:escape(tInput.sTable), tInput.iID )
		local SQLCur = assert( SQLCon:execute(sDeleteQuery) )
		if type(SQLCur) ~= "number" then SQLCur:close() end
		return true
	end,

	fill = function( tUser, iID, bClosure )
		local sUpdateQuery = [[UPDATE `requests`
			SET `filled` = '%s',
				`filldate` = NOW(),
				`filledby` = '%s'
			WHERE `id` = %d
			LIMIT 1]]
		sUpdateQuery = sUpdateQuery:format( (bClosure and 'C') or 'Y', SQLCon:escape(tUser.sNick), iID )
		local SQLCur = assert( SQLCon:execute(sUpdateQuery) )
		if type(SQLCur) ~= "number" then
			SQLCur:close()
		else
			SQLCur = nil
		end
		return true
	end
}

function OnExit()
	Core.UnregBot( tConfig.sBotName )
	SQLCon:close()
	SQLEnv:close()
end
