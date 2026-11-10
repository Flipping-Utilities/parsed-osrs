-- <nowiki>
local p = {}

local getArgs = require("Module:Arguments").getArgs
local coins = require('Module:Currency')._amount
local cache = require('Module:Break Isolation').cache_functions('Module:Component costs')
local parseMultiplier = require("Module:PriceUtil").parseMultiplier

local compData = mw.loadData('Module:Component costs/data')
local matnames = mw.loadData('Module:Disassemble/mats')
local geprices = mw.loadJsonData('Module:GEPrices/data.json')
local gelimits = mw.loadJsonData('Module:GELimits/data.json')
local gevolumes = mw.loadJsonData('Module:GEVolumes/data.json')
local itemcats = mw.loadData('Module:Disassemble/data')
local matinfo = mw.loadData('Module:Disassemble/matinfo')
local chances = mw.loadData('Module:Disassembly material calculator/data') -- chance info here
local lang = mw.language.getContentLanguage()
local expr = mw.ext.ParserFunctions.expr

-- forward declarations
local calculateCostByMethod
local storeprice

local messages = {
	['min'] = 'Price based on the [[Grand Exchange|GE]] value of %s as the cheapest price per component. See [[RuneScape:Material prices#%s|RS:Material prices § %s]] for details.',
	['thresholded-min'] = 'Price based on the [[Grand Exchange|GE]] value of %s as the cheapest price per component with a volume and a buy limit greater than or equal to %d. See [[RuneScape:Material prices#%s|RS:Material prices § %s]] for details.',
	['avg'] = 'Price based on the average cost per material of several items. See [[RuneScape:Material prices#%s|RS:Material prices § %s]] for details.',
	['traded-avg'] = 'Price based on the weighted mean of the cost per material of several items. See [[RuneScape:Material prices#%s|RS:Material prices § %s]] for details.',
}

-- from a given category in the disassemble template, and a material, return the chance of that material
-- returns chance (as a decimal between 0 and 1) if successful
-- returns -1 if not
local function get_non_special_chance(item_cat, mat)
	local function check(va, ma)
		if item_cat[va] then
			if item_cat[va]:find(ma, 0, true) ~= nil then
				return true, 0
			end
		end
		return false, 0
	end

	if check('often', mat) or check('sometimes', mat) or check('rarely', mat) then
		local cat_chances = chances[item_cat.cat]
		if cat_chances then
			local chance = cat_chances[mat]
			if chance then
				chance = chance / cat_chances._total
				return chance, cat_chances._master_modifier
			end
		end
	end

	return nil, 0
end

p.__getBucketData = cache('__getBucketData', function(itemName)
	local res = bucket('disassembly')
		.select('page_name', 'estimated_cost', 'estimated_cost_per', 'recurring_cost', 'recurring_cost_per', 'json')
		.where('page_name', itemName)
		.run()

	if #res == 0 then
		return nil
	end

	for _, v in ipairs(res) do
		local json = mw.text.jsonDecode(v['json'])
		if json and json.name == itemName then
			if not json.nocalc then
				json.page_name = v.page_name
				json.estimated_cost = v.estimated_cost
				json.estimated_cost_per = v.estimated_cost_per
				json.recurring_cost = v.recurring_cost
				json.recurring_cost_per = v.recurring_cost_per
				return json
			end
		end
	end

	return nil
end)

local function getStorePrice(item)
	if not storeprice then
		storeprice = require("Module:Store price")._main
	end

	local stinfo = storeprice(item)

	return stinfo[1]
end

local function json_decode(str)
	if str == nil then
		return nil
	end

	return mw.text.jsonDecode(str)
end

local function round(num, dp)
	if type(num) ~= 'number' then
		num = tonumber(num)
		if num == nil then
			return nil
		end
	end

	local mult = 10 ^ (dp or 0)
	if num >= 0 then
		return math.floor(num * mult + 0.5) / mult
	else
		return math.ceil(num * mult - 0.5) / mult
	end
end

local currentFrame
local function preprocess(expression)
    if currentFrame == nil then
        currentFrame = mw.getCurrentFrame()
    end

    return expr(currentFrame:preprocess(expression))
end

local function findInRecipe(tbl, target)
	if tbl == nil then
		return nil
	end

	local found
	local others = {}
	for _, item in ipairs(tbl) do
		if item.name == target or item.page == target then
			found = item
		else
			table.insert(others, found)
		end
	end

	return found, others
end

local function getCalcValue(item)
	local data = bucket('infobox_item')
		.select('calculated_value')
		.where(bucket.Or({ 'item_name', item }, { 'page_name_sub', item }, { 'page_name', item }))
		.where('calculated_value', '!=', bucket.Null())
		.run()

	local calcval
	if #data > 0 then
		calcval = data[1].calculated_value
	end

	if not calcval then
		error('No calculated value could be found for: ' .. item)
	end

	local calcval_num = tonumber(calcval)
	if calcval_num then
		return calcval_num
	end

	local price = tonumber(preprocess(calcval))
	if price then
		price = round(price, 2)
	else
		error('Error preprocessing calculated value: ' .. calcval)
	end

	return price
end

local function getEstimatedCost(item, cost_unit, cost_portion)
	local data = bucket("recipe")
		.select('sequence', 'production_json')
		.where('production_main_output', item)
		.orderBy('sequence', 'asc')
		.limit(1)
		.run()

	if #data == 0 then
		-- fallback
		return getCalcValue(item)
	end

	local production_json = json_decode(data[1]['production_json'])
	if production_json == nil then
		-- fallback
		return getCalcValue(item)
	end

	local found_output, found_others = findInRecipe(production_json.outputs, item)
	if found_output == nil then
		-- fallback
		return getCalcValue(item)
	end

	local portion = tonumber(found_output.portion) or 1
	local materials = production_json.materials
	if materials == nil then
		-- fallback
		return getCalcValue(item)
	end

	local cost = 0
	-- Add to cost
	for _, mat in ipairs(materials) do
		if mat.cost_unit == cost_unit then
			local cost_data = calculateCostByMethod(mat.cost_method, mat.cost_expr, mat.cost_unit, mat.portion)
			local cost_price = cost_data.price
			if cost_price ~= nil then
				cost = cost + cost_price * mat.quantity
			end
		end
	end

	-- Subtract from cost
	for _, mat in ipairs(found_others or {}) do
		if mat.cost_unit == cost_unit then
			local cost_data = calculateCostByMethod(mat.cost_method, mat.cost_expr, mat.cost_unit, mat.portion)
			local cost_price = cost_data.price
			if cost_price ~= nil then
				cost = cost + cost_price * mat.quantity
			end
		end
	end

	local price
	if cost ~= 0 then
		if cost_portion ~= nil and portion ~= cost_portion then
			price = round(cost / portion * cost_portion, 2)
		else
			price = cost
		end
	end

	if price ~= nil then
		return price
	else
		return nil
	end
end

local function calculateEstCost(itemName, itemData)
	local base_cost_method = itemData.base_cost_method
	local cost_portion = itemData.estimated_cost_per or 1

	if base_cost_method == 'gemw' then
		return geprices[itemName]
	elseif base_cost_method == 'store' then
		local cost = calculateCostByMethod('store', itemData.page_name, nil --[['coins']], cost_portion)
		return cost.price
	elseif base_cost_method == 'recipe' then
		local cost = calculateCostByMethod('estcost', itemData.page_name, nil --[['coins']], cost_portion)
		return cost.price
	elseif itemName.estimated_cost ~= nil then
		local cost = calculateCostByMethod('expr', itemName.estimated_cost, nil --[['coins']], cost_portion)
		return cost.price
	end
end

function calculateCostByMethod(method, method_expr, cost_unit, portion)
	local price

	if method == 'currency' then
		local cost_number = tonumber(method_expr, 10)
		if cost_number == nil then
			price = nil
			error('Error: Could not recognise this number: `' .. method_expr .. '`')
		else
			price = cost_number
		end
	elseif method == 'fixed' then
		local cost_number = tonumber(method_expr, 10)
		if cost_number == nil then
			price = nil
			error('Error: Could not recognise this number: `' .. method_expr .. '`')
		else
			price = cost_number
		end
	elseif method == 'expr' then
		local ok, expr_cost_v = pcall(preprocess, method_expr)
		if ok and tonumber(expr_cost_v, 10) then
			price = expr_cost_v
		else
			price = nil
			error('Error: Could not evaluate this expression: `' .. method_expr .. '`')
		end
	elseif method == 'gemw' then
		price = geprices[method_expr]
		if price == false then
			price = nil
			error('Error: Could not retrieve Grand Exchange price for item: ' .. method_expr)
		end
	elseif method == 'mat' then
		local compcost = p._main
		local ok, temp_cost = pcall(compcost, method_expr)
		if ok and temp_cost and temp_cost.price ~= nil then
			price = round(temp_cost.price, 0)
		else
			price = nil
			error("Error: No material cost could be found for: " .. method_expr)
		end
	elseif method == 'estcost' then
		local ok, temp_cost = pcall(getEstimatedCost, method_expr, cost_unit, portion)

		if ok and temp_cost ~= nil then
			price = temp_cost
		else
			price = nil
			error("Error: No estimated cost could be found for: " .. method_expr)
		end
	elseif method == "store" then
		local ok, temp_cost = pcall(getStorePrice, method_expr, portion)
		if ok then
			price = temp_cost
		else
			price = nil
			error("Error: No store price could be found for: " .. method_expr)
		end
	elseif method == 'invocation' then
		price = preprocess(method_expr)
	elseif method == 'no' then
		price = nil
	end

	return {
		price = price,
		cost_method = method,
		cost_expr = method_expr,
		cost_unit = cost_unit,
	}
end

function p.__getPrice(compName, comp, itemName, itemData)
	local cat
	local catName = string.lower(itemData.category)
	if itemcats[catName] then
		cat = itemcats[catName]
	else
		mw.log('No category found for: ' .. itemName)
		cat = itemcats['default']
	end

	local chance
	-- Try to find the special chance for the material
	if comp.special and itemData.special and itemData.special[compName] then
		local spec = itemData.special[compName]
		local cqty = spec.quantity

		if itemData.augmented then
			cqty = cqty * 4
		end

		if type(spec.chance) == 'number' then
			chance = (spec.chance / 100) * cqty
		elseif type(spec.chance) == 'table' then
			chance = (spec.chance[1] / spec.chance[2]) * cqty
		else
			-- to calculate the item price, set the chance to 0 if the chance is not found
			mw.log('Not found the chance of ' .. compName .. ' for ' .. itemName)
		end
	else
		local mastermodifier
		chance, mastermodifier = get_non_special_chance(cat, comp.short)
		if chance ~= nil then
			local cqty = tonumber(cat.compqty) or 1

			local junk
			if itemData.augmented then
				junk = 0
				cqty = cqty * 4
			else
				junk = itemData.junk and itemData.junk[1] and itemData.junk[10]
			end

			chance = (1 - junk / 100) * chance * cqty
		else
			-- to calculate the item price, set the chance to 0 if the chance is not found
			mw.log('Not found the chance of ' .. compName .. ' for ' .. itemName)
		end
	end

	local iprice

    local recurring_cost = itemData.recurring_cost
    if recurring_cost ~= nil then
        local cost_portion = itemData.recurring_cost_per or 1
        local cost = calculateCostByMethod('expr', recurring_cost, nil --[['coins']], cost_portion)
        iprice = cost.price
	elseif itemData.calcvalue then
		local ptemp = itemData.calcvalue
		if tonumber(ptemp) then
			iprice = tonumber(ptemp)
		else
			iprice = require('Module:Calcvalue')._get(itemName)
		end

		if not iprice then
			error('Invalid calcvalue for: ' .. itemName)
		end
	
    else
		iprice = calculateEstCost(itemName, itemData)
    end

	if not iprice then
		error('Price not found for: ' .. itemName)
	end

	if chance == nil then
		return nil, iprice
	end

	local iqty = tonumber(cat.itemqty) or 1
	local price = iqty * iprice / chance

	return price, iprice
end

function p.main(frame)
	local args = frame:getParent().args
	if not args[1] then error('No material type provided') end

	local ret = p._main(args[1])
	if args[2] then
		local t = string.lower(args[2])
		if t == 'raw' or t == 'rawprice' then
			return ret.price or 0
		elseif t == 'price' then
			return ret.price ~= nil and coins(ret.price, 'coins') or 'Unknown'
		elseif t == 'note' then
			return ret.note
		elseif t == 'rawobj' then
			return ret
		elseif t == 'name' then
			return ret.name
		end
	end

	local retstring = mw.getCurrentFrame():getParent():extensionTag('ref', ret.note)

	if ret.price ~= nil then
		retstring = coins(ret.price, 'coins') .. retstring
	else
		retstring = 'Unknown price' .. retstring
	end

	return retstring
end

function p.price(frame)
	local args = getArgs(frame, {
		trim = true,
		removeBlanks = true,
		frameOnly = false,
		wrappers = {
			"Template:MCP", -- Material Cost Price
		},
	})
	local comp = args[1]
	local multi = parseMultiplier(args[2]) or 1

	return p._price(comp, multi)
end

function p._price(comp, multi)
	local ret = p._main(comp)
	if ret.price == nil then
		return nil
	end

	return ret.price * (multi or 1)
end

-- Used by tools external to the wiki; avoid changing output format
function p._all_prices()
	local ret = {}
	for _, mat in pairs(matnames) do
		local ok, price = pcall(p._price, mat)
		table.insert(ret, string.format("%s: %.1f", mat, ok and price or 0))
	end
	return table.concat(ret, "\n")
end

local function sum(x)
	local s = 0
	for _, v in ipairs(x) do
		s = s + v
	end
	return s
end

local function weighted_mean(x, w)
	local sump = 0
	local sumw = sum(w)
	if sumw == 0 then
		-- Special case: all of the items have 0 volume, so treat them all as even weights
		return sum(x) / #x
	end
	
	for i, v in ipairs(x) do
		sump = sump + (v * w[i])
	end
	return sump / sumw
end

function p._main(compArg)
	compArg = string.lower(compArg)
	local compName
	if matnames[compArg] then
		compName = matnames[compArg]
	else
		compName = string.gsub(compArg, '^%w', string.upper)
	end

	local comp = compData[compName]
	if not comp then error('Invalid component name: ' .. compName) end

	if compName == 'Junk' then
		local note = comp.reason
		if not (note and note == '') then
			mw.log('Reason is blank for Junk in Module:Component_costs/data')
			note = 'Almost any item can provide junk.'
		end

		return {
			price = 1,
			note = note,
		}
	elseif compName == 'Offcut components' then
		return {
			price = 130 * 1/(2 * 1/20), -- rough estimate based on: mahogany table, buy price 130, 2x comps, 1/20 chance,
			note = 'Temporary static price until furniture prices stabilise',
		}
	elseif compName == 'Refined components' then
		local price = geprices['Junk refiner']
		if not price then
			error('GE price not found for Junk refiner')
		end
		price = price / 20

		local note = comp.reason
		if not (comp.reason and comp.reason == '') then
			mw.log('Reason is blank for Refined components in Module:Component_costs/data')
			note = 'Based on the price of [[Junk refiner]] (assumes production of 20 components)'
		end

		return {
			price = price,
			note = note,
		}
	end

	local itemCount = 0
	local items = {}
	for _, itemName in ipairs(comp.items) do
		local itemData = p.__getBucketData(itemName)

		if not itemData then
			mw.log('No data found for: ' .. itemName)
		else
			local pricePerComp, itemPrice = p.__getPrice(compName, comp, itemName, itemData)
			items[itemName] = { pricePerComp = pricePerComp, itemPrice = itemPrice, buyLimit = gelimits[itemName], volume = gevolumes[itemName], augmented = itemData.augmented }
			itemCount = itemCount + 1
		end
	end

	if itemCount == 0 then
		error('No items found')
	end

	local price, note, name
	if comp.method == 'avg' then
		-- Use average of given costs
		local sumPrice = 0
		local n = 0
		for _, v in pairs(items) do
			if v.pricePerComp then
				sumPrice = sumPrice + v.pricePerComp
				n = n + 1
			end
		end

		if n > 0 then
			price = sumPrice / n
		end

		note = string.format(messages['avg'], compName, compName)
	elseif comp.method == 'traded-avg' then
		-- Use weighted mean of given costs
		local x = {}
		local w = {}
		for _, v in pairs(items) do
			if v.pricePerComp and v.volume then
				table.insert(x, v.pricePerComp)
				table.insert(w, v.volume)
			end
		end

		if #x > 0 then
			price = weighted_mean(x, w)
		end

		note = string.format(messages['traded-avg'], compName, compName)
	elseif comp.method == 'min' and comp.threshold then
		-- Use min method
		local minPrice = 999999999999
		local item = 'no items'
		for i, v in pairs(items) do
			if (v.pricePerComp and v.pricePerComp < minPrice) and (v.volume or 0) >= comp.threshold and (v.buyLimit or 0) >= comp.threshold then
				minPrice = v.pricePerComp
				name = i
				item = '[[' .. i .. ']]'
			end
		end

		if item ~= 'no items' then
			price = minPrice
		end

		note = string.format(messages['thresholded-min'], item, lang:formatNum(comp.threshold), compName, compName)
	else
		-- Use min method
		local minPrice = 999999999999
		local item = 'no items'
		for i, v in pairs(items) do
			if v.pricePerComp and v.pricePerComp < minPrice then
				minPrice = v.pricePerComp
				name = i
				item = '[[' .. i .. ']]'
			end
		end

		if item ~= 'no items' then
			price = minPrice
		end

		note = string.format(messages['min'], item, compName, compName)
	end

	-- Round price
	if price ~= nil then
		price = math.floor(price + 0.5)
	end

	return {
		price = price,
		note = note,
		items = items,
		name = name,
	}
end

return p