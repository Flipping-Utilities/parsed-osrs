--------------------------
-- Module for {{Infobox Area}}
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local paramtest = require('Module:Paramtest')
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean

local maparg, mapdisp, featurearg, imgarg, addcategories, leaguesArg

-- Main function called with invokes
function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	ret:defineParams{
		{ name = 'name', func = 'name' },
		{ name = 'aka', func = 'has_content' },
		{ name = 'image', func = imgarg },
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'kingdom', func = 'has_content' },
		{ name = 'sea', func = 'has_content' },
		{ name = 'members', func = 'has_content' }, 
		{ name = 'leagueRegion', func =  leaguesArg },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
		{ name = 'floors', func = 'has_content' },
		{ name = 'music', func = 'has_content' },
		{ name = 'leader', func = 'has_content' },
		{ name = 'race', func = 'has_content' },
		{ name = 'tele', func = 'has_content' },
		{ name = 'bank', func = featurearg },
		{ name = 'altar', func = featurearg },
		{ name = 'obelisk', func = featurearg },
		{ name = 'map', func = { name = maparg, params = { 'map' }, flag = { 'd' } } },
		{ name = 'mapdisp', func = { name = mapdisp, params = { 'map' }, flag = { 'd' } }, dupes = true },
	}
	
	ret:create()
	ret:cleanParams()
	
	ret:defineLinks()

	ret:defineName('Infobox Area')
	ret:addButtonsCaption()

	ret:addRow{
		{ tag = 'argh', content = 'name', class='infobox-header',  colspan = '20' }
	}
	ret:addRow{
		{ tag = 'argd', content = 'image', class='infobox-image infobox-full-width-content', colspan = '20' }
	}
	:pad(20)
	
	-- PARAMETER: aka
	if ret:paramDefined('aka') then
		ret:addRow{
			{ tag = 'th', content = 'Also called', colspan = '8' },
			{ tag = 'argd', content = 'aka', colspan = '12' }
		}
	end
	
	-- PARAMETER: release
	ret:addRow{
		{ tag = 'th', content = 'Release', colspan = '8' },
		{ tag = 'argd', content = 'release', colspan = '12' }
	}
	-- PARAMETER: removal
	if ret:paramDefined('removal') then
		ret:addRow{
			{ tag = 'th', content = 'Removal', colspan = '8' },
			{ tag = 'argd', content = 'removal', colspan = '12' }
		}
	end
	
	-- PARAMETER: leader
	if ret:paramDefined('leader') then
		ret:addRow{
			{ tag = 'th', content = 'Leader', colspan = '8' },
			{ tag = 'argd', content = 'leader', colspan = '12' }
		}
	end
	
	-- PARAMETER: kingdom
	ret:addRow{
		{ tag = 'th', content = 'Kingdom', colspan = '8' },
		{ tag = 'argd', content = 'kingdom', colspan = '12' }
	}
	
	-- PARAMETER: sea
	if ret:paramDefined('sea') then
		ret:addRow{
			{ tag = 'th', content = 'Sea', colspan = '8' },
			{ tag = 'argd', content = 'sea', colspan = '12' }
		}
	end
	
	-- PARAMETER: members
	ret:addRow{
		{ tag = 'th', content = '[[Members]]', colspan = '8' },
		{ tag = 'argd', content = 'members', colspan = '12' }
	}
	
	-- PARAMETER: leagueRegion
	if ret:paramDefined('leagueRegion', 'all') then
		local leagues = require('Module:LeagueRegion')
		ret:addRow{
			{ tag = 'th', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] region', css = { ['vertical-align'] = 'middle' }, colspan = '8' },
			{ tag = 'argd', content = 'leagueRegion', css = { ['vertical-align'] = 'middle' }, colspan = '12' },
			meta = {addClass = 'leagues-global-flag'}
		}
	end
	
	-- PARAMETER: floors
	if ret:paramDefined('floors') then
		ret:addRow{
			{ tag = 'th', content = 'Floors', colspan = '8' },
			{ tag = 'argd', content = 'floors', colspan = '12' }
		}
	end
	
	-- PARAMETER: music
	ret:addRow{
		{ tag = 'th', content = 'Music', colspan = '8' },
		{ tag = 'argd', content = 'music', colspan = '12' }
	}
	
	-- PARAMETER: race
	if ret:paramDefined('race') then
		ret:addRow{
			{ tag = 'th', content = 'Inhabitants', colspan = '8' },
			{ tag = 'argd', content = 'race', colspan = '12' }
		}
	end
	
	-- PARAMETER: tele
	ret:addRow{
		{ tag = 'th', content = 'Teleports', colspan = '8' },
		{ tag = 'argd', content = 'tele', colspan = '12' }
	}
	
	-- Features
	ret:pad(20)
	:addRow{
		{ tag = 'th', content = 'Features', class='infobox-subheader',  colspan = '20' }
	}
	:pad(20)
	
	-- PARAMETER: bank
	ret:addRow{
		{ tag = 'th', content = '[[Bank]]s [[File:Bank map icon.png|15px|link=Bank]]', colspan = '8' },
		{ tag = 'argd', content = 'bank', colspan = '12' }
	}
	
	-- PARAMETER: altar
	ret:addRow{
		{ tag = 'th', content = '[[Altar]]s [[File:Altar map icon.png|15px|link=Altar]]', colspan = '8' },
		{ tag = 'argd', content = 'altar', colspan = '12' }
	}
	
	-- PARAMETER: obelisk
	ret:addRow{
		{ tag = 'th', content = '[[Obelisk]]s [[File:Small Summoning obelisk map icon.png|15px|link=Small obelisk]]', colspan = '8' },
		{ tag = 'argd', content = 'obelisk', colspan = '12' }
	}
	:pad(20)

	-- PARAMETER: map
	local map_defined  = ret:paramGrep('mapdisp', function(x) return (x or 'false') ~= 'false' end)
	if map_defined == true then
		ret:addRow{
			{ tag = 'th', content = 'Map', class = 'infobox-subheader', colspan = '20' }
		}
		:addRow{
			{ tag = 'argd', content = 'map', class = 'infobox-image infobox-full-width-content', colspan = '20' }
		}
	end

	ret:finish()
	
	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function maparg(arg)
	if infobox.isDefined(arg) then
		local low = string.lower(arg)
		if yesno(low) == false or low == 'none' then
			return "''No map to display.''"
		elseif low == 'name' then
			return string.format('[[File:%s location.png]]', mw.title.getCurrentTitle().text)
		elseif string.find(low, '.png') then
			return cleanimg{ file = arg, width = 250 }
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

function featurearg(arg)
	if not infobox.isDefined(arg) then
		return '-'
	end

	if  infobox.isDefined(arg) then
		return arg
	end

	return 'N/A'
end

function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end

function imgarg(arg)
	if infobox.isDefined(arg) then
		return cleanimg{ file = arg, width = 300, height = 300 }
	end
	return nil
end

function addcategories(args, catargs)
	local ret = { 'Locations' }

	-- Added if the parameter has content
	local defined_args = {
		leagueRegion = "Pages with League region",
	}
	
	-- Add the associated category if the parameter doesn't have content
	local notdefined_args = {
		image = 'Needs image',
		release = 'Needs release date',
		map = 'Needs map',
		leagueRegion = 'Needs League region',
	}
	
	-- defined categories
	for n, v in pairs(defined_args) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret, v)
		end
	end
	
	-- undefined categories
	for n, v in pairs(notdefined_args) do
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