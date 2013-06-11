function OnStartup()
	local f = io.open( Core.GetPtokaXPath().."scripts/files/command.txt", "r+" )
	local txt = f:read( "*a" )
	Core.SendToAll( txt )
end
