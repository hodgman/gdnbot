
local utils = require('./utils')


--todo wrap up so censor_table can be modified and saved/loaded
local censor_table = {
	['Language'] = {
	--	'java',
	},
	['Bad'] = {
		'assrape',
		'^rape',
		'faggot',
		'nigger',
		'^fag',
		'fag$',
	},
	['Insults'] = {
		'tard[^%s]*',
		'assh[^%s]*',
		'douche[^%s]+',
	},
	['Rude'] = {
		'fuck you',
		'fuck off',
	--	'fuck[^%s]+',
	--	'cunt',
	--	'dick',
		'cum$',
	--	'cums',
	},
}

local fixed_censor_table = {}
for group, words in pairs( censor_table ) do
	fixed_censor_table[group] = {}
	for i, v in pairs( words ) do
		table.insert( fixed_censor_table[group], utils.MakeCaseInsensitivePattern(v) )
		if v:sub(-1,-1) == '$' then
			v = v:sub(1,-2)..'%s'
			table.insert( fixed_censor_table[group], utils.MakeCaseInsensitivePattern(v) )
		end
		if v:sub(1,1) == '^' then
			v = '%s'..v:sub(2,-1)
			table.insert( fixed_censor_table[group], utils.MakeCaseInsensitivePattern(v) )
		end
	end
end

local loungeId

local drop = 0

local function Message_Censorship(client, message)
	if message.author.id == client.user.id then return end
	if --message.channel.name ~= 'general' and
	   --message.channel.name ~= 'gamedev' and
	   message.channel.name ~= 'botdev' then
		return 
	end
	
	drop = drop + 1
	if drop >= 2 then
		drop = 0
		return
	end
	--utils.print_r(fixed_censor_table)

	local reason = ''
	local censorCount = 0
	local newContent = message.content
	for group, words in pairs( fixed_censor_table ) do
		local group_triggered = false
		for i, v in pairs( words ) do
			local count = 0
			newContent, count = string.gsub(newContent, v, '#*@!!')
			censorCount = censorCount + count
			if count > 0 and not group_triggered then
				group_triggered = true
				reason = reason..'['..group..']'
			end
		end
	end
	
	if not loungeId then
		for k,v in pairs(client.__channels.__data) do
			if v.name == 'lounge' then
				loungeId = v.id
				break
			end
		end
	end
	
	if censorCount > 0 then
		local doDelete = math.random(0,1) > 0
		if doDelete then 
			newContent = reason..'"`'..newContent..'`"'
		else
			newContent = reason
		end
		if loungeId then
			newContent = 'Take it to the <#'..loungeId..'>! '..newContent
		end
		
		message:reply(newContent)
		if doDelete then 
			message:delete()
		end
	end
end


return {
	Message_Censorship = Message_Censorship,
}
