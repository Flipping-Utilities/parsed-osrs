-- <nowiki>
--------------------------
-- Module for [[Template:Infobox Seed]]
-- Please test changes to this module at [[Module:Infobox Seed/sandbox]] first
------------------------
local p = {}

--
-- imports
--
local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')
local any = require('Module:Array').any
local render = require('Module:Infobox Farming').render
local yn = require("Module:Yesno");

local isDefined = infobox.isDefined

local protection_choices = { any = true, never = true, all = true, none = true }
local protection_types = { payment = true, item = true, relic = true, flower = true, location = true }

local regrow_arg, regrow_bucket, regrow_notes;

local growth_potion_names = {
    ["Supreme growth potion (sundry)"] = "Sundry",
    ["Supreme growth potion (leafy)"] = "Leafy",
    ["Supreme growth potion (bushy)"] = "Bushy",
    ["Supreme growth potion (fruity)"] = "Fruity",
    ["Supreme growth potion (woody)"] = "Woody",
}

local patch_bucket_values = {
    allotment = "Allotment patch",
    flower = "Flower Patch",
    herb = "Herb patch",
    hops = "Hops Patch",
    bush = "Bush patch",
    tree = "Tree patch",
    ["fruit tree"] = "Fruit Tree Patch",
    calquat = "Calquat patch",
    ["spirit tree"] = "Spirit Tree Patch",
    ["elder tree"] = "Elder tree patch",
    ["crystal tree"] = "Crystal tree patch",
    ["money tree"] = "Money tree patch",
    cactus = "Cactus patch",
    mushroom = "Mushroom patch",
    ["evil turnip"] = "Evil turnip patch",
    ["jade vine"] = "Jade vine patch",
    ["nightshade"] = "Nightshade patch",
    ["harmony pillar"] = "Harmony pillar",
    ["vine flower"] = "Vine flower patch",
    ["vine herb"] = "Vine herb patch",
    ["vine bush"] = "Vine bush patch",
    ["dungeoneering"] = "Farming patch (Dungeoneering)",
    arc = "Berry planter",
    ["wilderness herb"] = "Herb patch (Wilderness)",
    ["wilderness flower"] = "Flower patch (Wilderness)",
    potato = "Potato patch",
}

local max_iter = 6

function string.starts(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

--
-- main
--
function p.main(frame)
    local args = frame:getParent().args
    local ret = infobox.new(args)

    ret:defineParams {
        -- General infomation
        { name = 'level', func = level_arg },
        { name = 'seed', func = { name = seed_args, params = { 'seed', 'name' }, flag = 'd' } },
        { name = 'seedling', func = 'has_content' },
        { name = 'seedlingW', func = 'has_content' },
        { name = 'sapling', func = 'has_content' },
        { name = 'growing', func = { name = growing_args, params = { 'growing', 'grown' }, flag = 'd' } },
        { name = 'grown', func = 'has_content' },
        { name = 'patch', func = patch_arg },
        { name = 'plantXP', func = to_number },
        { name = 'checkXP', func = to_number },
        { name = 'harvestXP', func = to_number },
        { name = 'harvestAction', func = to_number },
        { name = 'harvestLife', func = to_number },
        { name = 'yieldPerHarvest', func = yield_per_harvest_arg },
        { name = 'seedAmount', func = { name = to_number, params = { 'seedAmount', 1 }, flag = { 'd', 'r' } } },

        -- Growth
        { name = 'cycle', func = to_number },
        { name = 'cycleLength', func = to_number },
        { name = 'growthPotion', func = growth_potion_arg },
        { name = 'rapidGrowth', func = to_boolean },
        { name = 'regrow', func = regrow_arg },
        { name = 'regrow_bucket', func = { name = regrow_bucket, params = { 'regrow' } } },
        { name = 'regrow_notes', func = { name = regrow_notes, params = { 'regrow' } } },
    }

    local protection_params = {}
    for i = 1, max_iter do
        local protection_i = 'protection' .. tostring(i)

        -- Protections
        ret:defineParams {
            { name = protection_i .. 'type', func = protection_arg },
            { name = protection_i .. 'name', func = 'has_content' },
            { name = protection_i .. 'amount', func = to_number },
            { name = protection_i .. 'price', func = price_arg },

            { name = protection_i .. 'item', func = {
                name = pack_protection_item,
                params = {
                    protection_i .. 'type',
                    protection_i .. 'name',
                    protection_i .. 'amount',
                    protection_i .. 'price',
                },
                flag = 'd'
            } },
        }
        table.insert(protection_params, protection_i .. 'item')
    end

    ret:defineParams {
        { name = 'protectionChoice', func = protection_choice_arg },

        { name = 'protections', func = {
            name = to_list,
            params = protection_params,
            flag = 'd'
        } },
    }

    local crop_params = {}
    for i = 1, max_iter do
        local crop_i = 'crop' .. tostring(i)

        -- Crops
        ret:defineParams {
            { name = crop_i .. 'name', func = 'has_content' },
            { name = crop_i .. 'skill', func = 'has_content' },

            -- derived params
            { name = crop_i .. 'item', func = {
                name = pack_crop_item,
                params = {
                    crop_i .. 'name',
                    crop_i .. 'skill',
                },
                flag = 'd'
            } },
        }
        table.insert(crop_params, crop_i .. 'item')
    end

    ret:defineParams {
        { name = 'crops', func = {
            name = to_list,
            params = crop_params,
            flag = 'd'
        } },
    }

    ret:defineParams {
        -- Roots
        { name = 'rootName', func = 'has_content' },
        { name = 'root', func = { name = pack_root, params = { 'rootName' }, flag = 'd' } },
    }

    ret:defineParams {
        -- bucket params
        { name = 'level_bucket', func = { name = level_bucket_value, params = { 'level' }, flag = 'd' } },
        { name = 'patch_bucket', func = { name = patch_bucket_value, params = { 'patch' }, flag = 'd' } },
        { name = 'protections_json', func = { name = to_json, params = { 'protections' }, flag = 'd' } },
        { name = 'crops_json', func = { name = to_json, params = { 'crops' }, flag = 'd' } },
        { name = 'root_json', func = { name = to_json, params = { 'root' }, flag = 'd' } },
    }

    ret:customButtonPlacement(true)

    ret:create()
    ret:cleanParams()

    ret:addButtonsCaption()
    
    ret:useBucket('infobox_seed', {
        level_bucket = 'level',
        seed = 'seed',
        seedling = 'seedling',
        seedlingW = 'watered_seedling',
        sapling = 'sapling',
        growing = 'growing',
        grown = 'grown',
        patch_bucket = 'patch',
        plantXP = 'plant_experience',
        checkXP = 'check_experience',
        harvestXP = 'harvest_experience',
        harvestAction = 'max_harvest_action',
        harvestLife = 'harvest_life',
        yieldPerHarvest = 'yield_per_harvest',
        seedAmount = 'seed_amount',
        protectionChoice = 'protection_choice',
        protections_json = 'protections_json',
        cycle = 'cycle',
        cycleLength = 'cycle_length',
        regrow_bucket = 'regrow',
        regrow_notes = 'regrow_notes',
        growthPotion = 'applicable_growth_potion',
        rapidGrowth = 'is_able_rapid_growth',
        crops_json = 'crop_json',
        root_json = 'tree_root_json',
    })

    ret:defineName('Infobox Seed')
    ret:defineLinks({ hide = true })
    ret:addClass('infobox-seed left-info')

    local plant = {
        level = param_or_nil(ret, 'level'),
        seed = param_or_nil(ret, 'seed'),
        seedling = param_or_nil(ret, 'seedling'),
        watered_seedling = param_or_nil(ret, 'seedlingW'),
        sapling = param_or_nil(ret, 'sapling'),
        growing = param_or_nil(ret, 'growing'),
        grown = param_or_nil(ret, 'grown'),
        patch = param_or_nil(ret, 'patch'),
        plant_experience = param_or_nil(ret, 'plantXP'),
        check_experience = param_or_nil(ret, 'checkXP'),
        harvest_experience = param_or_nil(ret, 'harvestXP'),
        harvest_action = param_or_nil(ret, 'harvestAction'),
        harvest_life = param_or_nil(ret, 'harvestLife'),
        yield_per_harvest = param_or_nil(ret, 'yieldPerHarvest'),
        seed_amount = param_or_nil(ret, 'seedAmount'),
        protection_choice = param_or_nil(ret, 'protectionChoice'),
        protections = param_or_nil(ret, 'protections'),
        cycle = param_or_nil(ret, 'cycle'),
        cycle_length = param_or_nil(ret, 'cycleLength'),
        regrow = param_or_nil(ret, 'regrow'),
        applicable_growth_potion = param_or_nil(ret, 'growthPotion'),
        is_able_rapid_growth = param_or_nil(ret, 'rapidGrowth'),
        crops = param_or_nil(ret, 'crops'),
        root = param_or_nil(ret, 'root'),
    }

    render(ret, plant)

    if onmain() then
        local a1 = ret:param('all')
        local a2 = ret:categoryData()
        ret:wikitext(addcategories(a1, a2))
    end
    ret:finish()
    return ret:tostring()
end

--
-- param parsing and cleaning funcs
--
function seed_args(seed, name)
    if isDefined(seed) then
        return seed
    elseif isDefined(name) then
        return name
    else
        return error('Failed to find data for given seed name')
    end
end

function growing_args(growing, grown)
    if isDefined(growing) and isDefined(grown) and
        growing == grown then
        return nil
    else
        return growing
    end
end

function to_number(arg, default)
    if not isDefined(arg) then
        return nil
    end

    return tonumber(arg) or default
end

function to_list(...)
    local list = {}
    for _, v in ipairs(arg) do
        if isDefined(v) then
            table.insert(list, v)
        end
    end

    if next(list) == nil then
        return nil
    else
        return list
    end
end

function math_compare(op, first, second, default)
    local first_defined = isDefined(first)
    local second_defined = isDefined(second)
    if first_defined and second_defined then
        return op(first, second)
    elseif first_defined then
        return first
    elseif second_defined then
        return second
    else
        return default
    end
end

function split_comma(str, convert_func)
    local values = {}
    for v in string.gmatch(str, ' ?([^,]+) ?') do
        local num = convert_func(v)
        if num ~= nil then
            table.insert(values, num)
        end
    end

    if next(values) == nil then
        return nil
    else
        return values
    end
end

function level_arg(arg)
    if not isDefined(arg) then
        return 1
    end

    local levels = split_comma(arg, tonumber)
    if levels == nil then
        return 1
    elseif #levels == 1 then
        return levels[1]
    else
        return levels
    end
end

function price_arg(arg)
    if not isDefined(arg) then
        return "gemw"
    else
        return arg
    end
end

function yield_per_harvest_arg(arg)
    if not isDefined(arg) then
        return nil
    elseif arg == "Varies" then
        return -1
    else
        return to_number(arg)
    end
end

function protection_arg(arg)
    if protection_types[arg] then
        return arg
    else
        return nil
    end
end

function to_boolean(arg)
    if not isDefined(arg) then
        return false
    end
    return arg:lower() == "true"
end

function regrow_arg(arg)
    if not isDefined(arg) then
        return nil
    end

    local minutes = tonumber(arg)
    if minutes ~= nil then
        return minutes
    end

    local yesnoResult = yn(arg);
    if yesnoResult then
        return -1;
    elseif (yesnoResult == nil) then
        return arg;
    end

    return nil
end

function regrow_bucket(arg)
    local regrow = regrow_arg(arg);
    if type(regrow) == "number" then
        return regrow;
    elseif type(regrow) == "string" then
        return -1;
    end
    return nil;
end

function regrow_notes(arg)
    local regrow = regrow_arg(arg);
    if type(regrow) == "string" then
        return regrow;
    end
    return nil;
end

function growth_potion_arg(arg)
    if growth_potion_names[arg] then
        return arg
    else
        return nil
    end
end

function protection_choice_arg(arg)
    if protection_choices[arg] then
        return arg
    else
        return nil
    end
end

function patch_bucket_value(patches)
    if type(patches) == "string" then
        return patches
    elseif type(patches) == "table" then
        return table.concat(patches, infobox.splitpoint)
    else
        return nil
    end
end

function patch_arg(arg)
    local patch_list = split_comma(arg, tostring)
    if patch_list == nil then
        return nil
    end

    local patches = {}
    for _, v in ipairs(patch_list) do
        local known_patch = patch_bucket_values[v]
        if known_patch then
            table.insert(patches, known_patch)
        else
            table.insert(patches, v)
        end
    end

    if #patches == 1 then
        return patches[1]
    else
        return patches
    end
end

function is_herb_patch(patch)
    return patch == patch_bucket_values.herb or patch == patch_bucket_values["vine herb"] or
        patch == patch_bucket_values["wilderness herb"]
end

function has_herb_patch(patches)
    if type(patches) == "string" then
        return is_herb_patch(patches)
    elseif type(patches) == "table" then
        return any(patches, is_herb_patch)
    else
        return false
    end
end

function level_bucket_value(level)
    if type(level) == "number" then
        return level
    elseif type(level) == "table" then
        return table.concat(level, infobox.splitpoint)
    else
        return nil
    end
end

function to_nil(param)
    if isDefined(param) then
        return param
    else
        return nil
    end
end

function pack_crop_item(name, skill)
    if not isDefined(name) then
        return nil
    end

    if name == "Experience" then
        return {
            name = name,
            skill = skill,
        }
    else
        return {
            name = name,
        }
    end
end

function pack_protection_item(type, name, amount, price)
    if not isDefined(type) or not isDefined(name) then
        return nil
    end

    if type == "payment" then
        return {
            type = type,
            name = name,
            amount = to_nil(amount),
            price = price,
        }
    else
        return {
            type = type,
            name = name,
        }
    end
end

function pack_root(name)
    if not isDefined(name) then
        return nil
    end

    return {
        name = name,
    }
end

function to_json(table)
    if isDefined(table) then
        return mw.text.jsonEncode(table)
    else
        return nil
    end
end

function param_or_nil(ret, key)
    local val = ret:param(key)
    if isDefined(val) then
        return val
    else
        return nil
    end
end

function expr(t)
    local noerr, val = pcall(mw.ext.ParserFunctions.expr, t)
    if noerr then
        return tonumber(val)
    else
        return nil
    end
end

--
-- category funcs
--
function addcategories(args, catargs)
    local ret = {}

    -- always added
    table.insert(ret, 'Farming')

    local cat_map = {
        -- Added if the parameter has content
        defined = {
        },
        -- Added if the parameter has no content
        notdefined = {
            plantlvl = 'Needs Farming level',
            patch = 'Needs Farming patch type',
            cycles = 'Needs Farming grow time',
            cyclelength = 'Needs Farming grow time',
            seedamount = 'Needs Farming seeds per patch',
            plantxp = 'Needs Farming XP',
            checkxp = 'Needs Farming XP',
            harvestxp = 'Needs Farming XP',
        },
    }

    -- Run and add mapped categories
    for n, v in pairs(cat_map.defined) do
        if catargs[n] and catargs[n].one_defined then
            table.insert(ret, v)
        end
    end
    for n, v in pairs(cat_map.notdefined) do
        if catargs[n] and catargs[n].all_defined == false then
            table.insert(ret, v)
        end
    end

    if catargs.crops and catargs.crops.all_defined == false and
        catargs.root and catargs.root.all_defined == false then
        table.insert(ret, 'Needs Farming crop produced')
    end

    -- combine table and format category wikicode
    for i, v in ipairs(ret) do
        if v ~= '' then
            ret[i] = string.format('[[Category:%s]]', v)
        end
    end

    return table.concat(ret, '')
end

return p
-- </nowiki>