-- <nowiki>
local p = {}

local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local infobox = require('Module:Infobox')
local cleanimg = require("Module:Clean image").clean
local nosic = require('Module:Nosic')._main
local areq = require('Module:Achievement requirement')
local unique = require('Module:Array').unique

local lang = mw.getContentLanguage()
local isDefined = infobox.isDefined

local full_width = '25'
local left_width = '9'
local right_width = '16'

local combatmasteries = {
	easy = { name = 'Easy', score = 1 },
	medium = { name = 'Medium', score = 2 },
	hard = { name = 'Hard', score = 3 },
	elite = { name = 'Elite', score = 4 },
	master = { name = 'Master', score = 5 },
	grandmaster = { name = 'Grandmaster', score = 6 },
}

local hidden_types = {
	'[[List of achievements with hidden details#Type 1 hidden achievements|The previous achievement in the chain must be completed first.]]',
	'[[List of achievements with hidden details#Type 2 hidden achievements|This achievement must be completed first.]]',
}

local function hover_txt(text, tooltip)
	text = text:gsub('"', '&quot;')
	return ' <sup class="hover-text noprint small" title="' .. tooltip .. '">' .. text .. '</sup>'
end

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'members', func = members_arg },
		{ name = 'leagueRegion', func = leaguesArg },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
		{ name = 'description', func = 'has_content' },
		{ name = 'score', func = to_number },
		{ name = 'score disp', func = { name = score_disp, params = { 'score' }, flag = 'd' } },

		{ name = 'maincategory', func = category_arg },
		{ name = 'maincategory disp', func = { name = category_disp, params = { 'maincategory' }, flag = 'd' } },
		{ name = 'subcategory', func = category_arg },
		{ name = 'subcategory disp', func = { name = category_disp, params = { 'subcategory' }, flag = 'd' } },
		{ name = 'subsubcategory', func = category_arg },
		{ name = 'subsubcategory disp', func = { name = category_disp, params = { 'subsubcategory' }, flag = 'd' } },

		{ name = 'combat mastery', func = combat_mastery_arg },
		{ name = 'combat mastery disp', func = { name = combat_mastery_disp, params = { 'combat mastery' }, flag = 'd' } },
		{ name = 'combat mastery bucket', func = { name = combat_mastery_bucket, params = { 'combat mastery' }, flag = 'd' } },
		{ name = 'combat score', func = { name = combat_score_arg, params = { 'combat mastery' }, flag = 'd' } },
		{ name = 'combat score disp', func = { name = combat_score_disp, params = { 'combat score' }, flag = 'd' } },

		{ name = 'storymode', func = yesno },
		{ name = 'storymode disp', func = { name = storymode_disp, params = { 'storymode' }, flag = 'd' } },
		{ name = 'ironmanrestricted', func = yes_only },
		{ name = 'ironmanrestricted disp', func = { name = ironmanrestricted_disp, params = { 'ironmanrestricted' }, flag = 'd' } },

		{ name = 'mqc', func = yes_only },
		{ name = 'comp', func = yes_only },
		{ name = 'trimmed', func = yes_only },
		{ name = 'capes disp', func = { name = capes_disp, params = { 'mqc', 'comp', 'trimmed' }, flag = 'd' } },

		{ name = 'milestone', func = yes_only },
		{ name = 'active', func = yesno },

		{ name = 'graceperiod', func = 'has_content' },
		{ name = 'gracestart', func = { name = gracestart_arg, params = { 'gracestart', 'release' }, flag = 'p' } },
		{ name = 'graceactive', func = { name = graceactive_arg, params = { 'graceperiod' }, flag = 'd' } },
		{ name = 'graceperiod disp', func = { name = graceperiod_disp, params = { 'graceperiod', 'gracestart' }, flag = 'd' } },

		{ name = 'difficulty', func = { name = difficulty_arg, params = { 'difficulty', 'subcategory' }, flag = 'd' } },

		{ name = 'rewards', func = 'has_content' },
		{ name = 'requirements', func = { name = requirements_arg, params = { 'requirements' }, flag = 'd' } },
		{ name = 'ironman requirements', func = { name = requirements_arg, params = { 'ironman requirements', 'ironman_requirements' }, flag = 'd' } },
		{ name = 'cgim requirements', func = { name = requirements_arg, params = { 'competitive group ironman requirements', 'competitive_group_ironman_requirements' }, flag = 'd' } },
		{ name = 'requirements disp', func = { name = requirements_disp, params = { 'requirements', 'ironman requirements', 'cgim requirements' }, flag = 'd' } },
		{ name = 'requirements bucket', func = { name = requirements_bucket, params = { 'requirements', 'ironman requirements', 'cgim requirements' }, flag = 'd' } },
		{ name = 'requirements bucket skill', func = { name = requirements_bucket_value, params = { 'requirements bucket', 'skill' }, flag = { 'd', 'l' } } },
		{ name = 'requirements bucket quest', func = { name = requirements_bucket_value, params = { 'requirements bucket', 'quest' }, flag = { 'd', 'l' } } },
		{ name = 'requirements bucket achievement', func = { name = requirements_bucket_value, params = { 'requirements bucket', 'achievement' }, flag = { 'd', 'l' } } },
		{ name = 'requirements bucket regular', func = { name = requirements_bucket_value, params = { 'requirements bucket', 'regular' }, flag = { 'd', 'l' } } },
		{ name = 'requirements bucket ironman', func = { name = requirements_bucket_value, params = { 'requirements bucket', 'ironman' }, flag = { 'd', 'l' } } },
		{ name = 'requirements bucket cgim', func = { name = requirements_bucket_value, params = { 'requirements bucket', 'cgim' }, flag = { 'd', 'l' } } },

		{ name = 'hidden type', func = { name = hidden_type_arg, params = { 'hidden type' }, flag = 'd' } },
		{ name = 'hidden type disp', func = { name = hidden_type_disp, params = { 'hidden type' }, flag = 'd' } },

		{ name = 'grants benefits', func = yes_only },
		{ name = 'grants title', func = yes_only },
		{ name = 'grants item', func = yes_only },
		{ name = 'grants emote', func = yes_only },
		{ name = 'grants cosmetic override', func = yes_only },
		{ name = 'grants xp lamp', func = yes_only },

		{ name = 'image', func = { name = img_arg, params = { 'image', 'combat mastery' }, flag = 'd' } },
		{ name = 'image disp', func = { name = img_disp, params = { 'image' }, flag = 'd' } },
		{ name = 'id', func = { name = iddisp, params = { 'id' }, flag = 'p' } },
		{ name = 'achievementlink', func = { name = achievementlink, params = { 'id' } } },
		{ name = 'bucketarg', func = { name = bucketarg, params = {
			'name', 'description', 'members', 'leagueRegion_raw',
			'maincategory', 'subcategory', 'subsubcategory',
			'difficulty', 'storymode', 'ironmanrestricted',
			'mqc', 'comp', 'trimmed',
			'milestone', 'score', 'combat mastery bucket', 'combat score', 'hidden type', 'active',
			'id', 'graceperiod', 'gracestart',
		}, flag = 'd' } },
	}

	ret:useBucket('achievement', {
		name = 'name',
		image = 'icon',
		members = 'is_members_only',
		maincategory = 'maincategory',
		subcategory = 'subcategory',
		subsubcategory = 'subsubcategory',
		difficulty = 'difficulty',
		score = 'runescore',
		bucketarg = 'json',
		id = 'id',
		leagueRegion_raw = 'league_region',
	})

	ret:useBucket('achievement_requirement', {
		['requirements bucket skill'] = 'skill',
		['requirements bucket quest'] = 'quest',
		['requirements bucket achievement'] = 'achievement',
		['requirements bucket regular'] = 'regular',
		['requirements bucket ironman'] = 'ironman',
		['requirements bucket cgim'] = 'cgim',
	})

	ret:useBucket('achievement_id', {
		id = 'id',
	})

	ret:setMaxButtons(4)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)

	ret:defineLinks()

	ret:defineName('Infobox Achievement')
	ret:addClass('infobox-achievement')

	ret:addButtonsCaption()

	-- PARAMETER: name
	ret:addRow {
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = full_width },
	}

	ret:pad(full_width)

	-- PARAMETER: image
	ret:addRow {
		{ tag = 'argd', content = 'image disp', class = 'infobox-image infobox-full-width-content', colspan = full_width },
	}

	ret:pad(full_width)

	-- PARAMETER: release
	-- (update included automatically by infobox)
	ret:addRow {
		{ tag = 'th', content = 'Release', colspan = left_width },
		{ tag = 'argd', content = 'release', colspan = right_width },
	}

	-- PARAMETER: removal
	if hasParamDefined(ret, 'removal') then
		ret:addRow {
			{ tag = 'th', content = 'Removal', colspan = left_width },
			{ tag = 'argd', content = 'removal', colspan = right_width },
		}
	end

	-- PARAMETER: members
	ret:addRow {
		{ tag = 'th', content = '[[Members]]', colspan = left_width },
		{ tag = 'argd', content = 'members', colspan = right_width },
	}

	-- PARAMETER: description
	ret:addRow {
		{ tag = 'th', content = 'Description', colspan = left_width },
		{ tag = 'argd', content = 'description', colspan = right_width },
	}

	-- PARAMETER: score
	ret:addRow {
		{ tag = 'th', content = '[[RuneScore]]', colspan = left_width },
		{ tag = 'argd', content = 'score disp', colspan = right_width },
	}

	if hasParamDefined(ret, 'maincategory') then
		ret:addRow {
			{ tag = 'th', content = 'Category', colspan = left_width },
			{ tag = 'argd', content = 'maincategory disp', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'subcategory') then
		ret:addRow {
			{ tag = 'th', content = 'Subcategory', colspan = left_width },
			{ tag = 'argd', content = 'subcategory disp', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'subsubcategory') then
		ret:addRow {
			{ tag = 'th', content = 'Subsubcategory', colspan = left_width },
			{ tag = 'argd', content = 'subsubcategory disp', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'combat mastery') then
		ret:addRow {
			{ tag = 'th', content = '[[Combat Mastery achievements|Combat Mastery]]<br>tier', colspan = left_width },
			{ tag = 'argd', content = 'combat mastery disp', colspan = right_width },
		}
		ret:addRow {
			{ tag = 'th', content = '[[Combat Mastery achievements#CombatScore|CombatScore]]', colspan = left_width },
			{ tag = 'argd', content = 'combat score disp', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'storymode') then
		ret:addRow {
			{ tag = 'th', content = 'Story mode', colspan = left_width },
			{ tag = 'argd', content = 'storymode disp', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'ironmanrestricted') then
		ret:addRow {
			{ tag = 'th', content = '[[File:Ironman badge.png|link=]] Restricted', colspan = left_width },
			{ tag = 'argd', content = 'ironmanrestricted disp', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'capes disp') then
		ret:addRow {
			{ tag = 'th', content = 'Required for', colspan = left_width },
			{ tag = 'argd', content = 'capes disp', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'milestone') then
		ret:addRow {
			{ tag = 'th', content = 'Milestone', colspan = left_width },
			{ tag = 'td', content = '[[Milestone achievements|Yes]]', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'graceperiod') then
		ret:addRow {
			{ tag = 'th', content = '[[List of achievements with a grace period|Grace period]]', colspan = left_width },
			{ tag = 'argd', content = 'graceperiod disp', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'difficulty') then
		ret:addRow {
			{ tag = 'th', content = 'Difficulty', colspan = left_width },
			{ tag = 'argd', content = 'difficulty', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'hidden type') then
		local hidden_type_title = hover_txt('Visibility<br>condition',
			'Details for this achievement are hidden in-game until this condition is met')
		ret:addRow {
			{ tag = 'th', content = hidden_type_title, colspan = left_width },
			{ tag = 'argd', content = 'hidden type disp', colspan = right_width },
		}
	end
	
	-- PARAMETER: leagueRegion
	if hasParamDefined(ret, 'leagueRegion') then
		local leagues = require('Module:LeagueRegion')
		ret:addRow {
			{ tag = 'th', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] region', colspan = left_width,
				css = { ['vertical-align'] = 'middle' }
			},
			{ tag = 'argd', content = 'leagueRegion', colspan = right_width,
				css = { ['vertical-align'] = 'middle' }
			},
			meta = { addClass = 'leagues-global-flag' }
		}
	end
	
	local requirements = ret:param('requirements disp')
	if not isDefined(requirements) then
		ret:addRow {
			{ tag = 'th', content = 'Requirements', colspan = left_width },
			{ tag = 'td', content = 'None', colspan = right_width },
		}
	end

	if hasParamDefined(ret, 'rewards') then
		ret:addRow {
			{ tag = 'th', content = 'Rewards', colspan = left_width },
			{ tag = 'argd', content = 'rewards', colspan = right_width },
		}
	end

	ret:pad(full_width)

	if isDefined(requirements) then
		ret:addRow { { tag = 'th', content = 'Requirements', colspan = full_width, class = 'description-header infobox-subheader' } }
		ret:addRow {
			{ tag = 'td', content = requirements.content, colspan = full_width, class = requirements.class },
		}
	end

	-- Advanced data
	ret:addRow {
		{ tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = full_width },
		meta = { addClass = 'advanced-data' },
	}
	ret:pad(full_width, 'advanced-data')
	local has_id = ret:paramGrep('id', function(x) return string.lower(x or 'none') ~= 'none' end)
	if has_id then
		ret:addRow {
			{ tag = 'th', content = 'Achievement ID', colspan = left_width },
			{ tag = 'argd', content = 'id', colspan = right_width },
			meta = { addClass = 'advanced-data' },
		}

		ret:addRow {
			{ tag = 'th', content = 'Links', colspan = left_width },
			{ tag = 'argd', content = 'achievementlink', colspan = right_width },
			meta = { addClass = 'advanced-data' },
		}
	end
	ret:pad(full_width, 'advanced-data')

	ret:finish()
	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function to_number(arg, default)
	if not isDefined(arg) then
		return nil
	end

	return lang:parseFormattedNumber(arg) or default
end

function yes_only(arg, default)
	if not isDefined(arg) then
		return nil
	end

	if yesno(arg, default) then
		return true
	else
		return nil
	end
end

function img_arg(arg, combat_mastery)
	if isDefined(arg) then
		arg = arg:gsub('%[', ''):gsub('%]', ''):gsub('[Ff]ile:', ''):gsub('{{!}}', '|')
		arg = mw.text.split(arg, '|')
		return arg[1]
	end

	if isDefined(combat_mastery) then
		return string.format('Combat Mastery - %s achievement icon.png', combat_mastery.name)
	end

	return 'Default achievement icon.png'
end

function img_disp(arg)
	return cleanimg { file = arg, width = 50, height = 50 }
end

function members_arg(arg)
	if not isDefined(arg) then
		return nil
	end

	if yesno(arg) then
		return 'Yes'
	else
		return 'No'
	end
end

function leaguesArg(region)
	if not isDefined(region) then
		return nil
	end

	local leagues = require('Module:LeagueRegion')
	return leagues.regionsForInfobox(region)
end

function score_disp(arg)
	if not isDefined(arg) then
		return nil
	end

	return '[[File:RuneScore.png|link=RuneScore]] ' .. arg
end

function category_arg(arg)
	if not isDefined(arg) then
		return nil
	end

	if yesno(arg) == false then
		return nil
	end

	return arg
end

function category_disp(arg)
	if not isDefined(arg) then
		return nil
	end

	return string.format('[[%s achievements|%s]]', arg, arg)
end

function combat_mastery_arg(arg)
	if not isDefined(arg) then
		return nil
	end

	return combatmasteries[arg:lower()]
end

function combat_mastery_disp(arg)
	if not isDefined(arg) then
		return nil
	end

	return string.format('[[Combat Mastery - %s|%s]]', arg.name, arg.name)
end

function combat_mastery_bucket(arg)
	if not isDefined(arg) then
		return nil
	end

	return arg.name
end

function combat_score_arg(arg)
	if not isDefined(arg) then
		return nil
	end

	return arg.score
end

function combat_score_disp(arg)
	if not isDefined(arg) then
		return nil
	end

	return '[[File:Combat Mastery icon.png|link=Combat Mastery achievements#CombatScore|21x21px]] ' .. arg
end

function storymode_disp(storymode)
	if not isDefined(storymode) then
		return nil
	end

	if storymode then
		return 'Can be done in both story mode and normal mode'
	else
		return 'Can only be done in normal mode'
	end
end

function ironmanrestricted_disp(ironmanrestricted)
	if not isDefined(ironmanrestricted) then
		return nil
	end

	if ironmanrestricted then
		return 'Ironmen cannot obtain this achievement.'
	else
		-- Placeholder - should not be displayed
		return 'Ironmen can obtain this achievement.'
	end
end

function capes_disp(mqc, comp, trimmed)
	local ret = {}
	if mqc == true then
		table.insert(ret, '[[Master Quest Cape (achievement)|Master Quest Cape]]')
	end
	if comp == true then
		table.insert(ret, '[[Completionist Cape (achievement)|Completionist Cape]]')
	end
	if trimmed == true then
		table.insert(ret, '[[Trimmed Completionist Cape (achievement)|Trimmed Completionist Cape]]')
	end

	local len = #ret
	if len == 0 then
		return nil
	elseif len == 1 then
		return ret[1]
	else
		return '* ' .. table.concat(ret, '\n* ')
	end
end

function gracestart_arg(gracestart, release)
	if isDefined(gracestart) then
		return gracestart
	end

	if isDefined(release) then
		return release
	end

	return nil
end

function graceactive_arg(graceperiod)
	if not isDefined(graceperiod) then
		return nil
	end

	graceperiod = graceperiod:gsub('%[', ''):gsub('%]', '')
	local unixtime = lang:formatDate('U', graceperiod)

	return os.difftime(unixtime, os.time()) > 0
end

function graceperiod_disp(graceperiod, gracestart)
	if not isDefined(graceperiod) or not isDefined(gracestart) then
		return nil
	end

	return string.format('%s -<br>%s', gracestart, graceperiod)
end

function difficulty_arg(arg, subcategory)
	if not isDefined(arg) then
		return nil
	end

	if subcategory:lower() == 'new varrock' then
		return arg
	end

	return nil
end

function requirements_arg(arg, arg2)
	if not isDefined(arg) then
		if not isDefined(arg2) then
			return nil
		else
			arg = arg2
		end
	end

	arg = string.gsub(mw.text.trim(arg), ' +', ' ')
	local req = arg:lower()
	if req == 'no' or req == 'none' or req == '* none' then
		return nil
	end

	local units = areq._get_units_from_string(arg)
	if units == nil then
		return nil
	else
		return units
	end
end

function ironman_concerns_disp(concerns, title)
	local ret = mw.html.create('table')
		:addClass('mw-collapsible mw-collapsed')
		:css('background', 'none')
		:css('min-width', 'auto')

	ret:tag('tr'):tag('td')
		:addClass('inventory-image')
		:wikitext(title)

	ret:tag('tr'):tag('td')
		:css('padding-top', '0')
		:node(concerns)

	return ret
end

function requirements_disp(req, ironman_req, cgim_req)
	local req_type = type(req)
	local ironman_req_type = type(ironman_req)
	local cgim_req_type = type(cgim_req)
	if req_type ~= 'table' and ironman_req_type ~= 'table' and cgim_req_type ~= 'table' then
		-- 'None' or something else
		return req
	end

	local ret
	local shouldQcActive = false
	if req_type ~= 'table' then
		ret = mw.html.create()
		ret:tag('ul'):tag('li'):wikitext('None')
	else
		ret = areq.display_top_level_requirement(req)
		shouldQcActive = areq.should_qc_active(req)
	end

	if ironman_req_type == 'table' then
		local ironman_ret = areq.display_top_level_requirement(ironman_req)
		ret:node(ironman_concerns_disp(ironman_ret,
			"[[File:Ironman badge.png|link=]] [[File:Hardcore Ironman badge.png|link=]] '''Ironmen:'''"))

		shouldQcActive = shouldQcActive or areq.should_qc_active(req)
	end

	if cgim_req_type == 'table' then
		local ironman_ret = areq.display_top_level_requirement(cgim_req)
		ret:node(ironman_concerns_disp(ironman_ret,
			"[[File:Competitive Group Ironman badge.png|link=]] '''Competitive Group Ironmen:'''"))

		shouldQcActive = shouldQcActive or areq.should_qc_active(req)
	end

	return { content = tostring(ret), class = shouldQcActive and 'qc-active' or '' }
end

function gather_requirement_name(ret, arg)
	if arg.type == 'skill' then
		table.insert(ret.skill, arg.name)
	elseif arg.type == 'quest' then
		table.insert(ret.quest, arg.name)
	elseif arg.type == 'achievement' then
		table.insert(ret.achievement, arg.name)
		-- elseif unit.type == 'intangible' then
		--     -- no action
		-- elseif unit.type == 'error' then
		--     -- no action
	end
end

function gather_requirement_names_in_op(ret, arg)
	if arg.type == 'and' or arg.type == 'or' then
		for _, unit in ipairs(arg.units) do
			gather_requirement_name(ret, unit)
		end
	else
		gather_requirement_name(ret, arg)
	end
end

function requirements_bucket(req, ironman_req, cgim_req)
	local req_type = type(req)
	local ironman_req_type = type(ironman_req)
	local cgim_req_type = type(cgim_req)
	if req_type ~= 'table' and ironman_req_type ~= 'table' and cgim_req_type ~= 'table' then
		return {}
	end

	local ret = {
		skill = {},
		quest = {},
		achievement = {},
		regular = mw.text.jsonEncode(req),
		ironman = mw.text.jsonEncode(ironman_req),
		cgim = mw.text.jsonEncode(cgim_req),
	}

	local function requirement_name_unique(arg)
		return arg
	end

	if req_type == 'table' and req.type ~= 'intangible' then
		gather_requirement_names_in_op(ret, req)
		ret.skill = unique(ret.skill, requirement_name_unique)
		ret.quest = unique(ret.quest, requirement_name_unique)
		ret.achievement = unique(ret.achievement, requirement_name_unique)
	end

	return ret
end

function requirements_bucket_value(arg, key)
	return arg[key]
end

function hidden_type_arg(arg)
	if not isDefined(arg) then
		return nil
	end

	local type = to_number(arg)
	if hidden_types[type] then
		return type
	else
		return tostring(arg) -- erroneous parameter
	end
end

function hidden_type_disp(arg)
	if not isDefined(arg) then
		return nil
	end

	return hidden_types[arg] or 'This achievement must be unlocked first.' -- placeholder for the erroneous parameter
end

function bucketarg(
	name, description, members, leaguesregion,
	maincategory, subcategory, subsubcategory,
	difficulty, storymode, ironmanrestricted,
	mqc, comp, trimmed,
	milestone, score, combat_mastery, combat_score, hidden_type, active,
	id, graceperiod, gracestart)
	local toJSON = {
		['name'] = name,
		['name plain'] = nosic(name),
		['description'] = description,
		['members'] = members,
		['leaguesregion'] = leaguesregion and string.lower(tostring(leaguesregion)) or nil,
		['maincategory'] = maincategory,
		['subcategory'] = subcategory,
		['subsubcategory'] = subsubcategory,
		['difficulty'] = difficulty,
		['storymode'] = storymode,
		['ironmanrestricted'] = ironmanrestricted,
		['mqc'] = mqc,
		['comp'] = comp,
		['trimmed'] = trimmed,
		['milestone'] = milestone,
		['score'] = score,
		['combat mastery'] = combat_mastery,
		['combat score'] = combat_score,
		['hidden type'] = hidden_type,
		['active'] = active,
		['id'] = id,
		['graceperiod'] = graceperiod,
		['gracestart'] = gracestart,
	}

	for k, v in pairs(toJSON) do
		if v == '' or not isDefined(v) then
			toJSON[k] = nil
		end
	end

	return mw.text.jsonEncode(toJSON)
end

function hasParamDefined(info, name)
	return isDefined(info:param(name))
end

function iddisp(id)
	if isDefined(id) then
		if id:lower() ~= 'no' and id:lower() ~= 'none' then
			local r = string.gsub(id, ', *', ', ')
			return r
		elseif id:lower() == 'no' or id:lower() == 'none' then
			return 'None'
		end
	end
	return nil
end

function achievementlink(id)
	if tonumber(id) ~= nil then
		return string.format(
			'[https://chisel.weirdgloop.org/structs_rs3/index.html?type=achievements&id=%s Achievements%s]', id, id)
	end
	return nil
end

function add_formatted_category(tbl, arg, format)
	table.insert(tbl, string.format(format, arg))
end

function add_formatted_category_from_args(tbl, args, format)
	for _, v in ipairs(args_to_list(args)) do
		if v ~= nil then
			add_formatted_category(tbl, args.d, format)
		end
	end
end

function add_category_if(tbl, args, cat, predicate)
	for _, x in ipairs(args_to_list(args)) do
		if string.lower(tostring(x)) == predicate then
			table.insert(tbl, cat)
		end
	end
end

function args_to_list(args)
	local list = {}
	if args then
		if isDefined(args.d) then
			table.insert(list, args.d)
		end
		if args.switches then
			for _, x in ipairs(args.switches) do
				if isDefined(x) then
					table.insert(list, x)
				end
			end
		end
	end
	return list
end

-- Categories
function addcategories(args, catargs)
	local ret = {}
	table.insert(ret, 'Achievements')

	local cat_map = {
		-- Added if the parameter has content
		defined = {
			rewards = 'Achievements with rewards',
			['combat mastery'] = 'Combat Mastery achievements',
			['ironman requirements'] = 'Achievements with ironman requirements',
			['ironman_requirements'] = 'Pages with deprecated parameters', -- moved to ironman requirements
			leagueRegion = 'Pages with League region',
		},
		-- Added if the parameter has no content
		notdefined = {
			release = 'Needs release date',
			id = 'Achievements without ID',
			score = 'Achievements without score',
			requirements = 'Achievements with unknown requirements',
		},
		['true'] = {
			storymode = 'Achievements that can be done in story mode',
			mqc = 'Master Quest Cape achievements',
			comp = 'Completionist Cape achievements',
			trimmed = 'Trimmed Completionist Cape achievements',
			graceactive = 'Grace period achievements',
			milestone = 'Milestone achievements',
			['grants benefits'] = 'Achievements that grant benefits',
			['grants title'] = 'Achievements that grant titles',
			['grants item'] = 'Achievements that grant items',
			['grants emote'] = 'Achievements that grant emotes',
			['grants cosmetic override'] = 'Achievements that grant cosmetic overrides',
			['grants xp lamp'] = 'Achievements that grant XP lamps',
			['ironmanrestricted'] = 'Achievements that cannot be completed by ironmen',
		},
		['false'] = {
			storymode = 'Achievements that cannot be done in story mode',
			graceactive = 'Former grace period achievements',
			['active'] = 'Inactive achievements',
		},
		-- exact match (lower case)
		match = {
			['members'] = { ['yes'] = 'Members\' achievements', ['no'] = 'Free-to-play achievements' },
			['hidden type'] = { ['1'] = 'Hidden type 1 achievements', ['2'] = 'Hidden type 2 achievements' },
			['score'] = { ['0'] = 'Achievements with a RuneScore of 0' },
		},
	}

	for _, x in ipairs(args_to_list(args.milestone)) do
		if x == false then
			cat_map.notdefined.maincategory = 'Uncategorised achievements'
		end
	end

	add_formatted_category_from_args(ret, args.maincategory, '%s achievements')
	add_formatted_category_from_args(ret, args.subcategory, '%s achievements')
	add_formatted_category_from_args(ret, args.subsubcategory, '%s achievements')
	add_formatted_category_from_args(ret, args.difficulty, '%s achievements')
	add_formatted_category_from_args(ret, args['combat mastery bucket'], '%s Combat Mastery achievements')

	if catargs['hidden type'].one_defined then
		for _, x in ipairs(args_to_list(args['hidden type'])) do
			if type(x) ~= 'number' then
				table.insert(ret, 'Erroneous parameter')
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
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret, v)
		end
	end

	-- true/false
	for n, v in pairs(cat_map['true']) do
		add_category_if(ret, args[n], v, 'true')
	end
	for n, v in pairs(cat_map['false']) do
		add_category_if(ret, args[n], v, 'false')
	end

	-- searches
	for n, v in pairs(cat_map.match) do
		for m, w in pairs(v) do
			add_category_if(ret, args[n], w, m)
		end
	end

	-- Add category if description matches "solve this mystery." AND leagueRegion is not defined
	    if catargs.leagueRegion and catargs.leagueRegion.all_defined == false then
        	for _, x in ipairs(args_to_list(args['description'])) do
            if string.lower(tostring(x)) == 'solve this mystery.' then
                table.insert(ret, 'Needs League region/Mystery')
          	  end
        	end
    	end
	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end

	return table.concat(ret, '')
end

return p
-- </nowiki>