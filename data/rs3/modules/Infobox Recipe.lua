--[=[
-- Implements [[Template:Infobox Recipe]]
--]=]
local p = {}

require("strict")

-- start of imports
local geprice = require('Module:ExchangeLite').price
local plink = require("Module:Plink")._plink
local coins = require('Module:Coins')._amount
local coins_image = require('Module:Coins image')
local yesno = require('Module:Yesno')
local params = require('Module:Paramtest')
local ucfirst = params.ucfirst
local hc = params.has_content
local default_to = params.default_to
local commas = require('Module:Addcommas')
local skillpic = require('Module:Skill_clickpic')._main
local editbutton = require('Module:Edit button')
local onmain = require('Module:Mainonly').on_main
local currencies = require('Module:Currencies')._amount
local formatCalcvalue = require('Module:Calcvalue formatter').main
local contains = require('Module:Array').contains
local achievLink = require("Module:Achievement description")._link

-- convert some used globals to locals to improve performance
local math = math
local string = string
local table = table
local mw = mw
local expr = mw.ext.ParserFunctions.expr
local var = mw.ext.VariablesLua

local compcost
local dungprice
local storeprice
local popresourceCost
local old_price = false
local missing_gep = false
local missing_calcvalue = false
local missing_storeprice = false
local edit = editbutton('? (edit)')

-- Name mapping for special (multiple choice) items
local addCategories, addBucket

-- Tools that need special handling
local toolsList
local toolbeltTools
local processIcons
local facilitiesIcons
local facilitiesList
local discoveryList
local glyphTypes
do
	local _data = mw.loadData("Module:Infobox Recipe/data")
	toolsList = _data.toolsList
	toolbeltTools = _data.toolbeltTools
	processIcons = _data.processIcons
	facilitiesIcons = _data.facilitiesIcons
	facilitiesList = _data.facilitiesList
	discoveryList = _data.discoveryList
	glyphTypes = _data.glyphTypes
end

local TOOLBELT_TAG = ' <sup>(<span class="hover-text" title="This item can be added to the tool belt. Some items are automatically added by default."}}>tb</span>)</sup>'

-- forward declarations
local calculateCostByMethod

local function toolLink(name, txt)
	local toolbelt_tag = contains(toolbeltTools, name) and TOOLBELT_TAG or ''
	return (txt or plink(name)) .. toolbelt_tag
end

local function discoveryLinks(f)
	if params.is_empty(f) or (not f) then
		return {}
	end

	local result = {}
	for i, x in ipairs(mw.text.split(f, "%s*,%s*")) do
		x = mw.text.trim(x)
		result[i] = discoveryList[x] or ("[[%s]]"):format(x)
	end
	return result
end

local currentFrame
local function preprocess(expression)
	if currentFrame == nil then
		currentFrame = mw.getCurrentFrame()
	end

	return currentFrame:preprocess(expression)
end

local function extensionTag(...)
	if currentFrame == nil then
		currentFrame = mw.getCurrentFrame()
	end

	return currentFrame:extensionTag(...)
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
		missing_calcvalue = true
		error('No calculated value could be found for: ' .. item)
	end

	local calcval_num = tonumber(calcval)
	if calcval_num then
		return { calcval_num, 'Calculated value given as a number on the [[' .. item .. '|item page]].' }
	end

	local price = tonumber(preprocess(calcval))
	if price then
		price = round(price, 2)
	else
		error('Error preprocessing calculated value: ' .. calcval)
	end

	local class = string.gsub(item, '%W', '')
	local note = 'Calculated value given on the [[' .. item .. '|item page]] (generally based on GE prices of ingredients):  <span class="cv-formula-tog mw-customtoggle-' .. class .. '">[show/hide formula]</span>  <span class="mw-collapsible mw-collapsed" id="mw-customcollapsible-' .. class .. '"> <code>' .. formatCalcvalue(calcval) .. '</code></span>.'

	return { price, note }
end

--[[
Function to get the estimated cost of an item
--]]
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
	local quantity = tonumber(found_output.quantity) or 1
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

	local price, note
	if cost ~= 0 then
		if cost_portion ~= nil and portion ~= cost_portion then
			price = round(cost / quantity / portion * cost_portion, 2)
		else
			price = cost / quantity
		end

		note = 'Estimated cost given on the [[' .. item .. '|item page]] (generally based on GE prices of ingredients).'
	end

	if price ~= nil then
		return { price, note }
	else
		return nil
	end
end

local function askNrcval(item)
	local calcval = nil
	local ritual_component_durability = 1

	local data = bucket('infobox_item')
		.join('ritual_component', 'page_name', 'ritual_component.page_name')
		.select('calculated_value', 'ritual_component.json')
		.where(bucket.Or { 'item_name', item })
		.limit(1)
		.run()
	if #data > 0 then
		calcval = data[1].calculated_value
		ritual_component_durability = json_decode(data[1]['ritual_component.json']).durability
	end

	return calcval, ritual_component_durability
end

--[[
Function to get the calcval value of a necromancy ritual component
--]]
local function getNrcval(item)
	local calcval, ritual_component_durability

	if string.find(item, ' %(%d%)$') then
		local subobj = string.gsub(item, ' %((%d)%)$', '#(%1)')
		calcval, ritual_component_durability = askNrcval(subobj)
	end

	if not calcval then
		calcval, ritual_component_durability = askNrcval(item)
	end

	if not calcval then
		missing_calcvalue = true
		error('No calculated value could be found for: ' .. item)
	end

	local class = string.gsub(item, '%W', '')

	local unit_price
	local price = tonumber(calcval)
	if price then
		unit_price = price / ritual_component_durability
		return { unit_price, 'Calculated value given as a number on the [[' .. item .. '|item page]]: <span class="cv-formula-tog mw-customtoggle-' .. class .. '">[show/hide formula]</span>  <span class="mw-collapsible mw-collapsed" id="mw-customcollapsible-' .. class .. '"> <code>' .. price .. ' / ' .. ritual_component_durability .. '</code></span>.' }
	end

	price = preprocess(calcval)
	if tonumber(price) then
		unit_price = round(price / ritual_component_durability, 2)
	else
		error('Error preprocessing calculated value: ' .. calcval)
	end

	local note = 'Calculated value given on the [[' .. item .. '|item page]] (generally based on GE prices of ingredients): <span class="cv-formula-tog mw-customtoggle-' .. class .. '">[show/hide formula]</span>  <span class="mw-collapsible mw-collapsed" id="mw-customcollapsible-' .. class .. '"> <code>(' .. formatCalcvalue(calcval) .. ') / ' .. ritual_component_durability .. '</code></span>.'

	return { unit_price, note }
end

local function getStorePrice(item)
	if not storeprice then
		storeprice = require("Module:Store price")._main
	end

	local stinfo = storeprice(item)
	local note = string.format("Values based on prices in %s from [[%s]].", stinfo[2], stinfo[3])

	return { stinfo[1], note }
end

local function getSmugglePrice(item)
	if not dungprice then
		dungprice = require('Module:Smuggler price')._price
	end

	return dungprice(item)
end

local function getPopResourceValue(item)
	if not popresourceCost then
		popresourceCost = require("Module:Pop resource cost")._calcvalue
	end

	local price, note = popresourceCost(item, 1, true)

	return { round(price, 2), note }
end

function calculateCostByMethod(method, method_expr, cost_unit, portion)
	local price, price_note
	local price_note_deduplicate = false

	if method == 'currency' then
		local cost_number = tonumber(method_expr, 10)
		if cost_number == nil then
			price = nil
			missing_calcvalue = true
			price_note = 'Error: Could not recognise this number: <code>' .. method_expr .. '</code>'
		else
			price = cost_number
		end
	elseif method == 'fixed' then
		local cost_number = tonumber(method_expr, 10)
		if cost_number == nil then
			price = nil
			missing_calcvalue = true
			price_note = 'Error: Could not recognise this number: <code>' .. method_expr .. '</code>'
		else
			price = cost_number
			old_price = true
			price_note = 'Fixed price given'
		end
	elseif method == 'expr' then
		local ok, expr_cost_v = pcall(expr, method_expr)
		if ok and tonumber(expr_cost_v, 10) then
			price = expr_cost_v
		else
			price = nil
			missing_calcvalue = true
			price_note = 'Error: Could not evaluate this expression: <code>' .. method_expr .. '</code>'
		end
	elseif method == 'gemw' then
		price = geprice(method_expr, 1, false, nil, false)
		if price == false then
			price = nil
			missing_gep = true
			price_note = 'Error: Could not retrieve Grand Exchange price for item: ' .. method_expr
		end
	elseif method == 'mat' then
		if not compcost then
			compcost = require('Module:Component costs')._main
		end
		local ok, temp_cost = pcall(compcost, method_expr)
		if ok and temp_cost and temp_cost.price ~= nil then
			price = round(temp_cost.price, 0)
			price_note = temp_cost.note
		else
			price = nil
			missing_calcvalue = true
			price_note = "Error: No material cost could be found for: " .. method_expr
		end
	elseif method == 'estcost' then
		local ok, temp_cost = pcall(getEstimatedCost, method_expr, cost_unit, portion)

		if ok and temp_cost ~= nil then
			price = temp_cost[1]
			price_note = temp_cost[2]
		else
			price = nil
			missing_calcvalue = true
			price_note = "Error: No estimated cost could be found for: " .. method_expr
		end
	elseif method == 'nrcvalue' then
		local ok, temp_cost = pcall(getNrcval, method_expr, portion)

		if ok then
			price = temp_cost[1]
			price_note = temp_cost[2]
		else
			price = nil
			missing_calcvalue = true
			price_note = "Error: No estimated cost could be found for: " .. method_expr
		end
	elseif method == "store" then
		local ok, temp_cost = pcall(getStorePrice, method_expr, portion)
		if ok then
			price = temp_cost[1]
			price_note = temp_cost[2]
			price_note_deduplicate = true
		else
			price = nil
			missing_storeprice = true
			price_note = "Error: No store price could be found for: " .. method_expr
		end
	elseif method == 'smuggler' then
		local ok, temp_cost = pcall(getSmugglePrice, method_expr, portion)
		if ok then
			price = tonumber(temp_cost)
		else
			price = nil
			missing_storeprice = true
			price_note = "Error: No smuggler price could be found for: " .. method_expr
		end
	elseif method == 'popresource' then
		local ok, temp_cost = pcall(getPopResourceValue, method_expr)
		if ok then
			price = temp_cost[1]
			price_note = temp_cost[2]
		else
			price = nil
			missing_calcvalue = true
			price_note = "Error calculating indirect value: " .. tostring(temp_cost)
		end
	elseif method == 'invocation' then
		price = preprocess(method_expr)
		price_note = 'Price calculated from: <code>' .. formatCalcvalue(method_expr) .. '</code>'
		old_price = true
	elseif method == 'no' then
		price = nil
	end

	return {
		price = price,
		price_note = price_note,
		price_note_deduplicate = price_note_deduplicate,
		cost_method = method,
		cost_expr = method_expr,
		cost_unit = cost_unit,
	}
end

local function calculateCostToPrice(method_raw, page, name, gemwname, currency_name, portion)
	local method = string.lower(method_raw or '')

	if currency_name ~= nil then
		if method == nil then
			return calculateCostByMethod('currency', 1, currency_name, portion)
		else
			local cost_number_expr = commas._strip(method)
			local cost_number = tonumber(cost_number_expr, 10)
			if cost_number then
				return calculateCostByMethod('fixed', cost_number, currency_name, portion)
			else
				return calculateCostByMethod('expr', method, currency_name, portion)
			end
		end
	elseif string.lower(gemwname) == 'coins' then
		return calculateCostByMethod('currency', 1, currency_name, portion)
	elseif method == 'gemw' then
		return calculateCostByMethod('gemw', gemwname, currency_name, portion)
	elseif method == 'mat' then                           -- use (invention) material costs
		return calculateCostByMethod('mat', name, currency_name, portion)
	elseif method == 'estcost' or method == 'calcvalue' then -- use calcvalue from infobox
		return calculateCostByMethod('estcost', page, currency_name, portion)
	elseif method == 'nrcvalue' then                      -- use calcvalue from infobox and divide it by durability
		return calculateCostByMethod('nrcvalue', name, currency_name, portion)
	elseif method == "store" then                         -- use store price (set by [[Template:StoreLine]])
		return calculateCostByMethod('store', gemwname, currency_name, portion)
	elseif method == 'smuggler' or method == 'dung' then  -- use value from smuggler
		return calculateCostByMethod('smuggler', page, currency_name, portion)
	elseif method == 'popresource' then                   -- use value from Bucket:Infobox_pop_resource
		return calculateCostByMethod('popresource', page, currency_name, portion)
	elseif method == 'no' then
		return calculateCostByMethod('no', nil, currency_name, portion)
	elseif not hc(method) then
		local gemw = calculateCostByMethod('gemw', gemwname, currency_name, portion)
		if gemw.price ~= nil then
			return gemw
		end
		-- Fallback to estcost
		return calculateCostByMethod('estcost', page, currency_name, portion)
	else
		local cost_expr = commas._strip(method)
		local cost_number = tonumber(cost_expr, 10)
		if cost_number then -- parseable as number = use that
			-- Some untradeables have a distinct market price
			-- because of their materials
			-- The template {{GETotal}} will help here
			-- Look for template call
			return calculateCostByMethod('fixed', cost_number, currency_name, portion)
		elseif method:find('{{.*}}') then
			return calculateCostByMethod('invocation', method, currency_name, portion)
		else
			return calculateCostByMethod('expr', method, currency_name, portion)
		end
	end
end

local function strip_dose_name(name)
	return string.gsub(name, ' ?%(%d+%)', '')
end

local function get_dose_number(name)
	local dose = string.match(name, '%((%d+)%)')
	if dose ~= nil then
		return tonumber(dose)
	else
		return nil
	end
end

local function mat_loop(ret_list, item)
	local page = item.page
	if not page or not hc(page) then
		return false
	end

	-- parameters for a single item
	local name = default_to(item.name or item.txt, page)
	local gemwname = default_to(item.gemw or item.gemwname, page)
	local variant = default_to(item.var, nil)
	local portion = tonumber(default_to(item.ea, nil))
	local img_raw = default_to(item.img, nil)

	-- syntax sugar
	local type = string.lower(default_to(item.type, ''))
	if type == 'potion' or type == 'pot' then
		if img_raw == nil then
			img_raw = page .. '.png'
		end
		portion = get_dose_number(page)
		page = strip_dose_name(page)
		variant = '(' .. portion .. ')'
	end

	-- Mostly for foods that can be burnt
	local altitem = item.alt
	local altnote
	if altitem then
		altnote = 'This recipe has a chance to give [[' .. altitem .. '|' .. altitem:lower() .. ']] instead.'
	end
	local itemnote = item.itemnote or altnote or nil
	local qtynote = item.qtynote or nil

	-- 2 separate prices
	-- 1 for display
	-- 1 for calculation
	local cost_method = item.cost
	local currencyName = default_to(item.currency, nil)
	local cost_data = calculateCostToPrice(cost_method, page, name, gemwname, currencyName, portion)
	local price = cost_data.price
	local price_note = item.pnote or cost_data.price_note

	local qty = default_to(item.qty, '1')

	local price_total
	if price ~= nil then
		price_total = qty * price
	elseif price == nil then
		price_total = nil
	end

	local img
	if img_raw == nil then
		img = page .. '.png'
	elseif string.lower(img_raw) == 'no' then
		img = nil
	else
		img = img_raw
	end

	table.insert(ret_list, {
		page = page,
		name = name,
		variant = variant,
		portion = portion,
		price = price,
		price_total = price_total,
		price_note = price_note,
		price_note_original = cost_data.price_note,
		price_note_deduplicate = cost_data.price_note_deduplicate,
		cost_method = cost_data.cost_method,
		cost_expr = cost_data.cost_expr,
		cost_unit = cost_data.cost_unit,
		quantity = qty,
		image = img,
		itemnote = itemnote,
		quantitynote = qtynote,
	})

	return true
end

local function lookupArgs(args, prefix, default_key)
	local items = {}

	for key, value in pairs(args) do
		local matched_id, matched_key = string.match(key, prefix .. '(%d+)(.*)')
		matched_id = tonumber(matched_id);
		if matched_id ~= nil then
			if items[matched_id] == nil then
				items[matched_id] = {}
			end

			if not hc(matched_key) then
				matched_key = default_key
			end

			items[matched_id][matched_key] = value
		end
	end

	return items
end

--[[
Function to handle all the materials listed
Creates a table to pass to _main() consisting of
* Item name, as a wikilink
* Item image, as a wikilink, includes link to page
* Quantity
* Formatted price for display
* Clean price for calculations
* Note on the price source/calculation method

If the parameter mat# is defined and not blank

Every parameter (mat#img, mat#qty, mat#cost, mat#pnote) will be looked for as well
--]]
local function mat_list(objType, args)
	local items = lookupArgs(args, objType, 'page')

	local ret_list = {}

	for _, item in pairs(items) do
		mat_loop(ret_list, item)
	end

	return ret_list
end

local function calculate_price(mats)
	local currency_costs = {}

	for _, mat in ipairs(mats) do
		local price_total = mat.price_total

		if price_total ~= nil and price_total ~= 0 then
			local currency = mat.cost_unit
			if currency ~= nil then
				local ori_price = currency_costs[currency] or 0
				currency_costs[currency] = ori_price + price_total
			else
				local ori_price = currency_costs['coins'] or 0
				currency_costs['coins'] = ori_price + price_total
			end
		end
	end

	return currency_costs
end

local function calculate_profit(out_price, mat_price)
	local currency_profit = {}

	-- narrow copy
	for currency, cost in pairs(out_price) do
		currency_profit[currency] = cost
	end

	for currency, cost in pairs(mat_price) do
		local ori_price = currency_profit[currency] or 0
		currency_profit[currency] = ori_price - cost
	end

	return currency_profit
end

local function addRecipePriceVars(subcount, type, price)
	for currency, val in pairs(price) do
		local varname = string.format('Recipe_%s_%s_%d', type, currency, subcount)
		var.vardefine(varname, val)
	end
end

local function addRecipeMatsVars(subcount, type, mats)
	local varname
	for i, item in ipairs(mats) do
		varname = string.format('Recipe_%s%dqty_%d', type, i, subcount)
		var.vardefine(varname, item.quantity)
		varname = string.format('Recipe_%s%dea_%d', type, i, subcount)
		var.vardefine(varname, item.portion)
	end
end

local function parse_skill(ret_list, skill)
	local name = skill.name
	if not hc(skill.name) then
		return true
	end

	local lvl = default_to(skill.lvl, '?')
	local boost = yesno(skill.boostable, nil)
	local exp = default_to(skill.exp, '?')
	if exp ~= '?' then
		exp = commas._strip(exp)
	end

	table.insert(ret_list, {
		name = name,
		level = lvl,
		boostable = boost,
		experience = exp,
	})

	-- Determine which boostable flag to add
	if boost == nil and (tonumber(lvl) or 0) > 1 then
		return false
	else
		return true
	end
end

local function skill_list(args)
	local items = lookupArgs(args, 'skill', 'name')

	local ret_list = {}

	local unknown_boostable_flag = false
	for _, item in pairs(items) do
		if not parse_skill(ret_list, item) then
			unknown_boostable_flag = true
		end
	end

	return ret_list, unknown_boostable_flag
end

--[[
Function to get a list of required achievements, should there be any
Will take non-blank parameters and simply paste them as is into a table
Which will then be passed into the _main() function
--]]
local function achievement_list(args)
	local ret_list = {}
	local function achievement_loop(i)
		local achievement = args['achievement' .. i]
		if hc(achievement) then
			table.insert(ret_list, achievement)
			return true
		end
		return false
	end
	local i = 1
	while achievement_loop(i) do
		i = i + 1
	end
	return ret_list
end

--[[
Function to get a list of additional requirements, should there be any
Will take non-blank parameters and simply paste them as is into a table
Which will then be passed into the _main() function
--]]
local function get_other_reqs(args)
	local req_list = {}
	local function misc_loop(i)
		local req = args['misc' .. i]
		if req and hc(req) then
			table.insert(req_list, req)
			return true
		end
		return false
	end
	local all_misc = true
	for i = 1, 5 do
		all_misc = misc_loop(i) and all_misc
	end
	if all_misc then
		local i = 6
		while misc_loop(i) do
			i = i + 1
		end
	end
	return req_list
end

function p.main(frame)
	local invoke_args = frame.args
	local args = frame:getParent().args

	local subcount = 1
	if var.varexists('recipecount') then
		subcount = var.var('recipecount', 1)
		subcount = subcount + 1
		var.vardefine('recipecount', subcount)
	else
		var.vardefine('recipecount', 1)
	end

	-- Tables to pass; call above functions
	local materials = mat_list('mat', args)
	local outputs = mat_list('output', args)

	local material_total_price = calculate_price(materials)
	local output_total_price = calculate_price(outputs)
	local profit = calculate_profit(output_total_price, material_total_price)

	addRecipePriceVars(subcount, 'material_total', material_total_price)
	addRecipePriceVars(subcount, 'output_total', output_total_price)
	addRecipePriceVars(subcount, 'profit', profit)
	addRecipeMatsVars(subcount, 'output', outputs)

	-- deprecated var
	if hc(args.totalvar) then
		var.vardefine(args.totalvar, material_total_price['coins'])
	end

	local skills, unknown_boostable_flag = skill_list(args)
	local achievements = achievement_list(args)
	local misc_reqs = get_other_reqs(args)

	local useBucket = true
	if hc(args.bucket) then
		useBucket = yesno(args.bucket:lower())
	end

	-- Fetching and formatting parameters starting here
	local ticks, ticks2, ticksnote, uses_skills,
	method, improved, instructions = params.defaults {
		{ args.ticks, edit },
		{ args.ticks2, nil },
		{ args.ticksnote, nil },
		{ args.skill, nil },
		{ args.method, nil },
		{ args.improved, nil },
		{ args.instructions, nil },
	}

	local tool, process, facility, discovery, quest, complexity,
	noburnlevel, gauntlets,
	fireburn, firegaunt,
	cookmatic = params.defaults {
		{ args.tool, nil },
		{ args.process, nil },
		{ args.facility, nil },
		{ args.discovery, nil },
		{ args.quest, nil },
		{ args.complexity, nil },
		{ args.noburnlevel, nil },
		{ args.gauntlets, nil },
		{ args.fireburn, nil },
		{ args.firegaunt, nil },
		{ args.cookmatic, nil },
	}

	if yesno(noburnlevel) == false then
		noburnlevel = 'Never'
	end

	-- Check that improved is a number
	-- non-numeric value => invalid value, put nil
	-- 0 => it has improved recipe, but this is the "basic" one
	-- 1+ => it is an improved recipe
	improved = tonumber(improved, 10)

	-- Only accept "yes" or "no"
	-- Anything else defaults to no
	-- Should this default to unknown instead?
	local members = ''
	if hc(args.members) then
		members = yesno(args.members, true)
		if members then
			members = 'Yes'
		else
			members = 'No'
		end
	end

	if #skills > 0 or string.lower(uses_skills or '') ~= 'no' then
		uses_skills = true
	else
		uses_skills = false
	end

	-- Pass parameters to _main
	local parameters = {
		subcount = subcount,
		args = args,
		frame = frame,
		ticks = ticks,
		ticks2 = ticks2,
		ticksnote = ticksnote,
		improved = improved,
		method = method,
		materials = materials,
		outputs = outputs,
		material_total_price = material_total_price,
		output_total_price = output_total_price,
		profit = profit,
		tool = tool,
		process = process,
		facility = facility,
		discovery = discovery,
		complexity = complexity,
		misc_reqs = misc_reqs,
		skills = skills,
		unknown_boostable_flag = unknown_boostable_flag,
		uses_skills = uses_skills,
		members = members,
		noburnlevel = noburnlevel,
		gauntlets = gauntlets,
		fireburn = fireburn,
		firegaunt = firegaunt,
		cookmatic = cookmatic,
		quest = quest,
		achievements = achievements,
		useBucket = useBucket,
		instructions = instructions,
	}

	if invoke_args.onlyBucket == 'yes' then
		return p._bucket(parameters)
	else
		return p._main(parameters)
	end
end

--
-- Generates an array of table rows based on skills required for the recipe.
--
-- @param skills {array} List of skill requirements generated by skill_list function.
-- @return {array} List of html tr elements for each skill requirement. Empty table if skills is an empty table or nil.
-- @return {bool} True if any skill requirement, other than level 1, is missing a boostable value in skills. False otherwise.
--
local function generate_skills_rows(skills)
	local requirements = {}
	local unknown_boostable_flag = false

	-- Should this use yesno instead of lower comparison?
	for _, v in ipairs(skills) do
		local levelText = v.level == '?' and edit or v.level
		local boostable = yesno(v.boostable)
		-- Determine which boostable flag to add
		if boostable == true then
			levelText = levelText .. ' <sup title="This requirement is boostable" style="cursor:help; text-decoration:underline dotted;">(b)</sup>'
		elseif boostable == false then
			levelText = levelText .. ' <sup title="This requirement is not boostable" style="cursor:help; text-decoration:underline dotted;">(nb)</sup>'
		elseif (tonumber(v.level) or 0) > 1 then
			levelText = levelText .. ' <sup title="Unknown whether this requirement is boostable" style="cursor:help; text-decoration:underline dotted;">(b?)</sup>'
			unknown_boostable_flag = true
		end

		local xp = v.experience == '?' and edit or v.experience

		local requirement = mw.html.create('tr')
		requirement
			:tag('td'):css { ['white-space'] = 'nowrap' }:attr('colspan', 3):wikitext(skillpic(v.name, nil, true) .. ' [[' .. params.ucflc(v.name) .. ']]'):done()
			:tag('td'):wikitext(levelText):done()
			:tag('td'):wikitext(tonumber(xp) ~= nil and commas._add(xp) or xp):done()

		table.insert(requirements, requirement)
	end

	return requirements, unknown_boostable_flag
end

-- copied from [[Special:PermanentLink/36295338#L-421|Module:DropsLine#L-421]]
local function escape_ref_name(ref_content)
	-- setup reference for this row
	-- reference name
	return mw.ustring.gsub(
		mw.ustring.gsub(
			mw.ustring.lower(ref_content),
			-- replace spaces with hyphens
			"%s", "-"
		),
		-- remove all non-word characters
		"[^%w%-]", ""
	)
end

local function itemLink(item)
	local prodLink = item.page
	local prodVariant = item.variant

	local namestr = ""
	if prodVariant then
		namestr = string.format('%s#%s', prodLink, prodVariant)
	else
		namestr = string.format('%s', prodLink)
	end

	return namestr
end

local function itemDisplay(item)
	local prodLink = item.page
	local prodVariant = item.variant
	local prodName = item.name

	local namestr = ""
	if prodVariant and prodName then
		namestr = string.format('[[%s#%s|%s]]', prodLink, prodVariant, prodName)
	elseif prodVariant then
		namestr = string.format('[[%s#%s|%s]]', prodLink, prodVariant, prodLink)
	elseif prodName then
		namestr = string.format('[[%s|%s]]', prodLink, prodName)
	else
		namestr = string.format('[[%s]]', prodLink)
	end

	return namestr
end

local function itemImg(item)
	local mat_img_src = item.image
	if mat_img_src ~= nil and mat_img_src ~= "no" then
		return '[[File:' .. mat_img_src .. '|link=' .. itemLink(item) .. '|36x32px|frameless]]'
	else
		return ''
	end
end

--
-- Generates a tr element for the item described by item_data.
--
-- @param frame {table} Frame passed in to main.
-- @param item_data {table} A table representing a single item required or output by the recipe. Single member of a table produced by mat_list.
-- @return {html tr element} A tr element holding all information contained in item_data.
-- @return {int} Total cost of the given amount of this item.
-- @return {bool} True if either an item note or a quantity note was added to the tr element. False otherwise.
--
local function make_mat_row(item_data)
	local classOverride
	local textAlign = 'right'
	local has_ref_tag = false

	local price = item_data.price
	local currency = item_data.cost_unit
	local price_total = item_data.price_total

	local mat_disp, mat_title
	if currency ~= nil and price ~= nil then
		mat_disp = currencies(price_total, currency)
		mat_title = string.format('%s %s each', commas._add(price), currency)
	elseif price_total == nil then
		mat_disp = 'N/A'
		classOverride = 'table-na'
		textAlign = 'center'
	else
		mat_disp = commas._add(price_total)
		mat_title = commas._add(price) .. ' each'
	end

	local item_note = item_data.itemnote and extensionTag { name = 'ref', content = item_data.itemnote, args = { group = 'r' } } or ''
	if item_note ~= '' then
		has_ref_tag = true
	end

	local quantity_note = item_data.quantitynote and extensionTag { name = 'ref', content = item_data.quantitynote, args = { group = 'r' } } or ''
	if quantity_note ~= '' then
		has_ref_tag = true
	end

	-- If a price note is given use it
	local price_note = item_data.price_note or ''
	if price_note ~= '' then
		local ref_name = nil
		if not hc(item_data.price_note_original)
			or item_data.price_note_deduplicate then
			ref_name = "auto-" .. escape_ref_name(price_note)
		end

		price_note = extensionTag {
			name = 'ref',
			content = price_note,
			args = {
				group = "r",
				name = ref_name,
			},
		}
		has_ref_tag = true
	end

	local mat_img = itemImg(item_data)

	local row = mw.html.create('tr')

	row:tag('td')
		:css {
			['border-right'] = 'none',
			['text-align'] = 'center',
			['width'] = '36px',
		}
		:addClass('inventory-image')
		:wikitext(mat_img)

	row:tag('td')
		:css {
			['border-left'] = 'none',
			['padding-left'] = '0',
			['text-align'] = 'left',
		}
		:attr('colspan', '2')
		:wikitext(itemDisplay(item_data) .. item_note)

	row:tag('td')
		:addClass('ref-left')
		:css { ['width'] = '8ch' }
		:wikitext(quantity_note .. commas._add(item_data.quantity))

	row:tag('td')
		:addClass('ref-left')
		:addClass(classOverride)
		:css {
			['text-align'] = textAlign,
		}
		:wikitext(price_note)
		:tag('span')
		:attr('title', mat_title)
		:wikitext(mat_disp)
		:done()

	return row, has_ref_tag
end

--
-- Generates a list of tr elements describing all the items given.
--
-- @param frame {table} Frame passed in to main.
-- @param items {array} A list containing a all items required or output by the recipe. Produced by mat_list.
-- @return {array} A list of tr elements, holding one row for each item in items.
-- @return {table} A table of total prices for each currency used by members of items.
-- @return {bool} True if either an item note or a quantity note was added to any tr element. False otherwise.
--
local function generate_mat_rows(items)
	local has_ref_tag = false
	local rows = {}
	for _, v in ipairs(items) do
		local row, has_row_note = make_mat_row(v)

		has_ref_tag = has_ref_tag or has_row_note
		table.insert(rows, row)
	end

	return rows, has_ref_tag
end

--
-- Generates a tr element containing all of the total costs in the currencies for items in item_costs.
--
-- @param has_items {boolean} If the receipe has materials
-- @param item_costs {table} A table of total prices for each currency used by members of items. Produced by generate_rows.
-- @return {html tr element} A tr element holding all costs found in item_costs.
--
local function generate_total_cost_row(has_materials, item_costs)
	local total_cost_row = mw.html.create('tr')

	if not has_materials then
		total_cost_row:tag('td')
			:attr('colspan', '5')
			:css { ['font-style'] = 'italic', ['text-align'] = 'center' }
			:wikitext('Materials unknown ' .. editbutton())
			:done()

		return total_cost_row
	end

	local total_cost_breakdown = ''
	local total_price = 0
	local misc_costs_count = 0
	for i, _ in pairs(item_costs) do
		if i ~= 'coins' then
			misc_costs_count = misc_costs_count + 1
		end
	end

	for i, v in next, item_costs, nil do
		local curr_txt = ''
		if i == 'coins' then
			if misc_costs_count > 0 and v ~= 0 then
				curr_txt = coins(v)
			elseif misc_costs_count == 0 then
				curr_txt = commas._add(v)
			end
		else
			curr_txt = currencies(v, i)
		end

		total_cost_breakdown = (string.len(total_cost_breakdown) == 0 and total_cost_breakdown or total_cost_breakdown .. '<br>') .. curr_txt
		total_price = total_price + v
	end

	total_cost_row:tag('th')
		:attr('colspan', 4)
		:css { ['text-align'] = 'right' }
		:wikitext('Total cost')
		:done()

	if total_cost_breakdown ~= '' then
		total_cost_row:tag('td')
			:css { ['text-align'] = 'right' }
			:wikitext(total_cost_breakdown)
	else
		total_cost_row:tag('td')
			:addClass('table-na')
			:css('text-align', 'center')
			:wikitext('N/A')
	end

	return total_cost_row
end

--
-- Generates a tr element containing the difference between output and material costs (in coins).
--
-- @param frame {table} Frame passed in to main.
-- @param ticks {string|number} The number of ticks required to create one output. String or nil values will result in an assumption of 5.
-- @param materials_coins_cost {number} The total cost in coins of the materials.
-- @param outputs_coins_cost {number} The total cost in coins of the outputs.
-- @return {html tr element} A tr element holding the profit from one conversion of materials into outputs.
-- @return {bool} True if a note was added to the profit indicating questionable profits. False otherwise.
--
local function generate_profit_row(coins_profit)
	local profit = round(coins_profit, 2)

	local profclass = 'coins-zero'
	if profit < 0 then
		profclass = 'coins-neg'
	elseif profit > 0 then
		profclass = 'coins-pos'
	end

	-- Create and populate the table row element
	local profit_row = mw.html.create('tr')
	profit_row:tag('th')
		:attr('colspan', 4)
		:css { ['text-align'] = 'right' }
		:wikitext('Profit')
		:done()
	profit_row:tag('td')
		:css { ['text-align'] = 'right' }
		:addClass(profclass)
		:wikitext(commas._add(profit))
		:done()

	return profit_row
end

--
-- Main
--
local function improvedDisplay(i)
	local ico

	if i == 0 then
		ico = '[[File:Improved recipe icon.png|x16px|link=]] [[File:Improved recipe (dimmed) icon.png|x14px|link=]] [[File:Improved recipe (dimmed) icon.png|x14px|link=]] (Base)'
	elseif i == 1 then
		ico = '[[File:Improved recipe icon.png|x16px|link=]] [[File:Improved recipe icon.png|x16px|link=]] [[File:Improved recipe (dimmed) icon.png|x14px|link=]] (+ 1)'
	elseif i == 2 then
		ico = '[[File:Improved recipe icon.png|x16px|link=]] [[File:Improved recipe icon.png|x16px|link=]] [[File:Improved recipe icon.png|x16px|link=]] (+ 2)'
	else
		ico = '+ ' .. i
	end

	return ico
end

local function toolImages(t)
	local links = {}

	if params.is_empty(t) then
		return 'None'
	end

	local spl = mw.text.split(t, ",")
	for _, link_i in ipairs(spl) do
		link_i = mw.text.trim(link_i)
		local toolData = toolsList[link_i]
		local txt
		if type(toolData) == "table" then
			txt = toolLink(link_i, toolData[1])
			local altTool = toolData.alt
			if altTool then
				txt = txt .. " /&nbsp;" .. toolLink(altTool)
			end
		else
			txt = toolLink(link_i, toolData)
		end
		table.insert(links, txt)
	end
	return table.concat(links, ", ")
end

local function processLinks(f)
	local links = {}

	if params.is_empty(f) then
		return 'None'
	end

	local spl = mw.text.split(f, ",")
	for _, link_i in ipairs(spl) do
		link_i = mw.text.trim(link_i)
		if processIcons[link_i] ~= nil then
			table.insert(links, string.format("%s [[%s]]", processIcons[link_i], link_i))
		else
			table.insert(links, string.format("[[%s]]", link_i))
		end
	end
	return table.concat(links, ", ")
end

local function facilityLinks(f)
	local links = {}

	if params.is_empty(f) then
		return 'None'
	end

	local spl = mw.text.split(f, ",")
	for _, link_i in ipairs(spl) do
		link_i = mw.text.trim(link_i)
		if facilitiesList[link_i] ~= nil then
			table.insert(links, string.format("%s", facilitiesList[link_i]))
		elseif facilitiesIcons[link_i] ~= nil then
			table.insert(links, string.format("%s [[%s]]", facilitiesIcons[link_i], link_i))
		else
			table.insert(links, string.format("[[%s]]", link_i))
		end
	end
	return table.concat(links, ", ")
end

function p._main(parameters)
	local args = parameters.args
	local frame = parameters.frame

	-- Append the two tables a parent div
	local parent = mw.html.create('div')
		:addClass('recipe-table')
		:cssText('max-width:480px;')
	local ret = mw.html.create('table')
		:addClass('wikitable infobox-recipe align-center-2 align-right-3')
		:cssText('width:-moz-fit-content; width:fit-content;')

	-- Add "Requirements" header
	ret:tag('tr')
		:tag('th')
		:attr('colspan', '5')
		:wikitext('Requirements')
		:done()
	ret:done()

	---- Row 1: Members
	local members = parameters.members
	local members_icon, members_text
	if members == 'Yes' then
		members_icon = "[[File:P2P icon.png|21px|link=Members]]"
		members_text = "Yes"
	elseif members == 'No' then
		members_icon = "[[File:F2P icon.png|21px|link=Free-to-play]]"
		members_text = "No"
	else
		members_icon = '[[File:P2P-F2P icon.png|21px|link=Members]]'
		members_text = edit
	end

	local row1 = ret:tag('tr')
	row1:tag('td')
		:attr('colspan', '3')
		:wikitext(members_icon .. ' [[Members]]')
		:done()
	row1:tag('td')
		:attr('colspan', '2')
		:wikitext(members_text)
		:done()
	row1:done()

	---- Row 2: Ticks
	local row2 = ret:tag('tr')
	row2:tag('td')
		:attr('colspan', '3')
		:attr('title', 'Ticks per action')
		:wikitext('[[File:Make-X hourglass icon.png|21px|link=Game tick]] [[Game tick|Ticks]]')
		:done()

	local row2b = row2:tag('td')
		:attr('colspan', '2')

	local has_ticks_ref_tag = false
	local ticks = parameters.ticks
	local ticks2 = parameters.ticks2
	local ticksnote = parameters.ticksnote
	if tonumber(ticks, 10) then
		local secs = tonumber(ticks, 10) * 0.6
		local note = ''
		if ticksnote and string.find(ticksnote, '%S') then
			if ticksnote == '1' then
				ticksnote = 'When creating a single item'
			end
			note = frame:extensionTag { name = 'ref', content = ticksnote, args = { group = "r" } }
			has_ticks_ref_tag = true
		end
		if tonumber(ticks2, 10) then
			local secs2 = tonumber(ticks2, 10) * 0.6
			row2b:tag('span')
				:attr('title', commas._add(ticks) .. ' ticks (' .. commas._add(secs) .. ' seconds) per action')
				:wikitext(commas._add(ticks) .. ' (' .. commas._add(secs) .. 's) ')
				:done()
				:wikitext(' / ')
			row2b:tag('span')
				:attr('title', commas._add(ticks2) .. ' ticks (' .. commas._add(secs2) .. ' seconds) per action, ')
				:wikitext('<i> ' .. commas._add(ticks2) .. ' (' .. commas._add(secs2) .. 's)</i> ')
				:done()
			row2b:wikitext(note)
		else
			row2b:attr('title', commas._add(ticks) .. ' ticks (' .. commas._add(secs) .. ' seconds) per action')
				:wikitext(commas._add(ticks) .. ' (' .. commas._add(secs) .. 's) ' .. note)
		end
	elseif string.lower(ticks) == 'varies' then
		local note = ''
		if ticksnote and string.find(ticksnote, '%S') then
			note = frame:extensionTag { name = 'ref', content = ticksnote, args = { group = "r" } }
			has_ticks_ref_tag = true
		end
		row2b:attr('title', 'Varies')
			:wikitext('Varies ' .. note)
	else
		row2b:wikitext(ticks)
	end

	---- Row 3: Improved recipe
	local improved = parameters.improved
	if improved ~= nil then
		local improvedDisplayVal = improvedDisplay(improved)
		local row3 = ret:tag('tr')
		row3:tag('td')
			:attr('colspan', '3')
			:attr('title', 'Improved recipe based on skill level')
			:wikitext('[[File:Improved recipe icon.png|16px|link=]] Improved recipe')
			:done()
		row3:tag('td')
			:attr('colspan', '2')
			:wikitext(improvedDisplayVal)
			:done()
		row3:done()
	end

	---- Row 4: Tool
	local tool = parameters.tool
	if hc(tool) then
		local toolLinksVal = toolImages(tool)
		local row4 = ret:tag('tr')
		row4:tag('td')
			:attr('colspan', '3')
			:wikitext('[[File:Tool belt icon.png|21px|link=]] Tool')
			:done()
		row4:tag('td')
			:addClass(toolLinksVal == 'None' and 'table-na' or nil)
			:attr('colspan', '2')
			:wikitext(toolLinksVal)
			:done()
		row4:done()
	end

	---- Row 5: Process
	local process = parameters.process
	if hc(process) then
		local processLinksVal = processLinks(process)
		local row5 = ret:tag('tr')
		row5:tag('td')
			:attr('colspan', '3')
			:wikitext('[[File:Skilling Spells icon.png|21px|link=]] Process')
			:done()
		row5:tag('td')
			:addClass(processLinksVal == 'None' and 'table-na' or nil)
			:attr('colspan', '2')
			:wikitext(processLinksVal)
			:done()
		row5:done()
	end

	---- Row 6: Facility
	local facility = parameters.facility
	if hc(facility) then
		local facilityLinksVal = facilityLinks(facility)
		local row6 = ret:tag('tr')
		row6:tag('td')
			:attr('colspan', '3')
			:wikitext('[[File:World Map icon.png|21px|link=]] Facility')
			:done()
		row6:tag('td')
			:addClass(facilityLinksVal == 'None' and 'table-na' or nil)
			:attr('colspan', '2')
			:wikitext(facilityLinksVal)
			:done()
		row6:done()
	end

	---- Row 7: Discovery
	local discovery = parameters.discovery
	if hc(discovery) then
		local discoveryLinksVals = discoveryLinks(discovery)
		if #discoveryLinksVals == 0 then
			discoveryLinksVals = { 'None' }
		end
		for _, discoveryLinksVal in ipairs(discoveryLinksVals) do
			local row7 = ret:tag('tr')
			row7:tag('td')
				:attr('colspan', '3')
				:wikitext('<div style="padding:0 2.5px; display:inline-block;">[[File:Discovery icon.png|16px|link=Discovery]]</div> [[Discovery]]')
				:done()
			row7:tag('td')
				:addClass(discoveryLinksVal == 'None' and 'table-na' or nil)
				:attr('colspan', '2')
				:wikitext(discoveryLinksVal)
				:done()
			row7:done()
		end
	end

	-- Skills
	local uses_skills = parameters.uses_skills
	local skills = parameters.skills
	if uses_skills then
		local skill_requirements = mw.html.create('tr')
		skill_requirements
			:tag('th'):attr('colspan', 3):wikitext('Skill'):done()
			:tag('th'):wikitext('Level'):done()
			:tag('th'):wikitext('Experience'):done()

		if #skills == 0 then
			skill_requirements
				:tag('tr')
				:tag('td')
				:attr('colspan', '5')
				:css { ['font-style'] = 'italic', ['text-align'] = 'center' }
				:wikitext('Skills unknown ' .. editbutton())
				:done()
				:done()
		end

		local skill_requirement_rows = generate_skills_rows(skills)

		for _, row in ipairs(skill_requirement_rows) do
			skill_requirements:node(row)
		end

		ret:node(skill_requirements)
	end

	-- Stop burning food level
	local noburnlevel = parameters.noburnlevel
	if noburnlevel then
		ret:tag('tr')
			:tag('td')
			:attr('colspan', '3')
			:attr('title', 'Cooking level required to stop burning this food.')
			:css('cursor', 'help')
			:wikitext('[[File:Burnt lobster.png|21px|link=Cooking/Burn level]] Level to stop burning')
			:done()
			:tag('td')
			:wikitext(noburnlevel)
			:done()
			:tag('td')
			:addClass('table-na')
			:css('text-align', 'center')
			:wikitext('N/A')
			:done()
			:done()
	end

	-- Stop burning food level on the Lumbridge Castle cooking range
	local cookmatic = parameters.cookmatic
	if cookmatic then
		ret:tag('tr')
			:tag('td')
			:attr('colspan', '3')
			:attr('title', 'Cooking level required to stop burning this food on the Lumbridge Castle cooking range.')
			:css('cursor', 'help')
			:wikitext('[[File:Cooking range (Lumbridge Castle).png|21px|link=Cooking range (Lumbridge Castle)]] Cook-o-matic')
			:done()
			:tag('td')
			:wikitext(cookmatic)
			:done()
			:tag('td')
			:addClass('table-na')
			:css('text-align', 'center')
			:wikitext('N/A')
			:done()
			:done()
	end

	-- Stop burning food level with cooking gauntlets
	local gauntlets = parameters.gauntlets
	if gauntlets then
		ret:tag('tr')
			:tag('td')
			:attr('colspan', '3')
			:attr('title', 'Cooking level required to stop burning this food with cooking gauntlets.')
			:css('cursor', 'help')
			:wikitext('[[File:Cooking gauntlets.png|21px|link=Cooking gauntlets]] Level to stop burning with cooking gauntlets')
			:done()
			:tag('td')
			:wikitext(gauntlets)
			:done()
			:tag('td')
			:addClass('table-na')
			:css('text-align', 'center')
			:wikitext('N/A')
			:done()
			:done()
	end

	-- Stop burning food level on a fire
	local fireburn = parameters.fireburn
	if fireburn then
		ret:tag('tr')
			:tag('td')
			:attr('colspan', '3')
			:attr('title', 'Cooking level required to stop burning this food on a fire.')
			:css('cursor', 'help')
			:wikitext('[[File:Bonfire map icon.png|21px|link=Fire]] Burn level (fire)')
			:done()
			:tag('td')
			:wikitext(fireburn)
			:done()
			:tag('td')
			:addClass('table-na')
			:css('text-align', 'center')
			:wikitext('N/A')
			:done()
			:done()
	end

	-- Stop burning food level on a fire with cooking gauntlets
	local firegaunt = parameters.firegaunt
	if firegaunt then
		ret:tag('tr')
			:tag('td')
			:attr('colspan', '3')
			:attr('title', 'Cooking level required to stop burning this food on a fire with cooking gauntlets.')
			:css('cursor', 'help')
			:wikitext('[[File:Bonfire map icon.png|21px|link=Fire]][[File:Cooking gauntlets.png|21px|link=Cooking gauntlets]] Cooking gauntlets (fire)')
			:done()
			:tag('td')
			:wikitext(firegaunt)
			:done()
			:tag('td')
			:addClass('table-na')
			:css('text-align', 'center')
			:wikitext('N/A')
			:done()
			:done()
	end

	-- Add "Other requirements" header
	local quest = parameters.quest
	local achievements = parameters.achievements or {}
	local complexity = parameters.complexity
	local misc_reqs = parameters.misc_reqs
	if (
			hc(quest)
			or #achievements > 0
			or #misc_reqs > 0
			or hc(complexity)
		) then
		ret:tag('tr')
			:tag('th')
			:attr('colspan', '5')
			:wikitext('Other requirements')
			:done()
			:done()
	end

	-- Quest requirement
	if quest then
		ret:tag('tr')
			:tag('td')
			:attr('colspan', '5')
			:wikitext('[[File:Quest.png|21x21px|link=|alt=]] ' .. quest)
			:done()
			:done()
	end

	-- Achievement requirements
	for _, v in ipairs(achievements) do
		ret:tag('tr')
			:tag('td')
			:attr('colspan', '5')
			:wikitext(string.format(
				'%s You must complete the achievement: %s',
				'[[File:Default achievement icon.png|21x21px|link=|alt=]]',
				achievLink(v) or ('[[' .. v .. ']]')
			))
			:done()
			:done()
	end

	-- Complexity requirement
	if complexity then
		ret:tag('tr')
			:tag('td')
			:attr('colspan', '5')
			:wikitext('[[File:Quest.png|21x21px|link=|alt=]] Dungeon Complexity: ' .. complexity)
			:done()
			:done()
	end

	-- Miscellaneous requirements
	for _, v in ipairs(misc_reqs) do
		ret:tag('tr')
			:tag('td')
			:attr('colspan', '5')
			:wikitext(v)
			:done()
			:done()
	end

	-- Materials header
	ret:tag('tr')
		:tag('th')
		:attr('colspan', '3')
		:wikitext('Material')
		:done()
		:tag('th')
		:wikitext('Quantity')
		:done()
		:tag('th')
		:wikitext('Cost')
		:done()
		:done()

	-- Materials
	local materials = parameters.materials
	local material_rows, has_material_ref_tag = generate_mat_rows(materials)
	for _, row in ipairs(material_rows) do
		ret:node(row)
	end

	-- Total cost
	local total_cost_row = generate_total_cost_row(#materials > 0, parameters.material_total_price)
	ret:node(total_cost_row)

	-- Output header
	ret:tag('tr')
		:tag('th')
		:attr('colspan', '3')
		:wikitext('Output')
		:done()
		:tag('th')
		:wikitext('Quantity')
		:done()
		:tag('th')
		:wikitext('Cost')
		:done()
		:done()

	-- Output rows
	local outputs = parameters.outputs
	local output_rows, has_output_ref_tag = generate_mat_rows(outputs)
	for _, row in ipairs(output_rows) do
		ret:node(row)
	end

	-- Profit
	local coins_output = parameters.output_total_price['coins']
	if coins_output ~= nil then
		local coins_profit = parameters.profit['coins']
		local profit_row = generate_profit_row(coins_profit)
		ret:node(profit_row)
	end

	local instructions = parameters.instructions
	if instructions then
		local span_instructions = mw.html.create('span')
		span_instructions:newline()
		span_instructions:wikitext('\n' .. instructions)

		ret:tag('tr')
			:tag('th')
			:attr('colspan', '5')
			:css('text-align', 'center')
			:wikitext('Instructions')
			:done()
			:done()
			:tag('tr')
			:tag('td')
			:attr('colspan', '5')
			:wikitext(tostring(span_instructions))
	end

	local useBucket = parameters.useBucket
	if useBucket then
		addBucket(parameters.subcount,
			ticks, ticks2, ticksnote,
			improved, parameters.method,
			materials, outputs, tool, process, facility, discoveryLinks(discovery), complexity, misc_reqs,
			skills, uses_skills,
			members, quest, achievements,
			useBucket, instructions,
			noburnlevel, gauntlets, fireburn, firegaunt, cookmatic)
	end
	ret = ret:allDone()
	addCategories(ret, parameters.subcount,
		ticks, ticks2, ticksnote,
		improved, parameters.method,
		materials, outputs, tool, process, facility,
		discovery, complexity, misc_reqs,
		skills, uses_skills,
		members, quest, achievements,
		useBucket, instructions, parameters.unknown_boostable_flag,
		noburnlevel, gauntlets, fireburn, firegaunt, cookmatic,
		-- deprecated parameters
		args.storeValue, args.alchValue, args.totalvar)

	parent:node(ret)

	-- If there are any ref tags, add a Reflist section
	local outro = ''
	local has_ref_tag = has_ticks_ref_tag or has_material_ref_tag or has_output_ref_tag
	if has_ref_tag then
		outro = '<div class="reflist">\n' .. frame:extensionTag { name = 'references', args = { group = 'r' } } .. '</div>'
	end

	-- Return div with tables + categories + reflist
	return tostring(parent) .. outro
end

function p._bucket(args)
	if args.useBucket then
		addBucket(args.subcount,
			args.ticks, args.ticks2, args.ticksnote,
			args.improved, args.method,
			args.materials, args.outputs, args.tool, args.process, args.facility,
			discoveryLinks(args.discovery), args.complexity, args.misc_reqs,
			args.skills, args.uses_skills,
			args.members, args.quest, args.achievements,
			args.useBucket, args.instructions,
			args.noburnlevel, args.gauntlets, args.fireburn, args.firegaunt, args.cookmatic)
	end

	local ret = mw.html.create('')
	addCategories(ret, args.subcount,
		args.ticks, args.ticks2, args.ticksnote,
		args.improved, args.method,
		args.materials, args.outputs, args.tool, args.process, args.facility,
		args.discovery, args.complexity, args.misc_reqs,
		args.skills, args.uses_skills,
		args.members, args.quest, args.achievements,
		args.useBucket, args.instructions, args.unknown_boostable_flag,
		args.noburnlevel, args.gauntlets, args.fireburn, args.firegaunt, args.cookmatic,
		-- deprecated parameters
		args.storeValue, args.alchValue, args.totalvar)
	return ret
end

local function split_comma(arg)
	if not arg then
		return nil
	end

	local arg_lower = arg:lower()
	if arg_lower == "no" or arg_lower == "none" then
		return nil
	end

	local ret = mw.text.split(arg, "%s*,%s*")
	if next(ret) == nil then
		return nil
	else
		return ret
	end
end

function addBucket(subcount,
				   ticks, ticks2, ticksnote,
				   improved, method,
				   materials, outputs, tool, process, facility, discovery, complexity, misc_reqs,
				   skills, uses_skills,
				   members, quest, achievements,
				   useBucket, instructions,
				   noburnlevel, gauntlets, fireburn, firegaunt, cookmatic)
	if not onmain() then
		return
	end
	if not useBucket then
		return
	end

	local jsonObject = {
		skills = skills,
		members = members,
		materials = {},
		outputs = {},
		ticks = ticks,
		process = process,
		facility = facility,
		tool = tool,
		discovery = discovery,
		complexity = complexity,
		-- rsw-excl
		improved = improved,
		method = method or '',
		quest = quest or '',
		skill = uses_skills,
		noburnlevel = noburnlevel,
		gauntlets = gauntlets,
		fireburn = fireburn,
		firegaunt = firegaunt,
		cookmatic = cookmatic,
	}
	local outputPages = {}
	for _, v in ipairs(outputs) do
		local output = {
			page = v.page,
			name = v.name,
			variant = v.variant,
			portion = v.portion,
			quantity = v.quantity,
			image = v.image,
			cost_method = v.cost_method,
			cost_expr = v.cost_expr,
			cost_unit = v.cost_unit,
		}
		table.insert(jsonObject.outputs, output)
		table.insert(outputPages, v.page)
	end

	if facility == 'Glyph spot' then
		local glyph = mw.text.split(outputPages[1] or '', '%s')[1]
		if glyphTypes[glyph] then
			jsonObject['glyphType'] = glyphTypes[glyph]
		end
	end

	local materialPages = {}
	for _, v in ipairs(materials) do
		local material = {
			page = v.page,
			name = v.name,
			variant = v.variant,
			portion = v.portion,
			quantity = v.quantity,
			image = v.image,
			cost_method = v.cost_method,
			cost_expr = v.cost_expr,
			cost_unit = v.cost_unit,
		}
		table.insert(jsonObject.materials, material)
		table.insert(materialPages, v.page)
	end

	local subname = (outputs[1]["name"] or '') .. '_' .. subcount

	local bucketmap = {
		['uses_material'] = materialPages,
		['uses_tool'] = split_comma(tool),
		['uses_process'] = split_comma(process),
		['uses_facility'] = split_comma(facility),
		['discovery'] = discovery,
		['production_json'] = mw.text.jsonEncode(jsonObject),
		['production_output'] = outputPages,
		['production_main_output'] = outputPages[1] or '',
		['is_boostable'] = {},
		['uses_skill'] = {},
		['sequence'] = subcount,
		source_template = 'recipe', -- Bucket:recipe is written to by multiple templates, some of which only give partial data.
	}
	for _, s in ipairs(skills) do
		table.insert(bucketmap['uses_skill'], s.name)
		if yesno(s.boostable, false) then
			table.insert(bucketmap['is_boostable'], s.name)
		end
	end
	if tonumber(ticks, 10) then
		bucketmap['ticks'] = ticks
	end
	if tonumber(ticks2, 10) then
		bucketmap['ticks_secondary'] = ticks2
	end
	if ticksnote and string.find(ticksnote, '%S') then
		bucketmap['ticks_note'] = ticksnote
	end

	bucket("recipe").sub(subname).put(bucketmap)
end

function addCategories(ret, subcount,
					   ticks, ticks2, ticksnote,
					   improved, method,
					   materials, outputs, tool, process, facility, discovery, complexity, misc_reqs,
					   skills, uses_skills,
					   members, quest, achievements,
					   useBucket, instructions, unknown_boostable_flag,
					   noburnlevel, gauntlets, fireburn, firegaunt, cookmatic,
					   storeValue, alchValue, totalvar)
	if not onmain() then
		return
	end

	local cats = { '[[Category:Recipes]]' }

	if unknown_boostable_flag then
		table.insert(cats, '[[Category:Recipes missing boostable]]')
	end

	local missinglvl = false
	local missingexp = false
	local nonnumexp = false
	for _, s in ipairs(skills) do
		if s.name then
			local all_lower = s.name:lower()
			all_lower = ucfirst(all_lower)
			table.insert(cats, string.format('[[Category:Recipes using %s]]', all_lower))
		end
		if string.find(s.level, '?') then
			missinglvl = true
		end
		if string.find(s.experience, '?') then
			missingexp = true
		elseif tonumber(s.experience) == nil then
			nonnumexp = true
		end
	end
	if missinglvl then
		table.insert(cats, '[[Category:Missing skill info values]]')
	end
	if missingexp then
		table.insert(cats, '[[Category:Needs experience info]]')
	end
	if nonnumexp then
		table.insert(cats, '[[Category:Pages with non-numeric experience quantity]]')
	end
	if uses_skills and #skills == 0 then
		table.insert(cats, '[[Category:Missing skill info values]]')
	end

	if not tonumber(ticks, 10) and string.lower(ticks) ~= 'varies' then
		table.insert(cats, '[[Category:Recipes missing ticks]]')
	end
	if missing_gep then
		table.insert(cats, '[[Category:Recipes missing item values]]')
	end
	if missing_calcvalue then
		table.insert(cats, '[[Category:Recipes with items missing alternate values]]')
	end
	if missing_storeprice then
		table.insert(cats, '[[Category:Recipes with items missing store values]]')
	end
	-- Old/manual prices
	if old_price then
		table.insert(cats, '[[Category:Recipes using manual values]]')
	end
	if method and method:find('[Tt]ransmutation') then
		table.insert(cats, '[[Category:Items creatable by transmutation]]')
	end

	if tool ~= nil then
		table.insert(cats, '[[Category:Recipes that require a tool]]')
	end

	if process ~= nil then
		table.insert(cats, '[[Category:Recipes that use a process]]')
	end

	if facility ~= nil then
		table.insert(cats, '[[Category:Recipes that use a facility]]')
	end

	if noburnlevel or gauntlets or fireburn or firegaunt or cookmatic then
		table.insert(cats, '[[Category:Food with conditional burn immunity]]')
	end

	if storeValue ~= nil or alchValue ~= nil or totalvar ~= nil then
		table.insert(cats, '[[Category:Pages with deprecated parameters]]')
	end

	ret:wikitext(table.concat(cats, ''))
end

return p