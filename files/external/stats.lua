local tCfg, tDatabase = {
	s
}, {
	sUser = "stat",
	sPassword = "stats@hhfh",
	sHost = "localhost",
	sPort = 3306,
	sDB = "stats",
}

if not luasql then
	luasql = require "luasql.mysql"
end

sqlEnv = assert( luasql.mysql() )
sqlCon = assert( sqlEnv:connect(tDatabase.sDB, tDatabase.sUser, tDatabase.sPassword, tDatabase.sHost, tDatabase.sPort) )

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
