
local dpl = require('Module:DPLlua')
local utils = require('Module:Sandbox/User:Oo00oo00oO/utils')

local p = {}


--- Returns information about the latest game update as a JSON string.
---
--- Queries all game updates in the `Update` namespace, parses their dates,
--- sorts them newest first, and returns the latest update with its title and
--- ISO 8601 date (`YYYY-MM-DD`).
---
--- @param frame Frame|table Wikitext invocation frame or a table of arguments.
--- @param frame.asPreBlock (positional = 1) When truthy, the JSON output is wrapped in a `<pre>` block. Defaults to FALSE.
--- @return string JSON-encoded object containing `title` and `date` field.
function p.getLatestGameUpdateInfo(frame)
	local args = utils.extractArgs(frame)
	
	asPreBlock = ((args["asPreBlock"] or args[1]) and true) or false
	local results = dpl.ask({
		namespace = 'Update',
		category = 'Game updates',
		uses = 'Template:Update',
		include = '{Update}:date',
		count = 100000,
		ordermethod = 'created',
		order = 'descending'
	})

	local dataTable = {}

	-- Month names used by the DPL date format.
	local months = {
		Jan=1,
		Feb=2,
		Mar=3,
		Apr=4,
		May=5,
		Jun=6,
		Jul=7,
		Aug=8,
		Sep=9,
		Oct=10,
		Nov=11,
		Dec=12,
		January = 1,
		February = 2,
		March = 3,
		April = 4,
		May = 5,
		June = 6,
		July = 7,
		August = 8,
		September = 9,
		October = 10,
		November = 11,
		December = 12
	}

	for _, result in ipairs(results) do
		local dateString = result.include
			and result.include.Update
			and result.include.Update.date

		local day,monthName,year = string.match(dateString, '0?(%d+)%s*(%S+)%s*(%d+)')
		local timestamp = os.date("!%Y-%m-%d", os.time({
			year = tonumber(year or "1970"),
			month = months[monthName or "January"],
			day = tonumber(day or "1"),
			hour = 0,
			min = 0,
			sec = 0
		}))
	
	    
		table.insert(dataTable, {
			title = result.title,
			date = timestamp
		})
	end

	-- sort table newest first 
	table.sort(dataTable, function(a, b)
		if a.date == nil or b.date == nil then
			return false
		end
		return a.date > b.date
	end)
	
	-- format output
	local newest = dataTable[1]
	local output = utils.convertToJson(newest, asPreBlock)
	
	return output
end

return p