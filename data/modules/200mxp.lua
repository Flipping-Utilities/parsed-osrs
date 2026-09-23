-- <pre>

local p = {}

local lookuptable = require("Module:200mxp/data")

local gamemodeindex = {
	["all"] = 1,
	["im"] = 2,
	["uim"] = 3,
	["hcim"] = 4
}

local function lookup(skill,gamemode)
	local info = lookuptable[skill]
	if info == nil then
		return 'Invalid {{{1}}} param'
	elseif skill=='update' then
		return info
	else
		return info[gamemodeindex[gamemode] or 1]
	end
end

function p.lookup(frame)
	local args = frame:getParent().args
	local skill = string.lower(args[1] or '')
	local gamemode = string.lower(args[2] or 'all')
	return lookup(skill,gamemode)
end

return p