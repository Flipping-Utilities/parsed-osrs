local p = {}

local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')
local plink = require("Module:Plink")._plink
local skillpic = require('Module:Skill clickpic')._main
local var = mw.ext.VariablesLua
local lang = mw.language.getContentLanguage()
local isDefined = infobox.isDefined

local exchangearg, exchangedisp, exchangeamlodd, exchangebucket, exchangelvlarg, exchangelvldisp
local specialarg, specialnamedisp, specialpointdisp, specialdisp, castxpdisp
local familiarsarg, familiardisp, typedisp, pouchdisp, leveldisp
local specialcooldowndisp, autofiredisp, addcategories

local left = '8'
local right = '14'
local full = '22'

local function q_mark(text)
    text = text:gsub('"', '&quot;')
    return ' <sup class="hover-text noprint small" title="' .. text .. '">[?]</sup>'
end

local function positive_integer(arg)
    local num = tonumber(arg)

    if num == nil or num < 0 then
        return nil
    end

    local num2 = math.floor(num)
    if num ~= num2 then
        return nil
    end

    return num
end

local function familiar_lookup(arg)
    local result = bucket('infobox_familiar')
        .select('page_name', 'json')
        .where('scroll', arg)
        .run()

    if result ~= nil and #result >= 1 then
        local ret = {}
        local json
        local familiars = {}
        -- de-duplicate by pages only
        local pages = {}

        -- Consolidate familiar records
        for _, item in ipairs(result) do
            json = mw.text.jsonDecode(item.json)

            local page = item.page_name
            if not pages[page] then
                table.insert(familiars, {
                    link = item.page_name,
                    name = json.name,
                    level = json.level,
                    pouch = json.pouch,
                })

                pages[page] = true
            end
        end

        ret.familiars = familiars
        -- Take the last sample
        ret.special = json.special
        ret.special_name = json.special_name
        ret.special_cost = json.special_cost
        ret.special_cd = json.special_cd
        ret.cast_xp = json.cast_xp
        ret.autofire = json.autofire
        ret.type = json.type

        return ret
    end

    return nil
end

function p.main(frame)
    local args = frame:getParent().args
    return p._main(args)
end

function p._main(args)
    local familiar = infobox.new(args)
    familiar:defineParams {
        { name = 'name', func = 'name' }, -- Module:Infobox default
        { name = 'exchange', func = { name = exchangearg, params = { 'exchange', 'exchangefrom' }, flag = { 'd', 'd' } } },
        { name = 'exchange_disp', func = { name = exchangedisp, params = { 'exchange' }, flag = { 'd' } } },
        { name = 'exchange_amlodd', func = { name = exchangeamlodd, params = { 'exchange' }, flag = { 'd' } } },
        { name = 'exchange_bucket_from', func = { name = exchangebucket, params = { 'exchange', 'from' }, flag = { 'd', 'l' } } },
        { name = 'exchange_bucket_to', func = { name = exchangebucket, params = { 'exchange', 'to' }, flag = { 'd', 'l' } } },
        { name = 'exchange_level', func = { name = exchangelvlarg, params = { 'exchangelvl', 'exchange' }, flag = { 'd' } } },
        { name = 'exchange_level_disp', func = { name = exchangelvldisp, params = { 'exchange_level' }, flag = { 'd' } } },

        { name = 'special', func = { name = specialarg, params = { 'name' }, flag = { 'd' } } },
        { name = 'special_disp', func = { name = specialdisp, params = { 'special' }, flag = { 'd' } } },
        { name = 'special_name', func = { name = specialnamedisp, params = { 'special' }, flag = { 'd' } } },
        { name = 'special_point', func = { name = specialpointdisp, params = { 'special' }, flag = { 'd' } } },
        { name = 'special_cd', func = { name = specialcooldowndisp, params = { 'special' }, flag = { 'd' } } },
        { name = 'cast_xp', func = { name = castxpdisp, params = { 'special' }, flag = { 'd' } } },
        { name = 'autofire', func = { name = autofiredisp, params = { 'special' }, flag = { 'd' } } },

        { name = 'familiars', func = { name = familiarsarg, params = { 'special' }, flag = { 'd' } } },
        { name = 'level', func = { name = familiarlevelarg, params = { 'familiars' }, flag = { 'd' } } },
        { name = 'type', func = { name = typedisp, params = { 'special' }, flag = { 'd' } } },
    }

    familiar:useBucket('infobox_summoning_trade_in', {
        name = 'name',
        exchange_bucket_from = 'from',
        exchange_bucket_to = 'to',
        exchange_level = 'level',
    })

    familiar:create()
    familiar:cleanParams()
    familiar:addButtonsCaption()

    familiar:defineLinks()

    familiar:defineName('Infobox Summoning pouch')
    familiar:addClass('infobox-summoning-pouch left-info')

    -- PARAMETER: name
    familiar:addRow {
        { tag = 'argh', content = 'name', class = 'infobox-header', colspan = full },
    }

    local spec = familiar:param('special')
    if spec == 'none' then
        familiar:addRow {
            { tag = 'td', content = "''No special move''", colspan = full, class = 'text-align-center' },
        }
    else
        familiar:pad(full)
        -- PARAMETER: special_name
        familiar:addRow {
            { tag = 'th', content = 'Special move', colspan = left },
            { tag = 'argd', content = 'special_name', colspan = right },
        }

        -- PARAMETER: special_point
        familiar:addRow {
            { tag = 'th', content = 'Cost', colspan = left },
            { tag = 'argd', content = 'special_point', colspan = right },
        }

        local cast_xp = familiar:param('cast_xp')
        if isDefined(cast_xp) then
            -- PARAMETER: cast_xp
            familiar:addRow {
                { tag = 'th', content = 'Cast XP', colspan = left },
                { tag = 'argd', content = 'cast_xp', colspan = right },
            }
        end

        -- PARAMETER: autofire
        familiar:addRow {
            { tag = 'th', content = 'Autofire', colspan = left },
            { tag = 'argd', content = 'autofire', colspan = right },
        }

        -- PARAMETER: special_cd
        if familiar:paramDefined('cooldown') then
            familiar:addRow {
                { tag = 'th', content = 'Cooldown', colspan = left },
                { tag = 'argd', content = 'special_cd', colspan = right },
            }
        end

        familiar:addRow {
            { tag = 'argd', content = 'special_disp', colspan = full },
        }
    end

    local param_familiars = familiar:param('familiars')
    local fam_multi = #param_familiars > 1
    for i, fam in ipairs(param_familiars) do
        local subtitle
        if fam_multi then
            subtitle = 'Familiar ' .. i
        else
            subtitle = 'Familiar'
        end

        -- Familiar subheader
        familiar:addRow { { tag = 'th', content = subtitle, colspan = full, class = 'infobox-subheader' } }
        familiar:pad(full)

        familiar:addRow {
            { tag = 'th', content = 'Name', colspan = left },
            { tag = 'td', content = familiardisp(fam), colspan = right },
        }

        familiar:addRow {
            { tag = 'th', content = 'Level', colspan = left },
            { tag = 'td', content = leveldisp(fam), colspan = right },
        }

        familiar:addRow {
            { tag = 'th', content = 'Pouch', colspan = left },
            { tag = 'td', content = pouchdisp(fam), colspan = right },
        }

        familiar:pad(full)
    end

    -- Shard exchange
    familiar:addRow { { tag = 'th', content = '[[Summoning Trade In]]', colspan = full, class = 'infobox-subheader' } }

    if familiar:param('exchange_disp') == 'N/A' then
        familiar:addRow {
            { tag = 'td', content = "''Not available''", colspan = full, class = 'text-align-center' },
        }
    else
        familiar:pad(full)
        familiar:addRow {
            { tag = 'th', content = '[[Bogrog]]', colspan = left },
            { tag = 'argd', content = 'exchange_disp', colspan = right },
        }

        if isDefined(familiar:param('exchange_amlodd')) then
            familiar:addRow {
                { tag = 'th', content = '[[Lord Amlodd|Amlodd]]' .. q_mark('Rounding down. This benefit is only available after completion of the hard Tirannwn achievements.'), colspan = left },
                { tag = 'argd', content = 'exchange_amlodd', colspan = right },
            }
        end

        if isDefined(familiar:param('exchange_level')) then
            familiar:addRow {
                { tag = 'th', content = 'Required level', colspan = left },
                { tag = 'argd', content = 'exchange_level_disp', colspan = right },
            }
        end
        familiar:pad(full)
    end

    familiar:addDropLevelVars('summoning', 'level')

    familiar:finish()
    if onmain() then
        local a1 = familiar:param('all')
        local a2 = familiar:categoryData()
        familiar:wikitext(addcategories(a1, a2))
    end

    return familiar:tostring()
end

function typedisp(arg)
    local typ = arg.type
    if typ == 'standard' then
        return 'Standard'
    elseif typ == 'ancient' then
        return '[[Ancient Summoning|Ancient]]'
    elseif typ == 'stealing creation' then
        return '[[Stealing Creation]]'
    elseif typ == 'daemonheim' then
        return '[[Dungeoneering/Summoning|Daemonheim]]'
    else
        return 'Unknown'
    end
end

function specialarg(arg)
    if not isDefined(arg) then
        return nil
    end

    local familiar = familiar_lookup(arg)
    if familiar == nil then
        return nil
    end

    return familiar
end

function familiarsarg(arg)
    if not isDefined(arg) then
        return {}
    end

    return arg.familiars
end

function familiarlevelarg(arg)
    if not isDefined(arg) then
        return nil
    end

    local level = 150
    for _, fam in ipairs(arg) do
        if level > fam.level then
            level = fam.level
        end
    end

    var.vardefine('summoning_level', level)
    return level
end

function pouchdisp(arg)
    if not isDefined(arg) then
        return nil
    end

    local pouch = arg.pouch
    if pouch == nil then
        return nil
    end

    return plink(pouch)
end

function leveldisp(arg)
    if not isDefined(arg) then
        return 'Unknown'
    end

    local level = arg.level
    return skillpic('Summoning', level, true)
end

function exchangearg(exchange, exchangefrom)
    if not isDefined(exchange) then
        return nil
    end

    local lcarg = string.lower(exchange)
    if lcarg == "no" or lcarg == "none" or lcarg == "n/a" then
        return 'N/A'
    end

    if not isDefined(exchangefrom) then
        exchangefrom = 1
    end

    return { from = positive_integer(exchangefrom), to = positive_integer(exchange) }
end

function exchangedisp(arg)
    if not isDefined(arg) then
        return nil
    end

    if arg == 'N/A' then
        return 'N/A'
    end

    if arg.from ~= nil and arg.from ~= 1 then
        return arg.from .. ' for ' .. arg.to
    elseif arg.to ~= nil then
        return arg.to
    else
        return nil
    end
end

function exchangeamlodd(arg)
    if not isDefined(arg) then
        return nil
    end

    if arg == 'N/A' then
        return nil
    end

    if arg.from ~= nil and arg.from ~= 1 then
        return arg.from .. ' for ' .. math.floor(arg.to * 11) / 10
    elseif arg.to ~= nil then
        return math.floor(arg.to * 11) / 10
    else
        return nil
    end
end

function exchangebucket(arg, key)
    if not isDefined(arg) then
        return nil
    end

    if arg == 'N/A' then
        return false
    end

    var.vardefine('exchange_amount_' .. key, arg[key])
    return arg
end

function exchangelvlarg(level_arg, exchange)
    if not isDefined(level_arg) then
        return nil
    end

    if not isDefined(exchange) or exchange == 'N/A' then
        return nil
    end

    local level = positive_integer(level_arg)
    var.vardefine('exchange_summoning_level', level)
    return level
end

function exchangelvldisp(arg)
    if not isDefined(arg) then
        return nil
    end

    return skillpic('Summoning', arg, true)
end

function specialdisp(arg)
    if not isDefined(arg) then
        return 'Unknown'
    end

    local spec = arg.special
    if spec == nil then
        return 'Unknown'
    end

    return arg.special
end

function castxpdisp(arg)
    if not isDefined(arg) then
        return 'Unknown'
    end

    -- Skip Dungeoneering familiars at this moment
    if arg.type == 'daemonheim' then
        return nil
    end

    return arg.cast_xp
end

function autofiredisp(arg)
    if not isDefined(arg) then
        return 'Unknown'
    end

    local autofire = arg.autofire
    if autofire == 'familiar attacks' then
        return 'Familiar attacks'
    elseif autofire == 'seconds' then
        return 'Seconds'
    elseif autofire == 'none' then
        return 'None'
    else
        return 'Unknown'
    end
end

function familiardisp(arg)
    if not isDefined(arg) then
        return nil
    end

    return '[[' .. arg.link .. '|' .. arg.name .. ']]'
end

function specialpointdisp(arg)
    if not isDefined(arg) then
        return 'Unknown'
    end

    local special_cost = arg.special_cost
    if special_cost == nil then
        return 'Unknown'
    end

    return arg.special_cost .. ' [[Special moves#Points|special move points]]' ..
        '<br>' .. math.floor(arg.special_cost * 0.8) .. ' points (with [[spirit cape]])'
end

function specialnamedisp(arg)
    if not isDefined(arg) then
        return 'Unknown'
    end

    return arg.special_name
end

function specialcooldowndisp(arg)
    if not isDefined(arg) then
        return 'Unknown'
    end

    local cooldown = arg.special_cd
    if cooldown == nil or cooldown == 0 then
        return "None"
    else
        return string.format('[[File:Ability timer.png|20px]] %ss', lang:formatNum(cooldown), cooldown == 1 and 'tick' or 'ticks', lang:formatNum(cooldown * 0.6))
    end
end

local function find_pattern(val, pattern)
    return isDefined(val) and string.find(string.lower(tostring(val) or ''), pattern)
end

local function find_pattern_raw(val, pattern)
    if type(val) == "table" then
        for _, x in ipairs(val) do
            if find_pattern_raw(x, pattern) then
                return true
            end
        end
    else
        return find_pattern(val, pattern)
    end
end

local function check_catargs(arg, check_func)
    if not arg then
        return false
    end

    local val = arg.d
    if check_func(val) then
        return true
    end

    if arg.switches then
        for _, x in ipairs(arg.switches) do
            if check_func(x) then
                return true
            end
        end
    end

    return false
end

local function grep_args(arg, pattern)
    return check_catargs(arg, function(val)
        return find_pattern_raw(val, pattern)
    end)
end

local function check_one_existence(arg)
    return check_catargs(arg, isDefined)
end

function addcategories(args, catargs)
    local ret = { 'Summoning scrolls' }

    local cat_map = {
        -- Added if the parameter has content
        defined = {
            exchange_level = 'Summoning scrolls that can be traded in',
        },
        -- Added if the parameter has no content
        notdefined = {
            exchange = 'Summoning scrolls missing exchange',
        },
        -- Parameters that have text
        -- map a category to a value
        grep = {
            exchange = {
                ['n/a'] = 'Summoning scrolls that cannot be traded in',
            },
        },
    }

    -- Run and add mapped categories
    for n, v in pairs(cat_map.defined) do
        if check_one_existence(args[n]) then
            table.insert(ret, v)
        end
    end

    for n, v in pairs(cat_map.notdefined) do
        if catargs[n] and catargs[n].all_defined == false then
            table.insert(ret, v)
        end
    end

    -- searches
    for n, v in pairs(cat_map.grep) do
        for m, w in pairs(v) do
            if grep_args(args[n], m) then
                table.insert(ret, w)
            end
        end
    end

    -- combine table and format category wikicode
    for i, v in ipairs(ret) do
        if (v ~= '') then
            ret[i] = string.format('[[Category:%s]]', v)
        end
    end

    return table.concat(ret, '')
end

return p