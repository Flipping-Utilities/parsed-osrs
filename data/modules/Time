-- <pre>

local p = {}

-- minutes to hh:mm:ss
function p.m_to_c(frame)
	local args = frame:getParent().args
	local arg = args[1]
	return p._m_to_c(arg)
end

function p._m_to_c(arg)
	arg = arg or ''
	if arg == '' then
		return ''
	end

	-- look for and parse fractions
	if arg:find('/') then
		local n,d = arg:match('(%d+)%s*/%s*(%d+)')

		n = tonumber(n,10)
		d = tonumber(d,10)

		-- only continue if 60 (seconds in a minute) is denom
		if d == 60 then
			arg = n/d
		else
			return '' --for now
		end
	end

	arg = tonumber(arg)

	-- return if can't parse as a number
	if not arg then
		return ''
	end

	-- multiply by 60 so we're working with seconds
	arg = math.floor(arg * 60)

	local h,m,s = math.floor(arg/3600), math.floor((arg%3600)/60), arg%60

	-- 0 pad numbers to 2 places
	return string.format('%02i:%02i:%02i',h,m,s)
end


-- '# <unit>' to number of seconds
function p.w_to_s(frame)
	local args = frame:getParent().args
	local arg = args[1]
	return p._w_to_s(arg)
end

function p._w_to_s(arg)
	arg = arg or ''

	if arg == '' then
		return ''
	end

	-- find a number followed by a single word
	local _arg,unit = arg:match('(%d+)%s*(%S+)')

	-- lowercase unit
	unit = string.lower(unit)

	-- multiplier
	local mult = 0
	if unit:find('sec') then
		mult = 1
	elseif unit:find('min') then
		mult = 60
	elseif unit:find('hour') then
		mult = 3600
	end

	arg = tonumber(_arg) * mult

	return arg or 0
end

-- '# <unit>' to hh:mm:ss
function p.w_to_c(frame)
	local args = frame:getParent().args
	local arg = args[1]
	return p._w_to_c(arg)
end

function p._w_to_c(arg)
	arg = p._w_to_s(arg)
	local h,m,s = math.floor(arg/3600), math.floor((arg%3600)/60), arg%60

	-- 0 pad numbers to 2 places
	return string.format('%02i:%02i:%02i',h,m,s)
end

return p