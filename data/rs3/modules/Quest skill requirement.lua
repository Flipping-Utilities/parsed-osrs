require("strict");

local p = {} -- p stands for package
local lang = mw.language.getContentLanguage()
local arr = require('Module:Array')
local yesno = require('Module:Yesno')

-- Skill name
local skilllist = {
    "agility", "archaeology", "attack", "constitution", "construction",
    "cooking", "crafting", "defence", "divination", "dungeoneering",
    "farming", "firemaking", "fishing", "fletching", "herblore",
    "hunter", "invention", "magic", "mining", "necromancy",
    "prayer", "ranged", "runecrafting", "slayer", "smithing",
    "strength", "summoning", "thieving", "woodcutting",
}

local function parse(quest_data, skill)
	local out_tbl = {name=quest_data.page_name, full_name=quest_data.page_name_sub, level=0}
	skill = skill == "Quest points" and "quest points" or skill
    for _, requirement in ipairs(mw.text.split(quest_data.requirements, "\n")) do
    	if requirement:match('data%-skill=\"'..skill..'\"') then
	    	local data_skill_level = requirement:match('data%-level=\"(%d+)\"')
		    if data_skill_level then
		    	out_tbl.level = tonumber(data_skill_level)
		    end
    	end
    end
	return out_tbl
end

local function getQuests(skill)
	local cat = "Category:Quests with " .. skill .. " requirement"
    local qb = bucket('quest')
        .select('page_name', 'page_name_sub', 'requirements')
        .where(cat)
        .where(bucket.Not('Category:Removed quests'))

    local result = qb.run()
    
    local parsed = arr.map(result, function (hit) return parse(hit, skill) end)
    
    table.sort(parsed, function(a, b)
        if a.level == b.level then
            return a.name < b.name
        end
        return a.level < b.level
    end)
    return parsed
end

function p.renderSkills(frame)
    local args = frame:getParent().args
    local icon = args.icon
    local skill = lang:ucfirst((args.skill or args[1]):lower())
    local quests = getQuests(skill)

    local ret = mw.html.create('ul')

    for _, quest in ipairs(quests) do
    	-- We have issues with subquests
    	local icon_name = quest.full_name:match("(.*):") or quest.full_name
        if yesno(icon) then
            ret:tag('li'):wikitext(quest.level .. ' - [[File:' .. icon_name .. ' icon.png|link=' .. quest.name .. '|x25px]] [[' .. quest.name .. '|' .. quest.full_name .. ']]'):done()
        else
            ret:tag('li'):wikitext(quest.level .. ' - [[' .. quest.name .. '|' .. quest.full_name .. ']]'):done()
        end
    end
    return tostring(ret:done())
end

return p