local tSettings = {
	sAllowedProfiles = "0123",
	tBannedWords = {
		"pondy",
		"porn",
		"xxx",
		"rape",
		"sanhita",
	},
	tBannedTTH = {
		"RYLUZGTHGGUS6CE465VUTHT7TKWFJFZ55M6KPKY",
	},
}

local function IsBanned( sData )
	for iIndex, sWord in ipairs( tSettings.tBannedWords ) do
		if sData:find( "%?"..sWord ) then
			return iIndex
		end
	end
	for iIndex, sHash in ipairs( tSettings.tBannedTTH ) do
		if sData:find( "TTH:"..sHash ) then
			return iIndex
		end
	end
	return false
end

function SearchArrival( tUser, sQuery )
	if tSettings.sAllowedProfiles:find( tUser.iProfile ) then
		return false
	end
	if IsBanned( sQuery ) then
		return true
	end
end
