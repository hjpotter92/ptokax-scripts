local chatroom = {'Modz-Chat','Vip-Chat','Hub-Feed'}
local profiles =  { ["Modz-Chat"] = 4,
			["Vip-Chat"] = 3,
			["Hub-Feed"] = 3
			}

local modz = RegMan.GetRegsByProfile(4)
local vips = RegMan.GetRegsByProfile(3)
local ops = RegMan.GetRegsByProfile(2)
local gawds = RegMan.GetRegsByProfile(1)
local master = RegMan.GetRegsByProfile(0)

local list = { [4]= modz,
		  [3] = vips,
		  [2] = ops,
		  [1] =gawds,
		   [0] = master }

function Chatroomsend( user, chatz, message)
	local k = profiles[chatz]
	for i = 0,k,1 do
		local a = list[i]
		for k,v in ipairs(a) do
			if v.sNick ~= user then
				msg = string.format( "$To: %s From: %s $<%s> %s", v.sNick, chatz, user, message )
				Core.SendToNick( v.sNick, msg )
			end
		end
	end
end
