require('strict')
local commas = require('Module:Addcommas')
local skillpic = require('Module:Skill clickpic')._main
local getDefaultLeague = require('Module:LeagueRegion').getDefaultLeague
local renderLeagueRegions = require('Module:LeagueRegion')._main
local questDependencies = mw.loadData('Module:Questreq/data')
local p = {}

local MEM_ICON = {
	[false] = '[[File:F2P icon.png|30px|center|link=Free-to-play]]',
	[true] = '[[File:P2P icon.png|30px|center|link=Members]]',
}

local function renderNaCell(td)
	td:addClass('table-na nohighlight'):css('text-align: center'):wikitext('N/A')
end

--- Parse a quest reward entry such as `Mining:1,300 experience`.
local function parseRewardEntry(entry)
	if not entry or entry == '' then
		return nil, nil
	end

	local skillName, xpValue, xpText = entry:match('^([^:]+):([%d,A-Za-z%.]+) ([a-z]+)')
	if not skillName or not xpValue then
		return nil, entry
	end

	local xp = tonumber(commas._strip(xpValue), 10)
	if xp then
		if xpText == 'bonus experience' then
			return xp, commas._add(xp), true
		end
		return xp, commas._add(xp), false
	end

	return nil, xpValue, false
end

--- Find all reward entries for `targetSkill` in parallel bucket arrays.
--- This is technically very defensive because they should really be in the same order.
-- If multiple skill xp entries are present for the skill, the code sums them together
-- to get the total reward xp (ignoring siutations with mixed bonus/non-bonus xp)
local function findSkillReward(rewardsSkill, rewardsSkillXp, targetSkill)
	if not rewardsSkill or not rewardsSkillXp then
		return nil, nil
	end

	local totalXp = 0
	local isBonus = nil

	local target = targetSkill:lower()
	for index, skill in ipairs(rewardsSkill) do
		if (skill or ''):lower() == target then
			local rewardXp, rewardDisplay, rewardBonus = parseRewardEntry(rewardsSkillXp[index])
			if rewardXp == nil or type(rewardXp) ~= 'number' then
				-- non-numeric value eg "Medium lamp", just return first display value instead
				-- of totalling
				return rewardXp, rewardDisplay
			end
			if isBonus == nil then
				isBonus = rewardBonus
			end
			
			if isBonus == rewardBonus then
				-- don't total bonus with non-bonus xp
				-- if quest awards both. (assumption: whichever is first in the
				-- template is the one placed into the table)
				totalXp = totalXp + rewardXp
			end
		end
	end
	
	return totalXp, commas._add(totalXp)
end

--- Merge a quest's own skill requirements into `skillLevels` (skill -> max level).
local function addDirectRequirements(quest, skillLevels)
	if not quest then
		return
	end

	local levels = quest.requirement_skill_level or {}
	for index, entry in ipairs(levels) do
		local skillName, level
		local parsedSkill, levelText = (entry or ''):match('^([^:]+):(%d+)$')
		if parsedSkill and levelText then
			skillName = mw.text.trim(parsedSkill)
			level = tonumber(levelText)
		elseif quest.requirement_skill and quest.requirement_skill[index] then
			local levelOnly = (entry or ''):match('^(%d+)$')
			if levelOnly then
				skillName = mw.text.trim(quest.requirement_skill[index])
				level = tonumber(levelOnly)
			end
		end

		if skillName and level then
			local current = skillLevels[skillName]
			if not current or level > current then
				skillLevels[skillName] = level
			end
		end
	end
end
local function skillLevelsToArray(skillLevels)
	local requirements = {}
	for skill, level in pairs(skillLevels) do
		table.insert(requirements, {
			skill = skill,
			level = level,
		})
	end
	table.sort(requirements, function(a, b)
		return a.skill < b.skill
	end)
	return requirements
end

--- Walk quest dependency graph and return direct and prerequisite `{ skill, level }` records.
--- Prerequisite levels are merged across the graph, keeping the highest level per skill.
local function parseRequirements(quest, questByName)
	local directLevels = {}
	addDirectRequirements(quest, directLevels)

	local prereqLevels = {}
	local visited = {
		[quest.page_name] = true,
	}

	local function walk(questName, questObj)
		if not questName or visited[questName] or not questObj then
			return
		end
		visited[questName] = true

		addDirectRequirements(questObj, prereqLevels)

		local depEntry = questDependencies[questName]
		local prereqs = depEntry or {}
		for _, prereqName in ipairs(prereqs) do
			walk(prereqName, questByName[prereqName])
		end
	end

	local depEntry = questDependencies[quest.page_name]
	local prereqs = depEntry or {}
	for _, prereqName in ipairs(prereqs) do
		walk(prereqName, questByName[prereqName])
	end
	
	-- remove pre-req requirements that are lower than main quest
	for skill, level in pairs(prereqLevels) do
		local directLevel = directLevels[skill]
		if directLevel and level <= directLevel then
			prereqLevels[skill] = nil
		end
	end

	return skillLevelsToArray(directLevels), skillLevelsToArray(prereqLevels)
end

--- Split requirements into the filtered skill column and all other requirements.
local function splitRequirements(requirements, filterSkill)
	local primaryRequirement = nil
	local otherRequirements = {}
	local target = filterSkill:lower()

	for _, requirement in ipairs(requirements) do
		if requirement.skill:lower() == target then
			primaryRequirement = requirement
		else
			table.insert(otherRequirements, requirement)
		end
	end

	return primaryRequirement, otherRequirements
end

local function pickHigherRequirement(a, b)
	if not a then
		return b
	end
	if not b then
		return a
	end
	if b.level > a.level then
		return b
	end
	return a
end

local function extractQuestJson(quest)
	if not quest or not quest.json or quest.json == '' then
		return false
	end

	local data = mw.text.jsonDecode(quest.json)

	local isMembers = (data.members or ''):lower() == 'yes'
	local leagueRegion = (data.league_region_req or '')
	local leagueRegionAuto = (data.league_region_auto ~= 'no' and data.league_region_auto) or nil
	
	return isMembers, leagueRegion, leagueRegionAuto
end

local function removeSubquestRewards(skillRewardsByQuestName, parentQuestByQuestName)
	for subquest, parentQuest in pairs(parentQuestByQuestName) do
		local parentQuestReward = skillRewardsByQuestName[parentQuest]
		local subquestReward = skillRewardsByQuestName[subquest]
		if subquestReward and parentQuestReward and type(subquestReward.xpValue) == "number" and type(parentQuestReward.xpValue) == 'number' then
			-- reduce parent xp reward by subquest reward. accounts for siutations like r4d where
			-- there are multiple subquests that reward cooking/crafting,
			-- as well as (hypothetical?) sitations where the parent quest rewards additional xp on top of the subquests
			skillRewardsByQuestName[parentQuest].xpValue = parentQuestReward.xpValue - subquestReward.xpValue
			skillRewardsByQuestName[parentQuest].xpDisplay = commas._add(skillRewardsByQuestName[parentQuest].xpValue)
		end
	end
end

local function renderPrimaryRequirementCell(tr, primaryRequirement)
	local td = tr:tag('td')
	if primaryRequirement then
		td:wikitext(skillpic(primaryRequirement.skill, primaryRequirement.level, true, true))
	else
		renderNaCell(td)
	end
	td:done()
end

local function appendRequirementsList(parent, requirements)
	local list = parent:tag('ul')
	for _, requirement in ipairs(requirements) do
		list
			:tag('li')
			:wikitext(skillpic(requirement.skill, requirement.level, true, true))
		:done()
	end
end

local function renderOtherRequirementsCell(tr, otherRequirements, prereqOtherRequirements)
	local td = tr:tag('td')
	local hasDirect = #otherRequirements > 0
	local hasPrereq = #prereqOtherRequirements > 0

	if not hasDirect and not hasPrereq then
		renderNaCell(td)
	else
		if hasDirect then
			appendRequirementsList(td, otherRequirements)
		end

		if hasPrereq then
			local collapsible = td:tag('table')
				:addClass('mw-collapsible mw-collapsed')
				:css('background', 'none')
				:css('width', '100%')
			collapsible
				:tag('tr')
					:tag('th')
						:css('position', 'static')
						:wikitext('Including prerequisites:')
					:done()
				:done()
			local prereqTd = collapsible:tag('tr'):tag('td')
			appendRequirementsList(prereqTd, prereqOtherRequirements)
		end
	end
	td:done()
end

function p._main(args, frame)
	local filterSkill = mw.text.trim(args.skill or '')
	if filterSkill == '' then
		return 'Error: skill parameter required.'
	end

	local f2pOnly = mw.text.trim(args.f2p or ''):lower() == 'yes'

	local rewardsData = bucket('quest_rewards')
		.select('page_name', 'rewards_skill', 'rewards_skill_xp')
		.where('rewards_skill', filterSkill)
		.limit(2000)
		.run()

	local questData = bucket('quest')
		.select('page_name', 'icon', 'requirement_skill', 'requirement_skill_level', 'json')
		.where(bucket.Not('Category:Removed quests'))
		.limit(2000)
		.run()
		
	local questInfobox = bucket('infobox_quest')
		.select('page_name', 'subquest_of')
		.limit(2000)
		.run()

	local skillRewardsByQuestName = {}
	for _, reward in ipairs(rewardsData) do
		local xpValue, xpDisplay = findSkillReward(
			reward.rewards_skill,
			reward.rewards_skill_xp,
			filterSkill
		)
		skillRewardsByQuestName[reward.page_name] = { 
			xpValue = xpValue, 
			xpDisplay = xpDisplay, 
			reward = reward
		}
	end
	
	local parentQuestByQuestName = {}
	for _, infobox in ipairs(questInfobox) do
		parentQuestByQuestName[infobox.page_name] = infobox.subquest_of
	end

	--mw.logObject(questData)
	--mw.logObject(skillRewardsByQuestName)
	--mw.logObject(parentQuestByQuestName)

	local rows = {}
	local totalXp = 0
	
	local questByName = {}
	for _, quest in ipairs(questData) do
		questByName[quest.page_name] = quest
	end
	
	removeSubquestRewards(skillRewardsByQuestName, parentQuestByQuestName)

	for _, quest in ipairs(questData) do
		local questName = quest.page_name
		local reward = skillRewardsByQuestName[questName]
		if reward and reward.xpValue ~= 0 and reward.xpDisplay then
			local members, leagueRegion, leagueRegionAuto = extractQuestJson(quest)
			if not f2pOnly or not members then
				local directRequirements, prereqRequirements = parseRequirements(quest, questByName)
				local directPrimary, otherRequirements = splitRequirements(directRequirements, filterSkill)
				local prereqPrimary, prereqOtherRequirements = splitRequirements(prereqRequirements, filterSkill)
				local primaryRequirement = pickHigherRequirement(directPrimary, prereqPrimary)

				if reward.xpValue then
					totalXp = totalXp + reward.xpValue
				end

				table.insert(rows, {
					questName = questName,
					icon = quest.icon or (questName .. ' icon.png'),
					xpValue = reward.xpValue or -1,
					xpDisplay = reward.xpDisplay,
					members = members,
					primaryRequirement = primaryRequirement,
					otherRequirements = otherRequirements,
					prereqOtherRequirements = prereqOtherRequirements,
					leagueRegion = leagueRegion,
					leagueRegionAuto = leagueRegionAuto
				})
			end
		end
	end

	if #rows == 0 then
		return string.format("''There are no quests that reward %s  experience.''", filterSkill)
	end

	-- can't be an :orderBy() on the bucket because xp rewards are a list column
	table.sort(rows, function(a, b)
		if a.xpValue == b.xpValue then
			return a.questName < b.questName
		end
		return a.xpValue < b.xpValue
	end)

	local tbl = mw.html.create('table')
		:addClass('wikitable sortable sticky-header lighttable qc-active align-left-1 align-center-3 align-left-5')
		:css('text-align: center')
		:tag('tr')
			:tag('th'):wikitext('Quest'):css('width', '20%'):done()
			:tag('th'):wikitext('Members'):done()
			:tag('th'):attr('data-sort-type', 'number'):wikitext('XP<br>reward'):done()
			:tag('th'):attr('data-sort-type', 'text'):wikitext(filterSkill .. '<br>requirement'):done()
			:tag('th'):attr('data-sort-type', 'text'):wikitext('Other requirements'):done()
			:tag('th'):addClass('leagues-global-flag'):wikitext(string.format('[[%s|League]] region required', getDefaultLeague(frame))):done()
			:tag('th'):addClass('leagues-global-flag'):wikitext(string.format('[[%s|League]] region autocompleted', getDefaultLeague(frame))):done()
		:done()

	for _, row in ipairs(rows) do
		local tr = tbl:tag('tr')
		tr:tag('td')
			:wikitext(string.format('[[File:%s|link=%s|x25px]] [[%s]]', row.icon, row.questName, row.questName))
			:done()
		tr:tag('td'):wikitext(MEM_ICON[row.members]):attr('data-sort-value', (row.members and 'yes') or 'no'):done()
		tr:tag('td'):wikitext(row.xpDisplay):done()
		renderPrimaryRequirementCell(tr, row.primaryRequirement)
		renderOtherRequirementsCell(tr, row.otherRequirements, row.prereqOtherRequirements)
		tr:tag('td'):addClass('leagues-global-flag'):wikitext(renderLeagueRegions(row.leagueRegion))
		tr:tag('td'):addClass('leagues-global-flag'):wikitext((row.leagueRegionAuto and renderLeagueRegions(row.leagueRegionAuto)) or '')
		tr:done()
	end

	tbl:tag('tr')
		:addClass('sortbottom nohighlight')
		:tag('th'):css('border-right: 0'):done()
		:tag('th'):css('border-left: 0'):wikitext('Total'):done()
		:tag('td'):css('text-align: center'):wikitext(commas._add(totalXp)):done()
		:tag('th'):attr('colspan', 2):done()
		:tag('th'):addClass('leagues-global-flag'):attr('colspan', 2):done()
	:done()

	return tostring(tbl)
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args, frame)
end

return p