local p = {}

local params = require('Module:Paramtest')
local lang = mw.language.getContentLanguage()
local coins_image = require('Module:Coins image')
local curr_image = require('Module:Currency Image')
local exchange = require('Module:Exchange')
local yesno = require('Module:Yesno')
local round = require('Module:Round')
local on_main = require('Module:Mainonly').on_main
require("Module:Mw.html extension")

local var = mw.ext.VariablesLua

-- precalculated cached data
local droppeditem_data = mw.loadJsonData('Module:DropsLine/itemData.json')
local geprices_data = mw.loadJsonData('Module:GEPrices/data.json')
local highalch_data = mw.loadJsonData('Module:GEHighAlchs/data.json')

local ptitle = mw.title.getCurrentTitle()
local title = ptitle.fullText
local pgTitle = ptitle.text

local _noted = '&nbsp;<span class="dropsline-noted">(noted)</span>'
local members_note = '&nbsp;<sub title="Members only" style="cursor:help; margin-left:3px;">(m)</sub>'

local _priceStrings = {
    coins = "%s %s",
    standard = "%s %s each",
    alch_alt = "%s %s each; this item has a distinct value, even though it cannot be alchemised.",
    ge_alch = "%s %s each; this is the high alchemy value " ..
        "as this item cannot be traded on the Grand Exchange.",
    ge_alch_alt = "%s %s each; this item has a distinct value, " ..
        "even though it cannot be traded on the Grand Exchange.",
    ge_alt = "%s %s each; this item has a distinct value, even though it cannot " ..
        "be traded on the Grand Exchange or be alchemised."
}

local _altval =
'<span class="dropsline-altval" style="margin-left:0.3em;">[[File:AltValue.png|link=|frameless|20px]]</span>'
local valueImages = {
    alch_alt = _altval,
    ge_alt = _altval,
    ge_alch = '<span class="dropsline-gealch" style="margin-left:0.3em;">' ..
        '[[File:High Level Alchemy icon.png|link=High Level Alchemy|frameless|20px]]</span>'
}

-- txt = bg, sort, needs_exact; acceptable non-quantity rarity names
local rarities = {
    always = { 'table-bg-blue', 1, false },
    common = { 'table-bg-green', 16, true },
    uncommon = { 'table-bg-yellow', 64, true },
    rare = { 'table-bg-orange', 256, true },
    ['very rare'] = { 'table-bg-red', 1024, true },
    conditional = { 'table-bg-pink', 2048, false },
    random = { 'table-bg-pink', 4096, true },
    varies = { 'table-bg-pink', 4096, false },
    once = { 'table-bg-pink', 65536, false },
    _default = { 'table-bg-grey', 65536, true }
}

-- Treasure Hunter gem icons
local th_gem_icons = {
    white = '[[File:THGem-common.png|link=|frameless|20px|Common]]',
    yellow = '[[File:THGem-fairly-common.png|link=|frameless|20px|Fairly common]]',
    orange = '[[File:THGem-uncommon.png|link=|frameless|20px|Uncommon]]',
    red = '[[File:THGem-rare.png|link=|frameless|20px|Rare]]',
    purple = '[[File:THGem-very-rare.png|link=|frameless|20px|Very rare]]',
    shadow = '[[File:THGem-ultra-rare.png|link=|frameless|20px|Shadow]]',
    ['ultra-rare'] = '[[File:THGem-ultra-rare2.png|link=|frameless|20px|Ultra-Rare]]',
    no = 'N/A',
}

-- Treasure Hunter gem rarities
local th_gem_rarities = {
    white = 1,
    yellow = 1 / 2,
    orange = 1 / 3,
    red = 1 / 4,
    purple = 1 / 5,
    shadow = 1 / 6,
    ['ultra-rare'] = 1 / 7,
    no = 0,
}

-- Squeal of Fortune slot icons
local sof_slot_icons = {
    common = '[[File:SoF_slot_common.png|link=|frameless|x31px|Common]]',
    uncommon = '[[File:SoF_slot_uncommon.png|link=|frameless|x31px|Uncommon]]',
    rare = '[[File:SoF_slot_rare.png|link=|frameless|x31px|Rare]]',
    ['super rare'] = '[[File:SoF_slot_super_rare.png|link=|frameless|x31px|Super rare]]',
    no = 'N/A',
}

-- Squeal of Fortune slot rarities
local sof_slot_rarities = {
    common = 1,
    uncommon = 1 / 2,
    rare = 1 / 3,
    ['super rare'] = 1 / 4,
    no = 0,
}

-- colour-code (arbitrary numbers)
local function get_rarity_class(val)
    return val >= 1 and 'table-bg-blue'
        or val >= 1 / 16 and 'table-bg-green'
        or val >= 1 / 64 and 'table-bg-yellow'
        or val >= 1 / 256 and 'table-bg-orange'
        or 'table-bg-red'
end

local function commas(n)
    if tonumber(n) and n ~= 1 / 0 then
        return lang:formatNum(tonumber(n))
    end
    return n
end

local function sigfigalt(n)
    if n >= 100 then
        return math.floor(n + 0.5)
    end
    return round.sigfig(n, 3)
end

local function qty_parse(quantity)
    -- normalize dashes before splitting
    local normalized = mw.ustring.gsub(quantity, '[-—]', '–')
    local vals = mw.text.split(normalized, '[,;]')
    local values = {}
    for _, v in ipairs(vals) do
        local noted = v:lower():find('%(noted%)') ~= nil
        local clean = v:gsub('%s', ''):gsub('%([Nn]oted%)', '')
        local parts = mw.text.split(clean, '–')
        local a, b = tonumber(parts[1]), tonumber(parts[2])
        if not a then
            error('Non-numeric quantity found: "' .. tostring(quantity) .. '"')
        end
        if b and a > b then a, b = b, a end
        table.insert(values, { min = a, max = b, noted = noted })
    end
    return { values = values }
end

-- Returns min and max of the dataset (nil, nil for special cases)
local function qty_range(parsed)
    if parsed.special then return nil, nil end
    local low, high = math.huge, 0
    for _, v in ipairs(parsed.values) do
        low = math.min(low, v.min)
        high = math.max(high, v.max or v.min)
    end
    return low, high
end

-- quantity -> html quantity
local function qty_format_html(parsed)
    if parsed.special then return parsed.special end
    local parts = {}
    for _, v in ipairs(parsed.values) do
        local s = v.max and (commas(v.min) .. '–' .. commas(v.max)) or commas(v.min)
        if v.noted then s = s .. _noted end
        table.insert(parts, s)
    end
    -- Add line break if too many elements
    if #parts > 11 then
        local mid = math.floor(#parts / 2)
        parts[mid] = '<br/>' .. parts[mid]
    end
    return table.concat(parts, '; ')
end

-- quantity -> bucket quantity (basically just no commas and a nice (noted) string)
local function qty_bucket(parsed)
    if parsed.special then return parsed.special end
    local parts = {}
    for _, v in ipairs(parsed.values) do
        local s = v.max and (v.min .. '–' .. v.max) or tostring(v.min)
        if v.noted then s = s .. ' (noted)' end
        table.insert(parts, s)
    end
    return table.concat(parts, ', ')
end

-- turns out value could only ever possibly be a single number
local function get_total(value, qhigh, qlow)
    if not value or value < 0 then return false end
    if not qhigh or not qlow then
        return commas(value), value
    end
    local lower, higher = qlow * value, qhigh * value
    if higher == lower then
        return commas(higher), higher
    end
    return commas(lower) .. '–' .. commas(higher), higher
end

-- parse output from {{DropNote}} into
local function parse_dropnotes(notes)
    local note_list = {}
    local notes_new = ''
    local has_ref = notes:match('UNIQ%-%-ref') ~= nil

    if not string.match(notes, '<separator2>') then
        return note_list, notes, has_ref
    end

    -- We're creating refs on the drop source 'programmatically'
    local note_list_raw = mw.text.split(notes, '<separator2>')
    for _, note_raw in ipairs(note_list_raw) do
        if note_raw ~= '' then
            local note_table = {}
            local note_keyvals = mw.text.split(note_raw, '<separator1>')
            for _, keyval in ipairs(note_keyvals) do
                local eq_pos = mw.ustring.find(keyval, '=')
                local param_name = mw.ustring.sub(keyval, 1, eq_pos - 1)
                local param_val = mw.ustring.sub(keyval, eq_pos + 1)
                note_table[param_name] = param_val:gsub('<(/?)mathnote>', '<%1math>')
            end
            if params.has_content(note_table.name) then
                local varname = 'dropnote_' .. note_table.name
                if var.varexists(varname) then
                    note_table.content = var.var(varname)
                else
                    var.vardefine(varname, note_table.content)
                end
            end
            table.insert(note_list, note_table)
            notes_new = notes_new .. mw.getCurrentFrame():extensionTag {
                name = 'ref',
                content = note_table.content,
                args = { group = 'd', name = note_table.name }
            }
        end
    end
    return note_list, notes_new, has_ref
end

local function get_currency_image(altcur, total)
    local total_string = tostring(total)
    local img = curr_image(altcur, total_string) or 'AltValue.png'
    return '<span class="dropsline-altval" style="margin-left:0.3em;">' ..
        '[[File:' .. img .. '|link=|frameless|20px]]</span>'
end

local function get_currency_name(altcur, price)
    local lowcur = string.lower(altcur)
    local subbed = tostring(price):gsub('%W', '')
    local price_num = tonumber(subbed) or 0

    local is_plural = lang:plural(price_num, 'f', 't') == 't'
    if is_plural or lowcur == 'zemomark' or lowcur == 'tokkul' or lowcur == 'teci' then
        return altcur
    elseif lowcur == 'pieces of eight' then
        return 'piece of eight'
    else -- drop the last letter
        return altcur:sub(1, -2)
    end
end

-- Build GE and alch cell data based on item type and value info
local function get_price_cell_data(ctx)
    local NA_DATA = { content = 'N/A', title = 'This does not exist.', is_na = true, sort = nil }

    -- Nothing has no value
    if ctx.is_nothing then
        return NA_DATA, NA_DATA
    end

    -- Compute totals from value_info
    local ge_info = ctx.value_info.ge
    local total, vsort
    if ge_info then
        total, vsort = get_total(ge_info.value, ctx.qty_high, ctx.qty_low)
    end

    local alch_info = ctx.value_info.alch
    local alchtotal, vasort
    if alch_info then
        alchtotal, vasort = get_total(alch_info.value, ctx.qty_high, ctx.qty_low)
    end

    -- Coins are 1:1
    if ctx.is_coins then
        local coins_title = mw.ustring.format('%s coin%s', total, lang:plural(vsort, '', 's'))
        local coins_data = { content = total, title = coins_title, sort = vsort }
        return coins_data, coins_data
    end

    -- Normal items: build from value_info
    local ge_data = { content = nil, title = nil, is_na = false, sort = vsort }
    local alch_data = { content = nil, title = nil, is_na = false, sort = vasort }

    -- Alch price (processed first so it's available as GE fallback)
    local alch_currency_name
    if alch_info then
        alch_currency_name = lang:plural(alch_info.value, 'coin', 'coins')
        local currency_img
        if alch_info.currency then
            currency_img = get_currency_image(alch_info.currency, vasort)
            alch_currency_name = get_currency_name(alch_info.currency, alch_info.value)
        end
        alch_data.title = mw.ustring.format(_priceStrings[alch_info.type], commas(alch_info.value), alch_currency_name)
        alch_data.content = alchtotal .. (currency_img or valueImages[alch_info.type] or '')
    end

    -- GE price (with alch fallback)
    if ge_info then
        local currency_name = lang:plural(ge_info.value, 'coin', 'coins')
        local currency_img
        if ge_info.currency then
            currency_img = get_currency_image(ge_info.currency, vsort)
            currency_name = get_currency_name(ge_info.currency, ge_info.value)
        end
        ge_data.title = mw.ustring.format(_priceStrings[ge_info.type], commas(ge_info.value), currency_name)
        ge_data.content = total .. (currency_img or valueImages[ge_info.type] or '')
    elseif alch_info then
        ge_data.title = mw.ustring.format(_priceStrings.ge_alch, commas(alch_info.value), alch_currency_name)
        ge_data.content = alchtotal .. valueImages.ge_alch
        ge_data.sort = vasort -- Use alch sort when falling back
    end

    -- no GE
    if ge_data.content == nil then
        ge_data = {
            content = 'Not sold',
            title =
            'This item cannot be traded on the Grand Exchange nor alchemised and has no applicable value to display.',
            is_na = true,
            sort = nil
        }
    end

    -- no alch
    if alch_data.content == nil then
        alch_data = {
            content = 'N/A',
            title = 'This item cannot be alchemised and has no applicable value to display.',
            is_na = true,
            sort = nil
        }
    end

    return ge_data, alch_data
end

-- category mappings
local name_categories = {
    { 'effigy',                       '[[Category:Ancient effigy drop sources]]' },
    { 'clue scroll ',                 '[[Category:Clue scroll drop sources]]' },
    { 'rare drop table',              '[[Category:Rare drop table sources]]' },
    { 'wilderness shared loot table', '[[Category:Wilderness shared loot table sources]]' },
}

-- adding categories to mainspace
local function categories(name, qty_parsed, rarity, drop_version_found, leaguesCategory)
    local ret = ''
    name = name:lower()
    for _, entry in ipairs(name_categories) do
        if name:find(entry[1]) then
            ret = ret .. entry[2]
        end
    end
    if rarity == 'Unknown' then
        ret = ret .. '[[Category:Needs drop rarity added]]'
    end
    if qty_parsed.special == 'Unknown' then
        ret = ret .. '[[Category:Needs drop quantity added]]'
    end
    if drop_version_found == false then
        ret = ret .. '[[Category:Uses unrecognised drop version]]'
    end
    if leaguesCategory ~= '' then
        ret = ret .. leaguesCategory
    end
    return ret
end

-- Add data attributes to a rarity span, return title text if numeric
local function add_rarity_attrs(span, info, prefix)
    if type(info.value) ~= 'number' then return nil end
    prefix = prefix or ''
    span:attr({
        ['data-drop-fraction'] = prefix .. info.text,
        ['data-drop-oneover'] = prefix .. info.oneover,
        ['data-drop-percent'] = prefix .. info.percent,
        ['data-drop-permil'] = prefix .. info.permil,
        ['data-drop-permyriad'] = prefix .. info.permyriad,
    })
    return prefix .. info.title_percent
end

local function parse_rarity(rarity_arg)
    -- string rarities (always, common, rare, etc.)
    local rarity_lower = rarity_arg:lower()
    if rarities[rarity_lower] then
        local class, sort, needs_exact_tf = unpack(rarities[rarity_lower])
        return {
            text = params.ucflc(rarity_arg),
            value = nil,
            class = class,
            sort = sort,
            needs_exact = needs_exact_tf and rarity_lower or nil
        }
    end

    -- Try parsing as fraction (e.g., "1/128" or "1,000/10,000")
    local stripped = rarity_arg:gsub(',', '')
    local rv1, rv2 = stripped:match('([%d%.]+)/([%d%.]+)')
    if rv1 and rv2 then
        local value = rv1 / rv2
        return {
            text = commas(rv1) .. '/' .. commas(rv2),
            value = value,
            class = get_rarity_class(value),
            sort = 1 / value,
            needs_exact = nil,
            oneover = '1/' .. commas(sigfigalt(1 / value)),
            percent = round.sigfig(100 * value, 3),
            permil = round.sigfig(1000 * value, 3),
            permyriad = round.sigfig(10000 * value, 3),
            title_percent = string.format('%.3g%%', 100 * value),
        }
    end

    -- Fallback: try evaluating as math expression
    local ok, val = pcall(mw.ext.ParserFunctions.expr, rarity_arg)
    if ok and tonumber(val) then
        local value = tonumber(val)
        return {
            text = rarity_arg,
            value = value,
            class = get_rarity_class(value),
            sort = 1 / value,
            needs_exact = nil,
            oneover = '1/' .. commas(sigfigalt(1 / value)),
            percent = round.sigfig(100 * value, 3),
            permil = round.sigfig(1000 * value, 3),
            permyriad = round.sigfig(10000 * value, 3),
            title_percent = string.format('%.3g%%', 100 * value),
        }
    end

    -- Complete fallback - use default
    local class, sort, needs_exact_tf = unpack(rarities._default)
    return {
        text = rarity_arg,
        value = false,
        class = class,
        sort = sort,
        needs_exact = needs_exact_tf and '_default' or nil
    }
end

-- Helper: Find alch value from cache, GEMW, or bucket (in priority order)
-- Only call for normal items (not coins, not nothing)
local function get_value_info(bucket_name, gemw, alch, altvalue, altcur)
    local value_info = {}

    -- Normal items: look up values from caches
    local cached_alch = droppeditem_data[bucket_name]
    if type(cached_alch) ~= 'number' then
        cached_alch = highalch_data[bucket_name]
        if type(cached_alch) ~= 'number' or cached_alch < -1 then
            cached_alch = nil
        end
    end

    -- Find alch price (priority: cache → gemw → bucket)
    if alch then
        if cached_alch then
            value_info.alch = { value = cached_alch, type = 'standard' }
        elseif gemw then
            local hasgealch, gealchval = pcall(exchange._highalch, bucket_name)
            if hasgealch and gealchval > -1 then
                value_info.alch = { value = tonumber(gealchval), type = 'standard' }
            end
        end
        if not value_info.alch then
            local bucketData = bucket("infobox_item")
                .select("high_alchemy_value")
                .where("page_name", bucket_name)
                .limit(1)
                .run()
            if #bucketData > 0 and bucketData[1].high_alchemy_value ~= nil then
                value_info.alch = { value = bucketData[1].high_alchemy_value, type = 'standard' }
            end
        end
        alch = value_info.alch ~= nil
    end

    local geprice_frombulk = geprices_data[bucket_name]
    if type(geprice_frombulk) ~= 'number' or geprice_frombulk < 0 then
        geprice_frombulk = nil
    end

    -- Find GE price
    if gemw then
        if geprice_frombulk then
            value_info.ge = { value = geprice_frombulk, type = 'standard' }
        end
        gemw = value_info.ge ~= nil
    end

    -- Alt value overrides
    if altvalue ~= '' then
        local parsed_value = tonumber((altvalue:gsub(',', '')))
        if parsed_value then
            value_info.ge = {
                value = parsed_value,
                type = value_info.alch and 'ge_alch_alt' or 'ge_alt',
                currency = altcur
            }
            if not value_info.alch then
                value_info.alch = {
                    value = parsed_value,
                    type = 'alch_alt',
                    currency = altcur
                }
            end
        end
    end

    return value_info, gemw, alch
end

local IMAGE_STRING = '[[File:%s|link=%s|alt=%s: RS3 %s drops %s with rarity %s%s in quantity %s]]'
local NOTHING_STRING = '[[File:Nothing.png|link=Nothing|alt=This does not exist.]]'

function p.main(frame)
    local args = frame:getParent().args
    local frameArgs = frame.args
    local dropType = params.default_to(frameArgs.dtype, 'combat')

    -- Name
    local hasName = params.has_content(args.name)
    local name = hasName and args.name or 'Item'
    local altname = params.default_to(args.alt, name)
    local bucketName = params.default_to(args.bucketname, name)
    local isCoins = name:lower() == 'coins'
    local isNothing = name:lower() == 'nothing'

    -- Image
    local image
    if not hasName then
        image = ''
    elseif isNothing then
        image = NOTHING_STRING
    else
        local imageArg = params.default_to(args.image, name .. '.png')
        local imageFile = isCoins and coins_image(args.quantity) or imageArg:gsub('#.+$', '.png')
        local rarity_arg = params.default_to(args.rarity, 'Unknown')
        local quantity_arg = mw.ustring.lower(params.default_to(args.quantity, 'Unknown'))
        local rolls_arg = tonumber(args.rolls)
        local rollstext_img = rolls_arg and rolls_arg > 1 and (rolls_arg .. ' × ') or ''
        image = imageFile:lower() == 'no' and ''
            or mw.ustring.format(IMAGE_STRING, imageFile, name, imageFile, title, name, rollstext_img, rarity_arg,
                quantity_arg)
    end

    -- Name notes
    local namenotes = params.default_to(args.namenotes, '')
    local namenote_list, namenotes_new = parse_dropnotes(namenotes)
    local namenotes_display = params.has_content(namenotes) and namenotes_new or ''

    -- Quantity
    local quantity = mw.ustring.lower(params.default_to(args.quantity, 'Unknown'))
    local qty_parsed = isNothing and { special = 'N/A' }
        or quantity == 'varies' and { special = 'Varies' }
        or quantity == 'unknown' and { special = 'Unknown' }
        or qty_parse(quantity)
    local qty_low, qty_high = qty_range(qty_parsed)

    -- Quantity notes
    local quantitynotes = params.default_to(args.quantitynotes, '')
    local quantitynote_list, quantitynotes_new, qty_has_ref = parse_dropnotes(quantitynotes)
    local quantity_html = qty_format_html(qty_parsed)
    if params.has_content(quantitynotes) then
        quantity_html = quantity_html .. quantitynotes_new
    end

    --Rarity
    local rarity = params.default_to(args.rarity, 'Unknown')
    local rolls = tonumber(args.rolls)
    local rollstext = rolls and rolls > 1 and (rolls .. ' × ') or ''
    local approx = yesno(params.default_to(args.approx, ''), false)
    local tilde = approx and '~' or ''

    local rarity_info = parse_rarity(rarity)
    local needs_exact_rarity = rarity_info.needs_exact
    if rolls and rarity_info.value ~= false then
        rarity_info.sort = rarity_info.sort / rolls
        rarity_info.class = get_rarity_class(math.min(1 / rarity_info.sort, 0.99))
    end

    -- Alt rarities (altrarity, altrarity2, altrarity3, ...)
    local alt_rarity_endash = params.default_to(args.altraritydash, '')
    local alt_rarities = {}
    local i = 1
    while true do
        local suffix = i ~= 1 and i or ''
        local suffixed_alt_rarity = args['altrarity' .. suffix]
        if params.is_empty(suffixed_alt_rarity) then break end
        local alt_info = parse_rarity(suffixed_alt_rarity)
        alt_info.dash = params.has_content(args['altrarity' .. suffix .. 'dash'])
        table.insert(alt_rarities, alt_info)
        i = i + 1
    end
    local alt_rarity = alt_rarities[1] and alt_rarities[1].text or '' -- bucket compat

    -- Rarity notes
    local raritynotes = params.default_to(args.raritynotes, '')
    local citations = params.default_to(args.citations, '')
    local raritynote_list, raritynotes_new, rarity_has_ref = parse_dropnotes(raritynotes)
    raritynotes_new = raritynotes_new .. citations

    -- Values (ge, alch, th/sof)
    local altvalue = params.default_to(args.altvalue, '')
    local altcur = params.default_to(args.altcurrency, '')
    local gemw_arg = yesno(args.gemw or 'yes', false)
    local alch_arg = yesno(args.alch or 'yes', false)

    local value_info, gemw, alch
    if isNothing then
        value_info, gemw, alch = {}, false, alch_arg
    elseif isCoins then
        value_info = { alch = { value = 1, type = 'coins' }, ge = { value = 1, type = 'coins' } }
        gemw, alch = gemw_arg, alch_arg
    else
        value_info, gemw, alch = get_value_info(bucketName, gemw_arg, alch_arg, altvalue, altcur)
    end

    -- Structure - row version and table version
    local rowVersion = params.default_to(args.version, '')
    local hasRowwideVersion = params.has_content(rowVersion)
    local versionKey = hasRowwideVersion and rowVersion
        or params.has_content(frameArgs.version) and frameArgs.version
        or 'DEFAULT'

    -- Auto-generate version reference
    local hideautoversionnote = yesno(args.hideautoversionnote, false)
    if hasRowwideVersion and not hideautoversionnote then
        local cleanref = mw.ustring.gsub(
            mw.ustring.gsub(mw.ustring.lower(versionKey), "%s", "-"),
            "[^%w%-]", ""
        )
        local refname = "autod-" .. cleanref
        local ref_content = mw.ustring.format('Only dropped by version "%s".', versionKey)
        raritynotes_new = raritynotes_new .. mw.getCurrentFrame():extensionTag {
            name = 'ref',
            content = ref_content,
            args = { group = 'd', name = refname }
        }
    end

    local level = tonumber(args.level) or 0
    local rdt = yesno(args.rdt, false) or false
    local memsover = params.default_to(args.members, '')
    local members = yesno(memsover, false)
    local use_bucket_str = params.default_to(args.bucket, var.var('_bucket'))
    local use_bucket = params.is_empty(use_bucket_str) or yesno(use_bucket_str, true)
    local leagueRegionOverride = params.default_to(args.leagueRegion, '')

    -- Th/SoF specfic stuff
    local thgem = mw.ustring.lower(params.default_to(args.thgem, ''))
    local sofslot = mw.ustring.lower(params.default_to(args.sofslot, ''))
    local convert = tonumber(params.default_to(args.convert, ''))
    local defaultConvertCurrency = dropType == 'sof' and 'Coins' or 'Oddments'
    local convertcurrencyKey = params.default_to(args.convertcurrency, '')
    if not params.has_content(convertcurrencyKey) then
        convertcurrencyKey = params.default_to(frameArgs.convertcurrency, defaultConvertCurrency)
    end

    -- rows
    local ret = mw.html.create('tr')
        :css('text-align', 'center')
    -- inventory image
    ret:td({
        class = 'inventory-image',
        attr = { ['data-sort-value'] = name },
        wikitext = image
    })
    -- item name
    ret:td({
        class = 'item-col',
        css = { ['text-align'] = 'left' },
        wikitext = string.format('[[%s|%s]]%s%s', name, altname, namenotes_display, members and members_note or '')
    })
    if level > 0 then
        ret:td({
            attr = { ['data-sort-value'] = level },
            wikitext = level
        })
    end
    -- quantity
    ret:td({
        attr = { ['data-sort-value'] = qty_high },
        wikitext = quantity_html
    })
        :addClassIf(isNothing, 'table-na')
        :cssIf(isNothing, 'text-align', 'center')

    -- rarity
    local prefix = rollstext .. tilde
    local rarity_span_text = prefix .. rarity_info.text
    local rarity_cell = ret:td({ class = rarity_info.class, attr = { ['data-sort-value'] = rarity_info.sort } })
    local rarity_span = rarity_cell:tag('span'):wikitext(rarity_span_text)
    local rarity_cell_title = add_rarity_attrs(rarity_span, rarity_info, prefix)

    for _, alt in ipairs(alt_rarities) do
        local sep = alt.dash and '–' or '; '
        rarity_cell:tag('span'):wikitext(sep)
        local alt_span = rarity_cell:tag('span'):wikitext(alt.text)
        local alt_title = add_rarity_attrs(alt_span, alt)
        if alt_title then
            rarity_cell_title = (rarity_cell_title or rarity_span_text) .. sep .. alt_title
        elseif alt.needs_exact then
            needs_exact_rarity = needs_exact_rarity
                and (needs_exact_rarity .. ', ' .. alt.needs_exact)
                or alt.needs_exact
        end
    end

    rarity_cell
        :attrIf(rarity_cell_title, 'title', rarity_cell_title)
        :wikitextIf(#raritynotes_new > 3, raritynotes_new)

    if dropType == 'th' then
        -- Treasure Hunter gem
        ret:tag('td')
            :addClassIf(thgem == 'no', 'table-na')
            :cssIf(thgem == 'no', 'text-align', 'center')
            :wikitext(th_gem_icons[thgem] or '')
            :attr('data-sort-value', th_gem_rarities[thgem] or 2)
    elseif dropType == 'sof' then
        -- Squeal of Fortune slot
        ret:tag('td')
            :addClassIf(sofslot == 'no', 'table-na')
            :cssIf(sofslot == 'no', 'text-align', 'center')
            :wikitext(sof_slot_icons[sofslot] or '')
            :attr('data-sort-value', sof_slot_rarities[sofslot] or 2)
    end

    -- Determine GE and alch cell data
    local ge_data, alch_data = get_price_cell_data({
        is_nothing = isNothing,
        is_coins = isCoins,
        value_info = value_info,
        qty_high = qty_high,
        qty_low = qty_low
    })

    -- Render GE and alch cells
    local value_cell_css = { ['text-align'] = 'right', cursor = 'help' }
    ret:td({
        class = 'ge-column',
        attr = { ['data-sort-value'] = ge_data.sort, title = ge_data.title },
        css = value_cell_css,
        wikitext = ge_data.content
    })
        :addClassIf(ge_data.is_na, 'table-na')
        :cssIf(ge_data.is_na, 'text-decoration', 'underline dotted')
        :cssIf(ge_data.is_na, 'text-align', 'center')
    ret:td({
        class = 'alch-column',
        attr = { ['data-sort-value'] = alch_data.sort, title = alch_data.title },
        css = value_cell_css,
        wikitext = alch_data.content
    })
        :addClassIf(alch_data.is_na, 'table-na')
        :cssIf(alch_data.is_na, 'text-decoration', 'underline dotted')
        :cssIf(ge_data.is_na, 'text-align', 'center')

    local convertstr = 'each'
    local converttotal, vcsort
    -- If there is no quantity range, assume the convert value is the total
    if convert and qty_high == qty_low then
        converttotal, vcsort = get_total(convert, 1, 1)
        convertstr = 'total'
    elseif convert then
        converttotal, vcsort = get_total(convert, qty_high, qty_low)
    end
    -- SoF/TH convert value
    if dropType == 'sof' or dropType == 'th' then
        -- Determine convert cell data
        local convert_data = { content = nil, title = nil, is_disabled = false }
        if params.has_content(convert) then
            if convert ~= 'no' then
                local currency_img = get_currency_image(convertcurrencyKey, vcsort)
                local currency_name = get_currency_name(convertcurrencyKey, convert)
                convert_data.title = mw.ustring.format('%s %s %s', commas(convert), currency_name, convertstr)
                convert_data.content = converttotal .. currency_img
            else
                convert_data.content = 'Cannot be converted'
                convert_data.title = 'This item cannot be converted and has no applicable value to display.'
                convert_data.is_disabled = true
            end
        end

        -- Render convert cell
        ret:td({
            class = 'convert-column',
            attr = { ['data-sort-value'] = convert or -1 },
            css = { ['text-align'] = 'right', cursor = 'help' }
        })
            :wikitextIf(convert_data.content, convert_data.content)
            :attrIf(convert_data.title, 'title', convert_data.title)
            :cssIf(convert_data.is_disabled, 'color', '#999')
    end

    -- Bucket
    local drop_version_found = true
    local leaguesCategory = ''
    if on_main() and use_bucket and not isNothing then
        local bucketNameNote = mw.text.killMarkers(namenotes)
        local bucketQuantity = qty_bucket(qty_parsed)
        local bucketRolls = rolls or 1

        -- if versionKey isn't DEFAULT, bucketSubName is versionKey, else empty
        local bucketSubName = versionKey ~= 'DEFAULT' and versionKey or ''
        -- if bucketSubName isn't empty, dropFrom is pgTitle#bucketSubName, else pgTitle
        local dropFrom = pgTitle .. (bucketSubName ~= '' and '#' or '') .. bucketSubName

        local droppedItemName = rdt and 'Dropped item from RDT' or 'Dropped item'

        local bucket_alt_rarities = {}
        for _, alt in ipairs(alt_rarities) do
            table.insert(bucket_alt_rarities, { text = alt.text, value = alt.value, dash = alt.dash })
        end

        local bucket_json = {
            [droppedItemName] = bucketName,
            ['Name Notes'] = bucketNameNote,
            ['Name NotesP'] = namenote_list,
            ['Drop Quantity'] = bucketQuantity,
            ['Quantity High'] = qty_high,
            ['Quantity Low'] = qty_low,
            ['Quantity Notes'] = quantitynote_list,
            ['Rarity'] = rarity_info.text,
            ['Alt Rarity'] = alt_rarity,
            ['Alt Rarity Dash'] = alt_rarity_endash,
            ['Alt Rarities'] = bucket_alt_rarities,
            ['Rarity Notes'] = raritynote_list,
            ['Rolls'] = bucketRolls,
            ['Drop Value'] = value_info.alch and value_info.alch.value or 0,
            ['Drop GEMW'] = gemw,
            ['Drop Alch'] = alch,
            ['Dropped from'] = dropFrom,
            ['Drop type'] = dropType,
            ['Approx'] = approx
        }

        if dropType == 'store' then
            local dropLevelVar = string.format("DropLevel_%s_%s", dropType, versionKey)

            if not var.varexists(dropLevelVar) then
                drop_version_found = false
            else
                bucket_json['Drop level'] = var.var(dropLevelVar)
                bucket_json['Drop currency'] = var.var(string.format("DropStoreCurrency_%s_%s", dropType, versionKey))
            end
        elseif level > 0 then
            bucket_json['Drop level'] = tostring(level)
        elseif dropType == 'reward' or dropType == 'search' or dropType == 'th' or dropType == 'sof' then
            bucket_json['Drop level'] = 'N/A'
        else
            local seenLevels = {}
            for dropVersion in string.gmatch(versionKey, ' *([^,]+) *') do
                local dropLevelVar = string.format("DropLevel_%s_%s", dropType, dropVersion)

                if not var.varexists(dropLevelVar) then
                    if versionKey ~= 'DEFAULT' then
                        -- Fallback to 'DEFAULT' version
                        dropLevelVar = string.format("DropLevel_%s_%s", dropType, 'DEFAULT')
                    end

                    if not var.varexists(dropLevelVar) then
                        drop_version_found = false
                    end
                end

                local curDropLevelValues = var.var(dropLevelVar)
                for curDropLevel in string.gmatch(curDropLevelValues, ' *([^,]+) *') do
                    seenLevels[curDropLevel] = true
                end
            end
            local orderedLevels = {}
            for lvl, _ in pairs(seenLevels) do
                local n = tonumber(lvl)
                if n ~= nil then
                    table.insert(orderedLevels, n)
                end
            end
            table.sort(orderedLevels)
            bucket_json['Drop level'] = table.concat(orderedLevels, ',')
        end

        if rarity_has_ref then
            bucket_json['RarityNote Ref'] = true
        end
        if qty_has_ref then
            bucket_json['QuantityNote Ref'] = true
        end
        if dropType == 'archaeology' then
            if var.var('dropsline_is_arch_soil') == 'true' then
                bucket_json['Is soil screening'] = 'true'
            else
                bucket_json['Is soil screening'] = 'false'
            end
        end

        -- 1: Try taking regions from LeagueRegion variables
        local seenRegions = {}
        for dropVersion in string.gmatch(versionKey, ' *([^,]+) *') do
            local leagueRegionVar = string.format("LeagueRegion_%s", dropVersion)
            if not var.varexists(leagueRegionVar) and versionKey ~= 'DEFAULT' then
                mw.log('Expected dropversion region variable: ' .. leagueRegionVar .. ' for drop ' .. bucketName)
                leaguesCategory = leaguesCategory .. '[[Category:Uses unrecognized drop region version]]'
            end
            local curRegionValues = var.var(leagueRegionVar)
            for curRegion in string.gmatch(curRegionValues, ' *([^,]+) *') do
                seenRegions[curRegion] = true
            end
        end
        local orderedRegions = {}
        for region, _ in pairs(seenRegions) do
            table.insert(orderedRegions, region)
        end
        table.sort(orderedRegions)
        local leagueRegions = table.concat(orderedRegions, ',')
        -- 2: Try taking regions from DropsTableHead
        local regionFromDropsTableHead = var.var('_leagueRegion')
        if regionFromDropsTableHead ~= '' then
            leagueRegions = regionFromDropsTableHead
            leaguesCategory = leaguesCategory .. '[[Category:Pages with League region]]'
        end
        -- 3: Try taking regions set directly on DropsLine
        if leagueRegionOverride and leagueRegionOverride ~= '' then
            leagueRegions = leagueRegionOverride
            leaguesCategory = leaguesCategory .. '[[Category:Pages with League region]]'
        end
        if leagueRegions == '' then
            leaguesCategory = leaguesCategory .. '[[Category:DropsLine missing League region]]'
        end

        bucket_json['League region'] = leagueRegions

        local bucket_sub = {
            item_name = bucketName,
            rare_drop_table = rdt,
            drop_json = mw.text.jsonEncode(bucket_json)
        }

        if needs_exact_rarity then
            bucket_sub.needs_exact_rarity = needs_exact_rarity
        end

        bucket("dropsline").sub(bucketSubName).put(bucket_sub)
    end

    ---------------------------------------------------------------------------
    -- RETURN
    ---------------------------------------------------------------------------
    local cats = on_main() and categories(name, qty_parsed, rarity, drop_version_found, leaguesCategory) or ''
    return tostring(ret) .. cats
end

return p