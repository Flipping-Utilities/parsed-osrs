-- data for overriding things in the calculator
-- versions define what a row is split in to if there are multiple items of that type (eg jewellery charges)
--			potions are a special case and are caught automatically
-- names map page names to both gemw and image names
-- if only one needed, gemwnames and imgnames available

return {
	
	versions = {
		--charged jewellery
		['Amulet of farming'] = { 'Amulet of farming (1)', 'Amulet of farming (8)' },
		['Games necklace'] = { 'Games necklace (1)', 'Games necklace (8)' },
		['Ring of duelling'] = { 'Ring of duelling (1)', 'Ring of duelling (8)' },
		['Castle wars brace'] = { 'Castle wars brace (1)', 'Castle wars brace (3)' },
		['Forinthry bracelet'] = { 'Forinthry bracelet (1)', 'Forinthry bracelet (5)' },
		['Amulet of glory'] = { 'Amulet of glory', 'Amulet of glory (4)' },
		['Amulet of glory (t)'] = { 'Amulet of glory (t)', 'Amulet of glory (t4)' },
		['Ring of Wealth'] = { 'Ring of Wealth', 'Ring of Wealth (4)' },
		['Combat bracelet'] = { 'Combat bracelet', 'Combat bracelet (4)' },
		['Skills necklace'] = { 'Skills necklace', 'Skills necklace (4)' },
		
		-- ales in kegs
		['Asgarnian ale (keg)'] = { 'Asgarnian ale (1)', 'Asgarnian ale (2)', 'Asgarnian ale (3)', 'Asgarnian ale (4)' },
		['Asgarnian ale (m) (keg)'] = { 'Asgarnian ale (m1)', 'Asgarnian ale (m2)', 'Asgarnian ale (m3)', 'Asgarnian ale (m4)' },
		['Axeman\'s folly (keg)'] = { 'Axeman\'s folly (1)', 'Axeman\'s folly (2)', 'Axeman\'s folly (3)', 'Axeman\'s folly (4)' },
		['Axeman\'s folly (m) (keg)'] = { 'Axeman\'s folly (m1)', 'Axeman\'s folly (m2)', 'Axeman\'s folly (m3)', 'Axeman\'s folly (m4)' },
		['Chef\'s delight (keg)'] = { 'Chef\'s delight (1)', 'Chef\'s delight (2)', 'Chef\'s delight (3)', 'Chef\'s delight (4)' },
		['Chef\'s delight (m) (keg)'] = { 'Chef\'s delight (m1)', 'Chef\'s delight (m2)', 'Chef\'s delight (m3)', 'Chef\'s delight (m4)' },
		['Cider (keg)'] = { 'Cider (1)', 'Cider (2)', 'Cider (3)', 'Cider (4)' },
		['Cider (m) (keg)'] = { 'Cider (m1)', 'Cider (m2)', 'Cider (m3)', 'Cider (m4)' },
		['Dragon bitter (keg)'] = { 'Dragon bitter (1)', 'Dragon bitter (2)', 'Dragon bitter (3)', 'Dragon bitter (4)' },
		['Dragon bitter (m) (keg)'] = { 'Dragon bitter (m1)', 'Dragon bitter (m2)', 'Dragon bitter (m3)', 'Dragon bitter (m4)' },
		['Dwarven stout (keg)'] = { 'Dwarven stout (1)', 'Dwarven stout (2)', 'Dwarven stout (3)', 'Dwarven stout (4)' },
		['Dwarven stout (m) (keg)'] = { 'Dwarven stout (m1)', 'Dwarven stout (m2)', 'Dwarven stout (m3)', 'Dwarven stout (m4)' },
		['Greenman\'s ale (keg)'] = { 'Greenman\'s ale (1)', 'Greenman\'s ale (2)', 'Greenman\'s ale (3)', 'Greenman\'s ale (4)' },
		['Greenman\'s ale (m) (keg)'] = { 'Greenman\'s ale (m1)', 'Greenman\'s ale (m2)', 'Greenman\'s ale (m3)', 'Greenman\'s ale (m4)' },
		['Moonlight mead (keg)'] = { 'Moonlight mead (1)', 'Moonlight mead (2)', 'Moonlight mead (3)', 'Moonlight mead (4)' },
		['Moonlight mead (m) (keg)'] = { 'Moonlight mead (m1)', 'Moonlight mead (m2)', 'Moonlight mead (m3)', 'Moonlight mead (m4)' },
		['Pigswill (keg)'] = { 'Pigswill (1)', 'Pigswill (2)', 'Pigswill (3)', 'Pigswill (4)' },
		['Pigswill (m) (keg)'] = { 'Pigswill (m1)', 'Pigswill (m2)', 'Pigswill (m3)', 'Pigswill (m4)' },
		['Slayer\'s respite (keg)'] = { 'Slayer\'s respite (1)', 'Slayer\'s respite (2)', 'Slayer\'s respite (3)', 'Slayer\'s respite (4)' },
		['Slayer respite (m) (keg)'] = { 'Slayer respite (m1)', 'Slayer respite (m2)', 'Slayer respite (m3)', 'Slayer respite (m4)' },
		['Mind bomb'] = { 'Mind bomb (1)', 'Mind bomb (2)', 'Mind bomb (3)', 'Mind bomb (4)' },
		['Mind bomb (m)'] = { 'Mind bomb (m1)', 'Mind bomb (m2)', 'Mind bomb (m3)', 'Mind bomb (m4)' },
		['Wendlewick ale (keg)'] = { 'Wendlewick ale (1)', 'Wendlewick ale (2)', 'Wendlewick ale (3)', 'Wendlewick ale (4)' },
		['Wendlewick ale (m) (keg)'] = { 'Wendlewick ale (m1)', 'Wendlewick ale (m2)', 'Wendlewick ale (m3)', 'Wendlewick ale (m4)' },
		
		-- baskets
		['Apples'] = { 'Apples (5)' },
		['Bananas'] = { 'Bananas (5)' },
		['Oranges'] = { 'Oranges (5)' },
		['Strawberries'] = { 'Strawberries (5)' },
		['Tomatoes'] = { 'Tomatoes (5)' },
		
		-- sacks
		['Cabbages (sack)'] = { 'Cabbages (10)' },
		['Onions'] = { 'Onions (10)' },
		['Potatoes'] = { 'Potatoes (10)' },
		
		-- fog items
		['Combat hood'] = { 'Combat hood 0' },
		['Combat robe top'] = { 'Combat robe top 0' },
		['Combat robe bottom'] = { 'Combat robe bottom 0' },
		['Druidic mage hood'] = { 'Druidic mage hood 0' },
		['Druidic mage top'] = { 'Druidic mage top 0' },
		['Druidic mage bottom'] = { 'Druidic mage bottom 0' },
		['Battle hood'] = { 'Battle hood 0' },
		['Battle robe top'] = { 'Battle robe top 0' },
		['Battle robe bottom'] = { 'Battle robe bottom 0' },
		
		['Adamant spikeshield'] = { 'Adamant spikeshield 0' },
		['Adamant berserker shield'] = { 'Adamant berserker shield 0' },
		['Rune spikeshield'] = { 'Rune spikeshield 0' },
		['Rune berserker shield'] = { 'Rune berserker shield 0' },
		
		-- potions that are not potions
		['Compost potion'] = { 'Compost potion (1)', 'Compost potion (2)', 'Compost potion (3)', 'Compost potion (4)' },
		['Sacred oil'] = { 'Sacred oil (1)', 'Sacred oil (2)', 'Sacred oil (3)', 'Sacred oil (4)' },
		['Olive oil'] = { 'Olive oil (1)', 'Olive oil (2)', 'Olive oil (3)', 'Olive oil (4)' },
		['Mixture - step 1'] = { 'Mixture - step 1 (1)', 'Mixture - step 1 (2)', 'Mixture - step 1 (3)', 'Mixture - step 1 (4)' },
		['Mixture - step 2'] = { 'Mixture - step 2 (1)', 'Mixture - step 2 (2)', 'Mixture - step 2 (3)', 'Mixture - step 2 (4)' },
		['Guthix balance (unfinished)'] = { 'Guthix balance (unfinished) (1)', 'Guthix balance (unfinished) (2)', 'Guthix balance (unfinished) (3)', 'Guthix balance (unfinished) (4)' },
		
		-- other
		['Seaweed net'] = { 'Empty seaweed net' },
		['Waterskin'] = { 'Waterskin (0)', 'Waterskin (4)' },
		['XP Capacitor 5000'] = { 'XP Capacitor 5000 (charged)' },
	},


	names = {
	},
	gemwnames = {
	},
	imgnames = {
	},
}