local tDatabase = {
	index = {
		'dbName',
		'username',
		'password',
	},
}

local function Handle( sName )
	return unpack( tDatabase[sName] )
end

return Handle
