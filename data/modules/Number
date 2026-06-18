--[[
{{Helper module
|name = Number
|fname1 = _round(num, dp)
|ftype1 = float, int
|fuse1 = Rounds <code>num</code> to a precision given by <code>dp</code>, if <code>dp</code> is not specified, it defaults to zero.
|fname2 = _short(str)
|ftype2 = String
|fuse2 = Convert numbers ending in k, m or b to the actual correct number. Example: 3.5k -> 3500
}}
-- ]]
--
-- Number manipulation methods
--
-- Many methods are already available in the math library, so this will be fairly small
--

local p = {}

--
-- Rounds a number to a specified number of decimal places
--
-- If dp is not specified, it defaults to zero
-- based on <http://dev.wikia.com/wiki/Module:HF>
--
function p._round( num, dp )
	if not num then
		return
	end
	local mult = 10 ^ ( dp or 0 )
	return math.floor( num * mult + 0.5 ) / mult
end

function p.round( frame )
	return p._round( frame.args[1], frame.args[2] )
end

--
-- Expands a shorthand number to an actual number
--
-- @example 3.5k -> 3500
-- @example 10m -> 10000000
--
-- Returns the string if it is not a valid number
--

function p._short( str )
	local num = str:sub( 1, -2 )
	local char = str:sub( -1 )
	if tonumber( num ) then
		if char == 'k' then
			num = num * 10^3
		elseif char == 'm' then
			num = num * 10^6
		elseif char == 'b' then
			-- strip trailing letter
			num = num * 10^9
		else
			return str
		end
		return num
	else
		return str
	end
end

function p.short( frame )
	return p._short( frame.args[1] )
end

return p