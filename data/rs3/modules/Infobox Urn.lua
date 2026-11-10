--------------------------
-- Module for {{Infobox Urn}}
--------------------------
local p = {}

local infobox = require('Module:Infobox')
local quantitybox = require('Module:Quantity box')._main
local skillpic = require('Module:Skill clickpic')._main
local yesno = require('Module:Yesno')

local skillbucket, numberarg, quantityarg, restrictionarg, restrictionbucket
local norestrictionbucket, isnorestriction, levelarg, skillheaderarg
local enhancedxparg, enhancedxpbucket, materiallist, materialdisplay, jsonbucket

local no_restriction_values = {
	any = true,
	none = true,
	no = true,
	['n/a'] = true,
}

local urn_bucket_schema = {
	{ param = 'name', field = 'name' },
	{ param = 'skill_bucket', field = 'uses_skill' },
	{ param = 'materials_bucket', field = 'uses_material' },
	{ param = 'exquisite', field = 'is_exquisite' },
	{ param = 'restrict_bucket', field = 'filling_restriction' },
	{ param = 'no_restriction_bucket', field = 'no_restriction' },
	{ param = 'fill_bucket', field = 'experience_to_fill' },
	{ param = 'level_bucket', field = 'crafting_level' },
	{ param = 'xp_bucket', field = 'base_experience' },
	{ param = 'enhanced_xp_bucket', field = 'enhanced_experience' },
}

local urn_bucket_fields = {
	json_bucket = 'json',
}

local urn_json_params = {}

for _, definition in ipairs(urn_bucket_schema) do
	urn_bucket_fields[definition.param] = definition.field
	table.insert(urn_json_params, definition.param)
end

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)
	local materials = materiallist(args, args.skill)

	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'skill', func = 'has_content' },
		{ name = 'skill_bucket', func = { name = skillbucket, params = { 'skill' }, flag = 'p' } },
		{ name = 'skill_header', func = { name = skillheaderarg, params = { 'skill' }, flag = 'p' } },
		{ name = 'materials_bucket', func = function() return materials end },
		{ name = 'materials_display', func = { name = materialdisplay, params = { 'materials_bucket' }, flag = 'd', } },
		{ name = 'exquisite', func = { name = yesno, params = { 'exquisite', false }, flag = { 'p', 'r' } } },
		{ name = 'restrict', func = { name = restrictionarg, params = { 'restrict', 'skill' }, flag = 'p' } },
		{ name = 'restrict_bucket', func = { name = restrictionbucket, params = { 'restrict' }, flag = 'p' } },
		{ name = 'no_restriction_bucket', func = { name = norestrictionbucket, params = { 'restrict' }, flag = 'p' } },
		{ name = 'fill', func = { name = quantityarg, params = { 'fill' }, flag = 'p' } },
		{ name = 'fill_bucket', func = { name = 'numbers', params = { 'fill' }, flag = 'p' } },
		{ name = 'level', func = { name = levelarg, params = { 'level' }, flag = 'p' } },
		{ name = 'level_bucket', func = { name = 'numbers', params = { 'level' }, flag = 'p' } },
		{ name = 'xp', func = { name = quantityarg, params = { 'xp' }, flag = 'p' } },
		{ name = 'xp_bucket', func = { name = 'numbers', params = { 'xp' }, flag = 'p' } },
		{ name = 'enhanced_xp', func = { name = enhancedxparg, params = { 'exquisite', 'xp' }, flag = { 'd', 'p' } } },
		{ name = 'enhanced_xp_bucket', func = { name = enhancedxpbucket, params = { 'exquisite', 'xp' }, flag = { 'd', 'p' } } },
		{ name = 'json_bucket', func = { name = jsonbucket, params = urn_json_params, flag = 'd', } },
	}

	ret:useBucket('infobox_urn', urn_bucket_fields)

	ret:create()
	ret:cleanParams()
	ret:defineLinks()

	ret:defineName('Infobox Urn')
	ret:addClass('left-info')
	ret:addClass('infobox-urn')

	-- PARAMETER: name
	ret:addRow {
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '12' },
	}
		:pad(12)

	local skill = infobox.isDefined(args.skill) and mw.text.trim(args.skill) or ''

	if mw.ustring.lower(skill) == 'prayer' then
		-- PARAMETER: mat#
		if infobox.isDefined(ret:param('materials_display')) then
			ret:addRow {
				{ tag = 'th', content = 'Accepted ashes', colspan = '5' },
				{ tag = 'argd', content = 'materials_display', colspan = '7' },
			}
		end
	else
		-- PARAMETER: restrict
		ret:addRow {
			{ tag = 'th', content = 'Filling restriction', colspan = '5' },
			{ tag = 'argd', content = 'restrict', colspan = '7' },
		}
	end

	-- PARAMETER: fill
	ret:addRow {
		{ tag = 'th', content = 'Experience to fill', colspan = '5' },
		{ tag = 'argd', content = 'fill', colspan = '7' },
	}

	-- PARAMETER: level
		:addRow {
			{ tag = 'th', content = 'Level to add rune', colspan = '5' },
			{ tag = 'argd', content = 'level', colspan = '7' },
		}
		:pad(12)

		:addRow {
			{ tag = 'argh', content = 'skill_header', class = 'infobox-subheader', colspan = '12' },
		}
		:pad(12)

	-- PARAMETER: xp
		:addRow {
			{ tag = 'th', content = 'Basic', colspan = '5' },
			{ tag = 'argd', content = 'xp', colspan = '7' },
		}

		:addRow {
			{ tag = 'th', content = 'With [[urn enhancer]]', colspan = '5' },
			{ tag = 'argd', content = 'enhanced_xp', colspan = '7' },
		}
		:pad(6)

	ret:finish()

	return ret:tostring()
end

function skillbucket(skill)
	if not infobox.isDefined(skill) then
		return nil
	end

	skill = mw.text.trim(skill)

	return mw.ustring.upper(mw.ustring.sub(skill, 1, 1))
		.. mw.ustring.lower(mw.ustring.sub(skill, 2))
end

function numberarg(value)
	if not infobox.isDefined(value) then
		return nil
	end

	return tonumber((tostring(value):gsub(',', '')))
end

function quantityarg(value)
	if not infobox.isDefined(value) then
		return nil
	end

	return quantitybox(value)
end

function isnorestriction(restrict)
	if not infobox.isDefined(restrict) then
		return nil
	end

	return no_restriction_values[
		mw.ustring.lower(mw.text.trim(restrict))
	] == true
end

function restrictionarg(restrict, skill)
	if not infobox.isDefined(restrict) then
		return nil
	end

	if isnorestriction(restrict) then
		return 'Any level'
	end

	if not infobox.isDefined(skill) then
		return nil
	end

	return skillpic(skill, restrict)
end

function restrictionbucket(restrict)
	if not infobox.isDefined(restrict) or isnorestriction(restrict) then
		return nil
	end

	return numberarg(restrict)
end

function norestrictionbucket(restrict)
	if not infobox.isDefined(restrict) then
		return nil
	end

	return isnorestriction(restrict)
end

function levelarg(level)
	if not infobox.isDefined(level) then
		return nil
	end

	return skillpic('Crafting', level)
end

function skillheaderarg(skill)
	if not infobox.isDefined(skill) then
		return nil
	end

	return skillpic(skill) .. ' Experience granted'
end

function enhancedxpbucket(exquisite, xp)
	xp = numberarg(xp)

	if xp == nil then
		return nil
	end

	local multiplier = exquisite and 1.3125 or 1.25

	return math.floor(xp * multiplier * 10) / 10
end

function enhancedxparg(exquisite, xp)
	local enhanced_xp = enhancedxpbucket(exquisite, xp)

	if enhanced_xp == nil then
		return nil
	end

	return quantitybox(enhanced_xp)
end

function materiallist(args, skill)
	if not infobox.isDefined(skill)
		or mw.ustring.lower(mw.text.trim(skill)) ~= 'prayer'
	then
		return nil
	end

	local materials = {}

	for index = 1, 100 do
		local material = args['mat' .. index]

		if infobox.isDefined(material) then
			table.insert(materials, mw.text.trim(material))
		end
	end

	if #materials == 0 then
		return nil
	end

	return materials
end

function materialdisplay(materials)
	if type(materials) ~= 'table' or #materials == 0 then
		return nil
	end

	local links = {}

	for _, material in ipairs(materials) do
		table.insert(links, string.format('[[%s]]', material))
	end

	return table.concat(links, '<br>')
end

function jsonbucket(...)
	local data = {}

	for index, definition in ipairs(urn_bucket_schema) do
		local value = select(index, ...)

		if infobox.isDefined(value) then
			data[definition.field] = value
		end
	end

	return mw.text.jsonEncode(data)
end

return p