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

--[[
Data structure containing a variety of override types. Can be of type:
- "linked": allow two steps to be combined for a new improved quality
- "req": a requirement to improve the speed required
--]]
local overrides = {
	{
		
	}
}

function p.buildTable()
	return _buildTable('full', nil)
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
		stepParamStr = stepParamStr .. ',' .. string.gsub(step.step, ",", "‚")
	end
	local formatted = string.format(
[[<pre class="jcConfig">
module = Sandbox/User:Varied2350/cryptic/Cryptic clue quality calculator
modulefunc = main
form = typein
result = tableout
param = currgroup|Current Steps:||group|stepone,steptwo,stepthree
param = stepone|Step 1|Select|select|Select%s
param = steptwo|Step 2|Select|select|Select%s
param = stepthree|Step 3|Select|select|Select%s
param = newgroup|New Steps:||group|newstepone,newsteptwo,newstepthree
param = newstepone|New step 1|Select|select|Select%s
param = newsteptwo|New step 2|Select|select|Select%s
param = newstepthree|New step 3|Select|select|Select%s
</pre>]], stepParamStr, stepParamStr, stepParamStr, stepParamStr, stepParamStr, stepParamStr)
	return formatted
end

function _buildTable(tableType, args)
	-- create main wikitable to return
	local tab = mw.html.create('table'):addClass('wikitable sortable sticky-header align-center-1 align-center-3 align-center-4 align-center-5 align-right-6 align-right-7')
	tab:tag('tr')
		:tag('th'):wikitext('Step text')
		:tag('th'):wikitext('Time taken')
		:tag('th'):wikitext('Teleports used')
		
	local sorted = sortedSteps()
	
	-- iterate all possible cryptic steps
	for _,step in ipairs(sorted) do
		if tableType == 'full' or _isArgsStep(tableType, args, step['step']) then
			local itemStr = ''
			if step.stats['routes'] ~= nil and #step.stats['routes'] > 0 then
				for idx,itemReq in ipairs(step.stats['routes']) do
					itemStr = itemStr .. parseStepItem(itemReq)
					if idx ~= #step.stats['routes'] then
						itemStr = itemStr .. ','
					end
				end
			end
			tab:tag('tr')
				:tag('td'):wikitext(step.step)
				:tag('td'):wikitext(step.stats['timeTaken'] or step.stats['routes'][1]['timeTaken'])
				:tag('td'):wikitext(itemStr)
		end
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
		baseStr = baseStr .. '|txt=' .. stepItem['txt']
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
Determine if the given step is one of the steps set in the args based on step type
full	= always true, used for building the full step table display
old		= true if the step given is specified as one of the currently owned steps
new		= true if the step given is specified as one of the new steps to compare to
]]
function _isArgsStep(stepType, args, step)
	-- replace comma with visually similar character to not break calc functionality
	local replaced = string.gsub(step, ",", "‚")
	if stepType == 'full' then
		return true
	elseif stepType == 'old' then
		return replaced == args['stepone'] or replaced == args['steptwo'] or replaced == args['stepthree']
	else
		return replaced == args['newstepone'] or replaced == args['newsteptwo'] or replaced == args['newstepthree']
	end
end

function p._main(args)
	local quality = 0
	local newquality = 0
	
	-- iterate all cryptic steps
	for step,stats in pairs(stepQuality) do
		mw.logObject(step)
		mw.logObject(stats)
		-- old step, track current 3-step quality
		if _isArgsStep('old', args, step) then
			quality = quality + tonumber(stats['timeTaken'] or stats['routes'][1]['timeTaken'])
		end
		-- new step, track new 3-step quality
		if _isArgsStep('new', args, step) then
			newquality = newquality + tonumber(stats['timeTaken'] or stats['routes'][1]['timeTaken'])
		end
	end
	local resultDiv = mw.html.create('div')
	
	resultDiv:node(mw.html.create('p'):wikitext('Old Steps'))
	resultDiv:node(_buildTable('old', args))
	resultDiv:node(mw.html.create('p'):wikitext('New Steps'))
	resultDiv:node(_buildTable('new', args))
	
	
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