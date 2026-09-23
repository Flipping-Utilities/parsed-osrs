-- <pre>
-- Implements various currency templates
--

local p = {}

local function amount (a, coinType)
    -- convert used globals to locals where possible to improve performance
    local math = math
    local string = string
    local table = table
    local mw = mw
    local expr = mw.ext.ParserFunctions.expr

    local ret = {'<span class="coins inventory-image ', true, true, true, true, '</span>'}
    -- add class for CSS to add the correct image with
    -- see [[MediaWiki:Common.less/coins.less]] for more details
    local coinClasses = {
        coins = 'coins-',
        nocoins = '',
        nocoinsc = '',
        fiat = ''
    }
    local noCoins = {
    	nocoins = '',
    	nocoinsc = ' coins',
    	fiat = ''
    }
    local a2, num, amounts, i, j

    ret[1] = '<span class="coins inventory-image '
    ret[2] = coinClasses[coinType]

	if noCoins[coinType] then
		ret[1] = '<span class="coins '
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
    ret[3] = tostring(j)
    if noCoins[coinType] then
    	ret[3] = ''
    end

    -- set a class to denote positive or negative (css sets the colour)
    if a > 0 then
        ret[4] = ' coins-pos">'
    elseif a < 0 then
        ret[4] = ' coins-neg">'
    else
        ret[4] = '">'
    end
    
    local lang = mw.language.getContentLanguage();

	-- Assumes (for now) that all currencies want at least 2 significant digits
	--   if the number has a fractional part.
    if coinType == 'fiat' then
    	-- The fractional value returned is guaranteed to be formatted as 0.X
    	local whole, frac = math.modf(num)
    	ret[5] = lang:formatNum(whole)
    	-- Concat formatted whole portion onto fractional portion, if needed
    	if frac > 0 then
    		ret[5] = ret[5] .. string.format('%.2f', frac):sub(2)
    	end
    else
    	-- format number with commas
    	ret[5] = lang:formatNum(a)
    end

    if noCoins[coinType] then
    	ret[5] = ret[5] .. noCoins[coinType]
    end

    return table.concat( ret )
end

--
-- {{Coins}}
--
function p.coins(frame)
    local args = frame:getParent().args
    -- for {{coins|111}}
    local a = args[1] or '0'
    return amount(a, 'coins')
end

function p.nocoins(frame)
    local args = frame:getParent().args
    local c = 'nocoins'
    if string.find(args[2] or '', '%S') then
    	c = 'nocoinsc'
    end
    local a = args[1] or '0'
    return amount(a, c)
end

function p.fiat(frame)
	local args = frame:getParent().args
	local a = args[1] or '0'
	return amount(a, 'fiat')
end

--
-- Module access point
--
function p._amount(a, coinType)
    a = tostring(a) or '0'
    return amount(a, coinType)
end

return p