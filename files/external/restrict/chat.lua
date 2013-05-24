tSettings = {
	sAsBot = "<"..(SetMan.GetString( 21 ) or "PtokaX").."> ",
	sBotName = SetMan.GetString( 21 ) or "PtokaX",
}

function ChatArrival( tUser, sMessage )
	if tUser.iProfile == -1 then
		Core.SendToUser( tUser, tSettings.sAsBot..Error("gen", 2) )
		return true
	end
end
