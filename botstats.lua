--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

function OnStartup()
	package.path = Core.GetPtokaXPath().."scripts/files/dependency/?.lua;"..package.path
	local Connection = require 'config'
	dofile( Core.GetPtokaXPath().."scripts/files/chatstats.lua" )
	dofile( Core.GetPtokaXPath().."scripts/files/toks.lua" )
	tConfig = {
		tBot = {
			sName = "[BOT]Stats",
			sDescription = "Statistics collection and fetching tasks.",
			sEmail = "do-not@mail.me",
		},
		sPath = Core.GetPtokaXPath().."scripts/files/",
		sExtPath = "external/",
		sFunctionsFile = "tmp/chatstats.lua",
		sDepPath = "dependency/",
		sFuncFile = "functions.lua",
		sTxtPath = "texts/",
		sHelpFile = "statsHelp.txt",
	}
	tToksConfig = {
		iMinShareLimit = 64,
		fInflationConstant=0.99,
		fRegUserAllowanceFactor=0.005,
		fModAllowance=200,
		fVipAllowance=500,
		fOpAllowance=800,
	}
	tUserStats, tBotStats={}, {}
	tConfig.iTimerID1=TmrMan.AddTimer( 90 * 10^3, "UpdateStats" )
	tConfig.iTimerID2=TmrMan.AddTimer( 5 *60*10^3, "UpdateToks" )
	tConfig.iTimerID3=TmrMan.AddTimer( 24*60*60* 10^3, "Inflation" )
	tConfig.iTimerID4=TmrMan.AddTimer( 24*60*60* 10^3, "GrantAllowance" )

	local fHelp = io.open( tConfig.sPath..tConfig.sTxtPath..tConfig.sHelpFile, "r" )
	sHelp = fHelp:read( "*a" )
	fHelp:close()

	Core.RegBot( tConfig.tBot.sName, tConfig.tBot.sDescription, tConfig.tBot.sEmail, true )

	dofile( tConfig.sPath..tConfig.sDepPath..tConfig.sFuncFile )

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
	local bIsRegUser = (tUser.iProfile ~= -1)
	if bIsRegUser then
		IncreaseChatCount( tUser )
	end
end

function ToArrival( tUser, sMessage )
	local sMessage = string.gsub(sMessage,"|","")

	local sTo = sMessage:match( "$To: (%S+)" )
	local bIsRegUser = (tUser.iProfile ~= -1)
	local bIsBot = VerifyBots( sTo )
	if bIsRegUser then
		IncreasePMCount( tUser )
	end
	if bIsBot then
		IncreaseBotCount(sTo,bIsRegUser)
	end
	if sTo ~= tConfig.tBot.sName then return false end
	local sFchar = sMessage:match( "%b$$%b<> ([-+*/?#!]).*" )
	if not sFchar then return false end
	return ExecuteCommand( tUser, sMessage, true )
end

function OnExit()
	Core.UnregBot( tConfig.tBot.sName )
	TmrMan.RemoveTimer( tConfig.iTimerID1 )
	TmrMan.RemoveTimer( tConfig.iTimerID2 )
	TmrMan.RemoveTimer( tConfig.iTimerID4 )
	sqlCon:close()
	sqlEnv:close()
end

function ExecuteCommand( tUser,sMessage, bIsPm )
	tTokens = Explode( sMessage )
	local sCmd = tTokens[6]:lower():match(".(.*)")
	if sCmd == "h" or sCmd == "help" and bIsPm then
		Reply( tUser, sHelp, bIsPm )
		return true
	elseif sCmd == "see" or sCmd == "score" then
		local sNick = tTokens[7] or tUser.sNick
		if not RegMan.GetReg( sNick ) then
			Reply( tUser, "Available only for registered users.", bIsPm )
			return true
		end
		Reply( tUser, NickStats( sNick), bIsPm )
	elseif sCmd == "top" then
		local iLimit=tonumber(tTokens[7])
		if not iLimit then
			iLimit = 0
			tTokens[8] = tTokens[7]
		end
		if iLimit < 3 or iLimit > 100 then iLimit = 10 end
		Reply( tUser, DailyTop(iLimit, tTokens[8]), bIsPm )
		return true
	elseif sCmd == "topall" then
		local iLimit=tonumber(tTokens[7])
		if not iLimit or iLimit < 3 or iLimit > 100 then iLimit = 10 end
		Reply( tUser, AllTimeTop(iLimit), bIsPm )
		return true
	elseif sCmd == "toks" then
		local sNick = tTokens[7] or tUser.sNick
		if not RegMan.GetReg( sNick ) then
			Reply( tUser, "Available only for registered nicks.", bIsPm )
			return true
		end
		local sReply = NickToks( tUser,sNick)
		Reply( tUser, sReply, bIsPm )
		return true
	elseif sCmd == "rich" then
		local iLimit=tonumber(tTokens[7])
		if not iLimit then iLimit =15 end
		if iLimit > 100 then iLimit = 100 end
		Reply( tUser, CurrentTopToks(iLimit), bIsPm )
		return true
	elseif sCmd == "richest" then
		local iLimit=tonumber(tTokens[7])
		if not iLimit then iLimit =15 end
		if iLimit > 100 then iLimit = 100 end
		Reply( tUser, AllTimeTopToks(iLimit), bIsPm )
		return true
	elseif sCmd == "gift" then
		local sToNick=tTokens[7]
		local fAmount =tonumber(tTokens[8]) or 0
		local sMessage = table.concat(tTokens," ",9)
		if sToNick and fAmount then
			Reply( tUser, gift(tUser.sNick,sToNick,fAmount,sMessage), bIsPm )
		else
			Reply( tUser, "Incomplete parameters", bIsPm )
		end
		return true
	elseif sCmd == "transactions" then
		local sNick = tTokens[7] or tUser.sNick
		Reply( tUser, Transactions(tUser,sNick), bIsPm )
		return true
	end
end

function Reply( tUser, sMessage, bIsPm )
	if bIsPm then
		Core.SendPmToUser( tUser, tConfig.tBot.sName, sMessage )
	else
		Core.SendToUser( tUser, "<"..tConfig.tBot.sName.."> "..sMessage )
	end
end
