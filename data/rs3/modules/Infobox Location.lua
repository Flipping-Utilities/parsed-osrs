--------------------------
-- Module for {{Infobox Location}}
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local paramtest = require('Module:Paramtest')
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean
local leagues

local imgarg, maparg, mapdisp, addcategories, leaguesDisp

local function getLeagues()
	if leagues == nil then
		leagues = require('Module:LeagueRegion')
	end

	return leagues
end

-- Main function called with invokes
function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'image', func = { name = imgarg, params = { 'image' }, flag = { 'd' } } },
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'aka', func = 'has_content' },
		{ name = 'members', func = 'has_content' },
		{ name = 'location', func = 'has_content' },
		{ name = 'leagueRegion', func = 'has_content' },
		{ name = 'leagueRegion_disp', func = { name = leaguesDisp, params = { 'leagueRegion' }, flag = { 'd' } } },
		{ name = 'teleport', func = 'has_content' },
		{ name = 'music', func = 'has_content' },
		{ name = 'banks', func = 'has_content' },
		{ name = 'bankdeposits', func = 'has_content' },
		{ name = 'altars', func = 'has_content' },
		{ name = 'obelisks', func = 'has_content' },
		{ name = 'hotspots', func = 'has_content' },
		{ name = 'shops', func = 'has_content' },
		{ name = 'featuressection', func = 'has_content' },
		{ name = 'map', func = { name = maparg, params = { 'map' }, flag = { 'd' } } },
		{ name = 'mapdisp', func = { name = mapdisp, params = { 'map' }, flag = { 'd' } }, dupes = true },
	}

	ret:defineLinks()

	ret:create()
	ret:cleanParams()

	ret:useBucket('infobox_location', {
		name = 'name',
		image = 'image',
		members = 'is_members_only',
		location = 'location',
		leagueRegion = 'league_region',
		teleport = 'teleport',
		music = 'music',
		banks = 'banks',
		altars = 'altars',
		obelisks = 'obelisks',
		hotspots = 'hotspots',
		shops = 'shops',
		featuressection = 'featuressection',
	})

	ret:customButtonPlacement(true)
	ret:addButtonsCaption()

	ret:defineName('Infobox Location')

	-- PARAMETER: name
	ret:addRow {
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '20' },
	}

	-- PARAMETER: image
	ret:addRow {
		{ tag = 'argd', content = 'image', class = 'infobox-image infobox-full-width-content', colspan = '20' },
	}
		:pad(5)

	-- PARAMETER: release
	ret:addRow {
		{ tag = 'th', content = 'Release', colspan = '6' },
		{ tag = 'argd', content = 'release', colspan = '14' },
	}

	-- PARAMETER: removal
	if ret:paramDefined('removal') then
		ret:addRow {
			{ tag = 'th', content = 'Removal', colspan = '6' },
			{ tag = 'argd', content = 'removal', colspan = '14' },
		}
	end

	-- PARAMETER: aka
	if ret:paramDefined('aka') then
		ret:addRow {
			{ tag = 'th', content = 'Also called', colspan = '6' },
			{ tag = 'argd', content = 'aka', colspan = '14' },
		}
	end

	-- PARAMETER: members
	ret:addRow {
		{ tag = 'th', content = '[[Members]]', colspan = '6' },
		{ tag = 'argd', content = 'members', colspan = '14' },
	}

	-- PARAMETER: location
	if ret:paramDefined('location') then
		ret:addRow {
			{ tag = 'th', content = 'Location', colspan = '6' },
			{ tag = 'argd', content = 'location', colspan = '14' },
		}
	end

	-- PARAMETER: leagueRegion
	if ret:paramDefined('leagueRegion', 'all') then
		ret:addRow {
			{ tag = 'th', content = '[[' .. getLeagues().DEFAULT_LEAGUE .. '|League]] region', css = { ['vertical-align'] = 'middle' }, colspan = '6' },
			{ tag = 'argd', content = 'leagueRegion_disp', css = { ['text-align'] = 'left', ['vertical-align'] = 'middle' }, colspan = '14' },
			meta = { addClass = 'leagues-global-flag' },
		}
	end

	-- PARAMETER: teleport
	if ret:paramDefined('teleport') then
		ret:addRow {
			{ tag = 'th', content = 'Teleports', colspan = '6' },
			{ tag = 'argd', content = 'teleport', colspan = '14' },
		}
	end

	-- PARAMETER: music
	if ret:paramDefined('music') then
		ret:addRow {
			{ tag = 'th', content = 'Music', colspan = '6' },
			{ tag = 'argd', content = 'music', colspan = '14' },
		}
	end

	-- PARAMETER: features
	if ret:paramDefined('banks') or ret:paramDefined('bankdeposits') or ret:paramDefined('altars') or ret:paramDefined('obelisks') or ret:paramDefined('hotspots') or ret:paramDefined('shops') then
		ret:addRow { { tag = 'th', content = 'Features', colspan = '20', class = 'infobox-subheader' } }

		local features = {}
		if ret:paramDefined('banks') then
			table.insert(features, '[[File:Bank map icon.png|15px|link=Bank]] ' .. ret:param('banks'))
		end
		if ret:paramDefined('bankdeposits') then
			table.insert(features, '[[File:Bank Deposit map icon.png|15px|link=Bank deposit box]] ' .. ret:param('bankdeposits'))
		end
		if ret:paramDefined('altars') then
			table.insert(features, '[[File:Altar map icon.png|15px|link=Altar]] ' .. ret:param('altars'))
		end
		if ret:paramDefined('obelisks') then
			table.insert(features, '[[File:Small Summoning obelisk map icon.png|15px|link=Obelisk]] ' .. ret:param('obelisks'))
		end
		if ret:paramDefined('hotspots') then
			table.insert(features, '[[File:Excavation site map icon.png|15px|link=Excavation hotspot]] ' .. ret:param('hotspots'))
		end
		if ret:paramDefined('shops') then
			table.insert(features, '[[File:General store map icon.png|15px|link=Shop]] ' .. ret:param('shops'))
		end

		ret:addRow {
			{ tag = 'td', content = table.concat(features, ', '), colspan = '20', css = { ['text-align'] = 'center' } },
		}

		if yesno(ret:param('featuressection')) == true then
			ret:addRow {
				{ tag = 'td', content = '[[#Features|See features section below]]', colspan = '20', css = { ['text-align'] = 'center' } },
			}
		end
	end
	ret:pad(5)

	-- PARAMETER: map
	local map_defined = ret:paramGrep('mapdisp', function(x) return (x or 'false') ~= 'false' end)
	if map_defined == true then
		ret:addRow {
			{ tag = 'th', content = 'Map', class = 'infobox-subheader', colspan = '20' },
		}
			:addRow {
				{ tag = 'argd', content = 'map', class = 'infobox-image infobox-full-width-content', colspan = '20' } }
	end

	ret:finish()

	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function imgarg(arg)
	if infobox.isDefined(arg) then
		return cleanimg { file = arg, width = 300, height = 300 }
	end
	return nil
end

function leaguesDisp(region)
	if region ~= nil and region ~= '' then
		return getLeagues().regionsForInfobox(region)
	end
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
	else
		return nil
	end
end

function mapdisp(map)
	if infobox.isDefined(map) then
		local yn_map = map == "''No map to display.''"
		if yn_map then
			return 'false'
		else
			return 'true'
		end
	else
		return 'false'
	end
end

function addcategories(args, catargs)
	local ret = { 'Locations' }

	local cat_map = {
		-- Added if the parameter has content
		defined = {
			leagueRegion = 'Pages with League region',
		},
		-- Add the associated category if the parameter doesn't have content
		notdefined = {
			image = 'Needs image',
			members = 'Needs members status',
			release = 'Needs release date',
			map = 'Needs map',
			leagueRegion = 'Needs League region',
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

	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end

	return table.concat(ret, '')
end

return p