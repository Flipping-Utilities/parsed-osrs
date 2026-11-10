require('strict')
require("Module:Mw.html extension")
local p = {}

local POINTS_BY_TIER = {
	easy = 10,
	medium = 30,
	hard = 80,
	elite = 200,
	master = 400,
}

function p.format_completion_pct(completion_percent)
	if (completion_percent ~= nil) then
		local sort_val = completion_percent
		local str_val = string.format("%s%%", completion_percent)
		local colour = ""
		if (completion_percent == 0) then
			colour = "red"
		elseif (completion_percent < 0.1) then
			str_val = string.format("%.2f%%", completion_percent)
			colour = "red"
		elseif (completion_percent < 1) then
			colour = "orange"
		elseif (completion_percent < 10) then
			colour = "yellow"
		elseif (completion_percent < 50) then
			colour = "green"
		elseif (completion_percent <= 100) then
			colour = "blue"
		end
		return str_val, sort_val, colour
	else
		return nil
	end
end

local function extractSkillSortValue(skillFilter, skillText) 
	 for skill, level, sort in string.gmatch(skillText or '', 'class="skillreq" data%-skill="([a-zA-Z %-]+)" data%-level="([0-9A-Za-z%.]+)" data%-sort%-value="([a-zA-Z0-9 ]+)"') do
	 	mw.log(skill, level, sort)
		if string.lower(skillFilter) == string.lower(skill) then
			return tonumber(level, 10) or sort
		end
	 end
	return nil
end

function p._main(args)
	local completion_percent = mw.loadJsonData("Module:Equilibrium League/Tasks/completion.json")
	local region_filter = args.region
	local tier_filter = args.tier
	local skill_filter = args.skill
	local clue_filter = args.clue
	local blessingTask = args.blessingTask
	
	local tbl = mw.html.create('table')
		:addClass('wikitable sortable lighttable leagues-table qc-active qc-wikisync sticky-header align-center-1 align-center-5 align-center-6')
		:tag('tr')
			:tag('th')
				:wikitext('Region')
				:css('width', '0%')
			:done()
			:tag('th')
				:wikitext('Task')
				:css('width', '25%')
			:done()
			:tag('th')
				:wikitext('Information')
				:css('width', '35%')
			:done()
			:tag('th')
				:wikitext('Requirements')
				:css('width', '40%')
			:done()
			:tag('th')
				:wikitext('Pts')
				:attr('data-sort-type', 'number')
				:css('width', '0%')
				:css('min-width', '60px')
			:done()
			:tag('th')
				:wikitext('<span class="hover-text" title="Estimated percentage of players who have completed each task, based on WikiSync crowdsourcing">Comp%</span>')
				:css('width', '0%')
			:done()
		:done()

	local query = bucket('equilibrium_league_task')
		.select('name', 'description', 'skill', 'other', 'tier', 'region', 'id', 'clue', "blessing_task")
		.orderBy('id', 'ASC')
		.limit(2000)

	if region_filter and region_filter ~= '' then
		query.where('region', region_filter)
	end

	if tier_filter and tier_filter ~= '' then
		query.where('tier', string.lower(tier_filter))
	end
	
	if skill_filter and skill_filter ~= '' then
		local condition = bucket.Or()
		for value in string.gmatch(skill_filter, '[^,]+') do
			local trimmed = mw.text.trim(string.lower(value))
			condition = bucket.Or(condition, {'uses_skill', trimmed})
		end
		query.where(condition)
	end
	
	if clue_filter and string.lower(clue_filter) == 'yes' then
		query.where('clue', 'yes')
	end

	if blessingTask ~= nil and blessingTask ~= '' then
		query = query.where('blessing_task', blessingTask)
	end

	local data = query.run()
	
	if #data == 0 then
		return 'No matching tasks found.'
	end

	local tableData = {}
	for _, result in ipairs(data) do
		local name = result.name or ''
		local description = result.description or ''
		local skill = result.skill or ''
		local other = result.other or ''
		local tier = (result.tier or ''):lower():gsub('^%l', string.upper)
		local region = (result.region or ''):lower():gsub('^%l', string.upper)
		local id = result.id
		local points = POINTS_BY_TIER[string.lower(tier)] or ''
		local comp_pct, comp_sort, comp_colour = p.format_completion_pct(completion_percent[id])

		local requirements
		local req_class = ''
		if skill ~= '' and other ~= '' then
			requirements = skill .. '<br>' .. other
		elseif skill ~= '' then
			requirements = skill
		elseif other ~= '' then
			requirements = other
		else
			requirements = 'N/A'
			req_class = 'table-na nohighlight'
		end

		if string.lower(blessingTask or '') ~= 'yes' and result.blessing_task and result.blessing_task:lower() == 'yes' then
			description = description .. '<br>[[File:Equilibrium_League_Blessing-icon.png|20x20px|link=Equilibrium League/Blessings]] This task earns progress towards [[Equilibrium League/Blessings|blessings]].'
		end
		
		local reqSortValue
		if skill_filter then
			reqSortValue = extractSkillSortValue(skill_filter, skill)
			mw.log(skill)
			mw.log(reqSortValue)
		end
		
		table.insert(tableData, {
			id = id,
			region = region,
			tier = tier,
			name = name,
			description = description,
			reqSortValue = reqSortValue,
			requirements = requirements,
			req_class = req_class,
			points = points,
			comp_pct = comp_pct,
			comp_colour = comp_colour,
		})
	end
	
	table.sort(tableData, function(a, b)
		if skill_filter and a.reqSortValue ~= b.reqSortValue then
			return (a.reqSortValue or -1) < (b.reqSortValue or -1)
		elseif a.points ~= b.points then
		  return a.points < b.points
		end
		return string.lower(a.name) < string.lower(b.name)
	end)
		
	for _, row in ipairs(tableData) do
		tbl:tag('tr')
			:attr('id', row.id or '')
			:attr('data-taskid', row.id or '')
			:attr('data-league-region-for-filtering', string.lower(row.region))
			:attr('data-tasktier', string.lower(row.tier))
			:tag('td')
				:attr('data-sort-value', row.region)
				:wikitext(string.format('[[File:%s League Region Badge.png|x30px|link=Equilibrium League/Regions/%s]]', row.region, row.region))
			:done()
			:tag('td')
				:wikitext(row.name)
			:done()
			:tag('td')
				:wikitext(row.description)
			:done()
			:tag('td')
				:attrIf(row.reqSortValue, 'data-sort-value', row.reqSortValue or -1)
				:wikitext(row.requirements)
				:addClass(row.req_class)
			:done()
			:tag('td')
				:attr('data-sort-value', row.points)
				:wikitext(string.format('[[File:Catalyst League tasks - %s.png|%s|15px|link=]] %s', row.tier, row.tier, row.points))
			:done()
			:tag('td')
				:IF(row.comp_pct == nil)
					:na()
					:attr('data-sort-value', -1)
				:ELSE()
					:wikitext(row.comp_pct or '')
					:addClassIf(row.comp_colour, 'table-bg-' .. (row.comp_colour or ''))
					:attrIf(row.comp_sort, 'data-sort-value', row.comp_sort or -1)
				:END()
			:done()
		:done()
	end

	return tostring(tbl)
end

function p.main(frame)
	local args = frame:getParent().args
	
	return p._main(args)
end

return p