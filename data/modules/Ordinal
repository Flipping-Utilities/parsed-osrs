local p = {}
local lang = mw.getContentLanguage()
local hc = require('Module:Paramtest').has_content

p._ordinals = {
	[0] = 'th',
	'st',
	'nd',
	'rd',
	'th',
	'th', --5
	'th',
	'th',
	'th',
	'th',
	'th', --10
	
	-- special exceptions
	'th', --11th
	'th', --12th
	'th', --13th
}

p._text = {
	[0] = 'zeroth',
	'first',
	'second',
	'third',
	'fourth',
	'fifth',
	'sixth',
	'seventh',
	'eighth',
	'ninth',
	'tenth',
	'eleventh',
	'twelfth',
	'thirteenth',
	'fourteenth',
	'fifteenth',
	'sixteenth',
	'seventeenth',
	'eighteenth',
	'nineteenth',
	'twentieth'
}

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args[1], {txt = hc(args.text), caps = hc(args.caps)})
end

function p._main(ord, opts)
	ord = lang:parseFormattedNumber(ord)
	if not ord then
		ord = 1
	end
	ord = math.floor(ord)
	if opts.txt then
		if p._text[ord] then
			if opts.caps then
				return lang:ucfirst(p._text[ord])
			else
				return p._text[ord]
			end
		end
		-- if not txt then just do the normal number stuff
	end
	
	local suff
	local ord_digit = ord % 10
	if ord_digit == 1 or ord_digit == 2 or ord_digit == 3 then
		suff = p._ordinals[ord % 100] or p._ordinals[ord_digit]
	else
		suff = p._ordinals[ord_digit]
	end
	if not opts.nosup then
		suff = '<sup>'..suff..'</sup>'
	end
	if opts.nonum then
		return suff
	end
	return lang:formatNum(ord) .. suff
end

return p