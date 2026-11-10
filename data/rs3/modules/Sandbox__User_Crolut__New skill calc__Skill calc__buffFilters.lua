--[=[ buffFilters
-- Configuration, transformations, and ordered filtering rules used by
-- bonusGenerator.
--
-- Fields:
--      eliteSkills                 skills that use elite skill XP data
--      transforms                  named argument conversion functions
--      levelBoostRules             temporary visible level-boost rules
--      urnMultipliers              urn classification and multiplier settings
--      raisingAnimal               Raising Animals XP modifier settings
--      curingAnimalAgeMultipliers  Curing Animals multipliers by age
--      bigGameHunter               Big Game Hunter bonus XP settings
--      wildernessAgilityCourse     Wilderness course method settings
--      rules                       ordered argument preparation rules
--
-- Rule groups:
--      subcategory
--          Rules based on the selected skill sub-category. These are applied
--          using the calculator arguments, usually skill and disp.
--
--      method
--          Rules based on an individual method row. These are applied using
--          the method data, such as name, as well as the calculator arguments.
--
--      arguments
--          Rules based on selected calculator arguments. These are used when
--          one selected argument disables another selected argument.
--
-- Rule fields:
--      skill
--          Optional list of skill names the rule applies to. If omitted, the
--          rule applies to all skills.
--
--      disp
--          Optional list of sub-category names the rule applies to. If omitted,
--          the rule applies to all sub-categories.
--
--      name
--          Optional list of method names the rule applies to. This is mainly
--          used in method rules.
--
--      when
--          Optional table of required argument values. The rule only applies
--          when each listed argument matches the selected calculator argument.
--
--      disable
--          List of calculator argument parameters to remove before the 
--          arguments are sent to Calculator/Experience Buffs.
--]=]

--[=[ toPercentString
-- Converts a positive numeric percentage into the percentage-string format
-- expected by Calculator/Experience Buffs
-- Inputs:
--      value    value to convert into a percentage string
--      default  value returned when value is missing, invalid, or not positive
-- Returns:
--      percentage string, or default when no valid percentage exists
--]=]
local function toPercentString(value, default)
	local number = tonumber(value)

	if number ~= nil and number > 0 then
		return tostring(number) .. "%"
	end

	return default
end

--[=[ toExperienceBuffScale
-- Converts a positive calculator percentage to the ten-times scale expected
-- by Calculator/Experience Buffs for custom XP boost arguments
-- Inputs:
--      value    calculator percentage to convert
--      default  value returned when value is missing, invalid, or not positive
-- Returns:
--      converted Experience Buffs value, or default when no valid value exists
--]=]
local function toExperienceBuffScale(value, default)
	local number = tonumber(value) or 0

	if number > 0 then
		return number * 10
	end

	return default
end

return {
	eliteSkills = {
		Invention = true,
	},
	transforms = {
		toPercentString = toPercentString,
		toExperienceBuffScale = toExperienceBuffScale,
	},
	levelBoostRules = {
		{
			arg = "dungOutfits",
			values = {
				["Warped"] = 2,
			},
			excludeSkill = {
				"Dungeoneering",
				"Summoning",
			},
		},
	},
	raisingAnimal = {
		minimumAverageStat = 10,
		statDivisor        = 100,
		shinyBonus         = 0.10,
		traitBonuses = {
			Giver                  = 0.03,
			["Limited Efficiency"] = -0.03,
			Taker                  = -0.03,
		},
		thirdTraitBonuses = {
			Exalted          = 0.03,
			["Nice but Dim"] = 0.144,
		},
	},
	curingAnimalAgeMultipliers = {
		Baby       = 0.005,
		Adolescent = 0.0075,
		Adult      = 0.015,
		Elder      = 0.0045,
	},
	bigGameHunter = {
		skill   = "Hunter",
		disp    = "Big Game Hunting",
		arg     = "bghxp",
		bonusXp = 2000,
	},
	wildernessAgilityCourse = {
		skill = "Agility",
		disp  = "Wilderness Agility Course",
		name  = "Wilderness Agility Course",
		xp    = 571.4,
	},
	urnMultipliers = {
		default           = 1.2,
		exquisite         = 1.25,
		enhancer          = 1.25,
		exquisiteEnhancer = 1.3125,
	},
	rules = {
		-- Clear generated arguments before rebuilding them.
		{
			name = "Clear generated Experience Buff arguments",
			disable = {
				"bonus",
				"gorjan_floor_base_xp",
				"gorjan_skill_xp",
			},
		},
		{
			name = "Clear Portable Range",
			skill = {
				"Cooking",
			},
			disable = {
				"portable_range",
			},
		},

		-- Convert calculator values to Experience Buffs formats.
		{
			name = "Avatar percentage",
			source = "avatar",
			transform = "toPercentString",
		},
		{
			name = "Custom boost percentages",
			fields = {
				"custom",
				"custom_base",
				"custom_dxp",
				"custom_standalone",
				"custom_cat_a",
				"custom_cat_b_add",
				"custom_cat_b_mult",
				"custom_global",
				"custom_bonus",
				"custom_bonus_boost",
			},
			transform = "toExperienceBuffScale",
			default = 0,
		},

		-- Map calculator selections to Experience Buffs arguments.
		{
			name = "Abandoned to Occult Gorajan floor XP",
			skill = {
				"Dungeoneering",
			},
			disp = {
				"Dungeons",
			},
			when = {
				dungOutfits =
					"Abandoned/Frozen/Furnished/Occult",
			},
			set = {
				gorjan_floor_base_xp = "5%",
			},
		},
		{
			name = "Warped Gorajan floor XP",
			skill = {
				"Dungeoneering",
			},
			disp = {
				"Dungeons",
			},
			when = {
				dungOutfits = "Warped",
			},
			set = {
				gorjan_floor_base_xp = "7%",
			},
		},
		{
			name = "Abandoned to Occult Gorajan skill XP",
			excludeSkill = {
				"Dungeoneering",
			},
			when = {
				dungOutfits =
					"Abandoned/Frozen/Furnished/Occult",
			},
			set = {
				gorjan_skill_xp = "5%",
			},
		},
		{
			name = "Warped Gorajan skill XP",
			excludeSkill = {
				"Dungeoneering",
			},
			when = {
				dungOutfits = "Warped",
			},
			set = {
				gorjan_skill_xp = "7%",
			},
		},
		{
			name = "Stored bonus XP",
			when = {
				bxp = true,
			},
			numberAbove = {
				bxpnum = 0,
			},
			set = {
				bonus = true,
			},
		},
		{
			name = "Cooking Portable Range",
			skill = {
				"Cooking",
			},
			when = {
				cookingMethod = "Portable Range",
			},
			set = {
				portable_range = true,
			},
		},

		-- Argument-combination restrictions run before broader rules.
		{
			name = "Altar powder disables juju",
			when = {
				altar_powder = "Powder",
				juju = true,
			},
			disable = {
				"juju",
			},
		},
		{
			name = "Cinder pocket disables pulse pocket",
			when = {
				cinder_pocket = true,
			},
			disable = {
				"pulse_pocket",
			},
		},
		{
			name = "DXP restrictions",
			when = {
				dxp = true,
			},
			disable = {
				"altar_powder",
				"brawling",
				"dwarven_tool",
				"small_bomb",
			},
		},

		-- Broad sub-category restrictions.
		{
			name = "Blast furnace and Dungeoneering restrictions",
			disp = {
				"Blast furnace",
				"Dungeoneering",
			},
			disable = {
				"avatar",
				"outfit",
			},
		},
		{
			name = "Urn calculator restrictions",
			disp = {
				"Urns",
			},
			disable = {
				"urn",
				"urnEnhancer",
			},
		},
		{
			name = "Silverhawk brawling restriction",
			skill = {
				"Agility",
			},
			disp = {
				"Silverhawk Feathers",
			},
			disable = {
				"brawling",
			},
		},
		{
			name = "Cooking Brewing and Churning restrictions",
			skill = {
				"Cooking",
			},
			disp = {
				"Brewing",
				"Churning",
			},
			disable = {
				"bonfire",
				"portable_range",
			},
		},
		{
			name = "Cooking Gnome Drinks restriction",
			skill = {
				"Cooking",
			},
			disp = {
				"Gnome Drinks",
			},
			disable = {
				"portable_range",
			},
		},
		{
			name = "Cooking gauntlet restrictions",
			skill = {
				"Cooking",
			},
			disp = {
				"Brewing",
				"Churning",
				"Gnome Drinks",
				"Dungeoneering",
				"Urns",
			},
			disable = {
				"cookingGauntlets",
			},
		},
		{
			name = "Divination boon restrictions",
			skill = {
				"Divination",
			},
			disp = {
				"Boons",
				"Divine locations",
				"Dungeoneering",
				"Hall of Memories",
				"Hall of Memories (2 tick)",
				"Harvest",
				"Memory-storage bots",
				"Milestones",
				"Other",
				"Signs and Portents",
				"Transmutation",
			},
			disable = {
				"boon",
			},
		},
		{
			name = "Runecrafting Abyss restrictions",
			skill = {
				"Runecrafting",
			},
			disp = {
				"Impure Runes",
				"Pouches",
				"Runespan - Free",
				"Runespan - Members",
				"Tiaras",
			},
			disable = {
				"abyss",
			},
		},

		-- DXP runs first so it can see the original DXP selection.
		{
			name = "Construction unstable protean restriction",
			skill = {
				"Construction",
			},
			disp = {
				"Unstable Protean Plank",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Cooking unstable protean restriction",
			skill = {
				"Cooking",
			},
			disp = {
				"Unstable Protean Protein",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Crafting unstable protean restriction",
			skill = {
				"Crafting",
			},
			disp = {
				"Unstable Protean Hide",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Divination unstable protean restriction",
			skill = {
				"Divination",
			},
			disp = {
				"Unstable Protean Memory",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Firemaking unstable protean restriction",
			skill = {
				"Firemaking",
			},
			disp = {
				"Unstable Protean Logs",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Fletching unstable protean restriction",
			skill = {
				"Fletching",
			},
			disp = {
				"Unstable Protean Logs",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Herblore unstable protean restriction",
			skill = {
				"Herblore",
			},
			disp = {
				"Unstable Protean Shake",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Hunter unstable protean restriction",
			skill = {
				"Hunter",
			},
			disp = {
				"Unstable Protean Trap",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Invention unstable protean restriction",
			skill = {
				"Invention",
			},
			disp = {
				"Unstable Protean Cog",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Runecrafting unstable protean restriction",
			skill = {
				"Runecrafting",
			},
			disp = {
				"Unstable Protean Essence",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},
		{
			name = "Smithing unstable protean restriction",
			skill = {
				"Smithing",
			},
			disp = {
				"Unstable Protean Bar",
			},
			disable = {
				"dxp",
				"small_bomb",
			},
		},

		-- Individual method restrictions.
		{
			name = "Cleansing crystal altar powder restriction",
			skill = {
				"Prayer",
			},
			method = {
				"Cleansing crystal",
			},
			disable = {
				"altar_powder",
			},
		},
		{
			name = "Curly root urn restriction",
			skill = {
				"Woodcutting",
			},
			method = {
				"Curly root",
			},
			disable = {
				"urn",
				"urnEnhancer",
			},
		},
	},
}