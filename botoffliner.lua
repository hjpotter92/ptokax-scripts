function OnStartup()
	tCfg = {
		sBotName = "[BOT]Offliner",
		sBotDescription = "The database of newest additions to hub.",
		sBotEmail = "do-not@mail.me",
		sFunctionsFile = "botoff.lua",
		sHelpFile = "ohelp.txt",
		sRulesFile = "general.txt",
		sPath = "/root/PtokaX/scripts/files/",
		sChatFile = "chatcore.lua",
		sReportBot = "#[Hub-Feed]",
		iModProfile = 4,
		iRegProfile = 5
	}
	tProfiles = {
		AllowVIP = {
			[0] = true,			-- Admin
			[1] = true,			-- God
			[2] = true,			-- OP
			[3] = true,			-- VIP
			[4] = false,		-- Mods
			[5] = false,		-- Reg
			[6] = false,		-- sVIP
			[7] = false			-- gymkhana
		},
		AllowAdmin = {
			[0] = true,			-- Admin
			[1] = false,			-- God
			[2] = true,			-- OP
			[3] = false,			-- VIP
			[4] = false,		-- Mods
			[5] = false,		-- Reg
			[6] = false,		-- sVIP
			[7] = false			-- gymkhana
		}
	}
	dofile( tCfg.sPath..tCfg.sFunctionsFile )
	dofile( tCfg.sPath..tCfg.sChatFile )
	local fHelp = io.open( tCfg.sPath..tCfg.sHelpFile )
	local fRules = io.open( tCfg.sPath..tCfg.sRulesFile )
	sHelp = fHelp:read( "*a" )
	sRules = fRules:read( "*a" )
	Core.RegBot( tCfg.sBotName, tCfg.sBotDescription, tCfg.sBotEmail, true )
	sAllModerators, sAllCategories = tFunction.Connect()
end

function ToArrival( tUser, sMessage )
	local sTo = sMessage:match( "%$To: (%S+) From:" )
	if sTo ~= tCfg.sBotName then return false end
	local sCmd, sData = sMessage:match( "%b<>%s[%+%-%*%/%!%#%?](%w+)%s?(.*)|" )
	if not sCmd then return false end
	return ExecuteCommand( tUser, sCmd, sData )
end

--~ function ChatArrival( tUser, sMessage )
--~ 	local _, _, sCmd, sData = sMessage:find( "%b<>%s[%+%-%*%/%!%#%?](%w+)%s?(.*)|" )
--~ 	if not sCmd then return false end
--~ 	return ExecuteCommand( tUser, sCmd, sData )
--~ end

function UserConnected( tUser )
	tOffliner.PassMessage( tUser.sNick )
end

RegConnected, OpConnected = UserConnected, UserConnected

function ExecuteCommand( tUser, sCmd, sData )
	if sCmd == "l" or sCmd == "latest" then
		if (not sData) or sData:len() == 0 then
			tOffliner.l( tUser, 35 )
			return true
		else
			local tBreak = tFunction.Explode( sData )
			if tBreak[1] and tonumber( tBreak[1] ) then
				tOffliner.l( tUser, tonumber(tBreak[1]) )
				return true
			elseif tBreak[2] and tonumber( tBreak[2], 10 ) then
				tOffliner.l( tUser, tonumber(tBreak[2]), tBreak[1] )
				return true
			elseif not tonumber( tBreak[1] ) then
				tOffliner.l( tUser, 20, tBreak[1] )
				return true
			else
				Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 1) )
				return true
			end
			return true
		end
		return true

	elseif sCmd == "h" or sCmd == "help" then
		Core.SendPmToUser( tUser, tCfg.sBotName, sHelp )
		return true

	elseif sCmd == "r" or sCmd == "rules" then
		Core.SendPmToUser( tUser, tCfg.sBotName, sRules )
		return true

	elseif sCmd == "m" or sCmd == "msg" then
		if not sData or sData:len() == 0 then
			Core.SendPmToUser( tUser, tCfg.sBotName, "No message was specified. Error raised." )
			return true
		elseif sData:len() > 300 then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Message must be less than 300 characters. Error raised." )
			return true
		end
		local tBreak = tFunction.Explode( sData )
		tOffliner.StoreMessage( tUser.sNick, tBreak[1], table.concat(tBreak, " ", 2) )
		return true

	elseif sCmd == "search" or sCmd == "s" then
		if (not sData) or sData:len() == 0 then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! No search string was given." )
			return true
		elseif sData:len() < 3 then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 1) )
			return true
		else
			tOffliner.s( tUser, sData )
			return true
		end
		return true

	elseif sCmd == "sc" or sCmd == "showctg" then
		Core.SendPmToUser( tUser, tCfg.sBotName, sAllCategories.."|" )
		return true

	elseif sCmd == "sm" or sCmd == "showmods" then
		Core.SendPmToUser( tUser, tCfg.sBotName, sAllModerators.."|" )
		return true
	end

	if tUser.iProfile == -1 then
		Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 2 ) )
		return true
	end

	if (not sData) or sData:len() == 0 then
		Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 4 ) )
		return true
	end
	local tBreak = tFunction.Explode( sData )

	if sCmd == "al" or sCmd == "addlatest" then
		if #tBreak < 3 then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 4 ) )
			return true
		elseif not tFunction.CheckCategory( tBreak[1] ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! That category doesn't exist." )
			return true
		elseif not tFunction.CheckModerator( tUser.sNick ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 120)..sAllModerators )
			return true
		end
		if tOffliner.al( tUser, tBreak ) then
			local sChatMessage = "New "..tBreak[1]:upper()..": "..table.concat(tBreak, " ", 2).." added to latest database."
			tFunction.SendToAll( tUser.sNick, sChatMessage )
			SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot, tCfg.iModProfile )
			return true
		else
			return true
		end

	elseif sCmd == "dl" or sCmd == "dellatest" then
		if not tonumber( tBreak[1] ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return true
		end
		local tRow = tFunction.FetchRow( tonumber(tBreak[1]) )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 2) )
			return true
		end
		if tProfiles.AllowVIP[tUser.iProfile] or tRow.nick:lower() == tUser.sNick:lower() then
			tOffliner.dl( tUser, tonumber(tBreak[1]) )
			SendToRoom( tUser.sNick, "The entry #"..tostring(tBreak[1]).." - "..tRow.msg.." was deleted.", tCfg.sReportBot )
			Core.SendPmToUser( tUser, tCfg.sBotName, "The following entry was deleted.\n"..tFunction.CreateLatestReading(tRow) )
			return true
		elseif tRow.nick:lower() ~= tUser.sNick:lower() then
			Core.SendPmToUser( tUser, tCfg.sBotName, "This entry was not added by you. You can not delete it." )
			return true
		end

	elseif sCmd == "ul" or sCmd == "updatelatest" then
		if not tFunction.CheckModerator( tUser.sNick ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 120) )
			return true
		end
		if not tonumber( tBreak[1] ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return true
		end
		local tRow = tFunction.FetchRow( tonumber(tBreak[1]) )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 2) )
			return true
		end
		if tProfiles.AllowVIP[tUser.iProfile] or tRow.nick:lower() == tUser.sNick:lower() then
			tOffliner.ul( tUser, tBreak )
			Core.SendPmToUser( tUser, tCfg.sBotName, "The message has been updated." )
			local sChatMessage = "Entry #"..tostring(tBreak[1]).." was updated. "
			tFunction.SendToAll( tUser.sNick, sChatMessage.."Older entry was: "..tRow.msg )
			SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot, tCfg.iModProfile )
			return true
		elseif tRow.nick:lower() ~= tUser.sNick:lower() then
			Core.SendPmToUser( tUser, tCfg.sBotName, "This entry was not added by you. You do not have permission to edit it." )
			return true
		end
		return true

	elseif sCmd == "am" or sCmd == "addmagnet" then
		if not tFunction.CheckModerator( tUser.sNick ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 120) )
			return true
		end
		if not tonumber(tBreak[1]) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return true
		end
		local tRow = tFunction.FetchRow( tonumber(tBreak[1]) )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 2) )
			return true
		end
		if tOffliner.am( tUser, tBreak ) then
			local sChatMessage = "Magnet "..tBreak[2].." added for entry #"..tostring(tBreak[1]).." - "..tRow.msg
			tFunction.SendToAll( tUser.sNick, sChatMessage )
			SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot, tCfg.iModProfile )
			return true
		else
			return true
		end

	elseif sCmd == "em" or sCmd == "editmagnet" then
		if not tFunction.CheckModerator( tUser.sNick ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 120) )
			return true
		end
		if not tonumber(tBreak[1]) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return true
		end
		local tRow = tFunction.FetchMagnetRow( tonumber(tBreak[1]) )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 2) )
			return true
		end
		if tProfiles.AllowVIP[tUser.iProfile] or tRow.nick:lower() == tUser.sNick:lower() then
			if not tOffliner.em( tUser, tBreak ) then return true end
			local sChatMessage = "Magnet "..tBreak[2].." edited for magnetID #"..tostring(tBreak[1]).."."
			tFunction.SendToAll( tUser.sNick, sChatMessage )
			SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot, tCfg.iModProfile )
			return true
		else
			return true
		end

	elseif sCmd == "rm" or sCmd == "removemagnet" then
		if not tFunction.CheckModerator( tUser.sNick ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 120) )
			return true
		end
		if not tonumber(tBreak[1]) then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("gen", 5) )
			return true
		end
		local tRow = tFunction.FetchMagnetRow( tonumber(tBreak[1]) )
		if not tRow then
			Core.SendPmToUser( tUser, tCfg.sBotName, tFunction.Report("off", 2) )
			return true
		end
		if tProfiles.AllowVIP[tUser.iProfile] or tRow.nick:lower() == tUser.sNick:lower() then
			if not tOffliner.rm( tUser, tonumber(tBreak[1]) ) then return true end
			local sChatMessage = "Magnet removed for magnetID #"..tostring(tBreak[1]).."."
			SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot )
			return true
		else
			return true
		end

	elseif sCmd == "addmod" then
		if not tProfiles.AllowVIP[tUser.iProfile] then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! You don't have access to this command." )
			return true
		end
		if not RegMan.GetReg( tBreak[1] ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! The user "..tBreak[1].." must register first." )
			return true
		elseif tFunction.CheckModerator( tBreak[1] ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! The user "..tBreak[1].." is already a moderator." )
			return true
		end
		RegMan.ChangeReg( tBreak[1], RegMan.GetReg(tBreak[1]).sPassword, tCfg.iModProfile )
		if tOffliner.addmod( tUser, tBreak[1] ) then
			sAllModerators, sAllCategories = tFunction.Connect()
			local sChatMessage = "New moderator: "..tBreak[1].." ."
			tFunction.SendToAll( tUser.sNick, sChatMessage )
			SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot )
			return true
		else
			return true
		end

	elseif sCmd == "delmod" then
		if not tProfiles.AllowVIP[tUser.iProfile] then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! You don't have access to this command." )
			return true
		end
		if not tFunction.CheckModerator( tBreak[1] ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! The user "..tBreak[1].." is not a moderator." )
			return true
		end
		tOffliner.delmod( tUser, tBreak[1] )
		sAllModerators, sAllCategories = tFunction.Connect()
		local sChatMessage = "Moderator removed: "..tBreak[1].." ."
		tFunction.SendToAll( tUser.sNick, sChatMessage )
		SendToRoom( tUser.sNick, sChatMessage, tCfg.sReportBot )
		if not RegMan.GetReg( tBreak[1] ) then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! The user "..tBreak[1].." is unregistered at the moment." )
			return true
		elseif not tProfiles.AllowAdmin[tUser.iProfile] then
			RegMan.ChangeReg( tBreak[1], RegMan.GetReg(tBreak[1]).sPassword, tCfg.iModProfile )
			return true
		end
		return true

	elseif sCmd == "addctg" then
		if not tProfiles.AllowAdmin[tUser.iProfile] then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! You don't have access to this command." )
			return true
		end
		tOffliner.addctg( tUser, tBreak[1] )
		return true

	elseif sCmd == "delctg" then
		if not tProfiles.AllowAdmin[tUser.iProfile] then
			Core.SendPmToUser( tUser, tCfg.sBotName, "Sorry! You don't have access to this command." )
			return true
		end
		return true

	else
		return false
	end
	return false
end
