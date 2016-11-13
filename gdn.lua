_G.litcord = require('litcord')
_G.client = litcord.Client()

--debug_html = 'd:\\' --Don't commit!!

local http = require('coro-http')
local httpCodec = require('http-codec')
local querystring = require('querystring')
local fs = require('fs')

local utils = require('./utils')
require('./logger')
require('./gamedev_web')

local censor = require('./censor')
local secrets = require('./secret/secrets')
local config = require('./config')
local timer = require('timer')
local json = require('json')



client:login({ token = secrets.discordToken })

client:on(
	'ready',
	function()
		print('Ready!')
		client:setGame('GameDev.net')
		
		math.randomseed( os.time() )
	end
)


client:on('message',        function(m) return censor.Message_Censorship(client, m) end )
client:on('messageUpdated', function(m) return censor.Message_Censorship(client, m) end )



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
		if message.cleanContent:starts('!help') then
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
			if utils.IsModerator(message.author) then
				message:reply("ok")
			end
		elseif message.cleanContent:starts('!say ') then
			if utils.IsModerator(message.author) then
			
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
			if utils.IsModerator(message.author) then
				message:reply("ok")
				GdnCheckIncompleteProfiles(true, message)
				SaveGDNState()
			end
		end
	end
)
