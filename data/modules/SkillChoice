--Quests are organised by least to most cumulative experience; quests with the same experience rewards are organised alphabetically--

local SCP = require('Module:SCP')._main
local commas = require('Module:Addcommas')._add
local p = {}

--
-- Example quest structure
-- name - Name of the quest
-- requirements - String list of skills required for the quest completion (see other examples for SCP usage)
-- rewards - Table of information in the following format: experience gained, number of times available, (optional) extra text to add to the base (See MM1 for reference)
-- restrictions - Any restrictions that are imposed for what the user can select (I.E. a skill level requirement or specific skills only)
-- notes - (optional) A reference note of details relating to a specific experience value gained (See MM1 for reference), generally used alongside the optional text in a reward table
--

local questList = {
	{
		name = 'X Marks the Spot',
		requirements = 'None',
		rewards = { 300, 1 },
		restrictions = 'None'
	},
	{
		name = 'Client of Kourend',
		requirements = 'None',
		rewards = { 500, 2 },
		restrictions = 'None'
	},
	{
		name = 'The Ides of Milk',
		requirements = 'None',
		rewards = { 1000, 1 },
		restrictions = 'Attack Strength Defence Magic Ranged Hitpoints Prayer'
	},
	{
		name = 'Fairytale II - Cure a Queen',
		requirements = string.format('%s, %s', SCP('Farming', '49'), SCP('Herblore', '57')),
		rewards = { 2500, 1 },
		restrictions = 30
	},
	{
		name = 'A Tail of Two Cats',
		requirements = 'None',
		rewards = { 2500, 2 },
		restrictions = 30
	},
	{
		name = 'The Great Brain Robbery',
		requirements = string.format('%s, %s, %s', SCP('Crafting', '16'), SCP('Construction', '30'), SCP('Prayer', '50')),
		rewards = { 5000, 1 },
		restrictions = 30
	},
	{
		name = 'King\'s Ransom',
		requirements = string.format('%s', SCP('Defence', '65')),
		rewards = { 5000, 1 },
		restrictions = 50
	},
	{
		name = 'Darkness of Hallowvale',
		requirements = string.format('%s, %s, %s, %s, %s, %s', SCP('Construction', '5'), SCP('Mining', '20'), SCP('Thieving', '22'), SCP('Crafting', '32'), SCP('Magic', '33'), SCP('Strength', '40')),
		rewards = { 2000, 3 },
		restrictions = 30
	},
	{
		name = 'A Taste of Hope',
		requirements = string.format('%s, %s, %s, %s, %s', SCP('Crafting', '48'), SCP('Herblore', '40'), SCP('Attack', '40'), SCP('Agility', '45'), SCP('Slayer', '38')),
		rewards = { 2500, 3 },
		restrictions = 35
	},
	{
		name = 'The Tourist Trap',
		requirements = string.format('%s, %s', SCP('Fletching', '10'), SCP('Smithing', '20')),
		rewards = { 4650, 2 },
		restrictions = 'Agility Fletching Smithing Thieving'
	},
	{
		name = 'A Kingdom Divided',
		requirements = string.format('%s, %s, %s, %s, %s,<br/>%s, %s', SCP('Agility', '54'), SCP('Thieving', '52'), SCP('Woodcutting', '52'), SCP('Herblore', '50'), SCP('Mining', '42'), SCP('Crafting', '38'), SCP('Magic', '35')),
		rewards = { 10000, 2 },
		restrictions = 40
	},
	{
		name = 'In Search of Knowledge',
		requirements = 'None',
		rewards = { 10000, 1 },
		restrictions = 40,
		qualifier = '([[Miniquests|miniquest]])'
	},
	{
		name = 'Curse of the Empty Lord',
		requirements = string.format("Some players will need %s", SCP('Prayer', '31')),
		rewards = { 10000, 1 },
		restrictions = 50,
		qualifier = '([[Miniquests|miniquest]])'
	},
	{
		name = 'Shadow of the Storm',
		requirements = string.format('%s', SCP('Crafting', '30')),
		rewards = { 10000, 1 },
		restrictions = 'Attack Strength Defence Magic Ranged Hitpoints'
	},
	{
		name = 'Contact!',
		requirements = 'None',
		rewards = { 7000, 2 },
		restrictions = 'Attack Strength Defence Magic Ranged Hitpoints'
	},
	{
		name = 'Dream Mentor',
		requirements = string.format('%s, %s, %s, %s, %s,<br/>%s, %s, %s, %s', SCP('Agility', '32'), SCP('Combat', '85'), SCP('Crafting', '61'), SCP('Defence', '40'), SCP('Firemaking', '49'), SCP('Herblore', '5'), SCP('Magic', '65'), SCP('Mining', '60'), SCP('Woodcutting', '55')),
		rewards = { 15000, 1 },
		restrictions = 'Strength Defence Magic Ranged Hitpoints'
	},
	{
		name = 'The Fremennik Isles',
		requirements = string.format('%s, %s', SCP('Construction', '20'), SCP('Agility', '40')),
		rewards = { 10000, 2 },
		restrictions = 'Attack Strength Defence Hitpoints'
	},
	{
		name = 'A Night at the Theatre',
		requirements = string.format('%s recommended', SCP('Combat', '90')),
		rewards = { 20000, 4 },
		restrictions = 'Attack Strength Defence Magic Ranged Hitpoints',
		notes = 'The chosen skill must be at least level 50'
		
	},
	{
		name = 'One Small Favour',
		requirements = string.format('%s, %s, %s, %s', SCP('Agility', '36'), SCP('Crafting', '25'), SCP('Herblore', '18'), SCP('Smithing', '30')),
		rewards = { 10000, 2 },
		restrictions = 30
	},
	{
		name = 'Recipe for Disaster',
		requirements = string.format('%s, %s, %s, %s, %s,<br/>%s, %s, %s, %s, %s,<br/>%s, %s, %s, %s, %s', SCP('Quest', '175'), SCP('Cooking', '70'), SCP('Agility', '48'), SCP('Mining', '50'), SCP('Fishing', '53'), SCP('Thieving', '53'), SCP('Herblore', '25'), SCP('Magic', '59'), SCP('Smithing', '40'), SCP('Firemaking', '50'), SCP('Ranged', '40'), SCP('Crafting', '40'), SCP('Fletching', '10'), SCP('Slayer', '10'), SCP('Woodcutting', '36')),
		rewards = { 20000, 1 },
		restrictions = 50,
		qualifier = '([[Recipe for Disaster/Defeating the Culinaromancer|The final battle]])'
	},
	{
		name = 'Legends\' Quest',
		requirements = string.format('%s, %s, %s, %s, %s, %s,<br/>%s, %s, %s, %s, %s', SCP('Quest', '107'), SCP('Agility', '50'), SCP('Crafting', '50'), SCP('Herblore', '45'), SCP('Magic', '56'), SCP('Mining', '52'), SCP('Prayer', '42'), SCP('Smithing', '50'), SCP('Strength', '50'), SCP('Thieving', '50'), SCP('Woodcutting', '50')),
		rewards = { 30000, 4 },
		restrictions = 'Attack Strength Defence Magic Hitpoints Prayer <br/> Woodcutting Crafting Smithing Herblore Agility Thieving'
	},
	{
		name = 'Monkey Madness I',
		requirements = 'None',
		rewards = { 35000, 1, '& 20,000' },
		restrictions = 'Attack Strength Defence Hitpoints',
		notes = '35,000 experience is granted to the chosen pair of skills, and 20,000 is granted to the pair of skills not chosen.'
	},
	{
		name = 'Sins of the Father',
		requirements = string.format('%s, %s, %s, %s, %s, %s, %s', SCP('Woodcutting', '62'), SCP('Fletching', '60'), SCP('Crafting', '56'), SCP('Agility', '52'), SCP('Slayer', '50'), SCP('Attack', '50'), SCP('Magic', '49')),
		rewards = { 15000, 6 },
		restrictions = 60
	},
	{
		name = 'Dragon Slayer II',
		requirements = string.format('%s, %s, %s, %s, %s,<br/>%s, %s, %s, %s', SCP('Quest', '200'), SCP('Magic', '75'), SCP('Smithing', '70'), SCP('Mining', '68'), SCP('Crafting', '62'), SCP('Agility', '60'), SCP('Thieving', '60'), SCP('Construction', '50'), SCP('Hitpoints', '50')),
		rewards = { 25000, 4 },
		restrictions = 'Attack Strength Defence Magic Ranged Hitpoints'
	},
	{
		name = 'Into the Tombs',
		requirements = string.format('%s recommended', SCP('Combat', '95')),
		rewards = { 50000, 1 },
		restrictions = 'Attack Strength Defence Magic Ranged Hitpoints',
		qualifier = '([[Miniquests|miniquest]])'
	},
	{
		name = 'The Final Dawn',
		requirements = string.format('%s, %s, %s, %s recommended', SCP('Thieving', '66'), SCP('Runecraft', '52'), SCP('Fletching','52'), SCP('Combat', '85')),
		rewards = { 55000, 1 },
		restrictions = 'Attack Strength Defence Magic Ranged Hitpoints Prayer',
	},
	{
		name = 'Monkey Madness II',
		requirements = string.format('%s, %s, %s, %s, %s, %s', SCP('Slayer', '69'), SCP('Crafting', '70'), SCP('Hunter', '60'), SCP('Agility', '55'), SCP('Thieving', '55'), SCP('Firemaking', '60')),
		rewards = { 50000, 2 },
		restrictions = 'Attack Strength Defence Magic Ranged Hitpoints'
	},
	{
		name = 'Desert Treasure II - The Fallen Empire',
		requirements = string.format('%s, %s, %s, %s, %s, %s', SCP('Firemaking', '75'), SCP('Magic', '75'), SCP('Thieving', '70'), SCP('Herblore', '62'), SCP('Runecraft', '60'), SCP('Construction', '60')),
		rewards = { 100000, 3 },
		restrictions = 'Attack Strength Defence Magic Ranged Hitpoints Prayer'
	}
}

function p.invoke_main(frame)
	return p.main(frame, frame:getParent().args[1])
end

function p.main(frame, skill)
	local totalXp = 0
	local resultsTable = mw.html.create('table')
	local header = mw.html.create('tr')
		header:tag('th')
			:wikitext('Quest')
		:done()
		:tag('th')
			:attr('data-sort-type', 'number')
			:wikitext('Experience<br/>reward')
		:done()
		:tag('th')
			:addClass('unsortable')
			:wikitext('Skills available')
		:done()
		:tag('th')
			:addClass('unsortable')
			:wikitext('Skill requirements')
		:done()
	
	resultsTable:addClass('wikitable sortable qc-active lighttable oqg-table'):css('text-align', 'center')
		:node(header)
	:done()
	
	for i, v in ipairs(questList) do
		local skill_restrictions = ''
		local valid_skill = false

		-- Restrictions --
		if type(v.restrictions) == 'number' then
			--Skills of certain level are eligible--
			skill_restrictions = string.format('Any skill above %s', v.restrictions)
			valid_skill = true
		else 
			for sk in string.gmatch(v.restrictions, "[%a%p]+") do
				-- Any skill is eligible -- 
				if sk == 'None' then
					skill_restrictions = 'Any'
					valid_skill = true
				elseif sk == '<br/>' then
					skill_restrictions = skill_restrictions .. (sk)
				-- Specific skills are eligible --
				else  
    				skill_restrictions = skill_restrictions .. SCP(sk)
    				if sk == skill or skill == 'Any' then
    					valid_skill = true
    				end
    			end
			end
		end
		
		-- Only gets quest info if skill is eligible --
		if valid_skill == true then
			local quest = mw.html.create('tr')
			
			-- Quest name --
			if v.qualifier then
				quest:tag('td')
					:wikitext(string.format('[[%s]]<br />%s', v.name, v.qualifier))
				:done()	
			else
			quest:tag('td')
				:wikitext(string.format('[[%s]]', v.name))
			:done()
			end
			
			-- Rewards --
			if v.notes then 
				local extraReward = v.rewards[3] ~= nil and string.format(' %s', v.rewards[3]) or ''
				local reference = frame:extensionTag{ name='ref', content = v.notes, args = { group='sc' } }
				-- Need preprocess to deal with ref tag in MM1's v.notes--
				quest:tag('td')
					:wikitext(commas(v.rewards[1]) .. rewardModifier(v.rewards[2]) .. extraReward .. reference)
				:done()
			else
				quest:tag('td')
					:wikitext(commas(v.rewards[1]) .. rewardModifier(v.rewards[2]))
				:done()
			end
			
			-- Skill restrictions and quest requirements --
			quest:tag('td')
				:wikitext(skill_restrictions)
			:done()
			:tag('td')
				:wikitext(v.requirements)
			:done()
				
			-- Inserts info to table --
			totalXp = totalXp + (v.rewards[1] * v.rewards[2])
			resultsTable:node(quest)
			:done()		
		end
	end
	
	-- Inserts total xp --
	total = mw.html.create('tr')
	total:tag('th')
			:wikitext('Total')
		:done()
		:tag('th')
			:wikitext(commas(totalXp))
		:done()
		:tag('th')
			:attr('colspan', '2')
			:wikitext('')
		:done()
		
	resultsTable:node(total)
	
	return tostring(resultsTable) .. '\n' .. frame:extensionTag{ name='references', args = { group='sc' } }
end

function rewardModifier(reward)
	if reward == 2 then
		return ' twice'
	elseif reward == 3 then
		return ' three times'
	elseif reward == 4 then
		return ' four times'
	elseif reward == 5 then
		return ' five times'
	elseif reward == 6 then
		return ' six times'
	else
		return ''
	end
end

return p