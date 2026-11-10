local p = {}

require("strict")
require("Module:Mw.html extension")

local yesno = require('Module:Yesno')
local editBtn = '? <small>' .. require('Module:Edit button')() .. '</small>'
local hc = require('Module:Paramtest').has_content
local onmain = require('Module:Mainonly').on_main()
local mapLink = require('Module:Map/templates')._maptemp
local leagues = require('Module:LeagueRegion')
local var = mw.ext.VariablesLua

local function to_link(link, display)
	if link == nil then
		return nil
	end

	return "[[" .. link .. "|" .. display .. "]]"
end

local mems_icons = {
	[false] = "[[File:F2P icon.png|30px|center|link=Free-to-play|Free-to-play]]",
	[true] = "[[File:P2P icon.png|30px|center|link=Members|Members]]",
}

local function to_member_data(parsed_member)
	local memyesno = yesno(parsed_member, nil)
	local members = memyesno ~= nil and mems_icons[memyesno] or 'Unknown'
	return members
end

local function querySitesByName(name, category_filter)
	local b = bucket('resource_locations')
		.select(
			'page_name',
			'page_name_sub',
			'location',
			'requirements',
			'league_region',
			'infobox_location.is_members_only',
			'infobox_location.location'
		)
		.join('infobox_location', 'resource_locations.page_name', 'infobox_location.page_name')
		.where('resource_location_type', 'mine')
		.where('page_name_sub', name)
		.limit(5000)

	if category_filter then
		b.where("Category:" .. category_filter)
	else
		b.where(bucket.Not("Category:Removed content"))
	end

	return b.run()
end

local function getSiteInfoByName(site_name)
	if hc(site_name) then
		local sites = querySitesByName(site_name)
		if #sites > 0 then
			local site = sites[1]

			return {
				valid = true,
				link = site['page_name_sub'],
				display = site['location'],
				membs = site['infobox_location.is_members_only'],
				requirements = site["requirements"],
				league_region = site["league_region"],
				location = site["infobox_location.location"],
			}
		end
	end

	return {
		valid = false,
	}
end

-- Handle League Region variable storage
local function addLeagueRegion(dropVersions, leagueRegion)
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
			if region ~= 'no' and region ~= 'n/a' then
				valuesForVersion[region] = true
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
end

-- {{RockLocLine}}
function p.rock_location_line(frame)
	local args = frame:getParent().args

	local site_info = getSiteInfoByName(args.site)

	-- Copy args into new table to avoid custom scribunto iteration behavior on args
	local mapArgs = {}
	for k, v in pairs(args) do
		-- Only copy named and non-map args
		if k ~= 'site' and not tonumber(k) then
			mapArgs[k] = v
		end
	end

	if not hc(mapArgs.mtype) then
		mapArgs.mtype = 'pin'
	end

	if not hc(mapArgs.icon) then
		mapArgs.icon = 'bluePin'
	end

	mapArgs.ptype = 'object'
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

		table.insert(mapArgs, argStr)
		spawns = spawns + 1
	end

	if hc(args.spawns) then
		spawns = tonumber(args.spawns) or spawns
	end

	local version
	if hc(args.version) then
		version = {}
		for ver in mw.text.gsplit(args.version, '%s*,%s*') do
			table.insert(version, ver)
		end
	end

	if site_info.valid then
		bucket('infobox_mine_location').put({
			site = site_info.link,
			instances = spawns,
			map_args = mapArgs,
			version = version,
		})
	end

	-- if at least one spawn given, add the maplink
	-- otherwise, force spawn and maplink cols to editBtn and tag with 'Needs map' category
	-- this prevents claiming zero spawns and a map of Lumbridge, a rather useless/misleading output
	local map, instances
	if instances == 0 then
		spawns = editBtn
		map = editBtn .. '[[Category:Needs map]]'
	else
		instances = tostring(spawns)
		map = mapLink(mapArgs, { type = 'maplink' })
	end

	-- build table row to return
	-- column order (from {{RockLocationTableHead}}): Mine, Members, Requirements, Instances, Map, League Region
	local ret = mw.html.create('tr')
		:td(to_link(site_info.link, site_info.display))

	if site_info.location ~= nil then
		ret:td(site_info.location)
	else
		ret:na()
	end

	ret:td(to_member_data(site_info.membs))

	local req = site_info.requirements
	if req then
		ret:td('\n' .. req .. '\n')
	else
		ret:na()
	end

	ret:td(instances)
		:td(map)

	local siteleagueRegion = site_info.league_region
	local leagueRegion = leagues.regionsWithSizeThreshold(siteleagueRegion)
	if leagueRegion and leagueRegion ~= "" and leagueRegion ~= 'None' then
		ret:td { leagueRegion, class = "leagues-global-flag" }
	else
		ret:td { "N/A",
			attr = { "data-sort-value", "" },
			class = "table-na leagues-global-flag" }
	end

	if siteleagueRegion ~= nil then
		addLeagueRegion(args.dropversion or '', siteleagueRegion)
	end

	return ret:allDone()
end

return p