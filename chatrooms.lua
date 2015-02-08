--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

function OnStartup()
	tConfig = {
		iMaxHistory = 35,
		sGlobalPath = "/www/ChatLogs/",
		iTotalProfiles = table.getn( ProfMan.GetProfiles() ),
		iTimerID = 0,					-- This will store the ID of timer set by PtokaX
		iRefreshRate = 20 * 1000,			-- Time in ms when the MyINFO will be refreshed. Right now, 20 seconds.
		sTimeFormat = "[%Y-%m-%d %H:%M:%S] ",
	}
	tChatRooms = {
		["#[ModzChat]"] = {
			iMaxProfile = 4,			-- The maximum profile number allowed to access this chatroom.
			BOT = {
				sDescription = "Chatroom for moderators.",
				sEmail = "donot@mail.me"
			},
			sFileName = "ModsChat.txt",
			tChatHistory = {},
		},
		["#[VIPChat]"] = {
			iMaxProfile = 3,
			BOT = {
				sDescription = "Chatroom for usage by VIPs.",
				sEmail = "donot@mail.me"
			},
			sFileName = "VIPChat.txt",
			tChatHistory = {},
		}
	}
	for sIndex, sValue in pairs(tChatRooms) do
		Core.RegBot( sIndex, sValue.BOT.sDescription, sValue.BOT.sEmail, true )
	end
	if tConfig.iTimerID == 0 then
		tConfig.iTimerID = TmrMan.AddTimer( tConfig.iRefreshRate )
	end
	Hide()
end

function SaveToFile( sChatMessage, sRoom )
	local sStoreMessage = os.date( tConfig.sTimeFormat )..sChatMessage
	local fWrite = io.open( tConfig.sGlobalPath..os.date( "%Y/%m/" )..tChatRooms[sRoom].sFileName, "a" )
	fWrite:write( sStoreMessage.."\n" )
	fWrite:flush()
	fWrite:close()
	return true
end

function SendToRoom( tSelfUser, sRoom, sIncoming )
	local tCurrentHistory = tChatRooms[sRoom].tChatHistory
	table.insert( tCurrentHistory, os.date( tConfig.sTimeFormat )..sIncoming )
	if tCurrentHistory[ tConfig.iMaxHistory + 1 ] do
		table.remove( tCurrentHistory, 1 )
	end
	for iIterate = 0, tChatRooms[sRoom].iMaxProfile do
		local tUsers = Core.GetOnlineUsers( iIterate )
		if tUsers then
			for iIndex, tRecipient in ipairs( tUsers ) do
				if tRecipient.sNick:lower() ~= tSelfUser.sNick:lower() then
					Core.SendToUser( tRecipient, "$To: "..tRecipient.sNick.." From: "..sRoom.." $"..sIncoming.."|" )
				end
			end
		end
	end
	return true
end

function UserConnected( tUser )
	Hide( tUser )
end
RegConnected = UserConnected

function OnTimer( iID )
	Hide()
end

function Hide()
	for sIndex, tValue in pairs( tChatRooms ) do
		local sQuitINFO = "$Quit "..sIndex.."|"
		Core.SendToProfile( -1, sQuitINFO )
		for iIterate = (tValue.iMaxProfile + 1), (tConfig.iTotalProfiles - 1) do
			Core.SendToProfile( iIterate, sQuitINFO )
		end
	end
end

function ToArrival( tUser, sMessage )
	local sTo = sMessage:match "%$To: (%S+)"
	if not tChatRooms[sTo] or tUser.iProfile == -1 then
		return false
	end
	if tUser.iProfile > tChatRooms[sTo].iMaxProfile then
		Core.SendPmToUser( tUser, sTo, "Sorry! You don't have access to the chatroom.|" )
		return true
	else
		local sChat = sMessage:match "%b$$(.*)|" 
		SaveToFile(sChat, sTo)
		local sCmd, sData = sMessage:match "%b$$%b<>%s+[-+*/?!#](%w+)%s?(.*)|" 
		if not sCmd then
			SendToRoom( tUser, sTo, sChat )
		elseif sCmd:lower() == "history" then
			local sReply, sData = "Past %d messages: \n\n\t%s\n\n", tonumber( sData )
			if (not sData) or sData > 35 or sData < 0 then sData = 15 end
			sReply = sReply:format( sData, History( sData, sTo ) )
			Core.SendPmToUser( tUser, sTo, sReply)
		else
			SendToRoom( tUser, sTo, sChat)
		end
		return true
	end
end

function History( iNumLines, sBotName )
	local tChatHistory = tChatRooms[sBotName].tChatHistory
	local iStartIndex = ( #tChatHistory - iNumLines ) + 1
	if #tChatHistory < iNumLines then
		iStartIndex = 1
	end
	if iStartIndex > #tChatHistory then
		iStartIndex = #tChatHistory
	end
	return table.concat( tChatHistory, "\n\t", iStartIndex, #tChatHistory )
end

function OnExit()
	for sIndex, sValue in pairs(tChatRooms) do
		Core.UnregBot( sIndex )
	end
end
