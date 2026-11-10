--[=[
     Notations found in this Module:
        * name:     Name of product
        * icon:      Alternate image location
        * level:    Level required to complete
        * xp:       Experience gained
        * urns:     Indicates whether the item fills urns
        * maxLevel: Highest level of an item an urn can be filled
        * material: Materials required { #, "Item name", ...}
            - Special case for alternate currencies: {#, value, "Item name", ...}
        * mcount:   Material count - Number of materials required
            - This allows for exclusion of items not found in the GE
        * title:    Alternative name of object
            - Used to clarify the difference from a similar object or offer a cleaner name
        * mtrade:   Indicates whether the materials needed can be found in the GE
        * trade:    Indicates whether the product can be found in the GE
        * currency: Indicates an alternative currency being used
        * value:    Specifies the products value in alternative currency
        * members:  Indicates whether an item is members-only content
--]=]
local skillData = {}
 
return function(trainMethod)
 
    -- Popular Methods
    if trainMethod == "Popular" then
        local methods = 
        {
            {   
                icon        = "Oak logs",
                name        = "Oak tree",
                level       = 10,
                xp          = 37.5
            }, {
                icon        = "Willow logs",
                name        = "Willow tree",
                level       = 20,
                xp          = 67.5
            }, {
                icon        = "Maple logs",
                name        = "Maple tree",
                level       = 40,
                xp          = 100
            }, {
                icon        = "Acadia logs",
                name        = "Acadia tree",
                level       = 50,
                xp          = 80
            }, {
                icon        = "Eucalyptus logs",
                name        = "Eucalyptus tree",
                level       = 58,
                xp          = 165,
                members     = true
            }, {
                icon        = "Yew logs",
                name        = "Yew tree",
                level       = 70,
                xp          = 187.5
            }, {
                icon        = "Choking ivy icon",
                name        = "Choking ivy",
                level       = 68,
                xp          = 332.5,
                members     = true,
                trade       = 0
            }, {
                icon        = "Magic logs",
                name        = "Magic tree",
                level       = 80,
                xp          = 365,
                members     = true
            }, {
                name        = "Curly root",
                level       = 83,
                xp          = 161,
                urns        = false,
                members     = true,
                trade       = 0
            }, {
                icon        = "Elder logs",
                name        = "Elder tree",
                level       = 90,
                xp          = 425,
                members     = true
            }, {
                icon        = "Bamboo",
                name        = "Bamboo (tree)",
                title       = "Bamboo",
                level       = 90,
                xp          = 202.5,
                members     = true,
                trade       = 0
            }, {
                icon        = "Crystal geode",
                name        = "Crystal tree",
                level       = 94,
                xp          = 350,
                members     = true,
                trade       = 0
            }, {
                icon        = "Eternal magic logs",
                name        = "Eternal magic tree",
                level       = 100,
                xp          = 635,
                members     = true
            }
        }
    return methods
    end

    -- The Arc region
    if trainMethod == "The Arc" then
        local methods = 
        {
            {   
                icon        = "Bamboo",
                name        = "Bamboo (tree)",
                title       = "Bamboo",
                level       = 90,
                xp          = 202.5,
                members     = true,
                trade       = 0
            }, {
                icon        = "Golden bamboo",
                name        = "Golden bamboo (tree)",
                title       = "Golden bamboo",
                level       = 96,
                xp          = 655.5,
                members     = true,
                trade       = 0
            }
        }
    return methods
    end    
    
    if trainMethod == "Croesus" then
        local methods = 
        {
            {   
                name        = "Timber fungus",
                level       = 88,
                xp          = 550,
                members     = true
            }, {
                name        = "Enriched timber fungus",
                level       = 92,
                xp          = 585,
                members     = true
            }
        }
    return methods
    end    
            
    -- Free only options
    if trainMethod == "Free-to-Play" then
        local methods = 
        {
            {   
                icon        = "Logs",
                name        = "Tree",
                level       = 1,
                xp          = 25
            }, {
                icon        = "Oak logs",
                name        = "Oak tree",
                level       = 10,
                xp          = 37.5
            }, {
                icon        = "Willow logs",
                name        = "Willow tree",
                level       = 20,
                xp          = 67.5
            }, {
                icon        = "Maple logs",
                name        = "Maple tree",
                level       = 40,
                xp          = 100
            }, {
                icon        = "Acadia logs",
                name        = "Acadia tree",
                level       = 50,
                xp          = 80
            }, {
                icon        = "Yew logs",
                name        = "Yew tree",
                level       = 70,
                xp          = 187.5
            }
        }
    return methods
    end    
                    
    -- Members only options
    if trainMethod == "Members" then
        local methods = 
        {
            {   
                icon        = "Achey tree logs",
                name        = "Achey tree",
                level       = 1,
                xp          = 25,
                members     = true
            }, {
                icon        = "Teak logs",
                name        = "Teak tree",
                level       = 30,
                xp          = 85,
                members     = true
            }, {
                icon        = "Creeping ivy icon",
                name        = "Creeping ivy",
                level       = 35,
                xp          = 162.5,
                members     = true,
                trade       = 0
            }, {
                icon        = "Bark",
                name        = "Hollow tree",
                level       = 45,
                xp          = 82.5,
                members     = true
            }, {
                icon        = "Bark",
                name        = "Hollow tree",
                title       = "Hollow tree (Bark)",
                level       = 45,
                xp          = 357.7,
                members     = true
            }, {
                icon        = "Mahogany logs",
                name        = "Mahogany tree",
                level       = 60,
                xp          = 125,
                members     = true
            }, {
                icon        = "Arctic pine logs",
                name        = "Arctic pine tree",
                level       = 54,
                xp          = 145,
                members     = true
            }, {
                icon        = "Eucalyptus logs",
                name        = "Eucalyptus tree",
                level       = 58,
                xp          = 165,
                members     = true
            }, {
                icon        = "Choking ivy icon",
                name        = "Choking ivy",
                level       = 68,
                xp          = 332.5,
                members     = true,
                trade       = 0
            }, {
                icon        = "Magic logs",
                name        = "Magic tree",
                level       = 80,
                xp          = 365,
                members     = true
            }, {
                name        = "Overgrown idol",
                icon        = "Overgrown idol icon",
                title       = "Overgrown idols",
                iconSize    = 21,
                level       = 81,
                xp          = 383.5,
                members     = true,
                trade       = 0
            }, {
                icon        = "Cursed magic logs",
                name        = "Cursed magic tree",
                level       = 82,
                xp          = 400.0,
                members     = true,
                trade       = 0
            }, {
                name        = "Curly root",
                level       = 83,
                xp          = 161,
                urns        = false,
                members     = true,
                trade       = 0
            }, {
                icon        = "Bloodwood logs",
                name        = "Bloodwood tree",
                level       = 85,
                xp          = 320,
                members     = true,
                trade       = 0
            }, {
                icon        = "Elder logs",
                name        = "Elder tree",
                level       = 90,
                xp          = 425,
                members     = true
            }, {
                icon        = "Crystal geode",
                name        = "Crystal tree",
                level       = 94,
                xp          = 350,
                members     = true,
                trade       = 0
            }, {
                icon        = "Eternal magic logs",
                name        = "Eternal magic tree",
                level       = 100,
                xp          = 635,
                members     = true
            }
        }
    return methods
    end    

    -- Woodcutting urns
    if trainMethod == "Urns" then
        local methods = 
        {
            {   
                name        = "Cracked woodcutting urn",
                xp          = 960,
                urns        = false,
                maxLevel    = 10,
                material    = {1, "Cracked woodcutting urn (no rune)", 1, "Earth rune"},
                mcount      = 2,
                trade       = 0
            },{   
                name        = "Cracked woodcutting urn",
                title		= "Cracked woodcutting urn (Urn Enhancer)",
                xp          = 1000,
                urns        = false,
                maxLevel    = 10,
                material    = {1, "Cracked woodcutting urn (no rune)", 1, "Earth rune", 1/150, "Divine charge"},
                mcount      = 3,
                members     = true,
                trade       = 0
            },{   
                name        = "Fragile woodcutting urn",
                xp          = 2550,
                urns        = false,
                maxLevel    = 35,
                material    = {1, "Fragile woodcutting urn (no rune)", 1, "Earth rune"},
                mcount      = 2,
                trade       = 0
            },{   
                name        = "Fragile woodcutting urn",
                title		= "Fragile woodcutting urn (Urn Enhancer)",
                xp          = 2656.25,
                urns        = false,
                maxLevel    = 35,
                material    = {1, "Fragile woodcutting urn (no rune)", 1, "Earth rune", 1/150, "Divine charge"},
                mcount      = 3,
                members     = true,
                trade       = 0
            },{   
                name     = "Plain woodcutting urn",
                xp          = 4950,
                urns        = false,
                maxLevel    = 58,
                material    = {1, "Plain woodcutting urn (no rune)", 1, "Earth rune"},
                mcount      = 2,
                trade       = 0
            },{   
                name        = "Plain woodcutting urn",
                title		= "Plain woodcutting urn (Urn Enhancer)",
                xp          = 5156.25,
                urns        = false,
                maxLevel    = 58,
                material    = {1, "Plain woodcutting urn (no rune)", 1, "Earth rune", 1/150, "Divine charge"},
                mcount      = 3,
                members     = true,
                trade       = 0
            },{   
                name        = "Strong woodcutting urn",
                xp          = 9975,
                urns        = false,
                maxLevel    = 75,
                material    = {1, "Strong woodcutting urn (no rune)", 1, "Earth rune"},
                mcount      = 2,
                members     = true,
                trade       = 0
            },{   
                name        = "Strong woodcutting urn",
                title		= "Strong woodcutting urn (Urn Enhancer)",
                xp          = 10390.625,
                urns        = false,
                maxLevel    = 75,
                material    = {1, "Strong woodcutting urn (no rune)", 1, "Earth rune", 1/150, "Divine charge"},
                mcount      = 3,
                members     = true,
                trade       = 0
            },{   
                name        = "Decorated woodcutting urn",
                xp          = 11400,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated woodcutting urn (no rune)", 1, "Earth rune"},
                mcount      = 2,
                members     = true,
                trade       = 0
            },{   
                name        = "Decorated woodcutting urn",
                title		= "Decorated woodcutting urn (Urn Enhancer)",
                xp          = 11875,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated woodcutting urn (no rune)", 1, "Earth rune", 1/150, "Divine charge"},
                mcount      = 3,
                members     = true,
                trade       = 0
            },{   
                name        = "Exquisite woodcutting urn",
                xp          = 16268.75,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite woodcutting urn (no rune)", 1, "Earth rune"},
                mcount      = 2,
                members     = true,
                trade       = 0
            },{   
                name        = "Exquisite woodcutting urn",
                title		= "Exquisite woodcutting urn (Urn Enhancer)",
                xp          = 17082.1875,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite woodcutting urn (no rune)", 1, "Earth rune", 1/150, "Divine charge"},
                mcount      = 3,
                members     = true,
                trade       = 0
            }
        }
        return methods
    end

    -- Dungeon
    if trainMethod == "Dungeoneering" then
        local methods = 
        {
            {   
                icon        = "Tangle gum branches",
                name        = "Tangle gum tree",
                level       = 1,
                xp          = 35,
                urns        = false,
                trade       = 0
            }, {
                name        = "Seeping elm tree",
                icon        = "Seeping elm branches",
                level       = 10,
                xp          = 60,
                urns        = false,
                trade       = 0
            }, {
                name        = "Blood spindle tree",
                icon        = "Blood spindle branches",
                level       = 20,
                xp          = 85,
                urns        = false,
                trade       = 0
            }, {
                icon        = "Utuku branches",
                name        = "Utuku tree",
                level       = 30,
                xp          = 115,
                urns        = false,
                trade       = 0
            }, {
                icon        = "Spinebeam branches",
                name        = "Spinebeam tree",
                level       = 40,
                xp          = 145,
                urns        = false,
                trade       = 0
            }, {
                name        = "Bovistrangler tree",
                icon        = "Bovistrangler branches",
                level       = 50,
                xp          = 175,
                urns        = false,
                trade       = 0
            }, {
                name        = "Thigat tree",
                icon        = "Thigat branches",
                level       = 60,
                xp          = 210,
                urns        = false,
                members     = true,
                trade       = 0
            }, {
                name        = "Corpsethorn tree",
                icon        = "Corpsethorn branches",
                level       = 70,
                xp          = 245,
                urns        = false,
                members     = true,
                trade       = 0
            }, {
                name        = "Entgallow tree",
                icon        = "Entgallow branches",
                level       = 80,
                xp          = 285,
                urns        = false,
                members     = true,
                trade       = 0
            }, {
                name        = "Grave creeper tree",
                icon        = "Grave creeper branches",
                level       = 90,
                xp          = 330,
                urns        = false,
                members     = true,
                trade       = 0
            },
        }
        return methods
    end

    -- Other Methods
    if trainMethod == "Other" then
        local methods = 
        {
            {   
                name        = "Woodcutting#Jungle",
                title       = "Light jungle",
                icon        = "Machete",
                level       = 10,
                xp          = 32,
                members     = true,
                trade       = 0
            }, {
                name        = "Woodcutting#Jungle",
                title       = "Medium jungle",
                icon        = "Machete",
                level       = 20,
                xp          = 55,
                members     = true,
                trade       = 0
            }, {
                name        = "Woodcutting#Jungle",
                title       = "Dense jungle",
                icon        = "Machete",
                level       = 35,
                xp          = 80,
                members     = true,
                trade       = 0
            }, {
                name        = "Woodcutting#Canoes",
                title       = "Log canoe",
                icon        = "Log",
                iconSize    = 125,
                level       = 12,
                xp          = 30,
                trade       = 0
            }, {
                name        = "Woodcutting#Canoes",
                title       = "Dugout canoe",
                icon        = "Dugout",
                iconSize    = 125,
                level       = 27,
                xp          = 60,
                trade       = 0
            }, {
                name        = "Woodcutting#Canoes",
                title       = "Stable dugout canoe",
                icon        = "Stable Dugout",
                iconSize    = 125,
                level       = 42,
                xp          = 90,
                trade       = 0
            }, {
                name        = "Woodcutting#Canoes",
                title       = "Waka canoe",
                icon        = "Waka",
                iconSize    = 125,
                level       = 57,
                xp          = 150,
                trade       = 0
            }, {
                name        = "Split log",
                title       = "Split arctic pine logs",
                level       = 54,
                xp          = 43,
                urns        = false,
                members     = true,
                trade       = 0
            }
        }
        return methods
    end     
end