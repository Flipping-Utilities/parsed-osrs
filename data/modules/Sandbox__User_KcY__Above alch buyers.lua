-- <pre>
local p = {}

local commas = require('Module:Addcommas')._add
local currencyImage = require('Module:Currency Image')

local PAGE_SIZE = 5000

local function to_int(v)
	return tonumber(v) or 0
end

local function fetch_all()
	local rows = {}
	local offset = 0
	while true do
		local page = bucket('storeline')
			.select('sold_by', 'sold_item', 'sold_item_image', 'store_buy_price', 'store_buy_multiplier', 'store_delta', 'store_currency')
			.limit(PAGE_SIZE)
			.offset(offset)
			.run()
		for _, row in ipairs(page) do
			table.insert(rows, row)
		end
		if #page < PAGE_SIZE then
			break
		end
		offset = offset + PAGE_SIZE
	end
	return rows
end

function p.main(frame)
	local args = frame.args or {}
	local coinsOnly = tostring(args.coins or 'yes'):lower() ~= 'no'
	local minPrice = tonumber(args.minprice) or 0
	local bestOnly = tostring(args.best or ''):lower() == 'yes'

	local groups = {}
	local order = {}
	for _, r in ipairs(fetch_all()) do
		local mult = to_int(r.store_buy_multiplier)
		if mult > 600 and mult < 1000 then
			local price = tonumber(r.store_buy_price)
			if price and price > 0 then
				local currency = (r.store_currency == nil or r.store_currency == '') and 'Coins' or r.store_currency
				local key = r.sold_item .. '|' .. currency .. '|' .. price .. '|' .. mult .. '|' .. to_int(r.store_delta)
				local g = groups[key]
				if not g then
					g = {
						item = r.sold_item,
						image = (r.sold_item_image and r.sold_item_image ~= '') and r.sold_item_image or ('File:' .. r.sold_item .. '.png'),
						currency = currency,
						price = price,
						mult = mult,
						delta = to_int(r.store_delta),
						shops = {},
					}
					groups[key] = g
					table.insert(order, key)
				end
				g.shops[r.sold_by] = true
			end
		end
	end

	local out = {}
	for _, key in ipairs(order) do
		table.insert(out, groups[key])
	end

	if bestOnly then
		local best = {}
		local bestOrder = {}
		for _, g in ipairs(out) do
			local cur = best[g.item]
			if not cur then
				best[g.item] = g
				table.insert(bestOrder, g)
			elseif g.mult > cur.mult or (g.mult == cur.mult and g.price > cur.price) then
				best[g.item] = g
			end
		end
		out = bestOrder
	end

	local filtered = {}
	for _, g in ipairs(out) do
		if g.price >= minPrice then
			table.insert(filtered, g)
		end
	end
	out = filtered

	table.sort(out, function(a, b)
		if a.mult ~= b.mult then return a.mult > b.mult end
		if a.price ~= b.price then return a.price > b.price end
		return a.item < b.item
	end)

	local t = mw.html.create('table')
	t:addClass('wikitable sortable above-alch')
		:attr('style', 'text-align:center;')
		:tag('tr')
			:tag('th'):attr('colspan', 2):wikitext('Item'):done()
			:tag('th'):attr('data-sort-type', 'number'):wikitext('Price bought at'):done()
			:tag('th'):wikitext('Shops'):done()
			:tag('th'):attr('data-sort-type', 'number'):wikitext('Percentage'):done()
			:tag('th'):attr('data-sort-type', 'number'):wikitext('Change per'):done()
		:done()

	for _, g in ipairs(out) do
		local shopList = {}
		for shop in pairs(g.shops) do
			table.insert(shopList, '[[' .. shop .. ']]')
		end
		table.sort(shopList)

		local price = commas(g.price)
		local img = currencyImage(g.currency, g.price)
		if img then
			price = string.format('[[File:%s|link=%s]] ', img, g.currency) .. price
		end

		local tr = t:tag('tr')
			:attr('data-item', g.item)
			:attr('data-currency', g.currency)
			:attr('data-price', g.price)
			:attr('data-mult', g.mult)
		if coinsOnly and g.currency ~= 'Coins' then
			tr:attr('style', 'display:none;')
		end
		tr:tag('td'):wikitext('[[' .. g.image .. '|link=' .. g.item .. ']]'):done()
		tr:tag('td'):css('text-align', 'left'):wikitext('[[' .. g.item .. ']]'):done()
		tr:tag('td'):attr('data-sort-value', g.price):wikitext(price):done()
		tr:tag('td'):wikitext(table.concat(shopList, ', ')):done()
		tr:tag('td'):attr('data-sort-value', g.mult):wikitext(string.format('%.1f%%', g.mult / 10)):done()
		tr:tag('td'):attr('data-sort-value', g.delta):wikitext(string.format('%.1f%%', g.delta / 10)):done()
	end

	return tostring(t)
end

return p