local format_completion_pct = require("Module:ELTasks").format_completion_pct
local p = {}

local function contains(t, v)
	for _, val in ipairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

local function writeBucket(args)
	if mw.title.getCurrentTitle().namespace ~= 0 then
		return
	end
	
	local skill = args.s
	local other = args.other
	local clue = args.clue
	local additionalUsesSkill = args.uses_skill
	local id_num = tonumber(args.id)
	local blessingTask = args.blessingTask or "no"
	
	local uses_skill = {}
	for k in string.gmatch(skill or '', 'data%-skill="([a-zA-Z %-]+)"') do
		table.insert(uses_skill, k:lower())
	end
	
	for k in string.gmatch(additionalUsesSkill or '', '[^,]+') do
		if not contains(uses_skill, k:lower()) then
			table.insert(uses_skill, k:lower())
		end
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
		local str_val, sort_val, colour = format_completion_pct(completion_percent)
		return string.format("class='table-bg-%s' data-sort-value='%s' | %s", colour, sort_val, str_val)
	else
		return "class='table-na nohighlight' style='text-align: center;' data-sort-value='-1' | <small>N/A</small>"
	end
end

return p