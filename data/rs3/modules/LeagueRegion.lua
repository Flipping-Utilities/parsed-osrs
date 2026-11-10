require('strict')
local p = {}

p.DEFAULT_LEAGUE = 'Equilibrium League'

local regions = {
	global = true,
	anachronia = true,
	asgarnia = true,
	desert = true,
	fremennik = true,
	havenhythe = true,
	kandarin = true,
	karamja = true,
	misthalin = true,
	morytania = true,
	tirannwn = true,
	wilderness = true,
	disabled = true,
	impossible = true,
	["animal wrangler"] = true,
	antiquarian = true,
	["assassin's insight"] = true,
	["crystal grace"] = true,
	["clue connoisseur"] = true,
	["devout"] = true,
	["divine druid"] = true,
	["icyenic faith"] = true,
	["endless harvest"] = true,
	["golden touch"] = true,
	["infernal fire"] = true,
	["nature's network"] = true,
	["naragi edict"] = true,
	perkfection = true,
	["production master"] = true,
	superheated = true,
	survivalist = true,
	transmutation = true,
	voidwalker = true
}

-- To enable {{#invoke:LeagueRegion|DEFAULT_LEAGUE}} in template-only infoboxes
function p.getDefaultLeague(frame) return p.DEFAULT_LEAGUE end

local function icon(region, league)
	region = region:gsub('^%l', string.upper)
	return string.format('[[File:%s League Region Badge.png|30px|%s|link=%s/Regions/%s]]', region, region, league, region)
end

local function badges(region, league, compact)
	local ret = {}
	
	for value in string.gmatch(region, '[^,]+') do
		local trimmed = mw.text.trim(value):gsub("_", " ")
		
		-- Ampersand regions wrapped in additional badge span
		if string.find(trimmed, '&') then
			local ampersandRegions, ampersandBadges = {}, {}
			
			for curRegion in string.gmatch(trimmed, '[^&]+') do
				curRegion = mw.text.trim(curRegion)
				if regions[curRegion:lower()] then
					local span = mw.html.create('span')
						:addClass('league-badge')
						:attr('data-league-region', curRegion:lower())
						:wikitext(icon(curRegion, league))
					:done()
					
					table.insert(ampersandRegions, curRegion:lower())
					table.insert(ampersandBadges, tostring(span))
				end
			end
			
			if #ampersandRegions > 0 then
				local wrapper = mw.html.create('span')
					:addClass('league-badge league-badge-wrapper')
					:attr('data-league-region', table.concat(ampersandRegions, '&'))
					:wikitext(table.concat(ampersandBadges, '&'))
				:done()
				
				table.insert(ret, tostring(wrapper))
			end
		elseif regions[trimmed:lower()] then
			if compact then
				local span = mw.html.create('span')
					:addClass('league-badge')
					:attr('data-league-region', trimmed:lower())
					:wikitext(icon(trimmed, league))
				:done()
				
				table.insert(ret, tostring(span))
			else
				local uc_region = trimmed:gsub('^%l', string.upper)
				
				local span = mw.html.create('span')
					:addClass('league-region')
                    :css('text-align', 'left')
					:attr('data-league-region', trimmed:lower())
					:wikitext(icon(trimmed, league))
					:tag('span')
						:addClass('league-name')
						:wikitext(string.format('[[%s/Regions/%s|%s]]', league, uc_region, uc_region))
					:done()
					:tag('span')
						:addClass('league-check')
						:wikitext('✓')
					:done()
				:done()
				
				table.insert(ret, tostring(span))
			end
		end
	end
	
	return table.concat(ret, '')
end

function p._compact(region, league)
	if region == nil or region:lower() == 'no' or region:lower() == 'n/a' then
		return ''
	end
	
	if league == nil or league == '' then
		league = p.DEFAULT_LEAGUE
	end
	
	return badges(region, league, true)
end

function p._main(region, league)
	if region == nil or region:lower() == 'no' or region:lower() == 'n/a' then
		return 'None'
	end
	
	if league == nil or league == '' then
		league = p.DEFAULT_LEAGUE
	end
	
	return badges(region, league, false)
end

-- Renders badge icons with text
function p.main(frame)
	local frameArgs = frame.args
	local args = frame:getParent().args
	return p._main(frameArgs[1] or args[1], frameArgs.league)
end

-- Renders badge icons without text
function p.compact(frame)
	local frameArgs = frame.args
	local args = frame:getParent().args
	return p._compact(frameArgs[1] or args[1], frameArgs.league)
end

-- Shows at most 2 full chips.
-- More regions will render as badge icons without text.
function p.regionsWithSizeThreshold(arg)
	local trimmed = mw.text.trim(arg or '')
	local comma_count = select(2, string.gsub(trimmed, ',', ''))
	
	local func = comma_count < 2 and p._main or p._compact
	return func(trimmed)
end

-- Parsing function for use in infoboxes.
function p.regionsForInfobox(arg)
	if arg == nil or arg == '' or arg == "UH OH YOU SHOULDN'T SEE THIS!" or string.find(arg, 'action=edit') then
		return nil
	end
	
	if string.lower(arg) == 'no' or string.lower(arg) == 'n/a' then
		return 'N/A'
	end
	
	return p.regionsWithSizeThreshold(arg)
end

return p