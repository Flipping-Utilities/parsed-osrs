--------------------------
-- Module for {{Infobox NPC}}
------------------------
local p = {}

local commas = require('Module:Addcommas')._add
local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean

local npcrace = mw.loadData('Module:NPC races')
local imgarg, imgback, questarg, txtarg, numargcommas, genderarg, pronounsarg, optionarg, optionbucket, maparg, mapdisp, mapmarkerarg, racearg, sizearg, sizedisp, iddisp, idbucket, addcategories, leaguesArg
local badarg, image_bucket, racedisp, is_default_version

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)
	local default_version_index = tonumber(args.defver) or 1

	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'aka', func = 'has_content' },
		{ name = 'image', func = imgarg },
		{ name = 'image_bucket', func = { name = image_bucket, params = { 'image' }, flag = 'p' } },
		{ name = 'imagebackground', func = { name = imgback, params = { 'imagebackground' }, flag = { 'd' } }, dupes = true },
		{ name = 'vanchor', func = { name = 'has_content', params = { 'version' }, flag = 'p' } },
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'members', func = 'has_content' },
		{ name = 'quest', func = { name = questarg, params = { 'quest' }, flag = { 'd' } } },
		{ name = 'location', func = { name = txtarg, params = { 'location' }, flag = 'd' } },
		{ name = 'leagueRegion', func = leaguesArg },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
		{ name = 'level', func = { name = numargcommas, params = { 'level', 'level' } } },
		{ name = 'size', func = { name = sizearg, params = { 'size' }, flag = 'p' } },
		{ name = 'size_disp', func = { name = sizedisp, params = { 'size' }, flag = 'p' } },
		{ name = 'options', func = { name = optionarg, params = { 'options', 'actions' }, flag = 'd' } },
		{ name = 'options_bucket', func = { name = optionbucket, params = { 'options', 'actions' }, flag = 'p' }, dupes = true },
		{ name = 'examine', func = { name = txtarg, params = { 'examine' }, flag = { 'd' } } },
		{ name = 'map', func = { name = maparg, params = { 'map' }, flag = { 'd' } } },
		{ name = 'mapdisp', func = { name = mapdisp, params = { 'map' }, flag = { 'd' } }, dupes = true },
		{ name = 'map_marker', func = { name = mapmarkerarg, params = { 'marker' }, flag = { 'd' } } },
		{ name = 'race_parsed', func = { name = racearg, params = { 'race' } } },
		{ name = 'race', func = { name = racedisp, params = { 'race_parsed', 'race' } } },
		{ name = 'id', func = { name = iddisp, params = { 'id' }, flag = 'p' } },
		{ name = 'objectid', func = { name = iddisp, params = { 'objectid' }, flag = 'p' } },
		{ name = 'histid', func = { name = iddisp, params = { 'histid' }, flag = 'p' } },
		{ name = 'histobjectid', func = { name = iddisp, params = { 'histobjectid' }, flag = 'p' } },
		{ name = 'id_bucket', func = { name = idbucket, params = { 'id' }, flag = 'p' }, dupes = true },
		{ name = 'objectid_bucket', func = { name = idbucket, params = { 'objectid' }, flag = 'p' }, dupes = true },
		{ name = 'histid_bucket', func = { name = idbucket, params = { 'histid' }, flag = 'p' }, dupes = true },
		{ name = 'spotanimid', func = 'has_content' },
		{ name = 'chisel_links', func = { name = 'make_chisel_links', params = { 'name', '<br>', 'mrnd', 'id', 'mrod', 'objectid' }, flag = { 'p', 'r', 'r', 'p', 'r', 'p' } } },
		{ name = 'hist_chisel_links', func = { name = 'make_chisel_links', params = { 'name', '<br>', 'mrnd', 'histid', 'mrod', 'histobjectid' }, flag = { 'p', 'r', 'r', 'p', 'r', 'p' } } },
		{ name = 'default_version', func = { name = is_default_version, params = { 'bucketname' .. default_version_index, 'version' .. default_version_index, 'bucketname', 'version' } } },
		{ name = 'shop', func = 'has_content' },
		{ name = 'gender', func = { name = genderarg, params = { 'gender' }, flag = { 'd' } } },
		{ name = 'pronouns', func = 'has_content' },
		{ name = 'f2pvisible', func = 'has_content' },
		{ name = 'voice', func = 'has_content' },
		{ name = 'shopversion', func = 'has_content' },
	}

	ret:useBucket('infobox_npc', {
		image_bucket = 'image',
		id_bucket = 'npc_id',
		objectid_bucket = 'object_id',
		members = 'is_members_only',
		location = 'location',
		options_bucket = 'options',
		examine = 'examine',
		default_version = 'default_version',
		leagueRegion_raw = 'league_region'
	})
	ret:useBucket('npc_id', {
		id_bucket = 'id'
	})
	ret:useBucket('object_id', {
		objectid_bucket = 'id'
	})

	ret:setMaxButtons(4)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)

	ret:linkParams {
		image = 'imagebackground'
	}

	ret:defineLinks()

	ret:defineName('Infobox NPC')
	ret:addClass('infobox-npc')

	ret:addButtonsCaption()

	-- PARAMETER: name
	ret:addRow {
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '20' }
	}
		:pad(20)

	-- PARAMETER: image
		:addRow {
			{ tag = 'argd', content = 'image', class = 'infobox-full-width-content', colspan = '20' },
			meta = { addClass = ret:param('imagebackground', 'r') }
		}
		:pad(20)

	-- PARAMETER: release
	-- (update included automatically by infobox)
		:addRow {
			{ tag = 'th', content = 'Release', colspan = '8', css = { ['white-space'] = 'nowrap' } },
			{ tag = 'argd', content = 'release', colspan = '12' }
		}

	-- PARAMETER: removal
	if ret:paramDefined('removal', 'all') then
		ret:addRow {
			{ tag = 'th', content = 'Removal', colspan = '8' },
			{ tag = 'argd', content = 'removal', colspan = '12' }
		}
	end

	-- PARAMETER: aka
	if ret:paramDefined('aka') then
		ret:addRow {
			{ tag = 'th', content = 'Also called', colspan = '8' },
			{ tag = 'argd', content = 'aka', colspan = '12' }
		}
	end

	-- PARAMETER: members
	ret:addRow {
		{ tag = 'th', content = '[[Members]]', colspan = '8' },
		{ tag = 'argd', content = 'members', colspan = '12' }
	}

	-- PARAMETER: level
	if ret:paramDefined('level', 'all') then
		ret:addRow {
			{ tag = 'th', content = '[[Combat level]]', colspan = '8', css = { ['white-space'] = 'nowrap' } },
			{ tag = 'argd', content = 'level', colspan = '12' }
		}
	end

	-- PARAMETER: race
	ret:addRow {
		{ tag = 'th', content = '[[List of races|Race]]', colspan = '8' },
		{ tag = 'argd', content = 'race', colspan = '12' }
	}

	-- PARAMETER: size
	if ret:paramDefined('size', 'all') then
		ret:addRow {
			{ tag = 'th', content = '[[Game square|Size]]', colspan = '8' },
			{ tag = 'argd', content = 'size_disp', colspan = '12' }
		}
	end

	-- PARAMETER: quest
	ret:addRow {
		{ tag = 'th', content = '[[Quests|Quest]]', colspan = '8' },
		{ tag = 'argd', content = 'quest', colspan = '12' }
	}

	-- PARAMETER: location
	ret:addRow {
		{ tag = 'th', content = '[[Locations|Location]]', colspan = '8' },
		{ tag = 'argd', content = 'location', colspan = '12' }
	}
	
	-- PARAMETER: leagueRegion
	if ret:paramDefined('leagueRegion', 'all') then
		local leagues = require('Module:LeagueRegion')
		ret:addRow{
			{ tag = 'th', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] region', css = { ['vertical-align'] = 'middle' }, colspan = '8' },
			{ tag = 'argd', content = 'leagueRegion', css = {['text-align'] = 'left', ['vertical-align'] = 'middle' }, colspan = '12' },
			meta = {addClass = 'leagues-global-flag'}
		}
	end

	-- PARAMETER: shop
	if ret:paramDefined('shop', 'all') then
		ret:addRow {
			{ tag = 'th', content = '[[Shop]]', colspan = '8' },
			{ tag = 'argd', content = 'shop', colspan = '12' }
		}
	end

	-- PARAMETER: gender
	if ret:paramDefined('gender', 'all') then
		ret:addRow {
			{ tag = 'th', content = '[[Gender]]', colspan = '8' },
			{ tag = 'argd', content = 'gender', colspan = '12' }
		}
	end

	-- PARAMETER: pronouns
	if ret:paramDefined('pronouns', 'all') or ret:param('gender') == 'Non-binary' then
		ret:addRow {
			{ tag = 'th', content = 'Pronouns', colspan = '8' },
			{ tag = 'argd', content = 'pronouns', colspan = '12' }
		}
	end

	-- PARAMETER: options (formerly actions)
	ret:addRow {
		{ tag = 'th', content = '[[Choose Option|Options]]', colspan = '8' },
		{ tag = 'argd', content = 'options', colspan = '12' }
	}

	-- PARAMETER: examine
	ret:addRow {
		{ tag = 'th', content = '[[Examine]]', colspan = '8' },
		{ tag = 'argd', content = 'examine', colspan = '12' }
	}

	-- PARAMETER: marker
	if ret:paramDefined('map_marker', 'all') then
		ret:addRow {
			{ tag = 'th', content = '[[Minimap#Marker|Minimap marker]]', colspan = '8' },
			{ tag = 'argd', content = 'map_marker', colspan = '12' }
		}
	end

	ret:pad(20)

	-- PARAMETER: map
	local map_defined = ret:paramGrep('mapdisp', function(x) return (x or 'false') ~= 'false' end)
	if map_defined == true then
		ret:addRow {
			{ tag = 'th', content = 'Map', class = 'infobox-subheader', colspan = '20' }
		}
			:addRow {
				{ tag = 'argd', content = 'map', class = 'infobox-full-width-content infobox-image', colspan = '20' } }
	end

	-- PARAMETER: Advanced data
	ret:addRow {
		{ tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '20' },
		meta = { addClass = 'advanced-data' }
	}
		:pad(20, 'advanced-data')
	if ret:paramDefined('id', 'all') or not ret:paramDefined('histid', 'all') then
		ret:addRow {
			{ tag = 'th', content = 'NPC ID', colspan = '8' },
			{ tag = 'argd', content = 'id', colspan = '12' },
			meta = { addClass = 'advanced-data' }
		}
		if ret:paramDefined('objectid', 'all') then
			ret:addRow {
				{ tag = 'th', content = 'Object ID', colspan = '8' },
				{ tag = 'argd', content = 'objectid', colspan = '12' },
				meta = { addClass = 'advanced-data' }
			}
		end
		ret:addRow {
			{ tag = 'th', content = 'Links', colspan = '8' },
			{ tag = 'argd', content = 'chisel_links', colspan = '12' },
			meta = { addClass = 'advanced-data' }
		}
	end
	if ret:paramDefined('histid', 'all') or ret:paramDefined('histobjectid', 'all') then
		if ret:paramDefined('histid', 'all') then
			ret:addRow {
				{ tag = 'th', content = 'Historical ID', colspan = '8' },
				{ tag = 'argd', content = 'histid', colspan = '12' },
				meta = { addClass = 'advanced-data' }
			}
		end
		if ret:paramDefined('histobjectid', 'all') then
			ret:addRow {
				{ tag = 'th', content = 'Historical Object ID', colspan = '8' },
				{ tag = 'argd', content = 'histobjectid', colspan = '12' },
				meta = { addClass = 'advanced-data' }
			}
		end
		ret:addRow {
			{ tag = 'th', content = 'Historical Links', colspan = '8' },
			{ tag = 'argd', content = 'hist_chisel_links', colspan = '12' },
			meta = { addClass = 'advanced-data' }
		}
	end
	if ret:paramDefined('spotanimid', 'all') then
		ret:addRow {
			{ tag = 'th', content = 'Spot Anim ID', colspan = '8' },
			{ tag = 'argd', content = 'spotanimid', colspan = '12' },
			meta = { addClass = 'advanced-data' }
		}
	end

	ret:pad(20, 'advanced-data')

	-- Save vars for use by later templates
	if ret:paramDefined('shopversion', 'all') then
		ret:addVersionBasedVars('ShopInfo_LeagueRegion', 'shopversion', 'leagueRegion_raw')
		ret:addVersionBasedVars('LeagueRegion', 'dropversion', 'leagueRegion_raw')
		
		ret:addVersionBasedVars('ShopInfo_location', 'shopversion', 'location')
		ret:addVersionBasedVars('ShopInfo_members', 'shopversion', 'members')
	else
		ret:addVersionBasedVars('ShopInfo_LeagueRegion', 'shopversion', 'leagueRegion_raw')
		ret:addVersionBasedVars('LeagueRegion', 'dropversion', 'leagueRegion_raw')
		
		ret:addVersionBasedVars('ShopInfo_location', 'vanchor', 'location')
		ret:addVersionBasedVars('ShopInfo_members', 'vanchor', 'members')
	end

	ret:finish()
	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	else
		ret.suppressAllBucket = true
	end
	return ret:tostring()
end

function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end

function imgarg(arg)
	if infobox.isDefined(arg) then
		return cleanimg { file = arg, width = 300, height = 300 }
	end
	return nil
end

function imgback(arg)
	if infobox.isDefined(arg) then
		if yesno(arg) then
			return 'infobox-imgbg'
		end
	end
	return ''
end

function txtarg(txt)
	if infobox.isDefined(txt) then
		txt = mw.text.trim(txt)
		if string.sub(txt, 1, 1) == '*' then
			local ret = mw.html.create('ul')
			for x in mw.text.gsplit(txt, '\n%*%s*') do
				local _x = string.gsub(x, '^%*%s*', '')
				ret:tag('li'):wikitext(_x)
			end
			return tostring(ret)
			-- txt = '\n'..txt..'\n'
		end
		return txt
	end
	return nil
end

function maparg(arg)
	if infobox.isDefined(arg) then
		local low = string.lower(arg)
		if yesno(low) == false or low == 'none' then
			return "''No map to display.''"
		elseif low == 'name' then
			return string.format('[[File:%s location.png]]', mw.title.getCurrentTitle().text)
		elseif string.find(low, '.png') then
			return cleanimg { file = arg, width = 250 }
		else
			return arg
		end
	end
	return nil
end

function mapmarkerarg(arg)
	if infobox.isDefined(arg) then
		local low = string.lower(arg)
		if yesno(low) == false or low == 'none' or low == 'hide' then
			return "Hidden"
		elseif yesno(low) == true then
			return "Shown"
		else
			return arg
		end
	end
	return nil
end

function image_bucket(arg)
	local _img = string.match(arg, "File:.-%.png")
	return _img
end

local function numberargs(arg, arg_name)
	local arg_v = (arg or ''):find('%S') and string.gsub(arg, ',', '') or -1
	local arg_i
	if arg_v == -1 then
		arg_i = nil
	elseif string.lower(arg_v) == 'n/a' then
		arg_i = 'N/A'
	elseif string.lower(arg_v) == 'varies' then
		arg_i = 'Varies'
	else
		arg_i = tonumber(arg_v:gsub(',', ''), 10)
		if not arg_i then
			arg_i = badarg(arg_name, 'should be a single numerical value.')
		end
	end
	return arg_i
end

-- For numbers (adds commas)
function numargcommas(arg, arg_name)
	local ret = numberargs(arg, arg_name)
	if type(ret) == 'number' then
		return commas(ret)
	end
	return ret
end

-- red ERR span with title hover for explanation
function badarg(argname, argmessage)
	argname = argname or '(unknown)'
	argmessage = argmessage or '(empty)'
	return '<span ' ..
		'title="The parameter «' .. argname .. '» ' .. argmessage .. '" ' ..
		'style="color:red; font-weight:bold; cursor:help; border-bottom:1px dotted red;">' ..
		'ERR</span>'
end

function racearg(arg)
	if infobox.isDefined(arg) then
		local ret = {}
		for race in mw.text.gsplit(arg, ',') do
			race = mw.text.trim(string.lower(race))
			if npcrace[race] then
				table.insert(ret, race)
			end
		end
		return ret
	end
	return nil
end

function racedisp(arg, raw)
	if infobox.isDefined(arg) then
		local ret = {}
		for _, race in ipairs(arg) do
			if npcrace[race].racelink then
				if npcrace[race].racedisp then
					table.insert(ret, string.format('[[%s|%s]]', npcrace[race].racelink, npcrace[race].racedisp))
				else
					table.insert(ret, string.format('[[%s]]', npcrace[race].racelink))
				end
			end
		end

		local r = table.concat(ret, ', ')
		if r ~= '' then
			return r
		else
			return raw
		end
	end
	return nil
end

function sizearg(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	arg = tonumber(arg)
	if arg == nil then
		return nil
	end

	local arg2 = math.floor(arg)
	if arg ~= arg2 or arg <= 1 then
		return nil
	end

	return arg
end

function sizedisp(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	return string.format('%sx%s', arg, arg)
end

function mapdisp(map)
	if infobox.isDefined(map) then
		local yn_map = map == "''No map to display.''"
		if yn_map then
			return 'false'
		else
			return 'true'
		end
	end
	return 'false'
end

function iddisp(id)
	if infobox.isDefined(id) then
		if id:lower() ~= 'no' and id:lower() ~= 'none' then
			local r = string.gsub(id, ', *', ', ')
			return r
		elseif id:lower() == 'no' or id:lower() == 'none' then
			return 'None'
		end
	end
	return nil
end

function idbucket(id)
	if infobox.isDefined(id) and id:lower() ~= 'no' and id:lower() ~= 'none' then
		local r = string.gsub(id, ', *', infobox.splitpoint)
		return r
	end
	return nil
end

function is_default_version(default_bucketVer, default_textVer, bucketVer, textVer)
	if default_bucketVer ~= '' then
		local tmp = default_bucketVer == bucketVer
		return tmp
	end
	if default_textVer ~= '' then
		local tmp = default_textVer == textVer
		return tmp
	end
	return true --If we don't have any versions then we are the default version
end

function questarg(arg)
	if infobox.isDefined(arg) then
		if string.lower(arg) == 'no' then
			return 'No'
		else
			local items = mw.text.split(arg, ',')
			if #items == 1 then
				return mw.text.trim(items[1])
			else
				local ret = mw.html.create('ul'):css('margin-top', '0')
				local r = mw.ustring.gsub(arg, '%[*Missing, Presumed Death%]*', '!foo!')
				for x in mw.text.gsplit(r, ',') do
					ret:tag('li'):wikitext(mw.text.trim(x))
				end
				ret = tostring(ret)
				ret = mw.ustring.gsub(ret, '!foo!', '[[Missing, Presumed Death]]')
				return ret
			end
		end
	end
	return nil
end

function genderarg(arg)
	local arg_lower = string.lower(arg)
	if not infobox.isDefined(arg) or arg_lower == 'none' or arg_lower == 'n/a' or arg_lower == 'no' or arg_lower == 'hide' or arg_lower == 'unspecified' then
		return nil
	elseif arg_lower == 'non-binary' or arg_lower == 'nonbinary' then
		return 'Non-binary'
	else
		return arg
	end
end

function optionarg(arg, arg_old)
	if not infobox.isDefined(arg) and infobox.isDefined(arg_old) then
		arg = arg_old
	end
	if infobox.isDefined(arg) then
		local arg_lower = string.lower(arg)
		if arg_lower == 'none' or arg_lower == 'examine' then
			return 'Examine'
		elseif arg_lower == 'n/a' then
			return 'N/A'
		end
		local has_examine = false
		local ret = {}
		for x in mw.text.gsplit(arg, ',') do
			table.insert(ret, mw.text.trim(x))
			has_examine = has_examine or (string.find(x, 'Examine') ~= nil)
		end
		if not has_examine then
			table.insert(ret, 'Examine')
		end
		local ret_str = table.concat(ret, ', ')
		ret_str = mw.ustring.gsub(ret_str, '%[*[Ww]alk [Hh]ere%]*', '[[Walk here|Walk here]]')
		ret_str = mw.ustring.gsub(ret_str, '%[*[Ee]xamine%]*', 'Examine')
		return ret_str
	end
	return nil
end

function optionbucket(arg, arg_old)
	if not infobox.isDefined(arg) and infobox.isDefined(arg_old) then
		arg = arg_old
	end
	if infobox.isDefined(arg) then
		if string.lower(arg) == 'none' or string.lower(arg) == 'examine' then
			return 'Examine'
		elseif string.lower(arg) == 'n/a' then
			return 'N/A'
		end
		local r = string.gsub(arg, ',%s*', infobox.splitpoint)
		r = mw.ustring.gsub(r, '%[*[Ww]alk [Hh]ere%]*', 'Walk here')
		r = mw.ustring.gsub(r, '%[*[Ee]xamine%]*', 'Examine')
		if not r:find('Examine') then
			r = r .. infobox.splitpoint .. 'Examine'
		end
		return r
	end
	return nil
end

function addcategories(args, catargs)
	local ret = { 'Non-player characters' }

	-- ID based categories
	local misID = {}
	local cachedNpc = false
	if args.id.switches then
		for i, v in ipairs(args.id.switches) do
			if infobox.isDefined(v) and v ~= 'None' then
				cachedNpc = true
			elseif not infobox.isDefined(v) then
				misID[i] = true
			end
		end
	else
		if infobox.isDefined(args.id.d) and args.id.d ~= 'None' then
			cachedNpc = true
		elseif not infobox.isDefined(args.id.d) then
			misID[0] = true
		end
	end

	if cachedNpc then
		table.insert(ret, 'Cache NPCs')
	end

	local cachedScenery = false
	if args.objectid.switches then
		for i, v in ipairs(args.objectid.switches) do
			if infobox.isDefined(v) and v ~= 'None' then
				cachedScenery = true
				misID[i] = false
			end
		end
	elseif infobox.isDefined(args.objectid.d) and args.objectid.d ~= 'None' then
		cachedScenery = true
		misID[0] = false
	end

	if cachedScenery then
		table.insert(ret, 'Cache scenery')
	end

	if args.histid.switches then
		for i, v in ipairs(args.histid.switches) do
			if infobox.isDefined(v) and v ~= 'None' then
				misID[i] = false
			end
		end
	elseif infobox.isDefined(args.histid.d) and args.histid.d ~= 'None' then
		misID[0] = false
	end

	if args.spotanimid.switches then
		for i, v in ipairs(args.spotanimid.switches) do
			if infobox.isDefined(v) and v ~= 'None' then
				misID[i] = false
			end
		end
	elseif infobox.isDefined(args.spotanimid.d) and args.spotanimid.d ~= 'None' then
		misID[0] = false
	end

	if #misID == 0 and misID[0] == true then
		table.insert(ret, 'NPCs without ID')
	else
		for _, v in ipairs(misID) do
			if v then
				table.insert(ret, 'NPCs without ID')
				break
			end
		end
	end

	local cat_map = {
		-- Added if the parameter has content
		defined = {
			aka = 'Pages with AKA',
			shop = 'Merchants',
			pronouns = 'Non-player characters with pronouns',
			histid = 'Non-player characters with historical IDs',
			leagueRegion = 'Pages with League region',
		},
		-- Added if the parameter has no content
		notdefined = {
			image = 'Needs non-player character image',
			members = 'Needs members status',
			release = 'Needs release date',
			examine = 'Needs NPC examine added',
			options = 'Needs options added',
			race = 'Needs race',
			map = 'Needs map',
			leagueRegion = 'Needs League region/NPC',
		},
	}

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

	-- Add the associated race category
	if type(args.race_parsed.d) == 'table' and #args.race_parsed.d > 0 then
		for _, race in ipairs(args.race_parsed.d) do
			table.insert(ret, npcrace[race].racecat)
			if npcrace[race].addcat then
				for _, cat in ipairs(npcrace[race].addcat) do
					table.insert(ret, cat)
				end
			end
		end
	else
		table.insert(ret, 'Needs race')
	end

	-- Add the associated gender category if matched
	if args['gender'] then
		local gender = string.lower(args['gender'].d or '')
		if gender == 'male' then
			table.insert(ret, 'Male characters')
		elseif gender == 'female' then
			table.insert(ret, 'Female characters')
		elseif gender == 'non-binary' then
			table.insert(ret, 'Non-binary characters')
		elseif gender == 'genderless' then
			table.insert(ret, 'Genderless characters')
		end

		-- Add the associated pronouns category if matched
		if gender == 'non-binary' then
			if not infobox.isDefined(args['pronouns'].d) then
				table.insert(ret, 'Non-binary characters with missing pronouns')
			end
		end
	end

	-- Add the associated category if the parameter is valued at yes
	if args['voice'] then
		if string.lower(args['voice'].d or '') == 'yes' then
			table.insert(ret, 'Voice acted NPCs')
		end
	end

	-- Add the parameter of hidden NPCs
	if args['map_marker'] then
		for _, v in ipairs(args['map_marker'].switches or {}) do
			if v == 'Hidden' then
				table.insert(ret, 'NPCs not visible on the minimap')
			end
		end
		if args['map_marker'].d == 'Hidden' then
			table.insert(ret, 'NPCs not visible on the minimap')
		end
	end

	if args.f2pvisible.switches then
		for _, v in ipairs(args.f2pvisible.switches) do
			if infobox.isDefined(v) then
				if yesno(v) then
					table.insert(ret, 'Non-player characters that are visible but not interactive in free-to-play')
					break
				end
			end
		end
	elseif infobox.isDefined(args.f2pvisible.d) then
		if yesno(args.f2pvisible.d) then
			table.insert(ret, 'Non-player characters that are visible but not interactive in free-to-play')
		end
	end

	-- Add the associated category if the parameter is not valued at no
	if args['quest'] then
		if string.lower(args['quest'].d or '') ~= 'no' then
			table.insert(ret, 'Quest NPCs')
		end
	end

	-- Option based categories
	if args.options_bucket.switches then
		for _, v in ipairs(args.options_bucket.switches) do
			if infobox.isDefined(v) then
				if v == 'Examine' then
					table.insert(ret, 'Non-interactive characters')
				else
					table.insert(ret, 'Interactive characters')
				end
			end
		end
	elseif infobox.isDefined(args.options_bucket.d) then
		if args.options_bucket.d == 'Examine' then
			table.insert(ret, 'Non-interactive characters')
		else
			table.insert(ret, 'Interactive characters')
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