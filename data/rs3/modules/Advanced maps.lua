-- <nowiki>
local maps = require('Module:Map')
local hc = require('Module:Paramtest').has_content
local yesno = require('Module:Yesno')
local icons

local p = {}

-- For color incrementing
local dotcolors = { '#A6CEE3', '#ED0000', '#42B540', '#0099B4', '#925E9F', '#FDAF91', '#AD002A', '#ADB6B6', '#1B1919' }
local dotcolors2 = { '#a6cee3', '#6a3d9a', '#fb9a99', '#1f78b4', '#b2df8a', '#fdbf6f', '#b15928', '#33a02c', '#cab2d6',
	'#e31a1c', '#ffff99', '#ff7f00' }

local curcolor = 1

-- Possible style args
local styles = { 'title', 'description', 'label', 'class', 'stroke', 'stroke-opacity', 'stroke-width', 'fill',
	'fill-opacity', 'radius', 'r', 'icon', 'iconWikiLink', 'direction' }
local pairstyles = { 'iconSize', 'iconAnchor', 'popupAnchor' }
-- Pin types
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

local genMap

-- Create JSON
local function toJSON(j)
	local json_good, json = pcall(mw.text.jsonEncode, j) --, mw.text.JSON_PRETTY)
	if json_good then
		return json
	end
	return error('Error converting to JSON')
end

-- Parse coordinates
local function parseCoords(str)
	local ret = {}
	for u in mw.text.gsplit(str, '%s*;%s*') do
		local xy = mw.text.split(u, '%s*,%s*')
		local x = tonumber(xy[1])
		local y = tonumber(xy[2])
		if x and y then
			table.insert(ret, { x = x, y = y })
		end
	end
	if #ret < 1 then error('Error the following is not a valid coordinate set: ' .. str) end
	return ret
end

local function parseComplCoords(str)
	local ret, i = {}, 1
	for v in mw.text.gsplit(str, '%s*;%s*;%s*') do
		ret[i] = {}
		for u in mw.text.gsplit(v, '%s*;%s*') do
			local xy = mw.text.split(u, '%s*,%s*')
			local x = tonumber(xy[1])
			local y = tonumber(xy[2])
			if x and y then
				table.insert(ret[i], { x, y })
			end
		end
		if #ret[i] < 1 then error('Error the following is not a valid coordinate set: ' .. str) end
		i = i + 1
	end
	if #ret < 1 then error('Error the following is not a valid coordinate set: ' .. str) end
	return ret
end

local function assignFillColourIfEmpty(ftargs)
	-- Force a new color if none given
	if not ftargs.fill then
		ftargs.fill = dotcolors[curcolor]
		curcolor = curcolor + 1

		if curcolor > #dotcolors then
			curcolor = 1
		end
	end
end

-- Single point type features
local function pointFeats(ret, ftargs, opts, coords, typ)
	local mult = false
	if #coords > 1 then
		mult = true
	end

	for _, v in ipairs(coords) do
		v.desc = ftargs.desc or ''

		local args = ftargs
		if mult then
			args = mw.clone(ftargs)
		end

		if typ == 'circle' then
			-- Circle
			args.x = v.x
			args.y = v.y
			table.insert(ret, maps.featCircle(args, opts))
		elseif typ == 'circlemarker' then
			-- CircleMarker
			args.x = v.x
			args.y = v.y
			table.insert(ret, maps.featCirMark(args, opts, v))
		elseif typ == 'text' then
			-- Text label
			table.insert(ret, maps.featText(args, opts, v))
		elseif typ == 'pin' then
			-- Pin
			table.insert(ret, maps.featPin(args, opts, v))
		elseif typ == 'icon' then
			-- Pin but use iconWikiLink with a predefine one
			args.icon = string.lower(args.icon)

			table.insert(ret, maps.featIcon(args, opts, v))
		elseif typ == 'square' or typ == 'sq' then
			-- Square dot
			table.insert(ret, maps.featSqDot(args, opts, v))
		elseif typ == 'dot' then
			-- Dot
			table.insert(ret, maps.featDot(args, opts, v))
		end

		-- Weird-looking performance optimization due to SimpleStyleParser being a buggy piece of shit.
		-- Reduces parse time by about 50%. Do not remove without talking to Cook
		if ret[#ret].properties.description == '' then
			ret[#ret].properties.description = nil
		end
	end
end

local function genKeyFeature(ret, feature)
	local typ = feature['type']
	if hc(typ) then
		typ = string.lower(typ or '')
	else
		typ = 'dot'
	end

	local show = false
	if feature['key'] and feature['title'] then
		show = true
	elseif typ ~= 'text' and feature['coords'] and hc(feature['coords']) then
		show = true
	end

	if feature['nokey'] then
		show = false
	end

	if not show then
		return
	end

	local val = feature['title'] or feature['label'] or 'Missing title'

	local symb = mw.html.create('div')
	symb:addClass('amap-key-symb')

	if typ == 'key' then
		-- Only title text, no symbol
		symb:addClass('amap-key-nosymb')
	elseif typ == 'text' then
		local cl = 'leaflet-vis-tooltip'
		if feature['class'] then
			cl = cl .. ' ' .. feature['class']
		end
		symb:addClass('map-style-preview')
			:tag('div'):addClass(cl):wikitext('XX'):done()
	elseif typ == 'polygon' or typ == 'circle' or typ == 'circlemarker' or typ == 'complex-polygon' or typ == 'complpoly' then
		local cl = 'amap-key-poly'
		if typ == 'circle' or typ == 'circlemarker' then cl = 'amap-key-circ' end

		local brdCol = feature['stroke'] or '#3388ff'
		local brdWi = feature['stroke-width'] or 3
		symb
			:tag('div'):addClass(cl):css({
			border = brdWi .. 'px solid ' .. brdCol,
			opacity = feature['stroke-opacity'] or 1
		})
			:tag('div'):css({
			background = feature['fill'] or '#3388ff',
			opacity = feature['fill-opacity'] or 0.2
		})
			:done():done()
	elseif typ == 'line' or typ == 'lines' or typ == 'linestring' then
		local brdCol = feature['stroke'] or '#3388ff'
		local brdWi = tonumber(feature['stroke-width']) or 3
		brdWi = brdWi / 2 -- div height 0 so border renders double height
		symb:tag('div'):addClass('amap-key-line'):css({
			border = brdWi .. 'px solid ' .. brdCol,
			opacity = feature['stroke-opacity'] or 1
		}):done()
	elseif typ == 'pin' then
		local iconSize = '26x42px'
		local pimg
		if feature['iconWikiLink'] then
			pimg = feature['iconWikiLink']
		else
			pimg = feature['icon'] or 'lightPin'
			if pinTypes[pimg] then
				pimg = pinTypes[pimg]
			else
				pimg = 'pin_green.svg'
			end
		end
		if feature['iconSize'] then
			iconSize = string.gsub(feature['iconSize'], '%s*,%s*', 'x') .. 'px'
		end
		symb:wikitext(string.format('[[File:%s|%s|link=]]', pimg, iconSize))
	elseif typ == 'icon' then
		if not icons then
			icons = mw.loadData('Module:Map/icons')
		end

		local ic = string.lower(feature['icon'])
		ic = icons[ic]
		if not ic then
			error('Invalid icon name: ' .. ic .. ', see [[Module:Map/icons]] for available icons and aliases')
		end

		symb:wikitext(string.format('[[File:%s|%sx%spx|link=]]', ic.icon,
			math.ceil(ic.iconSize[1]), math.ceil(ic.iconSize[2])))
	elseif typ == 'square' or typ == 'sq' or
		typ == 'dot' then
		-- Dot or square dot
		local cl
		if typ == 'square' or typ == 'sq' then
			cl = 'leaflet-sqdot'
		else
			cl = 'leaflet-dot'
		end
		symb:tag('div'):addClass('amap-key-dots')
			:tag('div'):addClass(cl):css({ background = feature['fill'] or '#3388ff' })
			:done()
			:done()
	else
		error('The type "' .. typ .. '" of the map feature is not recognised.')
	end

	ret:tag('li')
		:node(symb)
		:tag('div')
		:addClass('amap-key-text')
		:wikitext(val)
		:done()
		:done()
end

-- Generate the map key
local function genKey(args, featureParams)
	local ret = mw.html.create('ul')

	-- Look for up to MAX_ARG_COUNT feature groups, defined in order
	local hasKeyFeatures = false

	for _, feature in pairs(featureParams) do
		if feature['key'] or feature['coords'] and hc(feature['coords']) then
			hasKeyFeatures = true
			genKeyFeature(ret, feature)
		end
	end

	if args.compass then
		hasKeyFeatures = true

		ret:tag('li')
			:tag('div'):addClass('amap-key-symb amap-key-nosymb'):done()
			:tag('div')
			:addClass('amap-key-text amap-key-compass')
			:wikitext('[[File:Compass.png|35x35px|link=]]')
			:done()
			:done()
	end

	if hasKeyFeatures then
		return tostring(ret)
	else
		return ''
	end
end

-- Category args
local function catArg(arg)
	local ret = ''
	for u in mw.text.gsplit(arg, '%s*,%s*') do
		if u and u ~= '' then
			ret = ret .. string.format('[[Category:%s]]', u)
		end
	end
	return ret
end

-- Edit buttons
local function navBar(name)
	local viewSpan = mw.html.create('span')
		:attr('title', 'View this map')
		:wikitext('v')

	local talkSpan = mw.html.create('span')
		:attr('title', 'Discussion about this map')
		:wikitext('d')

	local editSpan = mw.html.create('span')
		:attr('title', 'You can edit this map. Please use the preview button before saving.')
		:wikitext('e')

	local pgtitle = mw.title.getCurrentTitle()

	local ret = mw.html.create('div')
		:addClass('amap-nav plainlinks noprint')
	if pgtitle.prefixedText ~= 'Map:' .. name then
		ret:wikitext('[[Map:' .. name .. '|' .. tostring(viewSpan) .. ']]')
			:wikitext('&nbsp;')
			:tag('span'):css('font-size', '80%'):wikitext('&bull;'):done()
			:wikitext('&nbsp;')
	end
	ret:wikitext('[' .. tostring(mw.uri.fullUrl('Map talk:' .. name)) .. ' ' .. tostring(talkSpan) .. ']')
		:wikitext('&nbsp;')
		:tag('span'):css('font-size', '80%'):wikitext('&bull;'):done()
		:wikitext('&nbsp;')
		:wikitext('[' .. tostring(mw.uri.fullUrl('Map:' .. name, 'action=edit')) .. ' ' .. tostring(editSpan) .. ']')

	return ret
end

local function addcategories(args)
	local ret = ''

	local nsp = mw.title.getCurrentTitle().namespace
	if nsp == 0 then
		-- On main
		ret = ret .. '[[Category:Pages using advanced maps]]'
		if args.pgcats then
			ret = ret .. catArg(args.pgcats)
		end
	elseif nsp == 118 then
		-- Map namespace
		ret = ret .. '[[Category:Advanced maps]]'
		if args.mapcats then
			ret = ret .. catArg(args.mapcats)
		end
	end

	return ret
end

local function parseFeatureParams(args)
	local features = {}

	for key, value in pairs(args) do
		local matched_key, matched_id = string.match(key, '(.*%l)(%d+)')
		matched_id = tonumber(matched_id);
		if matched_id ~= nil then
			if features[matched_id] == nil then
				features[matched_id] = {}
			end

			features[matched_id][matched_key] = value
		end
	end

	return features
end

function p.main(frame)
	local args = frame:getParent().args

	-- Combination parameters
	if args.center and hc(args.center) then
		local xy = mw.text.split(args.center, '%s*,%s*')
		local x = tonumber(xy[1])
		local y = tonumber(xy[2])
		if x then args.x = x end
		if y then args.y = y end
	end
	if args.dimensions then
		local xy = mw.text.split(args.dimensions, '%s*,%s*')
		local x = tonumber(xy[1])
		local y = tonumber(xy[2])
		if x then args.width = x end
		if y then args.height = y end
	elseif args.size then
		local xy = mw.text.split(args.size, '%s*,%s*')
		local x = tonumber(xy[1])
		local y = tonumber(xy[2])
		if x then args.width = x end
		if y then args.height = y end
	end

	local featureParams = parseFeatureParams(args)

	-- for norpreprocess just return mapframe
	if args.nopreprocess then
		local ret = tostring(genMap(args, featureParams))
		return ret .. addcategories(args)
	elseif yesno(args.maponly) then
		local ret = tostring(genMap(args, featureParams))
		return ret .. addcategories(args)
	end

	local title = args.title
	local width = args.width or 600

	local intmap = genMap(args, featureParams)
	local key = genKey(args, featureParams)

	local class = 'advanced-map'
	if hc(args.group) then
		class = class .. ' ' .. args.group
	end

	-- translate "centre" spelling for align, set alignment, all centered in map namespace
	local nsp = mw.title.getCurrentTitle().namespace
	if nsp ~= 118 and args.align then
		local align = string.lower(args.align)
		if align == 'left' then
			class = class .. ' amap-left'
		elseif align == 'right' then
			class = class .. ' amap-right'
			--elseif align == 'centre' or align == 'center' then
		end
	end

	-- optional drop shadows for pins/imgs
	if args.shadows then
		local shadow = string.lower(args.shadows)
		if shadow == 'dark' then
			class = class .. ' amap-dropdark'
		elseif shadow == 'light' then
			class = class .. ' amap-droplight'
		end
	end

	local keyclass = 'amap-key'
	if args.keycols and tonumber(args.keycols) then
		keyclass = keyclass .. ' amap-' .. tonumber(args.keycols) .. 'col'
	end

	local ret = mw.html.create('div')
	ret:addClass(class)
		:css({ width = width .. 'px' })

	if args.keyonly then
		-- empty
	elseif title == nil then
		-- empty
	else
		if string.find(title, '%[%[') then
			ret:tag('div'):addClass('amap-title')
				:wikitext(title)
				:done()
		else
			ret:tag('div'):addClass('amap-title')
				:tag('span'):wikitext(title):done()
				:done()
		end
	end
	if key ~= '' and args.keyonly then
		ret:tag('div')
			:addClass(keyclass)
			:wikitext(key)
			:done()
	elseif args.nokey then
		ret:tag('div')
			:addClass('amap-map')
			:wikitext(intmap)
			:done()
	else
		ret:tag('div')
			:addClass('amap-map')
			:wikitext(intmap)
			:done()
		if key ~= '' then
			ret:tag('div')
				:addClass(keyclass)
				:wikitext(key)
				:done()
		end
	end

	-- Add navigaion buttons to top left like navbox
	if args.name then
		ret:node(navBar(args.name))
	end

	return tostring(ret) .. addcategories(args)
end

local function genMapFeature(featCol, feature, opts)
	local typ = feature['type']
	if hc(typ) then
		typ = string.lower(typ or '')
	else
		typ = 'dot'
	end

	local coords = parseCoords(feature['coords'])

	local ftargs = {}

	-- Complex coords
	local complcoords
	if typ == 'complex-polygon' or typ == 'complpoly' or typ == 'lines' then
		complcoords = parseComplCoords(feature['coords'])
	end

	-- fill in default fill colour
	if typ == 'square' or typ == 'sq' or
		typ == 'dot' then
		assignFillColourIfEmpty(feature)
	end

	-- Get styles for map feature group
	for _, s in ipairs(styles) do
		if feature[s] and hc(feature[s]) then
			ftargs[s] = feature[s]
		end
	end

	if ftargs.radius then
		ftargs.r = ftargs.radius
	end

	for _, s in ipairs(pairstyles) do
		if feature[s] and hc(feature[s]) then
			local xy = mw.text.split(feature[s], '%s*,%s*')
			local x = tonumber(xy[1])
			local y = tonumber(xy[2])
			if x and y then
				ftargs[s] = { x, y }
			end
		end
	end

	-- Jagex coords indicates coordinates are a tille and feature should be centered
	-- Used for things such as monster or item spawns, or object locatioons copied from
	-- their pages or where dev coordinates were retrieved in game.
	if (feature['jagex'] and hc(feature['jagex'])) or
		(feature['jagexCoords'] and hc(feature['jagexCoords'])) then
		ftargs.jagexCoords = true
	end

	if typ == 'complex-polygon' or typ == 'complpoly' then
		if #complcoords > 1 then
			table.insert(featCol, maps.featComplPolygon(ftargs, opts, complcoords))
		else
			ftargs.pins = complcoords[1]
			table.insert(featCol, maps.featPolygon(ftargs, opts))
		end
	elseif typ == 'lines' then
		for _, v in ipairs(complcoords) do
			local lcoords = {}
			for _, k in ipairs(v) do
				table.insert(lcoords, { x = k[1], y = k[2] })
			end
			ftargs.pins = lcoords
			table.insert(featCol, maps.featLine(ftargs, opts))
		end
	elseif typ == 'polygon' then
		ftargs.pins = coords
		table.insert(featCol, maps.featPolygon(ftargs, opts))
	elseif typ == 'line' or typ == 'linestring' then
		ftargs.pins = coords
		table.insert(featCol, maps.featLine(ftargs, opts))
	elseif typ == 'circle' or
		typ == 'circlemarker' or
		typ == 'text' or
		typ == 'pin' or
		typ == 'icon' or
		typ == 'square' or typ == 'sq' or
		typ == 'dot' then
		-- Single point features
		pointFeats(featCol, ftargs, opts, coords, typ)
	else
		error('The type "' .. typ .. '" of the map feature is not recognised.')
	end
end

function genMap(args, featureParams)
	-- Shared options
	local opts = {
		mapID = args.mapID or 28, -- RuneScape Surface
		plane = tonumber(args.plane) or 0,
	}

	local featCol = {}
	-- Look for up to MAX_ARG_COUNT feature groups, defined in order
	for _, feature in pairs(featureParams) do
		if hc(feature['coords']) then
			genMapFeature(featCol, feature, opts)
		elseif hc(feature['key']) then
			-- noop
		end
	end

	local ftjson = {
		type = 'FeatureCollection',
		features = featCol
	}
	local mapopts = {
		x = args.x,
		y = args.y,
		width = args.width or 600,
		height = args.height or 600,
		mapID = opts.mapID,
		plane = opts.plane,
		zoom = args.zoom or 2,
		align = 'center',
		plainTiles = 'true'
	}
	if hc(args.group) then
		mapopts.group = args.group
	end
	if yesno(args.maponly) and args.align then
		mapopts.align = args.align
	end
	-- translate "centre" spelling for align
	if mapopts.align == 'centre' then
		mapopts.align = 'center'
	end
	if hc(args.caption) then
		mapopts.text = args.caption
	else
		mapopts.frameless = ''
	end
	if hc(args.showicons) then
		mapopts.plainTiles = 'false'
	end
	if hc(args.mapVersion) then
		mapopts.mapVersion = args.mapVersion
	end

	-- mw.logObject(ftjson)

	-- Create map element
	local mapelem = mw.html.create('mapframe')
	mapelem:attr(mapopts):newline():wikitext(toJSON(ftjson)):newline()

	if args.nopreprocess then
		return tostring(mapelem)
	end
	return mw.getCurrentFrame():preprocess(tostring(mapelem))
end

return p