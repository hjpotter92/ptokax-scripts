local tDatabase, tTop = {
	sUser = "stat",
	sPassword = "stats@hhfh",
	sHost = "localhost",
	sPort = 3306,
	sDB = "stats",
}, {
	sHeader = ( "\t%05s\t%-32s\t%-7s\n\t" ):format( "S.No.", "UserName", "Score" ),
	sTemplate = "%-3d.\t%-25s\t%-7d",
}

if not luasql then
	luasql = require "luasql.mysql"
end

sqlEnv = assert( luasql.mysql() )
sqlCon = assert( sqlEnv:connect(tDatabase.sDB, tDatabase.sUser, tDatabase.sPassword, tDatabase.sHost, tDatabase.sPort) )

local function List( sqlCur )
	local tRow, tTemp, iCounter = {},{}, 1
	tRow = sqlCur:fetch( tRow, "a" )
	while tRow do
		table.insert( tTemp, tTop.sTemplate:format(iCounter, tRow.nick, tRow.total) )
		tRow, iCounter = sqlCur:fetch( tRow, "a" ), iCounter + 1
	end
	sqlCur = nil
	return tTemp
end

function UserScore( sNick, sDate, iMain, iPM )
	local sQuery = [[INSERT INTO `scores` (`nick`, `count`, `messages`, `dated`)
	VALUES ('%s', %d, %d, '%s')
	ON DUPLICATE KEY
		UPDATE `count` = `count` + %d,
			`messages` = `messages` + %d]]
	sQuery = sQuery:format( sqlCon:escape(sNick), iMain, iPM, sDate, iMain, iPM )
	local sqlCur = assert( sqlCon:execute(sQuery) )
	sqlCur = nil
end

function BotStats( sBotName, sDate, iRegs, iUnregs )
	local sQuery = [[INSERT INTO `botStats` (`name`, `regs`, `unregs`, `dated`)
	VALUES ('%s', %d, %d, '%s')
	ON DUPLICATE KEY
		UPDATE `regs` = `regs` + %d,
			`unregs` = `unregs` + %d]]
	sQuery = sQuery:format( sqlCon:escape(sBotName), iRegs, iUnregs, sDate, iRegs, iUnregs )
	local sqlCur = assert( sqlCon:execute(sQuery) )
	sqlCur = nil
end

function tTop.Total( iLimit )
	local sQuery, tTemp, iCounter = [[SELECT `nick`,
		SUM(`count`) AS `total`
	FROM `scores`
	GROUP BY `nick`
	ORDER BY `total` DESC
	LIMIT %d]], {}, 1
	local sqlCur, sResult = assert( sqlCon:execute(sQuery:format(iLimit)) ), ( "\n\n\t\tShowing %d of all time top chatterers\n\n" ):format( iLimit )
	tTemp = List( sqlCur )
	return sResult..tTop.sHeader..table.concat( tTemp, "\n\t" )
end

function tTop.Daily( iLimit, sDate )
	local sResult, tTemp = "\n\n\t\tShowing %d of %s\n\n", {}
	sResult = sResult:format( iLimit, sDate or "today" )
	local sQuery, sDate = [[SELECT `nick`,
		`count` AS `total`
	FROM `scores`
	WHERE `dated` = %s
	ORDER BY `total` DESC
	LIMIT %d]], ( sDate and "'"..sqlCon:escape(sDate).."'" ) or "CURDATE()"
	local sqlCur = assert( sqlCon:execute(sQuery:format(sDate, iLimit)) )
	tTemp = List( sqlCur )
	return sResult..tTop.sHeader..table.concat( tTemp, "\n\t" )
end

function tTop.User( sNick )
	local sQuery, tRow, sResult = [[SELECT s.`nick` AS `nick`,
		s.`count` AS `recent`,
		t.`total` AS `total`,
		t.`avrg` AS `avrg`,
		t.`pm` AS `pm`,
		t.`max` AS `highest`,
		ss.`dated` AS `dated`,
		t.`dated` AS `rcntdate`
	FROM (
		SELECT `nick`,
			SUM(`count`) AS `total`,
			AVG(`count`) AS `avrg`,
			SUM(`messages`) AS `pm`,
			MAX(`count`) AS `max`,
			MAX(`dated`) AS `dated`
		FROM `scores`
		WHERE `nick` = '%s'
	) AS `t`
	INNER JOIN `scores` s
		ON s.`nick` = t.`nick`
			AND s.`dated` = t.`dated`
	INNER JOIN scores ss
		ON ss.`nick` = t.`nick`
			AND t.`max` = ss.`count`
	LIMIT 1]], {}, [[

	HiT Hi FiT Hai: Mainchat stats for %s
	-------------------------------------

	User: %s
	Total count: %d
	Average count: %d
	PMs sent: %d
	Most recent score of %d on %s
	Highest activity on %s (with score of %d)
	-------------------------------------\n\n]]
	local sqlCur = assert( sqlCon:execute(sQuery:format( sqlCon:escape(sNick) )) )
	tRow = sqlCur:fetch( tRow, "a" )
	if not tRow then
		return false, "No record was obtained. Please participate more on the hub."
	end
	return sResult:format( tRow.nick, tRow.nick, tRow.total, tRow.avrg, tRow.pm, tRow.recent, tRow.rcntdate, tRow.dated, tRow.highest )
end
