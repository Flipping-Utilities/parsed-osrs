-- <nowiki>
-- Module:Item location map
--
-- Draws every known location of an item on one interactive map:
--   spawns - pins on the item's own page ({{ItemSpawnLine}})
--   drops  - monsters in Bucket:Dropsline
--   shops  - shops in Bucket:Storeline
-- All pins are read from Bucket:Coordinates.

local maps = require('Module:Map')
local yesno = require('Module:Yesno')
local hc = require('Module:Paramtest').has_content

local p = {}

local SURFACE = 28
local WORLD = -1          -- "Default" basemap: the whole game world at game coordinates
local BATCH = 40          -- page names per coordinates query
local MAX_ROWS = 5000     -- Bucket's query limit
local ZONES = 'Module:Map coordinates/transform-data.json'
local DEFAULT_GROUP = 'itemlocations'

-- kind -> pin colour, legend label
local KINDS = {
	spawn = { icon = 'greenPin', file = 'Pin green.svg', label = 'Item spawns' },
	drop  = { icon = 'redPin',   file = 'Pin red.svg',   label = 'Drop sources' },
	shop  = { icon = 'bluePin',  file = 'Pin blue.svg',  label = 'Shops' },
}
local LEGEND_ORDER = { 'spawn', 'drop', 'shop' }

local NOT_LOCATIONS = { ['teleport destination'] = true, ['transport destination'] = true }

-- Entrances of other maps are the surface pins of the pages named here, or of
-- the page named like the map when it is not listed. Composite maps list one
-- page per dungeon. A map with no such pin is reported in ENTRANCE_CATEGORY.
local ENTRANCE_PAGES = {
	[0]   = { 'Ardougne Sewers' },                           -- Ardougne Underground
	[13]  = { 'Brimhaven Dungeon' },                         -- Karamja Underground
	[21]  = { 'Keldagrim entrance tunnel' },                 -- Keldagrim
	[26]  = { 'Lumbridge Swamp Caves' },                     -- Dorgesh-Kaan, reached through the caves
	[607] = { 'Lumbridge Swamp Caves' },                     -- Goblin Mines (Dorgesh-Kaan mine)
	[31]  = { 'Lumbridge Swamp Caves', 'H.A.M. Hideout' },   -- Misthalin Underground
	[283] = { 'H.A.M. Hideout' },                            -- H.A.M. store rooms
	[545] = { 'Observatory Dungeon' },                       -- Observatory
}
local ENTRANCE_ICON = 'dungeon entrance'
local MAX_ENTRANCES = 6   -- markers per entrance page (some pages pin every NPC inside)
local ENTRANCE_CATEGORY = '[[Category:Item location maps with unknown entrances]]'

-------------------------------------------------------------------------------
-- Bucket queries
-------------------------------------------------------------------------------

-- Pins of the given pages: page -> { {x=, y=, plane=, mapid=}, ... }
local function fetchPins(pages)
	local byPage = {}
	for i = 1, #pages, BATCH do
		local conds = {}
		for j = i, math.min(i + BATCH - 1, #pages) do
			table.insert(conds, { 'page_name', pages[j] })
		end
		local rows = bucket('coordinates')
			.select('page_name', 'type', 'x', 'y', 'plane', 'mapid')
			.where(bucket.Or(unpack(conds)))
			.limit(MAX_ROWS)
			.run()
		for _, r in ipairs(rows) do
			-- x and y are repeated fields, so they arrive as arrays
			local x = tonumber(type(r.x) == 'table' and r.x[1] or r.x)
			local y = tonumber(type(r.y) == 'table' and r.y[1] or r.y)
			if x and y and not NOT_LOCATIONS[r.type] then
				byPage[r.page_name] = byPage[r.page_name] or {}
				table.insert(byPage[r.page_name], {
					x = x, y = y,
					plane = tonumber(r.plane) or 0,
					mapid = tonumber(r.mapid) or SURFACE,
				})
			end
		end
	end
	return byPage
end

-- Monsters dropping the item: set of page names
local function fetchDrops(item, includeRdt)
	local q = bucket('dropsline')
		.select('page_name')
		.where('item_name', item)
		.limit(MAX_ROWS)
	if not includeRdt then
		q.where('rare_drop_table', false)
	end
	local drops = {}
	for _, r in ipairs(q.run()) do
		drops[r.page_name] = true
	end
	return drops
end

-- Shops selling the item: page -> owner wikitext (used when the shop page has no pin)
local function fetchShops(item, includeHistorical)
	local rows = bucket('storeline')
		.select('page_name', 'is_historical', 'infobox_shop.owner')
		.join('infobox_shop', 'storeline.page_name_sub', 'infobox_shop.page_name_sub')
		.where('sold_item', item)
		.limit(MAX_ROWS)
		.run()
	local shops = {}
	for _, r in ipairs(rows) do
		if includeHistorical or r.is_historical ~= true then
			shops[r.page_name] = r['infobox_shop.owner'] or ''
		end
	end
	return shops
end

-- First `limit` page names, alphabetically (0 = all)
local function sortedPages(t, limit)
	local pages = {}
	for page in pairs(t) do
		table.insert(pages, page)
	end
	table.sort(pages)
	while limit > 0 and #pages > limit do
		table.remove(pages)
	end
	return pages
end

-------------------------------------------------------------------------------
-- Pins
-------------------------------------------------------------------------------

-- Gather every pin: { x, y, plane, mapid, map, kind, title }
-- `map` is the map the pin was recorded on; `mapid` the map it is drawn on.
-- The popup title is the item name for spawns and a link to the source otherwise.
local function gatherPins(item, opts)
	local pins = {}
	local function add(kind, page, pagePins)
		local title = kind == 'spawn' and page or ('[[' .. page .. ']]')
		for i, pin in ipairs(pagePins) do
			if opts.maxpins > 0 and i > opts.maxpins then
				break
			end
			table.insert(pins, {
				x = pin.x, y = pin.y, plane = pin.plane,
				mapid = pin.mapid, map = pin.mapid, kind = kind, title = title,
			})
		end
	end

	if opts.kinds.spawn then
		add('spawn', item, fetchPins({ item })[item] or {})
	end

	if opts.kinds.drop then
		local pages = sortedPages(fetchDrops(item, opts.rdt), opts.limit)
		local pagePins = fetchPins(pages)
		for _, page in ipairs(pages) do
			add('drop', page, pagePins[page] or {})
		end
	end

	if opts.kinds.shop then
		local shops = fetchShops(item, opts.historical)
		local pages = sortedPages(shops, opts.limit)
		local pagePins = fetchPins(pages)
		-- Shops without a pin of their own use their owner's pins
		local owners, needOwner = {}, {}
		for _, page in ipairs(pages) do
			local owner = shops[page]:match('%[%[([^%]|#]+)')
			if not pagePins[page] and owner then
				needOwner[page] = owner
				table.insert(owners, owner)
			end
		end
		local ownerPins = #owners > 0 and fetchPins(owners) or {}
		for _, page in ipairs(pages) do
			add('shop', page, pagePins[page] or ownerPins[needOwner[page]] or {})
		end
	end

	return pins
end

-------------------------------------------------------------------------------
-- Maps and the world map
-------------------------------------------------------------------------------

-- Map ID -> zone entry of the transform data (name, subareas)
local zones
local function zone(mapid)
	if not zones then
		zones = {}
		local ok, data = pcall(mw.loadJsonData, ZONES)
		for _, z in ipairs(ok and data or {}) do
			zones[tonumber(z.id)] = z
		end
	end
	return zones[mapid]
end

local function mapName(mapid)
	if mapid == SURFACE then
		return 'Surface'
	elseif mapid == WORLD then
		return 'World'
	end
	local z = zone(mapid)
	return z and z.name or ('Map ' .. mapid)
end

-- The same pin on the world map (ID -1), which draws the whole game world at
-- game coordinates. Pins are stored in the coordinates of their own map. For
-- maps that rearrange the game world (Keldagrim, the Strongholds, the
-- surface's Arc and Anachronia, ...) the transform data lists, per rectangle
-- of the map (dst), where it comes from in the game (src, with its plane);
-- shifting by src - dst gives the game coordinates. Most dungeon maps use game
-- coordinates already, and a pin in no rectangle is left where it is.
local function toWorld(pin)
	local out = {
		x = pin.x, y = pin.y, plane = pin.plane,
		mapid = WORLD, map = pin.map, kind = pin.kind, title = pin.title,
	}
	if pin.mapid == WORLD then
		return out
	end
	local z = zone(pin.mapid)
	local best
	for _, area in ipairs(z and z.subarea or {}) do
		local d = area.dst
		if pin.x >= d.x1 and pin.x <= d.x2 and pin.y >= d.y1 and pin.y <= d.y2 then
			if tonumber(area.plane) == pin.plane then
				best = area
				break
			end
			best = best or area
		end
	end
	if best then
		local dx, dy = best.src.x1 - best.dst.x1, best.src.y1 - best.dst.y1
		out.x, out.y = pin.x + dx, pin.y + dy
		if dx ~= 0 or dy ~= 0 then
			-- rearranged maps lay their floors out side by side on one plane
			out.plane = tonumber(best.plane) or pin.plane
		end
	end
	return out
end

-------------------------------------------------------------------------------
-- Rendering
-------------------------------------------------------------------------------

-- Bounding box and most common plane of a set of pins
local function extent(pins)
	local minx, maxx, miny, maxy = math.huge, -math.huge, math.huge, -math.huge
	local planes = {}
	for _, pin in ipairs(pins) do
		minx, maxx = math.min(minx, pin.x), math.max(maxx, pin.x)
		miny, maxy = math.min(miny, pin.y), math.max(maxy, pin.y)
		planes[pin.plane] = (planes[pin.plane] or 0) + 1
	end
	local plane, best = 0, 0
	for pl, n in pairs(planes) do
		if n > best then
			plane, best = pl, n
		end
	end
	return {
		x = math.floor((minx + maxx) / 2), y = math.floor((miny + maxy) / 2),
		x_range = maxx - minx + 1, y_range = maxy - miny + 1, plane = plane,
	}
end

-- The main element: every pin as GeoJSON in one Kartographer group, on map
-- `mapid`, with the initial view fitted to `focus` (the pins shown first).
-- The map viewer only shows the pins whose mapID and plane match the map.
-- Plain tiles (no in-game icons) keep the pins readable, as on Map: pages.
local function mainMap(pins, mapid, focus, args, etype, group, extra)
	local features = {}
	for _, pin in ipairs(pins) do
		-- desc = '' keeps featPin from filling the description with the coordinates
		table.insert(features, maps.featPin({ jagexCoords = true }, { mapID = pin.mapid, plane = pin.plane },
			{ x = pin.x, y = pin.y, title = pin.title, desc = '', icon = KINDS[pin.kind].icon }))
	end
	for _, feature in ipairs(extra or {}) do
		table.insert(features, feature)
	end
	local margs = extent(focus)
	margs.mapID, margs.etype, margs.group, margs.plainTiles = mapid, etype, group, 'true'
	margs.plane = tonumber(args.plane) or margs.plane
	margs.width, margs.height, margs.zoom, margs.caption = args.width, args.height, args.zoom, args.caption
	margs.text = args.text or ('Show ' .. #pins .. ' locations')
	return maps.createFeatMap(margs, { type = 'FeatureCollection', features = features })
end

-- An empty maplink that shows the group, centred on the given pins. `raw`
-- returns the tag unexpanded, for wikitext that another tag parses later
-- (a pin description).
local function mapLink(pins, mapid, text, group, raw)
	local margs = extent(pins)
	margs.mapID, margs.etype, margs.text, margs.show, margs.plainTiles = mapid, 'maplink', text, group, 'true'
	margs.nopreprocess = true
	local tag = tostring(maps.createFeatMap(margs, {})):gsub('>%s*%[%]%s*</', '></')
	if raw then
		return tag
	end
	return mw.getCurrentFrame():preprocess(tag)
end

-- Entrance markers for the maps in `order` other than `primary`: one per
-- surface pin of the map's entrance page(s), drawn on `frameMap`. The popup
-- names the place, counts the locations inside and holds a map link that opens
-- the group at those pins. Returns the features and the maps with no entrance.
local function entranceMarkers(order, primary, byMap, frameMap, group)
	local pages, pagesByMap = {}, {}
	for _, mapid in ipairs(order) do
		if mapid ~= primary and mapid ~= SURFACE and mapid ~= WORLD and zone(mapid) then
			pagesByMap[mapid] = ENTRANCE_PAGES[mapid] or { mapName(mapid) }
			for _, page in ipairs(pagesByMap[mapid]) do
				table.insert(pages, page)
			end
		end
	end
	local features, missing = {}, {}
	if #pages == 0 then
		return features, missing
	end
	local pagePins = fetchPins(pages)
	for _, mapid in ipairs(order) do
		local found = false
		for _, page in ipairs(pagesByMap[mapid] or {}) do
			local drawn, seen = 0, {}
			for _, pin in ipairs(pagePins[page] or {}) do
				local key = pin.x .. ',' .. pin.y .. ',' .. pin.plane
				if pin.mapid == SURFACE and drawn < MAX_ENTRANCES and not seen[key] then
					found, drawn, seen[key] = true, drawn + 1, true
					local marker = { x = pin.x, y = pin.y, plane = pin.plane, mapid = SURFACE, map = SURFACE }
					if frameMap == WORLD then
						marker = toWorld(marker)
					end
					local n = #byMap[mapid]
					local title = page
					if page ~= mapName(mapid) then
						title = page .. ' (' .. mapName(mapid) .. ')'
					end
					-- the link opens the dungeon's own map, or the world map in world mode
					local target = frameMap == WORLD and WORLD or mapid
					local desc = n .. (n == 1 and ' location' or ' locations') .. ' inside. '
						.. mapLink(byMap[mapid], target, 'Show on the map', group, true)
						.. ' &bull; [[' .. page .. ']]'
					table.insert(features, maps.featIcon({ icon = ENTRANCE_ICON, jagexCoords = true },
						{ mapID = frameMap, plane = marker.plane },
						{ x = marker.x, y = marker.y, title = title, desc = desc }))
				end
			end
		end
		if pagesByMap[mapid] and not found then
			table.insert(missing, mapid)
		end
	end
	return features, missing
end

local function legend(pins)
	local present = {}
	for _, pin in ipairs(pins) do
		present[pin.kind] = true
	end
	local parts = {}
	for _, kind in ipairs(LEGEND_ORDER) do
		if present[kind] then
			table.insert(parts, ('[[File:%s|12px|link=]] %s'):format(KINDS[kind].file, KINDS[kind].label))
		end
	end
	return table.concat(parts, ' &bull; ')
end

-------------------------------------------------------------------------------
-- Entry point
-------------------------------------------------------------------------------

-- Parameters come from the template ({{Item location map|...}}) or, when the
-- form calculator invokes the module directly, from the #invoke itself.
function p.main(frame)
	local args = {}
	for _, source in ipairs({ frame.args, frame:getParent().args }) do
		for k, v in pairs(source) do
			if hc(v) then
				args[k] = v
			end
		end
	end
	return p._main(args)
end

function p._main(args)
	local item = mw.text.trim(args.item or args[1] or '')
	if item == '' then
		item = mw.title.getCurrentTitle().text
	end

	-- Which source types: |sources=spawns,drops,shops, or one yes/no flag per
	-- type (|spawns= |drops= |shops=), which is what the calculator's checkboxes send.
	local kinds = {}
	if args.spawns or args.drops or args.shops then
		for _, kind in ipairs(LEGEND_ORDER) do
			kinds[kind] = yesno(args[kind .. 's'], false)
		end
	else
		for word in mw.text.gsplit(args.sources or 'spawns,drops,shops', '%s*,%s*') do
			kinds[word:lower():gsub('s$', '')] = true
		end
	end
	local pins = gatherPins(item, {
		kinds = kinds,
		rdt = yesno(args.rdt, false),
		historical = yesno(args.historical, false),
		limit = tonumber(args.limit) or 100,   -- monsters / shops looked up (alphabetically), each; 0 = all
		maxpins = tonumber(args.maxpins) or 50, -- pins drawn per source; 0 = all
	})

	if #pins == 0 then
		return "''No map locations are known for [[" .. item .. "]].''[[Category:Empty item location maps]]"
	end

	-- |world=yes (or |mapid=-1): everything on the world map instead of one
	-- map per dungeon
	local world = yesno(args.world, false) or tonumber(args.mapid) == WORLD
	if world then
		for i, pin in ipairs(pins) do
			pins[i] = toWorld(pin)
		end
	end

	-- Pins per recorded map with the surface first when it has any
	local byMap, order = {}, {}
	for _, pin in ipairs(pins) do
		if not byMap[pin.map] then
			byMap[pin.map] = {}
			table.insert(order, pin.map)
		end
		table.insert(byMap[pin.map], pin)
	end
	table.sort(order, function(a, b)
		if (a == SURFACE) ~= (b == SURFACE) then
			return a == SURFACE
		end
		return #byMap[a] > #byMap[b]
	end)
	local primary = tonumber(args.mapid)
	if not byMap[primary] then
		primary = order[1]
	end

	local group = hc(args.group) and args.group or DEFAULT_GROUP
	local etype = (args.type or ''):lower() == 'maplink' and 'maplink' or 'mapframe'
	local frameMap = world and WORLD or primary

	-- Entrance markers for the other maps, on the surface by default; on the
	-- world map the dungeons are drawn themselves, so only on request
	local entrances, missing = {}, {}
	if (frameMap == SURFACE or frameMap == WORLD) and yesno(args.entrances, not world) then
		entrances, missing = entranceMarkers(order, primary, byMap, frameMap, group)
	end

	local out = { tostring(mainMap(pins, frameMap, byMap[primary], args, etype, group, entrances)) }
	if #missing > 0 then
		table.insert(out, ENTRANCE_CATEGORY)
	end
	if etype == 'mapframe' then
		table.insert(out, '<div class="item-location-map-legend" style="text-align:center">' .. legend(pins) .. '</div>')
	end
	local links = {}
	for _, mapid in ipairs(order) do
		if mapid ~= primary then
			table.insert(links, mapLink(byMap[mapid], world and WORLD or mapid, mapName(mapid), group))
		end
	end
	if #links > 0 then
		local label = world and 'Jump to' or 'Other maps'
		table.insert(out, "<div class=\"item-location-map-othermaps\" style=\"text-align:center\">'''" .. label .. "''': " .. table.concat(links, ' &bull; ') .. '</div>')
	end
	return '<div class="item-location-map">' .. table.concat(out) .. '</div>'
end

return p
-- </nowiki>