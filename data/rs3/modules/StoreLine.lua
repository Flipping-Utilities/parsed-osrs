-- <nowiki>
require("Module:Mw.html extension")
require("strict")

local p = {}

local lang = mw.language.getContentLanguage()
local var = mw.ext.VariablesLua
local params = require('Module:Paramtest')
local defTo = params.default_to
local yesno = require('Module:Yesno')
local currency_image = require('Module:Currency Image')
local onmain = require('Module:Mainonly').on_main
local arr = require('Module:Array')
local skill_pics = require('Module:Skill clickpic')._main

local exchange = require('Module:Exchange')
local find_geprice = exchange._price
local find_gealch = exchange._highalch
local _gealch = '<span class="dropsline-gealch" style="margin-left:0.3em">[[File:High Level Alchemy icon.png|link=High Level Alchemy|frameless|20px]]</span>'
local _altval = '<span class="dropsline-altval" style="margin-left:0.3em">[[File:AltValue.png|link=|frameless|20px]]</span>'

local p2pIcon = '[[File:P2P icon.png|25px|frameless|link=Members|Members]]'
local f2pIcon = '[[File:F2P icon.png|25px|frameless|link=Free-to-play|Free-to-play]]'

local REF_GROUP = "s"

local _priceStrings = {
	sell = "Shop sells for %s each.",
	sellThreshold = "Shop sells at %s.",
	sellFree = "Free sample",
	buy = "Shop buys for %s each.",
	ge = "%s %s each",
	gePack = "%s %s per pack; this is the total for all the items in the pack",
	alch = "%s %s each; this is the high alchemy value as this item cannot be traded on the Grand Exchange.",
	alchPack = "%s %s per pack; this is the total high alchemy value of all the items in the pack as they cannot be traded on the Grand Exchange.",
	alt = "%s %s each; this item has a distinct value, even though it cannot be traded on the Grand Exchange or be alchemised.",
	geAlch = "%s %s each on the Grand Exchange, and %s %s each in high alchemy value",
	resale = "%s %s total",
	resaleNormalised = "%s coin%s per %s",
	resaleOne = "%s %s each. Infinite stock available",
	resaleError = "%s %s each. Error: Stock provided was not a number"
}

local function ref(content, name)
	if content == nil then
		return ""
	end

	return mw.getCurrentFrame():getParent():extensionTag('ref', content, { name = name, group = REF_GROUP })
end

local function help_text(text, title)
	text = text:gsub('"', '&quot;')
	return '<span class="hover-text noprint" title="' .. title .. '">' .. text .. '</span>'
end

local function to_number(arg, default)
	if arg == nil then
		return default
	end

	return tonumber(arg) or default
end

local function commas(n)
	if tonumber(n) then
		local x_good, x = pcall(lang.formatNum, lang, tonumber(n))
		if x_good then
			return x
		end
	end
	return n
end

local function splitArgs(value, separator, default)
	value = defTo(value, default)
	if value == nil then
		return nil
	end

	return mw.text.split(value, '%s*' .. separator .. '%s*')
end

-- function to get the currency image and name (singular vs plural)
local function currencyInfo(currency, price)
	local retcur

	-- body
	local clean = tonumber(price)
	if clean and clean ~= 1 then
		retcur = currency
	else
		local lowcur = string.lower(currency)
		if lowcur == 'pieces of eight' then
			retcur = 'piece of eight'
		elseif string.sub(lowcur, -1) == 's' then
			retcur = string.sub(currency, 1, -2)
		else
			retcur = currency
		end
	end

	local img = currency_image(currency, price)
	if img then
		img = '<span class="dropsline-altval" style="margin-left:0.3em">[[File:' .. img .. '|link=|frameless|20px]]</span>'
		return img, retcur, true
	else
		img = '<span class="dropsline-altval" style="margin-left:0.3em">' .. currency .. '</span>'
		return img, retcur, false
	end
end

local function itemHighlight(item, args)
	item.highlight = true
	if params.has_content(args.highlight) then
		item.highlight = yesno(args.highlight, true)
	end
end

local function itemPackNum(item, args)
	-- Check pack number
	local pack = defTo(args.pack, '')
	if pack == '' then
		return
	end

	item.pack = pack
	item.packQuantity = to_number(defTo(args.packquantity), 50)
end

local function itemPurchaseMethod(item, args)
	--- Purchase through right-click 'option' or dialogue options, no shop interface
	local option = defTo(args.option)
	if option ~= nil then
		item.option = option
	end

	-- Purchase only through dialogue options, no right-click 'option', no shop interface
	-- Based on dialogue options, usually bargaining
	local chat = defTo(args.chat)
	if chat ~= nil then
		item.chat = chat
	end
end

local function itemQuantity(item, args)
	local quantity = splitArgs(args.quantity, item.separator, '1') or {}

	local noted = {}
	if item.name ~= nil then
		for i, _ in ipairs(item.name) do
			local q = defTo(quantity[i], '1')
			if q:find('%(noted%)') then
				noted[i] = true
				q = mw.ustring.gsub(q, '%(noted%)', '')
			else
				noted[i] = false
			end

			quantity[i] = to_number(q, 1)
		end
	else
		quantity[1] = 1
	end

	item.hidequantity = yesno(args.hidequantity, false)
	item.quantity = quantity
	item.noted = noted
end

local function itemRandom(item, args)
	--- Purely random, no guaranteed
	--- Drop version bucket name
	local random = defTo(args.random)
	if random == nil then
		return
	end

	item.random = random
end

local function lower_equal(a, b)
	if a == b then
		return true
	elseif a == nil or b == nil then
		return false
	end

	return a:lower() == b:lower()
end

local function itemShowActual(item, args)
	item.showactual = yesno(var.var('storeShowActual', 'no'), false)
	if item.name == nil or item.displayName == nil then
		item.showactual = false
	elseif #item.name == 1 and lower_equal(item.displayName, item.name[1]) then
		item.showactual = false
	end
end

local function itemName(item, args)
	--- Name with page link
	--- Some items may be bundled with purchase
	--- For purchasable unlocks, upgrades, and rewards
	--- parameter: name (if a internal link is available), text (if there is no related article, and the shop page lacks the proper section)

	--- Name in plain text
	--- Suppress all other parameters
	local text = defTo(args.text, nil)
	if text ~= nil then
		item.text = text
	end

	local name = splitArgs(args.name, item.separator)
	if name == nil then
		--- name is a must in this case
		return
	end

	item.name = name

	if text ~= nil then
		return
	end

	--- Display name in plain text
	--- Only one name is accepted
	item.displayName = defTo(args.alt or args.displayname or name[1], nil)
end

local function itemSkillRequirement(item, args)
	-- Based on skill level
	-- The numbers of column shown
	item.skillColumns = to_number(var.var('skillColumns'), 0)

	-- The skill requirements set (may not show)
	local skills = {}

	local i = 1
	local column = args['skill' .. i]
	while column do
		local collc = string.lower(column)
		if not (collc == 'n/a' or collc == 'no') then
			local req = splitArgs(column, ',')

			if req ~= nil then
				local skill = defTo(req[1], nil)
				local level = to_number(req[2], nil)
				skills[i] = { name = skill, level = level }
			end
		end

		i = i + 1
		column = args['skill' .. i]
	end

	item.skills = skills
end

local function itemRequirements(item, args)
	item.requirementColumn = yesno(var.var('requirementColumn', 'no'), false)

	-- Based on quest condition
	item.quest = splitArgs(args.quest, item.separator)
	item.questPartial = splitArgs(args['quest-partial'], item.separator)
	item.questDuring = splitArgs(args['quest-during'], item.separator)
	item.questBefore = splitArgs(args['quest-before'], item.separator)

	item.storeQuest = splitArgs(var.var('storeQuest'), item.separator)
	item.storeQuestPartial = splitArgs(var.var('storeQuestPartial'), item.separator)
	item.storeQuestDuring = splitArgs(var.var('storeQuestDuring'), item.separator)
	item.storeQuestBefore = splitArgs(var.var('storeQuestBefore'), item.separator)

	-- Based on achievement condition, including area tasks
	item.achievement = splitArgs(args.achievement, item.separator)
	item.achievementBefore = splitArgs(args['achievement-before'], item.separator)
	item.storeAchievement = splitArgs(var.var('storeAchievement'), item.separator)
	item.storeAchievementBefore = splitArgs(var.var('storeAchievementBefore'), item.separator)

	-- Based on purchased item, purchasable unlocks, upgrades, and rewards
	item.itemPurchased = splitArgs(args.purchased, item.separator)
	item.storeItemPurchased = splitArgs(var.var('storeItemPurchased'), item.separator)

	-- Based on obtained item, e.g. mask of gu, dungeoneering outfit piece
	item.itemObtained = splitArgs(args.obtained, item.separator)
	item.storeItemObtained = splitArgs(var.var('storeItemObtained'), item.separator)

	-- Based on carrying item in the backpack, e.g. logs for campfire
	item.itemCarrying = splitArgs(args.carrying, item.separator)
	item.itemCarryingQty = splitArgs(args['carrying-quantity'], item.separator)
	item.storeItemCarrying = splitArgs(var.var('storeItemCarrying'), item.separator)

	-- Based on equipped item, e.g. ring of charos
	item.itemEquipped = splitArgs(args.equipped, item.separator)
	item.storeItemEquipped = splitArgs(var.var('storeItemEquipped'), item.separator)
end

local function itemMiscRequirements(item, args)
	local misc = {}

	-- Miscellaneous requirements
	local miscArg = defTo(args.misc)
	if miscArg ~= nil then
		misc[1] = miscArg
	end

	local i = 1
	miscArg = defTo(args['misc' .. i])
	while miscArg do
		table.insert(misc, miscArg)

		i = i + 1
		miscArg = defTo(args['misc' .. i])
	end

	item.misc = misc

	local storeMisc = defTo(var.var('storeMisc'))
	if storeMisc ~= nil then
		item.storeMisc = storeMisc
	end
end

local function itemImage(item, args)
	local name = item.name and item.name[1] or nil
	-- Use 'File:<name>.png' if no image param
	-- Use 'File:<image>' if image param; image param will include extension
	local image_n = defTo(args.image, (name or item.text) .. '.png')
	if image_n:lower() == 'no' then
		item.image = ''
		return
	end

	image_n = mw.ustring.gsub(image_n, '#.+$', '.png')

	-- If no size given in image param, enforce max dimensions of 32x32px
	local max_dims = ''
	if not (image_n and image_n:match('|.-px')) then
		max_dims = '|frameless|32x32px'
	end

	if params.is_empty(name) then
		item.image = mw.ustring.format('[[File:%s|link=|alt=Stock of %s%s]]',
			image_n, item.displayName or item.text, max_dims)
	else
		item.image = mw.ustring.format('[[File:%s|link=%s|alt=Stock of %s%s]]',
			image_n, name, item.displayName or name, max_dims)
	end
end

local function itemGemwName(item, args)
	local gemwName = splitArgs(args.gemwname or args.pack, item.separator) or {}

	if item.name ~= nil then
		for i, name in ipairs(item.name) do
			local gn = defTo(gemwName[i])
			if gn == nil then
				gemwName[i] = name
			else
				local snlc = gn:lower()
				if snlc == 'none' or snlc == 'n/a' then
					gemwName[i] = nil
				end
			end
		end
	end

	item.gemwName = gemwName
end

local function cleanBucketName(name)
	local cleanedName, dropVers
	-- Remove version number from potions, enchanted jewellery, waterskins etc for bucket
	if name:match(' %(%d%)$') then
		cleanedName, dropVers = mw.ustring.match(name, '^(.-) (%(%d%))$')
	elseif name:match('%#') then
		cleanedName, dropVers = mw.ustring.match(name, '^(.-)%#([%w%s%(%)_,\']+)$')
	else
		cleanedName = mw.ustring.gsub(name, ' %(%d%)$', '')
		dropVers = ''
	end

	cleanedName = mw.text.trim(cleanedName)
	dropVers = mw.text.trim(dropVers)

	if dropVers ~= '' then
		-- get subobject instead
		return cleanedName .. '#' .. dropVers
	else
		return cleanedName
	end
end

local function itemBucketName(item, args)
	local bucketname = splitArgs(args.bucketname, item.separator) or {}

	for i, name in ipairs(item.gemwName) do
		local sn = defTo(bucketname[i])
		if sn == nil then
			bucketname[i] = cleanBucketName(name)
		else
			local snlc = sn:lower()
			if snlc == 'none' or snlc == 'n/a' then
				bucketname[i] = nil
			end
		end
	end

	item.bucketname = bucketname
end

local function itemCurrency(item, args)
	local currency = defTo(args.currency, var.var('currency', ''))
	if currency == '' then
		currency = 'coins'
	end

	item.currency = splitArgs(currency, item.separator)
end

local function itemStock(item, args)
	local stock = defTo(args.stock, '')
	stock = mw.ustring.lower(string.gsub(stock, ',', ''):gsub('%s', ''))
	item.stock = stock

	-- Stock display
	item.infStock = false
	item.stockNa = false
	if stock == '∞' or stock == 'inf' or stock == 'infinite' then
		item.stockSort = 'Infinity'
		item.stockTitle = 'Infinite available'
		item.stockDisp = '<span style="font-size:120%">∞</span>'
		item.infStock = true
		return
	elseif stock == 'n/a' then
		item.stockSort = 0
		item.stockTitle = 'No stock available'
		item.stockDisp = '<small>N/A</small>'
		item.stockNa = true
		return
	elseif stock == 'unique' then
		item.stockSort = 1
		item.stockNum = 1
		item.stockLimit = true
		item.stockTitle = 'Available if not owned'
		item.stockDisp = '<small>Unique</small>'
		return
	elseif mw.ustring.find(stock, '%(unique%)') ~= nil then
		stock = mw.ustring.gsub(stock, '%(unique%)', '')
		local stockNum = tonumber(stock)
		if stockNum ~= nil then
			item.stockNum = stockNum
			item.stockLimit = true
			item.stockTitle = 'Base stock of ' .. stock .. ' if not owned'
			item.stockDisp = commas(item.stockNum) .. ' <small>(unique)</small>'
			return
		end
	elseif stock == '0' then
		item.stockNa = true
	end

	item.stockNum = tonumber(stock)
	if item.stockNum then
		item.stockSort = stock
		item.stockTitle = 'Base stock of ' .. stock
		item.stockDisp = commas(item.stockNum)
	else
		item.stockSort = -1
		item.stockTitle = 'Invalid stock of ' .. stock .. 'was provided'
		item.stockDisp = '<span style="color:#FF0000; border-bottom:1px dashed; font-weight:bold">Error</span>[[Category:Pages with shop stock errors]]'
	end
end

local function itemPrice(value)
	local num = tonumber(value)
	if num ~= nil then
		return num
	end

	local val = yesno(value, value)
	if not val then
		return 'not'
	else
		val = string.lower(val)
		if val == 'not sold' or
			val == 'not bought' or
			val == 'none' or
			val == 'n/a' then
			return 'not'
		elseif val == 'free' then
			return 'free'
		end
	end

	return value
end

local function itemInvalidSell(item)
	item.sell = {}
	item.sellSort = 'Infinity'
	item.sellTitle = 'Sell price entered is invalid or none was given.'
	item.sellDisp = '<span style="color:#FF0000; border-bottom:1px dashed; font-weight:bold">Error</span>[[Category:Pages with shop stock errors]]'
end

local function itemSellMods(args, separator)
	local sellmods = splitArgs(var.var('sellmods'), separator)
	if sellmods == nil then
		return nil, nil
	end

	local sellmodRoundings = splitArgs(var.var('sellmodRoundings'), separator) or {}

	for i, sellmod in ipairs(sellmods) do
		local storemod = to_number(sellmod, 1)
		local argmod = args['sellmod' .. i]

		if argmod then
			sellmods[i] = to_number(argmod, storemod)
		else
			sellmods[i] = storemod
		end

		local argmodRounding = args['sellmod' .. i .. 'round']
		if params.has_content(argmodRounding) then
			sellmodRoundings[i] = argmodRounding:lower()
		elseif sellmodRoundings[i] == nil then
			sellmodRoundings[i] = 'ceil'
		end
	end

	return sellmods, sellmodRoundings
end

local function itemSell(item, args)
	-- Clean sell values
	local sellValues = splitArgs(args.sell, item.separator, '0') or {}
	for i, v in ipairs(sellValues) do
		sellValues[i] = itemPrice(v)
	end
	item.sell = sellValues

	-- Sell display
	item.sellSort = args.sellSort
	item.sellNowrap = false
	if #sellValues == 1 then
		local sellValue = sellValues[1]
		-- Free is free, 0 is 0, don't confuse
		if sellValue == 'free' then
			item.sellValue = 0
			item.sellSort = sellValue
			item.sellTitle = _priceStrings.sellFree
			item.sellDisp = 'Free'

			return
		elseif sellValue == 'not' then
			item.sellValue = 'not'
			item.sellSort = -1
			item.sellTitle = 'This item is not sold by this shop'
			item.sellDisp = 'Not sold'

			return
		elseif type(sellValue) ~= 'number' then
			itemInvalidSell(item)

			return
		end
	end

	-- Regular price
	local noWrap = false
	local displays = {}
	local titles = {}
	local currencies = {}
	local itemCurrencies = item.currency
	for i, sellValue in ipairs(sellValues) do
		if type(sellValue) ~= 'number' then
			item.sellValue = nil
			itemInvalidSell(item)
			return
		end

		local img, currency, nw = currencyInfo(itemCurrencies[i], sellValue)
		local disp = commas(sellValue) .. img
		local title = commas(sellValue) .. ' ' .. currency
		table.insert(displays, disp)
		table.insert(titles, title)
		table.insert(currencies, currency)
		noWrap = noWrap or nw
	end

	local sellDisp = mw.text.listToText(displays, '; ', '; and ')
	local sellPrice = mw.text.listToText(titles, '; ', '; and ')

	-- Manually unlock after reaching a certain currency threshold, no currency consumption
	-- parameter: threshold (set to yes)
	local threshold = yesno(defTo(args.threshold, var.var('thresholdUnlock', 'no')))
	if threshold then
		item.threshold = true
		item.sellDisp = sellDisp .. '<br><small>(not consumed)</small>'
		item.sellTitle = mw.ustring.format(_priceStrings.sellThreshold, sellPrice)
	else
		item.sellDisp = sellDisp
		item.sellTitle = mw.ustring.format(_priceStrings.sell, sellPrice)
	end

	item.sellValue = table.concat(sellValues, ";")
	item.sellCurrency = table.concat(currencies, ";")
	item.sellCurrencies = currencies

	item.sellSort = item.sellValue
	item.sellNowrap = noWrap
end

local function mathRound(num)
	if num >= 0 then
		return math.floor(num + 0.5)
	else
		return math.ceil(num - 0.5)
	end
end

local function itemDiscounted(item, args)
	local sellValues = item.sell
	if #sellValues == 0 then
		-- Skip processing the discounts
		item.discounted = {}
		return
	end

	-- Discounts
	local sellmods, sellmodRoundings = itemSellMods(args, item.separator)
	if sellmods == nil or sellmodRoundings == nil then
		item.discounted = {}
		return
	end
	item.sellmods = sellmods

	item.sellmodMiscs = splitArgs(var.var('sellmodMiscs'), item.separator)

	local itemCurrencies = item.currency

	-- Discounted price
	local discountPrices = {}
	for i, mod in ipairs(sellmods) do
		local noWrap = false
		local displays = {}

		local predefinedPrices = splitArgs(args['sellmod' .. i .. 'price'], item.separator) or {}

		local rounding
		if sellmodRoundings[i] == 'floor' then
			rounding = math.floor
		elseif sellmodRoundings[i] == 'round' then
			rounding = mathRound
		else
			rounding = math.ceil
		end

		local discountedPrices = {}
		for j, sellValue in ipairs(sellValues) do
			local predefinedPrice = predefinedPrices[j]
			local predefined
			if predefinedPrice ~= nil then
				predefined = itemPrice(predefinedPrice)
			end

			local price = predefined ~= nil and predefined or sellValue
			if price == 'free' then
				table.insert(discountedPrices, 0)
				table.insert(displays, 'Free')
			elseif price == 'not' then
				table.insert(discountedPrices, 'not')
				table.insert(displays, 'Not sold')
			else
				local discounted
				if predefined ~= nil then
					discounted = predefined
				else
					discounted = rounding(sellValue * mod)
				end

				local img, _, nw = currencyInfo(itemCurrencies[j], discounted)
				local disp = commas(discounted) .. img
				table.insert(discountedPrices, discounted)
				table.insert(displays, disp)
				noWrap = noWrap or nw
			end
		end

		local value = table.concat(discountedPrices, ";")
		discountPrices[i] = {
			value = value,
			disp = mw.text.listToText(displays, '; ', '; and '),
			sort = value,
			nowrap = noWrap
		}
	end

	item.discounted = discountPrices
end

local function itemInvalidBuy(item)
	item.buy = {}
	item.buySort = 'Infinity'
	item.buyTitle = 'Buy price entered is invalid or none was given.'
	item.buyDisp = '<span style="color:#FF0000; border-bottom:1px dashed; font-weight:bold">Error</span>[[Category:Pages with shop stock errors]]'
end

local function itemBuy(item, args)
	-- Clean buy values
	local buyTbl = splitArgs(args.buy, item.separator, '0') or {}
	for i, v in ipairs(buyTbl) do
		buyTbl[i] = itemPrice(v)
	end
	item.buy = buyTbl

	-- Buy display
	item.buySort = args.buySort
	item.buyNowrap = false

	if #buyTbl == 1 then
		local buyValue = string.lower(buyTbl[1])
		if buyValue == 'not' then
			item.buyValue = 'not'
			item.buySort = -1
			item.buyTitle = 'This item cannot be sold to this shop'
			item.buyDisp = 'Not bought'

			return
		end
	end

	local noWrap = false
	local disp = {}
	local titles = {}
	local currencies = {}
	for i, buyValue in ipairs(buyTbl) do
		if type(buyValue) ~= 'number' then
			item.buyValue = nil
			itemInvalidBuy(item)
			return
		end

		local bImg, bCur, bNw = currencyInfo(item.currency[i], buyValue)

		table.insert(disp, commas(buyValue) .. bImg)
		table.insert(titles, commas(buyValue) .. ' ' .. bCur)
		table.insert(currencies, bCur)
		noWrap = noWrap or bNw
	end

	item.buyTitle = mw.ustring.format(_priceStrings.buy, mw.text.listToText(titles, '; ', '; and '))
	item.buyDisp = mw.text.listToText(disp, '; ', '; and ')
	item.buyValue = table.concat(buyTbl, ";")
	item.buyCurrency = table.concat(currencies, ";")
	item.buyCurrencies = currencies

	item.buySort = item.buyValue
	item.buyNowrap = noWrap
end

local function itemAltValue(item, args)
	if args.altvalue == nil then
		return
	end

	item.altValue = tonumber(args.altvalue)
	item.altCurrency = defTo(args.altcurrency, '')
	if item.altCurrency == '' then
		item.altCurrency = 'coins'
	end
end

local function itemGemw(item, args)
	local gemw = yesno(args.gemw, true)
	if args.gemw == nil then
		gemw = yesno(var.var('gemw', 'yes'), true)
	end

	item.gemw = gemw
end

local function itemAlch(item, args)
	item.alch = yesno(args.alch or 'yes', false)
end

local function lookupGemwValue(name)
	local has_geprice, geprice_check = pcall(find_geprice, name)
	if not has_geprice then
		return nil
	end

	return geprice_check
end

local function lookupAlchValue(name, bucketname, gemw)
	-- Test for existance of alch value
	if gemw then
		-- does not have no-ge override
		-- lookup in GEMW
		local hasgealch, gealchval = pcall(find_gealch, name)
		-- alch is not disabled
		if hasgealch then
			if gealchval > -1 then
				return tonumber(gealchval)
			end
		end
	end

	local data = bucket('infobox_item')
		.select('high_alchemy_value')
		.where(bucket.Or({ 'item_name', bucketname }, { 'item_name', name }, { 'page_name', name }))
		.where('high_alchemy_value', '!=', bucket.Null())
		.limit(1)
		.run()

	if #data > 0 then
		return data[1].high_alchemy_value
	else
		mw.log("StoreLine didn't find high alch value for:" .. bucketname)
	end

	return nil
end

local function itemGe(item)
	-- GE value and display
	if item.altValue ~= nil then
		local value = item.altValue
		item.itemValue = value
		item.geSort = value - 10e10

		local geImg, geCur, geNw = currencyInfo(item.altCurrency, value)
		item.geTtl = mw.ustring.format(_priceStrings.alt, commas(value), geCur)
		item.geDisp = commas(value) .. geImg .. _altval
		item.geNowrap = geNw
	elseif item.geValue == nil and item.alchValue == nil then
		-- No GE
		item.itemValue = nil
		item.geSort = '-Infinity'
		item.geTtl = 'Item cannot be sold or alchemised'
		item.geDisp = 'N/A'
		item.geNowrap = false
	elseif item.geValue ~= nil and item.alchValue == nil then
		local value = item.geValue
		item.itemValue = value
		item.geSort = value

		local titleTemplate = item.pack ~= nil and _priceStrings.gePack or _priceStrings.ge
		local geImg, geCur, geNw = currencyInfo(item.geCurrency, value)
		item.geTtl = mw.ustring.format(titleTemplate, commas(value), geCur)

		item.geDisp = commas(value) .. geImg
		item.geNowrap = geNw
	elseif item.geValue == nil and item.alchValue ~= nil then
		local value = item.alchValue
		item.itemValue = value
		item.geSort = value

		local titleTemplate = item.pack ~= nil and _priceStrings.alchPack or _priceStrings.alch
		local _, geCur, _ = currencyInfo(item.alchCurrency, value)
		item.geTtl = mw.ustring.format(titleTemplate, commas(value), geCur)
		item.geDisp = commas(value) .. _gealch
		item.geNowrap = true
	else
		local geValue = item.geValue
		local alchValue = item.alchValue
		item.itemValue = geValue + alchValue
		item.geSort = item.itemValue

		local geImg, geCur, _ = currencyInfo(item.geCurrency, geValue)
		local _, alchCurr, _ = currencyInfo(item.alchCurrency, alchValue)
		item.geTtl = mw.ustring.format(_priceStrings.geAlch, commas(geValue), geCur, commas(alchValue), alchCurr)
		item.geDisp = '<span class="white-space:nowrap">' .. commas(geValue) .. geImg ..
			'</span>; <span class="white-space:nowrap">' .. commas(alchValue) .. _gealch .. "</span>"
		item.geNowrap = false
	end
end

local function calculateNormalisedValue(value, sell, differentCurrency, item)
	local resale
	if not differentCurrency then
		resale = value - sell
		if item.stockNum and not item.infStock then
			resale = item.stockNum * resale
		end
	else
		resale = value / sell
		resale = math.floor((resale * 100) + 0.5) / 100
	end
	return resale
end

local function itemResale(item)
	item.resaleNowrap = false
	item.resaleValue = 0 -- initialise to avoid exceptions thrown on untradable items

	-- Resale value cell contents
	-- Resale = 0 if currencies don't match
	local resale
	local differentCurrency = false
	local multipleCurrency = #item.currency > 1
	local itemCurrency1 = item.currency[1]
	local itemSell1 = item.sell[1]

	if not multipleCurrency and type(itemSell1) == 'number' then
		if item.altValue ~= nil then
			differentCurrency = item.altCurrency ~= itemCurrency1
			resale = calculateNormalisedValue(item.altValue, itemSell1, differentCurrency, item)
			item.resaleValue = resale
		elseif item.geValue ~= nil or item.alchValue ~= nil then
			resale = 0
			differentCurrency = item.geCurrency ~= itemCurrency1

			if item.geValue ~= nil then
				resale = resale + calculateNormalisedValue(item.geValue, itemSell1, differentCurrency, item)
			end
			if item.alchValue ~= nil then
				resale = resale + calculateNormalisedValue(item.alchValue, itemSell1, differentCurrency, item)
			end
			item.resaleValue = resale
		end
	end

	if resale and differentCurrency then
		local sinImg, sinCur, sinNw = currencyInfo(itemCurrency1, 1)
		local resImg, _, resNw = currencyInfo('coins', resale)
		item.resaleSort = resale - 10e10
		item.resaleTtl = mw.ustring.format(_priceStrings.resaleNormalised, commas(resale), lang:plural(resale or 0, '', 's'), sinCur)
		item.resaleDisp = commas(resale) .. resImg .. '/' .. sinImg
		item.resaleNowrap = sinNw and resNw
	elseif resale and item.infStock then
		local resImg, resCur, resNw = currencyInfo(itemCurrency1, resale)
		item.resaleSort = 'Infinity'
		item.resaleTtl = mw.ustring.format(_priceStrings.resaleOne, commas(resale), resCur)
		item.resaleDisp = mw.ustring.format('<span style="font-size:120%%">∞</span> (%s)%s', commas(resale), resImg)
		item.resaleNowrap = resNw
	elseif resale and item.stockNum then
		local resImg, resCur, resNw = currencyInfo(itemCurrency1, resale)
		item.resaleSort = resale
		item.resaleTtl = mw.ustring.format(_priceStrings.resale, commas(resale), resCur)
		item.resaleDisp = commas(resale) .. resImg
		item.resaleNowrap = resNw
	elseif resale then
		local resImg, resCur, resNw = currencyInfo(itemCurrency1, resale)
		item.resaleSort = '-Infinity'
		item.resaleTtl = mw.ustring.format(_priceStrings.resaleError, commas(resale), resCur)
		item.resaleDisp = mw.ustring.format('<span style="color:#FF0000; border-bottom:1px dashed; font-weight:bold">%s%s</span>[[Category:Pages with shop stock errors]]', commas(resale), resImg)
		item.resaleNowrap = resNw
	elseif differentCurrency then
		item.resaleSort = '-Infinity'
		item.resaleTtl = 'Cost and value are in different currencies'
		item.resaleDisp = 'N/A'
	elseif multipleCurrency then
		item.resaleSort = '-Infinity'
		item.resaleTtl = 'Cost is in multiple currencies'
		item.resaleDisp = 'N/A'
	else
		item.resaleSort = '-Infinity'
		item.resaleTtl = 'Item is not tradeable or alchable and no value was provided'
		item.resaleDisp = 'N/A'
	end
end

local function itemGeAndResale(item, args)
	itemAltValue(item, args)

	if item.altValue == nil then
		itemGemw(item, args)
		itemAlch(item, args)

		-- Lookup GE price
		local geValue
		local alchValue
		for i, name in ipairs(item.gemwName) do
			-- Test for existance of alch value
			if item.gemw then
				local value = lookupGemwValue(name)
				if value ~= nil then
					-- has a alch value from GEMW
					value = value * item.quantity[i]

					if item.pack ~= nil then
						value = value * tonumber(item.packQuantity)
					end
				end

				if geValue == nil then
					geValue = value
				else
					geValue = geValue + value
				end
			elseif item.alch then
				local value = lookupAlchValue(name, item.bucketname[i])
				if value ~= nil then
					-- has a alch value from GEMW
					value = value * item.quantity[i]

					if item.pack ~= nil then
						value = value * tonumber(item.packQuantity)
					end
				end

				if alchValue == nil then
					alchValue = value
				elseif value ~= nil then -- alchValue ~= nil
					alchValue = alchValue + value
				end
			end
		end

		item.geValue = geValue
		item.geCurrency = 'coins'
		item.alchValue = alchValue
		item.alchCurrency = 'coins'
	end

	if not item.hidege then
		itemGe(item)
	end

	if not item.hideresale then
		itemResale(item)
	end
end

local function itemIronmen(item, args)
	local ironmen = defTo(args.ironmen)
	if ironmen ~= nil then
		ironmen = ironmen:lower()
		if ironmen == 'only' then
			item.ironmen = 'only'
		else
			item.ironmen = yesno(ironmen)
		end
	else
		local storeIronmen = defTo(var.var('storeIronmen'))
		if storeIronmen == 'only' then
			item.ironmen = 'only'
		else
			item.ironmen = yesno(storeIronmen)
		end
	end

	item.hideironmen = yesno(var.var('hideIronmen', 'yes'), true)
end

local function itemId(item, args, tableId)
	local id = defTo(args.id or args.displayname or args.name, nil)
	item.id = id
	item.postfix = tableId .. (id or 'nid') .. (item.variant or 'nv') .. (item.stock or 'nstck') .. ' ' .. (item.sellValue or 'ns') .. ' ' .. (item.sellCurrency or 'nsc') .. (item.buyValue or 'nb') .. ' ' .. (item.buyCurrency or 'nbc')
end

local function itemDropLevelVar(item, args)
	local dropversion = defTo(args.dropversion)

	local dropLevelVar, dropStoreCurrencyVar
	if dropversion ~= nil then
		dropLevelVar = string.format("DropLevel_%s_%s", 'store', dropversion)
		dropStoreCurrencyVar = string.format("DropStoreCurrency_%s_%s", 'store', dropversion)
	elseif item.random ~= nil then
		dropLevelVar = string.format("DropLevel_%s_%s", 'store', item.random)
		dropStoreCurrencyVar = string.format("DropStoreCurrency_%s_%s", 'store', item.random)
	else
		return
	end

	var.vardefine(dropLevelVar, item.sellValue)
	var.vardefine(dropStoreCurrencyVar, item.sellCurrency)
end

local function itemNameNotes(item)
	local nameNotes = {
		skills = item.skills,
		random = item.random,
		piece = item.piece,
		variant = item.variant,
		recipe = item.recipe,
		feature = item.feature,
		option = item.option,
		chat = item.chat,
		quest = {
			after = { item = item.quest, store = item.storeQuest },
			partial = { item = item.questPartial, store = item.storeQuestPartial },
			during = { item = item.questDuring, store = item.storeQuestDuring },
			before = { item = item.questBefore, store = item.storeQuestBefore },
		},
		achievement = {
			after = { item = item.achievement, store = item.storeAchievement },
			before = { item = item.achievementBefore, store = item.storeAchievementBefore },
		},
		item = {
			purchased = { item = item.itemPurchased, store = item.storeItemPurchased },
			obtained = { item = item.itemObtained, store = item.storeItemObtained },
			carrying = { item = item.itemCarrying, quantity = item.itemCarryingQty, store = item.storeItemCarrying },
			equipped = { item = item.itemEquipped, store = item.storeItemEquipped },
		},
		misc = { item = item.misc, store = item.storeMisc },
		threshold = item.threshold,
	}

	-- add if it is a special value
	if item.ironmen == 'only' or item.ironmen == false then
		nameNotes.ironmen = item.ironmen
	end

	return mw.text.killMarkers(mw.text.jsonEncode(nameNotes))
end

local function itemSellModNotes(item)
	local values = {}
	local miscs = {}

	local itemValue = item.sellValue
	local itemMiscs = item.sellmodMiscs

	for i, dis in ipairs(item.discounted) do
		local value = dis.value

		-- Avoid inserting 'non-discounted' prices
		if value ~= itemValue then
			table.insert(values, value)
			table.insert(miscs, itemMiscs[i])
		end
	end

	local sellModNotes = {
		values = values,
		miscs = miscs,
	}

	return mw.text.killMarkers(mw.text.jsonEncode(sellModNotes))
end

function p.main(frame)
	local args = frame:getParent().args

	-- legacy uppercase parameters
	args.historical = args.historical or args.Historical
	args.name = args.name or args.Name
	args.rawname = args.name or args.Name
	args.displayname = args.displayname or args.DisplayName
	args.pack = args.pack or args.Pack
	args.packquantity = args.packquantity or args.packnum or args.packNum or args.PackNum
	args.currency = args.currency or args.Currency
	args.stock = args.stock or args.Stock
	args.sell = args.sell or args.Sell
	args.buy = args.buy or args.Buy
	args.image = args.image or args.Image
	args.altvalue = args.altvalue or args.AltValue
	args.altcurrency = args.altcurrency or args.AltCurrency
	args.description = args.description or args.Description
	args.members = args.members or args.Members

	return p._main(args)
end

function p._main(args)
	local item = {}

	item.separator = defTo(args.separator, defTo(var.var('separator'), ';'))
	--------------------------
	--- Per stock specific
	--------------------------
	itemName(item, args)
	itemGemwName(item, args)
	itemBucketName(item, args)
	itemQuantity(item, args)

	item.rawname = args.rawname or args.name

	itemRandom(item, args)

	--- Random piece of the group/collection, usually guaranteed, no more purchases after owning
	item.piece = defTo(args.piece)

	--- Show actual item of the pieces
	itemShowActual(item, args)

	--- Item variant need to be noted
	item.variant = defTo(args.variant)

	--- The stock line is converted to a recipe shown on the product page
	item.recipe = defTo(args.recipe)

	--- It is a feature upgrade, no items are gained or lost
	item.feature = yesno(args.feature, false)

	--- Item pack, check pack number
	itemPackNum(item, args)

	--- Default type, common shop interface type, may require a dialogue, may need to find it in the interface or outside the game
	itemPurchaseMethod(item, args)

	itemSkillRequirement(item, args)
	itemRequirements(item, args)
	itemMiscRequirements(item, args)

	--------------------------
	--- Image column
	--------------------------

	item.hideimage = yesno(var.var('hideImage', 'no'), false)
	itemImage(item, args)

	--------------------------
	--- Currency column
	--------------------------

	--- Correct currencies
	itemCurrency(item, args)

	--------------------------
	--- Stock column
	--------------------------

	item.hidestock = yesno(var.var('hideStock', 'no'), false) or yesno(var.var('upgradeStore', 'no'), false)
	itemStock(item, args)

	--------------------------
	--- Sell and buy columns
	--------------------------

	item.hidesell = yesno(var.var('hideSell', 'no'), false)
	itemSell(item, args)
	itemDiscounted(item, args)

	item.hidebuy = yesno(var.var('hideBuy', 'no'), false)
	itemBuy(item, args)

	--------------------------
	--- GE and resale columns
	--------------------------

	item.hidege = yesno(var.var('hideGE', 'no'), false)
	item.hideresale = yesno(var.var('hideResale', 'no'), false)

	if not item.hidege or not item.hideresale then
		itemGeAndResale(item, args)
	end

	--------------------------
	--- Description column
	--------------------------

	--- Show description or not
	item.showdescriptions = yesno(var.var('showDescription', 'no'), false)

	--- Description text
	item.description = defTo(args.description or args.Description, '')
	item.unlockHint = defTo(args['unlock-hint'])
	item.keywords = table.concat(splitArgs(defTo(args.keywords), item.separator) or {}, "; ")

	--------------------------
	--- Members column
	--------------------------

	if args.members ~= nil then
		item.members = yesno(defTo(args.members))
	else
		local storeMembers = defTo(var.var('storeMembers'))
		if storeMembers ~= nil then
			item.members = yesno(storeMembers)
		end
	end

	item.hidemembers = yesno(var.var('hideMembers', 'yes'), true)

	--------------------------
	--- Ironmen column
	--------------------------

	itemIronmen(item, args)

	--------------------------
	--- Custom column
	--------------------------

	local function addCustomColumns(self)
		local extraColumns = to_number(var.var('extraColumns'), 0)
		if extraColumns < 1 then
			return self
		end

		for i = 1, extraColumns do
			local column = args['column' .. i]
			if column == 'N/A' or column == nil then
				self:tag('td')
					:attr('data-sort-value', 0)
					:attr('class', 'table-na')
					:wikitext('<small>N/A</small>')
					:done()
			else
				self:tag('td')
					:wikitext(column)
					:css {
						['max-width'] = '70ch',
					}
					:done()
			end
		end

		return self
	end

	--------------------------
	--- Shop Bucket features
	--- not per stock
	--------------------------
	local useBucket
	if item.recipe ~= nil then
		useBucket = false
	elseif args.bucket ~= nil then
		useBucket = false
	else
		useBucket = yesno(var.var('bucket', 'yes'), true)
	end

	local bucketVersions = arr.filter(splitArgs(args.version, ',', var.var('storeVersion', '')), function(e) return e ~= nil and e ~= '' end)

	--------------------------
	--- Cosmetic features
	--------------------------
	local tableId = var.var('storeTableId')

	itemHighlight(item, args)
	itemId(item, args, tableId)
	itemDropLevelVar(item, args)

	local historical = defTo(args.historical)
	if historical ~= nil then
		item.historical = yesno(historical, false)
	else
		item.historical = yesno(var.var('historical', 'no'), false)
	end

	local deprecated = false
	if defTo(args.namenotes) ~= nil then
		deprecated = true
	end
	if defTo(args.buynotes) ~= nil then
		deprecated = true
	end
	if defTo(args.sellnotes) ~= nil then
		deprecated = true
	end

	--------------------------
	--- Display
	--------------------------
	local ret = p.display(item, tableId, addCustomColumns)

	local unrecognizedShopVersionCategory = false
	if useBucket and onmain() then
		unrecognizedShopVersionCategory = p.addBucket(item, bucketVersions)
	end

	return tostring(ret)
		.. (deprecated and '[[Category:Pages with deprecated parameters]]' or '')
		.. (unrecognizedShopVersionCategory and '[[Category:Uses unrecognized shop version]]' or '')
end

local function itemNotes(notes, prefix, item)
	local refs = ''
	for n, note in ipairs(notes) do
		local varname = 'storeRef_' .. prefix .. mw.text.killMarkers(note)
		if var.varexists(varname) then
			refs = refs .. ref('', var.var(varname))
		else
			local refname = item.postfix .. '_' .. n
			var.vardefine(varname, refname)
			refs = refs .. ref(note, refname)
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

local function insertRequirement(requirementItems, item)
	-- Based on quest condition
	formatRequirement(requirementItems, item.quest, 'Available after completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.questPartial, 'Available after partial completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.questDuring, 'Available during %s.', '[[%s]]')
	formatRequirement(requirementItems, item.questBefore, 'Available before completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.achievement, 'Available after completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.achievementBefore, 'Available before completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.itemPurchased, 'Available after having purchased %s.', '[[%s]]')
	formatRequirement(requirementItems, item.itemObtained, 'Available after having obtained %s.', '[[%s]]')
	formatRequirementWithQty(requirementItems, item.itemCarrying, item.itemCarryingQty, 'Available while carrying %s.', '[[%s]]%s')
	formatRequirement(requirementItems, item.itemEquipped, 'Available while equipping %s.', '[[%s]]')
end

local function insertStoreRequirement(requirementItems, item)
	formatRequirement(requirementItems, item.storeQuest, 'Available after completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.storeQuestPartial, 'Available after partial completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.storeQuestDuring, 'Available during %s.', '[[%s]]')
	formatRequirement(requirementItems, item.storeQuestBefore, 'Available before completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.storeAchievement, 'Available after completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.storeAchievementBefore, 'Available before completion of %s.', '[[%s]]')
	formatRequirement(requirementItems, item.storeItemPurchased, 'Available after having purchased %s.', '[[%s]]')
	formatRequirement(requirementItems, item.storeItemObtained, 'Available after having obtained %s.', '[[%s]]')
	formatRequirement(requirementItems, item.storeItemCarrying, 'Available while carrying %s.', '[[%s]]')
	formatRequirement(requirementItems, item.storeItemEquipped, 'Available while equipping %s.', '[[%s]]')
end

function p.display(item, tableId, addCustomColumns)
	local ret = mw.html.create('tr')
		:addClassIf(not item.highlight, 'nohighlight')

	-- inventory image
	if not item.hideimage then
		ret:td {
			class = 'inventory-image',
			wikitext = item.image,
		}
	end

	-- item name
	-- no hideXXX parameter for the column that lists the actual items.
	local displayName = item.text or string.format('[[%s|%s]]', item.name[1], item.displayName)

	local shownActual = false
	if item.name ~= nil and #item.name > 1 then
		local names = {}
		for i, n in ipairs(item.name) do
			if not item.hidequantity then
				local q = item.quantity[i]
				table.insert(names, string.format('[[%s|%s]]&nbsp;&times;&nbsp;%s%s', n, n, commas(q), item.noted[i] and ' (noted)' or ''))
			else
				table.insert(names, string.format('[[%s|%s]]%s', n, n, item.noted[i] and ' (noted)' or ''))
			end
		end

		displayName = displayName .. string.format('<br><small>(Including %s)</small>', mw.text.listToText(names, '; ', '; and '))
		shownActual = true
	elseif not item.hidequantity and item.quantity[1] > 1 then
		if item.showactual then
			displayName = displayName .. string.format('<br><small>(Actual: %s&nbsp;&times;&nbsp;%s%s)</small>', item.name[1], commas(item.quantity[1]), item.noted[1] and ' noted' or '')
			shownActual = true
		else
			displayName = displayName .. string.format(' <small>(&times;&nbsp;%s%s)</small>', commas(item.quantity[1]), item.noted[1] and ' noted' or '')
		end
	elseif item.noted[1] then
		if item.showactual then
			displayName = displayName .. string.format('<br><small>(Actual: %s (noted))</small>', item.name[1])
			shownActual = true
		else
			displayName = displayName .. ' <small>(noted)</small>'
		end
	end

	if item.hidemembers and item.members ~= nil then
		if item.members then
			displayName = displayName .. '<br><small>(Members only)</small>'
		end
	end

	if item.random ~= nil then
		displayName = displayName .. '<br><small>(Random)</small>'
	end

	if item.recipe then
		displayName = displayName .. string.format('<br><small>(%s)</small>', item.recipe)
	end

	if item.piece ~= nil then
		displayName = displayName .. string.format('<br><small>(%s)</small>', item.piece)
	end

	if item.variant ~= nil then
		displayName = displayName .. string.format('<br><small>(%s)</small>', item.variant)
	end

	if item.feature then
		displayName = displayName .. '<br><small>(' .. help_text('Feature unlock', 'No items are gained, or lost.') .. ')</small>'
	end

	if not shownActual and item.showactual then
		displayName = displayName .. string.format('<br><small>(Actual: %s)</small>', item.name[1])
	end

	if item.option then
		-- sprite 18903 left
		-- sprite 12996 left-large
		-- sprite 18906 right
		-- sprite 12997 right-large
		displayName = displayName .. '<br>(<i title="Options" style="padding: 0 1px">[[File:Default cursor.png|alt=Choose Option|link=Choose Option|x13px]]</i> ' .. help_text(item.option, 'The \'' .. item.option .. '\' option') .. ')'
	end

	if item.chat then
		displayName = displayName .. '<br>' .. item.chat
	end

	-- Requirements
	do
		local notes = {}

		if item.skillColumns < 1 then
			local skills = item.skills
			local skillLen = arr.len(skills)
			if skillLen > 0 then
				local skillNames = {}
				for i = 1, skillLen do
					local skill = skills[i]
					if skill ~= nil then
						table.insert(skillNames, string.format('level %s [[%s]]', skill.level, skill.name))
					end
				end
				table.insert(notes, string.format('Requires %s to unlock.', mw.text.listToText(skillNames, ', ', ', and ')))
			end
		end

		if not item.requirementColumn then
			insertStoreRequirement(notes, item)

			if item.storeMisc ~= nil then
				arr.insert(notes, item.storeMisc, true)
			end

			insertRequirement(notes, item)

			if item.misc ~= nil then
				arr.insert(notes, item.misc, true)
			end
		end

		if item.hideironmen and item.ironmen ~= nil then
			if item.ironmen == 'only' then
				table.insert(notes, 'Only available to [[Ironman Mode]] accounts.')
			elseif item.ironmen == true then
				table.insert(notes, 'Available to [[Ironman Mode]] accounts.')
			elseif item.ironmen == false then
				table.insert(notes, 'Not available to [[Ironman Mode]] accounts.')
			end
		end

		if not item.showdescriptions then
			if params.has_content(item.unlockHint) then
				table.insert(notes, "''Unlock hint:'' " .. item.unlockHint)
			end

			if params.has_content(item.keywords) then
				table.insert(notes, "''Keywords:'' " .. item.keywords)
			end
		end

		displayName = displayName .. ' ' .. itemNotes(notes, tableId, item)
	end

	ret:td {
		class = 'item-col',
		wikitext = displayName,
		css = {
			['max-width'] = '36ch',
		},
	}:done()

	-- stock
	if not item.hidestock then
		ret:td {
			css = {
				cursor = 'help',
			},
			class = string.format('stock-col%s', item.stockNa and ' table-na' or ''),
			attr = {
				['data-sort-value'] = item.stockSort,
				['title'] = item.stockTitle,
			},
			wikitext = item.stockDisp,
		}
			:cssIf(item.stockNa, 'text-align', 'center'):done()
	end

	-- sell price
	if not item.hidesell then
		ret:td {
			css = {
				["white-space"] = item.sellNowrap and "nowrap" or nil,
				cursor = 'help',
			},
			class = 'sell-col ref-left',
			attr = {
				['data-sort-value'] = item.sellSort,
				["data-store-value"] = item.sellValue,
				["data-store-currency"] = item.sellCurrency,
				['title'] = item.sellTitle,
			},
			wikitext = item.sellDisp,
		}:done()

		for i, discountPrice in ipairs(item.discounted) do
			ret:td {
				css = {
					["white-space"] = discountPrice.sellNowrap and "nowrap" or nil,
				},
				class = 'sell-mod-col sell-mod-col' .. i .. ' ref-left',
				attr = {
					['data-sort-value'] = discountPrice.sort,
					["data-store-value"] = discountPrice.value,
					["data-store-currency"] = item.sellCurrency,
				},
				wikitext = discountPrice.disp,
			}:done()
		end
	end

	-- buy price
	if not item.hidebuy then
		ret:td {
			css = {
				["white-space"] = item.buyNowrap and "nowrap" or nil,
				cursor = 'help',
			},
			class = 'buy-col',
			attr = {
				['data-sort-value'] = item.buySort,
				["data-store-value"] = item.buyValue,
				["data-store-currency"] = item.buyCurrency,
				['title'] = item.buyTitle,
			},
			wikitext = item.buyDisp,
		}:done()
	end

	if not item.hidege then
		-- GE price
		ret:td {
			css = {
				["white-space"] = item.geNowrap and "nowrap" or nil,
				cursor = 'help'
			},
			class = string.format('ge-column%s', item.geDisp == 'N/A' and ' table-na' or ''),
			attr = {
				['data-sort-value'] = item.geSort,
				["data-store-value"] = item.geValue,
				["data-store-currency"] = item.geValue and "coins" or nil,
				['title'] = item.geTtl,
			},
			wikitext = item.geDisp,
		}
			:cssIf(item.geDisp == 'N/A', 'text-align', 'center'):done()
	end

	if not item.hideresale then
		-- resale value
		ret:td {
			css = {
				["white-space"] = item.resaleNowrap and "nowrap" or nil,
				cursor = 'help',
				display = 'table-cell' -- because I wanted to add class .coins
			},
			class = string.format('resale-col%s', item.resaleDisp == 'N/A' and ' table-na' or ''),
			attr = {
				['data-sort-value'] = item.resaleSort,
				["data-store-value"] = item.resaleValue,
				["data-store-currency"] = item.resaleValue and "coins" or nil,
				['title'] = item.resaleTtl,
			},
			wikitext = item.resaleDisp,
		}
			:cssIf(item.resaleDisp == 'N/A', 'text-align', 'center')
			:addClassIf(item.resaleDisp ~= 'N/A', 'coins')
			:addClassIf(item.resaleValue > 0, 'coins-pos')
			:addClassIf(item.resaleValue < 0, 'coins-neg'):done()
	end

	if not item.hidemembers then
		ret:td {
			class = 'members-col',
			wikitext = item.members and p2pIcon or f2pIcon,
		}:done()
	end

	if not item.hideironmen then
		local ironmenStatus
		local ironmenStatusNa = false
		if item.ironmen == 'only' then
			ironmenStatus = 'Only'
		elseif item.ironmen == true then
			ironmenStatus = 'Yes'
		elseif item.ironmen == false then
			ironmenStatus = 'No'
		else
			ironmenStatus = 'Unknown'
			ironmenStatusNa = true
		end

		ret:td {
			class = string.format('ironmen-col%s', ironmenStatusNa and ' table-na' or ''),
			wikitext = ironmenStatus,
		}
			:cssIf(ironmenStatusNa, 'text-align', 'center'):done()
	end

	-- Based on skill level
	if item.skillColumns > 0 then
		-- item.skill

		local skills = item.skills
		for i = 1, item.skillColumns do
			local skill = skills[i]
			if skill ~= nil then
				ret:td {
					class = 'skill-col',
					attr = {
						['data-sort-value'] = skill.level,
					},
					wikitext = skill_pics(skill.name, skill.level),
				}:done()
			else
				ret:td {
					class = 'skill-col table-na',
					attr = {
						['data-sort-value'] = 0,
					},
					css = {
						['text-align'] = 'center',
					},
					wikitext = 'N/A'
				}
			end
		end
	end

	if item.requirementColumn then
		local requirements = {}
		insertStoreRequirement(requirements, item)

		if item.storeMisc ~= nil then
			arr.insert(requirements, item.storeMisc, true)
		end

		insertRequirement(requirements, item)

		if item.misc ~= nil then
			arr.insert(requirements, item.misc, true)
		end

		ret:td {
			class = 'item-col',
			wikitext = table.concat(requirements, '<br>'),
		}:done()
	end

	-- description
	if item.showdescriptions then
		local description = item.description

		if params.has_content(item.unlockHint) then
			description = description .. "<br>''Unlock hint:'' " .. item.unlockHint
		end

		if params.has_content(item.keywords) then
			description = description .. "<br>''Keywords:'' " .. item.keywords
		end

		ret:td {
			class = 'description-col',
			css = {
				['min-width'] = '30ch',
				['max-width'] = '70ch',
			},
			wikitext = description,
		}:done()
	end

	ret:exec(addCustomColumns)
	--Add class if line but not table is historical
		:addClassIf(item.historical and not yesno(item.tempHistorical, false), 'storeline-hist')
	-- data-rowid attribute for lighttables
		:attrIf(params.has_content(item.id), 'data-rowid', item.id)

	return ret
end

--- Capitalizes the first letter of a string
-- @param str The string to capitalize
-- @return A new string with the first letter capitalized
local function uc_first(str)
	if not str or str == "" then
		return str
	end
	return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

function p.addBucket(item, bucketVersions)
	-- Bucket
	local bucketNameNotes = itemNameNotes(item)
	local bucketSellModNotes = itemSellModNotes(item)
	local stock_bucket = item.stockNum
	if item.stock == 'n/a' then
		stock_bucket = 'N/A'
	end

	local shopVersions = { 'DEFAULT' }
	if bucketVersions ~= nil and #bucketVersions > 0 then
		shopVersions = bucketVersions
	end

	local location = defTo(var.var('storeTableLocation'))
	local itemMembers = item.members or false

	local sourceNames = {}
	local membersValues = {}
	local locationsValues = {}
	local unrecognisedShopVersionCategory = false

	for _, shopVersion in ipairs(shopVersions) do
		local function getVersionedVar(pattern)
			local versionedVar = string.format(pattern, shopVersion)
			if not var.varexists(versionedVar) then
				if shopVersion ~= 'DEFAULT' then
					-- Fallback to 'DEFAULT' version
					versionedVar = string.format(pattern, 'DEFAULT')
				end

				if not var.varexists(versionedVar) then
					unrecognisedShopVersionCategory = true
				end
			end

			return versionedVar
		end

		local locationsVar = getVersionedVar("ShopInfo_location_%s")
		local membersVar = getVersionedVar("ShopInfo_members_%s")

		if shopVersion ~= 'DEFAULT' then
			table.insert(sourceNames, shopVersion)
		end

		local currentLocation
		if location == nil then
			currentLocation = var.var(locationsVar)
		else
			currentLocation = location
		end
		table.insert(locationsValues, currentLocation)

		local currentMembers = itemMembers or var.var(membersVar) or false
		table.insert(membersValues, currentMembers)
	end

	local bucket_sub = {
		-- add function to reduce image to File:Some name.png
		['sold_item_image'] = item.image,
		['sold_item_notes'] = bucketNameNotes,
		['store_stock'] = stock_bucket,
		['store_stock_unique'] = item.stockLimit,
		['store_sell_price'] = item.sellValue,
		['store_sell_mods'] = bucketSellModNotes,
		['store_buy_price'] = item.buyValue,
		['store_currency'] = item.currency,
	}

	if item.historical then
		bucket_sub['is_historical'] = true
	end

	if item.infStock then
		bucket_sub['store_stock_infinite'] = true
		bucket_sub['store_stock'] = nil
	end

	if item.pack ~= nil then
		bucket_sub['pack_amount'] = item.packQuantity

		if item.historical then
			bucket_sub['is_historical'] = true
		end
		bucket_sub['pack_of'] = item.pack
	end

	local sold_item_name = {}
	if item.rawname then
		sold_item_name = arr.map(mw.text.split(item.rawname, ';'), uc_first)
	else
		sold_item_name = { uc_first(item.text) }
	end

	for i, name in pairs(sold_item_name) do
		bucket_sub['sold_item'] = name
		bucket_sub['quantity'] = item.quantity[i]

		for j, _ in ipairs(shopVersions) do
			bucket_sub['store_location'] = locationsValues[j]

			-- If the value came from the DEFAULT var it might be a comma separated list
			if type(membersValues[j]) == 'string' then
				local members = mw.text.split(string.lower(membersValues[j] or ''), '%s*,%s*')
				if arr.any(members, 'no') then
					bucket_sub['is_members_only'] = false
				elseif arr.all(members, 'yes') then
					bucket_sub['is_members_only'] = true
				end
			else
				bucket_sub['is_members_only'] = membersValues[j]
			end

			local sourceName = sourceNames[j]
			bucket('storeline').sub(sourceName).put(bucket_sub)
		end
	end

	return unrecognisedShopVersionCategory
end

return p
-- </nowiki>