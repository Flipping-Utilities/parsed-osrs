local p = {}
local expr = mw.ext.ParserFunctions.expr

function p.min(frame)
	local args = getargs(frame)
	return p._min(args)
end

function p._min(tbl)
	local low = tbl[1]
	
	for _, v in ipairs(tbl) do
		if v < low then
			low = v
		end
	end
	
	return low
end

function p.max(frame)
	local args = getargs(frame)
	return p._max(args)
end

function p._max(tbl)
	local high = tbl[1]
	
	for _, v in ipairs(tbl) do
		if v > high then
			high = v
		end
	end
	
	return high
end

	
function getargs(frame)
	args = frame:getParent().args
	local nums = {}
	
	for _, v in ipairs(args) do
		local w = string.gsub(v,',','')
		w = tonumber(w) or tonumber(expr(w))
		if w then
			table.insert(nums,w)
		end
	end
	
	return nums
end


return p