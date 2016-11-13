
local file = io.open('logs/'..os.date("!%Y_%m_%d")..'.log', 'a')
if file then
	file:write(os.date('!%H_%M_%S')..'--STARTING UP--\n')
	file:close()
end

local client = _G['client']

client:on(
	'message',
	function(message)
		local channelName = message.channel.name or '?'
		local log = os.date('!%H_%M_%S')..' : #'..channelName:gsub(":", "::")..' : '..message.author.username:gsub(":", "::")..'('..message.author.id..')'..' : '..message.cleanContent:gsub(":", "::")..' : ';
		--if( message.author.id == '109587405673091072' ) then
		--	message.channel:sendMessage('<@!109587405673091072> Hi')
		--end
		
		local file = io.open('logs/'..os.date("!%Y_%m_%d")..'.log', 'a')
		if file then
			file:write(log..'\n')
			file:close()
		end
		
		print( log )
		
	end
)