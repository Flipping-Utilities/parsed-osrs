require("strict");
local p = {}

local yesno = require('Module:Yesno')
local purge = require('Module:Purge')._purge
local params = require('Module:Paramtest')
local lang = mw.language.getContentLanguage()
local commas = function(n) return lang:formatNum(tonumber(n)) end
local var = mw.ext.VariablesLua

local images = {
    combat = '<span style="margin-left:0.3em;">[[File:Multicombat.png|link=Combat level|frameless|20px]]</span>',
    -- skills
    agility = '<span style="margin-left:0.3em;">[[File:Agility-icon.png|link=Agility|frameless|20px]]</span>',
    archaeology = '<span style="margin-left:0.3em;">[[File:Archaeology-icon.png|link=Archaeology|frameless|20px]]</span>',
    attack = '<span style="margin-left:0.3em;">[[File:Attack-icon.png|link=Attack|frameless|20px]]</span>',
    constitution = '<span style="margin-left:0.3em;">[[File:Constitution-icon.png|link=Constitution|frameless|20px]]</span>',
    construction = '<span style="margin-left:0.3em;">[[File:Construction-icon.png|link=Construction|frameless|20px]]</span>',
    cooking = '<span style="margin-left:0.3em;">[[File:Cooking-icon.png|link=Cooking|frameless|20px]]</span>',
    crafting = '<span style="margin-left:0.3em;">[[File:Crafting-icon.png|link=Crafting|frameless|20px]]</span>',
    defence = '<span style="margin-left:0.3em;">[[File:Defence-icon.png|link=Defence|frameless|20px]]</span>',
    divination = '<span style="margin-left:0.3em;">[[File:Divination-icon.png|link=Divination|frameless|20px]]</span>',
    dungeoneering = '<span style="margin-left:0.3em;">[[File:Dungeoneering-icon.png|link=Dungeoneering|frameless|20px]]</span>',
    farming = '<span style="margin-left:0.3em;">[[File:Farming-icon.png|link=Farming|frameless|20px]]</span>',
    firemaking = '<span style="margin-left:0.3em;">[[File:Firemaking-icon.png|link=Firemaking|frameless|20px]]</span>',
    fishing = '<span style="margin-left:0.3em;">[[File:Fishing-icon.png|link=Fishing|frameless|20px]]</span>',
    fletching = '<span style="margin-left:0.3em;">[[File:Fletching-icon.png|link=Fletching|frameless|20px]]</span>',
    herblore = '<span style="margin-left:0.3em;">[[File:Herblore-icon.png|link=Herblore|frameless|20px]]</span>',
    hunter = '<span style="margin-left:0.3em;">[[File:Hunter-icon.png|link=Hunter|frameless|20px]]</span>',
    invention = '<span style="margin-left:0.3em;">[[File:Invention-icon.png|link=Invention|frameless|20px]]</span>',
    magic = '<span style="margin-left:0.3em;">[[File:Magic-icon.png|link=Magic|frameless|20px]]</span>',
    mining = '<span style="margin-left:0.3em;">[[File:Mining-icon.png|link=Mining|frameless|20px]]</span>',
    necromancy = '<span style="margin-left:0.3em;">[[File:Necromancy-icon.png|link=Necromancy|frameless|20px]]</span>',
    prayer = '<span style="margin-left:0.3em;">[[File:Prayer-icon.png|link=Prayer|frameless|20px]]</span>',
    ranged = '<span style="margin-left:0.3em;">[[File:Ranged-icon.png|link=Ranged|frameless|20px]]</span>',
    runecrafting = '<span style="margin-left:0.3em;">[[File:Runecrafting-icon.png|link=Runecrafting|frameless|20px]]</span>',
    slayer = '<span style="margin-left:0.3em;">[[File:Slayer-icon.png|link=Slayer|frameless|20px]]</span>',
    smithing = '<span style="margin-left:0.3em;">[[File:Smithing-icon.png|link=Smithing|frameless|20px]]</span>',
    strength = '<span style="margin-left:0.3em;">[[File:Strength-icon.png|link=Strength|frameless|20px]]</span>',
    summoning = '<span style="margin-left:0.3em;">[[File:Summoning-icon.png|link=Summoning|frameless|20px]]</span>',
    thieving = '<span style="margin-left:0.3em;">[[File:Thieving-icon.png|link=Thieving|frameless|20px]]</span>',
    woodcutting = '<span style="margin-left:0.3em;">[[File:Woodcutting-icon.png|link=Woodcutting|frameless|20px]]</span>',
    -- misc
    store = '<span style="margin-left:0.3em;">[[File:General store storefront icon.png|link=|frameless|20px|Shop]]</span>',
    reward = '<span style="margin-left:0.3em;">[[File:Casket.png|link=|frameless|20px|Reward]]</span>',
    search = '<span style="margin-left:0.3em;">[[File:Pickup cursor.png|link=|frameless|20px]]</span>',
    sof = '<span style="margin-left:0.3em;">[[File:Spin ticket.png|link=|frameless|20px|Squeal of Fortune]]</span>',
    th = '<span style="margin-left:0.3em;">[[File:Treasure Hunter icon.png|link=|frameless|20px|Treasure Hunter]]</span>',
    misc = '',
}

local rewardTemplate = '<span style="margin-left:0.3em;">[[File:%s|link=|frameless|20px|%s]]</span>'
local rewardImages = mw.loadData('Module:get drop info/rewards')

local REF_GROUP = 'f'

local _noted = '&nbsp;<span class="dropsline-noted">(noted)</span>'

--class, sort
local rarities = {
    always = { 'table-bg-blue', 1 },
    common = { 'table-bg-green', 16 },
    uncommon = { 'table-bg-yellow', 64 },
    rare = { 'table-bg-orange', 256 },
    ['very rare'] = { 'table-bg-red', 1024 },
    conditional = { 'table-bg-pink', 2048 },
    random = { 'table-bg-pink', 4096 },
    varies = { 'table-bg-pink', 4096 },
    once = { 'table-bg-pink', 65536 },
    _default = { 'table-bg-grey', 65536 },
}
-- arbitrary numbers
local rarities2 = {
    { 1, 'table-bg-blue' },
    { 1 / 16, 'table-bg-green' },
    { 1 / 64, 'table-bg-yellow' },
    { 1 / 256, 'table-bg-orange' },
    { 1 / 1024, 'table-bg-red' },
}

local function cmb(level)
    -- if no level is given, return unknown
    if not level then
        return 'Unknown', 0
    end

    -- split list into table
    -- recreate the list string to ensure consistent formatting
    local levelValues = {}
    for _, v in ipairs(level) do
        v = mw.text.trim(v)
        local vnum = tonumber(v)
        if vnum ~= nil then
            table.insert(levelValues, vnum)
        else
            table.insert(levelValues, v)
        end
    end

    table.sort(levelValues)

    for i, v in ipairs(levelValues) do
        if type(v) == 'number' then
            levelValues[i] = commas(v)
        end
    end

    -- To prevent any possible confusion with formatted numbers
    -- elements should be separated with semicolons followed by a space
    return table.concat(levelValues, '; '), levelValues[1] or 0
end

local currency_image

-- function to get the currency image
local function currencyInfo(currency, price)
    if currency_image == nil then
        currency_image = require('Module:Currency Image')
    end
    local img = currency_image(currency, price)
    if img then
        return '<span class="dropsline-altval" style="margin-left:0.3em">[[File:' .. img .. '|link=|frameless|20px]]</span>'
    else
        return '<span class="dropsline-altval" style="margin-left:0.3em">' .. currency .. '</span>'
    end
end

local function makeLine(idx, item_name, data, source_currently_unavailable, source_removed)
    local dropTypes = data['Drop type'] or { 'combat' }
    -- String value fallback
    if type(dropTypes) == "string" then
        dropTypes = { dropTypes }
    end
    local dropType1 = dropTypes[1]
    local dropLevels = data['Drop level']
    -- String value fallback
    if type(dropLevels) == "string" then
        dropLevels = { { dropLevels } }
    end

    local levelDisp, levelClass, levelSort
    if dropType1 == 'store' then
        local currency = data['Drop currency']
        if currency == nil then
            levelDisp = 'N/A ' .. images.store
            levelClass = 'table-na'
            levelSort = 0
        else
            local currencies = mw.text.split(currency, '%s*;%s*')
            local levels = mw.text.split(dropLevels[1], '%s*;%s*')

            local disp = {}
            for i, lvl in ipairs(levels) do
                local currencyImg = currencyInfo(currencies[i], lvl)
                table.insert(disp, commas(lvl) .. currencyImg)
            end
            levelDisp = table.concat(disp, '; ')
            levelSort = levels[1]
        end
    elseif dropType1 == 'reward' or dropType1 == 'search' or
        dropType1 == 'sof' or dropType1 == 'th' or dropType1 == 'misc' then
        local img = images[dropType1]

        if rewardImages[data['Dropped from']] then
            img = string.format(rewardTemplate, rewardImages[data['Dropped from']][2], data['Dropped from'])
        end

        levelDisp = 'N/A ' .. img
        levelClass = 'table-na'
        levelSort = 0
    else
        local dropDisp = {}
        for i, dropType in ipairs(dropTypes) do
            local img = images[dropType]
            if img == nil then
                return nil
            end

            local disp, sort = cmb(dropLevels[i])

            table.insert(dropDisp, disp .. ' ' .. img)
            if levelSort == nil then
                levelSort = sort
            end
        end
        levelDisp = table.concat(dropDisp, '; ')
    end

    local noteref = data['QuantityNote Ref'] or data['RarityNote Ref'] or false

    local cleanSrc = data['Dropped from'] or ''
    local splitSrc = mw.text.split(cleanSrc, '%#')
    if #splitSrc == 2 then
        splitSrc[2] = splitSrc[2]:gsub('_', ' ')
        cleanSrc = string.format('%s|%s <span class="beast-version">%s</span>', data['Dropped from'], splitSrc[1], splitSrc[2])
    end

    -- Pull League Region details and render
    local leagueRegion = data['League region'] or ''
    local leagueRegionBadges = ''
    if leagueRegion and leagueRegion ~= '' then
        local leagues = require('Module:LeagueRegion')
        leagueRegionBadges = leagues._compact(leagueRegion)
    end

    return p.line(
        item_name,
        cleanSrc,
        data['Name Notes'],
        { value = levelDisp, class = levelClass, sort = levelSort },
        dropTypes,
        data['Drop Quantity'],
        data['Quantity Notes'],
        data['Rarity'],
        data['Alt Rarity'],
        data['Alt Rarity Dash'],
        data['Rarity Notes'],
        data['Rolls'],
        noteref,
        data['Approx'],
        leagueRegionBadges,
        source_currently_unavailable,
        source_removed,
        idx,
        data["Alt Rarities"]
    );
end

local function makeTable(item_name, args)
    local limit = tonumber(args.limit) or 500
    mw.logObject(item_name, "item to look for")
    local query = bucket("dropsline")
        .select("page_name", "page_name_sub", "drop_json", "Category:Events")
        .where("item_name", item_name)
        .limit(limit)
    if args.incrdt ~= 'y' then
        query.where("rare_drop_table", false)
    end

    local sources_restricted = {
        "Category:New Varrock",
        "Category:Items exclusive to Leagues",
        "Category:Items exclusive to Catalyst League",
        "Category:Items exclusive to Equilibrium League",
    }
    for _, r in ipairs(sources_restricted) do
        query.select(r)
    end

    query.select("Category:Discontinued content that is currently available")

    local sources_currently_unavailable = {
        "Category:Recurring content",
        "Category:Items that may not be currently obtainable",
        "Category:Discontinued content",
        "Category:Discontinued content that is currently available",
        "Category:Treasure Hunter rewards",
    }
    for _, r in ipairs(sources_currently_unavailable) do
        query.select(r)
    end

    local sources_removed = {
        "Category:Treasure Hunter promotions",
        "Category:Removed content",
        "Category:Historical article",
    }
    for _, r in ipairs(sources_removed) do
        query.select(r)
    end

    local bucketdata = query.run()

    if #bucketdata == 0 then
        return {}
    end

    local ret_main = {}
    local ret_irregular_sources = {}
    local ret_restricted = {}

    local hasRefs = false
    local dropped_by_monster = false
    local has_source_restricted = false
    local has_source_removed = false
    local has_source_currently_unavailable = false

    local events = {}
    for i, v in ipairs(bucketdata) do
        local dropJSON = mw.text.jsonDecode(v['drop_json'] or '{}')
        if dropJSON and (
                dropJSON['QuantityNote Ref'] or
                dropJSON['RarityNote Ref'] or
                (dropJSON['Quantity Notes'] and type(dropJSON['Quantity Notes']) == 'table') or
                (dropJSON['Rarity Notes'] and type(dropJSON['Rarity Notes']) == 'table')
            ) then
            hasRefs = true
        end

        local source_restricted = false
        local source_removed = false
        local source_currently_unavailable = false

        local drop_type = (dropJSON['Drop type'] or {})[1]
        if drop_type == 'combat' then
            dropped_by_monster = true
        end

        if v['Category:Events'] then
            local event_subs = events[v.page_name]
            if event_subs == nil then
                event_subs = bucket("infobox_event")
                    .select("page_name", "page_name_sub", "end_date")
                    .where("page_name", v.page_name)
                    .limit(limit)
                    .run()
                events[v.page_name] = event_subs
            end

            -- There are some pages without infobox_event
            local current_event = {}
            for _, evt in ipairs(event_subs) do
                current_event = evt
                if evt.page_name_sub == v.page_name_sub then
                    break
                end
            end

            if current_event.end_date == nil or os.difftime(current_event.end_date, os.time()) <= 0 then
                source_removed = true
                has_source_removed = true
            end
        end

        -- Determine if it is flagged
        if drop_type == 'th' then
            source_removed = true
            has_source_removed = true
        elseif drop_type == 'sof' then
            source_removed = true
            has_source_removed = true
        else
            for _, r in ipairs(sources_restricted) do
                if v[r] then
                    source_restricted = true
                    has_source_restricted = true
                    break
                end
            end

            if not v["Category:Discontinued content that is currently available"] then
                for _, r in ipairs(sources_currently_unavailable) do
                    if v[r] then
                        source_currently_unavailable = true
                        has_source_currently_unavailable = true
                        break
                    end
                end
            end

            for _, r in ipairs(sources_removed) do
                if v[r] then
                    source_removed = true
                    has_source_removed = true
                    break
                end
            end
        end

        if source_removed or source_currently_unavailable then
            table.insert(ret_irregular_sources, makeLine(i, item_name, dropJSON, source_currently_unavailable, source_removed))
        elseif source_restricted then
            table.insert(ret_restricted, makeLine(i, item_name, dropJSON, source_currently_unavailable, source_removed))
        else
            table.insert(ret_main, makeLine(i, item_name, dropJSON, source_currently_unavailable, source_removed))
        end
    end

    local uri = tostring(mw.uri.fullUrl('RuneScape:Autolists/full')) .. '#' .. mw.uri.buildQueryString { type = 'drops', page = item_name }
    local text = {
        "<div class=\"seealso droplistintro\">For an exhaustive list of all known sources for this item, see <span class='plainlinks'>[", uri, " here]</span>.</div>\n",
        (#bucketdata > tonumber(limit)) and string.format("<div class=\"seealso\">Showing %d out of %d sources.</div>\n", limit, #bucketdata) or "",
    }

    local has_main = #ret_main > 0
    if has_main then
        local t = mw.html.create('table')
        t:addClass('wikitable sortable sticky-header item-drops filterable autosort=4,a')
            :css('text-align', 'center')
            :tag('tr')
            :tag('th'):addClass('drop-disp-btn btn-first'):wikitext('Source'):done()
            :tag('th'):wikitext('Level'):done()
            :tag('th'):wikitext('Quantity'):done()
            :tag('th'):wikitext('Rarity'):done()
            :tag('th'):wikitext('League region'):addClass('leagues-global-flag'):done()
        for _, v in ipairs(ret_main) do
            t:node(v)
        end
        table.insert(text, tostring(t))
    end

    if has_source_restricted then
        local t = mw.html.create('table')
        t:tag('caption'):wikitext('Sources in restricted locations')
        t:addClass('wikitable sortable sticky-header item-drops filterable autosort=4,a')
            :css('text-align', 'center')
            :tag('tr')
            :tag('th'):addClass('drop-disp-btn btn-first'):wikitext('Source'):done()
            :tag('th'):wikitext('Level'):done()
            :tag('th'):wikitext('Quantity'):done()
            :tag('th'):wikitext('Rarity'):done()
            :tag('th'):wikitext('League region'):addClass('leagues-global-flag'):done()
        for _, v in ipairs(ret_restricted) do
            t:node(v)
        end
        table.insert(text, tostring(t))
    end

    if not has_main and not has_source_restricted then
        table.insert(text, "&#128368;️ '''This item is not currently available from regular drop sources.''' Historical and non-permanent drop sources shown below.\n")
    end

    if has_source_removed or has_source_currently_unavailable then
        local t = mw.html.create('table')

        t:addClass('wikitable sortable sticky-header item-drops filterable autosort=4,a')
            :css('text-align', 'center')

        if #ret_main > 0 then
            t:addClass('mw-collapsible mw-collapsed')
            t:tag('caption'):wikitext('Show historical/non-permanent sources →'):css('text-wrap', 'nowrap')
        end

        t:tag('tr')
            :tag('th'):addClass('drop-disp-btn btn-first'):wikitext('Source'):done()
            :tag('th'):wikitext('Level'):done()
            :tag('th'):wikitext('Quantity'):done()
            :tag('th'):wikitext('Rarity'):done()
            :tag('th'):wikitext('League region'):addClass('leagues-global-flag'):done()
        for _, v in ipairs(ret_irregular_sources) do
            t:node(v)
        end

        if has_source_currently_unavailable or has_source_removed then
            local caption = {}
            if has_source_currently_unavailable then
                table.insert(caption, '<small>&#x231B; Denotes a source that may not be currently available in-game.</small>')
            end
            if has_source_removed then
                table.insert(caption, '<small>† Denotes removed content that dropped the item.</small>')
            end

            if #caption > 0 then
                t:tag('tr'):addClass('sortbottom')
                    :tag('td')
                    :attr('colspan', '4')
                    :wikitext(table.concat(caption, '<br>'))
            end
        end

        table.insert(text, tostring(t))
    end

    if hasRefs then
        local refList = mw.getCurrentFrame():getParent():extensionTag('references', '', { group = REF_GROUP })
        if yesno(args.hidenotes, false) then
            refList = '<div class="mw-collapsible mw-collapsed"><span style="font-weight:bold; display:inline-block;">Notes (expand →)<span class="mw-collapsible-toggle-placeholder"></span></span><div class="mw-collapsible-content">' .. refList .. '</div></div>'
        end
        table.insert(text, refList)
    end

    if dropped_by_monster then
        table.insert(text, '[[Category:Items dropped by monster]]')
    end

    return table.concat(text, '')
end

-- supporting function for number => colour
local function get_rarity_class(val)
    local curr
    for _, v in ipairs(rarities2) do
        curr = v
        if val >= v[1] then
            break
        end
    end
    return curr[2]
end

local function expr(t)
    local err, val = pcall(mw.ext.ParserFunctions.expr, t)
    if err then
        return tonumber(val)
    else
        return false
    end
end

local function sigfig(n, f)
    if n == 0 then
        return 0
    end
    f = math.floor(f - 1)
    local m = math.floor(math.log10(n))
    local v = n / (10 ^ (m - f))
    -- floor(x + 0.5) is standard rounding to one decimal place
    v = math.floor(v + 0.5) * 10 ^ (m - f)
    return v
end

local function sigfigalt(n)
    if n >= 100 then
        return math.floor(n + 0.5)
    else
        return sigfig(n, 3)
    end
end

local function ref(content, name)
    if content == nil then
        return ""
    end

    return mw.getCurrentFrame():getParent():extensionTag('ref', content, { name = name, group = REF_GROUP })
end


local function qty(quantity)
    -- if no quantity is given, return unknown
    if not quantity or quantity == 'unknown' then
        return 'Unknown'
    end
    -- en dashes are the proper dash for number ranges
    -- replace all hyphens and em dashes with en
    -- strip *all* whitespace
    -- change '(noted)' to '$n' for parsing
    quantity = mw.ustring.gsub(quantity, '[-—]', '–')
        :gsub('%s', '')
        :gsub('%(noted%)', '$n')
    -- split list into table
    local vals = mw.text.split(quantity, '[,;]')

    -- recreate the quantity string to ensure consistent formatting
    local nums = {}
    for _, v in ipairs(vals) do
        local clean = v:gsub('$n', '')
        -- if list element contains an en dash (indicating range)
        -- Find the smaller/larger number (just in case)
        -- Compare them to the current min/max
        -- put them in order with desired format
        if mw.ustring.find(v, '–') then
            local splitvals = mw.text.split(clean, '–')
            -- assume a is smaller, b is larger
            local a = tonumber(splitvals[1])
            local b = tonumber(splitvals[2])
            local addx
            -- Just in case
            if a and b then
                if a > b then
                    a, b = b, a
                end
                addx = commas(a) .. '–' .. commas(b)
            else
                addx = splitvals[1] .. '–' .. splitvals[2]
            end
            if v:find('$n') then
                addx = addx .. _noted
            end
            table.insert(nums, addx)
        else
            local addx = tonumber(clean) ~= nil and commas(tonumber(clean)) or clean
            if v:find('$n') then
                addx = addx .. _noted
            end
            table.insert(nums, addx)
        end
    end
    -- To prevent any possible confusion with formatted numbers
    -- elements should be separated with semicolons followed by a space
    local numstr = table.concat(nums, '; ')
    if numstr:find('%d') then
        return numstr
    else
        return 'Unknown'
    end
end

local function add_dropnotes(notes, element, item, ref_prefix)
    for n, note in ipairs(notes) do
        local varname = 'dropsrc_var_' .. item .. note.content
        if var.varexists(varname) then
            element:wikitext(ref('', var.var(varname)))
        else
            local refname = ref_prefix .. '_' .. n
            var.vardefine(varname, refname)
            element:wikitext(ref(note.content, refname))
        end
    end
end

function p.line(
    item, name, namenotes,
    level, dropTypes,
    quantity, quantitynotes,
    rarity, altrarity, altraritydash, raritynotes, rolls,
    noteref, approx, leagueRegionBadges, source_currently_unavailable, source_removed, i, alt_rarities)
    -- missing notes to empty string (and not nil)
    namenotes = namenotes or ''
    quantitynotes = quantitynotes or ''
    raritynotes = raritynotes or ''
    approx = yesno(approx or 'no', false)

    local rarity_value
    if rarities[string.lower(tostring(rarity))] then
        rarity = params.ucflc(rarity)
    else
        rarity_value = rarity:gsub(',', '') --temp place to put this without overriding rarity
        local rv1, rv2 = string.match(rarity_value, '([%d%.]+)/([%d%.]+)')
        if rv1 and rv2 then
            rarity = commas(rv1) .. '/' .. commas(rv2)
            rarity_value = rv1 / rv2
        else
            rarity_value = expr(rarity)
        end
    end

    local rare_class, rare_sort = nil, nil
    if rarity_value == nil then
        rare_class, rare_sort = unpack(rarities[string.lower(tostring(rarity))] or rarities._default)
    elseif rarity_value == false then
        rare_class, rare_sort = unpack(rarities._default)
    else
        rare_sort = 1 / rarity_value
        rare_class = get_rarity_class(rarity_value)
    end
    local rollstext = ''
    if rolls ~= 1 and rolls then
        rollstext = rolls .. ' × '
        if rarity_value ~= false then
            rare_sort = rare_sort / rolls
            rare_class = get_rarity_class(math.min(1 / rare_sort, 0.99))
        end
    end
    local tilde = ''
    if approx then
        tilde = '~'
    end

    -- Clean up the lists
    quantity = qty(quantity)
    local qtysort = mw.text.split(quantity, '[^%d,]')[1]
    if qtysort == '' then
        qtysort = 0
    end

    -- Check if name is already formated
    if name:match('^%[%[') then
        name = name
    else
        name = '[[' .. name .. ']]'
    end
    if #namenotes > 5 then
        name = name .. ' ' .. namenotes
    end
    -- Table row creation
    local ret = mw.html.create('tr')
        :css('text-align', 'center')
    -- Higher priority
    if source_removed then
        ret:addClass('drop-removed')
    elseif source_currently_unavailable then
        ret:addClass('drop-restricted')
    end

    local name_cell = ret:tag('td')
        :css('text-align', 'left')
    -- Higher priority
    if source_removed then
        name_cell:addClass('table-bg-grey'):wikitext(name .. '<span title="Was previously dropped by" style="cursor:help;"><small><b> †</b></small></span>')
    elseif source_currently_unavailable then
        name_cell:wikitext(name .. '<span title="May not be currently available" style="cursor:help;"><small><b> &#x231B;</b></small></span>')
    else
        name_cell:wikitext(name)
    end

    ret:tag('td')
        :wikitext(level.value)
        :addClass(level.class)
        :attr('data-sort-value', level.sort)
        :done()
    local quantity_cell = ret:tag('td')
    quantity_cell:attr('data-sort-value', qtysort)
    quantity_cell:wikitext(quantity)
    if type(quantitynotes) == 'table' then
        add_dropnotes(quantitynotes, quantity_cell, item, 'dropsrc_q_ref_' .. i)
    end
    quantity_cell:done()

    local rarity_cell = ret:tag('td')
    local rarity_span = rarity_cell:tag('span')
    rarity_span:wikitext(rollstext .. tilde .. rarity)
    rarity_cell:attr('data-sort-value', rare_sort)
        :addClass(rare_class)
        :done()

    if type(rarity_value) == 'number' then
        rarity_span:attr {
            ['title'] = rollstext .. tilde .. string.format('%.3g%%', 100 * rarity_value),
            ['data-drop-fraction'] = rollstext .. tilde .. rarity,
            ['data-drop-oneover'] = rollstext .. tilde .. string.format('%s', rarity_value == 0 and 0 or '1/' .. commas(sigfigalt(1 / rarity_value))),
            ['data-drop-percent'] = rollstext .. tilde .. sigfig(100 * rarity_value, 3),
            ['data-drop-permil'] = rollstext .. tilde .. sigfig(1000 * rarity_value, 3),
            ['data-drop-permyriad'] = rollstext .. tilde .. sigfig(10000 * rarity_value, 3),
        }
    end

    local function buildAltRaritySpan(tbl_alt_rarity)
        local alt_text = tbl_alt_rarity.text;
        local alt_value = tbl_alt_rarity.value;

        if (tbl_alt_rarity.dash) then
            rarity_cell:tag('span'):wikitext('–')
        else
            rarity_cell:tag('span'):wikitext('; ')
        end

        local alt_rarity_span = rarity_cell:tag('span')
        alt_rarity_span:wikitext(alt_text)
        if type(alt_value) == 'number' then
            alt_rarity_span:attr {
                ['title'] = rollstext .. string.format('%.3g%%', 100 * alt_value),
                ['data-drop-fraction'] = alt_text,
                ['data-drop-oneover'] = string.format('%s', alt_value == 0 and 0 or '1/' .. commas(sigfigalt(1 / alt_value))),
                ['data-drop-percent'] = sigfig(100 * alt_value, 3),
                ['data-drop-permil'] = sigfig(1000 * alt_value, 3),
                ['data-drop-permyriad'] = sigfig(10000 * alt_value, 3),
            }
        end
    end

    if alt_rarities then
        for _, tbl_alt_rarity in ipairs(alt_rarities) do
            buildAltRaritySpan(tbl_alt_rarity);
        end
    elseif altrarity ~= '' and altrarity ~= nil then
        local alt_rarity_value
        if rarities[string.lower(tostring(altrarity))] then
            altrarity = params.ucflc(altrarity)
        else
            alt_rarity_value = altrarity:gsub(',', '') --temp place to put this without overriding rarity
            local rv1, rv2 = string.match(alt_rarity_value, '([%d%.]+)/([%d%.]+)')
            if rv1 and rv2 then
                altrarity = commas(rv1) .. '/' .. commas(rv2)
                alt_rarity_value = rv1 / rv2
            else
                alt_rarity_value = expr(altrarity)
            end
        end

        buildAltRaritySpan {
            text = altrarity,
            value = alt_rarity_value,
            dash = (altraritydash ~= '' and altraritydash ~= nil),
        };
    end

    if type(raritynotes) == 'table' then
        add_dropnotes(raritynotes, rarity_cell, item, 'dropsrc_r_ref_' .. i)
    end

    if noteref then
        local reftext = 'There is further information on this drop; see the associated page for details.'
        rarity_cell:wikitext(ref(reftext, '_dropref_'))
    end

    if leagueRegionBadges and leagueRegionBadges ~= '' then
        ret:tag('td')
            :css('max-width', '200px')
            :css('text-align', 'left') -- Align badges to the left
            :addClass('leagues-global-flag')
            :wikitext(leagueRegionBadges)
    else
        ret:tag('td')
            :css('max-width', '200px')
            :css('text-align', 'left') -- Keep N/A left-aligned as well for consistency
            :addClass('table-na leagues-global-flag')
            :wikitext('N/A')
    end

    return ret:done()
end

function p.main(frame)
    return p._main(frame:getParent().args)
end

function p._main(args)
    local item = args.item or args[1]
    local cleanedName = item
    local dropVers

    if item then
        item = mw.ustring.gsub(item, '&#39;', "'")
        if item:match('%#') then
            cleanedName, dropVers = mw.ustring.match(item, '^(.-)%#([%w%s%(%)]+)$')
        end
        if dropVers ~= nil and dropVers ~= '' then
            item = cleanedName .. '#' .. dropVers
        end
    else
        item = mw.title.getCurrentTitle().text
    end

    local verscount = 0
    if args.versions then
        local versionsnum = tonumber(args.versions)
        if versionsnum then
            verscount = math.floor(versionsnum)
        end
    end

    if verscount == 0 then
        local ret = makeTable(item, args)
        if #ret > 0 then
            return ret
        else
            return (":''No drop sources found. To force an update, click "
                .. purge('dml-' .. mw.uri.anchorEncode(item), 'here', 'span')
                .. ".''[[Category:Empty drop lists]]")
        end
    end

    local vers, res, emptyvers, rescount = 1, {}, {}, 0
    while vers <= verscount do
        local versname = cleanedName .. ' (' .. vers .. ')'
        local verres = makeTable(versname, args)
        if #verres == 0 then
            table.insert(emptyvers, versname)
        else
            if args.headers and params.has_content(args.headers) then
                if string.lower(args.headers) == 'potion' or string.lower(args.headers) == 'potions' then
                    table.insert(res, string.format('===%s dose===', vers))
                else
                    table.insert(res, string.format('===' .. args.headers .. '===', vers))
                end
            else
                table.insert(res, '===' .. versname .. '===')
            end
            table.insert(res, verres)
            rescount = rescount + 1
        end
        vers = vers + 1
    end

    if rescount == 0 then
        return 'Failed to find drop sources for that item and versions - ensure it is spelled correctly and version count is correct. (ERR: no results from bucket)[[Category:Empty drop lists]]'
    end
    if #emptyvers > 0 then
        table.insert(res, 1, '')
        local str = string.format("The following versions have no drop sources: %s. This, and the following lists are auto-generated (%s).", table.concat(emptyvers, ', '), purge('Products', 'click here to update', 'span'))
        table.insert(res, 1, str)
    end

    return table.concat(res, '\n')
end

return p