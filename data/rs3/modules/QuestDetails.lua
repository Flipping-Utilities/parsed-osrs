-- {{Quest details}}
--
require("strict")
local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local infobox = require('Module:Infobox')

local lang = mw.language.getContentLanguage()
local quest_req, has_quest_req
do
    local _module_questreq = require("Module:Questreq")
    quest_req = _module_questreq._main
    has_quest_req = _module_questreq.has_reqs
end

local currentTitle = mw.title.getCurrentTitle()
local pagename = currentTitle.fullText

local subjectName, iconParam, iconDisp, yearParam, startDisp, membersDisp, lengthParam, requirementDisp, ironmanConcernsDisp, itemsDisp,
followsEventsDisp, recommendedDisp, fullCompletionDisp, emptyToNone,
yesnoParam, hasParamDefined, emptyToNil, questBucket, onQuickGuide,
addcategories, parseReqsSkill, parseReqsSkillLevel, leagueRegionAutoDisp

local p = {}

p.difficulties = {
    ["novice"] = { 0, "Novice", '[[File:Novice.svg|7px|Novice|link=]] Novice' },
    ["intermediate"] = { 1, "Intermediate", '[[File:Intermediate.svg|7px|Intermediate|link=]] Intermediate' },
    ["experienced"] = { 2, "Experienced", '[[File:Experienced.svg|7px|Experienced|link=]] Experienced' },
    ["master"] = { 3, "Master", '[[File:Master.svg|7px|Master|link=]] Master' },
    ["grandmaster"] = { 4, "Grandmaster", '[[File:Grandmaster.svg|7px|Grandmaster|link=]] Grandmaster' },
    ["special"] = { 250, "Special", '[[File:Special.svg|7px|Special|link=]] Special' },
    ["none"] = { 251, "N/A", "N/A" } -- special values for non-quest items
}

p.lengths = {
    ["seasonal"] = { 0, "Seasonal" },
    ["very short"] = { 1, "Very Short" },
    ["short"] = { 2, "Short" },
    ["short to medium"] = { 3, "Short to Medium" },
    ["medium"] = { 4, "Medium" },
    ["medium to long"] = { 5, "Medium to Long" },
    ["long"] = { 6, "Long" },
    ["long to very long"] = { 7, "Long to Very Long" },
    ["very long"] = { 8, "Very Long" },
    ["very, very long"] = { 9, "Very, Very Long" },
    ["none"] = { 10, "N/A" } -- special values for non-quest items
}

function p.details(frame)
    local _args = frame:getParent().args
    local ret = infobox.new(_args)

    ret:defineParams {
        { name = 'name', func = subjectName },
        { name = 'icon', func = iconParam },
        { name = 'release_year', func = yearParam },
        { name = 'release_year_nth', func = 'numbers' },
        { name = 'iconDisp', func = { name = iconDisp, params = { 'icon', 'release_year', 'release_year_nth', 'age', 'name' } } },
        { name = 'start', func = 'has_content' },
        { name = 'start_path', func = 'has_content' },
        { name = 'startDisp', func = { name = startDisp, params = { 'start', 'start_path' } } },
        { name = 'members', func = yesnoParam },
        { name = 'membersDisp', func = { name = membersDisp, params = { 'members' } } },
        { name = 'length', func = lengthParam },
        { name = 'quest_requirement', func = yesnoParam },
        { name = 'quest_requirement_limit', func = 'numbers' },
        { name = 'quest_requirement_collapsed', func = yesnoParam },
        { name = 'requirements', func = 'has_content' },
        { name = 'ironman', func = 'has_content' },
        { name = 'full', func = 'has_content' },
        { name = 'fullDisp', func = { name = fullCompletionDisp, params = { 'full' } } },
        { name = 'follows', func = 'has_content' },
        { name = 'followsDisp', func = {
            name = followsEventsDisp,
            params = { 'follows', 'name', 'quest_requirement_limit' }
        } },
        { name = 'items', func = 'has_content' },
        { name = 'itemsDisp', func = { name = itemsDisp, params = { 'items' } } },
        { name = 'recommended', func = 'has_content' },
        { name = 'recommendedDisp', func = { name = recommendedDisp, params = { 'recommended' } } },
        { name = 'kills', func = emptyToNone },
        -- leagues
        { name = 'leagueRegion', func = 'has_content' },
        { name = 'leagueRegionReq', func = 'has_content' },
        { name = 'leagueRegionAuto', func = 'has_content' },
        { name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
        { name = 'leagueRegionReq_raw', func = { name = 'has_content', params = { 'leagueRegionReq' }, flag = 'p' } },
        { name = 'leagueRegionAuto_raw', func = { name = 'has_content', params = { 'leagueRegionAuto' }, flag = 'p' } },
    }

    local quest_bucket_params = {
        icon = 'icon',
        length = 'official_length',
        release_year = 'official_release_year',
        release_year_nth = 'release_year_nth',
        requirements = 'requirements',
        requirement_skill = 'requirement_skill',
        requirement_skill_level = 'requirement_skill_level',
        league_region = 'leagueRegion_raw',
        league_region_req = 'leagueRegionReq_raw',
        league_region_auto = 'leagueRegionAuto_raw',
        quest_bucket = 'json',
    }

    ret:defineParams {
        { name = 'quest_bucket', func = {
            name = questBucket,
            params = { 'start', 'length', 'requirements', 'items', 'kills', 'members', 'leagueRegion_raw', 'leagueRegionReq_raw', 'leagueRegionAuto_raw' }
        } },
    }

    ret:defineParams {
        { name = 'requirement_skill', func = {
            name = parseReqsSkill,
            params = { 'requirements' }
        } },
    }

    ret:defineParams {
        { name = 'requirement_skill_level', func = {
            name = parseReqsSkillLevel,
            params = { 'requirements' }
        } },
    }

    ret:customButtonPlacement(true)
    ret:setAddRSWInfoboxClass(false)
    ret:setNameCheck(false)
    ret:create()
    ret:cleanParams()

    if not onQuickGuide() then
        ret:useBucket('quest', quest_bucket_params)
    end

    ret:addClass('questdetails plainlinks')
    ret:attr { cellspacing = '3' }

    local auto_width = { ["max-width"] = "85%", ["width"] = "auto" }
    ret:addRow {
        { tag = 'th', class = "questdetails-header", content = 'Start point' },
        { tag = 'argd', class = "questdetails-info", content = 'startDisp', css = auto_width },
        { tag = 'argd', class = "text-align-center", content = 'iconDisp', rowspan = 3,
            css = { ["vertical-align"] = "top" }
        }
    }

    ret:addRow {
        { tag = 'th', class = "questdetails-header", content = '[[Members]]' },
        { tag = 'argd', class = "questdetails-info", content = 'membersDisp', css = auto_width }
    }

    ret:addRow {
        { tag = 'th', class = "questdetails-header", content = "Length<br/><small>''as displayed in-game''</small>" },
        { tag = 'argd', class = "questdetails-info", content = 'length', colspan = 2 }
    }

    ret:addRow {
        { tag = 'th', class = "questdetails-header", content = 'Requirements' },
        { tag = 'td', class = "questdetails-info qc-active", content = requirementDisp(ret), colspan = 2 }
    }

    if hasParamDefined(ret, 'follows') then
        ret:addRow {
            { tag = 'th', class = "questdetails-header", content = 'Follows events' },
            { tag = 'argd', class = "questdetails-info qc-active", content = 'followsDisp', colspan = 2 },
        }
    end

    ret:addRow {
        { tag = 'th', class = "questdetails-header", content = 'Required items' },
        { tag = 'argd', class = "questdetails-info", content = 'itemsDisp', colspan = 2 }
    }

    if hasParamDefined(ret, 'recommended') then
        ret:addRow {
            { tag = 'th', class = "questdetails-header", content = 'Recommended' },
            { tag = 'argd', class = "questdetails-info", content = 'recommendedDisp', colspan = 2 },
        }
    end

    ret:addRow {
        { tag = 'th', class = "questdetails-header", content = 'Combat' },
        { tag = 'argd', class = "questdetails-info", content = 'kills', colspan = 2 }
    }

    if hasParamDefined(ret, 'full') then
        ret:addRow {
            { tag = 'th', class = "questdetails-header", content = 'Full completion' },
            { tag = 'argd', class = "questdetails-info qc-active", content = 'fullDisp', colspan = 2 }
        }
    end

    if hasParamDefined(ret, 'leagueRegionReq') then
		local leagues = require('Module:LeagueRegion')
		local formattedReq = leagues.regionsForInfobox(ret:param('leagueRegionReq'))
		
        ret:addRow {
            meta = { addClass = 'leagues-global-flag' },
            { tag = 'th', class = 'questdetails-header', content = string.format('[[%s|League]] region required', leagues.getDefaultLeague()) },
            { tag = 'td', class = 'questdetails-info', content = formattedReq, colspan = 2 }
        }
    end

    if hasParamDefined(ret, 'leagueRegionAuto') then
        local leagues = require('Module:LeagueRegion')
        local formattedAuto = leagues.regionsForInfobox(ret:param('leagueRegionAuto'))
		
		if formattedAuto ~= 'N/A' then
			ret:addRow {
				meta = { addClass = 'leagues-global-flag' },
				{ tag = 'th', class = 'questdetails-header', content = string.format('[[%s|League]] auto-complete', leagues.getDefaultLeague()) },
				{ tag = 'td', class = 'questdetails-info', content = 'Unlocking ' .. formattedAuto .. ' [[File:Yes check.svg|20px|link=]] will auto-complete the quest.', colspan = 2 }
			}
		end
    end

    if hasParamDefined(ret, 'leagueRegion') then
        local leagues = require('Module:LeagueRegion')
        ret:addRow {
            meta = { addClass = 'leagues-global-flag' },
            { tag = 'th', class = 'questdetails-header', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] notes' },
            { tag = 'argd', class = 'questdetails-info', content = 'leagueRegion', colspan = 2 }
        }
    end

    ret:finish()
    if onmain() and not onQuickGuide() then
        local allargs = ret:param('all')
        local catargs = ret:categoryData()
        ret:wikitext(addcategories(allargs, catargs))
    end
    return ret:tostring()
end

function leagueRegionAutoDisp(val)
    if not infobox.isDefined(val) then
        return nil
    end
    return 'Unlocking ' .. val .. ' [[File:Yes check.svg|20px|link=]] will auto-complete the quest.'
end

function subjectName(arg)
    if infobox.isDefined(arg) then
        return arg
    end

    return pagename:gsub("/Quick guide", "")
end

function iconParam(icon)
    if infobox.isDefined(icon) then
        icon = icon:gsub('%[',''):gsub('%]',''):gsub('[Ff]ile:',''):gsub('{{!}}','|')
        icon = mw.text.split(icon, '|')
        return icon[1]
    else
        return nil
    end
end

function iconDisp(icon, year, year_nth, age, name)
    local node = mw.html.create('div')
        :css('position', 'relative')
        :css('float', 'right')

    if infobox.isDefined(icon) then
        node:wikitext('[[File:' .. icon .. '|50px]]')
    else
        node:tag('div')
            :css({ width = '50px', height = '50px' })
    end

    node
        :tag('br'):done()
        :tag('span')
        :wikitext(year)

    if infobox.isDefined(year_nth) then
        node:tag('sup')
            :css('display', 'none')
            :wikitext('#' .. year_nth)
            :done()
    end

    if infobox.isDefined(age) then
        age = age:lower()
    else
        local result = bucket('infobox_quest')
            .select('official_age')
            .where('name', name)
            .where('official_age', '!=', bucket.Null())
            .limit(1)
            .run()
        if #result > 0 then
            age = result[1].official_age:lower()
        end
    end

    if age == '5' then
        node:tag('div')
            :css('position', 'absolute')
            :css('top', '0')
            :css('right', '0')
            :css('pointer-events', 'none')
            :wikitext('[[File:Fifth age quest icon.png|50px]]')
            :done()
    elseif age == '6' then
        node:tag('div')
            :css('position', 'absolute')
            :css('top', '0')
            :css('right', '0')
            :css('pointer-events', 'none')
            :wikitext('[[File:Sixth age quest icon.png|50px]]')
            :done()
    elseif age == 'chaos' or age == 'age of chaos' then
        node:tag('div')
            :css('position', 'absolute')
            :css('top', '0')
            :css('right', '0')
            :css('pointer-events', 'none')
            :wikitext('[[File:Sixth age quest icon.png|50px]]')
            :done()
    end

    node:done()

    return tostring(node)
end

function yearParam(y)
    if not infobox.isDefined(y) then
        return nil
    end

    local yr = tonumber(y)
    -- Keep the lower bound check only
    -- if yr >= 2001 and yr <= tonumber(os.date("%Y")) + 1 then
    if yr >= 2001 then
        return yr
    else
        return nil
    end
end

function startDisp(start, startPath)
    if infobox.isDefined(startPath) then
        return '[[File:Quest map icon.png|17px|link=]] ' .. start .. " " .. startPath
    else
        return '[[File:Quest map icon.png|17px|link=]] ' .. start
    end
end

function membersDisp(members)
    if not infobox.isDefined(members) then
        return nil
    end

    return members == 'Yes' and '[[File:P2P icon.png|30px|link=]] Members only' or
        '[[File:F2P icon.png|30px|link=]] Free to play'
end

function lengthParam(length)
    if not infobox.isDefined(length) then
        return nil
    end

    local len = length:lower()
    if len == "no" or len == "none" or len == "n/a" then
        return p.lengths.none[2]
    end

    return p.lengths[len][2]
end

function requirementDisp(ret)
    local name = ret:param('name')
    if not infobox.isDefined(name) then
        return nil
    end

    local quest_req_limit = ret:param('quest_requirement_limit')
    if not infobox.isDefined(quest_req_limit) then
        quest_req_limit = 5
    end

    local quest_req_collapsed = ret:param('quest_requirement_collapsed')
    if not infobox.isDefined(quest_req_collapsed) then
        quest_req_collapsed = false
    end

    local req = mw.html.create()

    local must_show_quest_req = ret:param('quest_requirement')
    if not infobox.isDefined(must_show_quest_req) then
        must_show_quest_req = nil
    end

    local extra = ret:param('requirements')
    if must_show_quest_req == 'Yes' or (must_show_quest_req ~= 'No' and not string.find(extra, "questreq")) then
        req:node(quest_req(name, quest_req_limit, quest_req_collapsed)):newline()
    else -- Skip adding questreq if it does
        req = req:newline()
    end

    local has_requirement = has_quest_req(name)
    if infobox.isDefined(extra) then
        req:wikitext(extra):newline()
        has_requirement = true
    end

    local ironman_conerns = ret:param('ironman')
    if infobox.isDefined(ironman_conerns) then
        req:node(ironmanConcernsDisp(ironman_conerns)):newline()
        has_requirement = true
    end

    if not has_requirement then
        req:wikitext('* None')
    end

    return tostring(req)
end

function ironmanConcernsDisp(concerns)
    return mw.html.create()
        :tag('table')
        :addClass('mw-collapsible mw-collapsed')
		:css('background', 'none')
        :tag('tr'):tag('th')
        :addClass('inventory-image'):wikitext("[[File:Ironman badge.png|link=]] [[File:Hardcore Ironman badge.png|link=]] '''Ironmen:'''")
        :tag('tr'):tag('td')
        :newline()
        :wikitext(concerns)
        :allDone()
end

function itemsDisp(items)
    local node = mw.html.create()
        :tag('i')
        :wikitext('Items from the [[tool belt]] are not listed unless they do not work or are not automatically added.')
        :done()

    if not infobox.isDefined(items) then
        node:newline():wikitext("* None")
        return tostring(node)
    end

    node
        :tag('div')
        :addClass('lighttable checklist')
        :newline()
        :wikitext(items)
    return tostring(node)
end

function followsEventsDisp(recommended, name, quest_req_limit)
    if not infobox.isDefined(recommended) then
        return nil
    end

    local b = yesno(recommended)
    if b == false then
        return nil
    end

    local remark
    if b == true then
        remark = "''For full storyline comprehension, completion of the following quests is recommended but not required.''"
    else
        remark = recommended
    end

    if not infobox.isDefined(quest_req_limit) then
        quest_req_limit = 3
    end

    local node = mw.html.create()
        :wikitext(remark)
        :newline()
        :node(quest_req('Follows:' .. name, quest_req_limit, true))
    return tostring(node)
end

function recommendedDisp(recommended)
    if not infobox.isDefined(recommended) then
        return nil
    end

    local node = mw.html.create('div')
        :addClass('qc-active lighttable checklist')
        :newline()
        :wikitext(recommended)
    return tostring(node)
end

function fullCompletionDisp(requirements)
    if not infobox.isDefined(requirements) then
        return nil
    end

    local node = mw.html.create()
        :tag('i')
        :wikitext('For full completion and unlocking additional rewards, the following is required.')
        :done()

    node:newline():wikitext(requirements)
    return tostring(node)
end

function emptyToNone(value)
    if not infobox.isDefined(value) then
        return "* None"
    end

    return value
end

function yesnoParam(p)
    if infobox.isDefined(p) then
        local b = yesno(p)
        if b then
            return 'Yes'
        elseif not b then
            return 'No'
        else
            return nil
        end
    end
    return nil
end

function hasParamDefined(ret, name)
    return infobox.isDefined(ret:param(name))
end

function emptyToNil(value)
    if not infobox.isDefined(value) then
        return nil
    end

    return value
end

function questBucket(start, length, requirements, items, kills, members, leagueRegion_raw, leagueRegionReq_raw, leagueRegionAuto_raw)
    local bucketJSON = {
        name = currentTitle.text,
        start = emptyToNil(start),
        length = emptyToNil(length),
        requirements = emptyToNil(requirements),
        items = emptyToNil(items),
        kills = emptyToNil(kills),
        members = emptyToNil(members),
        league_region = emptyToNil(leagueRegion_raw),
        league_region_req = emptyToNil(leagueRegionReq_raw),
        league_region_auto = emptyToNil(leagueRegionAuto_raw),
    }

    return mw.text.jsonEncode(bucketJSON)
end

function parseReqsSkill(requirements)
	-- extracts all the skills from the skillreq html stored in the requirements
	
	local split = mw.text.split(requirements,'*')
	local out = {}
	for _,s in ipairs(split) do
		s = mw.ustring.match(s,'^%s*<span class=\"skillreq\" data%-skill="[^"]*"')
		if s~=nil then
			s = mw.ustring.gsub(s,'^%s*<span class=\"skillreq\" data%-skill="','') 
			s = mw.ustring.gsub(s,'"$','') 
			table.insert(out,s)
		end
	end
	return out
end

function parseReqsSkillLevel(requirements)
	-- extracts all the skills and their levels from the skillreq html stored in the requirements
	local split = mw.text.split(requirements,'*')
	local out = {}
	for _,s in ipairs(split) do
		local s1 = mw.ustring.match(s,'^%s*<span class=\"skillreq\" data%-skill="[^"]*"')
		local s2 = mw.ustring.match(s,'data%-level="[^"]*"')
		if s1~=nil and s2~=nil then
			s1 = mw.ustring.gsub(s1,'^%s*<span class=\"skillreq\" data%-skill="','') 
			s1 = mw.ustring.gsub(s1,'"$','') 
			s2 = mw.ustring.gsub(s2,'^data%-level="','') 
			s2 = mw.ustring.gsub(s2,'"$','') 
			table.insert(out,s1..':'..s2)
		end
	end
	return out
end

function onQuickGuide()
    return currentTitle.subpageText == "Quick guide"
end

function addcategories(args, catargs)
    local ret = {}

    local cat_map = {
        -- Added if the parameter has content
        defined = {
            ironman = 'Quests with Ironman requirements',
	    leagueRegionReq = 'Pages with League region'

        },
        -- Added if the parameter has no content
        notdefined = {
            length = 'Needs official length added',
            release_year = 'Needs official release year added',
            leagueRegionReq = 'Needs leagueRegionAuto/Quest',
   
        },
    }

    local length = args.length.d
    if infobox.isDefined(length) and length ~= "N/A" then
        local cat = string.format("%s quests", length)
        table.insert(ret, cat)
    end

    local release_year = args.release_year.d
    if infobox.isDefined(release_year) then
        local cat = string.format("Quests released in %s", release_year)
        table.insert(ret, cat)
    end

    local requirements = args.requirements.d
    if infobox.isDefined(requirements) then
    	for _, requirement in ipairs(mw.text.split(requirements, "\n")) do
            local data_skill_name = requirement:match('data%-skill=\"([a-zA-Z %-]+)\"')
            if data_skill_name then
                data_skill_name = lang:ucfirst(data_skill_name:lower())
                local cat = "Quests with " .. data_skill_name .. " requirement"
                table.insert(ret, cat)
            end
        end
    end

    -- Run and add mapped categories
    for n, v in pairs(cat_map.defined) do
        if catargs[n] and catargs[n].one_defined then
            table.insert(ret, v)
        end
    end
    for n, v in pairs(cat_map.notdefined) do
        if catargs[n] and not catargs[n].all_defined then
            table.insert(ret, v)
        end
    end

    -- combine table and format category wikicode
    for i, v in ipairs(ret) do
        if v ~= '' then
            ret[i] = string.format('[[Category:%s]]', v)
        end
    end

    return table.concat(ret, '')
end

return p
-- </nowiki>