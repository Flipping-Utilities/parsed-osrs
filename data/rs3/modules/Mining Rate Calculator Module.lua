local p = {}
local getArgs = require("Module:Arguments").getArgs;
local data = mw.loadData('Module:MS Data')
local gemw = require('Module:ExchangeLite')
local xp, level;

do
	local _module_experience = require('Module:Experience');
	xp = _module_experience._xp_at_level;
	level = _module_experience._level_at_xp;
end
local coins = require('Module:Currency')._amount
local commas = require('Module:Addcommas')._add

local lang = mw.getContentLanguage() -- Number format helper function.
local function fnum(x)
	if type(x) == 'number' then return lang:formatNum(x) end
	return x
end

local function shallow_copy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end


local remainingExp, geodePrice;

function p.main(frame)
	local args = getArgs(frame)
	local mining_level = tonumber(args.mining_level) or 1		-- Mining level
	local str_level = tonumber(args.str_level) or 1				-- Strength level
	local mining_xp = tonumber(args.mining_xp) or 1				-- Mining xp
	local target_lvl = tonumber(args.target_level) or 0			-- Target mining level
	local target_xp = tonumber(args.target_xp) or 0				-- Target mining xp
	local pick = data.picks[args.pickaxe]					-- Pickaxe
	local methodtmp = args.method or 'Semi-AFK'
	local method = data.method_m[methodtmp]					-- Method chosen
	local corehammer = tonumber(args.corehammer) or 0			-- Tagga's corehammer
	local pockettmp = args.pocket or 'None'
	local pocket = data.pocket[pockettmp]					-- Pocket
	local tmpvarrock = args.varrock or 'None'
	local varrock = data.varrock[tmpvarrock]				-- Varrock armour
	local newvar = tonumber(args.newvar) or 1				-- New varrock tasks
	local familiar = data.familiar_m[args.familiar] or 0		-- Familiar
	local gmo = data.outfit_s[args.gmo] or 0				-- Golden mining outfit pieces unlocked
	local outfittmp = args.outfit or 'None'
	local outfit = data.outfit_m[outfittmp]					-- Outfit selected
	local cape = tonumber(args.cape) or 0					-- Mining skillcape
	local amulet = tonumber(args.amulet) or 0				-- Amulet of glory
	local ringtmp = args.ring or 'None'
	local ring = data.rings[ringtmp]						-- Ring
	local lucktmp = args.luck or 'None'
	local luck = data.luck[lucktmp]						-- Luck items and potions
	local pof = args.pofperk or 'None'					-- POF animal perks.
	local avatmp = args.avatar or 'None'
	local avatar = data.avatar[avatmp] or 0					-- Avatar
	local juju = args.juju or 'None'					-- Juju mining potions
	local pottmp = args.str_potion or args.potion or 'None'
	local str_potion = data.potion[pottmp]					-- Strength bonus potions
	pottmp = args.mining_potion or 'None'
	local mining_potion = data.mining_potion[pottmp]			-- Mining bonus potions
	
	-- Spell / Crystallise logic with crash-proof fallback
	local spelltmp = args.spell or 'None'
	local spell = data.spells_m[spelltmp]
	if not spell then
		spell = data.spells_m['None'] or {ore = 1, xp = 0}
	end
	
	local trah = tonumber(args.trah) or 0					-- Trahaearn Hour
	local sprite = tonumber(args.starsprite) or 0				-- Star sprite ore bonus for first 15 minutes
	local spirits = tonumber(args.spirits) or 0				-- Stone spirits
	local lvl20 = tonumber(args.lvl20) or 1					-- Pickaxe item level 20
	local honed = data.honed[args.honed] or 0				-- Honed perk
	honed = honed * lvl20
	local wise = data.wise[args.wise] or 0					-- Wise perk
	local furnace = data.furnace[args.furnace] or 0			-- Furnace perk
	furnace = furnace * lvl20
	local fortune = data.fortune[args.fortune] or 0			-- Fortune perk
	fortune = fortune * lvl20
	local impsouled = data.impsouled[args.impsouled] or 0		-- Imp Souled perk
	impsouled = impsouled * lvl20
	
	-- NEW PERKS ADDED HERE
	local careless = 0
	if args.careless and args.careless ~= '' and args.careless ~= 'None' then
		-- Try data table lookup first (for consistency with other perks)
		if data.careless and data.careless[args.careless] then
			careless = data.careless[args.careless]
		else
			-- Otherwise treat as direct number input (1-5)
			careless = tonumber(args.careless) or 0
		end
	end
	local explosive = tonumber(args.explosive) or 0			-- Explosive perk (1=Yes, 0=No)
	
	-- Paradox spell (Robust check against trailing spaces or casing)
	local is_paradox_spell = args.spell and (string.find(string.lower(args.spell), 'paradox') ~= nil)
	local paradox_active = (tonumber(args.paradox) == 1) or is_paradox_spell
	
	local urntmp = args.urns or 'None'
	local urns = data.urns[urntmp]							-- Urns
	local urntypes = shallow_copy(data.urn_types)
	if urntmp:find("Exquisite") then
		urntypes[#urntypes] = data.urn_exquisite -- Replace decorated with exquisite urn
	end
	local ramtmp = args.ramhammer or 'None'
	local ramhammer = data.ramhammer[ramtmp]				-- Dwarven Ramhammer
	local refined = data.refined[args.refined] or 0			-- Refined
	refined = refined * lvl20
	local raf = tonumber(args.raf) or 0					-- Refer a friend bonus
	local bxp = tonumber(args.bxp) or 0					-- Bonus XP
	local bxpnum = tonumber(args.bxpnum) or 0				-- Amount of bonus XP
	local dxp = tonumber(args.dxp) or 0					-- Double XP Weekend
	local pcore = tonumber(args.pulsecore) or 0				-- Advanced pulse core (only xp boost)
	local skillctmp = args.skillchompa or 'None'
	local skillchompa = data.skillchompa[skillctmp]			-- Skillchompas
	local customtmp = tonumber(args.custom) or 0
	local custom = customtmp / 100						-- Custom XP boost
	local custom_mine = tonumber(args.custommine) or 0		-- Custom mining level boost (flat #)
	local custom_str = tonumber(args.customstr) or 0		-- Custom strength level boost (flat #)
	local porter = data.porter[args.porter] or 0			-- Cost of one porter charge
	local critenhancer = tonumber(args.critenhancer) or 0	-- Enhancer (Crit)
	local geodeenhancer = tonumber(args.geodeenhancer) or 0	-- Enhancer (Geode)
	
	-- No ramhammer on dxp
	if dxp ~= 0 then
		ramhammer = data.ramhammer['None']
	end
	
	-- Combine luck items bonuses, non-stacking
	local meta_bonus = 0
	if  ring.meta > luck.meta then
		meta_bonus = ring.meta
	else
		meta_bonus = luck.meta
	end
	local meta = data.metamorphic_chance + meta_bonus			-- Chance for metamorphic geode
	
	-- Pof perks
	local pofgeode = 0
	local pofcrit = 0
	if pof == 'Scimitops' then
		pofgeode = 0.01
	elseif pof == 'Scimitops x2' then
		pofgeode = 0.02
	elseif pof == 'Scimitops x2 + Asciatops' then
		pofgeode = 0.02
		pofcrit = 0.03
	elseif pof == 'Scimitops + Asciatops' then
		pofgeode = 0.01
		pofcrit = 0.03
	elseif pof == 'Scimitops + Asciatops x2' then
		pofgeode = 0.01
		pofcrit = 0.06
	elseif pof == 'Asciatops x2' then
		pofcrit = 0.06
	elseif pof == 'Asciatops' then
		pofcrit = 0.03
	end
	
	-- Offhands
	local offhandcritdamage = 0
	local offhandcritchance = 0
	if corehammer == 1 then
		offhandcritdamage = 35
		offhandcritchance = 0.1
	end
	
	--Enhancer (Geode)
	local enhancergeode = 0
	if geodeenhancer == 1 then
		enhancergeode = 0.3
	end
	
	--Enhancer (Crit)
	local enhancercrit = 0
	if critenhancer == 1 then
		enhancercrit = 0.1
	end
	
	-- Levels and targets
	local remaining = 0
	local virtual_mining_level;
	virtual_mining_level, mining_xp, target_lvl, target_xp, remaining = remainingExp(mining_level, mining_xp, target_lvl, target_xp)
		-- deal with no bxp but claiming to have bxp
	if bxpnum == 0 then
		bxp = 0
	end
	local real_mining_level = math.min(virtual_mining_level, 110);
	mining_level = real_mining_level;
	
	-- Experience boosts (direct XP modifiers)
	local xp_boosts = 1 * (1 + dxp) * (1 + raf) * (1 + pcore) + avatar + wise + bxp + furnace + ramhammer.xp + custom
	if outfit.gmo == 1 then xp_boosts = xp_boosts + gmo end -- If the selected outfit applies the golden mining outfit bonus then add it to xp boosts
	
	-- Bonus xp
	if bxpnum > 0 then
		local div = 2 * (xp_boosts -1) -- remove boosts then half of xp can come from bxp
		if bxpnum < (remaining / div) then
			xp_boosts = xp_boosts - 1
			remaining = remaining - bxpnum
		end
	end
	local has_target = false									-- Has a target
	if remaining > 0 then has_target = true end				-- Has target true if remaining xp > 0
	
	local t = mw.html.create('table')	-- Create the headers of the table
	t:addClass('wikitable sticky-header sortable')
	
	if not has_target then
		local r = t:tag('tr')
		r:tag('th')  :wikitext('Level')             :attr('rowspan', 2) :done()
		:tag('th')  :wikitext('Rock')               :attr('rowspan', 2) :done()
		:tag('th')  :wikitext('Hardness Penalty')   :attr('rowspan', 2) :done()
		:tag('th')  :wikitext('Crit Chance')        :attr('rowspan', 2) :done()
		:tag('th')  :wikitext('Double ore chance')  :attr('rowspan', 2) :done()
		:tag('th')  :wikitext('XP Per Hour')        :attr('colspan', 3) :done()
		if spirits > 0 then
			r:tag('th')  :wikitext('Stone Spirits Used')  :attr('rowspan', 2)  :done()
		end
		if urns > 0 then
			r:tag('th')  :wikitext('Urns Used')     :attr('rowspan', 2) :done()
		end
		r:tag('th')  :wikitext('Ore Per Hour')      :attr('rowspan', 2) :done()
		:tag('th')  :wikitext('Ore Value')			:attr('rowspan', 2) :done()
		:tag('th')  :wikitext('Geode Chance')       :attr('rowspan', 2) :done()
		:tag('th')  :wikitext('Geodes Per Hour')    :attr('rowspan', 2) :done()
		:tag('th')  :wikitext('GP Per Hour')		:attr('rowspan', 2) :done()
		:done()
		:tag('tr')
		:tag('th')  :wikitext('Min')                                     :done()
		:tag('th')  :wikitext('Avg')                                    :done()
		:tag('th')  :wikitext('Max')                                     :done()
		:done()
	else
		local r = t:tag('tr')
		r:tag('th')  :wikitext('Rock')              :attr('rowspan', 2) :done()
		:tag('th')	:wikitext('Level')				:attr('rowspan', 2) :done()
		:tag('th')	:wikitext('Time Required (hr)')		:attr('colspan', 3)	:done()
		if spirits > 0 then
			r:tag('th')  :wikitext('Stone Spirits Used')  :attr('rowspan', 2)  :done()
		end
		if urns > 0 then
			r:tag('th')  :wikitext('Urns Used')     :attr('rowspan', 2) :done()
		end
		r:tag('th')	:wikitext('Ore mined')			:attr('rowspan', 2)	:done()
		:tag('th')	:wikitext('Geodes found')		:attr('rowspan', 2)	:done()
		:tag('th')	:wikitext('Ore cost')			:attr('rowspan', 2)	:done()
		:tag('th')	:wikitext('Profit/Loss')		:attr('rowspan', 2)	:done()
		:tag('th')	:wikitext('Profit/XP')			:attr('rowspan', 2)	:done()
		:done()
		:tag('tr')
		:tag('th')	:wikitext('Min')										:done()
		:tag('th')  :wikitext('Avg')                                     :done()
		:tag('th')  :wikitext('Max')                                    :done()
		:done()
	end
	
	-- Mining level boosts
	if (mining_potion.type == "normal") then
		mining_level = real_mining_level * mining_potion.per + mining_potion.flat;
	elseif (mining_potion.type == "extreme") then
		-- TODO: Extreme mining potion (once that gets added)
	else
		error("Unknown potion type: " .. mining_potion.type);
	end
	mining_level = mining_level + custom_mine
	if real_mining_level < 99 then cape = 0 end			-- Turn off skillcape if selected without 99 mining
	if cape > 0 then
		mining_level = math.max(mining_level, real_mining_level + 1); -- Level boosts don't stack
	end
	local damage_bonus = familiar + ring.damage		-- Damage bonus
	
	-- Strength level boosts
	str_level = str_level * str_potion.per + str_potion.flat + custom_str
	
	-- Check that pickaxe is usable at level
	local higher_pick = false
	local orig_pick;
	-- It's not possible to use level boosts to use higher pickaxe tiers
	if pick.level > real_mining_level then
		higher_pick = true
		orig_pick = pick
		local picklvl = 0
		local pickdmg = 0
		for p,pdata in pairs(data.picks) do
			if pdata.level > picklvl and pdata.max > pickdmg and pdata.level <= real_mining_level then
				pick = pdata
				picklvl = pdata.level
				pickdmg = pdata.max
			end
		end
	end
	
	-- Check number of perks
	local perk_cnt = 0
	if wise > 0 then
		perk_cnt = perk_cnt + 1
	end
	if furnace > 0.1 then
		perk_cnt = perk_cnt + 1
	end
	if honed > 0 then
		perk_cnt = perk_cnt + 1
	end
	if fortune > 0 then
		perk_cnt = perk_cnt + 1
	end
	if refined > 0 then
		perk_cnt = perk_cnt + 1
	end
	if impsouled > 0 then
		perk_cnt = perk_cnt + 1
	end
	
	-- Critical hit bonus
	local crit_bonus = 0
	for i = 1,20,1 do
		if mining_level >= data.crit_bonus_level[i]
		then crit_bonus = data.crit_bonus[i]
		else break end
	end
	crit_bonus = crit_bonus + skillchompa.bonus + offhandcritdamage	-- Skillchompas critical hit bonus
	
	if args.method == 'AFK' then 
		spell = data.spells_m['None'] or {ore = 1, xp = 0} 
	end -- Turn off crystallise if AFK
	
	for index,r in ipairs(data.rocks) do
		if mining_level >= r.level or has_target then	-- Remove rocks that cannot be mined at the selected mining level
			
			-- No urns with lava flow
			local xp_boosts_rock = xp_boosts
			if urns > 0 and r.urns then
					xp_boosts_rock = xp_boosts_rock + urns
			end
			
			-- Net hardness
			local net_hardness = pick.pen - r.hardness
			if net_hardness > 0 then net_hardness = 0 end
			
			-- Critical hit chance
			local crit_chance = 0
			if		r.len_crit_chance_level == 2 then
				if		mining_level >= r.crit_chance_level[2] then crit_chance = data.crit_chances[2]
				elseif	mining_level >= r.crit_chance_level[1] then crit_chance = data.crit_chances[1]
				else											crit_chance = data.crit_chance_base end
			elseif	r.len_crit_chance_level == 1 then
				if		mining_level >= r.crit_chance_level[1] then crit_chance = data.crit_chances[1]
				else											crit_chance = data.crit_chance_base end
			else												crit_chance = data.crit_chance_base
			end
			crit_chance = crit_chance + pocket.crit + pofcrit + offhandcritchance + enhancercrit
			if args.outfit == 'Starfury Outfit' then -- Starfury's crit chance only applies to Seren stones
				if r.name == '[[Seren stones]]' then crit_chance = crit_chance + outfit.crit	end
			else
				crit_chance = crit_chance + outfit.crit
			end
			
			--Base damage calculations
			local net_crit_bonus = crit_bonus + net_hardness
			if net_crit_bonus < 1 then net_crit_bonus = 1 end
			local net_crit = net_crit_bonus * crit_chance
			
			-- !!! START DAMAGE CALCULATION UPDATE FOR PERKS !!!
			local damage_base = (mining_level + math.floor(str_level/10) + net_hardness + net_crit + damage_bonus) * ramhammer.damage
			
			-- Careless Perk: 2% damage increase per rank
			if careless > 0 then
				damage_base = damage_base * (1 + (0.02 * careless))
			end
			
			-- Explosive Perk: 20% damage increase on core rocks
			if explosive == 1 and r.core == 1 then
				damage_base = damage_base * 1.20
			end
			-- !!! END DAMAGE CALCULATION UPDATE !!!
			
			-- PARADOX SPELL: 100% damage increase
			if paradox_active then
				damage_base = damage_base * 2.0
			end
			
			local damage_min = damage_base + pick.min
			local damage_avg = damage_base + pick.avg
			local damage_max = damage_base + pick.max
			if damage_min < 1 then damage_min = 1 end -- If negative damage due to hardness then swings do 1 damage.
			if damage_avg < 1 then damage_avg = 1 end
			if damage_max < 1 then damage_max = 1 end
			
			-- Perfect juju mining potion
			local method_xp = method.xp
			if juju == 'Perfect juju mining potion' and r.spirits ~= nil and r.spirits > 0 and method_xp < (0.9) then
				method_xp = 0.9
			end
			
			-- Separate method_ore for ore calculations
			local method_ore = method_xp
			if careless > 0 then
    			-- Reduces stamina by an additional 10% per rank (Careless 5 = 50% penalty)
				method_xp = method_xp * (1 - (0.10 * careless))
			end
			
			-- Some rocks do not use stamina drain
			if r.drain == 1 then
				method_xp = 1
				method_ore = 1
			end
			
			-- XP calculations
			local xp_swing_min = math.floor(10 * damage_min * r.xp * data.base_xp)/10
			local xp_swing_avg = math.floor(10 * damage_avg * r.xp * data.base_xp)/10
			local xp_swing_max = math.floor(10 * damage_max * r.xp * data.base_xp)/10
			local xp_hr_min = xp_swing_min * data.swing_hr * method_xp
			local xp_hr_avg = xp_swing_avg * data.swing_hr * method_xp
			local xp_hr_max = xp_swing_max * data.swing_hr * method_xp
			
			-- Ore calculations (average only)
			local swings_ore = r.diff / damage_avg -- Average swings per ore
			local uncapped_swings_ore = swings_ore
			if swings_ore < 1 then swings_ore = 1 end -- Apply damage cap
			local ore_swing = 1 / swings_ore -- Average ore per swing
			local base_ore = ore_swing * (data.swing_hr * (1 - furnace)) * math.min(method_ore * (swings_ore/uncapped_swings_ore),1) -- Average ore per hour, adjusted by theoretical uncapped swings per hour to correct afk method calculation
			
			-- Double ore chance
			local double_ore_chance = 0
			if		r.len_double_ore == 2 then
				if		mining_level >= r.double_ore_chance[2] then double_ore_chance = data.double_ore_chances[2]
				elseif	mining_level >= r.double_ore_chance[1] then double_ore_chance = data.double_ore_chances[1]
				else											double_ore_chance = data.double_ore_chance_base end
			elseif	r.len_double_ore == 1 then
				if		mining_level >= r.double_ore_chance[1] then double_ore_chance = data.double_ore_chances[1]
				else											double_ore_chance = data.double_ore_chance_base end
			else												double_ore_chance = data.double_ore_chance_base
			end
			double_ore_chance = double_ore_chance + honed + fortune -- Apply honed & fortune perk and mining cape if applicable
			if r.core == 1 then double_ore_chance = double_ore_chance + cape end -- apply mining cape only on core rocks
			
			-- Double ore chance (Varrock armour)
			if varrock.no > 0 then				-- Skips if no varrock armour is selected
				if r.core == 1 then				-- Skips if the rock is not a core rock
					if r.varrock[varrock.no] == 1 then	-- Checks if the armour selected applies to the rock
						double_ore_chance = double_ore_chance + (data.varrock[r.varrock_no]['effect'] * newvar)
					end
				end
			end
			
			-- Double ore chance (Trah hour)
			if trah == 1 then
				if r.trah == 1 then double_ore_chance = double_ore_chance + data.trah_bonus end
			end
			
			-- Double ore chance (Star sprite), fist 15 minutes
			if sprite == 1 then
				if r.sprite == 1 then double_ore_chance = double_ore_chance + data.sprite_bonus * 0.25 end
			end
			
			-- !!! WATERFIEND FAMILIAR UPDATE !!!
			-- Flat 5% chance to duplicate gathered ores
			if args.familiar and (string.find(string.lower(args.familiar), 'waterfiend') ~= nil) then
				double_ore_chance = double_ore_chance + 0.05
			end
			-- !!! END WATERFIEND FAMILIAR UPDATE !!!
			
			local ore_boosts = r.ore + double_ore_chance	-- Ore multiplier
			local spirits_multiplier = 1.0  -- Multiplier for stone spirits
			if r.spirits ~= nil and r.spirits > 0 then
				if spirits == 1 then
					-- Stone spirits double the ore yield - each ore mined gives 2 ores instead of 1
					-- This is a true 2x multiplier on the final ore count
					spirits_multiplier = 2.0
				elseif juju ~= 'None' then
					ore_boosts = ore_boosts + 0.1						-- Stone spirits from juju mining potions
				end
			end
			local total_ore = base_ore * ore_boosts * spirits_multiplier
			
			-- Geode chance
			local geode_chance = 0
			if		r.len_geode_chance == 3 then
				if		mining_level >= r.geode_chance_level[3] then geode_chance = data.geode_chances[3]
				elseif	mining_level >= r.geode_chance_level[2] then geode_chance = data.geode_chances[2]
				elseif	mining_level >= r.geode_chance_level[1] then geode_chance = data.geode_chances[1]
				else									geode_chance = data.geode_chance_base end
			elseif		r.len_geode_chance == 2 then
				if		mining_level >= r.geode_chance_level[2] then geode_chance = data.geode_chances[2]
				elseif	mining_level >= r.geode_chance_level[1] then geode_chance = data.geode_chances[1]
				else										 geode_chance = data.geode_chance_base end
			elseif	r.len_geode_chance == 1 then
				if		mining_level >= r.geode_chance_level[1] then geode_chance = data.geode_chances[1]
				else										 geode_chance = data.geode_chance_base end
			else											 geode_chance = data.geode_chance_base end
			geode_chance = geode_chance + pocket.geode + refined + amulet + pofgeode + enhancergeode
			
			-- Rockertunities
			-- Rockertunity multiplier
			local rck_mult = 0
			if r.len_rockertunity_level == 2 then
				if mining_level >= r.rockertunity_level[2] then rck_mult = data.rockertunity_mult[2]
				elseif mining_level >= r.rockertunity_level[1] then rck_mult = data.rockertunity_mult[1]
				else rck_mult = data.rockertunity_mult_base end
			elseif r.len_rockertunity_level == 1 then
				if mining_level >= r.rockertunity_level[1] then rck_mult = data.rockertunity_mult[1]
				else rck_mult = data.rockertunity_mult_base end
			else
				rck_mult = data.rockertunity_mult_base
			end
			rck_mult = rck_mult + outfit.rck + pocket.rck -- Add the magic golem and pocket rockertunity multiplier
			
			-- Rockertunity Ore
			local rck_ore_loss = (rck_mult * ore_swing) - (data.rck_loss * ore_swing)
			if rck_ore_loss > 1 then rck_ore_loss = 1 end
			local rck_ore = data.rck_hr * rck_ore_loss
			
			-- Rockertunity XP
			local rck_xp_min = data.rck_hr * ((rck_mult * xp_swing_min) - (data.rck_loss * xp_swing_min))
			local rck_xp_avg = data.rck_hr * ((rck_mult * xp_swing_avg) - (data.rck_loss * xp_swing_avg))
			local rck_xp_max = data.rck_hr * ((rck_mult * xp_swing_max) - (data.rck_loss * xp_swing_max))
			
			if method.rck == 1 then
				if r.core == 1 then
					-- !!! ROCKERTUNITY UPDATE: DISABLE IF EXPLOSIVE IS ACTIVE !!!
					if explosive == 0 then
						xp_hr_min = math.floor(xp_hr_min + rck_xp_min)
						xp_hr_avg = math.floor(xp_hr_avg + rck_xp_avg)
						xp_hr_max = math.floor(xp_hr_max + rck_xp_max)
						base_ore = base_ore + rck_ore
						total_ore = total_ore + rck_ore * ore_boosts
					end
					-- !!! END ROCKERTUNITY UPDATE !!!
				end
			end
			
			if r.diff == 1 then total_ore = 0 end -- Remove ore for unknown HP (seren stones / arc) temporary until their HP has been decided
			
			-- Stone spirits used, and cost
			local spirits_used = 0
			local spirit_cost = 0
			if spirits == 1 and r.spirits ~= nil and r.spirits > 0 then
				spirits_used = base_ore * r.spirits
				if juju ~= 'None' then
					spirits_used = spirits_used - base_ore * 0.1
				end
				spirits_used = math.ceil(spirits_used)
				spirit_cost = gemw.price(r.spirit_name)
			end
			
			-- Urns used, and cost
			local urns_used = 0
			local urn_cost = 0
			local urn_img = ''
			if xp_boosts_rock > xp_boosts then
				for _, urn in ipairs(urntypes) do
					if urn.level >= r.level then
						urn_img = urn.img..' '
						urns_used = math.ceil(xp_hr_avg / urn.xp)
						urn_cost = urn.ge
						break
					end
				end
			end
			
			-- Apply experience boosts and crystallise
			if r.core == 1 then
				-- Safe fallback added: (spell.ore or 1) and (spell.xp or 0)
				total_ore = math.floor(10 * total_ore * (spell.ore or 1))/10
				xp_hr_min = math.floor(xp_hr_min * (xp_boosts_rock + (spell.xp or 0)))
				xp_hr_avg = math.floor(xp_hr_avg * (xp_boosts_rock + (spell.xp or 0)))
				xp_hr_max = math.floor(xp_hr_max * (xp_boosts_rock + (spell.xp or 0)))
			else
				total_ore = math.floor(10 * total_ore)/10
				xp_hr_min = math.floor(xp_hr_min * xp_boosts_rock)
				xp_hr_avg = math.floor(xp_hr_avg * xp_boosts_rock)
				xp_hr_max = math.floor(xp_hr_max * xp_boosts_rock)
			end
			
			-- !!! PARADOX SPELL XP PENALTY !!!
			if paradox_active then
				-- Reduces XP gain by 60% (keeps only 40%)
				xp_hr_min = math.floor(xp_hr_min * 0.4)
				xp_hr_avg = math.floor(xp_hr_avg * 0.4)
				xp_hr_max = math.floor(xp_hr_max * 0.4)
			end
			
			-- Do not calculate XP if using a dwarven ramhammer
			if ramtmp == 'Damage Mode' then
				xp_hr_min = 0
				xp_hr_avg = 0
				xp_hr_max = 0
			elseif ramtmp == 'XP Mode' then
				total_ore = 0
			end
			
			-- Calculate GPH for best ore in the category
			local gold_per_hour = -1
			if (nil == r.avg_value) == false then
				gold_per_hour = total_ore * r.avg_value
			elseif (nil == r.name_GrandExchange) == false then
				local total_price = 0
				local count = 0
				for index,name in pairs(r.name_GrandExchange) do
					total_price = total_price + gemw.price(name)
					count = count + 1
				end
				gold_per_hour = total_ore * total_price / count
			else
				gold_per_hour = 0
			end
			
			-- Add a row to the table
			if not has_target then
				-- Total Geodes
				local geodes = ""
				local geode_price = 0
				local total_geode = 0
				if r.core == 1 then										-- Geodes only work with core rocks
					if method.rck == 1 then geodes = (base_ore + rck_ore) * geode_chance
					else				geodes = base_ore * geode_chance end
					if r.geode == 'Sedimentary' then
						local sednum = math.floor(100*geodes)/100
						geode_price = sednum * geodePrice('sedimentary')
						geodes = '[[File:Sedimentary geode.png|Sedimentary geode|link=Sedimentary geode]] '..sednum
						total_geode = sednum
					else
						local ignnum = math.floor(100*(geodes*(1-meta)))/100
						local metnum = math.floor(100*(geodes*meta))/100
						geode_price = ignnum * geodePrice('igneous') + metnum * geodePrice('metamorphic')
						geodes = '[[File:Igneous geode.png|Igneous geode|link=Igneous geode]] '..ignnum..'<br>[[File:Metamorphic geode.png|Metamorphic geode|link=Metamorphic geode]] '..metnum
						total_geode = ignnum + metnum
					end
				end
				
				-- Urn cost
				urn_cost = urns_used * urn_cost
				
				-- Spirits cost
				spirit_cost = spirits_used * spirit_cost
				
				-- Porter cost
				local porter_cost = base_ore * math.min(r.ore, 1) * porter * (1 - impsouled)
				
				-- GP per hour
				local total_profit = gold_per_hour + math.floor(geode_price) - urn_cost - spirit_cost - porter_cost
				
				-- Clean up values and ignore zero values for a cleaner looking calculator
				if net_hardness == 0 then net_hardness = "" end
				if total_ore == 0 then total_ore = "" end
				if r.core == 0 then geode_chance = ""
				else geode_chance = (geode_chance*100)..'%'
				end
				
				local row = t:tag('tr')
				row:tag('td')  :wikitext(r.level)                           :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(r.img..' '..r.name)                                                   :done()
				:tag('td')  :wikitext(net_hardness)                         :css('text-align', 'center')    :done()
				:tag('td')  :wikitext((crit_chance*100)..'%')               :css('text-align', 'center')    :done()
				:tag('td')  :wikitext((double_ore_chance*100)..'%')         :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(fnum(xp_hr_min))                      :css('text-align', 'center')    :done()
				:tag('td')  :wikitext("'''"..fnum(xp_hr_avg).."'''")        :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(fnum(xp_hr_max))                      :css('text-align', 'center')    :done()
				if spirits > 0 then
					if r.spirits ~= nil and r.spirits > 0 then
						row:tag('td')	:wikitext(string.format('[[File:%s.png|%s|link=%s]]', r.spirit_name, r.spirit_name, r.spirit_name)..fnum(spirits_used))
						:css('text-align', 'center')	:attr('data-sort-value', urns_used)    :done()
					else
						row:tag('td')	:wikitext(fnum(spirits_used) or "")	:css('text-align', 'center')	:attr('data-sort-value', urns_used)    :done()
					end
				end
				if urns > 0 then
					row:tag('td')	:wikitext(urn_img..fnum(urns_used))		:css('text-align', 'center')	:attr('data-sort-value', urns_used)    :done()
				end
				row:tag('td')  :wikitext(fnum(total_ore) or "")             :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(coins(gold_per_hour,'coins'))         :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(geode_chance)                         :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(geodes)                               :css('text-align', 'center')    :attr('data-sort-value', total_geode)	:done()
				:tag('td')  :wikitext(coins(total_profit,'coins'))          :css('text-align', 'center')    :done()
				:done()
			else
				-- Color rows based on current/target levels
				local row_classes = 'table-bg-yellow sortbottom'
				if target_lvl < r.level then 			row_classes = 'table-bg-red sortbottom'
				elseif mining_level >= r.level then		row_classes = 'table-bg-green' end
				
				-- Calculate time needed
				local min_time = math.ceil(remaining / xp_hr_max)
				local avg_time = math.ceil(remaining / xp_hr_avg)
				local max_time = math.ceil(remaining / xp_hr_min)
				
				-- Spirits used, and cost
				spirits_used = math.ceil(avg_time * spirits_used)
				spirit_cost = spirits_used * spirit_cost
				
				-- Urns used, and cost
				urns_used = math.ceil(avg_time * urns_used)
				urn_cost = urns_used * urn_cost
				
				-- Porters cost
				local porter_cost = avg_time * base_ore * math.min(r.ore, 1) * porter * (1 - impsouled)
				
				-- Total ore
				total_ore = math.floor(total_ore * avg_time)
				-- Total ore cost
				local ore_cost = math.floor(avg_time * gold_per_hour)
				
				-- Total geodes and price
				local geodes = ""
				local geode_price = 0
				local total_geode = 0
				if r.core == 1 then										-- Geodes only work with core rocks
					if method.rck == 1 then geodes = (base_ore + rck_ore) * geode_chance
					else				geodes = base_ore * geode_chance end
					if r.geode == 'Sedimentary' then
						local sednum = math.floor(avg_time * (100*geodes)/100)
						geode_price = sednum * geodePrice('sedimentary')
						geodes = '[[File:Sedimentary geode.png|Sedimentary geode|link=Sedimentary geode]] '..sednum
						total_geode = sednum
					else
						local ignnum = math.floor(avg_time * 100*(geodes*(1-meta))/100)
						local metnum = math.floor(avg_time * 100*(geodes*meta)/100)
						geode_price = ignnum * geodePrice('igneous') + metnum * geodePrice('metamorphic')
						geodes = '[[File:Igneous geode.png|Igneous geode|link=Igneous geode]] '..ignnum..'<br>[[File:Metamorphic geode.png|Metamorphic geode|link=Metamorphic geode]] '..metnum
						total_geode = ignnum + metnum
					end
				end
				
				-- Total profit and profit per xp
				local total_profit = ore_cost + geode_price - urn_cost - spirit_cost - porter_cost
				local profit_xp = math.floor((total_profit / remaining)*100) / 100
				
				-- Clean up values and ignore zero values for a cleaner looking calculator
				if net_hardness == 0 then net_hardness = "" end
				if total_ore == 0 then total_ore = "" end
				if r.core == 0 then geode_chance = ""
				else geode_chance = (geode_chance*100)..'%'
				end
				
				local row = t:tag('tr')	:addClass(row_classes)
				row:tag('td')	:wikitext(r.img..' '..r.name)										:done()
				:tag('td')  :wikitext(r.level)                              :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(fnum(min_time))                       :css('text-align', 'center')    :done()
				:tag('td')  :wikitext("'''"..fnum(avg_time).."'''")         :css('text-align', 'center')	:done()
				:tag('td')  :wikitext(fnum(max_time))                       :css('text-align', 'center')    :done()
				if spirits > 0 then
					if r.spirits ~= nil and r.spirits > 0 then
						row:tag('td')	:wikitext(string.format('[[File:%s.png|%s|link=%s]]', r.spirit_name, r.spirit_name, r.spirit_name)..fnum(spirits_used))
						:css('text-align', 'center')	:attr('data-sort-value', urns_used)    :done()
					else
						row:tag('td')	:wikitext(fnum(spirits_used) or "")	:css('text-align', 'center')	:attr('data-sort-value', urns_used)    :done()
					end
				end
				if urns > 0 then
					row:tag('td')	:wikitext(urn_img..fnum(urns_used))		:css('text-align', 'center')	:attr('data-sort-value', urns_used)    :done()
				end
				row:tag('td') :wikitext(fnum(total_ore) or "")              :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(geodes)                               :css('text-align', 'center')	:attr('data-sort-value', total_geode)   :done()
				:tag('td')  :wikitext(coins(ore_cost,'coins'))              :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(coins(total_profit,'coins'))          :css('text-align', 'center')    :done()
				:tag('td')  :wikitext(coins(profit_xp,'coins'))             :css('text-align', 'center')    :done()
				:done()
			end
		end
	end
	
	local msg = mw.html.create('div')
	-- Add message of xp needed to reach target
	if has_target then
		local msgtxt = 'To train mining from '..commas(mining_xp)..' experience (level '..virtual_mining_level..') to '..commas(target_xp)..' experience (level '..target_lvl..'), '..commas(remaining)..' experience is required.'
		msg:tag('p'):css({['font-size'] = "1.1em", ['font-weight'] = "bold"}):wikitext(msgtxt):done()
	end
	-- Add message for pickaxe level
	if higher_pick then
		local msgtxt = orig_pick.name..' pickaxe requires mining level '..orig_pick.level..' to use. Your pickaxe will act as a '..pick.name..' pickaxe.'
		msg:tag('p'):css({['font-size'] = "1em", ['font-weight'] = "bold", ['color'] = "red",}):wikitext(msgtxt):done()
	end
	
	return tostring(msg)..tostring(t)
end

--[=[ remainingExp
-- Finds and returns experiences and levels based on inputs
-- Inputs:
--      curLvl		The current level or 1
--		curXP		The current xp or 1
--      tgtLvl		The target level or 0
--		tgtXP		The target xp or 0
-- Returns:
--      current level,
--      current experience,
--      goal level,
--      goal experience,
--      experience remaining
--]=]
function remainingExp(curLvl, curXP, tgtLvl, tgtXP)
	local remaining
	if curLvl > 120 and curXP == 1 then
		curXP = curLvl
	elseif curXP <= 120 and curLvl == 1 then
		curLvl = curXP
		curXP = 1
	end
	if tgtLvl > 120 and tgtXP == 0 then
		tgtXP = tgtLvl
	elseif tgtXP <= 120 and tgtLvl == 0 then
		tgtLvl = tgtXP
		tgtXP = 0
	end
	if curXP == 1 then
		curXP = xp(curLvl)
	else
		curLvl = level(curXP)
	end
	if tgtLvl > 0 or tgtXP > 0 then
		if tgtXP == 0 then
			tgtXP = xp(tgtLvl)
		else
			tgtLvl = level(tgtXP)
		end
	end
    -- Prevent negative values
    local remaining = math.ceil(tgtXP - curXP)
    if remaining < 0 then
        remaining = 0
    end
    return curLvl, curXP, tgtLvl, tgtXP, remaining
end

--[=[ geodePrice
-- Calculates and returns average price for a geode based on its possible rewards
-- Inputs:
--      gtype		Geode type
-- Returns:
--      average price
--]=]
function geodePrice(gtype)
	local total = 0
	local items = 0
	-- Loop over geode and get prices
	for index,i in ipairs(data[gtype]) do
		if gtype == 'metamorphic' then
			if i.name == 'Dragon equipment' then
				-- Dragon drops based on Mod Breezy on Discord 22-Jan-19
				local dragonequip = {
					gemw.price('Dragon battleaxe'),
					gemw.price('Off-hand dragon battleaxe'),
					gemw.price('Dragon claw'),
					gemw.price('Off-hand dragon claw'),
					gemw.price('Dragon longsword'),
					gemw.price('Off-hand dragon longsword'),
					gemw.price('Dragon mace'),
					gemw.price('Off-hand dragon mace'),
					gemw.price('Dragon scimitar'),
					gemw.price('Off-hand dragon scimitar'),
					gemw.price('Dragon warhammer'),
					gemw.price('Off-hand dragon warhammer'),
					gemw.price('Dragon hasta'),
					gemw.price('Dragon 2h sword'),
					gemw.price('Dragon halberd'),
					gemw.price('Dragon spear'),
					gemw.price('Dragon full helm'),
					gemw.price('Dragon helm'),
					gemw.price('Dragon chainbody'),
					gemw.price('Dragon kiteshield'),
					gemw.price('Dragon sq shield'),
					gemw.price('Dragon platelegs'),
					gemw.price('Dragon plateskirt'),
					gemw.price('Dragon boots'),
				}
				local sum = 0
				for i,v in ipairs(dragonequip) do
					sum = sum + v
				end
				total = total + sum/table.getn(dragonequip)
				items = items + 1
			elseif i.ge == 'no' then
				if i.alch == 'yes' then
					total = total + i.alchvalue
					items = items + 1
				elseif i.merch == 'yes' then
					total = total + i.merchvalue
					items = items + 1
				else
					items = items + 1
				end
			else
				if i.number == 1 then
					if i.name == 'Uncut onyx' then
						total = total + gemw.price(i.name) * (1/10)
						--skip adding to count here, adding below for onyx dust since both are 1/14 chance like the rest
					else
						total = total + gemw.price(i.name)
						items = items + 1
					end
				else
					if i.name == 'Onyx dust' then
						local minprice = gemw.price(i.name) * i.low
						local maxprice = gemw.price(i.name) * i.high
						total = total + ((minprice+maxprice)/2)*(9/10)
						items = items + 1
					else
						local minprice = gemw.price(i.name) * i.low
						local maxprice = gemw.price(i.name) * i.high
						total = total + (minprice+maxprice)/2
						items = items + 1
					end
				end
			end
		else
			total = total + gemw.price(i.name) * i.prob
		end
	end
	if gtype == 'metamorphic' then
		total = total / items
	end
	return math.floor(total)
end
return p