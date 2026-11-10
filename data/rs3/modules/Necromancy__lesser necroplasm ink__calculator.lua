-- Module:Necromancy/lesser_necroplasm_ink/calculator

local p = {}

local getArgs = require("Module:Arguments").getArgs
local data = mw.loadData("Module:Necromancy/rituals/data")
local ge_price = require("Module:Exchange")._price
local _coins = require("Module:Currency")._coins
local commas = require("Module:Addcommas")._add
local experience = require("Module:Experience")
local nextUp = require("Module:Math/ulp").nextUp

local xp_to_lvl = experience._level_at_xp
local lvl_to_xp = experience._xp_at_level

local RITUAL_NAME = "Lesser necroplasm"
local SITE = "Um"

local WEAK_NECROPLASM_PRICE = 3
local BASIC_GHOSTLY_INK_PRICE = 3
local REGULAR_INK_XP = 21
local REGULAR_INK_SECONDS = 1.2
local INKS_PER_INVENTORY = 13
local BANK_SECONDS_PER_INVENTORY = 2.4
local INK_INVENTORY_SECONDS = INKS_PER_INVENTORY * REGULAR_INK_SECONDS + BANK_SECONDS_PER_INVENTORY
local INKS_PER_HOUR = INKS_PER_INVENTORY * 3600 / INK_INVENTORY_SECONDS
local LESSER_NECROPLASM_BUY_LIMIT = 50000
local LESSER_NECROPLASM_BUY_LIMIT_HOURS = 4
local GE_TAX_RATE = 0.02

local XP_ICON = "[[File:Necromancy-icon.png|link=Necromancy|20px]]"
local COIN_ICON = "[[File:Coins 1000.png|link=Coins|20px]]"

local function clamp(value, minimum, maximum)
	return math.min(maximum, math.max(minimum, value))
end

local function boolArg(value)
	if value == true then return true end
	if value == nil or value == false or value == "" or value == "false" or value == "0" then return false end
	local number = tonumber(value)
	if number ~= nil then return number ~= 0 end
	return value == "true"
end

local function round(value)
	if value % 1 ~= 0 then
		return math.floor(value + 0.5)
	end
	return value
end

local function round2(value)
	return math.floor(value * 100 + 0.5) / 100
end

local function coin_text(value)
	return _coins(round(value))
end

local function format_number(value)
	return commas(round(value))
end

local function format_decimal(value)
	return commas(round2(value))
end

local function format_duration(seconds)
	seconds = math.max(0, round(seconds))
	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600
	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60

	local parts = {}
	if hours > 0 then
		table.insert(parts, tostring(hours) .. "h")
	end
	if minutes > 0 or hours > 0 then
		table.insert(parts, tostring(minutes) .. "m")
	end
	table.insert(parts, tostring(seconds) .. "s")
	return table.concat(parts, "&nbsp;")
end

local function format_seconds1(seconds)
	local rounded = math.floor(seconds * 10 + 0.5) / 10
	if rounded % 1 == 0 then
		return tostring(math.floor(rounded)) .. "s"
	end
	return tostring(rounded) .. "s"
end

local function ink_crafting_time(ink_count)
	if ink_count <= 0 then
		return 0
	end
	local inventories = math.ceil(ink_count / INKS_PER_INVENTORY)
	return ink_count * REGULAR_INK_SECONDS + inventories * BANK_SECONDS_PER_INVENTORY
end

local function item_icon(item)
	return "[[File:" .. item .. ".png|link=" .. item .. "|30px]]"
end

local function item_name(item)
	return "[[" .. item .. "]]"
end

local function price_or_zero(item)
	return ge_price(item) or 0
end

local function input_price(item)
	if item == "Basic ghostly ink" then
		return BASIC_GHOSTLY_INK_PRICE
	end
	return price_or_zero(item)
end

local function ge_tax_each(price)
	return math.floor((price or 0) * GE_TAX_RATE)
end

local function gross_value(amount, price)
	return amount * price
end

local function tax_value(amount, price)
	return amount * ge_tax_each(price)
end

local function net_sale_value(amount, price)
	return gross_value(amount, price) - tax_value(amount, price)
end

local function glyph_durability(glyph)
	local glyph_data = data.glyphs[glyph]
	return data.glyphduration[glyph_data.type][glyph_data.tier]
end

local function add_amount(target, item, amount)
	target[item] = (target[item] or 0) + amount
end

local function add_recipe(target, recipe, multiplier)
	for item, amount in pairs(recipe or {}) do
		add_amount(target, item, amount * multiplier)
	end
end

local function add_effects(target, effects, multiplier)
	for effect, amount in pairs(effects or {}) do
		target[effect] = math.floor(nextUp((target[effect] or 0) + amount * multiplier))
	end
end

local function ingredient_row(item, amount, unit_price, cost_used, note)
	local row = mw.html.create("tr")
	row
		:tag("td"):css({["border-right"]="none",["text-align"]="center",["width"]="1%"}):wikitext(item_icon(item)):done()
		:tag("td"):css({["border-left"]="none",["padding-left"]="0"}):wikitext(item_name(item)):done()
		:tag("td"):addClass("ref-left"):wikitext(format_decimal(amount)):done()
		:tag("td"):addClass("ref-left"):wikitext(COIN_ICON .. " " .. coin_text(unit_price)):done()
		:tag("td"):addClass("ref-left"):wikitext(COIN_ICON .. " " .. coin_text(cost_used)):done()
		:tag("td"):wikitext(note or ""):done()
	return row
end

local function output_row(item, amount, unit_price)
	local gross = gross_value(amount, unit_price)
	local tax = tax_value(amount, unit_price)
	local net = gross - tax

	local row = mw.html.create("tr")
	row
		:tag("td"):css({["border-right"]="none",["text-align"]="center",["width"]="1%"}):wikitext(item_icon(item)):done()
		:tag("td"):css({["border-left"]="none",["padding-left"]="0"}):wikitext(item_name(item)):done()
		:tag("td"):addClass("ref-left"):wikitext(format_decimal(amount)):done()
		:tag("td"):addClass("ref-left"):wikitext(COIN_ICON .. " " .. coin_text(unit_price)):done()
		:tag("td"):addClass("ref-left"):wikitext(COIN_ICON .. " " .. coin_text(gross)):done()
		:tag("td"):addClass("ref-left"):wikitext(COIN_ICON .. " -" .. coin_text(tax)):done()
		:tag("td"):addClass("ref-left"):wikitext(COIN_ICON .. " " .. coin_text(net)):done()
	return row
end

local function summary_row(table_node, left_label, left_value, right_label, right_value)
	table_node
		:tag("tr")
			:tag("th"):wikitext(left_label):done()
			:tag("td"):wikitext(left_value):done()
			:tag("th"):wikitext(right_label):done()
			:tag("td"):wikitext(right_value):done()
		:done()
end

function p.main(frame)
	return p._main(getArgs(frame))
end

function p._main(args)
	local ritual = data.rituals[RITUAL_NAME]
	if ritual == nil then
		return '<div class="error">Lesser necroplasm ritual data could not be loaded.</div>'
	end

	local current_xp_arg = tonumber(args.necromancy_xp)
	local current_level
	local current_xp

	if args.cur_toggle == "Experience" and current_xp_arg ~= nil then
		current_xp = clamp(current_xp_arg, 0, 200000000)
		current_level = clamp(tonumber(xp_to_lvl(current_xp)) or 1, 1, 120)
	else
		current_level = clamp(math.floor(tonumber(args.necromancy_lvl) or 20), 1, 120)
		current_xp = lvl_to_xp(current_level)
	end

	if current_level < 20 then
		return '<div class="error">This method requires level 20 Necromancy to craft regular ghostly ink.</div>'
	end

	local target_level = clamp(math.floor(tonumber(args.target_lvl) or current_level), 20, 120)
	local target_xp = lvl_to_xp(target_level)

	if target_xp < current_xp then
		return '<div class="error">Target level must be above your current level/experience.</div>'
	end

	local buy_lesser_ge = boolArg(args.buy_lesser_ge)
	local buy_ashes_ge = boolArg(args.buy_ashes_ge)
	local buy_vial_ge = boolArg(args.buy_vial_ge)
	local alteration_necklace = boolArg(args.alteration_necklace)

	local recipe = ritual.recipes[1]
	local ritual_input = recipe[1]
	local ritual_output = recipe[2]

	local weak_per_ritual = ritual_input["Weak necroplasm"] or 0
	local base_lesser_per_ritual = ritual_output["Lesser necroplasm"] or 0
	local base_ectoplasm_per_ritual = ritual_output["Ectoplasm"] or 0

	local foundational_glyph_count = 0
	for _, amount in pairs(ritual.glyphs) do
		foundational_glyph_count = foundational_glyph_count + amount
	end

	local available_slots = 0
	for _, info in ipairs(data.glyphspots) do
		if current_level >= info[1] then
			available_slots = info[2]
		end
	end

	local alteration_counts = {}
	local alteration_list = {}
	local alteration_effects = { attraction = 100 }
	local alteration_effect_multiplier = alteration_necklace and nextUp(1.2) or 1

	if not buy_lesser_ge then
		for slot = foundational_glyph_count + 1, 11 do
			local selected = args["a" .. tostring(slot)]
			if selected ~= nil and selected ~= "" and selected ~= "None" then
				if slot > available_slots then
					return '<div class="error">Alteration glyph slot ' .. tostring(slot) ..
						' is not available at level ' .. tostring(current_level) .. ' Necromancy.</div>'
				end

				local glyph = data.glyphs[selected]
				if glyph == nil then
					return '<div class="error">Unknown alteration glyph: ' .. tostring(selected) .. '.</div>'
				end

				if glyph.lvl > current_level then
					return '<div class="error">' .. tostring(selected) .. ' requires level ' ..
						tostring(glyph.lvl) .. ' Necromancy.</div>'
				end

				alteration_counts[selected] = (alteration_counts[selected] or 0) + 1
				table.insert(alteration_list, selected)
				add_effects(alteration_effects, glyph.alteration, alteration_effect_multiplier)
			end
		end

		local cape_alteration = args.a12
		if cape_alteration ~= nil and cape_alteration ~= "" and cape_alteration ~= "None" then
			if current_level < 99 then
				return '<div class="error">The Necromancy cape perk alteration requires level 99 Necromancy.</div>'
			end

			local glyph = data.glyphs[cape_alteration]
			if glyph == nil then
				return '<div class="error">Unknown cape perk alteration: ' .. tostring(cape_alteration) .. '.</div>'
			end

			if glyph.lvl > current_level then
				return '<div class="error">' .. tostring(cape_alteration) .. ' requires level ' ..
					tostring(glyph.lvl) .. ' Necromancy.</div>'
			end

			table.insert(alteration_list, cape_alteration .. " (cape)")
			add_effects(alteration_effects, glyph.alteration, alteration_effect_multiplier)
		end
	end

	local average_glyph_materials = {}

	if not buy_lesser_ge then
		for glyph, amount in pairs(ritual.glyphs) do
			local durability = glyph_durability(glyph)
			add_recipe(average_glyph_materials, data.glyphs[glyph].recipe, amount / durability)
		end

		for glyph, amount in pairs(alteration_counts) do
			local durability = glyph_durability(glyph)
			add_recipe(average_glyph_materials, data.glyphs[glyph].recipe, amount / durability)
		end
	end

	local average_glyph_cost = 0
	for item, amount in pairs(average_glyph_materials) do
		average_glyph_cost = average_glyph_cost + amount * input_price(item)
	end

	local output_bonus = buy_lesser_ge and 0 or (alteration_effects.output or 0)
	local speed_bonus = buy_lesser_ge and 0 or (alteration_effects.speed or 0)
	local attraction = buy_lesser_ge and 100 or (alteration_effects.attraction or 100)
	local disturbance_duration = buy_lesser_ge and 0 or (alteration_effects["disturbance duration"] or 0)

	local lesser_per_ritual = math.floor(nextUp(base_lesser_per_ritual * (100 + output_bonus) / 100))
	local ectoplasm_per_ritual = math.floor(nextUp(base_ectoplasm_per_ritual * (100 + output_bonus) / 100))

	local lesser_required_per_cycle
	local inks_per_cycle
	local lesser_left_per_cycle

	if buy_lesser_ge then
		lesser_required_per_cycle = base_lesser_per_ritual
		inks_per_cycle = math.floor(lesser_required_per_cycle / 20)
		lesser_left_per_cycle = 0
	else
		inks_per_cycle = math.floor(lesser_per_ritual / 20)
		lesser_required_per_cycle = inks_per_cycle * 20
		lesser_left_per_cycle = lesser_per_ritual - lesser_required_per_cycle
	end

	local ashes_per_cycle = inks_per_cycle
	local vials_per_cycle = inks_per_cycle

	local site_multiplier = data.sitemultiplier[SITE] or 1
	local base_ritual_xp = math.floor(ritual.xp * site_multiplier)
	local ritual_xp = buy_lesser_ge and 0 or base_ritual_xp
	local ink_xp = inks_per_cycle * REGULAR_INK_XP
	local xp_per_cycle = ritual_xp + ink_xp

	local base_ritual_ticks = ritual.ticks
	local modified_ritual_ticks = math.ceil(base_ritual_ticks * (100 + math.max(speed_bonus, -50)) / 100)
	local ritual_seconds = buy_lesser_ge and 0 or (modified_ritual_ticks * 2 * 0.6)

	local average_seconds_per_ink = 3600 / INKS_PER_HOUR
	local ink_seconds = inks_per_cycle * average_seconds_per_ink
	local cycle_seconds = ritual_seconds + ink_seconds
	local xp_per_hour = xp_per_cycle * 3600 / cycle_seconds

	local price_ashes = price_or_zero("Ashes")
	local price_vial = price_or_zero("Vial of water")
	local price_regular_ink = price_or_zero("Regular ghostly ink")
	local price_ectoplasm = price_or_zero("Ectoplasm")
	local price_lesser = price_or_zero("Lesser necroplasm")

	local ritual_focus_cost = buy_lesser_ge and 0 or (weak_per_ritual * WEAK_NECROPLASM_PRICE)

	local crafting_ingredient_cost =
		(buy_lesser_ge and (lesser_required_per_cycle * price_lesser) or 0) +
		(buy_ashes_ge and (ashes_per_cycle * price_ashes) or 0) +
		(buy_vial_ge and (vials_per_cycle * price_vial) or 0)

	local ritual_cost_per_cycle =
		ritual_focus_cost +
		average_glyph_cost

	local crafting_cost_per_cycle = crafting_ingredient_cost
	local cost_per_cycle = ritual_cost_per_cycle + crafting_cost_per_cycle

	local ectoplasm_output_per_cycle = buy_lesser_ge and 0 or ectoplasm_per_ritual
	local lesser_output_for_sale_per_cycle = buy_lesser_ge and 0 or lesser_left_per_cycle

	-- Ritual economics only count outputs that are actually sold.
	-- Lesser necroplasm used to make ink is transferred to the crafting stage
	-- and is not counted as ritual revenue, which prevents double-counting.
	local ritual_gross_revenue_per_cycle =
		gross_value(ectoplasm_output_per_cycle, price_ectoplasm) +
		gross_value(lesser_output_for_sale_per_cycle, price_lesser)

	local ritual_tax_per_cycle =
		tax_value(ectoplasm_output_per_cycle, price_ectoplasm) +
		tax_value(lesser_output_for_sale_per_cycle, price_lesser)

	local ritual_net_revenue_per_cycle =
		ritual_gross_revenue_per_cycle - ritual_tax_per_cycle

	local ritual_profit_per_cycle =
		ritual_net_revenue_per_cycle - ritual_cost_per_cycle

	local crafting_gross_revenue_per_cycle =
		gross_value(inks_per_cycle, price_regular_ink)

	local crafting_tax_per_cycle =
		tax_value(inks_per_cycle, price_regular_ink)

	local crafting_net_revenue_per_cycle =
		crafting_gross_revenue_per_cycle - crafting_tax_per_cycle

	local crafting_profit_per_cycle =
		crafting_net_revenue_per_cycle - crafting_cost_per_cycle

	local gross_revenue_per_cycle =
		ritual_gross_revenue_per_cycle + crafting_gross_revenue_per_cycle

	local tax_per_cycle =
		ritual_tax_per_cycle + crafting_tax_per_cycle

	local net_revenue_per_cycle =
		ritual_net_revenue_per_cycle + crafting_net_revenue_per_cycle

	local profit_per_cycle =
		ritual_profit_per_cycle + crafting_profit_per_cycle

	local gp_per_hour = profit_per_cycle * 3600 / cycle_seconds

	local xp_remaining = math.max(0, target_xp - current_xp)
	local cycles_needed = 0
	if xp_remaining > 0 then
		cycles_needed = math.ceil(xp_remaining / xp_per_cycle)
	end

	local rituals_needed = buy_lesser_ge and 0 or cycles_needed
	local total_ink = inks_per_cycle * cycles_needed
	local total_ashes = ashes_per_cycle * cycles_needed
	local total_vials = vials_per_cycle * cycles_needed
	local total_weak = buy_lesser_ge and 0 or (weak_per_ritual * cycles_needed)
	local total_ectoplasm = ectoplasm_output_per_cycle * cycles_needed
	local total_lesser_required = lesser_required_per_cycle * cycles_needed
	local total_lesser_for_sale = lesser_output_for_sale_per_cycle * cycles_needed

	local exact_glyph_materials = {}
	if rituals_needed > 0 then
		for glyph, amount in pairs(ritual.glyphs) do
			local durability = glyph_durability(glyph)
			local redraws = math.ceil(rituals_needed / durability)
			add_recipe(exact_glyph_materials, data.glyphs[glyph].recipe, amount * redraws)
		end

		for glyph, amount in pairs(alteration_counts) do
			local durability = glyph_durability(glyph)
			local redraws = math.ceil(rituals_needed / durability)
			add_recipe(exact_glyph_materials, data.glyphs[glyph].recipe, amount * redraws)
		end
	end

	local exact_glyph_cost = 0
	for item, amount in pairs(exact_glyph_materials) do
		exact_glyph_cost = exact_glyph_cost + amount * input_price(item)
	end

	local total_ritual_cost =
		total_weak * WEAK_NECROPLASM_PRICE +
		exact_glyph_cost

	local total_crafting_cost =
		(buy_lesser_ge and (total_lesser_required * price_lesser) or 0) +
		(buy_ashes_ge and (total_ashes * price_ashes) or 0) +
		(buy_vial_ge and (total_vials * price_vial) or 0)

	local total_cost =
		total_ritual_cost + total_crafting_cost

	local total_ritual_gross_revenue =
		gross_value(total_ectoplasm, price_ectoplasm) +
		gross_value(total_lesser_for_sale, price_lesser)

	local total_ritual_tax =
		tax_value(total_ectoplasm, price_ectoplasm) +
		tax_value(total_lesser_for_sale, price_lesser)

	local total_ritual_net_revenue =
		total_ritual_gross_revenue - total_ritual_tax

	local total_ritual_profit =
		total_ritual_net_revenue - total_ritual_cost

	local total_crafting_gross_revenue =
		gross_value(total_ink, price_regular_ink)

	local total_crafting_tax =
		tax_value(total_ink, price_regular_ink)

	local total_crafting_net_revenue =
		total_crafting_gross_revenue - total_crafting_tax

	local total_crafting_profit =
		total_crafting_net_revenue - total_crafting_cost

	local total_gross_revenue =
		total_ritual_gross_revenue + total_crafting_gross_revenue

	local total_tax =
		total_ritual_tax + total_crafting_tax

	local total_net_revenue =
		total_ritual_net_revenue + total_crafting_net_revenue

	local total_profit =
		total_ritual_profit + total_crafting_profit

	local total_ritual_seconds = rituals_needed * ritual_seconds
	local total_ink_seconds = ink_crafting_time(total_ink)
	local total_seconds = total_ritual_seconds + total_ink_seconds
	local total_xp_gained = cycles_needed * xp_per_cycle

	local result = {}

	local summary_holder = mw.html.create("div")
		:addClass("recipe-table")
		:cssText("width:-moz-fit-content;width:fit-content;max-width:760px;")

	local summary = summary_holder
		:tag("table")
			:addClass("wikitable infobox-recipe")
			:css({ width = "100%" })

	summary
		:tag("tr")
			:tag("th")
				:attr("colspan", "4")
				:wikitext("Lesser necroplasm → Regular ghostly ink")
			:done()
		:done()

	summary_row(summary, XP_ICON .. " XP per hour", format_number(xp_per_hour), COIN_ICON .. " Profit per hour", coin_text(gp_per_hour))
	summary_row(summary, "Ritual XP", buy_lesser_ge and "Skipped" or (XP_ICON .. " " .. format_number(ritual_xp)), "Ink crafting XP", XP_ICON .. " " .. format_number(ink_xp))
	summary_row(summary, "Total XP per cycle", XP_ICON .. " " .. format_number(xp_per_cycle), "Net profit per cycle", COIN_ICON .. " " .. coin_text(profit_per_cycle))
	summary_row(summary, "Ritual time", buy_lesser_ge and "Skipped" or format_seconds1(ritual_seconds), "Ink crafting rate", format_number(INKS_PER_HOUR) .. " inks/h")

	local alteration_text = "None"
	if buy_lesser_ge then
		alteration_text = "Skipped (GE lesser necroplasm)"
	elseif #alteration_list > 0 then
		alteration_text = table.concat(alteration_list, ", ")
	end

	summary_row(summary, "Ritual alterations", alteration_text, "Alteration necklace", (not buy_lesser_ge and alteration_necklace) and "Yes" or "No")
	summary_row(summary, "Multiply output bonus", buy_lesser_ge and "Skipped" or ("+" .. tostring(output_bonus) .. "%"), "Speed modifier", buy_lesser_ge and "Skipped" or (tostring(speed_bonus) .. "%"))

	if not buy_lesser_ge then
		summary_row(summary, "Lesser necroplasm / ritual", item_icon("Lesser necroplasm") .. " " .. format_number(lesser_per_ritual), "Ectoplasm / ritual", item_icon("Ectoplasm") .. " " .. format_number(ectoplasm_per_ritual))
		summary_row(summary, "Soul attraction", tostring(attraction) .. "%", "Disturbance duration bonus", "+" .. tostring(disturbance_duration) .. "%")
	end

	summary_row(summary, "Full ink inventory", format_seconds1(INKS_PER_INVENTORY * REGULAR_INK_SECONDS) .. " crafting", "Banking per inventory", format_seconds1(BANK_SECONDS_PER_INVENTORY))
	summary_row(summary, "13-ink inventory total", format_seconds1(INK_INVENTORY_SECONDS), "Inks per inventory", tostring(INKS_PER_INVENTORY))

	local ge_ingredients = {}
	if buy_lesser_ge then table.insert(ge_ingredients, "Lesser necroplasm") end
	if buy_ashes_ge then table.insert(ge_ingredients, "Ashes") end
	if buy_vial_ge then table.insert(ge_ingredients, "Vial of water") end
	local ge_ingredient_text = #ge_ingredients > 0 and table.concat(ge_ingredients, ", ") or "None"

	summary_row(summary, "Average cycle time", format_seconds1(cycle_seconds), "GE ingredients", ge_ingredient_text)

	summary:done()
	table.insert(result, tostring(summary_holder:done()))

	table.insert(result, "\n== Ritual costs and profit ==\n")

	local ritual_holder = mw.html.create("div")
		:addClass("recipe-table")
		:cssText("width:-moz-fit-content;width:fit-content;max-width:900px;")

	local ritual_table = ritual_holder
		:tag("table")
			:addClass("wikitable")
			:css({ width = "100%" })

	if buy_lesser_ge then
		ritual_table
			:tag("tr")
				:tag("th"):wikitext("Lesser necroplasm ritual"):done()
				:tag("td"):wikitext("Skipped — Lesser necroplasm is bought from the Grand Exchange."):done()
			:done()
			:tag("tr")
				:tag("th"):wikitext("Ritual cost"):done()
				:tag("td"):wikitext(COIN_ICON .. " 0"):done()
			:done()
			:tag("tr")
				:tag("th"):wikitext("Ritual profit contribution"):done()
				:tag("td"):wikitext(COIN_ICON .. " 0"):done()
			:done()
	else
		ritual_table
			:tag("tr")
				:tag("th"):attr("colspan", "6"):wikitext("Ritual inputs per cycle"):done()
			:done()
			:tag("tr")
				:tag("th"):attr("colspan", "2"):wikitext("Item"):done()
				:tag("th"):wikitext("Amount"):done()
				:tag("th"):wikitext("Price each"):done()
				:tag("th"):wikitext("Cost used"):done()
				:tag("th"):wikitext("Source"):done()
			:done()

		ritual_table:node(ingredient_row(
			"Weak necroplasm",
			weak_per_ritual,
			WEAK_NECROPLASM_PRICE,
			weak_per_ritual * WEAK_NECROPLASM_PRICE,
			"Lupe's shop"
		))

		for item, amount in pairs(average_glyph_materials) do
			ritual_table:node(ingredient_row(
				item,
				amount,
				input_price(item),
				amount * input_price(item),
				"Average glyph cost"
			))
		end

		ritual_table
			:tag("tr")
				:tag("th"):attr("colspan", "4"):wikitext("Total ritual cost"):done()
				:tag("th"):wikitext(COIN_ICON .. " " .. coin_text(ritual_cost_per_cycle)):done()
				:tag("td"):wikitext(""):done()
			:done()
			:tag("tr")
				:tag("th"):attr("colspan", "6"):wikitext("Ritual outputs per cycle"):done()
			:done()
			:tag("tr")
				:tag("th"):attr("colspan", "2"):wikitext("Output"):done()
				:tag("th"):wikitext("Amount"):done()
				:tag("th"):wikitext("GE price each"):done()
				:tag("th"):wikitext("Accounting"):done()
				:tag("th"):wikitext("Value used"):done()
			:done()

		ritual_table
			:tag("tr")
				:tag("td")
					:css({["border-right"]="none",["text-align"]="center",["width"]="1%"})
					:wikitext(item_icon("Lesser necroplasm"))
				:done()
				:tag("td")
					:css({["border-left"]="none",["padding-left"]="0"})
					:wikitext(item_name("Lesser necroplasm"))
				:done()
				:tag("td"):wikitext(format_decimal(lesser_required_per_cycle)):done()
				:tag("td"):wikitext(COIN_ICON .. " " .. coin_text(price_lesser)):done()
				:tag("td"):wikitext("Transferred to ink crafting"):done()
				:tag("td"):wikitext("Not counted as sale revenue"):done()
			:done()

		if ectoplasm_output_per_cycle > 0 then
			local ectoplasm_net = net_sale_value(ectoplasm_output_per_cycle, price_ectoplasm)
			ritual_table
				:tag("tr")
					:tag("td")
						:css({["border-right"]="none",["text-align"]="center",["width"]="1%"})
						:wikitext(item_icon("Ectoplasm"))
					:done()
					:tag("td")
						:css({["border-left"]="none",["padding-left"]="0"})
						:wikitext(item_name("Ectoplasm"))
					:done()
					:tag("td"):wikitext(format_decimal(ectoplasm_output_per_cycle)):done()
					:tag("td"):wikitext(COIN_ICON .. " " .. coin_text(price_ectoplasm)):done()
					:tag("td"):wikitext("Sold on GE after tax"):done()
					:tag("td"):wikitext(COIN_ICON .. " " .. coin_text(ectoplasm_net)):done()
				:done()
		end

		if lesser_output_for_sale_per_cycle > 0 then
			local lesser_net = net_sale_value(lesser_output_for_sale_per_cycle, price_lesser)
			ritual_table
				:tag("tr")
					:tag("td")
						:css({["border-right"]="none",["text-align"]="center",["width"]="1%"})
						:wikitext(item_icon("Lesser necroplasm"))
					:done()
					:tag("td")
						:css({["border-left"]="none",["padding-left"]="0"})
						:wikitext(item_name("Lesser necroplasm") .. " (leftover)")
					:done()
					:tag("td"):wikitext(format_decimal(lesser_output_for_sale_per_cycle)):done()
					:tag("td"):wikitext(COIN_ICON .. " " .. coin_text(price_lesser)):done()
					:tag("td"):wikitext("Sold on GE after tax"):done()
					:tag("td"):wikitext(COIN_ICON .. " " .. coin_text(lesser_net)):done()
				:done()
		end

		ritual_table
			:tag("tr")
				:tag("th"):attr("colspan", "5"):wikitext("Ritual gross sale value"):done()
				:tag("th"):wikitext(COIN_ICON .. " " .. coin_text(ritual_gross_revenue_per_cycle)):done()
			:done()
			:tag("tr")
				:tag("th"):attr("colspan", "5"):wikitext("Ritual GE tax"):done()
				:tag("th"):wikitext(COIN_ICON .. " -" .. coin_text(ritual_tax_per_cycle)):done()
			:done()
			:tag("tr")
				:tag("th"):attr("colspan", "5"):wikitext("Ritual net sale value"):done()
				:tag("th"):wikitext(COIN_ICON .. " " .. coin_text(ritual_net_revenue_per_cycle)):done()
			:done()
			:tag("tr")
				:tag("th"):attr("colspan", "5"):wikitext("Ritual profit contribution"):done()
				:tag("th"):wikitext(COIN_ICON .. " " .. coin_text(ritual_profit_per_cycle)):done()
			:done()
	end

	ritual_table:done()
	table.insert(result, tostring(ritual_holder:done()))

	table.insert(result, "\n== Ink crafting costs and profit ==\n")

	local crafting_holder = mw.html.create("div")
		:addClass("recipe-table")
		:cssText("width:-moz-fit-content;width:fit-content;max-width:900px;")

	local crafting_table = crafting_holder
		:tag("table")
			:addClass("wikitable")
			:css({ width = "100%" })

	crafting_table
		:tag("tr")
			:tag("th"):attr("colspan", "6"):wikitext("Ink crafting inputs per cycle"):done()
		:done()
		:tag("tr")
			:tag("th"):attr("colspan", "2"):wikitext("Item"):done()
			:tag("th"):wikitext("Amount"):done()
			:tag("th"):wikitext("Price each"):done()
			:tag("th"):wikitext("Cost used"):done()
			:tag("th"):wikitext("Source"):done()
		:done()

	crafting_table:node(ingredient_row(
		"Lesser necroplasm",
		lesser_required_per_cycle,
		price_lesser,
		buy_lesser_ge and (lesser_required_per_cycle * price_lesser) or 0,
		buy_lesser_ge and "Grand Exchange" or "Ritual output"
	))

	crafting_table:node(ingredient_row(
		"Ashes",
		ashes_per_cycle,
		price_ashes,
		buy_ashes_ge and (ashes_per_cycle * price_ashes) or 0,
		buy_ashes_ge and "Grand Exchange" or "Self-supplied"
	))

	crafting_table:node(ingredient_row(
		"Vial of water",
		vials_per_cycle,
		price_vial,
		buy_vial_ge and (vials_per_cycle * price_vial) or 0,
		buy_vial_ge and "Grand Exchange" or "Self-supplied"
	))

	crafting_table
		:tag("tr")
			:tag("th"):attr("colspan", "4"):wikitext("Total crafting cost"):done()
			:tag("th"):wikitext(COIN_ICON .. " " .. coin_text(crafting_cost_per_cycle)):done()
			:tag("td"):wikitext(""):done()
		:done()
		:tag("tr")
			:tag("th"):attr("colspan", "7"):wikitext("Ink crafting output per cycle"):done()
		:done()
		:tag("tr")
			:tag("th"):attr("colspan", "2"):wikitext("Item"):done()
			:tag("th"):wikitext("Amount"):done()
			:tag("th"):wikitext("GE price each"):done()
			:tag("th"):wikitext("Gross value"):done()
			:tag("th"):wikitext("GE tax"):done()
			:tag("th"):wikitext("Net value"):done()
		:done()

	crafting_table:node(output_row(
		"Regular ghostly ink",
		inks_per_cycle,
		price_regular_ink
	))

	crafting_table
		:tag("tr")
			:tag("th"):attr("colspan", "6"):wikitext("Crafting gross output value"):done()
			:tag("th"):wikitext(COIN_ICON .. " " .. coin_text(crafting_gross_revenue_per_cycle)):done()
		:done()
		:tag("tr")
			:tag("th"):attr("colspan", "6"):wikitext("Crafting GE tax"):done()
			:tag("th"):wikitext(COIN_ICON .. " -" .. coin_text(crafting_tax_per_cycle)):done()
		:done()
		:tag("tr")
			:tag("th"):attr("colspan", "6"):wikitext("Crafting net output value"):done()
			:tag("th"):wikitext(COIN_ICON .. " " .. coin_text(crafting_net_revenue_per_cycle)):done()
		:done()
		:tag("tr")
			:tag("th"):attr("colspan", "6"):wikitext("Crafting profit contribution"):done()
			:tag("th"):wikitext(COIN_ICON .. " " .. coin_text(crafting_profit_per_cycle)):done()
		:done()

	crafting_table:done()
	table.insert(result, tostring(crafting_holder:done()))

	table.insert(result, "\n== Combined profit ==\n")

	local combined_holder = mw.html.create("div")
		:addClass("recipe-table")
		:cssText("width:-moz-fit-content;width:fit-content;max-width:760px;")

	local combined_table = combined_holder
		:tag("table")
			:addClass("wikitable infobox-recipe")
			:css({ width = "100%" })

	summary_row(combined_table, "Ritual cost", COIN_ICON .. " " .. coin_text(ritual_cost_per_cycle), "Crafting cost", COIN_ICON .. " " .. coin_text(crafting_cost_per_cycle))
	summary_row(combined_table, "Ritual profit contribution", COIN_ICON .. " " .. coin_text(ritual_profit_per_cycle), "Crafting profit contribution", COIN_ICON .. " " .. coin_text(crafting_profit_per_cycle))
	summary_row(combined_table, "Combined cost per cycle", COIN_ICON .. " " .. coin_text(cost_per_cycle), "Combined net profit per cycle", COIN_ICON .. " " .. coin_text(profit_per_cycle))
	summary_row(combined_table, "Combined GE tax per cycle", COIN_ICON .. " -" .. coin_text(tax_per_cycle), "Combined net profit per hour", COIN_ICON .. " " .. coin_text(gp_per_hour))

	combined_table:done()
	table.insert(result, tostring(combined_holder:done()))

	table.insert(result, "\n== Target level ==\n")

	local target_holder = mw.html.create("div")
		:addClass("recipe-table")
		:cssText("width:-moz-fit-content;width:fit-content;max-width:760px;")

	local target = target_holder:tag("table"):addClass("wikitable infobox-recipe"):css({ width = "100%" })

	target
		:tag("tr")
			:tag("th"):attr("colspan", "4"):wikitext("Training to level " .. tostring(target_level)):done()
		:done()

	summary_row(target, "Current XP", XP_ICON .. " " .. format_number(current_xp), "Target XP", XP_ICON .. " " .. format_number(target_xp))

	if buy_lesser_ge then
		summary_row(target, "XP remaining", XP_ICON .. " " .. format_number(xp_remaining), "Ink batches required", format_number(cycles_needed))
	else
		summary_row(target, "XP remaining", XP_ICON .. " " .. format_number(xp_remaining), "Rituals required", format_number(rituals_needed))
	end

	summary_row(target, "Regular ghostly ink crafted", item_icon("Regular ghostly ink") .. " " .. format_number(total_ink), "Total XP gained", XP_ICON .. " " .. format_number(total_xp_gained))
	summary_row(target, buy_lesser_ge and "Total crafting time" or "Total ritual + crafting time", format_duration(total_seconds), "Average XP/h", XP_ICON .. " " .. format_number(xp_per_hour))
	summary_row(target, "Total ritual cost", COIN_ICON .. " " .. coin_text(total_ritual_cost), "Total crafting cost", COIN_ICON .. " " .. coin_text(total_crafting_cost))
	summary_row(target, "Ritual profit contribution", COIN_ICON .. " " .. coin_text(total_ritual_profit), "Crafting profit contribution", COIN_ICON .. " " .. coin_text(total_crafting_profit))
	summary_row(target, "Total input cost", COIN_ICON .. " " .. coin_text(total_cost), "Gross output value", COIN_ICON .. " " .. coin_text(total_gross_revenue))
	summary_row(target, "Total GE tax", COIN_ICON .. " -" .. coin_text(total_tax), "Net output value", COIN_ICON .. " " .. coin_text(total_net_revenue))
	summary_row(target, "Total net profit", COIN_ICON .. " " .. coin_text(total_profit), "Average net profit/h", COIN_ICON .. " " .. coin_text(gp_per_hour))

	if buy_lesser_ge then
		local limit_inks = math.floor(LESSER_NECROPLASM_BUY_LIMIT / 20)
		summary_row(
			target,
			"Lesser necroplasm GE limit",
			format_number(LESSER_NECROPLASM_BUY_LIMIT) .. " / " .. tostring(LESSER_NECROPLASM_BUY_LIMIT_HOURS) .. "h",
			"Inks supported per buy limit",
			format_number(limit_inks)
		)
	end

	target:done()
	table.insert(result, tostring(target_holder:done()))

	local mats_holder = mw.html.create("div")
		:addClass("recipe-table")
		:cssText("width:-moz-fit-content;width:fit-content;max-width:760px;")

	local mats = mats_holder:tag("table"):addClass("wikitable"):css({ width = "100%" })

	mats
		:tag("tr")
			:tag("th"):attr("colspan", "4"):wikitext("Total materials for target"):done()
		:done()
		:tag("tr")
			:tag("th"):attr("colspan", "2"):wikitext("Item"):done()
			:tag("th"):wikitext("Amount"):done()
			:tag("th"):wikitext("Cost used"):done()
		:done()

	local total_materials = {}

	if not buy_lesser_ge then
		add_amount(total_materials, "Weak necroplasm", total_weak)
		for item, amount in pairs(exact_glyph_materials) do
			add_amount(total_materials, item, amount)
		end
	end

	add_amount(total_materials, "Lesser necroplasm", total_lesser_required)
	add_amount(total_materials, "Ashes", total_ashes)
	add_amount(total_materials, "Vial of water", total_vials)

	for item, amount in pairs(total_materials) do
		local cost = 0
		if item == "Weak necroplasm" then
			cost = amount * WEAK_NECROPLASM_PRICE
		elseif item == "Lesser necroplasm" then
			cost = buy_lesser_ge and (amount * price_lesser) or 0
		elseif item == "Ashes" then
			cost = buy_ashes_ge and (amount * price_ashes) or 0
		elseif item == "Vial of water" then
			cost = buy_vial_ge and (amount * price_vial) or 0
		else
			cost = amount * input_price(item)
		end

		mats
			:tag("tr")
				:tag("td"):css({["border-right"]="none",["text-align"]="center",["width"]="1%"}):wikitext(item_icon(item)):done()
				:tag("td"):css({["border-left"]="none",["padding-left"]="0"}):wikitext(item_name(item)):done()
				:tag("td"):wikitext(format_decimal(amount)):done()
				:tag("td"):wikitext(COIN_ICON .. " " .. coin_text(cost)):done()
			:done()
	end

	mats:done()
	table.insert(result, tostring(mats_holder:done()))

	if not buy_lesser_ge and (attraction ~= 100 or disturbance_duration ~= 0) then
		table.insert(result,
			'\n<div class="notice"><b>Disturbance note:</b> Attraction and Protection glyph effects are shown and their glyph costs are included, but disturbance XP, disturbance rewards, and disturbance handling time are not included in this calculator.</div>'
		)
	end

	table.insert(result,
		"\n<small>Assumptions: if Lesser necroplasm is bought from the GE, the ritual is skipped completely. Otherwise the calculator uses the base City of Um Lesser necroplasm ritual and applies the selected alteration glyphs using the Wiki ritual data module. Multiply glyphs modify ritual output and Speed glyphs modify ritual duration, capped at -50% speed as in the ritual calculator. Ink crafting uses 13 inks per inventory: 15.6 seconds crafting plus 2.4 seconds banking, equal to 2,600 inks/hour. Output sale values deduct a 2% GE seller tax per item, rounded down. Unchecked ashes or vials are treated as self-supplied at 0 GP cost. Travel time is excluded.</small>"
	)

	return table.concat(result)
end

return p