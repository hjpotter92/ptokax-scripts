--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

local tSettings = {
	sBotName = SetMan.GetString( 21 ) or "PtokaX",
	iBanTime = 60,
}

function UserConnected( tUser )
	local sMode = tUser.GetUserValue( 0 ) or "P"
	if sMode:lower() == "p" then
		BanMan.TempBan( tUser, tSettings.iBanTime, Error("gen", 3), tSettings.sBotName, true )
		Core.Disconnect( tUser )
	end
end

RegConnected = UserConnected
