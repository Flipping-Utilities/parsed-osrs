require('Module:Mw.html extension')
local yesno = require('Module:Yesno')
local ttools = require('Module:TableTools')
p = {}

function p.main(frame)
	
	local args = frame:getParent().args
	local boss = args[1] or 'monsters'
	
	local loc_res = bucket.Or({'location_restriction', 'surface'}, {'location_restriction', bucket.Null()})
	
	local query = bucket('infobox_monster')
		.select(
			'page_name',
			'page_name_sub',
			'size',
			'league_region'
		)
		.where(bucket.Not('Category:Historical article'))
		.where(bucket.Not('Category:Recurring content'))
		.where(bucket.Not('Category:Faction PvP'))
		.where(bucket.Not('Category:Combat familiars'))
		.where(loc_res)
		.limit(5000)
		.orderBy('size', 'desc')
	
	query.where({'size','>',1})
	
	if boss == 'bosses' then
		query.where('Category:Bosses')
	elseif boss == 'minions' then
		query.where('Category:Boss minions')
	else
		query.where(bucket.Not('Category:Bosses'))
		query.where(bucket.Not('Category:Boss minions'))
	end
	
	local data = query.run()
	
	if #data == 0 then
		return 'No results'
	end
	
	local t = {}

	local tbl = mw.html.create('table')
		:addClass('wikitable sortable align-center-2 align-center-3')
		:tr()
			:th('Name')
			:th('Size')
			:th('Damage<br>boost')
			:th('League region')
	
	local t = {}
	local orderedCols = { 'size', 'league_region' }
		
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
			if ttools.size(v['size']) <= 1 and ttools.size(v['league_region']) <= 1 then
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
				
				mw.logObject(t_entry)
				
				local damage = (5 * v.size)
				
				tbl:tr()
					:td(string.format('[[%s]]', main_object))
					:td(string.format('%d × %d', v.size, v.size))
					:td(string.format('%s%%', damage))
					:td(leaguesArg(v.league_region))
				t_entry['printed'] = true
			end
		else
			
			local damage = (5 * v.size)
			
			tbl:tr()
				:td(string.format('[[%s]]', v.page_name_sub))
				:td(string.format('%d × %d', v.size, v.size))
				:td(string.format('%s%%', damage))
				:td(leaguesArg(v.league_region))
		end
		
	end

	return tbl:allDone()

end

function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end

return p