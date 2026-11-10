local p = {}

require("strict")
require("Module:Mw.html extension")

local arr = require('Module:Array')
local mapLink = require('Module:Map/templates')._maptemp
local plink = require("Module:Plink")._plink

local function level_sort(a, b)
    return (tonumber(a.level) or 0) < (tonumber(b.level) or 0)
end

local function to_link(link, display)
    if link == nil then
        return nil
    end

    return "[[" .. link .. "|" .. display .. "]]"
end

local function build_category_string(cat_table)
    local filtered = arr.filter(cat_table, function(comp) return comp ~= '' end)
    local mapped = arr.map(filtered, function(category) return string.format('[[Category:%s]]', category) end)
    return table.concat(mapped, '')
end

local function query(mine)
    local locs = bucket('infobox_mine_location')
        .select(
            'page_name',
            'instances',
            'map_args',
            'version'
        )
        .where('site', mine)
        .run()

    local rock_page_names = {}
    local rock_page_name_subs = {}
    for _, loc in ipairs(locs) do
        if loc.version ~= nil then
            for _, ver in ipairs(loc.version) do
                table.insert(rock_page_name_subs, loc.page_name .. '#' .. ver)
            end
        else
            table.insert(rock_page_names, loc.page_name)
        end
    end

    rock_page_names = arr.unique(rock_page_names)
    rock_page_name_subs = arr.unique(rock_page_name_subs)

    local rock_queries = {}
    for _, page_name in ipairs(rock_page_names) do
        table.insert(rock_queries, { 'page_name', page_name })
    end
    for _, page_name_sub in ipairs(rock_page_name_subs) do
        table.insert(rock_queries, { 'page_name_sub', page_name_sub })
    end

    local rocks = bucket('infobox_ore')
        .select(
            'page_name',
            'page_name_sub',
            'name',
            'level',
            'ore'
        )
        .where(bucket.Or(rock_queries))
        .run()

    return locs, rocks
end

local function group_rocks_from_table(rocks)
    local tbl = {}

    -- gem rocks have multiple variants
    table.sort(rocks, level_sort)

    for _, r in ipairs(rocks) do
        local target = tbl[r.page_name]
        if target == nil then
            tbl[r.page_name] = r
            r.level = { r.level }
        else
            table.insert(target.level, r.level)
            arr.insert(target.ore, r.ore, nil, true)
        end
    end

    for _, r in pairs(tbl) do
        r.ore = arr.unique(r.ore)
    end

    return tbl
end

local function parse_locs_from_table(locs, grouped_rocks)
    local tbl = {}
    for _, loc in ipairs(locs) do
        local rock = grouped_rocks[loc.page_name]
        table.insert(tbl, {
            link = rock.page_name_sub,
            display = rock.name,
            level = rock.level,
            ore = rock.ore,
            instances = loc.instances,
            map = mw.text.jsonDecode(loc.map_args),
        })
    end

    return tbl
end

-- Format all resources for ore into a bulleted list
local function format_ore(ores)
    if #ores == 0 then
        return ''
    end

    if #ores == 1 then
        return plink(ores[1], ores[1])
    end

    local parts = {}
    for _, ore in ipairs(ores) do
        table.insert(parts, '* ' .. plink(ore, ore))
    end
    return '<div class="plainlist">\n' .. table.concat(parts, '\n') .. '\n</div>'
end

-- Takes template args and converts the wikitext data into a display table on the same page
-- TODO: compose these different fronts with different ends. Input, display, output (categories only right now)
local function rock_template_to_table_display(ore)
    local locs, rocks = query(ore)

    local grouped_rocks = group_rocks_from_table(rocks)

    -- Normal parsing pathway - it is as if we pulled from bucket
    local parsed_locs = parse_locs_from_table(locs, grouped_rocks)
    table.sort(parsed_locs, level_sort)

    local tbl = mw.html.create("table")
        :addClass("wikitable sortable lighttable sticky-header align-center-3 align-center-5")

    tbl:tr()
        :th("Level")
        :th("Rock")
        :th("Instances")
        :th("Ore")
        :th("Map")

    for _, rock in ipairs(parsed_locs) do
        local ret = tbl:tr()

        ret
            :td { table.concat(rock.level, ", ") .. " [[File:Mining-icon.png|21x21px|link=Mining]]", attr = { ["data-sort-value"] = rock.level[1] } }
            :td(to_link(rock.link, rock.display))
            :td(rock.instances)
            :td(format_ore(rock.ore))
            :td(mapLink(rock.map, { type = 'maplink' }))
    end

    -- Need to do categories too, because this is at the end of the assign
    -- local titles = arr.map(parsed_locs, function(cache) return 'Excavation sites with ' .. to_pagename(cache.material) .. ' caches' end)
    -- local category_string = build_category_string(titles)
    local category_string = ''

    -- Returns the table and categories
    return tostring(tbl) .. category_string
end

-- [[Template:Mine list]]
function p.list(frame)
    local args = frame:getParent().args

    local ore = args[1] or mw.title.getCurrentTitle().text or ''

    return rock_template_to_table_display(ore)
end

return p