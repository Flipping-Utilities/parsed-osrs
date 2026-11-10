local prices = mw.loadJsonData('Module:GEPrices/data.json')
local alchprices
local limits = mw.loadJsonData('Module:GELimits/data.json')
local volumes = mw.loadJsonData('Module:GEVolumes/data.json')
local membs = mw.loadJsonData('Module:GEMembers/data.json')
local natureRune = prices['Nature rune']
local fireRune = prices['Fire rune']
local divineChargeEach = prices['Divine charge']/3000
local p = {}
local yesno = require('Module:Yesno')

function sortByProfit(a,b)
	return a[2] > b[2]
end
local lang = mw.getContentLanguage()
function fnum(x)
	return lang:formatNum(tonumber(x) or 0)
end

function p.get(m_limit, costPerAlch, mult, max_value)
	min_limit = m_limit - 1
	local profit = {}
	for k,price in pairs(prices) do
		if tonumber(price) then
			if (tonumber(limits[k]) or 5000) > min_limit and price <= max_value then
				local alch = alchprices[k] or 1
				local prof = math.max(1, math.floor(alch * mult)) - (price + costPerAlch)
				if (prof > 0) then
					table.insert(profit, { k, prof })
				end
			end
		end
	end
	table.sort(profit, sortByProfit)
	return profit
end

function p.makeTable(data, options)
	local t = mw.html.create('table')
	t:addClass('wikitable sortable sticky-header align-center-1 align-right-3 align-right-4 align-right-5 align-right-6 align-right-7 align-right-8 align-right-9 align-center-10 align-center-11')
	local tr_h = t:tag('tr')
	tr_h:tag('th'):wikitext('&nbsp;'):addClass('unsortable'):done()
		:tag('th'):wikitext('Item'):done()
		:tag('th'):wikitext('GE price'):done()
		:tag('th'):wikitext(options.alch_type.is_gen_store and 'Store price' or '[['..(options.alch_type.is_low_alch and 'Low' or 'High')..' Alch]]'):done()
		:tag('th'):wikitext('Profit'):done()
		:tag('th'):wikitext('[[wikipedia:Return on investment|ROI%]]'):done()
		:tag('th'):wikitext('[[Grand Exchange#Trade restrictions|Limit]]'):done()
		:tag('th'):wikitext('Trade volume'):done()
	if options.alch_type.is_machine then
		tr_h:tag('th'):wikitext('Max daily profit'):done()
	else
		tr_h:tag('th'):wikitext('Max profit'):done()
	end
	if not options.alch_type.hide_membs then
		tr_h:tag('th'):wikitext('Members'):done()
	end
	tr_h:tag('th'):wikitext('Details'):done()
			
	t:newline()
	for i,v in ipairs(data) do
		local tr = t:tag('tr')
		local item, price, alch, profit, limit, volume, roi, profitMax, memb, memb_str
		item = v[1]
		profit = v[2]
		price = prices[item]
		alch = alchprices[item]
		if options.alch_type.is_gen_store then
			alch = alch/2
		end
		limit = limits[item]
		volume = volumes[item]
		roi = 100 * profit / price
		roi = string.format('%.2f', roi)
		if options.alch_type.lim_adjust then
			if limit then
				profitMax = math.min(options.alch_type.per_num*4, limit) * profit
			else
				profitMax = options.alch_type.per_num*4 * profit
			end
		else
			if options.alch_type.is_machine then
				profitMax = math.min(options.alch_type.per_num, limit) * 6 * profit
			else
				profitMax = profit * options.alch_type.per_num
			end
		end
		profit = string.format('%.1f', profit)
		profitMax = string.format('%d', profitMax)
		memb = membs[item]
		if memb then
			memb_str = '[[File:P2P icon.png|20x20px|link=Members]]'
		elseif memb == false then
			memb_str = '[[File:F2P icon.png|20x20px|link=Free-to-play]]'
		else
			memb_str = '?'
		end
		
		
		tr	:tag('td'):wikitext(string.format('[[File:%s.png|link=%s]]', item, item)):done()
			:tag('td'):wikitext(string.format('[[%s]]', item)):attr('data-sort-value', item):done()
			:tag('td'):wikitext(fnum(price)):attr('data-sort-value', price):done()
			:tag('td'):wikitext(fnum(alch)):attr('data-sort-value', alch):done()
			:tag('td'):wikitext(fnum(profit)):attr('data-sort-value', profit):done()
			:tag('td'):wikitext(fnum(roi),'%'):attr('data-sort-value', roi):done()
			:tag('td'):wikitext(fnum(limit)):attr('data-sort-value', limit):done()
			:tag('td'):wikitext(fnum(volume)):attr('data-sort-value', volume):done()
			:tag('td'):wikitext(fnum(profitMax)):attr('data-sort-value', profitMax):done()
		if not options.alch_type.hide_membs then
			tr:tag('td'):wikitext(memb_str):attr('data-sort-value', tostring(memb)):done()
		end
		tr:tag('td'):wikitext('[[Exchange:',item,'|view]]'):done()
		t:newline()
	end
	local ret
	if options.intro then
		if options.alch_type.is_gen_store then
			ret = string.format( 'There are currently %s items profitable to sell to a General Store.\n%s', #data, tostring(t) )
		else
			local st2
			st2 = ''
			if options.limit > 0 then
				st2 = ', with a buy limit of at least '..fnum(options.limit)
			end
			ret = string.format( 'There are currently %s items profitable to use %s Level Alchemy on %s%s. It costs %.1f coins per alch.\n%s', #data, options.alch_type.is_low_alch and 'Low' or 'High', options.alch_type.txt, st2, options.alch_type.cost, tostring(t) )
		end
	else
		ret = t
	end
	return ret
end

function p.test()
	return p.makeTable(p.get(1000, 0))
end

function p.main(frame)
	return p._main(frame:getParent().args)
end

function p.inv_main(frame)
	return p._main(frame.args)
end

local alch_type_map = {
	['general store'] = { -4, txt='', cost=0, per_num=50000, lim_adjust=true, is_gen_store=true},
	['low alch'] = { -3, txt='with a fire staff', cost=natureRune, per_num=2000, lim_adjust=true, is_low_alch=true},
	['low alch explorers ring'] = { -3, txt='with an explorers ring', cost=0, per_num=30, lim_adjust=false, is_low_alch=true},
	['fire staff'] = {0, txt='with a fire staff', cost=natureRune, per_num=1200, lim_adjust=true},
	['no staff'] = {-2, txt='without a staff', cost=natureRune+5*fireRune, per_num=1200, lim_adjust=true},
	['nature staff'] = {-1, txt='with a nature staff', cost=natureRune*0.9+5*fireRune, per_num=1200, lim_adjust=true},
	['alchemiser machine'] = {1, txt='with an alchemiser machine', cost=natureRune+5*fireRune+divineChargeEach*5.6, per_num=32, is_machine=true, hide_membs=true},
	['alchemiser mk. ii machine'] = {2, txt='with an alchemiser mk. II machine', cost=natureRune+divineChargeEach*6, per_num=100, is_machine=true, hide_membs=true}
}

function p._main(args)
	local limit = tonumber(args.limit) or 0
	local alchtype = alch_type_map[string.lower(tostring(args.alchtype))] or alch_type_map['fire staff']
	local intro = not yesno(args.hideintro)
	local mult = 1
	local max_value = tonumber(args.max_value) or math.huge
	if alchtype.is_low_alch then
		alchprices = mw.loadJsonData('Module:GELowAlchs/data.json')
	elseif alchtype.is_gen_store then
		alchprices = mw.loadJsonData('Module:GEHighAlchs/data.json')
		mult = 0.5
	else
		alchprices = mw.loadJsonData('Module:GEHighAlchs/data.json')
	end
	if alchtype.is_machine then
		max_value = 500000
	end
	return p.makeTable(p.get(limit, alchtype.cost, mult, max_value), { intro = intro, limit = limit, alch_type = alchtype, max_value = max_value })
end

return p