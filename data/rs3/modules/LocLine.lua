local editBtn = '? <small>' .. require('Module:Edit button')() .. '</small>'
local yesno = require('Module:Yesno')
local pt = require('Module:Paramtest')
local default_to = pt.default_to
local hc = pt.has_content
local onmain = require('Module:Mainonly').on_main()
local mapLink = require('Module:Map/templates')._maptemp
local var = mw.ext.VariablesLua
require('Module:Mw.html extension')

local p = {}

function p.main(frame)
	local args = frame:getParent().args
	local templateArgs = frame.args

	return p._main(args, templateArgs)
end

function p._main(args, templateArgs)
	local membsCol = {
		[true] = '[[File:P2P icon.png|30px|link=Members|alt=Members]]',
		[false] = '[[File:F2P icon.png|30px|link=Free-to-play|alt=Free-to-play]]',
	}
	local membs = membsCol[yesno(args.members or args.mem or "no")]
	
	local loc = default_to(args.location or args.loc, editBtn)
	local levels = default_to(args.levels or args.lvls, editBtn)
	
	local requirements = default_to(args.requirements, "None")
	if requirements:sub(1, 1) == "*" then
		requirements = "\n" .. requirements
	end
	
	-- Copy args into new table to avoid custom scribunto iteration behavior on args
	local mapArgs = {}
	for k, v in pairs(args) do
		-- Only copy named args
		if not tonumber(k) then
			mapArgs[k] = v
		end
	end
	
	if not hc(mapArgs.mtype) then
		mapArgs.mtype = 'pin'
	end
	
	if not hc(mapArgs.icon) then
		mapArgs.icon = templateArgs.icon
	end
	
	mapArgs.ptype = templateArgs.ptype
	mapArgs.type = 'maplink'
	
	-- Assume coordinates are jagex coordinates
	-- (ie the game tile) so center pin in squares.
	-- Allow override using "exact" param
	mapArgs.jagexCoords = 'true'
	if hc(args.exact) then
		mapArgs.jagexCoords = 'false'
	end

	local spawns = 0
	for _, arg in ipairs(args) do
		local argStr = mw.text.trim(arg)
		
        if hc(argStr) then
            -- add "NPC ID: ####" pin descriptions only if description not already provided
            if not arg:find('desc:') then
                local npcId = arg:match('npcid:(%d+)')
                if npcId then
                    local desc = 'NPC ID&#58; ' .. npcId
                    argStr = argStr .. ',desc:' .. desc
                end
            end
            
            table.insert(mapArgs, argStr)
            spawns = spawns + 1
        end
	end

	if hc(args.spawns) then
		spawns = tonumber(args.spawns) or spawns
	end
	
	-- if at least one spawn given, add the maplink
	-- otherwise, force spawn and maplink cols to editBtn and tag with 'Needs map' category
	-- this prevents claiming zero spawns and a map of Lumbridge, a rather useless/misleading output
	local map
	if spawns == 0 then
		spawns = editBtn
		map = editBtn .. '[[Category:Needs map]]'
	else
		spawns = tostring(spawns)
		map = mapLink(mapArgs, { type = 'maplink' })
	end
	
	local categoryString = ''

	local leagueRegion = ''
	local locRegions = {}
	if args.leagueRegion and args.leagueRegion ~= '' then
		local leagues = require('Module:LeagueRegion')
		leagueRegion = leagues.regionsWithSizeThreshold(args.leagueRegion)
		
		categoryString = categoryString .. '[[Category:Pages with League region]]'
		
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
			for region in string.gmatch(args.leagueRegion, ' *([^,]+) *') do
				region = string.lower(region)
				if region ~= 'no' and region ~= 'n/a' then
					valuesForVersion[region] = true
					table.insert(locRegions, region)
				end
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
			mw.log('LocLine defining var', varName, table.concat(ordered, ', '))
			var.vardefine(varName, table.concat(ordered, ','))
		end
	else
		if onmain then
			categoryString = categoryString .. '[[Category:Needs League region]]'
		end
	end
	
	if templateArgs.ptype == 'item' then
		categoryString = categoryString .. '[[Category:Items that have spawns]]'
	end

	-- build table row to return
	-- column order (from {{LocTableHead}}): Location, Levels, Members, Spawns, Map
	local ret = mw.html.create('tr')
		:td(loc)
		:IF(templateArgs.ptype ~= 'object' and templateArgs.ptype ~= 'item')
			:td(levels)
		:END()
		:td(membs)
		:IF(requirements:lower() ~= "none")
			:td(requirements)
		:ELSE()
			:td{"None", attr = { "data-sort-value", "" }, class = "table-na" }
		:END()
		:td(spawns)
		:td(map)
		:IF(leagueRegion and leagueRegion ~= "" and leagueRegion ~= 'None')
			:td{leagueRegion, class = "leagues-global-flag"}
		:ELSE()
			:td{"N/A", attr = { "data-sort-value", "" }, class = "table-na leagues-global-flag" }
		:END()
	
	return ret:allDone():wikitext(categoryString)
end

return p