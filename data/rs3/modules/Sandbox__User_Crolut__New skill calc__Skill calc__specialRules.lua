--[=[ specialRules
-- Data rules for Skill calc special cases.
--
-- Fields:
--      recipeReplacement rules replacing Recipe for matching rows
--          skill           optional matching skill names
--          disp            optional matching sub-category names
--          source          key in bucket containing replacement rules
--      outputQty         rules for output quantity modifiers
--      materialReduction rules for reducing material quantities
--          materials       exact material names affected by the rule
--          alternateResult separate calculated-cost result fields
--]=]

return {
	bucket = {
		itemInfo = {
			name = "infobox_item",
			itemField = "item_name",
			matchField = "exchange_page",
			matchPrefix = "Exchange:",
			fields = {
				{
					data = "tradable",
					numberedField = "Tradable",
					bucket = "tradeable",
				},
				{
					data = "highAlch",
					numberedField = "HighAlch",
					prefixes = {
						"product",
						"productOther",
					},
					bucket = "high_alchemy_value",
					number = true,
				},
				{
					data = "members",
					methodField = "members",
					prefix = "product",
					index = 1,
					bucket = "is_members_only",
				},
			},
		},
		urnInfo = {
			name = "infobox_urn",
			itemField = "name",
			skillField = "uses_skill",
			fields = {
				{
					data = "fillingRestriction",
					bucket = "filling_restriction",
					number = true,
				},
				{
					data = "noRestriction",
					bucket = "no_restriction",
				},
				{
					data = "xpToFill",
					bucket = "experience_to_fill",
					number = true,
				},
				{
					data = "baseExperience",
					bucket = "base_experience",
					number = true,
				},
				{
					data = "enhancedExperience",
					bucket = "enhanced_experience",
					number = true,
				},
				{
					data = "usesMaterial",
					bucket = "uses_material",
					repeated = true,
				},
			},
		},
		seedInfo = {
			name = "infobox_seed",
			itemField = "seed",
			pageField = "page_name",
			pageSubField = "page_name_sub",
			fields = {
				{data = "level", bucket = "level", number = true},
				{
					data = "materialQty1",
					bucket = "seed_amount",
					number = true,
				},
				{
					data = "plantXp",
					bucket = "plant_experience",
					number = true,
				},
				{
					data = "patchXp",
					bucket = "patch_experience",
					number = true,
				},
				{
					data = "checkXp",
					bucket = "check_experience",
					number = true,
				},
				{
					data = "harvestXp",
					bucket = "harvest_experience",
					number = true,
				},
				{
					data = "maxHarvestActions",
					bucket = "max_harvest_action",
					number = true,
				},
				{
					data = "harvestLife",
					bucket = "harvest_life",
					number = true,
				},
				{
					data = "productQty",
					bucket = "yield_per_harvest",
					number = true,
					default = 1,
				},
				{data = "cycle", bucket = "cycle", number = true},
				{
					data = "cycleLength",
					bucket = "cycle_length",
					number = true,
				},
				{data = "regrow", bucket = "regrow", number = true},
				{
					data = "applicableGrowthPotion",
					bucket = "applicable_growth_potion",
				},
				{
					data = "products",
					bucket = "crop_json",
					json = true,
				},
			},
		},
		storeline = {
			name = "storeline",
			itemField = "sold_item",
			currencyAliases = {
			},
			fields = {
				{ data = "storeSellPrice", bucket = "store_sell_price", },
				{ data = "storeBuyPrice", bucket = "store_buy_price", },
				{ data = "storeCurrency", bucket = "store_currency", },
				{ data = "storeHistorical", bucket = "is_historical", },
				{ data = "storeMembers", bucket = "is_members_only", },
				{ data = "storeName", bucket = "page_name", },
				{ data = "storePackAmount", bucket = "pack_amount", },
				{ data = "storePackOf", bucket = "pack_of", },
				{ data = "storePage", bucket = "page_name_sub", },
				{ data = "storeStock", bucket = "store_stock", },
				{ data = "storeStockInfinite", bucket = "store_stock_infinite",	},
			},
		},
	},
	recipeReplacement = {
		{
			disp = {
				"Urns",
			},
			source = "urnInfo",
		},
	},
	outputQty = {
		flatMultipliers = {
			{
				skill = {
					"Cooking",
				},
				disp = {
					"Brewing",
				},
				multiplier = 2,
			},
		},
		levelMultipliers = {
			{
				skill = {
					"Runecrafting",
				},
				disp = {
					"Runes - Free",
					"Runes - Members",
					"Impure Runes",
				},
				field = "name",
				levels = {
					["Air rune"] = {
						{ level = 1, multiplier = 1 },
						{ level = 11, multiplier = 2 },
						{ level = 22, multiplier = 3 },
						{ level = 33, multiplier = 4 },
						{ level = 44, multiplier = 5 },
						{ level = 55, multiplier = 6 },
						{ level = 66, multiplier = 7 },
						{ level = 77, multiplier = 8 },
						{ level = 88, multiplier = 9 },
						{ level = 99, multiplier = 10 },
						{ level = 110, multiplier = 11 },
						{ level = 121, multiplier = 12 },
					},
					["Mind rune"] = {
						{ level = 1, multiplier = 1 },
						{ level = 14, multiplier = 2 },
						{ level = 28, multiplier = 3 },
						{ level = 42, multiplier = 4 },
						{ level = 56, multiplier = 5 },
						{ level = 70, multiplier = 6 },
						{ level = 84, multiplier = 7 },
						{ level = 98, multiplier = 8 },
						{ level = 112, multiplier = 9 },
						{ level = 126, multiplier = 10 },
					},
					["Water rune"] = {
						{ level = 5, multiplier = 1 },
						{ level = 19, multiplier = 2 },
						{ level = 38, multiplier = 3 },
						{ level = 57, multiplier = 4 },
						{ level = 76, multiplier = 5 },
						{ level = 95, multiplier = 6 },
						{ level = 114, multiplier = 7 },
					},
					["Earth rune"] = {
						{ level = 9, multiplier = 1 },
						{ level = 26, multiplier = 2 },
						{ level = 52, multiplier = 3 },
						{ level = 78, multiplier = 4 },
						{ level = 104, multiplier = 5 },
					},
					["Fire rune"] = {
						{ level = 14, multiplier = 1 },
						{ level = 35, multiplier = 2 },
						{ level = 70, multiplier = 3 },
						{ level = 105, multiplier = 4 },
					},
					["Body rune"] = {
						{ level = 20, multiplier = 1 },
						{ level = 46, multiplier = 2 },
						{ level = 92, multiplier = 3 },
					},
					["Cosmic rune"] = {
						{ level = 27, multiplier = 1 },
						{ level = 59, multiplier = 2 },
						{ level = 118, multiplier = 3 },
					},
					["Chaos rune"] = {
						{ level = 35, multiplier = 1 },
						{ level = 74, multiplier = 2 },
					},
					["Astral rune"] = {
						{ level = 40, multiplier = 1 },
						{ level = 82, multiplier = 2 },
					},
					["Nature rune"] = {
						{ level = 44, multiplier = 1 },
						{ level = 91, multiplier = 2 },
					},
					["Law rune"] = {
						{ level = 54, multiplier = 1 },
						{ level = 110, multiplier = 2 },
					},
					["Death rune"] = {
						{ level = 65, multiplier = 1 },
					},
					["Armadyl rune"] = {
						{ level = 72, multiplier = 7 },
						{ level = 77, multiplier = 8 },
						{ level = 88, multiplier = 9 },
						{ level = 99, multiplier = 10 },
						{ level = 110, multiplier = 11 },
						{ level = 121, multiplier = 12 },
					},
					["Blood rune"] = {
						{ level = 77, multiplier = 1 },
					},
					["Soul rune"] = {
						{ level = 90, multiplier = 1 },
					},
					["Time rune"] = {
						{ level = 100, multiplier = 1 },
					},
					["Spirit rune"] = {
						{ level = 1, multiplier = 1 },
						{ level = 11, multiplier = 2 },
						{ level = 22, multiplier = 3 },
						{ level = 33, multiplier = 4 },
						{ level = 44, multiplier = 5 },
						{ level = 55, multiplier = 6 },
						{ level = 66, multiplier = 7 },
						{ level = 77, multiplier = 8 },
						{ level = 88, multiplier = 9 },
						{ level = 99, multiplier = 10 },
						{ level = 110, multiplier = 11 },
						{ level = 121, multiplier = 12 },
					},
					["Bone rune"] = {
						{ level = 20, multiplier = 1 },
						{ level = 46, multiplier = 2 },
						{ level = 92, multiplier = 3 },
					},
					["Flesh rune"] = {
						{ level = 40, multiplier = 1 },
						{ level = 82, multiplier = 2 },
					},
					["Miasma rune"] = {
						{ level = 60, multiplier = 1 },
						{ level = 120, multiplier = 2 },
					},
				},
			},
		},
	},
	materialReduction = {
		{
			skill = {
				"Fletching",
			},
			disp = {
				"Arrows",
				"Bolts",
				"Darts",
				"Bows - Unstrung",
			},
			arg = "portable",
			reduction = 0.1,
			doubleWithArg = "brooch",
		},
		{
			skill = {
				"Crafting",
			},
			arg = "portable",
			reduction = 0.1,
			doubleWithArg = "brooch",
		},
		{
			skill = {
				"Magic",
			},
			materials = {
				"Air rune",
				"Water rune",
				"Earth rune",
				"Fire rune",
			},
			reduction = 1,
			alternateResult = {
				key = "elementalBattlestaff",
				unitPriceField =
					"elementalBattlestaffUnitPrice",
				totalPriceField =
					"elementalBattlestaffTotalPrice",
				calculatedUnitCostPrefix =
					"calculatedElementalBattlestaffCostPerAction",
				calculatedTotalCostPrefix =
					"calculatedElementalBattlestaffTotalCost",
			},
		},
	},
}