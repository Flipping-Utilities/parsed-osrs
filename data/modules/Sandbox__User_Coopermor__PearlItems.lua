require('strict')

local p = {}

local pearlRanges = {
	{
		name = 'Tiny pearl',
		min = 0,
		max = 199,
	},
	{
		name = 'Small pearl',
		min = 200,
		max = 999,
	},
	{
		name = 'Shiny pearl',
		min = 1000,
		max = 1999,
	},
	{
		name = 'Bright pearl',
		min = 2000,
		max = 4999,
	},
	{
		name = 'Big pearl',
		min = 5000,
		max = 9999,
	},
	{
		name = 'Huge pearl',
		min = 10000,
		max = 19999,
	},
	{
		name = 'Enormous pearl',
		min = 20000,
		max = 49999,
	},
	{
		name = 'Shimmering pearl',
		min = 50000,
		max = 99999,
	},
	{
		name = 'Glistening pearl',
		min = 100000,
		max = 199999,
	},
	{
		name = 'Brilliant pearl',
		min = 200000,
		max = 499999,
	},
	{
		name = 'Radiant pearl',
		min = 500000,
		max = nil,
	},
}

local function getItemsForPearl(pearl)
	local query = bucket('infobox_item')
		.select(
			'page_name_sub',
			'item_name',
			'high_alchemy_value'
		)

	if pearl.max then
		query = query.where(
			{'high_alchemy_value', '>=', pearl.min},
			{'high_alchemy_value', '<=', pearl.max}
		)
	else
		query = query.where(
			{'high_alchemy_value', '>=', pearl.min}
		)
	end

	return query
		.limit(5000)
		.run()
end

local function formatNumber(value)
	return mw.language.getContentLanguage():formatNum(value)
end

function p.main(frame)
	local output = {}

	for _, pearl in ipairs(pearlRanges) do
		local items = getItemsForPearl(pearl)

		table.sort(items, function(a, b)
			local aValue = tonumber(a.high_alchemy_value) or 0
			local bValue = tonumber(b.high_alchemy_value) or 0

			if aValue == bValue then
				return (a.item_name or '') < (b.item_name or '')
			end

			return aValue < bValue
		end)

		table.insert(output, '== [[' .. pearl.name .. ']] ==')
		table.insert(output, '{| class="wikitable sortable"')
		table.insert(output, '! Item')
		table.insert(output, '! High alchemy')

		for _, item in ipairs(items) do
			local name = item.item_name
			local value = tonumber(item.high_alchemy_value)

			if name and value then
				local pageName = item.page_name_sub or name
				table.insert(output, '|-')
				table.insert(output, '| [[' .. pageName .. '|' .. name .. ']]')
				table.insert(
					output,
					'| data-sort-value="' .. value .. '" | ' ..
					formatNumber(value)
				)
			end
		end

		table.insert(output, '|}')
		table.insert(output, '')
	end

	return table.concat(output, '\n')
end

return p