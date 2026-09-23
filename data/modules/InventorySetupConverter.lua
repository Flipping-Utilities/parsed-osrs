local p = {}

local function splitIds(value)
	local ids = {}
	local seen = {}

	for part in string.gmatch(value or '', '[^,]+') do
		local id = tonumber(part)

		if id ~= nil and id > 0 and not seen[id] then
			seen[id] = true
			table.insert(ids, id)
		end
	end

	return ids
end

function p.itemNames(frame)
	local ids = splitIds(frame.args.ids)
	local output = {}

	for _, itemId in ipairs(ids) do
		local data = bucket('infobox_item')
			.select('item_name')
			.where('item_id', itemId)
			.limit(1)
			.run()

		if data ~= nil and data[1] ~= nil then
			output[tostring(itemId)] = data[1].item_name
		end
	end

	return mw.text.jsonEncode(output)
end

return p