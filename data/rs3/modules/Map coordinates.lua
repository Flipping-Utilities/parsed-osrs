-- <nowiki>
local p = {}

local function transform_base_map(transformed_coords, transform_target, z, x, y)
	local target_plane = transform_target.origin.plane
	if target_plane > 0 then
		mw.log('Found transformed plane to: ' .. target_plane);
	end

	for _, area in ipairs(transform_target.subarea) do
		local src = area.src
		local dst = area.dst
		if x >= src.x1 and x <= src.x2 and
			y >= src.y1 and y <= src.y2 then
			local xt = x - src.x1 + dst.x1;
			local yt = y - src.y1 + dst.y1;
			local zt = math.max(z - target_plane + (area.plane - target_plane), 0)

			table.insert(transformed_coords, { mapId = transform_target.id, name = transform_target.name, internal_name = transform_target.internal_name, z = zt, x = xt, y = yt })
		end
	end
end

local transforms
-- Transfor the original coordinates to submap
local function found_and_transform(z, x, y)
	if transforms == nil then
		transforms = mw.loadJsonData("Module:Map_coordinates/transform-data.json")
	end

	local possible_zones = {}
	for _, zone in ipairs(transforms) do
		for _, area in ipairs(zone.subarea) do
			local src = area.src
			if x >= src.x1 and x <= src.x2 and
				y >= src.y1 and y <= src.y2 then
				table.insert(possible_zones, zone)
				break
			end
		end
	end

	if #possible_zones == 0 then
		mw.log('Found none is possible, so fallback to map ID -1.');
		return { { mapId = -1, z = z, x = x, y = y } }
	end

	local found_zone_ids = {}
	for _, zone in ipairs(possible_zones) do
		table.insert(found_zone_ids, zone.id)
	end
	local found_zone_str = table.concat(found_zone_ids, ", ")

	local found_zone_length = #possible_zones;
	if found_zone_length > 1 then
		mw.log('Found multiple possible zones: ' .. found_zone_str);
	else
		mw.log('Found one possible zone: ' .. found_zone_str);
	end

	local transformed_coords = {}
	for _, transform_target in ipairs(possible_zones) do
		transform_base_map(transformed_coords, transform_target, z, x, y)
	end

	return transformed_coords
end

local function to_number(str, default)
	if default == nil then
		default = 0
	end
	return tonumber(str) or default
end

---
--- For templates, used on Calculator:Coordinates
---
local function fromString(str)
	str = str
		:gsub('%s*%(%s*', '')
		:gsub('%s*%)%s*', '')

	local ret = {}
	local error

	if str:match('%s*,%s*') then
		-- assume it is coordinates
		local args = mw.text.split(str, '%s*,%s*')
		local nargs = #args

		if nargs == 2 then
			-- x, y => 0, x1, y1, x2, y2
			local x, y = to_number(args[1]), to_number(args[2])
			local subdivided = p.convertToSubdividedCoordinates(0, x, y)
			ret = { subdivided = subdivided, coord = { z = 0, x = x, y = y } }
		elseif nargs == 3 then
			-- z, x, y => z, x1, y1, x2, y2
			local z, x, y = to_number(args[1]), to_number(args[2]), to_number(args[3])
			local subdivided = p.convertToSubdividedCoordinates(z, x, y)
			ret = { subdivided = subdivided, coord = { z = z, x = x, y = y } }
		elseif nargs == 5 then
			-- z, x1, y1, x2, y2 => z, x, y
			local z, x1, y1, x2, y2 = to_number(args[1]), to_number(args[2]), to_number(args[3]), to_number(args[4]), to_number(args[5])
			local coord = p.convertToCoordinates(z, x1, y1, x2, y2)
			ret = { subdivided = { z = z, x1 = x1, y1 = y1, x2 = x2, y2 = y2 }, coord = coord }
		else
			error = 'Invalid number of arguments, must be: x,y; z,x,y; or z,x1,y1,x2,y2'
		end
	else
		-- assume it is a single number
		if tonumber(str) then
			local coord = p.convertIntToCoordinates(str)
			local subdivided = p.convertToSubdividedCoordinates(coord.z, coord.x, coord.y)
			ret = { subdivided = subdivided, coord = coord }
		else
			error = 'Invalid number'
		end
	end

	return ret, error
end

local function transform(ret)
	local coord = ret.coord
	local transformed = found_and_transform(coord.z, coord.x, coord.y)

	local output = ""
	for _, t in ipairs(transformed) do
		output = output .. '{| class="wikitable"\n|+ Transformed'
		output = output .. "\n|-\n!Map ID \n| " .. t.mapId
		output = output .. "\n|-\n!Map name \n| " .. (t.name or "[None]")
		output = output .. "\n|-\n!Internal name \n| " .. (t.internal_name or "[None]")
		output = output .. "\n|-\n!Plane \n| " .. t.z
		output = output .. "\n|-\n!Coordinate \n| <span style='user-select:all;'>" .. t.x .. ", " .. t.y .. "</span>"
		output = output .. "\n|-\n!Coordinate alternative format 1 \n| <code style='user-select:all;'>&verbar;x=" .. t.x .. "&verbar;y=" .. t.y .. (t.z > 0 and ("&verbar;plane=" .. t.z) or "") .. "&verbar;mapID=" .. t.mapId .. "</code>"
		output = output .. "\n|-\n!Coordinate alternative format 2 \n| <code style='user-select:all;'>x:" .. t.x .. ",y:" .. t.y .. (t.z > 0 and ("&verbar;plane=" .. t.z) or "") .. "</code>"
		output = output .. "\n|}\n"
	end

	local c = ret.coord
	if c then
		output = output .. '{| class="wikitable"\n|+ Untransformed'
		output = output .. "\n|-\n!Map ID \n| -1"
		output = output .. "\n|-\n!Plane \n| " .. c.z
		output = output .. "\n|-\n!Coordinate \n| <span style='user-select:all;>" .. c.x .. ", " .. c.y .. "</span>"
		output = output .. "\n|-\n!Coordinate alternative format 1 \n| <code style='user-select:all;>&verbar;x=" .. c.x .. "&verbar;y=" .. c.y .. (c.z > 0 and ("&verbar;plane=" .. c.z) or "") .. "&verbar;mapID=-1</code>"
		output = output .. "\n|-\n!Coordinate alternative format 2 \n| <code style='user-select:all;>x:" .. c.x .. ",y:" .. c.y .. "</code>"
		output = output .. "\n|}"
	end

	local s = ret.subdivided
	if s then
		output = output .. "\n;Subdivided coordinate: " .. s.z .. "," .. s.x1 .. "," .. s.y1 .. "," .. s.x2 .. "," .. s.y2
	end

	return output
end

function p.transform(frame)
	local args = frame:getParent().args
	local str = args.text or args[1]

	local ret, error = fromString(str)
	if error ~= nil then
		mw.logObject(ret)
		return 'Invalid Input! ' .. error
	end

	return transform(ret)
end

function p.transcalc(frame)
	local args = frame:getParent().args
	local ret = {
		subdivided = p.convertToSubdividedCoordinates(args.z, args.x, args.y),
		coord = { z = tonumber(args.z) or 0, x = tonumber(args.x) or 0, y = tonumber(args.y) or 0 },
	}

	return transform(ret)
end

function p.convertToSubdividedCoordinates(z, x, y)
	local x1 = math.floor(x / 64)
	local y1 = math.floor(y / 64)
	local x2 = x % 64
	local y2 = y % 64
	return { z = tonumber(z) or 0, x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end

function p.convertToCoordinates(z, i, j, x, y)
	x = i * 64 + x
	y = j * 64 + y
	return { z = tonumber(z) or 0, x = x, y = y }
end

function p.convertIntToCoordinates(int)
	local z = math.floor(int / 268435456)
	local x = math.floor(int / 16384) % 16384
	local y = int % 16384
	return { z = z or 0, x = x, y = y }
end

function p.fromString(frame)
	local args = frame:getParent().args
	local str = args.text or args[1]

	local ret, error = fromString(str)

	if error ~= nil then
		return 'Invalid Input! ' .. error
	end

	local output = ""

	if ret then
		local c = ret.coord
		if c then
			output = output .. ";Plane: " .. c.z
			output = output .. "\n;Coordinate: " .. c.x .. ", " .. c.y .. "\n"
		end

		local s = ret.subdivided
		if s then
			output = output .. "\n;Subdivided coordinate: " .. s.z .. "," .. s.x1 .. "," .. s.y1 .. "," .. s.x2 .. "," .. s.y2 .. "\n"
		end
	end

	return output
end

function p.toRS(frame)
	local args = frame:getParent().args
	local z = args.z or args[1]
	local x = args.x or args[2]
	local y = args.y or args[3]
	local s = p.convertToSubdividedCoordinates(z, x, y)
	return '(' .. s.z .. "," .. s.x1 .. "," .. s.y1 .. "," .. s.x2 .. "," .. s.y2 .. ')'
end

function p.toMap(frame)
	local args = frame:getParent().args
	local z = args.z or args[1]
	local i = args.x1 or args[2]
	local j = args.y1 or args[3]
	local x = args.x2 or args[4]
	local y = args.y2 or args[5]
	local c = p.convertToCoordinates(z, i, j, x, y)
	return '(' .. c.z .. "," .. c.x .. "," .. c.y .. ')'
end

return p
-- </nowiki>