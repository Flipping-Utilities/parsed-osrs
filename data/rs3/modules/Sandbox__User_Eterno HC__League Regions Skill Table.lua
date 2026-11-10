local p = {}

local currentLeagueRegions = {
	'#Anachronia',
	'#Asgarnia',
	'#Desert',
	'#Fremennik',
	'#Havenhythe',
	'#Misthalin',
	'#Morytania',
	'#Kandarin',
	'#Karamja',
	'#Tirannwn',
	'#Wilderness',
}

local allowedSubpages = {
	'#Barehanded',
}

local ignoredSubpages = {
	'#Sticky Fingers',
	'#Normal',
	'#Pickpocket',
	'#Knock-out',
}

local function asList(v)
	if v == nil then
		return {}
	elseif type(v) == 'table' then
		return v
	end
	return { v }
end

local function mergeInto(entry, listKey, seenKey, value)
	for _, v in ipairs(asList(value)) do
		if v ~= '' and not entry[seenKey][v] then
			entry[seenKey][v] = true
			table.insert(entry[listKey], v)
		end
	end
end

local function areBlankRegions(row)
	for _, league_region_field in ipairs({
		'infobox_scenery.league_region',
		'infobox_npc.league_region',
		'infobox_monster.league_region'
	}) do
		if row[league_region_field] ~= nil and row[league_region_field] ~= '' then
			if mw.ustring.upper(row[league_region_field]) ~= 'NO' then
				return false
			end
		end
	end
	return true
end

local function levelsFromJson(production_json)
	local skills = {}

	for _, jsonStr in ipairs(production_json or {}) do
		local ok, data = pcall(mw.text.jsonDecode, jsonStr)
		if not ok or type(data) ~= 'table' then
			return nil
		end

		for _, s in ipairs(data.skills) do
			if not skills[s.name] then
				skills[s.name] = tonumber(s.level)
			else
				skills[s.name] = math.min(tonumber(s.level), skills[s.name])
			end
		end
	end

	return skills
end

local function experienceFromJson(production_json)
	local skills = {}

	for _, jsonStr in ipairs(production_json or {}) do
		local ok, data = pcall(mw.text.jsonDecode, jsonStr)
		if not ok or type(data) ~= 'table' then
			return nil
		end

		for _, s in ipairs(data.skills) do
			if not skills[s.name] then
				skills[s.name] = tonumber(s.experience)
			else
				skills[s.name] = math.min(tonumber(s.experience), skills[s.name])
			end
		end
	end

	return skills
end

local function checkSubpageForStrings(subPage, checkedStrings)
	for _, check in ipairs(checkedStrings) do
		if string.find(subPage, check, 1, true) then
			return string.sub(check, 2)
		end
	end
	return nil
end

local function getSubpageRegion(subPage)
	return checkSubpageForStrings(subPage, currentLeagueRegions)
end

local function isIgnoredSubpage(subPage)
	return checkSubpageForStrings(subPage, ignoredSubpages)
end

local function isAllowedSubpage(subPage)
	return getSubpageRegion(subPage) or checkSubpageForStrings(subPage, allowedSubpages)
end

local function buildSkill(skill)
	local query = bucket('recipe')
		.select(
			'recipe.page_name',
			'recipe.page_name_sub',
			'recipe.uses_tool',
			'infobox_scenery.league_region',
			'infobox_npc.league_region',
			'infobox_monster.league_region',
			'recipe.production_json'
		)
		.join('infobox_scenery', 'infobox_scenery.page_name', 'recipe.page_name')
		.join('infobox_npc', 'infobox_npc.page_name', 'recipe.page_name')
		.join('infobox_monster', 'infobox_monster.page_name', 'recipe.page_name')
		.where('recipe.uses_skill', skill)
		.where(bucket.Not("Category:Thievable quest entities"))
	    .where(bucket.Not("Category:Quest NPCs"))
	    .where(bucket.Not("Category:Quest monsters"))
		.limit(5000)

	local rows = query.run()

    local res = {}
	local byPage = {}

	for _, row in ipairs(rows) do
		local page = row['recipe.page_name']
		
		local isSubpage = false
		if row['recipe.page_name_sub'] ~= nil and row['recipe.page_name_sub'] ~= '' then
			if isAllowedSubpage(row['recipe.page_name_sub']) then
				page = row['recipe.page_name_sub']
				isSubpage = true
			end
		end

		if page and page ~= '' and not areBlankRegions(row) then
			local entry = byPage[page]
			if not entry then
				entry = {
					page_name = page,
					tools = {}, toolSeen = {},
					regions = {}, regionSeen = {},
					production = {}, productionSeen = {},
					subpage = isSubpage, subpageRegion = '',
				}
				if isSubpage then
					entry['subpageRegion'] = getSubpageRegion(page)
				end
				
				byPage[page] = entry
				table.insert(res, entry)
			end

			mergeInto(entry, 'tools', 'toolSeen', row['recipe.uses_tool'])
			mergeInto(entry, 'regions', 'regionSeen', row['infobox_scenery.league_region'])
			mergeInto(entry, 'regions', 'regionSeen', row['infobox_npc.league_region'])
			mergeInto(entry, 'regions', 'regionSeen', row['infobox_monster.league_region'])
			mergeInto(entry, 'production', 'productionSeen', row['recipe.production_json'])
		end
	end

    return res
end

function p.main(frame)
	local args = frame.args
	local skill = args.skill or args[1]
	if not skill or skill == '' then
		return '<span class="error">No skill specified</span>'
	end

	local entries = buildSkill(skill)

	local out = mw.html.create('table')
		:addClass('wikitable sortable')
	out:tag('tr')
		:tag('th'):wikitext('Page'):done()
		:tag('th'):wikitext('Level'):done()
		:tag('th'):wikitext('Experience'):done()
		:tag('th'):wikitext('Tools'):done()
		:tag('th'):wikitext('League regions'):done()

	for _, entry in ipairs(entries) do
		local levels = levelsFromJson(entry.production)
		local experiences = experienceFromJson(entry.production)
		
		local emptyExperience = true
		local fmtExperiences = {}
		if experiences ~= nil then
			for skillName, skillExperience in pairs(experiences) do
				if skillExperience > 0 then
					emptyExperience = false
					local skillIcon = frame:expandTemplate{
						title = 'Skill clickpic',
						args = { skillName },
					}
					table.insert(
						fmtExperiences,
						string.format('%s xp %s', skillExperience, skillIcon)
					)
				end
			end
		end
		
		if levels ~= nil and not emptyExperience then
			local fmtLevels = {}
			for skillName, skillLevel in pairs(levels) do
				table.insert(
					fmtLevels,
					frame:expandTemplate{
						title = 'Skill clickpic',
						args = { skillName, skillLevel },
					}
				)
			end
			
			local pageRegions = {}
			if entry.subpage and entry.subpageRegion then
				pageRegions = { entry.subpageRegion }
			else
				pageRegions = entry.regions
			end
			
			local fmtRegions = {}
			for _, region in ipairs(pageRegions) do
				table.insert(
					fmtRegions,
					frame:expandTemplate{
						title = 'LeagueRegionIcon',
						args = { region },
					}
				)
			end

			local fmtTools = {}
			for _, tool in ipairs(entry.tools) do
				table.insert(
					fmtTools,
					string.format('[[%s]]', tool)
				)
			end

			out:tag('tr')
				:tag('td'):wikitext(string.format('[[%s]]', entry.page_name)):done()
			    :tag('td'):wikitext(table.concat(fmtLevels, '<br>')):done()
			    :tag('td'):wikitext(table.concat(fmtExperiences, '<br>')):done()
				:tag('td'):wikitext(table.concat(fmtTools, ', ')):done()
				:tag('td'):wikitext(table.concat(fmtRegions, ', ')):done()
		end
	end

	return tostring(out)
end

return p