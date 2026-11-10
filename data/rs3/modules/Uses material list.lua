require("strict")
local p = {}
local plink = require("Module:Plink")._plink
local geprice = require('Module:ExchangeLite').price
local gevol = require("Module:Exchange")._volume
local commas = require('Module:Addcommas')._add
local skillpic = require('Module:Skill_clickpic')._main
local hc = require('Module:Paramtest').has_content
local yesno = require('Module:Yesno')
local purge = require('Module:Purge')._purge
local lang = mw.getContentLanguage()
local arr = require('Module:Array')

local TOOLBELT_TAG = '<sup>(<span class="hover-text" title="This item can be added to the tool belt. Some items are automatically added by default."}}>tb</span>)</sup>'
local QUERY_LIMIT = 50
local toolsList, toolbeltTools, processIcons, facilitiesIcons, facilitiesList
local auxiliaryOrder = { "process", "tool", "facility" }
do
    local _data = mw.loadData("Module:Infobox Recipe/data")
    toolsList = _data.toolsList
    toolbeltTools = _data.toolbeltTools
    processIcons = _data.processIcons
    facilitiesIcons = _data.facilitiesIcons
    facilitiesList = _data.facilitiesList
end

local function toolLink(name, txt)
    local toolbelt_tag = arr.contains(toolbeltTools, name) and TOOLBELT_TAG or ''
    return (txt or plink(name)) .. toolbelt_tag
end

local function toolToAuxiliaryLink(item)
    local tools = toolsList[item]
    if type(tools) == "table" then
        local link = toolLink(item, tools[1])
        local altTool = tools.alt
        if altTool then
            link = link .. " /&nbsp;" .. toolLink(altTool)
        end
        return link
    else
        return toolLink(item, tools)
    end
end

local function processToAuxiliaryLink(item)
    local processIcon = processIcons[item]
    if processIcon ~= nil then
        return string.format("%s [[%s]]", processIcon, item)
    else
        return string.format("[[%s]]", item)
    end
end

local function facilityToAuxiliaryLink(item)
    local facilities = facilitiesList[item]
    if facilities ~= nil then
        return string.format("%s", facilities)
    end

    local facilitiesIcon = facilitiesIcons[item]
    if facilitiesIcon ~= nil then
        return string.format("%s [[%s]]", facilitiesIcon, item)
    else
        return string.format("[[%s]]", item)
    end
end

local function toAuxiliaryLink(kind, txt)
    local links = {}
    local items = mw.text.split(txt, "%s*,%s*")
    for _, item in ipairs(items) do
        if kind == "tool" then
            table.insert(links, toolToAuxiliaryLink(item))
        elseif kind == "process" then
            table.insert(links, processToAuxiliaryLink(item))
        elseif kind == "facility" then
            table.insert(links, facilityToAuxiliaryLink(item))
        end
    end

    return table.concat(links, ", ")
end

local function shouldHideAuxiliary(bucket_data)
    for _, bucket_item in ipairs(bucket_data) do
        for _, v in ipairs(auxiliaryOrder) do
            local auxiliary = bucket_item.production_json[v] or ""
            if auxiliary ~= "" then
                return false
            end
        end
    end

    return true
end

local function cleanName(name)
    local cleaned = string.gsub(name, "%p", "")

    if #cleaned then
        return cleaned
    end

    return name
end

local dyeList = {
	'barrows',
	'shadow',
	'ice',
	'third age',
	'blood',
	'aurora',
	'soul',
	'red',
	'orange',
	'yellow',
	'green',
	'blue',
	'purple',
	'black',
	'pink'
}

local function dyeName(name)
	local lowerName = string.lower(name)
	
	for _,dye in ipairs(dyeList) do
		if string.find(lowerName, "%(" .. dye .. "%)") then
			return dye
		end
	end
	return name
end

local function cleanNameSort(t1, t2)
	local clean1 = cleanName(t1.page_name)
	local clean2 = cleanName(t2.page_name)
	local dye1 = dyeName(t1.page_name)
	local dye2 = dyeName(t2.page_name)
	
	if dye1 ~= dye2 then
		return dye1 < dye2
	end
	return clean1 < clean2
end

local function progressionSort(bucketData)
    local recordsByOutput = {}
    local dependencyCounts = {}
    local dependents = {}

    for _, bucketItem in ipairs(bucketData) do
        dependencyCounts[bucketItem] = 0
        dependents[bucketItem] = {}

        local output = bucketItem.production_json.outputs and bucketItem.production_json.outputs[1]
        if output then
            if output.page then
                recordsByOutput[output.page:lower()] = bucketItem
            end
            if output.name then
                recordsByOutput[output.name:lower()] = bucketItem
            end
        end
    end

    for _, bucketItem in ipairs(bucketData) do
        local dependencies = {}

        for _, material in ipairs(bucketItem.production_json.materials or {}) do
            local predecessor = material.page and recordsByOutput[material.page:lower()]
                or material.name and recordsByOutput[material.name:lower()]

            if predecessor and predecessor ~= bucketItem then
                dependencies[predecessor] = true
            end
        end

        for predecessor in pairs(dependencies) do
            dependencyCounts[bucketItem] = dependencyCounts[bucketItem] + 1
            table.insert(dependents[predecessor], bucketItem)
        end
    end

    local available = {}
    for _, bucketItem in ipairs(bucketData) do
        if dependencyCounts[bucketItem] == 0 then
            table.insert(available, bucketItem)
        end
    end

    local ordered = {}
    local processed = {}
    while #available > 0 do
        table.sort(available, cleanNameSort)
        local bucketItem = table.remove(available, 1)
        table.insert(ordered, bucketItem)
        processed[bucketItem] = true

        for _, dependent in ipairs(dependents[bucketItem]) do
            dependencyCounts[dependent] = dependencyCounts[dependent] - 1
            if dependencyCounts[dependent] == 0 then
                table.insert(available, dependent)
            end
        end
    end

    local remaining = {}
    for _, bucketItem in ipairs(bucketData) do
        if not processed[bucketItem] then
            table.insert(remaining, bucketItem)
        end
    end
    table.sort(remaining, cleanNameSort)

    for _, bucketItem in ipairs(remaining) do
        table.insert(ordered, bucketItem)
    end

    for index, bucketItem in ipairs(ordered) do
        bucketData[index] = bucketItem
    end
end

local function askBucket(name, limit)
    local records = bucket("recipe")
        .select("page_name", "production_json", "Category:Removed content", "Category:Pages using information from game APIs or cache", "Category:Historical article")
        .where('uses_material', name)
		.where(bucket.Not("Category:Dyed equipment"))
        .limit(limit)
        .orderBy('page_name', 'asc')
        .run()
	
	if #records < limit then
		local dyeRecords = bucket("recipe")
			.select("page_name", "production_json", "Category:Removed content", "Category:Pages using information from game APIs or cache", "Category:Historical article")
			.where('uses_material', name)
			.where("Category:Dyed equipment")
			.limit(limit - #records)
			.orderBy('page_name', 'asc')
			.run()
		
		for _, record in ipairs(dyeRecords) do
			table.insert(records, record)
		end
	end

    if records == nil then
        return nil
    end

    local return_records = {}
    for _, r in ipairs(records) do
        local json = mw.text.jsonDecode(r.production_json or '{}')
        if json.outputs then -- Filter out things like skilling methods that don't produce any output
            r.production_json = json
            table.insert(return_records, r)
        end
    end

    return return_records
end

function p.main(frame)
    return p._main(frame:getParent())
end

local function stripDoseName(name)
    return string.gsub(name, ' ?%(%d+%)$', '')
end

local function findInRecipe(tbl, target)
    if tbl == nil then
        return nil
    end

    for _, item in ipairs(tbl) do
        if item.page == target then
            return item
        end
    end

    return nil
end

local function roundToInt(num)
	if num >= 0 then
		return math.floor(num + 0.5)
	end
	
	return math.ceil(num - 0.5)
end

local function geVolume(item, noCommas)
	local vol = nil

    if hc(item) then
        vol = gevol(item)
        if vol and not noCommas then
        	vol = commas(vol)
    	end
    end

    return vol
end

function p._main(frame)
    local args = frame.args
    local material = args[1] or args.material or mw.title.getCurrentTitle().text

    --mw.log('[Uses material list] looking for material: ' .. material)
    local bucket_records = askBucket(material, tonumber(args.limit) or QUERY_LIMIT)

    local verscount = 0
    if args.versions then
        local vernum = tonumber(args.versions)
        if vernum then
            verscount = math.floor(vernum)
        end
    end

    local res = {}
    if verscount > 0 then
        local variant_recipes = {}
        local prefix = stripDoseName(material)

        for vers = 1, verscount, 1 do
            local versname = prefix .. ' (' .. vers .. ')'
            --mw.log('[Uses material list] looking for material: ' .. versname)

            local ver_data = askBucket(versname, tonumber(args.limit) or QUERY_LIMIT)
            -- local verres = p.printTable(args, versname, bucket_data)

            variant_recipes[vers] = { portion = tostring(vers), name = versname, data = ver_data }
        end

        for _, r in ipairs(bucket_records or {}) do
            local item = findInRecipe(r.production_json.materials, prefix)

            if item ~= nil then
                local target_group = variant_recipes[item.portion or 1]
                if target_group == nil then
                    variant_recipes[item.portion or 1] = { portion = tostring(item.portion), name = item.name, data = { r } }
                else
                    table.insert(target_group.data, r)
                end
            end
        end

        local ordered_variants = {}
        for _, r in pairs(variant_recipes) do
            table.insert(ordered_variants, r)
        end

        table.sort(ordered_variants, function(a, b)
            return a.portion < b.portion
        end)

        local rescount = 0
        local emptyvers = {}
        for _, v in ipairs(ordered_variants) do
            local verres = p.printTable(args, v.name, v.data)
            if not verres then
                table.insert(emptyvers, v.name)
            else
                if args.headers and hc(args.headers) then
                    if string.lower(args.headers) == 'potion' or string.lower(args.headers) == 'potions' then
                        table.insert(res, string.format('===From %s doses===', v.portion))
                    else
                        table.insert(res, string.format('===' .. args.headers .. '===', v.name))
                    end
                else
                    table.insert(res, '===' .. v.name .. '===')
                end

                table.insert(res, verres)
                rescount = rescount + 1
            end
        end

        if rescount == 0 then
            return
            'Failed to find products with that material and versions - ensure it is spelled correctly and version count is correct. (ERR: no results from Bucket)[[Category:Empty drop lists]]'
        end

        if #emptyvers > 0 then
            table.insert(res, 1, '')
            local str = string.format(
                "The following versions have no products: %s. This, and the following lists are auto-generated (%s).",
                table.concat(emptyvers, ', '), purge('Products', 'click here to update', 'span'))
            table.insert(res, 1, str)
        end

        return table.concat(res, '\n')
    elseif not bucket_records or #bucket_records == 0 then
        return 'Failed to find products with that material - ensure it is spelled correctly. (ERR: no results from Bucket)[[Category:Empty drop lists]]'
    else
        return p.printTable(args, material, bucket_records) or
            'Failed to find products with that material - ensure it is spelled correctly. (ERR: no mat found in results)[[Category:Empty drop lists]]'
    end
end

local function editbtn(prodLink)
    return '[' .. tostring(mw.uri.fullUrl(prodLink, 'action=edit')) .. ' ' .. ('(edit)') .. ']'
end

local function itemLink(item)
    local prodLink = item.page
    local prodVariant = item.variant

    local namestr = ""
    if prodVariant then
        namestr = string.format('%s#%s', prodLink, prodVariant)
    else
        namestr = string.format('%s', prodLink)
    end

    return namestr
end

local function itemDisplay(item)
    local prodLink = item.page
    local prodVariant = item.variant
    local prodName = item.name

    local namestr = ""
    if prodVariant and prodName then
        namestr = string.format('[[%s#%s|%s]]', prodLink, prodVariant, prodName)
    elseif prodVariant then
        namestr = string.format('[[%s#%s|%s]]', prodLink, prodVariant, prodLink)
    elseif prodName then
        namestr = string.format('[[%s|%s]]', prodLink, prodName)
    else
        namestr = string.format('[[%s]]', prodLink)
    end

    return namestr
end

local function itemImg(item)
    local mat_img_src = item.image
    if mat_img_src ~= nil and mat_img_src ~= "no" then
        return '[[File:' .. mat_img_src .. '|link=' .. itemLink(item) .. '|30x30px|frameless]]'
    else
        return ''
    end
end

local function printRow(t, recipe, material, hideGE, hideGEVolume, hideAuxiliary, showprofit, historic, cacheOnly)
    local prow = t:tag('tr')

    local output = recipe.outputs[1]
	if output == nil then
		return nil
	end
    local namestr = itemDisplay(output)

    if namestr ~= '' then
        namestr = string.format('%s × %s', commas(output.quantity or 1), namestr)
    end

    if string.find(recipe.method or '', '%S') then
        namestr = namestr .. string.format('<br><small>(%s)</small>', recipe.method)
    end

    local improved = tonumber(recipe.improved) or 0
    if improved > 0 then
        namestr = namestr .. string.format('<br><small>(Improved +%s recipe)</small>', recipe.improved)
    end

    if historic then
        namestr = namestr .. '<span title="Previously used" style="cursor:help;"><small><b> †</b></small></span>'
        prow.addClass('products-hist')
    end
    if cacheOnly then
        namestr = namestr .. '<span title="From the game APIs or cache" style="cursor:help;"><small><b> ‡</b></small></span>'
    end

    local mats_table = mw.html.create('table')
    mats_table:addClass('products-materials')
        :attr{
            cellspacing = 0,
        }
        :css{
            margin = 0,
        }

    local mats_sort = 0
    local cost_raw = 0
    local found_material = false
    for _, mat_info in ipairs(recipe.materials) do
        local mat_tr = mats_table:tag('tr')

        local qty = string.gsub(mat_info.quantity, '%-', '–')

        local matpage = mat_info.page
        local matnm = mat_info.name
        local matnm_lc = matnm:lower()
        local mat_lc = material:lower()
        if matnm_lc == mat_lc or matpage:lower() == mat_lc then
            found_material = true
            mat_tr:addClass('production-selected')
            mats_sort = tonumber(qty) or 0
        end

        local product = string.format('%s × ', commas(qty))
        local matimg = itemImg(mat_info)

        mat_tr:tag('td')
            :css{
                ['text-align'] = 'right',
                ['white-space'] = 'pre',
            }
            :wikitext(product)
            :tag('td')
            :css{
                ['text-align'] = 'center',
            }
            :wikitext(matimg)
            :tag('td')
            :css{
                ['text-align'] = 'left',
                ['white-space'] = 'pre',
                ['width'] = '100%',
            }
            :wikitext('&nbsp;')
            :wikitext(itemDisplay(mat_info))
        local price = (matnm_lc == "coins" and 1) or geprice(matnm) or 0
        cost_raw = cost_raw + price * (qty or 1)
    end

    if found_material == false then
        return nil
    end

    local price_raw, price_total
    if not hideGE or showprofit then
        price_raw = geprice(output.name or output.page)
        if price_raw then
            price_total = roundToInt(price_raw * (output.quantity or 1))
        end
    end

    local price_cell
    if not hideGE then
        price_cell = mw.html.create('td')

        if price_raw then
            price_cell:wikitext(commas(price_total))
                :attr('data-sort-value', price_total)
        else
            price_cell:wikitext('N/A')
                :addClass('table-na')
                :attr{ ['title'] = 'This item has no available Grand Exchange price.', ['data-sort-value'] = "0" }
                :css('text-align', 'center')
        end
    end

    local volume_cell
	if not hideGEVolume then
	    volume_cell = mw.html.create('td')
	    local volume
	
	    if price_raw then
	        volume = geVolume(output.name or output.page)

			if volume then
				volume_cell:wikitext(volume)
			end
	    end

	    if not volume then
            volume_cell:wikitext('N/A')
                :addClass('table-na')
                :attr{ ['title'] = 'This item has no available Grand Exchange volume.', ['data-sort-value'] = "-1" }
                :css('text-align', 'center')
        end
	end

    local memberstr
    local members = yesno(recipe.members, nil)
    if members == true then
        memberstr = "[[File:P2P icon.png|30px|link=Members|alt=Members]]"
    elseif members == false then
        memberstr = "[[File:F2P icon.png|30px|link=Free-to-play|alt=Free-to-play]]"
    else
        memberstr = '<small>Unknown</small><br>' .. editbtn(output.name)
    end

    local skills_cell = mw.html.create('td')
    skills_cell:addClass('plainlist')

    local skills_ul = skills_cell:tag('ul')
    skills_ul:addClass('skills-list')

    local experience_cell = mw.html.create('td')
    experience_cell:addClass('plainlist')

    local experience_ul = experience_cell:tag('ul')
    experience_ul:addClass('skills-list')

    if #recipe.skills == 0 then
        local skill_li = skills_ul:tag('li')
        skill_li:wikitext(string.format('None'))
        skills_cell:addClass('table-na'):css('text-align', 'center')

        local experience_li = experience_ul:tag('li')
        experience_li:wikitext(string.format('None'))
        experience_cell:addClass('table-na'):css('text-align', 'center')
    else
        for index, v in ipairs(recipe.skills) do
            local skill_li = skills_ul:tag('li')
            skill_li
                :attr('data-sort-value', index == 1 and v.level or '')
            if v.level == '?' or v.level == 'Varies' then
                skill_li:wikitext(v.level .. ' ' .. skillpic(lang:ucfirst(v.name)))
            else
                skill_li:wikitext(skillpic(lang:ucfirst(v.name), v.level))
            end
            local experience_li = experience_ul:tag('li')
            local experience = tonumber(string.gsub(v.experience, ',', ''), 10)
            experience_li
                :attr('data-sort-value', index == 1 and v.experience or '')
                :wikitext(experience ~= nil and skillpic(lang:ucfirst(v.name), experience) or v.experience)
        end
    end

    local auxiliary_cell
    if not hideAuxiliary then
        -- Process/Facility/Tool. Not a great way to generalise this unless all of
        -- these, plus "skill used", are collected under something like "auxiliary"
        auxiliary_cell = mw.html.create('td')

        local auxiliaryList = {}
        for _, v in ipairs(auxiliaryOrder) do
            local auxiliaryLink = recipe[v] and toAuxiliaryLink(v, recipe[v]) or ""
            if auxiliaryLink ~= "" then
                table.insert(auxiliaryList, auxiliaryLink)
            end
        end

        if #auxiliaryList > 0 then
            auxiliary_cell:wikitext(table.concat(auxiliaryList, ", "))
        else
            auxiliary_cell:wikitext(string.format('N/A')):addClass('table-na'):css('text-align', 'center')
        end
    end

    prow
    -- Item (image)
        :tag('td')
        :addClass('inventory-image')
        :wikitext(itemImg(output))
        :done()
        :tag('td')
        :attr('data-sort-value', cleanName(output.name))
        :wikitext(namestr)
        :done()
    -- Members
        :tag('td')
        :wikitext(memberstr)
        :done()

    -- Process/Facility/Tool
    if not hideAuxiliary then
        prow:node(auxiliary_cell)
    end

    prow
    -- Skills
        :node(skills_cell)
    -- Experience
        :node(experience_cell)
    -- Materials
        :tag('td')
        :attr('data-sort-value', mats_sort)
        :node(mats_table)
        :done()

    -- Grand Exchange price
    if not hideGE then
        prow:node(price_cell)
    end

    -- Grand Exchange volume
    if not hideGEVolume then
        prow:node(volume_cell)
    end

    -- Profit
    if showprofit then
        if price_raw then
            local profit1 = roundToInt(price_total - cost_raw)
            local profclass = profit1 >= 0 and 'text-green' or 'text-red'
            prow
                :tag('td')
                :wikitext(commas(profit1))
                :addClass(profclass)
                :attr('data-sort-value', profit1)
        else
            prow
                :tag('td')
                :wikitext('N/A')
                :addClass('table-na')
                :attr{ ['title'] = 'This item has no available GE price.', ['data-sort-value'] = 0 }
                :css('text-align', 'center')
        end
    end
    return true
end

function p.printTable(args, material, bucket_data)
    local hideGE = yesno(args.hideGE or args.hidege) or false
    local hideGEVolume = yesno(args.hideGEVolume or args.hidegevolume) or false
    local showProfit = yesno(args.profit) or false

    if hideGE then
        hideGEVolume = true
    end

    local intro = ''
    if #bucket_data >= QUERY_LIMIT then
        intro = string.format(
        "<div class='seealso prodlistintro'>For an exhaustive list of all products, see <span class='plainlinks'>[%s here]</span>.</div>",
        tostring(mw.uri.fullUrl('RuneScape:Autolists/full')) ..
        '#' .. mw.uri.buildQueryString{ type = 'products', page = material }) .. '\n'
    end

    if args.sort and args.sort:lower() == "progression" then
        progressionSort(bucket_data)
    else
        table.sort(bucket_data, cleanNameSort)
    end

    local hideAuxiliary = shouldHideAuxiliary(bucket_data)

    local columns = 0
    local t = mw.html.create('table'):addClass('wikitable sortable products-list sticky-header')
    if hc(args.class) then
        t:addClass(args.class)
    end

    local ttlrow = t:tag('tr')
        :tag('th')
        :attr('colspan', '2')
        :wikitext('Product')
        :done()
        :tag('th')
        :wikitext('Members')
        :done()
    t:addClass("align-center-" .. (columns + 1) .. " align-center-" .. (columns + 3))
    columns = columns + 3

    if (not hideAuxiliary) then
        ttlrow:tag('th')
            :wikitext('Using')
            :done()
        t:addClass("align-center-" .. (columns + 1))
        columns = columns + 1
    end

    ttlrow:tag('th')
        :wikitext('Skills')
        :done()
        :tag('th')
        :wikitext('Experience')
        :done()
        :tag('th')
        :wikitext('Materials')
        :done()
    t:addClass("align-right-" .. (columns + 1) .. " align-right-" .. (columns + 2))
    columns = columns + 3

    if (not hideGE) then
        ttlrow:tag('th')
            :wikitext('GE price')
            :done()
        t:addClass("align-right-" .. (columns + 1))
        columns = columns + 1
    end

    if (not hideGEVolume) then
        ttlrow:tag('th')
            :wikitext('GE volume')
            :done()
        t:addClass("align-right-" .. (columns + 1))
        columns = columns + 1
    end

    if showProfit then
        ttlrow:tag('th')
            :wikitext('Profit')
            :done()
        t:addClass("align-right-" .. (columns + 1))
        columns = columns + 1
    end

    local rows = 0
    local hasHistoric = false
    local hasCacheOnly = false
    for _, bucket_item in ipairs(bucket_data) do
        local currentHistoric = bucket_item["Category:Removed content"] or bucket_item["Category:Historical article"]
        local currentCacheOnly = bucket_item["Category:Pages using information from game APIs or cache"]
        hasHistoric = hasHistoric or currentHistoric
        hasCacheOnly = hasCacheOnly or currentCacheOnly
        local row = printRow(t, bucket_item.production_json, material, hideGE, hideGEVolume, hideAuxiliary, showProfit, currentHistoric, currentCacheOnly)
        if row ~= nil then
            rows = rows + 1
        end
    end

    if hasHistoric or hasCacheOnly then
        local captions = {}
        if hasHistoric then
            table.insert(captions, ('<small>† Denotes discontinued recipes that used [[%s]]</small>'):format(material))
        end
        if hasCacheOnly then
            table.insert(captions, ('<small>‡ Denotes recipes that use [[%s]] but were obtained from the game [[Application programming interface|APIs]] or [[Jagex cache|cache]] and may not be available</small>'):format(material))
        end
        t:tag('caption')
            :css('caption-side', 'bottom')
            :wikitext(table.concat(captions, '<br>'))
            :done()
    end

    if rows == 0 then
        return false
    end

    return intro .. tostring(t)
end

return p
--</pre>