require('strict')
local p = {}

local POINTS_BY_TIER = {
	easy = 10,
	medium = 30,
	hard = 80,
	elite = 200,
	master = 400,
}

function p._main(args)
	local region_filter = args.region
	local tier_filter = args.tier
	local skill_filter = args.skill
	local clue_filter = args.clue
	
	local tbl = mw.html.create('table')
		:addClass('wikitable sortable lighttable leagues-table qc-active sticky-header align-center-1 align-center-5 align-center-6')
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
		:done()

	local query = bucket('equilibrium_league_task')
		.select('name', 'description', 'skill', 'other', 'tier', 'region', 'id', 'clue')
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

	local data = query.run()
	
	if #data == 0 then
		return 'No matching tasks found.'
	end

	for _, result in ipairs(data) do
		local name = result.name or ''
		local description = result.description or ''
		local skill = result.skill or ''
		local other = result.other or ''
		local tier = (result.tier or ''):lower():gsub('^%l', string.upper)
		local region = (result.region or ''):lower():gsub('^%l', string.upper)
		local id = result.id
		local points = POINTS_BY_TIER[string.lower(tier)] or ''

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
		
		tbl:tag('tr')
			:attr('id', id or '')
			:attr('data-taskid', id or '')
			:attr('data-league-region-for-filtering', string.lower(region))
			:attr('data-tasktier', string.lower(tier))
			:tag('td')
				:attr('data-sort-value', region)
				:wikitext(string.format('[[File:%s League Region Badge.png|x30px|link=Equilibrium League/Regions/%s]]', region, region))
			:done()
			:tag('td')
				:wikitext(name)
			:done()
			:tag('td')
				:wikitext(description)
			:done()
			:tag('td')
				:wikitext(requirements)
				:addClass(req_class)
			:done()
			:tag('td')
				:attr('data-sort-value', points)
				:wikitext(string.format('[[File:Catalyst League tasks - %s.png|%s|15px|link=]] %s', tier, tier, points))
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