-- <nowiki>
-- code for [[Template:Disassembly junk calculator/t]]
-- -> [[Calculator:Disassembly by material/Junk]]
local p = {}

local yesno = require('Module:Yesno')
local cats = mw.loadData('Module:Disassemble/data')
local prices = mw.loadJsonData('Module:GEPrices/data.json')
local limits = mw.loadJsonData('Module:GELimits/data.json')
local volumes = mw.loadJsonData('Module:GEVolumes/data.json')
local camt = require('Module:Currency')._amount
local info = mw.loadData('Module:Disassembly category calculator/data') -- versioning info here
local commas = require('Module:Addcommas')._add
require("Module:Mw.html extension")

local function gep(item)
	item = info.gemwnames[item] or info.names[item] or item
	return prices[item] or 0, limits[item] or -1, volumes[item] or -1
end

local function img(item)
	return info.imgnames[item] or info.names[item] or item
end

local function plink_pic(image, page)
	return '[[File:' .. image .. '.png|link=' .. page .. ']]'
end

local function junk(lv)
	local junkpast75 = {
		[75] = 4.2,
		[76] = 3.8,
		[77] = 3.4,
		[78] = 3.0,
		[79] = 2.7,
		[80] = 2.3,
		[81] = 2.0,
		[82] = 1.7,
		[83] = 1.4,
		[84] = 1.2,
		[85] = 1.0,
		[86] = 0.8,
		[87] = 0.6,
		[88] = 0.4,
		[89] = 0.3,
	}

	lv = tonumber(lv) or 1
	if lv >= 90 then
		return 0
	elseif lv >= 75 then
		return junkpast75[lv]
	else
		return 100 - 1.1 * lv
	end
end

local function nocoins(amt)
	return camt(amt, 'nocoins')
end

-- non-special mat row
-- item | cqty | junk | price per dis | buy limit | chance of mat per nonjunk | overall chance per item | cost per mat | mats per hour
local function make_row(data)
	local displayName = '[[' .. data.page .. '|' .. data.name .. ']]'
	if data.iqty ~= nil and data.iqty > 1 then
		displayName = data.iqty .. ' × ' .. displayName
	end

	local junkperdis = data.junk * data.cqty / 100
	local priceperdis = data.price * data.iqty
	local base = priceperdis / junkperdis
	local matsperhour = 3000 * junkperdis

	-- TODO: javascript support
	local tr = mw.html.create('tr')
	tr:attr {
		['data-dis-mats'] = data.cqty,
		['data-dis-junk'] = data.junk,
		['data-dis-price'] = priceperdis,
		['data-dis-raw'] = 100,
	}
		:addClass('dis-calc-row')

	tr
		:td { plink_pic(data.img, data.page), attr = { ['data-sort-value'] = data.page } }
		:td { displayName, attr = { ['data-sort-value'] = data.page } }
		:td { data.cqty, attr = { ['data-sort-value'] = data.cqty } }
		:td { string.format('%.1f%%', data.junk), attr = { ['data-sort-value'] = data.junk }, class = 'data-dis-junkcell' }

	if priceperdis > 0 then
		tr:td { nocoins(priceperdis), class = 'data-dis-costcell' }
	else
		tr:na():addClass('data-dis-costcell')
	end

	if tonumber(data.limit) then
		if data.limit > 0 then
			tr:td { commas(data.limit), attr = { ['data-sort-value'] = data.limit }, class = 'data-dis-limitcell' }
		else
			tr:na():addClass('data-dis-limitcell')
		end
	else
		tr:td { "''Unknown''", attr = { ['data-sort-value'] = 0 }, class = 'data-dis-limitcell' }
	end

	if tonumber(data.volume) then
		if data.volume >= 0 then
			tr:td { commas(data.volume), attr = { ['data-sort-value'] = data.volume }, class = 'data-dis-volumecell' }
		else
			tr:na():addClass('data-dis-volumecell')
		end
	else
		tr:td { "''Unknown''", attr = { ['data-sort-value'] = 0 }, class = 'data-dis-volumecell' }
	end

	tr:td { junkperdis, attr = { ['data-sort-value'] = junkperdis }, class = 'data-dis-chancecell-junkcalc' }

	if base > 0 then
		tr:td { nocoins(base), class = 'data-dis-costcell-junkcalc' }
	else
		tr:na():addClass('data-dis-costcell-junkcalc')
	end

	tr:td { commas(matsperhour), attr = { ['data-sort-value'] = matsperhour }, class = 'data-dis-mphcell-junkcalc data-dis-mphcell' }

	return tr
end

-- special case: potions
-- cqty does not vary, it might actually idk
local function potion(data)
	if data.calcvalue and data.calccomp then
		data.name = string.format('%s (%s)', data.page, data.calccomp)
		data.img = img(data.name)
		data.cqty = data.calccomp
		data.price = data.calcvalue
		data.limit = -1
		data.volume = -1
		return make_row(data)
	end

	-- setup 6-dose
	data.name = data.page .. ' (6)'
	data.img = img(data.name)
	data.cqty = 6
	data.price, data.limit, data.volume = gep(data.name)

	if data.price > 0 then
		-- if 6-dose has a price, then this is a flask; only show 6 dose (5 and lower not GE-able)
		return make_row(data)
	else
		local rows = mw.html.create()

		data.name = data.page .. ' (4)'
		data.price, data.limit, data.volume = gep(data.name)
		if data.price > 0 then
			-- if 4 dose has a price, this is a 4-dose vial
			for i = 4, 1, -1 do
				data.name = string.format('%s (%s)', data.page, i)
				data.img = img(data.name)
				data.cqty = i
				data.price, data.limit, data.volume = gep(data.name)
				rows.node(make_row(data))
			end
		else
			-- if 4 dose does not have a price, this is a 2-dose mix
			for i = 2, 1, -1 do
				data.name = string.format('%s (%s)', data.page, i)
				data.img = img(data.name)
				data.cqty = i
				data.price, data.limit, data.volume = gep(data.name)
				rows.node(make_row(data))
			end
		end

		return rows
	end
end

local function dose(data)
	if data.calcvalue and data.calccomp then
		data.name = data._name
		data.img = img(data.name)
		data.cqty = data.calccomp
		data.price = data.calcvalue
		data.limit = -1
		data.volume = -1
		return make_row(data)
	end

	data.name = data._name
	data.price, data.limit, data.volume = gep(data.name)
	if data.price > 0 then
		return make_row(data)
	end
end

-- main parsing function and module entry point
function p._output_node_per_data(args)
	local cat = cats[string.lower(args.category)]
	if not cat then
		return nil
	end

	local data = {}
	data.junk = junk(args.level)
	if data.junk == 0 then
		return nil
	end

	data.page = args._page
	data._name = args.name
	data.name = data.page
	data.img = img(data.page)

	-- defaults
	data.iqty = tonumber(cat.itemqty) or 1
	data.cqty = tonumber(cat.compqty) or 1

	data.calcvalue = tonumber(args.calcvalue) or nil
	data.calccomp = tonumber(args.calccomp) or nil

	local pot = args.potion or cat.potion or 'false'
	pot = string.lower(tostring(pot))
	if yesno(pot) then
		return potion(data)
	elseif args.category == '1 dose' or args.category == '2 dose' or
		args.category == '3 dose' or args.category == '4 dose' or
		args.category == '5 dose' or args.category == '6 dose' then
		return dose(data)
	end

	local versions = info.versions[args._page]
	if versions then
		local rows = mw.html.create()

		for _, v in ipairs(versions) do
			data.name = v

			if data.calcvalue then
				data.price, data.limit, data.volume = data.calcvalue, -1, -1
			else
				data.price, data.limit, data.volume = gep(v)
			end

			data.img = img(v)

			rows.node(make_row(data))
		end

		return rows
	else
		if data.calcvalue then
			data.price, data.limit, data.volume = data.calcvalue, -1, -1
		else
			data.price, data.limit, data.volume = gep(data.page)
		end

		return make_row(data)
	end
end

function p.main(frame)
	local tbl = mw.html.create('table')
	tbl:addClass('wikitable sortable sticky-header align-center-1 align-left-2')
		:css('text-align', 'right')
		:attr('id', 'dis-calc-table')

	tbl:tr()
		:th { 'Item', attr = { colspan = '2' } }
		:th { 'Materials<br>each', attr = { ['data-sort-type'] = 'number' } }
		:th { 'Junk', attr = { ['data-sort-type'] = 'number' } }
		:th { 'Cost per<br>disassemble', attr = { ['data-sort-type'] = 'number' } }
		:th { '[[Grand Exchange#Trade restrictions|Buy<br>limit]]', attr = { ['data-sort-type'] = 'number' } }
		:th { 'Trade<br>vol.', attr = { ['data-sort-type'] = 'number' } }
		:th { 'Junk per<br>disassemble', attr = { ['data-sort-type'] = 'number' } }
		:th { 'Cost per junk', attr = { ['data-sort-type'] = 'number' } }
		:th { 'Junk per hour', attr = { ['data-sort-type'] = 'number' } }

	local bucket_data = bucket('disassembly')
		.select('page_name', 'json')
		.where('Category:Disassembly junk calculator')
		.where('Category:Grand Exchange items')
		.where(bucket.Not { 'Category:Pages using information from game APIs or cache' })
		.limit(3000)
		.run()

	for _, entry in ipairs(bucket_data) do
		local args = mw.text.jsonDecode(entry.json)
		args._page = entry.page_name
		local node = p._output_node_per_data(args)
		tbl:node(node)
	end

	return tbl
end

return p