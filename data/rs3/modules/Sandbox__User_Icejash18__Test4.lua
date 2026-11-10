local p = {}

local tm2 = require('Module:Tilemarkers')
local map = require('Module:Map')
local yesno = require('Module:Yesno')
local fln = require('Module:FloorNumber')._main

local defaultHexColor = '#FF3388FF'

local function splitOnPlane(json)
    local planeTiles = {}

    for _, tile in ipairs(json) do
        local plane = tile.level ~= nil and tostring(tile.level) or '0'
        if planeTiles[plane] == nil then
            planeTiles[plane] = {}
        end

        table.insert(planeTiles[plane], tile)
    end

    return planeTiles
end

local function parseToken(output, args)
    -- common args
    if args.token == nil or args.token == '' then
        error('[Module:Tile markers] Argument{1} for json page must not be nil.')
    end
    output.token = args.token

    local content, decodeError
    content, decodeError = tm2.decodeCodec(args.token)
    assert(content, decodeError and ('[Module:Tile markers] ' .. decodeError) or '[Module:Tile markers] Unknown internal error.')

    output.content = content
end

local function parseArgs(output, args)
    if args.preview ~= nil then
        output.preview = yesno(args.preview, true)
    elseif args.showpreview ~= nil then
        output.preview = yesno(args.showpreview, true)
    else
        output.preview = true
    end

    -- ensure caption, if specified, is not blank
    if args.caption ~= nil then
        if args.caption == '' then
            error('[Module:Tile markers] caption argument cannot be blank.')
        else
            output.caption = args.caption
        end
    end

    -- ensure width, if specified, is not invalid number
    if args.width ~= nil then
        local w = tonumber(args.width)
        if w == nil then
            error('[Module:Tile markers] width argument must be a valid number.')
        else
            output.width = args.width
        end
    else
        output.width = 300
    end

    -- ensure height, if specified, is not invalid number
    if args.height ~= nil then
        local w = tonumber(args.height)
        if w == nil then
            error('[Module:Tile markers] height argument must be a valid number.')
        else
            output.height = args.height
        end
    end

    -- if no map preview is needed, skip the rest
    if not output.preview then
        return
    end

    -- override args
    -- ensure both or neither x and y are specified
    if args.x ~= nil or args.y ~= nil then
        if args.x == nil or args.x == '' or args.y == nil or args.y == '' then
            error('[Module:Tile markers] Both x and y must be specified if you are overriding the map window location.')
        else
            output.x = args.x
            output.y = args.y
        end
    end

    -- ensure zoom, if specified, is not blank
    if args.zoom ~= nil then
        if args.zoom == '' then
            error('[Module:Tile markers] zoom argument cannot be blank.')
        else
            output.zoom = args.zoom
        end
    end

    if args.align ~= nil then
        if args.align ~= 'left' and args.align ~= 'center' and args.align ~= 'right' and args.align ~= 'none' then
            error('[Module:Tile markers] An invalid align value was specified.')
        else
            output.align = args.align
        end
    end

    if args.preview_plane ~= nil then
        if args.preview_plane == '' then
            error('[Module:Tile markers] preview_plane argument cannot be blank.')
        else
            output.preview_plane = args.preview_plane
        end
    end

    if args.preview_all ~= nil then
        output.preview_all = yesno(args.preview_all, true)
    end
end

local function extractColourFromTilemarker(rawColour)
    local rawColorHex = rawColour and string.format("%08X", rawColour) or defaultHexColor

    local colour, opacity
    if string.len(rawColorHex) > 7 then
        colour = '#' .. string.sub(rawColorHex, 0, 6)
        opacity = string.sub(rawColorHex, 7, 8)
    else
        opacity = 'FF'
        colour = rawColorHex
    end

    local opacityPercent = tonumber(opacity, 16) / 255

    return colour, opacityPercent
end

local function renderSingleMapPreview(plane, tiles, group, parsedArgs)
    local mapArgs = {
        mapID = -1,
        plane = tonumber(plane),
        x = parsedArgs.x,
        y = parsedArgs.y,
        width = parsedArgs.width,
        height = parsedArgs.height,
        nopreprocess = false,
    }

    local opts = {
        mapID = -1,
        plane = tonumber(plane),
    }

    -- check and set all required named arguments for the map
    if parsedArgs.x ~= nil then
        mapArgs.x = parsedArgs.x
        mapArgs.y = parsedArgs.y
    else
        local xmin = math.huge
        local xmax = -math.huge
        local ymin = math.huge
        local ymax = -math.huge

        for _, pin in pairs(tiles) do
            if pin.x > xmax then
                xmax = pin.x
            end
            if pin.x < xmin then
                xmin = pin.x
            end
            if pin.z > ymax then
                ymax = pin.z
            end
            if pin.z < ymin then
                ymin = pin.z
            end
        end

        local xrange = xmax - xmin
        local yrange = ymax - ymin

        mapArgs.x = math.floor(xmin + xrange / 2)
        mapArgs.y = math.floor(ymin + yrange / 2)
    end

    if parsedArgs.zoom ~= nil then
        mapArgs.zoom = parsedArgs.zoom
    end

    if parsedArgs.caption ~= nil then
        mapArgs.caption = parsedArgs.caption
    end

    local features = {}
    -- mapArgs.pins = features

    -- iterate and render each tile marker as an anonymous argument in map
    for _, tileMarker in pairs(tiles) do
        local worldX, worldY = tileMarker.x, tileMarker.z

        local strokeColour, strokeOpacity = extractColourFromTilemarker(tileMarker.outlineColour)
        local fillColour, fillOpacity = extractColourFromTilemarker(tileMarker.fillColour)

        local squareArgs = {
            squareX = .5,
            squareY = .5,
            x = worldX,
            y = worldY,
            group = group,
            jagexCoords = true,
        }

        squareArgs.stroke = strokeColour
        squareArgs['stroke-opacity'] = strokeOpacity

        squareArgs.fill = fillColour
        squareArgs['fill-opacity'] = fillOpacity

        table.insert(features, map.featSquare(squareArgs, opts))

        if tileMarker.label and tileMarker.label ~= "" then
            local textArgs = {
                squareX = .5,
                squareY = .5,
                x = worldX,
                y = worldY,
                group = group,
                jagexCoords = true,
                label = tileMarker.label,
                class = 'large-label',
            }
            table.insert(features, map.featText(textArgs, opts, textArgs))
        end
    end

    local json = {}
    if #features > 0 then
        json = {
            type = 'FeatureCollection',
            features = features,
        }
    end

    return map.createFeatMap(mapArgs, json)
end

local function renderMapPreview(splitTiles, parsedArgs)
    local mapNodes = {}

    -- iterate the tiles in each plane to generate a map
    if splitTiles == nil then
        mw.log('splitJson is nil!')
    end

    local group = ''
    if parsedArgs.content.name ~= nil then
        -- strip non-alpha chars
        group = string.gsub(parsedArgs.content.name, "%A", "")
    end

    if not parsedArgs.preview_all then
        local targetPlane, targetSplitTiles, total_plane
        if parsedArgs.preview_plane then
            targetPlane = parsedArgs.preview_plane
            targetSplitTiles = splitTiles[parsedArgs.preview_plane]
            total_plane = 1
        else
            total_plane = 0

            local maxPins = 0
            for plane, tiles in pairs(splitTiles) do
                if maxPins <= #tiles then
                    maxPins = #tiles
                    targetPlane = plane
                end
                total_plane = total_plane + 1
            end

            targetSplitTiles = splitTiles[targetPlane]
        end

        table.insert(mapNodes, renderSingleMapPreview(targetPlane, targetSplitTiles, group, parsedArgs))

        if total_plane > 1 then
            table.insert(mapNodes, "<small>''This is a preview of markers on " .. tostring(fln { uk = targetPlane }) ..
                ". Not all markers are displayed on this map.</small>")
        end
    else
        for plane, tiles in pairs(splitTiles) do
            -- currently we only want to display one map, so just break loop on the first plane
            -- if needed later, add conditional logic for what plane/how many to render
            table.insert(mapNodes, renderSingleMapPreview(plane, tiles, group, parsedArgs))
        end
    end

    return mapNodes
end

function p._main(args)
    local parsedArgs = {}

    -- check if it is valid token
    parseToken(parsedArgs, args)

    -- parse map args
    parseArgs(parsedArgs, args)

    local containerDiv = mw.html.create('div')
        :addClass('tilemarker-container')
        :css {
            ['max-width'] = parsedArgs.width .. 'px',
            ['box-sizing'] = 'border-box',
        }

    if parsedArgs.align == 'left' then
        containerDiv:css { ['float'] = 'left', ['clear'] = 'left' }
    elseif parsedArgs.align == 'right' then
        containerDiv:css { ['float'] = 'right', ['clear'] = 'right' }
    elseif parsedArgs.align == 'center' or parsedArgs.align == 'centre' then
        containerDiv:css { ['margin-left'] = 'auto', ['margin-right'] = 'auto' }
    end

    local tokenPresetDiv = mw.html.create('div')
        :addClass('tilemarker-preset-container')
        :css { ['padding'] = '0.25em' }

    tokenPresetDiv:tag('span')
        :addClass('tilemarker-preset-title')
        :wikitext("'''Tilemarkers preset''': ")
        :tag('span'):css('user-select', 'none'):wikitext('['):done()
        :wikitext('[[RuneScape:Tilemarkers|help]]')
        :tag('span'):css('user-select', 'none'):wikitext(']'):done()

    tokenPresetDiv:tag('p')
        :css { ['margin-top'] = '0' }
        :wikitext(parsedArgs.content.name):done()

    local tokenCodeContainer = tokenPresetDiv:tag('div')
        :addClass('tilemarker-token-scroll')
        :css {
            ['overflow-x'] = 'scroll',
            ['padding-bottom'] = '0.75em',
        }

    local tokenCode = tokenCodeContainer:tag('code')
        :addClass('tilemarker-token')
        :css {
            ['user-select'] = 'all',
            ['box-decoration-break'] = 'clone',
            ['word-break'] = 'keep-all',
            ['white-space'] = 'nowrap',
        }
        :node(args.token)

    if parsedArgs.preview then
        local splitTiles = splitOnPlane(parsedArgs.content.tiles)
        local previewNodes = renderMapPreview(splitTiles, parsedArgs)
        -- only render one, so just hardcode first index for now
        for _, previewNode in ipairs(previewNodes) do
            containerDiv:node(previewNode)
        end
    end

    containerDiv:node(tokenPresetDiv)

    return containerDiv;
end

function p.main(frame)
    local args = frame:getParent().args
    return p._main(args)
end

return p