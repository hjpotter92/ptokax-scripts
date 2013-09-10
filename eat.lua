path="/root/PtokaX/scripts/"
bot=SetMan.GetString(21)
dofile(path.."files/digest.lua")
nickc = {}
falone = {}
muted = {}
desu =false
san =false
chan =false
inPM=false
local temp={					 -- built in commands ,bypass these commands if typed in mainchat
"ban", "banip", "fullban", "fullbanip", "nickban", "tempban", "tempbanip", "fulltempban", "fulltempbanip", "nicktempban", "unban", 
"permunban", "tempunban", "getbans", "getpermbans", "gettempbans", "clrpermbans", "clrtempbans", "rangeban", "fullrangeban", 
"rangetempban", "fullrangetempban", "rangeunban", "rangepermunban", "rangetempunban", "getrangebans", "getrangepermbans", 
"getrangetempbans", "clrrangepermbans", "clrrangetempbans", "checknickban", "checkipban", "checkrangeban", "getinfo", "op",
"gag", "ungag", "restart", "startscript", "stopscript", "restartscript", "restartscripts", "getscripts", "reloadtxt", "addreguser", "delreguser", 
"topic", "massmsg", "opmassmsg", "myip", "help"
}	
PtokaxCommands={}
for k,v in ipairs(temp) do
	PtokaxCommands[v]=true
end
cmdchars = {	--commands start with these
["!"]=true,
["/"]=true,
["+"]=true
}
tmr = TmrMan.AddTimer(400,"fileread") 

fileread = function()
	local file = io.open("/root/IRCout.txt","r")
	if not file then return end
	local msg = file:read("*a")
	file:close();
	if msg ~= "" then
		local user = {
			sNick = "IRC",
			sIP="127.0.0.1",
			iProfile = 6
			}
		local file=io.open("/root/IRCout.txt","w+")
		file:close()
		digest(user,msg,true)
	end
end
ChatArrival = function(user,data)
	local data = string.gsub(data,"|","") --remove terminating |
	local tempdata = data.." "
	 _, _,fchar,cmd= tempdata:find( "%b<> (.)(%S+)%s")
	 local isCmd=false
	 local irc=false
	if  not cmdchars[fchar] then	
		isCmd=false
		digest(user,data,isCmd,irc)
		return true
	end
	if isthere(cmd,PtokaxCommands) then		-- let ptokax handle inbuilt commands
		return
	end
	if isthere(cmd,CustomCommands) then  
		isCmd=true
		inPM=false
		digest(user,data,isCmd,irc)
		return true
	end
end

ToArrival = function( user, data)
	local tempdata = string.gsub(data,"|","") --remove terminating |
	local tempdata = tempdata.." "
	 _,_,to,from= tempdata:find( "$To:%s(%S+)%sFrom:%s(%S+)%s$%b<>%s.*")
	if  to~= "PtokaX" then
		return
	end
	_,_,tempdata=tempdata:find("$.*$(.*)")
	_, _,fchar,cmd= tempdata:find( "%b<> (.)(%S+)%s")
	if  not cmdchars[fchar] then	
		return
	end
	if isthere(cmd,CustomCommands) then  
		local isCmd=true
		local irc=false
		inPM=true
		digest(user,tempdata,isCmd,irc)
		return true
	end
end

