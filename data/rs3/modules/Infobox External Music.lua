-- <nowiki>
--------------------------
-- Module for [[Template:Infobox Music]]
-- Please test changes to this module at [[Module:Infobox Music/sandbox]] first
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local infobox = require('Module:Infobox')
local numberarg, numberbucketarg, namearg, namebucketarg, filearg, membersarg, durationarg, soundcloudarg, scexclusivearg
local if_not_number_na
local downloadsarg, maparg, bucketarg, addcategories

function if_not_number_na(number)
	if not tonumber(number) then return true else return false end
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

-- =p._main{name='Citadel XVI'}
function p._main(args)
	local ret = infobox.new(args)

	ret:defineParams{
		{ name = 'number', func = { name = numberarg, params = { 'number' }, flag = { 'p' } } },
		{ name = 'name', func = { name = namearg, params = { 'name', 'number' }, flag = { 'p', 'd' } } },
		{ name = 'file', func = { name = filearg, params = { 'file' }, flag = { 'p' } } },
		{ name = 'file_listen', func = { name = listenarg, params = { 'file' }, flag = { 'd' } } },
		{ name = 'file_link', func = { name = linkarg, params = { 'file' }, flag = { 'd' } } },
		{ name = 'release', func = 'has_content' },
		{ name = 'platform', func = 'has_content' },
		{ name = 'album', func = 'has_content' },
		{ name = 'vocals', func = 'has_content' },
		{ name = 'instruments', func = 'has_content' },
		{ name = 'key', func = 'has_content' },
		{ name = 'time_signature', func = 'has_content' },
		{ name = 'duration', func = { name = durationarg, params = { 'duration' }, flag = { 'p' } } },
		{ name = 'composer', func = 'has_content' },
		{ name = 'soundcloud', func = { name = soundcloudarg, params = { 'soundcloud' }, flag = { 'p' } } },
		{ name = 'downloads', func = { name = downloadsarg, params = { 'downloads' }, flag = { 'p' } } },
	}


	ret:create()
	ret:cleanParams()

	ret:defineLinks()

	ret:defineName('Infobox Music')
	ret:addClass('infobox-music')

	-- Since the name is a combination of the track name and number,
	-- need to duplicate Module:Infobox's name-comparison logic here
	-- in order to set the 'no-parenthesis-style' if appropriate
	if args.name then
		if mw.text.decode(args.name) == mw.title.getCurrentTitle().fullText then
			ret:addClass('no-parenthesis-style')
		end
	end

	-- PARAMETER: name
	ret:addRow{
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '20' }
	}
	:pad(20)

	-- PARAMETER: file
	if ret:paramDefined('file') then
		ret:addRow{
			{ tag = 'argd', content = 'file_listen', class = 'infobox-full-width-content infobox-media-player', colspan = '20' }
		}
		ret:addRow{
			{
				tag = 'argd', content = 'file_link', colspan = '20',
				class = 'infobox-full-width-content', css = { ['font-size'] = '90%' }
			}
		}
	else 
		ret:addRow{ { tag = 'td', content = '[[Special:Upload|Please add an audio sample!]]',
			css = { ['text-align'] = 'center', ['font-weight'] = 'bold' }, colspan = '20' } }
	end

	-- PARAMETER: release
	ret:pad(20)
	ret:addRow{
		{ tag = 'th', content = 'Release', colspan = '8' },
		{ tag = 'argd', content = 'release', colspan = '12' }
	}

	ret:pad(20)
	ret:addRow{
		{ tag = 'th', content = 'Details', class = 'infobox-subheader', colspan = '20' }
	}
	ret:pad(20)

	-- PARAMETER: duration
	ret:addRow{
		{ tag = 'th', content = 'Duration', colspan = '8' },
		{ tag = 'argd', content = 'duration', colspan = '12' }
	}

	-- PARAMETER: platform
	if ret:paramDefined('platform') then
		ret:addRow{
			{ tag = 'th', content = 'Platforms', colspan = '8' },
			{ tag = 'argd', content = 'platform', colspan = '12' }
		}
	end

	-- PARAMETER: album
	if ret:paramDefined('album') then
		ret:addRow{
			{ tag = 'th', content = 'Album', colspan = '8' },
			{ tag = 'argd', content = 'album', colspan = '12' }
		}
	end

	-- PARAMETER: vocals
	if ret:paramDefined('vocals') then
		ret:addRow{
			{ tag = 'th', content = 'Vocals', colspan = '8' },
			{ tag = 'argd', content = 'vocals', colspan = '12' }
		}
	end

	-- PARAMETER: instruments
	ret:addRow{
		{ tag = 'th', content = 'Instruments', colspan = '8' },
		{ tag = 'argd', content = 'instruments', colspan = '12' }
	}

	if ret:paramDefined('key') then
	-- PARAMETER: key
	ret:addRow{
		{ tag = 'th', content = 'Key', colspan = '8' },
		{ tag = 'argd', content = 'key', colspan = '12' }
	}
	end
	
	if ret:paramDefined('time_signature') then
	-- PARAMETER: time signature
	ret:addRow{
		{ tag = 'th', content = 'Time signature', colspan = '8' },
		{ tag = 'argd', content = 'time_signature', colspan = '12' }
	}
	end

	-- PARAMETER: composer
	ret:addRow{
		{ tag = 'th', content = 'Composer', colspan = '8' },
		{ tag = 'argd', content = 'composer', colspan = '12' }
	}

	-- PARAMETER: soundcloud
	if ret:paramDefined('soundcloud') then
		ret:addRow{
			{ tag = 'th', content = 'SoundCloud', colspan = '8' },
			{ tag = 'argd', content = 'soundcloud', colspan = '12' }
		}
	end

	-- PARAMETER: downloads
	if ret:paramDefined('downloads') then
		ret:addRow{
			{ tag = 'th', content = 'Downloads', colspan = '8' },
			{ tag = 'argd', content = 'downloads', colspan = '12' }
		}
	end
	ret:pad(20)

	if not ret:paramGrep('scexclusive', 'yes') and not ret:paramGrep('downloads', 'yes') then
		-- PARAMETER: map
		local map_defined = ret:paramGrep('map', function(x) return (x or 'N/A') ~= 'N/A' end)
		if map_defined then
			ret:addRow{
				{ tag = 'th', content = 'Map', class = 'infobox-subheader', colspan = '20' }
			}
			:addRow{
				{ tag = 'argd', content = 'map', colspan = '20', class = 'infobox-full-width-content infobox-image' }
			}
		end
	end

	if ret:paramDefined('id') then
		-- Advanced data
		ret:addRow{
			{ tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '20' },
			meta = { addClass = 'advanced-data' }
		}
		-- PARAMETER: id
		:pad(20, 'advanced-data')
		:addRow{
			{ tag = 'th', content = 'Music Track ID', colspan = '8' },
			{ tag = 'argd', content = 'id', colspan = '12' },
			meta = { addClass = 'advanced-data' }
		}
		-- PARAMETER: sort_string
		:addRow{
			{ tag = 'th', content = 'Sort string', colspan = '8' },
			{ tag = 'argd', content = 'sort_string', colspan = '12' },
			meta = { addClass = 'advanced-data' }
		}
		:pad(20, 'advanced-data')
	end

	ret:finish()
	if onmain() then
		-- Add a category sort key for music tracks that need it
		-- NB: This variable is never referenced!!!!!!
		local name = args.name or string.match( ret:param('name', 'd'), '(.-)<span' )
		local sortkey = args.sort_string
		local defaultsort = sortkey and mw.getCurrentFrame()
			:callParserFunction{ name = 'DEFAULTSORT', args = { sortkey } } or ''
		local a2 = ret:categoryData()
		ret:wikitext( defaultsort )
		ret:wikitext( addcategories( ret, a2 ) )
	end

	return ret:tostring()

end

function namearg(name, number)
	if not infobox.isDefined(name) then
		name = mw.title.getCurrentTitle().text
	end
	return name .. number
end

function namebucketarg(arg)
	if not infobox.isDefined(arg) then
		arg = mw.title.getCurrentTitle().text
	end
	return arg
end

function numberarg(arg)
	if infobox.isDefined(arg) then
		if tonumber(arg) then
			return '<span style="font-size: 80%;"> (#' .. arg .. ')</span>'
		end
		if string.lower(arg) == 'n/a' or string.lower(arg) == 'no' then
			return ''
		end
	else
		return ''
	end
end

function numberbucketarg(arg)
	if infobox.isDefined(arg) and tonumber(arg) then
		return arg
	end
end

function filearg(arg)
	if infobox.isDefined(arg) then
		-- allow [[File:Example.ogg]] syntax to be used in the template
		return arg:gsub("^%[%[File:", ""):gsub("%]%]$", "")
	end
end

function listenarg(arg)
	if infobox.isDefined(arg) then
		if arg:match("(%.ogg)$") or arg:match("(%.mp3)$") then
			local frame = mw.getCurrentFrame()
			return frame:expandTemplate{ title = 'Listen inline', args = { filename = arg } }
		end
	end
end

function linkarg(arg)
	if infobox.isDefined(arg) then
		return string.format("([[:File:%s|file source]])", arg)
	end
end


function durationarg(arg)
	if string.match(arg, "^(%d?%d:%d%d)$") then
		return arg
	end
end

function soundcloudarg(arg)
	local scarg = string.gsub(arg, 'https?://www%.', 'https://')
	if string.match(scarg, "^https://soundcloud%.com/runescapesoundtrack/[%l%d%-]*$") then
		return string.format('[%s Link]', arg)
	end
end



local composers = {
	['mod ian'] = 'Mod Ian',
	['mod grace'] = 'Mod Grace',
	['mod bond'] = 'Mod Bond',
	['mod lord'] = 'Mod Lord',
	['andrew l'] = 'Andrew L',
	['mod adam r'] = 'Mod Adam R',
	['michael m'] = 'Michael M',
	['iain h'] = 'Iain H',
	['mod jolley'] = 'Mod Jolley',
	['mod dan a'] = 'Mod Dan A',
	['james h'] = 'James H',
	['sam j'] = 'Sam J',
	['mod ash'] = 'Mod Ash',
	['mod abbie'] = 'Mod Abbie',
	['abbie d'] = 'Mod Abbie',
	['mod slippers'] = 'Mod Slippers',
	['helen r'] = 'Helen R',
	['linda h'] = 'Linda H',
	['mod surma'] = 'Mod Surma',
	['mod jodgers'] = 'Mod Jodgers',
	['mod rainbow'] = 'Mod Rainbow',
	['mod nixon'] = 'Mod Nixon',
	['mod debris'] = 'Mod Debris',
	['artur baryshev'] = 'Artur Baryshev',
}

function addcategories( ibox, catargs )
	local args = ibox.args
	local ret = { 'Music tracks' }

	local cat_map = {
		-- Added if the parameter has content
		defined = {
			-- param = 'category',
		},
		-- Added if the parameter has no content
		notdefined = {
			file = 'Needs audio added',
			instruments = 'Needs instruments',
			key = 'Needs key signature',
			time_signature = 'Needs time signature',
			duration = 'Needs track duration added',
			composer = 'Needs composer added',
		},
	}

	if args.soundcloud then
		table.insert( ret, 'SoundCloud-exclusive music' )
	end
	if not args.soundcloud or not args.album then
		table.insert( ret, 'Download-only music' )
	end
	if args.album then
		table.insert( ret, 'Album only music' )
	end

	if args.composer then

	local complist = string.lower(args.composer)
	local compcount = 0
	for name, cat in pairs(composers) do
		if complist:find(string.lower(cat)) then
			table.insert( ret, 'Music composed by ' .. cat )
			compcount = compcount + 1
		end
	end

		if compcount == 0 then
			table.insert( ret, 'Invalid composer' )
		end
		if compcount > 1 then
			table.insert( ret, 'Tracks with multiple composers' )
		end
	end

	-- Run and add mapped categories
	for n, v in pairs( cat_map.defined ) do
		if catargs[n] and catargs[n].one_defined then
			table.insert( ret, v )
		end
	end
	for n, v in pairs( cat_map.notdefined ) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert( ret, v )
		end
	end

	-- combine table and format category wikicode
	for i, v in ipairs( ret ) do
		if ( v ~= '' ) then
			ret[i] = string.format( '[[Category:%s]]', v )
		end
	end

	return table.concat( ret, '' )
end

return p