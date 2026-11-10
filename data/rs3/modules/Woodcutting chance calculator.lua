local utils = require( 'Module:SkillUtils' )
local trees = mw.loadData('Module:SkillUtils/TreeData')
local hatchets, woodcutting_mult
do
	local _hatchet_data = mw.loadData('Module:SkillUtils/HatchetData')
	hatchets = _hatchet_data.hatchets
	woodcutting_mult = _hatchet_data.mult
end
local geprices = mw.loadJsonData('Module:GEPrices/data.json')
local yn = require('Module:Yesno')
local pt = require('Module:Paramtest')
local round = require("Module:Round").round
local lang = mw.getContentLanguage()
require("Module:Mw.html extension")

local p = {}

local function plink(link, image, text)
	_text = text
	_image = image
	if text == nil then
		_text = link
	end
	if image == nil then
		_image = link
	end
	return string.format('[[File:%s.png|link=%s]] [[%s|%s]]', _image, link, link, _text)
end

local function multifloor(x, m)
	local _x = x
	for i,v in ipairs(m) do
		_x = math.floor( _x * v )
	end
	return _x
end

local function gep(x)
	return geprices[x] or 0
end

local function fnum(num, dp)
	local ret = math.pow(10, dp) * num + 0.5
	ret = math.floor(ret)
	ret = math.pow(10, -dp) * ret
	return lang:formatNum(ret)
end

function perc(x)
	return round(x * 100, 1) .. "%"
end

function p.makeFellTable()
	local t = mw.html.create('table')
	t:addClass('wikitable sortable sticky-header mw-collapsible mw-collapsed align-right-2 align-right-3')
		:tag('caption'):wikitext('Tree fell chances'):done()
		:tr()
			:th('Tree')
			:th('Fell chance<br>(x/256)')
			:th('Percentage')
	
	for i,v in ipairs(trees) do
		if v.fell ~= nil and v.fell ~= -1 then
			t:tr()
				:td('[['..v.name..']]')
				:td(v.fell)
				:td(perc(v.fell/256))
		end
	end
	return t
end

function p.makeSimpleTable()
	local col2 = {"colspan", 2}
	local t = mw.html.create('table')
		:addClass('wikitable sortable sticky-header mw-collapsible mw-collapsed text-align-right align-center-1 align-left-2 align-center-3')
		:tag('caption'):wikitext('Tree high and low chances'):done()
		:tr()
			:th{'Order', attr={'rowspan', 2}}
			:th{'Tree<br>Logs', attr={'rowspan', 2}}
			:th{'Level', attr={'rowspan', 2}}
			:th{'Base XP', attr={'rowspan', 2}}
			:th{'Fell chance<br>(x/256)', attr={'rowspan', 2}}
	
	local hatchetrow = t:done() -- grab the parent tr() to the th{}'s above
	local hlrow = t:tr()
	for _, hatchet in ipairs(hatchets) do
		local linkstr = string.format('[[File:%s|link=%s]] [[%s|%s]]', hatchet.image, hatchet.label, hatchet.label, hatchet.label)
		hatchetrow:th{linkstr, attr=col2}
		hlrow:th("Low"):th("High")
	end

	for i, tree in ipairs(trees) do
		local namecell = '[['..tree.name..']]'
		if tree.logs then
			namecell = namecell..'<br>'..plink(tree.logs)
		end
		local fellchance = tree.fell
		if fellchance == -1 then
			fellchance = nil
		end
		
		local tr = t:tr()
		tr
			:td(i)
			:td(namecell)
			:td(tree.level)
			:td(tree.xp)
			:IF(not fellchance):na():ELSE():td(fellchance):END()

		for _, hatchet in ipairs(hatchets) do
			local low, high = utils.woodcutting_low_high(tree.chance, hatchet.power, tree.ratio)
			tr
				:td(low)
				:td(high)
		end
	end
	
	return t:allDone()
end


function p.calculator(frame)
	return p._calculator(frame:getParent().args)
end

local multipliers_list = {
	skillchompa = {
		cobalt = 1.01,
		viridian = 1.02,
		azure = 1.03,
		crimson = 1.04,
		crystal = 1.05
	},
	outfit = {
		sentinel = 1.05,
		["nature's sentinel"] = 1.07,
		["nature&#039;s sentinel"] = 1.07
	},
	offhand = 1.06,
	ring = 1.03,
	idol = 1.1,
	menaphos = 1.1,
	familiar = {
		['beaver'] = 2
	},
	crystallise = {
		None = 1,
		Crystallise = 1.2,
		["Crystallise and Light Form"] = 1.4
	},
	offhand_log = 0.2,
	juju_log = 0.05
}

function p._calculator(args)
	local level = tonumber(args.level) or 99
	local spots = {}
	local spots_order = {}
	
	-- setup multipliers
	local hi_multipliers = {}
	local lo_multipliers = {}
	local xp_multipliers = {}
	
	local arg_hatchet = string.gsub(string.lower(args.hatchet or ''), '%s', '_')
	local hatchet = {}
	local in_hatchets = false
	for _, hatchet_ in ipairs(hatchets) do
		if arg_hatchet == hatchet_.short then
			in_hatchets = true
			hatchet = hatchet_
		end
	end
	if not in_hatchets then
		hatchet = hatchets[1]
	end
	
	-- if table.insert(t, nil) is a noop
	for _, v in ipairs({ 'skillchompa', 'outfit'}) do
		if pt.has_content(args[v]) then
			table.insert(hi_multipliers, multipliers_list[v][string.lower(args[v])])
		end
	end
	for _, v in ipairs({'ring', 'idol', 'offhand'}) do
		if yn(args[v]) then
			table.insert(hi_multipliers, multipliers_list[v])
		end
	end
	
	-- only applies to menaphos fish
	local menaphos = {}
	if yn(args.menaphos) then
		menaphos = { multipliers_list.menaphos }
	end
	
	-- both hi and low
	local _h = tonumber(args.honed) or 0
	local honed = 0
	if hatchet.augmentable and _h > 0 then
		honed = 1 + 0.02 * _h
		if yn(args.level20) then
			honed = 1 + 0.022 * _h
		end
	end
	
	-- familiar is special
	local familiar = 0
	if pt.has_content(args.familiar) then
		familiar = multipliers_list.familiar[string.lower(args.familiar)] or 0
	end
	
	-- multiple log chance
	local log_multi = 1
	if yn(args.offhand) then
		log_multi = log_multi + multipliers_list.offhand_log
	end
	if yn(args.juju) then
		log_multi = log_multi + multipliers_list.juju_log
	end
	
	-- !!! NEW: Cadantine incense sticks logic !!!
	-- Gives a 2.5% chance per potency level to not deplete a tree.
	-- We'll approximate this by giving a flat bonus to logs/hr, 
	-- since you spend less time running between trees.
	if pt.has_content(args.cadantine) and args.cadantine ~= "None" then
		local cadantine_pot = tonumber(args.cadantine) or 0
		-- 0.025 (2.5%) extra logs simulated per potency level
		log_multi = log_multi + (0.025 * cadantine_pot)
	end

	-- filter into spot-groupings of the relevant things based on level
	for _, v in ipairs(trees) do
		local addSpot = level >= v.level
		if addSpot then
			local spotName = v.name
			table.insert(spots_order, spotName)
			spots[spotName] = v
		end
	end
	
	-- construct output table
	local ret = mw.html.create('table')
		:addClass('wikitable sortable sticky-header text-align-right align-left-1 align-left-2')
		:tr()
			:th('Tree')
			:th('Logs')
			:th("[[File:Woodcutting-icon.png|link=Woodcutting]] XP")
			:th('Success chance')
			:th('Logs/hr')
			:th('XP/hr')
			:th('GP/hr')

	local hatchet_power = hatchet.power
	if (hatchet.proficiency and level >= hatchet.proficiency.level) then
		hatchet_power = hatchet_power + hatchet.proficiency.power
	end
	
	for _, v in ipairs(spots_order) do
		local tree = spots[v]
		local tr = ret:tr()
		local delay = 4
		local totalGPH = 0
		local totalXPH = 0
		local low, high = utils.woodcutting_low_high(tree.chance, hatchet_power, tree.ratio)
		local newHi = multifloor(high, hi_multipliers)
		if tree.is_menaphos then
			newHi = multifloor(newHi, menaphos)
		end
		local newLo = multifloor(low, lo_multipliers)
		if honed > 0 then
			newHi = math.ceil( newHi * honed )
			newLo = math.ceil( newLo * honed )
		end
		if familiar > 0 then
			local fambuff = math.floor( familiar * math.floor( 10 * ( high - low ) / 98 ) / 10 )
			newHi = newHi + fambuff
			newLo = newLo + fambuff
		end
		
		-- caps chance at 100%
		local chance = math.min(utils.stat_roll(newLo, newHi, level, woodcutting_mult), 1)
		
		local lph = 6000 / delay * log_multi * chance
		totalGPH = lph * gep(tree.ge or tree.logs)
		local xp = tree.xp
		if tree.is_bgh_tree then
			xp = level
		end
		if tree.can_crystallise then
			xp = tree.xp * multipliers_list.crystallise[args.crystallise or 'None']
		end
		
		-- !!! NEW: Torstol incense sticks logic !!!
		-- Increases base XP by 0.5% per potency level
		if pt.has_content(args.torstol) and args.torstol ~= "None" then
			local torstol_pot = tonumber(args.torstol) or 0
			xp = xp * (1 + (0.005 * torstol_pot))
		end

		totalXPH = lph * xp
		
		tr:td('[['..tree.name..']]')
		if tree.logs then
			tr:td(plink(tree.logs))
		else
			tr:na()
		end
		tr
			:td(round(xp, 1))
			:td(perc(chance))
			:td(fnum(lph, 0))
			:td(round(totalXPH, 0, true))
			:td(fnum(totalGPH, 0))
	end
	
	return ret:allDone()
end

return p