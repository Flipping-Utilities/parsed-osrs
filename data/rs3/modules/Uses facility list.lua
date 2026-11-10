require('strict')

local commas = require('Module:Addcommas')
local skillPic = require('Module:Skill clickpic')._main
local hc = require('Module:Paramtest').has_content
local yesNo = require('Module:Yesno')
local lang = mw.getContentLanguage()
require("Module:Mw.html extension")

local p = {}

local function splitComma(arg)
	return mw.text.split(arg or '', "%s*,%s*")
end

local function buildItemTable(items)
	local items_table = mw.html.create('table')
		:addClass('products-materials')
		:attr { cellspacing = 0 }
		:css { margin = 0 }

	local sort_value = nil
	for _, item in ipairs(items) do
		local quantity = string.gsub(item.quantity, '%-', '–')
		if sort_value == nil then
			sort_value = quantity
		end

		items_table:tr()
			:td {
				string.format("%s × ", commas._add(quantity)),
				css = {
					['text-align'] = 'right',
					['white-space'] = 'pre',
				}
			}
			:td {
				(item.image ~= nil and item.image:lower() ~= "no") and ('[[File:' .. item.image .. '|link=' .. item.page .. ']]') or '',
				css = {
					['text-align'] = 'center',
				}
			}
			:td {
				string.format(' [[%s|%s]]', item.page, item.txt or item.name),
				css = {
					['text-align'] = 'left',
					['white-space'] = 'pre',
					['width'] = '100%',
				}
			}
	end

	return items_table, sort_value
end

local function buildRow(recipe, facility)
	local ret = mw.html.create('tr')

	-- Outputs
	local outputs_table, outputs_sort_value = buildItemTable(recipe.outputs)

	ret
		:td()
		:addClass('plainlist')
		:attr('data-sort-value', outputs_sort_value)
		:node(outputs_table)
		:wikitext((recipe.method ~= "" and '<small>(' .. recipe.method .. ')</small>' or ''))

	-- Members
	if (yesNo(recipe.members)) then
		ret:td("[[File:P2P icon.png|x19px|link=Members|Members]]")
	elseif (not yesNo(recipe.members)) then
		ret:td("[[File:F2P icon.png|x19px|link=Free-to-play|Free-to-play]]")
	end

	--Facility
	local facilityList = mw.html.create('ul'):addClass('products-materials')
	local facilities = splitComma(recipe.facility)
	for i, facil in ipairs(facilities) do
		facil = mw.text.split(facil, '|')[1]
		if recipe.glyphType and recipe.glyphType ~= '' then
			facil = string.format('%s<br><small>(%s)</small>', facil, recipe.glyphType)
		end
		facilityList:tag('li'):attr('data-sort-value', i == 1 and facil or ''):wikitext(facil) -- For highlighting _all_ facilities --- :addClass('production-selected')
	end
	ret:td():addClass('plainlist'):node(facilityList)

	-- Skills (level)
	-- Skills (xp)
	local skillList = mw.html.create('ul'):addClass('skills-list')
	local xpList = mw.html.create('ul'):addClass('skills-list')

	if (#recipe.skills == 0) then
		skillList:tag('li'):wikitext('None')
		xpList:tag('li'):wikitext('None')
		ret:tag('td'):addClass('table-na plainlist'):css('text-align', 'center'):node(skillList)
		ret:tag('td'):addClass('table-na plainlist'):css('text-align', 'center'):node(xpList)
	else
		for i, skill in ipairs(recipe.skills) do
			skillList
				:tag('li')
				:attr('data-sort-value', i == 1 and skill.level or '')
            if skill.level == '?' or skill.level == 'Varies' then
                skillList:wikitext(skill.level .. ' ' .. skillPic(lang:ucfirst(skill.name)))
            else
                skillList:wikitext(skillPic(lang:ucfirst(skill.name), skill.level))
            end
            local experience = tonumber(string.gsub(skill.experience, ',', ''), 10)
			xpList
				:tag('li')
				:attr('data-sort-value', i == 1 and skill.experience or '')
				:wikitext(experience ~= nil and skillPic(lang:ucfirst(skill.name), experience) or skill.experience)
		end
		ret:td():addClass('plainlist'):node(skillList)
		ret:td():addClass('plainlist'):node(xpList)
	end

	-- Inputs
	local mats_table = mw.html.create('table')
		:addClass('products-materials')
		:attr { cellspacing = 0 }
		:css { margin = 0 }
	local materialSortValue = 0
	for _, mat_info in ipairs(recipe.materials or recipe.mats) do
		local qty = string.gsub(mat_info.quantity, '%-', '–')
		mats_table:tr()
			:td {
				string.format("%s × ", commas._add(qty)),
				css = {
					['text-align'] = 'right',
					['white-space'] = 'pre',
				}
			}
			:td {
				(mat_info.image ~= nil and mat_info.image:lower() ~= "no") and ('[[File:' .. mat_info.image .. '|link=' .. mat_info.page .. ']]') or '',
				css = {
					['text-align'] = 'center',
				}
			}
			:td {
				string.format(' [[%s|%s]]', mat_info.page, mat_info.txt or mat_info.name),
				css = {
					['text-align'] = 'left',
					['white-space'] = 'pre',
					['width'] = '100%',
				}
			}
	end
	ret:td():addClass('plainlist'):attr('data-sort-value', materialSortValue):node(mats_table)

	return ret:allDone()
end

local function createHeader(class, data)
	local header = mw.html.create("table")
		:addClass("wikitable sortable mw-collapsible sticky-header products-list align-center-2 align-center-3 align-right-4 align-right-5")
		:addClassIf(hc(class), class)
		:tr()
		:th("Product")
		:th("Members")
		:th("Facility")
		:th { "Skills", attr = { "data-sort-type", "number" } }
		:th { "XP", attr = { "data-sort-type", "number" } }
		:th("Materials")
	return header:allDone()
end

local function addRecipeByFacilities(data, recipe, facilities)
	local recipeFacilities = splitComma(recipe.facility)
	for _, rf in ipairs(recipeFacilities) do
		rf = mw.text.split(rf, '|')[1]
		for _, f in ipairs(facilities) do
			if mw.text.trim(rf) == mw.text.trim(f) then
				table.insert(data, recipe)
			end
		end
	end

	return false
end

function p.loadData(facilities, limit, offset)
	-- Fetch data
	local conds = {}
	for _, fac in ipairs(facilities) do
		table.insert(conds, { "uses_facility", fac })
	end

	local t1 = os.clock()
	local bucket_data = bucket("recipe")
		.select("page_name_sub", "production_json")
		.where(bucket.Or(conds))
		.limit(limit)
		.offset(offset)
		.orderBy('page_name_sub', 'ASC')
		.run()
	local t2 = os.clock()

	if (bucket_data == nil) then
		return nil
	end
	mw.log(string.format('Uses facility list: Bucket: entries %d, time elapsed: %.3f ms.', #bucket_data, (t2 - t1) * 1000))

	local data = {}
	for _, v in ipairs(bucket_data) do
		if type(v.production_json) == 'string' then
			local production = mw.text.jsonDecode(v.production_json)
			addRecipeByFacilities(data, production, facilities)
		end
	end

	return data
end

function p._main(args)
	local facility = args ~= nil and args[1] or mw.title.getCurrentTitle().text
	local facilities = splitComma(facility)
	local data = p.loadData(facilities, args.limit, args.offset)

	if data == nil then
		return 'Failed to find products using that facility - ensure it is spelled correctly. (ERR: no results from Bucket)[[Category:Empty drop lists]]'
	end

	local ret = createHeader(args.class, data)
	for _, recipe in ipairs(data) do
		ret:node(buildRow(recipe, facilities))
	end

	return ret:allDone()
end

--[[ DEBUG
= p._main({'Anvil'})
= p._main({'Crafting table 1, Crafting table 2'})
--]]

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

return p