-- <nowiki>
local hc = require('Module:Paramtest').has_content
local icons
local mapVersionList
local fileCache = {}

local p = {}

local zoomSizes = {
    -- { 3, 8 }, -- disabling the default to 3
	{ 2, 4 },
	{ 1, 2 },
	{ 0, 1 },
	{ -1, 1 / 2 },
	{ -2, 1 / 4 },
	{ -3, 1 / 8 }
}
-- Default size of maps (to calc zoom)
local default_size = 800 -- 800px for full screen
-- Map feature (overlay) types
local featureMap = {
	none = {},
	square = { square = true },
	rectangle = { square = true },
	polygon = { polygon = true },
	line = { line = true },
	lines = { line = true },
	linestring = { line = true },
	circle = { circle = true },
	pin = { pins = true },
	pins = { pins = true },
	dot = { dots = true },
	dots = { dots = true },
	sqdot = { sqdots = true },
	sqdots = { sqdots = true },
	circlemarker = { cmarker = true },
	icons = { icons = true },
	icon = { icons = true },
	['pin-polygon'] = { polygon = true, pins = true },
	['pins-polygon'] = { polygon = true, pins = true },
	['pin-line'] = { line = true, pins = true },
	['pins-line'] = { line = true, pins = true },
	['pin-circle'] = { circle = true, pins = true },
	['pins-circle'] = { circle = true, pins = true },
	['dot-polygon'] = { polygon = true, dots = true },
	['dots-polygon'] = { polygon = true, dots = true },
	['dot-line'] = { line = true, dots = true },
	['dots-line'] = { line = true, dots = true },
	['sqdot-polygon'] = { polygon = true, sqdots = true },
	['sqdot-line'] = { line = true, sqdots = true },
	text = { text = true }
}
-- Possible properties
local properties = {
	polygon = { title = true, description = true, stroke = true, ['stroke-opacity'] = true, ['stroke-width'] = true, fill = true, ['fill-opacity'] = true },
	line = { title = true, description = true, stroke = true, ['stroke-opacity'] = true, ['stroke-width'] = true },
	circle = { title = true, description = true, stroke = true, ['stroke-opacity'] = true, ['stroke-width'] = true, fill = true, ['fill-opacity'] = true },
	dot = { title = true, description = true, fill = true, iconSize = true },
	sqdot = { title = true, description = true, fill = true, iconSize = true },
	cmarker = { title = true, description = true, stroke = true, ['stroke-opacity'] = true, ['stroke-width'] = true, fill = true, ['fill-opacity'] = true },
	pin = { title = true, description = true, icon = true, iconWikiLink = true, iconSize = true, iconAnchor = true, popupAnchor = true },
	text = { title = true, description = true, label = true, direction = true, class = true }
}
local numprops = { 'stroke-opacity', 'stroke-width', 'fill-opacity' }

local pinTypes = {
	['greyPin'] = 'pin_grey.svg',
	['redPin'] = 'pin_red.svg',
	['greenPin'] = 'pin_green.svg',
	['bluePin'] = 'pin_blue.svg',
	['cyanPin'] = 'pin_cyan.svg',
	['magentaPin'] = 'pin_magenta.svg',
	['yellowPin'] = 'pin_yellow.svg',
	['lightPin'] = 'pin_light.svg',
	['darkPin'] = 'pin_dark.svg',
}
local pinSize = { 26, 31 }
local pinAnchor = { 13, 31 }
local pinPopupAnchor = { 0, -31 }

-- Create JSON
local function toJSON(j)
	local json_good, json = pcall(mw.text.jsonEncode, j) --, mw.text.JSON_PRETTY)
	if json_good then
		return json
	end
	return error('Error converting to JSON')
end
-- Create map html element
local function createMapElement(elem, args, json)
	local mapelem = mw.html.create(elem)
	mapelem:attr(args):newline():wikitext(toJSON(json)):newline()
	return mapelem
end
-- Create pin description
local function parseDesc(args, pin, pgname, ptype)
	local desc = {}
	if ptype == 'item' then
		desc = {
			"'''Item''': " .. (args.item or pgname),
			"'''Quantity''': " .. (pin.qty or 1)
		}
		if pin.respawn then
			table.insert(desc, "'''Respawn time''': " .. pin.respawn)
		elseif args.respawn then
			table.insert(desc, "'''Respawn time''': " .. args.respawn)
		end
		if pin.notes then
			table.insert(desc, "'''Notes''': " .. pin.notes)
		elseif args.notes then
			table.insert(desc, "'''Notes''': " .. args.notes)
		end
	elseif ptype == 'npc' then
		if pin.npcname then
			table.insert(desc, "'''NPC''': " .. pin.npcname)
		elseif args.npcname then
			table.insert(desc, "'''NPC''': " .. args.npcname)
		else
			table.insert(desc, "'''NPC''': " .. pgname)
		end
		if pin.version then
			table.insert(desc, "'''Version''': " .. pin.version)
		elseif args.version then
			table.insert(desc, "'''Version''': " .. args.version)
		end
		if pin.npcid then
			table.insert(desc, "'''NPC ID''': " .. pin.npcid)
		elseif args.npcid then
			table.insert(desc, "'''NPC ID''': " .. args.npcid)
		end
		if pin.objectid then
			table.insert(desc, "'''Object ID''': " .. pin.objectid)
		elseif args.objectid then
			table.insert(desc, "'''Object ID''': " .. args.objectid)
		end
		if pin.respawn then
			table.insert(desc, "'''Respawn time''': " .. pin.respawn)
		elseif args.respawn then
			table.insert(desc, "'''Respawn time''': " .. args.respawn)
		end
		if pin.notes then
			table.insert(desc, "'''Notes''': " .. pin.notes)
		elseif args.notes then
			table.insert(desc, "'''Notes''': " .. args.notes)
		end
	elseif ptype == 'object' then
		table.insert(desc, "'''Object''': " .. (pin.objectname or args.objectname or pgname))
		if pin.version then
			table.insert(desc, "'''Version''': " .. pin.version)
		elseif args.version then
			table.insert(desc, "'''Version''': " .. args.version)
		end
		if pin.objectid then
			table.insert(desc, "'''Object ID''': " .. pin.objectid)
		elseif args.objectid then
			table.insert(desc, "'''Object ID''': " .. args.objectid)
		end
		if pin.npcid then
			table.insert(desc, "'''NPC ID''': " .. pin.npcid)
		elseif args.npcid then
			table.insert(desc, "'''NPC ID''': " .. args.npcid)
		end
		if pin.respawn then
			table.insert(desc, "'''Respawn time''': " .. pin.respawn)
		elseif args.respawn then
			table.insert(desc, "'''Respawn time''': " .. args.respawn)
		end
		if pin.notes then
			table.insert(desc, "'''Notes''': " .. pin.notes)
		elseif args.notes then
			table.insert(desc, "'''Notes''': " .. args.notes)
		end
	else
		if args.desc then
			table.insert(desc, args.desc)
		end
		if pin.desc then
			table.insert(desc, pin.desc)
		elseif pin.x and pin.y then
			table.insert(desc, 'X,Y: ' .. pin.x .. ',' .. pin.y)
		end
	end

	return table.concat(desc, '<br>')
end
-- Parse unnamed arguments (arg = pin)
function p.parseArgs(args, ptype)
	args.pins = {}
	local sep = args.sep or '%s*,%s*'
	local pgname = mw.title.getCurrentTitle().text
	local rng = {
		xmin = 10000000,
		xmax = -10000000,
		ymin = 10000000,
		ymax = -10000000
	}

	local i, cnt = 1, 0
	while (args[i]) do
		local v = mw.text.trim(args[i])
		if hc(v) then
			local pin = {}
			for u in mw.text.gsplit(v, sep) do
				local _u = mw.text.split(u, '%s*:%s*')
				if _u[2] then
					local k = mw.text.trim(_u[1])
					if k == 'x' or k == 'y' then
						pin[k] = tonumber(mw.text.trim(_u[2]))
					else
						pin[k] = mw.text.trim(_u[2])
					end
				else
					if pin.x then
						pin.y = tonumber(_u[1])
					else
						pin.x = tonumber(_u[1])
					end
				end
			end

			if pin.x > rng.xmax then
				rng.xmax = pin.x
			end
			if pin.x < rng.xmin then
				rng.xmin = pin.x
			end
			if pin.y > rng.ymax then
				rng.ymax = pin.y
			end
			if pin.y < rng.ymin then
				rng.ymin = pin.y
			end

			-- Pin size/location args
			if pin.iconSizeX and pin.iconSizeY then
				pin.iconSize = { tonumber(pin.iconSizeX), tonumber(pin.iconSizeY) }
			elseif pin.iconSize then
				pin.iconSize = { tonumber(pin.iconSize), tonumber(pin.iconSize) }
			end
			if pin.iconAnchorX and pin.iconAnchorY then
				pin.iconAnchor = { tonumber(pin.iconAnchorX), tonumber(pin.iconAnchorY) }
			elseif pin.iconAnchor then
				pin.iconAnchor = { tonumber(pin.iconAnchor), tonumber(pin.iconAnchor) }
			end
			if pin.popupAnchorX and pin.popupAnchorY then
				pin.popupAnchor = { tonumber(pin.popupAnchorX), tonumber(pin.popupAnchorY) }
			elseif pin.popupAnchor then
				pin.popupAnchor = { tonumber(pin.popupAnchor), tonumber(pin.popupAnchor) }
			end

			pin.desc = parseDesc(args, pin, pgname, ptype)

			table.insert(args.pins, pin)
			cnt = cnt + 1
		end
		i = i + 1
	end

	-- In no anonymous args then x,y are pin
	if cnt == 0 then
		local x = tonumber(args.x) or 3233 -- Default is Lumbridge loadstone
		local y = tonumber(args.y) or 3222
		rng.xmax = x
		rng.xmin = x
		rng.ymax = y
		rng.ymin = y
		local desc = parseDesc(args, {}, pgname, ptype)
		table.insert(args.pins, { x = x, y = y, desc = desc })
		cnt = cnt + 1
	end

	local xrange = rng.xmax - rng.xmin
	local yrange = rng.ymax - rng.ymin

	if not tonumber(args.x) then
		args.x = math.floor(rng.xmin + xrange / 2)
	end
	if not tonumber(args.y) then
		args.y = math.floor(rng.ymin + yrange / 2)
	end
	-- Default range (1 pin) is 1
	if not tonumber(args.x_range) then
		if xrange >= 0 then
			args.x_range = xrange + 1
		else
			args.x_range = 1
		end
	end
	if not tonumber(args.y_range) then
		if yrange > 0 then
			args.y_range = yrange + 1
		else
			args.y_range = 1
		end
	end
	
	-- Min square size
	args.squareX = tonumber(args.squareX)
	args.squareY = tonumber(args.squareY)

	if args.squareX ~= nil then
		if args.squareX < 3 then
			args.squareX = 3
		end
	else
		if xrange > 0 then
			args.squareX = xrange + 1
		elseif cnt == 1 then
			args.squareX = 10
		elseif cnt > 1 then
			args.squareX = 1
		end
	end

	if args.squareY ~= nil then
		if args.squareY < 3 then
			args.squareY = 3
		end
	else
		if xrange > 0 then
			args.squareY = yrange + 1
		elseif cnt == 1 then
			args.squareY = 10
		elseif cnt > 1 then
			args.squareY = 1
		end
	end

	args.pin_count = cnt

	return args
end

-- Add styles
local function styles(ftjson, args, this, ptype)
	local props = properties[ptype]
	for i, v in pairs(args) do
		if props[i] then
			if type(v) == "table" then
				ftjson.properties[i] = mw.clone(v)
			else
				ftjson.properties[i] = v
			end
		end
	end
	for i, v in pairs(this) do
		if props[i] then
			ftjson.properties[i] = v
		end
	end
	for _, v in ipairs(numprops) do
		if ftjson.properties[v] then
			ftjson.properties[v] = tonumber(ftjson.properties[v])
		end
	end

	return ftjson
end

-- Functions for templates were moved to the /templates submodule! --

-- Function for creating map or link
function p.createMap(args)
	local opts = {
		mapID = args.mapID or 28, -- RuneScape Surface
		plane = tonumber(args.plane) or 0,
	}

	local featColl, features = {}, {}
	if hc(args.features) then
		local _features = string.lower(args.features)
		features = featureMap[_features] or {}
	end
	if features.square then
		table.insert(featColl, p.featSquare(args, opts))
	elseif features.circle then
		table.insert(featColl, p.featCircle(args, opts))
	end
	if features.polygon then
		table.insert(featColl, p.featPolygon(args, opts))
	elseif features.line then
		table.insert(featColl, p.featLine(args, opts))
	end
	if features.text then
		for _, pin in ipairs(args.pins) do
			table.insert(featColl, p.featText(args, opts, pin))
		end
	end
	if features.pins then
		if not opts.group then
			opts.group = 'pins'
		end
		opts.icon = args.icon or 'cyanPin'
		for _, pin in ipairs(args.pins) do
			table.insert(featColl, p.featPin(args, opts, pin))
		end
	elseif features.icons then
		if not opts.group then
			opts.group = 'pins'
		end
		for _, pin in ipairs(args.pins) do
			table.insert(featColl, p.featIcon(args, opts, pin))
		end
	elseif features.dots then
		if not opts.group then
			opts.group = 'dots'
		end
		for _, pin in ipairs(args.pins) do
			table.insert(featColl, p.featDot(args, opts, pin))
		end
	elseif features.sqdot or features.sqdots then
		if not opts.group then
			opts.group = 'dots'
		end
		for _, pin in ipairs(args.pins) do
			table.insert(featColl, p.featSqDot(args, opts, pin))
		end
	elseif features.cmarker then
		if not opts.group then
			opts.group = 'dots'
		end
		for _, pin in ipairs(args.pins) do
			table.insert(featColl, p.featCirMark(args, opts, pin))
		end
	end

	local json = {}
	if #featColl > 0 then
		json = {
			type = 'FeatureCollection',
			features = featColl
		}
	end

	return p.createFeatMap(args, json)
end

-- Function for creating map or link with features already generated
function p.createFeatMap(args, ftcoljson)
	local x, y = args.x, args.y
	local opts = {
		x = x,
		y = y,
		width = args.width or 300,
		height = args.height or 300,
		mapID = 28, -- RuneScape Surface is default
		plane = tonumber(args.plane) or 0,
		zoom = args.zoom or 2,
		align = args.align or 'center'
	}
	-- make sure mapID passed as number 0 works
	if type(tonumber(args.mapID)) == 'number' then
		opts.mapID = args.mapID
	end

	if hc(args.group) then
		opts.group = args.group
	end
	if hc(args.show) then
		opts.show = args.show
	end

	-- plain map tiles
	if hc(args.plaintiles) then
		opts.plainTiles = 'true'
	end
	if hc(args.plainTiles) then
		opts.plainTiles = 'true'
	end

	-- other map tile version
	if hc(args.mapversion) or hc(args.mapVersion) then
		local mapvers = args.mapversion
		if hc(args.mapVersion) then
			mapvers = args.mapVersion
		end
		if not mapVersionList then
			mapVersionList = mw.loadData('Module:Map/versions')
		end
		if mapVersionList[mapvers] then
			opts.mapVersion = mapVersionList[mapvers]
		else
			opts.mapVersion = mapvers
		end
	end

	-- mapframe, maplink
	local etype = 'mapframe'
	if hc(args.etype) then
		etype = args.etype
	end

	-- translate "centre" spelling for align
	if opts.align == 'centre' then
		opts.align = 'center'
	end

	-- Caption or link text
	if etype == 'maplink' then
		opts.text = args.text or 'Show map'
		if string.find(opts.text, '[%[%]]') then
			return error('Text cannot contain links')
		end
	elseif hc(args.caption) then
		opts.text = args.caption
	else
		opts.frameless = ''
	end

	-- Zoom
	if type(tonumber(args.zoom)) == 'number' then
		opts.zoom = args.zoom
	else
		local width, height = opts.width, opts.height
		if etype == 'maplink' then
			width, height = default_size, default_size
		end
		local x_range = tonumber(args.squareX) or 3
		local y_range = tonumber(args.squareY) or 3
		if tonumber(args.r) then
			x_range = tonumber(args.r) or 3
			y_range = tonumber(args.r) or 3
		end
		if tonumber(args.x_range) then
			x_range = tonumber(args.x_range) or 3
		end
		if tonumber(args.y_range) then
			y_range = tonumber(args.y_range) or 3
		end

		local zoom = -3
		for _, v in ipairs(zoomSizes) do
			local sqsx, sqsy = width / v[2], height / v[2]
			if sqsx > x_range and sqsy > y_range then
				zoom = v[1]
				break
			end
		end
		if zoom > 3 then
			zoom = 3
		end
		opts.zoom = zoom
	end

	local map = createMapElement(etype, opts, ftcoljson)
	if args.nopreprocess then
		return map
	end
	return mw.getCurrentFrame():preprocess(tostring(map))
end

-- Create a square feature
function p.featSquare(args, opts)
	local x, y = args.x, args.y
	local squareX = tonumber(args.squareX) or 3
	local squareY = tonumber(args.squareY) or 3
	squareX = math.max(0.5, args.r or math.floor(squareX / 2))
	squareY = math.max(0.5, args.r or math.floor(squareY / 2))

	if args.jagexCoords then
		x = x + 0.5
		y = y + 0.5
	end

	local ftjson = {
		type = 'Feature',
		properties = { ['_'] = '_', mapID = opts.mapID, plane = opts.plane },
		geometry = {
			type = 'Polygon',
			coordinates = {
				{
					{ x - squareX, y - squareY },
					{ x - squareX, y + squareY },
					{ x + squareX, y + squareY },
					{ x + squareX, y - squareY }
				}
			}
		}
	}

	ftjson = styles(ftjson, args, {}, 'polygon')
	return ftjson
end

-- Create a polygon feature
function p.featPolygon(args, opts)
	local points, lastpoint = {}, {}
	for _, v in ipairs(args.pins) do
		table.insert(points, { v.x, v.y, })
		lastpoint = { v.x, v.y, }
	end
	-- Close polygon
	if not (points[1][1] == lastpoint[1] and points[1][2] == lastpoint[2]) then
		table.insert(points, { points[1][1], points[1][2] })
	end

	local ftjson = {
		type = 'Feature',
		properties = { ['_'] = '_', mapID = opts.mapID, plane = opts.plane },
		geometry = {
			type = 'Polygon',
			coordinates = { points }
		}
	}

	ftjson = styles(ftjson, args, {}, 'polygon')
	return ftjson
end

-- Create a complex polygon feature (allows nested coords array)
function p.featComplPolygon(args, opts, coords)
	local ftjson = {
		type = 'Feature',
		properties = { ['_'] = '_', mapID = opts.mapID, plane = opts.plane },
		geometry = {
			type = 'Polygon',
			coordinates = coords
		}
	}

	ftjson = styles(ftjson, args, {}, 'polygon')
	return ftjson
end

-- Create a line feature
function p.featLine(args, opts)
	local points, lastpoint = {}, {}
	for _, v in ipairs(args.pins) do
		table.insert(points, { v.x, v.y, })
		lastpoint = { v.x, v.y, }
	end
	if hc(args.close) then
		-- Close line
		if not (points[1][1] == lastpoint[1] and points[1][2] == lastpoint[2]) then
			table.insert(points, { points[1][1], points[1][2] })
		end
	end

	local ftjson = {
		type = 'Feature',
		properties = {
			['_'] = '_',
			shape = 'Line',
			mapID = opts.mapID,
			plane = opts.plane
		},
		geometry = {
			type = 'LineString',
			coordinates = points
		}
	}

	ftjson = styles(ftjson, args, {}, 'line')
	return ftjson
end

-- Create a circle feature
function p.featCircle(args, opts)
	local rad = tonumber(args.r) or 10
	local ftjson = {
		type = 'Feature',
		properties = {
			['_'] = '_',
			shape = 'Circle',
			radius = rad,
			mapID = opts.mapID,
			plane = opts.plane
		},
		geometry = {
			type = 'Point',
			coordinates = {
				args.x, args.y, opts.plane
			}
		}
	}

	-- Center circles on tile, when using tile based coordinates eg from in game
	if args.jagexCoords then
		ftjson.geometry.coordinates[1] = ftjson.geometry.coordinates[1] + 0.5
		ftjson.geometry.coordinates[2] = ftjson.geometry.coordinates[2] + 0.5
	end

	ftjson = styles(ftjson, args, {}, 'circle')
	return ftjson
end

-- Create a text label feature
function p.featText(args, opts, pin)
	local desc = pin.desc or args.desc
	local ftjson = {
		type = 'Feature',
		properties = {
			shape = 'Text',
			description = desc,
			mapID = opts.mapID,
			plane = opts.plane
		},
		geometry = {
			type = 'Point',
			coordinates = {
				pin.x, pin.y, opts.plane
				-- pin.x+0.5, pin.y-0.5, opts.plane
			}
		}
	}

	-- Center text on tile, when using tile based coordinates eg from in game
	if args.jagexCoords then
		ftjson.geometry.coordinates[1] = ftjson.geometry.coordinates[1] + 0.5
		ftjson.geometry.coordinates[2] = ftjson.geometry.coordinates[2] + 0.5
	end

	ftjson = styles(ftjson, args, pin, 'text')
	return ftjson
end

-- Create a dot type marker feature
function p.featDot(args, opts, pin)
	local desc = pin.desc or pin.x .. ', ' .. pin.y
	local ftjson = {
		type = 'Feature',
		properties = {
			shape = 'Dot',
			description = desc,
			mapID = opts.mapID,
			plane = opts.plane
		},
		geometry = {
			type = 'Point',
			coordinates = {
				pin.x, pin.y, opts.plane
				-- pin.x+0.5, pin.y-0.5, opts.plane
			}
		}
	}

	-- Center dots on tile, when using tile based coordinates eg from in game
	if args.jagexCoords then
		ftjson.geometry.coordinates[1] = ftjson.geometry.coordinates[1] + 0.5
		ftjson.geometry.coordinates[2] = ftjson.geometry.coordinates[2] + 0.5
	end

	ftjson = styles(ftjson, args, pin, 'dot')
	return ftjson
end

-- Create a square dot marker type feature
function p.featSqDot(args, opts, pin)
	local desc = pin.desc or pin.x .. ', ' .. pin.y
	local ftjson = {
		type = 'Feature',
		properties = {
			shape = 'SquareDot',
			description = desc,
			mapID = opts.mapID,
			plane = opts.plane
		},
		geometry = {
			type = 'Point',
			coordinates = {
				pin.x, pin.y, opts.plane
				-- pin.x+0.5, pin.y-0.5, opts.plane
			}
		}
	}

	-- Center square dots on tile, when using tile based coordinates eg from in game
	if args.jagexCoords then
		ftjson.geometry.coordinates[1] = ftjson.geometry.coordinates[1] + 0.5
		ftjson.geometry.coordinates[2] = ftjson.geometry.coordinates[2] + 0.5
	end

	ftjson = styles(ftjson, args, pin, 'sqdot')
	return ftjson
end

-- Create a circlemarker feature (like a pin it rescales on zoom)
function p.featCirMark(args, opts, pin)
	local rad = tonumber(args.r) or 10
	local desc = pin.desc or pin.x .. ', ' .. pin.y
	local ftjson = {
		type = 'Feature',
		properties = {
			shape = 'CircleMarker',
			radius = rad,
			description = desc,
			mapID = opts.mapID,
			plane = opts.plane
		},
		geometry = {
			type = 'Point',
			coordinates = {
				pin.x, pin.y, opts.plane
				-- pin.x+0.5, pin.y-0.5, opts.plane
			}
		}
	}

	-- Center circle marker on tile, when using tile based coordinates eg from in game
	if args.jagexCoords then
		ftjson.geometry.coordinates[1] = ftjson.geometry.coordinates[1] + 0.5
		ftjson.geometry.coordinates[2] = ftjson.geometry.coordinates[2] + 0.5
	end

	ftjson = styles(ftjson, args, pin, 'cmarker')
	return ftjson
end

local function getFilePath(iconWikiLink)
	if string.find(iconWikiLink, 'https?://') then
		-- empty
		return iconWikiLink
	elseif fileCache[iconWikiLink] then
		return fileCache[iconWikiLink]
	else
		local link = mw.ext.GloopTweaks.filepath(iconWikiLink)
		fileCache[iconWikiLink] = link
		return link
	end
end

-- Create a pin feature
-- Pin types: greyPin, redPin, greenPin, bluePin, cyanPin, magentaPin, yellowPin, lightPin, darkPin
function p.featPin(args, opts, pin)
	local desc = pin.desc or pin.x .. ', ' .. pin.y
	local ftjson = {
		type = 'Feature',
		properties = {
			providerID = 0,
			description = desc,
			mapID = opts.mapID,
			plane = opts.plane
		},
		geometry = {
			type = 'Point',
			coordinates = {
				pin.x, pin.y, opts.plane
				-- pin.x+0.5, pin.y+0.5, opts.plane
			}
		}
	}

	-- Center pin on tile, when using tile based coordinates eg from in game
	if args.jagexCoords then
		ftjson.geometry.coordinates[1] = ftjson.geometry.coordinates[1] + 0.5
		ftjson.geometry.coordinates[2] = ftjson.geometry.coordinates[2] + 0.5
	end

	-- operate on either pin or args, whichever (tested in that order) defines an iconWikiLink
	local tbl = pin.iconWikiLink and pin or args.iconWikiLink and args
	if tbl then
		tbl.iconWikiLink = getFilePath(tbl.iconWikiLink)
		if not args.popupAnchor and not pin.popupAnchor then
			tbl.popupAnchor = { 0, 0 }
		end
	end

	ftjson = styles(ftjson, args, pin, 'pin')

	-- remove factory-set pin icons
	if ftjson.properties.icon then
		if not ftjson.properties.iconWikiLink then
			ftjson.properties.iconWikiLink = getFilePath(pinTypes[ftjson.properties.icon])
			ftjson.properties.iconSize = mw.clone(pinSize)
			ftjson.properties.iconAnchor = mw.clone(pinAnchor)
			ftjson.properties.popupAnchor = mw.clone(pinPopupAnchor)
		end

		ftjson.properties.icon = nil
	end

	if not (ftjson.properties.icon or ftjson.properties.iconWikiLink) then
		ftjson.properties.iconWikiLink = getFilePath(pinTypes.lightPin)
		ftjson.properties.iconSize = mw.clone(pinSize)
		ftjson.properties.iconAnchor = mw.clone(pinAnchor)
		ftjson.properties.popupAnchor = mw.clone(pinPopupAnchor)
	end
	return ftjson
end

-- Predefined icons for pins froom [[Module:Map/icons]]
function p.featIcon(args, opts, pin)
	local desc = pin.desc or pin.x .. ', ' .. pin.y
	local ftjson = {
		type = 'Feature',
		properties = {
			providerID = 0,
			description = desc,
			mapID = opts.mapID,
			plane = opts.plane
		},
		geometry = {
			type = 'Point',
			coordinates = {
				pin.x, pin.y, opts.plane
				-- pin.x+0.5, pin.y-0.5, opts.plane
			}
		}
	}

	-- Center icon on tile, when using tile based coordinates eg from in game
	if args.jagexCoords then
		ftjson.geometry.coordinates[1] = ftjson.geometry.coordinates[1] + 0.5
		ftjson.geometry.coordinates[2] = ftjson.geometry.coordinates[2] + 0.5
	end

	if not icons then
		icons = mw.loadData('Module:Map/icons')
	end
	local ic = pin.icon or args.icon
	ic = icons[ic]
	if not ic then
		error('Invalid icon name: ' .. ic .. ', see [[Module:Map/icons]] for available icons and aliases')
	end

	if fileCache[ic.icon] then
		pin.iconWikiLink = fileCache[ic.icon]
	else
		local link = mw.ext.GloopTweaks.filepath(ic.icon)
		fileCache[ic.icon] = link
		pin.iconWikiLink = link
	end
	pin.iconSize = { ic.iconSize[1], ic.iconSize[2] }
	pin.iconAnchor = { ic.iconAnchor[1], ic.iconAnchor[2] }
	pin.popupAnchor = { ic.popupAnchor[1], ic.popupAnchor[2] }

	ftjson = styles(ftjson, args, pin, 'pin')
	return ftjson
end

return p
-- </nowiki>