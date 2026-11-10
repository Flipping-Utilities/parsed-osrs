local p = {}

local minColWidth = '80px'
local maxColWidth = '150px'

-- Dictionary mapping raw attribute keys to formatted wiki links
local attributeMap = {
    demon    = '[[Demon (attribute)|Demon]]',
    dragon   = '[[Draconic (attribute)|Draconic]]',
    fiery    = '[[Fiery (attribute)|Fiery]]',
    flying   = '[[Flying (attribute)|Flying]]',
    golem    = '[[Golem (attribute)|Golem]]',
    icy      = '[[Icy (attribute)|Icy]]',
    kalphite = '[[Kalphite (attribute)|Kalphite]]',
    leafy    = '[[Leafy (attribute)|Leafy]]',
    penance  = '[[Penance (attribute)|Penance]]',
    rat      = '[[Rat (attribute)|Rat]]',
    shade    = '[[Shade (attribute)|Shade]]',
    spectral = '[[Spectral (attribute)|Spectral]]',
    undead   = '[[Undead (attribute)|Undead]]',
    vampyre1 = '[[Vampyre (attribute)|Vampyre (tier 1)]]',
    vampyre2 = '[[Vampyre (attribute)|Vampyre (tier 2)]]',
    vampyre3 = '[[Vampyre (attribute)|Vampyre (tier 3)]]',
    xerician = '[[Xerician (attribute)|Xerician]]',
}

-- Master mapping using the exact database field names from useBucket
local statDefinitions = {
    -- Core Attributes
    combat_level = { label = 'Combat Level', icon = 'Combat icon.png', bucketKey = 'combat_level' },
    size         = { label = 'Size', icon = 'Combat icon.png', bucketKey = 'size' },
    members      = { label = 'Members Only', icon = 'Old school bond.png', bucketKey = 'is_members_only' },
    examine      = { label = 'Examine', icon = 'Spell scroll.png', bucketKey = 'examine' },
    release      = { label = 'Release Date', icon = 'Invocations - time limit icon.png', bucketKey = 'release_date' },

    -- Combat Info
    hitpoints    = { label = 'Hitpoints', icon = 'Hitpoints icon.png', bucketKey = 'hitpoints' },
    max_hit      = { label = 'Max Hit', icon = 'Damage hitsplat (max hit).png', bucketKey = 'max_hit' },
    attack_style = { label = 'Attack Style', icon = 'Attack icon.png', bucketKey = 'attack_style' },
    attack_speed = { label = 'Attack Speed', icon = 'Attack icon.png', bucketKey = 'attack_speed' },
    attributes   = { label = 'Attributes', icon = 'Combat icon.png', bucketKey = 'attribute' },
    poisonous    = { label = 'Poisonous', icon = 'Poison hitsplat.png', bucketKey = 'poisonous' },
    xpbonus      = { label = 'XP Bonus', icon = 'Slayer icon.png', bucketKey = 'experience_bonus' },
    flatarmour   = { label = 'Flat Armour', icon = 'Defence icon.png', bucketKey = 'flat_armour' },

    -- Combat & Offensive Stats
    att          = { label = 'Attack', icon = 'Attack icon.png', bucketKey = 'attack_level' },
    str          = { label = 'Strength', icon = 'Strength icon.png', bucketKey = 'strength_level' },
    def          = { label = 'Defence', icon = 'Defence icon.png', bucketKey = 'defence_level' },
    mage         = { label = 'Magic', icon = 'Magic icon.png', bucketKey = 'magic_level' },
    range        = { label = 'Ranged', icon = 'Ranged icon.png', bucketKey = 'ranged_level' },
    attbns       = { label = 'Attack Bonus', icon = 'Attack icon.png', bucketKey = 'attack_bonus' },
    strbns       = { label = 'Strength Bonus', icon = 'Strength icon.png', bucketKey = 'strength_bonus' },
    amagic       = { label = 'Magic Attack', icon = 'Magic icon.png', bucketKey = 'magic_attack_bonus' },
    mbns         = { label = 'Magic Damage', icon = 'Magic Damage icon.png', bucketKey = 'magic_damage_bonus' },
    arange       = { label = 'Ranged Attack', icon = 'Ranged icon.png', bucketKey = 'range_attack_bonus' },
    rngbns       = { label = 'Ranged Strength', icon = 'Ranged Strength icon.png', bucketKey = 'range_strength_bonus' },

    -- Defensive Stats & Immunities
    def_stab     = { label = 'Stab Defence', icon = 'White dagger.png', bucketKey = 'stab_defence_bonus' },
    def_slash    = { label = 'Slash Defence', icon = 'White scimitar.png', bucketKey = 'slash_defence_bonus' },
    def_crush    = { label = 'Crush Defence', icon = 'White warhammer.png', bucketKey = 'crush_defence_bonus' },
    def_magic    = { label = 'Magic Defence', icon = 'Magic defence icon.png', bucketKey = 'magic_defence_bonus' },
    def_light    = { label = 'Light Ranged Defence', icon = 'Steel dart.png', bucketKey = 'light_range_defence_bonus' },
    def_standard = { label = 'Standard Ranged Defence', icon = 'Steel arrow 5.png', bucketKey = 'standard_range_defence_bonus' },
    def_heavy    = { label = 'Heavy Ranged Defence', icon = 'Steel bolts 5.png', bucketKey = 'heavy_range_defence_bonus' },
    elem_weak    = { label = 'Elemental Weakness', icon = 'Pure essence.png', bucketKey = 'elemental_weakness' },
    elem_pct     = { label = 'Weakness %', icon = 'Pure essence.png', bucketKey = 'elemental_weakness_percent'},
    poison_res   = { label = 'Poison Resist', icon = 'Poison hitsplat.png', bucketKey = 'poison_resistance' },
    venom_res    = { label = 'Venom Resist', icon = 'Venom hitsplat.png', bucketKey = 'venom_resistance' },
    cannon_imm   = { label = 'Cannon Immune', icon = 'Dwarf_multicannon.png', bucketKey = 'cannon_immune' },
    burn_imm     = { label = 'Burn Immune', icon = 'Fire rune.png', bucketKey = 'burn_immune' },
    freeze_res   = { label = 'Freeze Resist', icon = 'Water rune.png', bucketKey = 'freeze_resistance' }
}

local elementMap = {
    air   = '[[File:Air rune.png|30px|link=Air rune]]',
    water = '[[File:Water rune.png|30px|link=Water rune]]',
    earth = '[[File:Earth rune.png|30px|link=Earth rune]]',
    fire  = '[[File:Fire rune.png|30px|link=Fire rune]]'
}

local function getRequiredBucketKeys()
    local keys = { 'name', 'image' }
    local seen = { name = true, image = true }
    for _, def in pairs(statDefinitions) do
        if not seen[def.bucketKey] then
            table.insert(keys, def.bucketKey)
            seen[def.bucketKey] = true
        end
    end
    return keys
end

local function getMonsterData(monsterName)
    if not monsterName or monsterName == '' then
        return nil
    end

    local results = bucket('infobox_monster')
        .select(unpack(getRequiredBucketKeys()))
        .where('name', monsterName)
        .run()

    if results and #results > 0 then
        return results[1]
    end
    return nil
end

local function isBonusOrDefenceCol(colKey)
    local cols = {
        attbns = true, strbns = true, amagic = true, mbns = true, arange = true, rngbns = true,
        def_stab = true, def_slash = true, def_crush = true, def_magic = true,
        def_light = true, def_standard = true, def_heavy = true, flatarmour = true
    }
    return cols[colKey] == true
end

local function formatBucketValue(colKey, val)
    if val == nil or val == '' then
        return '-'
    end

    if val == true or val == 'true' then
        return 'Yes'
    elseif val == false or val == 'false' then
        return 'No'
    end

    -- Convert elemental weakness to rune images
    if colKey == 'elem_weak' then
        local elemVal = type(val) == 'table' and (val.d and val.d[1] or val[1]) or val
        if elemVal then
            local cleanElement = tostring(elemVal):lower()
            if elementMap[cleanElement] then
                return elementMap[cleanElement]
            end
        end
    end
    
    -- Show '% Weakness' next to elemental weakness percentage
    if colKey == 'elem_pct' then
        local elemPctVal = type(val) == 'table' and (val.d and val.d[1] or val[1]) or val
        if elemPctVal then
            return elemPctVal .. "% Weakness"
        end
    end

    -- Handle table values (like max_hit or attributes)
    if type(val) == 'table' then
        local items = val.d or val
        
        if colKey == 'max_hit' then
            if type(val) == 'table' then
                local rawText = tostring(items[1] or '')
                local totalNum = rawText:match("(%d+)%s*total") or rawText:match("^(%d+)")
                if totalNum then
                    return totalNum
                end
            end
        end

        if colKey == 'attributes' then
            local formattedItems = {}
            for _, item in ipairs(items) do
                local cleanItem = tostring(item):lower()
                table.insert(formattedItems, attributeMap[cleanItem] or tostring(item))
            end
            if #formattedItems > 0 then
                return table.concat(formattedItems, '<br>')
            end
        end

        if type(items) == 'table' then
            return table.concat(items, ', ')
        else
            return tostring(items)
        end
    end

    local num = tonumber(val)
    if num then
        if isBonusOrDefenceCol(colKey) and num > 0 then
            return '+' .. tostring(num)
        end
        return tostring(num)
    end

    return tostring(val)
end

local function buildHtmlTable(monsters, columnsConfig, align)
    local wrapper = mw.html.create('div')
        :css('overflow-x', 'auto')

    if align == 'right' then
        wrapper:addClass('floatright')
               :css('margin', '0 0 1em 1em')
    elseif align == 'left' then
        wrapper:addClass('floatleft')
               :css('margin', '0 1em 1em 0')
    elseif align == 'inline' then
        wrapper:css('display', 'inline-block')
               :css('vertical-align', 'top')
               :css('margin', '0.5em')
    end

    local tbl = wrapper:tag('table')
        :addClass('wikitable')
        :css('text-align', 'center')

    local headerRow = tbl:tag('tr')
    headerRow:tag('th')
        :css('min-width', '160px')
        :wikitext('Monster')
        :done()
    
    for _, colInfo in ipairs(columnsConfig) do
        local colKey = colInfo.key
        local showIcon = colInfo.showIcon
        
        local statDef = statDefinitions[colKey]
        if statDef then
            local th = headerRow:tag('th')
                :css('min-width', minColWidth)
                :css('max-width', maxColWidth)
                :css('box-sizing', 'border-box')
            if statDef.icon and showIcon then
                th:wikitext(string.format('[[File:%s|20px|link=|%s]]<br>%s', statDef.icon, statDef.label, statDef.label))
            else
                th:wikitext(statDef.label)
            end
            th:done()
        else
            headerRow:tag('th')
                :css('min-width', minColWidth)
                :css('max-width', maxColWidth)
                :css('box-sizing', 'border-box')
                :css('vertical-align', 'top')
                :wikitext(colKey)
                :done()
        end
    end

    for _, monsterName in ipairs(monsters) do
        local data = getMonsterData(monsterName)
        local row = tbl:tag('tr')
        
        local cellName = row:tag('td')
            :css('text-align', 'left')
            :css('min-width', '120px')
            :css('max-width', '140px')
            :css('white-space', 'normal')
            
        local imgVal = data and data.image
        if type(imgVal) == 'table' then
            imgVal = imgVal.d or imgVal[1]
        end
        
        local monsterLink = string.format('[[%s|%s]]', monsterName, monsterName)
        
        if imgVal and tostring(imgVal) ~= '' then
            imgVal = tostring(imgVal):gsub("^%[+%s*File:", ""):gsub("^File:", ""):gsub("%s*%]+$", "")
            
            local flexContainer = mw.html.create('div')
                :css('display', 'flex')
                :css('align-items', 'center')
                :css('gap', '8px')
                
            flexContainer:tag('div')
                :css('flex-shrink', '0')
                :wikitext(string.format('[[File:%s|75px|frameless|link=%s]]', imgVal, monsterName))
                
            flexContainer:tag('div')
                :wikitext(monsterLink)
                
            cellName:node(flexContainer)
        else
            cellName:wikitext(monsterLink)
        end
        cellName:done()

        for _, colInfo in ipairs(columnsConfig) do
            local colKey = colInfo.key
            local statDef = statDefinitions[colKey]
            local bucketKey = statDef and statDef.bucketKey or colKey
            local val = data and data[bucketKey]
            
            local formattedVal = formatBucketValue(colKey, val)
            row:tag('td')
                :css('min-width', minColWidth)
                :css('max-width', maxColWidth)
                :css('box-sizing', 'border-box')
                :wikitext(formattedVal)
                :done()
        end
    end

    return tostring(wrapper)
end

function p.main(frame)
    local args = frame.args
    
    local monsters = {}
    local monsterInput = args.monsters
    local align = args.align and args.align:lower() or ''
    
    if monsterInput and monsterInput ~= '' then
        for m in string.gmatch(monsterInput, '[^,]+') do
            local cleaned = m:gsub("^%s*", ""):gsub("%s*$", "")
            if cleaned ~= '' then
                table.insert(monsters, cleaned)
            end
        end
    end
    
    if #monsters == 0 then
        monsters = { 'General Graardor', "K'ril Tsutsaroth", 'Commander Zilyana', "Kree'arra" }
    end

    local columnsConfig = {}
    if args.cols and args.cols ~= '' then
        for colToken in string.gmatch(args.cols, '[^,%s]+') do
            local colKey, modifier = string.match(colToken, '^([^:]+):?(.*)$')
            if colKey and colKey ~= '' then
                local showIcon = true
                if modifier and modifier:lower() == 'noicon' then
                    showIcon = false
                end
                table.insert(columnsConfig, { key = colKey, showIcon = showIcon })
            end
        end
    else
        columnsConfig = {
            { key = 'combat_level', showIcon = true },
            { key = 'hitpoints', showIcon = true },
            { key = 'attack_style', showIcon = true },
            { key = 'flatarmour', showIcon = true },
            { key = 'att', showIcon = true },
            { key = 'str', showIcon = true },
            { key = 'def', showIcon = true },
            { key = 'mage', showIcon = true },
            { key = 'range', showIcon = true },
            { key = 'attbns', showIcon = true },
            { key = 'strbns', showIcon = true },
            { key = 'amagic', showIcon = true },
            { key = 'mbns', showIcon = true },
            { key = 'arange', showIcon = true },
            { key = 'rngbns', showIcon = true },
            { key = 'def_stab', showIcon = true },
            { key = 'def_slash', showIcon = true },
            { key = 'def_crush', showIcon = true },
            { key = 'def_magic', showIcon = true },
            { key = 'def_light', showIcon = true },
            { key = 'def_standard', showIcon = true },
            { key = 'def_heavy', showIcon = true },
            { key = 'elem_weak', showIcon = true },
            { key = 'elem_pct', showIcon = true }
        }
    end

    return buildHtmlTable(monsters, columnsConfig, align)
end

return p