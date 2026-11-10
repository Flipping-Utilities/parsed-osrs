local p = {}
local normalise_category_data =  mw.loadData('Module:Slayer assignments/normalise')
local Masters = {
	["Turael"] = mw.loadData('Module:Slayer assignments/Turael'),
	["Jacquelyn"] = mw.loadData('Module:Slayer assignments/Jacquelyn'),
	["Vannaka"] = mw.loadData('Module:Slayer assignments/Vannaka'),
	["Mazchna"] = mw.loadData('Module:Slayer assignments/Mazchna'),
	["Chaeldar"] = mw.loadData('Module:Slayer assignments/Chaeldar'),
	["Sumona"] = mw.loadData('Module:Slayer assignments/Sumona'),
	["Duradel"] = mw.loadData('Module:Slayer assignments/Duradel'),
	["Kuradal"] = mw.loadData('Module:Slayer assignments/Kuradal'),
	["Morvran"] = mw.loadData('Module:Slayer assignments/Morvran'),
	["Laniakea"] = mw.loadData('Module:Slayer assignments/Laniakea'),
	["Raptor"] = mw.loadData('Module:Slayer assignments/The Raptor'),
	["Mandrith"] = mw.loadData('Module:Slayer assignments/Mandrith'),
}

local function normalise(x)
	-- standardising just in case we want to do other things to normalise
	return string.lower(x)
end

-- used to generate [[Module:Slayer assignments/normalise]]
-- just run p._dump() in the console below when editing this module
-- then copy the output and paste into the normalise module
function p._dump()
	local all_tasks = {}
	for master,master_data in pairs(Masters) do
		for mob,mob_data in pairs(master_data) do
			local norm = normalise(mob)
			if all_tasks[norm] then
				if all_tasks[norm] ~= mob then
					mw.log('Dupe: '..norm..' = '..mob)
				end
			else
				all_tasks[norm] = mob
			end
		end
	end
	local out = {}
	for normalised,mob in pairs(all_tasks) do
		table.insert(out, string.format('\t["%s"] = "%s",', normalised, mob))
	end
	table.sort(out)
	table.insert(out, 1, 'return {')
	table.insert(out, '}')
	return table.concat(out,'\n')
end

function p.normalise_category(cat)
	local _cat = normalise(cat)
	if normalise_category_data[_cat] then
		return normalise_category_data[_cat]
	end
	return cat
end
function p.normalise_master(x)
	-- could use a map here like categories
	-- but not needed really
	return string.upper(string.sub(x,0,1)) .. string.lower(string.sub(x,2))
end

p.slayer_master_order = {"Turael","Jacquelyn","Vannaka","Raptor","Mazchna","Chaeldar","Sumona","Duradel","Kuradal","Morvran","Laniakea","Mandrith"}

function p.getAssigners(cat)
	cat = p.normalise_category(cat)
	local assigners = {none=true}
	for i,v in ipairs(p.slayer_master_order) do
		local assigned = Masters[v][cat] ~= nil
		assigners[v] = assigned
		assigners.none = assigners.none and not assigned
	end
	return assigners
end

function p.getAmounts(master,cat)
	master=p.normalise_master(master)
	cat = p.normalise_category(cat)
	local amounts = {}

	if Masters[master][cat] ~= nil then
		if Masters[master][cat].min ~= nil then
			amounts["min"] = Masters[master][cat].min
		else
			amounts["min"] = "?"
		end
		
		if Masters[master][cat].max ~= nil then
			amounts["max"] = Masters[master][cat].max
		else
			amounts["max"] = "?"
		end
	end
	
	return amounts
end

function p.getAllAmounts(cat)
	cat = p.normalise_category(cat)
	local out = {none=true}
	for i,v in ipairs(p.slayer_master_order) do
		if Masters[v][cat] then
			out[v] = p.getAmounts(v,cat)
			out.none=false
		end
	end
	return out
end

function p.getWeight(master,cat)
	master=p.normalise_master(master)
	cat = p.normalise_category(cat)
	
	local weight = 0
	
	if Masters[master][cat] ~= nil then
		if Masters[master][cat].weight ~= nil then
			weight = Masters[master][cat].weight
		end
	end
	
	return weight
end

function p.getTotalWeight(master)
	master=p.normalise_master(master)
	
	local total_weight = 0
	
	for mob,mob_data in pairs(Masters[master]) do
		if mob_data ~= nil then
			if mob_data.weight ~= nil then
				total_weight = total_weight + mob_data.weight
			end
		end
	end
	
	return total_weight
end

function p.getReqs(master,cat)
	master = p.normalise_master(master)
	cat = p.normalise_category(cat)
	
	local reqs = {}
	
	if Masters[master][cat] ~= nil then
		if Masters[master][cat].reqs ~= nil then
			reqs = Masters[master][cat].reqs
		end
	end
	
	return reqs
end

function p.getAssignments(master)
	master=p.normalise_master(master)
	return Masters[master]
end

function p.getCategories()
	ret = {}
	for _, data in pairs(Masters) do
		for cat, _ in pairs(data) do
			if (ret[cat] == nil) then
				ret[cat] = ""
			end
		end
	end
	return ret
end

return p