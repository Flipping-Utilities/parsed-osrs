--------------------------
-- Module for [[Template:Infobox Excavation Site]]
------------------------
local p = {}

local arr = require('Module:Array')
local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')
local rh = require('Module:Infobox Archaeology/Common')
local parse_requirements, getdigsite
local bucketarg

function p.main(frame)
    local args = frame:getParent().args
    return p._main(args)
end

function p._main(args)
    local ret = infobox.new(args)

    ret:defineParams {
        { name = 'name', func = 'name' },
        { name = 'digsitebucket', func = { name = getdigsite, params = { 'name', 'digsite' }, flag = 'p' } },
        { name = 'digsite', func = 'has_content' },
        { name = 'members', func = 'has_content' },
        { name = 'requirements', func = { name = parse_requirements,
            params = { 'requirement_level', 'requirement_level_boostable', 'requirement_item', 'requirement_mystery', 'requirement_mystery_partial', 'requirement_quest', 'requirement_quest_partial', 'requirement_achievement', 'requirement_skills', 'requirement_skills_boostable', 'requirement_research', 'requirement_other' }, flag = 'p' } },
        { name = 'bucketarg', func = { name = bucketarg, params = { 'name', 'digsitebucket', 'requirements' }, flag = 'd' } }
    }

    ret:useBucket('infobox_excavation_site', {
        name = 'site_name',
        digsitebucket = 'dig_site',
        members = 'is_members_only',
        bucketarg = 'json'
    })

    ret:create()
    ret:setMaxButtons(4)
    ret:cleanParams()
    ret:customButtonPlacement(true)
    ret:defineLinks({ hide = true })
    ret:defineName('Infobox Excavation Site')
    ret:addClass('infobox-excavation-site left-info')
    ret:noSwitch()
    ret:addButtonsCaption()

    -- PARAMETER: name
    ret:addRow {
        { tag = 'argh', content = 'name', class = 'infobox-header', colspan = '5' }
    }
    ret:pad(3)

    local digsite = ret:param('digsitebucket')
    if infobox.isDefined(digsite) then
        -- PARAMETER: digsite
        ret:addRow {
            { tag = 'th', content = 'Dig site', colspan = '2' },
            { tag = 'argd', content = 'digsitebucket', colspan = '3' }
        }
    end

    local requirements_string = rh.parse_requirements(ret:param("requirements"))
    -- PARAMETER: requirements
    ret:addRow {
        { tag = 'th', content = 'Requirements', colspan = '2' },
        { tag = 'td', content = requirements_string, colspan = '3' }
    }
    ret:pad(3)
    ret:finish()

    if onmain() then
        local cats = { 'Excavation sites' }
        if not getdigsite(args.name, args.digsite) then
            table.insert(cats, "Archaeology microsites")
        end
        ret:wikitext(table.concat(arr.map(cats, function(cat) return string.format('[[Category:%s]]', cat) end), ''))
    end


    return ret:tostring()
end

local function parse_site(site)
    local site_dict = { site = '', digsite = '', short = '' }
    if not site or site == '' or site:lower() == "none" then
        site_dict.site = 'none'
        site_dict.digsite = 'none'
        site_dict.short = 'none'
    else
        local digsite, short = site:match("(.*) %- (.*) excavation site")
        if digsite and short then
            site_dict.site = site
            site_dict.digsite = digsite
            site_dict.short = short
        else
            digsite, short = site:match("(.*) %- (.*)")
            if digsite and short then
                site_dict.site = site
                site_dict.digsite = digsite
                site_dict.short = short
            else
                local alt_short = site:match("^(.*) excavation site")
                if alt_short then
                    site_dict.site = site
                    site_dict.digsite = "none"
                    site_dict.short = alt_short
                else
                    site_dict.site = 'none'
                    site_dict.digsite = 'none'
                    site_dict.short = 'none'
                end
            end
        end
    end
    return site_dict
end

function getdigsite(name, digsite)
    if infobox.isDefined(digsite) and digsite:match(" Dig Site") then
        return digsite
    else
        local site_dict = parse_site(name)
        if (site_dict.digsite ~= "none") and (not (site_dict.digsite == "God Wars Dungeon")) and (not (site_dict.digsite == "Odd Old Man")) then return site_dict.digsite .. " Dig Site" end
    end
    return nil
end

local function split_semicolon(str)
    return mw.text.split(str, "; *")
end

function parse_requirements(requirement_level, requirement_level_boostable, requirement_item, requirement_mystery, requirement_mystery_partial, requirement_quest, requirement_quest_partial, requirement_achievement, requirement_skills, requirement_skills_boostable, requirement_research, requirement_other)
    local reqs = {}
    local is_empty = true
    if requirement_level ~= '' and tonumber(requirement_level) then
        reqs.level = tonumber(requirement_level)
        is_empty = false
    end
    if requirement_level_boostable ~= '' then
        reqs.level_boostable = requirement_level_boostable
        is_empty = false
    end
    if requirement_item ~= '' then
        reqs.item = split_semicolon(requirement_item)
        is_empty = false
    end
    if requirement_mystery ~= '' then
        reqs.mystery = split_semicolon(requirement_mystery)
        is_empty = false
    end
    if requirement_mystery_partial ~= '' then
        reqs.mystery_partial = split_semicolon(requirement_mystery_partial)
        is_empty = false
    end
    if requirement_quest ~= '' then
        reqs.quest = split_semicolon(requirement_quest)
        is_empty = false
    end
    if requirement_quest_partial ~= '' then
        reqs.quest_partial = split_semicolon(requirement_quest_partial)
        is_empty = false
    end
    if requirement_achievement ~= '' then
        reqs.achievement = split_semicolon(requirement_achievement)
        is_empty = false
    end
    if requirement_skills ~= '' then
        reqs.skills = split_semicolon(requirement_skills)
        is_empty = false
    end
    if requirement_skills_boostable ~= '' then
        local boostable = arr.map(split_semicolon(requirement_skills_boostable), function(pred)
            if pred == "true" then
                return true
            else
                return false
            end
        end)
        reqs.skills_boostable = boostable
        is_empty = false
    end
    if requirement_research ~= '' then
        reqs.research = split_semicolon(requirement_research)
        is_empty = false
    end
    if requirement_other ~= '' then
        reqs.other = split_semicolon(requirement_other)
        is_empty = false
    end
    if is_empty then
        return nil
    else
        return reqs
    end
end

function bucketarg(name, digsitebucket, requirements, factionbucket)
    local toJSON = {
        name = name,
        digsitebucket = digsitebucket,
        requirements = requirements,
        factionbucket = factionbucket
    }

    for k, v in pairs(toJSON) do
        if v == '' or type(v) == 'string' and (string.find(v, 'action=edit')) then
            toJSON[k] = nil
        end
    end

    return mw.text.jsonEncode(toJSON)
end

return p