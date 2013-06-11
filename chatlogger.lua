--[[
--
--	The chat logger stat bot, defined and designed by hjpotter92
--	for HiT Hi FiT Hai - Sharing for Friends hub.
--
--	Please don't share the codes on external websites/git without permissions
--
--]]

function OnStartup()
	dofile( Core.GetPtokaXPath().."scripts/chatStatSQL.lua" )
	tProfiles = {
		[-1] = 0,				-- Unregistered users
		[0] = 1,				-- Masters/Admins
		[1] = 1,				-- Gods/Final Years
		[2] = 1,				-- Ops
		[3] = 0,				-- VIPs
		[4] = 0,				-- Mods
		[5] = 0,				-- Registered Users
		[6] = 0,				-- sVIPs
		[7] = 0					-- Gymkhana users
	}
	tBotNames = {
		["PtokaX"] = true,
		["Infobot"] = true,
		["#[ModzChat]"] = true,
		["[BOT]Offliner"] = true,
		["#[VIPChat]"] = true,
		["OpChat"] = true,
		["[BOT]Info]"] = true,
		["#[Anime]"] = true
	}
	tConfig = {
		sBotName = SetMan.GetString( 21 ),
		iMaxLines = 100
	}
	tChatHistory = { "Hi" }
	tFunctions = {
		History = function( iNumLines )				-- iNumLines has been precalculated. Please check usage before changing.
			local iStartIndex = ( #tChatHistory - iNumLines ) + 1
			local sSendValue = ""
			if #tChatHistory < tonumber( iNumLines ) then
				iStartIndex = 1
			else
				iStartIndex = #tChatHistory - iNumLines + 1
			end
			if iStartIndex == 0 then
				iStartIndex = 1
			elseif iStartIndex > #tChatHistory then
				iStartIndex = #tChatHistory
			end
			sSendValue = table.concat( tChatHistory, "\n\t", iStartIndex, #tChatHistory )
			return sSendValue
		end,

		Top = function( tUser, iToppers )
			local sToppersList = "\n\r\t\tTop chatterers on HiT Hi FiT Hai\n\tDisplaying the list of top "..tostring( iToppers ).." chit-chatters.\n"
			local sTemp = ""
			sTemp = sTemp..FetchTopStats( SQLCon, iToppers )
			sToppersList = sToppersList..sTemp
			Core.SendPmToUser( tUser, tConfig.sBotName, sToppersList.."|" )
		end,

		Score = function( tUser, ofWhom )
			local sToppersList = "\n\r\t\tWelcome, "..tUser.sNick.." to HiT Hi FiT Hai\n\n"
			if FetchStats( SQLCon, ofWhom ) then
				local sTemp = FetchStats( SQLCon, ofWhom )
				sToppersList = sToppersList..sTemp.."\n"
			else
				sToppersList = sToppersList.."Sorry, the requested user has never used main-chat\n"
			end
			Core.SendPmToUser( tUser, tConfig.sBotName, sToppersList.."|" )
		end,

		Explode = function( sInput )
			local tReturn = {}
			string.gsub( sInput, "(%S+)", function( s ) table.insert( tReturn, s ) end )
			return tReturn
		end
	}
	SQLEnv, SQLCon = CreateConnection()
--~ 	InitialiseDB( SQLCon )
end

function ChatArrival( tUser, sMessage )
	sMessage = string.gsub( sMessage, "[\|]", "" )			--	Removing the terminating '|' character only.
	local _, iPunc = sMessage:find( "^%b<>%s%p" )
	local sTime = os.date( "%I:%M:%S %p" )
	local sChatLine = "["..sTime.."] "..sMessage
	if not( iPunc and tProfiles[tUser.iProfile] == 1 ) then
		table.insert( tChatHistory, sChatLine )
		if tChatHistory[tConfig.iMaxLines + 1] then
			table.remove( tChatHistory, 1 )
		end
	end
	local sDate = os.date( "%Y-%m-%d" )
	UpdateChatDate( SQLCon, sDate )
	UpdateUserStat( SQLCon, tUser.sNick )
	local _, _, sCmd = sMessage:find("%b<>%s+[%+%-%*%/%!%.%#%?](%w+)")
	sChatLine = sChatLine:gsub( "&#124;", "|" ):gsub( "&#36;", "$" ):gsub( "[\n\r]+", "\n\t" )
	local sFileName = "../../www/ChatLogs/"..os.date( "%Y/%m/%d_%m_%Y" )..".txt"
	local fWrite = io.open( sFileName, "a" )
	fWrite:write( sChatLine.."\n" )
	fWrite:flush()
	fWrite:close()
	local sSendValue = "\n\r\t\tChat history bot for HiT Hi FiT Hai\n\tShowing the mainchat history for past %d messages\n"
	if sCmd then
		if sCmd:lower() == "history" then
			local _, _, sData = sMessage:find( sCmd.."%s+(%d+)" )
			if( not sData ) or not tonumber(sData) or tonumber(sData) > 100 then sData = 15 end
			sSendValue = string.format( sSendValue, tonumber(sData) )..tFunctions.History( tonumber(sData) )
			Core.SendToUser( tUser, sSendValue.."|" )
			return true
		elseif sCmd:lower() == "top" then
			local _, _, sData = sMessage:find( sCmd.."%s+(%d+)" )
			if( not sData ) or not tonumber(sData) or tonumber(sData) > 100 then sData = 5 end
			tFunctions.Top( tUser, tonumber(sData) )
			return true
		elseif sCmd:lower() == "score" or sCmd:lower() == "see" then
			local _, _, sData = sMessage:find( sCmd.."%s+(%S+)" )
			if( not sData ) then sData = tUser.sNick end
			tFunctions.Score( tUser, sData )
			return true
		elseif sCmd:lower() == "hubtopic" then
			local sTopic = "<"..tConfig.sBotName.."> "..(SetMan.GetString( 10 ) or "Sorry! No hub topic exists.")
			Core.SendToUser( tUser, sTopic )
			sTopic = nil
			return true
		else
			return false
		end
	end
	return false
end

function ToArrival( tUser, sMessage )
	local _, _, to, from = sMessage:find("^$To: (%S+) From: (%S+)")
	local _, _, msg = sMessage:find("^%b\$\$%b<> [%+%-%*%/%!%.%#%?](.*)|")
	local sSendValue = "\n\r\t\tChat history bot for HiT Hi FiT Hai\n\tShowing the mainchat history for past %d messages\n"
	local tString = {}
	local sDate = os.date( "%Y-%m-%d" )
	UpdatePMDate( SQLCon, sDate, tBotNames[to] )
	if to == tConfig.sBotName and msg then
		tString = tFunctions.Explode( msg )
		if string.lower( tString[1] ) == "history" then
			if ( not tString[2] ) or tonumber( tString[2] ) > 100 then tString[2] = 15 end
			sSendValue = string.format( sSendValue, tonumber(tString[2]) )..tFunctions.History( tString[2] )
			Core.SendPmToUser( tUser, tConfig.sBotName, sSendValue.."|" )
		elseif string.lower( tString[1] ) == "top" then
			if ( not tString[2] ) or tonumber( tString[2] ) > 100 then tString[2] = 5 end
			tFunctions.Top( tUser, tonumber( tString[2] ) )
		elseif string.lower( tString[1] ) == "score" or string.lower( tString[1] ) == "see" then
			if ( not tString[2] ) then tString[2] = tUser.sNick end
			tFunctions.Score( tUser, tString[2] )
		elseif string.lower( tString[1] ) == "hubtopic" then
			local sTopic = SetMan.GetString( 10 ) or "Sorry! No hub topic exists."
			Core.SendPmToUser( tUser, tConfig.sBotName, sTopic )
			sTopic = nil
		end
	end
end

function UserConnected( tUser )
	if tUser.iProfile == -1 then return end
	local sLastLines = "<"..tConfig.sBotName..">\n\t\tHere is what was happening a few moments ago:\n"
	sLastLines = sLastLines..tFunctions.History( 15 )
	Core.SendToUser( tUser, sLastLines )
end

RegConnected, OpConnected = UserConnected, UserConnected

function OnExit()
	SQLCon:close()
	SQLEnv:close()
end
