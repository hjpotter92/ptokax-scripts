
modifiers=function(user,data)	
	if isthere(user.sNick,muted) then 
		if user.sNick ~= "IRC" then
			Core.SendToUser(user,"<PtokaX> You are muted.|")
		end
		return false
	end
	 if isthere_key(user.sNick,unsubbed) then
                Core.SendToUser(user,"<PtokaX> You have unsubscribed from Mainchat.To subscribe again enter !sub|")
		return false
	end
	local msg = string.gsub(data,"%b<>(.*)","%1")
	local nick=user.sNick
	if isthere(user.sNick,nickc) then 
		nick = nickc[user.sNick]
	end
	if desu then
	   msg = msg.." desu"
        end
	--allow only 1 at a time
	if san then
		nick=nick.."-san"
        end
	if chan then
		nick=nick.."-chan"
	end
	local finalmsg="<"..nick..">"..msg
	if isthere(user.sNick,falone) then 
		Core.SendToUser(user,finalmsg)
		return false
	end
	return finalmsg
end
