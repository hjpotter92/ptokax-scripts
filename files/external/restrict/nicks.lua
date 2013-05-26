local tSettings = {
	sAsBot = "<"..(SetMan.GetString( 21 ) or "PtokaX").."> ",
	sBotName = SetMan.GetString( 21 ) or "PtokaX",
	iBanTime = 6,
}

function UserConnected( tUser )
	if tUser.sNick:find( "^[^%w_%.]" ) then
		Core.SendToUser( tUser, tSettings.sAsBot..Error("gen", 50) )
		BanMan.TempBan( tUser, tSettings.iBanTime, Error("gen", 50), tSettings.sBotName, true )
		Core.Disconnect( tUser )
	end
	if tUser.sNick:find( "\160" ) then
		Core.SendToUser( tUser, tSettings.sAsBot.."Certain characters are not allowed in nicks." )
		Core.Disconnect( tUser )
	end
end

RegConnected, OpConnected = UserConnected, UserConnected
