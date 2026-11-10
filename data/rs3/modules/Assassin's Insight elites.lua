require('Module:Mw.html extension')
local ttools = require('Module:TableTools')
local lang = mw.language.getContentLanguage()
p = {}

function p.main(frame)
	
	local args = frame:getParent().args
	local query = bucket('infobox_monster')
		.select(
			'page_name',
			'page_name_sub',
			'slayer_experience',
			'league_region'
		)
		.limit(5000)
		.orderBy('page_name_sub')
		.where('Category:Elite spawns')
	
	local data = query.run()
	
	if #data == 0 then
		return 'No results'
	end
	
	local tbl = mw.html.create('table')
		:addClass('wikitable sortable align-center-4')
		:tr()
			:th('Name')
			:th('Slayer XP')
			:th('Boosted Slayer XP')
			:th('League region')
	
	local t = {}
	local orderedCols = { 'slayer_experience', 'league_region' }
		
	--Combine multiple instances of the same mob into one result
	for _, v in pairs(data) do
		local main_object = v.page_name
		t[main_object] = t[main_object] or {}

		-- Process columns' data
		for _, col in ipairs(orderedCols) do
			t[main_object][col] = t[main_object][col] or {}
			local val = v[col]
			if val then
				val = type(val) ~= 'table' and {val} or val
				for _, singleVal in pairs(val) do
					t[main_object][col][singleVal] = 1
				end
			end
		end
	
		--Mark pages with identical size and region among versions
		for k, v in pairs(t) do
			v['printed'] = false
			if ttools.size(v['slayer_experience']) <= 1 and ttools.size(v['league_region']) <= 1 then
				v['all_same'] = true
			else
				v['all_same'] = false
			end
		end
	
	end
		
	for k, v in pairs(data) do
		local main_object = v.page_name
		
		t_entry = t[main_object]
		
		if t_entry['all_same'] then
			if not t_entry['printed'] then
				
				tbl:tr()
					:td(string.format('[[%s]]', main_object))
					:td(lang:formatNum(v.slayer_experience))
					:td(lang:formatNum(v.slayer_experience*5))
					:td(leaguesArg(v.league_region))
				t_entry['printed'] = true
			end
		else
			
			tbl:tr()
				:td(string.format('[[%s]]', main_object))
				:td(lang:formatNum(v.slayer_experience))
				:td(lang:formatNum(v.slayer_experience*5))
				:td(leaguesArg(v.league_region))
		end
		
	end

	return tbl:allDone()

end

function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues._compact(region)
	end
end

return p