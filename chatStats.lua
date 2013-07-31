function OnStartup()
	tConfig, tUserStats, tBotStats = {
		tBot = {
			sName = "[BOT]Stats",
			sDescription = "Statistics collection and fetching tasks.",
			sEmail = "do-not@mail.me",
		},
		sPath = Core.GetPtokaXPath().."scripts/files/",
		sExtPath = "external/",
		sFunctionsFile = "stats.lua",
		sDepPath = "dependency/",
		sFuncFile = "functions.lua",
		sTxtPath = "texts/",
		sHelpFile = "statsHelp.txt",
		iTimerID = TmrMan.AddTimer( 90 * 10^3, "UpdateStats" ),
	}, {}, {}
	local fHelp = io.open( tConfig.sPath..tConfig.sTxtPath..tConfig.sHelpFile, "r" )
	sHelp = fHelp:read( "*a" )
	fHelp:close()
	Core.RegBot( tConfig.tBot.sName, tConfig.tBot.sDescription, tConfig.tBot.sEmail, true )
	dofile( tConfig.sPath..tConfig.sDepPath..tConfig.sFuncFile )
	dofile( tConfig.sPath..tConfig.sExtPath..tConfig.sFunctionsFile )
end

function ChatArrival( tUser, sMessage )
	if tUser.iProfile == -1 then return false end
	local sDate, sCmd, sData = os.date( "%Y-%m-%d" ), sMessage:match( "%b<> [-+*/?#!](%w+)%s?(.*)|" )
	if type( tUserStats[sDate] ) ~= "table" then
		tUserStats[sDate] = {}
	end
	if not tUserStats[sDate][tUser.sNick] then tUserStats[sDate][tUser.sNick] = { main = 0, msg = 0 } end
	tUserStats[sDate][tUser.sNick].main = ( tUserStats[sDate][tUser.sNick].main or 0 ) + 1
	if not sCmd then return false end
	return ExecuteCommand( tUser, sCmd, sData, false )
end

function ToArrival( tUser, sMessage )
	local sTo, sDate, bRegUserFlag = sMessage:match( "$To: (%S+)" ), os.date( "%Y-%m-%d" ), tUser.iProfile ~= -1
	local iFlag = VerifyBots( sTo )
	if iFlag == 0 and not bRegUserFlag then return false end
	if bRegUserFlag then
		if type( tUserStats[sDate] ) ~= "table" then
			tUserStats[sDate] = {}
		end
		if not tUserStats[sDate][tUser.sNick] then tUserStats[sDate][tUser.sNick] = { msg = 0, main = 0 } end
		tUserStats[sDate][tUser.sNick].msg = ( tUserStats[sDate][tUser.sNick].msg or 0 ) + 1
	end
	if iFlag == 0 then return false end
	if type( tBotStats[sDate] ) ~= "table" then
		tBotStats[sDate] = {}
	end
	if not tBotStats[sDate][sTo] then tBotStats[sDate][sTo] = { regs = 0, unregs = 0 } end
	if bRegUserFlag then
		tBotStats[sDate][sTo].regs = (tBotStats[sDate][sTo].regs or 0) + 1
	else
		tBotStats[sDate][sTo].unregs = (tBotStats[sDate][sTo].unregs or 0) + 1
	end
	if sTo ~= tConfig.tBot.sName then return false end
	local sCmd, sData = sMessage:match( "%b$$%b<> [-+*/?#!](%w+)%s?(.*)|" )
	if not sCmd then return false end
	return ExecuteCommand( tUser, sCmd, sData, true )
end

function OnExit()
	Core.UnregBot( tConfig.tBot.sName )
	TmrMan.RemoveTimer( tConfig.iTimerID )
	sqlCur:close()
	sqlEnv:close()
end

function VerifyBots( sInput )
	if sInput:find( "^%[BOT%]" ) then
		return 1
	elseif sInput:find( "^#%[" ) then
		return 2
	elseif sInput:find( "OpChat" ) then
		return 2
	elseif sInput == SetMan.GetString( 21 ) then
		return 1
	else
		return 0
	end
end

function UpdateStats()
	for sDate, tTemporary in pairs( tUserStats ) do
		for sNick, tTemp in pairs( tTemporary ) do
			UserScore( sNick, sDate, tTemp.main, tTemp.msg )
		end
	end
	for sDate, tTemporary in pairs( tBotStats ) do
		for sName, tTemp in pairs( tTemporary ) do
			BotStats( sName, sDate, tTemp.regs, tTemp.unregs )
		end
	end
	tUserStats, tBotStats = {}, {}
end

function ExecuteCommand( tUser, sCmd, sMessage, bIsPm )
	local sCmd, iLimit = sCmd:lower(), tonumber( sData )
	if sCmd == "h" or sCmd == "help" and bIsPm then
		Reply( tUser, sHelp, bIsPm )
	elseif sCmd == "stath" or sCmd == "stathelp" and not bIsPm then
		Reply( tUser, sHelp, bIsPm )
	elseif sCmd == "see" or sCmd == "score" then
		if sMessage:len() == 0 then sMessage = tUser.sNick end
		if not RegMan.GetReg( sMessage ) then
			Reply( tUser, "Available only for registered users.", bIsPm )
		end
		local sReply, sError = tTop.User( sMessage )
		if sError then
			Reply( tUser, sError, bIsPm )
		end
		Reply( tUser, sReply, bIsPm )
	elseif sCmd == "top" then
		local tBreak = Explode( sMessage )
		if tBreak[2] then
			Reply( tUser, tTop.Daily(tBreak[1], tBreak[2]), bIsPm )
		else
			if not iLimit or iLimit < 3 or iLimit > 100 then iLimit = 10 end
			Reply( tUser, tTop.Daily(iLimit), bIsPm )
		end
	elseif sCmd == "topall" then
		if not iLimit or iLimit < 3 or iLimit > 100 then iLimit = 10 end
		Reply( tUser, tTop.Total(iLimit), bIsPm )
	end
end

function Reply( tUser, sMessage, bIsPm )
	if bIsPm then
		Core.SendPmToUser( tUser, tConfig.tBot.sName, sMessage )
	else
		Core.SendToUser( tUser, "<"..tConfig.tBot.sName.."> "..sMessage )
	end
end
