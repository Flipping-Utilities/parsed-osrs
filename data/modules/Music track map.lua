local map = require('Module:Map')

local p = {}

-- arg json takes a geoJSON array [[[x1,y1], [x2,y2], ...]] and converts it to an array of map strings [x1:y1,x2:y2,...].
local function jsonToMapStrings(json)
	local decoded = mw.text.jsonDecode(json)
    for i, poly in ipairs(decoded) do
    	for j, coord in ipairs(poly) do
			coord[j] = table.concat(coord[j], ':')
    	end
    	poly[i] = table.concat(poly[i], ',')
    end
	return decoded
end

function p.main(frame)
	local args = frame:getParent().args
	local mapArgs = {
		mtype = "polygon",
		group = args.group or 1
	}
	local mapStrings = jsonToMapStrings(args[1])
	for i, poly in ipairs(mapStrings) do
		table.insert(mapArgs, poly)
	end
	local mapFrame = map.buildMap(mapArgs)

    return mapFrame
end

return p