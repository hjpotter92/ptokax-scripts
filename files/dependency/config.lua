local tDatabase = {
	index = {
		'dbName',
		'username',
		'password',
		'hostname',
	},
}

local function Handle( sName )
	return unpack( tDatabase[sName] )
end

return Handle
