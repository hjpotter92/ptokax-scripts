function OnStartup()
	tConfig, tList = {
		sPath = "/root/PtokaX/scripts/",
		sFiles = "files/external/restrict/",
		sHubAddress = SetMan.GetString( 2 ) or "localhost",
		sProtocol = "http://",
	}, {
		"chat.lua",
		"share.lua",
		"nicks.lua",
		"search.lua",
	}
	tConfig.sHubFAQ = tConfig.sProtocol..tConfig.sHubAddress.."/faq.php?code=%s&num=%04d"
	for iIndex, sScript in ipairs( tList ) do
		dofile( tConfig.sPath..tConfig.sFiles..sScript )
	end
end

function Error( sCode, iNum )
	return tConfig.sHubFAQ:format( sCode:upper(), iNum )
end
