-- <nowiki>
require("strict")
local p = {}

local checkType = require("libraryUtil").checkType;
local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local infobox = require('Module:Infobox')
local skillclickpic = require('Module:Skill clickpic')._main
local params = require('Module:Paramtest')
local defTo = params.default_to
local comma = require('Module:Addcommas')._add
local currency = require('Module:Currencies')._amount

local isDefined = infobox.isDefined

local speciesData = mw.loadData('Module:Animal species data/data')
require("Module:Mw.html extension")

local muck_disp, breeding_disp, breeding_max_disp, breeding_chance_disp, produces_disp, param_noop, json_bucket, attach_growth_table, attach_buyer_table, addcategories

local function format_plural(value, singular, plural)
    checkType("format_plural", 1, value, "number");
    if value == 0 then
        return
    elseif value == 1 then
        return value .. singular
    else
        return value .. plural
    end
end

local function format_duration(minutes)
    local output = {}

    local one_hour = 60
    local one_day = one_hour * 24
    if minutes >= one_day then
        --table.insert(output, format_plural(math.floor(minutes / one_day), " day", " days"))
        table.insert(output, format_plural(math.floor(minutes / one_day), "d", "d"))
        minutes = minutes % one_day
    end

    if minutes >= one_hour then
        -- table.insert(output, format_plural(math.floor(minutes / one_hour), " hour", " hours"))
        table.insert(output, format_plural(math.floor(minutes / one_hour), "h", "h"))
        minutes = minutes % one_hour
    end

    if minutes > 0 then
        --table.insert(output, format_plural(minutes, " minute", " minutes"))
        table.insert(output, format_plural(minutes, "m", "m"))
    end

    return table.concat(output, " ")
end

function p.main(frame)
    local args = frame:getParent().args
    args = p._parse_args(args)

    local ret = infobox.new(args)

    ret:defineParams {
        { name = 'name', func = 'name' },
        { name = 'species', func = param_noop },
        { name = 'level', func = param_noop },
        { name = 'pen', func = param_noop },
        { name = 'food', func = param_noop },
        { name = 'muck', func = muck_disp },
        { name = 'muck_disp', func = { name = muck_disp, params = { 'muck' }, flag = { 'p' } } },
        { name = 'breeding', func = json_bucket },
        { name = 'breeding_disp', func = { name = breeding_disp, params = { 'breeding' }, flag = { 'p' } } },
        { name = 'breeding_max_disp', func = { name = breeding_max_disp, params = { 'breeding' }, flag = { 'p' } } },
        { name = 'breeding_chance', func = json_bucket },
        { name = 'breeding_chance_disp', func = { name = breeding_chance_disp, params = { 'breeding_chance' }, flag = { 'p' } } },
        { name = 'produces', func = json_bucket },
        { name = 'produces_disp', func = { name = produces_disp, params = { 'produces' }, flag = { 'p' } } },
        { name = 'growth', func = json_bucket },
        { name = 'xp', func = json_bucket },
        { name = 'beans', func = json_bucket },
        { name = 'buyer', func = json_bucket },
    }

    ret:useBucket('infobox_animal', {
        name = 'name',
        level = 'level',
        pen = 'pen',
        food = 'food',
        muck = 'muck',
        breeding = 'breeding',
        breeding_chance = 'breeding_chance',
        produces = 'produces',
        growth = 'growth',
        xp = 'xp',
        beans = 'beans',
        buyer = 'buyer',
    })

    ret:setMaxButtons(4)
    ret:create()
    ret:cleanParams()
    ret:customButtonPlacement(true)

    ret:defineLinks()

    ret:defineName('Infobox Animal')
    ret:addClass('infobox-animal left-info')

    ret:addButtonsCaption()

    -- PARAMETER: name
    ret:addRow {
        { tag = 'argh', content = 'name', class = 'infobox-header', colspan = '20' }
    }

    ret:pad(20)

    -- PARAMETER: level
    ret:addRow {
        { tag = 'th', content = skillclickpic('Farming') .. ' Level', colspan = '8' },
        { tag = 'argd', content = 'level', colspan = '12' }
    }

    -- PARAMETER: pen
    ret:addRow {
        { tag = 'th', content = 'Pen size', colspan = '8' },
        { tag = 'argd', content = 'pen', colspan = '12' }
    }

    -- PARAMETER: food
    ret:addRow {
        { tag = 'th', content = 'Eats', colspan = '8' },
        { tag = 'argd', content = 'food', colspan = '12' }
    }

    -- PARAMETER: Produce
    ret:addRow {
        { tag = 'th', content = 'Produce' .. '<sup class="hover-text noprint" title="Produce per growth stage excluding egg to child.">[?]</sup>', colspan = '8' },
        { tag = 'argd', content = 'produces_disp', colspan = '12' }
    }

    -- PARAMETER: muck
    ret:addRow {
        { tag = 'th', content = 'Muck', colspan = '8' },
        { tag = 'argd', content = 'muck_disp', colspan = '12' }
    }

    -- PARAMETER: breeding
    ret:pad(20)
    ret:addRow {
        { tag = 'th', content = 'Breeding', class = 'infobox-subheader', colspan = '20' },
    }
    ret:pad(20)

    ret:addRow {
        { tag = 'th', content = 'Cycle', colspan = '8' },
        { tag = 'argd', content = 'breeding_disp', colspan = '12' }
    }

    ret:addRow {
        { tag = 'th', content = 'Max cycle', colspan = '8' },
        { tag = 'argd', content = 'breeding_max_disp', colspan = '12' }
    }

    ret:addRow {
        { tag = 'th', content = 'Success chance', colspan = '8' },
        { tag = 'argd', content = 'breeding_chance_disp', colspan = '12' }
    }

    ret:pad(20)

    ret:addDropLevelVars('farming', 'level')

    ret:finish()

    local elem = mw.html.create()
    attach_growth_table(elem, args)
    attach_buyer_table(elem, args)

    if onmain() then
        local a1 = ret:param('all')
        local a2 = ret:categoryData()
        ret:wikitext(addcategories(a1, a2))
    end

    return ret:tostring() .. tostring(elem)
end

local function floor_10(xp)
    return math.floor(10 * xp) / 10
end

local function calc_curing_xp(xp, multi)
    return comma(floor_10(xp * multi))
end

function attach_growth_table(ret, args)
    local egg = args.egg

    ret:tag(''):tag('h3'):wikitext('Growth stage info')

    local tbl = ret:tag('table'):addClass('wikitable')

    tbl:tr()
        :th { "Single stage" }
        :If(egg):th { "Egg", css = { 'width', '9ch' } }:End()
        :th { "Child", css = { 'width', '9ch' } }
        :th { "Adolescent", css = { 'width', '9ch' } }
        :th { "Adult", css = { 'width', '9ch' } }
        :th { "Elder", css = { 'width', '9ch' } }
        :th { "Total", css = { 'width', '9ch' } }

    local growth = args.growth
    local row = tbl:tr()
        :th { "Growth time" }

    if egg then
        row:na()
    end
    if growth.child ~= nil then
        row:td(format_duration(growth.child))
    else
        row:na()
    end
    row
        :td { format_duration(growth.adolescent) }
        :td { format_duration(growth.adult) }
        :td { format_duration(growth.elder) }
        :td { format_duration(growth.total) }

    local xp = args.xp
    row = tbl:tr()
        :th { "Checking XP" }

    if egg then
        row:na()
    end
    if xp.child ~= nil then
        row:td( comma(floor_10(xp.child)) )
    else
        row:na()
    end
    row
        :td { comma(floor_10(xp.adolescent)) }
        :td { comma(floor_10(xp.adult)) }
        :td { comma(floor_10(xp.elder)) }
        :td { comma(floor_10(xp.total)) }

    row = tbl:tr()
        :th { "Curing disease XP" }

    if egg then
        row:na()
    end
    if xp.child ~= nil then
        row:td(calc_curing_xp(xp.child, 0.05))
    else
        row:na()
    end
    row
        :td { calc_curing_xp(xp.adolescent, 0.05) }
        :td { calc_curing_xp(xp.adult, 0.05) }
        :td { calc_curing_xp(xp.elder, 0.01) }
        :na()

    local beans = args.beans
    row = tbl:tr()
        :th { "[[Player-owned farm#Selling|Base sell price]]" }

    if egg then
        if beans.egg ~= nil then
            row:td(currency(beans.egg, 'beans'))
        else
            row:na()
        end
    end

    row
        :td { currency(beans.child, 'beans') }
        :td { currency(beans.adolescent, 'beans') }
        :td { currency(beans.adult, 'beans') }
        :td { currency(beans.elder, 'beans') }
        :na()
end

local function chatl(link, display, pic)
    return mw.html.create()
        :tag('span')
        :addClass('chathead-link')
        :wikitext(string.format('[[File:%s.png|link=%s|alt=%s.png: Chat head image of %s|35x35px]]', pic, link, pic, display))
        :done()
        :wikitext(string.format('[[%s|%s]]', link, display))
        :done()
end

function attach_buyer_table(ret, args)
    local buyer = args.buyer

    ret:tag('h3'):wikitext('Buyer')

    local tbl = ret:tag('table'):addClass('wikitable rotation-group rotation-group-noactivestyle'):attr(args.buyer_spawn)
    tbl:tr()
        :td():node(chatl(buyer.link, buyer.display, buyer.pic))
    tbl:tr()
        :th():wikitext('Spawns')
    local placeholders = { 'We are contacting the buyer.', 'They said they would provide the arrival time...', 'and of course the departure time.' }
    for i = 0, 2 do
        local row = tbl:tr():addClass('rotation-item')
        row:td()
            :tag('span'):addClass('rotation-inactive-text rotation-next-start'):wikitext(placeholders[i + 1]):done()
            :tag('span'):addClass('rotation-active-text rotation-countdown rotation-hideuntilsetup'):done()
    end
end

local function parse_species(speciesName)
    if speciesName ~= nil then
        speciesName = speciesName:lower()
    end

    local species = speciesData[speciesName]
    if species == nil then
        return {}
    end

    return species
end

local function parse_level(species, level)
    return defTo(tonumber(level), species.level)
end

local function parse_pen(species, pen)
    return defTo(pen, species.pen)
end

local function parse_food(species, food)
    return defTo(food, species.food)
end

local function parse_muck(species, muck)
    muck = defTo(muck, species.muck)
    if muck == false or not params.has_content(muck) then
        return nil
    end

    return muck
end

function muck_disp(muck)
    if not isDefined(muck) then
        return 'None'
    end

    return muck
end

local function parse_breeding(species, breeding)
    return defTo(tonumber(breeding), species.breedingtime)
end

function breeding_disp(breeding)
    return format_duration(breeding)
end

function breeding_max_disp(breeding)
    return format_duration(breeding * 5)
end

local function parse_breeding_chance(species, breeding_chance)
    return defTo(tonumber(breeding_chance), species.breedingchancepercentage)
end

function breeding_chance_disp(breeding_chance)
    return breeding_chance .. '%'
end

local function zero_to_nil(value)
    if value == 0 then
        return nil
    else
        return value
    end
end

local function parse_growth(species, child, adolescent, adult, elder)
    local child = defTo(tonumber(child), species.childtime)
    local adolescent = defTo(tonumber(adolescent), species.adolescenttime)
    local adult = defTo(tonumber(adult), species.adulttime)
    local elder = defTo(tonumber(elder), species.eldertime)
    return {
    	child = zero_to_nil(child),
    	adolescent = zero_to_nil(adolescent),
    	adult = zero_to_nil(adult),
    	elder = zero_to_nil(elder),
    	total = zero_to_nil(child + adolescent + adult + elder)
    }
end

local function parse_xp(species, child, adolescent, adult, elder)
    local child = defTo(tonumber(child), species.childxp)
    local adolescent = defTo(tonumber(adolescent), species.adolescentxp)
    local adult = defTo(tonumber(adult), species.adultxp)
    local elder = defTo(tonumber(elder), species.elderxp)
    return {
    	child = zero_to_nil(child),
    	adolescent = zero_to_nil(adolescent),
    	adult = zero_to_nil(adult),
    	elder = zero_to_nil(elder),
    	total = zero_to_nil(child + adolescent + adult + elder)
    }
end

local function parse_beans(species, beans, eggbeans)
    local adolescent = defTo(tonumber(beans), species.beans)
    return {
        egg = defTo(eggbeans, species.egg and math.floor(adolescent * 0.1) or nil),
        child = math.floor(adolescent * 0.2),
        adolescent = adolescent,
        adult = math.floor(adolescent * 0.85),
        elder = math.floor(adolescent * 0.7),
    }
end

local function parse_buyer(species, buyer, buyer_display, buyer_alt, buyer_pic)
    local link = defTo(buyer, species.buyer)
    return {
        link = link,
        display = defTo(buyer_display or buyer_alt, species.buyeralttxt or link),
        pic = defTo(buyer_pic, species.buyerpic or link .. ' chathead'),
    }
end

local function parse_buyer_spawn(pen)
    local starttime = '2019-11-25 00:00:00+00'
    local period = { ['Small'] = 1, ['Medium'] = 2, ['Large'] = 3 }
    local length = period[pen];
    mw.log(length)
    return {
        ['data-rotation-start'] = starttime,
        ['data-rotation-nexttimeformat'] = "D MMM HH:mm",
        ['data-rotation-active'] = '{"d":' .. length .. '}',
        ['data-rotation-fullperiod'] = '{"d":' .. length * 3 .. '}',
        ['data-rotation-itemperiod'] = '{"d":' .. length .. '}',
        ['data-rotation-next-within'] = '{"d":0}',
        ['data-rotation-option-skipactive'] = "true",
        ['data-rotation-option-sorttotop'] = "true",
    }
end

local function to_list(...)
    local list = {}
    for k, v in pairs(arg) do
        if k ~= 'n' and isDefined(v) then
            table.insert(list, v)
        end
    end

    if next(list) == nil then
        return nil
    else
        return list
    end
end

local function parse_produces(args)
    return to_list(args.produceitem, args.produceitem1, args.produceitem2, args.produceitem3, args.produceitem4, args.produceitem5, args.produceitem6)
end

local function plink(name)
    local file = name .. '.png'
    return string.format('[[File:%s|link=%s|frameless|35px]] [[%s]]', file, name, name)
end

function produces_disp(produces)
    for i, produce in ipairs(produces) do
        if produce:lower() == 'varies' then
            produces[i] = 'Varies'
        elseif produce:lower() == 'no' or produce:lower() == 'none' then
            produces[i] = 'None'
        else
            produces[i] = plink(produce)
        end
    end

    return table.concat(produces, ',')
end

function p._parse_args(args)
    local species = parse_species(args.species)
    args.species = species
    args.egg = yesno(args.egg, species.egg)

    args.level = parse_level(species, args.level)
    args.pen = parse_pen(species, args.pen)
    args.food = parse_food(species, args.food)
    args.muck = parse_muck(species, args.muck)

    -- Breeding
    args.breeding = parse_breeding(species, args.breeding)
    args.breeding_chance = parse_breeding_chance(species, args.breeding_chance)

    -- Growth and XP
    args.growth = parse_growth(species, args.childtime, args.adolescenttime, args.adulttime, args.eldertime)
    args.xp = parse_xp(species, args.childxp, args.adolescentxp, args.adultxp, args.elderxp)

    -- Buyer info
    args.beans = parse_beans(species, args.beans, args.eggbean)
    args.buyer = parse_buyer(species, args.buyer, args.buyerdisplay, args.buyeralt, args.buyerpic)
    args.buyer_spawn = parse_buyer_spawn(args.pen)

    -- Produces
    args.produces = parse_produces(args)

    return args
end

function param_noop(arg)
    return arg
end

function json_bucket(content)
    if not isDefined(content) then
        return nil
    end

    local json_good, json = pcall(mw.text.jsonEncode, content) --, mw.text.JSON_PRETTY)
    if json_good then
        return json
    end

    return error('Error converting to JSON')
end

-- Categories
function addcategories(args, catargs)
    local ret = {}
    table.insert(ret, 'Archaeology collections')

    local cat_map = {
        -- Added if the parameter has no content
        notdefined = {
            release = 'Needs release date',
            id = 'Archaeology collections without ID'
        },
    }

    for n, v in pairs(cat_map.notdefined) do
        if catargs[n] and catargs[n].all_defined == false then
            table.insert(ret, v)
        end
    end

    -- combine table and format category wikicode
    for i, v in ipairs(ret) do
        if (v ~= '') then
            ret[i] = string.format('[[Category:%s]]', v)
        end
    end

    return table.concat(ret, '')
end

return p
-- </nowiki>