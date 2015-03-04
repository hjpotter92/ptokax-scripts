--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

function OnStartup()
	tConfig, tChatHistory, tTopics = {
		sBotName = SetMan.GetString( 21 ) or "PtokaX",
		sProfiles = "012",		-- No history for commands from users with profiles
		sLogsPath = "/www/ChatLogs/",
		sTimeFormat = "[%I:%M:%S %p] ",
		sPath = Core.GetPtokaXPath().."scripts/texts/",
		sTickersList = "tickers.txt",
		iMaxLines = 100,
		iTickerDelay = 6 * 60 * 60 * 10^3,		-- 6 hours to milliseconds
		iTickerID = false,
		iTopicIndex = 0,
	}, { "Hi!" }, {}
	for sLine in io.lines( tConfig.sPath..tConfig.sTickersList ) do
		local sNick, sTopic = sLine:match "^(%S+) (.+)$"
		table.insert( tTopics, {sNick = sNick, sTopic = sTopic} )
	end
end

function ChatArrival( tUser, sMessage )
	LogMessage( sMessage:sub(1, -2) )
	local sCmd, sData = sMessage:match "%b<> [-+*/?!#](%w+)%s?(.*)|"
	local sTime = os.date( tConfig.sTimeFormat )
	local sChatLine = sTime..sMessage:sub( 1, -2 )
	if not( sCmd and tConfig.sProfiles:find(tUser.iProfile) ) then
		table.insert( tChatHistory, sChatLine )
		if tChatHistory[ tConfig.iMaxLines + 1 ] then
			table.remove( tChatHistory, 1 )
		end
	end
	sCmd = sCmd:lower()
	if ExecuteCommand[sCmd] then
		return ExecuteCommand[sCmd]( tUser, sData, false )
	end
	return false
end

function ToArrival( tUser, sMessage )
	local sTo, sFrom = sMessage:match "$To: (%S+) From: (%S+)"
	if sTo ~= tConfig.sBotName then return false end
	local sCmd, sData = sMessage:match "%b$$%b<> [-+*/?!#](%w+)%s?(.*)|"
	sCmd = sCmd:lower()
	if ExecuteCommand[sCmd] then
		return ExecuteCommand[sCmd]( tUser, sData, true )
	end
	return false
end

function UserConnected( tUser )
	if tUser.iProfile == -1 then return end
	local sLastLines = "<"..tConfig.sBotName.."> Here is what was happening a few moments ago:\n\t"
	sLastLines = sLastLines..History( 15 )
	Core.SendToUser( tUser, sLastLines )
end

function OnTimer( iTimerID )
	if tConfig.iTickerID ~= iTimerID then
		return false
	end
	tConfig.iTopicIndex = ( tConfig.iTopicIndex + 1 ) % #tTopics
	local tCurrentTopic, sUpdated = tTopics[ tConfig.iTopicIndex ], ( "<%s> Hub topic was updated by [ %%s ] to %%s." ):format( tConfig.sBotName )
	SetMan.SetString( 10, tCurrentTopic.sTopic )
	Core.SendToAll( sUpdated:format(tCurrentTopic.sNick, tCurrentTopic.sTopic) )
	return true
end

RegConnected, OpConnected = UserConnected, UserConnected

function History( iNumLines )
	local iStartIndex = ( #tChatHistory - iNumLines ) + 1
	if #tChatHistory < iNumLines then
		iStartIndex = 1
	end
	if iStartIndex > #tChatHistory then
		iStartIndex = #tChatHistory
	end
	return table.concat( tChatHistory, "\n\t", iStartIndex, #tChatHistory )
end

function LogMessage( sLine )
	local sTime = os.date( tConfig.sTimeFormat )
	local sChatLine, sFileName = sTime..sLine, tConfig.sLogsPath..os.date( "%Y/%m/%d_%m_%Y" )..".txt"
	sChatLine = sChatLine:gsub( "&#(%d+);", function(x)
			return string.char( tonumber(x) )
		end ):gsub( "[\n\r]+", "\n\t" ):gsub( "&amp;", "&" )
	local fWrite = io.open( sFileName, "a" )
	fWrite:write( sChatLine.."\n" )
	fWrite:flush()
	fWrite:close()
end

function Reply( tUser, sMessage, bIsPM )
	if bIsPM then
		Core.SendPmToUser( tUser, tConfig.sBotName, sMessage )
	else
		Core.SendToUser( tUser, sMessage )
	end
	return true
end

ExecuteCommand = {
	history = ( function()
		local sPrefix = ( "<%s> \n\r\t\tChat history bot for HiT Hi FiT Hai\n\tShowing the mainchat history for past %%d messages\n\t" ):format( tConfig.sBotName )
		return function( tUser, sData, bIsPM )
			local iLimit = tonumber( sData )
			if (not iLimit) or iLimit > tConfig.iMaxLines or iLimit < 0 then iLimit = 15 end
			local sReply = sPrefix:format(iLimit)..History(iLimit)
			return Reply( tUser, sReply, bIsPM )
		end
	end )(),

	hubtopic = ( function()
		local sPrefix, sNoTopic = ( "<%s> Current hub topic is: %%s." ):format( tConfig.sBotName ), "Sorry! No hub topic exists."
		return function( tUser, sData, bIsPM )
			local sReply = sPrefix:format( SetMan.GetString(10) or sNoTopic )
			return Reply( tUser, sReply, bIsPM )
		end
	end )(),

	topic = ( function()
		local sErased, sUpdated = ( "<%s> Hub topic was erased by [ %%s ]." ):format( tConfig.sBotName ), ( "<%s> Hub topic was updated by [ %%s ] to %%s." ):format( tConfig.sBotName )
		return function( tUser, sData, bIsPM )
			if not ProfMan.GetProfilePermission( tUser.iProfile, 7 ) then return false end
			if sData:len() == 0 or sData:lower() == "off" then
				Core.SendToAll( sErased:format(tUser.sNick) )
				return ExecuteCommand.ticker( tUser, sData, bIsPM )
			end
			if tConfig.iTickerID then
				TmrMan.RemoveTimer( tConfig.iTickerID )
				tConfig.iTickerID = false
			end
			SetMan.SetString( 10, sData )
			Core.SendToAll( sUpdated:format(tUser.sNick, sData) )
			return true
		end
	end )(),

	ticker = ( function()
		local sReply = ( "<%s> Topics ticker has been activated." ):format( tConfig.sBotName )
		return function( tUser, sData, bIsPM )
			if not ProfMan.GetProfilePermission( tUser.iProfile, 7 ) then return false end
			if tConfig.iTickerID then return false end
			tConfig.iTickerID = TmrMan.AddTimer( tConfig.iTickerDelay )
			return Reply( tUser, sReply, bIsPM )
		end
	end )(),
}
