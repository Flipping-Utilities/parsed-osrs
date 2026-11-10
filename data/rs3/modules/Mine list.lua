local p = {}

require("strict")
require("Module:Mw.html extension")

local arr = require('Module:Array')
local yesno = require('Module:Yesno')
local mapLink = require('Module:Map/templates')._maptemp
local leagues

local function getLeagues()
    if leagues == nil then
        leagues = require('Module:LeagueRegion')
    end

    return leagues
end

local function to_link(link, display)
    if link == nil then
        return nil
    end

    return "[[" .. link .. "|" .. display .. "]]"
end

local function to_member_data(parsed_member)
    local mems_icons = {
        [false] = "[[File:F2P icon.png|30px|center|link=Free-to-play|Free-to-play]]",
        [true] = "[[File:P2P icon.png|30px|center|link=Members|Members]]",
    }
    local memyesno = yesno(parsed_member, nil)
    local members = memyesno ~= nil and mems_icons[memyesno] or 'Unknown'
    return members
end

local function build_category_string(cat_table)
    local filtered = arr.filter(cat_table, function(comp) return comp ~= '' end)
    local mapped = arr.map(filtered, function(category) return string.format('[[Category:%s]]', category) end)
    return table.concat(mapped, '')
end

local function query(ore)
    local rocks = bucket('infobox_ore')
        .select(
            'page_name'
        )
        .where('ore', ore)
        .run()

    rocks = arr.unique(arr.map(rocks, function(r) return r.page_name end))

    local rock_queries = {}
    for _, rock in ipairs(rocks) do
        table.insert(rock_queries, { 'page_name', rock })
    end

    local b = bucket('infobox_mine_location')
        .join('resource_locations', 'resource_locations.page_name_sub', 'infobox_mine_location.site')
        .join('infobox_location', 'infobox_location.page_name', 'resource_locations.page_name')
        .select(
            'instances',
            'map_args',
            'resource_locations.page_name_sub',
            'resource_locations.location',
            'resource_locations.requirements',
            'resource_locations.league_region',
            'infobox_location.is_members_only',
            'infobox_location.location'
        )
        .where(bucket.Or(rock_queries))
        .where('resource_locations.resource_location_type', 'mine')

    return b.run()
end

-- Parse from table is used on the page where the bucket gets written
-- Note the swap between None and nil for digsite. This is for table formatting; we want None in the bucket properties
local function parse_from_table(site)
    return {
        link = site['resource_locations.page_name_sub'],
        display = site['resource_locations.location'],
        membs = site['infobox_location.is_members_only'],
        requirements = site["resource_locations.requirements"],
        league_region = site["resource_locations.league_region"],
        location = site["infobox_location.location"],
        instances = site.instances,
        map = mw.text.jsonDecode(site.map_args),
    }
end

local function rock_template_to_table_display(ore)
    local site_locs = query(ore)
mw.logObject(site_locs)
    -- Normal parsing pathway - it is as if we pulled from bucket
    local parsed_locs = arr.map(site_locs, parse_from_table)

    local tbl = mw.html.create("table")
        :addClass("wikitable sortable lighttable sticky-header align-center-3 align-center-5")

    tbl:tr()
        :th("Mine")
        :th("Location")
        :th("Members")
        :th("Requirements")
        :th("Instances")
        :th("Map")
        :th { "League region", class = "leagues-global-flag" }

    for _, site in ipairs(parsed_locs) do
        local ret = tbl:tr()

        ret:td(to_link(site.link, site.display))

        if site.location ~= nil then
            ret:td(site.location)
        else
            ret:na()
        end

        ret:td(to_member_data(site.membs))

        local req = site.requirements
        if req then
            ret:td('\n' .. req .. '\n')
        else
            ret:na()
        end

        ret:td(site.instances)
            :td(mapLink(site.map, { type = 'maplink' }))

        local siteleagueRegion = site.league_region
        local leagueRegion = getLeagues().regionsWithSizeThreshold(siteleagueRegion)
        if leagueRegion and leagueRegion ~= "" and leagueRegion ~= 'None' then
            ret:td { leagueRegion, class = "leagues-global-flag" }
        else
            ret:td { "N/A",
                attr = { "data-sort-value", "" },
                class = "table-na leagues-global-flag" }
        end
    end

    -- Need to do categories too, because this is at the end of the assign
    -- local titles = arr.map(parsed_locs, function(cache) return 'Excavation sites with ' .. to_pagename(cache.material) .. ' caches' end)
    -- local category_string = build_category_string(titles)
    local category_string = ''

    -- Returns the table and categories
    return tostring(tbl) .. category_string
end

local rockparams = {
    ["tin rock"] = { txt = "[[tin rock]] [[File:Tin ore.png]]", cat = "tin rocks" },
    ["copper rock"] = { txt = "[[copper rock]] [[File:Copper ore.png]]", cat = "copper rocks" },
    ["iron rock"] = { txt = "[[iron rock]] [[File:Iron ore.png]]", cat = "iron rocks" },
    ["silver rock"] = { txt = "[[silver rock]] [[File:Silver ore.png]]", cat = "silver rocks" },
    ["coal rock"] = { txt = "[[coal rock]] [[File:Coal.png]]", cat = "coal rocks" },
    ["concentrated coal deposit"] = { txt = "[[concentrated coal deposit]] [[File:Coal.png]]", cat = "concentrated coal deposits" },
    ["gold rock"] = { txt = "[[gold rock]] [[File:Gold ore.png]]", cat = "gold rocks" },
    ["concentrated gold deposit"] = { txt = "[[concentrated gold deposit]] [[File:Gold ore.png]]", cat = "concentrated gold deposits" },
    ["mithril rock"] = { txt = "[[mithril rock]] [[File:Mithril ore.png]]", cat = "mithril rocks" },
    ["adamantite rock"] = { txt = "[[adamantite rock]] [[File:Adamantite ore.png]]", cat = "adamantite rocks" },
    ["runite rock"] = { txt = "[[runite rock]] [[File:Runite ore.png]]", cat = "runite rocks" },
    ["blurite rock"] = { txt = "[[blurite rock]] [[File:Blurite ore.png]]", cat = "blurite rocks" },
    ["rocks (tears of guthix)"] = { txt = "[[Rocks (Tears of Guthix)|magic stone rocks]] [[File:Magic stone (Tears of Guthix).png]]", cat = "magic stone rocks" },
    ["daeyalt vein"] = { txt = "[[daeyalt vein]] [[File:Daeyalt ore.png]]", cat = "daeyalt veins" },
    ["rubium vein"] = { txt = "[[rubium vein]] [[File:Rubium.png]]", cat = "rubium veins" },
    ["sandstone rock"] = { txt = "[[sandstone rock]] [[File:Sandstone (10kg).png]]", cat = "sandstone rocks" },
    ["mineral deposit"] = { txt = "[[mineral deposit]] [[File:Sandstone (10kg).png]]", cat = "mineral deposits" },
    ["banite rock"] = { txt = "[[banite rock]] [[File:Banite ore.png]]", cat = "banite rocks" },
    ["clay rock"] = { txt = "[[clay rock]] [[File:Clay.png]]", cat = "clay rocks" },
    ["soft clay rock"] = { txt = "[[soft clay rock]] [[File:Soft clay.png]]", cat = "soft clay rocks" },
    ["gem rock (tai bwo wannai)"] = { txt = "[[Gem rock (Tai Bwo Wannai)]] [[File:Uncut lapis lazuli.png]]", cat = "gem rocks" },
    ["common gem rock"] = { txt = "[[common gem rock]] [[File:Uncut jade.png]]", cat = "common gem rocks" },
    ["uncommon gem rock"] = { txt = "[[uncommon gem rock]] [[File:Uncut sapphire.png]]", cat = "uncommon gem rocks" },
    ["precious gem rock"] = { txt = "[[precious gem rock]] [[File:Uncut ruby.png]]", cat = "precious gem rocks" },
    ["rare gem rock"] = { txt = "[[rare gem rock]] [[File:Uncut diamond.png]]", cat = "rare gem rocks" },
    ["prifddinas gem rock"] = { txt = "[[Prifddinas gem rock]] [[File:Uncut dragonstone.png]]", cat = "Prifddinas gem rocks" },
    ["kal'gerion gem rock"] = { txt = "[[Kal'gerion gem rock]] [[File:Uncut dragonstone.png]]", cat = "Kal'gerion gem rocks" },
    ["granite rock"] = { txt = "[[granite rock]] [[File:Granite (5kg).png]]", cat = "granite rocks" },
    ["limestone rock"] = { txt = "[[limestone rock]] [[File:Limestone.png]]", cat = "limestone rocks" },
    ["rune essence (rock)"] = { txt = "[[rune essence rock]] [[File:Rune essence.png]]", cat = "essence rocks" },
    ["drakolith rock"] = { txt = "[[drakolith rock]] [[File:Drakolith.png]]", cat = "drakolith rocks" },
    ["orichalcite rock"] = { txt = "[[orichalcite rock]] [[File:Orichalcite ore.png]]", cat = "orichalcite rocks" },
    ["luminite rock"] = { txt = "[[luminite rock]] [[File:Luminite.png]]", cat = "luminite rocks" },
    ["necrite rock"] = { txt = "[[necrite rock]] [[File:Necrite ore.png]]", cat = "necrite rocks" },
    ["phasmatite rock"] = { txt = "[[phasmatite rock]] [[File:Phasmatite.png]]", cat = "phasmatite rocks" },
    ["light animica rock"] = { txt = "[[light animica rock]] [[File:Light animica.png]]", cat = "light animica rocks" },
    ["dark animica rock"] = { txt = "[[dark animica rock]] [[File:Dark animica.png]]", cat = "dark animica rocks" },
    ["salty crabletine"] = { txt = "[[salty crabletine]] [[File:Sea salt.png]]", cat = "salty crabletines" },
    ["salty crablet"] = { txt = "[[salty crablet]] [[File:Sea salt.png]]", cat = "salty crablets" },
    ["alaea crablet"] = { txt = "[[alaea crablet]] [[File:Alaea sea salt.png]]", cat = "alaea crablets" },
    ["stone slab vein"] = { txt = "[[Stone slab vein]] [[File:Stone slab.png]]", cat = "stone slab veins" },
    ["'perfect' gold rock"] = { txt = "[['Perfect' gold rock]] [[File:'Perfect' gold ore.png]]", cat = "'perfect' gold rocks" },
    ["red sandstone (rock)"] = { txt = "[[red sandstone (rock)]] [[File:Red sandstone.png]]", cat = "red sandstones" },
    ["punishment rock"] = { txt = "[[punishment rock]] [[File:Punishment rock (ore).png]]", cat = "punishment rocks" },
    ["crystal-flecked sandstone (rock)"] = { txt = "[[crystal-flecked sandstone (rock)]] [[File:Crystal-flecked sandstone.png]]", cat = "crystal-flecked sandstones" },
    ["feldip swamp rock"] = { txt = "[[Feldip swamp rock]] [[File:Rock (ore).png]]", cat = "feldip swamp rocks" },
    ["solid crystal"] = { txt = "[[solid crystal]] [[File:Crystal fragment.png]]", cat = "solid crystals" },
    ["moulding guard"] = { txt = "[[moulding guard]] [[File:Enriched calcified fungus.png]]", cat = "moulding guards" },
    ["crust"] = { txt = "[[crust]]", cat = "crust" },
    ["copper rock (beneath cursed tides)"] = { txt = "[[copper rock (Beneath Cursed Tides)]] [[File:Soggy copper ore.png]]", cat = "soggy copper rocks" },
    ["tin rock (beneath cursed tides)"] = { txt = "[[tin rock (Beneath Cursed Tides)]] [[File:Soggy tin ore.png]]", cat = "soggy tin rocks" },
    ["novite rock"] = { txt = "[[novite rock]] [[File:Novite ore.png]]", cat = "novite rocks" },
    ["kratonium rock"] = { txt = "[[kratonium rock]] [[File:Kratonium ore.png]]", cat = "kratonium rocks" },
    ["fractite rock"] = { txt = "[[fractite rock]] [[File:Fractite ore.png]]", cat = "fractite rocks" },
    ["bathus rock"] = { txt = "[[bathus rock]] [[File:Bathus ore.png]]", cat = "bathus rocks" },
    ["promethium rock"] = { txt = "[[promethium rock]] [[File:Promethium ore.png]]", cat = "promethium rocks" },
    ["gorgonite rock"] = { txt = "[[gorgonite rock]] [[File:Gorgonite ore.png]]", cat = "gorgonite rocks" },
    ["marmaros rock"] = { txt = "[[marmaros rock]] [[File:Marmaros ore.png]]", cat = "marmaros rocks" },
    ["zephyrium rock"] = { txt = "[[zephyrium rock]] [[File:Zephyrium ore.png]]", cat = "zephyrium rocks" },
    ["katagon rock"] = { txt = "[[katagon rock]] [[File:Katagon ore.png]]", cat = "katagon rocks" },
    ["argonite rock"] = { txt = "[[argonite rock]] [[File:Argonite ore.png]]", cat = "argonite rocks" },
    ["seren stone"] = { txt = "[[seren stone]] [[File:Corrupted ore.png]]", cat = "seren stones" },
    ["porcelain clay rock"] = { txt = "[[porcelain clay rock]] [[File:Porcelain clay.png]]", cat = "porcelain clay rocks" },
    ["platinum rock"] = { txt = "[[platinum rock]] [[File:Platinum ore.png]]", cat = "platinum rocks" },
    ["meteorite"] = { txt = "[[meteorite]] [[File:Meteorite chunk.png]]", cat = "meteorites" },
    ["havensilver rock"] = { txt = "[[havensilver rock]] [[File:Havensilver ore.png]]", cat = "havensilver rocks" },
}

local function query_all()
    local b = bucket('infobox_mine_location')
        .join('infobox_location', 'infobox_location.page_name', 'infobox_mine_location.site')
        .join('resource_locations', 'resource_locations.page_name', 'infobox_location.page_name')
        .select(
            'page_name',
            'instances',
            'resource_locations.page_name_sub',
            'resource_locations.location',
            'resource_locations.requirements',
            'resource_locations.league_region',
            'infobox_location.is_members_only',
            'infobox_location.location'
        )
        .where('resource_locations.resource_location_type', 'mine')

    return b.run()
end

local function group_mines_from_table(site_locs)
    local tbl = {}

    for _, r in ipairs(site_locs) do
        local key = r['resource_locations.page_name_sub']
        if tbl[key] == nil then
            tbl[key] = { r }
        else
            table.insert(tbl[key], r)
        end
    end

    return tbl
end

local function parse_all_from_table(mine_rocks)
    local first = mine_rocks[1]
    return {
        link = first['resource_locations.page_name_sub'],
        display = first['resource_locations.location'],
        membs = first['infobox_location.is_members_only'],
        requirements = first["resource_locations.requirements"],
        league_region = first["resource_locations.league_region"],
        location = first["infobox_location.location"],
        rocks = arr.map(mine_rocks, function(rock)
            return { name = rock['page_name'], instances = rock['instances'] }
        end),
    }
end

-- Format a rock like Infobox Mine does: "3 × [[iron rock]] [[File:Iron ore.png]]"
local function format_rock(resource)
    local name = resource.name
    local instances = resource.instances or 0
    local rock = rockparams[name:lower()]
    if rock then
        return string.format('%s &times; %s', instances, rock.txt)
    else
        return string.format('%s &times; [[%s]]', instances, name)
    end
end

-- Format all resources for a mine into a bulleted list
local function format_mine_contents(resources)
    if #resources == 0 then
        return ''
    end

    if #resources == 1 then
        return format_rock(resources[1])
    end

    local parts = {}
    for _, res in ipairs(resources) do
        table.insert(parts, '* ' .. format_rock(res))
    end
    return '\n' .. table.concat(parts, '\n') .. '\n'
end

local function show_all_rocks_display()
    local site_locs = query_all()

    local grouped_mines = group_mines_from_table(site_locs)

    local parsed_locs = {}
    for _, mine in pairs(grouped_mines) do
        table.insert(parsed_locs, parse_all_from_table(mine))
    end

    local tbl = mw.html.create("table")
        :addClass("wikitable sortable lighttable sticky-header align-center-4")

    tbl:tr()
        :th("Mine")
        :th("Rocks")
        :th("Location")
        :th("Members")
        :th("Requirements")
        :th { "League region", class = "leagues-global-flag" }

    for _, site in ipairs(parsed_locs) do
        local ret = tbl:tr()

        ret
            :td(to_link(site.link, site.display))
            :td(format_mine_contents(site.rocks))

        if site.location ~= nil then
            ret:td(site.location)
        else
            ret:na()
        end

        ret:td(to_member_data(site.membs))

        local req = site.requirements
        if req then
            ret:td('\n' .. req .. '\n')
        else
            ret:na()
        end

        local siteleagueRegion = site.league_region
        local leagueRegion = getLeagues().regionsWithSizeThreshold(siteleagueRegion)
        if leagueRegion and leagueRegion ~= "" and leagueRegion ~= 'None' then
            ret:td { leagueRegion, class = "leagues-global-flag" }
        else
            ret:td { "N/A",
                attr = { "data-sort-value", "" },
                class = "table-na leagues-global-flag" }
        end
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

    local is_show_all = yesno(args.all)
    if is_show_all then
        return show_all_rocks_display()
    else
        local ore = args[1] or mw.title.getCurrentTitle().text or ''
        return rock_template_to_table_display(ore)
    end
end

return p