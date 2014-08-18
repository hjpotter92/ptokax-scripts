--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

function OnStartup()
	tConfig, tList = {
		sPath = Core.GetPtokaXPath().."scripts/",
		sFiles = "external/restrict/",
		sHubAddress = SetMan.GetString( 2 ) or "localhost",
		sProtocol = "http://",
	}, {
		"chat.lua",
		"share.lua",
		"nicks.lua",
		"search.lua",
	}
	tConfig.sHubFAQ = tConfig.sProtocol..tConfig.sHubAddress.."/faq/%s/%04d"
	for iIndex, sScript in ipairs( tList ) do
		dofile( tConfig.sPath..tConfig.sFiles..sScript )
	end
end

function Error( sCode, iNum )
	return tConfig.sHubFAQ:format( sCode:upper(), iNum )
end
