local tables = require('Module:Tables')
local VariablesLua = mw.ext.VariablesLua
local p = {}
local itemData = mw.loadJsonData('Module:Collection_log/data.json')

local headers = {
	item = "Item",
	id = "Id",
	icon = "",
	name = "Name",
	collection = "Collections",
	completion = '<span style="cursor:help; border-bottom:1px dotted;" title="Estimated percentage of players (of those who have used the WikiSync collection log integration) who have collected this item">Comp%</span>'
}

local overrides = {
	[2978] = { name = "Chompy bird hat (ogre bowman)" },
	[2979] = { name = "Chompy bird hat (bowman)" },
	[2980] = { name = "Chompy bird hat (ogre yeoman)" },
	[2981] = { name = "Chompy bird hat (yeoman)" },
	[2982] = { name = "Chompy bird hat (ogre marksman)" },
	[2983] = { name = "Chompy bird hat (marksman)" },
	[2984] = { name = "Chompy bird hat (ogre woodsman)" },
	[2985] = { name = "Chompy bird hat (woodsman)" },
	[2986] = { name = "Chompy bird hat (ogre forester)" },
	[2987] = { name = "Chompy bird hat (forester)" },
	[2988] = { name = "Chompy bird hat (ogre bowmaster)" },
	[2989] = { name = "Chompy bird hat (bowmaster)" },
	[2990] = { name = "Chompy bird hat (ogre expert)" },
	[2991] = { name = "Chompy bird hat (expert)" },
	[2992] = { name = "Chompy bird hat (ogre dragon archer)" },
	[2993] = { name = "Chompy bird hat (dragon archer)" },
	[2994] = { name = "Chompy bird hat (expert ogre dragon archer)" },
	[2995] = { name = "Chompy bird hat (expert dragon archer)" },
	[4068] = { name = "Decorative sword (red)" },
	[4069] = { name = "Decorative armour (red platebody)" },
	[4070] = { name = "Decorative armour (red platelegs)" },
	[4071] = { name = "Decorative helm (red)" },
	[4072] = { name = "Decorative shield (red)" },
	[4503] = { name = "Decorative sword (white)" },
	[4504] = { name = "Decorative armour (white platebody)" },
	[4505] = { name = "Decorative armour (white platelegs)" },
	[4506] = { name = "Decorative helm (white)" },
	[4506] = { name = "Decorative helm (white)" },
	[4507] = { name = "Decorative shield (white)" },
	[4508] = { name = "Decorative sword (gold)" },
	[4509] = { name = "Decorative armour (gold platebody)" },
	[4510] = { name = "Decorative armour (gold platelegs)" },
	[4511] = { name = "Decorative helm (gold)" },
	[4512] = { name = "Decorative shield (gold)" },
	[4513] = { name = "Castlewars hood (Saradomin)" },
	[4514] = { name = "Castlewars cloak (Saradomin)" },
	[4515] = { name = "Castlewars hood (Zamorak)" },
	[4516] = { name = "Castlewars cloak (Zamorak)" },
	[6926] = { name = "Bones to peaches (item)", text = "[[Bones to Peaches]]"},
	[7975] = { name = "Crawling hand (item)"},
	[8940] = { name = "Rum (red)" },
	[8941] = { name = "Rum (blue)" },
	[11666] = { name = "Void seal"},
	[11893] = { name = "Decorative armour (red plateskirt)" },
	[11894] = { name = "Decorative armour (white plateskirt)" },
	[11895] = { name = "Decorative armour (gold plateskirt)" },
	[11896] = { name = "Decorative armour (magic top)" },
	[11897] = { name = "Decorative armour (magic legs)" },
	[11898] = { name = "Decorative armour (magic hat)" },
	[11899] = { name = "Decorative armour (ranged top)" },
	[11900] = { name = "Decorative armour (ranged legs)" },
	[11901] = { name = "Decorative armour (quiver)" },
	[11901] = { name = "Decorative armour (quiver)" },
	[12536] = { name = "Dragon legs+skirt ornament kit"},
	[13324] = { name = "Baby chinchompa (grey)"},
	[19912] = { name = "Zombie head (Treasure Trails)", text = "[[Zombie head (Treasure Trails)|Zombie head]]"},
	[20665] = { name = "Rift guardian (fire)"},
	[21061] = { name = "Graceful hood (Agility Arena)" },
	[21064] = { name = "Graceful cape (Agility Arena)" },
	[21067] = { name = "Graceful top (Agility Arena)" },
	[21070] = { name = "Graceful legs (Agility Arena)" },
	[21073] = { name = "Graceful gloves (Agility Arena)" },
	[21076] = { name = "Graceful boots (Agility Arena)" },
	[22746] = { name = "Ikkle Hydra (serpentine)", text = "[[Ikkle Hydra]]"},
	[24189] = { name = "Deadman's chest (cosmetic)", text = "[[Deadman's chest]]"},
	[24190] = { name = "Deadman's legs (cosmetic)", text = "[[Deadman's legs]]"},
	[24191] = { name = "Deadman's cape (cosmetic)", text = "[[Deadman's cape]]"},
	[24763] = { name = "Mysterious page", text = "[[Mysterious_page#1|Mysterious page (first floor)]]"},
	[24765] = { name = "Mysterious page", text = "[[Mysterious_page#2|Mysterious page (second floor)]]"},
	[24767] = { name = "Mysterious page", text = "[[Mysterious_page#3|Mysterious page (third floor)]]"},
	[24769] = { name = "Mysterious page", text = "[[Mysterious_page#4|Mysterious page (fourth floor)]]"},
	[24771] = { name = "Mysterious page", text = "[[Mysterious_page#5|Mysterious page (fifth floor)]]"},
	[24862] = { name = "Karamjan monkey (item)"},
	[24863] = { name = "Zombie monkey (item)"},
	[24864] = { name = "Maniacal monkey (item)"},
	[24865] = { name = "Skeleton monkey (item)"},
	[24868] = { name = "Golden Armadyl special attack (item)", text = "[[Golden Armadyl special attack]]"},
	[24869] = { name = "Golden Bandos special attack (item)", text = "[[Golden Bandos special attack]]"},
	[24870] = { name = "Golden Saradomin special attack (item)", text = "[[Golden Saradomin special attack]]"},
	[24871] = { name = "Golden Zamorak special attack (item)", text = "[[Golden Zamorak special attack]]"},
	[24884] = { name = "Supply crate (Mahogany Homes)", text = "[[Supply crate (Mahogany Homes)|Supply crate]]"},
	[25163] = { name = "Decorative boots (red)" },
	[25165] = { name = "Decorative full helm (red)" },
	[25167] = { name = "Decorative boots (white)" },
	[25169] = { name = "Decorative full helm (white)" },
	[25171] = { name = "Decorative boots (gold)" },
	[25174] = { name = "Decorative full helm (gold)" },
	[25615] = { name = "Large water container"},
	[27019] = { name = "Ore pack (Giants' Foundry)"},
	[27590] = { name = "Muphin (ranged)", text = "[[Muphin]]"},
	[29974] = { name = "Prescription goggles (unfocused)", text = "[[Prescription goggles]]"},
	[29978] = { name = "Alchemist labcoat (apron off)", text = "[[Alchemist labcoat]]"},
	[29982] = { name = "Alchemist pants (apron off)", text = "[[Alchemist pants]]"},
	[29992] = { name = "Alchemist's amulet (uncharged)", text = "[[Alchemist's amulet]]"},
	[30045] = { name = "Graceful hood (Varlamore)" },
	[30048] = { name = "Graceful cape (Varlamore)" },
	[30051] = { name = "Graceful top (Varlamore)" },
	[30054] = { name = "Graceful legs (Varlamore)" },
	[30057] = { name = "Graceful gloves (Varlamore)" },
	[30060] = { name = "Graceful boots (Varlamore)" },
	[30637] = { name = "Giantsoul amulet" },
	[11341] = { name = "Ancient page", text = "[[Ancient page#1|Ancient page (1)]]"},
	[11342] = { name = "Ancient page (2)", text = "[[Ancient page#2|Ancient page (2)]]"},
	[11343] = { name = "Ancient page", text = "[[Ancient page#3|Ancient page (3)]]"},
	[11344] = { name = "Ancient page (2)", text = "[[Ancient page#4|Ancient page (4)]]"},
	[11345] = { name = "Ancient page", text = "[[Ancient page#5|Ancient page (5)]]"},
	[11346] = { name = "Ancient page (2)", text = "[[Ancient page#6|Ancient page (6)]]"},
	[11347] = { name = "Ancient page", text = "[[Ancient page#7|Ancient page (7)]]"},
	[11348] = { name = "Ancient page (2)", text = "[[Ancient page#8|Ancient page (8)]]"},
	[11349] = { name = "Ancient page", text = "[[Ancient page#9|Ancient page (9)]]"},
	[11350] = { name = "Ancient page (2)", text = "[[Ancient page#10|Ancient page (10)]]"},
	[11351] = { name = "Ancient page", text = "[[Ancient page#11|Ancient page (11)]]"},
	[11352] = { name = "Ancient page (2)", text = "[[Ancient page#12|Ancient page (12)]]"},
	[11353] = { name = "Ancient page", text = "[[Ancient page#13|Ancient page (13)]]"},
	[11354] = { name = "Ancient page (2)", text = "[[Ancient page#14|Ancient page (14)]]"},
	[11355] = { name = "Ancient page", text = "[[Ancient page#15|Ancient page (15)]]"},
	[11356] = { name = "Ancient page (2)", text = "[[Ancient page#16|Ancient page (16)]]"},
	[11357] = { name = "Ancient page", text = "[[Ancient page#17|Ancient page (17)]]"},
	[11358] = { name = "Ancient page (2)", text = "[[Ancient page#18|Ancient page (18)]]"},
	[11359] = { name = "Ancient page", text = "[[Ancient page#19|Ancient page (19)]]"},
	[11360] = { name = "Ancient page (2)", text = "[[Ancient page#20|Ancient page (20)]]"},
	[11361] = { name = "Ancient page", text = "[[Ancient page#21|Ancient page (21)]]"},
	[11362] = { name = "Ancient page (2)", text = "[[Ancient page#22|Ancient page (22)]]"},
	[11363] = { name = "Ancient page", text = "[[Ancient page#23|Ancient page (23)]]"},
	[11364] = { name = "Ancient page (2)", text = "[[Ancient page#24|Ancient page (24)]]"},
	[11365] = { name = "Ancient page", text = "[[Ancient page#25|Ancient page (25)]]"},
	[11366] = { name = "Ancient page (2)", text = "[[Ancient page#26|Ancient page (26)]]"},
	[32388] = { name = "Medallion fragment (1)", text = "[[Medallion fragment]]"},
	[32389] = { name = "Medallion fragment (2)", text = "[[Medallion fragment]]"},
	[32390] = { name = "Medallion fragment (3)", text = "[[Medallion fragment]]"},
	[32391] = { name = "Medallion fragment (4)", text = "[[Medallion fragment]]"},
	[32392] = { name = "Medallion fragment (5)", text = "[[Medallion fragment]]"},
	[32393] = { name = "Medallion fragment (6)", text = "[[Medallion fragment]]"},
	[32394] = { name = "Medallion fragment (7)", text = "[[Medallion fragment]]"},
	[32395] = { name = "Medallion fragment (8)", text = "[[Medallion fragment]]"}
}

local tabOverrides = {
	["Callisto and Artio"] = "[[Callisto]] and [[Artio]]",
	["Venenatis and Spindel"] = "[[Venenatis]] and [[Spindel]]",
	["Vet'ion and Calvar'ion"] = "[[Vet'ion]] and [[Calvar'ion]]",
	["All Pets"] = "[[Pet|All Pets]]",
	["Shades of Mort'ton"] = "[[Shades of Mort'ton (minigame)|Shades of&nbsp;Mort'ton]]", -- &nbsp; to prevent wikisync matching as quest name
	["Beginner Treasure Trails"] = "[[Reward casket (beginner)|Beginner Treasure Trails]]",
	["Easy Treasure Trails"] = "[[Reward casket (easy)|Easy Treasure Trails]]",
	["Medium Treasure Trails"] = "[[Reward casket (medium)|Medium Treasure Trails]]",
	["Hard Treasure Trails"] = "[[Reward casket (hard)|Hard Treasure Trails]]",
	["Hard Treasure Trails (Rare)"] = "[[Reward casket (hard)|Hard Treasure Trails (Rare)]]",
	["Elite Treasure Trails"] = "[[Reward casket (elite)|Elite Treasure Trails]]",
	["Master Treasure Trails"] = "[[Reward casket (master)|Master Treasure Trails]]",
	["Elite Treasure Trails (Rare)"] = "[[Reward casket (elite)|Elite Treasure Trails (Rare)]]",
	["Master Treasure Trails (Rare)"] = "[[Reward casket (master)|Master Treasure Trails (Rare)]]",
	["Shared Treasure Trail Rewards"] = "[[Treasure Trails#Universal rewards|Shared Treasure Trails Rewards]]",
	["The Fight Caves"] = "[[TzHaar Fight Cave|The Fight Caves]]",
	["Barrows Chests"] = "[[Chest (Barrows)|Barrows Chests]]",
	["Miscellaneous"] = "Miscellaneous",
	["Skilling Pets"] = "[[Pets|Skilling Pets]]",
	["Monkey Backpacks"] = "[[Monkey (Monkey Madness II)|Monkey Backpacks]]",
	["Elder Chaos Druids"] = "[[Elder chaos druid|Elder Chaos Druids]]",
	["Fossil Island Notes"] = "[[Stone chest (House on the Hill)|Fossil Island Notes]]",
	["Scroll Cases"] = "[[Scroll case|Scroll Cases]]",
	["Vale Totems"] = "[[Vale Totems (minigame)|Vale&nbsp;Totems]]", -- &nbsp; to prevent wikisync matching as quest name
	["Boat Paints"] = "[[Boat paint|Boat Paints]]",
	["Lost Schematics"] = "[[Lost schematics|Lost Schematics]]",
	["Ocean Encounters"] = "[[Ocean encounters|Ocean Encounters]]",
	["Sailing Miscellaneous"] = "[[Sailing]] Miscellaneous",
}
local clueTabs = { "Beginner Treasure Trails", "Easy Treasure Trails", "Medium Treasure Trails", "Hard Treasure Trails", "Hard Treasure Trails (Rare)", "Elite Treasure Trails", "Master Treasure Trails", "Elite Treasure Trails (Rare)", "Master Treasure Trails (Rare)", "Shared Treasure Trail Rewards", "Scroll Cases" }

local function validate_arg(value, valid, name)
	if not valid[value] then
		error("Invalid value for '" .. name .. "': " .. value)
	end
end

local function parse_validate_args(args)
	local parsed_args = {}
	local parsed_cats = mw.text.split(args['category'] or 'all', ',', true)
	local parsed_cols = mw.text.split(args['cols'] or 'item,collection,completion', ',', true)
	local parsed_output = args['output'] or 'table'
	
	local out_cats = {}
	local out_cols = {}
	
	local valid_cols = {
		item = true,
		id = true,
		icon = true,
		name = true,
		collection = true,
		completion = true
	}
	local valid_outputs = {
		table = true,
		raw = true
	}
	
	-- loop and validate multi-args
	for i, cat in ipairs(parsed_cats) do
		cat = string.lower(mw.text.trim(cat))
		if 'all' == cat then
			-- if "all" category, ignore the rest
			out_cats = {}
			out_cats['all'] = 1
			break
		end
		out_cats[cat] = i
	end
	
	for i, col in ipairs(parsed_cols) do
		col = mw.text.trim(col)
		validate_arg(col, valid_cols, "column")
		out_cols[col] = i
	end
	
	parsed_output = mw.text.trim(parsed_output)
	validate_arg(parsed_output, valid_outputs, "output")
	
	-- consolidate parsed/validated args into new table
	parsed_args['category'] = out_cats
	parsed_args['cols'] = out_cols
	parsed_args['output'] = parsed_output
	
	return parsed_args
end

local function getData(categories)
	local data = {}
	
	for idx, item in ipairs(itemData) do
		for _, tab in ipairs(item['tabs']) do
			if categories[string.lower(tab)] or categories['all'] then
				table.insert(data, item)
				break
			end
		end
	end
	return data;
end

local function completionCell(id, outputType)
	local completion_percent = mw.loadJsonData("Module:Collection_log/completion.json")[tonumber(id)]
	
	-- return raw percentage
	if (outputType == 'raw') then
		return completion_percent or 0
	end
	
	-- return html formatted percentage
	if (completion_percent ~= nil) then
		local color = ""
		if (completion_percent < 0.1) then
			completion_percent = "<0.1"
			color = "red"
		elseif (completion_percent < 10) then
			color = "orange"
		elseif (completion_percent < 25) then
			color = "yellow"
		elseif (completion_percent < 50) then
			color = "green"
		elseif (completion_percent <= 100) then
			color = "blue"
		end
		return {text = tostring(completion_percent)..'%', class = "table-bg-" .. color}
	else
		return {text = "N/A", class="table-na nohighlight"}
	end	
end

local function getOverrides(itemId)
	-- Have a big map of overrides
	return overrides[itemId];
end

local function makeTable(data, columns)
	local columnValues = {}
	local col_sort = {}
	-- sort keys by their order specified in the arg
	for k, v in pairs(columns) do
		-- col_sort[#] = colname
		col_sort[v] = k
	end
	-- loop col_sort in order
	for _,v in ipairs(col_sort) do
		-- insert header, indexed by colname
		table.insert(columnValues, headers[v])
	end
	
	-- try to sort by completion% descending
	local sortkey = columns['completion']
	if sortkey then
		sortkey = sortkey .. ',d'
	else
		-- if completion isn't selected, sort by one of the other cols ascending
		sortkey = columns['name'] or columns['collection'] or columns['id'] or columns['item']
		sortkey = sortkey and sortkey .. ',a' or ''
	end
	local clogTable = mw.html.create('table'):addClass(string.format('wikitable lighttable sortable qc-active collection-log autosort=%s', sortkey)):cssText('max-width: 800px')
	tables._row(clogTable:tag('tr'), columnValues, true)
	
	

	for _, v in ipairs(data) do
		-- local sanitisedName = v.name:gsub("{{.-}}", "")
		local isClueJunk = false
		local tabs = {}
		for _, tab in ipairs(v.tabs) do
			local tabText = tabOverrides[tab] or string.format("[[%s]]", tab)
			table.insert(tabs, tabText)
			for _, clueTabName in ipairs(clueTabs) do
				if clueTabName == tab then
					isClueJunk = true
				end
			end
		end
		
		local override = getOverrides(v.id)
		local name = v.name
		if (override ~= nil and override.name ~= nil) then
			name = override.name
		end
		
		local text = string.format("[[%s]]", name)
		if (override ~= nil and override.text ~= nil) then
			text = override.text
		end
		local image = v.image or (name .. ".png")
		
		local orderedRowData = {}
		for i,colname in ipairs(col_sort) do
			if colname == 'item' then
				orderedRowData[colname] = string.format("[[File:%s]] %s", image, text)
			elseif colname == 'collection' then
				orderedRowData[colname] = table.concat(tabs, ', ')
			elseif colname == 'completion' then
				orderedRowData[colname] = completionCell(v.id, 'table')
			elseif colname == 'id' then
				orderedRowData[colname] = v.id
			elseif colname == 'icon' then
				orderedRowData[colname] = string.format("[[File:%s]]", image)
			elseif colname == 'name' then
				orderedRowData[colname] = text
			end
		end

		local row = {}
		for _, column in ipairs(col_sort) do
			table.insert(row, orderedRowData[column])
		end
		
		local htmlRow = clogTable:tag('tr'):attr('data-item-id', v.id)
		if isClueJunk then
			htmlRow:attr('data-item-clue-junk', 'true')
		end
		tables._row(htmlRow, row, false)
	end

	return clogTable
end

local function makeLuaTable(data, columns)
	local retlua = {}
	
	for _, v in ipairs(data) do
		local isClueJunk = false
		local tabs = {}
		for _, tab in ipairs(v.tabs) do
			local tabText = tabOverrides[tab] or string.format("[[%s]]", tab)
			table.insert(tabs, tabText)
			for _, clueTabName in ipairs(clueTabs) do
				if clueTabName == tab then
					isClueJunk = true
				end
			end
		end
		
		local override = getOverrides(v.id)
		local name = v.name
		if (override ~= nil and override.name ~= nil) then
			name = override.name
		end
		
		local text = string.format("[[%s]]", name)
		if (override ~= nil and override.text ~= nil) then
			text = override.text
		end
		local image = v.image or (name .. ".png")
		
		for colname,colidx in pairs(columns) do
			local item_data = {}
			
			if colname == 'item' then
				item_data[colname] = string.format("[[File:%s]] %s", image, text)
			elseif colname == 'collection' then
				item_data[colname] = table.concat(tabs, ', ')
			elseif colname == 'completion' then
				item_data[colname] = completionCell(v.id, 'raw')
			elseif colname == 'id' then
				item_data[colname] = v.id
			elseif colname == 'icon' then
				item_data[colname] = string.format("[[File:%s]]", image)
			elseif colname == 'name' then
				item_data[colname] = text
			end
		end
	end
	
	mw.logObject(data)
	
	return retlua
end

function p.list(frame)
	local args = frame:getParent().args
	
	return p._list(args)
end

function p._list(args)
	local parsed_args = parse_validate_args(args)
	
	local columns = parsed_args['cols']
	local categories = parsed_args['category']
	local data = getData(categories)
	-- table.sort(data, sortByTierAndMonster)
	local retobj = nil
	if parsed_args['output'] == 'table' then
		retobj = tostring( makeTable(data, columns) )
	else
		retobj = makeLuaTable(data, columns)
		mw.logObject(retobj)
	end
	return retobj
end

return p