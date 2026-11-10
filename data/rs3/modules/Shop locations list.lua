-- <nowiki>
require("Module:Mw.html extension")
local p = {}

local commas = require("Module:Addcommas")._add
local params = require("Module:Paramtest")
local yesNo = require("Module:Yesno")
local arr = require('Module:Array')
local currencyImage = require("Module:Currency Image")
local yesno = require('Module:Yesno')
local var = mw.ext.VariablesLua
local lang = mw.language.getContentLanguage()

local p2pIcon = '[[File:P2P icon.png|25px|frameless|link=Members|alt=Members]]'
local f2pIcon = '[[File:F2P icon.png|25px|frameless|link=Free-to-play|alt=Free-to-play]]'
local itemPackIcon = ' [[File:Empty sack pack.png|25px|frameless|link=Item pack|alt=Item pack]]'

local REF_GROUP = "sl"

local leagues
local function getLeagues()
    if leagues == nil then
        leagues = require('Module:LeagueRegion')
    end

    return leagues
end

local function starts_with(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

local function to_number(arg, default)
    if arg == nil then
        return default
    end

    return tonumber(arg) or default
end

local function editbutton(title)
    if title == "" then
        return ""
    end

    local originalTitle = mw.title.getCurrentTitle().fullText
    originalTitle = originalTitle:gsub("([^%w])", "%%%1")
    originalTitle = originalTitle:gsub(' ', '_')

    local link = mw.title.getCurrentTitle():fullUrl("action=edit")
    link = link:gsub(originalTitle, title)
    link = link:gsub(' ', '_')
    link = string.format("<span class='plainlinks'>[%s '''?''' (edit)]</span>", link)

    return link
end

local function ref(content, name)
    if content == nil then
        return ""
    end

    return mw.getCurrentFrame():getParent():extensionTag('ref', content, { name = name, group = REF_GROUP })
end

local function packIcon(link)
    if params.has_content(link) then
        return string.format(' [[File:%s.png|25px|frameless|link=%s|alt=%s]]', link, link, link)
    else
        return itemPackIcon
    end
end

local function getCurrency(currency, i, default)
    local currencyType = type(currency);
    if currencyType == 'string' then
        return currency
    elseif currencyType == 'table' then
        return currency[i] or default
    else
        return default
    end
end

local function convertShopNotes(idx, notes, itemName)
    local refs = ''

    local function addRef(varname, note, n)
        local refname = string.format('%s_%s_%s', itemName, idx, n)
        var.vardefine(varname, refname)
        refs = refs .. ref(note, refname)
    end

    for n, note in ipairs(notes) do
        local varname = 'storeLocRef_' .. mw.text.killMarkers(note)
        if var.varexists(varname) then
            local oldvar = var.var(varname)
            if starts_with(oldvar, itemName) then
                refs = refs .. ref('', oldvar)
            else
                addRef(varname, note, n)
            end
        else
            addRef(varname, note, n)
        end
    end

    return refs
end

local function formatRequirement(tbl, values, fmt, name_fmt)
    if values == nil then
        return
    end

    local names = {}
    for _, value in ipairs(values) do
        table.insert(names, string.format(name_fmt, value))
    end

    table.insert(tbl, string.format(fmt, mw.text.listToText(names, ', ', ', and ')))
end

local function formatRequirementWithQty(tbl, values, quantities, fmt, name_fmt)
    if values == nil then
        return
    end

    if quantities == nil then
        quantities = {}
    end

    local names = {}
    for i, value in ipairs(values) do
        local qty = to_number(quantities[i] or '')
        if qty == nil then
            table.insert(names, string.format(name_fmt, value, ''))
        else
            table.insert(names, string.format(name_fmt, value, ' (&times;' .. lang:formatNum(qty) .. ')'))
        end
    end

    table.insert(tbl, string.format(fmt, mw.text.listToText(names, ', ', ', and ')))
end

local function insertRequirement(requirementItems, notes)
    -- Based on quest condition
    formatRequirement(requirementItems, notes.quest.after.store, 'Available after completion of %s.', '[[%s]]')
    formatRequirement(requirementItems, notes.quest.after.item, 'Available after completion of %s.', '[[%s]]')

    formatRequirement(requirementItems, notes.quest.partial.store, 'Available after partial completion of %s.', '[[%s]]')
    formatRequirement(requirementItems, notes.quest.partial.item, 'Available after partial completion of %s.', '[[%s]]')

    formatRequirement(requirementItems, notes.quest.during.store, 'Available during %s.', '[[%s]]')
    formatRequirement(requirementItems, notes.quest.during.item, 'Available during %s.', '[[%s]]')

    formatRequirement(requirementItems, notes.quest.before.store, 'Available before completion of %s.', '[[%s]]')
    formatRequirement(requirementItems, notes.quest.before.item, 'Available before completion of %s.', '[[%s]]')

    formatRequirement(requirementItems, notes.achievement.after.store, 'Available after completion of %s.', '[[%s]]')
    formatRequirement(requirementItems, notes.achievement.after.item, 'Available after completion of %s.', '[[%s]]')

    formatRequirement(requirementItems, notes.achievement.before.store, 'Available before completion of %s.', '[[%s]]')
    formatRequirement(requirementItems, notes.achievement.before.item, 'Available before completion of %s.', '[[%s]]')

    formatRequirement(requirementItems, notes.item.purchased.store, 'Available after having purchased %s.', '[[%s]]')
    formatRequirement(requirementItems, notes.item.purchased.item, 'Available after having purchased %s.', '[[%s]]')

    formatRequirement(requirementItems, notes.item.obtained.store, 'Available after having obtained %s.', '[[%s]]')
    formatRequirement(requirementItems, notes.item.obtained.item, 'Available after having obtained %s.', '[[%s]]')

    formatRequirement(requirementItems, notes.item.carrying.store, 'Available while carrying %s.', '[[%s]]%s')
    formatRequirementWithQty(requirementItems, notes.item.carrying.item, notes.item.carrying.quantity, 'Available while carrying %s.', '[[%s]]%s')

    formatRequirement(requirementItems, notes.item.equipped.item, 'Available while equipping %s.', '[[%s]]')
    formatRequirement(requirementItems, notes.item.equipped.store, 'Available while equipping %s.', '[[%s]]')
end

local function convertShopDisplay(idx, storeLine, itemName, isPackOf)
    local shopDisp

    -- Fallback: Check infobox_shop first, then fall back to infobox_npc for dialogue-only shops
    local salesperson = storeLine['infobox_shop.owner'] or storeLine['infobox_npc.page_name']
    if salesperson ~= nil and string.lower(salesperson) ~= 'n/a' then
        shopDisp = salesperson .. '<br>Shop: '
    else
        shopDisp = '';
    end

    local soldby = storeLine.page_name_sub
    local soldbyVariantPos = soldby:find('#')
    if soldbyVariantPos ~= nil then
        local soldbyTag = soldby:sub(soldbyVariantPos + 1):gsub('_', ' ')
        shopDisp = string.format("%s[[%s|%s  <small>''%s''</small>]]", shopDisp, soldby, storeLine.page_name, soldbyTag)
    else
        shopDisp = string.format("%s[[%s]]", shopDisp, soldby)
    end

    if isPackOf then
        shopDisp = string.format("%s%s <small>''(%s×)''</small>", shopDisp, packIcon(storeLine['sold_item']), commas(storeLine['pack_amount'] or 1))
    end

    local quantity = to_number(storeLine['quantity'])
    if quantity ~= nil and quantity > 1 then
        shopDisp = string.format("%s <small>''(%s×)''</small>", shopDisp, commas(quantity))
    end

    local shopNotes = {}
    local itemNotes = mw.text.jsonDecode(storeLine['sold_item_notes'])

    local skills = itemNotes.skills or {}
    local skillLen = arr.len(skills)
    if skillLen > 0 then
        local skillNames = {}
        for i = 1, skillLen do
            local skill = skills[i]
            if skill ~= nil then
                table.insert(skillNames, string.format('level %s [[%s]]', skill.level, skill.name))
            end
        end
        table.insert(shopNotes, string.format('Requires %s to unlock.', mw.text.listToText(skillNames, ', ', ', and ')))
    end

    insertRequirement(shopNotes, itemNotes)

    if itemNotes.misc.store ~= nil then
        arr.insert(shopNotes, itemNotes.misc.store, true)
    end

    if itemNotes.misc.item ~= nil then
        arr.insert(shopNotes, itemNotes.misc.item, true)
    end

    if itemNotes.ironmen == 'only' then
        table.insert(shopNotes, 'Only available to [[Ironman Mode]] accounts.')
    elseif itemNotes.ironmen == true then
        table.insert(shopNotes, 'Available to [[Ironman Mode]] accounts.')
    elseif itemNotes.ironmen == false then
        table.insert(shopNotes, 'Not available to [[Ironman Mode]] accounts.')
    end

    return shopDisp, convertShopNotes(idx, shopNotes, itemName)
end

local function convertStockMembers(storeLine, itemIsMembers, editbtn)
    local members = {}
    local bucketMembers;
    if itemIsMembers or storeLine['is_members_only'] then
        -- Members only when any source is members only
        bucketMembers = true
    elseif storeLine['is_members_only'] ~= nil then
        bucketMembers = storeLine['is_members_only']
    end

    if type(bucketMembers) == 'string' or type(bucketMembers) == 'boolean' then
        table.insert(members, bucketMembers)
    elseif type(bucketMembers) == 'table' then
        for _, v in ipairs(bucketMembers) do
            table.insert(members, v)
        end
    end

    local stockMembers = ''
    -- contains yes and no
    local hasYes, hasNo = false, false
    for _, value in ipairs(members) do
        value = yesNo(value)
        if value == true then
            hasYes = true
        elseif value == false then
            hasNo = true
        end
    end
    if hasYes and hasNo then
        stockMembers = f2pIcon .. "/" .. p2pIcon
    elseif hasYes then
        stockMembers = p2pIcon
    elseif hasNo then
        stockMembers = f2pIcon
    else
        -- Unsupported type for yesNo, default to editbtn
        stockMembers = editbtn
    end

    return stockMembers
end

local function convertStock(storeLine, isPackOf, historic, editbtn)
    if storeLine['store_stock_infinite'] then
        local stock = '<span style="font-size:120%;">∞</span>'

        local stockSortValue
        if historic then
            stockSortValue = -10e99
        else
            stockSortValue = 10e99
        end

        local stockTtl = 'Infinite available'

        return stock, stockSortValue, stockTtl
    end

    -- base amount in stock
    local stock = storeLine['store_stock'] or ''
    stock = string.lower(string.gsub(stock, ',', ''))

    if stock == 'n/a' then
        local stockSortValue = 10e99
        local stockTtl = 'No stock available'
        stock = 'N/A'

        return stock, stockSortValue, stockTtl
    end

    local stockSortValue = 0
    local stockTtl = ''
    local stockNum = to_number(stock)
    if not stockNum then
        stock = editbtn -- If stock can't be converted to a number it will default to the edit button
        return editbtn, stockSortValue, stockTtl
    end

    if isPackOf then
        local packNum = to_number(storeLine['pack_amount'], 0)
        local total = stockNum * packNum
        stockSortValue = total
        stockTtl = commas(stockNum) .. ' packs of ' .. commas(packNum)
        stock = commas(total)
    else
        stockSortValue = stockNum
        stockTtl = commas(stockNum)
        stock = commas(stockNum)
    end

    if storeLine['store_stock_unique'] then
        if stockNum == 1 then
            stockTtl = 'Available if not owned'
            stock = '<small>Unique</small>'
        else
            stockTtl = 'Base stock of ' .. stock .. ' if not owned'
            stock = stock .. ' <small>(unique)</small>'
        end
    end

    if historic then
        stockSortValue = stockSortValue * -1
    end

    return stock, stockSortValue, stockTtl
end

local function convertSellPrice(storeLine, currency, isPackOf, historic, editbtn)
    -- sellValue
    local bucketSellPrice = storeLine['store_sell_price']
    if bucketSellPrice == nil then
        local sellValue = {}
        local sellValueDisp = editbtn
        local sellSortValue = -2
        local sellTtl = nil
        return sellValue, sellValueDisp, sellSortValue, sellTtl
    end

    local sellPrice = mw.text.split(bucketSellPrice, '%s*;%s*')
    if #sellPrice == 1 then
        local sellValue = {}
        local sellValueDisp = string.lower(string.gsub(sellPrice[1], ',', ''))
        if sellValueDisp == 'free' or sellValueDisp == '0' or sellValueDisp == 'sample' then
            sellValue['coins'] = 0
            sellValueDisp = 'Free'
            local sellSortValue = 0
            local sellTtl = 'Free'
            return sellValue, sellValueDisp, sellSortValue, sellTtl
        elseif sellValueDisp == 'n/a' or sellValueDisp == 'not' then
            sellValueDisp = 'N/A'
            local sellSortValue = -1
            local sellTtl = 'This shop does not sell the item'
            return sellValue, sellValueDisp, sellSortValue, sellTtl
        end
    end

    local sellValue = {}
    local sellValueDisps = {}
    local sortValues = {}
    local titles = {}
    for i, value in ipairs(sellPrice) do
        local sellNum = to_number(value)
        if sellNum == nil then
            local sellValueDisp = editbtn
            local sellSortValue = -2
            local sellTtl = nil
            return {}, sellValueDisp, sellSortValue, sellTtl
        end

        local sellCurrency = getCurrency(currency, i, editbtn)
        local sellValueDisp
        local sortValue
        local title
        if isPackOf then
            local packNum = to_number(storeLine['pack_amount'], 0)
            local each = sellNum / packNum
            sellValue[sellCurrency] = each
            sellValueDisp = commas(each)
            sortValue = each
            title = 'Pack of ' .. commas(packNum) .. ' costs ' .. commas(sellNum) .. ' ' .. sellCurrency
        else
            sellValue[sellCurrency] = sellNum
            sellValueDisp = commas(sellNum)
            sortValue = sellNum
            title = commas(sellNum) .. ' ' .. sellCurrency
        end

        local currencyImg = currencyImage(sellCurrency, sortValue) or ''
        if (params.has_content(currencyImg)) then
            local currLink = sellCurrency:gsub("^%l", string.upper)
            currencyImg = string.format('<span class="inventory-image">[[File:%s|x22px|link=%s]]</span>', currencyImg, currLink)
            sellValueDisp = sellValueDisp .. ' ' .. currencyImg
        else
            sellValueDisp = sellValueDisp .. ' ' .. sellCurrency
        end

        if historic then
            sortValue = sortValue * 1000
        end

        table.insert(sellValueDisps, sellValueDisp)
        table.insert(sortValues, sortValue)
        table.insert(titles, title)
    end

    local sellValueDisp = mw.text.listToText(sellValueDisps, '; ', '; and ')
    local sellSortValue = table.concat(sortValues, ";")
    local sellTtl = mw.text.listToText(titles, '; ', '; and ')

    return sellValue, sellValueDisp, sellSortValue, sellTtl
end

local function convertBuyPrice(storeLine, currency, isPackOf, historic, editbtn)
    -- buyValue
    local bucketBuyPrice = storeLine['store_buy_price']
    if bucketBuyPrice == nil then
        local buyValue = editbtn
        local buySortValue = -2
        local buyTtl = nil
        return buyValue, buySortValue, buyTtl
    end

    local buyPrice = mw.text.split(bucketBuyPrice, '%s*;%s*')
    if #buyPrice == 1 then
        local buyValue = string.lower(string.gsub(buyPrice[1], ',', ''))
        if buyValue == 'n/a' or buyValue == 'not' then
            buyValue = 'N/A'
            local buySortValue = -1
            local buyTtl = 'The item cannot be sold to this shop'
            return buyValue, buySortValue, buyTtl
        end
    end

    local values = {}
    local sortValues = {}
    local titles = {}
    for i, value in ipairs(buyPrice) do
        local buyNum = to_number(value)
        if buyNum == nil then
            local buyValue = editbtn
            local buySortValue = -2
            local buyTtl = nil
            return buyValue, buySortValue, buyTtl
        end

        local buyCurrency = getCurrency(currency, i, editbtn)
        local buyValueDisp
        local sortValue
        local title
        if isPackOf then
            local packNum = to_number(storeLine['pack_amount'], 0)
            local each = buyNum / packNum
            buyValueDisp = commas(each)
            sortValue = each
            title = 'Pack of ' .. commas(packNum) .. ' costs ' .. commas(buyNum) .. ' ' .. buyCurrency
        else
            buyValueDisp = commas(buyNum)
            sortValue = buyNum
            title = commas(buyNum) .. ' ' .. buyCurrency
        end

        local currencyImg = currencyImage(buyCurrency, sortValue) or ''
        if (params.has_content(currencyImg)) then
            local currLink = buyCurrency:gsub("^%l", string.upper)
            currencyImg = string.format('<span class="inventory-image">[[File:%s|x22px|link=%s]]</span>', currencyImg, currLink)
            buyValueDisp = buyValueDisp .. ' ' .. currencyImg
        else
            buyValueDisp = buyValueDisp .. ' ' .. buyCurrency
        end

        if historic then
            sortValue = sortValue * 1000
        end

        table.insert(values, buyValueDisp)
        table.insert(sortValues, sortValue)
        table.insert(titles, title)
    end

    local buyValue = mw.text.listToText(values, '; ', '; and ')
    local buySortValue = table.concat(sortValues, ";")
    local buyTtl = mw.text.listToText(titles, '; ', '; and ')

    return buyValue, buySortValue, buyTtl
end

local function convertStoreLine(idx, itemName, storeLine, itemIsMembers)
    local isPackOf = itemName == storeLine['pack_of']

    local shopDisp, sellerNotes = convertShopDisplay(idx, storeLine, itemName, isPackOf)

    local editbtn = editbutton(storeLine.page_name)

    -- Retrieve shop info

    -- location
    local location = storeLine['store_location'] or editbtn
    if type(location) == 'table' and #location > 0 then
        location = table.concat(location, ', ')
    elseif type(location) == 'table' then
        location = editbtn
    end

    -- League Region
    local leagueRegion = storeLine['infobox_shop.league_region'] or storeLine['infobox_npc.league_region'] or ''

    -- Extract the string if it's a table
    leagueRegion = type(leagueRegion) == 'table' and table.concat(leagueRegion, ',') or leagueRegion

    -- Check for empty or missing region data
    if leagueRegion and leagueRegion ~= "" then
        leagueRegion = getLeagues().regionsForInfobox(leagueRegion)
    else
        leagueRegion = "N/A"
    end

    -- Historical?
    local historic = false
    if storeLine['is_historical'] then
        historic = true
    end

    -- members only?
    local stockMembers = convertStockMembers(storeLine, itemIsMembers, editbtn)

    local stock, stockSortValue, stockTtl = convertStock(storeLine, isPackOf, historic, editbtn)

    local currency = storeLine['store_currency']
    local currencyType = type(currency)
    if currencyType == 'string' and params.is_empty(currency) or
        currencyType == 'table' and params.table_is_empty(currency) or
        currency == nil then
        currency = editbtn
    end

    local sellValue, sellValueDisp, sellSortValue, sellTtl = convertSellPrice(storeLine, currency, isPackOf, historic, editbtn)

    local buyValue, buySortValue, buyTtl = convertBuyPrice(storeLine, currency, isPackOf, historic, editbtn)

    return {
        seller = shopDisp,
        sellerNotes = sellerNotes,
        location = location,
        members = stockMembers,
        stock = stock,
        stockTitle = stockTtl,
        sellValue = sellValue,
        stockSortValue = stockSortValue,
        sellValueDisp = sellValueDisp,
        sellTitle = sellTtl,
        sellSortValue = sellSortValue,
        buyValue = buyValue,
        buyTitle = buyTtl,
        buySortValue = buySortValue,
        historic = historic,
        leagueRegion = leagueRegion,
    }
end

function p.makeTable(item, shops, historical, vers, header)
    local res = mw.html.create()
    local restbl = res:tag('table')
    if header then
        restbl:tag('caption'):wikitext(header)
    end

    if historical then
        restbl:addClass('wikitable sortable autosort=1-a storeloc-hist align-center-3 align-right-4 align-right-5 align-center-6 sticky-header')
    else
        restbl:addClass('wikitable sortable autosort=1-a align-center-3 align-right-4 align-right-5 align-center-6 sticky-header')
    end

    -- Header Row
    local headerRow = restbl:tag('tr')

    headerRow:tag('th'):wikitext('Seller'):done()
        :tag('th'):wikitext('Location'):done()
        :tag('th'):wikitext('Number<br />in stock'):attr('data-sort-type', 'number'):done()
        :tag('th'):wikitext('Price<br/>sold at'):attr('data-sort-type', 'number'):done()
        :tag('th'):wikitext('Price<br/>bought at'):attr('data-sort-type', 'number'):done()
        :tag('th'):wikitext('Members'):done()
        :tag('th'):addClass('leagues-global-flag'):wikitext('League region')

    -- Create the rows for the output table
    local hasHistoric = false
    local hasRefs = false
    local hasSellValue = false
    local minSellValue = {}

    for _, shop in ipairs(shops) do
        local row = restbl:tag('tr')

        -- Seller Cell
        local sellerCell = row:tag('td')
        if shop.historic then
            hasHistoric = true
            row:addClass('store-hist')
            sellerCell:wikitext(shop.seller .. '<span title="Was previously sold by" style="cursor:help;"><small><b> †</b></small></span>')
        else
            sellerCell:wikitext(shop.seller)
        end

        if params.has_content(shop.sellerNotes) then
            hasRefs = true
            sellerCell:wikitext(' ' .. shop.sellerNotes)
        end

        -- Track sell prices
        if shop.sellValueDisp ~= 'N/A' and (shop.stock ~= 'N/A' and shop.stock ~= '0') then
            hasSellValue = true
            for currency, value in pairs(shop.sellValue) do
                local prevSellValue = minSellValue[currency]
                if prevSellValue == nil then
                    minSellValue[currency] = value
                elseif value > 0 then
                    minSellValue[currency] = math.min(value, prevSellValue)
                end
            end
        end

        -- Location
        row:tag('td'):wikitext(shop.location)

        -- Number in Stock
        local stockCell = row:tag('td')
            :css('cursor', 'help')
            :attr('data-sort-value', shop.stockSortValue)
            :attr('title', shop.stockTitle)
            :wikitext(shop.stock)
        if shop.stock == 'N/A' or shop.stock == '0' then
            stockCell:addClass('table-na'):css('text-align', 'center')
        end

        -- Price Sold At
        local sellCell = row:tag('td')
            :css('cursor', 'help')
            :attr('data-sort-value', shop.sellSortValue)
            :attr('title', shop.sellTitle)
            :wikitext(shop.sellValueDisp)
        if shop.sellValueDisp == 'N/A' then
            sellCell:addClass('table-na'):css('text-align', 'center')
        end

        -- Price Bought At
        local buyCell = row:tag('td')
            :css('cursor', 'help')
            :attr('data-sort-value', shop.buySortValue)
            :attr('title', shop.buyTitle)
            :wikitext(shop.buyValue)
        if shop.buyValue == 'N/A' then
            buyCell:addClass('table-na'):css('text-align', 'center')
        end

        -- Members Cell
        row:tag('td'):wikitext(shop.members)

        -- League Region Cell
        local leagueCell = row:tag('td')
            :addClass('leagues-global-flag')
            :css('vertical-align', 'middle')
            :css('text-align', 'left')
            :wikitext(shop.leagueRegion)
        if shop.leagueRegion == "N/A" then
            leagueCell:addClass('table-na')
        end
    end

    if hasSellValue then
        for currency, value in pairs(minSellValue) do
            local varname = 'ShopInfo_sell' .. currency .. vers
            var.vardefine(varname, value)
        end

        -- There are some "records" that exist in the form of recipes, which use {{Infobox Recipe}}
        res = res:wikitext("[[Category:Items sold by shops]]")
    end

    return tostring(res), hasRefs
end

local function getHistoricalNote(item)
    local caption = '<small>† Denotes discontinued or seasonal shops that stocked ' .. item .. '. For help, see [[Template:Shop locations list/FAQ|the FAQ]].</small>'
    local res = mw.html.create('p')
        :wikitext(caption)
        :done()

    return tostring(res)
end

function p.main(frame)
    local args = frame:getParent().args
    local item = args[1] and mw.text.trim(args[1]) or mw.title.getCurrentTitle().text
    mw.log(string.format('Searching for shops that sell: %s', item))

    local historical = yesNo(args.historical or args.Historical or args[2]) or false

    local pageRequest = {
        limit = args.limit or 100,
        sort = args.sort,
        order = args.order,
        onlypacks = yesNo(args.onlypacks) or false,
        hidenotes = yesno(args.hidenotes, false),
    }

    local cleanedName = item
    local dropVers
    local hasvers = false
    if item then
        item = mw.ustring.gsub(item, '&#39;', "'")
        if item:match('%#') then
            cleanedName, dropVers = mw.ustring.match(item, '^(.-)%#([%w%s%(%)\']+)$')
            hasvers = true
        end
        if dropVers ~= nil and dropVers ~= '' then
            item = cleanedName .. '#' .. dropVers
        end
    else
        item = mw.title.getCurrentTitle().text
        cleanedName = item
    end

    local verscount = 0
    if args.versions then
        local versionsnum = to_number(args.versions)
        if versionsnum then
            verscount = math.floor(versionsnum)
        end
    end

    -- Create the header of the output
    local headerText = ""
    if historical then
        headerText = "<div class=\"seealso\">Note: As this item is no longer sold, this is a list of shops that previously sold it.</div>"
    end

    if verscount == 0 then
        local shops, shopsHistorical, shopsRestricted = p.getShops(item, pageRequest)

        if #shops == 0 and #shopsHistorical == 0 and #shopsRestricted == 0 then
            return ":''Failed to find shops with that item - ensure it is spelled correctly. (ERR: no results from Bucket)''[[Category:Empty shop lists]]"
        end

        local content = ''
        local hasRefs = false

        if #shops > 0 then
            local mainTbl, mainHasRefs = p.makeTable(cleanedName, shops, historical, 1)
            content = headerText .. mainTbl
            hasRefs = hasRefs or mainHasRefs
        end

        if #shopsRestricted > 0 then
            local restrictedTbl, restrictedHasRefs = p.makeTable(cleanedName, shopsRestricted, historical, '1nv', 'Shops in restricted locations')
            content = content .. restrictedTbl
            hasRefs = hasRefs or restrictedHasRefs
        end

        if #shopsHistorical > 0 then
            local historicalTbl, historicalHasRefs = p.makeTable(cleanedName, shopsHistorical, historical, '1h', 'Historical stocks in the shops')
            content = content .. historicalTbl .. getHistoricalNote(cleanedName)
            hasRefs = hasRefs or historicalHasRefs
        end

        if hasRefs then
            local refList = mw.getCurrentFrame():getParent():extensionTag('references', '', { group = REF_GROUP })
            if pageRequest.hidenotes then
                refList = '<div class="mw-collapsible mw-collapsed"><span style="font-weight:bold; display:inline-block;">Notes (expand →)<span class="mw-collapsible-toggle-placeholder"></span></span><div class="mw-collapsible-content">' .. refList .. '</div></div>'
            end

            content = content .. tostring(refList)
        end

        return content
    end

    local vers, res, emptyvers, rescount = 1, {}, {}, 0
    while vers <= verscount do
        local versname = cleanedName .. ' (' .. vers .. ')'
        local shops, shopsHistorical, shopsRestricted = p.getShops(versname, pageRequest)
        if #shops == 0 and #shopsHistorical == 0 and #shopsRestricted == 0 then
            table.insert(emptyvers, versname)
        else
            local headers = args.headers
            local headers_level = tonumber(args.headers_level) or 3
            local header_wikitext = string.rep("=", headers_level)
            if params.has_content(headers) then
                if string.lower(headers) == 'potion' or string.lower(headers) == 'potions' then
                    table.insert(res, string.format('%s%s dose%s', header_wikitext, vers, header_wikitext))
                else
                    table.insert(res, string.format('%s%s%s', header_wikitext, vers, header_wikitext))
                end
            else
                table.insert(res, string.format('%s%s%s', header_wikitext, versname, header_wikitext))
            end

            local hasRefs = false

            if #shops > 0 then
                local mainTbl, mainHasRefs = p.makeTable(cleanedName, shops, historical, 1)
                table.insert(res, mainTbl)
                hasRefs = hasRefs or mainHasRefs
            end

            if #shopsRestricted > 0 then
                local restrictedTbl, restrictedHasRefs = p.makeTable(cleanedName, shops, historical, vers .. 'nv', 'Shops in restricted locations')
                table.insert(res, restrictedTbl)
                hasRefs = hasRefs or restrictedHasRefs
            end

            if #shopsHistorical > 0 then
                local historicalTbl, historicalHasRefs = p.makeTable(cleanedName, shops, historical, vers .. 'h', 'Historical stocks in the shops')
                table.insert(res, historicalTbl .. getHistoricalNote(cleanedName))
                hasRefs = hasRefs or historicalHasRefs
            end

            if hasRefs then
                local refList = mw.getCurrentFrame():getParent():extensionTag('references', '', { group = REF_GROUP })
                if pageRequest.hidenotes then
                    refList = '<div class="mw-collapsible mw-collapsed"><span style="font-weight:bold; display:inline-block;">Notes (expand →)<span class="mw-collapsible-toggle-placeholder"></span></span><div class="mw-collapsible-content">' .. refList .. '</div></div>'
                end

                table.insert(res, refList)
            end

            rescount = rescount + 1
        end
        vers = vers + 1
    end

    local cats = ""
    if rescount == 0 then
        return ":''Failed to find shops for that item and versions - ensure it is spelled correctly and version count is correct. (ERR: no results from Bucket)''[[Category:Empty shop lists]]"
    end

    if #emptyvers > 0 then
        table.insert(res, 1, '')
        local str = string.format("The following versions have no shops: %s. This, and the following lists are auto-generated.", table.concat(emptyvers, ', '))
        table.insert(res, 1, str)
    end

    return headerText .. table.concat(res, '\n') .. cats
end

function p.getShops(itemName, pageRequest)
    mw.log('Querying for item info for ' .. itemName)

    local itemIsMembers = false
    local itemData = bucket('infobox_item')
        .select('is_members_only')
        .where('page_name', itemName)
        .run()

    if itemData and #itemData > 0 then
        itemIsMembers = itemData[1]['is_members_only'] == true
    end
    mw.log('Found that item membership is: ' .. tostring(itemIsMembers))

    local b = bucket('storeline')
        .select(
            'page_name_sub',
            'page_name',
            'sold_item',
            'sold_item_notes',
            'quantity',
            'pack_of',
            'pack_amount',
            'is_members_only',
            'store_stock',
            'store_stock_unique',
            'store_stock_infinite',
            'store_sell_price',
            'store_buy_price',
            'store_currency',
            'store_location',
            'infobox_shop.owner',
            'is_historical',
            'infobox_shop.league_region',
            'infobox_npc.page_name',
            'infobox_npc.league_region',
            'Category:New Varrock'
        )
        .join('infobox_shop', 'storeline.page_name_sub', 'infobox_shop.page_name_sub')
        .join('infobox_npc', 'storeline.page_name_sub', 'infobox_npc.page_name_sub')
        .where(bucket.Or({ 'sold_item', itemName }, { 'pack_of', itemName }))
        .orderBy('page_name_sub', 'asc')

    local storeLines = b.run()

    if storeLines == nil then
        error('The item "' .. itemName .. '" is not, and was never, sold in any shop, please check for typos[[Category:Empty shop lists]]', 0)
    end

    local shops = {}
    local shopsHistorical = {}
    local shopsRestricted = {}
    -- Loop over array of subobjects (items sold by shops)
    for idx, storeLine in pairs(storeLines) do
        local store = convertStoreLine(idx, itemName, storeLine, itemIsMembers)
        if storeLine['is_historical'] then
            table.insert(shopsHistorical, store)
        elseif storeLine['Category:New Varrock'] then
            table.insert(shopsRestricted, store)
        else
            table.insert(shops, store)
        end
    end

    return shops, shopsHistorical, shopsRestricted
end

return p
-- </nowiki>