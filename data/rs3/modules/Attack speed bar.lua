-- <nowiki>
-- Implements [[Template:Attack speed bar]]

local p = {}

local hasc = require('Module:Paramtest').has_content

local interval = {
	-- Universal
	['random'] = {'Random','???'},

	-- Weapons
	['fastest'] = {'Fastest','2.4'},
	['fast'] = {'Fast','3.0'},
	['average'] = {'Average','3.6'},
	['slow'] = {'Slow','4.2'},
	['slowest'] = {'Slowest','7.2'},

	-- Monsters, weapons, misc
	['1'] = {'1 tick','0.6'},
	['2'] = {'2 ticks','1.2'},
	['3'] = {'3 ticks','1.8'},
	['4'] = {'4 ticks','2.4'},
	['5'] = {'5 ticks','3.0'},
	['6'] = {'6 ticks','3.6'},
	['7'] = {'7 ticks','4.2'},
	['8'] = {'8 ticks','4.8'},
	['9'] = {'9 ticks','5.4'},
	['10'] = {'10 ticks','6.0'},
	['11'] = {'11 ticks','6.6'},
	['12'] = {'12 ticks','7.2'}
}

local function render(args)
	local speed,kind
	if hasc(args.speed) and hasc(args.kind) then
		speed = mw.text.trim(tostring(args.speed)):lower()
		kind = mw.text.trim(tostring(args.kind)):lower()
	end

	local ret = mw.html.create('span'):addClass('attack-speed')
	if interval[speed] ~= nil then
		ret	:addClass(kind)

		if kind == 'monster' and speed ~= 'random' then
			ret	:addClass('t' .. speed)
		elseif kind == 'weapon' or kind == 'monster' then
			local speed_class_prefix = ''
			if kind == 'weapon' and tonumber(speed) then
				speed_class_prefix = 'ticks-'
			end
			ret :addClass(speed_class_prefix .. speed)
		end

		ret	:tag('div')
				:wikitext(interval[speed][1] .. ' ')
				:tag('small')
					:wikitext('(' .. interval[speed][2] .. 's)')
				:done()
			:done()
	else
		ret	:wikitext('Undefined')
	end
	ret	:tag('b'):addClass(''):done()
		:done()

	return ret
end

function p.main(frame)
	return render(frame:getParent().args)
end

function p.weapon(s)
	return render({ kind='weapon', speed=s })
end

function p.monster(s)
	return render({ kind='monster', speed=s })
end

return p