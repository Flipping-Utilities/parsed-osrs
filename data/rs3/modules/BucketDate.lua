local p = {}
local lang = mw.getContentLanguage()
local onmain = require('Module:Mainonly').on_main

function p.main(frame)
	local bucket_name = frame.args.bucket_name
	local args = frame:getParent().args
	pcall(p._main, args[1], args.sub, bucket_name)
end

function p._main(date, page_name_sub, bucket_name)
	bucket_name = bucket_name or "release_date"
	if date == nil or date == '' then
		return
	end
	
	if not onmain() then
		return
	end

	date = date:gsub('[[%]]', '')
	local bucketYear = lang:formatDate('Y', date)
	local bucketMonth = lang:formatDate('n', date)
	local bucketDay = lang:formatDate('j', date)
	bucket(bucket_name).sub(page_name_sub).put{
		date_text = date,
		date = os.time{year = bucketYear, month = lang:formatDate('m', date), day = bucketDay},
		year = bucketYear,
		month = bucketMonth,
		day = bucketDay,
	}
end

return p