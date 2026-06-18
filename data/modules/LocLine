local p = {}

local editBtn = '<small>' .. require('Module:Edit button')() .. '</small>'
local yesno = require('Module:Yesno')
local isEmpty = require('Module:Paramtest').is_empty
local hc = require('Module:Paramtest').has_content
local buildMap = require('Module:Map').buildMap
local onmain = require('Module:Mainonly').on_main()
local tb = require('Module:Trailblazer Region')
local var = mw.ext.VariablesLua

local membscol = {
	[true] = '[[File:Member icon.png|link=Members|alt=Members]]',
	[false] = '[[File:Free-to-play icon.png|link=Free-to-play|alt=Free-to-play]]',
}

function p.main(frame)
	local args = frame:getParent().args
	local templateArgs = frame.args

	-- Copy args into new table to avoid custom scribunto iteration behavior on args
	local mapArgs = {}
	local coordinates = {}
	for k,v in pairs(args) do
    	mapArgs[k] = v
    	--Bucket can only hold 5254 bytes of information in a repeated field
		--this restriction is going away in the next update. For now just truncate
		--to 100 entries (strangled plant has very long entries)
    	if type(k) == 'number' and #coordinates < 100 then
			local cord = mw.text.trim(v)
			if cord ~= '' then
				coordinates[#coordinates + 1] = cord
			end
    	end
	end
	
	if not hc(mapArgs.mtype) then mapArgs.mtype = 'pin' end
	if not hc(mapArgs.icon) then mapArgs.icon = templateArgs.icon end
	mapArgs.ptype = templateArgs.ptype
	mapArgs.type = 'maplink'

	local loc = args.location or '? ' .. editBtn
	if (isEmpty(loc)) then loc = '? ' .. editBtn end

	local membs = membscol[yesno(args.members ~= nil and args.members or "no")]
	
	local spawns = args.spawns
	if spawns == nil then
		local i = 1
		while args[i] do i = i + 1 end -- Counts up the amount of spawns
		spawns = i - 1
	end
	if spawns == 0 then spawns = '? ' .. editBtn end
	
	local mapping = buildMap(mapArgs)
	
	-- build table row to return
	local locationRow = mw.html.create('tr')
	locationRow:tag('td'):wikitext(loc):done()
	if templateArgs.ptype == 'monster' then
		local levels = args.levels
		if (isEmpty(levels)) then levels = '? ' .. editBtn end
		locationRow:tag('td'):addClass(levels == 'N/A' and 'table-na' or ''):wikitext(levels):done()
	end
	locationRow:tag('td'):wikitext(membs):done()
	locationRow:tag('td'):wikitext(spawns):done()
	locationRow:tag('td'):wikitext(mapping):done()

	local leagueRegion = args.leagueRegion
	local categoryString = ''
	local locRegions = {}
	if leagueRegion and leagueRegion ~= '' then
		if leagueRegion:lower() == 'n/a' then
			leagueRegion = 'no'
		end

		if yesno(leagueRegion, true) then
			locationRow:tag('td'):attr('class','leagues-global-flag'):wikitext(tb.regionsWithSizeThreshold(leagueRegion))
		else
			locationRow:tag('td'):attr('class','table-na leagues-global-flag'):wikitext('<small>N/A</small>')
		end

		local dropVersions = args.dropversion or ''

		-- All regions are additionally saved to the DEFAULT drop version
		dropVersions = dropVersions .. ',DEFAULT'

		local valuesToSet = {}
		for dropVersion in string.gmatch(dropVersions, ' *([^,]+) *') do
			local varName = string.format('LeagueRegion_%s', dropVersion)

			local valuesForVersion = {}
			-- read any existing values for this var so we can append to it
			local previousRegions = var.var(varName)
			for previousRegion in string.gmatch(previousRegions, ' *([^,]+) *') do
				previousRegion = string.lower(previousRegion)
				valuesForVersion[previousRegion] = true
			end

			-- add in new regions
			for region in string.gmatch(leagueRegion, ' *([^,]+) *') do
				region = string.lower(region)
				valuesForVersion[region] = true
				table.insert(locRegions, region)
			end

			valuesToSet[varName] = valuesForVersion
		end

		-- set new values for each var
		for varName, regions in pairs(valuesToSet) do
			local ordered = {}
			for region, _ in pairs(regions) do
				table.insert(ordered, region)
			end
			table.sort(ordered)
			mw.log('LocLine defining var',varName,table.concat(ordered, ', '))
			var.vardefine(varName, table.concat(ordered, ','))
		end
	else
		locationRow:tag('td'):attr('class','table-na leagues-global-flag'):wikitext('<small>N/A</small>')
		if onmain then
			categoryString = '[[Category:Needs League region]]'
		end
	end
	
	-- Matches the subName logic in DropsLine
	local dropversion = args.dropversion
	local subName = ''
    if dropversion and dropversion ~= 'DEFAULT' then
        subName = args.dropversion
    end
	
	bucket('locline').sub(subName).put{
		members = yesno(args.members ~= nil and args.members or "no"),
		mapid = args['mapID'],
		plane = args['plane'] or 0,
		coordinates = coordinates,
		leagueregion = locRegions
	}

	return tostring(locationRow) .. categoryString
end

return p