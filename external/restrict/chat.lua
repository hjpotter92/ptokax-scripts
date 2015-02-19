--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

function RestrictChat( sBotName, Error )
	local Error, sAsBot = Error, "<"..SetMan.GetString( 21 ).."> "
	return function( tUser, sMessage )
		if tUser.iProfile == -1 then
			Core.SendToUser( tUser, sAsBot..Error("gen", 2) )
			return true
		end
	end
end

return RestrictChat
