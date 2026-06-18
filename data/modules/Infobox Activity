--------------------------
-- Module for [[Template:Infobox Activity]]
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')
local tb = require('Module:Trailblazer Region')

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)
	local default_version_index = tonumber(args.defver) or 1

	ret:defineParams{
		{ name = 'name', func = 'name' },
		{ name = 'default_version', func = { name = is_default_version, params = { 'bucketname'..default_version_index, 'version'..default_version_index, 'bucketname', 'version' } } },
		{ name = 'image', func = 'image' },
		{ name = 'image_bucket', func = { name = image_bucket, params = { 'image' }, flag = 'p' } },
		{ name = 'aka', func = 'has_content' },
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'type', func = typearg },
		{ name = 'type_raw', func = {name = 'has_content', params = { 'type' }, flag = 'p' } },
		{ name = 'members', func = 'has_content' },
		{ name = 'location', func = 'has_content' },
		{ name = 'leagueRegion', func = tb.regionsForInfobox },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
		{ name = 'players', func = 'has_content' },
		{ name = 'skills', func = 'has_content' },
		{ name = 'requirements', func = 'has_content' },
		{ name = 'currency', func = 'has_content' },
		{ name = 'tutorial', func = 'has_content' },
		{ name = 'music', func = 'has_content' },
		{ name = 'map', func = maparg },
		{ name = 'dropversion', func = 'has_content' },
	}
	
	ret:useBucket('infobox_activity', {
		image_bucket = 'image',
		members = 'is_members_only',
		default_version = 'default_version'
	})

	ret:defineLinks({ hide = true })

	ret:setMaxButtons(8)
	ret:create()
	ret:cleanParams()

	ret:customButtonPlacement(true)
	ret:addButtonsCaption()

	ret:defineName('Infobox Activity')
	ret:addClass('infobox-minigame')

	ret:addRow{
		{ tag = 'argh', content = 'name', class='infobox-header', colspan = '20' }
	}

	:addRow{
		{ tag = 'argd', content = 'image', class='infobox-image infobox-full-width-content', colspan = '20' }
	}
	:pad(20)

	:addRow{
		{ tag = 'th', content = 'Released', colspan = '8' },
		{ tag = 'argd', content = 'release', colspan = '12' }
	}

	if ret:paramDefined('removal') then
		ret:addRow{
			{ tag = 'th', content = 'Removal', colspan = '8' },
			{ tag = 'argd', content = 'removal', colspan = '12' }
		}
	end

	if ret:paramDefined('aka') then
		ret:addRow{
			{ tag = 'th', content = 'Also called', colspan = '8' },
			{ tag = 'argd', content = 'aka', colspan = '12' }
		}
	end
	
	if ret:paramDefined('type') then
		ret:addRow{
			{ tag = 'th', content = 'Type', colspan = '8' },
			{ tag = 'argd', content = 'type', colspan = '12' }
		}
	end
	
	ret:addRow{
		{ tag = 'th', content = '[[Members]]', colspan = '8' },
		{ tag = 'argd', content = 'members', colspan = '12' }
	}
	:addRow{
		{ tag = 'th', content = '[[Location]]', colspan = '8' },
		{ tag = 'argd', content = 'location', colspan = '12' }
	}

	if ret:paramDefined('leagueRegion', 'all') then
		ret:addRow{
			{ tag = 'th', content = '[[Demonic Pacts League|League]] region', colspan = '8' },
			{ tag = 'argd', content = 'leagueRegion', colspan = '12' },
			meta = {addClass = 'leagues-global-flag'}
		}
	end
	
	if ret:paramDefined('players', 'all') then
		ret:addRow{
			{ tag = 'th', content = 'Participants', colspan = '8' },
			{ tag = 'argd', content = 'players', colspan = '12' }
		}
	end
	if ret:paramDefined('skills', 'all') then
		ret:addRow{
			{ tag = 'th', content = 'Skills', colspan = '8' },
			{ tag = 'argd', content = 'skills', colspan = '12' }
		}
	end
	if ret:paramDefined('requirements', 'all') then
		ret:addRow{
			{ tag = 'th', content = 'Requirements', colspan = '8' },
			{ tag = 'argd', content = 'requirements', colspan = '12' }
		}
	end
	if ret:paramDefined('currency', 'all') then
		ret:addRow{
			{ tag = 'th', content = '[[Currency|Reward currency]]', colspan = '8' },
			{ tag = 'argd', content = 'currency', colspan = '12' }
		}
	end
	if ret:paramDefined('tutorial', 'all') then
		ret:addRow{
			{ tag = 'th', content = 'Tutorial', colspan = '8' },
			{ tag = 'argd', content = 'tutorial', colspan = '12' }
		}
	end
	if ret:paramDefined('music', 'all') then
		ret:addRow{
			{ tag = 'th', content = '[[Music]]', colspan = '8' },
			{ tag = 'argd', content = 'music', colspan = '12' }
		}
	end
	ret:pad(20)

	local map_defined = ret:paramGrep('map', function(x) return (x or 'N/A') ~= 'N/A' end)
	if map_defined then
		ret:addRow{
			{ tag = 'th', content = 'Map', class = 'infobox-subheader', colspan = '20' }
		}
		:addRow{
			{ tag = 'argd', content = 'map', colspan = '20', class = 'infobox-full-width-content infobox-image' }
		}
	end
	
	ret:addVersionBasedVars('LeagueRegion', 'dropversion', 'leagueRegion_raw')

	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function typearg(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	return '[['..arg..']]'
end

function maparg(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	if string.lower(arg) == 'no' then
		return 'N/A'
	end

	return arg
end

-- split items with multiple images for bucket (e.g. [[File:Arrow 1.png]] [[File:Arrow 2.png]])
function image_bucket(arg)
	local _img = {}
	for i in string.gmatch(arg, "[Ff]ile:.-%.png") do
		table.insert(_img, i)
	end
	if #_img == 0 then
		return nil
	end
	return table.concat(_img, '&&SPLITPOINT&&')
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

function addcategories(args, catargs)
	local ret = { 'Activities' }

 	-- Add the associated category if the parameter has content
	local defined_args = {
		aka = 'Pages with AKA',
	}
	for n, v in pairs(defined_args) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret, v)
		end
	end

 	-- Add the associated category if the parameter doesn't have content
 	local notdefined_args = {
 		image = 'Needs image',
 		release = 'Needs release date',
 		members = 'Needs members status',
 		map = 'Needs map',
 		leagueRegion = 'Needs League region',
 	}
	for n, v in pairs(notdefined_args) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret, v)
		end
	end

	local cat_map = {
		-- Parameters that have text
		-- map a category to a value
		matches = {
			type_raw = {
				minigame = 'Minigames',
				['distraction and diversion'] = 'Distractions and Diversions',
				raid = 'Raids',
			},
		}
	}
	
	-- searches
	for n, v in pairs(cat_map.matches) do
		for m, w in pairs(v) do
			if args[n] then
				if string.lower(tostring(args[n].d) or '') == m then
					table.insert(ret, w)
				end
				if args[n].switches then
					for _, x in ipairs(args[n].switches) do
						if string.lower(tostring(x)) == m then
							table.insert(ret, w)
						end
					end
				end
			end
		end
	end
	
    -- release year
    local year = args.release.d:match('%d%d%d%d')
    if year then
        table.insert(ret, 'Content released in '..year)
    end
    if args.release.switches then
        for _, v in ipairs(args.release.switches) do
            year = v:match('%d%d%d%d')
            if year then
                table.insert(ret, 'Content released in '..year)
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