local p = {}

local bucket = mw.ext.bucket
local currencies = require('Module:Currencies')


--------------------------------------------------------------------------------
-- YOUR EQUILIBRIUM REGIONS
--------------------------------------------------------------------------------

local selectedRegions = {
	['Misthalin'] = true,
	['Havenhythe'] = true,
	['Karamja'] = true,
	['Kandarin'] = true,
	['Tirannwn'] = true,
	['Kharidian Desert'] = true,
}


local regionOrder = {
	['Misthalin'] = 1,
	['Havenhythe'] = 2,
	['Karamja'] = 3,
	['Kandarin'] = 4,
	['Tirannwn'] = 5,
	['Kharidian Desert'] = 6,
}


--------------------------------------------------------------------------------
-- TRANSMUTATION CHAINS
--
-- Each chain is now DATA.
-- The renderer/calculation code below is shared by every chain.
--------------------------------------------------------------------------------

local chains = {}


--------------------------------------------------------------------------------
-- RUNES
--------------------------------------------------------------------------------

chains.runes = {

	name = 'Runes',

	itemHeader = 'Transmutable item',
	levelHeader = 'RC level',
	regionHeader = 'Altar region',
	strategyHeader1 = 'Fastest transmute route',
	strategyHeader2 = 'Cheapest transmute route',
	strategyMode = 'routes',

	regionMode = 'page',

	items = {

		{
			item = 'Rune essence',
			level = 1,
		},

		{
			item = 'Pure essence',
			level = 1,
		},

		{
			item = 'Air rune',
			level = 1,
			regionPage = 'Air altar',
			fallbackRegion = 'Misthalin',
		},

		{
			item = 'Mind rune',
			level = 1,
			regionPage = 'Mind altar',
			fallbackRegion = 'Asgarnia',
		},

		{
			item = 'Water rune',
			level = 5,
			regionPage = 'Water altar',
			fallbackRegion = 'Misthalin',
		},

		{
			item = 'Earth rune',
			level = 9,
			regionPage = 'Earth altar',
			fallbackRegion = 'Misthalin',
		},

		{
			item = 'Fire rune',
			level = 14,
			regionPage = 'Fire altar',
			fallbackRegion = 'Kharidian Desert',
		},

		{
			item = 'Body rune',
			level = 20,
			regionPage = 'Body altar',
			fallbackRegion = 'Asgarnia',
		},

		{
			item = 'Cosmic rune',
			level = 27,
			regionPage = 'Cosmic altar',
			fallbackRegion = 'Misthalin',
		},

		{
			item = 'Chaos rune',
			level = 35,
			regionPage = 'Chaos altar',
			fallbackRegion = 'Wilderness',
		},

		{
			item = 'Astral rune',
			level = 40,
			regionPage = 'Astral altar',
			fallbackRegion = 'Fremennik Province',
		},

		{
			item = 'Nature rune',
			level = 44,
			regionPage = 'Nature altar',
			fallbackRegion = 'Karamja',
		},

		{
			item = 'Law rune',
			level = 54,
			regionPage = 'Law altar',
			fallbackRegion = 'Asgarnia',
		},

		{
			item = 'Death rune',
			level = 65,
			regionPage = 'Death altar',
			fallbackRegion = 'Tirannwn',
		},

		{
			item = 'Blood rune',
			level = 77,
			regionPage = 'Blood altar',
			fallbackRegion = 'Morytania',
		},

		{
			item = 'Soul rune',
			level = 90,
			regionPage = 'Soul altar',
			fallbackRegion = 'Kharidian Desert',
		},

		{
			item = 'Time rune',
			level = 100,
			regionPage = 'Time altar',
			fallbackRegion = 'Anachronia',
		},
	},


	----------------------------------------------------------------------------
	-- MANUALLY CURATED RUNE ROUTES
	----------------------------------------------------------------------------

	routeAdvice = {

		['Astral rune'] = {

			fastest = {
				from = 'Chaos rune',
				tiers = 1,
				rate = 12000,
				unitCost = 140,
			},

			cheapest = {
				from = 'Body rune',
				tiers = 3,
				rate = 4000,
				unitCost = 16,
			},
		},


		['Time rune'] = {

			fastest = {
				from = 'Soul rune',
				tiers = 1,
				rate = 12000,
				unitCost = 410,
			},

			cheapest = {
				from = 'Body rune',
				tiers = 9,
				rate = 12000 / 9,
				unitCost = 16,
			},
		},
	},
}


--------------------------------------------------------------------------------
-- ORES
--------------------------------------------------------------------------------

chains.ores = {

	name = 'Ores',

	itemHeader = 'Transmutable ore',
	levelHeader = 'Mining level',
	regionHeader = 'Natural access',

	strategyHeader1 = 'Transmute fallback',
	strategyHeader2 = 'Transmute throughput',
	strategyMode = 'manual',

	regionMode = 'manual',

	items = {

		{
			item = 'Copper ore',
			level = 1,
			regionText = 'Various',
		},

		{
			item = 'Tin ore',
			level = 1,
			regionText = 'Various',
		},

		{
			item = 'Iron ore',
			level = 10,
			regionText = 'Various',
		},

		{
			item = 'Coal',
			level = 20,
			regionText = 'Various',
		},

		{
			item = 'Mithril ore',
			level = 30,
			regionText = 'Various',
		},

		{
			item = 'Adamantite ore',
			level = 40,
			regionText = 'Various',
		},

		{
			item = 'Luminite',
			level = 40,
			regionText = 'Various',
		},

		{
			item = 'Runite ore',
			level = 50,
			regionText = 'Various',
		},

		{
			item = 'Orichalcite ore',
			level = 60,
			regionText = 'Various',
		},

		{
			item = 'Drakolith',
			level = 60,
			regionText = 'Various',
		},

		{
			item = 'Necrite ore',
			level = 70,
			regionText = 'Various',
		},

		{
			item = 'Phasmatite',
			level = 70,
			regionText = 'Various',
		},

		{
			item = 'Banite ore',
			level = 80,
			regionText = 'Various',
		},

		{
			item = 'Light animica',
			level = 90,
			regionText = 'Various',
		},

		{
			item = 'Dark animica',
			level = 90,
			manualRegion = 'Misthalin',
		},


		--------------------------------------------------------------------
		-- PRIMAL / DAEMONHEIM ORES
		--------------------------------------------------------------------

		{
			item = 'Novite ore',
			level = 100,
			manualRegion = 'Wilderness',
		},

		{
			item = 'Bathus ore',
			level = 100,
			manualRegion = 'Wilderness',
		},

		{
			item = 'Marmaros ore',
			level = 100,
			manualRegion = 'Wilderness',
		},

		{
			item = 'Kratonium ore',
			level = 100,
			manualRegion = 'Wilderness',
		},

		{
			item = 'Fractite ore',
			level = 100,
			manualRegion = 'Wilderness',
		},

		{
			item = 'Zephyrium ore',
			level = 100,
			manualRegion = 'Wilderness',
		},

		{
			item = 'Argonite ore',
			level = 100,
			manualRegion = 'Wilderness',
		},

		{
			item = 'Katagon ore',
			level = 100,
			manualRegion = 'Wilderness',
		},

		{
			item = 'Gorgonite ore',
			level = 100,
			manualRegion = 'Wilderness',
		},

		{
			item = 'Promethium ore',
			level = 100,
			manualRegion = 'Wilderness',
		},
	},


	----------------------------------------------------------------------------
	-- TRANSMUTATION FALLBACKS
	--
	-- Dark animica is the highest naturally accessible ore in your regions
	-- before the Daemonheim primal sequence.
	--
	-- Throughput assumes:
	-- 12,000 one-tier item transitions per hour.
	----------------------------------------------------------------------------

	routeAdvice = {

		['Novite ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Novite ore]]'''"
				.. '<br>1 tier',

			col2 =
				"'''12,000/hour'''",
		},


		['Bathus ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Bathus ore]]'''"
				.. '<br>2 tiers',

			col2 =
				"'''6,000/hour'''",
		},


		['Marmaros ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Marmaros ore]]'''"
				.. '<br>3 tiers',

			col2 =
				"'''4,000/hour'''",
		},


		['Kratonium ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Kratonium ore]]'''"
				.. '<br>4 tiers',

			col2 =
				"'''3,000/hour'''",
		},


		['Fractite ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Fractite ore]]'''"
				.. '<br>5 tiers',

			col2 =
				"'''2,400/hour'''",
		},


		['Zephyrium ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Zephyrium ore]]'''"
				.. '<br>6 tiers',

			col2 =
				"'''2,000/hour'''",
		},


		['Argonite ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Argonite ore]]'''"
				.. '<br>7 tiers',

			col2 =
				"'''~1,714/hour'''",
		},


		['Katagon ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Katagon ore]]'''"
				.. '<br>8 tiers',

			col2 =
				"'''1,500/hour'''",
		},


		['Gorgonite ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Gorgonite ore]]'''"
				.. '<br>9 tiers',

			col2 =
				"'''~1,333/hour'''",
		},


		['Promethium ore'] = {
			col1 =
				"'''[[Dark animica]] → [[Promethium ore]]'''"
				.. '<br>10 tiers',

			col2 =
				"'''1,200/hour'''",
		},
	},
}


--------------------------------------------------------------------------------
-- DIVINE ENERGY
--------------------------------------------------------------------------------

chains.divineenergy = {

	name = 'Divine Energy',

	renderer = 'divineEnergy',

	itemHeader = 'Divine energy',
	levelHeader = 'Divination level',
	regionHeader = 'Colony region',

	-- We ask the live wisp page for leagueRegion first.
	-- fallbackRegion is used only if that Wiki page has not yet been tagged.
	regionMode = 'manual',

	items = {

		{
			item = 'Pale energy',
			level = 1,
			manualRegion = 'Misthalin',

			porter = {
				sign = 'Sign of the porter I',
				energy = 30,
				jewellery = 'Sapphire necklace',
				charges = 5,
			},

			divineCharge = 2000,
		},


		{
			item = 'Flickering energy',
			level = 10,
			manualRegion = 'Asgarnia',

			divineCharge = 1000,
		},


		{
			item = 'Bright energy',
			level = 20,
			manualRegion = 'Misthalin',

			porter = {
				sign = 'Sign of the porter II',
				energy = 35,
				jewellery = 'Sapphire necklace',
				charges = 10,
			},

			divineCharge = 900,
		},


		{
			item = 'Glowing energy',
			level = 30,
			manualRegion = 'Kandarin',

			divineCharge = 850,
		},


		{
			item = 'Sparkling energy',
			level = 40,
			manualRegion = 'Fremennik',

			porter = {
				sign = 'Sign of the porter III',
				energy = 40,
				jewellery = 'Emerald necklace',
				charges = 15,
			},

			divineCharge = 800,
		},


		{
			item = 'Gleaming energy',
			level = 50,
			manualRegion = 'Karamja',

			divineCharge = 700,
		},


		{
			item = 'Vibrant energy',
			level = 60,
			manualRegion = 'Kandarin',

			porter = {
				sign = 'Sign of the porter IV',
				energy = 45,
				jewellery = 'Emerald necklace',
				charges = 20,
			},

			divineCharge = 650,
		},


		{
			item = 'Lustrous energy',
			level = 70,
			manualRegion = 'Morytania',

			divineCharge = 550,
		},


		{
			item = 'Brilliant energy',
			level = 80,
			manualRegion = 'Desert',

			divineCharge = 450,
		},


		{
			item = 'Radiant energy',
			level = 85,
			manualRegion = 'Morytania',

			porter = {
				sign = 'Sign of the porter V',
				energy = 60,
				jewellery = 'Ruby necklace',
				charges = 25,
			},

			divineCharge = 400,
		},


		{
	item = 'Luminous energy',
	level = 90,
	manualRegion = 'Desert',

	porter = {
		sign = 'Sign of the porter VI',
		energy = 80,
		jewellery = 'Diamond necklace',
		charges = 30,
	},

	divineCharge = 350,
},


		{
			item = 'Incandescent energy',
			level = 95,
			manualRegion = 'Tirannwn',

			porter = {
				sign = 'Sign of the porter VII',
				energy = 120,
				jewellery = 'Dragonstone necklace',
				charges = 50,
			},

			divineCharge = 225,
		},
	},
}

--------------------------------------------------------------------------------
-- BASIC HELPERS
--------------------------------------------------------------------------------

local function toNumber(value)

	if value == nil then
		return nil
	end


	local cleaned =
		tostring(value):gsub(',', '')


	return tonumber(cleaned)
end


local function formatNumber(value)

	local number =
		toNumber(value)


	if not number then
		return tostring(
			value or '—'
		)
	end


	local rounded =
		math.floor(
			number + 0.5
		)


	return mw.language
		.getContentLanguage()
		:formatNum(rounded)
end


--------------------------------------------------------------------------------
-- CURRENCY
--------------------------------------------------------------------------------

local function getCurrencyName(currency)

	if type(currency) == 'table' then

		if #currency == 0 then
			return nil
		end


		return tostring(
			currency[1]
		)
	end


	if currency == nil
		or tostring(currency) == '' then

		return nil
	end


	return tostring(currency)
end


local function isCoins(currency)

	local name =
		getCurrencyName(currency)


	if not name then
		return false
	end


	name =
		string.lower(name)


	return name == 'coins'
		or name == 'coin'
end


local function formatCurrencyAmount(amount, currency)

	local number =
		toNumber(amount)


	if not number then
		return '—'
	end


	local currencyName =
		getCurrencyName(currency)


	if currencyName then

		local success, result =
			pcall(
				currencies._amount,
				tostring(
					math.floor(
						number + 0.5
					)
				),
				currencyName
			)


		if success
			and result ~= nil
			and tostring(result) ~= '' then

			return result
		end
	end


	return formatNumber(number)
end


--------------------------------------------------------------------------------
-- LEAGUE REGION EXTRACTION
--------------------------------------------------------------------------------

local regionCache = {}


local function cleanRegion(value)

	if value == nil then
		return nil
	end


	local text =
		tostring(value)


	text = text:gsub(
		'<!%-%-.-%-%->',
		''
	)


	text = text:gsub(
		'%[%[([^%]|]+)|[^%]]+%]%]',
		'%1'
	)


	text = text:gsub(
		'%[%[([^%]]+)%]%]',
		'%1'
	)


	text =
		mw.text.trim(text)


	if text == '' then
		return nil
	end


	if text == 'Desert' then
		return 'Kharidian Desert'
	end


	return text
end


local function getLeagueRegion(pageName)

	if not pageName
		or pageName == '' then

		return nil
	end


	if regionCache[pageName] ~= nil then

		if regionCache[pageName] == false then
			return nil
		end


		return regionCache[pageName]
	end


	local title =
		mw.title.new(pageName)


	if not title then

		regionCache[pageName] =
			false

		return nil
	end


	local content =
		title:getContent()


	if not content then

		regionCache[pageName] =
			false

		return nil
	end


	local region =
		content:match(
			'|%s*leagueRegion%s*=%s*([^\n|}]+)'
		)


	if not region then

		region =
			content:match(
				'|%s*leagueregion%s*=%s*([^\n|}]+)'
			)
	end


	region =
		cleanRegion(region)


	if region then

		regionCache[pageName] =
			region

		return region
	end


	regionCache[pageName] =
		false


	return nil
end


--------------------------------------------------------------------------------
-- NATIVE LEAGUE-REGION BADGE
--------------------------------------------------------------------------------

local function formatLeagueRegion(frame, region)

	if not region then
		return '—'
	end


	local success, result =
		pcall(
			function()

				return frame:expandTemplate{
					title = 'LeagueRegion',
					args = {
						[1] = region,
					}
				}

			end
		)


	if success
		and result ~= nil
		and mw.text.trim(
			tostring(result)
		) ~= '' then

		return result
	end


	return '[['
		.. region
		.. ']]'
end


--------------------------------------------------------------------------------
-- CHAIN-SPECIFIC REGION DISPLAY
--------------------------------------------------------------------------------

local function formatItemRegion(
	frame,
	chain,
	entry
)

	----------------------------------------------------------------------------
	-- EXAMPLE: RUNES
	-- Read the live leagueRegion field from the altar page.
	----------------------------------------------------------------------------

	if chain.regionMode == 'page' then

		if not entry.regionPage then
			return '—'
		end


		local region =
			getLeagueRegion(
				entry.regionPage
			)


		if not region then
			region =
				entry.fallbackRegion
		end


		return formatLeagueRegion(
			frame,
			region
		)
	end


	----------------------------------------------------------------------------
	-- EXAMPLE: ORES
	-- Manually flag special region-locked natural acquisition.
	----------------------------------------------------------------------------

	if chain.regionMode == 'manual' then

		if entry.manualRegion then

			local result =
				formatLeagueRegion(
					frame,
					entry.manualRegion
				)


local detail =
	entry.requirementText
	or entry.regionDetail


if detail then

	result =
		result
		.. '<br><small>'
		.. detail
		.. '</small>'
end


			return result
		end


		if entry.regionText then
			return entry.regionText
		end
	end


	return '—'
end


--------------------------------------------------------------------------------
-- SHOP QUERY
--------------------------------------------------------------------------------

local function queryItem(item)

	return bucket('storeline')
		.select(
			'page_name',
			'sold_item',
			'store_stock',
			'store_sell_price',
			'store_buy_price',
			'store_currency'
		)
		.where(
			'sold_item',
			item
		)
		.limit(500)
		.run()
end


--------------------------------------------------------------------------------
-- BASIC SHOP-OFFER FILTER
--
-- This deliberately happens BEFORE reading the shop's leagueRegion page.
-- That prevents wasting expensive page lookups on reward stores, Tokkul,
-- free samples, etc.
--------------------------------------------------------------------------------

local function basicPurchaseOffer(row)

	local stock =
		toNumber(
			row.store_stock
		)


	local price =
		toNumber(
			row.store_sell_price
		)


	if not stock
		or stock <= 0 then

		return false
	end


	if not price
		or price <= 0 then

		return false
	end


	if not isCoins(
		row.store_currency
	) then

		return false
	end


	return true
end


--------------------------------------------------------------------------------
-- COLLECT VALID SOURCES IN YOUR SIX REGIONS
--------------------------------------------------------------------------------

local function collectSources(item)

	local rows =
		queryItem(item)


	local sources = {}
	local seen = {}


	for _, row in ipairs(
		rows
	) do

		if basicPurchaseOffer(row) then

			local shop =
				tostring(
					row.page_name
					or ''
				)


			local region =
				getLeagueRegion(shop)


			if region
				and selectedRegions[region] then

				local key =
					table.concat({
						shop,
						tostring(region),
						tostring(
							row.store_stock
						),
						tostring(
							row.store_sell_price
						)
					}, '||')


				if not seen[key] then

					seen[key] =
						true


					row._leagueRegion =
						region


					table.insert(
						sources,
						row
					)
				end
			end
		end
	end


	return sources
end


--------------------------------------------------------------------------------
-- REMOVE DOMINATED SHOP OFFERS
--
-- Offer A disappears when Offer B is:
--
--   <= price
--   >= stock
--
-- and strictly better on at least one of those dimensions.
--------------------------------------------------------------------------------

local function paretoFilter(sources)

	local kept = {}


	for i, candidate in ipairs(
		sources
	) do

		local candidatePrice =
			toNumber(
				candidate.store_sell_price
			)


		local candidateStock =
			toNumber(
				candidate.store_stock
			)


		local dominated =
			false


		for j, other in ipairs(
			sources
		) do

			if i ~= j then

				local otherPrice =
					toNumber(
						other.store_sell_price
					)


				local otherStock =
					toNumber(
						other.store_stock
					)


				if otherPrice
					and otherStock
					and candidatePrice
					and candidateStock then


					local noMoreExpensive =
						otherPrice
						<= candidatePrice


					local noLessStock =
						otherStock
						>= candidateStock


					local strictlyBetter =
						otherPrice
						< candidatePrice
						or otherStock
						> candidateStock


					if noMoreExpensive
						and noLessStock
						and strictlyBetter then

						dominated =
							true

						break
					end
				end
			end
		end


		if not dominated then

			table.insert(
				kept,
				candidate
			)
		end
	end


	return kept
end


--------------------------------------------------------------------------------
-- GROUP ECONOMICALLY IDENTICAL OFFERS
--------------------------------------------------------------------------------

local function groupOffers(sources)

	local groups = {}


	for _, source in ipairs(
		sources
	) do

		local price =
			toNumber(
				source.store_sell_price
			)


		local stock =
			toNumber(
				source.store_stock
			)


		local key =
			tostring(price)
			.. '|'
			.. tostring(stock)


		if not groups[key] then

			groups[key] = {
				price = price,
				stock = stock,
				shops = {},
			}
		end


		table.insert(
			groups[key].shops,
			source
		)
	end


	local result = {}


	for _, group in pairs(
		groups
	) do

		table.sort(
			group.shops,
			function(a, b)

				local regionA =
					regionOrder[
						a._leagueRegion
					] or 999


				local regionB =
					regionOrder[
						b._leagueRegion
					] or 999


				if regionA ~= regionB then
					return regionA < regionB
				end


				return tostring(
					a.page_name
				)
				<
				tostring(
					b.page_name
				)
			end
		)


		table.insert(
			result,
			group
		)
	end


	table.sort(
		result,
		function(a, b)

			if a.price ~= b.price then
				return a.price < b.price
			end


			return a.stock > b.stock
		end
	)


	return result
end


--------------------------------------------------------------------------------
-- FORMAT BEST DIRECT PURCHASE CELL
--------------------------------------------------------------------------------

local function formatPurchaseCell(sources)

	if #sources == 0 then

		return "''No stocked coin shop source "
			.. "in selected regions.''"
	end


	local efficient =
		paretoFilter(
			sources
		)


	local groups =
		groupOffers(
			efficient
		)


	local lines = {}


	for _, group in ipairs(
		groups
	) do

		local shopNames = {}


		for _, source in ipairs(
			group.shops
		) do

			table.insert(
				shopNames,

				'[['
				.. tostring(
					source.page_name
				)
				.. ']]'

				.. ' <small>('
				.. tostring(
					source._leagueRegion
				)
				.. ')</small>'
			)
		end


		local line =

			"'''"
			.. formatNumber(
				group.stock
			)

			.. ' @ '

			.. formatCurrencyAmount(
				group.price,
				{'coins'}
			)

			.. "'''"

			.. '<br>'

			.. table.concat(
				shopNames,
				'; '
			)


		table.insert(
			lines,
			line
		)
	end


	return table.concat(
		lines,
		'<br><br>'
	)
end


--------------------------------------------------------------------------------
-- MANUAL ROUTE ADVICE
--------------------------------------------------------------------------------

local function formatRouteAdvice(
	targetItem,
	route
)

	if not route then
		return '—'
	end


	local hourlyCost =
		route.rate
		* route.unitCost


	return
		"'''[["
		.. route.from
		.. ']] → [['
		.. targetItem
		.. "]]'''"

		.. '<br>'

		.. tostring(
			route.tiers
		)

		.. (
			route.tiers == 1
			and ' tier'
			or ' tiers'
		)

		.. ' · '

		.. formatNumber(
			route.rate
		)

		.. '/hour'

		.. '<br>'

		.. formatCurrencyAmount(
			route.unitCost,
			{'coins'}
		)

		.. ' per '
		.. targetItem

		.. ' · '

		.. formatCurrencyAmount(
			hourlyCost,
			{'coins'}
		)

		.. '/hour'
end


--------------------------------------------------------------------------------
-- GENERIC CHAIN RENDERER
--------------------------------------------------------------------------------

local function renderChain(
	frame,
	chain
)

	local output = {}


	----------------------------------------------------------------------------
	-- COLLAPSIBLE TABLE
	----------------------------------------------------------------------------

	table.insert(
		output,
		'{| class="wikitable mw-collapsible mw-collapsed" '
		.. 'data-expandtext="Expand" '
		.. 'data-collapsetext="Collapse"'
	)


	table.insert(
		output,
		'! '
		.. chain.itemHeader
	)


	table.insert(
		output,
		'! '
		.. chain.levelHeader
	)


	table.insert(
		output,
		'! '
		.. chain.regionHeader
	)


	table.insert(
		output,
		'! Best direct purchase'
	)


table.insert(
	output,
	'! '
	.. (
		chain.strategyHeader1
		or 'Fastest transmute route'
	)
)


table.insert(
	output,
	'! '
	.. (
		chain.strategyHeader2
		or 'Cheapest transmute route'
	)
)


	----------------------------------------------------------------------------
	-- ITEMS
	----------------------------------------------------------------------------

	for _, entry in ipairs(
		chain.items
	) do

		local item =
			entry.item


		local sources =
			collectSources(
				item
			)


		table.insert(
			output,
			'|-'
		)


		------------------------------------------------------------
		-- ITEM
		------------------------------------------------------------

		table.insert(
			output,
			'| [['
			.. item
			.. ']]'
		)


		------------------------------------------------------------
		-- LEVEL
		------------------------------------------------------------

		table.insert(
			output,
			'| style="text-align:center;" | '
			.. tostring(
				entry.level
				or '—'
			)
		)


		------------------------------------------------------------
		-- REGION / NATURAL ACCESS
		------------------------------------------------------------

		table.insert(
			output,
			'| style="text-align:center;" | '
			.. formatItemRegion(
				frame,
				chain,
				entry
			)
		)


		------------------------------------------------------------
		-- DIRECT PURCHASE
		------------------------------------------------------------

		table.insert(
			output,
			'| '
			.. formatPurchaseCell(
				sources
			)
		)


		------------------------------------------------------------
		-- ROUTE ADVICE
		--
		-- Per your rule, only display this when the item has NO
		-- valid direct coin-purchase source in your regions.
		------------------------------------------------------------

local advice =
	chain.routeAdvice
	and chain.routeAdvice[item]
	or nil


if #sources == 0
	and advice then


	------------------------------------------------------------
	-- STANDARD ROUTE MODE
	-- Used by Runes.
	------------------------------------------------------------

	if chain.strategyMode == 'routes' then

		table.insert(
			output,
			'| '
			.. formatRouteAdvice(
				item,
				advice.fastest
			)
		)


		table.insert(
			output,
			'| '
			.. formatRouteAdvice(
				item,
				advice.cheapest
			)
		)


	------------------------------------------------------------
	-- MANUAL TWO-COLUMN MODE
	-- Used by Ores and future specialized acquisition tables.
	------------------------------------------------------------

	elseif chain.strategyMode == 'manual' then

		table.insert(
			output,
			'| '
			.. tostring(
				advice.col1
				or '—'
			)
		)


		table.insert(
			output,
			'| '
			.. tostring(
				advice.col2
				or '—'
			)
		)


	------------------------------------------------------------
	-- UNKNOWN MODE
	------------------------------------------------------------

	else

		table.insert(
			output,
			'| style="text-align:center;" | —'
		)


		table.insert(
			output,
			'| style="text-align:center;" | —'
		)
	end


else

	table.insert(
		output,
		'| style="text-align:center;" | —'
	)


	table.insert(
		output,
		'| style="text-align:center;" | —'
	)
end
	end


	table.insert(
		output,
		'|}'
	)


	return table.concat(
		output,
		'\n'
	)
end
--------------------------------------------------------------------------------
-- DIVINE ENERGY-SPECIFIC FORMATTING
--------------------------------------------------------------------------------

local function formatPorterCell(entry)

	local porter =
		entry.porter


	if not porter then
		return '—'
	end


	return
		"'''[["
		.. porter.sign
		.. "]]'''"

		.. '<br>'

		.. formatNumber(
			porter.energy
		)

		.. ' energy + [['
		.. porter.jewellery
		.. ']]'

		.. '<br>'

		.. "'''"
		.. formatNumber(
			porter.charges
		)
		.. " charges'''"
end


--------------------------------------------------------------------------------
-- DIVINE ENERGY RENDERER
--------------------------------------------------------------------------------

local function renderDivineEnergy(
	frame,
	chain
)

	local output = {}


	----------------------------------------------------------------------------
	-- COLLAPSIBLE TABLE
	----------------------------------------------------------------------------

	table.insert(
		output,
		'{| class="wikitable mw-collapsible mw-collapsed" '
		.. 'data-expandtext="Expand" '
		.. 'data-collapsetext="Collapse"'
	)


	table.insert(
		output,
		'! Divine energy'
	)


	table.insert(
		output,
		'! Divination level'
	)


	table.insert(
		output,
		'! Colony region'
	)


	table.insert(
		output,
		'! Sign of the porter'
	)


	table.insert(
		output,
		'! Energy / divine charge'
	)


	----------------------------------------------------------------------------
	-- ROWS
	----------------------------------------------------------------------------

	for _, entry in ipairs(
		chain.items
	) do

		table.insert(
			output,
			'|-'
		)


		------------------------------------------------------------
		-- ENERGY
		------------------------------------------------------------

table.insert(
	output,
	'| [[File:'
	.. entry.item
	.. '.png|32px|link='
	.. entry.item
	.. ']] [['
	.. entry.item
	.. ']]'
)

		------------------------------------------------------------
		-- DIVINATION LEVEL
		------------------------------------------------------------

		table.insert(
			output,
			'| style="text-align:center;" | '
			.. tostring(
				entry.level
			)
		)


		------------------------------------------------------------
		-- COLONY LEAGUE REGION
		------------------------------------------------------------

		table.insert(
			output,
			'| style="text-align:center;" | '
			.. formatItemRegion(
				frame,
				chain,
				entry
			)
		)


		------------------------------------------------------------
		-- PORTER
		------------------------------------------------------------

		table.insert(
			output,
			'| '
			.. formatPorterCell(
				entry
			)
		)


		------------------------------------------------------------
		-- DIVINE CHARGE
		------------------------------------------------------------

		table.insert(
			output,
			'| style="text-align:center;" | '
			.. "'''"
			.. formatNumber(
				entry.divineCharge
			)
			.. "''' energy"
		)
	end


	table.insert(
		output,
		'|}'
	)


	return table.concat(
		output,
		'\n'
	)
end

--------------------------------------------------------------------------------
-- PUBLIC ENTRY POINT
--
-- Example:
--
-- {{#invoke:Sandbox/User:Dreke13|transmutation|chain=runes}}
-- {{#invoke:Sandbox/User:Dreke13|transmutation|chain=ores}}
--------------------------------------------------------------------------------

function p.transmutation(frame)

	local chainKey =
		mw.text.trim(
			tostring(
				frame.args.chain
				or ''
			)
		)


	chainKey =
		string.lower(
			chainKey
		)


	local chain =
		chains[chainKey]


	if not chain then

		return "'''Unknown Transmutation chain:''' <code>"
			.. mw.text.nowiki(
				chainKey
			)
			.. '</code>'
	end


if chain.renderer == 'divineEnergy' then

	return renderDivineEnergy(
		frame,
		chain
	)
end


return renderChain(
	frame,
	chain
)
end



return p