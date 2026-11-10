local p = {}

local scp = require('Module:Skill clickpic')._main
local yesNo = require('Module:Yesno')
local paramTest = require('Module:Paramtest')
local membersIcon = require('Module:Members').icon

local trim = mw.text.trim
local split = mw.text.split
local ustring = mw.ustring
local listToText = mw.text.listToText

function plinkify(tbl)
    -- mw.logObject(tbl)
    if tbl == nil then
        return nil
    elseif type(tbl) == 'string' then
        tbl = { tbl }
    end
    for i, v in ipairs(tbl) do
        local name = v.name or v
        local fileName = v.name or v
        if name ~= '' or fileName ~= '' then
            if (not mw.title.new(fileName .. '.png', 'File'):getContent()) then -- If file doesnt exist, just use name
                tbl[i] = '[[' .. name .. ']]'
            else
                tbl[i] = '[[File:' .. fileName .. '.png|link=' .. name .. '|frameless|35x35px]] [[' .. name .. ']]'
            end
        end
    end
    return table.concat(tbl, '<br/>')
end

-- val index in arr
function indexOf(tbl, val, doSearch)
    for i, item in ipairs(tbl) do
        if item == val then
            return i
        elseif doSearch and string.find(item, val) then
            return i
        end
    end
    return 0
end

function skillpic(name, level)
    if level == '?' or level == 'Varies' then
        return level .. ' ' .. scp(name)
    else
        return scp(name, level)
    end
end

function buildRow(page, skillName, images, columns)
    local row = mw.html.create('tr')

    -- First cell, image/icon
    local image = getLastElement(page['infobox_item.image'] or page['infobox_monster.image'] or page['infobox_scenery.image'] or page['infobox_npc.image'])
    local icon = nil --getLastElement(page['infobox_construction.icon'])
    -- If images is set to icons, prefer icon over images. If its not icon, prefer image over icon
    local pic = images == 'icons' and (icon or image) or (image or icon)
    -- If images is set to icons, set smaller size, otherwise set larger size
    local imageSize = images == 'icons' and '35x35px' or '120x120px'

    if (pic) then
        row:tag('td'):wikitext('[[' .. pic .. '|frameless|' .. imageSize .. '|center|link=' .. page.page_name .. ' ]]')
    else
        row:tag('td'):wikitext('')
    end

    -- Second cell, page name + verisoning (if applicable)
    local title = split(page["page_name_sub"] or page["name"], '#')[1]
    local subtitle = split(page["page_name_sub"] or page["name"], '#')[2]
    if title == subtitle then
        subtitle = nil
    end
    row:tag('td'):wikitext(string.format("[[%s|%s]]%s", page["page_name"], title, subtitle and ' <small>(' .. string.gsub(subtitle, '_', ' ') .. ')</small>' or ''))

    -- Third cell (optional), members
    if (columns['membersColumn']) then
        local members = page['is_members_only']
            or page['infobox_scenery.is_members_only']
            or page['infobox_npc.is_members_only']
            or page['infobox_item.is_members_only']
            or page['infobox_monster.is_members_only']
        --or page['infobox_construction.icon'] --All of construction is members only
        row:tag('td'):wikitext(membersIcon(members))
    end

    -- Fourth cell, skill level requirement
    local skills = page["skills"]
    local mainSkillStr = ''
    local otherSkillStr = ''
    local skillExp = nil
    for _, s in ipairs(skills) do
        if s.name == skillName then
            mainSkillStr = mainSkillStr .. skillpic(s.name, s.level) .. '<br/>'
            skillExp = s.experience
        else
            otherSkillStr = otherSkillStr .. skillpic(s.name, s.level) .. '<br/>'
        end
    end

    if mainSkillStr == '' then mainSkillStr = '(?)' end
    row:tag('td'):wikitext(mainSkillStr)

    -- Fifth cell, skill experience yield
    row:tag('td'):wikitext(concatenateTable(skillExp) or '(?)')

    -- Sixth cell, materials
    if (columns['materialsColumn']) then
        row:tag('td'):wikitext(plinkify(page['materials']))
    end

    -- Seventh cell, tools
    if (columns['toolsColumn']) then
        row:tag('td'):wikitext(plinkify(page['uses_tool']))
    end

    -- Eighth cell, facilities
    if (columns['facilitiesColumn']) then
        local facs = {}
        if page.uses_facility then
            for _, f in ipairs(page['uses_facility']) do
                if f ~= '' then
                    table.insert(facs, '[[' .. f .. ']]')
                end
            end
        end

        row:tag('td'):wikitext(concatenateTable(facs))
    end

    -- Ninth cell, other skills

    if (columns['otherSkillsColumn']) then
        row:tag('td'):wikitext(otherSkillStr)
    end

    return row
end

function createHeader(skill, columns)
    local tabl = mw.html.create('table'):addClass('wikitable sortable sticky-header align-center-1'):done()
    local header = tabl:tag('tr')
    header:tag('th'):attr('colspan', '2'):wikitext('Name')
    if (columns['membersColumn']) then
        tabl:addClass('align-center-3')
        header:tag('th'):wikitext(membersIcon('both'))
    end
    header:tag('th'):wikitext(skill .. ' level')
    header:tag('th'):wikitext(skill .. ' XP')
    if (columns['materialsColumn']) then
        header:tag('th'):wikitext('Materials used')
    end
    if (columns['toolsColumn']) then
        header:tag('th'):wikitext('Tools used')
    end
    if (columns['facilitiesColumn']) then
        header:tag('th'):wikitext('Facilities used')
    end
    if (columns['otherSkillsColumn']) then
        header:tag('th'):wikitext('Skills involved')
    end
    return tabl
end

function shouldExclude(property, exclusionList)
    for _, exclusion in ipairs(exclusionList) do
        if ((paramTest.has_content(exclusion)) and (ustring.find(string.lower(concatenateTable(property) or ''), string.lower(trim(exclusion))))) then
            return true
        end
    end
    return false
end

function tableConcat(mainTable, dedupeCache, newTable, exclusionList, skillName)
    for i = 1, #newTable, 1 do
        local production_json = mw.text.jsonDecode(newTable[i].production_json or '{}')
        -- newTable[i].production_json = nil
        for k, v in pairs(production_json) do
            newTable[i][k] = v
        end
        -- Only add pages not using excluded materials
        if (not ((shouldExclude(production_json['materials'], exclusionList)))) then
            local good = false
            -- mw.logObject(production_json, 'prod-j')
            if #mainTable == 0 or mainTable[#mainTable].production_json ~= production_json then -- Easy deduplication for identical materials
                for _, z in ipairs(newTable[i]["skills"] or {}) do
                    if z.name == skillName then
                        local expNum = tonumber(z.experience)
                        if expNum and expNum ~= -1 then -- -1 is used by skill info to denote a skill that isn't used in a specific variant
                            good = true
                        elseif not expNum then
                            good = true
                        end
                    end
                end
            end
            if good and dedupeCache[newTable[i].production_json] == nil then
                dedupeCache[newTable[i].production_json] = true
                mainTable[#mainTable + 1] = newTable[i]
            end
        end
    end
    return mainTable
end

function getLastElement(tbl)
    return type(tbl) == 'table' and tbl[#tbl] or tbl
end

function concatenateTable(tbl)
    return type(tbl) == 'table' and listToText(tbl, ', ', ' and ') or tbl
end

function loadData(strictExp, skillName, membersColumn, exclusionList, limit, batchSize, category, notcategory)
    local allData = {}
    local dedupeCache = {}

    for i = 0, limit, batchSize do
        local b = bucket("recipe")
            .select(
                "production_json",
                "infobox_item.image",
                "infobox_item.is_members_only",
                --"infobox_construction.image",
                "infobox_monster.image",
                "infobox_monster.is_members_only",
                "infobox_scenery.image",
                "infobox_scenery.is_members_only",
                --"infobox_npc.image",
                "infobox_npc.is_members_only",
                --"infobox_construction.icon",
                "page_name",
                "page_name_sub",
                "recipe.uses_skill",
                "uses_tool",
                "uses_facility",
                "is_members_only"
            )
            .join("infobox_item", "recipe.page_name", "infobox_item.page_name")
            --.join("infobox_construction", "recipe.page_name", "infobox_construction.page_name")
            .join("infobox_monster", "recipe.page_name", "infobox_monster.page_name")
            .join("infobox_scenery", "recipe.page_name", "infobox_scenery.page_name")
            .join("infobox_npc", "recipe.page_name", "infobox_npc.page_name")
            .where("recipe.uses_skill", skillName)
            --.where(bucket.Or(
            --	{"infobox_item.default_version", true},
            --	{"infobox_construction.default_version", true},
            --	{"infobox_scenery.default_version", true},
            --	{"infobox_npc.default_version", true},
            --	{"infobox_monster.default_version", true}
            --))
            .orderBy("page_name", "ASC")
            .limit(batchSize)
            .offset(i)

        if (category) then
            b.where("Category:" .. category)
        end

        if (notcategory) then
            b.where(bucket.Not("Category:" .. notcategory))
        end

        local t1 = os.clock()
        local bucketData = b.run()
        local t2 = os.clock()
        if (bucketData == nil or #bucketData == 0) then break end
        mw.log(string.format('Bucket: entries %d, time elapsed: %.3f ms.', #bucketData, (t2 - t1) * 1000))

        tableConcat(allData, dedupeCache, bucketData, exclusionList, skillName)
    end

    if (allData == nil) then
        error("No results found for the specified query.")
    end
    -- mw.logObject(allData,'allData')
    return allData
end

function p._main(args)
    -- Strict requests experience >0
    local strictExp = (yesNo(args.strict) or false) and '' or ' OR '
    local skillName = trim(args.skill)
    local limit = paramTest.default_to(tonumber(args.limit), 5000) -- Acting as a real limiter
    local batchSize = paramTest.default_to(tonumber(args.batchsize), 5000)

    --Table columns
    local columns = {
        membersColumn = yesNo(args.members or true, true),
        materialsColumn = yesNo(args.materials or true, true),
        toolsColumn = yesNo(args.tools or true, true),
        facilitiesColumn = yesNo(args.facilities or true, true),
        otherSkillsColumn = yesNo(args['other skills'] or true, true),
    }

    local exclusions = split(args['exclude material'] or '', ',')
    local images = string.lower(args.images or '')

    local data = loadData(strictExp, skillName, columns['membersColumn'], exclusions, limit, batchSize, args.category, args.notcategory)

    local ret = createHeader(skillName, columns)

    for i, page in pairs(data) do
        ret:node(buildRow(page, skillName, images, columns))
    end

    return ret
end

function p.main(frame)
    local args = frame:getParent().args
    return p._main(args)
end

return p