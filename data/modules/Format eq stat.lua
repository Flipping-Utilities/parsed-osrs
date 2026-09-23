local p = {}

function p.signed(arg)
	local first_char = string.sub(arg, 1, 1)

	if first_char == '+' or first_char == '-' then
		return arg
	else
		return '+'..arg
	end
end

function p.main(frame)
	local args = frame:getParent().args

	local arg = args[1] or ''
	return p.signed(arg)
end

return p