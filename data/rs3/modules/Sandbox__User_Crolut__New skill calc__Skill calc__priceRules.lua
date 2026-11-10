--[=[ priceRules
-- Data rules for Skill calc cost calculations.
--
-- Fields:
--      storeBlacklist              Storeline stores excluded from pricing
--      currencyBlacklist           Storeline currencies excluded from pricing
--      geTaxRate                   product Grand Exchange tax rate
--      materialStoreStockCoverage  minimum store stock share for materials
--      highAlchMethods             material costs for one high alchemy use
--          materials                   item quantities used for one item
--      highAlchCostOverrides       method cost overrides by exact currency
--      highAlchCurrencyConversions one-to-one high alchemy currencies
--      productPriceSourceOrder     product source priority for equal values
--      materialPriceSourceOrder    material source priority for equal values
--]=]

return {
	storeBlacklist = {
		["reward shop (soul wars)"] = true,
	},
	currencyBlacklist = {
		zeal = true,
	},
	geTaxRate = 0.02,
	materialStoreStockCoverage = 0.3,
	highAlchCostOverrides = {
		["Rusty coins"] = 0,
	},
	highAlchCurrencyConversions = {
		["Rusty coins"] = true,
	},
	productPriceSourceOrder = {
		"ge",
		"store",
		"highalch",
	},
	materialPriceSourceOrder = {
		"ge",
		"store",
	},
	highAlchMethods = {
		["Spell"] = {
			materials = {
				{
					name = "Fire rune",
					quantity = 5,
				},
				{
					name = "Nature rune",
					quantity = 1,
				},
			},
		},
		["Alchemiser"] = {
			materials = {
				{
					name = "Divine charge",
					quantity = 45 / 8 / 3000,
				},
				{
					name = "Nature rune",
					quantity = 1,
				},
				{
					name = "Fire rune",
					quantity = 5,
				},
			},
		},
		["Alchemiser mk. II"] = {
			materials = {
				{
					name = "Divine charge",
					quantity = 150 / 25 / 3000,
				},
				{
					name = "Nature rune",
					quantity = 1,
				},
			},
		},
	},
}