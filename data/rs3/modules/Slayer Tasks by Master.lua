require("strict")
require('Module:Mw.html extension')
local sc = require('Module:Skill clickpic')._main
local slayer_disambig = require('Module:Slayer assignments/disambig').disambig
local round = require("Module:Round").round

local p = {}

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

function p._main(args)
	local master = args[1] or ''
	local results = p.get_results(master)
	results = p.format_results(results)
	
	return p.display_results(results, master)
end

function p.get_results(master)
	local results = require(('Module:Slayer assignments/%s'):format(master))

	return results
end

local function pcall_greater(a, b)
	if type(a) ~= 'number' or type(b) ~= 'number' then
		return false
	else
		return a > b
	end
end

local function pcall_lesser(a, b)
	if type(a) ~= 'number' or type(b) ~= 'number' then
		return false
	else
		return a < b
	end
end

function p.format_results(results)
	local out = {}
	
	for cat, params in pairs(results) do
		local temp = {}
		temp.name = cat
		temp.params = params
		
		local data = bucket('infobox_monster')
			.select(
				'page_name',
				'page_name_sub',
				'combat_level',
				'slayer_level',
				'slayer_experience',
				'life_points',
				'weakness_text',
				'susceptible_to',
				'slayer_category'
			)
			.where('slayer_category', cat)
			.where(bucket.Or({'location_restriction',bucket.Null()},{'location_restriction','!=','removed'}))
			.limit(5000)
			.orderBy('combat_level', 'asc')
			.run()
			
		temp.combat_level_min = 999999
		temp.combat_level_max = 0
		temp.slayer_experience_min = 999999
		temp.slayer_experience_max = 0
		
		for _,d in ipairs(data) do
			if pcall_lesser(d.combat_level, temp.combat_level_min) then
				temp.combat_level_min = d.combat_level
				temp.combat_level_min_enemy = d.page_name_sub
			end
			if pcall_greater(d.combat_level, temp.combat_level_max) then
				temp.combat_level_max = d.combat_level
				temp.combat_level_max_enemy = d.page_name_sub
			end
			
			if pcall_lesser(d.slayer_experience, temp.slayer_experience_min) then
				temp.slayer_experience_min = d.slayer_experience
				temp.slayer_experience_min_enemy = d.page_name_sub
			end
			if pcall_greater(d.slayer_experience, temp.slayer_experience_max) then
				temp.slayer_experience_max = d.slayer_experience
				temp.slayer_experience_max_enemy = d.page_name_sub
			end
		end
		
		table.insert(out, temp)
	end
	
	table.sort(out, function(a, b) return a.name < b.name end)
	return out
end

function p.display_results(results, master)
	local function minMaxCols(res, key_prefix, num_dps)
		local val_min = round(res[key_prefix .. "_min"] or 0, num_dps, true)
		local val_min_enemy = res[key_prefix .. "_min_enemy"]
		local val_max = round(res[key_prefix .. "_max"] or 0, num_dps, true)
		local val_max_enemy = res[key_prefix .. "_max_enemy"]
		local result = mw.html.create()
		
		if val_min == val_max then
			result
				:td{
					val_min_enemy and ('[[%s|%s]]'):format(val_min_enemy, val_min) or val_min,
					attr = { colspan = '2', align = 'center' }
				}
		else
			result
				:td(val_min_enemy and ('[[%s|%s]]'):format(val_min_enemy, val_min) or val_min)
				:td(val_max_enemy and ('[[%s|%s]]'):format(val_max_enemy, val_max) or val_max)
		end
		
		return result:allDone()
	end
	
	local out = mw.html.create('table')
		:addClass('wikitable sortable lighttable')
		:tr()
			:th{ "Monster", attr = { rowspan = '2' } }
			:th{ "Amount", attr = { colspan = '2' } }
			:th{ "Combat level", attr = { colspan = '2' } }
			:th{ "Slayer experience", attr = { colspan = '2' } }
			:th{ "Unlock requirements", attr = { rowspan = '2' } }
			:th{ ("[[%s#Task weighting|Weighting]]"):format(master), attr = { rowspan = '2' } }
		:tr()
			:th("Min")
			:th("Max")
			:th("Min")
			:th("Max")
			:th("Min")
			:th("Max")
	
	local total_weight = 0
	for _, res in ipairs(results) do
		local reqs = {}
		if res.params.reqs then
			for k, v in pairs(res.params.reqs) do
				-- always put slayer req first
				if k == "slayer" and v > 0 then
					table.insert(reqs, 1, sc(k, v))
				elseif k ~= "other" and v > 0 then
					table.insert(reqs, sc(k, v))
				end
			end
			-- always put "other" req last
			table.insert(reqs, res.params.reqs.other)
		end
		
		out:tr()
			:td(slayer_disambig(res.name, true))
			:td(res.params.min or '?')
			:td(res.params.max or '?')
			:node(minMaxCols(res, "combat_level", 0))
			:node(minMaxCols(res, "slayer_experience", 1))
			:td(table.concat(reqs, ", "))
			:td(res.params.weight or '?')
		
		if res.params.weight ~= nil then
			total_weight = total_weight + res.params.weight
		end
	end
	out:tr()
		:th{ "Total weight", attr = { colspan = '8' } }
		:th(total_weight)
	
	-- variable "sum" used by [[Slayer Master/Task Weighting]]
	mw.ext.VariablesLua.vardefine("sum", total_weight)

	return out:allDone()
end

return p