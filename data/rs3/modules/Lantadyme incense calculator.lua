
local pcost = require('Module:Potion price')._main
local exg = mw.loadJsonData('Module:GEPrices/data.json')
local curr = require('Module:Currency')._coins

local p = {}

local incense_each = exg['Lantadyme incense sticks']

local function potioncost(pot, dose, options)
	local exg_name = pot..' ('..dose..')'
	if exg[exg_name] then
		return exg[exg_name]
	end
	options[1] = pot
	return pcost(options)
end
local function coinstd(tr, x)
	x = math.floor(x+0.5)
	tr:tag('td'):attr('data-sort-value', x):wikitext(curr(x))
end

local function plinkp(pot, dose)
	return string.format('[[File:%s (%s).png|link=%s#(%s)]]', pot, dose, pot, dose)
end
local function plink(pot, dose)
	return string.format('%s [[%s#(%s)|%s]]', plinkp(pot,dose), pot, dose, pot)
end

local data = {
	['Weapon poison+++'] = 4,
	['Spirit attraction potion'] = 4,	
	['Aggression potion'] = 4,
	['Overload'] = 4,
	['Super prayer renewal potion'] = 6,
	['Holy overload potion'] = 6,
	['Searing overload potion'] = 6,
	['Aggroverload'] = 6,
	['Holy aggroverload'] = 6,
	['Supreme overload potion'] = 6,
	['Elder overload potion'] = 6,
	['Supreme overload salve'] = 6,
	['Elder overload salve'] = 6,
	['Spirit attraction flask'] = 6,
	['Weapon poison+++ flask'] = 6,
	['Aggression flask'] = 6,
}
local duration_data = {
	['Weapon poison+++'] = 12,
	['Weapon poison+++ flask'] = 12,
	_default = 6
}

local rows = {
	-- singles
	{ 'Weapon poison+++' },
	{ 'Spirit attraction potion' },
	{ 'Aggression potion' },
	{ 'Overload' },
	{ 'Super prayer renewal potion' },
	{ 'Holy overload potion' },
	{ 'Searing overload potion' },
	{ 'Aggroverload' },
	{ 'Holy aggroverload' },
	{ 'Supreme overload potion' },
	{ 'Elder overload potion' },
	{ 'Supreme overload salve' },
	{ 'Elder overload salve' },
	{ 'Spirit attraction flask' },
	{ 'Weapon poison+++ flask' },
	{ 'Aggression flask' },
	-- sets
	{ 'Super prayer renewal potion', 'Supreme overload potion' },
	{ 'Super prayer renewal potion', 'Elder overload potion' },
	{ 'Supreme overload potion', 'Weapon poison+++' },
	{ 'Elder overload potion', 'Weapon poison+++' },
	{ 'Supreme overload salve', 'Weapon poison+++' },
	{ 'Elder overload salve', 'Weapon poison+++' },
	{ 'Aggression potion', 'Holy overload potion' },
	{ 'Aggression potion', 'Holy overload potion', 'Weapon poison+++' },
	{ 'Aggression potion', 'Supreme overload potion' },
	{ 'Aggression potion', 'Supreme overload potion', 'Weapon poison+++' },
	{ 'Aggression potion', 'Elder overload potion' },
	{ 'Aggression potion', 'Elder overload potion', 'Weapon poison+++' },
	{ 'Aggression potion', 'Supreme overload salve' },
	{ 'Aggression potion', 'Supreme overload salve', 'Weapon poison+++' },
	{ 'Aggression potion', 'Elder overload salve' },
	{ 'Aggression potion', 'Elder overload salve', 'Weapon poison+++' },
	{ 'Aggroverload', 'Super prayer renewal potion' },
	{ 'Aggroverload', 'Super prayer renewal potion', 'Weapon poison+++' },
	{ 'Holy aggroverload', 'Weapon poison+++' },
	{ 'Holy aggroverload', 'Spirit attraction potion' },
	{ 'Elder overload potion', 'Aggression flask', 'Weapon poison+++ flask' },
	{ 'Elder overload salve', 'Aggression potion', 'Spirit attraction potion' },
	{ 'Elder overload salve', 'Aggression potion', 'Spirit attraction potion', 'Weapon poison+++' },
	{ 'Elder overload salve', 'Aggression flask', 'Spirit attraction flask' },
	{ 'Elder overload salve', 'Aggression flask', 'Weapon poison+++ flask' },
	{ 'Elder overload salve', 'Aggression flask', 'Spirit attraction flask', 'Weapon poison+++ flask' },
	{ 'Elder overload salve', 'Spirit attraction flask', 'Weapon poison+++ flask' },
}


local doses_first_hour = {}
local doses_per_hour = {}
local normal_doses_per_hour = {}
-- calculate doses per hour
for pot,dur in pairs(duration_data) do
	if not doses_first_hour[dur] then
		-- when the duration is constant we can just do a simple divide
		doses_per_hour[dur] = 60 / (dur+2)
		normal_doses_per_hour[dur] = 60/dur

		-- varying time due to increasing potency, so we do a looping thing
		local doses_consumed = 0
		local time_elapsed = 0
		local dose_time_left = dur+0.5
		for i=0.5,60,0.5 do
			local potency = math.min(4, math.max(1, math.floor(i / 10)+1))
			dose_time_left = dose_time_left - 0.5
			if dose_time_left == 0 then
				doses_consumed = doses_consumed + 1
				dose_time_left = dur + potency * 0.5
			end
			--mw.log(string.format('after %2.1f: p%s - %s doses, %2.1fm left', i,potency,doses_consumed,dose_time_left))
		end
		doses_consumed = doses_consumed + 1 - dose_time_left/(dur+2)
		doses_first_hour[dur] = doses_consumed
	end
end


function p.main(frame)
	local pcost_opts = frame.args --potential todo, if more calc-only args are added
	
	local out = mw.html.create('table')
	out:addClass('wikitable sortable')
		:tag('tr')
			:tag('th'):wikitext('Potion'):done()
			:tag('th'):wikitext('No incense'):done()
			:tag('th'):wikitext('First hour'):done()
			:tag('th'):wikitext('Overloaded hour'):done()
			:tag('th'):wikitext('Subsequent hour'):done()
			:tag('th'):wikitext('Savings'):done()
		:done():newline()

	for i,v in ipairs(rows) do
		local txt, func, totals_per_hour, dur, dose, pc
		if #v > 1 then
			func = plinkp
		else
			func = plink
		end
		txt = {}
		totals_per_hour = {no=0, first=0, ong=0}
		for j,k in ipairs(v) do
			dur = duration_data[k] or duration_data._default
			dose = data[k]
			pc = potioncost(k, dose, pcost_opts)
			table.insert(txt, func(k, dose))
			totals_per_hour.no = totals_per_hour.no + pc * normal_doses_per_hour[dur] / dose
			totals_per_hour.first = totals_per_hour.first + pc * doses_first_hour[dur] / dose
			totals_per_hour.ong = totals_per_hour.ong + pc * doses_per_hour[dur] / dose
		end

		local tr = out:tag('tr')
		tr:tag('td'):wikitext(table.concat(txt, ' + ')):done()
		coinstd(tr, totals_per_hour.no)
		coinstd(tr, totals_per_hour.first + incense_each*6)
		coinstd(tr, totals_per_hour.ong + incense_each*11)
		coinstd(tr, totals_per_hour.ong + incense_each*6)
		coinstd(tr, totals_per_hour.no - totals_per_hour.ong - incense_each*6)
		out:newline()
	end
	return out
end


return p