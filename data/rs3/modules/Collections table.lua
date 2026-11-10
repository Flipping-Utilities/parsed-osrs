-- <nowiki>
local p = {}

local onmain = require('Module:Mainonly').on_main
local commas = require('Module:Addcommas')._add
local currency = require('Module:Currency short')._amount
local exchange = require('Module:Exchange')
local plinkt = require('Module:Plink')._plinkt
local hc = require("Module:Paramtest").has_content;

require('Module:Mw.html extension')

local function starts_with(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

local function plinkqty(link, qty)
	return mw.html.create()
		:td { string.format('%s ×', qty), css = { ['white-space'] = 'pre', ['text-align'] = 'right' } }
		:td { string.format("[[File:%s.png|link=%s|alt=RuneScape inventory image of %s]]", link, link, link), css = { ['text-align'] = 'center' } }
		:td(string.format("[[%s|%s]]", link, link))
		:allDone()
end

local function convert_artefact(artefact_name, production, excavation_hotspot, dig_site, chronotes)
	local artefact = {}
	artefact.name = artefact_name
	artefact.hotspot = excavation_hotspot
	artefact.dig_site = dig_site
	artefact.chronotes = chronotes

	for _, skill in ipairs(production.skills) do
		if skill.name == 'Archaeology' then
			artefact.level = skill.level
			artefact.experience = skill.experience
		end
	end

	local materials = {}
	for _, material in ipairs(production.materials) do
		if starts_with(material.name, artefact_name) then
			artefact.damaged = material.name
		else
			table.insert(materials, material)
		end
	end

	artefact.materials = materials

	return artefact
end

local function query_artefacts(names, name_indexes)
	local artefactsQuery = {}

	for _, name in ipairs(names) do
		table.insert(artefactsQuery, { 'production_main_output', name })
	end

	local query = bucket("recipe")
		.select('page_name', 'production_json', 'infobox_artefact.excavation_hotspot', 'infobox_artefact.dig_site', 'infobox_artefact.chronotes')
		.join("infobox_artefact", "infobox_artefact.page_name", "recipe.page_name")
		.where(bucket.Or(artefactsQuery))

	local bucketdata = query.run()
	if #bucketdata == 0 then
		return {}
	end

	local artefacts = {}
	for _, v in ipairs(bucketdata) do
		local production_json = mw.text.jsonDecode(v['production_json'] or '{}')
		if production_json then
			local artefact = convert_artefact(v['page_name'], production_json, v['infobox_artefact.excavation_hotspot'], v['infobox_artefact.dig_site'], v['infobox_artefact.chronotes'])
			artefacts[name_indexes[artefact.name]] = artefact
		end
	end

	return artefacts
end

local function put_artefacts_to_collection(collection_name, args)
	local names = {}
	local name_indexes = {}
	for i, v in ipairs(args) do
		local name = mw.text.trim(v)
		table.insert(names, name)
		name_indexes[name] = i
	end

	local artefacts = query_artefacts(names, name_indexes)

	for _, v in pairs(artefacts) do
		bucket('infobox_collection_artefacts').sub(v.name).put({
			collection = collection_name,
			artefact = v.name,
			index = name_indexes[v.name]
		})
	end

	return artefacts
end

local function query_collection(name)
	local query = bucket("infobox_collection")
		.select('page_name', 'name', 'first', 'recurring', 'chronotes', 'collector', 'level', 'artefacts')
		.where('name', name)

	local bucketdata = query.run()
	if #bucketdata == 0 then
		error('No collection found. Make sure spelling and capitalisation are correct.')
		return {}
	end

	return bucketdata[1]
end

local function query_artefacts_in_collection(collection_name)
	local query = bucket("infobox_collection_artefacts")
		.select('artefact', 'index')
		.where('collection', collection_name)

	local bucketdata = query.run()
	if #bucketdata == 0 then
		return {}
	end

	local names = {}
	local name_indexes = {}
	for _, v in ipairs(bucketdata) do
		table.insert(names, v.artefact)
		name_indexes[v.artefact] = v.index
	end

	return query_artefacts(names, name_indexes)
end

local function display_artefacts(collection_name, artefacts, completion_chronotes)
	local ret = mw.html.create('table')
		:addClass('wikitable lighttable sortable align-center-1')

	local table_id
	if hc(collection_name) then
		table_id = 'Archaeology Collection - ' .. collection_name;
		ret:attr("data-tableid", table_id);
	end

	ret:tr()
		:th("Level")
		:th { 'Artefact', attr = { colspan = "3" } }
		:th("XP")
		:th('[[Chronotes]]')
		:th('Hotspot')
		:th('Materials')
		:th('Material costs')

	local total_mats = {}
	local cumulative_chronotes = 0
	local total_xp = 0
	local total_price = 0

	for _, artefact in pairs(artefacts) do
		local chronotes = artefact.chronotes or '?'
		if tonumber(chronotes, 10) then
			cumulative_chronotes = cumulative_chronotes + tonumber(chronotes, 10)
		end

		local level = artefact.level
		local xp = artefact.experience
		total_xp = total_xp + xp

		local mats = mw.html.create('table')
			:addClass('products-materials')
			:attr('cellspacing', '1')
			:css('margin', '0')

		local price = 0
		for _, mat_info in ipairs(artefact.materials) do
			local qty = tonumber(mat_info.quantity, 10) or 1

			local mat_name = mat_info.name
			if total_mats[mat_name] then
				total_mats[mat_name] = total_mats[mat_name] + qty
			else
				total_mats[mat_name] = qty
			end

			local mat_price = exchange._price(mat_name, 1, nil, nil, 0)
			price = price + (mat_price * qty)

			mats:tr():addClass('nohighlight'):node(plinkqty(mat_name, qty))
		end

		total_price = total_price + price

		local source = '[[' .. artefact.hotspot .. ']]'
		if artefact.dig_site then
			source = source .. ' ([[' .. artefact.dig_site .. ']])'
		end

		ret:tr()
			:attrIf(table_id, "data-rowid", artefact.name)
			:td(level)
			:node(plinkt(artefact.name))
			:td(string.format("[[%s|(damaged)]]", artefact.damaged))
			:td(commas(xp))
			:td(currency(chronotes, 'chronotes'))
			:td(source)
			:td():node(mats:allDone())
			:td { currency(price, 'coins', true), attr = { 'data-sort-value', price } }
	end

	local mats = mw.html.create('table')
		:addClass('products-materials')
		:attr('cellspacing', '1')
		:css('margin', '0')
	for m, n in pairs(total_mats) do
		mats:tr():addClass('nohighlight'):node(plinkqty(m, n))
	end

	completion_chronotes = completion_chronotes or 0
	local chronotes_price = exchange._price('Chronotes', 1, nil, nil, 0)
	local total_chronotes = cumulative_chronotes + completion_chronotes
	local total_chronotes_price = chronotes_price * (cumulative_chronotes + completion_chronotes)
	local chronotes_total =
		currency(cumulative_chronotes, 'chronotes', true) .. ' + ' .. currency(completion_chronotes, 'chronotes', true)
		.. '<br><span style="white-space:nowrap">(' .. currency(total_chronotes, 'chronotes', true) .. ' total)</span>'
		.. '<br><span style="white-space:nowrap">(' .. currency(total_chronotes_price, 'coins', true) .. ')</span>'

	ret:tr { class = 'nohighlight sortbottom' }
		:th { 'Total', attr = { "colspan", "4" } }
		:td(commas(total_xp))
		:td(chronotes_total)
		:td { '', ['class'] = "table-na nohighlight" }
		:td():node(mats:allDone())
		:td(currency(total_price, 'coins', true))

	return tostring(ret:allDone())
end

local function display_collection_summary(collection)
	local show_intro = true
	if not show_intro then
		return
	end

	local onetime_str = 'N/A'
	if collection.first then
		local first = collection.first
		if collection.chronotes then
			table.insert(first, commas(collection.chronotes) .. ' [[chronotes]]')
		end

		onetime_str = mw.text.listToText(first)
	end

	local recurring_str = ''
	local recurring = {}
	
	if collection.recurring then
		recurring = collection.recurring
	end

	if recurring[1] ~= 'No' then
		if collection.chronotes then
			table.insert(recurring, commas(collection.chronotes) .. ' [[chronotes]]')
		end

		recurring_str = mw.text.listToText(recurring)
	end

	if recurring_str == '' then
		recurring_str = 'N/A'
	end

	local intro = string.format(
		"* '''Archaeology level required:''' %s\n* '''First time reward:''' %s\n* '''Recurring reward:''' %s\n",
		collection.level, onetime_str, recurring_str
	)

	return intro
end

function p._query_collection(name)
	return query_collection(name)
end

function p._query_artefacts_in_collection(collection_name)
	return query_artefacts_in_collection(collection_name)
end

function p._put_artefacts_to_collection(args)
	local collection_arg = args.name

	local collection_name
	if hc(collection_arg) then
		collection_name = collection_arg
	elseif onmain() then
		local t = mw.title.getCurrentTitle();
		collection_name = t.text;
	end

	local artefacts = put_artefacts_to_collection(collection_name, args)
	local chronotes_arg = args.chronotes or args.collectionCompletionChronotesBonus or args.collectioncompletionchronotesbonus

	return display_artefacts(collection_name, artefacts, chronotes_arg)
end

function p._show_collection(args)
	local collection_name = args[1]
	if not hc(collection_name) then
		error('No collection found. Make sure spelling and capitalisation are correct.')
	end

	local collection = query_collection(collection_name)
	local artefacts = query_artefacts_in_collection(collection_name)

	local ret = display_collection_summary(collection)
	return ret .. display_artefacts(collection.name, artefacts, collection.chronotes)
end

function p.show_collection(frame)
	local args = frame:getParent().args
	return p._show_collection(args)
end

function p.put_artefacts_to_collection(frame)
	local args = frame:getParent().args
	return p._put_artefacts_to_collection(args)
end

return p
-- </nowiki>