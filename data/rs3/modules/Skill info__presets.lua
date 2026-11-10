local p = {}

local paramtest = require('Module:Paramtest')
local yesno = require('Module:Yesno')
local scp = require('Module:Skill clickpic')._main
local editbutton = require('Module:Edit button')
local edit = editbutton("'''?''' (edit)")

-- string.lower which also accepts `nil` values without erroring
local function lc(str)
    return str and string.lower(str)
end

-- multiply num by mul, rounded to 1 decimal
local function times(num, mul)
    return math.floor((tonumber(num) or 0) * mul * 10) / 10
end

local function overwrite2(args, map, labels)
    local newargs = {}
    -- by default, translate |version= to |bucketname= for all presets
    if paramtest.has_content(args.version) then
        map.version = 'bucketname'
    end
    -- make a copy to work in
    for prop, val in pairs(args) do
        mw.logObject({ prop, val })
        local num = string.match(prop, "%d+$") or ''
        local nonum = string.gsub(prop, num .. '$', '')
        local mapped = map[nonum]
        if mapped and not tonumber(mapped[#mapped]) then
            -- only add the number back if the map target doesn't already specify a switch number
            mapped = mapped .. num
        end
        if mapped then
            -- if a map exists, insert the specified value from this parameter.
            -- If the user manually set this parameter already, don't override
            newargs[mapped] = args[mapped] or val
        else
            -- not in the list to copy, so no mapping to do; simply copy it from the original
            newargs[prop] = val
        end
    end
    -- copy labels array to newargs, if not already set
    for prop, val in pairs(labels) do
        -- overwrite only if the destination is not already defined
        newargs[prop] = newargs[prop] or val
    end
    return newargs
end

local function clickpicsarg(names, lvls)
    local ret = ''
    for i, lvl in ipairs(lvls) do
        local name = names[i]
        if paramtest.has_content(name) and paramtest.has_content(lvl) then
            ret = ret .. scp(name, lvl)
        end
    end
    if ret ~= '' then
        return ret
    else
        return edit
    end
end

function p.agility(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
        course = 'loc',
    }
    local labels = {
        skill1name = "Agility",
        locname = "[[Agility#Agility courses|Agility course]]",
    }
    local mustargs = {
        'type',
    }

    if paramtest.has_content(args.failxp) then
        labels.version1 = "Success"
        labels.skill1lvl1 = args.level
        labels.skill1exp1 = args.xp
        labels.skill1note1 = args.xpnote

        labels.version2 = "Failure"
        labels.skill1lvl2 = args.level
        labels.skill1exp2 = args.failxp
        labels.skill1label2 = "XP on failure"
    end
    return overwrite2(args, map, labels), mustargs
end

function p.divination(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
    }
    local labels = {
        skill1name = "Divination",
    }
    local mustargs = {
    }
    mw.logObject({ map, labels, mustargs })
    return overwrite2(args, map, labels), mustargs
end

function p.farming(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
    }
    local labels = {
        skill1name = "Farming",
    }
    local mustargs = {
    }
    mw.logObject({ map, labels, mustargs })
    return overwrite2(args, map, labels), mustargs
end

function p.firemaking(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
    }
    local labels = {
        skill1name = "Firemaking",
        tool = "[[Tinderbox]]",
    }
    local mustargs = {
        'tool', 'type'
    }

    -- Variants
    if lc(args.type) == 'logs' then
        labels.facility = "N/A"
        labels.tool = "[[Tinderbox]]"
        labels.skill1name = "Firemaking"

        labels.version1 = "Light fire"
        labels.skill1lvl1 = args.level
        labels.skill1exp1 = tonumber(args.xp)
        labels.time1 = 'N/A'

        local variant_n = 2

        if (args.bonfirexp) then
            labels["version" .. variant_n] = "Bonfire"
            labels["skill1lvl" .. variant_n] = args.level
            labels["skill1exp" .. variant_n] = tonumber(args.bonfirexp) or -1
            labels["facility" .. variant_n] = "[[Bonfire]]"
            labels["time" .. variant_n] = args.bonfireinterval
            labels["timename"] = 'Bonfire interval'
            variant_n = variant_n + 1
            table.insert(mustargs, 'time')
        end

        if (args.bowlevel) then
            labels["version" .. variant_n] = "Bow"
            labels["tool" .. variant_n] = "[[Bow]]"
            labels["skill1lvl" .. variant_n] = args.bowlevel
            labels["skill1exp" .. variant_n] = tonumber(args.xp)
            labels["skill1note" .. variant_n] = "Requires [[Barbarian Firemaking]] training.<br>" ..
                (args.xpnote2 or args.xpnote or '')
            labels["time" .. variant_n] = 'N/A'
            variant_n = variant_n + 1
        end

        if (args.pyrelevel) then
            labels.skill2name = "Crafting"
            labels["version" .. variant_n] = "Pyre ship"
            labels["tool" .. variant_n] = "[[Tinderbox]] or [[bow]], and a [[hatchets|hatchet]]"
            labels["skill1note" .. variant_n] = "Requires [[Barbarian Firemaking]] training.<br>" ..
                (args.xpnote2 or args.xpnote or '')
            labels["skill2lvl" .. variant_n] = args.pyrelevel
            labels["skill2exp" .. variant_n] = args.craftxp
            labels["facility" .. variant_n] = "[[Pyre boat#Site|Pyre site]]"
            labels["time" .. variant_n] = 'N/A'
        end

        if args.bonfire then
            table.insert(mustargs, 'skill1exp2')
        end
    elseif lc(args.type) == 'pyre' then
        labels.facility = "[[Funeral pyre (Mort'ton)|Mort'ton funeral pyre]]"
        labels.skill2name = "Prayer"
        labels.skill2lvl = '1'
    elseif lc(args.type) == 'light' then
        labels.skill1exp = '0'
    end
    local newargs = overwrite2(args, map, labels)
    if lc(newargs.tool) == 'no' then newargs.tool = 'N/A' end
    local types = {
        logs = 'Logs',
        pyre = '[[Pyre logs]]',
        light = '[[Light sources|Light source]]',
        other = 'Other',
    }
    newargs.type = types[lc(args.type)]
    return newargs, mustargs
end

function p.fishing(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
        spot = 'facility',
        bait = 'item',
    }
    local labels = {
        skill1name = "Fishing",
        facilityname = "[[Fishing spot]]",
        itemname = 'Bait',
        productname = "Fish",
    }
    local mustargs = {
        'tool',
        'item',
    }
    local newargs = overwrite2(args, map, labels)
    if lc(newargs.tool) == 'no' then newargs.tool = 'N/A' end
    if lc(newargs.item) == 'no' then newargs.item = 'N/A' end
    return newargs, mustargs
end

function p.hunter(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
        retaliation = 'type',
        trap = 'tool',
    }
    local labels = {
        skill1name = "Hunter",
        typename = "Retaliation",
        toolname = "Trap",
        productname = "Catch",
    }
    local mustargs = {
        'tool',
        'type',
    }
    if paramtest.has_content(args.bait) then
        labels.itemname = "Bait"
        map.bait = 'item'
    elseif paramtest.has_content(args.container) then
        labels.itemname = "Container"
        map.container = 'item'
    elseif paramtest.has_content(args.pref_bait) then
        labels.itemname = "Preferred bait"
        map.pref_bait = 'item'
    end
    if string.find(lc(args.name) or '', 'impling') then
        -- Net catching implings
        labels.version1 = 'Net (Overworld)'
        labels.skill1lvl1 = args.level1 or tonumber(args.level)
        labels.skill1exp1 = args.wildxp
        labels.skill1label1 = "Overworld XP"
        labels.type1 = "None"
        labels.tool1 = "None"
        local variant_index = 2
        if string.lower(args.name) ~= 'snow impling' and string.lower(args.name) ~= 'crystal impling' and string.lower(args.name) ~= 'ghost impling' then
            -- Net catching implings in Puro-Puro
            labels["version" .. variant_index] = 'Net (Puro-Puro)'
            labels["skill1lvl" .. variant_index] = labels.skill1lvl1
            labels["skill1exp" .. variant_index] = args.xp
            labels["skill1label" .. variant_index] = '[[Puro-Puro]] XP'
            labels["type" .. variant_index] = '[[Imp defender]]s in [[Puro-Puro]]'
            labels["tool" .. variant_index] = args.trap
            variant_index = variant_index + 1
        end

        -- Barehanded catching
        labels["version" .. variant_index] = "Barehanded"
        labels["skill1lvl" .. variant_index] = labels.skill1lvl1
        labels["skill1exp" .. variant_index] = labels.skill1exp1
        labels["skill1label" .. variant_index] = "Overworld XP"
        labels["type" .. variant_index] = "None"
        labels["tool" .. variant_index] = "None"
    end
    local newargs = overwrite2(args, map, labels)
    -- default for barehanded is the same as specified level. Due to not being a direct param value this can't be done through the normal `map` array.
    return newargs, mustargs
end

function p.mining(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
        rock = 'facility',
    }
    local labels = {
        skill1name = "Mining",
        facilityname = "Rock",
    }
    local mustargs = {
        'tool',
        'time',
    }
    mw.logObject({ map, labels, mustargs })
    return overwrite2(args, map, labels), mustargs
end

function p.necromancy(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
        spot = 'facility',
    }
    local labels = {
        skill1name = "Necromancy",
    }
    local mustargs = {}
    local newargs = overwrite2(args, map, labels)
    if lc(newargs.tool) == 'no' then newargs.tool = 'N/A' end
    if lc(newargs.item) == 'no' then newargs.item = 'N/A' end
    return newargs, mustargs
end

function p.prayer(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
    }
    local labels = {
        skill1name = "Prayer",
    }
    -- Customisations based on the type of prayer object
    if lc(args.type) == 'bone' or lc(args.type) == 'dragon bone' or lc(args.type) == 'ashes' then
        -- Switch infobox with different ways to offer bones

        local currentSwitch = 1
        -- Default switch
        if lc(args.type) == 'bone' or lc(args.type) == 'dragon bone' then
            labels.version1 = "Burying"
        else
            labels.version1 = "Scattering"
        end
        labels['skill1lvl' .. currentSwitch] = args.level
        labels['skill2exp' .. currentSwitch] = -1
        labels['skill3exp' .. currentSwitch] = -1
        labels['item' .. currentSwitch] = "N/A"
        labels['facility' .. currentSwitch] = "N/A"
        labels['tool' .. currentSwitch] = "N/A"

        -- Dragon Rider amulet
        if lc(args.type) == 'dragon bone' then
            currentSwitch = currentSwitch + 1

            labels['version' .. currentSwitch] = "Dragon Rider amulet"
            labels['skill1lvl' .. currentSwitch] = args.level
            labels['skill1exp' .. currentSwitch] = times(args.xp, 2)
            labels['skill2exp' .. currentSwitch] = -1
            labels['skill3exp' .. currentSwitch] = -1
            labels['item' .. currentSwitch] = "N/A"
            labels['facility' .. currentSwitch] = "N/A"
            labels['tool' .. currentSwitch] = "[[Dragon Rider amulet]]"
        end

        -- Auto-sanctifier
        currentSwitch = currentSwitch + 1

        labels['version' .. currentSwitch] = "Auto-sanctifier"
        labels['skill1lvl' .. currentSwitch] = args.level
        labels['skill1exp' .. currentSwitch] = times(args.xp, 3.5)
        labels['skill2exp' .. currentSwitch] = -1
        labels['skill3exp' .. currentSwitch] = -1
        labels['item' .. currentSwitch] = "N/A"
        labels['facility' .. currentSwitch] = "N/A"
        labels['tool' .. currentSwitch] = "[[Auto-sanctifier]]"

        -- Powder of burials
        if lc(args.type) == 'bone' or lc(args.type) == 'dragon bone' then
            currentSwitch = currentSwitch + 1

            labels['version' .. currentSwitch] = "Powder of burials"
            labels['skill1lvl' .. currentSwitch] = args.level
            labels['skill1exp' .. currentSwitch] = times(args.xp, 3.5)
            labels['skill2exp' .. currentSwitch] = -1
            labels['skill3exp' .. currentSwitch] = -1
            labels['item' .. currentSwitch] = "[[Powder of burials]]"
            labels['facility' .. currentSwitch] = "N/A"
            labels['tool' .. currentSwitch] = "N/A"
        end

        -- regular altar
        currentSwitch = currentSwitch + 1

        labels['version' .. currentSwitch] = "Regular altar"
        labels['skill1lvl' .. currentSwitch] = args.level
        labels['skill1exp' .. currentSwitch] = times(args.xp, 1.5)
        labels['skill2exp' .. currentSwitch] = -1
        labels['skill3exp' .. currentSwitch] = -1
        labels['item' .. currentSwitch] = "N/A"
        labels['facility' .. currentSwitch] = "[[Altar]]"
        labels['tool' .. currentSwitch] = "N/A"

        -- Gilded altar
        currentSwitch = currentSwitch + 1

        labels['version' .. currentSwitch] = "Gilded altar"
        labels['skill1lvl' .. currentSwitch] = args.level
        labels['skill1label' .. currentSwitch] = "Two [[Chapel#Lamps|burners]]"
        labels['skill1exp' .. currentSwitch] = times(args.xp, 3.5)
        labels['skill2name' .. currentSwitch] = "Prayer"
        labels['skill2lvl' .. currentSwitch] = args.level
        labels['skill2label' .. currentSwitch] = "No [[Chapel#Lamps|burners]]"
        labels['skill2exp' .. currentSwitch] = times(args.xp, 2.5)
        labels['skill3exp' .. currentSwitch] = -1
        labels['item' .. currentSwitch] = "[[Clean marrentill]]"
        labels['facility' .. currentSwitch] = "[[Gilded altar]]"
        labels['tool' .. currentSwitch] = "N/A"

        -- Chaos altar
        currentSwitch = currentSwitch + 1

        labels['version' .. currentSwitch] = "Chaos altar"
        labels['skill1lvl' .. currentSwitch] = args.level
        labels['skill1exp' .. currentSwitch] = times(args.xp, 3.5)
        labels['skill2exp' .. currentSwitch] = -1
        labels['skill3exp' .. currentSwitch] = -1
        labels['item' .. currentSwitch] = "N/A"
        labels['facility' .. currentSwitch] = "[[Chaos altar (Wilderness)]]"
        labels['tool' .. currentSwitch] = "N/A"

        -- Fort Forinthry Chapel
        currentSwitch = currentSwitch + 1

        labels['version' .. currentSwitch] = "Fort Forinthry Chapel"
        labels['skill1lvl' .. currentSwitch] = args.level
        labels['skill1label' .. currentSwitch] = "Tier 1"
        labels['skill1exp' .. currentSwitch] = times(args.xp, 2.0)
        labels['skill2name' .. currentSwitch] = "Prayer"
        labels['skill2lvl' .. currentSwitch] = args.level
        labels['skill2label' .. currentSwitch] = "Tier 2"
        labels['skill2exp' .. currentSwitch] = times(args.xp, 2.5)
        labels['skill3name' .. currentSwitch] = "Prayer"
        labels['skill3lvl' .. currentSwitch] = args.level
        labels['skill3label' .. currentSwitch] = "Tier 3"
        labels['skill3exp' .. currentSwitch] = times(args.xp, 3.0)
        labels['item' .. currentSwitch] = "N/A"
        labels['facility' .. currentSwitch] = "[[Altar (Fort Forinthry)|Fort Forinthry altar]]"
        labels['tool' .. currentSwitch] = "N/A"

        -- Ectofuntus
        if lc(args.ectofuntus) ~= 'no' then
            currentSwitch = currentSwitch + 1

            labels['version' .. currentSwitch] = 'Ectofuntus'
            labels['skill1lvl' .. currentSwitch] = args.level
            labels['skill1exp' .. currentSwitch] = times(args.xp, 4)
            labels['skill2exp' .. currentSwitch] = -1
            labels['skill3exp' .. currentSwitch] = -1
            labels['item' .. currentSwitch] = "[[Bucket of slime]]"
            labels['facility' .. currentSwitch] = "[[Ectofuntus]]"
            labels['tool' .. currentSwitch] = "N/A"
        end

        -- Cremation
        if lc(args.cremation) ~= 'no' and (lc(args.type) == 'bone' or lc(args.type) == 'dragon bone') then
            currentSwitch = currentSwitch + 1

            labels['skill4name' .. currentSwitch] = "Firemaking"
            labels['skill4lvl' .. currentSwitch] = 1
            labels['version' .. currentSwitch] = 'Cremation'
            labels['skill1exp' .. currentSwitch] = times(args.xp, 2.5)
            labels['skill2exp' .. currentSwitch] = -1
            labels['skill3exp' .. currentSwitch] = -1
            labels['skill4exp' .. currentSwitch] = times(args.xp, 2)
            labels['item' .. currentSwitch] = "None"
            labels['facility' .. currentSwitch] = "[[Bonfire]], [[Portable brazier]]"
            labels['tool' .. currentSwitch] = "N/A"
        end
    elseif lc(args.type) == 'bonemeal' then
        labels.item = "[[Bucket of slime]]"
        labels.facility = "[[Ectofuntus]]"
    elseif lc(args.type) == 'monster' then
        labels.tool = "[[Ectoplasmator]]"
    elseif lc(args.type) == 'guthix balance' then
        labels.item = "[[Guthix balance]]"
    elseif lc(args.type) == 'dungeoneering' then
        -- Dungeoneering ashes, clears out the other params
    end
    mw.logObject({ map, labels, args })
    local mustargs = {
        'type',
    }
    local newargs = overwrite2(args, map, labels)
    local types = {
        bone = 'Bones',
        ['dragon bone'] = 'Bones',
        bonemeal = '[[Bonemeal]]',
        ashes = 'Ashes',
        dungeoneering = 'Ashes',
        monster = 'Monster',
        ['guthix balance'] = 'Potion',
        ['other'] = 'Other',
    }
    newargs.type = types[lc(args.type)]
    return newargs, mustargs
end

-- Thieving
local function lootlvl(lvl, loot)
    lvl = tonumber(lvl)
    loot = tonumber(loot)
    if lvl and loot then
        local thiev = lvl + loot
        local agil = thiev - 10
        if agil > 105 or thiev > 126 then -- max level + max boost
            -- boosting works for agility but cannot currently be tested for thieving due to the lower agil level cap
            return 'N/A'
        end
        return clickpicsarg({ 'Thieving', 'Agility' }, { thiev, agil })
    else
        return nil
    end
end

function p.thieving(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
        stun = 'time',
    }
    local labels = {
        skill1name = "Thieving",
        toolname = "Tool",
    }
    local mustargs = {
    }
    if lc(args.type) == 'pickpocket' then
        if not yesno(args.hidesticky, false) then
            local stickyXp = args.sticky or times(args.xp, 0.67)

            labels.version1 = "Normal"
            labels.skill1lvl1 = args.level
            labels.skill1exp1 = args.xp
            labels.skill1note1 = args.xpnote

            labels.version2 = "Sticky Fingers"
            labels.skill1lvl2 = args.level
            labels.skill1exp2 = stickyXp
        end
        labels.timename = "[[Stun|Stun time]]"
        table.insert(mustargs, 'time')
        table.insert(mustargs, 'damage')
        if yesno(args.multiloot, false) then
            map.multiloot_x2_levels = 'multiloot_x2_levels'
            map.multiloot_x3_levels = 'multiloot_x3_levels'
            map.multiloot_x4_levels = 'multiloot_x4_levels'
            labels.multiloot_x2_name = 'Double loot'
            labels.multiloot_x3_name = 'Triple loot'
            labels.multiloot_x4_name = 'Quadruple loot'
            labels.multiloot_x2_levels = lootlvl(args.level, 10)
            labels.multiloot_x3_levels = lootlvl(args.level, 20)
            labels.multiloot_x4_levels = lootlvl(args.level, 30)
        end
    end
    mw.logObject({ map, labels, args, mustargs })
    return overwrite2(args, map, labels), mustargs
end

function p.woodcutting(args)
    local map = {
        level = 'skill1lvl',
        boostable = 'skill1boostable',
        xp = 'skill1exp',
        xpnote = 'skill1note',
        xpnote_name = 'skill1note_name',
        tree = 'facility',
    }
    local labels = {
        skill1name = "Woodcutting",
        facilityname = "Tree",
        productname = "Logs",
    }
    local mustargs = {
        'tool',
        'time',
    }
    mw.logObject({ map, labels, mustargs })
    return overwrite2(args, map, labels), mustargs
end

return p