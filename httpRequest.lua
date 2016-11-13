
local http = require('coro-http')
local httpCodec = require('http-codec')

local cookies = {}

local function httpRequest(config)

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
		--	utils.print_r( { method, config.path, headers, data } )
			return http.request(
				method,
				config.path,
				headers,
				data
			)
		end
	)
	--utils.print_r(response)
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
	--utils.print_r(cookies)
	return success, response, received
end

return {
	httpRequest = httpRequest
}