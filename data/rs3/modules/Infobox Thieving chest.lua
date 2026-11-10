--------------------------
-- Module for [[Template:Thieving chest info]]
--------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local paramtest = require('Module:Paramtest')
local infobox = require('Module:Infobox')
local scp = require('Module:Skill clickpic')._main
local qty = require('Module:Quantity box')._main
local editbutton = require('Module:Edit button')

local edit = editbutton("'''?''' (edit)")

local TIME_UNITS = {
    s = 1,
    sec = 1,
    secs = 1,
    second = 1,
    seconds = 1,
    m = 60,
    min = 60,
    mins = 60,
    minute = 60,
    minutes = 60,
    h = 3600,
    hr = 3600,
    hrs = 3600,
    hour = 3600,
    hours = 3600,
    d = 86400,
    dy = 86400,
    dys = 86400,
    day = 86400,
    days = 86400,
    w = 604800,
    wk = 604800,
    wks = 604800,
    week = 604800,
    weeks = 604800,
    mo = 2592000,
    mos = 2592000,
    month = 2592000,
    months = 2592000,
}

local function xp_disp(xp)
    if not infobox.isDefined(xp) then
        return qty(0) .. edit
    end

    return qty(xp)
end

-- Make list of clickpics for output
local function clickpicsarg(lvl)
    if not infobox.isDefined(lvl) then
        return nil
    end

    return scp('Thieving', lvl) .. ' <sup title="This requirement is boostable" style="cursor:help; text-decoration:underline dotted;">(b)</sup>'
end

local function numericarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    return tonumber(arg)
end

local function failedxp(xp)
    if not infobox.isDefined(xp) then
        return nil
    end

    return (math.floor(xp / 4) / 10) .. ' xp'
end

local function intermediatexp(xp)
    if not infobox.isDefined(xp) then
        return nil
    end

    return (math.floor(xp) / 10) .. ' xp'
end

local function finalxp(xp)
    if not infobox.isDefined(xp) then
        return nil
    end

    return (xp - (math.floor(xp) / 2)) .. ' xp'
end

local function timeValueToSeconds(value, unit, skipRounding)
    value = tostring(value or ''):gsub(',', '')
    value = tonumber(value)
    unit = string.lower(unit or ''):gsub('%.', '')

    local multiplier = TIME_UNITS[unit]
    if not value or not multiplier then
        return nil
    end

    local seconds = value * multiplier
    if skipRounding then
        return seconds
    end

    local ticks = math.floor(seconds / 0.6 + 0.5)

    return ticks * 6 / 10
end

local function respawnTimeArg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    arg = mw.text.trim(tostring(arg))
        :gsub('–', '-')
        :gsub('—', '-')
        :gsub('−', '-')

    local firstValue, firstUnit, secondValue, secondUnit = arg:match(
        '^([%d,]*%.?%d+)%s*([%a%.]*)%s*%-%s*' ..
        '([%d,]*%.?%d+)%s*([%a%.]*)%s*$'
    )

    if firstValue then
        if firstUnit == '' then
            firstUnit = secondUnit
        end

        if secondUnit == '' then
            secondUnit = firstUnit
        end

        local minimum = timeValueToSeconds(firstValue, firstUnit)
        local maximum = timeValueToSeconds(secondValue, secondUnit)

        if not minimum or not maximum then
            return nil
        end

        if minimum > maximum then
            minimum, maximum = maximum, minimum
        end

        return {
            minimum = minimum,
            maximum = maximum,
        }
    end

    firstValue, firstUnit, secondValue, secondUnit = arg:match(
        '^([%d,]*%.?%d+)%s*([%a%.]+)%s*,?%s+' ..
        '([%d,]*%.?%d+)%s*([%a%.]+)%s*$'
    )

    if firstValue then
        local firstSeconds = timeValueToSeconds(
            firstValue,
            firstUnit,
            true
        )
        local secondSeconds = timeValueToSeconds(
            secondValue,
            secondUnit,
            true
        )

        if not firstSeconds or not secondSeconds then
            return nil
        end

        return timeValueToSeconds(
            firstSeconds + secondSeconds,
            'seconds'
        )
    end

    local value, unit = arg:match('^([%d,]*%.?%d+)%s*([%a%.]+)%s*$')

    return timeValueToSeconds(value, unit)
end

local function dropversionparg(drop, ver)
    if infobox.isDefined(drop) then
        return drop
    elseif infobox.isDefined(ver) then
        return ver
    end

    return nil
end

local function addcategories(args, catargs, mand)
    local ret = {}

    table.insert(ret, 'Thieving')

    local cat_map = {
        -- Added if the parameter has content
        defined = {
        },
        -- Added if the parameter has no content
        notdefined = {
            level = 'Missing skill info values',
            time = 'Missing skill info values',
            xp = 'Needs experience info',
        },
    }

    -- Run and add mapped categories
    for n, v in pairs(cat_map.defined) do
        if catargs[n] and catargs[n].one_defined then
            table.insert(ret, v)
        end
    end
    for n, v in pairs(cat_map.notdefined) do
        if catargs[n] and catargs[n].all_defined == false then
            table.insert(ret, v)
        end
    end

    -- combine table and format category wikicode
    for i, v in ipairs(ret) do
        if v ~= '' then
            ret[i] = string.format('[[Category:%s]]', v)
        end
    end

    return table.concat(ret, '')
end

function p.main(frame)
    local args = frame:getParent().args
    return p._main(args)
end

function p._main(args)
    local ret = infobox.new(args)
    ret:defineParams {
        { name = 'name', func = 'name' },
        { name = 'level', func = { name = numericarg, params = { 'level' }, flag = 'd' } },
        { name = 'xp', func = { name = numericarg, params = { 'xp' }, flag = 'd' } },
        { name = 'xp_disp', func = { name = xp_disp, params = { 'xp' }, flag = 'd' } },
        { name = 'xp_failed', func = { name = failedxp, params = { 'xp' }, flag = 'd' } },
        { name = 'xp_intermediate', func = { name = intermediatexp, params = { 'xp' }, flag = 'd' } },
        { name = 'xp_final', func = { name = finalxp, params = { 'xp' }, flag = 'd' } },
        { name = 'xp_bucket', func = { name = tonumber, params = { 'xp' }, flag = 'd' } },
        { name = 'clickpics', func = { name = clickpicsarg, params = { 'level' }, flag = 'd' } },

        { name = 'timename', func = { name = paramtest.default_to, params = { 'timename', "Respawn time" }, flag = { 'p', 'r' } } },
        { name = 'time', func = 'hasContent' },
        { name = 'dropversion', func = { name = dropversionparg, params = { 'dropversion', 'version' }, flag = 'd' } },
    }

    ret:setNameCheck(false)
    ret:create()
    ret:cleanParams()

    ret:customButtonPlacement(true)
    ret:addButtonsCaption()

    ret:defineLinks { hide = true }

    ret:defineName('Thieving chest info')
    ret:addClass('thieving-chest-info left-info')

    ret:addDropLevelVars('thieving', 'level')

    local tblwidth = 20
    local tblleft = 9
    local tblright = 11

    ret
        :addRow {
            { tag = 'argh', content = 'name', class = 'infobox-header', colspan = tblwidth },
        }

        :pad(tblwidth)

        :addRow {
            { tag = 'th', content = 'Level required', colspan = tblleft },
            { tag = 'argd', content = 'clickpics', colspan = tblright },
        }

        :addRow {
            { tag = 'th', content = 'Total XP<br><small>(without failure)</small>', colspan = tblleft },
            { tag = 'argd', content = 'xp_disp', colspan = tblright },
        }

        :addRow {
            { tag = 'argh', content = 'timename', colspan = tblleft },
            { tag = 'argd', content = 'time', colspan = tblright },
        }

    if ret:param('xp') ~= nil then
        -- XP breakdown
        ret:pad(tblwidth)
            :addRow {
                { tag = 'th', content = 'XP breakdown', class = 'infobox-subheader', colspan = tblwidth },
            }
            :pad(tblwidth)

            :addRow {
                { tag = 'th', content = 'Failure', colspan = tblleft },
                { tag = 'argd', content = 'xp_failed', colspan = tblright },
            }

            :addRow {
                { tag = 'th', content = 'Intermediate steps', colspan = tblleft },
                { tag = 'argd', content = 'xp_intermediate', colspan = tblright },
            }

            :addRow {
                { tag = 'th', content = 'Final step', colspan = tblleft },
                { tag = 'argd', content = 'xp_final', colspan = tblright },
            }
    end

    ret:pad(tblwidth)

    ret:finish()

    if onmain() then
        local a1 = ret:param('all')
        local a2 = ret:categoryData()
        ret:wikitext(addcategories(a1, a2))
    end
    return ret:tostring()
end

return p