local p = {};
local map = require('Module:Map')
local bit32 = require("bit32")
local defaultHexColor = '#FF3388FF'

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

function p._main(args)
	local parsedArgs = parseArgs(args)
	
	local jsonContent = mw.loadJsonData(parsedArgs['jsonPage'])
	local splitJson = splitOnPlane(jsonContent)
	
	local containerDiv = mw.html.create( 'div' )
	local resultsDiv = mw.html.create( 'div' )
		resultsDiv:css({display = 'none'})
		resultsDiv:addClass('tilemarker-div')
		resultsDiv:node(mw.text.jsonEncode(jsonContent))


	if parsedArgs['showpreview'] then
		local previewNodes = renderMapPreview(splitJson, parsedArgs)
		-- only render one, so just hardcode first index for now
		containerDiv:node(previewNodes[1])
	end
	
	containerDiv:node(resultsDiv)

	return containerDiv;
end

function parseArgs(args)
	local newArgs = {}
	-- common args
	if args[1] == nil or args[1] == '' then
		error('[Module:Tile markers button] Argument{1} for json page must not be nil.')
	end
	newArgs['jsonPage'] = args[1]
	
	if args[2] ~= nil and args[2] ~= '' then
		newArgs['pageName'] = args[2]
	end
	
	-- override args
	-- ensure both or neither x and y are specified
	if args['x'] ~= nil or args['y'] ~= nil then
		if args['x'] == nill or args['x'] == '' or args['y'] == nil or args['y'] == '' then
			error('[Module:Tile markers button] Both x and y must be specified if you are overriding the map window location.')
		else
			newArgs['x'] = args['x']
			newArgs['y'] = args['y']
		end
	end
	
	-- ensure zoom, if specified, is not blank
	if args['zoom'] ~= nil then
		if args['zoom'] == '' then
			error('[Module:Tile markers button] zoom argument cannot be blank')
		else
			newArgs['zoom'] = args['zoom']	
		end
	end
	
	newArgs['showpreview'] = parseBoolean(args['showpreview'], true)
	
	if args['align'] ~= nil then
		if args['align'] ~= 'left' and args['align'] ~= 'center' and args['align'] ~= 'right' then
			error('[Module:Tile markers button] An invalid align value was specified.')
		else
			newArgs['align'] = args['align']	
		end
	end
	
	return newArgs
end

function renderMapPreview(splitJson, parsedArgs)
	mw.logObject(splitJson)
	mw.logObject(parsedArgs)
	local mapNodes = {}
	
	-- iterate the tiles in each plane to generate a map
	if splitJson == nil then
		mw.log('splitJson is nil!')
	end
	for plane,tiles in pairs(splitJson) do
		local namedMapArgs = {}
		
		-- check and set all required named arguments for the map
		namedMapArgs['mapID'] = '-1'
		namedMapArgs['plane'] = plane
		
		if parsedArgs['x'] ~= nil then
			namedMapArgs['x'] = parsedArgs['x']
			namedMapArgs['y'] = parsedArgs['y']
		end
		
		if parsedArgs['zoom'] ~= nil then
			namedMapArgs['zoom'] = parsedArgs['zoom']
		end
		
		if parsedArgs['align'] ~= nil then
			namedMapArgs['align'] = parsedArgs['align']
		end
		
		-- iterate and render each tile marker as an anonymous argument in map
		for i, tileMarker in pairs(tiles) do
			local worldX, worldY = extractCoordsFromTilemarker(tileMarker)
			local color, opacity = extractColorFromTilemarker(tileMarker)
			
			local anonArgsStr = 'mtype:rectangle,rectX:1,rectY:1,'
			
			if parsedArgs['pageName'] ~= nil then
				-- strip non-alpha chars
				local stripped = string.gsub(parsedArgs['pageName'], "%A", "")
				anonArgsStr = anonArgsStr .. 'group:' .. stripped .. ','
			else
				local stripped = string.gsub(parsedArgs['jsonPage'], "%A", "")
				anonArgsStr = anonArgsStr .. 'group:' .. stripped .. ','
			end
			
			if color ~= nil then
				anonArgsStr = anonArgsStr .. 'stroke:' .. color .. ','
				-- anonArgsStr = anonArgsStr .. 'fill:' .. color .. ','
				-- anonArgsStr = anonArgsStr .. 'fill-opacity:' .. opacity .. ','
			end
			
			anonArgsStr = anonArgsStr .. worldX .. ','
			anonArgsStr = anonArgsStr .. worldY
			
			table.insert(namedMapArgs, anonArgsStr)
		end
		
		-- currently we only want to display one map, so just break loop on the first plane
		-- if needed later, add conditional logic for what plane/how many to render
		table.insert(mapNodes, map.buildMap(namedMapArgs))
		break
	end
	
	return mapNodes
end

function extractCoordsFromTilemarker(tileMarker)
	local regionId = tileMarker['regionId']
	local regionX = tileMarker['regionX']
	local regionY = tileMarker['regionY']
	
	local worldX = (bit32.lshift(bit32.rshift(regionId, 8), 6)) + regionX
	local worldY = (bit32.lshift(bit32.band(regionId, 0xFF), 6)) + regionY
	
	return worldX, worldY
end

function extractColorFromTilemarker(tileMarker)
    local rawColorHex = tileMarker['color'] or tileMarker['colour'] or defaultHexColor
    
    local color
    local opacity
    if string.len(rawColorHex) > 7 then
    	opacity = string.sub(rawColorHex, 2, 3)
    	color = '#'..string.sub(rawColorHex, 4)
    else
    	opacity = 'FF'
    	color = rawColorHex
    end
    
    local opacityPercent = tonumber(opacity, 16) / 255
    
    return color, opacityPercent
end

function splitOnPlane(json)
	local planeTiles = {}
	
	for i, tile in ipairs(json) do
		local plane = tile['z'] ~= nil and tostring(tile['z']) or '0'
		if planeTiles[plane] == nil then
			planeTiles[plane] = {}
		end
		
		table.insert(planeTiles[plane], tile)
	end
	
	return planeTiles
end

function parseBoolean(inputStr, default)
	if inputStr == nil then
		return default
	end
	
	return string.lower(inputStr) == 'yes' or string.lower(inputStr) == 'y' or string.lower(inputStr) == 'true' or string.lower(inputStr) == 't' and true or false
end

return p;