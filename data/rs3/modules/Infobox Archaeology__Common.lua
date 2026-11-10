require('strict')
require("Module:Mw.html extension")
local p = {}
local arr = require('Module:Array')
local skillpic = require('Module:Skill clickpic')
local materials = require("Module:SkillUtils/Data/Archaeology Materials")

local function add_boost(base)
	local boost_text = "<small title='This skill can be boosted.' style='cursor:help; border-bottom:1px dotted;'>'''(b)'''</small>"
	return base .. boost_text
end

local function make_skill_link(skill)
	local split_table = mw.text.split(skill, " ")
	return skillpic._main(split_table[2], split_table[1])
end

local function split_and_boost_skill(skill, is_boostable)
	if skill:match("¦") then
		local split_table = mw.text.split(skill, "¦")
		local left = split_and_boost_skill(split_table[1], is_boostable)
		local right = split_and_boost_skill(split_table[2], is_boostable)
		return left .. " or " .. right
	else
		local parsed_skill = make_skill_link(skill)
		return is_boostable and add_boost(parsed_skill) or parsed_skill
	end
end

local function make_quest_link(quest, partial)
	local quest_text = '[[File:%s icon.png|link=%s|alt=%s.png: Quest icon of %s|x25px]] [[%s]]'
	local return_string = string.format(quest_text, quest, quest, quest, quest, quest)
	if not partial then
		return return_string
	end
	return "Partial completion of " .. return_string
end

local function make_mystery_link(mystery, partial)
	local mystery_text = '[[File:Archaeology - Mysteries achievement icon.png|link=%s|x25px]] [[%s]]'
	local return_string = string.format(mystery_text, mystery, mystery)
	if not partial then
		return return_string
	end
	return "Partial completion of " .. return_string
end

local function make_achievement_link(achievement, partial)
	local achievement_text = '[[%s]]'
	local return_string = string.format(achievement_text, achievement)
	if not partial then
		return return_string
	end
	return "Partial completion of " .. return_string
end

local function make_plink(str, modifier) 
	local plink_text = '[[File:%s.png|link=%s]] [[%s]]'
	return string.format(plink_text, str, str, str)
end

local function no_op(str)
    return str
end

local function split_general(req_str, modifier, parse_fn_left, parse_fn_right)
	if req_str:match("¦") then
		local split_table = mw.text.split(req_str, "¦")
		local left = split_general(split_table[1], modifier, parse_fn_left, parse_fn_right)
		local right = split_general(split_table[2], modifier, parse_fn_right, parse_fn_left)
		return left .. " or " .. right
	else
		return parse_fn_left(req_str, modifier)
	end
end

local function get_modifier_or_false(modifier_table, index)
	if modifier_table and modifier_table[index] ~= nil then return modifier_table[index]
	else return false end
end

-- Turns a table of items into a bulleted list of plinks
function p.to_bulleted(variant, elems)
	if variant == "drops" then
		local result = mw.html.create('ul')
		for _, drop in ipairs(elems) do
			result:tag('li')
				:tag('span')
					:addClass('pic-link inventory-image')
					:wikitext(('[[File:%s.png|link=%s|alt=%s.png: RS3 Inventory image of %s]]'):format(drop:gsub(':', '-'), drop, drop, drop))
				:done()
				:wikitext(('[[%s]]'):format(drop))
			:done()
		end
		return tostring(result)
	elseif variant == "requirements" then
		if not elems then return "None" end
		local reqs_list = p.build_requirements_list(elems)
	
		if #reqs_list == 0 then return "None"
		else
	        local result = mw.html.create('ul')
			for _, req in ipairs(reqs_list) do
				result:tag('li')
					:tag('span')
						:wikitext(req)
					:done()
				:done()
			end
			return tostring(result)
		end
    end
end

function p.build_requirements_list(reqs)
	local reqs_list = {}

	if reqs.level then
		local pic = skillpic._main("Archaeology", reqs.level)
		pic = reqs.level_boostable and add_boost(pic) or pic
		table.insert(reqs_list, pic)
	end

	if reqs.quest then
		local quests = reqs.quest
		local partial = reqs.quest_partial
		for idx, quest in ipairs(quests) do
			local is_partial = get_modifier_or_false(partial, idx)
			-- There are no cases of quests being OR options, but here for consistency
			table.insert(reqs_list, split_general(quest, is_partial, make_quest_link, make_quest_link))
		end
	end

	if reqs.mystery then
		local mysteries = reqs.mystery
		local partial = reqs.mystery_partial
		for idx, mystery in ipairs(mysteries) do
			local is_partial = get_modifier_or_false(partial, idx)
			-- This looks strange, but there's exactly one case of a mystery OR a buff being required
			table.insert(reqs_list, split_general(mystery, is_partial, make_mystery_link, make_plink))
		end
	end

	if reqs.achievement then
		local achievements = reqs.achievement
		for _, achievement in ipairs(achievements) do
			table.insert(reqs_list, split_general(achievement, false, make_achievement_link, make_achievement_link))
		end
	end

	if reqs.skills then
		local skills = reqs.skills
		local boostable = reqs.skills_boostable
		for idx, skill in ipairs(skills) do
			-- GWD is the offender here, with 60 strength or 60 agility required for access
			local is_boostable = get_modifier_or_false(boostable, idx)
			table.insert(reqs_list, split_and_boost_skill(skill, is_boostable))
		end
	end

	if reqs.item then
		local items = reqs.item
		for _, item in ipairs(items) do
			table.insert(reqs_list, split_general(item, false, make_plink, make_plink))
		end
	end

	if reqs.research then
		local research = reqs.research
		for _, rch in ipairs(research) do
			table.insert(reqs_list, split_general(rch, false, make_achievement_link, make_achievement_link))
		end
	end

	if reqs.other then
		local other = reqs.other
		for _, o in ipairs(other) do
			table.insert(reqs_list, split_general(o, false, no_op, no_op))
		end
	end
	return reqs_list
end

function p.parse_requirements(reqs)
	if not reqs then return "None" end
	local reqs_list = p.build_requirements_list(reqs)

	local requirements_string
	if #reqs_list == 0 then return "None"
	else
		if #reqs_list > 1 then
			reqs_list = arr.map(reqs_list, function (req) return "* " .. req end)
			return '\n'..table.concat(reqs_list,'\n')
		else
			return '\n'..reqs_list[1]
		end
	end
end

p.digsites = {
    ["archaeology guild"] = { link = "Archaeology Guild", pic = "Qualification icon", txt = "Archaeology Guild", size = "25" },
    ["kharid-et"] = { link = "Kharid-et Dig Site", pic = "Archaeology - Kharid-et achievement icon", txt = "Kharid-et", size = "25" },
    ["infernal source"] = { link = "Infernal Source Dig Site", pic = "Archaeology - Infernal Source achievement icon", txt = "Infernal Source", size = "25" },
    ["everlight"] = { link = "Everlight Dig Site", pic = "Archaeology - Everlight achievement icon", txt = "Everlight", size = "25" },
    ["senntisten"] = { link = "Senntisten Dig Site", pic = "Archaeology - Senntisten achievement icon", txt = "Senntisten", size = "25" },
    ["stormguard citadel"] = { link = "Stormguard Citadel Dig Site", pic = "Archaeology - Stormguard achievement icon", txt = "Stormguard Citadel", size = "25" },
    ["warforge"] = { link = "Warforge Dig Site", pic = "Archaeology - Warforge achievement icon", txt = "Warforge", size = "25" },
    ["orthen"] = { link = "Orthen Dig Site", pic = "Archaeology - Orthen achievement icon", txt = "Orthen", size = "25" },
    ["daemonheim"] = { link = "Daemonheim Dig Site", pic = "Archaeology - Daemonheim achievement icon", txt = "Daemonheim", size = "25" },
    ["moonrise"] = { link = "Moonrise Dig Site", pic = "Archaeology - Moonrise achievement icon", txt = "Moonrise", size = "25" },
    ["none"] = { link = "None", pic = "Archaeology-icon", txt = "None", size = "25"},
}

p.cultures = {
    ["stormguard citadel"] = { link = "Armadylean", pic = "Armadylean culture icon", txt = "Armadylean", size = "25" },
    ["armadylean"] = { link = "Armadylean", pic = "Armadylean culture icon", txt = "Armadylean", size = "25" },
    ["warforge"] = { link = "Bandosian", pic = "Bandosian culture icon", txt = "Bandosian", size = "25" },
    ["bandosian"] = { link = "Bandosian", pic = "Bandosian culture icon", txt = "Bandosian", size = "25" },
    ["orthen"] = { link = "Dragonkin", pic = "Dragonkin culture icon", txt = "Dragonkin", size = "25" },
    ["dragonkin"] = { link = "Dragonkin", pic = "Dragonkin culture icon", txt = "Dragonkin", size = "25" },
    ["daemonheim"] = { link = "Dragonkin", pic = "Dragonkin culture icon", txt = "Dragonkin", size = "25" },
    ["everlight"] = { link = "Saradominist", pic = "Saradominist culture icon", txt = "Saradominist", size = "25"  },
    ["saradominist"] = { link = "Saradominist", pic = "Saradominist culture icon", txt = "Saradominist", size = "25"  },
    ["infernal source"] = { link = "Zamorakian", pic = "Zamorakian culture icon", txt = "Zamorakian", size = "25" },
    ["zamorakian"] = { link = "Zamorakian", pic = "Zamorakian culture icon", txt = "Zamorakian", size = "25" },
    ["kharid-et"] = { link = "Zarosian", pic = "Zarosian culture icon", txt = "Zarosian", size = "25" },
    ["zarosian"] = { link = "Zarosian", pic = "Zarosian culture icon", txt = "Zarosian", size = "25" },
    ["senntisten"] = { link = "Zarosian", pic = "Zarosian culture icon", txt = "Zarosian", size = "25" },
    ["moonrise"] = { link = "Guthixian", pic = "Guthixian culture icon", txt = "Guthixian", size = "25" },
    ["agnostic"] = { link = "", pic = "Archaeology-icon", txt = "Agnostic", size = "25" },
}

p.initial_scenery = {
	["archaeology guild"] = "Senntisten soil",
	["varrock"] = "Senntisten soil",
	["senntisten"] = "Ancient gravel (scenery)",
	["kharid-et"] = "Ancient gravel (scenery)",
	["infernal source"] = "Fiery brimstone",
	["everlight"] = "Saltwater mud",
	["stormguard citadel"] = "Aerated sediment",
	["warforge"] = "Earthen clay",
	["orthen"] = "Volcanic ash (scenery)",
	["daemonheim"] = "Volcanic ash (scenery)",
	["moonrise"] = "Mossy peat (scenery)",
	["none"] = "N/A"
}

return p