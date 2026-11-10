local p = {}
local on_main = require('Module:Mainonly').on_main()
local plink = require('Module:Plink')._plink
local icons = mw.loadData('Module:Clue solution/data')
local map = require('Module:Map')
require('Module:Mw.html extension')

local function ucfirst(str) return str:gsub("^%l", string.upper) end

local CLUE_TABLE_CLASS = 'wikitable cluetable'

local DEFAULT_ICON = icons['clue5']

--- Map pin icon per clue type.
local CLUE_ICONS = {
    anagram    = DEFAULT_ICON,
    coordinate = icons['clue2'],
    cryptic    = DEFAULT_ICON,
    simple     = DEFAULT_ICON,
    emote      = DEFAULT_ICON,
    map        = DEFAULT_ICON,
    compass    = icons['clue3'],
    scan       = icons['clue1'],
}

local CLUE_DIFFICULTIES = {
    ['easy'] = true,
    ['medium'] = true,
    ['hard'] = true,
    ['elite'] = true,
    ['master'] = true
}

--- Fields that make up each clue type's clue_type_data bucket record - clue-specific data, generally
local CLUE_TYPE_DATA_FIELDS = {
    anagram    = { 'question', 'answer', 'puzzle', 'chathead' },
    coordinate = { 'fight' },
    cryptic    = { 'keyhint', 'question', 'answer', 'puzzle' },
    simple     = { 'keyhint', 'question', 'answer', 'puzzle' },
    emote      = { 'items', 'emotes', 'hideyhole', 'fight' },
    map        = { 'clueimage' },
    compass    = { 'group' },
    scan       = { 'group' },
}

--- Map link popup field definitions per clue type.
-- Each entry is { label, field } where `field` indexes into a table of formats
-- Read this as, for example, anagram clue maps have popups with fields for the clue, its solution, and a second step -
-- these are challenges questions, puzzles, etc.
local POPUP_FIELDS = {
    anagram    = { { 'Clue', 'clue' }, { 'Solution', 'solution' }, { 'Second step', 'second_step' } },
    coordinate = { { 'Clue', 'clue' }, { 'Fight', 'fight' } },
    cryptic    = { { 'Clue', 'clue' }, { 'Solution', 'solution' }, { 'Second step', 'second_step' } },
    simple     = { { 'Clue', 'clue' }, { 'Solution', 'solution' }, { 'Second step', 'second_step' } },
    emote      = { { 'Clue', 'clue' }, { 'Fight', 'fight' } },
    map        = { { 'Clue', 'clueimage' }, { 'Solution', 'solution' } },
    compass    = { { 'Clue', 'location' } },
    scan       = { { 'Clue', 'location' } },
}

local function puzzle_box(variant)
    local version = '(' .. ucfirst(variant) .. ')'
    return {
        page    = 'Treasure Trails/Guide/Puzzle boxes',
        version = version,
        image   = 'Puzzle box (' .. variant .. ').png',
        display = 'Puzzle box ' .. version,
    }
end

local PUZZLE_DISPLAYS = {
    lockbox = { image = 'Lockbox (master).png', page = 'Treasure Trails/Guide/Lockboxes', display = 'Lockbox' },
    towers  = { image = 'Towers puzzle scroll (master).png', page = 'Treasure Trails/Guide/Towers', display = 'Towers puzzle' },
    castle  = puzzle_box('castle'),
    bridge  = puzzle_box('bridge'),
    tree    = puzzle_box('tree'),
    troll   = puzzle_box('troll'),
}

local COORDINATE_CLUE_FIGHTS = {
    saradomin     = { image = 'Saradomin symbol.png', page = 'Saradomin wizard' },
    zamorak       = { image = 'Zamorak symbol.png', page = 'Zamorak wizard' },
    guthix        = { image = 'Guthix symbol.png', page = 'Guthix wizard' },
    cabbagemancer = { image = 'Brassica Prime symbol.png', page = 'Cabbagemancer' },
    bandos        = { image = 'Bandos symbol.png', page = 'Bandosian wild mage' },
    armadyl       = { image = 'Armadyl symbol.png', page = 'Armadylean shaman (Treasure Trails)', display = 'Armadylean shaman' },
}

local VERBOSE_COORDINATE_CLUE =
'(%d+)%s*degrees?%s+(%d+)%s*minutes?%s+(%a+)%s+(%d+)%s*degrees?%s+(%d+)%s*minutes?%s+(%a+)'
local COMPACT_COORDINATE_CLUE =
'(%d+)%.(%d+)([NSns])%s+(%d+)%.(%d+)([EWew])'

local ORIGIN = { X = 2440, Y = 3161 }

local EMOTE_DISAMBIGUATIONS = {
    bow = 'Bow (emote)',
}

local function image_link(image, opts)
    local parts = { 'File:' .. image }
    local opt_map = {
        ["size"] = opts.size and (tostring(opts.size):gsub('px', '') .. 'px'),
        ["align"] = opts.align,
        ["link"] = opts.link and ('link=' .. opts.link),
    }
    for _, opt in ipairs({ "size", "align", "link" }) do
        if opts[opt] then
            table.insert(parts, opt_map[opt])
        end
    end
    return '[[' .. table.concat(parts, '|') .. ']]'
end

--- Format a wikilink: [[target|display]] or [[target]]
local function wiki_link(target, display)
    if display then return string.format('[[%s|%s]]', target, display) end
    return string.format('[[%s]]', target)
end

local function icon_wikitext_link(image, image_opts, link_opts)
    local target = link_opts.version and (link_opts.page .. '#' .. link_opts.version) or link_opts.page
    local display = link_opts.display or (link_opts.version and link_opts.page)
    local link_table = {
        image_link(image, { size = image_opts.size, link = target }),
        wiki_link(target, display)
    }
    return table.concat(link_table, ' ')
end

--- Grab a clue's difficulty and its "clue" string (usually the operant part of the clue text)
local function parse_page_title()
    local title = mw.title.getCurrentTitle().fullText
    local clue = title:match(' %- (.+)$')
    local difficulty
    for match in title:gmatch('%(([^)]+)%)') do
        if CLUE_DIFFICULTIES[match:lower()] then
            difficulty = match:lower()
            break
        end
    end
    return difficulty, clue
end

--- Standardized edit button
local function edit_button(txt)
    local page_title = mw.title.getCurrentTitle().fullText
    return string.format('[%s %s]', tostring(mw.uri.fullUrl(page_title, 'action=edit')), txt or 'edit')
end

--- Normalize a wikitext image string to a clean 'File:Name.ext' form.
-- Strips brackets, pipes (|frameless, |200px, etc.), and {{!}} escapes.
local function normalize_image(file)
    if not file or file == '' then return nil end
    local clean = file:gsub('%[', ''):gsub('%]', ''):gsub('{{!}}', '|')
    -- Take only the part before any pipe (removes |frameless, |200px, etc.)
    clean = clean:match('^([^|]+)') or clean
    -- Trim whitespace
    clean = clean:match('^%s*(.-)%s*$')
    if clean == '' then return nil end
    -- Strip File: prefix — image_link adds it back for display
    return (clean:gsub('^[Ff]ile:', ''))
end

--- Convert degree/minute notation to a tile coordinate on one axis
local function degrees_to_tile(deg, min, positive, origin)
    local sign = positive and 1 or -1
    return sign * (32 * deg + math.ceil(min * 8 / 15)) + origin
end

--- Parse degree notation string into structured components
-- Returns two tables: { x, y } tile coords, { ns_deg, ns_min, ns, ew_deg, ew_min, ew } display components
-- nil, nil on failure
local function parse_degree_notation(coord_str)
    local ns_deg, ns_min, ns, ew_deg, ew_min, ew = coord_str:match(VERBOSE_COORDINATE_CLUE)
    if not ns_deg then
        ns_deg, ns_min, ns, ew_deg, ew_min, ew = coord_str:match(COMPACT_COORDINATE_CLUE)
    end
    if not ns_deg then return nil, nil end

    ns_deg, ns_min = tonumber(ns_deg), tonumber(ns_min)
    ns = ns:sub(1, 1):upper()

    ew_deg, ew_min = tonumber(ew_deg), tonumber(ew_min)
    ew = ew:sub(1, 1):upper()

    local tiles = {
        x = degrees_to_tile(ew_deg, ew_min, ew == 'E', ORIGIN.X),
        y = degrees_to_tile(ns_deg, ns_min, ns == 'N', ORIGIN.Y),
    }
    local degrees = {
        ns_deg = ns_deg,
        ns_min = ns_min,
        ns = ns,
        ew_deg = ew_deg,
        ew_min = ew_min,
        ew = ew,
    }
    return tiles, degrees
end

--- Parse coordinate string into x/y arrays
-- Single point: "x1,y1" -> {x1}, {y1}
-- Multiple points: "x1,y1;x2,y2;x3,y3;..." -> {x1, x2, x3, ...}, {y1, y2, y3, ...}
local function unzip_points(coord_str)
    local xs, ys = {}, {}
    for point in coord_str:gmatch('[^;]+') do
        local parts = mw.text.split(mw.text.trim(point), '%s*,%s*')
        local x, y = tonumber(parts[1]), tonumber(parts[2])
        if x and y then
            table.insert(xs, x)
            table.insert(ys, y)
        end
    end
    return xs, ys
end

--- Zip two parallel arrays into an array of {x, y} tables
local function zip_points(xs, ys)
    local points = {}
    for i = 1, #xs do
        points[i] = { x = xs[i], y = ys[i] }
    end
    return points
end

--- Compute the rounded mean of a numeric array for the centroid
local function mean(vals)
    local sum = 0
    for i = 1, #vals do sum = sum + vals[i] end
    return math.floor(sum / #vals + 0.5)
end

-- Collect suffixed args (base, base1, base2, base3...) into an array
local function collect_suffixed(args, base)
    local result = {}
    -- Check unnumbered base key first (e.g. "emote")
    if args[base] then
        result[1] = args[base]
    end
    local i = 1
    while args[base .. i] do
        -- Only add numbered key if it wasn't already captured as the base key
        if i > 1 or not args[base] then
            result[#result + 1] = args[base .. i]
        end
        i = i + 1
    end
    return result
end

--- Shallow-copy a table (one level deep)
local function shallow_copy(t)
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end

--- Normalize empty-string template args to nil
local function nonempty(s)
    if s and s ~= '' then return s end
    return nil
end

local fmt = {}

function fmt.chathead(solution, chathead, page)
    if not solution then return nil end

    local pic = (chathead or (solution .. ' chathead')) .. '.png'
    local target = page or solution
    local display = page and solution or nil
    local link = icon_wikitext_link(pic, { size = '35x35' }, { page = target, display = display })
    return string.format('<span class="chathead-link">%s</span>', link)
end

function fmt.clue_link(clue_text, difficulty, display_text)
    local page = string.format('Clue scroll (%s) - %s', difficulty:lower(), clue_text)
    return "''" .. wiki_link(page, display_text or clue_text) .. "''"
end

function fmt.coord_display(degrees, clue, difficulty)
    if not degrees then return edit_button("''Invalid coordinates''") end

    local verbose_base = '%02d degrees %02d minutes %s'
    local compact_base = '%02d.%02d%s'
    local ns_word = (degrees.ns == 'N') and 'north' or 'south'
    local ew_word = (degrees.ew == 'E') and 'east' or 'west'

    local verbose = string.format(verbose_base, degrees.ns_deg, degrees.ns_min, ns_word) ..
        '<br>' .. string.format(verbose_base, degrees.ew_deg, degrees.ew_min, ew_word)

    -- Link the verbose display to the clue page if clue and difficulty are available
    if clue and difficulty then
        local page = string.format('Clue scroll (%s) - %s', difficulty:lower(), clue)
        verbose = wiki_link(page, verbose)
    end

    local compact = string.format(compact_base, degrees.ns_deg, degrees.ns_min, degrees.ns) ..
        ' ' .. string.format(compact_base, degrees.ew_deg, degrees.ew_min, degrees.ew)

    return verbose .. '<br><span style="font-size:smaller;">(' .. compact .. ')</span>'
end

function fmt.coord_shorthand(clue)
	local clue_clean = (clue or ''):gsub('<br%s*/?>', ' '):gsub(',', ' '):gsub('%s+', ' ')
    local tiles, degrees = parse_degree_notation(clue_clean)
    return string.format('%02d%02d%s%02d%02d%s',
    	degrees.ns_deg, degrees.ns_min, degrees.ns,
    	degrees.ew_deg, degrees.ew_min, degrees.ew)
end

function fmt.emotes(emotes)
    if not emotes or #emotes == 0 then
        return "''None''"
    end

    local emotes_tbl = {}
    for _, emote in ipairs(emotes) do
        local parts = mw.text.split(emote, '%s*,%s*')
        local plinked_parts = {}
        for _, part in ipairs(parts) do
            local pic = part .. ' emote icon.png'
            local target = EMOTE_DISAMBIGUATIONS[part:lower()] or part
            table.insert(plinked_parts,
                icon_wikitext_link(pic, { size = 30 }, { page = target, display = part }))
        end
        table.insert(emotes_tbl, table.concat(plinked_parts, " or "))
    end

    return table.concat(emotes_tbl, " then ")
end

function fmt.fight(fight)
    if not fight then return "''None''" end
    local page = fight:match('^([^#]+)') or fight

    local icon_fight = COORDINATE_CLUE_FIGHTS[page:lower()]

    if icon_fight then
        return icon_wikitext_link(icon_fight.image, { size = 30 }, icon_fight)
    end
    -- Use page name (without #anchor) as display text when anchor is present
    return wiki_link(fight, page ~= fight and page or nil)
end

function fmt.hideyhole(text, size)
    if not text then return "''None''" end

    local pic = text .. '.png'
    local link = icon_wikitext_link(pic, { size = size or '75' }, { page = text })
    return link
end

function fmt.image(image)
    if not image then return '[[Special:Upload|Please upload an image!]]' end
    return image_link(image, { size = 300, align = 'center' })
end

function fmt.items(items)
    if not items or #items == 0 then
        return edit_button("''Please provide items''")
    end

    local items_tbl = {}
    for _, entry in ipairs(items) do
        local suffix = entry.item:match('^[Nn]othing (.+)$')
        local item_str = suffix and ("[[File:Nothing.png]] Nothing " .. suffix)
            or plink(entry.item, { pic = entry.pic })
        table.insert(items_tbl, item_str)
    end
    return table.concat(items_tbl, "<br>")
end

function fmt.list(text, fallback)
    if text then return '\n' .. text .. '\n' end
    return fallback or "''None''"
end

function fmt.location(text)
    if text then return text end
    return edit_button("''Please provide a location''")
end

function fmt.map(map_data, extra_pin, popup_pin)
    local xs, ys = map_data.xs, map_data.ys
    if not xs or #xs == 0 then return edit_button("''Please provide coords''") end

    local function make_pin(pin, map_opts)
        return map.featPin({ jagexCoords = true }, map_opts, {
            x = pin.x,
            y = pin.y,
            description = pin.description,
            iconWikiLink = pin.icon or 'pin_magenta.svg',
            iconSize = { 26, 42 },
            iconAnchor = { 13, 42 },
            popupAnchor = { 0, -42 },
        })
    end

    local map_opts = { mapID = map_data.mapID, plane = map_data.plane }

    -- Single point -> pin; multiple points -> polygon
    local primary = (#xs == 1) and make_pin(popup_pin, map_opts)
        or map.featPolygon({ pins = zip_points(xs, ys) }, map_opts)

    return map.createFeatMap({
        x = mean(xs),
        y = mean(ys),
        mapID = map_data.mapID,
        plane = map_data.plane,
        etype = 'mapframe',
        text = 'Show on map',
    }, {
        type = 'FeatureCollection',
        features = {
            primary,
            extra_pin and make_pin(extra_pin, map_opts)
        }
    }
    )
end

--- Format the "second step" of a clue
-- Second steps are essentially Either[puzzle, key hint, question/answer pair] | nil
function fmt.second_step(opts)
    if not opts then return nil end

    if opts.puzzle then
        local key = opts.puzzle:lower()
        local data = PUZZLE_DISPLAYS[key] or opts.puzzle
        return icon_wikitext_link(data.image, { size = 30 }, data)
    end

    if opts.keyhint then
        return string.format("'''Key hint:''' %s", opts.keyhint)
    end

    if opts.question or opts.answer then
        local parts = {}
        if opts.question then
            table.insert(parts, string.format("'''Question:''' %s", opts.question))
        end
        if opts.answer then
            table.insert(parts, string.format("'''Answer:''' %s", opts.answer))
        end
        return table.concat(parts, '<br>')
    end

    return nil
end

function fmt.solution(text)
    if text then return text end
    return edit_button("''Please provide a solution''")
end

function fmt.travel(text)
    return fmt.list(text, edit_button("''Please provide suggested travel''"))
end

local function parse_hideyhole(args)
    if not args.hideyhole then return nil end

    local hideyhole_table = {
        page = args.hideyhole,
        description = "'''Hidey-hole:''' " .. wiki_link(args.hideyhole),
    }

    if args.hideyholecoords then
        local hh_xs, hh_ys = unzip_points(args.hideyholecoords)
        hideyhole_table.x = hh_xs[1]
        hideyhole_table.y = hh_ys[1]
    end

    return hideyhole_table
end

local function parse_map_data(args)
    if not args.coords then return {} end
    local xs, ys = unzip_points(args.coords)
    return {
        xs = xs,
        ys = ys,
        mapID = tonumber(args.mapID) or 28,
        plane = tonumber(args.plane) or 0,
    }
end

local function parse_items_data(args)
    local raw = collect_suffixed(args, 'item')
    local items = {}
    for index, item in ipairs(raw) do
        items[index] = { item = item, pic = args['itempic' .. index] }
    end
    return items
end

--- Build a complete popup pin from map data and pre-rendered display values.
local function build_popup_pin(map_data, display, clue_type)
    local xs, ys = map_data.xs, map_data.ys
    if not xs or #xs == 0 then return nil end
    local x, y = xs[1], ys[1]
    local parts = {}
    for _, field in ipairs(POPUP_FIELDS[clue_type]) do
        local val = display[field[2]]
        if val then
            parts[#parts + 1] = string.format("'''%s:''' %s", field[1], val)
        end
    end
    parts[#parts + 1] = string.format('(%d, %d)', x, y)
    return {
        x = x,
        y = y,
        description = table.concat(parts, '<br>'),
        icon = CLUE_ICONS[clue_type],
    }
end

local function parse_args(args, clue_type)
    -- Simple clues arrive with type="simple" set by the template
    clue_type = clue_type or args.type

    local parsed = {
        -- General clue metadata. In bucket order
        difficulty = args.difficulty or parse_page_title(),
        clue_type = clue_type,
        title = args.title,
        clue = nonempty(args.clue),
        solution = nonempty(args.solution),
        solution_page = nonempty(args.solution_page),
        requirements = nonempty(args.requirements),
        location_title = args.location_title,
        location = nonempty(args.location),
        travel = nonempty(args.travel),
        map_data = parse_map_data(args),
        image = normalize_image(args.image),

        -- Clue type-specific fields (these get put into clue_type_data in bucket; they're not top level)
        question = args.question,
        answer = args.answer,
        puzzle = args.puzzle,
        keyhint = args.keyhint,
        chathead = args.chathead,
        group = args.group,
        emotes = collect_suffixed(args, 'emote'),
        hideyhole = parse_hideyhole(args),
        items = parse_items_data(args),
        clueimage = normalize_image(args.clueimage),
        degrees = args.degrees,
        fight = nonempty(args.fight_npc),
    }

    parsed.display = {
        clue        = fmt.clue_link(parsed.clue, parsed.difficulty),
        solution    = fmt.solution(parsed.solution),
        chathead    = fmt.chathead(parsed.solution, parsed.chathead, parsed.solution_page),
        second_step = fmt.second_step(parsed),
        fight       = fmt.fight(parsed.fight),
        clueimage   = fmt.image(parsed.clueimage),
        location    = fmt.location(parsed.location),
        travel      = fmt.travel(parsed.travel),
        image       = fmt.image(parsed.image),
        coordinates = fmt.coord_display(parsed.degrees, parsed.clue, parsed.difficulty),
    }

    -- Parsed.display is needed for popup text - map clues and anagram/cryptic clues use formatted displays in popups
    parsed.display.map = fmt.map(parsed.map_data, parsed.hideyhole,
        build_popup_pin(parsed.map_data, parsed.display, parsed.clue_type))

    return parsed
end

--- Check whether a value has meaningful content (works for strings + tables)
local function has_content(val)
    if type(val) == 'table' then return next(val) ~= nil end
    if type(val) == 'string' then return #val > 0 end
    return val ~= nil
end

--- Writes to bucket 'clue'. Bucket put, bucket.put for anyone searching
local function write_bucket_row(parsed)
    local clue_type_data = {}
    for _, key in ipairs(CLUE_TYPE_DATA_FIELDS[parsed.clue_type]) do
        if parsed[key] and has_content(parsed[key]) then
            clue_type_data[key] = parsed[key]
        end
    end

    if clue_type_data.clueimage then
        clue_type_data.clueimage = 'File:' .. clue_type_data.clueimage
    end

    bucket('clue').put{
        clue_type = parsed.clue_type,
        difficulty = parsed.difficulty,
        clue = parsed.clue,
        solution = parsed.solution,
        image = parsed.image and ('File:' .. parsed.image),
        title = parsed.title,
        location_title = parsed.location_title,
        location = parsed.location,
        travel = parsed.travel,
        requirements = parsed.requirements,

        x_coordinate = parsed.map_data.xs,
        y_coordinate = parsed.map_data.ys,
        map_id = parsed.map_data.mapID,
        plane = parsed.map_data.plane,

        type_data = next(clue_type_data) and mw.text.jsonEncode(clue_type_data),
    }

    -- Write to bucket:coordinates
    local md = parsed.map_data
    if md.xs and #md.xs > 0 then
        bucket('coordinates').put{
            type = parsed.clue_type .. ' clue',
            title = parsed.clue,
            x = md.xs,
            y = md.ys,
            plane = md.plane or 0,
            mapid = md.mapID or 28,
        }
    end
end

--- tostring the table and when on main, write bucket data and categories
local function finalize(parsed, html_node)
    local to_category_string = function(cat) return '[[Category:' .. cat .. ']]' end

    local out = { tostring(html_node) }

    if on_main then
        write_bucket_row(parsed)
        -- Generic "clue scrolls category"
        table.insert(out, to_category_string("Clue scrolls"))
        table.insert(out, to_category_string(ucfirst(parsed.clue_type) .. ' clue scrolls'))
        table.insert(out, to_category_string(ucfirst(parsed.difficulty) .. ' clue scrolls'))
        if not parsed.image then
            table.insert(out, to_category_string("Needs image"))
        end
    end

    return table.concat(out, '')
end

p.ANAGRAM_PREAMBLE = "This anagram reveals<br>who to speak to next:<br><br>"

--- Anagram clues
function p.anagram(frame)
    local copied_args = shallow_copy(frame:getParent().args)
    copied_args.title = copied_args.title:gsub(p.ANAGRAM_PREAMBLE, ''):gsub(copied_args.clue, '')
    local parsed = parse_args(copied_args, 'anagram')

    local clue_cell = p.ANAGRAM_PREAMBLE .. parsed.title .. parsed.display.clue

    local anagram_table = mw.html.create('table'):addClass(CLUE_TABLE_CLASS)

    anagram_table
        :tr():th('Clue'):td( clue_cell )
        :tr():th('Solution'):td( parsed.display.chathead )
        :IF(parsed.display.second_step)
        	:tr():th('Second step'):td( parsed.display.second_step )
        :END()
        :tr():th('Location'):td( parsed.display.location )
        :tr():th('Suggested travel'):td( parsed.display.travel )
        :tr():th('Map'):td{ parsed.display.map, css = { 'text-align', 'center' } }
        :tr():th('Image'):td{ parsed.display.image, css = { 'text-align', 'center' } }

    return finalize(parsed, anagram_table)
end

--- Coordinate clues
function p.coordinate(frame)
    local copied_args = shallow_copy(frame:getParent().args)
    local clue_clean = (copied_args.clue or ''):gsub('<br%s*/?>', ' '):gsub(',', ' '):gsub('%s+', ' ')
    local tiles, degrees = parse_degree_notation(clue_clean)
    if not copied_args.coords then
        copied_args.coords = tiles and string.format('%d,%d', tiles.x, tiles.y)
    end
    copied_args.degrees = degrees
    local parsed = parse_args(copied_args, 'coordinate')
    parsed.title = parsed.display.coordinates

    local coordinate_table = mw.html.create('table'):addClass(CLUE_TABLE_CLASS)

    coordinate_table
        :tr():th('Coordinates'):td{ parsed.display.coordinates, css = { 'text-align', 'center' } }
        :IF(parsed.requirements ~= 'None')
        	:tr():th('Requirements'):td(fmt.list(parsed.requirements))
        :END()
        :IF(parsed.display.fight ~= "''None''" )
        	:tr():th('Fight'):td( parsed.display.fight )
        :END()
        :tr():th('Location'):td( parsed.display.location )
        :tr():th('Suggested travel'):td( parsed.display.travel )
        :tr():th('Map'):td{ parsed.display.map, css = { 'text-align', 'center' } }
        :tr():th('Image'):td{ parsed.display.image, css = { 'text-align', 'center' } }

    return finalize(parsed, coordinate_table)
end

--- Cryptic and simple clues
function p.cryptic(frame)
    local args = frame:getParent().args
    -- Simple clues follow the cryptic model; they arrive with type="simple" already set,
    -- which parse_args picks up and uses for both clue_type and clue_type_data.
    local parsed = parse_args(args, frame.args.type or args.type or 'cryptic')

    local cryptic_table = mw.html.create('table'):addClass(CLUE_TABLE_CLASS)

    cryptic_table
        :tr():th('Cryptic'):td( parsed.display.clue )
        :IF(parsed.title ~= '')
        	:tr():th('Title'):td( parsed.title )
        :END()
        :tr():th('Solution'):td( parsed.display.solution )
        :IF(parsed.display.second_step)
        	:tr():th('Second step'):td( parsed.display.second_step )
        :END()
        :tr():th('Location'):td( parsed.display.location )
        :tr():th('Suggested travel'):td( parsed.display.travel )
        :tr():th('Map'):td{ parsed.display.map, css = { 'text-align', 'center' } }
        :tr():th('Image'):td{ parsed.display.image, css = { 'text-align', 'center' } }

    return finalize(parsed, cryptic_table)
end

--- Emote clues
function p.emote(frame)
    local args = frame:getParent().args
    local parsed = parse_args(args, 'emote')

    local emote_table = mw.html.create('table'):addClass(CLUE_TABLE_CLASS)

    emote_table
        :tr():th('Clue'):td( parsed.display.clue )
        :IF(parsed.requirements)
        	:tr():th('Requirements'):td(fmt.list(parsed.requirements))
        :END()
        :tr():th('Emote'):td(fmt.emotes(parsed.emotes))
        :tr():th('Equipments'):td(fmt.items(parsed.items))
        :tr():th('Hidey-hole'):td(fmt.hideyhole(parsed.hideyhole and parsed.hideyhole.page))
        :tr():th('Fight'):td(parsed.display.fight)
        :tr():th('Location'):td( parsed.display.location )
        :tr():th('Suggested travel'):td( parsed.display.travel )
        :tr():th('Map'):td{ parsed.display.map, css = { 'text-align', 'center' } }
        :tr():th('Image'):td{ parsed.display.image, css = { 'text-align', 'center' } }

    return finalize(parsed, emote_table)
end

--- Map clues (the ones that are a picture of a map)
function p.map(frame)
    local args = frame:getParent().args
    local parsed = parse_args(args, 'map')

    local map_table = mw.html.create('table'):addClass(CLUE_TABLE_CLASS)

    map_table
        :tr():th('Clue'):td{ parsed.display.clueimage, css = { 'text-align', 'center' } }
        :tr():th('Solution'):td( parsed.display.solution )
        :tr():th('Location'):td( parsed.display.location )
        :tr():th('Suggested travel'):td( parsed.display.travel )
        :tr():th('Map'):td{ parsed.display.map, css = { 'text-align', 'center' } }
        :tr():th('Image'):td{ parsed.display.image, css = { 'text-align', 'center' } }

    return finalize(parsed, map_table)
end

--- Compass + scan clues act the same way on their pages - rows, that is
local function compass_scan_row(frame, clue_type, optional_difficulty_default)
    local copied_args = shallow_copy(frame:getParent().args)
    copied_args.difficulty = copied_args.difficulty or optional_difficulty_default
    local parsed = parse_args(copied_args, clue_type)

    local compscan_row = mw.html.create('tr')

    compscan_row
        :td{ parsed.display.location, css = { 'width', '40%' } }
        :td{ parsed.display.image, css = { 'width', '30%' } }
        :td{ parsed.display.map, css = { 'width', '30%' } }

    return finalize(parsed, compscan_row)
end

--- Compass clues
-- Elite difficulty by default - the only master scans are on the Arc, so we pass in the clue type on those ones only
function p.compass(frame)
    return compass_scan_row(frame, 'compass', 'elite')
end

--- Scan clues
-- No default difficulty
function p.scan(frame)
    return compass_scan_row(frame, 'scan')
end

--- Banner header for compass and scan clues
local function compass_scan_info_banner(frame)
    local args = frame:getParent().args
    local text = args.text or edit_button("''Please provide text''")

    local compscan_banner = mw.html.create('div')
        :addClass('transcript')
        :css('text-align', 'center')
        :css('width', '520px')
        :wikitext(text)

    return tostring(compscan_banner)
end

--- Compass clue banners
function p.compass_info(frame)
    return compass_scan_info_banner(frame)
end

--- Scan clue banners
function p.scan_info(frame)
    return compass_scan_info_banner(frame)
end

p.fmt = fmt
p.CLUE_TYPE_DATA_FIELDS = CLUE_TYPE_DATA_FIELDS
p.POPUP_FIELDS = POPUP_FIELDS
p.CLUE_ICONS = CLUE_ICONS
p.build_popup_pin = build_popup_pin

return p