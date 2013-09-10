
dofile(path.."files/custcom.lua")
dofile(path.."files/modifiers.lua")
dofile(path.."files/expel.lua")
dofile(path.."files/dependency/pickle.lua" )
digest =function( user,data,isCmd,irc)
		
	if isCmd then
		msg=custcom(user,data)
	else
		msg=modifiers(user,data)
	end
	if msg ~=false then
		dcmcout(msg)
		if irc then
			ircout(msg)
		end
	end
end
