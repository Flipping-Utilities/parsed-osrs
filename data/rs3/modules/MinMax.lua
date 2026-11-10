
local expr = mw.ext.ParserFunctions.expr

local p = {}

local function getArgs(frame)
	local args = frame:getParent().args
	local nums = {}

	for _, v in ipairs(args) do
		local w = tonumber((v:gsub(',', ''))) or tonumber((expr(v)))
		if w then
			table.insert(nums, w)
		end
	end

	return nums
end

function p.min(frame)
	return p._min(getArgs(frame))
end

function p._min(tbl)
	local low

	for _, v in ipairs(tbl) do
		if low == nil or v < low then
			low = v
		end
	end

	return low
end

function p.max(frame)
	return p._max(getArgs(frame))
end

function p._max(tbl)
	local high

	for _, v in ipairs(tbl) do
		if high == nil or v > high then
			high = v
		end
	end

	return high
end

function p.average(frame)
	return p._average(getArgs(frame))
end

function p._average(tbl)
	local sum = 0
	local count = 0
	for i, v in ipairs(tbl) do
		sum = sum + v
		count = i
	end
	return sum / count
end

function p.sum(frame)
	return p._sum(getArgs(frame))
end

function p._sum(tbl)
	local sum = 0
	for _, v in ipairs(tbl) do
		sum = sum + v
	end
	return sum
end

return p