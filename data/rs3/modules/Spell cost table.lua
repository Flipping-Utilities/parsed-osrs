-- <pre>

local p = {}
require('Module:Mw.html extension')
local gep = require('Module:Exchange')._price
local coins = require('Module:Coins')._amount
local yn = require('Module:Yesno')
local pt = require('Module:Paramtest')

local combo_runes = {
	['mist rune'] = { 'air rune', 'water rune' },
	['dust rune'] = { 'air rune', 'earth rune' },
	['smoke rune'] = { 'air rune', 'fire rune' },
	['mud rune'] = { 'water rune', 'earth rune' },
	['steam rune'] = { 'water rune', 'fire rune' },
	['lava rune'] = { 'earth rune', 'fire rune' }
}

local staffs = {
	['staff of air'] = { 'air rune' },
	['armadyl battlestaff'] = { 'air rune' },
	['staff of water'] = { 'water rune' },
	['staff of earth'] = { 'earth rune' },
	['staff of fire'] = { 'fire rune' },
	['avernic of frost'] = { 'air rune', 'water rune' },
	['mud battlestaff'] = { 'water rune', 'earth rune' },
	['Mudborne staff'] = { 'water rune', 'earth rune' },
	['steam battlestaff'] = { 'water rune', 'fire rune' },
	['lava battlestaff'] = { 'earth rune', 'fire rune' },
	['mystical staff'] = {'water rune', 'earth rune', 'fire rune'},
	['elemental battlestaff'] = { 'air rune', 'water rune', 'earth rune', 'fire rune'},
	['nature staff'] = { 'nature rune' },
	['law staff'] = { 'law rune' },

}

local percentage_saved = {
    ['staff of air'] = 1,
	['armadyl battlestaff'] = 1,
	['staff of water'] = 1,
	['staff of earth'] = 1,
	['staff of fire'] = 1,
	['avernic of frost'] = 1,
	['mud battlestaff'] = 1,
	['Mudborne staff'] = 1,
	['steam battlestaff'] = 1,
	['lava battlestaff'] = 1,
	['mystical staff'] = 1,
	['elemental battlestaff'] = 1,
	['nature staff'] = 0.1,
	['law staff'] = 0.1,

}

local non_rune_items = {
	['unpowered orb'] = true,
	['banana'] = true,
	['soft clay'] = true,
	['polypore spore'] = true,
}

function p.main(frame)
	local args = frame:getParent().args
	local runes = {}
	for i=1,10 do
		if not args['Rune'..i] then
			break
		end
		
		local rune = string.lower(args['Rune'..i])
		
		if not non_rune_items[rune] then
		    rune = rune..' rune'
		end
		    
		local num = tonumber(args['Rune'..i..'num'] or 1)
		table.insert(runes,{rune,num})
	end
	local no_staff = args.nostaff ~= nil
	local show_profit = yn(args.tablet)
	local sold_name = pt.default_to(args.sold_name, mw.title.getCurrentTitle().subpageText)

	return p._main(runes,no_staff,show_profit,sold_name)
end

function p._main(runes,no_staff,show_profit,sold_name)
	local cols = show_profit and 3 or 2
	local ret = mw.html.create('table')
					:addClass('wikitable inventory-image')
					:tag('tr')
						:tag('th')
							:wikitext('Input')
						:done()
						:tag('th')
							:wikitext('Cost')
						:done()
						:IF(show_profit)
							:tag('th')
								:wikitext('Profit')
							:done()
						:END()
					:done()
					:tag('tr')
						:tag('td')
							:wikitext(make_pics(runes))
						:done()
						:tag('td')
							:wikitext(coins(total_price(runes)))
						:done()
						:IF(show_profit)
							:tag('td')
								:wikitext(show_profit and (coins(gep(sold_name)-total_price(runes))))
							:done()
						:END()
					:done()

	local combos_used = {}
	local staffs_used = {}
	for i, v in pairs(combo_runes) do
		local amtused = 0
		local tblcopy = copytbl(runes)
		for _, w in ipairs(v) do
			for j, x in ipairs(tblcopy) do
				if w == x[1] then
					table.remove(tblcopy,j)
					if x[2] > amtused then
						amtused = x[2]
					end
				end
			end
		end
		if amtused > 0 then
			table.insert(tblcopy,1,{i, amtused})
			table.insert(combos_used,tblcopy)
		end
	end
	if #combos_used > 0 then
		ret:tag('tr')
			:tag('th')
				:attr('colspan',cols)
				:wikitext('Combo runes')
			:done()
		:done()
		for _, v in ipairs(combos_used) do
			ret:tag('tr')
				:tag('td')
					:wikitext(make_pics(v))
				:done()
				:tag('td')
					:wikitext(coins(total_price(v)))
				:done()
				:IF(show_profit)
					:tag('td')
						:wikitext(show_profit and (coins(gep(sold_name)-total_price(v))))
					:done()
				:END()
			:done()
		end
	end

	for i, v in pairs(staffs) do
		local isused = false
		local tblcopy = copytbl(runes)
		for _, w in ipairs(v) do
			for j, x in ipairs(tblcopy) do
				if w == x[1] then
				    isused = true
				    if percentage_saved[i] == 1 then
					    table.remove(tblcopy,j)
					else
					    new_amnt = tblcopy[j][2] * (1 - (percentage_saved[i] or 0))
					   tblcopy[j] = { tblcopy[j][1], new_amnt }
					end
				end
			end
		end
		if isused then
			table.insert(tblcopy,{i, 0})
			table.insert(staffs_used,tblcopy)
		end
	end

	if #staffs_used > 0 and not no_staff then
		ret:tag('tr')
			:tag('th')
				:attr('colspan',cols)
				:wikitext('[[Elemental staves|Staves]]')
			:done()
		:done()
		for _, v in ipairs(staffs_used) do
			ret:tag('tr')
				:tag('td')
					:wikitext(make_pics(v))
				:done()
				:tag('td')
					:wikitext(coins(total_price(v)))
				:done()
				:IF(show_profit)
					:tag('td')
						:wikitext(show_profit and (coins(gep(sold_name)-total_price(v))))
					:done()
				:END()
			:done()
		end
	end
	return ret
end

function copytbl(tbl)
	local ret = {}
	for _, v in ipairs(tbl) do
		table.insert(ret,v)
	end
	return ret
end

function make_pics(runes)
	local ret = {}
	for _, v in ipairs(runes) do
		if v[1] == 'avernic of frost' then
			table.insert(ret,'[[File:Avernic wand.png|link=Avernic wand]]')
			table.insert(ret,'[[File:Tome of frost.png|link=Tome of frost]]')
		elseif v[1] == 'mystical staff' then
			table.insert(ret,'[[File:Mystical staff (75).png|link=Mystical staff]]')
		else
			if v[2] > 0 then
				table.insert(ret,'<sup>'..v[2]..'</sup>')
			end
			table.insert(ret,'[[File:'..v[1]..'.png|link='..v[1]..']]')
		end
	end
	return table.concat(ret)
end

function total_price(runes)
	local ret = 0
	for _, v in ipairs(runes) do
		if v[2] > 0 then
			ret = ret + gep(v[1]) * v[2]
		end
	end
	return ret
end

return p