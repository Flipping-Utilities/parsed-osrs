require('strict')

local p = {}
local round = require('Module:Number')._round
local _coins = require('Module:Currency')._amount

-- funcs from [[Module:Mmgtable]]
local function sigfig(x, p)
	local x_sign = x < 0 and '-1' or '1'
	local x = math.abs(x)
	if x == 0 then
		return 0
	end
	local n = math.floor(math.log10(x)) + 1 - p
	return tonumber(x_sign) * math.pow(10,n) * round(x/math.pow(10, n), 0)
end

local function autoround(x, f)
	x = tonumber(x) or 0
	local _x
	if x < 0.1 and x > -0.1 then
		_x = sigfig(x,2)
	elseif x >= 100 or x <= -100 then
		_x = round(x, 0)
	else
		_x = round(x, 2)
	end
	if f then
		return lang:formatNum(_x)
	end
	return _x
end

local function loadData(args)
	local pages = {}
	for _, v in ipairs(args) do
		table.insert(pages, {'page_name', 'Money making guide/' .. v})
	end
	
	local b = bucket('money_making_guide')
		.select('page_name', 'json', 'Category:Obsolete money making guides')
		.where(bucket.Or(pages))
	
	local t1 = os.clock()
	local data = b.run()
	local t2 = os.clock()
	
	assert(data ~= nil and #data > 0, 'Bucket query failed')
	mw.log( string.format('HasMMG table Bucket: entries %d, time elapsed: %.3f ms.', #data, (t2 - t1) * 1000) )
	
	return data
end

local function addtblrow(row, page, price, skill)
	row:tag('tr')
		:tag('td')
			:wikitext('[[' .. page .. '|' .. page:gsub('Money making guide/', '') .. ']]')
			:done()
		:tag('td')
			:tag('span')
				:addClass('coins')
				:wikitext( _coins( autoround(price) , 'nocoins') )
				:done()
			:done()
		:tag('td')
			:addClass('plainlist')
			:wikitext('\n' .. skill)
			:done()
		:done()
end

local function convertSkillHTMLToTable(skillHTML)
	local newTable = {}
	
	-- Go over the skill html to take the skill names/levels out (we should maybe do this in the bucket code to save it for anyone to use?)
	for line in skillHTML:gmatch("([^\n]*)\n?") do
		local skillName = string.match(line, 'data%-skill%=%"(.-)%"')
		local skillLevel = tonumber(string.match(line, 'data%-level%=%"(.-)%"'))
		
		if skillName ~= nil and skillLevel ~= nil then
			newTable[string.lower(skillName)] = skillLevel
		end
	end
	
	return newTable
end

function p._main(args)
	local tbl = mw.html.create('table'):addClass('wikitable align-right-2')
	local cats = ''
	local normalmmg, recurringmmg = false, false
	local normalrows, recurringrows = mw.html.create(''), mw.html.create('')
	local numMethods = 0
	
	-- Decode them into tables so we can sort the tables first
	local normalMethods = {}
	local recurringMethods = {}
	
	for _, v in ipairs(loadData(args)) do
		v.data = mw.text.jsonDecode(v.json)
		
		if v.data.prices.default_value then
			if not normalmmg then
				normalmmg = true
			end
			numMethods = numMethods + 1
			
			table.insert(normalMethods, v)
		elseif v.data.prices.value then
			if not recurringmmg then
				recurringmmg = true
			end
			numMethods = numMethods + 1
			
			table.insert(recurringMethods, v)
		end
	end
	
	local orderString = ""
	
	if args.sort ~= nil then
		local sortLower = string.lower(args.sort)
		
		if sortLower == "profit" then
			if args.order ~= nil and string.lower(args.order) == "asc" then
				table.sort(normalMethods, function(a, b)
				  return a.data.prices.default_value < b.data.prices.default_value
				end)
				
				table.sort(recurringMethods, function(a, b)
				  return a.data.prices.value < b.data.prices.value
				end)
			else
				-- Nothing specified or anything other than asc will order descending profit
				table.sort(normalMethods, function(a, b)
				  return a.data.prices.default_value > b.data.prices.default_value
				end)
				
				table.sort(recurringMethods, function(a, b)
				  return a.data.prices.value > b.data.prices.value
				end)
			end
			
			orderString = ", ordered by Profit"
		else
			local foundSkillMatch = false
			
			for i, v in ipairs(normalMethods) do
				normalMethods[i].skillRequirement = convertSkillHTMLToTable(v.data.skill)
				if foundSkillMatch == false and normalMethods[i].skillRequirement[sortLower] ~= nil then foundSkillMatch = true end
			end
			
			for i, v in ipairs(recurringMethods) do
				recurringMethods[i].skillRequirement = convertSkillHTMLToTable(v.data.skill)
				if foundSkillMatch == false and normalMethods[i].skillRequirement[sortLower] ~= nil then foundSkillMatch = true end
			end
			
			mw.logObject(normalMethods)
			
			if foundSkillMatch then
				local function descSort(t)
						table.sort(t, function(a, b)
						if a.skillRequirement[sortLower] == nil then return false end
						if b.skillRequirement[sortLower] == nil then return true end
						return a.skillRequirement[sortLower] > b.skillRequirement[sortLower]
					end)
				end
				
				local function ascSort(t)
						table.sort(t, function(a, b)
						if a.skillRequirement[sortLower] == nil then return true end
						if b.skillRequirement[sortLower] == nil then return false end
						return a.skillRequirement[sortLower] < b.skillRequirement[sortLower]
					end)
				end
				
				if args.order ~= nil and string.lower(args.order) == "desc" then
					descSort(normalMethods)
					descSort(recurringMethods)
				else
					ascSort(normalMethods)
					ascSort(recurringMethods)
				end
				
				orderString = string.format(", ordered by %s level", sortLower:gsub("^%l", string.upper))
			end
		end
	end
	
	for _, v in ipairs(normalMethods) do
		addtblrow(normalrows, v.page_name, v.data.prices.default_value, v.data.skill)
		
		if v['Category:Obsolete money making guides'] or
			v.data.prices.default_value <= 100000 and v.data.members or
			v.data.prices.default_value <= 20000 then
			cats = cats .. '[[Category:Pages with obsolete money making guides listed]]'
		end
	end
	
	for _, v in ipairs(recurringMethods) do
		addtblrow(recurringrows, v.page_name, v.data.prices.value, v.data.skill)
		
		if v.data.prices.value <= 0 then
			cats = cats .. '[[Category:Pages with obsolete money making guides listed]]'
		end
	end
	
	if normalmmg then
		tbl:tag('tr')
			:tag('th')
				:wikitext('Method')
			:done()
			:tag('th')
				:wikitext('Hourly profit')
			:done()
			:tag('th')
				:wikitext('Skills')
			:done()
		:done()
		:node(normalrows)
	end
	
	if recurringmmg then
		tbl:tag('tr')
			:tag('th')
				:wikitext('Method')
			:done()
			:tag('th')
				:wikitext('Profit per instance')
			:done()
			:tag('th')
				:wikitext('Skills')
			:done()
		:done()
		:node(recurringrows)
	end
	
	local str = string.format('<p>The following [[money making guide]]%s %s available for %s%s:</p>',
		(numMethods >= 2 and 's' or ''),
		(numMethods >= 2 and 'are' or 'is'),
		(args.mobname or mw.title.getCurrentTitle().text),
		orderString
	)
	
	return str .. tostring( tbl ) .. cats
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

return p