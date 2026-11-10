local lang = mw.getContentLanguage()
require("Module:Mw.html extension")
local p = {}

-- Helper to round numbers
local function round(num, idp)
    local mult = 10^(idp or 1)
    return math.floor(num * mult + 0.5) / mult
end

function p.calculator(frame)
    local args = frame.args
    if not args.modeToggle then
        args = frame:getParent().args
    end

    ---------------------------------------------------------
    -- 1. Input Processing & Max LP Determination
    ---------------------------------------------------------
    local const_level    = tonumber(args.constitution) or 99
    local armor_hp       = tonumber(args.armor_hp) or 0
    local manual_max_lp  = tonumber(args.max_lp)
    
    -- Buff Toggles for Max LP
    local bonfire        = (args.bonfire or "none"):lower() -- "none", "logs", "oak", "willow", "maple", "yew", "magic", "elder"
    local thermal_bath   = (args.thermal_bath or "no"):lower() == "yes"
    local fortitude      = (args.prayer or "none"):lower() == "fortitude"
    local oomi_gossips   = (args.oomi_gossips or "no"):lower() == "yes"

    local computed_max_lp = 0
    
    -- Standard Base LP calculation (100 HP per Constitution level)
    local base_lp = const_level * 100

    -- Bonfire Boost Multipliers (% of Base LP)
    local bonfire_mults = {
        logs   = 0.01,
        oak    = 0.02,
        willow = 0.03,
        maple  = 0.04,
        yew    = 0.05,
        magic  = 0.08,
        elder  = 0.10,
    }
    local bonfire_percent = bonfire_mults[bonfire] or 0

    -- Calculate total max LP based on formulas
    -- Bonfire, Thermal Bath (10%), Fortitude (3%), and Oomi (5%) boost base + armor LP
    local base_and_gear = base_lp + armor_hp
    local total_boost_percent = bonfire_percent
    
    if thermal_bath then total_boost_percent = total_boost_percent + 0.10 end
    if fortitude    then total_boost_percent = total_boost_percent + 0.03 end
    if oomi_gossips then total_boost_percent = total_boost_percent + 0.05 end

    computed_max_lp = math.floor(base_and_gear * (1 + total_boost_percent))

    -- Use manual max_lp override if provided, otherwise use calculated value
    local final_max_lp = manual_max_lp or computed_max_lp

    ---------------------------------------------------------
    -- 2. Natural Regeneration Calculations
    ---------------------------------------------------------
    local in_combat      = (args.in_combat or "no"):lower() == "yes"
    local prayer         = (args.prayer or "none"):lower()
    local regen_bracelet = (args.regen_bracelet or "no"):lower() == "yes"
    local regen_aura     = (args.regen_aura or "no"):lower() == "yes"
    local rest_state     = (args.resting or "none"):lower()

    local base_percent = 0.001 -- 0.1% base
    local interval = 6.0       -- 6s base

    if prayer == "rapid_renewal" then
        interval = 1.2
    elseif prayer == "rapid_heal" then
        interval = 3.0
    end

    local total_percent = base_percent
    if regen_bracelet then total_percent = total_percent + 0.002 end
    if regen_aura     then total_percent = total_percent + 0.001 end
    if fortitude      then total_percent = total_percent + 0.001 end

    local natural_active = not in_combat or fortitude
    
    local hp_per_natural_proc = 0
    local hp_per_sec_natural = 0

    if natural_active then
        hp_per_natural_proc = final_max_lp * total_percent
        hp_per_sec_natural = hp_per_natural_proc / interval
    end

    ---------------------------------------------------------
    -- 3. Rest / Secondary Cycles Calculations
    ---------------------------------------------------------
    local secondary_hp_per_proc = 0
    local secondary_interval = 0
    local hp_per_sec_secondary = 0

    if not in_combat then
        if rest_state == "rest" then
            secondary_hp_per_proc = (final_max_lp * 0.01) + 1
            secondary_interval = 6.0
        elseif rest_state == "musician" then
            secondary_hp_per_proc = (final_max_lp * 0.01) + 1
            secondary_interval = 3.0
        elseif rest_state == "dream" then
            secondary_hp_per_proc = final_max_lp * 0.002
            secondary_interval = 1.2
        end

        if secondary_interval > 0 then
            hp_per_sec_secondary = secondary_hp_per_proc / secondary_interval
        end
    end

    ---------------------------------------------------------
    -- 4. MediaWiki Table Output
    ---------------------------------------------------------
    local total_hp_per_sec = hp_per_sec_natural + hp_per_sec_secondary
    local total_hp_per_min = total_hp_per_sec * 60

    local html = mw.html.create("table")
        :addClass("wikitable text-align-center")
        :css("min-width", "380px")
        :tag("caption")
        	:wikitext("Life points & regeneration summary")
        	:done()

    -- Display breakdown of Max LP source
    html:tr()
        :th("Effective max LP")
        :td{lang:formatNum(final_max_lp) .. (manual_max_lp and " (manual override)" or " (calculated)")}

    -- Natural regen row
    html:tr()
        :th("Natural regen proc")
        :td()
        	:IF(not natural_active)
        		:addClass("text-red")
        		:wikitext("Disabled (in combat)")
    		:ELSE()
    			:wikitext(string.format(
        			"%s LP every %.1fs", 
            		lang:formatNum(round(hp_per_natural_proc, 1)), 
            		interval
        		))
    		:END()

    -- Secondary cycle row
    if rest_state ~= "none" then
        html:tr()
            :th("Rest/spell proc")
            :td()
            	:IF(in_combat)
	        		:addClass("text-red")
	        		:wikitext("Disabled (in combat)")
        		:ELSE()
	    			:wikitext(string.format(
	        			"%s LP every %.1fs", 
	            		lang:formatNum(round(secondary_hp_per_proc, 1)), 
	            		secondary_interval
	        		))
	        	:END()
    end

    -- Totals rows
    html
    	:tr()
        	:th("LP / second")
        	:td{round(total_hp_per_sec, 2)}
		:tr()
        	:th("LP / minute")
        	:td{lang:formatNum(round(total_hp_per_min, 1)), css={"font-weight", "bold"}, class="text-green"}

    return tostring(html:allDone())
end

return p