--<nowiki>

--[[
Implements helper function for [Module:GETotal], [Module:GEPMinMax]
--]]
local p = {}

local compcost

local getArgs = require("Module:Arguments").getArgs;
local geprice = require('Module:Exchange')._price

local function expr(s)
    local res_good, res = pcall(mw.ext.ParserFunctions.expr, s)
    return res_good and res or nil
end

--[[
For simple sets, 1 item at a time
{{TEMPLATE NAME|a|b|c}} will add the prices of a, b, and c
Does not allow quantities of items
Technically unlimited
--]]
function p._simple(frame, func)
	local args = getArgs(frame);
    local prices = {}
    for _, v in ipairs(args) do
        table.insert(prices, geprice(v))
    end
    return func(prices)
end

--[[
For stuff that's a bit more complex
{{TEMPLATE NAME|name1=a|qty1=4|name2=b|qty2=1/4|mat1=c parts|matqty1=3.5}}
Will compare the price of a * 4, b / 4 and (c parts) * 3.5
Can recognize and parse vulgar fractions
All fractions and decimals will be truncated off the final price
Technically unlimited
--]]
function p._quantities(frame, func)
	local args = getArgs(frame);
    local prices = {}
    for i = 1, math.huge, 1 do
        local itemx = args['name' .. i]
        if itemx then
            local priceret = geprice(itemx)
            local qtyx = args['qty' .. i] or 1
            local qtyret = tonumber(qtyx) or p.frac(qtyx) or expr(qtyx) or 1
            table.insert(prices, math.floor(priceret * qtyret))
        else
            break
        end
    end
    for i = 1, math.huge, 1 do
        local matx = args['mat' .. i]
        if matx then
            if not compcost then
                compcost = require('Module:Component costs')._main
            end
            local cost = compcost(matx)
            if cost and cost.price ~= nil then
                local priceret = cost.price
                local qtyx = args['matqty' .. i] or 1
                local qtyret = tonumber(qtyx) or p.frac(qtyx) or expr(qtyx) or 1
                table.insert(prices, math.floor(priceret * qtyret))
            end
        else
            break
        end
    end
    return func(prices)
end

--[[
Helper function to parse vulgar fractions
If not readable as a vulgar fraction (i.e. no '/' character)
Returns nil, even if it can be read as a number
--]]
function p.frac(num)
    if not num then
        return nil
    elseif not num:find('/') then
        return nil
    end
    local parts = mw.text.split(num, '/')
    local numer, denom = tonumber(parts[1]), tonumber(parts[2])
    if numer and denom then
        return numer / denom
    else
        return nil
    end
end

--[[
Modified and deprecated version of quantities.
Will add together the price of a * 4 and b / 4
Can recognize and parse vulgar fractions
All fractions and decimals will be truncated off the final price
Technically unlimited

To use:
variable 'a' = array of {quantity,"item name", etc...}
variable 'b' = number of unique items to be included
--]]
function p._quantity(a, b, func)
    local values = a or {}
    local count  = b or 0
    local prices = {}

    for i = 1, (count * 2), 2 do
        local itemx = values[i + 1]
        if itemx then
            local priceret = geprice(itemx)
            local qtyx = values[i] or 1
            local qtyret = tonumber(qtyx) or p.frac(qtyx) or expr(qtyx) or 1
            table.insert(prices, math.floor(priceret * qtyret))
        end
    end

    return func(prices)
end

return p