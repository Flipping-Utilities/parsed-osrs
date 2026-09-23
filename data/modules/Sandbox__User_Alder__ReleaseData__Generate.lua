local p = {}

local Bucket = mw.ext.bucket
local dpl = require("Module:DPLlua")

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

local ITEM_FIELDS = {
	"page_name",
	"item_name",
	"image",
	"is_members_only",
	"examine",
	"high_alchemy_value",
	"release_date",
	"removal_date",
	"value",
	"weight",
	"quest",
	"tradeable"
}

local NPC_FIELDS = {
	"page_name",
	"npc_name",
	"image",
	"is_members_only",
	"release",
	"examine",
	"location",
	"quest"
}

local MONSTER_FIELDS = {
	"page_name",
	"name",
	"image",
	"is_members_only",
	"examine",
	"release_date",
	"combat_level",
	"attribute",
	"hitpoints"
}

local UPDATE_FIELDS = {
	"page_name",
	"type",
	"year",
	"month",
	"day"
}

local adjusted_dates = {
	npcs = {
		["Smithing catalyst (Blast Furnace)"] = "2005-08-23",
		["Captain Errdo"] = "2006-08-07",
		["Child"] = "2004-03-29",
		["Dog (NPC)"] = "2004-03-15",
		["Gnome (A Tail of Two Cats)"] = "2005-09-26",
		["Mourner (Biohazard)"] = "2004-03-15",
		["Mourner (Plague City)"] = "2004-03-15",
		["Soldier (Lizardman kill count)"] = "2016-01-07",
		["Parrot (Sailing alpha)"] = "2025-03-20",
		["Hammerhead shark"] = "2025-11-19",
	},
	music = {
		["Ambience 2"] = "2004-03-15",
		["Ambience 3"] = "2004-03-15",
		["Ambience 4"] = "2004-03-15",
		["Athletes Foot"] = "2005-08-09",
		["Autumn in Bridgelum"] = "2006-01-10",
		["Elf Singing"] = "2004-09-20",
		["Emperor"] = "2004-03-15",
		["Expedition"] = "2004-03-15",
		["Flamtaer Restored"] = "2004-10-18",
		["Game Intro 1"] = "2004-03-15",
		["Lonesome"] = "2004-03-15",
		["Oh Dear!"] = "2004-03-15",
		["Quest Complete 1"] = "2004-03-15",
		["Quest Complete 2"] = "2004-03-15",
		["Quest Complete 3"] = "2004-03-15",
		["Scape Soft"] = "2004-03-15",
		["Shining"] = "2004-03-15",
		["Start"] = "2004-03-15",
		["Talking Forest"] = "2004-03-15",
		["Theme"] = "2004-03-15",
		["Tomorrow"] = "2004-03-15",
		["Yesteryear"] = "2004-03-15",
	},
}

local function identity(value)
	return value
end

local function strip_brackets(value)
	if type(value) ~= "string" then
		return value
	end

	value = value:gsub("^%[%[", "")
	value = value:gsub("%]%]$", "")

	local pipe = string.find(value, "|", 1, true)

	if pipe then
		value = string.sub(value, 1, pipe - 1)
	end

	return value
end

local function has_valid_name(name)
	return type(name) == "string"
		and name ~= ""
		and name ~= "null"
		and not string.find(name, "[%[%]]")
end

local function parse_links(value)
	local result = {}

	if type(value) ~= "string" then
		return result
	end

	for link in string.gmatch(value, "%[%[(.-)%]%]") do
		local pipe = string.find(link, "|", 1, true)

		if pipe then
			link = string.sub(link, 1, pipe - 1)
		end

		if link ~= "" then
			table.insert(result, link)
		end
	end

	return result
end

local function parse_date(date)
	if type(date) ~= "string" or date == "" then
		return nil
	end

	date = date:gsub("%[%[", "")
	date = date:gsub("%]%]", "")

	local day, month, year =
		string.match(
			date,
			"^(%d+) (%a+) (%d%d%d%d)$"
		)

	local month_number = MONTH_NUMBERS[month]

	if not day or not month_number or not year then
		return nil
	end

	return string.format(
		"%04d-%02d-%02d",
		tonumber(year),
		month_number,
		tonumber(day)
	)
end

local field_transforms = {
	npcs = {
		image = strip_brackets,
		quest = parse_links,
	},
}

local function make_transform(
	year,
	adjusted_dates,
	field_transforms,
	name_field,
	date_field
)
	return function(row)
		local date = parse_date(row[date_field])

		if not date and adjusted_dates then
			date = adjusted_dates[row[name_field]]
		end

		if not date
			or string.sub(date, 1, 4) ~= tostring(year)
		then
			return nil
		end

		local record = {}

		for key, value in pairs(row) do
			local transform = field_transforms
				and field_transforms[key]
				or identity

			record[key] = transform(value)
		end

		record.date = date
		record[date_field] = nil

		return record
	end
end

local function get_from_bucket(bucket, fields, transform)
	local records = {}
	local offset = 0

	while true do
		local results = Bucket(bucket)
			.select(unpack(fields))
			.limit(PAGE_SIZE)
			.offset(offset)
			.run()

		if #results == 0 then
			break
		end

		for _, row in ipairs(results) do
			local record = transform(row)

			if record then
				local date = record.date
				record.date = nil -- omit from record, since we're grouping
				
				if records[date] == nil then
					records[date] = {}
				end
				
				table.insert(records[date], record)
			end
		end

		if #results < PAGE_SIZE then
			break
		end

		offset = offset + PAGE_SIZE
	end

	return records
end

-- groups by date, then by the given fields
local function group_by_fields(records, fields)
	local grouped = {}

	for date, date_records in pairs(records) do
		grouped[date] = {}

		for _, record in ipairs(date_records) do
			local current = grouped[date]

			for _, field in ipairs(fields) do
				local value = record[field]

				if current[value] == nil then
					current[value] = {}
				end

				current = current[value]
			end

			table.insert(current, record)
		end
	end

	return grouped
end

local function values_equal(a, b)
	if type(a) ~= type(b) then
		return false
	end

	if type(a) ~= "table" then
		return a == b
	end

	for key, value in pairs(a) do
		if not values_equal(value, b[key]) then
			return false
		end
	end

	for key, value in pairs(b) do
		if not values_equal(value, a[key]) then
			return false
		end
	end

	return true
end

local function remove_duplicates(records, fields)
	local result = {}

	for date, date_records in pairs(records) do
		result[date] = {}

		for _, record in ipairs(date_records) do
			local duplicate = false

			for _, existing in ipairs(result[date]) do
				local same = true

				for _, field in ipairs(fields) do
					if not values_equal(record[field], existing[field]) then
						same = false
						break
					end
				end

				if same then
					duplicate = true
					break
				end
			end

			if not duplicate then
				table.insert(result[date], record)
			end
		end
	end

	return result
end

local function get_items(year)
	return get_from_bucket(
		"infobox_item",
		ITEM_FIELDS,
		make_transform(year, adjusted_dates.items, field_transforms.items, "item_name", "release_date")
	)
end

local function get_npcs(year)
	local records = get_from_bucket(
		"infobox_npc",
		NPC_FIELDS,
		make_transform(year, adjusted_dates.npcs, field_transforms.npcs, "page_name", "release")
	)
	return group_by_fields(records, {"page_name"})
end

local function get_monsters(year)
	local records = get_from_bucket(
		"infobox_monster",
		MONSTER_FIELDS,
		make_transform(year, adjusted_dates.monsters, field_transforms.monsters, "page_name", "release_date")
	)
	records = remove_duplicates(records, {
		"page_name", "name", "combat_level", "hitpoints", "examine", "image"
	})

	return group_by_fields(records, {"page_name", "combat_level"})
end

local function get_quests(year)
	local quests = {}
	local seen_numbers = {}

	local results = dpl.ask({
		uses = "Template:Infobox Quest",
		include = "{Infobox Quest}",
		count = PAGE_SIZE,
		ordermethod = "title",
	})

	for _, row in ipairs(results) do
		local template = row.include
			and row.include["Infobox Quest"]

		if template then
			local name = template.name
			local number = template.number
			local release = template.release

			if has_valid_name(name)
				and number
				and number ~= ""
				and number ~= "null"
				and not seen_numbers[number]
			then
				local date = parse_date(release)

				if date
					and string.sub(date, 1, 4) == tostring(year)
				then
					seen_numbers[number] = true

					if quests[date] == nil then
						quests[date] = {}
					end

					if quests[date][name] == nil then
						quests[date][name] = {}
					end

					table.insert(quests[date][name], {
						number = strip_brackets(number),
						image = strip_brackets(template.image),
						members = strip_brackets(template.members),
						series = strip_brackets(template.series),
						developer = strip_brackets(template.developer),
						update = strip_brackets(template.update),
						aka = strip_brackets(template.aka),
						difficulty = strip_brackets(template.difficulty),
					})
				end
			end
		end
	end

	return quests
end

local function get_locations(year)
	local locations = {}
	local seen_names = {}

	local results = dpl.ask({
		uses = "Template:Infobox Location",
		include = "{Infobox Location}",
		count = PAGE_SIZE,
		ordermethod = "title",
	})

	for _, row in ipairs(results) do
		local template = row.include
			and row.include["Infobox Location"]

		if template then
			local name = template.name
			local release = template.release

			if has_valid_name(name)
				and not seen_names[name]
			then
				local date = parse_date(release)

				if date
					and string.sub(date, 1, 4) == tostring(year)
				then
					seen_names[name] = true

					if locations[date] == nil then
						locations[date] = {}
					end

					locations[date][name] = {
						image = strip_brackets(template.image),
						removal = strip_brackets(template.removal),
						members = strip_brackets(template.members),
						type = strip_brackets(template.type),
					}
				end
			end
		end
	end

	return locations
end

local function get_music(year)
	local music = {}
	local seen_names = {}

	local results = dpl.ask({
		uses = "Template:Infobox Music",
		include = "{Infobox Music}",
		count = PAGE_SIZE,
		ordermethod = "title",
	})

	for _, row in ipairs(results) do
		local template = row.include
			and row.include["Infobox Music"]

		if template then
			local name = template.name
			local release = template.release

			if has_valid_name(name)
				and not seen_names[name]
			then
				local date = parse_date(release)

				if not date then
					date = adjusted_dates.music[name]
				end

				if date
					and string.sub(date, 1, 4) == tostring(year)
				then
					seen_names[name] = true

					if music[date] == nil then
						music[date] = {}
					end

					music[date][name] = {
						number = strip_brackets(template.number),
						file = strip_brackets(template.file),
						removal = strip_brackets(template.removal),
						members = strip_brackets(template.members),
						location = strip_brackets(template.location),
						hint = strip_brackets(template.hint),
						duration = strip_brackets(template.duration),
						composer = strip_brackets(template.composer),
					}
				end
			end
		end
	end

	return music
end

local function get_updates(year)
	return get_from_bucket(
		"update",
		UPDATE_FIELDS,
		-- function(row)
		-- 	-- update bucket doesn't have a single date field, so transform manually here
		-- 	local update_year = tonumber(row.year)
		-- 	local month_number = MONTH_NUMBERS[row.month]
		-- 	local day = tonumber(row.day)

		-- 	if not update_year
		-- 		or not month_number
		-- 		or not day
		-- 		or update_year ~= tonumber(year)
		-- 	then
		-- 		return nil
		-- 	end

		-- 	return {
		-- 		page_name = strip_brackets(row.page_name),
		-- 		type = strip_brackets(row.type),
		-- 		date = string.format(
		-- 			"%04d-%02d-%02d",
		-- 			update_year,
		-- 			month_number,
		-- 			day
		-- 		),
		-- 	}
		function(row)
			return {
				page_name = row.page_name,
				type = row.type,
				year = row.year,
				month = row.month,
				day = row.day,
				date = "2001-01-01",
			}
		end
	)
end

local function get_god_letters(year)
	-- TODO: Query God letters released during this year.
	return {}
end

local function get_lore(year)
	-- TODO: Query lore released during this year.
	return {}
end

local function get_polls(year)
	local polls = {}
	local seen_ids = {}

	local results = dpl.ask({
		uses = "Template:PollNotice",
		include = "{PollNotice}",
		count = PAGE_SIZE,
		ordermethod = "title",
	})

	for _, row in ipairs(results) do
		local title = row.title
		local template = row.include
			and row.include.PollNotice

		if title and template then
			local poll_id
			local release_date

			if year < 2013 then
				-- Archived poll format:
				-- {{PollNotice|Archive|ID|Date}}
				poll_id = template[2]
				release_date = template[3]
			else
				-- Modern poll format:
				-- {{PollNotice|ID|Open date|Close date}}
				poll_id = template[1]
				release_date = template[2]
			end

			local date = parse_date(release_date)

			if poll_id
				and date
				and string.sub(date, 1, 4) == tostring(year)
				and not seen_ids[poll_id]
			then
				seen_ids[poll_id] = true

				if polls[date] == nil then
					polls[date] = {}
				end

				table.insert(polls[date], {
					name = strip_brackets(title),
					id = strip_brackets(poll_id),
				})
			end
		end
	end

	return polls
end

local function aggregate_by_release_date(template)
	local releases = {}
	local has_numbered_release = false

	for key, release in pairs(template) do
		local index = string.match(key, "^release(%d+)$")

		if index and release then
			has_numbered_release = true
			index = tonumber(index)

			local date = parse_date(release)

			if date then
				if releases[date] == nil then
					releases[date] = {}
				end

				table.insert(releases[date], index)
			end
		end
	end

	if not has_numbered_release then
		local date = parse_date(template.release)

		if date then
			releases[date] = {0}
		end
	end

	for _, indices in pairs(releases) do
		table.sort(indices)
	end

	return releases
end

local function get_construction(year)
	local construction = {}

	local results = dpl.ask({
		uses = "Template:Infobox Construction",
		include = "{Infobox Construction}",
		count = PAGE_SIZE,
		ordermethod = "title",
	})

	for _, row in ipairs(results) do
		local template = row.include
			and row.include["Infobox Construction"]

		if template then
			local releases = aggregate_by_release_date(template)

			for date, indices in pairs(releases) do
				if string.sub(date, 1, 4) == tostring(year) then
					if construction[date] == nil then
						construction[date] = {}
					end

					local record = {}

					-- Copy all template fields into the record.
					--
					-- Numbered fields are collected from every version
					-- belonging to this release date.
					-- Unnumbered fields are shared by all versions.
					local numbered_fields = {}

					for key, value in pairs(template) do
						local field, index =
							string.match(key, "^(.+)(%d+)$")

						if field and index then
							numbered_fields[field] = true
						end
					end

					for key, value in pairs(template) do
						local field, index =
							string.match(key, "^(.+)(%d+)$")

						if field and index then
							index = tonumber(index)

							-- Only include this numbered value if
							-- it belongs to this release-date group.
							for _, release_index in ipairs(indices) do
								if index == release_index then
									if record[field] == nil then
										record[field] = {}
									end

									table.insert(
										record[field],
										strip_brackets(value)
									)

									break
								end
							end
						elseif not numbered_fields[key] then
							-- This is an unnumbered/shared field.
							record[key] = strip_brackets(value)
						end
					end

					-- If a version-specific field has only one value,
					-- store it as a scalar rather than a one-element list.
					for field, value in pairs(record) do
						if type(value) == "table"
							and #value == 1
						then
							record[field] = strip_brackets(value[1])
						end
					end

					-- Use the normalized release date as the record's
					-- release field.
					record.release = date

					table.insert(
						strip_brackets(construction[date]),
						record
					)
				end
			end
		end
	end

	return construction
end

local function get_postbag(year)
	-- TODO: Query Postbag from the Hedge entries released during this year.
	return {}
end

local function get_players_gallery_transcripts(year)
	-- TODO: Query Players' Gallery transcripts released during this year.
	return {}
end

local function ensure_date(data, date)
	if data[date] == nil then
		data[date] = {}
	end

	return data[date]
end

local function merge_type(data, data_type, entries)
	for date, values in pairs(entries) do
		local date_data = ensure_date(data, date)
		date_data[data_type] = values
	end
end

local function is_array(value)
	if type(value) ~= "table" then
		return false
	end

	local count = 0

	for key, _ in pairs(value) do
		if type(key) ~= "number"
			or key < 1
			or key % 1 ~= 0
		then
			return false
		end

		count = count + 1
	end

	for i = 1, count do
		if value[i] == nil then
			return false
		end
	end

	return true
end

local function serialize_value(value, indent)
	local value_type = type(value)

	if value_type == "string" then
		return string.format("%q", value)

	elseif value_type == "number"
		or value_type == "boolean"
	then
		return tostring(value)

	elseif value_type == "nil" then
		return "nil"

	elseif value_type ~= "table" then
		error(
			"Cannot serialize value of type "
				.. value_type
		)
	end

	local parts = {}
	local next_indent = indent + 1
	local prefix = string.rep("\t", next_indent)

	if is_array(value) then
		for i = 1, #value do
			table.insert(
				parts,
				prefix
					.. serialize_value(
						value[i],
						next_indent
					)
			)
		end
	else
		local keys = {}

		for key, _ in pairs(value) do
			table.insert(keys, key)
		end

		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)

		for _, key in ipairs(keys) do
			local key_string

			if type(key) == "string"
				and string.match(
					key,
					"^[%a_][%w_]*$"
				)
			then
				key_string = key
			else
				key_string =
					"["
					.. serialize_value(key, next_indent)
					.. "]"
			end

			table.insert(
				parts,
				prefix
					.. key_string
					.. " = "
					.. serialize_value(
						value[key],
						next_indent
					)
			)
		end
	end

	return "{\n"
		.. table.concat(parts, ",\n")
		.. "\n"
		.. string.rep("\t", indent)
		.. "}"
end

local function serialize(data)
	return "return " .. serialize_value(data, 0)
end

local function generate(year)
	year = tonumber(year)

	if year == nil then
		error("ReleaseData/Generate requires a valid year")
	end

	year = math.floor(year)

	local data = {}

	-- Temporarily disabled while testing individual data types.
	-- merge_type(data, "items", get_items(year))
	-- merge_type(data, "npcs", get_npcs(year))
	-- merge_type(data, "monsters", get_monsters(year))
	-- merge_type(data, "quests", get_quests(year))
	-- merge_type(data, "locations", get_locations(year))
	-- merge_type(data, "construction", get_construction(year))
	-- merge_type(data, "music", get_music(year))

	merge_type(data, "updates", get_updates(year))

	-- merge_type(data, "god_letters", get_god_letters(year))
	-- merge_type(data, "lore", get_lore(year))
	-- merge_type(data, "polls", get_polls(year))
	-- merge_type(data, "postbag", get_postbag(year))
	-- merge_type(
	-- 	data,
	-- 	"players_gallery_transcripts",
	-- 	get_players_gallery_transcripts(year)
	-- )

	return serialize(data)
end

function p.generate(frame)
	local args = frame.args

	local year =
		args.year
		or args[1]
		or frame

	return generate(year)
end

local function debug_bad_dates()
	local bad = {}
	local offset = 0

	while true do
		local results = Bucket("infobox_monster")
			.select(
				"name",
				"page_name",
				"release_date"
			)
			.limit(PAGE_SIZE)
			.offset(offset)
			.run()

		if #results == 0 then
			break
		end

		for _, result in pairs(results) do
			if has_valid_name(result.name) then
				local release_date = result.release_date
				local date = parse_date(release_date)
				local page_name = result.page_name

				if not date then
					table.insert(
						bad,
						"<tr>" ..
						"<td>[[" .. result.page_name .. "]]</td>" ..
						"<td>" .. tostring(release_date) .. "</td>" ..
						"</tr>"
					)
				end
			end
		end

		if #results < PAGE_SIZE then
			break
		end

		offset = offset + PAGE_SIZE
	end

	return
		'<table class="wikitable">' ..
		'<tr><th>Name</th><th>Release date</th></tr>' ..
		table.concat(bad, "\n") ..
		'</table>'
end

function p.debug_bad_dates(frame)
	return debug_bad_dates()
end

return p