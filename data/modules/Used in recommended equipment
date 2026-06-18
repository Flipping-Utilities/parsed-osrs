local p = {}

local contains = require('Module:Array').contains
local paramTest = require('Module:Paramtest')

local decode = mw.text.jsonDecode
local html = mw.html
local title = mw.title
local trim = mw.text.trim


function buildRow(positions, page, tableStyle)
	local row = html.create('tr')
	row:tag('td'):attr('data-sort-value', string.sub(positions, 1, 1)):wikitext(positions):done()
		:tag('td'):wikitext('[[' .. page .. ']]' .. (paramTest.has_content(tableStyle) and ' <small>(' .. tableStyle .. ')</small>' or '')):done()
	
	return row
end

function createHeader()
	local tabl = html.create('table'):addClass('wikitable mw-collapsible mw-collapsed sortable align-center-1 align-left-2 autosort=1,a')
	tabl:tag('tr'):tag('th'):wikitext('Rank'):done()
		:tag('th'):wikitext('Method'):done()
		
	return tabl
end

-- Returns the input item's page name and slot type
function loadItemData(item)
	local t1 = os.clock()
	local bucketData = bucket("infobox_bonuses")
		.select("infobox_item.item_name", "equipment_slot", 'Category:Weapons with Special attacks')
		.join("infobox_item", "infobox_item.page_name_sub", "infobox_bonuses.page_name_sub")
		.where(bucket.Or({"infobox_item.item_name", item}, {"infobox_item.page_name", item}))
		.limit(1)
		.run()
	local t2 = os.clock()
	mw.log(string.format('Bucket: entries %d, time elapsed: %.3f ms.', #bucketData, (t2 - t1) * 1000))

	return bucketData[1]["infobox_item.item_name"], bucketData[1].equipment_slot, bucketData[1]["Category:Weapons with Special attacks"]
end

-- Returns true for the exact string `Amulet of glory` will only yield uncharged amulet of glory links
function stringContains(items, str)
	local foundItems = {}
	
	-- plinkp [[File:ItemName.png|link=ItemName]]
	for itemName in string.gmatch(str, '%[%[File:([^%.]+)%.png|link=([^%]]+)%]%]') do
	    foundItems[itemName] = true
	end
	
	-- plinkt [[ItemName|ItemName]]  
	for itemName in string.gmatch(str, '%[%[([^%|%]]+)[%|%]]') do
	    foundItems[itemName] = true
	end
	for _, item in ipairs(items) do
	    if foundItems[item] then
	        return true
	    end
	end
	return false
end

function loadData(items)
	local t1 = os.clock()
	local data = bucket('recommended_equipment').limit(10000).select('page_name', 'json').run()
	local t2 = os.clock()
	assert(data ~= nil and #data > 0, 'Bucket query failed')
	mw.log(string.format('Module:Used in recommended equipment - Bucket: entries %d, time elapsed: %.3f ms.', #data, (t2 - t1) * 1000))
	
	local newData = {}
	
	-- Split pages that have multiple recommended equipment templates into separate table entries
	--  Rename the first parameter to name for clarity and ease of use
	-- It will only return tables that contain links to the arg inputs
	for _, page in ipairs(data) do
		if(stringContains(items, page.json)) then
			table.insert(newData, { name = page.page_name, json = decode(page.json)})
		end
	end

	return newData
end

function p._main(args)
	-- CSV lists should only be used for things in the same slot that are functionally identical
	--  This is primarily for redirect/generic linking, e.g. like `God blessing` when referring to any of the blessings
	local itemStr = paramTest.default_to(args[1], title.getCurrentTitle().text)
	local items = {}
	for str in string.gmatch(itemStr, '([^,]+)') do
		table.insert(items, trim(str))
	end
	
	local data = loadData(items)
	
	-- Only using the primary page for slot/special info, others should never impact it
	local itemPage, itemSlot, special = loadItemData(items[1])
	
	local ret = createHeader()
	local rowCount = 0
	local retSpecial
	local rowCountSpecial = 0
	
	local itemHasSpecial = false
	if(special) then
		itemHasSpecial = true
		retSpecial = createHeader()
	end

	for _, equipmentTable in ipairs(data) do
		local slotRowsToTraverse = {}
		if(equipmentTable.json["Recommended Equipment"][itemSlot] ~= nil) then
			table.insert(slotRowsToTraverse, itemSlot)
		end
		
		-- Weapon and 2h are used interchangably, so include both in the search.
		if(itemSlot == 'weapon' and equipmentTable.json["Recommended Equipment"]['2h'] ~= nil) then
			table.insert(slotRowsToTraverse, '2h')
		elseif(itemSlot == '2h' and equipmentTable.json["Recommended Equipment"]['weapon'] ~= nil) then
			table.insert(slotRowsToTraverse, 'weapon')
		end
		
		if(itemHasSpecial and equipmentTable.json["Recommended Equipment"]['special'] ~= nil) then
			table.insert(slotRowsToTraverse, 'special')
		end
		
		-- Darts exist as weapons or ammo (and are included with blowpipe in weapon)
		if(string.sub(itemPage, -4) == 'dart' and equipmentTable.json["Recommended Equipment"]['ammo'] ~= nil) then
			table.insert(slotRowsToTraverse, 'ammo')
		end
		
		for _, slotRowName in ipairs(slotRowsToTraverse) do
			local positions = ''
			for i, slotEntry in ipairs(equipmentTable.json["Recommended Equipment"][slotRowName]) do
				if(stringContains(items, slotEntry)) then
					if(positions == '') then
						positions = positions .. i
					else
						positions = positions .. ', ' .. i
					end
				end
			end
			if(positions ~= '' and slotRowName ~= 'special') then
				ret:node(buildRow(positions, equipmentTable.name, equipmentTable.json.style))
				rowCount = rowCount + 1
			elseif(positions ~= '' and slotRowName == 'special') then
				retSpecial:node(buildRow(positions, equipmentTable.name, equipmentTable.json.style))
				rowCountSpecial = rowCountSpecial + 1
			end
		end
	end

	if rowCount == 0 and rowCountSpecial == 0 then
        do return 'Not used in any recommended equipment.[[Category:Not used in any recommended equipment]]' end
    end
	
	return (rowCount > 0 and tostring(ret) or '') .. (rowCountSpecial > 0 and tostring('\n===Special attack===\n') .. tostring(retSpecial) or '')
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

return p