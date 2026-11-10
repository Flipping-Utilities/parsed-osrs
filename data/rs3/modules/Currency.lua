-- Implements various currency templates
--
local getArgs = require("Module:Arguments").getArgs

local p = {}

local function amount (a, currencyType)
	if currencyType == nil then
		error(string.format("Function %s was missing currencyType argument - cannot compute currency without currencyType", "amount"))
	end
	
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
        rusty = 'rusty-coins-',
        chimes = 'chimes-',
        zemomark = 'zemomark-',
        chronotes = 'chronotes-',
        nocoins = '',
        nocoinsc = ''
    }
    local noCoins = {
    	nocoins = '',
    	nocoinsc = ' coins'
    }
    local a2, num, amounts, amountsChimes, i, j

    ret[1] = '<span class="coins inventory-image '
    ret[2] = coinClasses[currencyType]

	if noCoins[currencyType] then
		ret[1] = '<span class="nocoins '
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
    amountsChimes = {1000, 100, 50, 20, 1}

	local amts
    if currencyType == 'chimes' then
        amts = amountsChimes
    else
        amts = amounts
    end

    for i = 1, #amts do
        j = amts[i]

        if num >= j then
            break
        end
    end

    ret[3] = tostring(j)
    if noCoins[currencyType] then
    	ret[3] = ''
    end

    -- set a class to denote positive or negative (css sets the colour)
    if a > 0 then
        ret[4] = ' coins-pos">'
    elseif a < 0 then
        ret[4] = ' coins-neg">'
    else
        ret[4] = ' coins-zero">'
    end

    -- format number with commas
    ret[5] = mw.language.getContentLanguage():formatNum(a)
    if noCoins[currencyType] then
    	ret[5] = ret[5] .. noCoins[currencyType]
    end

    return table.concat( ret )
end

local function invokeAmount(a, currencyType)
	local ok, ret = pcall(amount, a, currencyType)
	if ok then
		return ret
	end
	error(string.format("Function %s threw an error with arguments a:%s, currencyType:%s", "amount", a, currencyType))
end

local function makeInvokeFunction(currencyType)
	return function(frame)
		local args = getArgs(frame)
		-- @todo remove named arg
		local a = args[1] or args.Amount or args.amount or '0'
		return invokeAmount(a, currencyType)
	end
end

--
-- {{Coins}}
--
p.coins = makeInvokeFunction('coins')

function p.nocoins(frame)
    local args = getArgs(frame)
    local c = 'nocoins'
    if string.find(args[2] or '', '%S') then
    	c = 'nocoinsc'
    end
    local a = args[1] or args.Amount or args.amount or '0'
	return invokeAmount(a, c)
end

--
-- {{Rusty coins}}
--
p.rusty = makeInvokeFunction("rusty")

--
-- {{Chimes}}
--
p.chimes = makeInvokeFunction("chimes")

--
-- {{Zemomark}}
--
p.zemomark = makeInvokeFunction("zemomark")

--
-- {{Chonotes}}
--
p.chronotes = makeInvokeFunction("chronotes")

--
-- Module access point
--
function p._amount(a, currencyType)
    a = tostring(a) or '0'
    return amount(a, currencyType)
end
-- Quick/lazy access to coins
function p._coins(a)
    a = tostring(a) or '0'
    return amount(a, 'coins')
end

return p