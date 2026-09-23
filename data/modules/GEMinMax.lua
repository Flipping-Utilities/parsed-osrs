-- <nowiki>
local prices = mw.loadJsonData('Module:GEPrices/data.json')
local _coins = require('Module:Currency')._amount
local p = {}

local fmap = {
	wikitable = 'wikitable',
	wikitablereverse = 'wikitablereverse',
	table = 'wikitable',
	t = 'wikitable',
	rtable = 'wikitablereverse',
	rt = 'wikitablereverse',
	bracket = 'bracket',
	b = 'bracket',
	backetreverse = 'backetreverse',
	rb = 'backetreverse',
	item = 'item',
	price = 'price',
	none = 'none'
}

local formats = {
	wikitable = function(i,v) return string.format('| %s\n| %s', i, v) end,
	wikitablereverse = function(i,v) return string.format('| %s\n| %s', v, i) end,
	bracket = function(i,v) return string.format('%s (%s)', i, v) end,
	backetreverse = function(i,v) return string.format('%s (%s)', v, i) end,
	item = function(i,v) return i end,
	price = function(i,v) return v end,
	none = function(i,v) return '' end
}

function findVal(comp, def, args)
	local item = '@unknown@'
	local value = def
	for i,v in ipairs(args) do
		local pr = prices[v]
		if pr then
			if comp(pr, value) then
				value = pr
				item = v
			end
		end
	end
	return item, value
end

function p._min(args)
	return findVal(function(pr,v) return v > pr  end, math.huge, args)
end
function p._max(args)
	return findVal(function(pr,v) return v < pr  end, -1, args)
end

function p.main(frame)
	local c = frame.args[1]
	local pargs = frame:getParent().args
	local f = fmap[pargs.format]
	f = formats[f] or formats.bracket
	local r1, r2 = p['_'..c](pargs)
	if pargs.coins == 'y' then
		r2 = _coins(r2, 'coins')
	elseif pargs.coins == 'n' then
		r2 = _coins(r2, 'nocoins')
	elseif pargs.coins == 'f' then
		r2 = mw.getContentLanguage():formatNum(r2)
	end
	if pargs.link == 'plp' then
		r1 = string.format('[[File:%s.png|link=%s]]', r1, r1)
	elseif pargs.link == 'p' then
		r1 = string.format('[[File:%s.png|link=%s]] [[%s]]', r1, r1, r1)
	elseif not pargs.link then
		r1 = string.format('[[%s]]', r1)
	end
	
	if pargs.var then
		mw.ext.VariablesLua.vardefine(pargs.var..'_item', r1)
		mw.ext.VariablesLua.vardefine(pargs.var..'_price', r2)
	end
	
	return f(r1, r2)
end

return p
-- </nowiki>