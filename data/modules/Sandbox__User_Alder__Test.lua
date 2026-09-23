local p = {}

local dpl = require('Module:DPLlua')

function p.main()
	local results = dpl.ask({
		namespace = '',
		uses = 'Template:Infobox Location',
		include = '{Infobox Location}',
		count = 2000,
		ordermethod = 'title',
	})

	local output = {}

	for _, result in ipairs(results) do
		local title = result.title
		local infobox = result.include and result.include['Infobox Location']

		local release = infobox and infobox.release

		if release then
			table.insert(output, string.format(
				'* [[%s]] — %s',
				title,
				release
			))
		end
	end

	return table.concat(output, '\n')
end

return p