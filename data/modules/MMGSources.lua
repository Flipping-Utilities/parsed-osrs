local p = {}

local lang = mw.getContentLanguage()
local round = require('Module:Number')._round

function p.main(frame)
	local args = frame:getParent().args

	local item = args[1]
	local minQtyPerHr = tonumber(args.minQtyPerHr) or 0

	if not item or item == '' then
		return ''
	end

	local data = bucket("mmg_output")
		.select("page_name", "qty_per_hour")
		.where("item", item)
		.where("qty_per_hour", ">=", minQtyPerHr)
		.orderBy("qty_per_hour", "DESC")
		.run()

	if not data or #data == 0 then
		return ''
	end

	local ret = mw.html.create('table')
		:addClass('wikitable sortable')

	ret:tag('tr')
		:tag('th')
			:wikitext('Items/hour')
			:done()
		:tag('th')
			:wikitext('Source')
			:done()

	for _, row in ipairs(data) do
		local display_name = row.page_name:gsub('^Money making guide/', '')

		local tr = ret:tag('tr')

		tr:tag('td')
			:wikitext(lang:formatNum(round(row.qty_per_hour, 2)))

		tr:tag('td')
			:wikitext(string.format(
				'[[%s|%s]]',
				row.page_name,
				display_name
			))
	end

	return ret
end

return p