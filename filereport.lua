function OnStartup()
	local f = io.open( "/root/PtokaX/scripts/files/command.txt", "r+" )
	local txt = f:read( "*a" )
	Core.SendToAll( txt )
end
