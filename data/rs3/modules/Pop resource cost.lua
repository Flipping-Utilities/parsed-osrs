-- <nowiki>
local p = {}

local getArgs = require("Module:Arguments").getArgs;
local parseMultiplier = require("Module:PriceUtil").parseMultiplier;
local formatCalcvalue = require('Module:Calcvalue formatter').main

local function calcvalueNotes(item, calcval)
    local class = string.gsub(item, '%W', '')
    local note = 'Calculated value given on the [[' .. item .. '|article]] (generally based on GE prices of products): <span class="cv-formula-tog mw-customtoggle-' .. class .. '">[show/hide formula]</span>  <span class="mw-collapsible mw-collapsed" id="mw-customcollapsible-' .. class .. '"> <code>' .. formatCalcvalue(calcval) .. '</code></span>.'
    return note
end

local function compileCalcvalue(val)
    local str = string.gsub( string.gsub(val, '{', '{{'), '}', '}}')
    return string.gsub(str, '¦', '|')
end

local function queryCalcvalue(item)
    local calcval
    local res = bucket('infobox_pop_resource')
        .select('json')
        .where(bucket.Or({ 'page_name', item }))
        .where(bucket.Not({ 'json', bucket.Null() }))
        .limit(1)
        .run()
    if res and res[1] then
        local json = res[1]['json']
        local jsg, content = pcall(mw.text.jsonDecode, json)
        if not jsg then
            return {
                type = 'error',
                message = '`pcall(mw.text.jsonDecode, unit)` failed: ' .. content,
            }
        end

        calcval = content.xrate
    end

    if not calcval then
        error('No calculated value could be found for: ' .. item)
    end

    return compileCalcvalue(calcval)
end

local function evalCalcvalue(calcval, multi)
    local price
    if tonumber(calcval) then
        price = tonumber(calcval)
    else
        local x = calcval
        price = mw.getCurrentFrame():preprocess("{{#expr: " .. x .. " }}")
        if tonumber(price) then
            price = math.floor(price * 100 + 0.5) / 100
        else
            error('Error preprocessing calculated value: ' .. calcval)
        end
    end

    if type(multi) == "number" then
        price = multi * price;
    end

    return price
end

function p.calcvalue(frame)
    local args = getArgs(frame);
    local item = args[1];
    local multi = parseMultiplier(args[2]) or 1;

    local ret, _ = p._calcvalue(item, multi, false);
    return ret
end

function p._calcvalue(item, multi, show_notes)
    local calcval = queryCalcvalue(item)
    return evalCalcvalue(calcval, multi), (show_notes and calcvalueNotes(item, calcval) or nil);
end

return p