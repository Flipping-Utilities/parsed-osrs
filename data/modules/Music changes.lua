
local p = {}

local onmain = require('Module:Mainonly').on_main
local bucket_data = {}

function p.bucket(frame)
	if not onmain() then
		return ''
	end
	local args = frame:getParent().args
	
	if args.file then
		bucket_data['track'] = string.gsub(args.file, '[%[%]]', '')
	end

	bucket_data["version"] = args.version
	bucket_data["date"] = args.date or args.daterange
	bucket_data["change"] = args.change
	bucket("music_versions").put(bucket_data)
end


return p