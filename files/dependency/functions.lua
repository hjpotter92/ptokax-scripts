function Explode( sInput )
	local tReturn = {}
	for sWord in sInput:gmatch( "(%S+)" ) do
		table.insert( tReturn, sWord )
	end
	return tReturn
end
