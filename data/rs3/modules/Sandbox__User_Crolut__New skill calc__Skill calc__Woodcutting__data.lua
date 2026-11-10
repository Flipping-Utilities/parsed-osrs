--[=[
     Notations found in this Module:
        * name:                Name of training method or target
        * icon:                Alternate image location
        * recipeReplacement:   Bucket source used instead of Recipe
        * level:               Level required to complete
        * xp:                  Experience gained
        * ticks:               Number of game ticks required per action
        * urns:                Indicates whether the item fills urns
        * maxLevel:            Highest level of an item an urn can be filled
        * title:               Alternative name of object - Used to clarify the difference from a similar object or offer a cleaner name
        * infoboxPageName:     Exact infobox bucket page name used
        * infoboxType:         Infobox bucket type used
        * recipePageName:      Exact Recipe bucket page_name used
        * recipeName:          Exact Recipe bucket production_json name used
        * recipeVersion:       Identifies the Recipe bucket version used when multiple recipes share the same page name
        * xpToFill:            Experience required to fill an urn
        * usesMaterialName#:   Name of an item that can be used to fill an urn
        * materialName#:       Name of material required
        * materialQty#:        Quantity of material required
        * materialTradable#:   Indicates whether a material can be found on the GE
        * materialStoreName#:  Store name used for a material cost
        * productName#:        Main output item produced
        * productQty#:         Quantity of product produced per action
        * productTradable#:    Indicates whether a product can be found on the GE
        * productHighAlch#:    High alchemy value of a product
        * productStoreName#:   Store name used for a product cost
        * members:             Indicates whether an item is members-only content
--]=]
local skillData = {}

return function(trainMethod)

    -- Popular Methods
    if trainMethod == "Popular" then
        local methods =
        {
			{
				name               = "Oak",
				icon               = "Oak logs",
				infoboxType        = "scenery",
				level              = 10,
				xp                 = 37.5,
				materialName1      = false,
				productName1       = "Oak logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 12,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Willow",
				icon               = "Willow logs",
				infoboxType        = "scenery",
				level              = 20,
				xp                 = 67.5,
				materialName1      = false,
				productName1       = "Willow logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 24,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Maple Tree",
				icon               = "Maple logs",
				infoboxType        = "scenery",
				recipeVersion      = "Standard",
				level              = 40,
				xp                 = 100,
				materialName1      = false,
				productName1       = "Maple logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 48,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Acadia tree",
				icon               = "Acadia logs",
				infoboxType        = "scenery",
				level              = 50,
				xp                 = 80,
				materialName1      = false,
				productName1       = "Acadia logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 51,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Eucalyptus tree",
				icon               = "Eucalyptus logs",
				infoboxType        = "scenery",
				level              = 58,
				xp                 = 165,
				materialName1      = false,
				productName1       = "Eucalyptus logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 75,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Yew",
				icon               = "Yew logs",
				infoboxType        = "scenery",
				level              = 70,
				xp                 = 187.5,
				materialName1      = false,
				productName1       = "Yew logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 96,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Choking ivy",
				icon               = "Choking ivy icon",
				infoboxType        = "scenery",
				level              = 68,
				xp                 = 332.5,
				materialName1      = false,
				productName1       = false,
				members            = true
			}, {
				name               = "Magic tree",
				icon               = "Magic logs",
				infoboxType        = "scenery",
				level              = 80,
				xp                 = 365,
				materialName1      = false,
				productName1       = "Magic logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 192,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Jade root (curly)",
				title              = "Curly root",
				icon               = "curly root",
				infoboxType        = "scenery",
				level              = 83,
				xp                 = 161.6,
				urns               = false,
				materialName1      = false,
				productName1       = "Curly root",
				productTradable1   = false,
				members            = true
			}, {
				name               = "Elder tree",
				icon               = "Elder logs",
				infoboxType        = "scenery",
				level              = 90,
				xp                 = 425,
				materialName1      = false,
				productName1       = "Elder logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 288,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Bamboo (tree)",
				title              = "Bamboo",
				icon               = "Bamboo",
				infoboxType        = "scenery",
				level              = 90,
				xp                 = 202.5,
				materialName1      = false,
				productName1       = "Bamboo",
				productQty1        = 1,
				productTradable1   = false,
				productHighAlch1   = false,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Crystal tree",
				icon               = "Crystal geode",
				infoboxType        = "scenery",
				level              = 94,
				xp                 = 350,
				materialName1      = false,
				productName1       = "Crystal geode",
				productTradable1   = false,
				members            = true
			}, {
				name               = "Eternal magic tree",
				icon               = "Eternal magic logs",
				infoboxType        = "scenery",
				level              = 100,
				xp                 = 635,
				materialName1      = false,
				productName1       = "Eternal magic logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 384,
				productStoreName1  = false,
				members            = true
			},
		}
    return methods
    end

    -- The Arc region
    if trainMethod == "The Arc" then
        local methods =
        {
			{
				name               = "Bamboo (tree)",
				title              = "Bamboo",
				icon               = "Bamboo",
				infoboxType        = "scenery",
				level              = 90,
				xp                 = 202.5,
				materialName1      = false,
				productName1       = "Bamboo",
				productQty1        = 1,
				productTradable1   = false,
				productHighAlch1   = false,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Golden Bamboo (tree)",
				title              = "Golden bamboo",
				icon               = "Golden bamboo",
				infoboxType        = "scenery",
				level              = 96,
				xp                 = 655.5,
				materialName1      = false,
				productName1       = "Golden bamboo",
				productQty1        = 1,
				productTradable1   = false,
				productHighAlch1   = false,
				productStoreName1  = false,
				members            = true
			},
		}
    return methods
    end

    -- Free only options
    if trainMethod == "Free-to-Play" then
        local methods =
        {
			{
				name               = "Tree",
				icon               = "Logs",
				infoboxType        = "scenery",
				recipeName         = "Tree",
				recipeVersion      = "Normal",
				level              = 1,
				xp                 = 25,
				materialName1      = false,
				productName1       = "Logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 2,
				productStoreName1  = "The Birds and the Bees",
				members            = false
			}, {
				name               = "Oak",
				icon               = "Oak logs",
				infoboxType        = "scenery",
				level              = 10,
				xp                 = 37.5,
				materialName1      = false,
				productName1       = "Oak logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 12,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Willow",
				icon               = "Willow logs",
				infoboxType        = "scenery",
				level              = 20,
				xp                 = 67.5,
				materialName1      = false,
				productName1       = "Willow logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 24,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Maple Tree",
				icon               = "Maple logs",
				infoboxType        = "scenery",
				recipeVersion      = "Standard",
				level              = 40,
				xp                 = 100,
				materialName1      = false,
				productName1       = "Maple logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 48,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Acadia tree",
				icon               = "Acadia logs",
				infoboxType        = "scenery",
				level              = 50,
				xp                 = 80,
				materialName1      = false,
				productName1       = "Acadia logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 51,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Yew",
				icon               = "Yew logs",
				infoboxType        = "scenery",
				level              = 70,
				xp                 = 187.5,
				materialName1      = false,
				productName1       = "Yew logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 96,
				productStoreName1  = false,
				members            = false
			},
		}
    return methods
    end

    -- Members only options
    if trainMethod == "Members" then
        local methods =
        {
			{
				name               = "Achey Tree",
				icon               = "Achey Tree logs",
				infoboxType        = "scenery",
				level              = 1,
				xp                 = 25,
				materialName1      = false,
				productName1       = "Achey tree logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 2,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Teak",
				icon               = "Teak logs",
				infoboxType        = "scenery",
				level              = 30,
				xp                 = 85,
				materialName1      = false,
				productName1       = "Teak logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 18,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Creeping ivy",
				icon               = "Creeping ivy icon",
				infoboxType        = "scenery",
				level              = 35,
				xp                 = 162.5,
				materialName1      = false,
				productName1       = false,
				members            = true
			}, {
				name               = "Hollow tree",
				icon               = "Bark",
				infoboxType        = "scenery",
				recipeVersion      = "No bark",
				level              = 45,
				xp                 = 82.5,
				materialName1      = false,
				productName1       = false,
				members            = true
			}, {
				name               = "Hollow tree",
				title              = "Hollow tree (Bark)",
				icon               = "Bark",
				infoboxType        = "scenery",
				recipeVersion      = "Bark",
				level              = 45,
				xp                 = 275,
				materialName1      = false,
				productName1       = "Bark",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 1,
				productStoreName1  = "Zaff's Superior Spellcasting",
				members            = false
			}, {
				name               = "Mahogany",
				icon               = "Mahogany logs",
				infoboxType        = "scenery",
				level              = 60,
				xp                 = 125,
				materialName1      = false,
				productName1       = "Mahogany logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 30,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Arctic Pine",
				icon               = "Arctic pine logs",
				infoboxType        = "scenery",
				level              = 54,
				xp                 = 145,
				materialName1      = false,
				productName1       = "Arctic pine logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 21,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Eucalyptus tree",
				icon               = "Eucalyptus logs",
				infoboxType        = "scenery",
				level              = 58,
				xp                 = 165,
				materialName1      = false,
				productName1       = "Eucalyptus logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 75,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Choking ivy",
				icon               = "Choking ivy icon",
				infoboxType        = "scenery",
				level              = 68,
				xp                 = 332.5,
				materialName1      = false,
				productName1       = false,
				members            = true
			}, {
				name               = "Magic tree",
				icon               = "Magic logs",
				infoboxType        = "scenery",
				level              = 80,
				xp                 = 365,
				materialName1      = false,
				productName1       = "Magic logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 192,
				productStoreName1  = false,
				members            = false
			}, {
				name               = "Overgrown idol",
				title              = "Overgrown idols",
				icon               = "Overgrown idol icon",
				iconSize           = 21,
				infoboxType        = "scenery",
				level              = 81,
				xp                 = 315,
				materialName1      = false,
				productName1       = false,
				members            = true
			}, {
				name               = "Cursed magic tree",
				icon               = "Cursed magic logs",
				infoboxType        = "scenery",
				level              = 82,
				xp                 = 400,
				materialName1      = false,
				productName1       = "Cursed magic logs",
				productQty1        = 1,
				productTradable1   = false,
				productHighAlch1   = 1,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Jade root (curly)",
				title              = "Curly root",
				icon               = "curly root",
				infoboxType        = "scenery",
				level              = 83,
				xp                 = 161.6,
				urns               = false,
				materialName1      = false,
				productName1       = "Curly root",
				productTradable1   = false,
				members            = true
			}, {
				name               = "Bloodwood tree",
				icon               = "Bloodwood logs",
				infoboxType        = "scenery",
				level              = 85,
				xp                 = 320,
				materialName1      = false,
				productName1       = "Bloodwood logs",
				productQty1        = 1,
				productTradable1   = false,
				productHighAlch1   = false,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Elder tree",
				icon               = "Elder logs",
				infoboxType        = "scenery",
				level              = 90,
				xp                 = 425,
				materialName1      = false,
				productName1       = "Elder logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 288,
				productStoreName1  = false,
				members            = true
			}, {
				name               = "Crystal tree",
				icon               = "Crystal geode",
				infoboxType        = "scenery",
				level              = 94,
				xp                 = 350,
				materialName1      = false,
				productName1       = "Crystal geode",
				productTradable1   = false,
				members            = true
			}, {
				name               = "Eternal magic tree",
				icon               = "Eternal magic logs",
				infoboxType        = "scenery",
				level              = 100,
				xp                 = 635,
				materialName1      = false,
				productName1       = "Eternal magic logs",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 384,
				productStoreName1  = false,
				members            = true
			},
		}
    return methods
    end

    -- Woodcutting urns
    if trainMethod == "Urns" then
        local methods =
        {
			{
				name               = "Cracked woodcutting urn",
				recipeReplacement  = "urnInfo",
				xp                 = 960,
				urns               = false,
				maxLevel           = 10,
				xpToFill           = 800,
				usesMaterialName1  = false,
				materialName1      = "Cracked woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				productName1       = false,
				members            = false
			}, {
				name               = "Cracked woodcutting urn",
				title              = "Cracked woodcutting urn (Urn Enhancer)",
				recipeReplacement  = "urnInfo",
				xp                 = 1000,
				urns               = false,
				maxLevel           = 10,
				xpToFill           = 800,
				usesMaterialName1  = false,
				materialName1      = "Cracked woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				materialName3      = "Divine charge",
				materialQty3       = 1 / 150,
				productName1       = false,
				members            = false
			}, {
				name               = "Fragile woodcutting urn",
				recipeReplacement  = "urnInfo",
				xp                 = 2550,
				urns               = false,
				maxLevel           = 35,
				xpToFill           = 2125,
				usesMaterialName1  = false,
				materialName1      = "Fragile woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				productName1       = false,
				members            = false
			}, {
				name               = "Fragile woodcutting urn",
				title              = "Fragile woodcutting urn (Urn Enhancer)",
				recipeReplacement  = "urnInfo",
				xp                 = 2656.2,
				urns               = false,
				maxLevel           = 35,
				xpToFill           = 2125,
				usesMaterialName1  = false,
				materialName1      = "Fragile woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				materialName3      = "Divine charge",
				materialQty3       = 1 / 150,
				productName1       = false,
				members            = false
			}, {
				name               = "Plain woodcutting urn",
				recipeReplacement  = "urnInfo",
				xp                 = 4950,
				urns               = false,
				maxLevel           = 58,
				xpToFill           = 4125,
				usesMaterialName1  = false,
				materialName1      = "Plain woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				productName1       = false,
				members            = false
			}, {
				name               = "Plain woodcutting urn",
				title              = "Plain woodcutting urn (Urn Enhancer)",
				recipeReplacement  = "urnInfo",
				xp                 = 5156.2,
				urns               = false,
				maxLevel           = 58,
				xpToFill           = 4125,
				usesMaterialName1  = false,
				materialName1      = "Plain woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				materialName3      = "Divine charge",
				materialQty3       = 1 / 150,
				productName1       = false,
				members            = false
			}, {
				name               = "Strong woodcutting urn",
				recipeReplacement  = "urnInfo",
				xp                 = 9975,
				urns               = false,
				maxLevel           = 75,
				xpToFill           = 8312.5,
				usesMaterialName1  = false,
				materialName1      = "Strong woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				productName1       = false,
				members            = true
			}, {
				name               = "Strong woodcutting urn",
				title              = "Strong woodcutting urn (Urn Enhancer)",
				recipeReplacement  = "urnInfo",
				xp                 = 10390.6,
				urns               = false,
				maxLevel           = 75,
				xpToFill           = 8312.5,
				usesMaterialName1  = false,
				materialName1      = "Strong woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				materialName3      = "Divine charge",
				materialQty3       = 1 / 150,
				productName1       = false,
				members            = true
			}, {
				name               = "Decorated woodcutting urn",
				recipeReplacement  = "urnInfo",
				xp                 = 11400,
				urns               = false,
				maxLevel           = -1,
				xpToFill           = 9500,
				usesMaterialName1  = false,
				materialName1      = "Decorated woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				productName1       = false,
				members            = true
			}, {
				name               = "Decorated woodcutting urn",
				title              = "Decorated woodcutting urn (Urn Enhancer)",
				recipeReplacement  = "urnInfo",
				xp                 = 11875,
				urns               = false,
				maxLevel           = -1,
				xpToFill           = 9500,
				usesMaterialName1  = false,
				materialName1      = "Decorated woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				materialName3      = "Divine charge",
				materialQty3       = 1 / 150,
				productName1       = false,
				members            = true
			}, {
				name               = "Exquisite woodcutting urn",
				recipeReplacement  = "urnInfo",
				xp                 = 16268.75,
				urns               = false,
				maxLevel           = -1,
				xpToFill           = 13015,
				usesMaterialName1  = false,
				materialName1      = "Exquisite woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				productName1       = false,
				members            = true
			}, {
				name               = "Exquisite woodcutting urn",
				title              = "Exquisite woodcutting urn (Urn Enhancer)",
				recipeReplacement  = "urnInfo",
				xp                 = 17285.4,
				urns               = false,
				maxLevel           = -1,
				xpToFill           = 13015,
				usesMaterialName1  = false,
				materialName1      = "Exquisite woodcutting urn (no rune)",
				materialQty1       = 1,
				materialTradable1  = true,
				materialName2      = "Earth rune",
				materialQty2       = 1,
				materialTradable2  = true,
				materialName3      = "Divine charge",
				materialQty3       = 1 / 150,
				productName1       = false,
				members            = true
			},
		}
        return methods
    end

    -- Dungeon
    if trainMethod == "Dungeoneering" then
        local methods =
        {
			{
				name               = "Tangle gum tree",
				icon               = "Tangle gum branches",
				infoboxType        = "scenery",
				level              = 1,
				xp                 = 35,
				urns               = false,
				materialName1      = false,
				productName1       = "Tangle gum branches",
				productTradable1   = false,
				members            = false
			}, {
				name               = "Seeping elm tree",
				icon               = "Seeping elm branches",
				infoboxType        = "scenery",
				level              = 10,
				xp                 = 60,
				urns               = false,
				materialName1      = false,
				productName1       = "Seeping elm branches",
				productTradable1   = false,
				members            = false
			}, {
				name               = "Blood spindle tree",
				icon               = "Blood spindle branches",
				infoboxType        = "scenery",
				level              = 20,
				xp                 = 85,
				urns               = false,
				materialName1      = false,
				productName1       = "Blood spindle branches",
				productTradable1   = false,
				members            = false
			}, {
				name               = "Utuku tree",
				icon               = "Utuku branches",
				infoboxType        = "scenery",
				level              = 30,
				xp                 = 115,
				urns               = false,
				materialName1      = false,
				productName1       = "Utuku branches",
				productTradable1   = false,
				members            = false
			}, {
				name               = "Spinebeam tree",
				icon               = "Spinebeam branches",
				infoboxType        = "scenery",
				level              = 40,
				xp                 = 145,
				urns               = false,
				materialName1      = false,
				productName1       = "Spinebeam branches",
				productTradable1   = false,
				members            = false
			}, {
				name               = "Bovistrangler tree",
				icon               = "Bovistrangler branches",
				infoboxType        = "scenery",
				level              = 50,
				xp                 = 175,
				urns               = false,
				materialName1      = false,
				productName1       = "Bovistrangler branches",
				productTradable1   = false,
				members            = false
			}, {
				name               = "Thigat tree",
				icon               = "Thigat branches",
				infoboxType        = "scenery",
				level              = 60,
				xp                 = 210,
				urns               = false,
				materialName1      = false,
				productName1       = "Thigat branches",
				productTradable1   = false,
				members            = true
			}, {
				name               = "Corpsethorn tree",
				icon               = "Corpsethorn branches",
				infoboxType        = "scenery",
				level              = 70,
				xp                 = 245,
				urns               = false,
				materialName1      = false,
				productName1       = "Corpsethorn branches",
				productTradable1   = false,
				members            = true
			}, {
				name               = "Entgallow tree",
				icon               = "Entgallow branches",
				infoboxType        = "scenery",
				level              = 80,
				xp                 = 285,
				urns               = false,
				materialName1      = false,
				productName1       = "Entgallow branches",
				productTradable1   = false,
				members            = true
			}, {
				name               = "Grave creeper tree",
				icon               = "Grave creeper branches",
				infoboxType        = "scenery",
				level              = 90,
				xp                 = 330,
				urns               = false,
				materialName1      = false,
				productName1       = "Grave creeper branches",
				productTradable1   = false,
				members            = true
			},
		}
        return methods
    end

    -- Other Methods
    if trainMethod == "Other" then
        local methods =
        {
			{
				name               = "Light jungle",
				icon               = "Machete",
				infoboxType        = "scenery",
				level              = 10,
				xp                 = 32,
				materialName1      = false,
				productName1       = false,
				members            = true
			}, {
				name               = "Medium jungle",
				icon               = "Machete",
				infoboxType        = "scenery",
				level              = 20,
				xp                 = 55,
				materialName1      = false,
				productName1       = false,
				members            = true
			}, {
				name               = "Dense jungle",
				icon               = "Machete",
				infoboxType        = "scenery",
				level              = 35,
				xp                 = 80,
				materialName1      = false,
				productName1       = false,
				members            = true
			}, {
				name               = "Canoe",
				title              = "Log canoe",
				icon               = "Log",
				iconSize           = 125,
				infoboxPageName    = "Canoe station",
				infoboxType        = "scenery",
				recipePageName     = "Canoe station",
				recipeName         = "Log canoe",
				level              = 12,
				xp                 = 30,
				materialName1      = false,
				productName1       = false,
				members            = false
			}, {
				name               = "Canoe",
				title              = "Dugout canoe",
				icon               = "Dugout",
				iconSize           = 125,
				infoboxPageName    = "Canoe station",
				infoboxType        = "scenery",
				recipePageName     = "Canoe station",
				recipeName         = "Dugout canoe",
				level              = 27,
				xp                 = 60,
				materialName1      = false,
				productName1       = false,
				members            = false
			}, {
				name               = "Canoe",
				title              = "Stable dugout canoe",
				icon               = "Stable Dugout",
				iconSize           = 125,
				infoboxPageName    = "Canoe station",
				infoboxType        = "scenery",
				recipePageName     = "Canoe station",
				recipeName         = "Stable Dugout canoe",
				level              = 42,
				xp                 = 90,
				materialName1      = false,
				productName1       = false,
				members            = false
			}, {
				name               = "Canoe",
				title              = "Waka canoe",
				icon               = "Waka",
				iconSize           = 125,
				infoboxPageName    = "Canoe station",
				infoboxType        = "scenery",
				recipePageName     = "Canoe station",
				recipeName         = "Waka Canoe",
				level              = 57,
				xp                 = 150,
				materialName1      = false,
				productName1       = false,
				members            = false
			}, {
				name               = "Split log",
				title              = "Split arctic pine logs",
				level              = 54,
				xp                 = 42.5,
				ticks              = 5,
				urns               = false,
				materialName1      = "Arctic pine logs",
				materialQty1       = 1,
				materialTradable1  = true,
				materialStoreName1 = false,
				productName1       = "Split log",
				productQty1        = 1,
				productTradable1   = true,
				productHighAlch1   = 54,
				productStoreName1  = false,
				members            = true
			},
		}
        return methods
    end
end