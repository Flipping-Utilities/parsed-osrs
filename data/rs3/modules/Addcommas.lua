--
-- Implements {{Addcommas}}
--
local libraryUtil = require('libraryUtil')
local p = {}

--
-- main function
-- keep public so it can be used in other modules
--
function p._add(arg, sep)
	libraryUtil.checkTypeMulti('Module:Addcommas._add', 1, arg, {'number', 'string'})
	libraryUtil.checkType('"Module:Addcommas"._add', 2, sep, "string", true);
    local lang = mw.language.getContentLanguage()
    
    local x;
    if type(arg) == 'number' then
    	x = lang:formatNum(arg)
    else
	    local z = tostring(arg)
	    
	    -- strip any existing commas
	    z = z:gsub(',', '')
	    
	    local y = mw.text.split(z, '[%-–]')

	    -- handle ranges as separate numbers
	    -- required by [[Module:Exchange]] (p._table)
	    if y[1] ~= '' and y[2] then
	        y[1] = tonumber(y[1])
	        y[2] = tonumber(y[2])
	        x = lang:formatNum(y[1]) .. '–' .. lang:formatNum(y[2])
	    else
	        x = lang:formatNum(tonumber(z))
	    end
    end

	if (sep) then
		x = mw.ustring.gsub(x, ",", sep);
	end
	return x;
end

--
-- strips any existing commas in the input
--
function p._strip(str)
	libraryUtil.checkType('Module:Addcommas._strip', 1, str, 'string')
    return str:gsub(',', '')
end

function p.commas(frame)
	local args = require("Module:Arguments").getArgs(frame);
    return p._add(args[1], args.sep);
end

return p