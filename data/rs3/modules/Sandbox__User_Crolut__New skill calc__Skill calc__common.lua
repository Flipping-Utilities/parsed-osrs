local p = {}

local checkType

do
	local libraryUtil = require("libraryUtil")
	checkType = libraryUtil.checkType
end

local bucketCache = {}
local activeDebug
local debugLog

-- forward declarations
local copySequence, copyMethodRows, copyFields, getBucketSelectFields,
      getBucketRows, getBucketField, getPreferredBucketRow,
      applyItemInfoBucketData, getStorelineCurrency, getStorelineCandidate,
      applyStorelineBucketData


-- debug helpers --
--[=[ debugLogger
-- Creates a logger for one module category
-- Inputs:
--      category  exact module debug category
-- Returns:
--      logger function accepting a message and optional value
--]=]
local function debugLogger(category)
	checkType("debugLogger", 1, category, "string")

	return function(message, value)
		if activeDebug ~= "all"
			and activeDebug ~= category
		then
			return
		end

		checkType("debugLog", 1, message, "string")

		local label = "[" .. category .. "] " .. message

		if value == nil then
			mw.log(label)
		else
			mw.logObject(value, label)
		end
	end
end

--[=[ setDebug
-- Sets the active debug category for the calculator invocation
-- Inputs:
--      debug  exact module category, all, or nil
-- Returns:
--      nothing
--]=]
local function setDebug(debug)
	checkType("setDebug", 1, debug, "string", true)

	activeDebug = debug

	debugLog("Debug logging initialized", {
		debug = activeDebug,
	})
end


debugLog = debugLogger("common")


-- generic helpers --
--[=[ copySequence
-- Copies array-style data from a read-only table into a mutable table
-- Inputs:
--      src     array-style source table
-- Returns:
--      mutable copy containing the same indexed values as src
--]=]
function copySequence(src)
	checkType("copySequence", 1, src, "table")

	local dst = {}
	for index, value in ipairs(src) do
		dst[index] = value
	end

	return dst
end

--[=[ copyMethodRows
-- Copies source data rows into mutable row tables
-- Inputs:
--      rows    array-style source data rows
-- Returns:
--      copied array-style source data rows
--]=]
function copyMethodRows(rows)
	checkType("copyMethodRows", 1, rows, "table")

	local copiedRows = {}

	for rowIndex, row in ipairs(rows) do
		local copiedRow = {}

		for fieldName, value in pairs(row) do
			copiedRow[fieldName] = value
		end

		copiedRows[rowIndex] = copiedRow
	end

	return copiedRows
end

--[=[ copyFields
-- Merges optional fields into an existing table while preserving the
-- destination table reference used by the caller
-- Inputs:
--      dst     destination table that receives copied fields
--      src     optional source table of fields to copy into dst
-- Returns:
--      destination table after any source fields have been copied
--]=]
function copyFields(dst, src)
	checkType("copyFields", 1, dst, "table")

	if src == nil then
		return dst
	end

	checkType("copyFields", 2, src, "table")

	for key, value in pairs(src) do
		dst[key] = value
	end

	return dst
end


-- bucket helpers --
--[=[ getBucketSelectFields
-- Gets the unique bucket fields required by one bucket rule
-- Inputs:
--      rules   bucket query rule
-- Returns:
--      array-style table of bucket fields to select
--]=]
function getBucketSelectFields(rules)
	checkType("getBucketSelectFields", 1, rules, "table")

	local selectLookup = {}
	local selectFields = {}

	local function addSelectField(field)
		if field ~= nil and not selectLookup[field] then
			selectLookup[field] = true
			table.insert(selectFields, field)
		end
	end

	addSelectField(rules.itemField)
	addSelectField(rules.matchField)

	for _, fieldPair in ipairs(rules.fields or {}) do
		addSelectField(fieldPair.bucket)
	end

	return selectFields
end

--[=[ getBucketRows
-- Gets and caches all bucket rows for one item and rule
-- Inputs:
--      itemName  exact item name used by the bucket query
--      rules     bucket query rule
-- Returns:
--      bucket rows, or nil when no rows are available
--]=]
function getBucketRows(itemName, rules)
	checkType("getBucketRows", 1, itemName, "string")
	checkType("getBucketRows", 2, rules, "table")

	local rulesCache = bucketCache[rules]

	if rulesCache == nil then
		rulesCache = {}
		bucketCache[rules] = rulesCache
	end

	if rulesCache[itemName] ~= nil then
		return rulesCache[itemName] or nil
	end

	local selectFields = getBucketSelectFields(rules)
	local success, rows = pcall(function()
		return bucket(rules.name)
			.select(unpack(selectFields))
			.where(rules.itemField, itemName)
			.run()
	end)

	if not success or type(rows) ~= "table" or #rows == 0 then
		rulesCache[itemName] = false
		return nil
	end

	rulesCache[itemName] = rows

	return rows
end

--[=[ getBucketField
-- Gets a bucket value using its configured data field name
-- Inputs:
--      row        bucket row
--      rules      bucket query rule
--      fieldName  configured data field name
-- Returns:
--      matching bucket value, or nil when no mapping exists
--]=]
function getBucketField(row, rules, fieldName)
	checkType("getBucketField", 1, row, "table")
	checkType("getBucketField", 2, rules, "table")
	checkType("getBucketField", 3, fieldName, "string")

	for _, fieldPair in ipairs(rules.fields or {}) do
		if fieldPair.data == fieldName then
			return row[fieldPair.bucket]
		end
	end

	return nil
end

--[=[ getPreferredBucketRow
-- Gets the preferred row from bucket rows that may contain duplicates
-- Inputs:
--      rows      bucket rows returned for one item
--      itemName  exact item name used by the bucket query
--      rules     bucket query rule
-- Returns:
--      preferred bucket row, or nil when no row is available
--]=]
function getPreferredBucketRow(rows, itemName, rules)
	checkType("getPreferredBucketRow", 1, rows, "table", true)
	checkType("getPreferredBucketRow", 2, itemName, "string")
	checkType("getPreferredBucketRow", 3, rules, "table")

	if rows == nil then
		return nil
	end

	if rules.matchField ~= nil then
		local matchValue = (rules.matchPrefix or "") .. itemName

		for _, row in ipairs(rows) do
			if row[rules.matchField] == matchValue then
				return row
			end
		end
	end

	return rows[1]
end

--[=[ applyItemInfoBucketData
-- Fills missing fields on one source data row from infobox_item bucket data
-- Inputs:
--      method    mutable source data row to enrich
--      itemName  exact output item name used by the bucket query
--      rules     item information bucket rule
-- Returns:
--      supplied source data row after missing fields have been filled
--]=]
function applyItemInfoBucketData(method, itemName, rules)
	checkType("applyItemInfoBucketData", 1, method, "table", true)
	checkType("applyItemInfoBucketData", 2, itemName, "string", true)
	checkType("applyItemInfoBucketData", 3, rules, "table", true)

	if method == nil or itemName == nil or rules == nil then
		return method
	end

	if type(rules.fields) ~= "table"
		or rules.name == nil
		or rules.itemField == nil
	then
		return method
	end

	local needsBucket = false

	for _, fieldPair in ipairs(rules.fields) do
		if method[fieldPair.data] == nil then
			needsBucket = true
			break
		end
	end

	if not needsBucket then
		return method
	end

	local rows      = getBucketRows(itemName, rules)
	local bucketRow = getPreferredBucketRow( rows, itemName, rules)

	if bucketRow == nil then
		return method
	end

	for _, fieldPair in ipairs(rules.fields) do
		local value = bucketRow[fieldPair.bucket]

		if fieldPair.number == true then
			value = tonumber(value)
		end

		if method[fieldPair.data] == nil and value ~= nil then
			method[fieldPair.data] = value
		end
	end

	return method
end

--[=[ getStorelineCurrency
-- Gets the preferred currency from one Storeline currency value
-- Inputs:
--      value  Storeline currency value or array
--      rules  Storeline bucket rule
-- Returns:
--      configured non-coin currency, coins, or nil
--]=]
function getStorelineCurrency(value, rules)
	checkType("getStorelineCurrency", 2, rules, "table")

	local values

	if type(value) == "table" then
		values = value
	else
		values = {
			value,
		}
	end

	local aliases = rules.currencyAliases or {}
	local coinCurrency

	for _, currency in ipairs(values) do
		local currencyName = tostring(currency or "")

		currencyName = aliases[currencyName] or currencyName

		if currencyName ~= "" then
			if currencyName == "coins" then
				coinCurrency = currencyName
			else
				return currencyName
			end
		end
	end

	return coinCurrency
end

--[=[ getStorelineCandidate
-- Builds one eligible Storeline buy-price candidate
-- Inputs:
--      row    Storeline bucket row
--      rules  Storeline bucket rule
--      args   optional calculator arguments
-- Returns:
--      Storeline candidate, or nil when the row is ineligible
--]=]
function getStorelineCandidate(row, rules, args)
	checkType("getStorelineCandidate", 1, row, "table")
	checkType("getStorelineCandidate", 2, rules, "table")
	checkType("getStorelineCandidate", 3, args, "table", true)

	local historical = getBucketField(row, rules, "storeHistorical")
	local members    = getBucketField(row, rules, "storeMembers")

	if historical == true then
		return nil
	end

	if args ~= nil
		and args.disp == "Free-to-Play"
		and members == true
	then
		return nil
	end

	local buyPrice = tonumber(
		getBucketField(row, rules, "storeBuyPrice")
	)
	local sellPrice = tonumber(
		getBucketField(row, rules, "storeSellPrice")
	)
	local currency = getStorelineCurrency(
		getBucketField(row, rules, "storeCurrency"),
		rules
	)

	if buyPrice == nil and sellPrice == nil then
		return nil
	end

	if currency == nil then
		return nil
	end

	local storeName = getBucketField(row, rules, "storeName")
	local storePage = getBucketField(row, rules, "storePage")

	return {
		storeBuyPrice  = buyPrice,
		storeSellPrice = sellPrice,
		storeCurrency  = currency,
		storeName      = storeName or storePage,
		storePage      = storePage or storeName,
	}
end

--[=[ applyStorelineBucketData
-- Applies preferred Storeline prices to one mutable data row
-- Inputs:
--      method    mutable data row to enrich
--      itemName  exact item name used by the bucket query
--      rules     Storeline bucket rule
--      args      optional calculator arguments
-- Returns:
--      supplied data row after Storeline data has been applied
--]=]
function applyStorelineBucketData(method, itemName, rules, args)
	checkType("applyStorelineBucketData", 1, method, "table", true)
	checkType("applyStorelineBucketData", 2, itemName, "string", true)
	checkType("applyStorelineBucketData", 3, rules, "table", true)
	checkType("applyStorelineBucketData", 4, args, "table", true)

	if method == nil or itemName == nil or rules == nil then
		return method
	end

	if type(rules.fields) ~= "table"
		or rules.name == nil
		or rules.itemField == nil
	then
		return method
	end

	local needsBuyPrice  = method.storeBuyPrice == nil
	local needsSellPrice = method.storeSellPrice == nil

	if not needsBuyPrice and not needsSellPrice then
		return method
	end

	local rows = getBucketRows(itemName, rules)

	if rows == nil then
		return method
	end

	local bestBuyCoin
	local bestBuyNonCoin
	local bestSellCoin
	local bestSellNonCoin

	for _, row in ipairs(rows) do
		local candidate = getStorelineCandidate(row, rules, args)

		if candidate ~= nil then
			local currency  = candidate.storeCurrency
			local buyPrice  = candidate.storeBuyPrice
			local sellPrice = candidate.storeSellPrice

			if needsBuyPrice and buyPrice ~= nil then
				if currency == "coins" then
					if bestBuyCoin == nil
						or buyPrice > bestBuyCoin.storeBuyPrice
					then
						bestBuyCoin = candidate
					end
				elseif bestBuyNonCoin == nil
					or buyPrice > bestBuyNonCoin.storeBuyPrice
				then
					bestBuyNonCoin = candidate
				end
			end

			if needsSellPrice and sellPrice ~= nil then
				if currency == "coins" then
					if bestSellCoin == nil
						or sellPrice < bestSellCoin.storeSellPrice
					then
						bestSellCoin = candidate
					end
				elseif bestSellNonCoin == nil
					or sellPrice < bestSellNonCoin.storeSellPrice
				then
					bestSellNonCoin = candidate
				end
			end
		end
	end

	local selectedBuy  = bestBuyNonCoin or bestBuyCoin
	local selectedSell = bestSellNonCoin or bestSellCoin

	if needsBuyPrice and selectedBuy ~= nil then
		method.storeBuyPrice = selectedBuy.storeBuyPrice
		method.storeCurrency = selectedBuy.storeCurrency
		if method.storeName == nil then
			method.storeName = selectedBuy.storeName
		end
		if method.storePage == nil then
			method.storePage = selectedBuy.storePage
		end
	end

	if needsSellPrice and selectedSell ~= nil then
		method.storeSellPrice = selectedSell.storeSellPrice
		method.storeSellCurrency = selectedSell.storeCurrency
		if method.storeSellName == nil then
			method.storeSellName = selectedSell.storeName
		end
		if method.storeSellPage == nil then
			method.storeSellPage = selectedSell.storePage
		end
	end

	return method
end


p._setDebug                 = setDebug
p._debugLogger              = debugLogger
p._copySequence             = copySequence
p._copyMethodRows           = copyMethodRows
p._copyFields               = copyFields
p._applyItemInfoBucketData  = applyItemInfoBucketData
p._applyStorelineBucketData = applyStorelineBucketData

return p