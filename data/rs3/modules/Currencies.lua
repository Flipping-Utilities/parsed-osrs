-- <pre>
-- Implements {{Currencies}}
-- Variant of Module:Coins to support other currency types
-- Original source: https://oldschool.runescape.wiki/w/Module:Currencies?action=edit

local p = {}

local currency_image = require("Module:Currency Image")

-- function to get the currency image and name (singular vs plural)
local function currencyInfo(currency, price)
    price = tostring(price)
    -- body
    local lowcur = string.lower(currency)
    local clean = price:gsub('%W', '')
    local retcur, img, hasImg
    if tonumber(clean) and tonumber(clean) ~= 1 then
        retcur = currency
    else
        if lowcur == 'zemomark' or lowcur == 'tokkul' or lowcur == 'teci' then
            retcur = currency
        elseif lowcur == 'pieces of eight' then
            retcur = 'piece of eight'
        else
            retcur = string.sub(currency, 1, (string.len(currency) - 1))
        end
    end
    img = currency_image(currency, price)
    if img then
        img = '<span class="currency-image">[[File:' .. img .. '|link=' .. currency .. '|frameless|x19px]]</span>'
        hasImg = true;
    else
        img = '<span>' .. currency .. '</span>'
        hasImg = false;
    end
    return img, retcur, hasImg
end

local function amount(a, currency)
	-- convert used globals to locals where possible to improve performance
	local math = math
	local string = string
	local table = table
	local mw = mw
        local expr = mw.ext.ParserFunctions.expr

	local ret = {'<span class="currencies coins', '', '', '', '</span>'}

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
		ret[2] = ' coins-zero"'
	end
	
	ret[2] = ret[2] .. ' data-sort-value="' .. a .. '">'

    local currencyDisplay, _, hasImg = currencyInfo(currency, num)
	-- format number with commas
	local formattedNum = mw.language.getContentLanguage():formatNum(a)

    if hasImg then
        ret[3] = currencyDisplay
        ret[4] = formattedNum
    else
        ret[3] = formattedNum .. ' '
        ret[4] = currencyDisplay
    end

	return table.concat(ret)
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

--
-- Documentation display
-- Returns a table or list of all supported currencies
--
function p._doc(display)
	local currency_data = mw.loadData('Module:Currency Image/data')
	local list = {}
	for i, _ in pairs(currency_data) do
		table.insert(list, i)
	end
	table.sort(list)
	
	if display == 'list' then
		return '<code>' .. table.concat(list, '</code>, <code>') .. '</code>'
	end
	
	local ret = mw.html.create('table')
		:addClass('wikitable sortable align-right-2')
		:tag('tr')
			:tag('th')
				:wikitext('Currency')
			:done()
			:tag('th')
				:wikitext('Displays as')
			:done()
		:done()
	for _, v in ipairs(list) do
		ret:tag('tr')
			:tag('td')
				:wikitext('[[' .. v .. ']]')
			:done()
			:tag('td')
				:wikitext(p._amount(10000, v))
			:done()
		:done()
	end
	
	return ret:allDone()
end

function p.doc(frame)
	return p._doc(frame.args[1])
end

return p