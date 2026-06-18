local p = {}

local commas = require('Module:Addcommas')
local skillPic = require('Module:SCP')._main
local yesNo = require('Module:Yesno')
local lang = mw.getContentLanguage()
local trim = mw.text.trim
local split = mw.text.split
local jsonDecode = mw.text.jsonDecode

-- remove when sailing releases
local contains = require('Module:Array').containsAny
--

function buildRow(recipe, facility)
	local ret = mw.html.create('tr')
	
	-- Outputs
	ret:tag('td'):wikitext(string.format('[[File:%s|class=inventory-image|link=%s]]', recipe.output.image, recipe.output.name))
	ret:tag('td'):attr('data-sort-value', recipe.output.name):wikitext(commas._add(recipe.output.quantity) .. ' × [[' .. recipe.output.name .. ']]' .. (recipe.output.subtxt ~= nil and '<br/><small>(' .. recipe.output.subtxt .. ')</small>' or ''))

	-- Members
	if(yesNo(recipe.members)) then
		ret:tag('td'):wikitext("[[File:Member icon.png|center|link=Members|alt=Members]]")
	elseif(not yesNo(recipe.members)) then
		ret:tag('td'):wikitext("[[File:Free-to-play icon.png|center|link=Free-to-play|alt=Free-to-play]]")
	end
	
	--Facility
	local facilityList = mw.html.create('ul'):addClass('products-materials')
	local facilitySortValue = nil
	local facilities = split(recipe.facilities, ",")
	for i, facil in ipairs(facilities) do
		facilityList:tag('li'):attr('data-sort-value', i == 1 and facil or ''):wikitext(facil) -- For highlighting _all_ facilities --- :addClass('production-selected')
	end
	ret:tag('td'):addClass('plainlist'):node(facilityList)
	
	-- Skills (level)
	-- Skills (xp)
	local skillList = mw.html.create('ul'):addClass('skills-list')
	local xpList = mw.html.create('ul'):addClass('skills-list')
	
	if(#recipe.skills == 0) then
		skillList:tag('li'):wikitext('None')
		xpList:tag('li'):wikitext('None')
		ret:tag('td'):addClass('table-na plainlist'):node(skillList)
		ret:tag('td'):addClass('table-na plainlist'):node(xpList)
	else
		for i, skill in ipairs(recipe.skills) do
			skillList:tag('li'):attr('data-sort-value', i == 1 and skill.level or ''):wikitext(skillPic(lang:ucfirst(skill.name), skill.level))
			xpList:tag('li'):attr('data-sort-value', i == 1 and skill.experience or ''):wikitext(commas._strip(skill.experience) ~= nil and skillPic(lang:ucfirst(skill.name), skill.experience) or skill.experience)
		end
		ret:tag('td'):addClass('plainlist'):node(skillList)
		ret:tag('td'):addClass('plainlist'):node(xpList)
	end

	-- Inputs
	local matList = mw.html.create('ul'):addClass('products-materials')
	local materialSortValue = nil
	for _, mat in ipairs(recipe.materials) do
		local quantity = string.gsub(mat.quantity, '%-', '–')
		if(materialSortValue == nil) then
			materialSortValue = quantity
		end
		   
        local image_txt = string.format('<span style="width:27px; display:inline-block; text-align:center;">[[File:%s|link=%s]]</span>', mat.image or mat.name .. '.png', mat.name)
        matList:tag('li'):wikitext(string.format('%s × %s [[%s]]', commas._add(quantity), image_txt, mat.name))
	end
	ret:tag('td'):addClass('plainlist'):attr('data-sort-value', materialSortValue):node(matList)
	
	return ret
end

function createHeader()
	local header = mw.html.create('table'):addClass('wikitable sortable products-list align-center-1 align-left-2 align-center-3'):done()
		header:tag('tr'):tag('th'):attr('colspan', '2'):wikitext('Product'):done()
			:tag('th'):wikitext('Members'):done()
			:tag('th'):wikitext('Facility'):done()
			:tag('th'):attr('data-sort-type', 'number'):wikitext('Skills'):done()
			:tag('th'):attr('data-sort-type', 'number'):wikitext('XP'):done()
			:tag('th'):wikitext('Materials'):done()
	return header
end

-- If both variables contain the same element as part of a list (or single string)
function bothContain(argOne, argTwo)
	if(argOne == nil) or (argOne == '') or (argTwo == nil) or (argTwo == '') then
		return false
	elseif((type(argOne) == 'string') and (string.find(argOne, ',') == nil)) and ((type(argTwo) == 'string') and (string.find(argTwo, ',') == nil)) then
		return trim(argOne) == trim(argTwo)
	else
		if(type(argOne) == 'string') then
			argOne = split(argOne, "%s*,%s*")
		end
		if(type(argTwo) == 'string') then
			argTwo = split(argTwo, "%s*,%s*")
		end
		for i, v in ipairs(argOne) do
			for j, w in ipairs(argTwo) do
				if(trim(w) == trim(v)) then
					return true
				end
			end
		end
		return false
	end
end

function p.loadData(facilities, limit, offset)
	-- Fetch data
    local conds = {}
    for _, fac in ipairs(facilities) do
		table.insert(conds, {"uses_facility", fac})
    end
    
	
	local t1 = os.clock()
    local query = bucket("recipe")
    	.select('page_name', 'production_json')
    	.where(bucket.Or(conds))
    	.orderBy('page_name', 'asc')
 
    local bucket_data = query.run()
    local t2 = os.clock()

    if not bucket_data then
        return 'Failed to find products using those facilities - ensure they are spelled correctly. (ERR: no results from Bucket)[[Category:Empty drop lists]]'
    end
    
    mw.log(string.format('Bucket: entries %d, time elapsed: %.3f ms.', #bucket_data, (t2 - t1) * 1000))

    -- Post-process
    local data = {}

    for _, e in ipairs(bucket_data) do
    	if type(e.production_json) == 'string' then
            local json = mw.text.jsonDecode(e.production_json)
            table.insert(data, json)
    	end
    end

	-- Remove recipes that do not use at least one of the input facilities
	-- Iterate in reverse so pops do not interrupt iteration
	for i = #data, 1, -1 do
		if(not bothContain(facilities, data[i].facilities)) then
			table.remove(data, i)
		end
	end
	
	-- Sort table values by order of facility input
	if((#facilities == 1) or (#data == 1)) then
		return data
	else
		local ret = {}
		-- This tracks the current position of where inserts should occur
		local facilityCountOffset = {}
		for i = 1, #facilities, 1 do
			table.insert(facilityCountOffset, 0)
		end
		for i, recipe in ipairs(data) do
			local pos = 0
			for j, facil in ipairs(facilities) do
				pos = pos + facilityCountOffset[j]
				if(bothContain(recipe.facilities, facil)) then
					table.insert(ret, pos + 1, recipe)
					facilityCountOffset[j] = facilityCountOffset[j] + 1
					break
				end
			end
		end
		return ret
	end
end

function p._main(args)
	local facility = args ~= nil and args[1] or mw.title.getCurrentTitle().text

	local facilities = {}
	if(string.find(facility, ',') == nil) then
		table.insert(facilities, trim(facility))
	else
		for _, facil in ipairs(split(facility, ",")) do
			table.insert(facilities, trim(facil))
		end
	end
	
	local data = p.loadData(facilities, args.limit, args.offset)
	
	if(data == nil) then
		return 'Failed to find products using that facility - ensure it is spelled correctly. (ERR: no results from Bucket)[[Category:Empty drop lists]]'
	end
	
	local ret = createHeader()
	for _, recipe in ipairs(data) do
		ret:node(buildRow(recipe, facilities))
	end
	
	return tostring(ret)
end

--[[ DEBUG
= p._main({'Anvil'})
= p._main({'Crafting table 1, Crafting table 2'})
--]]

function p.main(frame)
	--mw.logObject(frame)
	local args = frame:getParent().args
	return p._main(args)
end

return p