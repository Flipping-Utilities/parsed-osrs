require("strict")

local p = {}

function p.main(frame)
	local args = frame.args
	local level = args.level
	
	return ('Ability contribution from a level %s skill is %.2f'):format(level,145 * math.log(1 + 0.6 * level / 145 ) / math.log (1.6))
end

return p