--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

function OnStartup()
	tConfig, tList = {
		sBotName = SetMan.GetString( 21 ) or "PtokaX",
		sRequirePath = "external.restrict.",
		sHubAddress = SetMan.GetString( 2 ) or "localhost",
		sProtocol = "http://",
	}, {
		"chat",
		"share",
		"nicks",
		"search",
		"passive",
	}
	tConfig.sHubFAQ = tConfig.sProtocol..tConfig.sHubAddress.."/faq/%s/%04d"
	for iIndex, sScript in ipairs( tList ) do
		local r = require( tConfig.sRequirePath..sScript )
		tList[sScript] = r( tConfig.sBotName, Error )
		r = nil
	end
end

function Error( sCode, iNum )
	return tConfig.sHubFAQ:format( sCode:upper(), iNum )
end
