local p = {}

function p.main(frame)
	local args = frame:getParent().args
	local item = args[1]
	local image = args[2]
	return p._main(item, args.limit, args.offset, args.prefer, frame, image)
end

function p._main(item, limit, offset, priorityMaterial, frame, image)
	local data = p.query(item, limit, offset, nil, nil, priorityMaterial)
	if not data then return '' end
	
	local function renderNode(node)
		local html = {}
		if node.materials and #node.materials > 0 then
			table.insert(html, '<ul>')
			for _, mat in ipairs(node.materials) do
				table.insert(html, '<li>')
				if mat.subrecipe and mat.subrecipe.facility then
					table.insert(html, string.format('{{Sandbox/User:Varied2350/Item count|%s|%s}}{{Plinkp|%s}}', mat.name, mat.quantity, mat.subrecipe.facility))
				else
					table.insert(html, string.format('{{Sandbox/User:Varied2350/Item count|%s|%s}}', mat.name, mat.quantity))
				end
				if mat.subrecipe then
					table.insert(html, renderNode(mat.subrecipe))
				end
				table.insert(html, '</li>')
			end
			table.insert(html, '</ul>')
		end
		return table.concat(html)
	end
	
	local rootImage = image or item
	local rootVisual = string.format('{{Plinkp|%s}} [[%s]]', rootImage, item)
	local tree = string.format('<div class="crafting-tree"><ul><li>%s %s</li></ul></div>', rootVisual, renderNode(data))
	return frame:preprocess(tree)
end

function p.query(item, limit, offset, depth, parentQuantity, priorityMaterial)
    depth = depth or 0
	local maxDepth = 10
	parentQuantity = tonumber(parentQuantity) or 1
	local data = bucket('recipe')
		.select('production_json')
		-- .where(bucket.And({'page_name', item}, {'source_template', 'recipe'}))
		.where('page_name', item)
		.limit(tonumber(limit) or 500)
		.offset(tonumber(offset) or 0)
		.run()
	
	local selectedEntry = nil
	if priorityMaterial then
		for _, entry in pairs(data) do
			local json = mw.text.jsonDecode(entry.production_json)
			for _, mat in ipairs(json.materials or {}) do
				if mat.name == priorityMaterial then
					selectedEntry = entry
					break
				end
			end
			if selectedEntry then break end
		end
	end
	
	if not selectedEntry then
		for _, entry in pairs(data) do
			local checkJson = mw.text.jsonDecode(entry.production_json)
			
			if checkJson.materials and #checkJson.materials > 0 then
				selectedEntry = entry
				break
			end
		end
	end
	
	if selectedEntry then
		local json = mw.text.jsonDecode(selectedEntry.production_json)
		local outputQuantity = tonumber(json.output.quantity) or 1
		local result = {
			facility = json.uses_facility,
			output = {
				name = json.output.name,
				quantity = outputQuantity * parentQuantity,
			},
			materials = {}
		}
		local craftingOperations = parentQuantity / outputQuantity
		for _, material in ipairs(json.materials or {}) do
			local baseQuantity = tonumber(material.quantity) or 1
			local adjustedQuantity = math.floor((baseQuantity * craftingOperations) * 100) / 100
			local mat = {
				name = material.name,
				quantity = adjustedQuantity,
			}
			if tonumber(depth) < maxDepth then
				local subRecipe = p.query(material.name, limit, offset, depth + 1, adjustedQuantity, priorityMaterial)
				if subRecipe then
					mat.subrecipe = subRecipe
				end
			end
			table.insert(result.materials, mat)
		end
		return result
	end
end

return p