local p = {}

local Bucket = mw.ext.bucket

local PAGE_SIZE = 5000

local MONTH_NUMBERS = {
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
	December = 12,
}

local MONTH_NAMES = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December",
}

---Appends every value in source to destination.
---@param destination table
---@param source table
local function append_all(destination, source)
	for _, value in ipairs(source) do
		table.insert(destination, value)
	end
end

---Returns whether a field is considered enabled.
---The existing behavior treats any truthy value except "no" as enabled.
---@param value any
---@return boolean
local function is_enabled(value)
	return value and tostring(value):lower() ~= "no"
end

---Returns whether a name is valid.
---Bucket may return null values as strings beginning with "null".
---@param value any
---@return boolean
local function has_valid_name(value)
	if value == nil then
		return false
	end

	local name = tostring(value)

	if name == "" then
		return false
	end

	if string.sub(name:lower(), 1, 4) == "null" then
		return false
	end

	return true
end

---Builds a sortable ISO-style calendar-date key.
---@param year number
---@param month number
---@param day number
---@return string
local function make_date_key(year, month, day)
	return string.format(
		"%04d-%02d-%02d",
		tonumber(year),
		tonumber(month),
		tonumber(day)
	)
end

---Extracts numeric year, month, and day values from a date key.
---@param date_key string
---@return number|nil year
---@return number|nil month
---@return number|nil day
local function parse_date_key(date_key)
	local year, month, day = string.match(
		date_key,
		"(%d%d%d%d)-(%d%d)-(%d%d)"
	)

	return tonumber(year), tonumber(month), tonumber(day)
end

---Parses release dates in the form "DD Month YYYY".
---@param release_date any
---@return number|nil year
---@return number|nil month
---@return number|nil day
local function parse_release_date(release_date)
	if type(release_date) ~= "string" then
		return nil
	end

	local day, month_name, year = string.match(
		release_date,
		"(%d+)%s+(%a+)%s+(%d%d%d%d)"
	)

	local month = month_name and MONTH_NUMBERS[month_name]

	if not day or not month or not year then
		return nil
	end

	return tonumber(year), month, tonumber(day)
end

---Adds a value to a list stored under a key.
---@param groups table<string, table>
---@param key string
---@param value table
local function add_to_group(groups, key, value)
	if not groups[key] then
		groups[key] = {}
	end

	table.insert(groups[key], value)
end

---Retrieves all update rows for a year.
---@param target_year number
---@return table[]
local function get_updates(target_year)
	local updates = {}
	local offset = 0

	while true do
		local rows = Bucket("update")
			.select(
				"page_name",
				"page_name_sub",
				"date",
				"type",
				"year",
				"month",
				"day"
			)
			.where(
				{ "year", target_year }
			)
			.orderBy("date", "asc")
			.limit(PAGE_SIZE)
			.offset(offset)
			.run()

		if #rows == 0 then
			break
		end

		append_all(updates, rows)

		if #rows < PAGE_SIZE then
			break
		end

		offset = offset + PAGE_SIZE
	end

	return updates
end

---Retrieves quests whose release-date text contains the requested year.
---@param target_year number
---@return table[]
local function get_quests_for_year(target_year)
	local quests = {}
	local year_text = tostring(target_year)

	local rows = Bucket("infobox_quest")
		.select(
			"name",
			"number",
			"image",
			"release",
			"update",
			"members",
			"series",
			"developer"
		)
		.run()

	for _, row in ipairs(rows) do
		if string.find(
				row.release,
				year_text,
				1,
				true
			)
		then
			table.insert(quests, row)
		end
	end

	return quests
end

---Retrieves items whose release-date text contains the requested year.
---@param target_year number
---@return table[]
local function get_items_for_year(target_year)
	local items = {}
	local offset = 0
	local year_text = tostring(target_year)

	while true do
		local rows = Bucket("infobox_item")
			.select(
				"item_name",
				"image",
				"release_date",
				"tradeable",
				"quest",
				"examine",
				"is_members_only"
			)
			.limit(PAGE_SIZE)
			.offset(offset)
			.run()

		if #rows == 0 then
			break
		end

		for _, row in ipairs(rows) do
			if has_valid_name(row.item_name)
				and type(row.release_date) == "string"
				and string.find(
					row.release_date,
					year_text,
					1,
					true
				)
			then
				table.insert(items, row)
			end
		end

		if #rows < PAGE_SIZE then
			break
		end

		offset = offset + PAGE_SIZE
	end

	return items
end

---Retrieves NPCs whose release text contains the requested year.
---@param target_year number
---@return table[]
local function get_npcs_for_year(target_year)
	local npcs = {}
	local offset = 0
	local year_text = tostring(target_year)

	while true do
		local rows = Bucket("infobox_npc")
			.select(
				"npc_name",
				"image",
				"release",
				"is_members_only",
				"examine"
			)
			.limit(PAGE_SIZE)
			.offset(offset)
			.run()

		if #rows == 0 then
			break
		end

		for _, row in ipairs(rows) do
			if has_valid_name(row.npc_name)
				and type(row.release) == "string"
				and string.find(
					row.release,
					year_text,
					1,
					true
				)
			then
				table.insert(npcs, row)
			end
		end

		if #rows < PAGE_SIZE then
			break
		end

		offset = offset + PAGE_SIZE
	end

	return npcs
end

---Retrieves monsters whose release date contains the requested year.
---@param target_year number
---@return table[]
local function get_monsters_for_year(target_year)
	local monsters = {}
	local offset = 0
	local year_text = tostring(target_year)

	while true do
		local rows = Bucket("infobox_monster")
			.select(
				"name",
				"image",
				"release_date",
				"is_members_only",
				"examine",
				"combat_level"
			)
			.limit(PAGE_SIZE)
			.offset(offset)
			.run()

		if #rows == 0 then
			break
		end

		for _, row in ipairs(rows) do
			if has_valid_name(row.name)
				and type(row.release_date) == "string"
				and string.find(
					row.release_date,
					year_text,
					1,
					true
				)
			then
				table.insert(monsters, row)
			end
		end

		if #rows < PAGE_SIZE then
			break
		end

		offset = offset + PAGE_SIZE
	end

	return monsters
end

---Groups updates by their stored calendar date.
---@param updates table[]
---@return table<string, table[]>
local function group_updates_by_date(updates)
	local updates_by_date = {}

	for _, update in ipairs(updates) do
		if update.year and update.month and update.day then
			local date_key = make_date_key(
				update.year,
				update.month,
				update.day
			)

			add_to_group(
				updates_by_date,
				date_key,
				update
			)
		end
	end

	return updates_by_date
end

---Groups valid quest release dates by date.
---@param items table[]
---@return table<string, table[]>
local function group_quests_by_date(items)
	local items_by_date = {}

	for _, quest in ipairs(quests) do
		local year, month, day =
			parse_release_date(quest.release)

		if year and month and day then
			local date_key = make_date_key(
				year,
				month,
				day
			)

			add_to_group(
				quests_by_date,
				date_key,
				quest
			)
		end
	end

	return quests_by_date
end

---Groups valid item release dates by date.
---@param items table[]
---@return table<string, table[]>
local function group_items_by_date(items)
	local items_by_date = {}

	for _, item in ipairs(items) do
		local year, month, day =
			parse_release_date(item.release_date)

		if year and month and day then
			local date_key = make_date_key(
				year,
				month,
				day
			)

			add_to_group(
				items_by_date,
				date_key,
				item
			)
		end
	end

	return items_by_date
end

---Groups valid NPC release dates by date.
---@param npcs table[]
---@return table<string, table[]>
local function group_npcs_by_date(npcs)
	local npcs_by_date = {}

	for _, npc in ipairs(npcs) do
		local year, month, day =
			parse_release_date(npc.release)

		if year and month and day then
			local date_key = make_date_key(
				year,
				month,
				day
			)

			add_to_group(
				npcs_by_date,
				date_key,
				npc
			)
		end
	end

	return npcs_by_date
end

---Groups valid monster release dates by date.
---@param monsters table[]
---@return table<string, table[]>
local function group_monsters_by_date(monsters)
	local monsters_by_date = {}

	for _, monster in ipairs(monsters) do
		local year, month, day =
			parse_release_date(monster.release_date)

		if year and month and day then
			local date_key = make_date_key(
				year,
				month,
				day
			)

			add_to_group(
				monsters_by_date,
				date_key,
				monster
			)
		end
	end

	return monsters_by_date
end

---Sorts quests numerically within each date.
---@param quests_by_date table<string, table[]>
local function sort_quests_by_number(quests_by_date)
	for _, number_quests in pairs(quests_by_date) do
		table.sort(number_quests, function(a, b)
			return a.number < b.number
		end)
	end
end

---Sorts items alphabetically within each date.
---@param items_by_date table<string, table[]>
local function sort_items_by_date(items_by_date)
	for _, date_items in pairs(items_by_date) do
		table.sort(date_items, function(a, b)
			return tostring(a.item_name or "") <
				tostring(b.item_name or "")
		end)
	end
end

---Sorts NPCs alphabetically within each date.
---@param npcs_by_date table<string, table[]>
local function sort_npcs_by_date(npcs_by_date)
	for _, date_npcs in pairs(npcs_by_date) do
		table.sort(date_npcs, function(a, b)
			return tostring(a.npc_name or "") <
				tostring(b.npc_name or "")
		end)
	end
end

---Sorts monsters alphabetically within each date.
---@param monsters_by_date table<string, table[]>
local function sort_monsters_by_date(monsters_by_date)
	for _, date_monsters in pairs(monsters_by_date) do
		table.sort(date_monsters, function(a, b)
			return tostring(a.name or "") <
				tostring(b.name or "")
		end)
	end
end

---Merges NPC records with the same exact name on the same date.
---@param npcs_by_date table<string, table[]>
local function merge_npcs_by_date(npcs_by_date)
	for date_key, date_npcs in pairs(npcs_by_date) do
		local merged = {}
		local by_name = {}

		for _, npc in ipairs(date_npcs) do
			local name = tostring(npc.npc_name)

			if not by_name[name] then
				local merged_npc = {
					npc_name = name,
					image = npc.image,
					is_members_only =
						npc.is_members_only,
					examines = {},
					examine_seen = {},
				}

				by_name[name] = merged_npc
				table.insert(merged, merged_npc)
			end

			local merged_npc = by_name[name]
			local examine = npc.examine

			if examine
				and tostring(examine) ~= ""
			then
				examine = tostring(examine)

				if not merged_npc.examine_seen[
					examine
				]
				then
					table.insert(
						merged_npc.examines,
						examine
					)

					merged_npc.examine_seen[
						examine
					] = true
				end
			end
		end

		for _, npc in ipairs(merged) do
			npc.examine_seen = nil
		end

		npcs_by_date[date_key] = merged
	end
end

---Merges monster records with the same exact name on the same date.
---@param monsters_by_date table<string, table[]>
local function merge_monsters_by_date(monsters_by_date)
	for date_key, date_monsters in pairs(monsters_by_date) do
		local merged = {}
		local by_name = {}

		for _, monster in ipairs(date_monsters) do
			local name = tostring(monster.name)

			if not by_name[name] then
				local merged_monster = {
					name = name,
					image = monster.image,
					is_members_only =
						monster.is_members_only,
					combat_levels = {},
					combat_level_seen = {},
					examines = {},
					examine_by_text = {},
					unique_record_seen = {},
				}

				by_name[name] = merged_monster
				table.insert(
					merged,
					merged_monster
				)
			end

			local merged_monster = by_name[name]

			local combat_level =
				tonumber(monster.combat_level)

			local examine = monster.examine

			if examine ~= nil then
				examine = tostring(examine)
			end

			if examine == "" then
				examine = nil
			end

			local record_key =
				tostring(combat_level or "")
				.. "\001"
				.. tostring(examine or "")

			if not merged_monster.unique_record_seen[
				record_key
			]
			then
				merged_monster.unique_record_seen[
					record_key
				] = true

				if combat_level
					and not merged_monster.combat_level_seen[
						combat_level
					]
				then
					table.insert(
						merged_monster.combat_levels,
						combat_level
					)

					merged_monster.combat_level_seen[
						combat_level
					] = true
				end

				if examine then
					if not merged_monster.examine_by_text[
						examine
					]
					then
						local examine_entry = {
							text = examine,
							levels = {},
							level_seen = {},
						}

						merged_monster.examine_by_text[
							examine
						] = examine_entry

						table.insert(
							merged_monster.examines,
							examine_entry
						)
					end

					local examine_entry =
						merged_monster.examine_by_text[
							examine
						]

					if combat_level
						and not examine_entry.level_seen[
							combat_level
						]
					then
						table.insert(
							examine_entry.levels,
							combat_level
						)

						examine_entry.level_seen[
							combat_level
						] = true
					end
				end
			end
		end

		for _, monster in ipairs(merged) do
			table.sort(
				monster.combat_levels,
				function(a, b)
					return a < b
				end
			)

			for _, examine_entry in ipairs(
				monster.examines
			) do
				table.sort(
					examine_entry.levels,
					function(a, b)
						return a < b
					end
				)

				examine_entry.level_seen = nil
			end

			monster.combat_level_seen = nil
			monster.examine_by_text = nil
			monster.unique_record_seen = nil
		end

		monsters_by_date[date_key] = merged
	end
end

---Creates a sorted union of all dates containing data.
---@param updates_by_date table<string, table[]>
---@param items_by_date table<string, table[]>
---@param npcs_by_date table<string, table[]>
---@param monsters_by_date table<string, table[]>
---@return string[]
local function get_sorted_dates(
	updates_by_date,
	items_by_date,
	npcs_by_date,
	monsters_by_date
)
	local dates = {}
	local seen_dates = {}

	for date_key in pairs(updates_by_date) do
		seen_dates[date_key] = true
	end

	for date_key in pairs(items_by_date) do
		seen_dates[date_key] = true
	end

	for date_key in pairs(npcs_by_date) do
		seen_dates[date_key] = true
	end

	for date_key in pairs(monsters_by_date) do
		seen_dates[date_key] = true
	end

	for date_key in pairs(seen_dates) do
		table.insert(dates, date_key)
	end

	table.sort(dates)

	return dates
end

---Returns the last image filename from a repeated image field.
---@param image_value any
---@return string|nil
local function get_last_image(image_value)
	if type(image_value) == "table"
		and #image_value > 0
	then
		return image_value[#image_value]
	end

	if type(image_value) == "string"
		and image_value ~= ""
	then
		return image_value
	end

	return nil
end

---Normalizes an item image name for the plinkp template.
---@param image any
---@return string|nil
local function normalize_item_image(image)
	if image == nil then
		return nil
	end

	image = tostring(image)

	-- Remove a leading File: if Bucket included it.
	image = string.gsub(image, "^File:", "")

	-- plinkp supplies the file extension itself.
	image = string.gsub(image, "%.png$", "")

	if image == "" then
		return nil
	end

	return image
end

---Builds the item image using the plinkp template.
---@param image_value any
---@param name string
---@return string
local function build_item_image(image_value, name)
	if not name or name == "" then
		return ""
	end

	local image = get_last_image(image_value)
	image = normalize_item_image(image)

	if not image then
		return ""
	end

	local frame = mw.getCurrentFrame()

	return frame:expandTemplate{
		title = "plinkp",
		args = {
			[1] = name,
			pic = image,
		},
	}
end

---Removes a leading "File:" from an NPC/monster image value.
---@param image any
---@return string|nil
local function normalize_npc_monster_image(image)
	if image == nil then
		return nil
	end

	image = tostring(image)

	image = string.gsub(
		image,
		"^File:",
		""
	)

	return image
end

---Builds an NPC/monster image using native MediaWiki image syntax.
---@param image_value any
---@param name string
---@return string
local function build_npc_monster_image(
	image_value,
	name
)
	if not image_value
		or not name
		or name == ""
	then
		return ""
	end

	local image = get_last_image(image_value)

	if not image or image == "" then
		return ""
	end

	image = normalize_npc_monster_image(image)

	if not image then
		return ""
	end

	return "[[File:"
		.. image
		.. "|link="
		.. name
		.. "|50px]]"
end

---Returns the membership icon using the wiki's Members template.
---@param value any
---@return string
local function get_members_icon(value)
	local frame = mw.getCurrentFrame()

	if is_enabled(value) then
		return frame:expandTemplate{
			title = "Members",
			args = {
				[1] = "yes",
			},
		}
	end

	return frame:expandTemplate{
		title = "Members",
		args = {
			[1] = "no",
		},
	}
end

---Returns a theme-aware N/A value.
---@return string
local function get_na_value()
	return '<span style="'
		.. "color:var(--color-subtle, #72777d);"
		.. "background-color:var(--background-color-neutral-subtle, #f8f9fa);"
		.. "padding:1px 4px;"
		.. 'border-radius:2px;'
		.. '">N/A</span>'
end

---Returns the quest field as normal text or a bulleted list.
---@param quest any
---@return string
local function format_item_quests(quest)
	local quests = {}
	local seen = {}

	if quest == nil then
		return get_na_value()
	end

	local function add_quest(value)
		if value == nil then
			return
		end

		local text = tostring(value)

		text = string.gsub(text, "^%s+", "")
		text = string.gsub(text, "%s+$", "")

		if text == ""
			or text:lower() == "no"
			or string.sub(
				text:lower(),
				1,
				4
			) == "null"
		then
			return
		end

		if not seen[text] then
			table.insert(
				quests,
				text
			)

			seen[text] = true
		end
	end

	if type(quest) == "table" then
		for _, value in ipairs(quest) do
			if type(value) == "string" then
				for part in string.gmatch(
					value,
					"[^,]+"
				) do
					add_quest(part)
				end
			else
				add_quest(value)
			end
		end
	else
		for part in string.gmatch(
			tostring(quest),
			"[^,]+"
		) do
			add_quest(part)
		end
	end

	if #quests == 0 then
		return get_na_value()
	end

	if #quests == 1 then
		return quests[1]
	end

	local output = {
		'<ul style="margin:0;padding-left:1.5em;">'
	}

	for _, quest_name in ipairs(quests) do
		table.insert(
			output,
			"<li>" .. quest_name .. "</li>"
		)
	end

	table.insert(
		output,
		"</ul>"
	)

	return table.concat(output, "")
end

---Adds all updates for one date.
---@param output string[]
---@param updates table[]
local function add_updates(output, updates)
	if #updates == 0 then
		return
	end

	for _, update in ipairs(updates) do
		if update.page_name ~= nil then
			local page_name =
				tostring(update.page_name)

			if page_name ~= ""
				and string.sub(
					page_name:lower(),
					1,
					4
				) ~= "null"
			then
				local display_name = page_name

				if update.page_name_sub ~= nil then
					local sub_name =
						tostring(
							update.page_name_sub
						)

					if sub_name ~= ""
						and string.sub(
							sub_name:lower(),
							1,
							4
						) ~= "null"
					then
						display_name = sub_name
					end
				end

				table.insert(
					output,
					"* [["
						.. page_name
						.. "|"
						.. display_name
						.. "]]"
				)
			end
		end
	end
end

---Adds the quest table for one date.
---@param output string[]
---@param items table[]
local function add_quest_table(output, quests)
	if #quests == 0 then
		return
	end

	table.insert(
		output,
		"'''Quests'''"
	)

	table.insert(
		output,
		'{| class="wikitable lighttable individual"'
	)

	table.insert(
		output,
		'! colspan="2" | Quest'
	)

	for _, quest in ipairs(quests) do
		local name =
			tostring(quest.name or "")

		table.insert(
			output,
			"|-\n"
				.. "| [["
				.. name
				.. "]]\n"
				.. "| "
				.. "{{Infobox Quest\n"
				.. "|name = "
				.. name
				.. "\n|number = "
				.. quest.number
				.. "\n|image = "
				.. quest.image
				.. "\release = "
				.. quest.release
				.. "\n|update = "
				.. quest.update
				.. "\n|members = "
				.. quest.members
				.. "\n|series = "
				.. quest.series
				.. "\n|developer = "
				.. quest.developer
				.. "\n}}"
		)
	end

	table.insert(
		output,
		"|}"
	)
end

---Adds the item table for one date.
---@param output string[]
---@param items table[]
local function add_item_table(output, items)
	if #items == 0 then
		return
	end

	table.insert(
		output,
		"'''Items'''"
	)

	table.insert(
		output,
		'{| class="wikitable sortable lighttable qc-active"'
	)

	table.insert(
		output,
		'! colspan="2" | Item !! Examine !! Quest !! Tradeable !! Members'
	)

	for _, item in ipairs(items) do
		local name =
			tostring(item.item_name or "")

		local examine =
			tostring(item.examine or "")

		local examine_cell =
			'<div style="max-width:24ch;overflow-wrap:anywhere;">'
			.. examine
			.. "</div>"

		local quest_cell =
			format_item_quests(item.quest)

		local tradeable =
			tostring(item.tradeable or "")

		table.insert(
			output,
			"|-\n"
				.. "| "
				.. build_item_image(
					item.image,
					name
				)
				.. "\n"
				.. "| [["
				.. name
				.. "]]\n"
				.. "| "
				.. examine_cell
				.. "\n"
				.. "| "
				.. quest_cell
				.. "\n"
				.. "| "
				.. tradeable
				.. "\n"
				.. "| "
				.. get_members_icon(
					item.is_members_only
				)
		)
	end

	table.insert(
		output,
		"|}"
	)
end

---Adds the NPC table for one date.
---@param output string[]
---@param npcs table[]
local function add_npc_table(output, npcs)
	if #npcs == 0 then
		return
	end

	table.insert(
		output,
		"'''NPCs'''"
	)

	table.insert(
		output,
		'{| class="wikitable sortable lighttable qc-active"'
	)

	table.insert(
		output,
		"! Image !! Name !! Members !! Examine"
	)

	for _, npc in ipairs(npcs) do
		local name =
			tostring(npc.npc_name or "")

		local examine_output = ""

		if #(npc.examines or {}) == 1 then
			examine_output =
				npc.examines[1]

		elseif #(npc.examines or {}) > 1 then
			examine_output = "<ul>"

			for _, examine in ipairs(
				npc.examines
			) do
				examine_output =
					examine_output
					.. "<li>"
					.. examine
					.. "</li>"
			end

			examine_output =
				examine_output .. "</ul>"
		end

		table.insert(
			output,
			"|-\n"
				.. "| "
				.. build_npc_monster_image(
					npc.image,
					name
				)
				.. "\n"
				.. "| [["
				.. name
				.. "]]\n"
				.. "| "
				.. get_members_icon(
					npc.is_members_only
				)
				.. "\n"
				.. "| "
				.. examine_output
		)
	end

	table.insert(
		output,
		"|}"
	)
end

---Formats a list of combat levels.
---@param levels number[]
---@return string
local function format_combat_levels(levels)
	local values = {}

	for _, level in ipairs(levels or {}) do
		table.insert(
			values,
			tostring(level)
		)
	end

	return table.concat(
		values,
		", "
	)
end

---Formats a monster examine entry.
---@param examine_entry table
---@param show_levels boolean
---@return string
local function format_monster_examine(
	examine_entry,
	show_levels
)
	local text =
		tostring(examine_entry.text or "")

	if not show_levels then
		return text
	end

	local levels =
		examine_entry.levels or {}

	if #levels == 0 then
		return "<li>"
			.. text
			.. "</li>"
	end

	local level_values = {}

	for _, level in ipairs(levels) do
		table.insert(
			level_values,
			tostring(level)
		)
	end

	local level_text =
		table.concat(
			level_values,
			", "
		)

	local label = "level"

	if #levels > 1 then
		label = "levels"
	end

	return '<li>'
		.. text
		.. ' <span style="'
		.. 'color:var(--color-subtle, #72777d);'
		.. 'font-size:90%;'
		.. '">'
		.. "("
		.. label
		.. " "
		.. level_text
		.. ")"
		.. "</span></li>"
end

---Adds the monster table for one date.
---@param output string[]
---@param monsters table[]
local function add_monster_table(output, monsters)
	if #monsters == 0 then
		return
	end

	table.insert(
		output,
		"'''Monsters'''"
	)

	table.insert(
		output,
		'{| class="wikitable sortable lighttable qc-active"'
	)

	table.insert(
		output,
		"! Image !! Name !! Members !! Combat level !! Examine"
	)

	for _, monster in ipairs(monsters) do
		local name =
			tostring(monster.name or "")

		local examine_count =
			#(monster.examines or {})

		local examine_output = ""

		if examine_count == 1 then
			examine_output =
				format_monster_examine(
					monster.examines[1],
					false
				)

		elseif examine_count > 1 then
			examine_output = "<ul>"

			for _, examine_entry in ipairs(
				monster.examines
			) do
				examine_output =
					examine_output
					.. format_monster_examine(
						examine_entry,
						true
					)
			end

			examine_output =
				examine_output .. "</ul>"
		end

		table.insert(
			output,
			"|-\n"
				.. "| "
				.. build_npc_monster_image(
					monster.image,
					name
				)
				.. "\n"
				.. "| [["
				.. name
				.. "]]\n"
				.. "| "
				.. get_members_icon(
					monster.is_members_only
				)
				.. "\n"
				.. "| "
				.. format_combat_levels(
					monster.combat_levels
				)
				.. "\n"
				.. "| "
				.. examine_output
		)
	end

	table.insert(
		output,
		"|}"
	)
end

---Adds NPC and monster tables side-by-side.
---@param output string[]
---@param npcs table[]
---@param monsters table[]
local function add_npc_and_monster_tables(
	output,
	npcs,
	monsters
)
	if #npcs == 0
		and #monsters == 0
	then
		return
	end

	table.insert(
		output,
		'<div style="display:flex;flex-wrap:wrap;gap:1em;align-items:flex-start;">'
	)

	if #npcs > 0 then
		table.insert(
			output,
			"<div>"
		)

		add_npc_table(
			output,
			npcs
		)

		table.insert(
			output,
			"</div>"
		)
	end

	if #monsters > 0 then
		table.insert(
			output,
			"<div>"
		)

		add_monster_table(
			output,
			monsters
		)

		table.insert(
			output,
			"</div>"
		)
	end

	table.insert(
		output,
		"</div>"
	)
end

function p.main(frame)
	local args = frame.args

	local target_year =
		tonumber(args.targetyear) or 2006

	local updates =
		get_updates(target_year)
		
	local quests =
		get_quests_for_year(target_year)

	local items =
		get_items_for_year(target_year)

	local npcs =
		get_npcs_for_year(target_year)

	local monsters =
		get_monsters_for_year(target_year)

	local updates_by_date =
		group_updates_by_date(updates)
		
	local quests_by_date =
		group_quests_by_date(quests)

	local items_by_date =
		group_items_by_date(items)

	local npcs_by_date =
		group_npcs_by_date(npcs)

	local monsters_by_date =
		group_monsters_by_date(monsters)

	merge_npcs_by_date(
		npcs_by_date
	)

	merge_monsters_by_date(
		monsters_by_date
	)
	
	sort_quests_by_number(
		quests_by_date
	)

	sort_items_by_date(
		items_by_date
	)

	sort_npcs_by_date(
		npcs_by_date
	)

	sort_monsters_by_date(
		monsters_by_date
	)

	local dates =
		get_sorted_dates(
			updates_by_date,
			items_by_date,
			npcs_by_date,
			monsters_by_date
		)

	local output = {
		"'''Year: "
			.. tostring(target_year)
			.. "'''",
	}

	for _, date_key in ipairs(dates) do
		local year, month, day =
			parse_date_key(date_key)

		local date_updates =
			updates_by_date[date_key]
			or {}
		
		local date_quests =
			quests_by_date[date_key]
			or {}

		local date_items =
			items_by_date[date_key]
			or {}

		local date_npcs =
			npcs_by_date[date_key]
			or {}

		local date_monsters =
			monsters_by_date[date_key]
			or {}

		local month_name =
			MONTH_NAMES[month]
			or tostring(month)

		table.insert(
			output,
			"=== "
				.. tostring(day)
				.. " "
				.. tostring(month_name)
				.. " "
				.. tostring(year)
				.. " ==="
		)

		add_updates(
			output,
			date_updates
		)
		
		add_quest_table(
			output,
			date_quests
		)

		add_item_table(
			output,
			date_items
		)

		add_npc_and_monster_tables(
			output,
			date_npcs,
			date_monsters
		)
	end

	return table.concat(
		output,
		"\n"
	)
end

return p