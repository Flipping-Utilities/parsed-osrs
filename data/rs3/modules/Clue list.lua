local cs = require('Module:Clue solution')
local fmt = cs.fmt
local build_popup_pin = cs.build_popup_pin
local CLUE_TYPE_DATA_FIELDS = cs.CLUE_TYPE_DATA_FIELDS
local ANAGRAM_PREAMBLE = cs.ANAGRAM_PREAMBLE

local categories_to_exclude = {
    "Historical article",
    "Pages using information from game APIs or cache",
    "Removed content"
}

local p = {}

--- Grouping key fields per clue type (which bucket fields identify a unique clue)
local GROUP_BY = {
    coordinate = { 'clue' },
    cryptic    = { 'clue' },
    simple     = { 'clue' },
    anagram    = { 'clue' },
    emote      = { 'clue' },
    map        = { 'clue', 'page_name' },
    compass    = { 'title' },
    scan       = { 'clue', 'group' },
}

local CLUE_TABLE_CLASS = 'wikitable cluetable'

--- Return the first non-nil, non-empty field value from a row, or 'Unknown'.
local function group_key(row, fields)
    for _, field in ipairs(fields) do
        if row[field] and row[field] ~= '' then return row[field] end
    end
    return 'Unknown'
end

local function join_or(parts, fallback, separator)
    separator = separator or '<br>'
    return #parts > 0 and table.concat(parts, separator) or fallback
end

--- Build a display string from accumulated {formatted, title} parts
local function finalize_display(parts, empty)
    if #parts == 0 then return empty end
    if #parts == 1 then return parts[1].formatted end
    local out = {}
    for _, part in ipairs(parts) do
        local val = part.formatted
        if part.title then val = "'''" .. part.title .. ":''' " .. val end
        table.insert(out, val)
    end
    return table.concat(out, '<br>')
end

local function group_rows(rows)
    if not rows or #rows == 0 then return {}, {} end
    local clue_type = rows[1].clue_type
    local groups = {}
    local order = {}
    for _, row in ipairs(rows) do
        local key = group_key(row, GROUP_BY[clue_type])
        if not groups[key] then
            groups[key] = {}
            table.insert(order, key)
        end
        table.insert(groups[key], row)
    end
    return groups, order
end

--- Strip the File: prefix that the bucket stores; fmt functions add it back.
local function strip_file_prefix(s)
    if not s then return nil end
    return (s:gsub('^[Ff]ile:', ''))
end

--- Strip wiki links so the title renders as plain text
local function strip_links(s)
    if not s then return nil end
    s = s:gsub('%[%[[^%]|]*|([^%]]*)%]%]', '%1')
    s = s:gsub('%[%[([^%]]*)%]%]', '%1')
    return s
end

local function get_clue_bucket_data(frame, default_type, default_orderby)
    local parent = frame:getParent()
    local source = parent and parent.args or frame.args

    local b = bucket('clue')
        .select(
            'page_name',
            'clue_type',
            'difficulty',
            'clue',
            'solution',
            'image',
            'title',
            'location_title',
            'location',
            'travel',
            'requirements',
            'x_coordinate',
            'y_coordinate',
            'map_id',
            'plane',
            'type_data'
        )

    local clue_type = source.type or default_type
    if clue_type then
        b.where({ 'clue_type', clue_type })
    end

    for _, category in ipairs(categories_to_exclude) do
        b.where(bucket.Not("Category:" .. category))
    end

    if source.difficulty then
        b.where({ 'difficulty', source.difficulty })
    end

	local orderby = source.orderby or default_orderby
    if orderby then
        b.orderBy(orderby)
    end

    b.where({ 'clue', '!=', bucket.Null() })
    b.limit(source.limit or 1000)

    local rows = b.run()

    for _, row in ipairs(rows) do
        row.type_data = row.type_data and mw.text.jsonDecode(row.type_data) or {}
        row.group = row.group or row.type_data.group
    end

    return rows
end

local function rows_to_parsed(rows)
    local first = rows[1]
    local clue_type = first.clue_type
    local is_multi = #rows > 1

    -- Clue-level data
    local parsed = {
        clue = first.clue,
        clue_type = clue_type,
        difficulty = first.difficulty:lower(),
        solution = first.solution,
        title = first.title,
        requirements = first.requirements,
    }

    local td = first.type_data
    for _, key in ipairs(CLUE_TYPE_DATA_FIELDS[clue_type] or {}) do
        if td[key] ~= nil then
            parsed[key] = td[key]
        end
    end

    parsed.clueimage = strip_file_prefix(parsed.clueimage)

    parsed.display = {
        clue        = fmt.clue_link(parsed.clue, parsed.difficulty),
        solution    = fmt.solution(parsed.solution),
        chathead    = fmt.chathead(parsed.solution, parsed.chathead),
        second_step = fmt.second_step(parsed),
        fight       = fmt.fight(parsed.fight),
        clueimage   = fmt.image(parsed.clueimage),
        location    = fmt.location(first.location),
    }
    
    if (clue_type == 'coordinate') then
    	parsed.display.shorthand = '<strong>'.. fmt.coord_shorthand(parsed.clue) .. '</strong>'
    end

    parsed.display.title = ANAGRAM_PREAMBLE .. parsed.title .. parsed.display.clue

    local loc_parts, img_parts, map_parts = {}, {}, {}
    local travel_parts, travel_seen = {}, {}
    local req_parts, req_seen = {}, {}

    for _, row in ipairs(rows) do
        local title = row.location_title

        if row.location then
            local loc = row.location
            if is_multi and title then
                loc = "'''" .. title .. ":'''<br>" .. loc
            end
            table.insert(loc_parts, loc)
        end

        local image = strip_file_prefix(row.image)
        if image then
            if is_multi and title then
                table.insert(img_parts, "'''" .. title .. "'''")
            end
            table.insert(img_parts, fmt.image(image))
        end

        if row.x_coordinate and row.y_coordinate then
            local map_data = {
                xs = row.x_coordinate,
                ys = row.y_coordinate,
                mapID = row.map_id,
                plane = row.plane,
            }

            local row_display = {}
            for k, v in pairs(parsed.display) do row_display[k] = v end
            row_display.location = fmt.location(row.location)

            local popup_pin = build_popup_pin(map_data, row_display, clue_type)

            local extra_pin = nil
            if parsed.hideyhole and type(parsed.hideyhole) == 'table'
                and parsed.hideyhole.x and parsed.hideyhole.y then
                extra_pin = parsed.hideyhole
            end

            local map_cell = fmt.map(map_data, extra_pin, popup_pin)

            if is_multi and title then
                table.insert(map_parts, "'''" .. title .. "'''")
            end
            table.insert(map_parts, map_cell)
        end

        if row.travel and not travel_seen[row.travel] then
            travel_seen[row.travel] = true
            table.insert(travel_parts, { formatted = fmt.travel(row.travel), title = title })
        end

        if row.requirements and not req_seen[row.requirements] then
            req_seen[row.requirements] = true
            table.insert(req_parts, { formatted = fmt.list(row.requirements), title = title })
        end
    end

    parsed.location_display = join_or(loc_parts, "''None''", '<br><br>')
    parsed.image_display = join_or(img_parts, "''None''")
    parsed.map_display = join_or(map_parts, "''None''")
    parsed.travel_display = finalize_display(travel_parts, fmt.travel(nil))
    parsed.requirements_display = finalize_display(req_parts, fmt.list(nil))
    parsed.is_multi = is_multi

    return parsed
end

local function build_coordinate_row(rows)
    if not rows or #rows == 0 then return '' end
    local parsed = rows_to_parsed(rows)

    local t = mw.html.create('table')
    t:addClass(CLUE_TABLE_CLASS .. ' cluetable-coord align-left-3')
        :css({ ['width'] = '100%', ['text-align'] = 'center' })

    t:tr()
        :th({ 'Coordinates', css = { 'width', '20%' } })
        :th({ 'Location', css = { 'width', '20%' } })
        :th({ 'Suggested travel', css = { 'width', '30%' } })
        :th({ 'Image', css = { ['width'] = '15%', ['text-align'] = 'center' } })
        :th({ 'Map', css = { ['width'] = '15%', ['text-align'] = 'center' } })
    t:tr()
        :td({ parsed.display.clue, css = { 'text-align', 'center' } })
        :td({ parsed.location_display, css = { 'rowspan', 2} })
        :td({ parsed.travel_display, attr = { 'rowspan', 4 } })
        :td({ parsed.image_display, attr = { 'rowspan', 4 }, css = { 'text-align', 'center' } })
        :td({ parsed.map_display, attr = { 'rowspan', 4 }, css = { 'text-align', 'center' } })
    t:tr()
        :td({parsed.display.shorthand, css = { 'text-align', 'center' } })
    t:tr()
        :th({ 'Requirements', css = { 'width', '20%' } })
        :th({ 'Fight?', css = { 'width', '20%' } })
    t:tr()
        :td(parsed.requirements_display)
        :td(parsed.display.fight)

    return tostring(t)
end

local function build_cryptic_row(rows)
    if not rows or #rows == 0 then return '' end
    local parsed = rows_to_parsed(rows)

    local challenge = parsed.display.second_step
    local main_rowspan = 1 + (challenge and 2 or 0)

    local clue_cell = parsed.display.clue
    local title = strip_links(parsed.title)
    if title and title ~= '' and title ~= parsed.clue then
        clue_cell = clue_cell .. '<br><small>(' .. title .. ')</small>'
    end

    local t = mw.html.create('table')
    t:addClass(CLUE_TABLE_CLASS .. ' cluetable-cryptic'):css({ ['width'] = '100%' })

    t:tr()
        :th({ 'Cryptic', css = { 'width', '15%' } })
        :th({ 'Solution', css = { 'width', '15%' } })
        :th({ 'Location', css = { 'width', '15%' } })
        :th({ 'Suggested travel', css = { 'width', '20%' } })
        :th({ 'Image', css = { ['width'] = '17%', ['text-align'] = 'center' } })
        :th({ 'Map', css = { ['width'] = '18%', ['text-align'] = 'center' } })

    t:tr()
        :td({ clue_cell, attr = { 'rowspan', main_rowspan }, css = { 'text-align', 'center' } })
        :td({ parsed.display.solution, css = { 'text-align', 'center' } })
        :td({ parsed.location_display, attr = { 'rowspan', main_rowspan } })
        :td({ parsed.travel_display, attr = { 'rowspan', main_rowspan } })
        :td({ parsed.image_display, attr = { 'rowspan', main_rowspan }, css = { 'text-align', 'center' } })
        :td({ parsed.map_display, attr = { 'rowspan', main_rowspan }, css = { 'text-align', 'center' } })

    if challenge then
        t:tr():th({ 'Challenge', css = { 'height', '1em' } })
        t:tr():td({ '\n' .. challenge .. '\n', css = { 'text-align', 'left' } })
    end

    return tostring(t)
end

local function build_compass_section(rows)
    local t = mw.html.create('table')
    t:addClass('wikitable'):css('width', '100%')

    t:tr()
        :th({ 'Location', css = { 'width', '100%' } })
        :th('Image')
        :th('Map')

    for _, row in ipairs(rows) do
        local parsed = rows_to_parsed({ row })
        local location = row.location or 'Unknown location'

        t:tr()
            :tag('td'):wikitext(location):done()
            :tag('td'):wikitext(parsed.image_display):done()
            :tag('td'):wikitext(parsed.map_display):done()
    end

    return tostring(t)
end

local function build_compscan_section(rows)
    local t = mw.html.create('table')
    t:addClass('wikitable'):css('width', '100%')

    t:tr()
        :th({ 'Possible locations', css = { 'width', '100%' } })
        :th('Image')

    for _, row in ipairs(rows) do
        local parsed = rows_to_parsed({ row })
        local location = row.location or 'Unknown location'
        local map_cell = parsed.map_display
        local td_text = (map_cell ~= "''None''") and (location .. '<br>' .. map_cell) or location

        t:tr()
            :tag('td'):wikitext(td_text):done()
            :tag('td'):wikitext(parsed.image_display)
    end

    return tostring(t)
end

local function build_emote_row(rows)
    if not rows or #rows == 0 then return '' end
    local parsed = rows_to_parsed(rows)

    local has_req = parsed.requirements and parsed.requirements ~= ''

    local t = mw.html.create('table')
    t:addClass(CLUE_TABLE_CLASS .. ' cluetable-emote'):css('width', '100%')

    t:tr()
        :th({ 'Clue', css = { 'width', '25%' } })
        :th({ 'Requirements', css = has_req and { 'width', '30%' } or nil })
        :th({ 'Location', css = { 'width', '25%' } })
        :th({ 'Image', css = { 'width', '20%' } })
    t:tr()
        :td({ fmt.clue_link(parsed.clue, parsed.difficulty, parsed.title), css = { 'text-align', 'center' } })
        :td(parsed.requirements_display)
        :td({ parsed.map_display, attr = { 'rowspan', 7 }, css = { 'text-align', 'center' } })
        :td({ parsed.image_display, attr = { 'rowspan', 7 }, css = { 'text-align', 'center' } })
    t:tr()
        :th('Hidey-hole')
        :th('Fight?')
    t:tr()
        :td({ fmt.hideyhole(parsed.hideyhole and parsed.hideyhole.page, 30), css = { 'text-align', 'center' } })
        :td(parsed.display.fight)
    t:tr()
        :th('Items')
        :th('Suggested travel')
    t:tr()
        :td({ fmt.items(parsed.items), css = { 'text-align', 'center' } })
        :td({ parsed.travel_display, attr = { 'rowspan', 3 } })

    t:tr():th('Emote')
    t:tr():td({ fmt.emotes(parsed.emotes), css = { 'text-align', 'center' } })

    return tostring(t)
end

local function build_map_row(rows)
    if not rows or #rows == 0 then return '' end
    local parsed = rows_to_parsed(rows)

    local t = mw.html.create('table')
    t:addClass(CLUE_TABLE_CLASS .. ' cluetable-map'):css('width', '100%')

    t:tr()
        :th({ 'Map Clue', css = { 'width', '15%' } })
        :th({ 'Solution', css = { 'width', '15%' } })
        :th({ 'Suggested travel', css = { 'width', '20%' } })
        :th({ 'Image', css = { ['width'] = '17%', ['text-align'] = 'center' } })
        :th({ 'Map', css = { ['width'] = '18%', ['text-align'] = 'center' } })

    t:tr()
        :td({ parsed.display.clueimage, css = { 'text-align', 'center' } })
        :td({ parsed.display.solution, css = { 'text-align', 'center' } })
        :td({ parsed.travel_display, attr = { 'rowspan', 3 } })
        :td({ parsed.image_display, attr = { 'rowspan', 3 }, css = { 'text-align', 'center' } })
        :td({ parsed.map_display, attr = { 'rowspan', 3 }, css = { 'text-align', 'center' } })

    t:tr()

    t:tr()
        :th('Clue')
        :th('Location')

    t:tr()
        :td({ fmt.clue_link(parsed.clue, parsed.difficulty, parsed.title), css = { 'text-align', 'center' } })
        :td({ parsed.location_display, css = { 'text-align', 'center' } })

    return tostring(t)
end

local function build_anagram_row(rows)
    if not rows or #rows == 0 then return '' end
    local parsed = rows_to_parsed(rows)

    local challenge
    if parsed.is_multi then
        local variants, seen = {}, {}
        for _, row in ipairs(rows) do
            local rtd = row.type_data
            local ans = rtd.answer
            if ans and tostring(ans):lower() ~= 'none' then
                local s = tostring(ans)
                if not seen[s] then
                    seen[s] = { answer = s, titles = {} }
                    table.insert(variants, seen[s])
                end
                if row.location_title then
                    table.insert(seen[s].titles, row.location_title)
                end
            end
        end
        if #variants > 1 then
            local parts = {}
            if parsed.question then
                table.insert(parts, "'''Question:''' " .. tostring(parsed.question))
            end
            table.insert(parts, "'''Answer:'''")
            local answer_parts = {}
            for _, v in ipairs(variants) do
                local line = '* ' .. v.answer
                if #v.titles > 0 then
                    line = line .. ' (' .. table.concat(v.titles, ' / ') .. ')'
                end
                table.insert(answer_parts, line)
            end
            table.insert(parts, "\n" .. table.concat(answer_parts, "\n") .. "\n")
            challenge = table.concat(parts, '<br>')
        end
    end

    if not challenge then
        challenge = parsed.display.second_step
    end

    local main_rowspan = challenge and 3 or 1

    local t = mw.html.create('table')
    t:addClass(CLUE_TABLE_CLASS .. ' cluetable-anagram'):css('width', '100%')

    t:tr()
        :th({ 'Anagram', css = { 'width', '15%' } })
        :th({ 'Solution', css = { 'width', '15%' } })
        :th({ 'Location', css = { 'width', '15%' } })
        :th({ 'Suggested travel', css = { 'width', '25%' } })
        :th({ 'Map', css = { 'width', '15%' } })
        :th({ 'Image', css = { 'width', '15%' } })

    t:tr()
        :td({ parsed.display.title, attr = { 'rowspan', main_rowspan }, css = { 'text-align', 'center' } })
        :td({ parsed.display.chathead, css = { 'text-align', 'center' } })
        :td({ parsed.location_display, attr = { 'rowspan', main_rowspan } })
        :td({ parsed.travel_display, attr = { 'rowspan', main_rowspan } })
        :td({ parsed.map_display, attr = { 'rowspan', main_rowspan }, css = { 'text-align', 'center' } })
        :td({ parsed.image_display, attr = { 'rowspan', main_rowspan }, css = { 'text-align', 'center' } })

    if challenge then
        t:tr():th({ 'Challenge', css = { 'height', '1em' } })
        t:tr():td({ '\n' .. challenge .. '\n', css = { 'text-align', 'left' } })
    end

    return tostring(t)
end

function p.coordinates(frame)
    local rows = get_clue_bucket_data(frame, 'coordinate')
    local output = {}

    -- Two-level grouping: first by coordinate prefix (for jump links), then by clue
    local digit_groups = {}
    local sorted_keys = {}
    for _, row in ipairs(rows) do
        local prefix = row.clue and row.clue:match('^(%d%d)') or '00'
        if not digit_groups[prefix] then
            digit_groups[prefix] = {}
            table.insert(sorted_keys, prefix)
        end
        table.insert(digit_groups[prefix], row)
    end
    table.sort(sorted_keys)

    local difficulty = rows[1] and rows[1].difficulty and rows[1].difficulty:lower() or ''
    local anchor_prefix = difficulty ~= '' and (difficulty .. '-coord-') or 'coord-'

    local jump_links = {}
    for _, key in ipairs(sorted_keys) do
        table.insert(jump_links, string.format('[[#%s%s|%s]]', anchor_prefix, key, key))
    end

    if #jump_links > 0 then
        table.insert(output,
            '<div class="tile" role="navigation" id="toc" style="text-align: center; margin: 1.5em auto; padding: 1em 2em; width: fit-content; max-width: initial">')
        table.insert(output, "'''Jump to:'''<br> " .. table.concat(jump_links, ' &#8226; '))
        table.insert(output, '</div>')
    end

    for _, key in ipairs(sorted_keys) do
        table.insert(output, '<span id="' .. anchor_prefix .. key .. '"></span>')

        local clue_groups, clue_order = group_rows(digit_groups[key])
        table.sort(clue_order)

        for _, clue_text in ipairs(clue_order) do
            table.insert(output, build_coordinate_row(clue_groups[clue_text]))
        end
    end

    return table.concat(output, '\n')
end

function p.cryptics(frame)
    local rows = get_clue_bucket_data(frame, 'cryptic', 'title')
    local groups, order = group_rows(rows)
    local output = {}
    for _, key in ipairs(order) do
        table.insert(output, build_cryptic_row(groups[key]))
    end
    return table.concat(output, '\n')
end

function p.anagrams(frame)
    local rows = get_clue_bucket_data(frame, 'anagram', 'clue')
    local groups, order = group_rows(rows)
    local output = {}
    for _, key in ipairs(order) do
        table.insert(output, build_anagram_row(groups[key]))
    end
    return table.concat(output, '\n')
end

function p.emotes(frame)
    local rows = get_clue_bucket_data(frame, 'emote', 'title')
    local groups, order = group_rows(rows)
    local output = {}
    for _, key in ipairs(order) do
        table.insert(output, build_emote_row(groups[key]))
    end
    return table.concat(output, '\n')
end

function p.maps(frame)
    local rows = get_clue_bucket_data(frame, 'map')
    local groups, order = group_rows(rows)
    local output = {}
    for _, key in ipairs(order) do
        table.insert(output, build_map_row(groups[key]))
    end
    return table.concat(output, '\n')
end

local function build_compscan_list(frame, default_type)
    local rows = get_clue_bucket_data(frame, default_type)
    local groups, order = group_rows(rows)
    local output = {}
    for _, group_name in ipairs(order) do
        table.insert(output, string.format('====[[%s]]====', group_name))
        table.insert(output, build_compscan_section(groups[group_name]))
    end
    return table.concat(output, '\n')
end

function p.compass(frame)
    local rows = get_clue_bucket_data(frame, 'compass')
    local groups, order = group_rows(rows)
    local output = {}
    for _, group_name in ipairs(order) do
        table.insert(output, string.format('====%s====', group_name))
        table.insert(output, build_compass_section(groups[group_name]))
    end
    return table.concat(output, '\n')
end

function p.scan(frame)
    return build_compscan_list(frame, 'scan')
end

local LIST_HANDLERS = {
    coordinate = 'coordinates',
    cryptic    = 'cryptics',
    simple     = 'cryptics',
    compass    = 'compass',
    scan       = 'scan',
    anagram    = 'anagrams',
    emote      = 'emotes',
    map        = 'maps',
}

function p.list(frame)
    local parent = frame:getParent()
    local clue_type = (parent and parent.args or frame.args).type

    local handler = LIST_HANDLERS[clue_type] and p[LIST_HANDLERS[clue_type]]
    if handler then return handler(frame) end
    return '<span class="error">Unknown clue type: ' .. tostring(clue_type) .. '</span>'
end

return p