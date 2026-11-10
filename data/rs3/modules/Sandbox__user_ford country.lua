--<nowiki>
--Module for combat achievements in the Equilibrium League except I have no idea what I'm doing

local p = {}

local paramTest = require('Module:Paramtest')
local yesNo = require('Module:Yesno')
local tb = require('Module:LeagueRegion').regionsForInfobox

local tiers = {
	easy = 1,
	medium = 2,
	hard = 3,
	elite = 4,
	master = 5,
	grandmaster = 6
}

local function buildRow(itemData)
	local maincategory = itemData.maincategory or ''
	local subcategory = itemData.subcategory or ''
	local Name = itemData.page_name_sub or ''
	local Description = itemData.task or ''
	local difficulty = tostring(itemData.difficulty or '')
	local difficultyKey = string.lower(difficulty)
	local points = tiers[difficultyKey] or 0
	local icon = string.format(
		'[[File:Combat Mastery %s Achievement icon.png]] ',
		difficultyKey
	)
	local difficultyText =
		icon ..
		difficulty ..
		' (' ..
		points ..
		' ' ..
		(points == 1 and 'pt' or 'pts') ..
		')'
	local region = itemData.league_region
	local regionRaw = region ~= nil and region ~= '' and string.lower(region) or ''
	local jsonText = itemData.json or ''

    local row = mw.html.create('tr')
	row:attr('data-ca-task-id', tostring(itemData.id or ''))
	--row:attr('data-league-area-for-filtering', regionRaw)
	row:tag('td'):wikitext( '[[' .. maincategory .. ']]' ):done()
    row:tag('td'):wikitext( '[[' .. subcategory .. ']]' ):done()
    row:tag('td'):wikitext( '[[' .. Name .. ']]' ):done()
    row:tag('td'):wikitext( Description ):done()
    row:tag('td'):wikitext( difficultyText ):done()
    row:tag('td'):wikitext( jsonText ):done()

    if region ~= nil and region ~= ''  and region ~= 'N/A' and region ~= 'NA' then
        row:tag('td'):wikitext(tb(region)):done()
    else
        row:tag('td'):wikitext('N/A'):addClass('table-na nohighlight'):done()
    end
	
	return row
	
end

local function createHeader()
	local tabl = mw.html.create('table'):addClass('wikitable lighttable sortable qc-active ca-tasks jquery-tablesorter gm-table')
	local row = tabl:tag('tr')
	row:tag('th'):wikitext('maincategory'):done()
	row:tag('th'):wikitext('subcategory'):done()
	row:tag('th'):wikitext('Name'):done()
	row:tag('th'):wikitext('Description'):done()
	row:tag('th'):wikitext('difficulty'):done()
	row:tag('th'):wikitext('League Region'):done()
	row:tag('th'):wikitext('json'):done()
	return tabl
end

local function queryAchievements(out, pagesQuery, prefix, excluded)
	local b = bucket('achievement')
		.select('page_name', 'json', 'achievement_id.id',
			'achievement_requirement.regular', 'achievement_requirement.ironman', 'achievement_requirement.cgim',
			'achievement_notes.notes', 'release_date.date_text')
		.join('achievement_id', 'page_name_sub', 'achievement_id.page_name_sub')
		.join('achievement_notes', 'page_name_sub', 'achievement_notes.page_name_sub')
		.join('achievement_requirement', 'page_name_sub', 'achievement_requirement.page_name_sub')
		.join('release_date', 'page_name_sub', 'release_date.page_name_sub')
		.where(pagesQuery)
		.limit(5000)

	if excluded then 
		local not_categories = Array.map(categories_to_exclude, function(cat) return { bucket.Not("Category:" .. cat) } end)
		b.where(bucket.And(not_categories))
	end

	local bucketresult = b.run()
	-- Filter out any achievements with a null json field
	bucketresult = Array.filter(bucketresult, function(cheevo) return cheevo.json end)
	for _, record in ipairs(bucketresult) do
		local achievement = mw.text.jsonDecode(record.json)
		if prefix == '' or achievement.name:sub(1, #prefix) == prefix then
			-- Why is this here? What's wrong with achievements without a score?
			-- Mostly likely a 'tracker' achievement e.g. Task Master, Quest Cape (achievement)
			if achievement.score then
				extractBucketRecord(achievement, record)
				table.insert(out, achievement)
			end
		end
	end
end

local function getAchievements(queries, prefix, excluded)
	local out = {}
	for _, pagesQuery in ipairs(queries) do
		queryAchievements(out, pagesQuery, prefix, excluded)
	end
	return out
end

local function getcategories(category, difficulty)
	local categories = { 'Category:Achievements' }
	if category == 'Achievements with a RuneScore of 0' then
		categories = { string.format("Category:Achievements with a RuneScore of 0") }
	elseif category then
		categories = { string.format("Category:%s achievements", category) }
	end

	if difficulty then
		for key, _ in ipairs(categories) do
			categories[key] = bucket.And(categories[key], string.format("Category:%s achievements", difficulty))
		end
	end

	return categories
end

local function getCategoryType(row, category)
	if category == nil or category == '' then return 0 end
	if row.maincategory == category then return 1 end
	if row.subcategory == category then return 2 end
	if row.subsubcategory == category then return 3 end
	return 0
end

local function makeTable(achievements, columns, noGroup, autosort)
	local ret = mw.html.create('table'):addClass('wikitable sortable sticky-header lighttable'):attr('data-tableid',
		'Achievements list')
	local header = {}

	if autosort ~= false then
		ret:addClass('autosort=1,a')
	end

	-- only show (sub)subcat columns if some of them aren't N/A
	local showSubcategory = false
	local showSubsubcategory = false
	local showCombatScore = false;
	for _, v in ipairs(achievements) do
		if (v.subcategory or '') ~= '' and (v.subcategory or ''):lower() ~= 'no' then
			showSubcategory = true
		end
		if (v.subsubcategory or '') ~= '' and (v.subsubcategory or ''):lower() ~= 'no' then
			showSubsubcategory = true
		end
		do
			local combat_score = tostring(v['combat score'] or '');
			if combat_score ~= '' and combat_score:lower() ~= 'no' then
				showCombatScore = true;
			end
		end
	end

	-- man Lua makes some things difficult
	local tempColumns = {}
	for _, column in ipairs(columns) do
		if column == 'subcategory' then
			if showSubcategory then
				table.insert(tempColumns, column)
			end
		elseif column == 'subsubcategory' then
			if showSubsubcategory then
				table.insert(tempColumns, column)
			end
		elseif column == 'combat_score' then
			if showCombatScore then
				table.insert(tempColumns, column)
			end
		else
			table.insert(tempColumns, column)
		end
	end
	columns = tempColumns

	for _, column in ipairs(columns) do
		table.insert(header, headers[column])
	end

	tables._row(ret:tr(), header, true)
	local rows = {}
	local rowNum = 0
	for _, achievement in ipairs(achievements) do
		rowNum = rowNum + 1
		local maincategory = achievement.maincategory or 'No'
		local subcategory = achievement.subcategory or 'No'
		local subsubcategory = achievement.subsubcategory or 'No'
		local combatScore = tostring(achievement["combat score"] or "");
		local combatMasteryTier = tostring(achievement["combat mastery"] or "");

		local subcategoryCell = { text = "N/A", class = "table-na nohighlight" }
		if subcategory:lower() ~= 'no' then
			subcategoryCell = { text = string.format("[[%s achievements|%s]]", subcategory, subcategory) }
		end
		local subsubcategoryCell = { text = "N/A", class = "table-na nohighlight" }
		if subsubcategory:lower() ~= 'no' then
			subsubcategoryCell = { text = string.format("[[%s achievements|%s]]", subsubcategory, subsubcategory) }
		end

		local combatMasteryTierCell = { text = "N/A", class = "table-na nohighlight" }
		if combatMasteryTier:lower() ~= '' then
			local sortValue = combatMasteryTier
			if (combatMasteryTier:lower() == 'easy') then
				sortValue = '1'
			elseif (combatMasteryTier:lower() == 'medium') then
				sortValue = '2'
			elseif (combatMasteryTier:lower() == 'hard') then
				sortValue = '3'
			elseif (combatMasteryTier:lower() == 'elite') then
				sortValue = '4'
			elseif (combatMasteryTier:lower() == 'master') then
				sortValue = '5'
			elseif (combatMasteryTier:lower() == 'grandmaster') then
				sortValue = '6'
			end

			combatMasteryTierCell = {
				text = string.format(
					"[[File:Combat Mastery - %s achievement icon.png|25x25px|link=Combat Mastery - %s]] [[Combat Mastery - %s|%s]]",
					combatMasteryTier, combatMasteryTier, combatMasteryTier, combatMasteryTier),
				attr = { ["data-sort-value"] = sortValue }
			}
		end

		local combatScoreCell = {
			text = "N/A",
			class = "table-na nohighlight",
		};
		if combatScore ~= "" and combatScore ~= "no" then
			combatScoreCell = { text = combatScore }
		end

		local rowData = {
			name = {
				text = string.format("[[%s|%s]]", achievement._page, achievement.name),
				attr = { ["data-sort-value"] = achUtil.toSortKey(achievement.name) },
			},
			description = achievement.description or '',
			members = members_icon(yn(achievement.members)),
			category = string.format("[[%s achievements|%s]]", maincategory, maincategory),
			subcategory = subcategoryCell,
			subsubcategory = subsubcategoryCell,
			score = achievement.score,
			combat_mastery = combatMasteryTierCell,
			combat_score = combatScoreCell,
			sequence_number = rowNum,
			requirements = '\n' .. (achievement.requirements or '') .. '\n',
			notes = "\n" .. lang:ucfirst(achievement.notes or '') .. '\n',
			storymode = achievement.storymode and okay or not_okay,
			release = achievement.release,
			gracestart = achievement.gracestart,
			graceperiod = achievement.graceperiod
		}

		local row = {}
		for _, column in ipairs(columns) do
			table.insert(row, rowData[column])
		end
		row.id = achievement.id
		table.insert(rows, row)
	end
	if autosort ~= false then
		local function sort_function(a, b)
			return (tonumber(a[1]) or 0) < (tonumber(b[1]) or 0)
		end
		if columns[1] == 'name' then
			sort_function = function(a, b)
				return a[1].attr['data-sort-value'] < b[1].attr['data-sort-value']
			end
		end
		table.sort(rows, sort_function)
	end
	for _, row in ipairs(rows) do
		tables._row(ret:tr { attr = { 'data-rowid', row.id } }, row, false)
	end

	ret = tostring(ret)

	if noGroup then
		return ret
	elseif #achievements == 1 then
		return "''There is 1 achievement in this group.''\n" .. ret
	else
		return string.format("''There are %d achievements in this group.''\n", #achievements) .. ret
	end
end

function p._main(args)
	local limit = paramTest.default_to(tonumber(args.limit), 5000)
	local region = paramTest.has_content(args.region) and args.region or nil

	local data = queryAchievements(out, pagesQuery, prefix, excluded)

	local ret = createHeader()
	for _, itemPage in ipairs(data) do
		ret:node(buildRow(itemPage))
	end

	return ret
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

return p