-- <nowiki>
local maps = require('Module:Map')
local hc = require('Module:Paramtest').has_content
local default_to = require('Module:Paramtest').default_to
local onMain = require('Module:Mainonly').on_main

local p = {}

-- Returns a mutable copy of args
local function copyArgs(args)
	local t = {}
	for k, v in pairs(args) do
		t[k] = v
	end
	return t
end

-- Putting this in a separate function to centralize documentation of it
local function jagex_coords(exact)
	-- Assume coordinates are jagex coordinates
	-- (ie the game tile) so center pin in squares.
	-- Allow override using "exact" param
	-- jagexCoords is true by default, but if args.exact is specified, it's false
	return not hc(exact)
end

function p._npcmap(args)
	--[[ Each unnamed arg is 1 pin in format:
		x,y
		or
		x:#,y:#,version:#,npcid:#,notes:#
	]]
	args = maps.parseArgs(args, 'npc')

	-- Min square size (default to 10x10, and floor to 3x3)
	args.squareX = math.max(tonumber(args.squareX) or 10, 3)
	args.squareY = math.max(tonumber(args.squareY) or 10, 3)

	-- Default green pins
	args.icon = default_to(args.icon, 'greenPin')
	-- Pin group
	args.group = default_to(args.group, 'npcspawns')
	args.fill = default_to(args.fill, '#00ffff')
	args.stroke = default_to(args.stroke, '#00ffff')

	args.jagexCoords = jagex_coords(args.exact)

	-- Map type. if args.type, that, else if args.mtype, that, else square. then lowercase.
	local mtype = (
		(hc(args.type) and args.type)
		or (hc(args.mtype) and args.mtype)
		or 'square'
	):lower()

	if onMain() and not args.noBucket then
		for _, pin in ipairs(args.pins) do
			local bucket_data = {
				type = 'npc',
				title = pin.desc,
				x = pin.x,
				y = pin.y,
				plane = pin.plane or args.plane or 0,
				mapid = pin.mapID or args.mapID or 28,
			}
			bucket('coordinates').put(bucket_data)
		end
	end

	args.features = 'pins'

	if mtype == 'maplink' then
		-- Link to map with pins
		args.etype = 'maplink'
		args.text = default_to(args.text, 'Spawn location')

		return maps.createMap(args)
	elseif mtype == 'pin' or mtype == 'pins' then
		-- Map with pins
		args.etype = 'mapframe'

		return maps.createMap(args)
	else
		-- Standard map (square with link to all)
		if args.pin_count > 1 then
			args.text = default_to(args.text, 'show exact spawns')

			local capt = default_to(args.caption, args.pin_count .. ' spawns')

			args.etype = 'maplink'
			local link = tostring(maps.createMap(args))
			capt = capt .. link

			args.etype = 'mapframe'
			-- Why clear out caption?
			args.caption = ''
			args.features = 'square'
			args.group = args.group .. 'area'
			local map = tostring(maps.createMap(args))

			local classes = 'mw-kartographer-container thumb'
			-- Default to center append
			args.align = default_to(args.align, ''):lower()
			local append =
				(args.align == 'left' or args.align == 'right')
				and ' t' .. args.align
				or ' center'
			classes = classes .. append

			local width = args.width or 300
			local ret = mw.html.create('div')
				:addClass(classes)
				:tag('div')
				:addClass('thumbinner')
				:css('width', width .. 'px')
				:node(map)
				:tag('div')
				:addClass('thumbcaption')
				:node(capt)
				:done()
				:done()
				:done()

			return ret
		end

		args.etype = 'mapframe'
		args.group = args.group .. 'area'
		args.features = mtype or 'pins'

		return maps.createMap(args)
	end
end

function p.npcmap(frame)
	local args = copyArgs(frame:getParent().args)

	return p._npcmap(args)
end

function p._monstermap(args)
	--[[ Each unnamed arg is 1 pin in format:
		x,y
		or
		x:#,y:#,version:#,npcid:#,notes:#
	]]
	args = maps.parseArgs(args, 'npc')

	-- Default red pins
	args.icon = default_to(args.icon, 'redPin')
	-- Pin group
	args.group = default_to(args.group, 'monsterspawns')
	args.align = default_to(args.align, 'center')

	args.jagexCoords = jagex_coords(args.exact)

	args.features = 'pins'
	args.etype =
		(hc(args.type) and args.type:lower() == 'maplink')
		and 'maplink'
		or 'mapframe'

	if onMain() and not args.noBucket then
		for _, pin in ipairs(args.pins) do
			local bucket_data = {
				type = 'monster',
				title = pin.desc,
				x = pin.x,
				y = pin.y,
				plane = pin.plane or args.plane or 0,
				mapid = pin.mapID or args.mapID or 28,
			}
			bucket('coordinates').put(bucket_data)
		end
		--mw.logObject(args, 'monstermap')
	end

	return maps.createMap(args)
end

function p.monstermap(frame)
	local args = copyArgs(frame:getParent().args)

	return p._monstermap(args)
end

function p._objectmap(args)
	--[[ Each unnamed arg is 1 pin in format:
		x,y
		or
		x:#,y:#,version:#,objectid:#,notes:#
	]]
	args = maps.parseArgs(args, 'object')

	-- Default blue pins
	args.icon = default_to(args.icon, 'bluePin')
	-- Pin group
	args.group = default_to(args.group, 'objectspawns')
	args.align = default_to(args.align, 'center')

	args.jagexCoords = jagex_coords(args.exact)

	args.features = 'pins'
	args.etype = 'mapframe'
	if hc(args.type) and string.lower(args.type) == 'maplink' then
		args.etype = 'maplink'
	end

	if onMain() and not args.noBucket then
		for i, pin in ipairs(args.pins) do
			local bucket_data = {
				type = 'object',
				title = pin.desc,
				x = pin.x,
				y = pin.y,
				plane = pin.plane or args.plane or 0,
				mapid = pin.mapID or args.mapID or 28,
			}
			bucket('coordinates').put(bucket_data)
		end
		--mw.logObject(args, 'objectmap')
	end

	return maps.createMap(args)
end

function p.objectmap(frame)
	local args = copyArgs(frame:getParent().args)

	return p._objectmap(args)
end

function p._locationmap(args)
	if hc(args[1]) then
		local arr = mw.text.split(args[1], '%s*,%s*')
		args.x = arr[1]
		args.y = arr[2]
	end

	args.etype = 'mapframe'
	args.features = 'none'

	return maps.blankMap(args)
end

function p.locationmap(frame)
	local args = copyArgs(frame:getParent().args)

	return p._locationmap(args)
end

function p._spawnmaplink(args)
	--[[ Each unnamed arg is 1 pin in format:
		x,y
		or
		x:#,y:#,qty:#,respawn:#,notes:#
	]]
	args = maps.parseArgs(args, 'item')

	-- Default green pins
	args.icon = default_to(args.icon, 'greenPin')
	-- Pin group
	args.group = default_to(args.group, 'spawns')

	args.jagexCoords = jagex_coords(args.exact)

	args.features = 'pins'
	args.etype = 'maplink'

	local out = {
		'<span class="rsw-maplink-spawns">',
		tostring(maps.createMap(args)),
		'</span>'
	}

	if onMain() then
		table.insert(out, "[[Category:Items that have spawns]]")
		if not args.noBucket then
			for i, pin in ipairs(args.pins) do
				local bucket_data = {
					type = 'item spawn',
					title = pin.desc,
					x = pin.x,
					y = pin.y,
					plane = pin.plane or args.plane or 0,
					mapid = pin.mapID or args.mapID or 28,
				}
				bucket('coordinates').put(bucket_data)
			end
			--mw.logObject(args, 'itemspawnmap')
		end
	end

	return table.concat(out, '')
end

function p.spawnmaplink(frame)
	local args = copyArgs(frame:getParent().args)

	return p._spawnmaplink(args)
end

function p.teleportmap(frame)
	local args = copyArgs(frame:getParent().args)

	if hc(args.combine) then
		return p._teleportcombinedmap(args)
	end

	return p._teleportmap(args)
end

function p._teleportmap(args)
	--[[ Outputs a series of individual maps in the style of a multimap
		Ignores most formatting in favour if simplicity and consistency
		Each map is specified by x#, y#, name#, title#, mapID#, plane#
		for # from 1 to 99
		Also stores coordinates in Bucket:Coordinates
		Displays each separate set of coordinates on its own map
	]]

	local ret = mw.html.create('div')
		:css('display', 'flex')
		:css('flex-flow', 'row wrap')
		:css('justify-content', 'center')
		:css('align-items', 'flex-end')
		:css('margin', '-10px')

	local add_to_bucket = onMain() and not args.noBucket

	for i = 1, 99 do
		--unindexed args can be counted as index 1
		local name = (i == 1 and args.name) or args['name' .. i] or ''
		local title = (i == 1 and args.title) or args['title' .. i] or name
		local mapID = (i == 1 and args.mapID) or args['mapID' .. i] or 28
		local plane = (i == 1 and args.plane) or args['plane' .. i] or 0

		local coords = (i == 1 and (args.coords or args.coordinates or args[1])) or args['coords' .. i] or
			args['coordinates' .. i]
		local x, y

		if type(coords) == 'string' then
			local parts = mw.text.split(coords, ',')
			x = tonumber(parts[1])
			y = tonumber(parts[2])
		end

		if x and y then
			local map_args = {
				x = x,
				y = y,
				plane = plane,
				mapID = mapID,
				mtype = 'square',
				r = 2.5,
				jagexcoords = 't'
			}

			local map = tostring(p._maptemp(map_args, {}))
			ret:tag('div')
				:css('min-width', '300px')
				:css('margin', '10px')
				:tag('div')
				:css('text-align', 'center')
				:css('font-weight', 'bold')
				:css('max-width', '300px')
				:wikitext(title)
				:done()
				:wikitext(map)
				:done()

			if add_to_bucket then
				local coord_type = hc(args.transport) and 'transport destination' or 'teleport destination'

				local bucket_data = {
					type = coord_type,
					title = title,
					x = x,
					y = y,
					plane = plane,
					mapid = mapID,
				}
				mw.bucket("coordinates").sub(name).put(bucket_data)
			end
		end
	end

	ret:done()

	if not args.noMap then
		return ret
	end
end

function p._teleportcombinedmap(args)
	--[[ Outputs a series of individual maps in the style of a multimap
		Ignores most formatting in favour if simplicity and consistency
		Each map is specified by x#, y#, name#, title#, mapID#, plane#
		for # from 1 to 99
		Also stores coordinates in Bucket:Coordinates
		Combines multiple specified coordinates onto one map if they share a mapID
	]]

	local flatten = hc(args.flatten)
	local add_to_bucket = onMain() and not args.noBucket
	local map_args = {}
	for i = 1, 99 do
		--unindexed args can be counted as index 1
		local name = (i == 1 and args.name) or args['name' .. i] or ''
		local title = (i == 1 and args.title) or args['title' .. i] or name
		local mapID = (i == 1 and args.mapID) or args['mapID' .. i] or 28
		local plane = (i == 1 and args.plane) or args['plane' .. i] or 0

		local coords = (i == 1 and (args.coords or args.coordinates or args[1])) or args['coords' .. i] or
			args['coordinates' .. i]
		local x, y
		if type(coords) == 'string' then
			local parts = mw.text.split(coords, ',')
			x = tonumber(parts[1])
			y = tonumber(parts[2])
		end

		if x and y then
			if add_to_bucket then
				local coord_type = hc(args.transport) and 'transport destination' or 'teleport destination'

				local bucket_data = {
					type = coord_type,
					title = title,
					x = x,
					y = y,
					plane = plane,
					mapid = mapID,
				}
				mw.bucket("coordinates").sub(name).put(bucket_data)
			end

			local map_index
			for k, v in ipairs(map_args) do
				if v.mapID == mapID and ((flatten and mapID == 28) or v.plane == plane) then
					map_index = k
				end
			end
			if map_index == nil then
				local map_args_settings = {
					plane = plane,
					mapID = mapID,
					mtype = 'pin',
					jagexcoords = 't',
				}
				if flatten and mapID == 28 then
					map_args_settings.plane = 0
				end
				table.insert(map_args, map_args_settings)
				map_index = #map_args
			end
			map_args[map_index][#map_args[map_index] + 1] = ('x:%s,y:%s,title:%s'):format(x, y, title)
		end
	end

	if not args.noMap then
		local ret = mw.html.create('div')
			:css('display', 'flex')
			:css('flex-flow', 'row wrap')
			:css('justify-content', 'center')
			:css('align-items', 'flex-end')
			:css('margin', '-10px')

		for k, v in ipairs(map_args) do
			local title
			if #v == 1 then
				v.mtype = 'square'
				v.r = 2.5
				title = mw.text.split(v[1], 'title:')
				title = title[2]
			end
			local map = tostring(p._maptemp(v, {}))
			ret:tag('div')
				:css('min-width', '300px')
				:css('margin', '10px')
				:tag('div')
				:css('text-align', 'center')
				:css('font-weight', 'bold')
				:css('max-width', '300px')
				:wikitext(title)
				:done()
				:wikitext(map)
				:done()
		end

		ret:done()
		return ret
	end
end

function p._maptemp(args, templateArgs)
	--[[ Each unnamed arg is 1 pin in format:
		x,y
		or
		x:#,y:#,desc:#
	]]
	args = maps.parseArgs(args, 'generic')

	-- Default cyan pins
	args.icon = default_to(args.icon, 'cyanPin')

	if hc(args.iconSize) then
		if string.find(args.iconSize, ',') then
			local iSize = mw.text.split(args.iconSize, '%s*,%s*')
			args.iconSize = {
				tonumber(iSize[1]) or 25,
				tonumber(iSize[2]) or 25
			}
		else
			args.iconSize = {
				tonumber(args.iconSize) or 25,
				tonumber(args.iconSize) or 25
			}
		end
	end

	if hc(args.iconAnchor) then
		if string.find(args.iconAnchor, ',') then
			local iAnch = mw.text.split(args.iconAnchor, '%s*,%s*')
			args.iconAnchor = {
				tonumber(iAnch[1]) or 0,
				tonumber(iAnch[2]) or 0
			}
		else
			args.iconAnchor = {
				tonumber(args.iconAnchor) or 0,
				tonumber(args.iconAnchor) or 0
			}
		end
	end

	if hc(args.popupAnchor) then
		if string.find(args.popupAnchor, ',') then
			local pAnch = mw.text.split(args.popupAnchor, '%s*,%s*')
			args.popupAnchor = {
				tonumber(pAnch[1]) or 0,
				tonumber(pAnch[2]) or 0
			}
		else
			args.popupAnchor = {
				tonumber(args.popupAnchor) or 0,
				tonumber(args.popupAnchor) or 0
			}
		end
	end

	args.features =
		(hc(args.mtype) and args.mtype:lower())
		or (hc(templateArgs.mtype) and templateArgs.mtype:lower())
		or args.features
		or 'none'

	if hc(args.jagexCoords) or hc(args.jagexcoords) then
		args.jagexCoords = true
	end

	args.etype =
		(hc(args.type) and args.type:lower())
		or (hc(templateArgs.type) and templateArgs.type:lower())
		or 'mapframe'

	if onMain() and not args.noBucket then
		for _, pin in ipairs(args.pins) do
			local bucket_data = {
				type = 'generic',
				title = pin.desc,
				x = pin.x,
				y = pin.y,
				plane = pin.plane or args.plane or 0,
				mapid = pin.mapID or args.mapID or 28,
			}
			bucket('coordinates').put(bucket_data)
		end
		--mw.logObject(args, 'maptemp')
	end

	return maps.createMap(args)
end

function p.maptemp(frame)
	local args = copyArgs(frame:getParent().args)
	local templateArgs = frame.args

	return p._maptemp(args, templateArgs)
end

return p