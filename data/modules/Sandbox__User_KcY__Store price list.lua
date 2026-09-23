-- Lists every shop with its sell/buy/change percentages.
-- Sources data from the storeline bucket (populated by {{StoreTableHead}}/{{StoreLine}}).
local p = {}

local FETCH_LIMIT = 5000

local function fetchAllRows()
	local rows = {}
	local offset = 0
	while true do
		local batch = bucket('storeline')
			.select(
				'sold_by',
				'store_sell_multiplier',
				'store_buy_multiplier',
				'store_delta',
				'store_notes'
			)
			.offset(offset)
			.limit(FETCH_LIMIT)
			.run()
		if not batch or #batch == 0 then
			break
		end
		for _, row in ipairs(batch) do
			rows[#rows + 1] = row
		end
		offset = offset + #batch
		if #batch < FETCH_LIMIT then
			break
		end
	end
	return rows
end

-- Dedupe to one entry per (shop, sell, buy, delta) combination.
local function buildShopTable(rows)
	local shops = {}
	local keys = {}
	for _, row in ipairs(rows) do
		local sellNum = tonumber(row.store_sell_multiplier)
		local buyNum = tonumber(row.store_buy_multiplier)
		-- Skip tables where both multipliers are the 100% default (no buy/sell
		-- data recorded, e.g. service NPCs or secondary tables).
		if sellNum ~= 1000 or buyNum ~= 1000 then
			local key = table.concat({
				row.sold_by,
				row.store_sell_multiplier,
				row.store_buy_multiplier,
				row.store_delta,
			}, '|')
			local entry = shops[key]
			if not entry then
				entry = {
					sold_by = row.sold_by,
					sell = row.store_sell_multiplier,
					buy = row.store_buy_multiplier,
					delta = row.store_delta,
					sell_sort = sellNum,
					buy_sort = buyNum,
					delta_sort = tonumber(row.store_delta),
					notes = {},
				}
				shops[key] = entry
				keys[#keys + 1] = key
			end
			local note = row.store_notes or ''
			if note ~= '' and not entry.notes[note] then
				entry.notes[note] = true
			end
		end
	end
	return shops, keys
end

local function formatNotes(entry)
	local notes = {}
	for note in pairs(entry.notes) do
		notes[#notes + 1] = note
	end
	table.sort(notes)
	if #notes == 0 then
		return ''
	end
	if #notes <= 4 then
		return table.concat(notes, '; ')
	end
	return table.concat(notes, '; ', 1, 4) .. ' (+' .. (#notes - 4) .. ' more)'
end

local function percentText(value)
	return string.format('%.1f%%', value / 10)
end

function p.main(frame)
	local rows = fetchAllRows()
	local shops, keys = buildShopTable(rows)

	table.sort(keys, function(a, b)
		local ea, eb = shops[a], shops[b]
		if ea.sold_by ~= eb.sold_by then
			return ea.sold_by < eb.sold_by
		end
		local sa, sb = ea.sell_sort or 0, eb.sell_sort or 0
		if sa ~= sb then
			return sa < sb
		end
		local ba, bb = ea.buy_sort or 0, eb.buy_sort or 0
		if ba ~= bb then
			return ba < bb
		end
		return (ea.delta_sort or 0) < (eb.delta_sort or 0)
	end)

	local t = mw.html.create('table')
		:addClass('wikitable sortable autosort=1,a align-center-2 align-center-3 align-center-4')
		:tag('tr')
			:tag('th'):wikitext('Shop'):done()
			:tag('th'):attr('data-sort-type', 'number'):wikitext('Sells at'):done()
			:tag('th'):attr('data-sort-type', 'number'):wikitext('Buys at'):done()
			:tag('th'):attr('data-sort-type', 'number'):wikitext('Change per'):done()
			:tag('th'):wikitext('Notes'):done()
		:done()

	for _, key in ipairs(keys) do
		local e = shops[key]
		local shop = e.sold_by
		if not shop:match('^%[%[') then
			shop = '[[' .. shop .. ']]'
		end
		t:tag('tr')
			:tag('td'):css('text-align', 'left'):wikitext(shop):done()
			:tag('td')
				:attr('data-sort-value', e.sell_sort or 0)
				:wikitext(e.sell_sort and percentText(e.sell_sort) or e.sell)
			:done()
			:tag('td')
				:attr('data-sort-value', e.buy_sort or 0)
				:wikitext(e.buy_sort and percentText(e.buy_sort) or e.buy)
			:done()
			:tag('td')
				:attr('data-sort-value', e.delta_sort or 0)
				:wikitext(e.delta_sort and percentText(e.delta_sort) or e.delta)
			:done()
			:tag('td'):css('text-align', 'left'):wikitext(formatNotes(e)):done()
		:done()
	end

	return tostring(t)
end

return p