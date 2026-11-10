-- <pre>
-- Implements {{Coins}} and {{Rusty coins}}
--

local p = {}

local function amount (a, isRusty)
	-- convert used globals to locals where possible to improve performance
	local math = math
	local string = string
	local table = table
	local mw = mw
        local expr = mw.ext.ParserFunctions.expr

	local ret = {true, true, true, true, '</span>'}
	local a2, num, amounts, i, j

	if not isRusty then
		ret[1] = '<span class="coins inventory-image coins-'
	else
		ret[1] = '<span class="coins inventory-image rusty-coins-'
	end

	-- strip commas from input
	-- @example {{GEPrice|Foo}} -> '1,000'
	a = string.gsub(a, ',', '')

	-- cache tonumber result
	a2 = tonumber(a)

	-- only do this if required so as not to impact performance too much
	if a2 == nil then
		a = expr(a)
		a2 = tonumber(a) or 0
	end

	-- round to 2 d.p.
	a = math.floor(a2 * 100 + 0.5) / 100

	-- select which image class to use for css to hook off
	num = math.abs(a)
	amounts = {10000, 1000, 250, 100, 25, 5, 4, 3, 2, 1}

	for i = 1, #amounts do
		j = amounts[i]

		if num >= j then
			break
		end
	end

	ret[2] = tostring(j)

	-- set a class to denote positive or negative (css sets the colour)
	if a > 0 then
		ret[3] = ' coins-pos">'
	elseif a < 0 then
		ret[3] = ' coins-neg">'
	else
		ret[3] = ' coins-zero">'
	end

	-- format number with commas
	ret[4] = mw.language.getContentLanguage():formatNum(a)

	return table.concat( ret )
end

--
-- {{Coins}} access point
--
function p.amount(frame)
	local args = frame:getParent().args
	-- for {{coins|111}} or {{coins|amount=111}}
	-- @todo remove named arg
	local a = args[1] or args.Amount or args.amount or '0'
	return amount(a)
end

--
-- {{Rusty coins}} access point
--
function p.rusty(frame)
	local args = frame:getParent().args
	-- @todo remove named arg
	local a = args[1] or args.Amount or args.amount or '0'
	return amount(a, true)
end

--
-- Module access point
--
function p._amount(a, isRusty)
	a = tostring(a) or '0'
	return amount(a, isRusty)
end

return p