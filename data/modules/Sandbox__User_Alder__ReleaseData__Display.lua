
local p = {}

-- Default image size in pixels.
local DEFAULT_IMAGE_SIZE = 100

-- Image sizes by record type.
-- Types not listed here use DEFAULT_IMAGE_SIZE.
local IMAGE_SIZES = {
	quests = 300,
	locations = 300,
	monsters = 50,
	npcs = 50,
	miniquests = 300,
	activities = 300,
}

local MONTHS = {
	[1] = "January",
	[2] = "February",
	[3] = "March",
	[4] = "April",
	[5] = "May",
	[6] = "June",
	[7] = "July",
	[8] = "August",
	[9] = "September",
	[10] = "October",
	[11] = "November",
	[12] = "December",
}

-- Order in which record types are displayed.
local RECORD_TYPES = {
	"updates",
	"polls",
	"god_letters",
	"postbag",
	"players_gallery_transcripts",
	"lore",
	"videos",
	"livestreams",
	"quests",
	"miniquests",
	"locations",
	"activities",
	"music",
	"events",
	"items",
	"monsters",
	"npcs",
	"emotes",
	"construction",
	"rooms",
}

local TYPE_LABELS = {
	updates = "Updates",
	videos = "Videos",
	livestreams = "Livestreams",
	quests = "Quests",
	miniquests = "Miniquests",
	locations = "Locations",
	activities = "Activities",
	events = "Events",
	items = "Items",
	npcs = "NPCs",
	monsters = "Monsters",
	emotes = "Emotes",
	music = "Music",
	construction = "Construction",
	rooms = "Rooms",
	lore = "Lore",
	god_letters = "God letters",
	postbag = "Postbag",
	polls = "Polls",
	players_gallery_transcripts = "Players' Gallery transcripts",
}

-- Default field ordering for record types without custom ordering.
-- Members fields are always moved to the far right separately.
local FIELD_ORDER = {
	"name",
	"page_name",
	"npc_name",
	"item_name",
	"image",
	"number",
	"combat_level",
	"hitpoints",
	"examine",
	"release",
	"release_date",
	"removal_date",
	"quest",
	"series",
	"update",
	"location",
	"developer",
	"link",
	"type",
	"value",
	"high_alchemy_value",
	"weight",
	"tradeable",
	"date",
	"is_members_only",
	"members",
}

local FIELD_PRIORITY = {}

for index, field in ipairs(FIELD_ORDER) do
	FIELD_PRIORITY[field] = index
end

-- Fields that should not appear in the rendered tables.
local HIDDEN_FIELDS = {
	god_letters = {
		page_name = true,
	},
	lore = {
		link = true,
	},
	quests = {
		update = true,
		series = true,
	},
	locations = {
		type = true,
	},
	activities = {
		update = true,
	},
	items = {
		page_name = true,
		value = true,
		high_alchemy_value = true,
		weight = true,
		image = true,
		removal_date = true,
	},
	monsters = {
		attribute = true,
		hitpoints = true,
	},
	npcs = {
		name = true,
	},
	emotes = {
		sound = true,
		update = true,
	},
	miniquests = {
		series = true,
		update = true,
	},
	rooms = {
		update = true,
		level = true,
	},
	players_gallery_transcripts = {
		page_name = true,
	},
	postbag = {
		page_name = true,
	},
}

-- Construction records only display these fields.
local ALLOWED_FIELDS = {
	construction = {
		name = true,
		image = true,
		examine = true,
		icon = true,
		room = true,
	},
}

local function is_array(value)
	if type(value) ~= "table" then
		return false
	end

	local count = 0

	for key in pairs(value) do
		if type(key) ~= "number"
			or key < 1
			or key % 1 ~= 0 then
			return false
		end

		count = count + 1
	end

	return count == #value
end

local function parse_date(date)
	if type(date) ~= "string" then
		return nil
	end

	local year, month, day = date:match(
		"^(%d%d%d%d)%-(%d%d)%-(%d%d)$"
	)

	if not year then
		return nil
	end

	return tonumber(year), tonumber(month), tonumber(day)
end

local function format_date(date)
	local year, month, day = parse_date(date)

	if not year or not MONTHS[month] then
		return date
	end

	return day .. " " .. MONTHS[month] .. " " .. year
end

local function collect_records(value, records)
	if type(value) ~= "table" then
		return
	end

	-- Recognize actual record tables by their field names.
	-- Grouping tables contain other tables instead.
	local record_fields = {
		name = true,
		page_name = true,
		npc_name = true,
		item_name = true,
		title = true,
		examine = true,
		release = true,
		release_date = true,
		number = true,
		combat_level = true,
		hitpoints = true,
		link = true,
	}

	for key in pairs(record_fields) do
		if value[key] ~= nil then
			records[#records + 1] = value
			return
		end
	end

	-- Traverse arrays and nested grouping tables.
	for _, child in pairs(value) do
		if type(child) == "table" then
			collect_records(child, records)
		end
	end
end

local function is_members_field(field)
	return field == "is_members_only" or field == "members"
end

local function get_field_keys(records, record_type)
	local seen = {}
	local keys = {}

	for _, record in ipairs(records) do
		for key in pairs(record) do
			if type(key) == "string"
				and not seen[key]
				and not (
					HIDDEN_FIELDS[record_type]
					and HIDDEN_FIELDS[record_type][key]
				)
				and not (
					ALLOWED_FIELDS[record_type]
					and not ALLOWED_FIELDS[record_type][key]
				) then
				seen[key] = true
				keys[#keys + 1] = key
			end
		end
	end

	-- Return whether a field should precede another field.
	-- Members fields always appear at the far right.
	local function field_less(a, b, priority)
		local a_members = is_members_field(a)
		local b_members = is_members_field(b)

		if a_members ~= b_members then
			return not a_members
		end

		local pa = priority[a] or FIELD_PRIORITY[a] or math.huge
		local pb = priority[b] or FIELD_PRIORITY[b] or math.huge

		if pa ~= pb then
			return pa < pb
		end

		return a < b
	end

	-- Items: item_name is the first column.
	if record_type == "items" then
		table.sort(keys, function(a, b)
			local priority = {
				item_name = 1,
			}

			return field_less(a, b, priority)
		end)

		return keys
	end

	-- Quests: quest number first, followed by quest name.
	if record_type == "quests" then
		table.sort(keys, function(a, b)
			local priority = {
				number = 1,
				name = 2,
			}

			return field_less(a, b, priority)
		end)

		return keys
	end

	-- Music: name, file, duration, composer, location, and hint.
	if record_type == "music" then
		table.sort(keys, function(a, b)
			local priority = {
				name = 1,
				file = 2,
				image = 2,
				duration = 3,
				composer = 4,
				location = 5,
				hint = 6,
			}

			return field_less(a, b, priority)
		end)

		return keys
	end

	-- NPCs: display name first, then image.
	if record_type == "npcs" then
		table.sort(keys, function(a, b)
			local priority = {
				npc_name = 1,
				image = 2,
			}

			return field_less(a, b, priority)
		end)

		return keys
	end

	table.sort(keys, function(a, b)
		return field_less(a, b, {})
	end)

	return keys
end

local function format_field_name(field, record_type)
	if is_members_field(field) then
		return "Members"
	end

	if record_type == "music" and field == "image" then
		return "File"
	end

	-- Keep the underlying NPC field as npc_name, but display
	-- its column header as Name.
	if field == "npc_name" then
		return "Name"
	end

	local label = field:gsub("_", " ")
	return label:sub(1, 1):upper() .. label:sub(2)
end

local function normalize_image(value, record_type)
	if type(value) ~= "string" then
		return value
	end

	local size = IMAGE_SIZES[record_type] or DEFAULT_IMAGE_SIZE
	local size_option = tostring(size) .. "px"

	-- Bare filenames, such as "File:Goblin.png".
	if value:match("^%s*[Ff]ile:")
		or value:match("^%s*[Ii]mage:") then
		return "[[" .. value .. "|" .. size_option .. "]]"
	end

	-- Replace an existing pixel size in File/Image wikitext.
	local updated, count = value:gsub(
		"(%[%[%s*[Ff]ile:[^%]|]+)|%d+px",
		"%1|" .. size_option
	)

	updated = updated:gsub(
		"(%[%[%s*[Ii]mage:[^%]|]+)|%d+px",
		"%1|" .. size_option
	)

	if count > 0 then
		return updated
	end

	-- Add a pixel size to existing file links without one.
	if updated:match("^%s*%[%[%s*[Ff]ile:")
		or updated:match("^%s*%[%[%s*[Ii]mage:") then
		updated = updated:gsub(
			"%]%]$",
			"|" .. size_option .. "]]"
		)
	end

	return updated
end

local function format_members(value)
	local normalized = tostring(value):lower()
	local argument

	if normalized == "yes" or normalized == "true" then
		argument = "yes"
	else
		argument = "no"
	end

	return mw.getCurrentFrame():expandTemplate({
		title = "Members",
		args = { argument },
	})
end

local function format_value(value, record_type, field)
	if field == "quest" or field == "quests" then
		if value == nil or value == "" or value == "No"
			or (type(value) == "table" and next(value) == nil) then
			return "No"
		end

		return "Yes"
	end

	if value == nil then
		return ""
	end

	if is_members_field(field) then
		return format_members(value)
	end

	-- NPC and monster images may be stored as single-element arrays.
	-- Extract the filename and apply the configured image size.
	if (record_type == "npcs" or record_type == "monsters")
		and field == "image" then
		if type(value) == "table" then
			value = value[1]
		end

		if type(value) ~= "string" or value == "" then
			return ""
		end

		local size = IMAGE_SIZES[record_type] or DEFAULT_IMAGE_SIZE
		local size_option = tostring(size) .. "px"

		-- Replace any existing pixel size in a file link.
		if value:match("^%s*%[%[%s*[Ff]ile:") then
			local updated, count = value:gsub(
				"|(%d+px)",
				"|" .. size_option
			)

			if count > 0 then
				return updated
			end

			-- No existing size option: add one before the closing brackets.
			return value:gsub("%]%]$", "|" .. size_option .. "]]")
		end

		-- Bare filename, e.g. "File:Goblin.png".
		if value:match("^%s*[Ff]ile:")
			or value:match("^%s*[Ii]mage:") then
			return "[[" .. value .. "|" .. size_option .. "]]"
		end

		return value
	end

	-- Link each quest in a quest list to its own page.
	if field == "quest" and type(value) == "table" then
		local quests = {}

		for _, quest in ipairs(value) do
			local name = tostring(quest)
			quests[#quests + 1] = "[[" .. name .. "]]"
		end

		return table.concat(quests, ", ")
	end

	if type(value) == "boolean" then
		return value and "Yes" or "No"
	end

	if type(value) == "number" then
		return tostring(value)
	end

	if type(value) == "string" then
		-- Updates: link the update page while omitting "Update:"
		-- from the displayed text.
		if record_type == "updates" and field == "name" then
			local title = value:gsub("^Update:", "")
			return "[[Update:" .. title .. "|" .. title .. "]]"
		end
		
		if record_type == "god_letters" and field == "name" then
			return "[[Transcript:" .. value .. "|" .. value .. "]]"
		end

		-- Polls: omit "Poll:" from the displayed name but link to the poll page.
		if record_type == "polls" and field == "name" then
			local title = value:gsub("^Poll:", "")
			return "[[Poll:" .. title .. "|" .. title .. "]]"
		end

		-- Link these names to their own pages.
		if (record_type == "music"
			or record_type == "miniquests"
			or record_type == "activities"
			or record_type == "emotes")
			and field == "name" then
			return "[[" .. value .. "]]"
		end

		-- Quests: link the quest name to its own page.
		if record_type == "quests" and field == "name" then
			return "[[" .. value .. "]]"
		end

		-- Locations: link the location name to its own page.
		if record_type == "locations" and field == "name" then
			return "[[" .. value .. "]]"
		end

		-- Monsters: link the monster name to its own page.
		if record_type == "monsters" and field == "name" then
			return "[[" .. value .. "]]"
		end

		-- NPC display names are linked to their page in render_table().
		if record_type == "npcs" and field == "npc_name" then
			return value
		end

		-- Expand each RSL developer template independently. This handles
		-- multiple values such as "{{RSL|Mod Jolley|Chris J}}, {{RSL|Mod Newmatic|Matt H}}".
		if field == "developer" and value:find("{{RSL|", 1, true) then
			value = value:gsub("{{RSL|([^|{}]+)|([^{}]-)}}", function(target, display)
				return mw.getCurrentFrame():expandTemplate({
					title = "RSL",
					args = { target, display },
				})
			end)
		end

		-- Normalize images for other record types.
		if field == "image"
			and record_type ~= "items"
			and record_type ~= "emotes" then
			value = normalize_image(value, record_type)
		end

		-- Preserve literal pipes in wikitext so piped links and
		-- file options render correctly.
		value = value:gsub("\r\n", "\n")
		value = value:gsub("\n", "<br />")

		return value
	end

	if type(value) == "table" then
		if is_array(value) then
			local values = {}

			for _, item in ipairs(value) do
				values[#values + 1] =
					format_value(item, record_type, field)
			end

			return table.concat(values, ", ")
		end

		local keys = {}

		for key in pairs(value) do
			keys[#keys + 1] = key
		end

		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)

		local values = {}

		for _, key in ipairs(keys) do
			values[#values + 1] =
				tostring(key) .. ": "
				.. format_value(value[key], record_type, field)
		end

		return table.concat(values, ", ")
	end

	return tostring(value)
end

local function render_table(records, record_type)
	if #records == 0 then
		return ""
	end

	local fields = get_field_keys(records, record_type)

	-- Sort quests numerically by quest number.
	if record_type == "quests" then
		table.sort(records, function(a, b)
			local na = tonumber(a.number)
			local nb = tonumber(b.number)

			if na and nb and na ~= nb then
				return na < nb
			elseif na ~= nil and nb == nil then
				return true
			elseif na == nil and nb ~= nil then
				return false
			end

			return tostring(a.name or "") < tostring(b.name or "")
		end)
	end
	
	-- Sort items/npcs/monsters tables alphabetically
	-- Sort items on quest as well
	if record_type == "items" then
	    table.sort(records, function(a, b)
	        local a_no_quest = a.quest == "No"
	        local b_no_quest = b.quest == "No"
	
	        if a_no_quest ~= b_no_quest then
	            return a_no_quest
	        end
	
	        return (a.name or ""):lower() < (b.name or ""):lower()
	    end)
	elseif record_type == "monsters" or record_type == "npcs" then
	    table.sort(records, function(a, b)
	        return (a.name or ""):lower() < (b.name or ""):lower()
	    end)
	end

	local output = {
		'{| class="wikitable sortable lighttable"',
		"|-",
	}

	for _, field in ipairs(fields) do
		output[#output + 1] = "! " .. format_field_name(field, record_type)
	end

	for _, record in ipairs(records) do
		output[#output + 1] = "|-"

		for _, field in ipairs(fields) do
			local value = record[field]
			
			if record_type == "items" and field == "name" then
			    local image = record.image
			    local page_name = record.page_name
			    local name = record.name
			
			    if type(image) == "table" then
			        image = image[1]
			    end
			
			    value = string.format(
			        "[[%s|link=%s]] [[%s|%s]]",
			        tostring(image or ""),
			        tostring(page_name or ""),
			        tostring(page_name or ""),
			        tostring(name or "")
			    )
			end
			
			-- Lore: link the name to its destination in the hidden Link field.
			if record_type == "lore" and field == "name" then
				local target = record.link
			
				if target ~= nil and tostring(target) ~= "" then
					target = tostring(target)
					local display_name = tostring(record.name or value or "")
			
					if target:match("^https?://") then
						value = "[" .. target .. " " .. display_name .. "]"
					else
						value = "[[" .. target .. "|" .. display_name .. "]]"
					end
				end
			end

			-- Postbag and Players' Gallery: display the name as a link
			-- to page_name, without a separate page_name column.
			if (record_type == "postbag"
				or record_type == "players_gallery_transcripts")
				and field == "name" then
				local display_name = record.name
				local page_name = record.page_name or record.name

				if display_name ~= nil and page_name ~= nil
					and tostring(display_name) ~= ""
					and tostring(page_name) ~= "" then
					value = "[[" .. tostring(page_name) .. "|"
						.. tostring(display_name) .. "]]"
				end
			end

			-- NPCs: link the displayed NPC name to the page
			-- specified by record.name, keeping the display data.
			if record_type == "npcs" and field == "npc_name" then
				local display_name = record.npc_name
				local page_name = record.name

				if display_name ~= nil and page_name ~= nil
					and tostring(display_name) ~= ""
					and tostring(page_name) ~= "" then
					value = "[[" .. tostring(page_name) .. "|"
						.. tostring(display_name) .. "]]"
				end
			end

			output[#output + 1] = "| "
				.. format_value(value, record_type, field)
		end
	end

	output[#output + 1] = "|}"

	return table.concat(output, "\n")
end

local function render_record_type(record_type, data)
	local records = {}
	collect_records(data, records)

	if #records == 0 then
		return nil
	end

	return "'''" .. (TYPE_LABELS[record_type] or record_type)
		.. "'''\n\n" .. render_table(records, record_type)
end

function p.main(frame)
	local args = frame.args
	local year = tostring(args.year or args[1] or "2001")

	if not year:match("^%d%d%d%d$") then
		return "Error: year must be a four-digit year."
	end

	local data = mw.loadData(
		"Module:Sandbox/User:Alder/ReleaseData/" .. year
	)

	if type(data) ~= "table" then
		return "Error: could not load release data for " .. year .. "."
	end

	local dates = {}
	local rendered_months = {}

	for date in pairs(data) do
		local date_year, month = parse_date(date)

		if date_year == tonumber(year) and MONTHS[month] then
			dates[#dates + 1] = date
			rendered_months[month] = true
		end
	end

	table.sort(dates)

	local month_links = {}

	for month = 1, 12 do
		if rendered_months[month] then
			month_links[#month_links + 1] =
				"[[" .. "#" .. MONTHS[month]
				.. "|" .. MONTHS[month] .. "]]"
		end
	end

	local output = {}

	local previous_month

	for _, date in ipairs(dates) do
		local _, month = parse_date(date)

		if month ~= previous_month then
			output[#output + 1] = "== " .. MONTHS[month] .. " =="
			previous_month = month
		end

		output[#output + 1] = "=== " .. format_date(date) .. " ==="

		local date_data = data[date]

		for _, record_type in ipairs(RECORD_TYPES) do
			local type_data = date_data[record_type]

			if type_data then
				local section = render_record_type(record_type, type_data)

				if section then
					output[#output + 1] = section
				end
			end
		end
	end

	return table.concat(output, "\n\n")
end

return p