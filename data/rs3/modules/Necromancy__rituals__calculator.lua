--[[

Test command:

mw.log( p._main({
    ["necromancy_lvl"] = 99,
    ["target_lvl"] = 120,
    ["ritual"] = "Lesser ensoul material",
    -- ["ritual"] = "Lesser necroplasm",
    ["Lesser ensoul material"] = "Lesser unensouled bar",
    ["Lesser necroplasm"] = "Weak necroplasm",
    ["ritual_site"] = "Um",
    ["disturbance_speed"] = "Average",
    ["to_necroplasm"] = false,
    ["a4"] = "None",
    ["a5"] = "None",
    ["a6"] = "None",
    ["a7"] = "None",
    ["a8"] = "None",
    ["a9"] = "None",
    ["a10"] = "Speed I",
    ["a11"] = "Multiply III",
    ["a12"] = "None",
    ["underworld_grimoire"] = "Underworld Grimoire 2",
    ["xp_boost"] = 3,
    ["alteration_necklace"] = true,
	["ring_of_kayazu"] = true
}) )

]]

local _geprice = require('Module:Exchange')._price


local p = {}
local getArgs = require("Module:Arguments").getArgs;
local data = mw.loadData("Module:Necromancy/rituals/data")
local lamp_xps = mw.loadData("Module:Lamp/data").lamp_xps;
local commas = require('Module:Addcommas')._add
local _coins = require('Module:Currency')._coins
local nextUp = require("Module:Math/ulp").nextUp
local xp_to_lvl = require("Module:Experience")._level_at_xp
local lvl_to_xp = require("Module:Experience")._xp_at_level


local noprice = {
	"Soul",
	"Lesser unensouled bar", "Lesser ensouled bar",
	"Unensouled bar", "Ensouled bar",
	"Greater unensouled bar", "Greater ensouled bar",
	"Lesser ensouled cloth", "Ensouled cloth", "Greater ensouled cloth",
	"Lesser ensouled thread", "Ensouled thread", "Greater ensouled thread",
	"Bucket of slime"
}

local ingredient_sort_key = {
	"Weak necroplasm", "Lesser necroplasm", "Greater necroplasm", "Powerful necroplasm",
	"Basic ghostly ink", "Regular ghostly ink", "Greater ghostly ink", "Powerful ghostly ink",
	"Ashes", "Vial of water", "Ectoplasm"
}

local function get_ingredient_sort_key(ingredient)
	for i, sorted in ipairs(ingredient_sort_key) do
		if sorted == ingredient then
			return i
		end
	end
	return 0
end

local function ingredient_sort_compare(a, b)
	return get_ingredient_sort_key(a) < get_ingredient_sort_key(b)
end

local function sorted_ingredients(ingredient_mapping)
	local ingredients = {}
	for n, _ in pairs(ingredient_mapping) do table.insert(ingredients, n) end
	table.sort(ingredients, ingredient_sort_compare)
	local i = 0
	return function()
		i = i + 1
		local ingredient = ingredients[i]
		if ingredient ~= nil then
			return ingredient, ingredient_mapping[ingredient]
		end
		return nil
	end
end

local function geprice(item)
	-- Items bought from Soul Supplies
	if item == "Basic ghostly ink" then
		return 3
	elseif item == "Weak necroplasm" then
		return 3
	elseif item == "Basic ritual candle" then
		return 3	
	end
	for _, nopriceitem in ipairs(noprice) do
		if item == nopriceitem then
			return nil
		end
	end
	return _geprice(item)
end

local function round(n)
	if n % 1 ~= 0 then
		return math.floor(n+0.5)
	end
	return n
end

local function round2dp(n)  -- round to 2 decimal places
	if (n * 100) % 1 ~= 0 then
		return round(n*100)/100
	end
	return n
end

local function floor1dp(n)  -- floor to 1 decimal place
	if ((n * 10) % 1 ~= 0) then
		return math.floor(n * 10) / 10;
	end
	return n;
end

local function clamp(value, min, max)
	-- assert(min <= max);
	return math.min(max, math.max(value, min));
end

local function coins(n)
	return _coins(round(n))
end

local function lcm(a, b)
	-- Thanks to Ungael have possible prime factors 2, 3, 5, and 7
	local result = 1
	while a%2 == 0 and b%2 == 0 do
		result = result*2
		a = a/2
		b = b/2
	end
	while a%3 == 0 and b%3 == 0 do
		result = result*3
		a = a/3
		b = b/3
	end
	while a%5 == 0 and b%5 == 0 do
		result = result*5
		a = a/5
		b = b/5
	end
	while a%7 == 0 and b%7 == 0 do
		result = result*7
		a = a/7
		b = b/7
	end
	return result * a * b
end

local function ritual_foundational_glyphs(ritual)
	local result = 0
	for _, v in pairs(data.rituals[ritual].glyphs) do
		result = result+v
	end
	return result
end

local function disturbance_spawn_chance(attraction)
	-- Expected disturbance spawn chance by soul attraction "window".
	local chance = 1
	for _, name_limit in ipairs(data.attractionnames) do
		if attraction >= name_limit[2] then
			if name_limit.disturbance_chance ~= nil then
				chance = name_limit.disturbance_chance
			end
		end
	end
	return chance
end

local function disturbance_tier_cap(tier)
	-- Lesser rituals cap the roll at the last attraction before the first tier 2 disturbance.
	-- Greater rituals cap the roll at the last attraction before the first tier 3 disturbance.
	if tier >= 3 then return math.huge end
	local next_tier = tier + 1
	local min_attraction_next_tier = nil
	for _, disturbance in ipairs(data.disturbances) do
		if disturbance[2] == next_tier then
			min_attraction_next_tier = disturbance[3]
			break
		end
	end
	if min_attraction_next_tier == nil then
		return math.huge
	end
	return min_attraction_next_tier - 1
end

local function disturbance_probability(disturbance, attraction, tier)
	local cap = disturbance_tier_cap(tier)
	local roll_max = math.min(attraction, cap)
	if roll_max <= 0 then return 0 end
	if disturbance[2] > tier then return 0 end
	local min_attr = disturbance[3]
	if roll_max < min_attr then return 0 end

	-- Determine this disturbance's bucket as [min_attr, next_min_attr - 1] or [min_attr, roll_max] if last.
	local max_attr = roll_max
	for _, other in ipairs(data.disturbances) do
		local other_min = other[3]
		if other_min > min_attr then
			max_attr = math.min(max_attr, other_min - 1)
			break
		end
	end
	if max_attr < min_attr then return 0 end

	local bucket_len = max_attr - min_attr + 1
	local p_bucket = bucket_len / roll_max

	-- Special case: Wandering soul and Sparkling glyph share the 1-100 bucket equally.
	if min_attr == 1 then
		local same_bucket = 0
		for _, other in ipairs(data.disturbances) do
			if other[3] == 1 then
				same_bucket = same_bucket + 1
			else
				break
			end
		end
		if same_bucket > 0 then
			return p_bucket / same_bucket
		end
	end

	return p_bucket
end

local function add_counts(total, counts, multiplier)
	for k, v in pairs(counts) do
		local new_total = math.floor(nextUp((total[k] or 0) + v*multiplier))
		if new_total == 0 then new_total = nil end
		total[k] = new_total
	end
end

local function glyph_durability(glyph,ritual_site)
	local glyph_data = data.glyphs[glyph]
	if ritual_site == "Um" then return data.glyphduration[glyph_data.type][glyph_data.tier] end
	if ritual_site == "Ungael" then return data.glyphdurationungael[glyph_data.type][glyph_data.tier] end
end

local function item_output_row(item, amount)
	local image
	local name
	local price_class = nil
	local price_each = geprice(item)
	local price_text
	if price_each == nil then
		price_class = "table-na"
		price_text = "N/A"
	else
		price_text = coins(price_each * amount)
	end
	if item == "Soul" then
		image = "[[File:Soul (Well of Souls).png|link=Soul (Well of Souls)|30px]]"
		name = "[[Soul (Well of Souls)|Souls]]"
	else
		image = "[[File:"..item..".png|link="..item.."]]"
		name = "[["..item.."]]"
	end
	return mw.html.create("tr")
	:tag("td")
		:css({ ['border-right'] = 'none',
		       ['text-align'] = 'center',
		       ['width'] = '1%' })
		:wikitext(image)
	:done()
	:tag('td')
		:css({ ['border-left'] = 'none',
		       ['padding-left'] = '0',
		       ['text-align'] = 'left',
		       ['width'] = '40%' })
		:wikitext(name)
	:done()
	:tag('td')
		:addClass('ref-left')
		:css({ ['width'] = '20%' })
		:wikitext(commas(round2dp(amount)))
	:done()
	:tag('td')
		:addClass('ref-left')
		:addClass(price_class)
		:css({ ['width'] = '25%' })
		:tag('span')
			:attr('title', price_each and (price_each .. ' each') or nil)
			:wikitext(price_text)
		:done()
	:done()
end

local function formatDuration(seconds)
	local result = {}

	local SECONDS_IN_HOUR = 60 * 60
	local SECONDS_IN_MINUTE = 60

	if seconds > SECONDS_IN_HOUR then
		table.insert(result, math.floor(seconds / SECONDS_IN_HOUR) .. "h")
		seconds = seconds % SECONDS_IN_HOUR
	end

	if seconds > SECONDS_IN_MINUTE then
		table.insert(result, math.floor(seconds / SECONDS_IN_MINUTE) .. "m")
		seconds = seconds % SECONDS_IN_MINUTE
	end

	table.insert(result, seconds .. "s")

	return table.concat(result, "&nbsp;")
end

local BOOSTABLE = '<sup title="This requirement is boostable. There is a non-boostable requirement of level %d" style="cursor:help; text-decoration: underline dotted;">(b)</sup>'
local NOT_BOOSTABLE = '<sup title="This requirement is not boostable" style="cursor:help; text-decoration: underline dotted;">(nb)</sup>'

local function boostableText(minLevel, maxLevel)
	if minLevel < maxLevel then
		return tostring(maxLevel) .. string.format(BOOSTABLE, minLevel)
	end
	return tostring(minLevel) .. NOT_BOOSTABLE
end

local function boolArg(x)
	if type(x) == type(true) then return x end
	if type(x) == type(nil) then return false end
	if type(x) == type("") then
		if x == "true" then return true end
		if x == "false" or x == "" then return false end
	end
	x = tonumber(x)
	return tonumber(x) ~= 0
end

local GAME_TICKS_PER_HOUR = 60 * 60 / 0.6

local function disturbance_speed_state(disturbance_speed)
	local lc = tostring(disturbance_speed or "Average")
	if lc == "AFK" then
		return true, nil
	end
  return false, lc
end

function p.main(frame)
	local args = getArgs(frame, {
		wrappers = "Calculator:Template/Necromancy/Rituals",
	});
	return p._main(args)
end

function p._main(args)
	local experience_mode = args.cur_toggle == "Experience"
	local lvl = tonumber(args.necromancy_lvl or xp_to_lvl(args.necromancy_xp)) or 1
	if experience_mode then
		lvl = xp_to_lvl(clamp(tonumber(args.necromancy_xp) or 0, 0, 200000000))
	end
	local to_necroplasm = boolArg(args.to_necroplasm)
	local alteration_necklace = boolArg(args.alteration_necklace)
	local ring_of_kayazu = boolArg(args.ring_of_kayazu)
	local ritual_site = args.ritual_site
	local site_multiplier = data.sitemultiplier[ritual_site]
	
	local alteration_multiplier = 0
	if alteration_necklace then
		alteration_multiplier = 20
	end

	local slots = 0
	for _, info in ipairs(data.glyphspots) do
		if lvl >= info[1] then
			slots = info[2]
		end
	end
	
	local ritual_name = args.ritual
	local ritual = data.rituals[ritual_name]
	local whole_rituals = 1
	local n_glyphs = 0
	local max_lvl = ritual.lvl
	-- ritual level can't be boosted
	local min_lvl = max_lvl
	for glyph, amount in pairs(ritual.glyphs) do
		n_glyphs = n_glyphs+amount
		whole_rituals = lcm(whole_rituals, glyph_durability(glyph,ritual_site))
		local glyph_lvl = data.glyphs[glyph].lvl
		if glyph_lvl > max_lvl then max_lvl = glyph_lvl end
	end
	local alterations = {}
	local alteration_effects = { ["attraction"] = 100 }
	for i = n_glyphs+1, 12 do  -- 11 possible glyph slots, 12th is the cape perk
		local alteration = args["a"..tostring(i)]
		if alteration ~= nil and alteration ~= "None" then
			local multiplier = nextUp((100 + alteration_multiplier)/100)
			if i ~= 12 then
				-- cape perk isn't added to cost or accounted for in durability
				alterations[alteration] = (alterations[alteration] or 0) + 1
				n_glyphs = n_glyphs+1
				whole_rituals = lcm(whole_rituals, glyph_durability(alteration,ritual_site))
			end
			add_counts(alteration_effects, data.glyphs[alteration].alteration, multiplier)
			local glyph_lvl = data.glyphs[alteration].lvl
			if glyph_lvl > max_lvl then max_lvl = glyph_lvl end
			if i == 12 and math.max(glyph_lvl, 99) > min_lvl then
				-- cape perk can't be boosted (and you need 99 for the cape)
				min_lvl = math.max(glyph_lvl, 99)
			end
		end
	end

	local used_glyphs = {}
	for glyph, amount in pairs(ritual.glyphs) do
		used_glyphs[glyph] = amount * (whole_rituals / glyph_durability(glyph,ritual_site))
	end
	for glyph, amount in pairs(alterations) do
		used_glyphs[glyph] = amount * (whole_rituals / glyph_durability(glyph,ritual_site))
	end

	local focus = args[ritual_name]
	local recipe = ritual.recipes[1]
	for _, possible_recipe in ipairs(ritual.recipes) do
		for this_focus, _ in pairs(possible_recipe[1]) do
			if this_focus == focus then
				recipe = possible_recipe
			end
		end
	end
	local input = {}
	add_counts(input, recipe[1], whole_rituals)
	for glyph, amount in pairs(used_glyphs) do
		add_counts(input, data.glyphs[glyph].recipe, amount)
	end

	local underworld_grimoire = ({ ["Underworld Grimoire 1"] = 1, ["Underworld Grimoire 2"] = 2, ["Underworld Grimoire 3"] = 3, ["Underworld Grimoire 4"] = 4 })[args.underworld_grimoire] or 0

	local necroplasm_multiplier = 0
	if ritual.type == "necroplasm" then
		if underworld_grimoire > 0 then
			necroplasm_multiplier = 5 * (underworld_grimoire - 1)
		end
	end

	local disturbance_bonus_xp = 0.03 * underworld_grimoire

	-- Need to do in two steps because first step needs to round down
	local single_output = {}
	add_counts(single_output, recipe[2], (100 + (alteration_effects.output or 0) + necroplasm_multiplier) / 100)
	if necroplasm_multiplier ~= 0 then
		-- Does not increase ectoplasm output (? I think)
		single_output["Ectoplasm"] = math.floor(recipe[2]["Ectoplasm"] * ((100 + (alteration_effects.output or 0)) / 100))
	end
	
	local output = {}
	add_counts(output, single_output, whole_rituals)

	if to_necroplasm then
		local update = { ["Vial of water"] = 0, ["Ashes"] = 0 }
		for ingredient, amount in pairs(input) do
			local necroplasm = data.ink2necroplasm[ingredient]
			if necroplasm then
				update[necroplasm] = 20 * amount
				update["Vial of water"] = update["Vial of water"]+amount
				update["Ashes"] = update["Ashes"]+amount
				update[ingredient] = -amount
			end
		end
		add_counts(input, update, 1)
	end

	local total_cost = 0
	for item, amount in pairs(input) do
		total_cost = total_cost + (geprice(item) or 0)*amount
	end
	local total_profit = 0
	for item, amount in pairs(output) do
		total_profit = total_profit + (geprice(item) or 0)*amount
	end

	local xp_boost = (100 + (tonumber(args.xp_boost) or 0)) / 100;
	local xp = math.floor(ritual.xp * site_multiplier * xp_boost);

	local speed = alteration_effects.speed
	local tick_text_extra = ""
	if speed ~= nil then
		if speed < -50 then
			tick_text_extra = " <span style=\"cursor:help; text-decoration: underline dotted;\" title=\"Modified by speed glyphs (capped from "..tostring(speed).."%)\">(-50%)</span>"
		else
			tick_text_extra = " <span style=\"cursor:help; text-decoration: underline dotted;\" title=\"Modified by speed glyphs\">("..tostring(speed).."%)</span>"
		end
	end
	local tick_text = "<span title=\"One ritual tick is two game ticks\"> Ritual ticks</span>" .. tick_text_extra
	local ticks = math.ceil(ritual.ticks * (100 + math.max(speed or 0, -50)) / 100)
	local is_disturbance_afk, disturbance_effort_key = disturbance_speed_state(args.disturbance_speed)

	local output_mult = alteration_effects.output
	local output_text_extra = ""
	local output_text_modified_by = nil
	
	local modifiers = {}
	if output_mult ~= nil then
		table.insert(modifiers, "multiply glyphs")
	end
	if necroplasm_multiplier ~= 0 then
		table.insert(modifiers, "the Underworld Grimoire")
	end
	if alteration_multiplier ~= 0 then
        table.insert(modifiers, "alteration necklace")
    end
	output_text_modified_by = table.concat(modifiers, " and ")
	
	if output_text_modified_by ~= nil then
		output_text_extra = " <span style=\"cursor:help; text-decoration: underline dotted;\" title=\"Modified by "..output_text_modified_by.."\">(+"..tostring((output_mult or 0) + necroplasm_multiplier).."%)</div>"
	end

	local attraction = alteration_effects.attraction
	if ring_of_kayazu then
		attraction = attraction + 80
	end
	local disturbance_duration = alteration_effects["disturbance duration"] or 0
	local disturbance_reward_multiplier = ring_of_kayazu and 1.2 or 1
	local spawn_chance = disturbance_spawn_chance(attraction)
	local maximum_disturbances = math.floor((ritual.ticks - 2) / 12)  -- Number of disturbances if there were no speed modifiers
	local actual_disturbances = math.floor((ticks - 2) / 12)

	local expected_disturbance_xp_per_ritual = 0
	local expected_tome_xp_per_ritual = 0
	if not is_disturbance_afk then
		local disturbance_xp_each = lamp_xps[clamp(lvl, 1, 120)] * site_multiplier * (xp_boost + disturbance_bonus_xp)
		local tome_xp_each = data.tome_xp[clamp(lvl, 1, 120)] * site_multiplier
		local expected_disturbance_xp_per_spawn = 0
		local expected_tome_xp_per_spawn = 0
		for _, disturbance in ipairs(data.disturbances) do
			local p_spawn = disturbance_probability(disturbance, attraction, ritual.tier)
			if p_spawn > 0 then
				local xp_contrib = p_spawn * disturbance.xp_multiplier * disturbance_xp_each
				expected_disturbance_xp_per_spawn = expected_disturbance_xp_per_spawn + xp_contrib
				local tome_chance = disturbance.xp_tome_chance or 0
				local tome_contrib = 0
				if tome_chance ~= 0 then
					tome_contrib = p_spawn * tome_chance * tome_xp_each * disturbance_reward_multiplier
					expected_tome_xp_per_spawn = expected_tome_xp_per_spawn + tome_contrib
				end
			end
		end
		expected_disturbance_xp_per_ritual = expected_disturbance_xp_per_spawn * spawn_chance * actual_disturbances
		expected_tome_xp_per_ritual = expected_tome_xp_per_spawn * spawn_chance * actual_disturbances
	end

	-- Target-level or target-experience calculation, according to the selected mode.
	-- Uses the same Total XP per ritual displayed by the original calculator.
	local target_lvl = nil
	local target_xp = nil
	if experience_mode then
		target_xp = tonumber(args.target_xp)
		if target_xp ~= nil then
			target_xp = clamp(target_xp, 0, 200000000)
			target_lvl = clamp(xp_to_lvl(target_xp), 1, 120)
		end
	else
		target_lvl = tonumber(args.target_lvl)
		if target_lvl ~= nil then
			target_lvl = clamp(math.floor(target_lvl), 1, 120)
			target_xp = lvl_to_xp(target_lvl)
		end
	end
	local current_xp = nil
	local xp_remaining = nil
	local total_xp_per_ritual = floor1dp(
		xp + expected_disturbance_xp_per_ritual + expected_tome_xp_per_ritual
	)
	local rituals_to_target = nil

	-- Same ritual duration used by the original Ritual ticks display.
	local ritual_time_seconds = ticks * 2 * 0.6
	local total_ritual_time_seconds = nil

	-- Reuse the original calculator's average GP figures.
	local target_input_cost = nil
	local target_output_value = nil
	local target_net_profit = nil

	if target_xp ~= nil then
		if experience_mode and tonumber(args.necromancy_xp) ~= nil then
			current_xp = clamp(tonumber(args.necromancy_xp), 0, 200000000)
		else
			current_xp = lvl_to_xp(clamp(lvl, 1, 120))
		end

		xp_remaining = math.max(0, target_xp - current_xp)

		if total_xp_per_ritual > 0 then
			rituals_to_target = math.ceil(xp_remaining / total_xp_per_ritual)
		else
			rituals_to_target = 0
		end

		total_ritual_time_seconds = ritual_time_seconds * rituals_to_target

		local average_input_cost = total_cost / whole_rituals
		local average_output_value = total_profit / whole_rituals

		target_input_cost = average_input_cost * rituals_to_target
		target_output_value = average_output_value * rituals_to_target
		target_net_profit = target_output_value - target_input_cost
	end

	local effective_game_ticks = ticks * 2
	if not is_disturbance_afk then
		local it = data.disturbance_interaction_time
		if it then
			local restart = it.restart_ticks or 0
			local effort_tbl = (it.effort and disturbance_effort_key and it.effort[disturbance_effort_key]) or {}
			local ev_game_ticks_per_opp = 0
			for _, disturbance in ipairs(data.disturbances) do
				local p = disturbance_probability(disturbance, attraction, ritual.tier)
				if p > 0 then
					local budget = effort_tbl[disturbance[1]] or 0
					local time_contrib = p * (restart + budget)
					ev_game_ticks_per_opp = ev_game_ticks_per_opp + time_contrib
				end
			end
			ev_game_ticks_per_opp = ev_game_ticks_per_opp * spawn_chance
			effective_game_ticks = effective_game_ticks + (actual_disturbances * ev_game_ticks_per_opp)
		end
	end

	local result = {}
	if not is_disturbance_afk then
		local attraction_frag = {}
		table.insert(attraction_frag, "Soul attraction: "..tostring(attraction).."%<br>")
		for i, name_limit in ipairs(data.attractionnames) do
			if attraction >= name_limit[2] then
				table.insert(attraction_frag, "[[File:Soul attraction active.png|30px|"..name_limit[1].."|link=Soul attraction]]")
			else
				table.insert(attraction_frag, "[[File:Soul attraction inactive.png|30px|"..name_limit[1].."|link=Soul attraction]]")
			end
		end
		if disturbance_duration ~= 0 then
			table.insert(attraction_frag, "<br>Ritual disturbance duration increased by +"..tostring(disturbance_duration).."% by protection glyphs")
		end

		local placed_bracket = false
		local disturbance_ticks = {}
		for i=1,maximum_disturbances do
			local disturbance_tick = ticks - 1 - 12*i
			if i ~= 1 then table.insert(disturbance_ticks, ", ") end
			if not placed_bracket and disturbance_tick <= 0 then
				placed_bracket = true
				local lost = maximum_disturbances-actual_disturbances
				local plural = "s"
				if lost == 1 then plural = "" end
				table.insert(disturbance_ticks, "<span style=\"cursor:help; text-decoration: underline dotted;\" title=\"There are too many speed glyphs so you lose " .. tostring(lost) .. " possible disturbance" .. plural .. ", reducing xp rates from disturbances\">(")
			end
			table.insert(disturbance_ticks, tostring(disturbance_tick))
		end
		if placed_bracket then
			table.insert(disturbance_ticks, ")</span>")
		end
		disturbance_ticks = table.concat(disturbance_ticks)

		local disturbance_ticks_col_header = "Duration in ticks"
		if disturbance_duration ~= 0 then
			disturbance_ticks_col_header = disturbance_ticks_col_header .. " <span style=\"cursor:help; text-decoration: underline dotted;\" title=\"Modified by protection glyphs (+" .. tostring(disturbance_duration) .. "% disturbance duration)\">(+" .. tostring(disturbance_duration) .. "%)</span>"
		end

		local disturbance_table = mw.html.create("table")
			:addClass("wikitable")

		disturbance_table
		:tag("tr")
			:tag("th")
				:attr("colspan", "2")
				:wikitext("Soul attraction")
			:done()
			:tag("th"):wikitext("Disturbance chance"):done()
			:tag("th"):wikitext("<span style=\"cursor:help; text-decoration: underline dotted;\" title=\"The possible ritual ticks when a disturbance can spawn\">Disturbance ticks</span> (" .. tostring(actual_disturbances) .. ")"):done()
		:done()
		:tag("tr")
			:tag("td")
				:attr("colspan", "2")
				:wikitext(table.concat(attraction_frag, ""))
			:done()
			:tag("td")
				:wikitext(round2dp(spawn_chance * 100) .. "%")
			:done()
			:tag("td")
				:wikitext(disturbance_ticks)
			:done()
		:done()

		disturbance_table
		:tag("tr")
			:tag("th"):wikitext("Disturbance"):done()
			:tag("th"):wikitext("XP"):done()
			:tag("th"):wikitext("Chance"):done()
			:tag("th"):wikitext(disturbance_ticks_col_header):done()
		:done()

		for _, disturbance in ipairs(data.disturbances) do
			if disturbance[2] <= ritual.tier and disturbance[3] <= attraction then
				local p_spawn = disturbance_probability(disturbance, attraction, ritual.tier)
				local event_ticks = disturbance.ticks
				local display_ticks = "—"
				if event_ticks ~= nil then
					local modified_ticks = math.floor(event_ticks * (100 + disturbance_duration) / 100)
					local seconds = modified_ticks * 0.6
					local seconds_text = tostring(seconds)
					if seconds % 1 ~= 0 then
						seconds_text = tostring(round2dp(seconds))
					end
					display_ticks = tostring(modified_ticks) .. " (" .. seconds_text .. " seconds)"
				end
				disturbance_table
				:tag("tr")
					:tag("td"):wikitext("[["..disturbance[1].."]]"):done()
					:tag("td"):wikitext(floor1dp(disturbance.xp_multiplier * lamp_xps[clamp(lvl, 1, 120)] * site_multiplier * (xp_boost + disturbance_bonus_xp)) .. "&nbsp;XP"):done()
					:tag("td"):wikitext(round2dp(p_spawn * spawn_chance * 100) .. "%"):done()
					:tag("td"):wikitext(display_ticks):done()
				:done()
			end
		end

		table.insert(result, "== Disturbances ==\n")
		table.insert(result, tostring(disturbance_table:done()))
	end

	local tableholder = mw.html.create("div")
		:addClass('recipe-table')
		:cssText('width:-moz-fit-content;width:fit-content;max-width:515px;')

	local ritual_xp_h_title = "Experience gained per hour"
	if effective_game_ticks > (ticks * 2) then
		ritual_xp_h_title = "Experience gained per hour (includes expected time spent handling disturbances)"
	end
	local total_xp_h_title = "Total expected experience gained per hour"
	if effective_game_ticks > (ticks * 2) then
		total_xp_h_title = "Total expected experience gained per hour (includes expected time spent handling disturbances)"
	end

	for i=0,1 do
		local divider = 1
		if i == 0 then divider = whole_rituals end
		local header = "Per ritual (Average)"
		if i == 1 then header = "Per " .. tostring(whole_rituals) .. " rituals (Lowest common multiple of all glyphs)" end

		local tables = tableholder:tag("table"):addClass("wikitable infobox-recipe"):css({ width = '100%' })
		:tag("tr")
			:tag("th")
				:attr("colspan", "4")
				:wikitext(header)
			:done()
		:done()
		:tag("tr")
			:tag("th")
				:wikitext("Level required")
			:done()
			:tag("td")
				:wikitext(boostableText(min_lvl, max_lvl))
			:done()
			:tag("th")
				:wikitext(tick_text)
			:done()
			:tag("td")
				:wikitext(tostring(ticks*whole_rituals/divider).." ("..formatDuration(ticks*whole_rituals/divider*0.6*2)..")")
			:done()
		:done()
		:tag("tr")
			:tag("th")
				:wikitext("Ritual XP")
			:done()
			:tag("td")
				:wikitext(commas(xp*whole_rituals/divider))
			:done()
			:tag("th")
				:wikitext("Ritual XP/h")
				:attr("title", ritual_xp_h_title)
			:done()
			:tag("td")
				:wikitext(commas(math.floor(xp * GAME_TICKS_PER_HOUR / effective_game_ticks)))
			:done()
		:done()
		if not is_disturbance_afk then
			tables
			:tag("tr")
				:tag("th")
					:wikitext("Disturbance XP")
				:done()
				:tag("td")
					:wikitext(commas(floor1dp(expected_disturbance_xp_per_ritual*whole_rituals/divider)))
				:done()
				:tag("th")
					:wikitext("Disturbance XP/h")
					:attr("title", "Expected experience gained per hour from disturbances")
				:done()
				:tag("td")
					:wikitext(commas(math.floor(expected_disturbance_xp_per_ritual * GAME_TICKS_PER_HOUR / effective_game_ticks)))
				:done()
			:done()
		end
		if not is_disturbance_afk and expected_tome_xp_per_ritual ~= 0 then
			tables
			:tag("tr")
				:tag("th")
					:wikitext("Tome XP")
				:done()
				:tag("td")
					:wikitext(commas(floor1dp(expected_tome_xp_per_ritual*whole_rituals/divider)))
				:done()
				:tag("th")
					:wikitext("Tome XP/h")
					:attr("title", "Expected experience gained per hour from tomes")
				:done()
				:tag("td")
					:wikitext(commas(math.floor(expected_tome_xp_per_ritual * GAME_TICKS_PER_HOUR / effective_game_ticks)))
				:done()
			:done()
		end
    tables
		:tag("tr")
			:tag("th")
				:wikitext("Total XP")
			:done()
			:tag("td")
				:wikitext(commas(floor1dp((xp + expected_disturbance_xp_per_ritual + expected_tome_xp_per_ritual)*whole_rituals/divider)))
			:done()
			:tag("th")
				:wikitext("Total XP/h")
				:attr("title", total_xp_h_title)
			:done()
			:tag("td")
				:wikitext(commas(math.floor((xp + expected_disturbance_xp_per_ritual + expected_tome_xp_per_ritual) * GAME_TICKS_PER_HOUR / effective_game_ticks)))
			:done()
		:done()
		:tag("tr")
			:tag("th")
				:attr("colspan", "4")
				:wikitext("Inputs")
			:done()
		:done()
		for item, amount in sorted_ingredients(input) do
			tables:node(item_output_row(item, round2dp(amount / divider)))
		end
		tables
		:tag("tr")
			:tag("th")
				:attr("colspan", "3")
				:wikitext("Total cost")
			:done()
			:tag("td")
				:wikitext(coins(total_cost / divider))
			:done()
		:done()
		:tag("tr")
			:tag("th")
				:attr("colspan", "4")
				:wikitext("Outputs"..output_text_extra)
			:done()
		:done()
		for item, amount in sorted_ingredients(output) do
			tables:node(item_output_row(item, amount / divider))
		end
		tables
		:tag("tr")
			:tag("th")
				:attr("colspan", 3)
				:wikitext("Total profit")
			:done()
			:tag("td")
				:wikitext(coins(total_profit / divider))
			:done()
		:done()
		:tag("tr")
			:tag("th")
				:wikitext("Net profit")
			:done()
			:tag("td")
				:wikitext(coins((total_profit - total_cost) / divider))
			:done()
			:tag("th")
				:wikitext("Net profit per hour")
			:done()
			:tag("td")
				:wikitext(coins((total_profit - total_cost) * GAME_TICKS_PER_HOUR / (effective_game_ticks * whole_rituals)))
			:done()
		:done():done()
	end
	if target_xp ~= nil then
		local target_label = experience_mode and "Target experience" or "Target level"
		table.insert(result, "\n== " .. target_label .. " ==\n")

		local targetholder = mw.html.create("div")
			:addClass('recipe-table')
			:cssText('width:-moz-fit-content;width:fit-content;max-width:515px;')

		local targettable = targetholder:tag("table")
			:addClass("wikitable infobox-recipe")
			:css({ width = '100%' })

		targettable
		:tag("tr")
			:tag("th")
				:attr("colspan", "4")
				:wikitext(target_label .. " calculation")
			:done()
		:done()

		:tag("tr")
			:tag("th"):wikitext("Current XP"):done()
			:tag("td"):wikitext(commas(round(current_xp))):done()
			:tag("th"):wikitext("Target level"):done()
			:tag("td"):wikitext(tostring(target_lvl)):done()
		:done()

		:tag("tr")
			:tag("th"):wikitext("Target XP"):done()
			:tag("td"):wikitext(commas(round(target_xp))):done()
			:tag("th"):wikitext("XP remaining"):done()
			:tag("td"):wikitext(commas(round(xp_remaining))):done()
		:done()

		:tag("tr")
			:tag("th"):wikitext("Total XP per ritual"):done()
			:tag("td"):wikitext(commas(total_xp_per_ritual)):done()
			:tag("th"):wikitext("Rituals required"):done()
			:tag("td"):wikitext(commas(rituals_to_target)):done()
		:done()

		:tag("tr")
			:tag("th"):wikitext("Ritual time"):done()
			:tag("td"):wikitext(formatDuration(round(ritual_time_seconds))):done()
			:tag("th"):wikitext("Total rituals time"):done()
			:tag("td"):wikitext(formatDuration(round(total_ritual_time_seconds))):done()
		:done()

		:tag("tr")
			:tag("th"):wikitext("Estimated input cost"):done()
			:tag("td"):wikitext(coins(target_input_cost)):done()
			:tag("th"):wikitext("Estimated output value"):done()
			:tag("td"):wikitext(coins(target_output_value)):done()
		:done()

		:tag("tr")
			:tag("th")
				:attr("colspan", "3")
				:wikitext("Estimated net profit")
			:done()
			:tag("td")
				:wikitext(coins(target_net_profit))
			:done()
		:done()

		:done()

		table.insert(result, tostring(targetholder:done()))
		table.insert(
			result,
			"<small>Target estimates use the same Total XP, ritual duration, average input cost, and average output value calculated by the original ritual setup below.</small>"
		)
	end

	table.insert(result, "\n== Rituals ==\n")
	if n_glyphs > slots then
		table.insert(result, "Number of glyphs needed ("..tostring(n_glyphs)..") exceeds the number of slots you have at your level ("..tostring(slots)..")<br>")
	end
	table.insert(result, tostring(tableholder:done()))

	result = table.concat(result)
	
	return result
end

return p