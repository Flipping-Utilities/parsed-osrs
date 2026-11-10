-- <nowiki>
-- Module for [[Template:Infobox Set]]
-- Test changes using [[Module:Infobox set/sandbox]] [[Template:Infobox Set/sandbox]]

local p = {}

-- "imports"
local infobox = require('Module:Infobox')
local onmain = require('Module:Mainonly').on_main
local exchange = require('Module:Exchange')
local calcvalue = require('Module:Calcvalue')._get
local storeprice = require('Module:Store price')._main
local paramtest = require('Module:Paramtest')
local chart = require('Module:ExchangeData')._chart
local commas = require('Module:Addcommas')
local currency_img = require('Module:Currency Image')
local isDefined = infobox.isDefined

--lazy-load Module
local function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end

-- items table argument
local function ittable(geset, head, headalt, back, neck, body, bodyalt, shield, legs, legsalt, hands, feet, ring, twohand, mhand, ohand)
	local items = {}
	if isDefined(geset) then
		table.insert(items, geset)
	end
	if isDefined(head) then
		table.insert(items, head)
	end
	if isDefined(headalt) then
		table.insert(items, headalt)
	end
	if isDefined(back) then
		table.insert(items, back)
	end
	if isDefined(neck) then
		table.insert(items, neck)
	end
	if isDefined(body) then
		table.insert(items, body)
	end
	if isDefined(bodyalt) then
		table.insert(items, bodyalt)
	end
	if isDefined(shield) then
		table.insert(items, shield)
	end
	if isDefined(legs) then
		table.insert(items, legs)
	end
	if isDefined(legsalt) then
		table.insert(items, legsalt)
	end
	if isDefined(hands) then
		table.insert(items, hands)
	end
	if isDefined(feet) then
		table.insert(items, feet)
	end
	if isDefined(ring) then
		table.insert(items, ring)
	end
	if isDefined(twohand) then
		table.insert(items, twohand)
	end
	if isDefined(mhand) then
		table.insert(items, mhand)
	end
	if isDefined(ohand) then
		table.insert(items, ohand)
	end
	return items
end

-- image
local function imgparam(img, itemtbl)
	if isDefined(img) then
		return img
	else
		local imgs = {}
		for _, v in ipairs(itemtbl) do
			table.insert(imgs, string.format('[[File:%s.png]]', v))
		end
		return table.concat(imgs, '')
	end
end

-- tradeable
-- tradeablearg(value)
local function tradeablearg(v)
	v = string.lower(v or '')
	if v == 'yes' or v == 'no' then
		v = mw.text.split(v, '')
		v[1] = string.upper(v[1])
		return table.concat(v, '')
	elseif v == 'restricted' then
		return '[[Restricted trade items|Restricted]]'
	else
		return nil
	end
end

-- GE set args
local function geset(arg)
	if isDefined(arg) then
		local str = string.gsub(arg or '', '%[%[', '')
		str = string.gsub(str, '%]%]', '')
		return '[[' .. str .. ']]'
	end
	return nil
end
local function setshort(arg)
	if isDefined(arg) then
		local str = string.gsub(arg or '', '%[%[', '')
		str = string.gsub(str, '%]%]', '')
		return string.format('[[File:%s.png|link=%s]] [[%s|Set]]', str, str, str)
	end
	return nil
end
local function setprice(item, ptype)
	if isDefined(item) then
		if isDefined(ptype) then
			local str = string.lower(ptype)
			local it = string.gsub(item or '', '%[%[', '')
			it = string.gsub(it, '%]%]', '')
			if str == 'gemw' then
				if exchange._exists(it) then
					return commas._add(tonumber(exchange._price(it), 10))
				else
					error('No GE price could be found for: ' .. it)
				end
			elseif str == 'calcval' or str == 'calcvalue' then
				return commas._add(calcvalue(it))
			elseif str == 'store' or str == 'shop' then
				local sp = storeprice(it)
				return commas._add(sp[1])
			end
		end
	end
	return nil
end

-- prices
local function pricesarg(arg)
	if isDefined(arg) then
		local str = string.lower(arg)
		if str == 'gemw' then
			return str
		elseif str == 'calcval' or str == 'calcvalue' then
			return 'calcvalue'
		elseif str == 'store' or str == 'shop' then
			return 'store'
		elseif str == 'manual' then
			return 'manual'
		elseif str == 'no' then
			return 'no'
		end
	end
	return nil
end

-- GE graph
local function gemwgraph(ptype, itemtbl)
	if string.lower(ptype or '') ~= 'gemw' then
		return nil
	end

	local itstring = table.concat(itemtbl, ', ')
	bucket('logs').put({source_module="Infobox set", message=itstring})
	return chart { itstring, size = 'small', use_ids = 'n', defer = 'y' }
end

-- item args
local function setitem(item, slot, price)
	if isDefined(item) then
		if price == 'calcvalue' or price == 'gemw' or price == 'store' or price == 'manual' then
			return string.format('[[%s|%s]]', item, slot)
		else
			return string.format('[[%s]]', item)
		end
	end
	return nil
end
local function itemgemwprice(item)
	if exchange._exists(item) then
		return tonumber(exchange._price(item), 10)
	else
		error('No GE price could be found for: ' .. item)
	end
end
local function setitemprice(item, ptype, mprice)
	if not ptype then
		return nil
	end

	if not isDefined(item) then
		return nil
	end

	local price
	if ptype == 'gemw' then
		if isDefined(mprice) then
			price = itemgemwprice(mprice)
		else
			price = itemgemwprice(item)
		end
	elseif ptype == 'calcvalue' then
		if isDefined(mprice) then
			price = calcvalue(mprice)
		else
			price = calcvalue(item)
		end
	elseif ptype == 'store' then
		if isDefined(mprice) then
			price = storeprice(mprice)[1]
		else
			price = storeprice(item)[1]
		end
	elseif ptype == 'manual' then
		local numprice = commas._strip(mprice)
		if tonumber(numprice) then
			price = numprice
		else
			price = 0
		end
	else
		return nil
	end
	return commas._add(price)
end

-- Total price (without set)
local function totprice(headprice, headaltprice, backprice, neckprice, bodyprice, bodyaltprice, shieldprice, legsprice, legsaltprice, handsprice, feetprice, ringprice, twohandprice, mhandprice, ohandprice)
	local prices = {}
	table.insert(prices, headprice)
	table.insert(prices, headaltprice)
	table.insert(prices, backprice)
	table.insert(prices, neckprice)
	table.insert(prices, bodyprice)
	table.insert(prices, bodyaltprice)
	table.insert(prices, shieldprice)
	table.insert(prices, legsprice)
	table.insert(prices, legsaltprice)
	table.insert(prices, handsprice)
	table.insert(prices, feetprice)
	table.insert(prices, ringprice)
	table.insert(prices, twohandprice)
	table.insert(prices, mhandprice)
	table.insert(prices, ohandprice)

	local tot = 0
	for _, v in ipairs(prices) do
		local pr = tonumber(commas._strip(v), 10)
		if pr then
			tot = tot + pr
		end
	end

	if tot > 0 then
		return commas._add(tot)
	end
	return nil
end

-- long item names and links
local function itemlinks(itemtbl)
	local plinks = {}
	for _, v in ipairs(itemtbl) do
		table.insert(plinks, string.format('[[File:%s.png|link=%s]] [[%s]]', v, v, v))
	end
	return table.concat(plinks, '<br>')
end

--
local function noteparam(itemtbl, ptype, currency, total)
	if ptype == 'store' and itemtbl[1] then
		local stinfo = storeprice(itemtbl[1])
		return string.format("''Values based on prices in %s from [[%s]].''", stinfo[2], stinfo[3])
	elseif ptype == 'manual' then
		local tot = commas._strip(total)
		if tonumber(tot) and tonumber(tot) > 0 then
			tot = tonumber(tot)
		else
			tot = 1000
		end
		local img = currency_img(string.gsub(string.gsub(currency, '%[%[', ''), '%]%]', ''), tot)
		local cur = 'Coins'
		if isDefined(currency) then
			cur = currency
		end
		if not img then
			return string.format("''All prices in %s.''", cur)
		end
		return string.format("''All prices in [[File:%s|25x25px|link=]] %s.''", img, cur)
	end
	return nil
end

-- Categories
-- oman this is still blatant copy pasta
local function addcategories(ibox, args, catargs)
	local ret = { 'Equipment sets' }
	local cat_map = {
		-- Added if the parameter has content
		defined = {
			aka = 'Pages with AKA',
		},
		notdefined = {
			image = 'Needs image',
			members = 'Needs members status',
			prices = 'Needs price'
		},
	}

	-- defined categories
	for n, v in pairs(cat_map.defined) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret, v)
		end
	end
	-- undefined categories
	for n, v in pairs(cat_map.notdefined) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret, v)
		end
	end

	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		ret[i] = string.format('[[Category:%s]]', v)
	end
	return table.concat(ret, '')
end

-- Main function called with invokes
function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	-- Parameter definitions
	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'aka', func = 'has_content' },

		-- Generates a array style table of the set item names
		{ name = 'itemtbl', func = { name = ittable, params = { 'geset', 'head', 'headalt', 'back', 'neck', 'body', 'bodyalt', 'shield', 'legs', 'legsalt', 'hands', 'feet', 'ring', '2hand', 'mhand', 'ohand' }, flag = 'p' } },

		{ name = 'image', func = { name = imgparam, params = { 'image', 'itemtbl' }, flag = { 'p', 'd' } } },

		-- release and removal
		-- removal only shown if it exists
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },

		{ name = 'members', func = 'has_content' },
		{ name = 'quest', func = 'has_content' },
		{ name = 'tradeable', func = tradeablearg },

		{ name = 'geset', func = geset },
		{ name = 'setshort', func = { name = setshort, params = { 'geset' }, flag = 'd' } },
		{ name = 'setprice', func = { name = setprice, params = { 'geset', 'setprice' }, flag = { 'd', 'p' } } },

		-- price types
		{ name = 'prices', func = pricesarg },
		-- currency types
		{ name = 'currency', func = 'has_content' },
		-- ge graph
		{ name = 'graph', func = { name = gemwgraph, params = { 'prices', 'itemtbl' } }, flag = { 'p', 'd' } },

		-- items in set
		-- head, headalt, back, neck, body, bodyalt, shield, legs, legsalt, hands, feet, ring
		{ name = 'head', func = { name = setitem, params = { 'head', 'Head', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'headprice', func = { name = setitemprice, params = { 'head', 'prices', 'headprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'headalt', func = { name = setitem, params = { 'headalt', 'Head 2', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'headaltprice', func = { name = setitemprice, params = { 'headalt', 'prices', 'headaltprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'back', func = { name = setitem, params = { 'back', 'Back', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'backprice', func = { name = setitemprice, params = { 'back', 'prices', 'backprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'neck', func = { name = setitem, params = { 'neck', 'Neck', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'neckprice', func = { name = setitemprice, params = { 'neck', 'prices', 'neckprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'body', func = { name = setitem, params = { 'body', 'Torso', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'bodyprice', func = { name = setitemprice, params = { 'body', 'prices', 'bodyprice' }, flag = { 'p', 'd' } } },
		{ name = 'bodyalt', func = { name = setitem, params = { 'bodyalt', 'Torso 2', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'bodyaltprice', func = { name = setitemprice, params = { 'bodyalt', 'prices', 'bodyaltprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'shield', func = { name = setitem, params = { 'shield', 'Shield', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'shieldprice', func = { name = setitemprice, params = { 'shield', 'prices', 'shieldprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'legs', func = { name = setitem, params = { 'legs', 'Legs', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'legprice', func = { name = setitemprice, params = { 'legs', 'prices', 'legsprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'legsalt', func = { name = setitem, params = { 'legsalt', 'Legs 2', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'legaltprice', func = { name = setitemprice, params = { 'legsalt', 'prices', 'legsaltprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'hands', func = { name = setitem, params = { 'hands', 'Hands', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'handprice', func = { name = setitemprice, params = { 'hands', 'prices', 'handsprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'feet', func = { name = setitem, params = { 'feet', 'Feet', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'feetprice', func = { name = setitemprice, params = { 'feet', 'prices', 'feetprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'ring', func = { name = setitem, params = { 'ring', 'Ring', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'ringprice', func = { name = setitemprice, params = { 'ring', 'prices', 'ringprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = '2hand', func = { name = setitem, params = { '2hand', 'Two-hand', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = '2handprice', func = { name = setitemprice, params = { '2hand', 'prices', '2handprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'mhand', func = { name = setitem, params = { 'mhand', 'Main-hand', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'mhandprice', func = { name = setitemprice, params = { 'mhand', 'prices', 'mhandprice' }, flag = { 'p', 'd', 'p' } } },
		{ name = 'ohand', func = { name = setitem, params = { 'ohand', 'Off-hand', 'prices' }, flag = { 'p', 'r', 'd' } } },
		{ name = 'ohandprice', func = { name = setitemprice, params = { 'ohand', 'prices', 'ohandprice' }, flag = { 'p', 'd', 'p' } } },

		{ name = 'total', func = { name = totprice, params = { 'headprice', 'headaltprice', 'backprice', 'neckprice', 'bodyprice', 'bodyaltprice', 'shieldprice', 'legprice', 'legaltprice', 'handprice', 'feetprice', 'ringprice', '2handprice', 'mhandprice', 'ohandprice' }, flag = 'd' } },

		{ name = 'pricenote', func = { name = noteparam, params = { 'itemtbl', 'prices', 'currency', 'total', }, flag = { 'd', 'd', 'd', 'd' } } },
		{ name = 'itemlist', func = { name = itemlinks, params = { 'itemtbl' }, flag = { 'd' } } },
		
		{ name = 'leagueRegion', func = leaguesArg },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
	}

	ret:create()
	ret:cleanParams()

	ret:defineLinks()
	ret:defineName('Infobox Set')
	ret:addClass('infobox-set')

	-- TODO: set image and image of each item in set
	ret:addRow {
		{ tag = 'argd', content = 'image', class = 'infobox-image inventory-image bordered-image', colspan = '20' }
	}

		:addRow {
			{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '20' }
		}
		:pad(4)

		:addRow {
			{ tag = 'th', content = 'Release', colspan = '8' },
			{ tag = 'argd', content = 'release', colspan = '12' }
		}

	if ret:paramDefined('removal') then
		ret:addRow {
			{ tag = 'th', content = 'Removal', colspan = '8' },
			{ tag = 'argd', content = 'removal', colspan = '12' }
		}
	end

	if ret:paramDefined('aka') then
		ret:addRow {
			{ tag = 'th', content = '[[Slang dictionary|AKA]]', colspan = '8' },
			{ tag = 'argd', content = 'aka', colspan = '12' }
		}
	end

	ret:addRow {
		{ tag = 'th', content = '[[Members|Members items]]', colspan = '8' },
		{ tag = 'argd', content = 'members', colspan = '12' }
	}
		:addRow {
			{ tag = 'th', content = '[[Quest items|Quest items]]', colspan = '8' },
			{ tag = 'argd', content = 'quest', colspan = '12' }
		}
		:addRow {
			{ tag = 'th', content = '[[Items#Tradeability|Tradeable]]', colspan = '8' },
			{ tag = 'argd', content = 'tradeable', colspan = '12' }
		}
		if ret:paramDefined('leagueRegion') then
			local leagues = require('Module:LeagueRegion')
			ret:addRow{
			{ tag = 'th', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] region', css = {['vertical-align'] = 'middle' }, colspan = '8'},
			{ tag = 'argd', content = 'leagueRegion', colspan = '12'},
			meta = { addClass = 'leagues-global-flag' }
		}
		end
	if ret:paramDefined('geset') then
		ret:addRow {
			{ tag = 'th', content = '[[Item set|GE Set]]', colspan = '8' },
			{ tag = 'argd', content = 'geset', colspan = '12' }
		}
	end

	ret:pad(4)

	-- Values
	-- ge graph of all items, or calcvals for each
	if ret:paramDefined('prices') and not ret:paramGrep('prices', 'no') then
		--if ret:paramDefined('prices') then
		ret:addRow {
			{ tag = 'th', content = 'Values', class = 'infobox-subheader', colspan = '20' }
		}
			:pad(4)

		-- Set
		if ret:paramDefined('geset') and ret:paramDefined('setprice') then
			ret:addRow {
				{ tag = 'argh', content = 'setshort', colspan = '8' },
				{ tag = 'argd', content = 'setprice', colspan = '12' }
			}
		end

		-- Slot items
		if ret:paramDefined('head') then
			ret:addRow {
				{ tag = 'argh', content = 'head', colspan = '8' },
				{ tag = 'argd', content = 'headprice', colspan = '12' }
			}
		end
		if ret:paramDefined('headalt') then
			ret:addRow {
				{ tag = 'argh', content = 'headalt', colspan = '8' },
				{ tag = 'argd', content = 'headaltprice', colspan = '12' }
			}
		end
		if ret:paramDefined('back') then
			ret:addRow {
				{ tag = 'argh', content = 'back', colspan = '8' },
				{ tag = 'argd', content = 'backprice', colspan = '12' }
			}
		end
		if ret:paramDefined('neck') then
			ret:addRow {
				{ tag = 'argh', content = 'neck', colspan = '8' },
				{ tag = 'argd', content = 'neckprice', colspan = '12' }
			}
		end
		if ret:paramDefined('body') then
			ret:addRow {
				{ tag = 'argh', content = 'body', colspan = '8' },
				{ tag = 'argd', content = 'bodyprice', colspan = '12' }
			}
		end
		if ret:paramDefined('bodyalt') then
			ret:addRow {
				{ tag = 'argh', content = 'bodyalt', colspan = '8' },
				{ tag = 'argd', content = 'bodyaltprice', colspan = '12' }
			}
		end
		if ret:paramDefined('shield') then
			ret:addRow {
				{ tag = 'argh', content = 'shield', colspan = '8' },
				{ tag = 'argd', content = 'shieldprice', colspan = '12' }
			}
		end
		if ret:paramDefined('legs') then
			ret:addRow {
				{ tag = 'argh', content = 'legs', colspan = '8' },
				{ tag = 'argd', content = 'legprice', colspan = '12' }
			}
		end
		if ret:paramDefined('legsalt') then
			ret:addRow {
				{ tag = 'argh', content = 'legsalt', colspan = '8' },
				{ tag = 'argd', content = 'legaltprice', colspan = '12' }
			}
		end
		if ret:paramDefined('hands') then
			ret:addRow {
				{ tag = 'argh', content = 'hands', colspan = '8' },
				{ tag = 'argd', content = 'handprice', colspan = '12' }
			}
		end
		if ret:paramDefined('feet') then
			ret:addRow {
				{ tag = 'argh', content = 'feet', colspan = '8' },
				{ tag = 'argd', content = 'feetprice', colspan = '12' }
			}
		end
		if ret:paramDefined('ring') then
			ret:addRow {
				{ tag = 'argh', content = 'ring', colspan = '8' },
				{ tag = 'argd', content = 'ringprice', colspan = '12' }
			}
		end
		if ret:paramDefined('2hand') then
			ret:addRow {
				{ tag = 'argh', content = '2hand', colspan = '8' },
				{ tag = 'argd', content = '2handprice', colspan = '12' }
			}
		end
		if ret:paramDefined('mhand') then
			ret:addRow {
				{ tag = 'argh', content = 'mhand', colspan = '8' },
				{ tag = 'argd', content = 'mhandprice', colspan = '12' }
			}
		end
		if ret:paramDefined('ohand') then
			ret:addRow {
				{ tag = 'argh', content = 'ohand', colspan = '8' },
				{ tag = 'argd', content = 'ohandprice', colspan = '12' }
			}
		end

		ret:addRow {
			{ tag = 'th', content = 'Total', colspan = '8' },
			{ tag = 'argd', content = 'total', colspan = '12' }
		}

		-- Calcvalue or store note
		if ret:paramGrep('prices', 'calcvalue') then
			ret:addRow {
				{ tag = 'td', colspan = '20', content = "''Values calculated based on GE prices of materials''", css = { ['text-align'] = 'center' } }
			}
		elseif ret:paramGrep('prices', 'store') then
			ret:addRow {
				{ tag = 'argd', colspan = '20', content = 'pricenote', css = { ['text-align'] = 'center' } }
			}
		elseif ret:paramGrep('prices', 'manual') then
			ret:addRow {
				{ tag = 'argd', colspan = '20', content = 'pricenote', css = { ['text-align'] = 'center' } }
			}
		end

		-- GE Graph
		if ret:paramGrep('prices', 'gemw') then
			ret:addRow {
				{ tag = 'argd', content = 'graph', colspan = '20', css = { ['text-align'] = 'center', ['padding'] = '0' } }
			}
		end
	else
		ret:addRow {
			{ tag = 'th', content = 'Items', class = 'infobox-subheader', colspan = '20' }
		}
			:pad(4)

		-- Set
		if ret:paramDefined('geset') and ret:paramDefined('setprice') then
			ret:addRow {
				{ tag = 'th', content = 'Set', colspan = '8' },
				{ tag = 'argd', content = 'geset', colspan = '12' }
			}
		end

		-- Slot items
		if ret:paramDefined('head') then
			ret:addRow {
				{ tag = 'th', content = 'Head', colspan = '8' },
				{ tag = 'argd', content = 'head', colspan = '12' }
			}
		end
		if ret:paramDefined('headalt') then
			ret:addRow {
				{ tag = 'th', content = 'Head 2', colspan = '8' },
				{ tag = 'argd', content = 'headalt', colspan = '12' }
			}
		end
		if ret:paramDefined('back') then
			ret:addRow {
				{ tag = 'th', content = 'Back', colspan = '8' },
				{ tag = 'argd', content = 'back', colspan = '12' }
			}
		end
		if ret:paramDefined('neck') then
			ret:addRow {
				{ tag = 'th', content = 'Neck', colspan = '8' },
				{ tag = 'argd', content = 'neck', colspan = '12' }
			}
		end
		if ret:paramDefined('body') then
			ret:addRow {
				{ tag = 'th', content = 'Body', colspan = '8' },
				{ tag = 'argd', content = 'body', colspan = '12' }
			}
		end
		if ret:paramDefined('bodyalt') then
			ret:addRow {
				{ tag = 'th', content = 'Body 2', colspan = '8' },
				{ tag = 'argd', content = 'bodyalt', colspan = '12' }
			}
		end
		if ret:paramDefined('shield') then
			ret:addRow {
				{ tag = 'th', content = 'Shield', colspan = '8' },
				{ tag = 'argd', content = 'shield', colspan = '12' }
			}
		end
		if ret:paramDefined('legs') then
			ret:addRow {
				{ tag = 'th', content = 'Legs', colspan = '8' },
				{ tag = 'argd', content = 'legs', colspan = '12' }
			}
		end
		if ret:paramDefined('legsalt') then
			ret:addRow {
				{ tag = 'th', content = 'Legs 2', colspan = '8' },
				{ tag = 'argd', content = 'legsalt', colspan = '12' }
			}
		end
		if ret:paramDefined('hands') then
			ret:addRow {
				{ tag = 'th', content = 'Hands', colspan = '8' },
				{ tag = 'argd', content = 'hands', colspan = '12' }
			}
		end
		if ret:paramDefined('feet') then
			ret:addRow {
				{ tag = 'th', content = 'Feet', colspan = '8' },
				{ tag = 'argd', content = 'feet', colspan = '12' }
			}
		end
		if ret:paramDefined('ring') then
			ret:addRow {
				{ tag = 'th', content = 'Ring', colspan = '8' },
				{ tag = 'argd', content = 'ring', colspan = '12' }
			}
		end
		if ret:paramDefined('2hand') then
			ret:addRow {
				{ tag = 'th', content = '2-Hand', colspan = '8' },
				{ tag = 'argd', content = '2hand', colspan = '12' }
			}
		end
		if ret:paramDefined('mhand') then
			ret:addRow {
				{ tag = 'th', content = 'M-Hand', colspan = '8' },
				{ tag = 'argd', content = 'mhand', colspan = '12' }
			}
		end
		if ret:paramDefined('ohand') then
			ret:addRow {
				{ tag = 'th', content = 'O-Hand', colspan = '8' },
				{ tag = 'argd', content = 'ohand', colspan = '12' }
			}
		end			
	end

	ret:pad(4)

	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(ret, a1, a2))
	end

	return ret:tostring()
end

return p
--</nowiki>