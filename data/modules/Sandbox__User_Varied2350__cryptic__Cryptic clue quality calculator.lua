local p = {}

--[[
Attribution:
Initial copy of timings was based on this spreadsheet
https://docs.google.com/spreadsheets/d/1qCq-P0L9gKGYEtonvS8s0mTA9jcoupG6Xty1HvLZNww
]]

--[[
Main data structure containing each cryptic step, the amount of time the step
takes to complete (in ticks), along with any teleports required.

Future goals:
- Implement WikiSync level checking for steps that require/are sped up by shortcuts
- Implement linked steps for steps that can be completed faster when together
	(i.e. they are close to each other)

--]]
local stepQuality = require("Module:Sandbox/User:Varied2350/cryptic/Cryptic clue quality calculator/steps")
local fakeComma = '‚'

--[[
Data structure containing a variety of override times. If the order the steps are
completed in matters, ensure that the step that should be completed first
is the outer ID and the subsequent step ID is contained within it. Refer
to the required /steps module above to get the step ID
--]]
local overrides = {
	[5] = { -- Shhhh!
		[11] = { -- Darkness wanders around me
			timeTaken = 14
		}
	}
}

function p.buildTable()
	return _buildTable('Full table', stepQuality)
end

--[[
Build the main calculator config tag. Dynamically generate the select list
with each step text, replacing commas with '‚' to not break the calculator since
commas are used to separate each step in the list
]]
function p.buildCalcPre()
	-- build table from key values and sort
	local sorted = sortedSteps()
	
	
	local stepParamStr = ""
	for _,step in ipairs(sorted) do
		stepParamStr = stepParamStr .. ',' .. string.gsub(step.step, ",", fakeComma)
	end
	local formatted = string.format(
[[<pre class="jcConfig">
module = Sandbox/User:Varied2350/cryptic/Cryptic clue quality calculator
modulefunc = main
form = typein
result = tableout
param = currgroup|Current Steps:||group|step1,step2,step3
param = step1|Step 1|Select|select|Select%s
param = step2|Step 2|Select|select|Select%s
param = step3|Step 3|Select|select|Select%s
param = newgroup|New Steps:||group|newstep1,newstep2,newstep3
param = newstep1|New step 1|Select|select|Select%s
param = newstep2|New step 2|Select|select|Select%s
param = newstep3|New step 3|Select|select|Select%s
</pre>]], stepParamStr, stepParamStr, stepParamStr, stepParamStr, stepParamStr, stepParamStr)
	return formatted
end

function _buildTable(title, steps)
	-- create main wikitable to return
	local tab = mw.html.create('table'):addClass('wikitable sortable sticky-header align-center-1 align-center-3 align-center-4 align-center-5 align-right-6 align-right-7')
	tab:tag('tr')
		:tag('th'):wikitext('Step text')
		:tag('th'):wikitext('Time taken')
		:tag('th'):wikitext('Teleports used')
	
	-- iterate all possible cryptic steps
	for k,step in pairs(steps) do
		local itemStr = ''
		if step['routes'] ~= nil and #step['routes'] > 0 then
			for idx,itemReq in ipairs(step['routes']) do
				itemStr = itemStr .. parseStepItem(itemReq)
				if idx ~= #step['routes'] then
					itemStr = itemStr .. ','
				end
			end
		end
		tab:tag('tr')
			:tag('td'):wikitext(step['stepText'] or k)
			:tag('td'):wikitext(step['newTimeTaken'] or step['timeTaken'] or step['routes'][1]['timeTaken'])
			:tag('td'):wikitext(itemStr)
	end
	
	return tab
end

--[[
Format the step into a Plink style File tag
]]
function parseStepItem(stepItem)
	local baseStr = '[[File:' .. stepItem['name'] .. '.png'
	if stepItem['pic'] ~= nil then
		baseStr = baseStr .. '|pic=' .. stepItem['pic']
	end
	if stepItem['txt'] ~= nil then
		baseStr = baseStr .. ']][[' .. stepItem['name'] .. '|' .. stepItem['txt']
	end
	baseStr = baseStr .. ']] (' .. stepItem['timeTaken'] .. ')'
	
	return baseStr
end

function sortedSteps()
	local sorted = {}
	for step,stats in pairs(stepQuality) do
		table.insert(sorted, {step = step, stats = stats})
	end
	table.sort(sorted, function(a, b)
		local aTime = a.stats.timeTaken or (a.stats.routes and a.stats.routes[1] and a.stats.routes[1].timeTaken)
		local bTime = b.stats.timeTaken or (b.stats.routes and b.stats.routes[1] and b.stats.routes[1].timeTaken)
		return aTime < bTime
	end)
	return sorted
end

--[[
Filter the overrides table to only include ones that are applicable
to the cryptic steps given. Topologically sort it such that primary steps and
their linked secodary steps are completed in the required order using an implementation
of Kahn's algorithm

https://en.wikipedia.org/wiki/Topological_sorting#Kahn's_algorithm
]]
function sortStepsWithOverrides(steps, overrides)
	local byId = {}
	
	for stepText,step in pairs(steps) do
		step['stepText'] = stepText
		byId[step.id] = step
	end
	
	local dependents = {}
	local dependencyCount = {}
	
	-- filter overrides down to where primary and secondary IDs are both contained in the passed in list
	for firstStepId, subSteps in pairs(overrides) do
		if byId[firstStepId] then
			for subStepId, override in pairs(subSteps) do
				if byId[subStepId] then
					
					-- increment the count of steps this step depends on
					dependencyCount[subStepId] = (dependencyCount[subStepId] or 0) + 1
					
					-- add the secondary step to the list of dependents for the primary step
					dependents[firstStepId] = dependents[firstStepId] or {}
					table.insert(dependents[firstStepId], subStepId)
					
					-- override the timeTaken with the new timeTaken
					byId[subStepId]['newTimeTaken'] = override.timeTaken
				end
			end
		end
	end
	
	local queue = {}
	local queueHead = 1
	
	local independentSteps = {}
	local contiguousSteps = {}
	
	-- insert steps without any linked override steps at the end of the queue
	for _,step in pairs(steps) do
		local id = step.id
		if not dependencyCount[id] then
			if dependents[id] then
				table.insert(contiguousSteps, id)
				mw.log("Inserting contiguous step " .. step.id .. " into list.")
			else
				table.insert(independentSteps, id)
				mw.log("Inserting independent step " .. step.id .. " into list.")
			end
		end
	end
	
	for i = 1, #independentSteps do
		table.insert(queue, independentSteps[i])
	end
	for i = 1, #contiguousSteps do
		table.insert(queue, contiguousSteps[i])
	end
	
	local sorted = {}
	
	while queueHead <= #queue do
		local id = queue[queueHead]
		queueHead = queueHead + 1
		
		local step = byId[id]
		sorted[#sorted + 1] = step
		
		
		local children = dependents[id]
		if children then
			for i = 1, #children do
				local childId = children[i]
				-- decrement the count of steps this child depends on
				dependencyCount[childId] = dependencyCount[childId] - 1
				
				-- if it's no longer dependent on any steps, add it to the queue
				if dependencyCount[childId] == 0 then
					mw.log("Inserting step " .. childId .. " into list.")
					queue[#queue + 1] = childId
				end
			end
		end
	end
	return sorted
end

function p._main(args)
	local quality = 0
	local newquality = 0
	local oldsteps = {}
	local newsteps = {}
	
	-- Grab only the steps we need
	for i=1,3 do
		local stepTxt = string.gsub(args['step'..i], fakeComma, ",")
		oldsteps[stepTxt] = stepQuality[stepTxt]
		
		local newStepTxt = string.gsub(args['newstep'..i], fakeComma, ",")
		newsteps[newStepTxt] = stepQuality[newStepTxt]
	end
	
	-- Sort the steps into the order they must be completed in
	local sortedOldSteps = sortStepsWithOverrides(oldsteps, overrides)
	local sortedNewSteps = sortStepsWithOverrides(newsteps, overrides)
	
	-- add up timeTaken to determine quality
	for _,v in pairs(sortedOldSteps) do
		mw.log("Step")
		mw.logObject(v)
		quality = quality + tonumber(v['newTimeTaken'] or v['timeTaken'] or (v['routes'] and #v['routes'] > 0 and v['routes'][1]['timeTaken']) or 0)
	end
	for _,v in pairs(sortedNewSteps) do
		mw.logObject(sortedOldSteps)
		newquality = newquality + tonumber(v['newTimeTaken'] or v['timeTaken'] or (v['routes'] and #v['routes'] > 0 and v['routes'][1]['timeTaken']) or 0)
	end
	
	local resultDiv = mw.html.create('div')
	
	resultDiv:node(mw.html.create('p'):wikitext('Old Steps'))
	resultDiv:node(_buildTable('Old steps', sortedOldSteps))
	resultDiv:node(mw.html.create('p'):wikitext('New Steps'))
	resultDiv:node(_buildTable('New steps', sortedNewSteps))
	
	
	local returnStr = 'Your current 3 step should take ' .. tostring(quality) .. ' seconds to complete. '
	returnStr = returnStr .. 'Your new 3 step would take ' .. tostring(newquality) .. ' seconds to complete, '
	
	if newquality > quality then
		returnStr = returnStr .. 'which is ' .. newquality - quality .. ' seconds slower.'
	elseif newquality == quality then
		returnStr = returnStr .. 'which is equal to your current juggle clue.'
	else
		returnStr = returnStr .. 'which is ' .. quality - newquality .. ' seconds faster.'
	end
	
	resultDiv:node(returnStr)
	
	return resultDiv
end

--[[
Main function that grabs the frame args with a fallback to the parent frame args
in the event that they don't exist
]]
function p.main(frame)
	local args = frame.args or frame:getParent().args
	return p._main(args)
end

return p