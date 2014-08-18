--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

local tSettings = {
	sAsBot = "<"..(SetMan.GetString( 21 ) or "PtokaX").."> Minimum sharesize required to search and download is %d GiB.",
	sAllowedProfiles = "01236",
	iBanTime = 6,
	iShareLimit = 64,		-- In gibibytes
	iExponent = 3,
	iConversionFactor = 2^10,
}

tSettings.iDivisionFactor = tSettings.iConversionFactor ^ tSettings.iExponent

function SearchArrival( tUser, sData )
	tUser.iShareSize = Core.GetUserValue( tUser, 16 ) / tSettings.iDivisionFactor
	if tUser.iShareSize < tSettings.iShareLimit and not tSettings.sAllowedProfiles:find( tUser.iProfile ) then
		Core.SendToUser( tUser, tSettings.sAsBot:format(tSettings.iShareLimit) )
		return true
	end
end

ConnectToMeArrival, MultiConnectToMeArrival, RevConnectToMeArrival = SearchArrival, SearchArrival, SearchArrival
