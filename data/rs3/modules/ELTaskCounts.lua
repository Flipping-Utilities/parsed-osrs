require('strict')
local commas = require('Module:Addcommas')
local p = {}

local POINTS_BY_TIER = {
	easy = 10,
	medium = 30,
	hard = 80,
	elite = 200,
	master = 400,
}

local REGIONS = {
	"global",
	"misthalin",
	"havenhythe",
	"karamja",
	"anachronia",
	"asgarnia",
	"desert",
	"fremennik",
	"kandarin",
	"morytania",
	"tirannwn",
	"wilderness"
}

function p._main(args)
	local skill_filter = args.skill
	local clue_filter = args.clue
	local blessing_filter = args.blessingTask
	
	local tbl = mw.html.create('table')
		:addClass('wikitable leagues-wikisync-filter sortable align-left-2')
		:tag('tr')
			:tag('th')
			    :wikitext('[[File:Equilibrium League small icon.png|20px|link=|Equilibrium League preferences]]')
				:addClass('league-int-button unsortable noviewer')
			:done()
			:tag('th')
				:wikitext('Region')
			:done()
			:tag('th')
				:wikitext('Easy')
			:done()
			:tag('th')
				:wikitext('Medium')
			:done()
			:tag('th')
				:wikitext('Hard')
			:done()
			:tag('th')
				:wikitext('Elite')
			:done()
			:tag('th')
				:wikitext('Master')
			:done()
			:tag('th')
				:wikitext('Total tasks')
			:done()
			:tag('th')
				:wikitext('Total points')
			:done()
		:done()

	local query = bucket('equilibrium_league_task')
		.select('tier', 'region', 'clue', 'blessing_task')
		.limit(2000)
	
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
    
    if blessing_filter and blessing_filter ~= '' then
    	query.where('blessing_task', blessing_filter)
    end

	local data = query.run()
	
	if #data == 0 then
		return 'No matching tasks found.'
	end
	
	local regionCounts = {}

	for _, result in ipairs(data) do
		local tier = (result.tier or ''):lower()
		local region = (result.region or ''):lower()
		
		if regionCounts[region] == nil then
			regionCounts[region] = {}
		end
		
		if regionCounts[region][tier] == nil then
			regionCounts[region][tier] = 0
		end
		
		regionCounts[region][tier] = regionCounts[region][tier] + 1
	end
	
	mw.logObject(regionCounts)
	
	local regionTotals = {
		easy = 0,
		medium = 0,
		hard = 0,
		elite = 0,
		master = 0
	}
	
	-- leagueCounts is region -> tier -> numTasks
	for _, region in ipairs(REGIONS) do 
		local counts = regionCounts[region] or {}
		
		local easyCounts = counts.easy or 0
		local mediumCounts = counts.medium or 0
		local hardCounts = counts.hard or 0
		local eliteCounts = counts.elite or 0
		local masterCounts = counts.master or 0
		local totalCounts = easyCounts + mediumCounts + hardCounts + eliteCounts + masterCounts
		local totalPoints = 
			easyCounts * POINTS_BY_TIER.easy +
			mediumCounts * POINTS_BY_TIER.medium +
			hardCounts * POINTS_BY_TIER.hard +
			eliteCounts * POINTS_BY_TIER.elite +
			masterCounts * POINTS_BY_TIER.master
			
		regionTotals.easy = regionTotals.easy + easyCounts
		regionTotals.medium = regionTotals.medium + mediumCounts
		regionTotals.hard = regionTotals.hard + hardCounts
		regionTotals.elite = regionTotals.elite + eliteCounts
		regionTotals.master = regionTotals.master + masterCounts
		
		tbl:tag('tr')
			:tag('td')
				:addClass('league-wikisync-filter-cell')
				:attr('data-league-region', region)
			:done()
			:tag('td')
				:wikitext(string.format('[[File:%s League Region Badge.png|x30px|link=Equilibrium League/Regions/%s]]', region:gsub('^%l', string.upper), region:gsub('^%l', string.upper)))
			:done()
			:tag('td')
				:wikitext(commas._add(easyCounts))
			:done()
			:tag('td')
				:wikitext(commas._add(mediumCounts))
			:done()
			:tag('td')
				:wikitext(commas._add(hardCounts))
			:done()
			:tag('td')
				:wikitext(commas._add(eliteCounts))
			:done()
			:tag('td')
				:wikitext(commas._add(masterCounts))
			:done()
			:tag('td')
				:wikitext(commas._add(totalCounts))
			:done()
			:tag('td')
				:wikitext(commas._add(totalPoints))
			:done()
		:done()
	end
	
	local allTotalCounts = regionTotals.easy + regionTotals.medium + regionTotals.hard + regionTotals.elite + regionTotals.master
	local allTotalPoints = 
		regionTotals.easy * POINTS_BY_TIER.easy +
		regionTotals.medium * POINTS_BY_TIER.medium +
		regionTotals.hard * POINTS_BY_TIER.hard +
		regionTotals.elite * POINTS_BY_TIER.elite +
		regionTotals.master * POINTS_BY_TIER.master
	
	
	tbl:tag('tr')
		:tag('th')
			:attr('colspan', 2)
			:wikitext('Total (Selected)')
		:done()
		:tag('th')
			:wikitext(commas._add(regionTotals.easy))
			:attr('data-wikisync-total-column', 2)
		:done()
		:tag('th')
			:wikitext(commas._add(regionTotals.medium))
			:attr('data-wikisync-total-column', 3)
		:done()
		:tag('th')
			:wikitext(commas._add(regionTotals.hard))
			:attr('data-wikisync-total-column', 4)
		:done()
		:tag('th')
			:wikitext(commas._add(regionTotals.elite))
			:attr('data-wikisync-total-column', 5)
		:done()
		:tag('th')
			:wikitext(commas._add(regionTotals.master))
			:attr('data-wikisync-total-column', 6)
		:done()
		:tag('th')
			:wikitext(commas._add(allTotalCounts))
			:attr('data-wikisync-total-column', 7)
		:done()
		:tag('th')
			:wikitext(commas._add(allTotalPoints))
			:attr('data-wikisync-total-column', 8)
		:done()
		

	return tostring(tbl)
end

function p.main(frame)
	local args = frame:getParent().args
	
	return p._main(args)
end

return p