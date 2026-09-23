require('strict')

local p = {}
local skillreq = require('Module:SCP')._main

local skilllist = {
	'Agility',
	'Attack',
	'Construction',
	'Cooking',
	'Crafting',
	'Defence',
	'Farming',
	'Firemaking',
	'Fishing',
	'Fletching',
	'Herblore',
	'Hunter',
	'Magic',
	'Mining',
	'Prayer',
	'Ranged',
	'Runecraft',
	'Sailing',
	'Slayer',
	'Smithing',
	'Strength',
	'Thieving',
	'Woodcutting',
}

local function getQuestBucketRow(questname)
	local result = bucket('quest')
		.select('page_name', 'requirements')
		.where('page_name', questname)
		.run()

	if #result == 0 then
		return nil
	end

	return result[1]
end

function p.get_all_quests_for_calc()
	local result = bucket('quest')
		.select('page_name')
		.orderBy('page_name', 'asc')
		.run()

	local out = {}

	for _, quest in ipairs(result) do
		if quest.page_name then
			table.insert(out, quest.page_name)
		end
	end

	return ',' .. table.concat(out, ',')
end

local function parseInitialSkillRequirement(requirement)
	-- Only consider a skill requirement if the line begins with a span.
	-- This prevents lines such as the Warriors' Guild requirement from
	-- incorrectly becoming 99 Attack / 99 Strength requirements.
	local initialSpan = requirement:match('^%*%s*(<span.-</span>)')

	if not initialSpan then
		return nil, nil
	end

	local skill = initialSpan:match('data%-skill="([^"]+)"')
	local level = initialSpan:match('data%-level="(%d+)"')

	if not skill or not level then
		return nil, nil
	end

	return skill, tonumber(level)
end

local function stripBullet(requirement)
	return requirement
		:gsub('^%*+', '')
		:gsub('^%s+', '')
		:gsub('%s+$', '')
end

local function getQuestRequirements(questname)
	local quest = getQuestBucketRow(questname)

	local skillsTable = {}
	local otherTable = {}

	if not quest then
		return skillsTable, otherTable
	end

	local requirements = mw.text.split(quest.requirements or '', '\n', true)
	local inQuestSection = false

	for _, requirement in ipairs(requirements) do
		if requirement ~= '' then
			if requirement:match('^%*%s*Completion of the following quests:') then
				inQuestSection = true
			elseif inQuestSection and requirement:match('^%*%*') then
				-- Quest requirements are handled separately.
			else
				inQuestSection = false

				local skill, level = parseInitialSkillRequirement(requirement)

				if skill and level then
					local current = skillsTable[skill]

					if current == nil or level > current then
						skillsTable[skill] = level
					end
				else
					local other = stripBullet(requirement)

					if other ~= '' and other:lower() ~= 'none' then
						otherTable[other] = true
					end
				end
			end
		end
	end

	return skillsTable, otherTable
end

local function getDirectQuestRequirements(questname)
	local quest = getQuestBucketRow(questname)

	if not quest then
		return {}
	end

	local requirements = mw.text.split(quest.requirements or '', '\n', true)
	local quests = {}
	local inQuestSection = false

	for _, requirement in ipairs(requirements) do
		if requirement:match('^%*%s*Completion of the following quests:') then
			inQuestSection = true
		elseif inQuestSection then
			-- Direct requirements are exactly two levels deep:
			-- **[[Quest name]]
			--
			-- Ignore *** and deeper because those will be discovered by
			-- recursively looking at each direct quest's own requirements.
			if requirement:match('^%*%*[^%*]') then
				local questname = requirement:match('^%*%*%s*%[%[([^]|]+)')

				if questname then
					table.insert(quests, questname)
				end
			elseif not requirement:match('^%*') then
				break
			end
		end
	end

	return quests
end

local function collectQuestRequirements(questname, result, seen)
	result = result or {}
	seen = seen or {}

	if seen[questname] then
		return result
	end

	seen[questname] = true

	for _, subquest in ipairs(getDirectQuestRequirements(questname)) do
		if not result[subquest] then
			result[subquest] = true
		end

		collectQuestRequirements(subquest, result, seen)
	end

	return result
end

function p.get_requirements(questname)
	return collectQuestRequirements(questname)
end

function p.getSkillsDirect(frame)
	local questname = frame.args.name
	local skillsOnly = frame.args.skillonly == 'true'

	local skillsTable, otherTable = getQuestRequirements(questname)

	if not skillsOnly then
		for requirement in pairs(otherTable) do
			table.insert(skillsTable, requirement)
		end
	end

	return skillsTable
end

function p.getSkills(questname)
	local lvlret = {}
	local otherret = {}
	local otherset = {}
	local questret = {}
	local qpReq = -1

	local quests = p.get_requirements(questname)

	-- Also inspect the selected quest itself, since the recursive requirement
	-- list only contains its prerequisites.
	quests[questname] = true

	for subquest in pairs(quests) do
		local lvlreqs, otherreqs = getQuestRequirements(subquest)

		for skill, level in pairs(lvlreqs) do
			if skill == 'Quest points' then
				qpReq = math.max(qpReq, level)
			elseif lvlret[skill] == nil or lvlret[skill] < level then
				lvlret[skill] = level
			end
		end

		for other in pairs(otherreqs) do
			otherset[other] = true
		end

		if subquest ~= questname then
			table.insert(questret, '[[' .. subquest .. ']]')
		end
	end

	if qpReq > 0 then
		table.insert(questret, qpReq .. ' [[quest points]]')
	end
	
	for other in pairs(otherset) do
		table.insert(otherret, other)
	end

	table.sort(questret)
	table.sort(otherret)

	return lvlret, otherret, questret
end

function p.renderSkills(frame)
	local questname = frame.args.name
	local lvlreqs, otherreqs, subquests = p.getSkills(questname)

	local ret = mw.html.create('div')

	-- All skill requirements
	local skilltable = ret
		:tag('table')
			:tag('tr')
				:tag('th')
					:css('text-align', 'left')
					:wikitext('Level requirements:')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:addClass('qc-active')
					:tag('ul')

	for _, skill in ipairs(skilllist) do
		if lvlreqs[skill] then
			skilltable
				:tag('li')
					:wikitext(skillreq(skill, lvlreqs[skill], true))
				:done()
		end
	end

	-- All quests required
	local questtable = ret
		:tag('table')
			:addClass('mw-collapsible')
			:css('background', 'none')
			:tag('tr')
				:tag('th')
					:css('text-align', 'left')
					:wikitext('Quests required:')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:addClass('qc-active')
					:tag('ul')

	for _, subquest in ipairs(subquests) do
		questtable
			:tag('li')
				:wikitext(subquest)
			:done()
	end

	-- All other miscellaneous requirements
	local othertable = ret
		:tag('table')
			:addClass('mw-collapsible')
			:css('background', 'none')
			:tag('tr')
				:tag('th')
					:css('text-align', 'left')
					:wikitext('Other:')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:tag('ul')

	for _, otherreq in ipairs(otherreqs) do
		othertable
			:tag('li')
				:wikitext(otherreq)
			:done()
	end

	return tostring(ret)
end

return p