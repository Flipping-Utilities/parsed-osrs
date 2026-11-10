local sf = require('Module:Round').sigfig

local p = {}
function p.main(frame)
	return p._main(frame:getParent())
end
function p._main(frame)
	return p.sf(frame.args)
end
function p.sf(args)
	local v = args[1]
	v = v:gsub(' ', '')
	local m = v:match('(%d+%.?%d*)/1,?000')
	m = tonumber(m)
	if not m then
		return args[1]
	end
	return sf(m, 3)..'/1000'
end
return p