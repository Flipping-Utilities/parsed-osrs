local p = {}
local commas = require('Module:Addcommas')._add

function p._main(arg, init)
	if arg == '' or arg == nil then
		return ''
	end
	-- convert init to string if it is a number, or set to '1' if it is not a (string of a) number
	init = tonumber(init) and tostring(init) or '1'
	if tonumber(arg) then
		return string.format('<span class="infobox-quantity" data-val-each="%s" data-value="%s"><span class="infobox-quantity-replace">%s</span> xp</span>', arg, init, commas(arg))
	else
		return arg
	end
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(mw.text.trim(args[1], args[2]))
end

return p