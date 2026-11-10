-- <nowiki>
--
-- Module for {{Infobox POP Voyage}}
--
-- Test changes at [[Module:Infobox POP Voyage/sandbox]]
--

local p = {}

local commas = require('Module:Addcommas')._add
local yesno = require('Module:Yesno')
local infobox = require('Module:Infobox')
local onmain = require('Module:Mainonly').on_main
local leaguesArg

local voyage_types = {
    ['no voyage'] = 'No voyage selected',
    ['resources'] = 'Port resource',
    ['island'] = 'Crew & island unlock',
    ['experience'] = 'Experience',
    ['scroll'] = 'Forgotten scroll',
    ['story'] = 'Story',
    ['trait'] = 'Captain trait',
    ['trade goods'] = 'Trade good',
    ['barmaid'] = 'A Barmaid\'s Tip',
    ['clue'] = 'Clue',
    ['effect'] = 'Effect',
    ['item'] = 'Item',
    ['repair'] = 'Ship repair',
}

local adventurers = {
	'The Exile',
	'The Assassin',
	'The Occultist',
	'The Whaler',
	'The Tengu',
	'The Biologist', 
	'The Convict',
	'The Missionary',
	'The Trapper',
	'The Chef',
	'The Architect',
	'The Memory',
}

function p.main(frame)
	-- Create Infobox ret
	local args = frame:getParent().args
	local ret = infobox.new(args)

	-- Parameters for the Infobox Skin Template
	ret:defineParams{
		{ name = 'name', func = 'name' },
		{ name = 'vanchor', func = { name = 'has_content', params = { 'version' }, flag = 'p' } },
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'type', func = { name = lookuparg, params = { voyage_types, 'type' }, flag = { 'r', 'd' } } },
		{ name = 'region', func = { name = regionarg, params = { 'distance_req', 'region' }, flag = 'p' } },
		{ name = 'regiondisp', func = { name = regiondisparg, params = { 'region' }, flag = 'd' } },
		{ name = 'morale', func = formatnum, params = { 'morale' }, flag = 'p' },
		{ name = 'combat', func = formatnum, params = { 'combat' }, flag = 'p' },
		{ name = 'seafaring', func = formatnum, params = { 'seafaring' }, flag = 'p' },
		{ name = 'speed', func = 'has_content' },
		{ name = 'distance_req', func = formatnum, params = { 'distance_req' }, flag = 'p' },
		{ name = 'distance_gain', func = formatnum, params = { 'distance_gain' }, flag = 'p' },
		{ name = 'duration', func = { name = calc_duration,  params = { 'speed', 'distance_gain' }, flag = 'p' } },
		{ name = 'adventurers', func = 'has_content' },
		{ name = 'description', func = 'has_content' },
		{ name = 'success_text', func = 'has_content' },        
		{ name = 'leagueRegion', func = leaguesArg },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
		-- not used; only for categories
		{ name = 'id', func = { name = iddisp,  params = { 'id' }, flag = 'p' } },
		{ name = 'id_bucket', func = { name = idbucket, params = { 'id' }, flag = 'p' } },
		{ name = 'chisel_links', func = { name = make_chisel_links, params = { 'id_bucket' }, flag = 'd' } },
	}
	
	ret:create()
	ret:cleanParams()
	
	-- Set links for Module/Talk pages
	ret:defineLinks()

	ret:useBucket('struct_id', {
		id_bucket = 'id'
	})

	-- Define Infobox name
	ret:defineName('Infobox POP Voyage')
	ret:addClass('infobox-pop-voyage')
	
	if onmain() then
		local a2 = ret:categoryData()
	end
	
	ret:addButtonsCaption()
	
	-- ~~~~~~~~~~ PARAMETERS ~~~~~~~~~~
	-- PARAMETER: name
	ret:addRow{
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '20' } }
	:pad(20)
	
	-- PARAMETER: release
	:addRow{ 
		{ tag = 'th', content = 'Release date', colspan = '8' },
		{ tag = 'argd', content = 'release', colspan = '12' }
	}
	
	if ret:paramDefined('removal') then
		ret:addRow{
			{ tag = 'th', content = 'Removal', colspan = '8' },
			{ tag = 'argd', content = 'removal', colspan = '12' }
		}
	end
	
	ret:addRow{ 
		{ tag = 'th', content = 'Type', colspan = '8' },
		{ tag = 'argd', content = 'type', colspan = '12' }
	}

	:addRow{ 
		{ tag = 'th', content = 'Region', colspan = '8' },
		{ tag = 'argd', content = 'regiondisp', colspan = '12' }
	}
	
	:addRow{ 
		{ tag = 'th', content = 'Distance required', colspan = '8' },
		{ tag = 'argd', content = 'distance_req', colspan = '12' }
	}
	
	:addRow{ 
		{ tag = 'th', content = 'Distance gained', colspan = '8' },
		{ tag = 'argd', content = 'distance_gain', colspan = '12' }
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
	if ret:paramDefined('adventurers') then
		ret:addRow{
			{ tag = 'th', content = 'Adventurers', colspan = '8' },
			{ tag = 'argd', content = 'adventurers', colspan = '12' }
		}
	end
	
	ret:pad(20)
	:addRow{
		{ tag = 'th', content = 'Adversity', class = 'infobox-subheader', colspan = '20' }
	}
	:pad(20)
	
	:addRow{ 
		{ tag = 'th', content = 'Morale', colspan = '8' },
		{ tag = 'argd', content = 'morale', colspan = '12' }
	}
	
	:addRow{ 
		{ tag = 'th', content = 'Combat', colspan = '8' },
		{ tag = 'argd', content = 'combat', colspan = '12' }
	}
	
	:addRow{ 
		{ tag = 'th', content = 'Seafaring', colspan = '8' },
		{ tag = 'argd', content = 'seafaring', colspan = '12' }
	}
	
	:addRow{ 
		{ tag = 'th', content = 'Base duration', colspan = '8' },
		{ tag = 'argd', content = 'duration', colspan = '12' }
	}
	
	-- PARAMETER: description
	ret:pad(20)
	:addRow{
		{ tag = 'th', content = 'Description', class = 'infobox-subheader', colspan = '20' }
	}
	
	ret:addRow{
		{ tag = 'argd', content = 'description', colspan = '20',
		css = { ['max-width'] = '300px', ['text-align'] = 'center' } }
	}
	if ret:paramDefined('success_text') then
		ret:pad(20)
		:addRow{
			{ tag = 'th', content = 'Success text', class = 'infobox-subheader', colspan = '20' }
		}
		:addRow{
			{ tag = 'argd', content = 'success_text', colspan = '20',
			css = { ['max-width'] = '300px', ['text-align'] = 'center' } }
		}
	end

	ret:pad(20, 'advanced-data')
	:addRow{
		{ tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '20' },
		meta = {addClass = 'advanced-data'}
	}
	:pad(20, 'advanced-data')

	:addRow{
		{ tag = 'th', content = 'Struct ID', colspan = '8' },
		{ tag = 'argd', content = 'id', colspan = '12' },
		meta = {addClass = 'advanced-data'}
	}

	:addRow{
		{ tag = 'th', content = 'Links', colspan = '8' },
		{ tag = 'argd', content = 'chisel_links', colspan = '12' },
		meta = {addClass = 'advanced-data'}
	}
	:pad(20)
	
	ret:addVersionBasedVars('LeagueRegion', 'version', 'leagueRegion_raw')

	-- Finalise template
	ret:finish()
	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1,a2))
	end
	return ret:tostring()
end

--lazy-load Module
function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end
	
function regionarg(distance_req, region)
	if infobox.isDefined(region) then
		return region
	end
	region = ''
	distance_req = tonumber(distance_req)
	if infobox.isDefined(distance_req) then
		if distance_req >= 4100000 then
			region = 'The Shield'
		elseif distance_req >= 2300000 then
			region = 'The Loop'
		elseif distance_req >= 1200000 then
			region = 'The Pincers'
		elseif distance_req >= 450000 then
			region = 'The Bowl'
		elseif distance_req >= 140000 then
			region = 'The Scythe'
		elseif distance_req >= 40000 then
			region = 'The Hook'
		elseif distance_req >= 5000 then
			region = 'The Skull'
		else
			region = 'The Arc'
		end
		return region
	end
end

function regiondisparg(region)
	if infobox.isDefined(region) then
		if string.lower(region) ~= 'n/a' then
			return '[[' .. region .. ']]'
		else
			return 'N/A'
		end
	end
end

function formatnum(arg)
	if infobox.isDefined(arg) then
		return commas(arg)
	end
end

function lookuparg(t, c)
	return t[string.lower(c or '')]
end

function scale(value, from, to)
	return math.floor(value * to / from)
end

function calc_time_units(distance)
	local hours = 0
	local minutes = 0
	local seconds = 0
	seconds = math.floor(distance * 6 / 10)
	minutes = math.floor(seconds / 60)
	seconds = math.floor(seconds % 60)
	if (minutes > 59) then
		hours = math.floor(minutes / 60)
		minutes = math.floor(minutes % 60)
	end
	return hours, minutes, seconds
end

function calc_duration(speed_voyage, distance)
	if not infobox.isDefined(speed_voyage) or not infobox.isDefined(distance) then
		return nil
	end
	local hours = 0
	local minutes = 0
	local seconds = 0
	speed_voyage = math.max(1, speed_voyage)
	local speed_max = scale(125, 100, speed_voyage)
	local speed_min = scale(75, 100, speed_voyage)
	local speed_ship = 0
	local speed_effective = math.max(math.min(speed_max, speed_ship), speed_min)
	distance = scale(speed_voyage, speed_effective, distance)
	distance = math.max(1500, distance)
	hours, minutes, seconds = calc_time_units(distance)
	local minutes_str = tostring(minutes)
	if (minutes < 10) then
		minutes_str = "0" .. minutes_str
	end
	local duration_str = hours .. ':' .. minutes_str
	return duration_str
end

function iddisp(id)
	if infobox.isDefined(id) then
		if id:lower() ~= 'no' then
			local r = string.gsub(id, ', *', ', ')
			return r
		elseif id:lower() == 'no' then
			return 'None'
		end
	end
	return nil
end

function idbucket(id)
	if infobox.isDefined(id) then
		local r = string.gsub(id, ', *', infobox.splitpoint)
		return r
	end
	return nil
end

function make_chisel_links(id)
	local link = 'https://chisel.weirdgloop.org/structs_rs3/index.html?type=structs'
	if infobox.isDefined(id) then
		link = string.format('%s&id=%s', link, id)
	end
	return string.format('[%s Structs]', link)
end

function ucfirst(str)
    return (str:gsub("^%l", string.upper))
end

-- Categories
function addcategories(args, catargs)
	local ret = { 'Player-owned port voyages' }
	
	local cat_map = {
		-- Added if the parameter has content
		defined = {
			leagueRegion = 'Pages with League region'
		},

		-- Added if the parameter has no content
		notdefined = {
			release = 'Needs release date',
			update = 'Needs update added',
			leagueRegion = 'Needs League region/POP'
		}
	}

	if infobox.isDefined(args.type.d) then
		if string.lower(args.type.d) ~= 'no voyage selected' then
			table.insert(ret, args.type.d .. ' player-owned port voyages')
		end
	elseif args.type.switches then
		for _, v in ipairs(args.type.switches) do
			if infobox.isDefined(v) and string.lower(v) ~= 'no voyage selected' then
				table.insert(ret, v .. ' player-owned port voyages')
			end
		end
	end

    -- Add adventurer-specific categories if voyage type is 'clue'
    if ucfirst(string.lower(args.type.d)) == 'Clue' and infobox.isDefined(args.adventurers.d) then
    	local adventurers_string = string.lower(args.adventurers.d)
        for _, adventurer in ipairs(adventurers) do
            if string.find(adventurers_string, string.lower(adventurer), 1, true) then
                table.insert(ret, adventurer .. ' clue player-owned port voyages')
            end
        end
    end

	if infobox.isDefined(args.region.d) then
		if string.lower(args.region.d) ~= 'n/a' then
			table.insert(ret, 'Player-owned port voyages in ' .. args.region.d:gsub("^%u", string.lower))
		end
	end

	-- ids
	if not catargs.id.all_defined then
		table.insert(ret, 'Needs ID')
	end

	-- Add defined categories
	for n, v in pairs(cat_map.defined) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret,v)
		end
	end
	
	-- Add undefined categories
	for n, v in pairs(cat_map.notdefined) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret,v)
		end
	end
	
	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]',v)
		end
	end

	return table.concat(ret,'')
end	

return p
-- </nowiki>