--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

local tSettings = {
	sAsBot = "<"..(SetMan.GetString( 21 ) or "PtokaX").."> ",
	sBotName = SetMan.GetString( 21 ) or "PtokaX",
}

function ChatArrival( tUser, sMessage )
	if tUser.iProfile == -1 then
		Core.SendToUser( tUser, tSettings.sAsBot..Error("gen", 2) )
		return true
	end
end
