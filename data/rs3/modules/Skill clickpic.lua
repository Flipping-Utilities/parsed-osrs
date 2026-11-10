local p = {}

require('Module:Mw.html extension')
local pics = mw.loadData("Module:Skill clickpic/data")
local commas = require('Module:Addcommas')._add
local userError = require("Module:User error")
local lang = mw.getContentLanguage()
local hc = require('Module:Paramtest').has_content
local yesno = require('Module:Yesno')

local dpt = '<sup class="noprint">&#91;<span class="fact-text" title="The text in the vicinity of this tag needs clean-up.">clean-up needed</span>&#93;</sup>[[Category:Pages with deprecated parameters]]'

local function fnum(x)
    if type(x) == "number" then
        return commas(x)
    end

    return tonumber(x) or ''
end

local function formatSkillreq(skill, level, image, link, append_link)
    local ret = mw.html.create('span')
        :addClass('skillreq')
        :css('white-space', 'nowrap')
        :attrIf(skill, 'data-skill', skill)
        :attrIf(level, 'data-level', level)
        :attrIf(skill and level, 'data-sort-value', string.format('%s %s', skill, level))
        :wikitext(string.format(
            '%s [[File:%s.png|21x21px|link=%s|alt=%s]]',
            fnum(level), image, link, skill))

    if append_link then
        ret:wikitext(string.format(' [[%s]]', skill))
    end

    return ret
end

function p.main(frame)
    local args = frame:getParent().args

    return p._main(args[1] or '', args[2], args.link, false)
end

function p._main(name, level_txt, link, append_link)
    if type(name) ~= 'string' or pics[name:lower()] == nil then
        return userError('Not a valid skill name: ' .. name) .. '[[Category:Erroneous parameter]]'
    end

    local file = pics[name:lower()]
    local skill = file.link

    if yesno(link) == false then
        link = ''
    elseif type(link) ~= 'string' then
        link = skill
    end

    local level = lang:parseFormattedNumber(level_txt or '')
    local need_cleanup = false
    if level == nil and level_txt ~= nil then
        need_cleanup = true
    end

    if level then
        local ret = formatSkillreq(skill, level, file.image, link, append_link)
        return tostring(ret)
    end

    local ret = string.format('[[File:%s.png|21x21px|link=%s|alt=%s]]', file.image, link, skill)
        
    if append_link then
        ret = ret .. ' [[' .. link .. '|' .. skill .. ']]'
    end

    return ret .. (need_cleanup and dpt or "")
end

function p.link(frame)
    local args = frame:getParent().args

    return p._main(args[1] or '', args[2], args.link, true)
end

function p.req(frame)
    local args = frame:getParent().args

    local skill = args[1] or ''
    local level_txt = args[2]

    return p._req(skill, level_txt)
end

function p._req(name, level_txt)
    if type(name) ~= 'string' or pics[name:lower()] == nil then
        return userError('Not a valid skill name: ' .. name) .. '[[Category:Erroneous parameter]]'
    end

    local file = pics[name:lower()]
    local skill = file.link

    if not hc(level_txt) then
        return userError('It requires a valid level: ' .. level_txt) .. '[[Category:Erroneous parameter]]'
    end

    local level = lang:parseFormattedNumber(level_txt or '')
    if level == nil then
        return userError('It requires a single number of level: ' .. level_txt) .. '[[Category:Erroneous parameter]]'
    end

    local ret = formatSkillreq(skill, level, file.image, skill, true)
    return tostring(ret)
end

return p