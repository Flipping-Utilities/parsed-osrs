--------------------------------------------------------------------------------
-- Helper module for working with achievements.
--
-- Based on common code of [[Module:Achievements]]
-- and [[Module:Achievement description]].
--
-- @module achUtil
-- @alias  p
-- @require [[mw:Special:MyLanguage/Extension:Scribunto/Lua reference manual#libraryUtil|libraryUtil]]
--------------------------------------------------------------------------------

require("strict")
local checkType
do
	local _libraryUtil = require("libraryUtil")
	checkType = _libraryUtil.checkType
end
local ustr = mw.ustring
local getArgs = require("Module:Arguments").getArgs
local skill_clickpic = require('Module:Skill_clickpic')._main

local p = {}

-- Constants and sort order

p.skill_names = {
    'Agility', 'Archaeology', 'Attack', 'Constitution', 'Construction',
    'Cooking', 'Crafting', 'Defence', 'Divination', 'Dungeoneering',
    'Farming', 'Firemaking', 'Fishing', 'Fletching', 'Herblore',
    'Hunter', 'Invention', 'Magic', 'Mining', 'Necromancy',
    'Prayer', 'Ranged', 'Runecrafting', 'Slayer', 'Smithing',
    'Strength', 'Summoning', 'Thieving', 'Woodcutting'
}

p.non_skill_names = {
    'Total', 'Combat', 'Quest points', 'Music', 'RuneScore'
}

p.sort_order = {}
local num_skills = #p.skill_names
for i, skill in ipairs(p.skill_names) do
    p.sort_order[skill] = i
end
for j, non_skill in ipairs(p.non_skill_names) do
    p.sort_order[non_skill] = num_skills + j
end

p.BOOSTABLE = "<small title='This skill can be boosted.' style='cursor: help; border-bottom: 1px dotted'>'''(B)'''</small>"

--------------------------------------------------------------------------------
-- Returns the target page of the wikilink.
--
-- @param {string} link the wikilink to get the target page of.
-- @return {string} the target page of the wikilink.
--------------------------------------------------------------------------------
function p.toUnlinkedPage(link)
	checkType('"Module:Achievement".toUnlinkedPage', 1, link, "string")

	local unlinkedpage = link:match("%[%[(.-)%]%]")
	if unlinkedpage then
		-- Excluding the separator:
		local pos = unlinkedpage:find("|")
		if pos then
			unlinkedpage = unlinkedpage:sub(1, pos - 1)
		end
	end
	return mw.text.trim(unlinkedpage or link)
end

function p.unlinked_page(frame)
	return p.toUnlinkedPage(getArgs(frame)[1])
end

local ROMAN_NUMERAL_VALUES = {
	I = 1,
	V = 5,
	X = 10,
	L = 50,
	C = 100,
	D = 500,
	M = 1000,
}

--------------------------------------------------------------------------------
-- Parses the roman numeral into a Lua number.
--
-- @param {string} num the roman numeral value.
-- @return {number} the parsed number value.
--------------------------------------------------------------------------------
function p.parseRomanNumeral(num)
	checkType('"Module:Achievement util".parseRomanNumeral', 1, num, "string")

	local ret, lval = 0, 0
	local lchar

	for c in ustr.gmatch(num, ".") do
		local v = ROMAN_NUMERAL_VALUES[c]
		if (not v) then
			return error("Unknown character in roman numeral: " .. c)
		end
		if (lchar and lchar ~= c) then
			if (v > ROMAN_NUMERAL_VALUES[lchar]) then
				lval = -lval
			end
			ret = ret + lval
			lval = 0
		end
		lchar = c
		lval = lval + v
	end

	return ret + lval
end

local ROMAN_NUMERALS_PATTERN = "()%f[^%s%z]([IVXLCDM]+)$"
-- Largest number in achievements is currently 4 digits long. Update this
-- if an achievement ever gets more digits
local MAXIMUM_NUMERAL_WIDTH = 5

--------------------------------------------------------------------------------
-- Returns the sort key for the achievement name.
--
-- @param {string} name the achievement name.
-- @return {string} the sort key, with any trailing roman numerals
--         replaced with a decimal number, and then any decimal number
--         z-filled to be MAXIMUM_NUMERAL_WIDTH digits long, so
--         that "a9b" < "a10b", case-folded
--------------------------------------------------------------------------------
function p.toSortKey(name)
	checkType('"Module:Achievement util".toSortKey', 1, name, "string")

	-- Uses `mw.ustring` to correctly handle all Unicode space characters
	local pos, num = ustr.match(name, ROMAN_NUMERALS_PATTERN)
	if num then
		num = p.parseRomanNumeral(num)
		name = ustr.sub(name, 1, pos - 1) .. num
	end

	name = name:gsub("%d+", function(n)
		if n:len() > MAXIMUM_NUMERAL_WIDTH then
			error(("Please update MAXIMUM_NUMERAL_WIDTH in [[Module:Achievement util]] to be at least %d"):format(n:len()))
		end
		return ("0"):rep(MAXIMUM_NUMERAL_WIDTH - n:len()) .. n
	end)

	return mw.language.getContentLanguage():caseFold(name)
end

--- Extracting and formatting requirements
local function format_numeric(numeric_requirement)
    if not numeric_requirement.amount then
		return ""
    end

    local display_name = numeric_requirement.name
    if display_name == "Music" then
        display_name = display_name .. " tracks"
    elseif display_name == "Total" or display_name == "Combat" then
        display_name = display_name .. " level"
    end

    local amount_str = skill_clickpic(numeric_requirement.name, numeric_requirement.amount) .. " [[" .. display_name .. "]]"
    if numeric_requirement.is_boostable then
        amount_str = amount_str .. " " .. p.BOOSTABLE
    end

    return "* " .. amount_str
end

-- Parse requirements text and extracts numeric data (skills + skill-like things) and other data
function p.parse_requirements_text(requirements_text)
	if not requirements_text or requirements_text == "" then
		return {}, {}
	end
	
    local numeric_requirements = {}
    local non_numeric_requirements = {}

    if requirements_text then
        for _, requirement in ipairs(mw.text.split(requirements_text, "\n")) do
            -- These include what I'm calling "numerics" - things like runescore, total level, music tracks
            local data_skill_name = requirement:match('data%-skill=\"([a-zA-Z %-]+)\"')
            local data_skill_level = requirement:match('data%-level=\"(%d+)\"')
            if data_skill_name and data_skill_level then
                local numeric_requirement = {
                    name = data_skill_name,
                    amount = tonumber(data_skill_level),
                    is_boostable = requirement:match("'''%(B%)'''") ~= nil
                }
                table.insert(numeric_requirements, numeric_requirement)
            else
				-- Trim, from the start of the string: 1) any whitespace, any asterisks, any whitespace, catpture more than one of any character, lose whitespace until the end
				local meaningful_text = requirement:match("^%s*%**%s*(.+)%s*$")
				if meaningful_text and (not (meaningful_text == "None")) then
					table.insert(non_numeric_requirements, "* " .. meaningful_text)
				end
           end
        end
    end
	return numeric_requirements, non_numeric_requirements
end

function p.sort_and_combine_requirements(numeric_requirements, non_numeric_requirements)
	local formatted_numerics = {}
	for _, numeric_requirement in ipairs(numeric_requirements) do
		local formatted_numeric = format_numeric(numeric_requirement)
		if formatted_numeric ~= "" then
			table.insert(formatted_numerics, formatted_numeric)
		end
	end
	
    table.sort(numeric_requirements, function(a, b)
        local a_order = p.sort_order[a.name] or 999
        local b_order = p.sort_order[b.name] or 999
        return a_order < b_order
    end)

    local formatted_requirements = {}
    for _, numeric in ipairs(formatted_numerics) do
    	table.insert(formatted_requirements, numeric)
    end
	for _, non_numeric in ipairs(non_numeric_requirements) do
    	table.insert(formatted_requirements, non_numeric)
    end
    
    return table.concat(formatted_requirements, "\n")
end

return p