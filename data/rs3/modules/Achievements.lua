require("strict")
require('Module:Mw.html extension')
local checkType = require("libraryUtil").checkType
local getArgs = require("Module:Arguments").getArgs
local tt = require("Module:TableTools")
local sparseIpairs = tt.sparseIpairs
local tables = require('Module:Tables')
local yn = require("Module:Yesno")
local achUtil = require("Module:Achievement util")
local parse_requirements_text = achUtil.parse_requirements_text
local sort_and_combine_requirements = achUtil.sort_and_combine_requirements
local lang = mw.getContentLanguage()
local Array = require('Module:Array')
local areq = require('Module:Achievement requirement')

local p = {}

-- Generally excluded categories are commented out; inactive and milestone are included
-- as an explicit replacement for checks that were previously done on the achievement json
local categories_to_exclude = {
	--	"Removed content",
	--	"Future content",
	--	"Beta content",
	--	"Path-only achievements",
	--	"Quest-only achievements",
	--	"Achievements with ironman specific variants",
	--	"Uncategorised achievements",
	"Inactive achievements",
	"Milestone achievements"
}

local function ironman_concerns_disp(concerns, title)
	local ret = mw.html.create('table')
		:addClass('mw-collapsible mw-collapsed')
		:css('background', 'none')
		:css('min-width', 'auto')

	ret:tag('tr'):tag('td')
		:addClass('inventory-image')
		:wikitext(title)

	ret:tag('tr'):tag('td')
		:css('padding-top', '0')
		:node(concerns)

	return ret
end

local function members_icon(is_members)
	if is_members then
		return "[[File:P2P icon.png|21px|link=Members]]"
	end
	return "[[File:F2P icon.png|21px|link=Free-to-play]]"
end

local function extractBucketRecord(achievement, record)
	achievement['_page'] = record.page_name
	achievement.id  = record['achievement_id.id'] and record['achievement_id.id'][1] or -1

	if record['achievement_notes.notes'] then
		achievement.notes = record['achievement_notes.notes']
	end

	local requirement_node
	local regular_requirements_json = record['achievement_requirement.regular']
	if regular_requirements_json then
		local regular_requirements = mw.text.jsonDecode(regular_requirements_json)
		requirement_node = areq.display_top_level_requirement(regular_requirements)
	else
		requirement_node = mw.html.create()
		requirement_node:tag('ul'):tag('li'):wikitext('None')
	end

	local ironman_requirements_json = record['achievement_requirement.ironman']
	if ironman_requirements_json then
		local regular_requirements = mw.text.jsonDecode(ironman_requirements_json)
		local ironman_requirement_node = areq.display_top_level_requirement(regular_requirements)
		requirement_node:node(ironman_concerns_disp(ironman_requirement_node,
			"[[File:Ironman badge.png|link=]] [[File:Hardcore Ironman badge.png|link=]] '''Ironmen:'''"))
	end

	local cgim_requirements_json = record['achievement_requirement.cgim']
	if cgim_requirements_json then
		local regular_requirements = mw.text.jsonDecode(cgim_requirements_json)
		local ironman_requirement_node = areq.display_top_level_requirement(regular_requirements)
		requirement_node:node(ironman_concerns_disp(ironman_requirement_node,
			"[[File:Competitive Group Ironman badge.png|link=]] '''Competitive Group Ironmen:'''"))
	end

	achievement.requirements = tostring(requirement_node)

	achievement.release = record['release_date.date_text']
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

local function getcategories(category, difficulty, onlyCombatMastery)
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
	
	if onlyCombatMastery == true  then
		for key, _ in ipairs(categories) do
			categories[key] = bucket.And(categories[key], "Category:Combat Mastery achievements")
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

local headers = {
	name = "Name",
	description = "Description",
	members = "Members",
	score = "[[File:RuneScore.png|link=RuneScore]]",
	combat_mastery = "[[Combat Mastery achievements|Tier]]",
	combat_score = "[[File:Combat Mastery icon.png|22x22px|link=CombatScore]]",
	notes = 'Notes',
	requirements = 'Requirements',
	storymode = 'Story mode',
	category = "Category",
	subcategory = "Subcategory",
	subsubcategory = "Subsubcategory",
	sequence_number = "#",
	release = 'Release date',
	gracestart = "Grace period start",
	graceperiod = "Grace period end"
}

local not_okay = '[[File:X mark.svg|20px|alt=No|link=]]'
local okay = '[[File:Yes check.svg|20px|alt=Yes|link=]]'
local categoryTypes = { 'maincategory', 'subcategory', 'subsubcategory' }

-- if the sequence number column is included, the data param must be sorted in the correct order
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

local tier_map = {
    Beginner = "0",
    Easy = "1",
    Medium = "2",
	Hard = "3",
	Elite = "4",
}

local function toAreaTaskSortKey(name)
	checkType('"Module:Achievements".toAreaTaskSortKey', 1, name, "string")

	-- Uses `mw.ustring` to correctly handle all Unicode space characters
	local replaced = string.gsub(name, "%a+", tier_map)

	return mw.language.getContentLanguage():caseFold(replaced)
end


function p.list(frame)
	return p._list(getArgs(frame))
end

function p._list(args)
	local isCategory, category, queries, onlyCombatMastery
	local autosort = yn(args.autosort or "yes")

	if yn(args.category) ~= false then
		isCategory = true
		category = args.category or args[1]
		onlyCombatMastery = yn(args.onlyCombatMastery or "no")
		queries = getcategories(category, args.difficulty, onlyCombatMastery)
	else
		-- Not querying categories
		isCategory = false
		queries = {}
		for _, v in sparseIpairs(args) do
			table.insert(queries, { 'page_name', v })
		end
	end

	local achievements = getAchievements(queries, isCategory and args.prefix or '', yn(args.excluded, true))

	if #achievements == 0 then
		if category == 'Grace period' then
			return "''There are currently no achievements with a grace period.''"
		else
			return "''No achievements found matching these criteria.''"
		end
	end

	-- check whether we're querying on category, subcategory, subsubcategory, or none
	local categoryType = getCategoryType(achievements[1], category)
	if args.separate ~= nil then
		-- We're gaining one layer of specificity if they're separate.
		categoryType = categoryType + 1
	end

	local columns = {}
	if isCategory and (args.sequence_number or ''):lower() ~= 'no' then
		table.sort(achievements, function(a, b) return tonumber(a.id or -1) < tonumber(b.id or -1) end)
		if not args.prefix or args.prefix == '' then
			-- don't add sequence number if filtering a category by a prefix (but do sort them above)
			table.insert(columns, "sequence_number")
		end
	end
	table.insert(columns, "name")
	if (args.storymode or ''):lower() == 'yes' then
		table.insert(columns, 'storymode')
	end
	table.insert(columns, "description")
	if category ~= 'Free-to-play' and (args.members_column or ''):lower() ~= 'no' then
	    table.insert(columns, "members")
	end
	if (args.requirements or ''):lower() == 'yes' then
		table.insert(columns, 'requirements')
	end
	if (args.notes or ''):lower() == 'yes' then
		table.insert(columns, 'notes')
	end
	if categoryType <= 0 and (args.category_column or ''):lower() ~= 'no' then
		table.insert(columns, "category")
	end
	if categoryType <= 1 and (args.subcategory_column or ''):lower() ~= 'no' then
		table.insert(columns, "subcategory")
	end
	if categoryType <= 2 and (args.subsubcategory_column or ''):lower() ~= 'no' then
		table.insert(columns, "subsubcategory")
	end
	if (args.release or ''):lower() == 'yes' then
		table.insert(columns, "release")
	end
	if category == 'Grace period' or category == 'Former grace period' then
		table.insert(columns, "gracestart")
	end
	if category == 'Grace period' or category == 'Former grace period' then
		table.insert(columns, "graceperiod")
	end
	if (args.mastery_tier_column or ''):lower() == 'yes' then
		table.insert(columns, "combat_mastery")
	end
	table.insert(columns, "combat_score")
	if (args.runescore_column or ''):lower() ~= 'no' then
		table.insert(columns, "score")
	end

	-- don't let them use separate for a subsubcategory.
	if args.separate == nil or categoryType == 4 then
		return makeTable(achievements, columns, false, autosort)
	end

	local keyed_data = {}
	local keyName = categoryTypes[categoryType]
	local keys = {}
	for _, v in ipairs(achievements) do
		-- can't have nil as a key name in Lua, but this still represents something here
		local key = v[keyName] or 'No'
		if key == '' then key = 'No' end
		if keyed_data[key] == nil then
			keyed_data[key] = {}
			
			if category == 'Area Tasks' then
				table.insert(keys, {name = key, sort = toAreaTaskSortKey(key)})
			else
				table.insert(keys, {name = key, sort = achUtil.toSortKey(key)})
			end
		end
		table.insert(keyed_data[key], v)
	end

	table.sort(keys, function(a, b) return a.sort < b.sort end)

	local ret = {}
	if keyed_data.No then
		local tbl = makeTable(keyed_data.No, columns, false, autosort)
		table.insert(ret, tbl)
	end

	for _, key in ipairs(keys) do
		if key.name ~= "No" then
			local tbl = makeTable(keyed_data[key.name], columns, false, autosort)
			table.insert(ret, "===" .. key.name .. "===\n")
			table.insert(ret, tbl)
		end
	end

	return table.concat(ret, "\n")
end

return p