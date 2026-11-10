require("strict")
require('Module:Mw.html extension')
local on_main = require('Module:Mainonly').on_main()
local p = {}

-- =============================================================================
-- MODULE DEPENDENCIES AND SETUP
-- =============================================================================

local arr = require('Module:Array')
local plink = require('Module:Plink')._plink
local coins = require('Module:Currency')._coins
local get_calcvalue = require('Module:Calcvalue')._get
local get_popcost = require('Module:Pop resource cost')._calcvalue
local round = require('Module:Number')._round
local paramtest = require('Module:Paramtest')
local ttools = require('Module:TableTools')
local tables = require('Module:Tables')

local usage_data = require('Module:UsageCost/data')
local DIVINE_CHARGE_SLOTS = usage_data.DIVINE_CHARGE_SLOTS
local COMBAT_RATES = usage_data.COMBAT_RATES
local chargeDrainResearch, chargeDrainItemLvl = usage_data.chargeDrainResearch, usage_data.chargeDrainItemLvl

local lang = mw.getContentLanguage()
local function fnum(num)
    return lang:formatNum(num)
end
local GEPRICES = mw.loadJsonData('Module:GEPrices/data.json')

-- =============================================================================
-- CONSTANTS
-- =============================================================================

local consts = {
    max_methods = 6,
    max_items = 20,
    charges_per_charge = 3000,
    inv_cape_fac = 0.98,
    att_cape_fac = 0.98,
    drain_rate = 60
}

-- =============================================================================
-- PRICE CALCULATION AND CACHING
-- =============================================================================

-- This is the most complex function in the module. We're using a function closure here
-- specifically because of the need for caching calcvalue results; calcvalue is expensive to call,
-- and this allows us to cache the results. It works like a global without being one.
local get_item_price = (function()
    local cost_cache = { calcvalue = {}, pop = {} }
    local tradeable_ref = { "", "" }
    local calcvalue_ref = { "Item is not tradeable on the Grand Exchange. Using calculated value.", "calcvalue" }
    local untradeable_ref = { "Item is not tradeable on the Grand Exchange.", "untradeable" }

    local function get_cached_calcvalue(item)
        if cost_cache.calcvalue[item] ~= nil then
            return cost_cache.calcvalue[item], calcvalue_ref
        end

        -- It should be unreachable
        if GEPRICES[item] then
            cost_cache.calcvalue[item] = false
            return nil, untradeable_ref
        end

        local result, value = pcall(get_calcvalue, item)
        if result and value then
            cost_cache.calcvalue[item] = value
            return value, calcvalue_ref
        else
            cost_cache.calcvalue[item] = false
            return nil, untradeable_ref
        end
    end

    local function get_cached_pop_value(item)
        if cost_cache.pop[item] ~= nil then
            local cached = cost_cache.pop[item]
            return cached[1], { cached[2], "pop" }
        end

        local result, value, notes = pcall(get_popcost, item, 1, true)
        if result and value then
            cost_cache.pop[item] = { value, notes }
            return value, { notes, "pop" }
        else
            cost_cache.pop[item] = { false, nil }
            return nil, untradeable_ref
        end
    end

    local function get_price_impl(item_name, cost_method)
        if item_name:lower() == "coins" then
            return 1, tradeable_ref
        end

        if cost_method == 'pop' then
            return get_cached_pop_value(item_name)
        end

        local ge_price = GEPRICES[item_name]
        if ge_price then
            return ge_price, tradeable_ref
        end

        return get_cached_calcvalue(item_name)
    end

    return get_price_impl
end)()

-- =============================================================================
-- ARGUMENT HANDLING AND UTILITIES
-- =============================================================================

local function get_default_args(args)
    -- This pattern is really annoying
    local smithing = tonumber(paramtest.default_to(args.smithing, 0)) or 0
    local duration = tonumber(paramtest.default_to(args.duration, 60)) or 60
    local chargesperhour = tonumber(paramtest.default_to(args.chargesperhour, 1800)) or
        COMBAT_RATES[1].rate * consts.drain_rate
    local invlvl = tonumber(paramtest.default_to(args.invlvl, 1)) or 1
    local itemlvl = tonumber(paramtest.default_to(args.itemlvl, 1)) or 1
    local charges = tonumber(paramtest.default_to(args.charges, 0)) or 0
    local tier = tonumber(paramtest.default_to(args.tier, 1)) or 1
    local format = paramtest.default_to(args.format, "default")
    local op = paramtest.default_to(args.op, "min"):lower()
    local cape = paramtest.default_to(args.cape, false)
    cape = cape and cape ~= "false" and cape ~= ""

    -- Lowercase (obviously)
    op = op:lower()

    -- Whether or not capes apply
    local invcape = cape and consts.inv_cape_fac or 1
    local attcape = cape and consts.att_cape_fac or 1

    return {
        smithing = smithing,
        duration = duration,
        chargesperhour = chargesperhour,
        invlvl = invlvl,
        tier = tier,
        itemlvl = itemlvl,
        charges = charges,
        format_ = format,
        op = op,
        invcape = invcape,
        attcape = attcape
    }
end

local function get_cost_category(type_name)
    local cost_categories = {
        fixedduration = "fixed",
        combatcharge = "combat",
        divinecharge = "div",
        nonstandarddegrade = "nonstandard"
    }

    local lower_type = type_name:lower()
    return cost_categories[lower_type] or error("Unknown cost type: " .. lower_type)
end

-- =============================================================================
-- BUCKET INTEGRATION
-- =============================================================================

local function write_bucket_data(args, data, is_augmented)
    if (not on_main) or paramtest.has_content(args.bucket) then
        return
    end
    bucket('usage_cost').put({
        is_augmented = is_augmented,
        json = mw.text.jsonEncode(data)
    })
end

-- =============================================================================
-- REFERENCE HANDLING
-- =============================================================================

-- Creates a context for ref management
local function create_ref_context(suppress_refs)
    return {
        suppress_refs = suppress_refs or false,
        used_ref_names = {}
    }
end

-- Adds a ref to the uc group
local function ref(context, txt, name)
    if context.suppress_refs then
        return ""
    end

    -- Use paramtest for empty content check
    if paramtest.is_empty(txt) then
        return ""
    end

    -- Skip if this ref name was already used
    if name and context.used_ref_names[name] then
        return ""
    end

    -- Mark this ref name as used
    if name then
        context.used_ref_names[name] = true
    end

    -- Create the actual reference
    return mw.getCurrentFrame():extensionTag {
        name = 'ref',
        content = txt,
        args = {
            name = paramtest.default_to(name, ""),
            group = "uc"
        }
    }
end

local function add_reflist(context)
    if context.suppress_refs then
        return ""
    end

    return '<div class="reflist">' ..
        mw.getCurrentFrame():extensionTag {
            name = "references",
            args = { group = "uc" }
        } ..
        '</div>'
end

-- =============================================================================
-- DATA EXTRACTION AND PROCESSING
-- =============================================================================

local function get_max_index_range(search_str, max_allowed, args)
    -- Find the highest index by checking all keys
    local highest_index = 1
    local pattern = "^" .. search_str .. "(%d+)"

    for key, _ in pairs(args) do
        if type(key) == "string" then
            local index = key:match(pattern)
            if index then
                local num_index = tonumber(index)
                if num_index and num_index > highest_index then
                    highest_index = num_index
                end
            end
        end
    end

    -- Don't exceed max_allowed
    highest_index = math.min(highest_index, max_allowed)

    -- Return range from 1 to highest_index
    return arr.range(highest_index)
end

-- Get item data from a method
local function extract_single_item_data(context, args, method_prefix, item_idx)
    local item = args[method_prefix .. "item" .. item_idx]
    local qty = tonumber(paramtest.default_to(args[method_prefix .. "qty" .. item_idx], 1))
    local cost_method = args[method_prefix .. "cost" .. item_idx]
    local price, ref_info = get_item_price(item, cost_method)
    local ref_text = ref(context, ref_info[1], ref_info[2])

    return {
        item = item,
        qty = qty,
        cost_method = cost_method,
        price = price or 0,
        ref = ref_text
    }
end

local function build_method(context, args, method_prefix)
    -- Extract item data for this method (refs handled automatically)
    local item_indices = get_max_index_range(method_prefix .. "item", consts.max_items, args)
    local items_data = {}
    for _, idx in ipairs(item_indices) do
        local item_data = extract_single_item_data(context, args, method_prefix, idx)
        table.insert(items_data, item_data)
    end

    -- Get duration (method-specific overrides global)
    local method_duration = args[method_prefix .. "duration"]
    local global_duration = args.duration
    local duration_minutes = tonumber(method_duration or global_duration or 0)

    return {
        iqprs = items_data,
        description = args[method_prefix .. "desc"],
        is_smithing = args[method_prefix .. "smithing"] or false,
        duration = duration_minutes / 60 -- Convert to hours
    }
end

local function build_methods_from_json(ref_context, ucJSON)
    local methods = {}

    for _, json_method in ipairs(ucJSON.methods) do
        -- Build items data directly from JSON
        local items_data = {}
        for _, item_data in ipairs(json_method.iqprs or {}) do
            local price, ref_info = get_item_price(item_data.item, item_data.cost_method)
            local ref_text = ref(ref_context, ref_info[1], ref_info[2])

            table.insert(items_data, {
                item = item_data.item,
                qty = item_data.qty,
                cost_method = item_data.cost_method,
                price = price or 0,
                ref = ref_text
            })
        end

        -- Build method directly without intermediate conversions
        local method = {
            iqprs = items_data,
            description = json_method.desc,
            is_smithing = json_method.smithing or false,
            duration = (json_method.duration or 60) / 60 -- Convert to hours
        }

        table.insert(methods, method)
    end

    return methods
end

-- =============================================================================
-- TABLE BUILDING UTILITIES
-- =============================================================================

local function create_base_table(with_sorting)
    local css_class = "wikitable sortable"
    if with_sorting then
        css_class = css_class .. " align-right-2 autosort=2,d"
    end

    return mw.html.create("table"):addClass(css_class)
end

local function get_descriptions_table(methods)
    -- Check if any method has a description
    local has_descriptions = false
    for _, method in ipairs(methods) do
        if method.description then
            has_descriptions = true
            break
        end
    end

    if not has_descriptions then
        return nil
    end

    local cells = {}
    for _, method in ipairs(methods) do
        table.insert(cells, {
            text = method.description or "<small>N/A</small>",
            attr = method.description and {} or { ["data-sort-value"] = "0" },
            class = method.description and "" or "table-na"
        })
    end

    return { { tag = "th", text = "Method" }, unpack(cells) }
end

local function time_to_str(total_hours)
    local hours, minute_dec = math.modf(total_hours)
    local minutes, second_dec = math.modf(round(minute_dec * 60, 3))
    local seconds = round(second_dec * 60)

    local result = ""

    -- hours if present
    if hours > 0 then
        local hour_suffix = hours == 1 and "hour" or "hours"
        result = result .. hours .. " " .. hour_suffix .. " "
    end

    -- minutes if present
    if minutes > 0 then
        local minute_suffix = minutes == 1 and "minute" or "minutes"
        result = result .. minutes .. " " .. minute_suffix .. " "
    end

    -- seconds if present
    if seconds > 0 then
        local second_suffix = seconds == 1 and "second" or "seconds"
        result = result .. seconds .. " " .. second_suffix .. " "
    end

    return result
end

local function get_durations_table(methods)
    -- Check if all methods have the same duration
    local first_duration = methods[1].duration
    local all_same_duration = true
    for _, method in ipairs(methods) do
        if method.duration ~= first_duration then
            all_same_duration = false
            break
        end
    end

    if all_same_duration then
        -- Single colspan cell using temp-tables pattern
        return {
            { tag = "th", text = "Duration" },
            { text = time_to_str(first_duration), attr = { colspan = #methods } }
        }
    else
        -- Individual duration for each method
        local row = { { tag = "th", text = "Duration" } }
        for _, method in ipairs(methods) do
            table.insert(row, { text = time_to_str(method.duration) })
        end
        return row
    end
end

local function get_combat_rates(context, costs, charges)
    local combat_rate_rows = {}

    for i, combat_rate in ipairs(COMBAT_RATES) do
        local rate_name = combat_rate.name
        local rate_value = combat_rate.rate

        -- Create header with reference
        local charges_per_hour = rate_value * consts.drain_rate
        local header_text = rate_name ..
            " rate" .. ref(context, fnum(charges_per_hour) .. " charges per hour.", "rate" .. i)

        -- Build row using temp-tables pattern
        local row = { { tag = "th", text = header_text } }

        -- Calculate costs for this rate
        local rate_multiplier = charges_per_hour / charges
        for _, cost in ipairs(costs) do
            local rate_cost = cost * rate_multiplier
            table.insert(row, { text = coins(round(rate_cost)) })
        end

        table.insert(combat_rate_rows, row)
    end

    return combat_rate_rows
end

local function format_method_items(context, method)
    -- Format each item in the method
    local formatted_items = {}
    for _, iqpr in ipairs(method.iqprs) do
        local wikitext = tostring(fnum(round(iqpr.qty, 2)) .. " x " .. plink(iqpr.item)) .. iqpr.ref
        table.insert(formatted_items, wikitext)
    end

    local content = table.concat(formatted_items, '<br>')

    if method.is_smithing then
        local smithing_ref =
        "Cost at [[armour repair stand]] and [[Whetstone (device)|whetstone]] is reduced by 0.5% per [[Smithing]] level (Reductions of 50% at 99 Smithing, 55.5% at 110 Smithing)."
        content = content .. ref(context, smithing_ref, "smithing")
    end

    return {
        text = content,
        css = { ["vertical-align"] = "bottom" }
    }
end

local function calculate_method_cost(method)
    local total_cost = 0
    for _, iqpr in ipairs(method.iqprs) do
        total_cost = total_cost + (iqpr.qty * iqpr.price)
    end
    return total_cost
end

local function prepare_usage_data(frame)
    local args = frame:getParent().args
    local ref_context = create_ref_context(false)

    local method_indices = get_max_index_range("method", consts.max_methods, args)
    if #method_indices == 0 then
        error("No methods defined")
    end

    local methods = {}
    local items = {}
    local costs = {}

    for _, idx in ipairs(method_indices) do
        local method_name = "method" .. idx
        local method = build_method(ref_context, args, method_name)
        table.insert(methods, method)
        table.insert(items, format_method_items(ref_context, method))
        table.insert(costs, calculate_method_cost(method))
    end

    return args, methods, items, costs, ref_context
end

-- =============================================================================
-- TABLE BUILDER
-- =============================================================================

local function create_html_table(ref_context, row_groups)
    local assembled_table = create_base_table(false)
    local all_rows = {}

    for _, rows in ipairs(row_groups) do
        if rows then        -- Skip nil rows
            for _, row in ipairs(rows) do
                if row then -- Skip nil individual rows
                    table.insert(all_rows, row)
                end
            end
        end
    end

    tables._table(assembled_table, all_rows)
    return tostring(assembled_table) .. add_reflist(ref_context)
end

local function create_usage_table_builder(ref_context)
    local builder = {
        rows = {},
        context = ref_context
    }

    function builder:add_row(row_data)
        table.insert(self.rows, row_data)
        return self
    end

    function builder:add_simple_row(header, value)
        return self:add_row({
            { tag = "th", text = header },
            { text = value }
        })
    end

    function builder:add_header_row(header_text, cells)
        local row = { { tag = "th", text = header_text } }
        for _, cell in ipairs(cells or {}) do
            table.insert(row, cell)
        end
        table.insert(self.rows, row)
        return self
    end

    function builder:add_per_hour_header(method_count)
        return self:add_row({
            { tag = "th", text = "Per hour", attr = { colspan = method_count + 1 } }
        })
    end

    function builder:add_charges_header(charges, method_count)
        return self:add_header_row("[[Equipment degradation|Combat charges]]",
            { { text = fnum(charges), attr = { colspan = method_count } } })
    end

    function builder:add_hourly_costs(item_costs, methods)
        local cells = {}
        for i, cost in ipairs(item_costs) do
            local duration = methods[i].duration
            local cost_per_hour = cost / duration
            local rounded_cost = round(cost_per_hour)
            table.insert(cells, { text = coins(rounded_cost) })
        end
        return self:add_header_row("Cost", cells)
    end

    function builder:add_combat_rates(costs, charges)
        local combat_rates = get_combat_rates(self.context, costs, charges)
        for _, rate_data in ipairs(combat_rates) do
            table.insert(self.rows, rate_data)
        end
        return self
    end

    function builder:add_degrade_mechanics(degrade_text, method_count)
        table.insert(self.rows, {
            { tag = "th", text = "Degrade mechanics" },
            { text = degrade_text, attr = { colspan = method_count + 1 } }
        })
        return self
    end

    function builder:build()
        return self.rows
    end

    return builder
end

local UsageTableBuilder = {}

function UsageTableBuilder.combat_charge(ref_context, methods, items, item_costs, charges)
    local builder = create_usage_table_builder(ref_context)

    builder:add_charges_header(charges, #methods)

    local desc_row = get_descriptions_table(methods)
    if desc_row then builder:add_row(desc_row) end

    builder:add_header_row("Item(s) consumed", items)
    builder:add_header_row("Total GE price",
        arr.map(item_costs, function(cost) return { text = coins(cost) } end))

    builder:add_per_hour_header(#methods)

    builder:add_combat_rates(item_costs, charges)

    return builder:build()
end

function UsageTableBuilder.fixed_duration(ref_context, methods, items, item_costs)
    local builder = create_usage_table_builder(ref_context)

    local desc_row = get_descriptions_table(methods)
    if desc_row then builder:add_row(desc_row) end

    builder:add_row(get_durations_table(methods))
    builder:add_header_row("Item(s) consumed", items)
    builder:add_header_row("Total GE price",
        arr.map(item_costs, function(cost) return { text = coins(cost) } end))

    builder:add_per_hour_header(#methods)

    builder:add_hourly_costs(item_costs, methods)

    return builder:build()
end

function UsageTableBuilder.non_standard_degrade(ref_context, methods, items, item_costs, charges, degrade_text)
    local builder = create_usage_table_builder(ref_context)

    builder:add_charges_header(charges, #methods)

    local desc_row = get_descriptions_table(methods)
    if desc_row then builder:add_row(desc_row) end

    builder:add_header_row("Item(s) consumed", items)
    builder:add_header_row("Total GE price",
        arr.map(item_costs, function(cost) return { text = coins(cost) } end))
    builder:add_degrade_mechanics(degrade_text, #methods)

    return builder:build()
end

function UsageTableBuilder.divine_charge(ref_context, tier_display, slot_name, charges_per_hour, coins_per_hour)
    local builder = create_usage_table_builder(ref_context)

    builder:add_simple_row("Tier", tier_display)
    builder:add_simple_row("Slot", slot_name)

    builder:add_per_hour_header(1)

    builder:add_simple_row("Charges", charges_per_hour)
    builder:add_simple_row("Cost", coins_per_hour)

    return builder:build()
end

-- =============================================================================
-- COST CALCULATIONS
-- =============================================================================

local function calculate_divine_charge_cost_per_hour(args, ucJSON)
    local defaults = get_default_args(args)

    -- Get the original tier from JSON or args
    local original_tier = ucJSON["tier"]

    -- Apply the tier adjustment for calculation
    local effective_tier = original_tier < 70 and 67 or original_tier

    local tier_factor = (effective_tier - 60) / 8
    local time_factor = DIVINE_CHARGE_SLOTS[ucJSON["slot"]:lower()]["chargeDrainMult"] * 60 * 60
    local invention_level = defaults.invlvl
    local researchFactor = chargeDrainResearch(invention_level)
    local invention_cape_factor = defaults.invcape
    local item_level = defaults.itemlvl
    local charges_per_hour = tier_factor * time_factor * researchFactor * invention_cape_factor *
        chargeDrainItemLvl(item_level)
    local price_per_charge = GEPRICES["Divine charge"] / consts.charges_per_charge
    return { charges_per_hour * price_per_charge }
end

local function cost_per_hour(args, ucJSON, kind)
    if kind == "div" then
        return calculate_divine_charge_cost_per_hour(args, ucJSON)
    end

    local ref_context = create_ref_context(true)
    local methods = build_methods_from_json(ref_context, ucJSON)
    local item_costs = {}

    for _, method in ipairs(methods) do
        table.insert(item_costs, calculate_method_cost(method))
    end

    -- Apply type-specific transformations inline
    if kind == "fixed" then
        local hourly_costs = {}
        for i, cost in ipairs(item_costs) do
            local duration_minutes = methods[i].duration
            table.insert(hourly_costs, cost / duration_minutes / 60)
        end
        return hourly_costs
    elseif kind == "combat" then
        -- Inline combat cost calculation
        local defaults = get_default_args(args)
        local charges_per_hour = defaults.chargesperhour
        local attack_cape_factor = defaults.attcape
        local total_charges = ucJSON.charges
        local cost_multiplier = (charges_per_hour / total_charges) * attack_cape_factor

        local combat_costs = {}
        for _, cost in ipairs(item_costs) do
            table.insert(combat_costs, cost * cost_multiplier)
        end
        return combat_costs
    elseif kind == "nonstandard" then
        return item_costs
    else
        error("Unknown cost calculation kind: " .. tostring(kind))
    end
end

local function apply_cost_metric(args, cost)
    local defaults = get_default_args(args) -- Use new pattern
    local operation = defaults.op

    if operation == "avg" then
        return arr.sum(cost) / arr.len(cost)
    elseif operation == "highest" or operation == "max" then
        return arr.max(cost)
    elseif operation == "min" then
        return arr.min(cost)
    else
        -- Default to min if unknown operation
        return arr.min(cost)
    end
end

-- =============================================================================
-- PUBLIC INTERFACE OUTPUT FUNCTIONS
-- =============================================================================

function p.fixedDuration(frame)
    local args, methods, items, item_costs, ref_context = prepare_usage_data(frame)
    local usage_table = UsageTableBuilder.fixed_duration(ref_context, methods, items, item_costs)

    write_bucket_data(args, { type = "FixedDuration", methods = methods }, false)
    return create_html_table(ref_context, { usage_table })
end

function p.combatCharge(frame)
    local args, methods, items, item_costs, ref_context = prepare_usage_data(frame)
    local defaults = get_default_args(args)
    local charges = math.max(defaults.charges, 1)

    local usage_table = UsageTableBuilder.combat_charge(ref_context, methods, items, item_costs, charges)
    local contains_divine_charge = arr.any(items,
        function(item) return item.text and item.text:match("Divine charge") end)

    write_bucket_data(args, { type = "CombatCharge", charges = charges, methods = methods }, contains_divine_charge)
    return create_html_table(ref_context, { usage_table })
end

function p.nonStandardDegrade(frame)
    local args, methods, items, item_costs, ref_context = prepare_usage_data(frame)
    local defaults = get_default_args(args) -- Use new pattern
    local charges = defaults.charges
    local degrade_text = args.degradetext

    local usage_table = UsageTableBuilder.non_standard_degrade(ref_context, methods, items, item_costs, charges,
        degrade_text)

    write_bucket_data(args, { type = "NonStandardDegrade", charges = charges, methods = methods }, false)
    return create_html_table(ref_context, { usage_table })
end

function p.divineCharge(frame)
    local args = frame:getParent().args
    if paramtest.is_empty(args.slot) then
        error("Required argument 'slot' is missing or empty")
    end

    local ref_context = create_ref_context(false)
    local defaults = get_default_args(args)
    local slot = args.slot:lower()
    local slot_name = DIVINE_CHARGE_SLOTS[slot] and DIVINE_CHARGE_SLOTS[slot]["name"]

    -- Store the original tier for display
    local original_tier = defaults.tier
    local display_tier = original_tier

    -- Add ref if tier < 70
    local tier_ref = ""
    if original_tier < 70 then
        local tier_adjust_ref = "Any tier lower than 70 is treated as tier 67 for charge drain calculations."
        tier_ref = ref(ref_context, tier_adjust_ref, "tier_adjust")
    end

    -- For calculations, use the calc tier (67 for < 70)
    local effective_tier = (original_tier < 70) and 67 or original_tier
    local tier_factor = (effective_tier - 60) / 8
    local time_factor = DIVINE_CHARGE_SLOTS[slot]["chargeDrainMult"] * 60 * 60
    local charges_per_hour = tier_factor * time_factor

    local coins_per_hour = coins(round(GEPRICES["Divine charge"] * charges_per_hour / consts.charges_per_charge))
    local div_ref_str =
    "Can be reduced by [[Charge pack#Charge drain reduction|research]], [[equipment level]], [[Efficient]] and [[Enhanced Efficient]] perks, and the [[Invention cape]] perk."
    local divine_ref = fnum(charges_per_hour) .. ref(ref_context, div_ref_str, "divine charge")

    local formatted_tier = fnum(display_tier) .. tier_ref
    local usage_table = UsageTableBuilder.divine_charge(ref_context, formatted_tier, slot_name, divine_ref,
        coins_per_hour)

    -- Still use original tier in Bucket data for consistency
    write_bucket_data(args, {
        type = "DivineCharge",
        ["tier"] = original_tier,
        ["effective_tier"] = effective_tier,
        ["slot"] = slot
    }, true)

    return create_html_table(ref_context, { usage_table })
end

function p.getUsageCost(frame)
    local args = frame:getParent().args
    local item_args = ttools.compressSparseArray(args)

    -- Calculate cost for each item
    local total_cost = 0
    for _, item_name in ipairs(item_args) do
        local data = bucket('usage_cost')
            .select('json')
            .where('page_name', item_name)
            .limit(1)
            .run()
        local json_data = mw.text.jsonDecode(data[1].json) or {}
        local cost_type_name = json_data.type:lower()
        local cost = cost_per_hour(args, json_data, get_cost_category(cost_type_name))
        local metric_value = apply_cost_metric(args, cost)
        total_cost = total_cost + metric_value
    end

    -- Inline format logic instead of calling format_cost
    local defaults = get_default_args(args)
    local format_type = defaults.format_

    if format_type == "coins" then
        return coins(total_cost)
    elseif format_type == "coinssort" then
        return string.format("data-sort-value=\"%d\" | %s", total_cost, coins(total_cost))
    else
        return total_cost
    end
end

function p.getMultiUsageCosts(cat, notcat)
    local data = bucket('usage_cost')
        .select('page_name', 'json')
        .where(cat)
        .where(bucket.Not(notcat))
        .limit(5000)
        .run()
    local result_rows = {}
    local args = { is_smithing = false, smithing_level = 1 }

    for _, entry in ipairs(data) do
        local page_name = entry.page_name
        local decoded = mw.text.jsonDecode(entry.json)
        local type_name = decoded and decoded.type

        if type_name and get_cost_category(type_name) ~= "nonstandard" then
            local cost_type = get_cost_category(type_name:lower())
            local cost = cost_per_hour(args, decoded, cost_type)
            local metric_value = apply_cost_metric(args, cost)

            -- Inline formatting (eliminate format_usage_row)
            local link_text = plink(page_name, { size = "x30px" })

            local rounded_cost = math.floor(metric_value + 0.5)
            local row = {
                { text = link_text },
                { text = coins(rounded_cost), attr = { ["data-sort-value"] = rounded_cost } }
            }
            table.insert(result_rows, { metric_value, row })
        end
    end
    table.sort(result_rows, function(a, b) return a[1] > b[1] end)
    local out = {}
    for _, v in ipairs(result_rows) do
        table.insert(out, v[2])
    end
    return out
end

function p.getUsageCostTable(frame)
    local args = frame:getParent().args
    local cat = args['cat']
    cat = 'Category:' .. cat

    local notcat = args['notcat']
    notcat = 'Category:' .. notcat

    local multi_usage_costs = p.getMultiUsageCosts(cat, notcat)

    local builder = create_usage_table_builder(create_ref_context(true)) -- Suppress refs for this table

    -- Add header row
    builder:add_header_row("Item", { { tag = 'th', text = "Hourly usage cost" } })

    -- Add all data rows
    for _, row in ipairs(multi_usage_costs) do
        builder:add_row(row)
    end

    -- Build and create table using existing pattern
    local table_data = builder:build()
    local assembled_table = create_base_table(true) -- With sorting
    tables._table(assembled_table, table_data)

    return tostring(assembled_table)
end

return p