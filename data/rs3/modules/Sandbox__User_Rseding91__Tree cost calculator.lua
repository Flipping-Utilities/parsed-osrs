local data = mw.loadData('Module:Sandbox/User:Rseding91/Tree cost calculator/data')
local prices = mw.loadJsonData('Module:GEPrices/data.json')
local yn = require('Module:Yesno')
local lang = mw.getContentLanguage()
local p = {}
local bonuses = {}

function p.main(frame)
    return p._main(frame:getParent().args)
end

local function error_text(text)
    return string.format("<span class='error'>%s</span>", text)
end

local function create_builder()
    return { results = {}, i = 1 }
end

local function create_results_builder()
    return {
        base_experience = create_builder(),
        bonus_experience = create_builder(),
        cost = create_builder(),
        savings = create_builder()
    }
end

local function add_line(result_builder, text)
    result_builder.results[result_builder.i] = text
    result_builder.i = result_builder.i + 1
end

local function add_base_experience_line(results, line)
    add_line(results.base_experience, line)
end

local function add_bonus_experience_line(results, line)
    add_line(results.bonus_experience, line)
end

local function add_cost_line(results, line)
    add_line(results.cost, line)
end

local function add_savings_line(results, line)
    add_line(results.savings, line)
end

local function format_number(number)
    return lang:formatNum(math.floor(number * 100) / 100)
end

local function link_to(name)
    return string.format("[[%s]]", name)
end

function bonuses.premier_artifact(results, used)
    if used then
        add_bonus_experience_line(results, "* Premier artifact: +10%")
        return 0.1
    end
    return 0
end

function bonuses.wisdom_aura(results, used)
    if used then
        add_bonus_experience_line(results, "* Wisdom aura: +2.5%")
        return 0.025
    end
    return 0
end

function bonuses.brassica_primer(results, used)
    if used then
        add_bonus_experience_line(results, "* Brassica primer: +10%")
        return 0.1
    end
    return 0
end

function bonuses.farming_outfit(results, count)
    if count == 5 then
        add_bonus_experience_line(results, "* Farming outfit: +6%")
        return 0.06
    end
    if count ~= 0 then
        add_bonus_experience_line(results, "* Farming outfit: +" .. tostring(count) .. "%")
    end
    return count * 0.01
end

function bonuses.pulse_core_worn(results, worn)
    if worn then
        add_bonus_experience_line(results, "* Advanced pulse core (worn): +50%")
        return 0.5
    end
    return 0
end

function bonuses.wise_perk(results, level)
    if level ~= 0 then
        add_bonus_experience_line(results, "* Wise perk: +" .. tostring(level) .. "%")
    end
    return level * 0.01
end

function bonuses.pulse_core_bonus(results, percent)
    if percent ~= 0 then
        add_bonus_experience_line(results, "* Advanced pulse core bonus: +" .. tostring(percent) .. "%")
    end
    return percent * 0.01
end

function bonuses.avatar_habitat(results, percent)
    if percent ~= 0 then
        add_bonus_experience_line(results, "* Clan avatar bonus: +" .. tostring(percent) .. "%")
    end
    return percent * 0.01
end

function bonuses.bonus_xp(results, used)
    if used then
        add_bonus_experience_line(results, "* Bonus experience: +100%")
        return 1
    end
    return 0
end

function bonuses.double_xp(results, used)
    if used then
        add_bonus_experience_line(results, "* Double experience week/weekend: +100%")
        return 1
    end
    return 0
end

function bonuses.farming_urn(results, used, enhancer)
    if used then
        local bonus = 0.2
        add_bonus_experience_line(results, "* Farming urn: +20%")
        if enhancer then
            bonus = bonus + 0.05
            add_bonus_experience_line(results, "* Urn enhancer: +5%")
        end
        return bonus
    end
    return 0
end

function p._main(args)
    -- TODO Cinder core (worn and effect) ?

    local tree_name = args.tree_name
    local experience_data = data.experience[tree_name]
    if not experience_data then return "" end
    
    local results = create_results_builder();
    
    local master_farmer_outfit = yn(args.master_farmer_outfit)
    local farming_urn = args.farming_urn
    local urn_enhancer = yn(args.urn_enhancer)
    local pay_to_protect = yn(args.pay_to_protect)
    local sell_harvests = yn(args.sell_harvests)
    local giant_ent = yn(args.giant_ent)
    local scroll_of_life = yn(args.scroll_of_life)
    local manual_seed_cost = tonumber(args.manual_seed_cost)
    local manual_harvest_cost = tonumber(args.manual_harvest_cost)
    
    local base_experience = experience_data.plant + experience_data.check
    add_base_experience_line(results, "Base experience:")
    add_base_experience_line(results, string.format("* Planting: %s", format_number(experience_data.plant)))
    add_base_experience_line(results, string.format("* Checking: %s", format_number(experience_data.check)))
    
    local harvestable = experience_data.harvest or false
    if harvestable then
        base_experience = base_experience + (experience_data.harvest * experience_data.harvests)
        add_base_experience_line(results, string.format("* Harvesting: %s x %s",
                                                        format_number(experience_data.harvest),
                                                        tostring(experience_data.harvests)))
    end
    
    add_base_experience_line(results, string.format("* Total: %s", format_number(base_experience)))
    
    local premier_artifact = yn(args.premier_artifact)
    local wisdom_aura = yn(args.wisdom_aura)
    
    add_bonus_experience_line(results, "Bonus experience:")
    local bonus = bonuses.avatar_habitat(results, tonumber(args.avatar_habitat)) +
                  bonuses.wise_perk(results, tonumber(args.wise_perk)) +
                  bonuses.pulse_core_bonus(results, tonumber(args.pulse_core_bonus)) +
                  bonuses.brassica_primer(results, yn(args.brassica_primer)) +
                  bonuses.premier_artifact(results, premier_artifact) +
                  bonuses.wisdom_aura(results, wisdom_aura) +
                  bonuses.farming_outfit(results, tonumber(args.farming_outfit)) +
                  bonuses.pulse_core_worn(results, yn(args.pulse_core_worn)) +
                  bonuses.bonus_xp(results, yn(args.bonus_xp)) +
                  bonuses.double_xp(results, yn(args.double_xp))
    
    local urns_used = 0
    if farming_urn and farming_urn ~= 'None' then
        local urn_data = data.urns[farming_urn]
        
        -- Reject; urns don't work for this seed level
        if urn_data.max_level < data.levels[tree_name] then
            return error_text(string.format("%s urns only works on plants up to level %s. %s is level %s.",
                                            farming_urn,
                                            tostring(urn_data.max_level),
                                            tree_name,
                                            tostring(data.levels[tree_name])))
        end
        
        bonus = bonus + bonuses.farming_urn(results, farming_urn, urn_enhancer)
        urns_used = base_experience / urn_data.base
    end
    
    local total_experience = base_experience + (base_experience * bonus)
    
    if bonus ~= 0 then
        add_bonus_experience_line(results, string.format("* Total: %s%%", tostring(bonus * 100)))
        
        add_bonus_experience_line(results, "\nFinal experience:")
        local bonus_string = tostring(1 + bonus)
        add_bonus_experience_line(results, string.format("* Planting: %s x %s: %s",
                                                         format_number(experience_data.plant),
                                                         bonus_string,
                                                         format_number(experience_data.plant * (1 + bonus))))
        add_bonus_experience_line(results, string.format("* Checking: %s x %s: %s",
                                                         format_number(experience_data.check),
                                                         bonus_string,
                                                         format_number(experience_data.check * (1 + bonus))))
        
        if harvestable then
            add_bonus_experience_line(results, string.format("* Harvesting: %s x %s x %s: %s",
                                                             tostring(experience_data.harvest),
                                                             tostring(experience_data.harvests),
                                                             bonus_string,
                                                             format_number(experience_data.harvest * experience_data.harvests * (1 + bonus))))
        end
        
        add_bonus_experience_line(results, string.format("* Total: %s x %s: %s",
                                                         format_number(base_experience),
                                                         bonus_string,
                                                         format_number(total_experience)))
    end
    
    --[[ BASE COST CALCULATION ]]--
    local base_cost = 0
    add_cost_line(results, "\nCosts:")
    
    -- Seed cost
    local seed_cost = prices[tree_name]
    if manual_seed_cost and manual_seed_cost ~= 0 then
        seed_cost = manual_seed_cost
    end
    add_cost_line(results, string.format("* %s: %s", link_to(tree_name), format_number(seed_cost)))
    base_cost = base_cost + seed_cost
    
    -- Farming urn cost
    if farming_urn and farming_urn ~= 'None' then
        local urn_cost = prices[data.urns[farming_urn].name]
        local nature_rune_cost = prices['Nature rune']
        
        base_cost = base_cost + ((urn_cost + nature_rune_cost) * urns_used)
        add_cost_line(results, string.format("* %g urns: %s", urns_used, format_number(urn_cost * urns_used)))
        add_cost_line(results, string.format("* %g nature runes: %s", urns_used, format_number(nature_rune_cost * urns_used)))
        
        if urn_enhancer then
            local divine_charge_cost = prices['Divine charge']
            local added_cost = (divine_charge_cost / 150) * urns_used
            base_cost = base_cost + added_cost
            add_cost_line(results, string.format("* %g divine charge (urn enhancer): %s",
                                                 added_cost / divine_charge_cost,
                                                 format_number(added_cost)))
        end
    end
    
    -- Payment costs
    if pay_to_protect then
        local payment_data = data.payments[tree_name]
        local single_cost = prices[payment_data.name]
        local payment_count = payment_data.count
        local master_farmer_discount = ""
        if master_farmer_outfit then
            payment_count = math.max(1, payment_count - 2)
            master_farmer_discount = " (-2 master farmer outfit)"
        end
        add_cost_line(results, string.format("* %s%s %s: %s",
                                             tostring(payment_count),
                                             master_farmer_discount,
                                             link_to(payment_data.name),
                                             format_number(single_cost * payment_count)))
        
        base_cost = base_cost + (single_cost * payment_count)
    end
    add_cost_line(results, string.format("* Total: %s", format_number(base_cost)))
    
    
    --[[ PROJECTED SAVINGS ]]--
    local savings = 0
    add_savings_line(results, "\nAverage savings:")
    
    -- Selling harvests
    if sell_harvests and harvestable then
        local harvest_data = data.harvests[tree_name]
        local harvest_count = harvest_data.count
        
        local single_cost = prices[harvest_data.name]
        if manual_harvest_cost and manual_harvest_cost ~= 0 then
            single_cost = manual_harvest_cost
        end
        add_savings_line(results, string.format("* %s %s: %s",
                                                harvest_count,
                                                link_to(harvest_data.name),
                                                format_number(harvest_data.count * single_cost)))
        
        if giant_ent then
            local ent_chances = experience_data.harvests
            harvest_count = harvest_count + (ent_chances * 0.5)
            add_savings_line(results, string.format("* %g %s (giant ent): %s",
                                                    ent_chances * 0.5,
                                                    link_to(harvest_data.name),
                                                    format_number((ent_chances * 0.5) * single_cost)))
        end
        
        if master_farmer_outfit then
            local outfit_chances = experience_data.harvests
            harvest_count = harvest_count + (outfit_chances * 0.1)
            add_savings_line(results, string.format("* %g %s (master farmer outfit): %s",
                                                    outfit_chances * 0.1,
                                                    link_to(harvest_data.name),
                                                    format_number((outfit_chances * 0.1) * single_cost)))
        end
        
        savings = savings + (harvest_count * single_cost)
    end
    
    -- Saving a seed
    if scroll_of_life then
        local seed_savings = (seed_cost * 0.1);
        savings = savings + seed_savings
        add_savings_line(results, string.format("* 0.1 %s (scroll of life): %s",
                                                link_to(tree_name),
                                                format_number(seed_savings)))
    end
    if savings ~= 0 then
        add_savings_line(results, string.format("* Total: %s", format_number(savings)))
    end
    
    local builder = create_builder()
    
    -- GP per XP
    add_line(builder, "Gold pieces per experience:")
    add_line(builder, string.format("* (%s - %s)/%s = %s GP/XP",
                                    format_number(base_cost),
                                    format_number(savings),
                                    format_number(total_experience),
                                    format_number((base_cost - savings) / total_experience)))
    add_line(builder, "")
    
    for _,v in ipairs(results.base_experience.results) do
        add_line(builder, v)
    end
    
    if bonus ~= 0 then
        for _,v in ipairs(results.bonus_experience.results) do
            add_line(builder, v)
        end
    end
    
    for _,v in ipairs(results.cost.results) do
        add_line(builder, v)
    end
    
    if savings ~= 0 then
        for _,v in ipairs(results.savings.results) do
            add_line(builder, v)
        end
    end
    
    add_line(builder, "\nNotes:")
    add_line(builder, "* Assumes continual replanting")
    
    if sell_harvests and not harvestable then
        add_line(builder, "* Tree has no harvests")
    end
    
    if giant_ent then
        if sell_harvests and harvestable then
            add_line(builder, "* Giant ent pouch cost is not included")
        elseif not sell_harvests then
            add_line(builder, "* Giant ent has no effect because the harvests aren't being sold")
        elseif sell_harvests and not harvestable then
            add_line(builder, "* Giant ent has no effect because the tree has no harvests")
        end
    end
    
    return table.concat(builder.results, '\n')
end

function p.tree_list()
    local l = {}
    for k,v in pairs(data.names) do
        table.insert(l, v)
    end
    table.sort(l)
    return table.concat(l, ',')
end

function p.urn_list()
    local l = {}
    for k,v in pairs(data.urns) do
        l[v.order] = k
    end
    return table.concat(l, ',')
end

return p