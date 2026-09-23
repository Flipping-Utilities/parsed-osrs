local p = {}

local function trim(value)
	if value == nil then
		return nil
	end

	value = mw.text.trim(value)

	if value == '' then
		return nil
	end

	return value
end

local function getPriceData(args, prefix)
	local priceItems = {}
	local priceQuantities = {}

	local i = 1

	while true do
		local priceItem = trim(args[prefix .. 'price' .. i])

		if not priceItem then
			break
		end

		local quantity = tonumber(args[prefix .. 'price' .. i .. 'qty']) or 1

		table.insert(priceItems, priceItem)
		table.insert(priceQuantities, quantity)

		i = i + 1
	end

	return priceItems, priceQuantities
end

local function renderMissingLocationCategory(args)
	local hasEquipment =
		trim(args.equipment1)
		or trim(args.set1equipment1)

	local location = trim(args.location)

	if hasEquipment and not location then
		return '[[Category:Emote clues with missing STASH location]]'
	end

	return ''
end

local function renderMaintenanceCategory(args)
	local items = trim(args.items)
	local equipment1 = trim(args.equipment1)
	local setEquipment1 = trim(args.set1equipment1)

	if items and not equipment1 and not setEquipment1 then
		return '[[Category:Clue info with unstructured items]]'
	end

	return ''
end

local function getEmotes(args)
	local emotes = {}

	local first = trim(args.emote)

	if first then
		table.insert(emotes, first)
	end

	local i = 2

	while true do
		local emote = trim(args['emote' .. i])

		if not emote then
			break
		end

		table.insert(emotes, emote)
		i = i + 1
	end

	return emotes
end

local function writeClueInfo(args)
	local id = tonumber(args.id)

	if not id then
		return
	end

	bucket('clue_info').put({
		id = id,
		tier = trim(args.tier),
		emote = getEmotes(args),
		location = trim(args.location),
		reference = trim(args.reference),
	})
end

local function writeEquipmentRow(sub, clueId, setId, groupId, item, baseItem, priceItems, priceQuantities, isAlternate)
	bucket('clue_equipment')
		.sub(sub)
		.put({
			clue_id = clueId,
			set_id = setId,
			group_id = groupId,
			item = item,
			base_item = baseItem,
			price_items = priceItems,
			price_quantities = priceQuantities,
			is_alternate = isAlternate,
		})
end

local function writeEquipmentSet(args, clueId, setId, prefix)
	local group = 1

	while true do
		local equipmentPrefix = prefix .. 'equipment' .. group
		local baseItem = trim(args[equipmentPrefix])

		if not baseItem then
			break
		end

		local basePriceItems, basePriceQuantities =
			getPriceData(args, equipmentPrefix)

		writeEquipmentRow(
			prefix .. 'equipment-' .. group,
			clueId,
			setId,
			group,
			baseItem,
			baseItem,
			basePriceItems,
			basePriceQuantities,
			false
		)

		local alt = 1

		while true do
			local altPrefix = equipmentPrefix .. 'alt' .. alt
			local alternate = trim(args[altPrefix])

			if not alternate then
				break
			end

			local altPriceItems, altPriceQuantities =
				getPriceData(args, altPrefix)

			writeEquipmentRow(
				prefix .. 'equipment-' .. group .. '-alt-' .. alt,
				clueId,
				setId,
				group,
				alternate,
				baseItem,
				altPriceItems,
				altPriceQuantities,
				true
			)

			alt = alt + 1
		end

		group = group + 1
	end
end

local function writeEquipment(args)
	local clueId = tonumber(args.id)

	if not clueId then
		return
	end

	if trim(args.equipment1) then
		writeEquipmentSet(args, clueId, 1, '')
		return
	end

	local setId = 1

	while true do
		local prefix = 'set' .. setId

		if not trim(args[prefix .. 'equipment1']) then
			break
		end

		writeEquipmentSet(args, clueId, setId, prefix)

		setId = setId + 1
	end
end

local function writeBuckets(args)
	writeClueInfo(args)
	writeEquipment(args)
end

local function render(frame, args)
	local text = trim(args.text)
	local items = trim(args.items)
	local notes = trim(args.notes)
	local map = trim(args.map)

	if not text then
		text = frame:preprocess(
			'[{{fullurl:{{FULLPAGENAME}}|action=edit}} ? (edit)]'
		)
	end

	items = items or "''None''"
	notes = notes or "''None''"
	map = map or "''None''"

	return table.concat({
		'<div class="transcript" style="text-align:center;width:350px">',
		text,
		'</div>',
		'{|class="wikitable"',
		'!Items',
		'|' .. items,
		'|-',
		'!Notes',
		'|' .. notes,
		'|-',
		'!Map',
		'|' .. map,
		'|}',
		'[[Category:Clue scrolls]]',
		renderMaintenanceCategory(args),
		renderMissingLocationCategory(args),
	}, '\n')
end

function p.main(frame)
	local args = frame:getParent().args

	writeBuckets(args)

	return render(frame, args)
end

return p