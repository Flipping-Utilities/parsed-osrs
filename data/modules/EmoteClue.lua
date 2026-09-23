local p = {}

local function getCurrentItem()
	return mw.title.getCurrentTitle().text
end

local function getMatchingEquipment(item)
	return bucket('clue_equipment')
		.select(
			'page_name',
			'clue_id',
			'set_id',
			'group_id',
			'item',
			'base_item',
			'price_items',
			'price_quantities',
			'is_alternate'
		)
		.where('item', item)
		.orderBy('page_name', 'asc')
		.run()
end

local function getClue(pageName)
	local result = bucket('clue_info')
		.select(
			'page_name',
			'id',
			'tier',
			'emote',
			'location',
			'reference'
		)
		.where('page_name', pageName)
		.run()

	if #result == 0 then
		return nil
	end

	return result[1]
end

local function getClueEquipment(pageName)
	return bucket('clue_equipment')
		.select(
			'set_id',
			'group_id',
			'item',
			'base_item',
			'price_items',
			'price_quantities',
			'is_alternate'
		)
		.where('page_name', pageName)
		.orderBy('group_id', 'asc')
		.run()
end

local function renderClueReference(frame, reference)
	if not reference or reference == '' then
		return ''
	end

	return frame:extensionTag(
		'ref',
		frame:preprocess(reference),
		{
			group = 'clue',
		}
	)
end

local function makeSelectedItem(row)
	return {
		name = row.item,
		priceItems = row.price_items or {},
		priceQuantities = row.price_quantities or {},
	}
end

local function getSelectedEquipment(pageName, matchedRow)
	local rows = getClueEquipment(pageName)
	local groups = {}

	local matchedSet = tonumber(matchedRow.set_id) or 1
	local matchedGroup = tonumber(matchedRow.group_id)

	for _, row in ipairs(rows) do
		local setId = tonumber(row.set_id) or 1
		local groupId = tonumber(row.group_id)

		if setId == matchedSet then
			if groupId == matchedGroup and row.item == matchedRow.item then
				groups[groupId] = makeSelectedItem(row)
			elseif groupId ~= matchedGroup and row.item == row.base_item then
				groups[groupId] = makeSelectedItem(row)
			end
		end
	end

	local selected = {}

	for groupId = 1, #groups do
		if groups[groupId] then
			table.insert(selected, groups[groupId])
		end
	end

	return selected
end

local function renderItems(frame, items)
	local output = {}

	for _, item in ipairs(items) do
		table.insert(
			output,
			frame:expandTemplate({
				title = 'plinkp',
				args = { item.name },
			})
		)
	end

	return table.concat(output, ' ')
end

local function addItemPrices(frame, output, item)
	local priceItems = item.priceItems
	local priceQuantities = item.priceQuantities

	if not priceItems or #priceItems == 0 then
		table.insert(
			output,
			frame:expandTemplate({
				title = 'GEP',
				args = { item.name },
			})
		)

		return
	end

	for i, priceItem in ipairs(priceItems) do
		local quantity = tonumber(priceQuantities[i]) or 1

		if priceItem == 'Coins' then
			table.insert(output, tostring(quantity))
		else
			local args = {
				priceItem,
			}
	
			if quantity ~= 1 then
				args[2] = quantity
			end
	
			table.insert(
				output,
				frame:expandTemplate({
					title = 'GEP',
					args = args,
				})
			)
		end
	end
end

local function renderCost(frame, items)
	local prices = {}

	for _, item in ipairs(items) do
		addItemPrices(frame, prices, item)
	end

	return frame:expandTemplate({
		title = 'Coins',
		args = {
			table.concat(prices, ' + '),
		},
	})
end

local function ucfirst(text)
	if not text or text == '' then
		return ''
	end

	return mw.ustring.upper(mw.ustring.sub(text, 1, 1))
		.. mw.ustring.sub(text, 2)
end

local function renderTier(tier)
	local display = ucfirst(tier)

	return string.format(
		'[[Treasure Trails/Guide/Emote clues#%s Emote clues|%s]]',
		display,
		display
	)
end

local function renderSingleEmote(emote)
	if emote == 'Bow' then
		return '[[Bow (emote)|Bow]]'
	end

	return string.format('[[%s]]', emote)
end

local function renderEmote(emotes, cluePage)
	if not emotes then
		return ''
	end

	if type(emotes) == 'string' then
		emotes = { emotes }
	end

	local output = {}

	for _, emote in ipairs(emotes) do
		if emote and emote ~= '' then
			table.insert(output, renderSingleEmote(emote))
		end
	end

	local rendered = table.concat(output, '&nbsp;& ')

	if cluePage and cluePage ~= '' then
		rendered = rendered
			.. ' '
			.. string.format('[[%s|(clue)]]', cluePage)
	end

	return rendered
end

local function isTrue(value)
	return value == true
		or value == 1
		or value == '1'
		or value == 'true'
end

local function renderVariationNote(frame, row)
	if not isTrue(row.is_alternate) then
		return ''
	end

	if not row.base_item or row.base_item == '' then
		return ''
	end

	return frame:extensionTag('ref', string.format('The cost may be higher because of the variant of the item used. The base item is [[%s]].', row.base_item), {group = 'c',})
end

local function renderRow(frame, clue, matchedRow)
	local pageName = matchedRow.page_name

	local equipment = getSelectedEquipment(
		pageName,
		matchedRow
	)

	local items = renderItems(frame, equipment)
	local cost = renderCost(frame, equipment)
	local variationNote = renderVariationNote(frame, matchedRow)
	local emote = renderEmote(clue.emote, clue.page_name)
	local location = clue.location or ''
	local clueReference = renderClueReference(frame, clue.reference)

	return table.concat({
		'|-',
		'|' .. renderTier(clue.tier),
		'||' .. emote,
		'||' .. location .. clueReference,
		'||' .. items,
		'||' .. cost .. variationNote,
	}, '\n')
end

function p.main(frame)
	local currentItem = getCurrentItem()
	local matches = getMatchingEquipment(currentItem)

	if #matches == 0 then
		return ''
	end

	local rows = {}

	local seenPages = {}

	for _, matchedRow in ipairs(matches) do
		if not seenPages[matchedRow.page_name] then
			seenPages[matchedRow.page_name] = true

			local clue = getClue(matchedRow.page_name)

			if clue then
				table.insert(
					rows,
					renderRow(frame, clue, matchedRow)
				)
			end
		end
	end

	if #rows == 0 then
		return ''
	end

	return table.concat({
		'{| class="wikitable align-right-5" style="text-align:left"',
		'!Tier',
		'![[Emote]]s',
		'![[STASH]] location',
		'!Items',
		'!Cost',
		table.concat(rows, '\n'),
		'|}',
		frame:expandTemplate({
			title = 'Mainonly',
			args = {
				'[[Category:Items needed for an emote clue]]',
			},
		}),
		frame:expandTemplate({
			title = 'Reflist',
			args = {
				group = 'c',
			},
		}),
		frame:expandTemplate({
			title = 'Reflist',
			args = {
			group = 'clue',
			},
		}),
	}, '\n')
end

function p.template(frame)
	local args = frame:getParent().args

	if args.tier and args.tier ~= '' then
		return frame:expandTemplate({
			title = 'EmoteClue/legacy',
			args = args,
		})
	end

	return p.main(frame)
end

return p