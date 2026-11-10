require('strict')
local p = {}

local function writeBucket(args)
	if mw.title.getCurrentTitle().namespace ~= 0 then
		return
	end
	
	local skill = args.s
	local other = args.other
	local clue = args.clue
	local id_num = tonumber(args.id)
	local blessingTask = args.blessingTask or "no"
	
	local uses_skill = {}
	for k in string.gmatch(skill or '', 'data%-skill="([a-zA-Z %-]+)"') do
		table.insert(uses_skill, k:lower())
	end
	
	local data = {
		["name"] = args[1],
		["description"] = args[2],
		["skill"] = skill,
		["other"] = other,
		["uses_skill"] = uses_skill,
		["tier"] = (args.tier or ''):lower(),
		["region"] = (args.region or ''):lower(),
		["blessing_task"] = blessingTask,
		["id"] = id_num,
		["clue"] = (clue or ''):lower(),
	}
	
	bucket('equilibrium_league_task').put(data)
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

function p._main(args)
	writeBucket(args)
	local id = args.id
	local completion_percent = mw.loadJsonData("Module:Equilibrium_League/Tasks/completion.json")[tonumber(id)]
	if (completion_percent ~= nil) then
		local sort_val = completion_percent
		local color = ""
		if (completion_percent < 0.1) then
			completion_percent = "<0.1"
			color = "red"
		elseif (completion_percent < 1) then
			color = "orange"
		elseif (completion_percent < 10) then
			color = "yellow"
		elseif (completion_percent < 50) then
			color = "green"
		elseif (completion_percent <= 100) then
			color = "blue"
		end
		return string.format("class='table-bg-%s' data-sort-value='%s' | %s%%", color, sort_val, completion_percent)
	else
		return "class='table-na nohighlight' style='text-align: center;' data-sort-value='-1' | <small>N/A</small>"
	end
end

return p