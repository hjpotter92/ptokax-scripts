--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

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
