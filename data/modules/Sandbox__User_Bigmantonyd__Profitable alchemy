local p = {}

local prices = mw.loadJsonData('Module:GEPrices/data.json')
local values = mw.loadJsonData('Module:GEValues/data.json')
local limits = mw.loadJsonData('Module:GELimits/data.json')
local volumes = mw.loadJsonData('Module:GEVolumes/data.json')
local members = mw.loadJsonData('Module:GEMembers/data.json')

local natureRunePrice = prices['Nature rune']
local fireRunePrice = prices['Fire rune']

local commas = require('Module:Addcommas')._add
local paramTest = require('Module:Paramtest')
local yesNo = require('Module:Yesno')

local AlchemyTypes = {
	['general store'] = { cost = 0, perHour = 50000, mult = 0.1, label = "Sell price"},
	['general store single'] = { cost = 0, perHour = 300, mult = 0.6, label = "Sell price"},
	['low alch'] = { cost = natureRunePrice, perHour = 2000, mult = 0.4, label = "[[Low Alch]]"},
	['fire staff'] = { cost = natureRunePrice, perHour = 1200, mult = 0.6, label = "[[High Alch]]"},
	['no staff'] = { cost = natureRunePrice + 5 * fireRunePrice, perHour = 1200, mult = 0.6, label = "[[High Alch]]"},
}

function buildRow(item, price, alch, profit, roi, limit, volume, profitMax, profitPerMinute, membersStr, membersVal)
	local row = mw.html.create('tr')
	row:tag('td'):wikitext('[[File:' .. item .. '.png|link=' .. item .. ']]'):done()
		:tag('td'):wikitext('[[' .. item  .. ']]'):attr('data-sort-value', item):done()
		:tag('td'):wikitext(commas(price)):attr('data-sort-value', price):done()
		:tag('td'):wikitext(commas(alch)):attr('data-sort-value', alch):done()
		:tag('td'):wikitext(commas(profit)):attr('data-sort-value', profit):done()
		:tag('td'):wikitext(roi):attr('data-sort-value', roi):done()
		:tag('td'):wikitext(commas(limit)):attr('data-sort-value', limit):done()
		:tag('td'):wikitext(commas(volume)):attr('data-sort-value', volume):done()
		:tag('td'):wikitext(commas(profitMax)):attr('data-sort-value', profitMax):done()
		:tag('td'):wikitext(commas(profitPerMinute)):attr('data-sort-value', profitPerMinute):done()
		:tag('td'):wikitext(membersStr):attr('data-sort-value', tostring(membersVal)):done()
		:tag('td'):wikitext('[[Exchange:' .. item .. '|view]]'):done()
	return row
end

function createHeader(label)
	local ret = mw.html.create('table'):addClass('wikitable sortable sticky-header align-center-1 align-right-3 align-right-4 align-right-5 align-right-6 align-right-7 align-right-8 align-right-9 align-center-10 align-center-11')
	ret:tag('tr'):tag('th'):attr('colspan', '2'):wikitext('Item'):done()
		:tag('th'):wikitext('GE Price'):done()
		:tag('th'):wikitext(label):done()
		:tag('th'):wikitext('Profit'):done()
		:tag('th'):wikitext('[[wikipedia:Return on investment|ROI%]]'):done()
		:tag('th'):wikitext('[[Grand Exchange#Trade restrictions|Limit]]'):done()
		:tag('th'):wikitext('[[Grand Exchange#Volume|Volume]]'):done()
		:tag('th'):wikitext('Max profit'):done()
		:tag('th'):wikitext('Profit per Minute'):done()
		:tag('th'):wikitext('Members'):done()
		:tag('th'):wikitext('Details'):done()
	return ret
end

function sortByProfit(profitsOne, profitsTwo)
	return profitsOne[2] > profitsTwo[2]
end

function getData(costToAlch, mult, minBuyLimit, minVolume, maxItems)
	local profits = {}
	for item, price in pairs(prices) do
		if(tonumber(price)) then
			-- Include item if buy limit and volume are above the requested minimums and the item has a value
			if(((tonumber(limits[item]) or math.huge) >= minBuyLimit)
				and ((tonumber(volumes[item]) or math.huge) >= minVolume)
				and values[item]) then
				local profit = math.floor(values[item] * mult) - (price + costToAlch)
				if(profit > 0) then
					table.insert(profits, { item, profit })
				end
			end
		end
	end
	
	table.sort(profits, sortByProfit)
	while #profits > maxItems do
    	table.remove(profits)  -- Removes last element
	end
	return profits
end

function p._main(args)
	local minBuyLimit = paramTest.default_to(tonumber(args.minbuylimit), -1)
	local minVolume = paramTest.default_to(tonumber(args.minvolume), -1)
	local maxItems = paramTest.default_to(tonumber(args.maxitems), math.huge)
	local alchType = paramTest.default_to(string.lower(args.alchtype), 'fire staff')
	alchType = AlchemyTypes[alchType]
	
	data = getData(alchType.cost, alchType.mult, minBuyLimit, minVolume, maxItems)
	
	if #data == 0 then
		return '\'\'\'No items are currently profitable.\'\'\''
	end
	
	local ret = createHeader(alchType.label)
	for i, itemData in ipairs(data) do
		local item = itemData[1]
		local profit = itemData[2]
		local price = prices[item]
		local alch = math.floor(values[item] * alchType.mult)
		local limit = limits[item] or 0
		local volume = volumes[item]
		local roi = string.format('%.2f', 100 * (profit / (price + natureRunePrice))) .. '%'
		local profitMax = limit and (math.min(alchType.perHour * 4, math.floor(math.min(limit, volume / 24 * 4))) * profit) or (alchType.perHour * 4 * profit)
		local profitPerMinute = math.floor(profit * (alchType.perHour / 60))
		
		local membersStr = '?'
		if(members[item]) then
			membersStr = '[[File:Member icon.png|link=Members]]'
		elseif(not members[item]) then
			membersStr = '[[File:Free-to-play icon.png|link=Free-to-play]]'
		end
		
		ret:node(buildRow(item, price, alch, profit, roi, limit, volume, profitMax, profitPerMinute, membersStr, members[item]))
	end
	
	return ret
end

function p.main(frame)
	return p._main(frame.args)
end

return p