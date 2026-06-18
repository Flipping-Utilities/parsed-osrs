-- <pre>
-- Implements {{Currency}}
-- Variant of Module:Coins to support other currency types
-- Original source: http://oldschool.runescape.wiki/w/Module:Coins?action=history

local p = {}

local currency_image = require("Module:Currency_Image")

local function amount(a,currency)
	-- convert used globals to locals where possible to improve performance
	local math = math
	local string = string
	local table = table
	local mw = mw
        local expr = mw.ext.ParserFunctions.expr

	local ret = {'<span class="coins inventory-image', true, true, true, '</span>'}

	-- strip commas from input
	-- @example {{GEPrice|Foo}} -> '1,000'
	a = string.gsub(a, ',', '')

	-- for performance reasons, only calculate expr if required
	local a2 = tonumber(a)
	if a2 == nil then
		a = expr(a)
		a2 = tonumber(a) or 0
	end

	-- round to 2 d.p.
	a = math.floor(a2 * 100 + 0.5) / 100

	local num = math.abs(a)

	-- set a class to denote positive or negative (css sets the colour)
	if a > 0 then
		ret[2] = ' coins-pos"'
	elseif a < 0 then
		ret[2] = ' coins-neg"'
	else
		ret[2] = '"'
	end
	
	ret[2] = ret[2] .. ' data-sort-value="' .. a .. '" style="white-space:nowrap;">'

	local currencyImage = currency_image(currency, num) or ''
	if not (currencyImage=='') then
	    currencyImage = string.format('[[File:%s|link=%s]] ', currencyImage, currency)
    end
    
	ret[3] = tostring(currencyImage)

	-- format number with commas
	ret[4] = mw.language.getContentLanguage():formatNum(a)

	return table.concat( ret )
end

--
-- {{Currency}} access point
--
function p.amount(frame)
	local args = frame:getParent().args
	local value = args[2] or '0'
	local currency = args[1] or 'Coins'
	return amount(value, currency)
end

--
-- Module access point
--
function p._amount(a, b)
	local value = tostring(a) or '0'
	local currency = b or 'Coins'
	return amount(value, currency)
end

return p