--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

function OnStartup()
	tConfig = {
		tBot = {
			sName = "[BOT]Stats",
			sDescription = "Statistics collection and fetching tasks.",
			sEmail = "do-not@mail.me",
		},
		sPath = Core.GetPtokaXPath().."scripts/",
		sFuncFile = "functions.lua",
		sHelpFile = "statsHelp.txt",
		sHubBot = SetMan.GetString(21),
	}
	tPaths = {
		sTxtPath = tConfig.sPath.."texts/",
		sExtPath = tConfig.sPath.."external/",
		sDepPath = tConfig.sPath.."dependency/",
	}
	package.path = tPaths.sDepPath.."?.lua;"..package.path
	local Connection = require 'config'
	tToksConfig = {
		iMinShareLimit = 64,
		fInflationConstant=0.99,
		fRegUserAllowanceFactor=0.005,
		fModAllowance=200,
		fVipAllowance=500,
		fOpAllowance=800,
	}

	dofile( tPaths.sDepPath..tConfig.sFuncFile )
	dofile( tPaths.sExtPath.."stats/chat.lua" )
	dofile( tPaths.sExtPath.."stats/toks.lua" )
	dofile( tPaths.sExtPath.."stats/hubtopic.lua" )

	tUserStats, tBotStats = {}, {}
	tConfig.iTimerID1 = TmrMan.AddTimer( 90 * 10^3, "UpdateStats" )							-- Every 90 seconds
	tConfig.iTimerID2 = TmrMan.AddTimer( 5 * 60 * 10^3, "UpdateToks" )					-- Every 5 minutes
	tConfig.iTimerID3 = TmrMan.AddTimer( 24 * 60 * 60 * 10^3, "Inflation" )					-- Once every day
	tConfig.iTimerID4 = TmrMan.AddTimer( 24 * 60 * 60 * 10^3, "GrantAllowance" )		-- Once every day
	local fHelp = io.open( tPaths.sTxtPath..tConfig.sHelpFile, "r" )
	sHelp = fHelp:read( "*a" )
	fHelp:close()

	Core.RegBot( tConfig.tBot.sName, tConfig.tBot.sDescription, tConfig.tBot.sEmail, true )

	local luasql
	if not luasql then
		luasql = require "luasql.mysql"
	end
	if not sqlEnv then
		_G.sqlEnv = assert( luasql.mysql() )
		_G.sqlCon = assert( sqlEnv:connect(Connection 'stats') )
	end
end

function ChatArrival( tUser, sMessage )
	local bIsRegUser, sCmd, sData = (tUser.iProfile ~= -1), sMessage:match "%b<> [-+/#!?](%S+)%s*(.*)|$"
	if bIsRegUser then
		IncreaseChatCount( tUser )
	end
	if not sCmd then return false end
	if sCmd:lower() == 'topic' and ProfMan.GetProfilePermission( tUser.iProfile, 7 ) then
		if sData:len() == 0 then return false end
		NewHubTopic( tUser.sNick, sData )
	end
end

function ToArrival( tUser, sMessage )
	local sMessage = sMessage:gsub( "|", "" )
	local sTo = sMessage:match "$To: (%S+)"
	local bIsRegUser, bIsBot = (tUser.iProfile ~= -1), VerifyBots( sTo )
	if bIsRegUser then
		IncreasePMCount( tUser )
	end
	if bIsBot then
		IncreaseBotCount( sTo, bIsRegUser )
	end
	local sCmd, sData = sMessage:match "%b<> [-+/#!?](%S+)%s*(.*)"
	if not sCmd then return false end
	sCmd = sCmd:lower()
	if sCmd == 'topic' and ProfMan.GetProfilePermission( tUser.iProfile, 7 ) and sTo == tConfig.sHubBot then
		if sData:len() == 0 then return false end
		NewHubTopic( tUser.sNick, sData )
	end
	if sTo ~= tConfig.tBot.sName then return false end
	return ExecuteCommand( tUser, sCmd, sData )
end

function ExecuteCommand( tUser, sCmd, sMessage )
	local tTokens, sReply, bIsRegUser = Explode( sMessage ), false, (tUser.iProfile ~= -1)
	if sCmd == "h" or sCmd == "help" then
		sReply = sHelp

	elseif sCmd == "see" or sCmd == "score" then
		local sNick = tTokens[1] or tUser.sNick
		if not bIsRegUser then
			sReply = "Available only for registered users."
		else
			sReply = NickStats(sNick)
		end

	elseif sCmd == "top" then
		local iLimit=tonumber( tTokens[1] )
		if not iLimit then
			iLimit, tTokens[2] = 0, tTokens[1]
		end
		if iLimit < 3 or iLimit > 100 then iLimit = 10 end
		sReply = DailyTop( iLimit, tTokens[2] )

	elseif sCmd == "topall" then
		local iLimit=tonumber(tTokens[1])
		if not iLimit or iLimit < 3 or iLimit > 100 then iLimit = 10 end
		sReply = AllTimeTop(iLimit)

	elseif sCmd == "toks" then
		local sNick = tTokens[1] or tUser.sNick
		if not bIsRegUser then
			sReply = "Available only for registered nicks."
		else
			sReply = NickToks( tUser, sNick )
		end

	elseif sCmd == "rich" then
		local iLimit = tonumber( tTokens[1] )
		if not iLimit then iLimit = 15 end
		if iLimit > 100 then iLimit = 100 end
		sReply = CurrentTopToks( iLimit )

	elseif sCmd == "richest" then
		local iLimit = tonumber( tTokens[1] )
		if not iLimit then iLimit =15 end
		if iLimit > 100 then iLimit = 100 end
		sReply = AllTimeTopToks( iLimit )

	elseif sCmd == "gift" then
		local sToNick, fAmount = tTokens[1], tonumber(tTokens[2]) or 0
		if sToNick and fAmount then
			sReply = gift( tUser.sNick, sToNick, fAmount, sData )
		else
			sReply = "Incomplete parameters"
		end

	elseif sCmd == "transactions" then
		local sNick = tTokens[1] or tUser.sNick
		sReply = Transactions( tUser, sNick )

	elseif sCmd == "poll" then
		if tTokens[1] == "add" then
			sReply = AddPoll( tUser, table.concat(tTokens, 2) )
		elseif tTokens[1] == "remove" then
			sReply = DeletePoll( tUser, tTokens[2] )
		end
	end
	if sReply then
		Reply( tUser, sReply )
		return true
	end
	return false
end

function Reply( tUser, sMessage )
	Core.SendPmToUser( tUser, tConfig.tBot.sName, sMessage )
end

function OnExit()
	Core.UnregBot( tConfig.tBot.sName )
	TmrMan.RemoveTimer( tConfig.iTimerID1 )
	TmrMan.RemoveTimer( tConfig.iTimerID2 )
	TmrMan.RemoveTimer( tConfig.iTimerID3 )
	TmrMan.RemoveTimer( tConfig.iTimerID4 )
	sqlCon:close()
	sqlEnv:close()
end
