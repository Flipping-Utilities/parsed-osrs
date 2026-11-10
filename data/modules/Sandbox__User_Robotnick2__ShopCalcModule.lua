-- Percentages are stored in tenths of a percent (1000 = 100%).
-- Times are stored in tenths of a second.

local p = {}
local yesno = require('Module:Yesno')
local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max

local PER_MILLE = 1000
local TENTHS_PER_HOUR = 36000
local MAX_COINS = 2147483647
local MAX_STOCK = 100000
local MAX_QUANTITY = 1000000
local MAX_EXACT = 9007199254740991

local function formatNumber(number)
	return mw.language.getContentLanguage():formatNum(tonumber(string.format('%.0f', number)))
end

-- Read and check the form ----------------------------------------------------

local function readInputs(args)
	local function number(name)
		return tonumber(args[name])
	end
	local buying = args.action == 'Buying'
	local infinite = args.stockType == 'Infinite'
	local function perMille(name)
		local value = number(name)
		return value and floor(value * 10 + 0.5)
	end
	return {
		isBuying = buying,
		isInfiniteStock = infinite,
		listedPrice = number(buying and 'priceShopSellsAt' or 'priceShopBuysAt'),
		percent = perMille(buying and 'shopSellsAtValue' or 'shopBuysAtValue'),
		change = perMille('delta'),
		normalStock = number('baseStock'),
		currentStock = number('currentStock'),
		quantity = number(buying and 'buyQuantity' or 'sellQuantity'),
		itemValue = number('itemValue'),
		packContents = buying and number('packContentsQuantity') or 1,
		packItem = tostring(args.packContentsItem or ''):gsub("[%c|%[%]{}<>']", ''):sub(1, 120),
		wantsProfit = yesno(args.includeProfit, false),
		gePrice = number('grandExchangePrice'),
		taxExempt = yesno(args.grandExchangeTaxExempt, false),
		compareStrategies = yesno(args.compareStrategies, false) and not infinite,
		worlds = number('availableWorlds') or 1,
		hopSeconds = number('worldHopSeconds') or 0,
		restockSeconds = number('restockSeconds') or 0,
		overheadSeconds = number('cycleOverheadSeconds') or 0,
		gpPerHour = number('timeValueGpPerHour') or 0,
	}
end

-- Check for valid arithmetic and bound the number of loop iterations.
local function validate(inputs)
	local function whole(n, low, high)
		return n ~= nil and n == floor(n) and n >= low and n <= high
	end
	local function within(n, low, high)
		return n ~= nil and n >= low and n <= high
	end
	if not whole(inputs.listedPrice, 0, MAX_COINS)
		or not whole(inputs.quantity, 1, MAX_QUANTITY)
		or not whole(inputs.packContents, 1, MAX_QUANTITY) then
		return 'Invalid shop price or quantity.'
	end
	if not inputs.isInfiniteStock and (
		not within(inputs.percent, 1, 20000)
		or not within(inputs.change, 0, 1000)
		or not whole(inputs.normalStock, 0, MAX_STOCK)
		or not whole(inputs.currentStock, 0, MAX_STOCK)) then
		return 'Invalid shop percentage or stock.'
	end
	if inputs.wantsProfit and not whole(inputs.gePrice, 0, MAX_COINS) then
		return 'Invalid Grand Exchange price.'
	end
	if inputs.compareStrategies and (
		not whole(inputs.worlds, 1, 330)
		or not whole(inputs.gpPerHour, 0, MAX_COINS)
		or not within(inputs.hopSeconds, 0, 3600)
		or not within(inputs.restockSeconds, 0, 86400)
		or not within(inputs.overheadSeconds, 0, 86400)) then
		return 'Invalid strategy settings.'
	end
end

-- A rounded shop price may correspond to several possible item values.
-- Use the recorded value if supplied; otherwise choose from the possible range.
local function chooseItemValue(inputs)
	local low = ceil(inputs.listedPrice * PER_MILLE / inputs.percent)
	local high = ceil((inputs.listedPrice + 1) * PER_MILLE / inputs.percent) - 1
	local value = inputs.itemValue
	local note
	if not value or value < 0 or value > MAX_COINS or value ~= floor(value) then
		value = nil
	end
	if not value then
		if low <= high and low <= MAX_COINS then
			high = min(high, MAX_COINS)
			value = floor((low + high) / 2)
			if low < high then
				note = 'Estimated item value: ' .. formatNumber(value)
					.. ' coins (possible range: ' .. formatNumber(low) .. '–'
					.. formatNumber(high) .. '). Enter the exact item value for exact prices.'
			end
		else
			value = floor(inputs.listedPrice * PER_MILLE / inputs.percent + 0.5)
			if inputs.listedPrice > 0 then value = max(1, value) end
			value = min(MAX_COINS, value)
			note = 'No whole-number item value matches the listed shop price at '
				.. string.format('%.1f', inputs.percent / 10) .. '%. Using an estimate of '
				.. formatNumber(value) .. ' coins; enter the exact value if known.'
		end
	elseif value < low or value > high then
		local expected
		if low > high then
			expected = 'no whole-number value'
		elseif low == high then
			expected = formatNumber(low)
		else
			expected = formatNumber(low) .. '–' .. formatNumber(high)
		end
		note = 'The listed shop price suggests ' .. expected
			.. ' coins, but the supplied item value is ' .. formatNumber(value)
			.. ' coins. Using the supplied value.'
	end
	return value, note
end

-- Avoid calculations that exceed the precision of Lua's numeric values.
local function checkPrecision(inputs)
	if not inputs.isInfiniteStock then
		local span = inputs.percent + inputs.change
			* (inputs.normalStock + inputs.currentStock + inputs.quantity)
		if inputs.itemValue * (span * 1.0) > MAX_EXACT then
			return 'This price and quantity combination is too large to calculate accurately.'
		end
	end
	if inputs.wantsProfit and inputs.isBuying
		and (inputs.gePrice * 1.0) * inputs.packContents * inputs.quantity > MAX_EXACT then
		return 'This pack and GE price combination is too large to calculate accurately.'
	end
	if inputs.compareStrategies and inputs.gpPerHour > 0 then
		local time = inputs.quantity * (inputs.restockSeconds + inputs.overheadSeconds)
			+ inputs.worlds * inputs.hopSeconds
		if time * 10.0 * inputs.gpPerHour > MAX_EXACT then
			return 'The time and gp/hour values are too large to compare accurately.'
		end
	end
end

-- Shop prices ----------------------------------------------------------------

local function itemPrice(shop, stock)
	if shop.isInfiniteStock then
		return shop.listedPrice
	end
	if shop.isBuying and shop.itemValue == 0 then
		return 1
	end

	local missing = shop.normalStock - stock
	local price
	if missing == 0 then
		price = shop.listedPrice
	elseif shop.isBuying and missing < 0 then
		-- Shops with surplus stock use the inverse price formula when selling to players.
		price = floor(shop.itemValue * PER_MILLE / (shop.percent - shop.change * missing))
	else
		price = floor(shop.itemValue * (shop.percent + shop.change * missing) / PER_MILLE)
	end

	if shop.isBuying then
		local highest = floor(shop.itemValue * (shop.percent + 5000) / PER_MILLE)
		if price > highest then return highest end
		if price < 1 then return 1 end
		local tenPercent = floor(shop.itemValue / 10)
		local markup = floor(shop.itemValue * (shop.percent - PER_MILLE) / PER_MILLE)
		if price < tenPercent then return tenPercent end
		if price < markup then return markup end
	else
		local highest = floor(shop.itemValue * (PER_MILLE + shop.percent) / PER_MILLE)
		local lowest = floor(shop.itemValue / 10)
		if price > highest then return highest end
		if price <= lowest then return lowest end
	end
	return price
end

-- Walk through the requested items, remembering the most profitable
-- stopping point along the way when a GE price is provided.
local function trade(shop, quantity, geEach)
	local result = { coins = 0 }
	if geEach then result.bestQuantity, result.bestProfit = 0, 0 end
	local stock = shop.currentStock or 0
	local stockChange = shop.isBuying and -1 or 1
	local profit = 0

	for i = 1, quantity do
		local price = itemPrice(shop, stock)
		result.coins = result.coins + price
		if i == 1 then result.firstPrice = price end
		result.lastPrice = price
		if geEach then
			profit = profit + geEach + (shop.isBuying and -price or price)
			if profit > result.bestProfit then
				result.bestQuantity, result.bestProfit = i, profit
			end
		end
		stock = stock + stockChange
	end
	if geEach then result.geProfit = profit end
	return result
end

local function geProceeds(price, taxExempt)
	return taxExempt and price or price - min(floor(price / 50), 5000000)
end

-- Net GE proceeds when buying from a shop; GE purchase cost when selling to it.
local function geProfitPerItem(inputs)
	if inputs.isBuying then
		return geProceeds(inputs.gePrice, inputs.taxExempt) * inputs.packContents
	end
	return -inputs.gePrice
end

-- Strategies -----------------------------------------------------------------

local function toTenths(seconds)
	return floor(seconds * 10 + 0.5)
end

-- Lower scores are better. Selling gives negative cost because coins are earned.
local function effectiveCost(inputs, coins, timeTenths)
	local shopCost = inputs.isBuying and coins or -coins
	return shopCost + timeTenths * inputs.gpPerHour / TENTHS_PER_HOUR
end

-- Precalculate the coins exchanged for 1, 2, 3, ... items at normal stock.
-- This running-total table avoids repeating each trade for every plan.
local function normalStockTotals(shop, quantity)
	local totals = { [0] = 0 }
	local stock = shop.normalStock
	for i = 1, quantity do
		totals[i] = totals[i - 1] + itemPrice(shop, stock)
		stock = stock + (shop.isBuying and -1 or 1)
	end
	return totals
end

-- Divide the items as evenly as possible between worlds or batches.
-- Return the total coins, smaller group size, and counts of each group size.
local function evenGroups(totals, quantity, groups)
	local perGroup = floor(quantity / groups)
	local extraGroups = quantity % groups
	local smallGroups = groups - extraGroups
	local coins = smallGroups * totals[perGroup]
	if extraGroups > 0 then
		coins = coins + extraGroups * totals[perGroup + 1]
	end
	return coins, perGroup, smallGroups, extraGroups
end

-- Try each possible number of worlds, up to the entered world limit.
local function worldHopping(inputs, totals)
	local quantity = inputs.quantity
	local fewest = inputs.isBuying and ceil(quantity / inputs.normalStock) or 1
	if fewest > inputs.worlds then
		return { unavailable = 'Needs ' .. formatNumber(fewest) .. ' worlds; '
			.. formatNumber(inputs.worlds) .. ' available.' }
	end
	local hopTenths = toTenths(inputs.hopSeconds)
	if inputs.gpPerHour > 0 and hopTenths == 0 then
		return { unavailable = 'Enter the time per world hop.' }
	end

	local best, bestScore
	for worlds = fewest, min(quantity, inputs.worlds) do
		local coins, perWorld, smallWorlds, extraWorlds = evenGroups(totals, quantity, worlds)
		local hops = worlds - 1
		local timeTenths = hops * hopTenths
		local score = effectiveCost(inputs, coins, timeTenths)
		if not best or score < bestScore then
			bestScore = score
			best = {
				coins = coins, worlds = worlds, hops = hops, timeTenths = timeTenths,
				timeKnown = hopTenths > 0 or hops == 0,
				smallerQuantity = perWorld, smallerWorlds = smallWorlds,
				largerQuantity = perWorld + 1, largerWorlds = extraWorlds,
			}
		end
	end
	return best
end

-- Test different numbers of waits, dividing trades into even batches.
-- The last batch is larger if the division isn't exact (no waiting after it).
local function waitingForStock(inputs, totals)
	local restock = toTenths(inputs.restockSeconds)
	if restock == 0 then
		return { unavailable = 'Enter a restock time of at least 0.1 seconds.' }
	end
	local overhead = toTenths(inputs.overheadSeconds)
	local quantity = inputs.quantity
	local fewest = inputs.isBuying and ceil(quantity / inputs.normalStock) - 1 or 0
	local best, bestScore
	for waits = fewest, quantity - 1 do
		local coins, perBatch, smallBatches, extraBatches = evenGroups(totals, quantity, waits + 1)
		local last = perBatch
		local smallBeforeLast = smallBatches
		local largeBeforeLast = extraBatches
		if extraBatches > 0 then
			last = perBatch + 1
			largeBeforeLast = largeBeforeLast - 1
		else
			smallBeforeLast = smallBeforeLast - 1
		end
		local timeTenths = (quantity - last) * restock + waits * overhead
		local score = effectiveCost(inputs, coins, timeTenths)
		if not best or score < bestScore or (score == bestScore and timeTenths < best.timeTenths) then
			bestScore = score
			best = {
				coins = coins, timeTenths = timeTenths, waits = waits,
				lastQuantity = last, smallerQuantity = perBatch,
				smallerBatches = smallBeforeLast,
				largerQuantity = perBatch + 1, largerBatches = largeBeforeLast,
			}
		end
	end
	return best
end

-- Compare trading now, using multiple worlds, and waiting for stock recovery.
-- Every option is a single record used by both comparison and presentation.
local function strategyComparison(inputs, results)
	local quantity = inputs.quantity
	local comparison = {
		quantity = quantity, isBuying = inputs.isBuying,
		gpPerHour = inputs.gpPerHour, includesGE = inputs.wantsProfit,
		startingStockIsNormal = inputs.currentStock == inputs.normalStock,
		options = {},
	}
	local geEach = inputs.wantsProfit and geProfitPerItem(inputs) or nil
	local bestScore

	local function addOption(kind, label, option)
		option.kind = kind
		option.label = label
		if not option.unavailable then
			option.timeKnown = option.timeKnown ~= false
			option.timeValue = inputs.gpPerHour * option.timeTenths / TENTHS_PER_HOUR
			local score = effectiveCost(inputs, option.coins, option.timeTenths)
			if geEach then
				option.geProfit = geEach * quantity + (inputs.isBuying and -option.coins or option.coins)
				option.profitAfterTime = option.geProfit - option.timeValue
			else
				option.coinsAfterTime = option.coins + (inputs.isBuying and option.timeValue or -option.timeValue)
			end
			if not comparison.best or score < bestScore
				or (score == bestScore and option.timeTenths < comparison.best.timeTenths) then
				comparison.best, bestScore = option, score
			end
		end
		table.insert(comparison.options, option)
	end

	local tradedAll = results.quantityTraded == quantity
	if tradedAll then
		addOption('now', 'Trade now', { coins = results.coins, timeTenths = 0 })
	else
		addOption('now', 'Trade now', { unavailable = 'Only ' .. formatNumber(results.quantityTraded)
			.. ' of ' .. formatNumber(quantity) .. ' are in stock.' })
	end

	-- Both alternative strategies assume every batch starts at normal stock.
	local unavailable
	if not comparison.startingStockIsNormal then
		unavailable = 'Needs current stock at normal stock.'
	elseif inputs.isBuying and inputs.normalStock == 0 then
		unavailable = 'Normal stock is zero.'
	end
	if unavailable then
		addOption('hop', 'World hopping', { unavailable = unavailable })
		addOption('wait', 'Wait for stock', { unavailable = unavailable })
		return comparison
	end

	local maximum = inputs.isBuying and min(quantity, inputs.normalStock) or quantity
	local totals = normalStockTotals(inputs, maximum)
	local hop = worldHopping(inputs, totals)
	if not hop.unavailable and hop.hops == 0 and tradedAll then
		hop = { unavailable = 'Hopping does not improve the result at this time value.' }
	end
	addOption('hop', 'World hopping', hop)

	local wait = waitingForStock(inputs, totals)
	if not wait.unavailable and wait.waits == 0 and tradedAll then
		wait = { unavailable = 'Waiting does not improve the result at this time value.' }
	end
	addOption('wait', 'Wait for stock', wait)
	return comparison
end

-- Calculate a transaction ----------------------------------------------------

function p._calculate(args)
	local inputs = readInputs(args)
	local problem = validate(inputs)
	if problem then return nil, problem end
	if not inputs.isInfiniteStock then
		inputs.itemValue, inputs.valueNote = chooseItemValue(inputs)
	end
	problem = checkPrecision(inputs)
	if problem then return nil, problem end

	local quantity = inputs.quantity
	if inputs.isBuying and not inputs.isInfiniteStock then
		quantity = min(quantity, inputs.currentStock)
	end
	local geEach = inputs.wantsProfit and geProfitPerItem(inputs) or nil
	local results = trade(inputs, quantity, geEach)
	results.isBuying = inputs.isBuying
	results.isInfiniteStock = inputs.isInfiniteStock
	results.itemValue = not inputs.isInfiniteStock and inputs.itemValue or nil
	results.valueNote = inputs.valueNote
	results.quantityTraded = quantity

	if not inputs.isInfiniteStock then
		results.stockAfterTrade = inputs.currentStock + (inputs.isBuying and -quantity or quantity)
	end
	if inputs.isBuying and quantity < inputs.quantity then
		results.warning = quantity == 0 and 'The shop is out of stock.'
			or 'Only ' .. formatNumber(quantity)
			.. (inputs.packContents > 1 and ' packs' or ' items') .. ' are in stock, so the result is for '
			.. formatNumber(quantity) .. '.'
	end
	if inputs.wantsProfit then
		results.gePrice = inputs.gePrice
		results.geTaxPerItem = inputs.isBuying
			and inputs.gePrice - geProceeds(inputs.gePrice, inputs.taxExempt) or 0
	end
	if inputs.compareStrategies then
		results.strategyComparison = strategyComparison(inputs, results)
	end
	if inputs.isBuying and inputs.packContents > 1 then
		results.packContentsQuantity = inputs.packContents
		results.packContentsItem = inputs.packItem ~= '' and inputs.packItem or 'items'
		results.contentsReceived = quantity * inputs.packContents
	end
	return results
end

-- Output ---------------------------------------------------------------------
local function coins(amount)
	return formatNumber(amount) .. (amount == 1 and ' coin' or ' coins')
end

local function approximateCoins(amount)
	return 'about ' .. coins(floor(amount + 0.5))
end

-- Show a number with two decimal places, e.g. 1,234.50.
local function formatAverage(number)
	local whole, fraction = string.format('%.2f', number):match('^(%-?%d+)%.(%d%d)$')
	return formatNumber(tonumber(whole)) .. '.' .. fraction
end

-- Show a time in tenths of a second, e.g. "1 h 2 min 3.5 sec".
local function duration(tenths)
	local hours = floor(tenths / 36000)
	local minutes = floor((tenths % 36000) / 600)
	local seconds = (tenths % 600) / 10
	local parts = {}
	if hours > 0 then
		table.insert(parts, formatNumber(hours) .. ' h')
	end
	if minutes > 0 then
		table.insert(parts, minutes .. ' min')
	end
	if seconds > 0 or #parts == 0 then
		local text = seconds == floor(seconds) and tostring(seconds) or string.format('%.1f', seconds)
		table.insert(parts, text .. ' sec')
	end
	return table.concat(parts, ' ')
end

-- "1 item", "2 items"; "1 batch", "2 batches".
local function plural(count, word)
	local words = word == 'batch' and 'batches' or word .. 's'
	return formatNumber(count) .. ' ' .. (count == 1 and word or words)
end

local function waitingText(option, unit)
	if option.waits == 0 then
		return plural(option.lastQuantity, unit) .. ' without waiting'
	end
	local parts = {}
	if option.smallerBatches > 0 then
		table.insert(parts, plural(option.smallerBatches, 'batch') .. ' of ' .. formatNumber(option.smallerQuantity))
	end
	if option.largerBatches > 0 then
		table.insert(parts, plural(option.largerBatches, 'batch') .. ' of ' .. formatNumber(option.largerQuantity))
	end
	return table.concat(parts, ', ') .. '; then ' .. plural(option.lastQuantity, unit)
end

local function hoppingText(option, unit)
	local parts = {}
	if option.smallerWorlds > 0 then
		table.insert(parts, plural(option.smallerWorlds, 'world') .. ' × ' .. plural(option.smallerQuantity, unit))
	end
	if option.largerWorlds > 0 then
		table.insert(parts, plural(option.largerWorlds, 'world') .. ' × ' .. plural(option.largerQuantity, unit))
	end
	return table.concat(parts, '; ')
end

local function addRow(lines, label, value)
	table.insert(lines, '|-\n! style="text-align:left; font-weight:normal;" | ' .. label .. '\n| ' .. value)
end

local function addHeading(lines, heading)
	table.insert(lines, '|-\n! colspan="2" style="text-align:left;" | ' .. heading)
end

local function tradeTable(results, unit)
	local buying = results.isBuying
	local isPack = unit == 'pack'
	local perWhat = isPack and results.packContentsItem or 'item'
	local lines = {
		'{| class="wikitable" style="text-align:right;"',
		'|+ ' .. (buying and 'Buying ' or 'Selling ') .. plural(results.quantityTraded, unit)
			.. (buying and ' from the shop' or ' to the shop'),
	}
	addRow(lines, buying and 'Total cost' or 'Total received', coins(results.coins))
	if isPack then
		addRow(lines, 'Pack contents', formatNumber(results.packContentsQuantity) .. ' × ' .. results.packContentsItem)
		addRow(lines, 'Contents received', formatNumber(results.contentsReceived) .. ' × ' .. results.packContentsItem)
	end
	if results.isInfiniteStock then
		addRow(lines, 'Price per ' .. unit, coins(results.firstPrice))
		addRow(lines, 'Stock', 'Unlimited (fixed price)')
	else
		if results.quantityTraded > 1 then
			addRow(lines, 'Average price per ' .. unit,
				formatAverage(results.coins / results.quantityTraded) .. ' coins')
			addRow(lines, 'First and last ' .. unit,
				formatNumber(results.firstPrice) .. ' / ' .. coins(results.lastPrice))
		end
		addRow(lines, 'Stock after trade', formatNumber(results.stockAfterTrade))
		addRow(lines, isPack and 'Pack value' or 'Item value', coins(results.itemValue))
	end
	if results.geProfit then
		addHeading(lines, 'Profit (GE price: ' .. coins(results.gePrice) .. ' per ' .. perWhat .. ')')
		if buying then
			addRow(lines, 'GE tax per ' .. perWhat, coins(results.geTaxPerItem))
		end
		addRow(lines, 'Profit from this trade', coins(results.geProfit))
		local label = 'Most profitable ' .. (isPack and 'packs' or 'quantity') .. ' (current stock)'
		if results.bestQuantity > 0 then
			addRow(lines, label, formatNumber(results.bestQuantity) .. ' <small>('
				.. coins(results.bestProfit) .. ' profit)</small>')
		else
			addRow(lines, label, 'None')
		end
	end
	table.insert(lines, '|}')
	return table.concat(lines, '\n')
end

local function comparisonTable(results, unit)
	local comparison = results.strategyComparison
	local buying = comparison.isBuying
	local hasGE = comparison.includesGE
	local valuesTime = comparison.gpPerHour > 0
	local perWhat = unit == 'pack' and results.packContentsItem or 'item'
	local caption = '|+ Ways to ' .. (buying and 'buy ' or 'sell ') .. plural(comparison.quantity, unit)
	if hasGE then
		caption = caption .. ' (GE price: ' .. coins(results.gePrice) .. ' per ' .. perWhat .. ')'
	end
	local lines = {
		'{| class="wikitable" style="text-align:right;"',
		caption,
		'|-',
		'! Strategy',
		'! ' .. (buying and 'Shop cost' or 'Shop pays'),
		'! Extra time',
	}
	if hasGE then
		table.insert(lines, '! GE profit')
	end
	if valuesTime then
		table.insert(lines, '! ' .. (hasGE and 'Profit after time value'
			or buying and 'Cost including time value' or 'Received after time value'))
	end
	local columns = 3 + (hasGE and 1 or 0) + (valuesTime and 1 or 0)

	for _, option in ipairs(comparison.options) do
		table.insert(lines, '|-')
		local label = option.label
		if option == comparison.best then
			label = "'''" .. label .. " (best)'''"
		end
		if option.unavailable then
			table.insert(lines, '| ' .. label)
			table.insert(lines, '| colspan="' .. (columns - 1) .. '" style="text-align:left;" | ' .. option.unavailable)
		else
			if option.kind == 'hop' then
				label = label .. '<br /><small>' .. hoppingText(option, unit) .. '</small>'
			elseif option.kind == 'wait' then
				label = label .. '<br /><small>' .. waitingText(option, unit) .. '</small>'
			end
			table.insert(lines, '| ' .. label)
			table.insert(lines, '| ' .. coins(option.coins))
			table.insert(lines, '| ' .. (option.timeKnown and duration(option.timeTenths) or 'Not entered'))
			if hasGE then
				table.insert(lines, '| ' .. coins(option.geProfit))
			end
			if valuesTime then
				table.insert(lines, '| ' .. approximateCoins(hasGE and option.profitAfterTime or option.coinsAfterTime))
			end
		end
	end
	table.insert(lines, '|}')
	return table.concat(lines, '\n')
end

local function comparisonNotes(comparison)
	local notes = {}
	local best = comparison.best
	local valuesTime = comparison.gpPerHour > 0
	if best then
		local criterion
		if comparison.includesGE then
			criterion = valuesTime and 'Highest profit after time value' or 'Highest GE profit'
		elseif valuesTime then
			criterion = comparison.isBuying and 'Lowest cost after time value' or 'Most received after time value'
		else
			criterion = 'Best shop price'
		end
		table.insert(notes, '<p>' .. criterion .. ': ' .. best.label .. '. '
			.. (valuesTime and 'Time value estimates the coins you could earn elsewhere.'
				or 'Enter a time value to account for hopping and waiting.') .. '</p>')
		local bestProfit = valuesTime and best.profitAfterTime or best.geProfit
		if comparison.includesGE and bestProfit < 0 then
			table.insert(notes, '<p>Every option makes a loss.</p>')
		end
	end
	if not comparison.startingStockIsNormal then
		table.insert(notes, '<p><small>Hopping and waiting assume normal stock; '
			.. 'trading now uses current stock.</small></p>')
	end
	table.insert(notes, '<p><small>Times cover only the hop, recovery and batch times entered. '
		.. 'Allow separately for shop interactions.</small></p>')
	return table.concat(notes, '\n')
end

function p._main(args)
	local results, problem = p._calculate(args)
	if not results then
		return '<strong class="error">' .. problem .. '</strong>'
	end
	local unit = results.packContentsQuantity and 'pack' or 'item'
	local output = {}
	local comparison = results.strategyComparison
	if results.warning then
		table.insert(output, '<p>' .. (comparison and 'Trading now: ' or '') .. results.warning .. '</p>')
	end
	if results.valueNote then
		table.insert(output, '<p><small>' .. results.valueNote .. '</small></p>')
	end
	if comparison then
		if unit == 'pack' then
			table.insert(output, '<p>' .. plural(comparison.quantity, 'pack') .. ' contain '
				.. formatNumber(comparison.quantity * results.packContentsQuantity) .. ' × '
				.. results.packContentsItem .. '.</p>')
		end
		table.insert(output, comparisonTable(results, unit))
		table.insert(output, comparisonNotes(comparison))
	else
		table.insert(output, tradeTable(results, unit))
	end
	return table.concat(output, '\n')
end

function p.main(frame)
	return p._main(frame.args)
end

return p