--------------------------
-- Module for [[Template:Skill info]]
--------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local paramtest = require('Module:Paramtest')
local infobox = require('Module:Infobox')
local yesno = require('Module:Yesno')
local scp = require('Module:Skill clickpic')._main
local qty = require('Module:Quantity box')._main
local editbutton = require('Module:Edit button')
local edit = editbutton("'''?''' (edit)")

local presets = require('Module:Skill info/presets')

local MAXSKILL = 5 -- maximum amount of skills to iterate over; when changing this also change the `skillnames` param definition.

local SKILLS = {
	'Attack',			'Constitution',	'Mining',
	'Strength',			'Agility',		'Smithing',
	'Defence',			'Herblore',		'Fishing',
	'Ranged',			'Thieving',		'Cooking',
	'Prayer',			'Crafting',		'Firemaking',
	'Magic',			'Fletching',	'Woodcutting',
	'Runecrafting',		'Slayer',		'Farming',
	'Construction',		'Hunter',		'Summoning',
	'Dungeoneering',	'Divination',	'Invention',
	'Archaeology',		'Necromancy',
}

local TIME_UNITS = {
	s = 1, sec = 1, secs = 1, second = 1, seconds = 1,
	m = 60, min = 60, mins = 60, minute = 60, minutes = 60,
	h = 3600, hr = 3600, hrs = 3600, hour = 3600, hours = 3600,
	d = 86400, dy = 86400, dys = 86400, day = 86400, days = 86400,
	w = 604800, wk = 604800, wks = 604800, week = 604800, weeks = 604800,
	mo = 2592000, mos = 2592000, month = 2592000, months = 2592000,
}

-- array contains val
local function contains(tbl, val)
	for _, item in ipairs(tbl) do
		if item == val then
			return true
		end
	end
	return false
end
local function addNamedRow(ret, name, label, tblwidth, mand)
	if ret:paramDefined(name) or contains(mand, name) then
		ret:addRow{
			{ tag = 'argh', content = label, colspan = math.ceil(tblwidth/2) },
			{ tag = 'argd', content = name, colspan = math.floor(tblwidth/2) }
		}
	end
end

local function addHeader(ret, trigger_param, label, tblwidth, mand)
	if ret:paramDefined(trigger_param) or contains(mand, trigger_param) then
		ret:pad(tblwidth)
		ret:addRow{
			{ tag = 'th', content = label, class = 'infobox-subheader', colspan = tblwidth },
		}
		ret:pad(tblwidth)
	end
end

local function labelarg(lbl, skill, xp, note, note_name)
    if not infobox.isDefined(skill) then
		if (tonumber(xp) or 0) < 0 then
			return "[PLACEHOLDER]"
		else
			return nil
		end
	end

	local ref = ''
	if infobox.isDefined(note) then
        if not infobox.isDefined(note_name) then
            note_name = nil
        end	

		ref = mw.getCurrentFrame():extensionTag{ name = 'ref', content = note, args = { group = 'i', name = note_name } }
	end

	if infobox.isDefined(lbl) then
		return lbl .. ref
	else
		return string.format('[[%s|%s XP]]', skill, skill) .. ref
	end
end

local function exparg(xp)
	if xp ~= '' then
		return qty(xp)
	else
		return qty(0) .. edit
	end
end

local function expdisp(xp)
	-- default: show (needs explicit -1 to be hidden)
	if (tonumber(xp) or 1) < 0 then
		return 'infobox-cell-hidden'
	else
		return 'infobox-cell-shown'
	end
end

local function tolist(...)
	return {...}
end

-- Make list of clickpics for output
local function clickpicsarg(names, lvls, boostables)
	local ret = ''
	for i, lvl in ipairs(lvls) do
		local name = names[i]
		local boostable = yesno(boostables[i])
		if paramtest.has_content(name) and paramtest.has_content(lvl) then
			if lvl == 'Varies' then
				ret = ret .. 'Varies ' .. scp(name)
			else
				ret = ret .. scp(name, lvl)
			end
			-- yesno will return nil if boostable isn't a yesnoish value, which is shown as unknown above level 1
			if boostable == true then
				ret = ret .. ' <sup title="This requirement is boostable" style="cursor:help; text-decoration:underline dotted;">(b)</sup>'
			elseif boostable == false then
				ret = ret .. ' <sup title="This requirement is not boostable" style="cursor:help; text-decoration:underline dotted;">(nb)</sup>'
			elseif (tonumber(lvl) or 0) > 1 then
				ret = ret .. ' <sup title="Unknown whether this requirement is boostable" style="cursor:help; text-decoration:underline dotted;">(b?)</sup>'
			end
		end
	end
	if ret ~= '' then
		return ret
	else
		return edit
	end
end

local function boostablebucket(name, boostable)
	if paramtest.has_content(name) and yesno(boostable) == true then
		return name
	elseif paramtest.has_content(name) then
		return 'unknown'
	end
	return nil
end

local function unknownboostablearg(name, lvl, boostable)
	if paramtest.has_content(name) and (tonumber(lvl) or 0) > 1 and yesno(boostable) == nil then
		return true
	end
	return false
end

local function numericarg(arg)
	if not infobox.isDefined(arg) then
		return edit
	end
	return arg
end

local function productarg(product, productqty)
	if not infobox.isDefined(product) then
		return nil
	end

	local quantity = tonumber(productqty) or 1
	if quantity > 1 then
		return product .. ' &times; ' .. tostring(quantity)
	end

	return product
end

local function lvlbucket(skills, lvls, name)
	for i, s in ipairs(skills) do
		if string.lower(s) == name then
			return lvls[i]
		end
	end
	return nil
end

local function expbucket(skills, xp1, xp2, xp3, xp4, xp5, name)
	local xp = {xp1, xp2, xp3, xp4, xp5}
	for i, s in ipairs(skills) do
		if string.lower(s) == name then
			return xp[i]
		end
	end
	return nil
end

-- Take the link targets from any list of links and turn it into a plain csv
local function linkcsv(str)
	if type(str) ~= 'string' then return str end
	str = string.gsub(str, '%[%[File:[^%]]+%]%]', '')
	local ret = {}
	for m in string.gmatch(str, '%[%[([^%]|]+)') do
		table.insert(ret, m)
	end
	for m in string.gmatch(str, '%{%{[Pp]link|([^%}|]+)') do
		table.insert(ret, m)
	end

	return table.concat(ret, '&&SPLITPOINT&&')
end

local function csv_to_multi(raw, links)
    assert(type(links) == 'boolean')

    local r = string.gsub(raw, "'\"`UNIQ[^`]*QINU`\"'", '') -- UNIQ QINU typically means unparsed content, such as <ref></ref>. Remove this from bucket
	if infobox.isDefined(raw) then
		if links then
			r = linkcsv(r)
		else
			r = string.gsub(r, '%s*,%s*', '&&SPLITPOINT&&')
		end
		return r
    end
	return nil
end

local function timeValueToSeconds(value, unit, skipRounding)
	value = tostring(value or ''):gsub(',', '')
	value = tonumber(value)
	unit = string.lower(unit or ''):gsub('%.', '')

	local multiplier = TIME_UNITS[unit]
	if not value or not multiplier then
		return nil
	end

	local seconds = value * multiplier
	if skipRounding then
		return seconds
	end

	local ticks = math.floor(seconds / 0.6 + 0.5)

	return ticks * 6 / 10
end

local function respawnTimeArg(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	arg = mw.text.trim(tostring(arg))
		:gsub('–', '-')
		:gsub('—', '-')
		:gsub('−', '-')

	local firstValue, firstUnit, secondValue, secondUnit = arg:match(
		'^([%d,]*%.?%d+)%s*([%a%.]*)%s*%-%s*' ..
		'([%d,]*%.?%d+)%s*([%a%.]*)%s*$'
	)

	if firstValue then
		if firstUnit == '' then
			firstUnit = secondUnit
		end

		if secondUnit == '' then
			secondUnit = firstUnit
		end

		local minimum = timeValueToSeconds(firstValue, firstUnit)
		local maximum = timeValueToSeconds(secondValue, secondUnit)

		if not minimum or not maximum then
			return nil
		end

		if minimum > maximum then
			minimum, maximum = maximum, minimum
		end

		return {
			minimum = minimum,
			maximum = maximum,
		}
	end

	local firstValue, firstUnit, secondValue, secondUnit = arg:match(
		'^([%d,]*%.?%d+)%s*([%a%.]+)%s*,?%s+' ..
		'([%d,]*%.?%d+)%s*([%a%.]+)%s*$'
	)

	if firstValue then
		local firstSeconds = timeValueToSeconds(
			firstValue,
			firstUnit,
			true
		)
		local secondSeconds = timeValueToSeconds(
			secondValue,
			secondUnit,
			true
		)

		if not firstSeconds or not secondSeconds then
			return nil
		end

		return timeValueToSeconds(
			firstSeconds + secondSeconds,
			'seconds'
		)
	end

	local value, unit = arg:match('^([%d,]*%.?%d+)%s*([%a%.]+)%s*$')

	return timeValueToSeconds(value, unit)
end

function dropversionparg(drop, ver)
	if infobox.isDefined(drop) then
		return drop
	elseif infobox.isDefined(ver) then
		return ver
	end

	return nil
end

local function addcategories(args, catargs, mand)
	local ret = {}

	-- mandatory arguments missing
	for _, v in ipairs(mand) do
		if catargs[v] and not catargs[v].all_defined then
			if v ~= 'skill1exp' then -- skill1exp is handled individually for a more specific category
				table.insert(ret, 'Missing skill info values')
				mw.log(v .. " is not defined (missing skill info values)")
			end
		end
	end

	-- Experience missing for one of the versions, or for any skill1 version
	local missingboostable = false
	for i = 1, 5 do
		local stri = tostring(i)
		-- Any skill# that has experience defined at least once, should specify it for every version. Also skill1 must be filled out fully.
		if (catargs['skill'..stri..'exp_def'].one_defined or i == 1) then
			-- No experience rate given for at least one version
			if not catargs['skill'..stri..'exp_def'].all_defined then
				table.insert(ret, 'Needs experience info')
			elseif not catargs['skill'..stri..'exp_bucket'].all_defined then
				table.insert(ret, 'Pages with non-numeric experience quantity')
			end
			-- No label specified for at least one version
			if not catargs['skill'..stri..'label'].all_defined then
				table.insert(ret, 'Missing skill info values')
			end
		end

		local unknownboostable = args['skill'..stri..'unknown_boostable']
		if unknownboostable.d == true then
			missingboostable = true
		elseif unknownboostable.switches then
			for _, v in ipairs(unknownboostable.switches) do
				if v == true then
					missingboostable = true
					break
				end
			end
		end
	end
	if missingboostable then
		table.insert(ret, 'Recipes missing boostable')
	end

	-- Determine skill-related categories to add
	local skills = {}
	-- Get list of all `skillnames` params, which in turn consist of a full list of skill names for each switch version
	local skillstr = args['skillnames_str']
	local skillnames = skillstr.switches
	-- for non-switched boxes, just use the default; otherwise, append the default values
	if not skillnames then
		skillnames = {skillstr.d}
	else
		table.insert(skillnames, skillstr.d)
	end
	-- iterate over all skills and toggle associative array for listed skills
	for _, ver in ipairs(skillnames) do
		for s in mw.text.gsplit(ver, ',') do
			if paramtest.has_content(s) then
				skills[s] = true
			end
		end
	end
	-- add actual skill categories
	for skill, _ in pairs(skills) do
		table.insert(ret, skill)
	end

	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if v ~= '' then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end

	return table.concat(ret, '')
end

function p.main(frame)
	local args = frame:getParent().args
	local preset = frame.args[1] and string.lower(frame.args[1]) or args.preset
	mw.log(preset)
	local mand = {}
	if preset and presets[preset] then
		args, mand = presets[preset](args)
	end
	return p._main(args, mand)
end

function p._main(args, mand)
	table.insert(mand, 'skill1exp') -- Experience is a mandatory parameter
	local ret = infobox.new(args)
	ret:defineParams{
		{ name = 'name', func = 'name' },
		{ name = 'itemname', func = { name = paramtest.default_to, params = { 'itemname', "Uses item" }, flag = { 'p', 'r' } } },
		{ name = 'item', func = 'hasContent' },
		{ name = 'item_bucket', func = { name = csv_to_multi, params = { 'item', true }, flag = { 'p', 'r' } } },
		{ name = 'locname', func = { name = paramtest.default_to, params = { 'locname', "Location" }, flag = { 'p', 'r' } } },
		{ name = 'loc', func = 'hasContent' },
		{ name = 'loc_bucket', func = { name = csv_to_multi, params = { 'loc', true }, flag = { 'p', 'r' } } },
		{ name = 'facilityname', func = { name = paramtest.default_to, params = { 'facilityname', "Facility" }, flag = { 'p', 'r' } } },
		{ name = 'facility', func = 'hasContent' },
		{ name = 'facility_bucket', func = { name = csv_to_multi, params = { 'facility', true }, flag = { 'p', 'r' } } },
		{ name = 'typename', func = { name = paramtest.default_to, params = { 'typename', "Type" }, flag = { 'p', 'r' } } },
		{ name = 'type', func = 'hasContent' },
		{ name = 'type_bucket', func = { name = csv_to_multi, params = { 'type', true }, flag = { 'p', 'r' } } },
		{ name = 'toolname', func = { name = paramtest.default_to, params = { 'toolname', "Required tool" }, flag = { 'p', 'r' } } },
		{ name = 'tool', func = 'hasContent' },
		{ name = 'tool_bucket', func = { name = csv_to_multi, params = { 'tool', true }, flag = { 'p', 'r' } } },
		{ name = 'product', func = { name = productarg, params = { 'product', 'productqty' }, flag = 'p' } },
		{ name = 'productname', func = { name = paramtest.default_to, params = { 'productname', "Product" }, flag = { 'p', 'r' } } },
		{ name = 'product_bucket', func = { name = csv_to_multi, params = { 'product', true }, flag = { 'p', 'r' } } },
		{ name = 'product_main_bucket', func = { name = csv_to_multi, params = { 'product', true }, flag = { 'p', 'r' } } },		{ name = 'timename', func = { name = paramtest.default_to, params = { 'timename', "Respawn time" }, flag = { 'p', 'r' } } },
		{ name = 'time', func = 'hasContent' },
		{ name = 'time_bucket', func = { name = csv_to_multi, params = { 'time', true }, flag = { 'p', 'r' } } },
		{ name = 'damage', func = 'hasContent' },
		{ name = 'damagename', func = { name = paramtest.default_to, params = { 'damagename', "Damage" }, flag = { 'p', 'r' } } },
		{ name = 'damage_bucket', func = { name = csv_to_multi, params = { 'damage', true }, flag = { 'p', 'r' } } },
		{ name = 'multiloot_x2_name', func = { name = paramtest.default_to, params = { 'multiloot_x2_name', "Double loot" }, flag = { 'p', 'r' } } },
		{ name = 'multiloot_x3_name', func = { name = paramtest.default_to, params = { 'multiloot_x3_name', "Triple loot" }, flag = { 'p', 'r' } } },
		{ name = 'multiloot_x4_name', func = { name = paramtest.default_to, params = { 'multiloot_x4_name', "Quadruple loot" }, flag = { 'p', 'r' } } },
		{ name = 'multiloot_x2_levels', func = 'hasContent' },
		{ name = 'multiloot_x3_levels', func = 'hasContent' },
		{ name = 'multiloot_x4_levels', func = 'hasContent' },
		{ name = 'members', func = yesno },
		{ name = 'dropversion', func = { name = dropversionparg, params = { 'dropversion', 'version' }, flag='d' } },
		{ name = 'source_template', func = { name = tostring, params = { 'skill info' }, flag = 'r' } },
	}

	-- Generate skill-related arguments for each skill, similar to [[Template:Recipe]]
	for i = 1, MAXSKILL do
		local s = 'skill'..tostring(i)
		ret:defineParams{
			{ name = s..'name', func = 'hasContent' },
			{ name = s..'boostable', func = yesno },
			{ name = s..'lvl', func = { name = numericarg, params = { s..'lvl' }, flag = 'd' } },
			{ name = s..'disp', func = { name = expdisp, params = { s..'exp' }, flag = 'p' }, dupes = true },
			{ name = s..'exp', func = { name = exparg, params = { s..'exp' }, flag = 'd' }, dupes = true },
			{ name = s..'exp_def', func = { name = 'hasContent', params = { s..'exp' }, flag = 'p' } }, -- used for category, to check if the experience is actually defined
			{ name = s..'exp_bucket', func = { name = tonumber, params = { s..'exp' }, flag = 'p' } },
			{ name = s..'unknown_boostable', func = { name = unknownboostablearg, params = { s..'name', s..'lvl', s..'boostable' }, flag = 'p' } },
			{ name = s..'label', func = { name = labelarg, params = { s..'label', s..'name', s..'exp_bucket', s..'note', s..'note_name' }, flag = 'd' } },
		}
		-- Bucket
		ret:defineParams{
			{ name = s..'boostable_bucket', func = { name = boostablebucket, params = { s..'name', s..'boostable' }, flag = 'p' } },
			{ name = s.."skill_json", func = { name = skill_json, params = { s..'name', s..'lvl', s..'exp', s..'boostable' }, flag = {'p', 'p', 'p', 'p', 'p'} } }
		}
	end
	ret:defineParams{
		{ name = 'skillnames', func = { name = tolist, params = { 'skill1name', 'skill2name', 'skill3name', 'skill4name', 'skill5name' }, flag = 'p' } },
		{ name = 'skillnames_str', func = { name = table.concat, params = { 'skillnames', ',' }, flag = { 'd', 'r' } } },
		{ name = 'skillnames_bucket', func = { name = csv_to_multi, params = { 'skillnames_str', false }, flag = { 'd', 'r' } } },
		{ name = 'levels', func = { name = tolist, params = { 'skill1lvl', 'skill2lvl', 'skill3lvl', 'skill4lvl', 'skill5lvl' }, flag = 'p' } },
		{ name = 'boostables', func = { name = tolist, params = { 'skill1boostable', 'skill2boostable', 'skill3boostable', 'skill4boostable', 'skill5boostable' }, flag = 'p' } },
		{ name = 'clickpics', func = { name = clickpicsarg, params = { 'skillnames', 'levels', 'boostables' }, flag = 'd' } },
	}
	
	-- Bucket
	ret:defineParams{
		{ name = 'production_json', func = {
			name = recipe_json, 
			params = { 'name', 'members', 'facility_bucket', 'tool_bucket', 'item_bucket', 'product_bucket', 'productqty', 'time',
				'skill1skill_json', 'skill2skill_json', 'skill3skill_json', 'skill4skill_json', 'skill5skill_json' }, 
			flag = {'p', 'p', 'd', 'd', 'd', 'd', 'p', 'p', 'd', 'd', 'd', 'd', 'd'} 
		} }
	}
	
	ret:useBucket("recipe", {
		item_bucket = 'uses_material',
		facility_bucket = 'uses_facility',
		tool_bucket = 'uses_tool',
		members = 'is_members_only',
		skillnames_bucket = 'uses_skill',
		skill1boostable_bucket = 'is_boostable',
		skill2boostable_bucket = 'is_boostable',
		skill3boostable_bucket = 'is_boostable',
		skill4boostable_bucket = 'is_boostable',
		skill5boostable_bucket = 'is_boostable',
		product_bucket = 'production_output',
		product_main_bucket = 'production_main_output',
		production_json = 'production_json',
		source_template = 'source_template'
	})

	for _, s in ipairs(SKILLS) do
		local lcs = string.lower(s)
		-- These functions take in all lvl/xp info and poop out only the lvl/xp for the skill `lcs`.
		ret:defineParams{
			{ name = lcs..'lvl', func = { name = lvlbucket, params = { 'skillnames', 'levels', lcs }, flag = { 'd', 'd', 'r' } } },
			{ name = lcs..'exp', func = {
				name = expbucket,
				params = { 'skillnames', 'skill1exp_bucket', 'skill2exp_bucket', 'skill3exp_bucket', 'skill4exp_bucket', 'skill5exp_bucket', lcs },
				flag = { 'd', 'd', 'd', 'd', 'd', 'd', 'r' }
			} },
		}
	end

	ret:setNameCheck(false)
	ret:create()
	ret:cleanParams()

	for i = 1, MAXSKILL do
		local s = 'skill'..tostring(i)
		-- link exp box to the respective class stored in disp
		ret:linkParams{
			{ s..'exp', s..'disp' },
		}
	end

	ret:customButtonPlacement(true)
	ret:addButtonsCaption()

	ret:defineLinks({ hide = true })

	ret:defineName('Skill info')
	ret:addClass('skill-info')

	local tblwidth = 10

	ret:addRow{
		{ tag = 'argh', content = 'name', class='infobox-header', colspan = tblwidth }
	}

	:pad(tblwidth)

	:addRow{
		{ tag = 'th', content = 'Level required', colspan = math.ceil(tblwidth/2) },
		{ tag = 'argd', content = 'clickpics', colspan = math.floor(tblwidth/2) }
	}

	for i = 1, MAXSKILL do
		local s = 'skill'..tostring(i)
		addNamedRow(ret, s..'exp', s..'label', tblwidth, mand)
	end

	addNamedRow(ret, 'item', 'itemname', tblwidth, mand)
	addNamedRow(ret, 'loc', 'locname', tblwidth, mand)
	addNamedRow(ret, 'facility', 'facilityname', tblwidth, mand)
	addNamedRow(ret, 'type', 'typename', tblwidth, mand)
	addNamedRow(ret, 'tool', 'toolname', tblwidth, mand)
	addNamedRow(ret, 'time', 'timename', tblwidth, mand)
	addNamedRow(ret, 'damage', 'damagename', tblwidth, mand)
	addHeader(ret, 'multiloot_x2_levels', '[[Thieving#Pickpocketing multiple loot|Multiple loot potential]]', tblwidth, mand)
	addNamedRow(ret, 'multiloot_x2_levels', 'multiloot_x2_name', tblwidth, mand)
	addNamedRow(ret, 'multiloot_x3_levels', 'multiloot_x3_name', tblwidth, mand)
	addNamedRow(ret, 'multiloot_x4_levels', 'multiloot_x4_name', tblwidth, mand)
	addNamedRow(ret, 'product', 'productname', tblwidth, mand)

	ret:pad(tblwidth)

	for i = 1, MAXSKILL do
		local s = 'skill'..tostring(i)
		local par = ret:param(s..'name', 'd')
		if infobox.isDefined(par) then
			ret:addDropLevelVars(par:lower(), s..'lvl')
		end
	end

	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2, mand))
	end
	return ret:tostring()
end

function skill_json(name, level, exp, boostable)
	return {
		name = name,
		level = level,
		boostable = yesno(boostable),
		experience = exp,		
	}
end

local function jsonList(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	if type(arg) == "string" then
		return mw.text.split(
			arg,
			infobox.splitpoint,
			true
		)
	end

	return arg
end

function recipe_json(name, members, facility, tool, materials, product, productqty, time, s1, s2, s3, s4, s5)
	local goodSkills = {}
	for _, s in ipairs({s1, s2, s3, s4, s5}) do
		if s["name"] and s["name"] ~= '' then
			table.insert(goodSkills, s)
		end
	end
	
	if name == '' then
		name = nil
	end

	if not infobox.isDefined(facility) then
		facility = nil
	end

	if not infobox.isDefined(tool) then
		tool = nil
	end
	
	local formattedMats = {}
	
	local formattedMats = {}
	if type(materials) == "string" then
		materials = mw.text.split(materials, "&&SPLITPOINT&&", true)
	end
	
	for _, s in ipairs(materials) do
		s = string.gsub(s, "^%[https://.*", '') --Remove edit button string
		if s and s ~= '' then
			table.insert(formattedMats, {name = s, quantity = 1})
		end
	end
	
	local formattedOutputs = {}
	if infobox.isDefined(product) then
		table.insert(formattedOutputs, {page = product, name = product, quantity = tonumber(productqty) or 1})
	end
	
	local jsonObject = {
		name = name,
		skills = goodSkills, 
		members = yesno(members), 
		facilities = jsonList(facility),
		tools = jsonList(tool),
		materials = formattedMats,
		outputs = formattedOutputs,
		respawn_time = respawnTimeArg(time)
	}
	local good, json = pcall(mw.text.jsonEncode, jsonObject)

	if good then
		return json
	end
	return "Error saving json"
end
p._recipe_json = recipe_json
return p