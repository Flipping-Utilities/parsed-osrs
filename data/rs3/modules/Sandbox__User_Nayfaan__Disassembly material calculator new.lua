local rtPrices = mw.loadJsonData('Module:Sandbox/User:Nayfaan/data.json')
local idMap = mw.loadJsonData('Module:GEIDs/data.json')
local limits = mw.loadJsonData('Module:GELimits/data.json')
local volumes = mw.loadJsonData('Module:GEVolumes/data.json')
local item_variants = mw.loadData('Module:Disassembly category calculator/data').versions
local material_names = mw.loadData('Module:Disassemble/mats')
local material_categories = require('Module:Disassemble/categories')
local material_costs = require('Module:Component costs')
local coins = require('Module:Currency')._coins
local camt = require('Module:Currency')._amount
local formatCalcvalue = require('Module:Calcvalue formatter').main
local yn = require('Module:Yesno')

require("Module:Mw.html extension")

local p = {}
local DISASSEMBLES_PER_HOUR = 3000
local ITEM_LEVEL_STR = '<br><span style="font-size:smaller;">(item level 9+)</span>'
local lang = mw.getContentLanguage()
local expr = mw.ext.ParserFunctions.expr

-- forward declarations
local storeprice, dungprice, compcost, calculateCostByMethod

-- getting last update time

function p.lastUpdate()
	return rtPrices["%LAST_UPDATE_F%"]
end

--[===========================================[
HELPER FUNCTIONS
--]===========================================]

-- basic plink
local function plink_pic(x)
    return string.format('[[File:%s.png|link=%s]]', x, x)
end

local function nocoins(amt)
    return camt(amt, 'nocoins')
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

local function json_decode(str)
    if str == nil then
        return nil
    end

    return mw.text.jsonDecode(str)
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

-- ge price, limits, and volumes
local function gep(x)
    return prices[x], limits[x], volumes[x]
end

-- ge price
local function geprice(x)
    return prices[x]
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

function calculateCostByMethod(method, method_expr, cost_unit, portion)
    local price, price_note
    local price_note_deduplicate = false

    if method == 'currency' then
        local cost_number = tonumber(method_expr, 10)
        if cost_number == nil then
            price = nil
            price_note = 'Error: Could not recognise this number: <code>' .. method_expr .. '</code>'
        else
            price = cost_number
        end
    elseif method == 'fixed' then
        local cost_number = tonumber(method_expr, 10)
        if cost_number == nil then
            price = nil
            price_note = 'Error: Could not recognise this number: <code>' .. method_expr .. '</code>'
        else
            price = cost_number
            price_note = 'Fixed price given'
        end
    elseif method == 'expr' then
        local ok, expr_cost_v = pcall(preprocess, method_expr)
        if ok and tonumber(expr_cost_v, 10) then
            price = expr_cost_v
        else
            price = nil
            price_note = 'Error: Could not evaluate this expression: <code>' .. method_expr .. '</code>'
        end
    elseif method == 'gemw' then
        price = geprice(method_expr)
        if price == false then
            price = nil
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
            price_note = "Error: No material cost could be found for: " .. method_expr
        end
    elseif method == 'estcost' then
        local ok, temp_cost = pcall(getEstimatedCost, method_expr, cost_unit, portion)

        if ok and temp_cost ~= nil then
            price = temp_cost[1]
            price_note = temp_cost[2]
        else
            price = nil
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
            price_note = "Error: No store price could be found for: " .. method_expr
        end
    elseif method == 'smuggler' then
        local ok, temp_cost = pcall(getSmugglePrice, method_expr, portion)
        if ok then
            price = tonumber(temp_cost)
        else
            price = nil
            price_note = "Error: No smuggler price could be found for: " .. method_expr
        end
    elseif method == 'invocation' then
        price = preprocess(method_expr)
        price_note = 'Price calculated from: <code>' .. formatCalcvalue(method_expr) .. '</code>'
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

local function _fnum(x)
    local _x = tonumber(x)
    if not _x then
        return x
    end
    if math.abs(_x) < 100 then
        return x
    end
    return lang:formatNum(_x)
end

local function fnum(x)
    x = tonumber(x)
    if x then
        return _fnum(round(x))
    end
    return 0
end

function p.queryItemDisassemblyInfos(cat, lim, bucketlim, includeUntradeable)
    local b = bucket('disassembly')
        .select('page_name', 'category', 'augmented', 'estimated_cost', 'estimated_cost_per', 'transformed_items', 'recurring_cost', 'recurring_cost_per', 'required_quantity', 'normal_material_quantity', 'json')
        .where('Category:' .. cat)
        .where(bucket.Not('Category:Equipment applied cosmetic changes'))
        .where(bucket.Not('Category:Dyed equipment'))
        .where(bucket.Not('Category:Removed content'))
        .limit(tonumber(bucketlim) or 10000)

    if not includeUntradeable then
        b.where(bucket.Or('Category:Grand Exchange items', 'Category:Disassembly calculator override'))
    end

    if lim then
        b.where(bucket.Or('Category:High buy limit', 'Category:Disassembly calculator override'))
    end

    local records = {}

    local res = b.run()
    for _, v in ipairs(res) do
        local json = json_decode(v.json)
        v.json = json
        if json == nil then
            mw.log('Found json is null: ' .. v.page_name)
        elseif not json.nocalc then
            table.insert(records, v)
        end
    end

    return records
end

--[===========================================[

DISASSEMBLY BY MATERIAL - REGULAR COMPONENTS

--]===========================================]

local function makeRow_normal(context, item, itemVariant, includeUntradeable)
    local disInfo = item.json
    local name = itemVariant
    if not itemVariant then
        if disInfo.name then
            name = disInfo.name
        elseif disInfo.version then
            name = disInfo.page_name .. ' ' .. disInfo.version
        end
    end

    local is_special = false
    local mat = disInfo.materials[context.material]
    if mat == nil then
        -- probably a special material, so lets check that
        local specialdata = disInfo.special
        if specialdata then
            mat = specialdata[context.material]
            if mat then
            	if not mat.chance or mat.chance <= 0 then
            		return nil
            	end
                is_special = true
            end
        end
    end

    if mat == nil then
        return nil
    end

    local matQty, junk, junkStr, chance, matChance, matQtyValid, matChanceValid
    if not is_special then
        matQtyValid = true
        matChanceValid = true
        matQty = tonumber(disInfo.mat_quantity)
        junk = disInfo.junk and disInfo.junk[1]
        if junk == nil or matQty == nil then
            mw.log("WARNING: Junk or cqty is nil, skipping item: " .. name)
            matQtyValid = false
        end

        if matQtyValid then
            junkStr = string.format('%.1f%%', junk)
            if junkStr == '0.0%' then
                junkStr = '0%'
            end
            matChance = mat / disInfo.totalweight * 100
            chance = 100 * matQty * (1 - junk / 100) * matChance / disInfo.totalweight
        end
    else
        matQtyValid = true
        matChanceValid = true
        matQty = tonumber(mat.quantity) or 0
        junk = 0
        junkStr = '<span style="border-bottom:1px dotted #999; font-style:italic;">Special</span>'
        if type(mat.chance) == 'number' then
            matChance = mat.chance
        elseif type(mat.chance) == 'table' then
            matChance = 100 * mat.chance[1] / mat.chance[2]
        else
            matChanceValid = false
        end

        if matChanceValid then
            chance = matQty * matChance
        end
    end

    local price, limit, volume, cost_portion

    local recurring_cost = item.recurring_cost
    if recurring_cost ~= nil then
        cost_portion = item.recurring_cost_per or 1
        local cost = calculateCostByMethod('expr', recurring_cost, nil --[['coins']], item.cost_portion)
        price = cost.price
    else
        local base_cost_method = disInfo.base_cost_method
        cost_portion = item.estimated_cost_per or 1
        if base_cost_method == 'gemw' then
            price, limit, volume = gep(name)
        elseif base_cost_method == 'store' then
            local cost = calculateCostByMethod('store', item.page_name, nil --[['coins']], cost_portion)
            price = cost.price
        elseif base_cost_method == 'recipe' then
            local cost = calculateCostByMethod('estcost', item.page_name, nil --[['coins']], cost_portion)
            price = cost.price
        elseif item.estimated_cost ~= nil then
            local cost = calculateCostByMethod('expr', item.estimated_cost, nil --[['coins']], cost_portion)
            price = cost.price
        end
    end

    if not price and not includeUntradeable then
        return nil
    end

    local itemQty = disInfo.item_quantity
    if itemQty ~= nil then
        itemQty = tonumber(itemQty) or 1
    end

    if price then
        local portion = string.match(item.category, '(%d) dose')
        if portion ~= nil then
            portion = tonumber(portion) or 1
            if portion ~= cost_portion then
                price = round(price / cost_portion * portion, 2)
            end
        end

        if itemQty ~= cost_portion then
            price = round(price / cost_portion * itemQty, 2)
        end
    end

    local displayName = string.format('[[%s|%s]]', item.page_name, name)

    if itemQty ~= nil and itemQty > 1 then
        displayName = itemQty .. ' × ' .. displayName
    end

    local matQtyStr = matQty
    if matQtyValid and disInfo.augmented then
        displayName = displayName .. ITEM_LEVEL_STR
        matQty = matQty * 4
        matQtyStr = matQty .. ' (4×)'
        junk = 0
        junkStr = '0%'
    end

    local rawMaster
    if not is_special then
        if context.is_component then
            rawMaster = 1.2 * matChance
        else
            rawMaster = disInfo.mastermod * matChance
        end
    end

    local cost, mph
    if matChanceValid then
        if price then
            cost = price / (chance / 100)
        end
        mph = chance * DISASSEMBLES_PER_HOUR / 100
    end

    local tr = mw.html.create('tr')
    tr:addClass('dis-calc-row')
    if not is_special then
        tr:attr {
            ['data-dis-mats'] = matQty,
            ['data-dis-rawmaster'] = rawMaster,
            ['data-dis-raw'] = matChance,
            ['data-dis-price'] = price,
            ['data-dis-junk'] = junk,
        }
    end
    tr:attr { ['data-dis-isaugmented'] = tostring(disInfo.augmented) }

    -- item name
    tr
        :td { plink_pic(name), attr = { ['data-sort-value'] = name } }
        :td { displayName, attr = { ['data-sort-value'] = name } }
    -- comp qty
        :td { matQtyValid and matQtyStr or 'Unknown', attr = { ['data-sort-value'] = matQty } }
    -- junk
        :td { junkStr, attr = { ['data-sort-value'] = junk }, class = 'data-dis-junkcell' }
    -- price
        :td { price and nocoins(price) or 'N/A', attr = { ['data-sort-value'] = price or 0 } }
        :addClassIf(not price, 'table-na')
    -- limit
    -- don't need special rounding for limit, its an int, just add commas if needed
        :td { limit and _fnum(limit) or 'N/A', attr = { ['data-sort-value'] = limit or 0 }, class = 'data-dis-limitcell' }
        :addClassIf(not limit, 'table-na')
    -- volume
    -- don't need special rounding for volume, its an int, just add commas if needed
        :td { volume and _fnum(volume) or 'N/A', attr = { ['data-sort-value'] = volume or 0 }, class = 'data-dis-volumecell' }
        :addClassIf(not volume, 'table-na')
    -- raw chance
        :td { matChanceValid and fnum(matChance) .. '%' or 'Unknown', attr = { ['data-sort-value'] = matChance }, class = 'data-dis-rawchancecell' }
    -- chance
        :td { matChanceValid and fnum(chance) .. '%' or 'Unknown', attr = { ['data-sort-value'] = chance }, class = 'data-dis-chancecell' }
    -- cost
        :td { cost and nocoins(cost) or 'N/A', attr = { ['data-sort-value'] = cost }, class = 'data-dis-costcell' }
        :addClassIf(not cost, 'table-na')
    -- matsperhour
        :td { fnum(mph), attr = { ['data-sort-value'] = mph }, class = 'data-dis-mphcell' }
    -- timevalue
        :td { '', attr = { ['data-sort-value'] = '' }, class = 'data-dis-timevaluecell' }
    context.rows = context.rows + 1
    return tr
end

function p.makeTable_normal(mat, lim, bucketlim, includeUntradeable)
    local _mat = string.lower(mat)
    _mat = string.gsub(_mat, 'parts?', '')
    _mat = string.gsub(_mat, 'components?', '')
    _mat = mw.text.trim(_mat)
    _mat = material_names[_mat]
    local context = { rows = 0 }
    context.is_component = type(string.find(_mat, 'component')) == 'number'
    context.material = _mat

    local cat = 'Items that disassemble into ' .. _mat
    local t = mw.html.create('table')
    t
        :addClass('wikitable sortable sticky-header align-center-1 align-left-2 discalc-timevalue-hide')
        :attr('id', 'dis-calc-table')
        :css('text-align', 'right')
        :tr()
        :th { 'Item', attr = { colspan = '2' } }
        :th { 'Materials<br>each', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Junk', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Cost per<br>disassemble', attr = { ['data-sort-type'] = 'number' } }
        :th { '[[Grand Exchange#Trade restrictions|Buy<br>limit]]', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Trade<br>vol.', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Raw<br>chance', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Avg. number', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Cost per mat', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Mats per hour', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Efficiency ratio', attr = { ['data-sort-type'] = 'number' }, class = 'data-dis-timevaluecell' }

    for _, item in ipairs(p.queryItemDisassemblyInfos(cat, lim, bucketlim, includeUntradeable)) do
        if item_variants[item.page_name] then
            for _, item_variant in ipairs(item_variants[item.page_name]) do
                t:node(makeRow_normal(context, item, item_variant, includeUntradeable))
            end
        else
            t:node(makeRow_normal(context, item, nil, includeUntradeable))
        end
    end

    local div = mw.html.create('div')
    div:attr {
        ['id'] = 'dis-calc-settings',
        ['data-div-charge'] = prices['Divine charge'],
        ['data-is-material'] = 'true',
        ['data-is-component'] = tostring(context.is_component),
    }:wikitext("Please enable JavaScript to be able to change the junk reduction used, or switch to [[auto disassembler]]s. Until then, the table displays values for no junk reduction with no machine only.")

    local intro = [=[This is a list of all tradeable items that can give [[%s]] with the effective cost per material. Elsewhere on the wiki a price of %s per material is assumed.

;Notes
* GE prices may be inaccurate - we can't really do anything about that
* Untradeable items are excluded, with some exceptions

In the table:
* The "materials each" column is not the number of X components the item gives, but rather how many total materials you'll get everytime you disassemble the item.
* The raw chance column is the chance per non-junk material to get %s when disassembling the item.
* The Avg. number column is the number of %s you should expect when disassembling each item; this represents the junk chance and the number of materials in addition to the raw chance. It is listed as a percentage, to reduce decimal places needed.
** For example, if an item has an average number of 0.13%%, you should expect that you'll get 13 materials in 10,000 disassembles (0.13 per 100 disassembles, 0.0013 per disassemble) on average
* The materials per hour column is based upon performing the ideal 3,000 disassembly actions per hour. In reality, it will probably be less due to connection latency, server latency, and human error. The column also makes no attempt to account for buy limits or availability.
* The efficiency ratio column can be enabled by the checkbox below. Efficiency ratio is a measure of your efficiency when disassembling this time, taking into account the value of your time - see [[efficiency]] for details. '''The lower the number, the more efficient it is to disassemble'''. This, again, makes no attempt account for buy limits or availability, nor extra time spent obtaining untradeable items.
* The average number and cost is given for no junk reduction by default, but this can be changed with the drop-down menu.
[[Category:Calculators|%s]][[Category:Items that disassemble into %s| ]]
]=]
    t:tag('caption'):wikitext(string.format("Results shown: <span class='discalc-totalresults'>%s</span>", fnum(context.rows)))
    return string.format(intro, _mat, camt(material_costs._price(_mat), 'nocoinsc'), _mat, _mat, mw.title.getCurrentTitle().text, _mat) .. tostring(div) .. tostring(t)
end

--[===========================================[

DISASSEMBLY BY MATERIAL - SPECIAL-ONLY

--]===========================================]

local function makeRow_special(context, item, itemVariant, includeUntradeable, includemph)
    local disInfo = item.json
    local name = itemVariant
    if not itemVariant then
        if disInfo.name then
            name = disInfo.name
        elseif disInfo.version then
            name = disInfo.page_name .. ' ' .. disInfo.version
        end
    end

    -- grab quantity and chance
    local matQty, matChance, matQtyValid, matChanceValid
    if disInfo.special then
        local mat = disInfo.special[context.material]
        if mat then
            matQtyValid = true
            matChanceValid = true
            matQty = tonumber(mat.quantity)
            if type(mat.chance) == 'number' then
                matChance = mat.chance
            elseif type(mat.chance) == 'table' then
                matChance = 100 * mat.chance[1] / mat.chance[2]
            else
                -- shows items that can be dissasembled for mats with N/A even if chance is unknown
                matChanceValid = false
                matChance = 100
            end
            if matChance == 0 then
                matChanceValid = false
            end

            if not matQty then
                matQtyValid = false
                matQty = 1
            end
        end
    end

    -- grab trade price, limit and volume
    local price, limit, volume, cost_portion

    local recurring_cost = item.recurring_cost
    if recurring_cost ~= nil then
        cost_portion = item.recurring_cost_per or 1
        local cost = calculateCostByMethod('expr', recurring_cost, nil --[['coins']], item.cost_portion)
        price = cost.price
    else
        local base_cost_method = disInfo.base_cost_method
        cost_portion = item.estimated_cost_per or 1
        if base_cost_method == 'gemw' then
            price, limit, volume = gep(name)
        elseif base_cost_method == 'store' then
            local cost = calculateCostByMethod('store', item.page_name, nil --[['coins']], cost_portion)
            price = cost.price
        elseif base_cost_method == 'recipe' then
            local cost = calculateCostByMethod('estcost', item.page_name, nil --[['coins']], cost_portion)
            price = cost.price
        elseif item.estimated_cost ~= nil then
            local cost = calculateCostByMethod('expr', item.estimated_cost, nil --[['coins']], cost_portion)
            price = cost.price
        end
    end

    if not price and not includeUntradeable then
        return nil
    end

    local itemQty = disInfo.item_quantity
    if itemQty ~= nil then
        itemQty = tonumber(itemQty) or 1
    end

    if price then
        local portion = string.match(item.category, '(%d) dose')
        if portion ~= nil then
            portion = tonumber(portion) or 1
            if portion ~= cost_portion then
                price = round(price / cost_portion * portion, 2)
            end
        end

        if itemQty ~= cost_portion then
            price = round(price / cost_portion * itemQty, 2)
        end
    end

    local displayName = string.format('[[%s|%s]]', item.page_name, name)
    if itemQty ~= nil and itemQty > 1 then
        displayName = itemQty .. ' × ' .. displayName
    end

    local matQtyStr = matQty
    local junk = disInfo.junk[1]
    if matQtyValid and disInfo.augmented then
        displayName = displayName .. ITEM_LEVEL_STR
        matQty = matQty * 4
        matQtyStr = matQty .. ' (4×)'
        junk = 0
    end

    local cost, mph
    if price and matQtyValid and matChanceValid then
        cost = math.floor((price / (matQty * matChance / 100)) + 0.5)
        if includemph then
            mph = (matChance / 100 * matQty) * DISASSEMBLES_PER_HOUR
        end
    end

    local tr = mw.html.create('tr')
    tr:attr { ['data-dis-isaugmented'] = tostring(disInfo.augmented) }
    tr
        :td { plink_pic(name), attr = { ['data-sort-value'] = name } }
        :td { displayName, attr = { ['data-sort-value'] = name } }
        :td { matQtyValid and matQtyStr or 'Unknown', attr = { ['data-sort-value'] = matChanceValid and matQty or 'Infinity' } }
        :td { matChanceValid and fnum(matChance) .. '%' or 'Unknown', attr = { ['data-sort-value'] = matChanceValid and matChance or '-Infinity' } }
        :td { fnum(junk) .. '%', attr = { ['data-sort-value'] = junk }, class = 'data-dis-junkcell' }
        :td { price and nocoins(price) or 'N/A', attr = { ['data-sort-value'] = price or 0 } }
        :addClassIf(not price, 'table-na')
        :td { limit and _fnum(limit) or 'N/A', attr = { ['data-sort-value'] = limit }, class = 'data-dis-limitcell' }
        :addClassIf(not limit, 'table-na')
        :td { volume and _fnum(volume) or 'N/A', attr = { ['data-sort-value'] = volume }, class = 'data-dis-volumecell' }
        :addClassIf(not volume, 'table-na')
        :td { matChanceValid and cost and nocoins(cost) or 'N/A', attr = { ['data-sort-value'] = matChanceValid and cost or 'Infinity' }, class = 'data-dis-costcell' }
        :addClassIf(not cost, 'table-na')
    if includemph then
        tr
            :td { matChanceValid and fnum(mph) or 'N/A', attr = { ['data-sort-value'] = mph }, class = 'data-dis-mphcell' }
            :addClassIf(not mph, 'table-na')
    end
    context.rows = context.rows + 1
    return tr
end

function p.makeTable_special(mat, lim, bucketlim, includeUntradeable, includemph)
    local context = { rows = 0 }
    local _mat = string.lower(mat)
    _mat = string.gsub(_mat, 'parts?', '')
    _mat = string.gsub(_mat, 'components?', '')
    _mat = mw.text.trim(_mat)
    _mat = material_names[_mat]
    context.is_component = type(string.find(_mat, 'component')) == 'number'
    context.material = _mat
    context.short_material = string.gsub(_mat, context.is_component and ' components' or ' parts', '')

    local cat = 'Items that disassemble into ' .. _mat
    local t = mw.html.create('table')
        :addClass('wikitable sticky-header sortable align-center-1 align-left-2')
        :css('text-align', 'right')
    local header = t:tr()

    header
        :th { 'Item', attr = { colspan = '2' } }
        :th { context.short_material .. '<br>each', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Chance', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Junk', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Cost per<br>disassemble', attr = { ['data-sort-type'] = 'number' } }
        :th { '[[Grand Exchange#Trade restrictions|Buy<br>limit]]', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Trade<br>vol.', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Effective<br>cost', attr = { ['data-sort-type'] = 'number' } }
    if includemph then
        header:th { 'Mats per hour', attr = { ['data-sort-type'] = 'number' } }
    end

    for _, item in ipairs(p.queryItemDisassemblyInfos(cat, lim, bucketlim, includeUntradeable)) do
        if item_variants[item.page_name] then
            for _, item_variant in ipairs(item_variants[item.page_name]) do
                t:node(makeRow_special(context, item, item_variant, includeUntradeable, includemph))
            end
        else
            t:node(makeRow_special(context, item, nil, includeUntradeable, includemph))
        end
    end

    local intro = [=[This is a list of all tradeable items that can give [[%s]] with the effective cost per material. As this is a 'special' material, it is received independently of the item's junk chance, so only one effective cost column is required. Elsewhere on the wiki %s per material is assumed.

;Notes
* As mentioned above, rare/special components are received independent of junk chance, so that does not factor in to the cost
* Once special chances are more reliably known, they will be incorporated into the calculator
* GE prices may be inaccurate - we can't really do anything about that
* Untradeable items are excluded, with some exceptions
* If an item is missing from the table, it is most likely because the chance of receiving the special material is not known
[[Category:Calculators|%s]][[Category:Items that disassemble into %s| ]]
]=]

    t:tag('caption'):wikitext(string.format("Results shown: <span class='discalc-totalresults'>%s</span>", fnum(context.rows)))
    local material_cost = material_costs._price(_mat)
    local material_price = material_cost and 'a price of ' .. camt(material_cost, 'nocoinsc') or 'a unknown price'
    return string.format(intro, _mat, material_price, mw.title.getCurrentTitle().text, _mat) .. tostring(t)
end

--[===========================================[

DISASSEMBLY BY CATEGORY

--]===========================================]

local function makeRow_category(context, item, itemVariant, includeUntradeable)
    local disInfo = item.json
    local name = itemVariant
    if not name then
        if disInfo.name then
            name = disInfo.name
        elseif disInfo.version then
            name = disInfo.page_name .. ' ' .. disInfo.version
        end
    end

    local matQty = disInfo.mat_quantity
    local junk = disInfo.junk and disInfo.junk[1]
    local matQtyValid = true
    if junk == nil or matQty == nil then
        mw.log("WARNING: Junk or cqty is nil, skipping item: " .. name)
        matQtyValid = false
    end

    local price, limit, volume, cost_portion

    local recurring_cost = item.recurring_cost
    if recurring_cost ~= nil then
        cost_portion = item.recurring_cost_per or 1
        local cost = calculateCostByMethod('expr', recurring_cost, nil --[['coins']], item.cost_portion)
        price = cost.price
    else
        local base_cost_method = disInfo.base_cost_method
        cost_portion = item.estimated_cost_per or 1
        if base_cost_method == 'gemw' then
            price, limit, volume = gep(name)
        elseif base_cost_method == 'store' then
            local cost = calculateCostByMethod('store', item.page_name, nil --[['coins']], cost_portion)
            price = cost.price
        elseif base_cost_method == 'recipe' then
            local cost = calculateCostByMethod('estcost', item.page_name, nil --[['coins']], cost_portion)
            price = cost.price
        elseif item.estimated_cost ~= nil then
            local cost = calculateCostByMethod('expr', item.estimated_cost, nil --[['coins']], cost_portion)
            price = cost.price
        end
    end

    if not price and not includeUntradeable then
        return nil
    end

    local itemQty = disInfo.item_quantity
    if itemQty ~= nil then
        itemQty = tonumber(itemQty) or 1
    end

    if price then
        local portion = string.match(item.category, '(%d) dose')
        if portion ~= nil then
            portion = tonumber(portion) or 1
            if portion ~= cost_portion then
                price = round(price / cost_portion * portion, 2)
            end
        end

        if itemQty ~= cost_portion then
            price = round(price / cost_portion * itemQty, 2)
        end
    end

    local displayName = string.format('[[%s|%s]]', item.page_name, name)
    local matQtyStr = matQty
    if matQtyValid and disInfo.augmented then
        displayName = displayName .. ITEM_LEVEL_STR
        matQty = matQty * 4
        matQtyStr = matQty
        junk = 0
    end

    if itemQty ~= nil and itemQty > 1 then
        displayName = itemQty .. ' × ' .. displayName
    end

    local cost
    if price and junk and matQty then
        cost = price / ((1 - junk / 100) * matQty)
    end
    local mph = ((1 - junk / 100) * matQty) * DISASSEMBLES_PER_HOUR

    local tr = mw.html.create('tr')
    tr:addClass('dis-calc-row')
        :attr {
            ['data-dis-mats'] = matQty,
            ['data-dis-raw'] = 100,
            ['data-dis-price'] = price,
            ['data-dis-junk'] = junk,
            ['data-dis-isaugmented'] = tostring(disInfo.augmented),
        }
        :td { plink_pic(name), attr = { ['data-sort-value'] = name } }
        :td { displayName, attr = { ['data-sort-value'] = name } }
        :td { matQtyValid and matQtyStr or 'Unknown', attr = { ['data-sort-value'] = matQty } }
        :td { fnum(junk) .. '%', attr = { ['data-sort-value'] = junk }, class = 'data-dis-junkcell' }
        :td { price and nocoins(price) or 'N/A', attr = { ['data-sort-value'] = price or 0 } }
        :addClassIf(not price, 'table-na')
        :td { limit and _fnum(limit) or 'N/A', attr = { ['data-sort-value'] = limit }, class = 'data-dis-limitcell' }
        :addClassIf(not limit, 'table-na')
        :td { cost and nocoins(cost) or 'N/A', attr = { ['data-sort-value'] = cost or 0 }, class = 'data-dis-costcell' }
        :addClassIf(not cost, 'table-na')
        :td { fnum(mph), attr = { ['data-sort-value'] = mph }, class = 'data-dis-mphcell' }
        :td { '', attr = { ['data-sort-value'] = '' }, class = 'data-dis-timevaluecell' }
    context.rows = context.rows + 1
    return tr
end


function p.makeTable_category(cat, lim, bucketlim, includeUntradeable)
    local _cat = 'Disassemble category/' .. cat
    local t = mw.html.create('table')

    t:attr('id', 'dis-calc-table')
        :addClass('wikitable sortable sticky-header align-center-1 align-left-2 discalc-timevalue-hide')
        :css('text-align', 'right')
        :tr()
        :th { 'Item', attr = { colspan = '2' } }
        :th { 'Materials', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Junk', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Cost per<br>disassemble', attr = { ['data-sort-type'] = 'number' } }
        :th { '[[Grand Exchange#Trade restrictions|Buy<br>limit]]', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Effective<br>cost', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Mats per hour', attr = { ['data-sort-type'] = 'number' } }
        :th { 'Efficiency ratio', attr = { ['data-sort-type'] = 'number' }, class = 'data-dis-timevaluecell' }

    local context = { rows = 0 }
    for _, item in ipairs(p.queryItemDisassemblyInfos(_cat, lim, bucketlim, includeUntradeable)) do
        local variants = item_variants[item.page_name]
        if variants then
            for _, item_variant in ipairs(variants) do
                t:node(makeRow_category(context, item, item_variant, includeUntradeable))
            end
        else
            t:node(makeRow_category(context, item, nil, includeUntradeable))
        end
    end

    local div = mw.html.create('div')
    div:attr {
        ['id'] = 'dis-calc-settings',
        ['data-div-charge'] = prices['Divine charge'],
        ['data-is-material'] = 'false',
        ['data-is-component'] = 'false',
    }:wikitext("Please enable JavaScript to be able to change the junk reduction used, or switch to [[auto disassembler]]s. Until then, the table displays values for no junk reduction with no machine only.")
    local intro = [=[This is a list of all tradeable items in the [[Template:Disassembly/categories|disassembly category]] we've named [[:Category:Disassemble category/%s|"%s"]], with the effective cost per material obtained. This is a measure of how much obtaining each non-junk material will cost at base junk chance, with the option to change to any junk chance using JavaScript.

For more details on the calculator, see [[Calculator:Disassembly by category]]. ''Be aware that not all items have been updated with disassembly details. See [[User:Gaz Lloyd/Invention|here]] for instructions on how to help the wiki gather this information!''
[[Category:Calculators|%s]][[Category:Disassemble category/%s| ]]

%s
]=]
    t:tag('caption'):wikitext(string.format("Results shown: <span class='discalc-totalresults'>%s</span>", fnum(context.rows)))
    return string.format(intro, cat, cat, cat, cat, material_categories._get_info { cat = cat }, mw.title.getCurrentTitle().text) .. tostring(div) .. tostring(t)
end

--[===========================================[

ENTRY POINTS

--]===========================================]
local function isEmptyTable(x)
    if #x > 0 then
        return false
    end
    for _, _ in pairs(x) do
        return false
    end
    return true
end

function p.main(frame)
    local fr = frame
    local args = {}
    if fr then
        args = fr.args
    end
    if isEmptyTable(args) then
        fr = frame:getParent()
        args = fr.args
    end
    
    -- Getting prices from RT data
    
    local price_point = nil
    if args.price == "INS" or args.price == "INB" then
    	price_point = args.price
    else
    	error('price not passed; use "INB" or "INS"')
    end

	prices = {}
	
	for itemName, id in pairs(idMap) do
		if itemName == "%LAST_UPDATE%" or itemName == "%LAST_UPDATE_F%" then
			prices[itemName] = id
	    else
	        local data = rtPrices.data[id]
	        if data then
	        	if price_point == "INS" then
	            	prices[itemName] = data.low
	            elseif price_point == "INB" then
	            	prices[itemName] = data.high
	            else
	            	error('price point processing failed')
	            end
	        end
	    end
	end

    if args.type == 'material' then
        return p.makeTable_normal(args[1], yn(args.limit), args.bucketlimit, yn(args.include_untradeable, true))
    elseif args.type == 'special' then
        return p.makeTable_special(args[1], yn(args.limit), args.bucketlimit, yn(args.include_untradeable, true), yn(args.include_mph, false))
    elseif args.type == 'category' then
        return p.makeTable_category(args[1], yn(args.limit), args.bucketlimit, yn(args.include_untradeable, true))
    end
    error('type not passed; use "material", "special", or "category"')
end

return p