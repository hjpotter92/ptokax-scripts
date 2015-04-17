--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

modifiers = function( user, data )
	if isthere( user.sNick, muted ) then
		if user.sNick ~= "IRC" then
			Core.SendToUser( user, "<PtokaX> You are muted.|" )
		end
		return false
	end
	 if isthere_key( user.sNick, unsubbed ) then
		Core.SendToUser( user, "<PtokaX> You have unsubscribed from mainchat. To subscribe again enter !sub|" )
		return false
	end
	local msg, nick = data:match "%b<>(.*)", user.sNick
	if isthere( user.sNick, nickc ) then
		nick = nickc[user.sNick]
	end
	if isthere( user.sNick:lower(), lunarized ) then
		msg = GarbleMessage( msg ):gsub( '&', '&amp;' ):gsub( '$', '&#36;' ):gsub( '|', '&#124;' )
	end
	if desu then
		msg = msg.." desu"
	end
	--allow only 1 at a time
	if san then
		nick = nick.."-san"
	end
	if chan then
		nick = nick.."-chan"
	end
	local finalmsg = "<"..nick..">"..msg
	if isthere( user.sNick, falone ) then
		Core.SendToUser( user, finalmsg )
		return false
	end
	return finalmsg
end

function GarbleMessage( sLine )
	for cIndex, sLeet in pairs( tGarble ) do
		sLine = sLine:gsub( cIndex, sLeet )
	end
	return sLine
end
