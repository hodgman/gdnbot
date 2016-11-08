litcord = require('litcord')
client = litcord.Client()


local gdutils = require('gdutils')
local print_r = gdutils.print_r
local print_t = gdutils.print_t
local MakeCaseInsensitivePattern = gdutils.MakeCaseInsensitivePattern

local censor = require('censor')
local secrets = require('secret/secrets')
local config = require('config')

local timer = require('timer')

local json = require('json')

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function StripTags( str )
	return str:gsub("%b<>", "")
end
function StripWhitespace( str )
	return str:gsub("%s", "")
end
local function istable(t) return type(t) == 'table' end


--local debug_html = 'd:\\' --Don't commit!!

client:login({ token = secrets.discordToken })

client:on(
	'ready',
	function()
		print('Ready!')
		client:setGame('GameDev.net')
		
		math.randomseed( os.time() )
	end
)


client:on('message', function(m) return censor.Message_Censorship(client, m) end )
client:on('messageUpdated', function(m) return censor.Message_Censorship(client, m) end )

--TODO - logging
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

local file = io.open('logs/'..os.date("!%Y_%m_%d")..'.log', 'a')
if file then
	file:write(os.date('!%H_%M_%S')..'--STARTING UP--\n')
	file:close()
end

local responses = { 'Does not compute.', 'Error Code: 1337', 'Say what?', 'Type !help for commands', '<http://www.gamedev.net/page/index.html>', "Well, there's always the singleplayer campaign." }
--TODO - Interactions
client:on(
	'message',
	function(message)
		if message.author.id == client.user.id then return end
		if not message.client_mentioned then return end
		
		message:reply(responses[math.random(#responses)])
	end
)

local letters = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','1','2','3','4','5','6','7','8','9','0'}
function GenerateSecret(length)
	local r = ''
	for i=1,length do
		r=r..letters[math.random(1,26+10)]
	end
	return r
end

client:on(
	'message',
	function(message)
		if message.cleanContent:sub(1,1) ~= '!' then return end
		
	end
)


local http = require('coro-http')
local httpCodec = require('http-codec')
local querystring = require('querystring')

cookies = {}

function httpRequest(config)

	local data = (config.data or {})
	local method = (config.method or 'GET'):upper()
	
	local cookieString = ''
	for k,v in pairs(cookies) do
		cookieString = cookieString..k..'='..v..';'
	end
	local headers =
	{
		{'Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'},
		{'User-Agent', 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'},
		{'User-Agent', 'DiscordBot'},
	--	{'Connection', 'close'},
		{'Connection', 'keep-alive'},
		{'Content-Type', 'application/x-www-form-urlencoded'},
	--	{'Origin', config.origin or 'http://www.gamedev.net'},
	--	{'Host', config.origin or 'www.gamedev.net'},
		{'Referer', config.referer or 'http://www.gamedev.net/index.php?app=core&module=global&section=login'},
		{'Cookie', cookieString},
	}
	
	if method == 'GET' then
		local i = 1
		for k,v in pairs(data) do
			local ch = ((i == 1) and '?') or '&'
			config.path = config.path..ch..k..'='..v
			i = i + 1
		end
		data = nil
	elseif method == 'DELETE' then
		data = nil
	else
		local encoded = ''
		local i = 1
		for k,v in pairs(data) do
			local ch = ((i == 1) and '') or '&'
			encoded = encoded..ch..k..'='..v
			i = i + 1
		end
		data = encoded
	end
	
	local success, response, received = pcall(
		function()
		--	print_r( { method, config.path, headers, data } )
			return http.request(
				method,
				config.path,
				headers,
				data
			)
		end
	)
	--print_r(response)
	if success and response then
	for i,v in ipairs(response) do
		local header = response[i]
		local k = header[1]
		local v = header[2]
		if k == 'Set-Cookie' then
		--	print( k..': '..v )
			name, data = v:match("([^=]+)=([^=]+);.*")
			cookies[name] = data
		end
	end
	end
	--print_r(cookies)
	return success, response, received
end

function GdnPostLogin()

	local success, response, received = httpRequest(
		{
			method = 'GET',
			path = 'https://www.gamedev.net/index.php',
			origin = 'http://www.gamedev.net',
			referer = 'http://www.gamedev.net/page/index.html',
			data =
			{
				app='core',
				module='global',
				section='login',
			},
		}
	)
	if not success then
		return false
	end
	
	success, response, received = httpRequest(
		{
			method = 'POST',
			path = 'https://www.gamedev.net/index.php?app=core&module=global&section=login&do=process',
			origin = 'http://www.gamedev.net',
			referer = 'http://www.gamedev.net/index.php?app=core&module=global&section=login',
			data =
			{
				auth_key = '880ea6a14ea49e853634fbdc5015a024',
				ips_username = 'discordbot',
				referer = 'http%3A%2F%2Fwww.gamedev.net%2Fpage%2Findex.html',
				ips_password = querystring.urlencode(secrets.gdnetPassword),
				remember = '1',
				invisible = '1',
			},
		}
	)
	if not success or response.code >= 400 then
		print('* Login error.')
		return false
	end
	if debug_html then
		local file = io.open (debug_html..'test.html', 'w')
		file:write(received)
		file:close()
	end
	return true
end

function GdnGetMessages()

	local success, response, received = httpRequest(
		{
			method = 'GET',
			path = 'http://www.gamedev.net/index.php?app=members&module=messaging&section=view&do=showFolder&folderID=myconvo',
			origin = 'http://www.gamedev.net',
			referer = 'http://www.gamedev.net/page/index.html',
		}
	)
	if success and debug_html then
		local file = io.open (debug_html..'messages.html', 'w')
		file:write(received)
		file:close()
	end
	return success, response, received
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local gdn_dirty = false
local verified_users = {}
local user_profile_queue = {}
local messages_queued = {}
local messages_fetched = {}
local messages_processed = {}
local pm_reply_queue = {}
local gdn_user_to_secret = {}
local gdn_secret_to_user = {}

function LoadGDNState()
	print('LoadGDNState()')
	local state = gdutils.loadFile('gdn_state')
	if not state then 
		print('could not load state')
		return 
	end
--	print_r(state)
	gdn_dirty = true
	if state.verified_users     then for k,v in pairs(state.verified_users) do verified_users[k] = v end end
	if state.user_profile_queue then for k,v in pairs(state.user_profile_queue) do user_profile_queue[k] = v end end
	if state.messages_queued    then for k,v in pairs(state.messages_queued) do messages_queued[k] = v end end
	if state.messages_fetched   then for k,v in pairs(state.messages_fetched) do messages_fetched[k] = v end end
	if state.messages_processed then for k,v in pairs(state.messages_processed) do messages_processed[k] = v end end
	if state.pm_reply_queue     then for k,v in pairs(state.pm_reply_queue) do pm_reply_queue[k] = v end end
	if state.gdn_user_to_secret then for k,v in pairs(state.gdn_user_to_secret) do gdn_user_to_secret[k] = v end end
	if state.gdn_secret_to_user then for k,v in pairs(state.gdn_secret_to_user) do gdn_secret_to_user[k] = v end end
end

function SaveGDNState(backup, backup_only)
	if not gdn_dirty and not backup_only then return end
	print('SaveGDNState()')
	gdn_dirty = false
	local state = {
		verified_users = verified_users,
		user_profile_queue = user_profile_queue,
		messages_queued = messages_queued,
		messages_fetched = messages_fetched,
		messages_processed = messages_processed,
		pm_reply_queue = pm_reply_queue,
		gdn_user_to_secret = gdn_user_to_secret,
		gdn_secret_to_user = gdn_secret_to_user,
	}
	local blacklist = { 'responseChannel' }
	if not backup_only then 
		gdutils.saveFile('gdn_state', state, blacklist)
	end
	if backup then
		gdutils.saveFile('backup/gdn_state'..os.time(), state, blacklist)
	end
end



client:on(
	'message',
	function(message)
		if message.cleanContent:sub(1,1) ~= '!' then return end
		
		if message.cleanContent:starts('!profile') then
			local userId = message.content:match('!profile%s*(.-)%s*')
			if next(message.mentions) == nil then
				message.channel:sendMessage('usage !profile @user')
			else
				for k,v in pairs(message.mentions) do
					if verified_users[v.id] and verified_users[v.id].gdnUrl then
						message.channel:sendMessage(v.username..': <'..verified_users[v.id].gdnUrl..'>')
					else
						message.channel:sendMessage(v.username..' is not a verified user')
					end
				end
			end
		end
	end
)

client:on(
	'message',
	function(message)
		if message.cleanContent:sub(1,1) ~= '!' then return end
		
		if message.cleanContent:starts('!claim') then
		
			local secret = gdn_user_to_secret[message.author.id]
			if not secret then
				repeat
					secret = 'GDN'..GenerateSecret(16)
				until not gdn_secret_to_user[secret]
				gdn_dirty = true
				gdn_secret_to_user[secret] = message.author.id
				gdn_user_to_secret[message.author.id] = secret
				SaveGDNState()
			end
		
			local content = 'To link your Discord account to GameDev.net, send me (DiscordBot) the following PM via the link below\n'..
			                '	Subject: claim\n'..
			                '	Message: '..secret..'\n'..
							'<http://www.gamedev.net/index.php?app=members&module=messaging&section=send&do=form&fromMemberID=238005>\n'
			
			if verified_users[message.author.id] and verified_users[message.author.id].gdnUrl then
				message:reply('You have already claimed <'..verified_users[message.author.id].gdnUrl..'>')
			else
				--if not message.author.channel then
				--	client:openDirectMessage(message.author.id)
				--end
				--
				--if message.author.channel then
				--	message.author.channel:sendMessage(content)
				--	
				--	if message.author.channel ~= message.channel then
				--		message:reply('Check your direct messages')
				--	end
				--else
				--	message:reply('For some reason I cannot direct message you! Please send me a direct message to open the channel for me :kissing_heart:')
				--end
				if nil == message.author:sendMessage(content) then
					message:reply('For some reason I cannot direct message you! Please send me a direct message to open the channel for me :kissing_heart:')
				else
					message:reply('I\'ve sent a direct message :kissing_heart:')
				end
			end
		elseif message.cleanContent:starts('!help') then
			local exampleUsers = { 'yoshi', 'dsm' }
			local content = ('**List of commands:\n'
				..'`!claim`: Link your GameDev.net profile to your discord account.\n'
				..'`!profile`: Find someone\'s GameDev.net profile (e.g. !profile @'..exampleUsers[math.random(#exampleUsers)]..').\n'
				)
				
			if nil == message.author:sendMessage(content) then
				message:reply('For some reason I cannot direct message you! Please send me a direct message to open the channel for me :kissing_heart: \n'..content)
			else
				message:reply('I\'ve sent a direct message :kissing_heart:')
			end
		elseif message.cleanContent:starts('!mute') then
			if IsModerator(message.author) then
				message:reply("ok")
			end
		elseif message.cleanContent:starts('!say ') then
			if IsModerator(message.author) then
			
				local pattern = '!say #(.-) (.*)'
				local channelName, content = message.cleanContent:match(pattern)
				if channelName == nil then
					channelName = 'botdev'
					pattern = '!say (.*)'
					content = message.cleanContent:match(pattern)
				end
				local channel = nil
				for k,v in pairs(client.__channels.__data) do
					if v.name == channelName then
						channel = v
						break
					end
				end
				if channel then
					if content == nil then
						content = message.cleanContent:sub(5, -1)
					end
					channel:sendMessage(content)
				end
			end
		elseif message.cleanContent:starts('!regroup') then
			if IsModerator(message.author) then
				message:reply("ok")
				GdnCheckIncompleteProfiles(true, message)
				SaveGDNState()
			end
		end
	end
)

function IsModerator(user)
	server = client.servers:get('id', config.gdnetServerId)
	local roleId = 0
	for k,v in pairs(server.roles.__data) do
		if v.name == 'Moderators' or v.name == 'Staff' then
			roleId = v.id
			break
		end
	end
	
	local member = server.members:get('id', user.id)
	return table.contains(member.roles, roleId)
end

local allowed_groups = {
	['Muted'] = true,
	['GDNet+'] = true,
	['Moderators'] = true,
	['Members'] = true,
	['Staff'] = true,
}
local group_remap = {
	[StripWhitespace('Staff')]                       = { 'Staff', 'Moderators', 'Members' },
	[StripWhitespace('Senior Staff')]                = { 'Staff', 'Moderators', 'Members' },
	[StripWhitespace('Moderators')]                  = { 'Moderators', 'Members' },
	[StripWhitespace('Senior Moderators')]           = { 'Moderators', 'Members' },
	[StripWhitespace('SM Post Editors')]             = { 'Moderators', 'Members' },
	[StripWhitespace('Distinguished Rhino')]         = { 'Moderators', 'Members' },
	[StripWhitespace('GDNet+')]                      = { 'GDNet+', 'Members' },
	[StripWhitespace('GDNet+ Beanstalk')]            = { 'GDNet+', 'Members' },
	[StripWhitespace('Moderated Users')]             = { 'Muted', 'Members' },
	[StripWhitespace('Banned')]                      = { 'Muted', 'Members' },
	['default']                                      = 'Members',
}


function GdnPostPmReplies(server)

	--print('GdnPostPmReplies')
	--print_r(pm_reply_queue)
	
	for k, item in pairs(pm_reply_queue) do
		local success, response, received = httpRequest({
			method = 'GET',
			path = 'http://www.gamedev.net/index.php?app=members&module=messaging&section=view&do=showConversation&topicID='..item.gdnTopicId,
			origin = 'http://www.gamedev.net',
			referer = 'http://www.gamedev.net/page/index.html',
		})
		
		if success and debug_html then
			local file = io.open (debug_html..'msg_'..item.gdnTopicId..'.html', 'w')
			file:write(received)
			file:close()
		end
		
		local failed = false
		local authKey
		if success then
			local pattern = "<input type='hidden' name='authKey' value='(.-)' />"
			authKey = received:match(pattern)
			if authKey then
				print( 'found authKey for '..item.gdnTopicId..' : '..authKey )
			else
				print( 'Failed to find authKey for '..item.gdnTopicId )
				failed = true
			end
		end
		
		if authKey then
			--first load 
			--find 
			
			success, response, received = httpRequest({
				method = 'POST',
				path = 'http://www.gamedev.net/index.php?app=members&module=messaging&section=send&do=sendReply&topicID='..item.gdnTopicId,
				origin = 'http://www.gamedev.net',
				referer = 'http://www.gamedev.net/page/index.html',
				data = {
					authKey=authKey,
					fast_reply_used='1',
					enableemo='yes',
					enablesig='yes',
					isRte='1',
					noSmilies='0',
					noCKEditor_editor_5754eb3b7d418='0',
					msgContent='<p>'..item.content..'</p>',
					submit='Post',
				}
			})
			if success and not received:find('The following errors were found', 1, true) then
				print( 'Sent PM!' )		
				if debug_html then 
					local file = io.open (debug_html..'reply_'..item.gdnTopicId..'.html', 'w')
					file:write(received)
					file:close()
				end
			else
				print( 'Error sending PM!' )
				failed = true
			end
		end
		if failed then
			item.failed = (item.failed or 0) + 1
			if item.failed > 10 then
				print( 'Dropping PM after 10 failures!' )
				gdn_dirty = true
				pm_reply_queue[k] = nil
			end
		else
			gdn_dirty = true
			pm_reply_queue[k] = nil
		end
	end
	
end

function GdnCheckIncompleteProfiles(force, responseChannel)
	for userId, item in pairs(verified_users) do
		if (item.group == nil or force) and item.gdnUrl and userId and not user_profile_queue[item.gdnUrl] then
			gdn_dirty = true
			user_profile_queue[item.gdnUrl] = { discordUserId=userId, responseChannel=responseChannel };
		end
	end
end


function AddUserToGroup(server, discordUserId, group)
	local roleId = 0
	for k,v in pairs(server.roles.__data) do
		if v.name == group then
			roleId = v.id
			break
		end
	end
	if not roleId then
		print( 'Could not find role '..group )
		return 'Sorry, I failed to add you to '..group..'\n'
	else
		local member = server.members:get('id', discordUserId)
		if not table.contains(member.roles, roleId) then
		--todo - test new API
			table.insert(member.roles, roleId)
			member:edit({ roles = member.roles })
			print( 'Granted role '..group..' to '..member.user.username )
			return 'You have been added to '..group..'\n'
		else
			print( member.user.username..' already had role '..group )
			return ''
		end
	end
end

function SetUserGroups(server, discordUserId, groups)
	local message = ''
	local roleIds = {}
	for _,group in ipairs(groups) do
		local roleId = 0
		for k,v in pairs(server.roles.__data) do
			if v.name == group then
				roleId = v.id
				break
			end
		end
		if not roleId then
			print( 'Could not find role '..group )
			message = message..'Sorry, I failed to add you to '..group..'\n'
		else
			table.insert(roleIds, roleId)
			message = message..'You have been added to '..group..'\n'
		end
	end
	
	local member = server.members:get('id', discordUserId)
	--todo - test new API
	if member then
		member.roles = roleIds
		member:edit({ roles = member.roles })
		return message
	else
		return ''
	end
end

function GdnGetQueuedProfiles(server)
	for url, item in pairs(user_profile_queue) do
		local discordUserId = item.discordUserId
		local gdnTopicId = item.gdnTopicId
		local responseChannel = item.responseChannel
		local success, response, received = httpRequest({
			method = 'GET',
			path = url,
			origin = 'http://www.gamedev.net',
			referer = 'http://www.gamedev.net/page/index.html',
		})
		if success and response.code < 400 then
			if debug_html then
				local file = io.open (debug_html..'profile_'..discordUserId..'.html', 'w')
				file:write(received)
				file:close()
			end
			
			local pattern = "<span class='row_title'>Group</span>(.-)</span>"
			group = StripWhitespace(StripTags( received:match(pattern) ))
			
			if group_remap[group] then
				group = group_remap[group]
			else
				group = group_remap['default']
			end
			
			--[[if group == 'Banned' then
				print( 'oh shit, user should be banned' )
				discordUserId = nil
			else--]]if not group then
				discordUserId = nil
				group = '???'
			end
			
			if not istable(group) then
				group = { group }
			end
			for _,g in ipairs(group) do
				if not allowed_groups[g] then
					print( 'What is '..g..'?' )
					discordUserId = nil
					break
				end
			end
			
			--print( '|'..url..'|'..group..'|' )
			
			if discordUserId then
				gdn_dirty = true
				verified_users[discordUserId].group = group
				
				--local pmResponse = ''
				--for _,g in ipairs(group) do
				--	pmResponse = pmResponse..AddUserToGroup(server, discordUserId, g)
				--end
				local pmResponse = SetUserGroups(server, discordUserId, group)
		
				if gdnTopicId and string.len(pmResponse)>0 then
					table.insert( pm_reply_queue, {gdnTopicId=gdnTopicId, content=pmResponse} )
				end
				if responseChannel and responseChannel.reply and string.len(pmResponse)>0 then
					responseChannel:reply('Processing '..verified_users[discordUserId].gdnName)
					responseChannel:reply(pmResponse..'\n')
				end
				
				gdn_dirty = true
				user_profile_queue[url] = nil
			end
		end
	end
end

function VerifyUser( server, message, gdnTopicId )
	
	gdn_dirty = true
	
	if message.gdnName == nil then
		print( 'Invalid message' )
		return false
	end
	if message.gdnUrl == nil then
		print( 'Invalid message' )
		return false
	end
	
	local secret = message.content
	local userId = gdn_secret_to_user[secret] 
	if not userId then
		print( message.gdnName..' sent a bogus claim' )
		gdn_dirty = true
		table.insert( pm_reply_queue, {gdnTopicId=gdnTopicId, content='Could not validate that secret token. Did you copy and paste it correctly?</p><p>Do not use the reply button below; please begin a new PM from scratch.' } )
		return true
	end
	
	local member = server.members:get('id', userId)
		
	if not member then
		print( message.gdnName..' sent a claim for a missing member?' )
		gdn_dirty = true
		table.insert( pm_reply_queue, {gdnTopicId=gdnTopicId, content='something went wrong...' } )
		return true
	end
	
	if verified_users[userId] then
		gdn_dirty = true
		table.insert( pm_reply_queue, {gdnTopicId=gdnTopicId, content='This discord account has already been claimed by '..verified_users[userId].gdnName..'/'..verified_users[userId].username } )
		return true
	end
	verified_users[userId] = { gdnId=message.gdnId, gdnUrl=message.gdnUrl, gdnName=message.gdnName, username=member.user.username, discriminator=member.user.discriminator }
	print( message.gdnName..' claiming '..userId )
	
	user_profile_queue[message.gdnUrl] = { discordUserId=userId, gdnTopicId=gdnTopicId };

--	for k,v in pairs(server.members.__data) do
--		--print_t(v.user)
--		if v.user and v.user.username == message.username and v.user.discriminator == message.discriminator then
--		
--			if verified_users[v.user.id] then
--				table.insert( pm_reply_queue, {gdnTopicId=gdnTopicId, content='This discord account has already been claimed by '..verified_users[v.user.id].gdnName..'/'..verified_users[v.user.id].username } )
--				return
--			end
--			verified_users[v.user.id] = { gdnId=message.gdnId, gdnUrl=message.gdnUrl, gdnName=message.gdnName, username=message.username, discriminator=message.discriminator }
--			print( message.gdnName..' claiming '..v.user.id )
--			
--			user_profile_queue[message.gdnUrl] = { discordUserId=v.user.id, gdnTopicId=gdnTopicId };
--			return
--		end
--	end
	
--	print( message.gdnName..' sent a bogus claim' )
--	--print_r(message)
--	table.insert( pm_reply_queue, {gdnTopicId=gdnTopicId, content='I did not understand this message.' } )
	return true
end

function ProcessGdnPmMessages()
	server = client.servers:get('id', config.gdnetServerId)
	if not server then print('shit') return end
	
	for gdnTopicId,v in pairs(messages_fetched) do
		--if v.type =='claim' then
		if not VerifyUser(server, v, gdnTopicId) then
		--else
			gdn_dirty = true
			table.insert( pm_reply_queue, {gdnTopicId=gdnTopicId, content='I did not understand the subject line.' } )
		end
		gdn_dirty = true
		messages_fetched[gdnTopicId] = nil
		messages_processed[gdnTopicId] = true
	end
	
	SaveGDNState()
	
	GdnCheckIncompleteProfiles(false, nil)
	GdnGetQueuedProfiles(server)
	
	--print('user list')
	--print_r(verified_users)
	
	SaveGDNState()
	
	GdnPostPmReplies(server)
end
	
function GdnGetQueuedMessages()
	for gdnTopicId, url in pairs(messages_queued) do
		local success, response, received = httpRequest({
			method = 'GET',
			path = url,
			origin = 'http://www.gamedev.net',
			referer = 'http://www.gamedev.net/page/index.html',
		})
		if success and response.code < 400 then
			if debug_html then
				local file = io.open (debug_html..'message_'..gdnTopicId..'.html', 'w')
				file:write(received)
				file:close()
			end
			
			local subjectPattern = "<h2 class='maintitle'>(.-)</h2>"
			local subject = StripWhitespace(StripTags(received:match(subjectPattern)))
			--1234
			--http://www.gamedev.net/user/116251-hodgman/
			--Hodgman
			local authorPattern = '<span class="author vcard"><a.-hovercard%-ref="member" hovercard%-id="(%d+)" data%-ipb="noparse" class="_hovertrigger url fn name " href=\'(.-)\' title=\'View Profile\'><span itemprop="name">(.-)</span></a></span>'
		
			authorId, profileUrl, authorName = received:match(authorPattern)
			
			local contentPattern = "<div class='post entry%-content'>%s*(.-)%s*</div>"
			local content = StripWhitespace(StripTags(received:match(contentPattern)))
			--print( '|'..authorId..'|'..profileUrl..'|'..authorName..'|'..content..'|' )
			--username, discriminator = content:match('(.*)#(%d%d%d%d)')
			
			gdn_dirty = true
			messages_queued[gdnTopicId] = nil
			messages_fetched[gdnTopicId] = { type=subject:lower(), gdnId=authorId, gdnUrl=profileUrl, gdnName=authorName, content=content }
			print_r(messages_fetched[gdnTopicId])
		end
	end
	
	SaveGDNState()
	
	ProcessGdnPmMessages()
end

function GdnParseMessages(success, response, received)
	if not success then return false end
	
	local pattern = "<a href='http://www.gamedev.net/index.php%?app=members&amp;module=messaging&amp;section=view&amp;do=showConversation&amp;topicID=(%d+)' title='View this conversation'>"
	pattern = gdutils.MakeCaseInsensitivePattern(pattern)
	
	--local pattern2 = '(%d+)"'
	
--	print( 'parsing' )
	local cursor = 1
	repeat
		local _,gdnTopicId
		_, cursor, gdnTopicId = string.find(received, pattern, cursor)
		if gdnTopicId then
			if messages_fetched[gdnTopicId] == nil and messages_queued[gdnTopicId] == nil and messages_processed[gdnTopicId] == nil then
				print( 'message#'..gdnTopicId )
				gdn_dirty = true
				messages_queued[gdnTopicId] = 'http://www.gamedev.net/index.php?app=members&module=messaging&section=view&do=showConversation&topicID='..gdnTopicId
			end
		end
	until cursor == nil
	
	timer.sleep(500)
	
	GdnGetQueuedMessages()
	
	return true
	
end


local litcord_constants = require('litcord/constants')

client:on(
	{
		litcord_constants.events.GUILD_CREATE,
	--	litcord_constants.events.GUILD_UPDATE,
	},
	function(data)
		--timer.sleep(500)
		
		local roles = data.roles or {}
		local members = data.members or {}
		local channels = data.channels or {}
		data.roles = nil
		data.members = nil
		data.channels = nil
		--
		local server = client.servers:get('id', data.id)
		if not server then
			print('Connected to a server that doesn\'t exist??')
		end
	
		print('Connected to '..data.name..' : '..data.id)
		
		if data.id == config.gdnetServerId then
			
		--coroutine.wrap(function ()
		LoadGDNState()
		SaveGDNState(true, true)
		while true do
			print('GdnLogin()')
			if GdnPostLogin() then
				print('GdnGetMessages()')
				GdnParseMessages(GdnGetMessages())
			end
			SaveGDNState(true)
			timer.sleep(1000*120)
		end
		--end)() 
		end
	end
)


--client:on(
--	'message',
--	function(message)
--		if string.find(message.cleanContent, 'foobar') then
--		else
--		return
--		end
--		
--		GdnGetQueuedMessages()
--		
--	end
--)