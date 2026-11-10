local p = {}
local lang = mw.getContentLanguage()

function p.enddate(frame)
	local args = frame.args
	pcall(p._enddate, args[1], args.version)
end

function p._enddate(date, version)
	if date == nil or date == '' then
		return
	end

	date = date:gsub('%[', ''):gsub('%]', '')
	local bucketYear = lang:formatDate('Y', date)
	local bucketMonth = lang:formatDate('n', date)
	local bucketDay = lang:formatDate('j', date)
	bucket('infobox_event').sub(version).put({
		end_date_text = date,
		end_date = os.time({year = bucketYear, month = lang:formatDate('m', date), day = bucketDay}),
		end_year = bucketYear,
		end_month = bucketMonth,
		end_day = bucketDay
	})
end

return p