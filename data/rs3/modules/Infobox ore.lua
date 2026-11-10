local p = {}

local commas = require("Module:Addcommas")._add
local default_to, hc = (function()
    local m = require("Module:Paramtest")
    return m.default_to, m.has_content
end)()
local plink, plinkp = (function()
    local m = require("Module:Plink")
    return m._plink, m._plinkp
end)()
local yesno = require('Module:Yesno')
local htmlext = require("Module:Mw.html extension")
local onmain = require('Module:Mainonly').on_main

local var = mw.ext.VariablesLua
local M_ICON = "[[File:Mining-icon.png|21x21px|link=]] "

-- Create helper functions for commonly used td/th table cells with a colspan of 2
htmlext.addFunction(function(self, x) return self:td { x, attr = { "colspan", 2 } } end, "td2")
htmlext.addFunction(function(self, x) return self:th { x, attr = { "colspan", 2 } } end, "th2")

local function to_number(value, default)
    if value == "none" or value == "None" or value == nil then
        return default
    end

    return tonumber(value) or default
end

-- Table function used to work around mw.loadData() metatable restrictions
local function getOutputs(outputs)
    if not outputs then
        return nil
    elseif type(outputs) == "string" then
        return "[[" .. outputs .. "]]"
    end

    local ret = {}
    for i = 1, 100 do
        if outputs[i] then
            table.insert(ret, plink(outputs[i]))
        else
            break
        end
    end

    return table.concat(ret, "<br>")
end

local function queryRockData(page_name)
    local query = bucket("infobox_ore")
        .select("page_name_sub", "name", "level", "core", "ore", "json")
        .where("page_name_sub", page_name)

    local bucketdata = query.run()

    if #bucketdata == 0 then
        error("Failed to find data for given rock name")
    end

    local rock = bucketdata[1]
    local rock_json = mw.text.jsonDecode(rock.json)

    return {
        page_name = rock.page_name_sub,
        name = rock.name,
        level = rock.level,
        core = rock.core,
        ore = rock.ore,
        hitpoint = rock_json.hitpoint,
        hardness = rock_json.hardness,
        multiplier = rock_json.multiplier,
        ore_qty = rock_json.ore_qty,
        geode = rock_json.geode,
        spirit = rock_json.spirit,
        output = rock_json.output,
        critical = rock_json.critical,
        rockertunity = rock_json.rockertunity,
        geode_chance_level = rock_json.geode_chance_level,
        double_ore_chance = rock_json.double_ore_chance,
        varrock = rock_json.varrock,
    }
end

local function outputArg(arg)
    local ret = {}

    for u in mw.text.gsplit(arg or '', '%s*,%s*') do
        if hc(u) then
            table.insert(ret, u)
        end
    end

    return ret
end

local function putRockData(args)
    local name = args.name or mw.title.getCurrentTitle().text
    local level = to_number(args.level)
    local hitpoint = to_number(args.hp)
    local hardness = to_number(args.hardness)
    local multiplier = to_number(args.multiplier)
    local core = yesno(args.core)
    local ore_qty = to_number(args.qty, 1)
    local geode = default_to(args.geode)
    local spirit = default_to(args.spirit)
    local ore = outputArg(args.ore or args.output)

    local critical = { to_number(args.critical1), to_number(args.critical2) }
    local rockertunity = { to_number(args.rockertunity1), to_number(args.rockertunity2) }
    local geode_chance_level = { to_number(args.geode_chance1), to_number(args.geode_chance2) }
    local double_ore_chance = { to_number(args.double1), to_number(args.double2) }

    local varrock = to_number(args.varrock)

    local versionName = default_to(args.version)

    local useBucket = true
    if args.bucket ~= nil then
        useBucket = yesno(args.bucket)
    end

    if useBucket and onmain() then
        bucket('infobox_ore').sub(versionName).put({
            name = name,
            level = level,
            core = core,
            ore = ore,
            json = {
                hitpoint = hitpoint,
                hardness = hardness,
                multiplier = multiplier,
                ore_qty = ore_qty,
                geode = geode,
                spirit = spirit,
                critical = critical,
                rockertunity = rockertunity,
                geode_chance_level = geode_chance_level,
                double_ore_chance = double_ore_chance,
                varrock = varrock,
            }
        })
    end

    local var_name = string.format("DropLevel_mining_%s", versionName or 'DEFAULT')
    mw.log('defining var', var_name, level)
    var.vardefine(var_name, level)

    return {
        name = name,
        level = level,
        core = core,
        ore = ore,
        ore_qty = ore_qty,
        hitpoint = hitpoint,
        hardness = hardness,
        multiplier = multiplier,
        geode = geode,
        spirit = spirit,
        critical = critical,
        rockertunity = rockertunity,
        geode_chance_level = geode_chance_level,
        double_ore_chance = double_ore_chance,
        varrock = varrock,
    }
end

function p.main(frame)
    local args = frame:getParent().args

    local name = args.name or args[1]
    local oretype = string.lower(args.type or args[2] or "ore")
    if oretype ~= "ore" and oretype ~= "rock" then
        return error('You must choose either "ore" or "rock" as the type.')
    end

    local data
    if oretype == "rock" then
        data = putRockData(args)
    else
        data = queryRockData(name)
    end

    local mt = mw.html.create():tag("div")
        :addClass("text-align-center")
        :css('display', 'flex')
        :css('flex-direction', 'row')

    mw.ext.VariablesLua.vardefine("DropLevel_mining_DEFAULT", data.level)

    local header = data.name

    -- Begin infobox output
    local t = mw.html.create():tag("table"):addClass("wikitable")

    t:tr():th { header, attr = { "colspan", 7 } }

    t
        :tr()
        :th("[[Mining]] level")
        :td(M_ICON .. data.level)

    if oretype == "ore" then
        local row = t:tr():th("Source")
        row:td(string.format("[[%s|%s]]", data.page_name, data.name))
    elseif oretype == "rock" then
        if #data.ore > 0 then
            local row = t:tr():th("Output")
            row:td(getOutputs(data.ore))
        end
    end

    t:tr()
        :th("[[Mining#Core rocks|Core]]")
        :td(data.core and "[[File:Yes check.svg|20px|link=]]" or "[[File:X mark.svg|20px|link=]]")

    if data.spirit then
        t:tr()
            :th("[[Stone spirits|Stone spirit]]")
            :td(plink(data.spirit .. " stone spirit", { txt = data.spirit }))
    end

    if data.geode then
        t:tr()
            :th("[[Geode#Mining|Geode]]")
            :td(plink(data.geode .. " geode", { txt = data.geode }))
    end

    t:tr()
        :th2("Rock stats")

    t:tr()
        :th("[[Mining#Durability|Durability]]")
        :td(data.hitpoint and commas(data.hitpoint) or "")

    t:tr()
        :th("[[Mining#Hardness|Hardness]]")
        :td(data.hardness)

    t:tr()
        :th("[[Mining#Experience|XP multiplier]]")
        :td(data.multiplier)

    t:tr()
        :th("Base ore qty")
        :td(data.ore_qty)

    local mtrow = mt:node(t)

    if data.core or yesno(args.showcore) then
        mtrow:tag('br')

        t = mw.html.create():tag("table"):addClass("wikitable")
        t
            :th2("Bonus [[Mining#Critical swing|critical swing]] chance")

        t:tr()
            :th("+5%")
            :td(M_ICON .. (data.critical[1] or '?'))

        local row = t:tr()
            :th("+10%")

        if data.critical[2] then
            row:td(M_ICON .. data.critical[2])
        else
            row:na()
        end

        t:tr()
            :th2("[[Mining#Rockertunity multiplier|Rockertunity multiplier]]")

        t:tr()
            :th("×5")
            :td(M_ICON .. (data.rockertunity[1] or '?'))

        row = t:tr()
            :th("×6")

        if data.rockertunity[2] then
            row:td(M_ICON .. data.rockertunity[2])
        else
            row:na()
        end

        t:tr()
            :th2("[[Mining#Double ore chance|Double ore chance]]")

        t:tr()
            :th("5%")
            :td(M_ICON .. (data.double_ore_chance[1] or '?'))

        row = t:tr()
            :th("10%")

        if data.double_ore_chance[2] then
            row:td(M_ICON .. data.double_ore_chance[2])
        else
            row:na()
        end

        local minVarrockArmourLevel = data.varrock or 0
        if minVarrockArmourLevel > 0 then
            t:tr()
                :th("[[Varrock armour]]")
                :td(plink("Varrock armour " .. minVarrockArmourLevel, { txt = tostring(minVarrockArmourLevel) }))
                :wikitext(' (' .. (5 - minVarrockArmourLevel) .. "%)")
        end

        t:tr()
            :th2("[[Mining#Geodes|Geode]] chance")

        row = t:tr()
            :th("10%")

        if data.geode_chance_level[1] then
            row:td(M_ICON .. data.geode_chance_level[1])
        else
            row:na()
        end

        row = t:tr()
            :th("15%")

        if data.geode_chance_level[2] then
            row:td(M_ICON .. data.geode_chance_level[2])
        else
            row:na()
        end

        mtrow:node(t)
    end

    mt = mt:allDone()
    -- Set Rocks category, if applicable
    if oretype == "rock" then
        mt:wikitext("[[Category:Rocks]]")
    end

    return mt
end

return p