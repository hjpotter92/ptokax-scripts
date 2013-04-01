--[[
--
--	The chat logger stat bot, defined and designed by hjpotter92 and Brick
--	for HiT Hi FiT Hai - Sharing for Friends hub.
--
--	Please don't share the codes on external websites/git without permissions
--
--]]

if not luasql then
	luasql = require "luasql.mysql"
end

function CreateConnection()
	env = assert( luasql.mysql() )
	con = assert( env:connect( "stats", "root", "mysql@hhfh", "localhost", "3306" ) )
--	Core.SendPmToNick( "hjpotter92", "hTest", "MySQL Connection established." )
	return env, con
end

function InitialiseDB( SQLCon )
	local SQLRes = assert( SQLCon:execute([[CREATE TABLE IF NOT EXISTS `chatstat` (
				`id` BIGINT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`username` VARCHAR(25) NOT NULL,
				`totalcount` BIGINT(20) UNSIGNED NOT NULL,
				`thismonth` BIGINT(20) UNSIGNED NOT NULL,
				`thisweek` INT(10) UNSIGNED NOT NULL,
				`lastweek` INT(10) UNSIGNED NOT NULL,
				`lastmonth` INT(10) UNSIGNED NOT NULL,
			PRIMARY KEY (`id`),
			UNIQUE INDEX `id` (`id`),
			UNIQUE INDEX `username` (`username`)
		)
		ENGINE=MyISAM ]]) )
	local SQLRes = assert( SQLCon:execute([[CREATE TABLE IF NOT EXISTS `datedcount` (
				`id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
				`ondate` DATE NOT NULL,
				`chatcount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`pmcount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`botpmcount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
			PRIMARY KEY (`id`),
			UNIQUE INDEX `ondate` (`ondate`),
			INDEX `id` (`id`)
		)
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM ]]) )
end

local iRecord = 0

function UpdateUserStat( SQLCon, sNick )
	local sNick = SQLCon:escape(sNick)
	local sQuery = [[INSERT INTO `chatstat`(`username`, `totalcount`, `thismonth`, `thisweek`)
		VALUES( '%s', 1, 1, 1 )
		ON DUPLICATE KEY
		UPDATE `totalcount` = `totalcount` + 1, `thismonth` = `thismonth` + 1, `thisweek` = `thisweek` + 1 ]]
	local SQLCur = assert( SQLCon:execute(string.format(sQuery, sNick)) )
end

function UpdateChatDate( SQLCon, sDate )
	local sChatDateQuery = [[INSERT INTO `datedcount`(`ondate`, `chatcount`)
		VALUES( '%s', 1 )
		ON DUPLICATE KEY
		UPDATE `chatcount` = `chatcount` + 1 ]]
	local SQLCur = assert( SQLCon:execute(string.format( sChatDateQuery, SQLCon:escape(sDate) )) )
end

function UpdatePMDate( SQLCon, sDate, bBotCheck )
	local sChatPMQuery = [[INSERT INTO `datedcount`(`ondate`, `pmcount`, `botpmcount`)
		VALUES( '%s', 1, 1)
		ON DUPLICATE KEY
		UPDATE `pmcount` = `pmcount` + 1, `botpmcount` = `botpmcount` ]]
	if bBotCheck then
		sChatPMQuery = sChatPMQuery.."+ 1 "
	end
	local SQLCur = assert( SQLCon:execute(string.format( sChatPMQuery, SQLCon:escape(sDate) )) )
end

function FetchTopStats( Conn, iLimit )
	local sToReturn = string.format( "\t%03s\t%-32s\t%-7s\n\t", "S. No.", "UserName", "Score" )
	SQLQuery = assert( Conn:execute( string.format( [[SELECT username, totalcount FROM chatstat ORDER BY totalcount DESC LIMIT %d]], iLimit ) ) )
	DataArray = SQLQuery:fetch ({}, "a")
	i = 1
	while DataArray do
		sTemp = string.format( "%-3s\t%-25s\t%-7d", tostring(i), DataArray.username, DataArray.totalcount )
		sToReturn = sToReturn..sTemp.."\n\t"
		DataArray = SQLQuery:fetch ({}, "a")
		i = i + 1
	end
	return sToReturn
end

function FetchStats( SQLCon, ofWhom )
	local sToReturn, sQuery = "\t "..ofWhom.." has a total chat-count of %d\n\tThis month: %d\n\tThis week: %d", "SELECT `totalcount`, `thismonth`, `thisweek` FROM chatstat WHERE username='%s'"
	ofWhom = SQLCon:escape( ofWhom )
	Query = assert( SQLCon:execute(string.format(sQuery, ofWhom)) )
	tTemp = Query:fetch( {}, "a" )
	if tTemp and tTemp.totalcount then
		sToReturn = string.format(sToReturn, tonumber(tTemp.totalcount), tonumber(tTemp.thismonth), tonumber(tTemp.thisweek) )
	else return nil
	end
	return sToReturn
end
