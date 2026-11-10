local ttools = require("Module:TableTools")
local keysToList = ttools.keysToList
local Array = require("Module:Array")
local weakness = require("Module:Weakness clickpic/data")
local leagueRegion = require('Module:LeagueRegion')
local lang = mw.language.getContentLanguage()
require("Module:Mw.html extension")
local p = {}

local function leaguesArg(region)
	if region ~= nil and region ~= '' then
		return leagueRegion.regionsForInfobox(region)
	end
end

function p.main(frame)
	local args = frame:getParent().args
	local cat = string.lower(args[1])
	local loc_res = string.lower(args[2] or "surface")
	
	if loc_res == "surface" then
		loc_res = bucket.Or({'location_restriction', 'surface'}, {'location_restriction', bucket.Null()})
	else
		loc_res = {'location_restriction', loc_res}
	end
	
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
			'slayer_category',
			'league_region'
		)
		.where('slayer_category', cat)
		.where(loc_res)
		.limit(5000)
		.orderBy('slayer_level', 'asc')
		.run()

	if #data == 0 then
		return "No results"
	end
	
	local t = {}
	local orderedCols = { "combat_level", "slayer_level", "slayer_experience", "life_points", "weakness_text", "susceptible_to" , "league_region"}
	
	--Combine multiple instances of the same mob into one result
	for _, v in pairs(data) do
		
		--mw.logObject(v)
		
		local main_object = v.page_name
		t[main_object] = t[main_object] or {}

		-- process columns' data
		for _, col in ipairs(orderedCols) do
			t[main_object][col] = t[main_object][col] or {}
			local val = v[col]
			if val then
				val = type(val) ~= "table" and {val} or val
				for _, singleVal in pairs(val) do
					if col == 'slayer_level' and tonumber(singleVal) then
						singleVal = math.max(tonumber(singleVal), 1)
					end
					t[main_object][col][singleVal] = 1
				end
			end
		end
	end

	local tbl = mw.html.create("table")
		:addClass("wikitable sortable")
		:tr()
			:th("Name")
			:th("Combat level")
			:th("Slayer level")
			:th("Slayer XP")
			:th("[[Life points|LP]]")
			:th("[[Weakness]]")
			:th("[[Susceptibility|Susceptible to]]")
			:th("[["..leagueRegion.getDefaultLeague().."]]"):addClass("leagues-global-flag")

	local keys = keysToList(t)

	table.sort(keys, function (keya,keyb)
		local slayera = keysToList(t[keya]['slayer_level'])
		if #slayera==0 then slayera = {0} end
		local slayerb = keysToList(t[keyb]['slayer_level'])
		if #slayerb==0 then slayerb = {0} end
		local i = 1
		-- iterate slayera and slayerb, comparing equivalent indexed values until not equal
		while slayera[i] and slayerb[i] do
			if slayera[i] ~= slayerb[i] then
				return slayera[i] < slayerb[i]
			end
			i = i + 1
		end
		-- all values checked were equal
		-- check if one list is longer
		if i > 1 then
			i = i - 1
			if #slayera > #slayerb then
				return slayera[i+1] < slayerb[i]
			elseif #slayera < #slayerb then
				return slayera[i] < slayerb[i+1]
			end
		end
		-- all equal and equal length, compare names
		return keya < keyb
	end)

	for _,k in pairs(keys) do
		local v = t[k]
		local row = tbl:tr()
			:td(string.format("[[%s]]", k))
		
		for _, col in ipairs(orderedCols) do
			-- separator used in case column has multiple values
			local sep = "; "
			if col == "weakness_text" or col == "susceptible_to" then
				sep = " "
			end
			
			-- collect value(s) in order
			local tempTbl = {}
			local sortKey = nil
			if type(v[col]) ~= "table" then
				v[col] = {v[col]}
			end
			
			for k, _ in pairs(v[col]) do
				-- format value
				if col == "weakness_text" then
					k = string.format("[[File:%s|link=%s|34px|frameless]]", weakness[k].image, weakness[k].link) 
				elseif col == "susceptible_to" then
					k = string.format("[[File:%s|link=%s]]", weakness[k].image, weakness[k].link)

				else
					if sortKey == nil then
						sortKey = k
					end
					k = tonumber(k) and lang:formatNum(k) or k
				end
				
				table.insert(tempTbl, k)
			end
			
			if col == "league_region" then
				local regions = Array.reduce(tempTbl, function(x, acc)
					Array.insert(acc, mw.text.split(x, ","), true)
					return acc
				end, Array{})
				regions = Array.unique(regions)
				regions = Array.filter(regions, function(x)
					if string.find(x, "&") and Array.intersects(regions, mw.text.split(x, "&"))	then
						return false
					end
					return true
				end)
				regions = table.concat(regions, ",")
				tempTbl = { leaguesArg(regions) }
			end
			
			-- join ordered value(s) into output table column
			row:td{table.concat(tempTbl, sep), attr={['data-sort-value']=sortKey}}
			:IF(col == "league_region")
			    :addClass('leagues-global-flag')
			:END()
		end
	end

	return tbl:allDone()
end

return p