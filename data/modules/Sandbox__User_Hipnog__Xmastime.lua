
local p = {}

function p.test (frame)
	local args = frame.args
	local argxmas = args[1]
	local arg2 = args[2]
	local arg3 = args[3]
	
	if argxmas ~= "yes" then
		return arg2
	else 
		return arg3
	end
end


return p