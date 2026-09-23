local p = {}

local hasc = require('Module:Paramtest').has_content
local itemstats = require('Module:FetchItemStats')
local yesno = require('Module:Yesno')
local lang = mw.language.getContentLanguage()
local GEPrice = require('Module:Exchange')._price

-- Parse item string and check if GIF icons are allowed
local function parseItem(ret, itemString, equipSlot, stats, quantity)
	local itemString = itemString
	local allowGif = false
	local itemName = ""

	-- Look for a ;g at the end of the string and separate them
	if hasc(itemString) then
		allowGif = itemString:sub(-2) == ";g"
		if allowGif then
			itemName = itemString:sub(0, -3)
		else
			itemName = itemString or ""
		end
	end

	return ret, itemName, allowGif, equipSlot, stats, quantity
end

-- formats a number to thousands/millions
function formatAmount(_x)
	local x = tonumber(_x) or 1
	if x < 100000 then
		return x, 'qty-1'
	elseif x < 10000000 then
		return tostring(math.floor(x/1000))..'K', 'qty-100k'
	else
		return tostring(math.floor(x/1000000))..'M', 'qty-10m'
	end
end

-- Formats a <div> element for items
local function makeDiv(ret, itemName, allowGif, equipSlot, stats, quantity)
	local itemName = itemName
	local allowGif = allowGif
	local topDivClass = "equipment-" .. equipSlot

	local names = mw.text.split(itemName, ";")
	if #names <= 1 or names[2] == 'g' then
		names[2] = itemstats.defaultVersion(names[1]) or names[1]
	end

	local imgType = allowGif == true and "gif" or "png"

	-- Use proper item icon/link and background, if item is present or not
	if itemName == '' then
		equipSlotText = ""
	else
		equipSlotText = string.format("[[File:%s.%s|link=%s]]", names[1], imgType, names[2])
	end

	-- Create the divs
	local topDiv = ret
		:tag("div")
		:addClass(topDivClass)

	local nestedDiv = topDiv
		:tag("div")
		:addClass("equipment-plinkp")
		:wikitext(equipSlotText)

	if quantity then
		local amt, quantclass = formatAmount(quantity)
		nestedDiv:tag('span')
			:addClass('inv-quantity-text')
			:addClass(quantclass)
			:wikitext(amt)
	end

	if stats and itemName ~= '' then
		local GEP = GEPrice(names[1], nil, nil, nil, -1)
		local value = itemstats.value(names[2])
		local name = names[1]
		if allowGif then
			-- restore ;g flag in order to be able to show a gif in the IKOD interface
			name = name .. ';g'
		end
		if GEP == -1 then
			table.insert(stats.ikods, {name, value})
		else
			table.insert(stats.ikods, {name, GEP})
		end
		local statstr = ''
		local statstbl = itemstats.equipmentStats({names[2]})[1]
		for stat, bonus in pairs(stats) do
			if not statstbl then
				-- do nothing, this item doesn't seem to exist
			elseif statstbl[stat] then
				-- Note: technically not 100% true since two types of ammo don't combine to increase rstr
				-- but things like craw's bow or hvy ballista also give rstr in the weapon slot so this is
				-- not trivial to correct for. Just doing it this way works for almost all legit situations.
				stats[stat] = bonus + tonumber(statstbl[stat])
				if statstr == '' then
					statstr = bonus
				else
					statstr = statstr .. ',' .. bonus
				end
			elseif stat ~= "ikods" then
				mw.log('Not found: ', itemName, equipSlot, stat)
				mw.logObject(statstbl)
			end
		end
		nestedDiv:attr("data-gemw", GEP)
			:attr("data-value", value)
			:attr("data-bonuses", statstr)
	end

	if itemName ~= '' then
		topDiv:addClass("equipment-blank")
	end
end

function statsdata(ret, txt, val)
	if val >= 0 then
		if txt == "Magic damage" then
			val = string.format(": +%.1f%%", val)
		elseif string.find(txt, "Weight") then
			val = string.format(" %.1f kg", val)
		else
			val = ": +"..tostring(val)
		end
	else
		val = ": "..tostring(val)
	end
	ret:tag('data'):wikitext(txt..val):attr('value', val)
end

function statslist(ret, stats)
	local td = ret:tag("td"):addClass("equipment-stats"):tag("div")
	td:tag("b"):wikitext("Attack bonus")
	statsdata(td, 'Stab', stats['astab'])
	statsdata(td, 'Slash', stats['aslash'])
	statsdata(td, 'Crush', stats['acrush'])
	statsdata(td, 'Magic', stats['amagic'])
	statsdata(td, 'Range', stats['arange'])
	td:tag('b'):wikitext("Defence bonus")
	statsdata(td, 'Stab', stats['dstab'])
	statsdata(td, 'Slash', stats['dslash'])
	statsdata(td, 'Crush', stats['dcrush'])
	statsdata(td, 'Magic', stats['dmagic'])
	statsdata(td, 'Range', stats['drange'])
	td:tag('b'):wikitext("Other bonuses")
	statsdata(td, 'Melee strength', stats['str'])
	statsdata(td, 'Ranged strength', stats['rstr'])
	statsdata(td, 'Magic damage', stats['mdmg'])
	statsdata(td, 'Prayer', stats['prayer'])
	statsdata(td, '[[File:Weight icon.png|link=]]', stats['weight'])
end

function ikod(ret, stats)
	table.sort(stats.ikods, function(left, right)
		return left[2] > right[2]
	end)

	local risk = 0
	local smite = 0
	-- hidden td by default; will be shown when the IKOD button is pressed.
	local td = ret:tag("td"):addClass("equipment-ikod"):css("display", "none"):tag("div")
	td:tag("em"):wikitext("Items <b>KEPT</b> if not <strong>SKULLED</strong>:")
	local ul = td:tag("ul")
	for i, ikod in pairs(stats.ikods) do
		if i > 4 then
			-- Finish previous <ul> and insert a header that items will be lost.
		end
		it = ikod[1]
		val = ikod[2]
		local ftype = 'png'
		if it:sub(-2) == ';g' then
			ftype = 'gif'
			it = it:sub(0, -3)
		end
		if i == 4 then
			-- 4th item is only kept with protect item; create new header
			td:tag("hr")
			td:tag("em"):wikitext("Items <b>KEPT</b> if using <b>[[Protect Item|PROTECT ITEM]]</b>:")
			ul = td:tag("ul")
			ul:tag("li"):wikitext(string.format("[[File:%s.%s|link=|Kept-on-death value: %s]]", it, ftype, lang:formatNum(val)))
			smite = smite + tonumber(val)
			-- the rest of the items will be lost regardless; create a new header for that
			td:tag("hr")
			td:tag("em"):wikitext("Items sent to your <b>GRAVESTONE</b> or <strong>LOST</strong> to the player who killed you:")
			-- change currently active ul to a new one
			ul = td:tag("ul")
		else
			ul:tag("li"):wikitext(string.format("[[File:%s.%s|link=|Kept-on-death value: %s]]", it, ftype, lang:formatNum(val)))
			if i > 4 then
				risk = risk + tonumber(val)
				smite = smite + tonumber(val)
			end
		end
		i = i + 1
	end
	-- add an informative notice at the end
	td:tag("hr")
	td:tag("em"):wikitext("Data in this list is based purely on exchange or item value. " ..
		"See <b>[[Items Kept on Death]]</b> for info. " ..
		"The interface and items kept on death may vary in-game; [[RuneScape:General disclaimer|general disclaimer]]s apply.")
	return risk, smite
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

function p._main(args)
	local buttons = yesno(args.buttons, false)
	local stats = yesno(args.stats, false)

	local align
	if args.align == "right" then
		align = "equipment-right"
	elseif args.align == "center" then
		align = "equipment-center"
	elseif args.align == "inline" then
		align = ""
	else
		align = "equipment-left"
	end

	local tbl = mw.html.create("table"):addClass("equipment"):addClass(align)

	if args.align == "inline" then
		tbl:css("display", "inline-block")
	end

	tbl = tbl:tag("tr")
	local ret = tbl:tag("td"):tag("div")

	if stats then
		stats = {
			astab = 0,
			aslash = 0,
			acrush = 0,
			amagic = 0,
			arange = 0,
			dstab = 0,
			dslash = 0,
			dcrush = 0,
			dmagic = 0,
			drange = 0,
			str = 0,
			rstr = 0,
			mdmg = 0,
			prayer = 0,
			weight = 0,
			ikods = {},
		}
	end

	if buttons then
		ret:addClass("equipment-div-buttons")
	else
		ret:addClass("equipment-div")
	end

	-- Fetch equipment and create divs
	makeDiv(parseItem(ret, args.head, "head", stats))
	makeDiv(parseItem(ret, args.cape, "cape", stats))
	makeDiv(parseItem(ret, args.neck, "neck", stats))
	makeDiv(parseItem(ret, args.ammo, "ammo", stats, args.ammoquantity))
	makeDiv(parseItem(ret, args.ammo2, "ammo2", stats, args.ammo2quantity))
	makeDiv(parseItem(ret, args.weapon, "weapon", stats, args.weaponquantity))
	makeDiv(parseItem(ret, args.torso, "torso", stats))
	makeDiv(parseItem(ret, args.shield, "shield", stats))
	makeDiv(parseItem(ret, args.legs, "legs", stats))
	makeDiv(parseItem(ret, args.gloves, "gloves", stats))
	makeDiv(parseItem(ret, args.boots, "boots", stats))
	makeDiv(parseItem(ret, args.ring, "ring", stats))

	if stats then
		statslist(tbl, stats)
		if buttons then
			-- without buttons there is no way to switch to IKOD
			-- possible future feature: `if buttons or yesno(args.ikod, false)` for this if-statement
			local risk, smite = ikod(tbl, stats)
			ret:tag('div'):addClass("equipment-statsbutton")
			ret:node(string.format('<div class="equipment-ikodbutton" title="Risked value: %s&#10;When smited: %s"></div>', lang:formatNum(risk), lang:formatNum(smite)))
		end
	end

	return tbl:done()
end

return p