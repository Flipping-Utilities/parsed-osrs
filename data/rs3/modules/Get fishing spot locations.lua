local yesno = require('Module:Yesno')
local mapLink = require('Module:Map/templates')._maptemp

require("Module:Mw.html extension")

local p = {}

local MEM_ICON = {
    [false] = '[[File:F2P icon.png|30px|link=Free-to-play|alt=Free-to-play]]',
    [true] = '[[File:P2P icon.png|30px|link=Members|alt=Members]]',
}

local leagues

local function leaguesArg(region)
    if leagues == nil then
        leagues = require('Module:LeagueRegion')
    end

    if region ~= nil and region ~= '' then
        return leagues.regionsForInfobox(region)
    end

    return nil
end

function p.common(frame, bucket_data)
    local t = mw.html.create('table')
        :addClass('wikitable align-center-3 align-center-5 sortable autosort=1,a')
        :tr()
        :th('Spot')
        :th('Location')
        :th('Members')
        :th('Access requirements')
        :th('Instances')
        :th('Map')
        :th { 'League region', attr = { "class", "leagues-global-flag" } }

    local all_spots = bucket_data

    -- For each fishing spot
    for _, spot_data in ipairs(all_spots) do
        local spot_json = mw.text.jsonDecode(spot_data['fishingspotlocline.json'])
        local league_region = leaguesArg(spot_json['leagueRegion'])
        local mem = MEM_ICON[yesno(spot_json.mem or 'no')]
        local count = 0
        local mapArgs = {
            mapID = spot_json.mapID,
            plane = spot_json.plane or 0,
            mtype = 'pin',
            icon = 'redPin',
            text = 'Map',
        }

        for _, coords in ipairs(spot_json) do
            coords = coords:gsub('\n', '')
            table.insert(mapArgs, coords)
            count = count + 1
        end

        local map = mapLink(mapArgs, { type = 'maplink' })

        local spot_name = spot_data['fishingspotlocline.page_name']
        local spotText = '[[' .. spot_name

        if spot_json.shortname then
            spotText = spotText .. '|' .. spot_json.shortname
        end

        spotText = spotText .. ']]'

        local requirements = spot_json['requirements']

        if requirements:sub(1, 1) == "*" then
            requirements = "\n" .. requirements
        end

        t:tr()
            :td(spotText)
            :td(spot_json['loc'])
            :td(mem)
            :td(requirements)
            :td(count)
            :td(map)
            :td { league_region,
                attr = { "class", "leagues-global-flag" },
            }
    end

    return t:allDone()
end

local function get_name_queries(key, args)
    if args[1] == nil then
        return { { key, mw.title.getCurrentTitle().text } }
    end

    local parsed_names = {}
    for _, name in ipairs(args) do
        name = mw.text.trim(name)
        table.insert(parsed_names, { key, name })
    end

    return parsed_names
end

function p.item(frame)
    local args = frame:getParent().args
    local item_queries = get_name_queries('dropsline.item_name', args)

    local all_spots = bucket('fishingspotlocline')
        .join('dropsline', 'dropsline.page_name_sub', 'fishingspotlocline.page_name_sub')
        .select('fishingspotlocline.page_name', 'fishingspotlocline.json')
        .where(bucket.Or(item_queries))
        .limit(5000)
        .run()

    return p.common(frame, all_spots)
end

function p.spot(frame)
    local args = frame:getParent().args
    local tool_queries = get_name_queries('recipe.uses_tool', args)
mw.logObject(tool_queries)
    local all_spots = bucket('recipe')
        .join('fishingspotlocline', 'fishingspotlocline.page_name_sub', 'recipe.page_name_sub')
        --.join('dropsline', 'dropsline.page_name_sub', 'recipe.page_name_sub')
        .select('fishingspotlocline.page_name', 'fishingspotlocline.json')
        .where(bucket.Or(tool_queries))
        .where(bucket.Not('fishingspotlocline.json', bucket.Null()))
        .limit(50000)
        .run()

    return p.common(frame, all_spots)
end

return p