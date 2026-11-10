--[=[
     Notations found in this Module:
        * name:         Name of method
        * icon:         Alternate image location
        * level:        Level required to complete
        * xp:           Experience gained
        * product:      Main output item caught
        * urns:     Indicates whether the item fills urns
        * maxLevel: Highest level of an item an urn can be filled
        * material:     Materials required { #, "Item name", ...}
            - Special case for alternate currencies: {#, value, "Item name", ...}
        * mcount:       Material count - Number of materials required
            - This allows for exclusion of items not found in the GE
        * title:        Alternative name of object
            - Used to clarify the difference from a similar object or offer a cleaner name
        * equipment:    Indicates equipment needed to catch
        * mtrade:       Indicates whether the materials needed can be found in the GE
        * trade:        Indicates whether the product can be found in the GE
        * currency:     Indicates an alternative currency being used
        * value:        Specifies the products value in alternative currency
        * members:      Indicates whether an item is members-only content
--]=]
local skillData = {}

return function(trainMethod)
    if trainMethod == "Popular" then
        local methods = 
        {
            {
                name        = "Raw trout",
                title       = "Trout",
                level       = 20,
                xp          = 50,
                product     = "Raw trout",
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod"
            }, {
                name        = "Raw ghostly sole",
                title       = "Ghostly sole",
                level       = 66,
                xp          = 130,
                product     = "Raw ghostly sole",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw salmon",
                title       = "Salmon",
                level       = 30,
                xp          = 70,
                product     = "Raw salmon",
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod"
            }, {
                name        = "Leaping trout",
                level       = 48,
                xp          = 50,
                product     = "Leaping trout",
                material    = {1, "Feather"},
                equipment   = "Barbarian rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Leaping salmon",
                level       = 58,
                xp          = 70,
                product     = "Leaping salmon",
                material    = {1, "Feather"},
                equipment   = "Barbarian rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw monkfish",
                title       = "Monkfish",
                level       = 62,
                xp          = 120,
                product     = "Raw monkfish",
                equipment   = "Small fishing net",
                members     = true
            }, {
                name        = "Raw green blubber jellyfish",
                title       = "Green blubber jellyfish",
                level       = 68,
                xp          = 165,
                product     = "Raw green blubber jellyfish",
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Leaping sturgeon",
                level       = 70,
                xp          = 80,
                product     = "Leaping sturgeon",
                material    = {1, "Feather"},
                equipment   = "Barbarian rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw shark",
                title       = "Shark",
                level       = 76,
                xp          = 110,
                product     = "Raw shark",
                equipment   = "Harpoon",
                members     = true
            }, {
                name        = "Raw shark",
                title       = "Shark (Sharktooth)",
                level       = 76.1,
                xp          = 115.5,
                product     = "Raw shark",
                equipment   = "Harpoon",
                members     = true
            }, {
                name        = "Raw cavefish",
                title       = "Cavefish",
                level       = 85,
                xp          = 300,
                product     = "Raw cavefish",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw rocktail",
                title       = "Rocktail",
                level       = 90,
                xp          = 380,
                product     = "Raw rocktail",
                material    = {1, "Living minerals"},
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw blue blubber jellyfish",
                title       = "Blue blubber jellyfish",
                level       = 91,
                xp          = 390,
                product     = "Raw blue blubber jellyfish",
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Small crystal urchin",
                level       = 93,
                xp          = 310,
                product     = "Small crystal urchin",
                equipment   = "Fishing rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Medium crystal urchin",
                level       = 95,
                xp          = 330,
                product     = "Medium crystal urchin",
                equipment   = "Fishing rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Large crystal urchin",
                level       = 97,
                xp          = 350,
                product     = "Large crystal urchin",
                equipment   = "Fishing rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw sailfish",
                title       = "Sailfish",
                level       = 97.1,
                xp          = 400,
                product     = "Raw sailfish",
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw sailfish",
                title       = "Sailfish (swift)",
                level       = 97.2,
                xp          = 420,
                product     = "Raw sailfish",
                equipment   = "Fishing rod",
                members     = true
            }
        }
        return methods
    end
    
    if trainMethod == "The Arc" then
        local methods = 
        {
            {
                name        = "Raw tarpon",
                title       = "Tarpon",
                level       = 90,
                xp          = 132.5,
                product     = "Raw tarpon",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw seerfish",
                title       = "Seerfish",
                level       = 91,
                xp          = 145.5,
                product     = "Raw seerfish",
                equipment   = "Big fishing net",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw sillago",
                title       = "Sillago",
                level       = 92,
                xp          = 365,
                product     = "Raw sillago",
                equipment   = "Big fishing net",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw wobbegong",
                title       = "Wobbegong",
                level       = 96,
                xp          = 682.5,
                product     = "Raw wobbegong",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
    
    if trainMethod == "Barbarian" then
        local methods = 
        {
            {
                name        = "Leaping trout",
                level       = 48,
                xp          = 50,
                product     = "Leaping trout",
                material    = {1, "Fishing bait"},
                equipment   = "Barbarian rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Leaping salmon",
                level       = 58,
                xp          = 70,
                product     = "Leaping salmon",
                material    = {1, "Fishing bait"},
                equipment   = "Barbarian rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Leaping sturgeon",
                level       = 70,
                xp          = 80,
                product     = "Leaping sturgeon",
                material    = {1, "Fishing bait"},
                equipment   = "Barbarian rod",
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
    
    if trainMethod == "Deep Sea" then
        local methods =
        {
            {
                name        = "Raw green blubber jellyfish",
                title       = "Green blubber jellyfish",
                level       = 68,
                xp          = 165,
                product     = "Raw green blubber jellyfish",
                equipment   = "Fishing rod",
                members     = true
            },{
                name        = "Raw blue blubber jellyfish",
                title       = "Blue blubber jellyfish",
                level       = 91,
                xp          = 390,
                product     = "Raw blue blubber jellyfish",
                equipment   = "Fishing rod",
                members     = true
            },{
                name        = "Raw sailfish",
                title       = "Sailfish",
                level       = 97,
                xp          = 400,
                product     = "Raw sailfish",
                equipment   = "Fishing rod",
                members     = true
            },{
                name        = "Raw sailfish",
                title       = "Swift sailfish",
                level       = 97,
                xp          = 420,
                product     = "Raw sailfish",
                equipment   = "Fishing rod",
                members     = true
            }
        }
        return methods
    end
    
    if trainMethod == "Dungeoneering" then
        local methods = 
        {
            {
                name        = "Raw heim crab",
                title       = "Heim crab",
                level       = 1,
                xp          = 9,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0
            }, {
                name        = "Raw red-eye",
                title       = "Red-eye",
                level       = 10,
                xp          = 27,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0
            }, {
                name        = "Raw dusk eel",
                title       = "Dusk eel",
                level       = 20,
                xp          = 45,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0
            }, {
                name        = "Raw giant flatfish",
                title       = "Giant flatfish",
                level       = 30,
                xp          = 63,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0
            }, {
                name        = "Raw short-finned eel",
                title       = "Short-finned eel",
                level       = 40,
                xp          = 81,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0
            }, {
                name        = "Raw web snipper",
                title       = "Web snipper",
                level       = 50,
                xp          = 99,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0
            }, {
                name        = "Raw bouldabass",
                title       = "Bouldabass",
                level       = 60,
                xp          = 117,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw salve eel",
                title       = "Salve eel",
                level       = 70,
                xp          = 135,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw blue crab",
                title       = "Blue crab",
                level       = 80,
                xp          = 153,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw cave moray",
                title       = "Cave moray",
                level       = 90,
                xp          = 171,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw vile fish",
                title       = "Vile fish",
                level       = 0,
                xp          = 255,
                urns        = false,
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod",
                trade       = 0
            }
        }
        return methods
    end
    
    if trainMethod == "Urns" then
        local methods = 
        {
            {
                name        = "Cracked fishing urn",
                xp          = 900,
                urns        = false,
                maxLevel    = 10,
                material    = {1, "Cracked fishing urn (no rune)", 1, "Water rune"},
                mcount      = 2,
                trade       = 0
            }, {
                name        = "Cracked fishing urn",
                title		= "Cracked fishing urn (Urn Enhancer)",
                xp          = 937.5,
                urns        = false,
                maxLevel    = 10,
                material    = {1, "Cracked fishing urn (no rune)", 1, "Water rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members     = true
            },{
                name        = "Fragile fishing urn",
                xp          = 2100,
                urns        = false,
                maxLevel    = 30,
                material    = {1, "Fragile fishing urn (no rune)", 1, "Water rune"},
                mcount      = 2,
                trade       = 0
            },{
                name        = "Fragile fishing urn",
                title		= "Fragile fishing urn (Urn Enhancer)",
                xp          = 2187.5,
                urns        = false,
                maxLevel    = 30,
                material    = {1, "Fragile fishing urn (no rune)", 1, "Water rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members     = true
            }, {
                name        = "Plain fishing urn",
                xp          = 3000,
                urns        = false,
                maxLevel    = 50,
                material    = {1, "Plain fishing urn (no rune)", 1, "Water rune"},
                mcount      = 2,
                trade       = 0
            }, {
                name        = "Plain fishing urn",
                title		= "Plain fishing urn (Urn Enhancer)",
                xp          = 3125,
                urns        = false,
                maxLevel    = 50,
                material    = {1, "Plain fishing urn (no rune)", 1, "Water rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members     = true
            },{
                name        = "Strong fishing urn",
                xp          = 3600,
                urns        = false,
                maxLevel    = 70,
                material    = {1, "Strong fishing urn (no rune)", 1, "Water rune"},
                mcount      = 2,
                trade       = 0,
                members     = true
            }, {
                name        = "Strong fishing urn",
                title		= "Strong fishing urn (Urn Enhancer)",
                xp          = 3750,
                urns        = false,
                maxLevel    = 70,
                material    = {1, "Strong fishing urn (no rune)", 1, "Water rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members     = true
            },{
                name        = "Decorated fishing urn",
                xp          = 11400,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated fishing urn (no rune)", 1, "Water rune"},
                mcount      = 2,
                trade       = 0,
                members     = true
            },{
                name        = "Decorated fishing urn",
                title		= "Decorated fishing urn (Urn Enhancer)",
                xp          = 11875,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated fishing urn (no rune)", 1, "Water rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members     = true
            },{
                name        = "Exquisite fishing urn",
                xp          = 16625,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite fishing urn (no rune)", 1, "Water rune"},
                mcount      = 2,
                trade       = 0,
                members     = true
            },{
                name        = "Exquisite fishing urn",
                title		= "Exquisite fishing urn (Urn Enhancer)",
                xp          = 17456.2,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite fishing urn (no rune)", 1, "Water rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
 
    if trainMethod == "Free-to-Play" then
        local methods = 
        {
            {
                name        = "Raw shrimps",
                title       = "Shrimps",
                level       = 1,
                xp          = 10,
                product     = "Raw shrimps",
                equipment   = "Small fishing net"
            }, {
                name        = "Raw crayfish",
                title       = "Crayfish",
                level       = 1,
                xp          = 10,
                product     = "Raw crayfish",
                equipment   = "Crayfish cage"
            }, {
                name        = "Raw minnow",
                title       = "Minnow",
                level       = 1,
                xp          = 10,
                product     = "Raw minnow",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                trade       = 0
            }, {
                name        = "Raw sardine",
                title       = "Sardine",
                level       = 5,
                xp          = 20,
                product     = "Raw sardine",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod"
            }, {
                name        = "Raw herring",
                title       = "Herring",
                level       = 10,
                xp          = 30,
                product     = "Raw herring",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod"
            }, {
                name        = "Raw anchovies",
                title       = "Anchovies",
                level       = 15,
                xp          = 40,
                product     = "Raw anchovies",
                equipment   = "Small fishing net"
            }, {
                name        = "Raw trout",
                title       = "Trout",
                level       = 20,
                xp          = 50,
                product     = "Raw trout",
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod"
            }, {
                name        = "Raw pike",
                title       = "Pike",
                level       = 25,
                xp          = 60,
                product     = "Raw pike",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod"
            }, {
                name        = "Raw salmon",
                title       = "Salmon",
                level       = 30,
                xp          = 70,
                product     = "Raw salmon",
                material    = {1, "Feather"},
                equipment   = "Fly fishing rod"
            }, {
                name        = "Raw tuna",
                title       = "Tuna",
                level       = 35,
                xp          = 80,
                product     = "Raw tuna",
                equipment   = "Harpoon"
            }, {
                name        = "Raw lobster",
                title       = "Lobster",
                level       = 40,
                xp          = 90,
                product     = "Raw lobster",
                equipment   = "Lobster pot"
            }, {
                name        = "Raw swordfish",
                title       = "Swordfish",
                level       = 50,
                xp          = 100,
                product     = "Raw swordfish",
                equipment   = "Harpoon"
            }
        }
        return methods
    end
 
    if trainMethod == "Members" then
        local methods = 
        {
            {
                name        = "Raw karambwanji",
                title       = "Karambwanji",
                level       = 5,
                xp          = 5,
                product     = "Raw karambwanji",
                equipment   = "Small fishing net",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw mackerel",
                title       = "Mackerel",
                level       = 16,
                xp          = 20,
                product     = "Raw mackerel",
                equipment   = "Big fishing net",
                members     = true
            }, {
                name        = "Raw cod",
                title       = "Cod",
                level       = 23,
                xp          = 45,
                product     = "Raw cod",
                equipment   = "Big fishing net",
                members     = true
            }, {
                name        = "Frog spawn",
                level       = 33,
                xp          = 75,
                product     = "Frog spawn",
                equipment   = "Small fishing net",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw rainbow fish",
                title       = "Rainbow fish",
                level       = 38,
                xp          = 80,
                product     = "Raw rainbow fish",
                material    = {1, "Stripy feather"},
                equipment   = "Fly fishing rod",
                members     = true
            }, {
                name        = "Raw cave eel",
                title       = "Cave eel",
                level       = 38,
                xp          = 80,
                product     = "Raw cave eel",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw bass",
                title       = "Bass",
                level       = 46,
                xp          = 100,
                product     = "Raw bass",
                equipment   = "Big fishing net",
                members     = true
            }, {
                name        = "Raw lava eel",
                title       = "Lava eel",
                level       = 53,
                xp          = 30,
                product     = "Raw lava eel",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw monkfish",
                title       = "Monkfish",
                level       = 62,
                xp          = 120,
                product     = "Raw monkfish",
                equipment   = "Small fishing net",
                members     = true
            }, {
                name        = "Raw karambwan",
                title       = "Karambwan",
                level       = 65,
                xp          = 105,
                product     = "Raw karambwan",
                material    = {1, "Raw karambwanji"},
                mtrade      = 0,
                equipment   = "Karambwan vessel",
                members     = true
            }, {
                name        = "Raw shark",
                title       = "Shark",
                level       = 76,
                xp          = 110,
                product     = "Raw shark",
                equipment   = "Harpoon",
                members     = true
            }, {
                name        = "Raw shark",
                title       = "Shark (Sharktooth)",
                level       = 76,
                xp          = 115.5,
                product     = "Raw shark",
                equipment   = "Harpoon",
                members     = true
            }, {
                name        = "Raw sea turtle",
                title       = "Sea turtle",
                level       = 79,
                xp          = 38,
                product     = "Raw sea turtle",
                equipment   = "Bailing bucket",
                members     = true
            }, {
                name        = "Raw great white shark",
                title       = "Great white shark",
                level       = 80,
                xp          = 130,
                product     = "Raw great white shark",
                equipment   = "Harpoon",
                members     = true
            }, {
                name        = "Raw manta ray",
                title       = "Manta ray",
                level       = 81,
                xp          = 200,
                product     = "Raw manta ray",
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw cavefish",
                title       = "Cavefish",
                level       = 85,
                xp          = 300,
                product     = "Raw cavefish",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw rocktail",
                title       = "Rocktail",
                level       = 90,
                xp          = 380,
                product     = "Raw rocktail",
                material    = {1, "Living minerals"},
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw tiger shark",
                title       = "Tiger shark",
                level       = 95,
                xp          = 80,
                product     = "Raw tiger shark",
                equipment   = "Bailing bucket",
                trade       = 0,
                members     = true
            }, {
                name        = "Raw ghostly sole",
                title       = "Ghostly sole",
                level       = 66,
                xp          = 130,
                product     = "Raw ghostly sole",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw baron shark",
                title       = "Baron shark",
                level       = 76,
                xp          = 110,
                product     = "Raw baron shark",
                equipment   = "Harpoon",
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
 
    if trainMethod == "Menaphos" then
        local methods = 
        {
            {
                name        = "Raw desert sole",
                title       = "Desert sole",
                level       = 52,
                xp          = 60,
                product     = "Raw desert sole",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw catfish",
                title       = "Catfish",
                level       = 60,
                xp          = 85,
                product     = "Raw catfish",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                members     = true
            }, {
                name        = "Raw beltfish",
                title       = "Beltfish",
                level       = 72,
                xp          = 92,
                product     = "Raw beltfish",
                material    = {1, "Fishing bait"},
                equipment   = "Fishing rod",
                members     = true
            }
        }
        return methods
    end
    if trainMethod == "Croesus" then
        local methods = 
        {
            {
                name        = "Fungal algae",
                level       = 88,
                xp          = 105,
                product     = "Fungal algae",
                equipment   = "Big fishing net",
                members     = true
            }, {
                name        = "Enriched fungal algae",
                level       = 92,
                xp          = 145,
                product     = "Enriched fungal algae",
                equipment   = "Big fishing net",
                members     = true
            }
        }
        return methods
    end
end