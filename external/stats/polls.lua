--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

AddPoll = ( function()
	local tErrors, tQuery = {
		sNoTitle = "A poll should have a valid title.",
		sFewChoices = "A poll should have at least 2 valid options. At most 10 choices are allowed.",
	}, {
		sQuestion = [[INSERT INTO questions (question, nick, dated) VALUES ( '%s', '%s', NOW() )]],
		sChoice = [[INSERT INTO options (option_id, poll_id, option) VALUES ( %d, %d, '%s' )]],
	}
	local function Insert( tInput, sInput, iBegin, iEnd )
		if not iEnd then iEnd = #sInput end
		if iBegin >= iEnd then return end
		local sChoice = sqlCon:escape( sInput:sub(iBegin, iEnd) )
		table.insert( tInput, sChoice )
	end
	local function FindChoices( sInput )
		local tChoices = {}
		local iStart, iEnd, iTemp = sInput:find "%[%]"
		while iEnd do
			iStart, iTemp = sData:find( "%[%]", iEnd )
			if not iStart then break end
			Insert( tChoices, sData, iEnd + 1, iStart - 1 )
			iEnd = iTemp
		end
		Insert( tChoices, sData, iEnd + 1 )
		return tChoices
	end
	return function ( tUser, sData )
		local sNick = sqlCon:escape( tUser.sNick )
		local sTitle, sData = sData:match "^(.-)(%[%].*)"
		if not ( sTitle and sData ) then
			return tErrors.sNoTitle
		end
		local tChoices = FindChoices( sData )
		if #tChoices < 2 or #tChoices > 10 then
			return tErrors.sFewChoices
		end
		local sQuery = tQuery.sQuestion:format( sqlCon:escape(sTitle), sNick )
		local sqlCur = assert( sqlCon:execute(sQuery) )
		local iID = sqlCon:getlastautoid() or -1
		if iID == -1 then
			return "Some error occurred."
		end
		for iIndex, sChoice in ipairs( tChoices ) do
			local sQuery = tQuery.sChoice:format( iIndex, iID, sChoice )
			assert( sqlCon:execute(sQuery) )
		end
		return "New poll created with poll ID #"..iID
	end
end )()
