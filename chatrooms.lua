--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

function OnStartup()
	tConfig = {
		sGlobalPath = "/www/ChatLogs/",
		iTotalProfiles = table.getn( ProfMan.GetProfiles() ),
		iTimerID = 0,					-- This will store the ID of timer set by PtokaX
		iRefreshRate = 20 * 1000			-- Time in ms when the MyINFO will be refreshed. Right now, 20 seconds.
	}
	tChatRooms = {
		["#[ModzChat]"] = {
			iMaxProfile = 4,			-- The maximum profile number allowed to access this chatroom.
			BOT = {
				sDescription = "Chatroom for moderators.",
				sEmail = "donot@mail.me"
			},
			sFileName = "ModsChat.txt"
		},
		["#[VIPChat]"] = {
			iMaxProfile = 3,
			BOT = {
				sDescription = "Chatroom for usage by VIPs.",
				sEmail = "donot@mail.me"
			},
			sFileName = "VIPChat.txt"
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
	local sStoreMessage = os.date("[%Y-%m-%d %H:%M:%S]").." "..sChatMessage
	local fWrite = io.open( tConfig.sGlobalPath..os.date( "%Y/%m/" )..tChatRooms[sRoom].sFileName, "a" )
	fWrite:write( sStoreMessage.."\n" )
	fWrite:flush()
	fWrite:close()
	return true
end

function SendToRoom( tSelfUser, sRoom, sIncoming )
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
	SaveToFile( sIncoming, sRoom )
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
	local _, _, sTo = sMessage:find( "%$To: (%S+)" )
	if not tChatRooms[sTo] or tUser.iProfile == -1 then
		return false
	end
	if tUser.iProfile > tChatRooms[sTo].iMaxProfile then
		Core.SendPmToUser( tUser, sTo, "Sorry! You don't have access to the chatroom.|" )
		return true
	else
		local _, _, sChat = sMessage:find( "%b$$(.*)|" )
		SendToRoom( tUser, sTo, sChat )
		return true
	end
end

function OnExit()
	for sIndex, sValue in pairs(tChatRooms) do
		Core.UnregBot( sIndex )
	end
end
