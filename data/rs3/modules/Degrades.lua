
local paramtest = require('Module:Paramtest')
local curr = require('Module:Currency')._amount
local exg  = require('Module:ExchangeLite').price
local hc = paramtest.has_content
local lang = mw.getContentLanguage()
local unknown_str =  "''unknown <sup>(please provide data!)</sup>''"

local p = {}

local function fnum(n)
	if n == unknown_str then
		return n
	end
	return lang:formatNum(n)
end

local function nocoins(n)
	if hc(n) then
		return curr(n, 'nocoinsc')
	end
	return "''bad argument to ''cost'' parameter''"
end

local msreworkdata = {
	bars = {
		['full helm'] = 2,
		['helm'] = 1,
		['platelegs'] = 3,
		['plateskirt'] = 3,
		['platebody'] = 5,
		['chainbody'] = 3,
		['square shield'] = 2,
		['bane square shield'] = 3,
		['kiteshield'] = 3,
		['round shield'] = 3,
		['armoured boots'] = 1,
		['gauntlets'] = 1,
		['dagger'] = 1,
		['mace'] = 1,
		['sword'] = 1,
		['scimitar'] = 2,
		['longsword'] = 2,
		['warhammer'] = 3,
		['battleaxe'] = 3,
		['claws'] = 1,
		['two hand sword'] = 3,
		['two hand greataxe'] = 3,
		['two hand warhammer'] = 3,
		['2h sword'] = 3,
		['2h greataxe'] = 3,
		['2h warhammer'] = 3,
		['hatchet'] = 1,
		['throwing axe'] = 1,
		['pickaxe'] = 2,
	},
	metals = {
		['necronium'] = 'necronium bar',
		['bane'] = 'bane bar',
		['elder'] = 'elder rune bar',
		['primal'] = 'primal bar',
	}
}
local function getmsrework(exinfo)
	local item
	if hc(exinfo) then
		item = exinfo
	else
		item = mw.title.getCurrentTitle().text
	end
	item = item:lower()
	local base = 0
	for k,v in pairs(msreworkdata.bars) do
		if item:find(k) then
			base = math.max(base, v)
		end
	end
	local plus = 0
	if item:find(' %+ %d') then
		plus = tonumber(item:sub(-1))
	end
	local bars = base * math.pow(2, math.max(0, plus-1))
	
	local baritem = msreworkdata.metals[mw.text.split(item, ' ')[1]]
	local plural = ''
	if bars > 1 then
		plural = 's'
	end
	local noerr, cost = pcall(exg, lang:ucfirst(baritem))
	if not noerr or cost == nil then
		cost = -1
	end
	if cost > 0 then
		return string.format('%s [[%s]]%s (%s)', bars, baritem, plural, nocoins(cost * bars))
	else
		return string.format('%s [[%s]]%s', bars, baritem, plural)
	end
end

local types = {
	broken = { c = nocoins, t = 'This item degrades to a broken, repairable state over %s [[Equipment degradation|charges of combat]]. The base repair cost is %s for a full repair, which is scaled to how damaged it is. It can be repaired by a [[Equipment degradation#Repair NPC|character capable of repairing equipment]], or for less on an [[armour repair stand]] or [[whetstone (device)|whetstone]].' },
	dust = { c = tostring, t = 'This item degrades to dust over %s [[Equipment degradation|charges of combat]]. It cannot be repaired.'} ,
	dyed = { c = tostring, t = 'This item degrades to a broken, repairable state over %s [[Equipment degradation|charges of combat]]. It can be repaired using %s.' },
	masterwork = { c = tostring,  t = 'This item degrades to a broken, repairable state over %s [[Equipment degradation|charges of combat]]. It can be repaired with an unused and untrimmed %s, consuming the item.' },
	masterwork2 = { c = tostring,  t = 'This item degrades to a broken, repairable state over %s [[Equipment degradation|charges of combat]]. It can be repaired with %s, consuming the item.' }
}

local extras = {
	msrework = { c = getmsrework, t = 'Alternatively, it can be repaired on an [[anvil]], which costs %s and some time to reforge (both time and bar cost are scaled to lost charges).' },
}

function p.main(frame)
	return p._main(frame:getParent().args)
end
function p._main(args)
	local ret = {}
	local charges = tonumber(args.charges)
	local dtype = args.type
	local cost = args.cost
	local extra = args.extra
	local extrainfo = args.extrainfo
	if not hc(charges) then
		if hc(args.charges) and  args.charges:lower() == 'unknown' then
			charges = unknown_str
		else
			return "Please specify the ''charges'' parameter (as a number)"
		end
	end
	if not hc(dtype) then
		return "Please specify the ''type'' parameter"
	else
		dtype = dtype:lower()
		if not types[dtype] then
			return "Unsupported ''type'' parameter: "+t
		end
	end
	local info = types[dtype]
	
	local s = {
		info.t:format(fnum(charges), info.c(cost))
	}
	
	if hc(extra) then
		local exdata = extras[extra:lower()]
		if exdata then
			extra = exdata.t:format(exdata.c(extrainfo))
		end
		table.insert(s, extra)
	end
	
	return table.concat(s, ' ')
	
end
return p