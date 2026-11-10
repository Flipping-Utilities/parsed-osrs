--[=[ eltRules
-- Data rules for Skill calc/eltGenrator table output.
--
-- Fields:
--      eltsAliases       lookup table for remapping calculator
--                        skill/sub-category keys to elts header keys
--      dataAliases       lookup table for remapping calculator
--                        skill/sub-category keys to source data keys
--      currencyOrder     preferred currency order by resolved elts key
--                        unlisted currencies follow calculation order
--      wikiAttrs         maps table, header, and cell attributes
--          rowStatusClasses   CSS classes keyed by calculated row status
--                             values are unlocked, future, and unavailable
--      displaySort       row sort settings for rendered output
--          statusOrder       calculated statuses in display sort order
--                            unknown statuses sort after listed statuses
--          headersOrder      table headers used as tie-breakers
--                            headers not in the selected table are skipped
--                            values come from each header's display sort value
--          sortValues        custom data-sort-value mappings by header
--              values            exact raw values mapped to sort values
--              missing           sort value used for nil or empty values
--      displayTextOnly  rules that replace the complete wikitable output
--                        the first matching rule is rendered
--      displayBeforeTableText
--                        rules rendered before a normal wikitable
--                        all matching rules are rendered in source order
--          label             label for the display-text rule
--          calculatorArgs    optional calculator argument filter
--          text              flat replacement text template
--          values            replacements using the formatColumnText
--                            value structure
--      displayReferences rules that add markers to matching cells and notes
--                        below the completed table
--          label             label for the reference rule
--          group             optional MediaWiki reference group
--                            rules with the same group share one list
--                            rules with different groups use separate lists
--                            omitted group uses the default reference list
--          calculatorArgs    optional calculator argument filter
--              ["all"]           every listed argument must match
--              ["any"]           at least one listed argument must match
--              ["not"]           no listed argument may match
--                                supplied groups use AND logic
--                                at least one group must be present
--                                any calculator argument may be used
--                                values may be one value or a value list
--          columns           optional ordered marker columns
--                            first displayed column is used
--          message           reference message template
--          placement         marker placement
--                            afterCell appends to the completed cell
--                            afterLink appends to the displayed item link
--                            omitted placement defaults to afterCell
--          entries           optional nested entry list to process
--              source            source containing the entry list
--                                valid values are result and data
--              field             entry-list field keyed by table header
--          values            optional message replacement values
--                            uses the formatColumnText value structure
--          match             rule used to decide whether a cell is marked
--          source            source table checked by match or values
--                            valid values are result, data, and entry
--          field             field names keyed by table header
--          value             optional exact field value
--          values            optional list of accepted exact field values
--                            omitted value/values matches any non-empty value
--      formatColumnText  rules that resolve, format, and transform display
--                        cell text
--          label             label for the rule
--          calculatorArgs    optional calculator argument filter
--              ["all"]           every listed argument must match
--              ["any"]           at least one listed argument must match
--              ["not"]           no listed argument may match
--                                supplied groups use AND logic
--                                at least one group must be present
--                                any calculator argument may be used
--                                values may be one value or a value list
--          text              final cell text template
--          values            replacement values used by the text template
--          cellText          optional built-in replacement for current
--                            cell text; may be overridden in values
--          source            source table for a replacement value
--                            valid values are result, data, and args
--          field             table of field names keyed by table header
--                            a rule applies when this has the current header
--          textField         optional table of link text fields keyed by header
--          format            formatter for the replacement value
--                            valid values include text, link, currency,
--                            materialList, multiplier, _plink, _plinkt,
--                            and _plinkp
--          calculatedCostPrefix
--                            numbered calculated cost prefix by header
--          defaultLink       optional fallback link target for link formatting
--          defaultText       optional fallback link text for link formatting
--          minCount          optional minimum numeric value required
--          round             optional numeric rounding mode
--                            floor, ceiling, or round
--          decimalPlaces     optional non-negative decimal places
--                            defaults to 0 when round is present
--                            implies regular round when used alone
--          actions           optional fixed action multiplier for
--                            materialList formatting
--          splitPipe         true parses the source value as link|text
--          args              optional formatter arguments
--]=]

local p2pf2p = "[[File:P2P-F2P icon.png|30px|link=|alt=Members]]"

return {
	eltsAliases = {
		["Cooking-Fish"] = "Cooking-No Burn",
		["Cooking-Gnome Baking"] = "Cooking-No Burn",
		["Cooking-Meat"] = "Cooking-No Burn",
		["Cooking-Other"] = "Cooking-No Burn",
		["Cooking-Pie"] = "Cooking-No Burn",
		["Cooking-Pizza"] = "Cooking-No Burn",
		["Divination-All"] = "Divination-Profit/Loss",
		["Divination-Conversion"] = "Divination-Materials",
		["Divination-Divine locations"] = "Divination-Profit/Loss (no urns)",
		["Divination-Dungeoneering"] = "Divination-Materials (no urns)",
		["Divination-Hall of Memories"] = "Divination-Materials",
		["Divination-Hall of Memories (2 tick)"] = "Divination-Materials",
		["Divination-Memory-storage bots"] = "Divination-Materials (no urns)",
		["Divination-Milestones"] = "Divination-Profit/Loss",
		["Divination-Signs and Portents"] = "Divination-Profit/Loss",
		["Divination-Transmutation"] = "Divination-Profit/Loss (no urns)",
		["Fletching-Dungeoneering - Arrows"] = "Fletching-Dungeoneering",
		["Fletching-Dungeoneering - Bows"] = "Fletching-Dungeoneering",
		["Fletching-Dungeoneering - Staves"] = "Fletching-Dungeoneering",
		["Fletching-Dungeoneering - Traps"] = "Fletching-Dungeoneering",
		["Hunter-Herblore Habitat"] = "Hunter-Anachronia",
		["Hunter-Big Game Hunting"] = "Hunter-No Product",
		["Hunter-Box Trapping"] = "Hunter-Bait",
		["Hunter-Deadfall and Pitfall"] = "Hunter-Bait",
		["Hunter-Het's Oasis Scarabs"] = "Hunter-Bait",
		["Hunter-Nets and Sprites"] = "Hunter-Bait",
		["Hunter-Soporith Moths"] = "Hunter-No Bait No Product",
		["Runecrafting-Runes - Free"] = "Runecrafting-Runes",
		["Runecrafting-Impure Runes"] = "Runecrafting-Runes",
		["Runecrafting-Runes - Members"] = "Runecrafting-Runes",
		["Slayer-Items"] = "Slayer-Basic",
		["Slayer-Masters"] = "Slayer-Basic",
		["Slayer-Milestones"] = "Slayer-Basic",
		["Smithing-Adamant"] = "Smithing-Profit/Loss",
		["Smithing-Bane"] = "Smithing-Profit/Loss",
		["Smithing-Bronze"] = "Smithing-Profit/Loss",
		["Smithing-Elder rune"] = "Smithing-Profit/Loss",
		["Smithing-Godswords"] = "Smithing-Profit/Loss",
		["Smithing-Iron"] = "Smithing-Profit/Loss",
		["Smithing-Kethsian"] = "Smithing-Basic",
		["Smithing-Malevolent"] = "Smithing-Profit/Loss",
		["Smithing-Masterwork (finished)"] = "Smithing-Profit/Loss",
		["Smithing-Masterwork (unfinished)"] = "Smithing-Basic",
		["Smithing-Masterwork materials"] = "Smithing-Raw cost",
		["Smithing-Miscellaneous"] = "Smithing-Profit/Loss",
		["Smithing-Mithril"] = "Smithing-Profit/Loss",
		["Smithing-Necronium"] = "Smithing-Profit/Loss",
		["Smithing-Obsidian"] = "Smithing-Basic",
		["Smithing-Orikalkum"] = "Smithing-Profit/Loss",
		["Smithing-Rune"] = "Smithing-Profit/Loss",
		["Smithing-Steel"] = "Smithing-Profit/Loss",
		["Urns"] = "Urns",
	},
	dataAliases = {
		["Mining-Gems"] = "Gemstone rocks",
	},
	currencyOrder = {},
	wikiAttrs = {
		tableClasses = {
			"wikitable",
			"sortable",
			"sticky-header",
		},
		rowStatusClasses = {
			unlocked    = "table-bg-green",
			future      = "table-bg-yellow",
			unavailable = "table-bg-red",
		},
		classes = {
			["align-center"] = {
				"Level",
				"Slayer Level",
				"XP",
				"Total XP",
				"Egg to baby",
				"Baby to adolescent",
				"Adolescent to adult",
				"Adult to elder",
				"# needed",
				"# urns",
				"Stop burning",
				"Bench",
				"Wood",
				"Tool",
				"Bait",
				"Charm",
				"Pouch",
				"Guide",
				p2pf2p,
			},
			["align-right"] = {
				"Unit cost",
				"Cost",
				"Raw cost",
				"Product cost",
				"Profit",
				"Profit/Loss",
				"XP cost",
				"Profit/XP",
				"Cost with<br/>[[Elemental battlestaff]]",
			},
		},
		["data-sort-value"] = {
			"Level",
			"Slayer Level",
			"XP",
			"Total XP",
			"Egg to baby",
			"Baby to adolescent",
			"Adolescent to adult",
			"Adult to elder",
			"# needed",
			"# urns",
			"Stop burning",
			"Unit cost",
			"Cost",
			"Raw cost",
			"Product cost",
			"Profit",
			"Profit/Loss",
			"XP cost",
			"Profit/XP",
			"Cost with<br/>[[Elemental battlestaff]]",
			p2pf2p,
		},
		["colspan=2"] = {
			"Name",
			"Pouch",
			"Bait",
		},
	},
	displaySort = {
		statusOrder = {
			"unlocked",
			"future",
			"unavailable",
		},
		headersOrder = {
			"Level",
			"XP",
			"# needed",
			"Name",
		},
		sortValues = {
			["Stop burning"] = {
				values = {
					["Never"] = 1000,
				},
				missing = 1001,
			},
			[p2pf2p] = {
				values = {
					["false"] = 0,
					["true"] = 1,
				},
			},
		},
	},
	displayTextOnly = {
		{
			label = "Silverhawk Feathers",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Agility",
					["disp"] = "Silverhawk Feathers",
				},
			},
			text =
				"To train from {currXP} experience "
					.. "(level {currLevel}) to {goalXP} "
					.. "experience (level {goalLevel}), "
					.. "{remaining} experience is needed. "
					.. "This requires '''{feathers} "
					.. "[[Silverhawk feathers|feathers]]''' "
					.. "and, at current GE Prices, will cost "
					.. "{totalMaterialCost} coins.",
			values = {
				currXP = {
					source = "result",
					field = "currXP",
					format = "number",
				},
				currLevel = {
					source = "result",
					field = "currLevel",
					format = "number",
				},
				goalXP = {
					source = "result",
					field = "goalXP",
					format = "number",
				},
				goalLevel = {
					source = "result",
					field = "goalLevel",
					format = "number",
				},
				remaining = {
					source = "result",
					field = "actualRemaining",
					format = "number",
				},
				feathers = {
					source = "result",
					field = "actionsNeeded",
					format = "number",
				},
				totalMaterialCost = {
					source = "result",
					field = "totalMaterialCost",
					format = "currency",
				},
			},
		},
		{
			label = "Wilderness Agility Course",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Agility",
					["disp"] =
						"Wilderness Agility Course",
				},
			},
			text =
				"To train from '''{currXP} experience''' "
					.. "(level {currLevel}) to '''{goalXP} "
					.. "experience''' (level {goalLevel}), "
					.. "'''{remaining} experience''' is "
					.. "needed.<br/>This requires '''{laps} "
					.. "laps''' to be completed at "
					.. "'''{xpPerLap} XP''' per lap.",
			values = {
				currXP = {
					source = "result",
					field = "currXP",
					format = "number",
				},
				currLevel = {
					source = "result",
					field = "currLevel",
					format = "number",
				},
				goalXP = {
					source = "result",
					field = "goalXP",
					format = "number",
				},
				goalLevel = {
					source = "result",
					field = "goalLevel",
					format = "number",
				},
				remaining = {
					source = "result",
					field = "actualRemaining",
					format = "number",
				},
				laps = {
					source = "result",
					field = "lapsNeeded",
					format = "number",
				},
				xpPerLap = {
					source = "result",
					field = "actionXp",
					format = "number",
					decimalPlaces = 1,
				},
			},
		},
	},
	displayBeforeTableText = {
		{
			label = "Experience summary",
			text =
				"<div style='font-size:1.1em; "
					.. "font-weight:bold;'>"
					.. "To train {skill} from {currXP} "
					.. "experience (level {currLevel}) to "
					.. "{goalXP} experience "
					.. "(level {goalLevel}), {remaining} "
					.. "experience is required.</div>",
			values = {
				skill = {
					source = "args",
					field = "skill",
					format = "text",
				},
				currXP = {
					source = "result",
					field = "currXP",
					format = "number",
				},
				currLevel = {
					source = "result",
					field = "currLevel",
					format = "number",
				},
				goalXP = {
					source = "result",
					field = "goalXP",
					format = "number",
				},
				goalLevel = {
					source = "result",
					field = "goalLevel",
					format = "number",
				},
				remaining = {
					source = "result",
					field = "actualRemaining",
					format = "number",
				},
			},
		},
		{
			label = "Flatpacks level notice",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Construction",
					["disp"] = "Flatpacks",
				},
			},
			text =
				"<div style='color:red; font-size:0.9em; "
					.. "font-weight:bold;'>"
					.. "Levels refer to the minimum needed "
					.. "to use the associated workbench if "
					.. "otherwise lower.</div>",
		},
		{
			label = "Boons creation notice",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Divination",
					["disp"] = "Boons",
				},
			},
			text =
				"<div style='color:red; font-size:0.9em; "
					.. "font-weight:bold;'>"
					.. "Each boon can only be made once."
					.. "</div>",
		},
	},
	displayReferences = {
		{
			label = "storeline product price reference",
			group = "r",
			columns = {
				"Product cost",
				"Profit",
				"Profit/Loss",
			},
			message = "Sell {product} at {store}.",
			placement = "afterCell",
			entries = {
				source = "result",
				field = {
					["Product cost"] = "productCostDetails",
					["Profit"] = "productCostDetails",
					["Profit/Loss"] = "productCostDetails",
				},
			},
			values = {
				product = {
					source = "entry",
					field = {
						["Product cost"] = "name",
						["Profit"] = "name",
						["Profit/Loss"] = "name",
					},
					format = "link",
				},
				store = {
					source = "entry",
					field = {
						["Product cost"] = "storePage",
						["Profit"] = "storePage",
						["Profit/Loss"] = "storePage",
					},
					textField = {
						["Product cost"] = "storeName",
						["Profit"] = "storeName",
						["Profit/Loss"] = "storeName",
					},
					format = "link",
				},
			},
			match = {
				source = "entry",
				field = {
					["Product cost"] = "source",
					["Profit"] = "source",
					["Profit/Loss"] = "source",
				},
				values = {
					"store",
				},
			},
		},
		{
			label = "high alch product price reference",
			group = "r",
			columns = {
				"Product cost",
				"Profit",
				"Profit/Loss",
			},
			message = "High alch {product}.",
			placement = "afterCell",
			entries = {
				source = "result",
				field = {
					["Product cost"] = "productCostDetails",
					["Profit"] = "productCostDetails",
					["Profit/Loss"] = "productCostDetails",
				},
			},
			values = {
				product = {
					source = "entry",
					field = {
						["Product cost"] = "name",
						["Profit"] = "name",
						["Profit/Loss"] = "name",
					},
					format = "link",
				},
			},
			match = {
				source = "entry",
				field = {
					["Product cost"] = "source",
					["Profit"] = "source",
					["Profit/Loss"] = "source",
				},
				values = {
					"highalch",
				},
			},
		},
		{
			label = "storeline material price reference",
			group = "r",
			columns = {
				"Materials",
			},
			message = "Buy this from {store}.",
			placement = "afterLink",
			entries = {
				source = "result",
				field = {
					["Materials"] = "materialPriceDetails",
				},
			},
			values = {
				store = {
					source = "entry",
					field = {
						["Materials"] = "storePage",
					},
					textField = {
						["Materials"] = "storeName",
					},
					format = "link",
				},
			},
			match = {
				source = "entry",
				field = {
					["Materials"] = "source",
				},
				values = {
					"store",
				},
			},
		},
	},
	formatColumnText = {
		{
			label = "base result fields",
			text = "{cellText}",
			values = {
				cellText = {
					source = "result",
					field = {
						["Level"] = "level",
						["Slayer Level"] = "level2",
						["# needed"] = "actionsNeeded",
						["# urns"] = "urnsFilled",
						["Guide"] = "slayerGuide",
					},
					format = "text",
				},
			},
		},
		{
			label = "cooking base stop burning level",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Cooking",
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Stop burning"] = "noBurn",
					},
					format = "number",
				},
			},
		},
		{
			label = "cooking range gauntlet stop burning level",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Cooking",
					["cookingMethod"] = {
						"Range",
						"Portable Range",
					},
					["cookingGauntlets"] = true,
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Stop burning"] = "noBurnGauntlets",
					},
					format = "number",
				},
			},
		},
		{
			-- This needs verifying to see if bonfire uses regular fire
			-- stop burning levels
			label = "cooking bonfire stop burning level",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Cooking",
					["cookingMethod"] = "Bonfire",
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Stop burning"] = "noBurnFire",
					},
					format = "number",
				},
			},
		},
		{
			label = "cooking bonfire gauntlet stop burning level",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Cooking",
					["cookingMethod"] = "Bonfire",
					["cookingGauntlets"] = true,
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Stop burning"] =
							"noBurnFireGauntlets",
					},
					format = "number",
				},
			},
		},
		{
			label = "cooking Cook-o-Matic stop burning level",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Cooking",
					["cookingMethod"] = "Cook-o-Matic",
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Stop burning"] = "noBurnCookoMatic",
					},
					format = "number",
				},
			},
		},
		{
			label = "xp rounding",
			text = "{cellText}",
			values = {
				cellText = {
					source = "result",
					field = {
						["XP"] = "actionXp",
						["Egg to baby"] = "stage1Xp",
						["Baby to adolescent"] = "stage2Xp",
						["Adolescent to adult"] = "stage3Xp",
						["Adult to elder"] = "stage4Xp",
						["Total XP"] = "actionXp",
					},
					format = "number",
					decimalPlaces = 1,
				},
			},
		},
		{
			label = "Cost rounding",
			text = "{cellText}",
			values = {
				cellText = {
					source = "result",
					field = {
						["Unit cost"] = "materialCost",
						["Cost"] = "totalMaterialCost",
						["Raw cost"] = "totalMaterialCost",
						["Product cost"] = "totalOutputPrice",
						["Profit"] = "totalProfitLoss",
						["Profit/Loss"] = "totalProfitLoss",
						["Cost with<br/>[[Elemental battlestaff]]"] = "elementalBattlestaffTotalPrice",
					},
					format = "currency",
					calculatedCostPrefix = {
						["Unit cost"] = "calculatedMaterialCostPerAction",
						["Cost"] = "calculatedTotalMaterialCost",
						["Raw cost"] = "calculatedTotalMaterialCost",
						["Product cost"] = "calculatedTotalProductCost",
						["Profit"] = "calculatedTotalProfitLoss",
						["Profit/Loss"] = "calculatedTotalProfitLoss",
						["Cost with<br/>[[Elemental battlestaff]]"] =
							"calculatedElementalBattlestaffTotalCost",
					},
					decimalPlaces = 0,
				},
			},
		},
		{
			label = "Profit/XP rounding",
			text = "{cellText}",
			values = {
				cellText = {
					source = "result",
					field = {
						["Profit/XP"] = "profitPerXp",
						["XP cost"] = "xpCost",
					},
					format = "currency",
					calculatedCostPrefix = {
						["Profit/XP"] = "calculatedProfitPerXp",
						["XP cost"] = "calculatedXpCost",
					},
					decimalPlaces = 2,
				},
			},
		},
		{
			label = "summoning XP cost parity",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Summoning",
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "result",
					field = {
						["XP cost"] = "profitPerXp",
					},
					format = "currency",
					calculatedCostPrefix = {
						["XP cost"] = "calculatedProfitPerXp",
					},
					decimalPlaces = 2,
				},
			},
		},
		{
			label = "material quantity columns",
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Materials"] = "materialName1",
						["Seed"] = "materialName1",
						["Fruit"] = "materialName1",
					},
					format = "materialList",
				},
			},
		},
		{
			label = "summoning dungeoneering scroll materials",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Summoning",
					["disp"] = "Dungeoneering - Scrolls",
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Materials"] = "familiarIcon",
					},
					format = "_plink",
					args = {
						size = 32,
						["Materials"] = {
							linkField = {
								"familiar",
							},
							picField = {
								"familiarIcon",
							},
							textField = {
								"familiarTitle",
								"familiar",
							},
						},
					},
				},
			},
		},
		{
			label = "output quantity column",
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Output"] = "productName1",
					},
					format = "materialList",
				},
			},
		},
		{
			label = "fishing bait material quantity",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Fishing",
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Bait"] = "materialName1",
					},
					format = "materialList",
				},
			},
		},
		{
			label = "thieving safe location",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Thieving",
					["disp"] = "Safes",
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Location"] = "location",
					},
					format = "text",
				},
			},
		},
		{
			label = "thieving sorceress garden fruit",
			calculatorArgs = {
				["all"] = {
					["skill"] = "Thieving",
					["disp"] = "Sorceress Garden",
				},
			},
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Fruit"] = "materialName1",
					},
					format = "materialList",
				},
			},
		},
		{
			label = "name plinkt",
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Name"] = "name",
					},
					format = "_plinkt",
					args = {
						size = 32,
						["Name"] = {
							textField = {
								"title",
								"name",
							},
							picField = {
								"icon",
							},
							noIconField = "noIcon",
							resultPicField = {
								"icon",
							},
							sizeField = "iconSize",
							multiField = "multi",
							beforeLinkRules = {
								{
									source = "data",
									field = "sLink",
								},
							},
							afterLinkRules = {
								{
									source = "result",
									field = "outputQtyRange",
									format = "multiplier",
								},
								{
									source = "result",
									field = "outputQtyName",
									format = "multiplier",
									minCount = 1,
								},
								{
									source = "data",
									field = "eLink",
								},
							},
						},
					},
				},
			},
		},
		{
			label = "pouch and bait plinkt",
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Pouch"] = "familiarIcon",
						["Bait"] = "bait",
					},
					format = "_plinkt",
					args = {
						border = "no",
						size = 32,
						["Bait"] = {
							splitPipe = true,
						},
						["Pouch"] = {
							textField = {
								"familiarTitle",
								"familiar",
							},
							picField = {
								"familiarIcon",
							},
						},
					},
				},
			},
		},
		{
			label = "plinkp columns",
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Bench"] = "bench",
						["Wood"] = "wood",
						["Tool"] = "equipment",
						["Charm"] = "charm",
					},
					format = "_plinkp",
					args = {
						size = 32,
						["Bench"] = {
							picSuffix = "icon",
						},
					},
				},
			},
		},
		{
			label = "tech tree link",
			text = "{cellText}",
			values = {
				cellText = {
					source = "data",
					field = {
						["Tech tree"] = "techTree",
					},
					textField = {
						["Tech tree"] = "techTreeTitle",
					},
					format = "link",
					defaultLink = "Technology trees",
					defaultText = "Human",
				},
			},
		},
	},
}