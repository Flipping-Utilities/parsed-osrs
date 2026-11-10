local p = {}

local yesno = require('Module:Yesno')
local arr_insert = require('Module:Array').insert
local has_content = require('Module:Paramtest').has_content
local userError = require("Module:User error")
local skillreq = require('Module:Skill clickpic')._req

local var = mw.ext.VariablesLua

local boostable_tmpl = (function()
	local frame = mw.getCurrentFrame()
	return {
		yes = frame:expandTemplate { title = 'Boostable', args = { 'yes' } },
		no = frame:expandTemplate { title = 'Boostable', args = { 'no' } },
		y = frame:expandTemplate { title = 'Boostable', args = { 'y' } },
		n = frame:expandTemplate { title = 'Boostable', args = { 'n' } },
	}
end)()

p.unit_id_pattern = '(AREQ%-%-.-%-QERA)'

p.skill_names = {
	agility = 'Agility',
	archaeology = 'Archaeology',
	attack = 'Attack',
	constitution = 'Constitution',
	construction = 'Construction',
	cooking = 'Cooking',
	crafting = 'Crafting',
	defence = 'Defence',
	divination = 'Divination',
	dungeoneering = 'Dungeoneering',
	farming = 'Farming',
	firemaking = 'Firemaking',
	fishing = 'Fishing',
	fletching = 'Fletching',
	herblore = 'Herblore',
	hunter = 'Hunter',
	invention = 'Invention',
	magic = 'Magic',
	mining = 'Mining',
	necromancy = 'Necromancy',
	prayer = 'Prayer',
	ranged = 'Ranged',
	runecrafting = 'Runecrafting',
	slayer = 'Slayer',
	smithing = 'Smithing',
	strength = 'Strength',
	summoning = 'Summoning',
	thieving = 'Thieving',
	woodcutting = 'Woodcutting',

	-- special one
	['combat level'] = 'combat level',
	['total level'] = 'total level',
	['quest points'] = 'quest points',
}

local function skill_unit(skill, level, boostable, notes)
	local found_skill = p.skill_names[skill:lower()]

	if found_skill == nil then
		return nil
	end

	level = tonumber(level)
	if level == nil then
		return nil
	end

	return {
		type = 'skill',
		name = found_skill,
		level = level,
		boostable = boostable,
		notes = has_content(notes) and mw.text.trim(notes) or nil
	}
end

local function query_quest(name)
	local query = bucket("infobox_quest")
		.select('page_name', 'name', 'quest.icon')
		.join("quest", "quest.page_name_sub", "infobox_quest.page_name_sub")
		.where(bucket.Or({ 'page_name', name }, { 'name', name }))
		.where(bucket.Not('Category:Removed quests'))

	local bucketdata = query.run()
	if #bucketdata == 0 then
		return nil
	else
		return bucketdata[1]
	end
end

local function quest_unit(name, partial, notes)
	local quest = query_quest(name)
	if quest == nil then
		return nil
	end

	return {
		type = 'quest',
		name = quest.name,
		page_name = quest.page_name,
		icon = quest['quest.icon'],
		partial = partial,
		notes = has_content(notes) and mw.text.trim(notes) or nil
	}
end

local function query_achievement(cheevo)
	local query = bucket("achievement")
		.select('page_name', 'name', 'icon')
		.where(bucket.Or({ 'page_name', cheevo }, { 'name', cheevo }))

	local bucketdata = query.run()
	if #bucketdata == 0 then
		return nil
	else
		return bucketdata[1]
	end
end

local function achievement_unit(cheevo, partial, notes)
	local achievement = query_achievement(cheevo)
	if achievement == nil then
		return nil
	end

	return {
		type = 'achievement',
		name = achievement.name,
		page_name = achievement.page_name,
		icon = achievement.icon,
		partial = partial,
		notes = has_content(notes) and mw.text.trim(notes) or nil
	}
end

local function strip_link(arg)
	return string.gsub(string.gsub(arg, '%]%]', ''), '%[%[', '')
end

local function req_unit(args)
	local arg1 = args[1]
	if not has_content(arg1) then
		return nil
	end

	local req_name = strip_link(args.name or arg1)
	local req_num = tonumber(args.level) or tonumber(args[2]) or 1
	local req_boostable = yesno(args.boostable)
	if req_boostable == nil and args[3] ~= nil then
		req_boostable = args[3] == 'boostable'
	end
	local req_notes = args.notes or args[4]

	-- is it a skill?
	local ret = skill_unit(req_name, req_num, req_boostable, req_notes)
	if ret ~= nil then
		return ret
	end

	local req_partial = yesno(args.partial) or args[2] == 'partial'
	-- is it a quest?
	ret = quest_unit(req_name, req_partial, req_notes)
	if ret ~= nil then
		return ret
	end

	-- is it a achievement?
	ret = achievement_unit(req_name, req_partial, req_notes)
	if ret ~= nil then
		return ret
	end

	-- potential free text
	return nil
end

local function save_unit(content)
	local jsg, json = pcall(mw.text.jsonEncode, content)
	if jsg == nil then
		-- no pcall this time
		json = mw.text.jsonEncode({
			type = 'error',
			message = '`pcall(mw.text.jsonDecode, unit)` failed: ' .. json,
		})
	end

	local unit_id = 'AREQ--' .. mw.hash.hashValue('md5', json) .. '-QERA'
	var.vardefine(unit_id, json)
	return unit_id
end

local function parse_partial_completion(extra)
	-- plain '(partial)'
	local idx, idx_end = extra:find('%(partial%)')
	if idx ~= nil then
		return true, idx_end
	end

	-- 'partial'
	idx, idx_end = extra:find('partial')
	if idx ~= nil then
		return true, idx_end
	end

	-- Full completion (default)
	return false, nil
end

local function parse_quest_and_achievement_with_notes(name, extra)
	local partial, idx_end = parse_partial_completion(extra)
	local notes = extra:match('^%(? ?,? ?(.-)%)?$', idx_end and idx_end + 1 or nil)
	local ret = quest_unit(name, partial, notes)
	if ret ~= nil then
		return ret
	end

	return achievement_unit(name, partial, notes)
end

local function parse_skill_boostable(extra)
	-- {{Boostable|yes}}
	local idx, idx_end = extra:find(boostable_tmpl.yes, 1, true)
	if idx ~= nil then
		return true, idx_end
	end

	-- {{Boostable|y}}
	idx, idx_end = extra:find(boostable_tmpl.y, 1, true)
	if idx ~= nil then
		return true, idx_end
	end

	-- {{Boostable|no}}
	idx, idx_end = extra:find(boostable_tmpl.no, 1, true)
	if idx ~= nil then
		return false, idx_end
	end

	-- {{Boostable|n}}
	idx, idx_end = extra:find(boostable_tmpl.n, 1, true)
	if idx ~= nil then
		return false, idx_end
	end

	-- plain '(not boostable)'
	idx, idx_end = extra:find('%(not boostable%)')
	if idx ~= nil then
		return false, idx_end
	end

	-- plain 'not boostable'
	idx, idx_end = extra:find('not boostable')
	if idx ~= nil then
		return false, idx_end
	end

	-- plain '(boostable)'
	idx, idx_end = extra:find('%(boostable%)')
	if idx ~= nil then
		return true, idx_end
	end

	-- plain 'boostable'
	idx, idx_end = extra:find('boostable')
	if idx ~= nil then
		return true, idx_end
	end

	-- (nb)
	idx, idx_end = extra:find('%([nN][bB]%)')
	if idx ~= nil then
		return false, idx_end
	end

	-- (b)
	idx, idx_end = extra:find('%([bB]%)')
	if idx ~= nil then
		return true, idx_end
	end

	-- Unknown
	return nil, nil
end

local function parse_skill_with_notes(level, skill, extra)
	local boostable, idx_end = parse_skill_boostable(extra)
	local notes = extra:match('^ ?,? ?(.-)$', idx_end and idx_end + 1 or nil)
	notes = notes:gsub('^%( ?(.-) ?%)$', '%1')
	return skill_unit(skill, level, boostable, notes)
end

local function parse_req_unit(line)
	if not has_content(line) then
		return nil
	end

	-- Remove consecutive spaces
	arg = line:gsub(' +', ' ')
	-- Remove '* ' pattern
	line = line:gsub('%* *', '')
	-- Remove bold pattern
	line = line:gsub("'''", '')
	-- Remove italic pattern
	line = line:gsub("''", '')

	-- level skill
	local level, skill, skill_extra = line:match('^(%d+) (%a+) ?(.-)$')
	if level ~= nil or skill ~= nil then
		local ret = parse_skill_with_notes(level, skill, skill_extra)
		if ret ~= nil then
			return ret
		end
	end

	-- {{Skillreq}}
	level = line:match('data%-level=\"(%d+)\"')
	skill = line:match('data%-skill=\"([a-zA-Z %-]+)\"')

	if level ~= nil and skill ~= nil then
		skill_extra = line:match('</%a[%w%-]*> ?(.-)$')

		local ret = parse_skill_with_notes(level, skill, skill_extra)
		if ret ~= nil then
			return ret
		end
	end

	-- linked quest or achievement
	local link, link_extra = line:match('^%[%[([^|%[%]]*)|?[^%[%]]-%]%] ?(.-)$')
	if link ~= nil then
		local ret = parse_quest_and_achievement_with_notes(link, link_extra)
		if ret ~= nil then
			return ret
		end
	end

	-- quest or achievement (with notes)
	local partial_quest_name, partial_extra = line:match('^(.-) %((.-)%)$')
	if partial_quest_name ~= nil then
		local ret = parse_quest_and_achievement_with_notes(partial_quest_name, partial_extra)
		if ret ~= nil then
			return ret
		end
	end

	-- plain quest or achievement
	local ret = quest_unit(line, false)
	if ret ~= nil then
		return ret
	end

	-- is it a achievement?
	ret = achievement_unit(line)
	if ret ~= nil then
		return ret
	end

	-- intangible
	return { type = 'intangible', content = line }
end

local function parse_req_units_from_string(arg)
	local units = {}

	-- Replace line break
	arg = arg:gsub('<br%/?>', '\n')
	for line in mw.text.gsplit(arg, '\n') do
		-- areq unit
		local unit_id = line:match(p.unit_id_pattern)
		if unit_id ~= nil then
			-- retrieve the unit by id
			local unit = p._get_unit(unit_id)
			table.insert(units, unit)
		else
			local unit = parse_req_unit(line)
			if unit ~= nil then
				table.insert(units, unit)
			end
		end
	end

	return units
end

local function parse_req_units_in_op(arg)
	local units = {}

	-- Replace line break
	arg = arg:gsub('<br>', '\n')
	for line in mw.text.gsplit(arg, '\n') do
		-- areq unit
		local unit_id = line:match(p.unit_id_pattern)
		if unit_id ~= nil then
			-- keep the unit id
			table.insert(units, unit_id)
		else
			local unit = parse_req_unit(line)
			if unit ~= nil then
				table.insert(units, unit)
			end
		end
	end

	return units
end

local function req_op_or(args)
	local units = {}

	-- group all content in an argument into an 'and' operator
	for _, arg in ipairs(args) do
		local subunits = parse_req_units_in_op(arg)

		local subunits_length = #subunits
		local content
		if subunits_length == 0 then
			-- Almost impossible
		elseif subunits_length == 1 then
			-- fallback to single unit
			content = subunits[1]
		else
			-- fallback to and units
			content = {
				type = 'and',
				units = subunits,
			}
		end
		table.insert(units, content)
	end

	local unit_length = #units
	if unit_length == 0 then
		-- Almost impossible
		return nil
	elseif unit_length == 1 then
		-- fallback to single unit
		return save_unit(units[1])
	else
		-- multiple units
		local content = {
			type = 'or',
			units = units,
		}
		return save_unit(content)
	end
end

local function req_op_and(args)
	-- potential single areq
	local unit = req_unit(args)
	if unit ~= nil then
		return save_unit(unit)
	end

	-- potential free text
	local units = {}
	for _, arg in ipairs(args) do
		local subunits = parse_req_units_in_op(arg)
		arr_insert(units, subunits, true)
	end

	local unit_length = #units
	if unit_length == 0 then
		-- Almost impossible
		return nil
	elseif unit_length == 1 then
		-- fallback to single unit
		return save_unit(units[1])
	else
		-- multiple units
		local content = {
			type = 'and',
			units = units,
		}
		return save_unit(content)
	end
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

function p._main(args)
	if yesno(args['or']) then
		return req_op_or(args)
	else
		return req_op_and(args)
	end
end

function p._get_unit(content)
	if type(content) == "string" then
		local unit = var.var(content)
		if not has_content(unit) then
			return {
				type = 'error',
				message = '`unit_id` is not found: ' .. content,
			}
		end

		local jsg
		jsg, content = pcall(mw.text.jsonDecode, unit)
		if not jsg then
			return {
				type = 'error',
				message = '`pcall(mw.text.jsonDecode, unit)` failed: ' .. content,
			}
		end
	end

	if content.type == 'or' or content.type == 'and' then
		for i, subunit in ipairs(content.units) do
			content.units[i] = p._get_unit(subunit)
		end
	end

	return content
end

function p._get_units_from_string(arg)
	local units = parse_req_units_from_string(arg)

	local unit_length = #units
	if unit_length == 0 then
		-- Almost impossible
		return nil
	elseif unit_length == 1 then
		-- fallback to single unit
		return units[1]
	else
		-- multiple units, fallback to 'and' unit
		return {
			type = 'and',
			units = units,
		}
	end
end

local function display_requirement_content(unit)
	if unit.type == 'skill' then
		local content = skillreq(unit.name, unit.level)
		if unit.boostable == true then
			content = content .. ' ' .. boostable_tmpl.y
		elseif unit.boostable == false then
			content = content .. ' ' .. boostable_tmpl.n
		end

		if unit.notes ~= nil then
			content = content .. ' (' .. unit.notes .. ')'
		end

		return content
	elseif unit.type == 'quest' then
		local link = '&nbsp;[[' .. unit.page_name .. '|' .. unit.name .. ']]'
		if unit.icon then
			link = '[[File:' .. unit.icon .. '|link=' .. unit.page_name .. '|21x21px]]' .. link
		end

		local content = mw.html.create('span')
			:addClass('achievement-req-quest')
			:attr('data-quest', unit.name)
			:wikitext(link)

		if unit.partial or unit.notes then
			content:attr('data-partial', 'true')

			if unit.partial and unit.notes ~= nil then
				content:wikitext(' (partial, ' .. unit.notes .. ')')
			elseif unit.partial then
				content:wikitext(' (partial)')
			elseif unit.notes ~= nil then
				content:wikitext(' (' .. unit.notes .. ')')
			end
		end
		return content
	elseif unit.type == 'achievement' then
		local link = '&nbsp;[[' .. unit.page_name .. '|' .. unit.name .. ']]'
		if unit.icon then
			link = '[[File:' .. unit.icon .. '|link=' .. unit.page_name .. '|21x21px]]' .. link
		end

		local content = mw.html.create('span')
			:addClass('achievement-req-achievement')
			:attr('data-achievement', unit.name)
			:wikitext(link)

		if unit.partial or unit.notes then
			content:attr('data-partial', 'true')

			if unit.partial and unit.notes ~= nil then
				content:wikitext(' (partial, ' .. unit.notes .. ')')
			elseif unit.partial then
				content:wikitext(' (partial)')
			elseif unit.notes ~= nil then
				content:wikitext(' (' .. unit.notes .. ')')
			end
		end
		return content
	elseif unit.type == 'intangible' then
		local content = mw.html.create('span')
			:addClass('achievement-req-intangible')
			:wikitext(unit.content)
		return content
	elseif unit.type == 'error' then
		local content = userError(unit.message)
		return content .. '[[Category:Erroneous parameter]]'
	end
end

local function create_requirement_ul(parent_node, class)
	return parent_node:tag('ul')
		:addClass(class)
		:css('margin-left', '1.6ch'):css('padding-left', '.9ch')
end

local function display_requirement_unit(arg, parent_node, parent_type)
	if arg.type == 'and' then
		local ul = create_requirement_ul(parent_node, 'achievement-req-and')
		if parent_type == 'or' then
			ul:css('border-left', '1px dashed var(--transcript-border-color)')
		end
		for _, unit in ipairs(arg.units) do
			local li = ul:tag('li')
			display_requirement_unit(unit, li, arg.type)
		end
	elseif arg.type == 'or' then
		parent_node:wikitext('One of: ')
		local ul = create_requirement_ul(parent_node, 'achievement-req-or')
			:css('border-left', '1px dashed var(--transcript-border-color)')
		local unit_length = #arg.units
		for i, unit in ipairs(arg.units) do
			local li = ul:tag('li'):css('list-style', 'none')
			display_requirement_unit(unit, li, arg.type)
			if i < unit_length then
				li:wikitext(" ''or''")
			end
		end
	else
		parent_node:node(display_requirement_content(arg))
	end
end

function p.display_top_level_requirement(arg)
	if arg.type == 'intangible' then
		-- free text
		local ret = mw.html.create()
		ret:tag('ul'):tag('li'):wikitext(arg.content)
		return ret
	elseif arg.type == 'and' or arg.type == 'or' then
		local node = mw.html.create()
		display_requirement_unit(arg, node)
		return node
	else
		local ret = mw.html.create()
		local ul = create_requirement_ul(ret)
		ul:tag('li'):node(display_requirement_content(arg))
		return ret
	end
end

local function should_qc_active_for_content(unit)
	if unit.type == 'skill' then
		return true
	elseif unit.type == 'quest' then
		return true
	elseif unit.type == 'achievement' then
		return false
	elseif unit.type == 'intangible' then
		return false
	elseif unit.type == 'error' then
		return false
	end

	return false
end

local function should_qc_active_for_unit(arg)
	if arg.type == 'and' or arg.type == 'or' then
		local shouldQcActive = false
		for _, unit in ipairs(arg.units) do
			shouldQcActive = shouldQcActive or should_qc_active_for_unit(unit)
		end
		return shouldQcActive
	else
		return should_qc_active_for_content(arg)
	end
end

function p.should_qc_active(arg)
	if arg.type == 'intangible' then
		-- free text
		return false
	elseif arg.type == 'and' or arg.type == 'or' then
		return should_qc_active_for_unit(arg)
	else
		return should_qc_active_for_content(arg)
	end
end

return p