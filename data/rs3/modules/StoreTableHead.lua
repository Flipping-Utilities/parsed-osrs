local p = {}

local getArgs = require("Module:Arguments").getArgs
local params = require('Module:Paramtest')
local yesno = require('Module:Yesno')
local var = mw.ext.VariablesLua
local default_to = params.default_to

local REF_GROUP = "s"

local alignments = {
    left = true,
    center = true,
    right = true,
};

local function ref(content, name)
    if content == nil then
        return ""
    end

    return mw.getCurrentFrame():getParent():extensionTag('ref', content, { name = name, group = REF_GROUP })
end

local function extraColumns(ret, classes, args, prefix, startCols, defaultAlign)
    local cols = 0
    local i = 1
    local column = args[prefix .. i]
    while column do
        ret:tag('th'):wikitext(column)
        cols = cols + 1;

        local css = args[prefix .. i .. "css"];
        if css ~= nil then
            ret:cssText(css);
        end

        local align = string.lower(args[prefix .. i .. "align"] or defaultAlign);
        if alignments[align] then
            table.insert(classes, "align-" .. align .. "-" .. (startCols + cols));
        end

        i = i + 1
        column = args[prefix .. i]
    end

    return cols
end

local function priceMods(ret, args, prefix, class, default)
    local cols = 0
    local mods = {}
    local roundings = {}
    local miscs = {}

    local i = 1
    local mod = args[prefix .. i]
    while mod do
        local display = args[prefix .. i .. "name"] or string.format(default, i)
        local misc = args[prefix .. i .. "misc"]
        local rounding = args[prefix .. i .. "round"] or "ceil"

        local col = ret:tag('th'):addClass(class):addClass(class .. i):wikitext(display)
        if params.has_content(misc) then
            col:wikitext(ref(misc, prefix .. i))
            table.insert(miscs, misc)
        end

        cols = cols + 1;
        table.insert(mods, mod)
        table.insert(roundings, rounding:lower())

        i = i + 1
        mod = args[prefix .. i]
    end

    return cols, mods, roundings, miscs
end

function p.main(frame)
    local args = getArgs(frame)

    local separator = default_to(args.separator, ';')
    local currency = default_to(args.currency or args.Currency, 'coins')
    local historical = default_to(args.historical or args.Historical, '')
    local bucket = default_to(args.bucket, '')
    local gemw = default_to(args.gemw, '')
    local lighttable = default_to(args.lighttable, '')
    local stickyheader = default_to(args['sticky-header'], 'yes')
    local tableId = default_to(args.id, '')
    local showactual = default_to(args.actual, '')
    local hideimage = default_to(args.hideimage, 'no')
    local hidege = default_to(args.hidege, 'no')
    local hidebuy = default_to(args.hidebuy, 'no')
    local buyColumnName = default_to(args.sellname, 'Price<br>bought at')
    local hidesell = default_to(args.hidesell, 'no')
    local sellColumnName = default_to(args.sellname, 'Price<br>sold at')
    local hidestock = default_to(args.hidestock, 'no')
    local hiderestock = default_to(args.hiderestock, 'no')
    local hideresale = default_to(args.hideresale, 'no')
    local hidemembers = default_to(args.hidemembers, 'yes')
    local hidesmuggler = default_to(args.hidesmuggler, 'yes')
    local members = default_to(args.members, '')
    local hideironmen = default_to(args.hideironmen, 'yes')
    local ironmen = default_to(args.ironmen, '')
    local showDescription = default_to(args.descriptions, 'no')
    local descriptionsWidth = default_to(args['descriptions-width'], '')
    local version = default_to(args.version, '')
    local requirementColumn = default_to(args.requirementcolumn, 'no')
    local quest = default_to(args.quest, '')
    local questPartial = default_to(args['quest-partial'], '')
    local questDuring = default_to(args['quest-during'], '')
    local questBefore = default_to(args['quest-before'], '')
    local achievement = default_to(args.achievement, '')
    local achievementBefore = default_to(args['achievement-before'], '')
    local itemPurchased = default_to(args.purchased, '')
    local itemObtained = default_to(args.obtained, '')
    local itemCarrying = default_to(args.carrying, '')
    local itemEquipped = default_to(args.equipped, '')
    local miscReq = default_to(args.misc, '')
    local thresholdUnlock = default_to(args.threshold or args.upgradestore, 'no')
    local location = default_to(args.location, '')

    var.vardefine('separator', separator)
    var.vardefine('currency', currency)
    var.vardefine('historical', historical)
    var.vardefine('bucket', bucket)
    var.vardefine('gemw', gemw)
    var.vardefine('storeShowActual', showactual)
    var.vardefine('hideImage', hideimage)
    var.vardefine('hideGE', hidege)
    var.vardefine('hideBuy', hidebuy)
    var.vardefine('hideSell', hidesell)
    var.vardefine('hideStock', hidestock)
    var.vardefine('hideRestock', hiderestock)
    var.vardefine('hideResale', hideresale)
    var.vardefine('hideMembers', hidemembers)
    var.vardefine('hideSmuggler', hidesmuggler)
    var.vardefine('storeMembers', members)
    var.vardefine('hideIronmen', hideironmen)
    var.vardefine('storeIronmen', ironmen)
    var.vardefine('showDescription', showDescription)
    var.vardefine('storeVersion', version)
    var.vardefine('requirementColumn', requirementColumn)
    var.vardefine('storeQuest', quest)
    var.vardefine('storeQuestPartial', questPartial)
    var.vardefine('storeQuestDuring', questDuring)
    var.vardefine('storeQuestBefore', questBefore)
    var.vardefine('storeAchievement', achievement)
    var.vardefine('storeAchievementBefore', achievementBefore)
    var.vardefine('storeItemPurchased', itemPurchased)
    var.vardefine('storeItemObtained', itemObtained)
    var.vardefine('storeItemCarrying', itemCarrying)
    var.vardefine('storeItemEquipped', itemEquipped)
    var.vardefine('storeMisc', miscReq)
    var.vardefine('thresholdUnlock', thresholdUnlock)
    var.vardefine('storeTableLocation', location)

    local ret = mw.html.create('tr')
    local cols = 0

    local classes = {}
    -- Item name
    hideimage = yesno(hideimage)
    local colspan = hideimage and 1 or 2
    local itemColumnName = 'Item'
    ret:tag('th'):addClass('item-col'):attr('colspan', colspan):wikitext(itemColumnName):done()
    table.insert(classes, hideimage and 'align-left-1' or 'align-center-1 align-left-2')
    cols = cols + colspan;

    -- Stock
    if not yesno(hidestock) then
        ret:tag('th'):addClass('stock-col'):attr('data-sort-type', 'number'):wikitext('Number<br>in stock'):done()
        cols = cols + 1;
        table.insert(classes, 'align-center-' .. cols)
    end

    -- Restock
    --if not(yesno(hiderestock)) then
    --    ret:tag('th'):attr('data-sort-type', 'number'):wikitext('Restock<br/>time'):done()
    --	cols = cols + 1;
    --end

    -- Sell price
    if not (yesno(hidesell)) then
        ret:tag('th'):addClass('sell-col'):attr('data-sort-type', 'number'):wikitext(sellColumnName):done()
        cols = cols + 1;
        table.insert(classes, 'align-right-' .. cols)
    end

    -- Sell modifier
    local sellmodCols, sellmods, sellmodRoundings, sellmodMiscs = priceMods(ret, args, 'sellmod', 'sell-mod-col', 'Discounted %d')
    var.vardefine('sellmods', table.concat(sellmods, ';'))
    var.vardefine('sellmodRoundings', table.concat(sellmodRoundings, ';'))
    var.vardefine('sellmodMiscs', table.concat(sellmodMiscs, ';'))
    cols = cols + sellmodCols;

    -- Buy price
    if not (yesno(hidebuy)) then
        ret:tag('th'):addClass('buy-col'):attr('data-sort-type', 'number'):wikitext(buyColumnName):done()
        cols = cols + 1;
        table.insert(classes, 'align-right-' .. cols)
    end

    -- Smuggler minimum complexity
    if not (yesno(hidesmuggler)) then
        ret:tag('th'):attr('data-sort-type', 'number'):wikitext('Minimum<br>complexity'):done()
        cols = cols + 1;
        table.insert(classes, 'align-right-' .. cols)
    end

    -- GE price
    if not (yesno(hidege)) then
        ret:tag('th'):addClass('ge-column'):attr('data-sort-type', 'number'):wikitext('[[Grand Exchange|GE <br>price]]'):done()
        cols = cols + 1;
        table.insert(classes, 'align-right-' .. cols)
    end

    -- Resale price
    if not (yesno(hideresale)) then
        ret:tag('th'):addClass('resale-col'):attr('data-sort-type', 'number'):wikitext('Resale<br>value'):done()
        cols = cols + 1;
        table.insert(classes, 'align-right-' .. cols)
    end

    -- Members
    if not (yesno(hidemembers)) then
        ret:tag('th'):wikitext('Members'):done()
        cols = cols + 1;
        table.insert(classes, 'align-center-' .. cols)
    end

    -- Ironmen
    if not (yesno(hideironmen)) then
        ret:tag('th'):wikitext('Ironmen'):done()
        cols = cols + 1;
        table.insert(classes, 'align-center-' .. cols)
    end

    -- Skill requirement
    local skillCols = extraColumns(ret, classes, args, 'skill', cols, 'center')
    var.vardefine('skillColumns', skillCols)
    cols = cols + skillCols;

    -- Miscellaneous requirement
    if (yesno(requirementColumn)) then
        ret:tag('th'):addClass('requirement-col'):wikitext('Requirement'):done()
        cols = cols + 1;
        table.insert(classes, 'align-left-' .. cols)
    end

    -- Description
    if (yesno(showDescription)) then
        local descCol = ret:tag('th'):addClass('description-col'):wikitext('In-game description')
        if descriptionsWidth ~= '' then
            descCol:css('width', descriptionsWidth)
        end
        descCol:done()

        cols = cols + 1;
        table.insert(classes, 'align-left-' .. cols)
    end

    -- Extra
    local extraCols = extraColumns(ret, classes, args, 'column', cols, 'left')
    var.vardefine('extraColumns', extraCols)
    cols = cols + extraCols;
    ret:done()

    table.insert(classes, yesno(thresholdUnlock) and '' or 'store-table')
    table.insert(classes, yesno(lighttable) and 'lighttable' or '')
    table.insert(classes, yesno(stickyheader) and 'sticky-header' or '')
    table.insert(classes, yesno(historical) and 'storetbl-hist' or '')

    -- The template will not be called if all the parameters are the same
    local tableIdAttr = ''
    if tableId ~= '' then
        tableIdAttr = 'data-tableid="' .. tableId .. '"'
        var.vardefine('storeTableId', tableId)
    else
        local seq
        if var.varexists('storeTableSeq') then
            seq = tonumber(var.var('storeTableSeq')) + 1
        else
            seq = 1
        end

        var.vardefine('storeTableSeq', seq)
        var.vardefine('storeTableId', string.format('%s-%s', mw.title.getCurrentTitle().text, seq))
    end

    return string.format('<table class="wikitable sortable %s" %s>', table.concat(classes, " "), tableIdAttr) .. tostring(ret)
end

return p