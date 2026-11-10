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
        * members:  Indicates whether an object is members-only content
--]=]
local skillData = {}
 
return function(trainMethod)
    if trainMethod == "Runes" then
        local methods = 
        {
            {
                name        = "Air rune",
                level       = 1,
                xp          = 5,
                material    = {1, "Rune essence"}
            }, {
                name        = "Mind rune",
                level       = 1,
                xp          = 5.5,
                material    = {1, "Rune essence"}
            }, {
                name        = "Water rune",
                level       = 5,
                xp          = 6,
                material    = {1, "Rune essence"}
            }, {
                name        = "Earth rune",
                level       = 9,
                xp          = 6.5,
                material    = {1, "Rune essence"}
            }, {
                name        = "Fire rune",
                level       = 14,
                xp          = 7,
                material    = {1, "Rune essence"}
            }, {
                name        = "Body rune",
                level       = 20,
                xp          = 7.5,
                material    = {1, "Rune essence"}
            }, {
                name        = "Cosmic rune",
                level       = 27,
                xp          = 8,
                material    = {1, "Pure essence"},
                members     = true
            }, {
                name        = "Chaos rune",
                level       = 35,
                xp          = 8.5,
                material    = {1, "Pure essence"},
                members     = true
            }, {
                name        = "Astral rune",
                level       = 40,
                xp          = 8.7,
                material    = {1, "Pure essence"},
                members     = true
            }, {
                name        = "Nature rune",
                level       = 44,
                xp          = 9,
                material    = {1, "Pure essence"},
                members     = true
            }, {
                name        = "Law rune",
                level       = 54,
                xp          = 9.5,
                material    = {1, "Pure essence"},
                members     = true
            }, {
                name        = "Death rune",
                level       = 65,
                xp          = 10,
                material    = {1, "Pure essence"},
                members     = true
            }, {
                name        = "Armadyl rune",
                level       = 72,
                xp          = 10,
                material    = {1, "Pure essence"},
                members     = true
            }, {
                name        = "Blood rune",
                level       = 77,
                xp          = 10.5,
                material    = {1, "Pure essence"},
                members     = true
            }, {
                name        = "Soul rune",
                level       = 90,
                xp          = 91.7,
                material    = {5/3, "Pure essence"},
                members     = true
            }, {
                name        = "Time rune",
                level       = 100,
                xp          = 17,
                material    = {1, "Pure essence"},
                members     = true
            }
        }
        return methods
    end

    -- Combination runes
    if trainMethod == "Combination runes" then
        local methods = 
        {
            {
                name        = "Mist rune",
                level       = 6,
                xp          = 8.5,
                material    = {1, "Pure essence", 1, "Air rune", 1, "Air talisman"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Mist rune",
                eLink       = "([[Magic Imbue]])",
                level       = 6,
                xp          = 8.5,
                material    = {1, "Pure essence", 1, "Air rune", 2, "Astral rune"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Dust rune",
                level       = 10,
                xp          = 9,
                material    = {1, "Pure essence", 1, "Air talisman", 1, "Air rune"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Dust rune",
                eLink       = "([[Magic Imbue]])",
                level       = 10,
                xp          = 9,
                material    = {1, "Pure essence", 1, "Air rune", 2, "Astral rune"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Mud rune",
                level       = 13,
                xp          = 9.5,
                material    = {1, "Pure essence", 1, "Water talisman", 1, "Water rune"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Mud rune",
                eLink       = "([[Magic Imbue]])",
                level       = 13,
                xp          = 9.5,
                material    = {1, "Pure essence", 1, "Water rune", 2, "Astral rune"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Smoke rune",
                level       = 15,
                xp          = 9.5,
                material    = {1, "Pure essence", 1, "Air talisman", 1, "Air rune"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Smoke rune",
                eLink       = "([[Magic Imbue]])",
                level       = 15,
                xp          = 9.5,
                material    = {1, "Pure essence", 1, "Air rune", 2, "Astral rune"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Steam rune",
                level       = 19,
                xp          = 10,
                material    = {1, "Pure essence", 1, "Water talisman", 1, "Water rune"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Steam rune",
                eLink       = "([[Magic Imbue]])",
                level       = 19,
                xp          = 10,
                material    = {1, "Pure essence", 1, "Water rune", 2, "Astral rune"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Lava rune",
                level       = 23,
                xp          = 10.5,
                material    = {1, "Pure essence", 1, "Earth talisman", 1, "Earth rune"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Lava rune",
                eLink       = "([[Magic Imbue]])",
                level       = 23,
                xp          = 10.5,
                material    = {1, "Pure essence", 1, "Earth rune", 2, "Astral rune"},
                mcount      = 4,
                members     = true
            }
        }
        return methods
    end

    -- Tiaras
    if trainMethod == "Tiaras" then
        local methods = 
        {
            {
                name        = "Air tiara",
                xp          = 25,
                material    = {1, "Tiara", 1, "Air talisman"},
                mcount      = 2,
                members     = false
            }, {
                name        = "Mind tiara",
                xp          = 27.5,
                material    = {1, "Tiara", 1, "Mind talisman"},
                mcount      = 2,
                members     = false
            }, {
                name        = "Water tiara",
                xp          = 30,
                material    = {1, "Tiara", 1, "Water talisman"},
                mcount      = 2,
                members     = false
            }, {
                name        = "Earth tiara",
                xp          = 32.5,
                material    = {1, "Tiara", 1, "Earth talisman"},
                mcount      = 2,
                members     = false
            }, {
                name        = "Fire tiara",
                xp          = 35,
                material    = {1, "Tiara", 1, "Fire talisman"},
                mcount      = 2,
                members     = false
            }, {
                name        = "Body tiara",
                xp          = 37.5,
                material    = {1, "Tiara", 1, "Body talisman"},
                mcount      = 2,
                members     = false
            }, {
                name        = "Cosmic tiara",
                xp          = 40,
                material    = {1, "Tiara", 1, "Cosmic talisman"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Chaos tiara",
                xp          = 42.5,
                material    = {1, "Tiara", 1, "Chaos talisman"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Nature tiara",
                xp          = 45,
                material    = {1, "Tiara", 1, "Nature talisman"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Law tiara",
                xp          = 47.5,
                material    = {1, "Tiara", 1, "Law talisman"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Death tiara",
                xp          = 50,
                material    = {1, "Tiara", 1, "Death talisman"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Blood tiara",
                xp          = 52.5,
                material    = {1, "Tiara", 1, "Blood talisman"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Soul tiara",
                xp          = 55,
                material    = {1, "Tiara", 1, "Soul talisman"},
                mcount      = 2,
                members     = true
            }
        }
    return methods
    end

    -- Runespan - Free
    if trainMethod == "Runespan - Free" then
        local methods = 
        {
            {
                name        = "Air essling",
                icon        = "Air essling icon",
                level       = 1,
                xp          = 9.5,
                trade       = 0
            }, {
                name        = "Mind essling",
                icon        = "Mind essling icon",
                level       = 1,
                xp          = 10,
                trade       = 0
            }, {
                name        = "Water essling",
                icon        = "Water essling icon",
                level       = 5,
                xp          = 12.6,
                trade       = 0
            }, {
                name        = "Earth essling",
                icon        = "Earth essling icon",
                level       = 9,
                xp          = 14.5,
                trade       = 0
            }, {
                name        = "Fire essling",
                icon        = "Fire essling icon",
                level       = 14,
                xp          = 17.4,
                trade       = 0
            }, {
                name        = "Body esshound",
                icon        = "Body esshound icon",
                level       = 33,
                xp          = 23.13,
                trade       = 0
            }, {
                name        = "Cyclone",
                icon        = "Cyclone icon",
                level       = 1,
                xp          = 19,
                trade       = 0
            }, {
                name        = "Mind storm",
                icon        = "Mind storm icon",
                level       = 1,
                xp          = 20,
                trade       = 0
            }, {
                name        = "Water pool",
                icon        = "Water pool icon",
                level       = 5,
                xp          = 25.3,
                trade       = 0
            }, {
                name        = "Rock fragment (Runespan)",
                icon        = "Rock fragment icon",
                title       = "Rock fragment",
                level       = 9,
                xp          = 28.6,
                trade       = 0
            }, {
                name        = "Fireball",
                icon        = "Fireball icon",
                level       = 14,
                xp          = 34.8,
                trade       = 0
            }, {
                name        = "Vine (Runespan)",
                icon        = "Vine icon",
                title       = "Vine (Water)",
                level       = 17,
                xp          = 30.3,
                trade       = 0
            }, {
                name        = "Vine (Runespan)",
                icon        = "Vine icon",
                title       = "Vine (Earth)",
                level       = 17,
                xp          = 34.3,
                trade       = 0
            }, {
                name        = "Fleshy growth",
                icon        = "Fleshy growth icon",
                level       = 33,
                xp          = 46.2,
                trade       = 0
            }, {
                name        = "Fire storm",
                icon        = "Fire storm icon",
                title       = "Fire storm (Air)",
                level       = 33,
                xp          = 22.8,
                trade       = 0
            }, {
                name        = "Fire storm",
                icon        = "Fire storm icon",
                title       = "Fire storm (Fire)",
                level       = 33,
                xp          = 41.7,
                trade       = 0
            }
        }
    return methods
    end

    -- Runespan - Members
    if trainMethod == "Runespan - Members" then
        local methods = 
        {
            {
                name        = "Cosmic esshound",
                icon        = "Cosmic esshound icon",
                level       = 33,
                xp          = 26.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Chaos esshound",
                icon        = "Chaos esshound icon",
                level       = 35,
                xp          = 30.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Astral esshound",
                icon        = "Astral esshound icon",
                level       = 40,
                xp          = 35.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Nature esshound",
                icon        = "Nature esshound icon",
                level       = 44,
                xp          = 43.33,
                trade       = 0,
                members     = true
            }, {
                name        = "Law esshound",
                icon        = "Law esshound icon",
                level       = 54,
                xp          = 54,
                trade       = 0,
                members     = true
            }, {
                name        = "Death esswraith",
                icon        = "Death esswraith icon",
                level       = 65,
                xp          = 60,
                trade       = 0,
                members     = true
            }, {
                name        = "Blood esswraith",
                icon        = "Blood esswraith icon",
                level       = 77,
                xp          = 73,
                trade       = 0,
                members     = true
            }, {
                name        = "Soul esswraith",
                icon        = "Soul esswraith icon",
                level       = 90,
                xp          = 106.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Chaotic cloud",
                icon        = "Chaotic cloud icon",
                level       = 35,
                xp          = 61.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Nebula",
                icon        = "Nebula icon",
                title       = "Nebula (Cosmic)",
                level       = 40,
                xp          = 63.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Nebula",
                icon        = "Nebula icon",
                title       = "Nebula (Astral)",
                level       = 40,
                xp          = 85.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Shifter (Runespan)",
                icon        = "Shifter icon",
                title       = "Shifter",
                level       = 44,
                xp          = 86.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Jumper",
                icon        = "Jumper icon",
                level       = 54,
                xp          = 107.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Skulls",
                icon        = "Skulls icon",
                level       = 65,
                xp          = 120,
                trade       = 0,
                members     = true
            }, {
                name        = "Blood pool",
                icon        = "Blood pool icon",
                level       = 77,
                xp          =  146.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Bloody skulls",
                icon        = "Bloody skulls icon",
                title       = "Bloody skulls (Death)",
                level       = 83,
                xp          = 144,
                trade       = 0,
                members     = true
            }, {
                name        = "Bloody skulls",
                icon        = "Bloody skulls icon",
                title       = "Bloody skulls (Blood)",
                level       = 83,
                xp          = 175.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Living soul",
                icon        = "Living soul icon",
                level       = 90,
                xp          = 213,
                trade       = 0,
                members     = true
            }, {
                name        = "Undead soul",
                icon        = "Undead soul icon",
                title       = "Undead soul (Death)",
                level       = 95,
                xp          = 144,
                trade       = 0,
                members     = true
            }, {
                name        = "Undead soul",
                icon        = "Undead soul icon",
                title       = "Undead soul (Soul)",
                level       = 95,
                xp          = 255.5,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    -- Runecrafting Urns
    if trainMethod == "Urns" then
        local methods = 
        {
            {
                name        = "Cracked runecrafting urn",
                xp          = 1260,
                urns        = false,
                maxLevel    = 9,
                material    = {1, "Cracked runecrafting urn (no rune)", 1, "Pure essence"},
                mcount      = 2,
                trade       = 0,
                members 	= false
            }, {
                name        = "Cracked runecrafting urn",
                title       = "Cracked runecrafting (Urn Enhancer)",
                xp          = 1312.5,
                urns        = false,
                maxLevel    = 9,
                material    = {1, "Cracked runecrafting urn (no rune)", 1, "Pure essence", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members 	= true
                
            }, {
                name        = "Fragile runecrafting urn",
                xp          = 2100,
                urns        = false,
                maxLevel    = 27,
                material    = {1, "Fragile runecrafting urn (no rune)", 1, "Pure essence"},
                mcount      = 2,
                trade       = 0,
                members 	= false
            }, {
                name        = "Fragile runecrafting urn",
                title       = "Fragile runecrafting (Urn Enhancer)",
                xp          = 2187.5,
                urns        = false,
                maxLevel    = 27,
                material    = {1, "Fragile runecrafting urn (no rune)", 1, "Pure essence", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members 	= true
            }, {
                name        = "Plain runecrafting urn",
                xp          = 4200,
                urns        = false,
                maxLevel    = 54,
                material    = {1, "Plain runecrafting urn (no rune)", 1, "Pure essence"},
                mcount      = 2,
                trade       = 0,
                members 	= false
            }, {
                name        = "Plain runecrafting urn",
                title       = "Plain runecrafting (Urn Enhancer)",
                xp          = 4375,
                urns        = false,
                maxLevel    = 54,
                material    = {1, "Plain runecrafting urn (no rune)", 1, "Pure essence", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members 	= true
            }, {
                name        = "Strong runecrafting urn",
                xp          = 6000,
                urns        = false,
                maxLevel    = 77,
                material    = {1, "Strong runecrafting urn (no rune)", 1, "Pure essence"},
                mcount      = 2,
                trade       = 0,
                members 	= true
            }, {
                name        = "Strong runecrafting urn",
                title       = "Strong runecrafting (Urn Enhancer)",
                xp          = 6250,
                urns        = false,
                maxLevel    = 77,
                material    = {1, "Strong runecrafting urn (no rune)", 1, "Pure essence", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members 	= true
            }, {
                name        = "Decorated runecrafting urn",
                xp          = 8400,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated runecrafting urn (no rune)", 1, "Pure essence"},
                mcount      = 2,
                trade       = 0,
                members 	= true
            }, {
                name        = "Decorated runecrafting urn",
                title       = "Decorated runecrafting (Urn Enhancer)",
                xp          = 8750,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated runecrafting urn (no rune)", 1, "Pure essence", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members 	= true
            }, {
                name        = "Exquisite runecrafting urn",
                xp          = 11812.5,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite runecrafting urn (no rune)", 1, "Pure essence"},
                mcount      = 2,
                trade       = 0,
                members 	= true
            }, {
                name        = "Exquisite runecrafting urn",
                title       = "Exquisite runecrafting (Urn Enhancer)",
                xp          = 12403.125,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite runecrafting urn (no rune)", 1, "Pure essence", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members 	= true
            }
        }
        return methods
    end
    
     -- Runecrafting pouches
    if trainMethod == "Pouches" then
        local methods = 
        {
            {
                name        = "Sealed small rune pouch",
                level		= 55,
                xp          = 1500,
                material    = {30, "Magical thread"},
                trade       = 0,
                members 	= true
            }, {
                name        = "Sealed large rune pouch",
                level		= 90,
                xp          = 10000,
                material    = {100, "Magical thread"},
                members 	= true
            }, {
                name        = "Grasping rune pouch",
                title       = "Grasping rune pouch (from bought large pouch)",
                level		= 90,
                xp          = 10000,
                material    = {15, "Magical thread", 2000, "Croesus flakes", 1, "Sealed large rune pouch"},
                mcount		= 3,
                members 	= true
            }, {
                name        = "Grasping rune pouch",
                title       = "Grasping rune pouch (from crafted large pouch)",
                level		= 90,
                xp          = 20000,
                material    = {115, "Magical thread", 2000, "Croesus flakes"},
                mcount		= 2,
                members 	= true
            }
        }
        return methods
    end
    
    --Impure Essence
    if trainMethod == "Necrotic runes" then
        local methods = 
        {
            {
                name        = "Spirit rune",
                level       = 1,
                xp          = 11,
                material    = {1, "Impure essence"},
                members     = true
            }, {
                name        = "Bone rune",
                level       = 20,
                xp          = 15,
                material    = {1, "Impure essence"},
                members     = true
            }, {
                name        = "Flesh rune",
                level       = 40,
                xp          = 17.4,
                material    = {1, "Impure essence"},
                members     = true
            }, {
                name        = "Miasma rune",
                level       = 60,
                xp          = 20,
                material    = {1, "Impure essence"},
                members     = true
            }
        }
        return methods
    end
end