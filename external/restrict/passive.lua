--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

function RestrictUser( sBotName, Error )
	local Error, sBotName, iBanTime = Error, sBotName, 60
	return function( tUser )
		local sMode = tUser.GetUserValue( 0 ) or "P"
		if sMode:lower() == "p" then
			BanMan.TempBan( tUser, iBanTime, Error("gen", 3), sBotName, true )
			Core.Disconnect( tUser )
		end
	end
end

return RestrictUser
