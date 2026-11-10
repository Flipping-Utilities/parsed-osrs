--<nowiki>

--[[
Implements helper templates for [Module:Infobox recipe]
{{GETotal}} and {{GETotalqty}}
Adds all prices together and creates an easy to parse number
--]]
local p = {}

local helper = require('Module:GEPHelper')

--[[
For simple sets, 1 item at a time
{{GETotal|a|b|c}} will add the prices of a, b, and c
Does not allow quantities of items
Technically unlimited
--]]
function p.simple(frame)
    return helper._simple(frame, p._main)
end

--[[
For stuff that's a bit more complex
{{GETotalqty|name1=a|qty1=4|name2=b|qty2=1/4|mat1=c parts|matqty1=3.5}}
Will add together the price of a * 4, b / 4 and (c parts) * 3.5
Can recognize and parse vulgar fractions
All fractions and decimals will be truncated off the final price
Technically unlimited
--]]
function p.quantities(frame)
    return helper._quantities(frame, p._main)
end

--[[
Function to add prices together
]] --
function p._main(list)
    local price = 0
    for _, v in ipairs(list) do
        price = price + v
    end
    return price
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
function p._quantity(a, b)
    return helper._quantity(a, b, p._main)
end

return p