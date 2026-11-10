local p = {}

local checkType
do
	local libraryUtil = require("libraryUtil")
	checkType = libraryUtil.checkType
end

local hc = require("Module:Paramtest").has_content
local exchange = require("Module:Exchange")
local componentCosts = require("Module:Component costs")._main
local popResourceCost = require("Module:Pop resource cost")._calcvalue
local common = require("Module:Sandbox/User:Crolut/New skill calc/Skill calc/common")

local debugLog = common._debugLogger("priceGenerator")

local exchangePriceCache = {}
local storelineCache = {}

-- forward declarations
local getExchangePrice, getNumberedCount, addCalculatedCost,
	applyCalculatedCosts, blacklistHasValue, getSourceRank,
	chooseCandidate, getRuleField, getRuleSelectFields, getBucketRows,
	normalizeStoreFields, getStorelineCurrencies, storeMatches,
	getStorelineFields, getTypedItemCost,
	getHighAlchUseCost, getProductItemCost, getProductCostFields,
	ruleMatches, getMaterialQtyReduction, getNormalMaterialRule,
	getMaterialItemCost, getMaterialCostFields,
	applyAlternateMaterialReductions, getProfitLossFields,
	getXpCostFields, applyCalculatedCostFields, clearPriceFields,
	applyOutputFields


--[=[ getExchangePrice
-- Gets a cached Exchange price for an item and quantity
-- Inputs:
--      itemName   exact item name
--      quantity   item quantity, defaulting to 1
--      taxRate    optional product GE tax rate
-- Returns:
--      Exchange price, or nil when no price is available
--]=]
function getExchangePrice(itemName, quantity, taxRate)
	checkType("getExchangePrice", 1, itemName, "string", true)
	checkType("getExchangePrice", 2, quantity, "number", true)
	checkType("getExchangePrice", 3, taxRate, "number", true)

	if hc(itemName) == nil then
		return nil
	end

	local price = exchangePriceCache[itemName]
	if price == nil then
		price = exchange._price(itemName, 1, false, nil, -1, false)
		exchangePriceCache[itemName] = price ~= -1 and price or false
		price = exchangePriceCache[itemName]
	end
	if price == false then
		return nil
	end

	if taxRate ~= nil then
		price = price - math.floor(price * taxRate)
	end
	return price * (quantity or 1)
end

--[=[ getNumberedCount
-- Counts sequential numbered item fields for one prefix
-- Inputs:
--      data     source method table
--      prefix   numbered field prefix
-- Returns:
--      number of sequential Name fields
--]=]
function getNumberedCount(data, prefix)
	local count = 0
	while data[prefix .. "Name" .. (count + 1)] ~= nil do
		count = count + 1
	end
	return count
end

--[=[ addCalculatedCost
-- Adds one cost to the matching exact-currency calculated fields
-- Inputs:
--      fields     calculated field table
--      prefix     calculated field prefix
--      currency   exact currency name
--      cost       numeric amount to add
-- Returns:
--      matching currency index, or nil when the value is invalid
--]=]
function addCalculatedCost(fields, prefix, currency, cost)
	local amount = tonumber(cost)
	if currency == nil or amount == nil then
		return nil
	end

	local index = 1
	while fields[prefix .. "Currency" .. index] ~= nil do
		if fields[prefix .. "Currency" .. index] == currency then
			local field = prefix .. "Cost" .. index
			fields[field] = fields[field] + amount
			return index
		end
		index = index + 1
	end

	fields[prefix .. "Currency" .. index] = currency
	fields[prefix .. "Cost" .. index] = amount
	return index
end

--[=[ applyCalculatedCosts
-- Copies calculated currency costs into another calculated field group
-- Inputs:
--      fields         source calculated field table
--      sourcePrefix   source calculated field prefix
--      targetPrefix   destination calculated field prefix
--      multiplier     optional amount multiplier
--      target         optional destination table
-- Returns:
--      destination table containing copied calculated costs
--]=]
function applyCalculatedCosts(fields, sourcePrefix, targetPrefix, multiplier,
	target)
	local factor = tonumber(multiplier) or 1
	local ret = target or fields
	local index = 1

	while fields[sourcePrefix .. "Currency" .. index] ~= nil do
		addCalculatedCost(
			ret,
			targetPrefix,
			fields[sourcePrefix .. "Currency" .. index],
			fields[sourcePrefix .. "Cost" .. index] * factor
		)
		index = index + 1
	end

	return ret
end

--[=[ blacklistHasValue
-- Checks keyed and array-style blacklist entries for one value
-- Inputs:
--      blacklist      blacklist table
--      value          value to test
--      caseSensitive  whether text comparison preserves case
-- Returns:
--      whether the blacklist contains the value
--]=]
function blacklistHasValue(blacklist, value, caseSensitive)
	if value == nil then
		return false
	end

	local target = tostring(value)
	if not caseSensitive then
		target = target:lower()
	end

	if blacklist and blacklist[target] == true then
		return true
	end

	for _, entry in ipairs(blacklist or {}) do
		local current = tostring(entry)
		if not caseSensitive then
			current = current:lower()
		end
		if current == target then
			return true
		end
	end

	return false
end

--[=[ getSourceRank
-- Gets one price source's priority from an ordered source array
-- Inputs:
--      order    ordered source names
--      source   source name to find
-- Returns:
--      source position, or one position after the configured order
--]=]
function getSourceRank(order, source)
	for index, value in ipairs(order or {}) do
		if value == source then
			return index
		end
	end
	return #(order or {}) + 1
end

--[=[ chooseCandidate
-- Selects the best numeric candidate with configured tie priority
-- Inputs:
--      candidates   price candidates
--      highest      whether the highest value wins
--      order        ordered source priority for equal values
-- Returns:
--      selected candidate, or nil when no candidate has a numeric cost
--]=]
function chooseCandidate(candidates, highest, order)
	local selected

	for _, candidate in ipairs(candidates) do
		local value = tonumber(candidate.unitCost)
		if value ~= nil then
			local better = selected == nil
				or highest and value > selected.unitCost
				or not highest and value < selected.unitCost
			local tied = selected ~= nil and value == selected.unitCost

			if tied then
				better = getSourceRank(order, candidate.source)
					< getSourceRank(order, selected.source)
			end

			if better then
				candidate.unitCost = value
				selected = candidate
			end
		end
	end

	return selected
end

--[=[ getRuleField
-- Gets the bucket field mapped to one configured data field
-- Inputs:
--      rules      bucket rule
--      dataName   configured data field name
-- Returns:
--      matching bucket field, or nil when no mapping exists
--]=]
function getRuleField(rules, dataName)
	for _, field in ipairs(rules and rules.fields or {}) do
		if field.data == dataName then
			return field.bucket
		end
	end
	return nil
end

--[=[ getRuleSelectFields
-- Builds the unique bucket fields required by one bucket rule
-- Inputs:
--      rules   bucket rule
-- Returns:
--      sequential bucket field array
--]=]
function getRuleSelectFields(rules)
	local fields = {}
	local found = {}

	--[=[ add
	-- Adds one unique non-nil bucket field to the local selection array
	-- Inputs:
	--      field   bucket field name
	-- Returns:
	--      nothing
	--]=]
	local function add(field)
		if field ~= nil and not found[field] then
			found[field] = true
			fields[#fields + 1] = field
		end
	end

	add(rules and rules.itemField)
	add(rules and rules.matchField)
	for _, field in ipairs(rules and rules.fields or {}) do
		add(field.bucket)
	end
	return fields
end

--[=[ getBucketRows
-- Gets and caches raw Storeline rows for one item
-- Inputs:
--      itemName      exact item name
--      rules         Storeline bucket rule
--      includePacks  whether rows whose pack_of matches are included
-- Returns:
--      Storeline rows and whether the query succeeded
--]=]
function getBucketRows(itemName, rules, includePacks)
	if rules == nil or rules.name == nil or rules.itemField == nil then
		return nil, false
	end

	local mode = includePacks == true and "packs" or "direct"
	local itemCache = storelineCache[itemName]
	if itemCache ~= nil and itemCache[mode] ~= nil then
		local cached = itemCache[mode]
		return cached.rows, cached.success
	end

	local packField = includePacks == true
		and getRuleField(rules, "storePackOf") or nil
	local success, rows = pcall(function()
		local query = bucket(rules.name)
			.select(unpack(getRuleSelectFields(rules)))

		if packField ~= nil then
			query = query.where(bucket.Or(
				{ rules.itemField, itemName },
				{ packField, itemName }
			))
		else
			query = query.where(rules.itemField, itemName)
		end

		return query.run()
	end)

	if not success or type(rows) ~= "table" then
		rows = nil
		success = false
	end

	itemCache = itemCache or {}
	itemCache[mode] = {
		rows = rows,
		success = success,
	}
	storelineCache[itemName] = itemCache
	return rows, success
end

--[=[ normalizeStoreFields
-- Copies one supplied store identifier into the missing identifier
-- Inputs:
--      storeName   supplied Storeline store name
--      storePage   supplied Storeline store page
-- Returns:
--      normalized name, normalized page, and strict-pair flag
--]=]
function normalizeStoreFields(storeName, storePage)
	local originalName = storeName
	local originalPage = storePage

	if storeName == nil then
		storeName = storePage
	end
	if storePage == nil then
		storePage = storeName
	end

	local strict = type(originalName) == "string"
		and type(originalPage) == "string"
		and originalName ~= originalPage
	return storeName, storePage, strict
end

--[=[ getStorelineCurrencies
-- Resolves exact eligible Storeline currencies from one field value
-- Inputs:
--      value         Storeline currency value or array
--      pricingRules  pricing and Storeline rules
-- Returns:
--      sequential eligible exact-currency array
--]=]
function getStorelineCurrencies(value, pricingRules)
	local values = type(value) == "table" and value or { value }
	local aliases = (pricingRules.storelineRule or {}).currencyAliases or {}
	local blacklist = pricingRules.currencyBlacklist or {}
	local currencies = {}

	for _, currency in ipairs(values) do
		local name = tostring(currency or "")
		name = aliases[name] or name
		if name ~= "" and not blacklistHasValue(blacklist, name, true) then
			currencies[#currencies + 1] = name
		end
	end

	return currencies
end

--[=[ storeMatches
-- Checks whether one Storeline row matches supplied store identifiers
-- Inputs:
--      rowName    Storeline row store name
--      rowPage    Storeline row store page
--      storeName  normalized requested store name
--      storePage  normalized requested store page
--      strict     whether both identifiers must match
-- Returns:
--      whether the Storeline row matches
--]=]
function storeMatches(rowName, rowPage, storeName, storePage, strict)
	if storeName == nil and storePage == nil then
		return true
	end
	if strict then
		return rowName == storeName and rowPage == storePage
	end
	return rowName == storeName or rowPage == storeName
		or rowName == storePage or rowPage == storePage
end

--[=[ getStorelineFields
-- Selects the best eligible Storeline candidate in one exact currency
-- Inputs:
--      itemName       exact item name
--      useBuyPrice    whether to use store buy rather than sell price
--      targetCurrency exact required currency
--      storeName      optional store name restriction
--      storePage      optional store page restriction
--      totalQty       total reduced material quantity needed
--      args           calculator arguments
--      pricingRules   pricing and Storeline rules
-- Returns:
--      selected Storeline price candidate, or nil
--]=]
function getStorelineFields(itemName, useBuyPrice, targetCurrency, storeName,
	storePage, totalQty, args, pricingRules)
	local strict
	storeName, storePage, strict = normalizeStoreFields(storeName, storePage)

	if storeName == false or storePage == false then
		return nil
	end

	local rules = pricingRules.storelineRule or {}
	local includePacks = not useBuyPrice
	local rows = getBucketRows(itemName, rules, includePacks)
	if rows == nil then
		debugLog("Loaded Storeline rows", {
			itemName = itemName,
			useBuyPrice = useBuyPrice,
			targetCurrency = targetCurrency,
			storeName = storeName,
			storePage = storePage,
			totalQty = totalQty,
			args = args,
			pricingRules = pricingRules,
			rows = nil,
		})
		return nil
	end

	debugLog("Loaded Storeline rows", {
		itemName = itemName,
		useBuyPrice = useBuyPrice,
		targetCurrency = targetCurrency,
		storeName = storeName,
		storePage = storePage,
		totalQty = totalQty,
		args = args,
		pricingRules = pricingRules,
		rows = rows,
	})

	local priceName = useBuyPrice and "storeBuyPrice" or "storeSellPrice"
	local priceField = getRuleField(rules, priceName)
	local currencyField = getRuleField(rules, "storeCurrency")
	local historicalField = getRuleField(rules, "storeHistorical")
	local membersField = getRuleField(rules, "storeMembers")
	local nameField = getRuleField(rules, "storeName")
	local pageField = getRuleField(rules, "storePage")
	local stockField = getRuleField(rules, "storeStock")
	local infiniteField = getRuleField(rules, "storeStockInfinite")
	local packAmountField = getRuleField(rules, "storePackAmount")
	local packOfField = getRuleField(rules, "storePackOf")
	local stores = pricingRules.storeBlacklist or {}
	local coverage = tonumber(pricingRules.materialStoreStockCoverage) or 0

	if coverage < 0 then
		coverage = 0
	end

	local needed = tonumber(totalQty)
	local minimumStock = needed and needed > 0 and needed * coverage or 0
	local selected

	for _, row in ipairs(rows) do
		local rowName = row[nameField]
		local rowPage = row[pageField]
		local historical = row[historicalField]
		local members = row[membersField]
		local rowItem = row[rules.itemField]
		local packOf = row[packOfField]
		local isPack = includePacks and packOf == itemName
		local direct = rowItem == itemName
		local blocked = blacklistHasValue(stores, rowName, false)
			or blacklistHasValue(stores, rowPage, false)
		local eligible = historical ~= true
			and not blocked
			and (direct or isPack)
			and not (args and args.disp == "Free-to-Play" and members == true)
			and storeMatches(rowName, rowPage, storeName, storePage, strict)

		local packAmount = isPack and tonumber(row[packAmountField]) or nil

		if isPack and (packAmount == nil or packAmount <= 0) then
			eligible = false
		end

		local stockMultiplier = packAmount or 1
		local availableStock

		if eligible
			and not useBuyPrice and minimumStock > 0
		then
			if row[infiniteField] ~= true then
				local stock = tonumber(row[stockField])
				availableStock = stock and stock * stockMultiplier
				eligible = availableStock ~= nil
					and availableStock >= minimumStock
			end
		elseif eligible and not useBuyPrice then
			local stock = tonumber(row[stockField])
			availableStock = stock and stock * stockMultiplier
		end

		if eligible then
			local price = tonumber(row[priceField])

			if price ~= nil and isPack then
				price = price / packAmount
			end

			local currencies = getStorelineCurrencies(
				row[currencyField],
				pricingRules
			)
			local hasCurrency = false

			for _, currency in ipairs(currencies) do
				if currency == targetCurrency then
					hasCurrency = true
					break
				end
			end

			if price ~= nil and hasCurrency then
				local better = selected == nil
					or useBuyPrice and price > selected.unitCost
					or not useBuyPrice and price < selected.unitCost

				if better then
					selected = {
						unitCost = price,
						currency = targetCurrency,
						source = "store",
						storeName = rowName or rowPage,
						storePage = rowPage or rowName,
						storeItem = rowItem,
						packAmount = packAmount,
						storeStock = availableStock,
						storeStockCoverage = needed
							and needed > 0
							and availableStock
							and availableStock / needed
							or nil,
					}
				end
			end
		end
	end

	debugLog("Selected Storeline candidate", {
		itemName = itemName,
		useBuyPrice = useBuyPrice,
		targetCurrency = targetCurrency,
		storeName = storeName,
		storePage = storePage,
		totalQty = totalQty,
		args = args,
		pricingRules = pricingRules,
		rows = rows,
		selected = selected,
	})

	return selected
end

--[=[ getTypedItemCost
-- Gets one typed material's unit cost
-- Inputs:
--      itemName   exact material name
--      itemType   item, invComponent, or popResource
-- Returns:
--      unit cost, currency, source, and whether the type was handled
--]=]
function getTypedItemCost(itemName, itemType)
	local typeName = itemType or "item"
	if typeName == "item" then
		return nil, nil, nil, false
	end

	if typeName == "invComponent" then
		local success, result = pcall(componentCosts, itemName)
		local cost = success and type(result) == "table"
			and tonumber(result.price) or nil
		return cost, "coins", typeName, true
	end

	if typeName == "popResource" then
		local success, cost = pcall(popResourceCost, itemName, 1, false)
		return success and tonumber(cost) or nil, "coins", typeName, true
	end

	return nil, nil, typeName, true
end

--[=[ getHighAlchUseCost
-- Calculates the selected normal high-alchemy method cost
-- Inputs:
--      pricingRules   selected high-alchemy method and pricing rules
-- Returns:
--      complete cost per high-alchemy use, or nil
--]=]
function getHighAlchUseCost(pricingRules)
	local rule = pricingRules.highAlchMethodRule
	if type(rule) ~= "table" then
		return nil
	end

	local total = 0
	for _, material in ipairs(rule.materials or {}) do
		local quantity = tonumber(material.quantity)
		local unitCost = getExchangePrice(material.name, 1)
		if quantity == nil or unitCost == nil then
			return nil
		end
		total = total + unitCost * quantity
	end
	return total
end

--[=[ getProductItemCost
-- Resolves one product's explicit or best dynamic unit value
-- Inputs:
--      item          normalized product fields
--      args          calculator arguments
--      pricingRules  product pricing rules
-- Returns:
--      selected product pricing and source metadata
--]=]
function getProductItemCost(item, args, pricingRules)
	local currency = item.currency or "coins"
	if item.cost == false then
		return {
			currency = currency,
			tradable = item.tradable,
			highAlch = item.highAlch,
			disabled = true,
		}
	end

	if item.cost ~= nil then
		local ret = {
			unitCost = tonumber(item.cost),
			currency = currency,
			source = item.source or "data",
			tradable = item.tradable,
			highAlch = item.highAlch,
		}
		if ret.source == "store" then
			ret.storeName = item.storeName
			ret.storePage = item.storePage
		end
		return ret
	end

	local tradable = item.tradable
	local highAlch = item.highAlch

	local candidates = {}
	if tradable == true and currency == "coins" then
		candidates[#candidates + 1] = {
			unitCost = getExchangePrice(item.name, 1, pricingRules.geTaxRate),
			currency = "coins",
			source = "ge",
		}
	end

	local store = getStorelineFields(
		item.name,
		true,
		currency,
		item.storeName,
		item.storePage,
		nil,
		args,
		pricingRules
	)
	if store ~= nil then
		candidates[#candidates + 1] = store
	end

	local highAlchValue = tonumber(highAlch)
	if highAlchValue ~= nil then
		local overrides = pricingRules.highAlchCostOverrides or {}
		local override = overrides[currency]
		local highAlchCost
		local highAlchMethod

		if override ~= nil then
			highAlchCost = tonumber(override)
		else
			highAlchCost = getHighAlchUseCost(pricingRules)
			highAlchMethod = pricingRules.highAlchMethod
		end

		local net = highAlchCost and highAlchValue - highAlchCost or nil
		local conversions = pricingRules.highAlchCurrencyConversions or {}
		local allowed = currency == "coins" or conversions[currency] == true

		debugLog("Resolved high alchemy candidate", {
			item = item,
			currency = currency,
			highAlchValue = highAlchValue,
			highAlchCost = highAlchCost,
			highAlchMethod = highAlchMethod,
			net = net,
			allowed = allowed,
		})

		if net ~= nil and net > 0 and allowed then
			candidates[#candidates + 1] = {
				unitCost = net,
				currency = currency,
				source = "highalch",
				highAlchValue = highAlchValue,
				highAlchCost = highAlchCost,
				highAlchMethod = highAlchMethod,
			}
		end
	end

	local selected = chooseCandidate(
		candidates,
		true,
		pricingRules.productPriceSourceOrder
	) or {}
	selected.currency = selected.currency or currency
	selected.tradable = tradable
	selected.highAlch = highAlch

	debugLog("Resolved product item cost", {
		item = item,
		args = args,
		pricingRules = pricingRules,
		candidates = candidates,
		selected = selected,
	})

	return selected
end

--[=[ getProductCostFields
-- Calculates numbered product and productOther values for one method
-- Inputs:
--      method        source method data
--      result        existing action and output calculations
--      args          calculator arguments
--      pricingRules  product pricing rules
-- Returns:
--      numbered, aggregate, and primary-output product fields
--]=]
function getProductCostFields(method, result, args, pricingRules)
	local actions = tonumber(result.actionsNeeded) or 0
	local ret = {
		productCostDetails = {},
		productCostCurrencyComplete = {},
	}
	local hasProducts = false
	local currencyStates = {}
	local currencyOrder = {}

	local function getCurrencyState(currency)
		if currency == nil then
			return nil
		end

		local state = currencyStates[currency]
		if state == nil then
			state = {
				hasItem = false,
				hasCost = false,
				costPerAction = 0,
				totalCost = 0,
			}
			currencyStates[currency] = state
			currencyOrder[#currencyOrder + 1] = currency
		end
		return state
	end

	--[=[ addProduct
	-- Calculates and adds one numbered product to the local result
	-- Inputs:
	--      prefix         product or productOther
	--      index          numbered product index
	--      quantity       resolved per-action quantity
	--      totalQuantity  resolved total training quantity
	-- Returns:
	--      nothing
	--]=]

	local function addProduct(prefix, index, quantity, totalQuantity)
		local name = method[prefix .. "Name" .. index]
		if type(name) ~= "string" or name == "" then
			return
		end

		hasProducts = true
		local qty = tonumber(quantity) or 1
		local totalQty = tonumber(totalQuantity) or qty * actions
		local perActionValue = method[prefix .. "CostPerAction" .. index]
		local currency = method[prefix .. "Currency" .. index] or "coins"
		local source = method[prefix .. "CostSource" .. index]
		local item
		local unitCost
		local costPerAction
		local totalCost

		if perActionValue == false then
			item = {
				currency = currency,
				tradable = method[prefix .. "Tradable" .. index],
				highAlch = method[prefix .. "HighAlch" .. index],
				disabled = true,
			}
		elseif perActionValue ~= nil then
			costPerAction = tonumber(perActionValue)
			totalCost = costPerAction and costPerAction * actions or nil
			item = {
				currency = currency,
				source = source or "data",
				tradable = method[prefix .. "Tradable" .. index],
				highAlch = method[prefix .. "HighAlch" .. index],
			}
			if item.source == "store" then
				item.storeName = method[prefix .. "StoreName" .. index]
				item.storePage = method[prefix .. "StorePage" .. index]
			end
		else
			item = getProductItemCost({
				name = name,
				cost = method[prefix .. "Cost" .. index],
				currency = method[prefix .. "Currency" .. index],
				source = source,
				tradable = method[prefix .. "Tradable" .. index],
				highAlch = method[prefix .. "HighAlch" .. index],
				storeName = method[prefix .. "StoreName" .. index],
				storePage = method[prefix .. "StorePage" .. index],
			}, args, pricingRules)
			unitCost = tonumber(item.unitCost)
			currency = item.currency or currency
			if unitCost ~= nil then
				costPerAction = unitCost * qty
				totalCost = unitCost * totalQty
			end
		end

		debugLog("Resolved numbered product", {
			method = method,
			result = result,
			args = args,
			pricingRules = pricingRules,
			prefix = prefix,
			index = index,
			quantity = qty,
			totalQuantity = totalQty,
			perActionValue = perActionValue,
			item = item,
			unitCost = unitCost,
			costPerAction = costPerAction,
			totalCost = totalCost,
		})

		ret[prefix .. "Name" .. index] = name
		ret[prefix .. "Qty" .. index] = qty
		ret[prefix .. "Tradable" .. index] = item.tradable
		ret[prefix .. "Cost" .. index] = unitCost
		ret[prefix .. "CostPerAction" .. index] = costPerAction
		ret[prefix .. "Currency" .. index] = currency
		ret[prefix .. "CostSource" .. index] = item.source
		ret[prefix .. "HighAlch" .. index] = item.highAlch
		ret[prefix .. "StoreName" .. index] = item.storeName
		ret[prefix .. "StorePage" .. index] = item.storePage

		ret.productCostDetails[#ret.productCostDetails + 1] = {
			name = name,
			prefix = prefix,
			index = index,
			source = item.source,
			storeName = type(item.storeName) == "string"
				and item.storeName or nil,
			storePage = type(item.storePage) == "string"
				and item.storePage or nil,
			highAlchMethod = item.highAlchMethod,
		}

		local state = getCurrencyState(currency)
		if state ~= nil then
			state.hasItem = true
			if costPerAction ~= nil and totalCost ~= nil then
				state.hasCost = true
				state.costPerAction = state.costPerAction + costPerAction
				state.totalCost = state.totalCost + totalCost
			end
		end

		if prefix == "product" and index == 1 then
			ret.outputItem = name
			ret.outputQty = qty
			ret.outputTradable = item.tradable
			ret.outputCurrency = currency
			ret.outputUnitPrice = unitCost
			ret.outputPrice = costPerAction
			ret.outputPriceSource = item.source
			ret.outputStoreName = item.storeName
			ret.outputStorePage = item.storePage
			ret.highAlchValue = item.highAlchValue
			ret.highAlchCost = item.highAlchCost
			ret.highAlchMethod = item.highAlchMethod
		end
	end

	for index = 1, getNumberedCount(method, "product") do
		local qty = method["productQty" .. index]
		local totalQty
		if index == 1 then
			qty = result.outputQty or qty
			totalQty = result.totalOutputQty
		end
		addProduct("product", index, qty, totalQty)
	end

	for index = 1, getNumberedCount(method, "productOther") do
		addProduct("productOther", index, method["productOtherQty" .. index])
	end

	local resolvedCurrencies = 0
	for _, currency in ipairs(currencyOrder) do
		local state = currencyStates[currency]
		ret.productCostCurrencyComplete[currency] = state.hasCost

		if state.hasCost then
			resolvedCurrencies = resolvedCurrencies + 1
			addCalculatedCost(
				ret,
				"calculatedProductCostPerAction",
				currency,
				state.costPerAction
			)
			addCalculatedCost(
				ret,
				"calculatedTotalProductCost",
				currency,
				state.totalCost
			)
		end
	end

	ret.calculatedProductCostComplete =
		resolvedCurrencies > 0 or not hasProducts
	ret.calculatedProductCostHasItems = hasProducts

	debugLog("Built product cost fields", {
		method = method,
		result = result,
		args = args,
		pricingRules = pricingRules,
		fields = ret,
	})

	return ret
end

--[=[ ruleMatches
-- Checks whether one special rule matches the method and arguments
-- Inputs:
--      rule          special rule
--      method        source method data
--      args          calculator arguments
--      pricingRules  rule matcher and pricing rules
-- Returns:
--      whether the rule is active and matched
--]=]
function ruleMatches(rule, method, args, pricingRules)
	if type(pricingRules.getSpecialRule) ~= "function" then
		return false
	end
	if pricingRules.getSpecialRule({ rule }, method, args) == nil then
		return false
	end
	return rule.arg == nil or args and args[rule.arg] == true
end

--[=[ getMaterialQtyReduction
-- Resolves one material's effective quantity reduction
-- Inputs:
--      rule      material-reduction rule
--      itemName  exact material name
--      args      calculator arguments
-- Returns:
--      normalized reduction and whether it affects the material
--]=]
function getMaterialQtyReduction(rule, itemName, args)
	if rule == nil then
		return 0, false
	end
	if rule.arg ~= nil and (args == nil or args[rule.arg] ~= true) then
		return 0, false
	end

	if rule.materials ~= nil then
		local found = false
		for _, name in ipairs(rule.materials) do
			if name == itemName then
				found = true
				break
			end
		end
		if not found then
			return 0, false
		end
	end

	local reduction = tonumber(rule.reduction) or 0
	if rule.doubleWithArg ~= nil
		and args ~= nil
		and args[rule.doubleWithArg] == true
	then
		reduction = reduction * 2
	end
	if reduction >= 1 then
		reduction = 1
	end
	return reduction, reduction > 0
end

--[=[ getNormalMaterialRule
-- Gets the first matching normal material-reduction rule
-- Inputs:
--      method        source method data
--      args          calculator arguments
--      pricingRules  material-reduction rules and matcher
-- Returns:
--      matching normal rule, or nil
--]=]
function getNormalMaterialRule(method, args, pricingRules)
	for _, rule in ipairs(pricingRules.materialReductionRules or {}) do
		if rule.alternateResult == nil
			and ruleMatches(rule, method, args, pricingRules)
		then
			return rule
		end
	end
	return nil
end

--[=[ getMaterialItemCost
-- Resolves one material's explicit, typed, GE, or Storeline unit cost
-- Inputs:
--      item          normalized material fields
--      args          calculator arguments
--      pricingRules  material pricing rules
-- Returns:
--      selected material pricing and source metadata
--]=]
function getMaterialItemCost(item, args, pricingRules)
	local currency = item.currency or "coins"
	if item.cost == false then
		return {
			currency = currency,
			tradable = item.tradable,
			disabled = true,
		}
	end

	if item.cost ~= nil then
		local ret = {
			unitCost = tonumber(item.cost),
			currency = currency,
			source = item.source or "data",
			tradable = item.tradable,
		}
		if ret.source == "store" then
			ret.storeName = item.storeName
			ret.storePage = item.storePage
		end
		return ret
	end

	local unitCost, typedCurrency, source, typed = getTypedItemCost(
		item.name,
		item.type
	)
	if typed then
		return {
			unitCost = unitCost,
			currency = typedCurrency,
			source = source,
			tradable = nil,
		}
	end

	local tradable = item.tradable

	local candidates = {}
	if tradable == true and currency == "coins" then
		candidates[#candidates + 1] = {
			unitCost = getExchangePrice(item.name, 1),
			currency = "coins",
			source = "ge",
		}
	end

	local store = getStorelineFields(
		item.name,
		false,
		currency,
		item.storeName,
		item.storePage,
		item.totalQty,
		args,
		pricingRules
	)
	if store ~= nil then
		candidates[#candidates + 1] = store
	end

	local selected = chooseCandidate(
		candidates,
		false,
		pricingRules.materialPriceSourceOrder
	) or {}
	selected.currency = selected.currency or currency
	selected.tradable = tradable

	debugLog("Resolved material item cost", {
		item = item,
		args = args,
		pricingRules = pricingRules,
		candidates = candidates,
		selected = selected,
	})

	return selected
end

--[=[ getMaterialCostFields
-- Calculates reduced quantities and prices for all numbered materials
-- Inputs:
--      method         source method data
--      actionsNeeded  total actions required
--      args           calculator arguments
--      pricingRules   material pricing rules
--      reductionRule  normal or alternate quantity-reduction rule
-- Returns:
--      numbered, aggregate, per-currency, and reference material fields
--]=]
function getMaterialCostFields(method, actionsNeeded, args, pricingRules,
	reductionRule)
	local actions = tonumber(actionsNeeded) or 0
	local fields = {
		materialPriceDetails = {},
		materialCostCurrencyComplete = {},
	}
	local hasRequiredMaterials = false
	local allTradable = true
	local source
	local reductionApplied = false
	local appliedReduction
	local currencyStates = {}
	local currencyOrder = {}

	local function getCurrencyState(currency)
		if currency == nil then
			return nil
		end

		local state = currencyStates[currency]
		if state == nil then
			state = {
				hasMaterial = false,
				hasCost = false,
				costPerAction = 0,
				totalCost = 0,
				hasOriginalCost = false,
				originalCost = 0,
			}
			currencyStates[currency] = state
			currencyOrder[#currencyOrder + 1] = currency
		end
		return state
	end

	for index = 1, getNumberedCount(method, "material") do
		local name = method["materialName" .. index]
		if type(name) == "string" and name ~= "" then
			local originalQty = tonumber(method["materialQty" .. index]) or 1
			local reduction, affected =
				getMaterialQtyReduction(reductionRule, name, args)
			local qty = originalQty

			if affected then
				reductionApplied = true
				appliedReduction = reduction
				qty = reduction >= 1 and 0
					or math.ceil(originalQty * (1 - reduction))
			end

			local prefix = "material"
			local currency = method[prefix .. "Currency" .. index] or "coins"
			local fullReduction =
				affected and reduction >= 1
			local item = {
				currency = currency,
				tradable = method[prefix .. "Tradable" .. index],
			}
			local unitCost
			local costPerAction
			local originalItemCost

			if fullReduction then
				costPerAction = 0
			else
				local supplied = method[prefix .. "CostPerAction" .. index]

				if supplied == false then
					item.disabled = true
				elseif supplied ~= nil then
					local suppliedCost = tonumber(supplied)

					if originalQty == 0 then
						costPerAction = suppliedCost == 0 and 0 or nil
					else
						costPerAction =
							qty == originalQty
								and suppliedCost
								or suppliedCost
									and suppliedCost / originalQty * qty
					end

					item.source = method[
						prefix .. "CostSource" .. index
					] or "data"

					if item.source == "store" then
						item.storeName = method[prefix .. "StoreName" .. index]
						item.storePage = method[prefix .. "StorePage" .. index]
					end

					originalItemCost = suppliedCost
				else
					item = getMaterialItemCost({
						name = name,
						type = method[prefix .. "Type" .. index],
						cost = method[prefix .. "Cost" .. index],
						currency = method[prefix .. "Currency" .. index],
						source = method[prefix .. "CostSource" .. index],
						tradable = method[prefix .. "Tradable" .. index],
						storeName = method[prefix .. "StoreName" .. index],
						storePage = method[prefix .. "StorePage" .. index],
						totalQty = qty * actions,
					}, args, pricingRules)

					unitCost = tonumber(item.unitCost)
					currency = item.currency or currency

					if unitCost ~= nil then
						costPerAction = unitCost * qty
						originalItemCost = unitCost * originalQty
					end
				end
			end

			debugLog("Resolved numbered material", {
				method = method,
				actionsNeeded = actionsNeeded,
				args = args,
				pricingRules = pricingRules,
				reductionRule = reductionRule,
				index = index,
				name = name,
				originalQty = originalQty,
				reduction = reduction,
				affected = affected,
				qty = qty,
				fullReduction = fullReduction,
				item = item,
				unitCost = unitCost,
				costPerAction = costPerAction,
				originalItemCost = originalItemCost,
			})

			fields[prefix .. "Name" .. index] = name
			fields[prefix .. "Type" .. index] = method[
				prefix .. "Type" .. index
			]
			fields[prefix .. "Qty" .. index] = qty
			fields[prefix .. "Tradable" .. index] = item.tradable
			fields[prefix .. "Cost" .. index] = unitCost
			fields[prefix .. "CostPerAction" .. index] = costPerAction
			fields[prefix .. "Currency" .. index] = currency
			fields[prefix .. "CostSource" .. index] = item.source
			fields[prefix .. "StoreName" .. index] = item.storeName
			fields[prefix .. "StorePage" .. index] = item.storePage

			fields.materialPriceDetails[
				#fields.materialPriceDetails + 1
			] = {
				item = name,
				source = item.source,
				storeName =
					type(item.storeName) == "string" and item.storeName or nil,
				storePage =
					type(item.storePage) == "string" and item.storePage or nil,
				storeItem = item.storeItem,
				packAmount = item.packAmount,
				storeStock = item.storeStock,
				storeStockCoverage = item.storeStockCoverage,
			}

			if qty > 0 and item.tradable ~= true then
				allTradable = false
			end

			local state = getCurrencyState(currency)
			if state ~= nil then
				if qty > 0 then
					hasRequiredMaterials = true
					state.hasMaterial = true
				end

				if costPerAction ~= nil then
					state.hasCost = true
					state.costPerAction = state.costPerAction + costPerAction
					state.totalCost = state.totalCost + costPerAction * actions

					if qty > 0
						and item.source ~= nil
					then
						if source == nil then
							source = item.source
						elseif source ~= item.source then
							source = "mixed"
						end
					end
				end

				if originalItemCost ~= nil then
					state.hasOriginalCost = true
					state.originalCost = state.originalCost + originalItemCost
				end
			end
		end
	end

	local resolvedCurrencies = 0
	for _, currency in ipairs(currencyOrder) do
		local state = currencyStates[currency]

		if state.hasMaterial or state.hasCost then
			fields.materialCostCurrencyComplete[currency] = state.hasCost
		end

		if state.hasCost then
			resolvedCurrencies = resolvedCurrencies + 1
			addCalculatedCost(
				fields,
				"calculatedMaterialCostPerAction",
				currency,
				state.costPerAction
			)
			addCalculatedCost(
				fields,
				"calculatedTotalMaterialCost",
				currency,
				state.totalCost
			)
		end
	end

	fields.calculatedMaterialCostComplete =
		resolvedCurrencies > 0 or not hasRequiredMaterials
	fields.calculatedMaterialCostHasItems = hasRequiredMaterials
	fields.materialTradable = allTradable
	fields.materialCostSource = source or "none"

	if reductionApplied then
		fields.materialCostReduction = appliedReduction
	end

	local currency1 = fields.calculatedMaterialCostPerActionCurrency1

	if currency1 ~= nil
		and fields["calculatedMaterialCostPerActionCurrency2"] == nil
	then
		fields.materialCurrency = currency1
		fields.materialCost = fields.calculatedMaterialCostPerActionCost1
		fields.totalMaterialCost = fields.calculatedTotalMaterialCostCost1

		local state = currencyStates[currency1]
		if reductionApplied and state ~= nil and state.hasOriginalCost
		then
			fields.materialCostOriginal = state.originalCost
		end
	elseif currency1 == nil and not hasRequiredMaterials
	then
		fields.materialCost = 0
		fields.totalMaterialCost = 0
	end

	debugLog("Built material cost fields", {
		method = method,
		actionsNeeded = actionsNeeded,
		args = args,
		pricingRules = pricingRules,
		reductionRule = reductionRule,
		fields = fields,
	})

	return fields
end

--[=[ applyAlternateMaterialReductions
-- Calculates every matching alternate material-reduction result
-- Inputs:
--      result        mutable calculated result
--      method        source method data
--      args          calculator arguments
--      pricingRules  alternate reduction rules and pricing rules
-- Returns:
--      supplied result with alternate calculated costs
--]=]
function applyAlternateMaterialReductions(result, method, args, pricingRules)
	for _, rule in ipairs(pricingRules.materialReductionRules or {}) do
		local config = rule.alternateResult
		if config ~= nil and ruleMatches(rule, method, args, pricingRules) then
			local fields = getMaterialCostFields(
				method,
				result.actionsNeeded,
				args,
				pricingRules,
				rule
			)

			if type(config.unitPriceField) == "string" then
				result[config.unitPriceField] = fields.materialCost
			end
			if type(config.totalPriceField) == "string" then
				result[config.totalPriceField] = fields.totalMaterialCost
			end
			if type(config.calculatedUnitCostPrefix) == "string" then
				applyCalculatedCosts(
					fields,
					"calculatedMaterialCostPerAction",
					config.calculatedUnitCostPrefix,
					nil,
					result
				)
			end
			if type(config.calculatedTotalCostPrefix) == "string" then
				applyCalculatedCosts(
					fields,
					"calculatedTotalMaterialCost",
					config.calculatedTotalCostPrefix,
					nil,
					result
				)
			end

			debugLog("Applied alternate material reduction", {
				result = result,
				method = method,
				args = args,
				pricingRules = pricingRules,
				rule = rule,
				fields = fields,
			})
		end
	end

	return result
end

--[=[ getProfitLossFields
-- Calculates scalar per-action and total profit or loss
-- Inputs:
--      outputPrice        product value per action
--      materialCost       material cost per action
--      totalMaterialCost  total material cost
--      actionsNeeded      total actions required
--      outputCurrency     exact product currency
--      materialCurrency   exact material currency
--      totalOutputValue   resolved total product value
-- Returns:
--      scalar profit, total values, and profit currency
--]=]
function getProfitLossFields(outputPrice, materialCost, totalMaterialCost,
	actionsNeeded, outputCurrency, materialCurrency, totalOutputValue)
	local actions = tonumber(actionsNeeded) or 0
	local outputCurr = outputCurrency or "coins"
	local materialCurr = materialCurrency or "coins"
	local totalOutputPrice = tonumber(totalOutputValue)
	local actionCost = materialCost or 0
	local totalCost = totalMaterialCost or 0
	local profitLoss
	local totalProfitLoss

	if totalOutputPrice == nil and outputPrice ~= nil then
		totalOutputPrice = outputPrice * actions
	end
	if outputPrice ~= nil
		and (outputCurr == materialCurr or actionCost == 0)
	then
		profitLoss = outputPrice - actionCost
	end
	if totalOutputPrice ~= nil
		and (outputCurr == materialCurr or totalCost == 0)
	then
		totalProfitLoss = totalOutputPrice - totalCost
	end

	return {
		profitLoss = profitLoss,
		totalOutputPrice = totalOutputPrice,
		totalProfitLoss = totalProfitLoss,
		profitCurrency = (profitLoss ~= nil or totalProfitLoss ~= nil)
			and outputCurr or nil,
	}
end

--[=[ getXpCostFields
-- Calculates scalar XP costs and profit-per-XP values
-- Inputs:
--      materialCost       material cost per action
--      totalMaterialCost  total material cost
--      profitLoss         profit or loss per action
--      totalProfitLoss    total profit or loss
--      actionXp           action XP including bonus XP
--      actionXpNoBxp      action XP excluding bonus XP
--      totalExp           total experience gained
-- Returns:
--      scalar XP-cost and profit-per-XP fields
--]=]
function getXpCostFields(materialCost, totalMaterialCost, profitLoss,
	totalProfitLoss, actionXp, actionXpNoBxp, totalExp)
	local ret = {}
	if materialCost ~= nil and actionXp and actionXp ~= 0 then
		ret.xpCost = materialCost / actionXp
	end
	if materialCost ~= nil and actionXpNoBxp and actionXpNoBxp ~= 0 then
		ret.xpCostNoBxp = materialCost / actionXpNoBxp
	end
	if profitLoss ~= nil and actionXp and actionXp ~= 0 then
		ret.profitPerXp = profitLoss / actionXp
	end
	if profitLoss ~= nil and actionXpNoBxp and actionXpNoBxp ~= 0 then
		ret.profitPerXpNoBxp = profitLoss / actionXpNoBxp
	end
	if totalMaterialCost ~= nil and totalExp and totalExp ~= 0 then
		ret.totalXpCost = totalMaterialCost / totalExp
	end
	if totalProfitLoss ~= nil and totalExp and totalExp ~= 0 then
		ret.totalProfitPerXp = totalProfitLoss / totalExp
	end
	return ret
end

--[=[ applyCalculatedCostFields
-- Builds multi-currency XP-cost, profit, and profit-per-XP fields
-- Inputs:
--      result   mutable calculated result
-- Returns:
--      supplied result with calculated currency groups
--]=]
function applyCalculatedCostFields(result)
	local materialComplete = result.calculatedMaterialCostComplete == true
	local hasProducts = result.calculatedProductCostHasItems == true
	local materialCurrencies = result.materialCostCurrencyComplete or {}
	local productCurrencies = result.productCostCurrencyComplete or {}

	local function applyAvailableCosts(
		sourcePrefix,
		targetPrefix,
		multiplier,
		otherCurrencies
	)
		local factor = tonumber(multiplier) or 1
		local index = 1

		while result[sourcePrefix .. "Currency" .. index] ~= nil do
			local currency = result[sourcePrefix .. "Currency" .. index]

			if otherCurrencies[currency] ~= false then
				addCalculatedCost(
					result,
					targetPrefix,
					currency,
					result[sourcePrefix .. "Cost" .. index] * factor
				)
			end

			index = index + 1
		end
	end

	result.calculatedXpCostComplete = materialComplete

	if materialComplete then
		local actionXp = tonumber(result.actionXp)
		local noBxp = tonumber(result.actionXpNoBxp)
		local totalExp = tonumber(result.totalExp)

		if actionXp and actionXp ~= 0 then
			applyCalculatedCosts(
				result,
				"calculatedMaterialCostPerAction",
				"calculatedXpCost",
				1 / actionXp
			)
		end

		if noBxp and noBxp ~= 0 then
			applyCalculatedCosts(
				result,
				"calculatedMaterialCostPerAction",
				"calculatedXpCostNoBxp",
				1 / noBxp
			)
		end

		if totalExp and totalExp ~= 0 then
			applyCalculatedCosts(
				result,
				"calculatedTotalMaterialCost",
				"calculatedTotalXpCost",
				1 / totalExp
			)
		end
	end

	result.calculatedProfitLossComplete = false

	if not hasProducts then
		return result
	end

	applyAvailableCosts(
		"calculatedProductCostPerAction",
		"calculatedProfitLoss",
		nil,
		materialCurrencies
	)
	applyAvailableCosts(
		"calculatedMaterialCostPerAction",
		"calculatedProfitLoss",
		-1,
		productCurrencies
	)
	applyAvailableCosts(
		"calculatedTotalProductCost",
		"calculatedTotalProfitLoss",
		nil,
		materialCurrencies
	)
	applyAvailableCosts(
		"calculatedTotalMaterialCost",
		"calculatedTotalProfitLoss",
		-1,
		productCurrencies
	)

	local complete =result.calculatedProfitLossCurrency1 ~= nil
		or result["calculatedTotalProfitLossCurrency1"] ~= nil

	result.calculatedProfitLossComplete = complete

	if not complete then
		return result
	end

	local actionXp = tonumber(result.actionXp)
	local noBxp = tonumber(result.actionXpNoBxp)
	local totalExp = tonumber(result.totalExp)

	if actionXp and actionXp ~= 0 then
		applyCalculatedCosts(
			result,
			"calculatedProfitLoss",
			"calculatedProfitPerXp",
			1 / actionXp
		)
	end

	if noBxp and noBxp ~= 0 then
		applyCalculatedCosts(
			result,
			"calculatedProfitLoss",
			"calculatedProfitPerXpNoBxp",
			1 / noBxp
		)
	end

	if totalExp and totalExp ~= 0 then
		applyCalculatedCosts(
			result,
			"calculatedTotalProfitLoss",
			"calculatedTotalProfitPerXp",
			1 / totalExp
		)
	end

	return result
end

--[=[ clearPriceFields
-- Removes scalar pricing fields when no matching method data exists
-- Inputs:
--      result   mutable calculated result
-- Returns:
--      supplied result after scalar pricing fields are cleared
--]=]
function clearPriceFields(result)
	local fields = {
		"outputItem", "outputCurrency", "outputTradable",
		"outputUnitPrice", "outputPrice", "outputPriceSource",
		"outputStoreName", "outputStorePage", "materialCurrency",
		"materialTradable", "materialCost", "totalMaterialCost",
		"materialCostCurrencyComplete", "productCostCurrencyComplete",
		"calculatedMaterialCostHasItems", "materialCostSource",
		"materialCostReduction", "materialCostOriginal", "materialPriceDetails",
		"profitCurrency", "profitLoss", "totalOutputPrice", "totalProfitLoss",
		"xpCost", "xpCostNoBxp", "profitPerXp", "profitPerXpNoBxp",
		"totalXpCost", "totalProfitPerXp",
	}
	for _, field in ipairs(fields) do
		result[field] = nil
	end
	return result
end

--[=[ applyOutputFields
-- Applies complete product and material pricing to all result rows
-- Inputs:
--      results       mutable calculated result rows
--      data          source method rows
--      args          calculator arguments
--      pricingRules  combined product and material pricing rules
-- Returns:
--      supplied result rows with all pricing fields
--]=]
function applyOutputFields(results, data, args, pricingRules)
	debugLog("Starting price calculations", {
		results = results,
		data = data,
		args = args,
		pricingRules = pricingRules,
	})

	for index, result in ipairs(results) do
		local method = data and data[index] or nil

		debugLog("Starting method pricing", {
			index = index,
			result = result,
			method = method,
		})

		if method == nil then
			local before = mw.clone(result)

			clearPriceFields(result)

			debugLog("Cleared price fields", {
				index = index,
				before = before,
				result = result,
			})
		else
			local productFields = getProductCostFields(
				method,
				result,
				args,
				pricingRules
			)
			common._copyFields(result, productFields)

			debugLog("Applied product cost fields", {
				index = index,
				method = method,
				productFields = productFields,
				result = result,
			})

			local reductionRule = getNormalMaterialRule(
				method,
				args,
				pricingRules
			)

			debugLog("Selected material reduction rule", {
				index = index,
				method = method,
				args = args,
				pricingRules = pricingRules,
				rule = reductionRule,
			})

			local materialFields = getMaterialCostFields(
				method,
				result.actionsNeeded,
				args,
				pricingRules,
				reductionRule
			)
			common._copyFields(result, materialFields)
			applyAlternateMaterialReductions(result, method, args, pricingRules)

			debugLog("Applied material cost fields", {
				index = index,
				method = method,
				reductionRule = reductionRule,
				materialFields = materialFields,
				result = result,
			})

			local productCurrency =
				result.calculatedProductCostPerActionCurrency1
			local materialCurrencies =
				result.materialCostCurrencyComplete or {}
			local scalarComplete = productCurrency ~= nil
				and result.calculatedProductCostComplete
				and result.calculatedProductCostHasItems
				and materialCurrencies[productCurrency] ~= false
				and result["calculatedMaterialCostPerActionCurrency2"] == nil
				and result["calculatedProductCostPerActionCurrency2"] == nil
			local outputPrice = scalarComplete
				and result.calculatedProductCostPerActionCost1
				or nil
			local totalOutput = scalarComplete
				and result.calculatedTotalProductCostCost1
				or nil
			local profitCurrency = scalarComplete
				and result.calculatedProductCostPerActionCurrency1
				or nil

			debugLog("Resolved scalar pricing inputs", {
				index = index,
				result = result,
				productCurrency = productCurrency,
				materialCurrencies = materialCurrencies,
				scalarComplete = scalarComplete,
				outputPrice = outputPrice,
				totalOutput = totalOutput,
				profitCurrency = profitCurrency,
			})

			local profitFields = getProfitLossFields(
				outputPrice,
				scalarComplete and result.materialCost or nil,
				scalarComplete and result.totalMaterialCost or nil,
				result.actionsNeeded,
				profitCurrency,
				result.materialCurrency,
				totalOutput
			)
			common._copyFields(result, profitFields)

			debugLog("Applied profit and loss fields", {
				index = index,
				profitFields = profitFields,
				result = result,
			})

			local materialComplete =
				result.calculatedMaterialCostComplete == true
			local xpFields = getXpCostFields(
				materialComplete and result.materialCost or nil,
				materialComplete and result.totalMaterialCost or nil,
				result.profitLoss,
				result.totalProfitLoss,
				result.actionXp,
				result.actionXpNoBxp,
				result.totalExp
			)
			common._copyFields(result, xpFields)
			applyCalculatedCostFields(result)

			debugLog("Finished method pricing", {
				index = index,
				method = method,
				materialComplete = materialComplete,
				xpFields = xpFields,
				result = result,
			})
		end
	end

	debugLog("Finished price calculations", results)

	return results
end

p._getExchangePrice = getExchangePrice
p._getTypedItemCost = getTypedItemCost
p._getHighAlchUseCost = getHighAlchUseCost
p._getProductItemCost = getProductItemCost
p._getMaterialItemCost = getMaterialItemCost
p._getProductCostFields = getProductCostFields
p._getMaterialQtyReduction = getMaterialQtyReduction
p._getMaterialCostFields = getMaterialCostFields
p._applyAlternateMaterialReductions = applyAlternateMaterialReductions
p._getProfitLossFields = getProfitLossFields
p._getXpCostFields = getXpCostFields
p._applyCalculatedCostFields = applyCalculatedCostFields

p._setDebug = common._setDebug

p._applyOutputFields = applyOutputFields

return p