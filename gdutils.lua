
local function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

local function print_t( t )  
	for k, v in pairs( t ) do
	   print(k, v)
	end
end

local function MakeCaseInsensitivePattern(pattern)
	pattern = pattern:gsub('(%%%a)', function(v) return '|'..v:byte(2)..'|' end);
	pattern = pattern:gsub('(%a)', function(v) return '['..v:upper()..v:lower()..']' end)
	pattern = pattern:gsub('(|%d%d*%d*|)', function(v) return '%'..string.char(tonumber(v:sub(2,-2))) end);
	return pattern
end

local function serialize(file, o)
	if type(o) == 'number' then
	--	print('number'..o)
		file:write(o)
	elseif type(o) == 'string' then
	--	print('string'..o)
		file:write(string.format("%q", o))
	elseif type(o) == 'table' then
	--	print_t(o)
		file:write("{\n")
		for k,v in pairs(o) do
			file:write("  [")
			serialize(file, k)
			file:write("] = ")
			serialize(file, v)
			file:write(",\n")
		end
		file:write("}\n")
	elseif type(o) == 'boolean' then
	--	print('boolean'..(o and 'true' or 'false'))
		file:write(o and 'true' or 'false')
	elseif type(o) == 'nil' then
	--	print('nil')
		file:write('nil')
	else
	--	print("error: cannot serialize a " .. type(o))
		file:write('nil')
	end
end


local function saveFile(filename, object)
	local file = io.open (filename, 'w')
	file:write('return ')
	serialize(file, object)
	file:close()
end

local function loadFile(filename)
	local f = loadfile(filename)
	return f and f() or nil
end

return {
	saveFile = saveFile,
	loadFile = loadFile,
	serialize = serialize,
	print_r = print_r,
	print_t = print_t,
	MakeCaseInsensitivePattern = MakeCaseInsensitivePattern,
}
