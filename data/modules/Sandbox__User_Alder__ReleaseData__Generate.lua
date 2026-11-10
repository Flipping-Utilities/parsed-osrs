local p = {}

local Bucket = mw.ext.bucket
local dpl = require("Module:DPLlua")
local videos = mw.loadData("Module:Sandbox/User:Alder/ReleaseData/Videos")
local livestreams = mw.loadData("Module:Sandbox/User:Alder/ReleaseData/Livestreams")
local lore_data = mw.loadData("Module:Sandbox/User:Alder/ReleaseData/Lore")

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
	"item_id",
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
	"npc_id",
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
	"id",
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

-- Adjusting unknown dates for approximate release
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
	monsters = {
		["Bedabin Nomad Fighter"] = "2004-10-14",
		["Wild dog (Last Man Standing)"] = "2016-08-04"
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

local function ensure_date(data, date)
	if data[date] == nil then
		data[date] = {}
	end

	return data[date]
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

local function to_string_array(value)
    if value == nil then
        return {}
    end

    if type(value) ~= "table" then
        value = { value }
    end

    local result = {}

    for _, item in ipairs(value) do
        if item ~= nil then
            table.insert(result, tostring(item))
        end
    end

    return result
end

local field_transforms = {
    items = {
        item_id = to_string_array,
    },
    npcs = {
        image = strip_brackets,
        quest = parse_links,
        npc_id = to_string_array,
    },
    monsters = {
        id = to_string_array,
    },
}

local function make_transform(
	year,
	adjusted_dates,
	field_transforms,
	name_field,
	date_field,
	data_type
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

		record[date_field] = nil

		-- Standardize the identifying field.
		record.name = record[name_field]
		if name_field ~= "name" then
			record[name_field] = nil
		end

		return {
			date = date,
			type = data_type,
			record = record
		}
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
				table.insert(records, record)
			end
		end

		if #results < PAGE_SIZE then
			break
		end

		offset = offset + PAGE_SIZE
	end

	return records
end

-- Groups by date, then by the given fields.
-- Skips grouping levels for fields that are nil.
-- local function group_by_fields(records, fields)
-- 	local grouped = {}

-- 	for date, date_records in pairs(records) do
-- 		grouped[date] = {}

-- 		for _, record in ipairs(date_records) do
-- 			local current = grouped[date]

-- 			for _, field in ipairs(fields) do
-- 				local value = record[field]

-- 				if value ~= nil then
-- 					if current[value] == nil then
-- 						current[value] = {}
-- 					end

-- 					current = current[value]
-- 				end
-- 			end

-- 			table.insert(current, record)
-- 		end
-- 	end

-- 	return grouped
-- end

-- local function values_equal(a, b)
-- 	if type(a) ~= type(b) then
-- 		return false
-- 	end

-- 	if type(a) ~= "table" then
-- 		return a == b
-- 	end

-- 	for key, value in pairs(a) do
-- 		if not values_equal(value, b[key]) then
-- 			return false
-- 		end
-- 	end

-- 	for key, value in pairs(b) do
-- 		if not values_equal(value, a[key]) then
-- 			return false
-- 		end
-- 	end

-- 	return true
-- end

-- local function remove_duplicates(records, fields)
-- 	local result = {}

-- 	for date, date_records in pairs(records) do
-- 		result[date] = {}

-- 		for _, record in ipairs(date_records) do
-- 			local duplicate = false

-- 			for _, existing in ipairs(result[date]) do
-- 				local same = true

-- 				for _, field in ipairs(fields) do
-- 					if not values_equal(record[field], existing[field]) then
-- 						same = false
-- 						break
-- 					end
-- 				end

-- 				if same then
-- 					duplicate = true
-- 					break
-- 				end
-- 			end

-- 			if not duplicate then
-- 				table.insert(result[date], record)
-- 			end
-- 		end
-- 	end

-- 	return result
-- end

local function get_items(year)
	return get_from_bucket(
		"infobox_item",
		ITEM_FIELDS,
		make_transform(
			year,
			adjusted_dates.items,
			field_transforms.items,
			"item_name",
			"release_date",
			"items"
		)
	)
end

local function get_npcs(year)
	return get_from_bucket(
		"infobox_npc",
		NPC_FIELDS,
		make_transform(year, adjusted_dates.npcs, field_transforms.npcs, "page_name", "release", "npcs")
	)
end

local function get_monsters(year)
	return get_from_bucket(
		"infobox_monster",
		MONSTER_FIELDS,
		make_transform(year, adjusted_dates.monsters, field_transforms.monsters, "page_name", "release_date", "monsters")
	)
end

local function get_updates(year)
	return get_from_bucket(
		"update",
		UPDATE_FIELDS,
		function(row)
			if not row.year
				or not row.month
				or not row.day
				or tonumber(row.year) ~= tonumber(year)
			then
				return nil
			end

			return {
				date = string.format(
					"%04d-%02d-%02d",
					tonumber(row.year),
					tonumber(row.month),
					tonumber(row.day)
				),
				type = "updates",
				record = {
					name = row.page_name,
					type = row.type,
				},
			}
		end
	)
end


-- Shared DPL helper
local function get_from_dpl(template_name, transform)
	local results = dpl.ask({
		uses = "Template:" .. template_name,
		include = "{" .. template_name .. "}",
		count = PAGE_SIZE,
		ordermethod = "title",
	})

	local records = {}

	for _, row in ipairs(results) do
		local template = row.include
			and row.include[template_name]

		if template then
			local record = transform(row, template)

			if record then
				table.insert(records, record)
			end
		end
	end

	return records
end

-- DPL: Quests
local function get_quests(year)
	local seen_numbers = {}
	year = tostring(year)

	return get_from_dpl("Infobox Quest", function(row, template)
		local name = template.name
		local number = template.number

		if not has_valid_name(name)
			or not number
			or number == ""
			or number == "null"
			or seen_numbers[number]
		then
			return nil
		end

		local date = parse_date(template.release)

		if not date or string.sub(date, 1, 4) ~= year then
			return nil
		end

		seen_numbers[number] = true

		return {
			date = date,
			type = "quests",
			record = {
				name = name,
				number = number,
				image = template.image,
				members = template.members,
				series = template.series,
				developer = template.developer,
				update = template.update,
				aka = template.aka,
				difficulty = template.difficulty,
			},
		}
	end)
end

-- DPL Locations
local function get_locations(year)
    local seen_names = {}

    return get_from_dpl("Infobox Location", function(row, template)
        local name = template.name

        if not has_valid_name(name) or seen_names[name] then
            return nil
        end

        local date = parse_date(template.release)
        if not date or string.sub(date, 1, 4) ~= tostring(year) then
            return nil
        end

        seen_names[name] = true

        local image = template.image
        if not image or image == "" then
            image = template.image1
        end

        local record = {
            name = name,
            image = image,
            removal = template.removal,
            members = template.members,
            type = template.type,
        }

        return {
            date = date,
            type = "locations",
            record = record,
        }
    end)
end

-- DPL: Music
local function get_music(year)
	local seen_names = {}
	year = tostring(year)

	return get_from_dpl("Infobox Music", function(row, template)
		local name = template.name

		if not has_valid_name(name) or seen_names[name] then
			return nil
		end

		local date = parse_date(template.release)

		if not date then
			date = adjusted_dates.music[name]
		end

		if not date or string.sub(date, 1, 4) ~= year then
			return nil
		end

		seen_names[name] = true

		return {
			date = date,
			type = "music",
			record = {
				name = name,
				number = template.number,
				file = template.file,
				removal = template.removal,
				members = template.members,
				location = template.location,
				hint = template.hint,
				duration = template.duration,
				composer = template.composer,
			},
		}
	end)
end

-- DPL: God letters
local function get_god_letters(year)
	local seen_names = {}
	year = tostring(year)

	return get_from_dpl("God letter", function(row, template)
		local page_name = row.title
		local name = string.gsub(page_name, "^Transcript:", "")

		if not has_valid_name(name) or seen_names[name] then
			return nil
		end

		local date = parse_date(template.date)

		if not date or string.sub(date, 1, 4) ~= year then
			return nil
		end

		seen_names[name] = true

		return {
			date = date,
			type = "god_letters",
			record = {
				name = name,
				page_name = page_name,
			},
		}
	end)
end

-- DPL: Players' Gallery transcripts
local function get_players_gallery_transcripts(year)
	local seen_names = {}
	year = tostring(year)

	return get_from_dpl(
		"Players' Gallery transcript",
		function(row, template)
			local page_name = row.title
			local name = string.gsub(page_name, "^Transcript:", "")

			if not has_valid_name(name) or seen_names[name] then
				return nil
			end

			local date = parse_date(template.date)

			if not date or string.sub(date, 1, 4) ~= year then
				return nil
			end

			seen_names[name] = true

			return {
				date = date,
				type = "players_gallery_transcripts",
				record = {
					name = name,
					page_name = page_name,
				},
			}
		end
	)
end

-- DPL: Polls
local function get_polls(year)
	local seen_ids = {}
	local target_year = tonumber(year)

	return get_from_dpl("PollNotice", function(row, template)
		local title = row.title

		if not title then
			return nil
		end

		local poll_id
		local release_date

		if target_year < 2013 then
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

		if not poll_id or seen_ids[poll_id] then
			return nil
		end

		local date = parse_date(release_date)

		if not date
			or string.sub(date, 1, 4) ~= tostring(year)
		then
			return nil
		end

		seen_ids[poll_id] = true

		return {
			date = date,
			type = "polls",
			record = {
				name = title,
				id = poll_id,
			},
		}
	end)
end

-- DPL: Rooms
local function get_rooms(year)
	local seen_names = {}
	year = tostring(year)

	return get_from_dpl("Infobox Room", function(row, template)
		local name = template.name

		if not has_valid_name(name) or seen_names[name] then
			return nil
		end

		local date = parse_date(template.release)

		if not date or string.sub(date, 1, 4) ~= year then
			return nil
		end

		seen_names[name] = true

		return {
			date = date,
			type = "rooms",
			record = {
				name = name,
				image = template.image,
				update = template.update,
				icon = template.icon,
				level = template.level,
				cost = template.cost,
			},
		}
	end)
end

-- DPL: Activities
local function get_activities(year)
	local seen_names = {}
	year = tostring(year)

	return get_from_dpl("Infobox Activity", function(row, template)
		local name = template.name

		if not has_valid_name(name) or seen_names[name] then
			return nil
		end

		local date = parse_date(template.release)

		if not date or string.sub(date, 1, 4) ~= year then
			return nil
		end

		seen_names[name] = true

		return {
			date = date,
			type = "activities",
			record = {
				name = name,
				image = template.image,
				update = template.update,
				removal = template.removal,
				type = template.type,
				members = template.members,
				location = template.location,
			},
		}
	end)
end

-- DPL: Miniquests
local function get_miniquests(year)
	local seen_names = {}
	year = tostring(year)

	return get_from_dpl("Infobox Miniquest", function(row, template)
		local name = template.name

		if not has_valid_name(name) or seen_names[name] then
			return nil
		end

		local date = parse_date(template.release)

		if not date or string.sub(date, 1, 4) ~= year then
			return nil
		end

		seen_names[name] = true

		return {
			date = date,
			type = "miniquests",
			record = {
				name = name,
				image = template.image,
				update = template.update,
				removal = template.removal,
				members = template.members,
				series = template.series,
				developer = template.developer,
			},
		}
	end)
end

-- DPL: Emotes
local function get_emotes(year)
	local seen_names = {}
	year = tostring(year)

	return get_from_dpl("Infobox Emote", function(row, template)
		local name = template.name

		if not has_valid_name(name) or seen_names[name] then
			return nil
		end

		local date = parse_date(template.release)

		if not date or string.sub(date, 1, 4) ~= year then
			return nil
		end

		seen_names[name] = true

		return {
			date = date,
			type = "emotes",
			record = {
				name = name,
				image = template.image,
				update = template.update,
				sound = template.sound,
			},
		}
	end)
end

-- DPL: Events
local function get_events(year)
	local seen_names = {}
	year = tostring(year)

	return get_from_dpl("Infobox Event", function(row, template)
		local name = template.name

		if not has_valid_name(name) or seen_names[name] then
			return nil
		end

		local date = parse_date(template.release)

		if not date or string.sub(date, 1, 4) ~= year then
			return nil
		end

		seen_names[name] = true

		return {
			date = date,
			type = "events",
			record = {
				name = name,
				image = template.image,
				update = template.update,
				removal = template.removal,
			},
		}
	end)
end

-- DPL: Postbag
local function get_postbag(year)
	local seen_issues = {}
	year = tostring(year)

	return get_from_dpl("Postbag", function(row, template)
		local page_name = row.title
		local name = string.gsub(page_name, "^Transcript:", "")
		local issue = template.issue

		if not issue or seen_issues[issue] then
			return nil
		end

		local date = parse_date(template.date)

		if not date or string.sub(date, 1, 4) ~= year then
			return nil
		end

		seen_issues[issue] = true

		return {
			date = date,
			type = "postbag",
			record = {
				name = name,
				issue = issue,
				page_name = page_name,
			},
		}
	end)
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

-- DPL, special case
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
					-- Create one entry for each version released
					-- on this date.
					for _, release_index in ipairs(indices) do
						local record = {}

						for key, value in pairs(template) do
							local field, index =
								string.match(key, "^(.+)(%d+)$")

							if field and index then
								index = tonumber(index)

								if index == release_index then
									record[field] = value
								end
							else
								-- Copy shared, unnumbered fields.
								record[key] = value
							end
						end

						-- Use the normalized release date.
						record.release = date

						table.insert(construction, {
							date = date,
							type = "construction",
							record = record,
						})
					end
				end
			end
		end
	end

	return construction
end

-- Manual
local function get_lore(year)
	local lore = {}
	year = tostring(year)

	for _, entry in ipairs(lore_data) do
		if string.sub(entry.date, 1, 4) == year then
			table.insert(lore, {
				date = entry.date,
				type = "lore",
				record = {
					name = entry.name,
					link = entry.link,
				},
			})
		end
	end

	return lore
end

-- Manual
local function get_videos(year)
	local result = {}
	year = tostring(year)

	for _, video in ipairs(videos) do
		if string.sub(video.date, 1, 4) == year then
			table.insert(result, {
				date = video.date,
				type = "videos",
				record = {
					name = video.name,
					link = video.link,
				},
			})
		end
	end

	return result
end

-- Manual
local function get_livestreams(year)
	local result = {}
	year = tostring(year)

	for _, livestream in ipairs(livestreams) do
		if string.sub(livestream.date, 1, 4) == year then
			local record = {
				name = livestream.name,
			}

			if livestream.link ~= nil then
				record.link = livestream.link
			end

			table.insert(result, {
				date = livestream.date,
				type = "livestreams",
				record = record,
			})
		end
	end

	return result
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

-- Fields that identify a record should appear first.
local FIELD_PRIORITY = {
    page_name = 1,
    item_name = 2,
    npc_name = 3,
    name = 4,
    quest_name = 5,
    location_name = 6,
    track_name = 7,
    title = 8,
    id = 9,
    number = 10,
}

local function sanitize_string(value)
    -- Replace runs of newlines (including Windows CRLF) with a space.
    return (value:gsub("[\r\n]+", " "))
end


local function is_scalar(value)
    local value_type = type(value)

    return value_type == "string"
        or value_type == "number"
        or value_type == "boolean"
        or value_type == "nil"
end

local function is_inline_table(value)
    for _, entry in pairs(value) do
        if type(entry) == "table" then
            -- Allow arrays containing only scalar values,
            -- such as image = { "File:Crossbow.png" }.
            if not is_array(entry) then
                return false
            end

            for _, item in ipairs(entry) do
                if not is_scalar(item) then
                    return false
                end
            end
        elseif not is_scalar(entry) then
            return false
        end
    end

    return true
end

local function serialize(data)
	local json = mw.text.jsonEncode(data)
	
	return '<div style="overflow-x:auto; max-width:100%;">'
	    .. '<pre style="white-space:pre; width:max-content; min-width:100%; margin:0;">'
	    .. mw.text.nowiki(json)
	    .. '</pre></div>'
end

local function merge_output(data, type, nextOutput)
	return data .. "<b>" .. type .. "</b><br/>" .. nextOutput
end

local function generate(year)
	year = tonumber(year)

	if year == nil then
		error("ReleaseData/Generate requires a valid year")
	end

	year = math.floor(year)

	local data = ""

	-- data = merge_output(data, "updates", serialize(get_updates(year)))
	-- data = merge_output(data, "videos", serialize(get_videos(year)))
	-- data = merge_output(data, "livestreams", serialize(get_livestreams(year)))
	-- data = merge_output(data, "quests", serialize(get_quests(year)))
	-- data = merge_output(data, "miniquests", serialize(get_miniquests(year)))
	
	-- data = merge_output(data, "locations", serialize(get_locations(year)))
	-- data = merge_output(data, "activities", serialize(get_activities(year)))
	-- data = merge_output(data, "events", serialize(get_events(year)))
	data = merge_output(data, "items", serialize(get_items(year)))
	data = merge_output(data, "npcs", serialize(get_npcs(year)))
	
	data = merge_output(data, "monsters", serialize(get_monsters(year)))
	-- data = merge_output(data, "emotes", serialize(get_emotes(year)))
	-- data = merge_output(data, "music", serialize(get_music(year)))
	-- data = merge_output(data, "construction", serialize(get_construction(year)))
	-- data = merge_output(data, "rooms", serialize(get_rooms(year)))
	
	-- data = merge_output(data, "lore", serialize(get_lore(year)))
	-- data = merge_output(data, "god_letters", serialize(get_god_letters(year)))
	-- data = merge_output(data, "postbag", serialize(get_postbag(year)))
	-- data = merge_output(data, "polls", serialize(get_polls(year)))
	-- data = merge_output(data, "players_gallery_transcripts", serialize(get_players_gallery_transcripts(year)))

	return data
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