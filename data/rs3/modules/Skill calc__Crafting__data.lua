--[=[
     Notations found in this Module:
        * name:     Name of product
        * icon:      Alternate image location
        * level:    Level required to complete
        * xp:       Experience gained
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
        * materialCost: Specifies the raw materials value in alternative currency
--]=]
local skillData = {}
return function(trainMethod)
    if trainMethod == "Armour" then
        local methods = 
        {
            {
                name         = "Leather gloves",
                level        = 1,
                xp           = 13.8,
                material     = {1, "Leather"},
            }, {
                name         = "Leather boots",
                level        = 1,
                xp           = 16.25,
                material     = {1, "Leather"},
            }, {
                name         = "Leather cowl",
                level        = 1,
                xp           = 18.5,
                material     = {1, "Leather"},
            }, {
                name         = "Leather vambraces",
                level        = 11,
                xp           = 22,
                material     = {1, "Leather"},
            }, {
                name         = "Leather body",
                level        = 1,
                xp           = 25,
                material     = {1, "Leather"},
            }, {
                name         = "Leather chaps",
                level        = 1,
                xp           = 27,
                material     = {1, "Leather"},
            }, {
                name         = "Leather shield",
                level        = 19,
                xp           = 30,
                material     = {1, "Leather"},
                mcount       = 2,
            }, {
                name         = "Hard leather cowl",
                level        = 25,
                xp           = 21,
                material     = {1, "Hard leather", 0.25, "Thread"},
                mcount       = 2,
            }, {
                name         = "Hard leather gloves",
                level        = 25,
                xp           = 32,
                material     = {1, "Hard leather", 0.25, "Thread"},
                mcount       = 2,
            }, {
                name         = "Hard leather boots",
                level        = 27,
                xp           = 34,
                material     = {1, "Hard leather", 0.25, "Thread"},
                mcount       = 2,
            }, {
                name         = "Hard leather body",
                level        = 28,
                xp           = 35,
                material     = {1, "Hard leather", 0.25, "Thread"},
                mcount       = 2,
            }, {
                name         = "Hard leather chaps",
                level        = 28,
                xp           = 35,
                material     = {1, "Hard leather", 0.25, "Thread"},
                mcount       = 2,
            }, {
                name         = "Hard leather shield",
                level        = 29,
                xp           = 36,
                material     = {1, "Hard leather", 0.25, "Thread"},
                mcount       = 2,
            }, {
                name         = "Studded leather coif",
                level        = 38,
                xp           = 37,
                material     = {1, "Leather", 1, "Steel studs"},
                mcount       = 2,
            }, {
                name         = "Studded body",
                level        = 41,
                xp           = 40,
                material     = {1, "Leather body", 1, "Steel studs"},
                mcount       = 2,
            }, {
                name         = "Studded leather gloves",
                level        = 42,
                xp           = 40,
                material     = {1, "Leather gloves", 1, "Steel studs"},
                mcount       = 2,
            }, {
                name         = "Studded leather boots",
                level        = 43,
                xp           = 40,
                material     = {1, "Leather boots", 1, "Steel studs"},
                mcount       = 2,
            }, {
                name         = "Studded chaps",
                level        = 44,
                xp           = 42,
                material     = {1, "Leather chaps", 1, "Steel studs"},
                mcount       = 2,
            }, {
                name         = "Studded leather shield",
                level        = 45,
                xp           = 43,
                material     = {1, "Leather shield", 1, "Steel studs"},
                mcount       = 2,
            }, {
                name         = "Carapace gloves",
                level        = 30,
                xp           = 12,
                material     = {1, "Carapace", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Carapace boots",
                level        = 31,
                xp           = 12,
                material     = {1, "Carapace", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Carapace helm",
                level        = 33,
                xp           = 24,
                material     = {2, "Carapace", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Carapace legs",
                level        = 34,
                xp           = 24,
                material     = {2, "Carapace", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Carapace torso",
                level        = 35,
                xp           = 36,
                material     = {3, "Carapace", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Carapace shield",
                level        = 36,
                xp           = 36,
                material     = {3, "Carapace", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Snakeskin boots",
                level        = 45,
                xp           = 30,
                material     = {6, "Snakeskin", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Snakeskin vambraces",
                level        = 47,
                xp           = 35,
                material     = {8, "Snakeskin", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Snakeskin bandana",
                level        = 48,
                xp           = 45,
                material     = {5, "Snakeskin", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Snakeskin chaps",
                level        = 51,
                xp           = 50,
                material     = {12, "Snakeskin", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Snakeskin body",
                level        = 53,
                xp           = 55,
                material     = {15, "Snakeskin", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Green dragonhide vambraces",
                level        = 40,
                xp           = 62,
                material     = {1, "Green dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Green dragonhide boots",
                level        = 40,
                xp           = 62,
                material     = {1, "Green dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Green dragonhide chaps",
                level        = 40,
                xp           = 124,
                material     = {2, "Green dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Green dragonhide coif",
                level        = 40,
                xp           = 124,
                material     = {2, "Green dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Green dragonhide body",
                level        = 40,
                xp           = 186,
                material     = {3, "Green dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Green dragonhide shield",
                level        = 40,
                xp           = 248,
                material     = {4, "Green dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Blue dragonhide vambraces",
                level        = 50,
                xp           = 70,
                material     = {1, "Blue dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Blue dragonhide boots",
                level        = 50,
                xp           = 70,
                material     = {1, "Blue dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Blue dragonhide chaps",
                level        = 50,
                xp           = 140,
                material     = {2, "Blue dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Blue dragonhide coif",
                level        = 50,
                xp           = 140,
                material     = {2, "Blue dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Blue dragonhide body",
                level        = 50,
                xp           = 210,
                material     = {3, "Blue dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Blue dragonhide shield",
                level        = 50,
                xp           = 280,
                material     = {4, "Blue dragon leather", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Red dragonhide vambraces",
                level        = 55,
                xp           = 78,
                material     = {1, "Red dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Red dragonhide boots",
                level        = 55,
                xp           = 78,
                material     = {1, "Red dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Red dragonhide chaps",
                level        = 55,
                xp           = 156,
                material     = {2, "Red dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Red dragonhide coif",
                level        = 55,
                xp           = 156,
                material     = {2, "Red dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Red dragonhide body",
                level        = 55,
                xp           = 234,
                material     = {3, "Red dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Red dragonhide shield",
                level        = 55,
                xp           = 312,
                material     = {4, "Red dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Black dragonhide vambraces",
                level        = 60,
                xp           = 86,
                material     = {1, "Black dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Black dragonhide boots",
                level        = 60,
                xp           = 86,
                material     = {1, "Black dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Black dragonhide chaps",
                level        = 60,
                xp           = 172,
                material     = {2, "Black dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Black dragonhide coif",
                level        = 60,
                xp           = 172,
                material     = {2, "Black dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Black dragonhide body",
                level        = 60,
                xp           = 258,
                material     = {3, "Black dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Black dragonhide shield",
                level        = 60,
                xp           = 344,
                material     = {4, "Black dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Royal dragonhide vambraces",
                level        = 65,
                xp           = 94,
                material     = {1, "Royal dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Royal dragonhide boots",
                level        = 65,
                xp           = 94,
                material     = {1, "Royal dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Royal dragonhide chaps",
                level        = 65,
                xp           = 188,
                material     = {2, "Royal dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Royal dragonhide coif",
                level        = 65,
                xp           = 188,
                material     = {2, "Royal dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Royal dragonhide body",
                level        = 65,
                xp           = 282,
                material     = {3, "Royal dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Undead dragonhide vambraces",
                level        = 75,
                xp           = 102,
                material     = {1, "Undead dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Undead dragonhide boots",
                level        = 75,
                xp           = 102,
                material     = {1, "Undead dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Undead dragonhide chaps",
                level        = 75,
                xp           = 204,
                material     = {2, "Undead dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Undead dragonhide coif",
                level        = 75,
                xp           = 204,
                material     = {2, "Undead dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Undead dragonhide body",
                level        = 75,
                xp           = 306,
                material     = {3, "Undead dragon leather", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Spiky vambraces",
                level        = 32,
                xp           = 5.8,
                material     = {1, "Leather vambraces", 1, "Kebbit claws"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Green spiky vambraces",
                level        = 32,
                xp           = 5.8,
                material     = {1, "Green dragonhide vambraces", 1, "Kebbit claws"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Blue spiky vambraces",
                level        = 32,
                xp           = 5.8,
                material     = {1, "Blue dragonhide vambraces", 1, "Kebbit claws"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Red spiky vambraces",
                level        = 32,
                xp           = 5.8,
                material     = {1, "Red dragonhide vambraces", 1, "Kebbit claws"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Black spiky vambraces",
                level        = 32,
                xp           = 5.8,
                material     = {1, "Black dragonhide vambraces", 1, "Kebbit claws"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Royal spiky vambraces",
                level        = 32,
                xp           = 5.8,
                material     = {1, "Royal dragonhide vambraces", 1, "Kebbit claws"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Sirenic mask",
                level        = 91,
                xp           = 500,
                material     = {14, "Sirenic scale", 1, "Algarum thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Sirenic chaps",
                level        = 92,
                xp           = 1000,
                material     = {28, "Sirenic scale", 2, "Algarum thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Sirenic hauberk",
                level        = 93,
                xp           = 1500,
                material     = {42, "Sirenic scale", 3, "Algarum thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Wizard gloves",
                level        = 1,
                xp           = 5,
                material     = {1, "Strip of cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Black wizard gloves",
                level        = 1,
                xp           = 5,
                material     = {1, "Strip of black cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Wizard boots",
                level        = 2,
                xp           = 5,
                material     = {1, "Strip of cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Black wizard boots",
                level        = 2,
                xp           = 5,
                material     = {1, "Strip of black cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Wizard hat",
                level        = 3,
                xp           = 5,
                material     = {1, "Strip of cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Black wizard hat",
                level        = 3,
                xp           = 5,
                material     = {1, "Strip of black cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Wizard robe skirt",
                level        = 4,
                xp           = 10,
                material     = {2, "Strip of cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Black wizard robe skirt",
                level        = 4,
                xp           = 10,
                material     = {2, "Strip of black cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Wizard robe top",
                level        = 5,
                xp           = 10,
                material     = {2, "Strip of cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Black wizard robe top",
                level        = 5,
                xp           = 10,
                material     = {2, "Strip of black cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Wizard book",
                level        = 6,
                xp           = 15,
                material     = {3, "Strip of cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Wizard wand",
                level        = 7,
                xp           = 15,
                material     = {3, "Strip of cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Wizard shield",
                level        = 8,
                xp           = 15,
                material     = {3, "Strip of cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Black wizard shield",
                level        = 8,
                xp           = 15,
                material     = {3, "Strip of black cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Imphide gloves",
                level        = 10,
                xp           = 10,
                material     = {1, "Imphide", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Imphide boots",
                level        = 11,
                xp           = 10,
                material     = {1, "Imphide", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Imphide hood",
                level        = 12,
                xp           = 20,
                material     = {2, "Imphide", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Imphide robe bottom",
                level        = 13,
                xp           = 20,
                material     = {2, "Imphide", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Imphide robe top",
                level        = 14,
                xp           = 30,
                material     = {3, "Imphide", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Imphide book",
                level        = 15,
                xp           = 30,
                material     = {3, "Imphide", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Imp horn wand",
                level        = 16,
                xp           = 30,
                material     = {3, "Imphide", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Imphide shield",
                level        = 17,
                xp           = 40,
                material     = {4, "Imphide", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Spider silk gloves",
                level        = 20,
                xp           = 12.5,
                material     = {1, "Spider silk", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Spider silk boots",
                level        = 21,
                xp           = 12.5,
                material     = {1, "Spider silk", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Spider silk hood",
                level        = 22,
                xp           = 25,
                material     = {2, "Spider silk", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Spider silk robe bottom",
                level        = 23,
                xp           = 25,
                material     = {2, "Spider silk", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Spider silk robe top",
                level        = 24,
                xp           = 37.5,
                material     = {3, "Spider silk", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Spider orb",
                level        = 25,
                xp           = 25,
                material     = {2, "Spider silk", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Spider wand",
                level        = 26,
                xp           = 25,
                material     = {2, "Spider silk", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Spider silk shield",
                level        = 27,
                xp           = 37.5,
                material     = {3, "Spider silk", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Batwing gloves",
                level        = 30,
                xp           = 12,
                material     = {1, "Batwing", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Batwing boots",
                level        = 31,
                xp           = 12,
                material     = {1, "Batwing", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Batwing hood",
                level        = 33,
                xp           = 24,
                material     = {2, "Batwing", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Batwing legs",
                level        = 34,
                xp           = 24,
                material     = {2, "Batwing", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Batwing torso",
                level        = 35,
                xp           = 36,
                material     = {3, "Batwing", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Batwing book",
                level        = 36,
                xp           = 24,
                material     = {2, "Batwing", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Batwing wand",
                level        = 37,
                xp           = 24,
                material     = {2, "Batwing", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Batwing shield",
                level        = 38,
                xp           = 36,
                material     = {3, "Batwing", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Mystic boots",
                level        = 51,
                xp           = 14,
                material     = {1, "Mystic cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Mystic gloves",
                level        = 52,
                xp           = 14,
                material     = {1, "Mystic cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Mystic hat",
                level        = 53,
                xp           = 28,
                material     = {2, "Mystic cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Mystic robe bottom",
                level        = 54,
                xp           = 28,
                material     = {2, "Mystic cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Mystic robe top",
                level        = 55,
                xp           = 42,
                material     = {3, "Mystic cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Mystic orb",
                level        = 56,
                xp           = 24,
                material     = {2, "Mystic cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Mystic wand",
                level        = 57,
                xp           = 28,
                material     = {2, "Mystic cloth", 1, "Logs", 0.2, "Thread"},
                mcount       = 3,
            }, {
                name         = "Mystic shield",
                level        = 58,
                xp           = 42,
                material     = {3, "Mystic cloth", 0.2, "Thread"},
                mcount       = 2,
            }, {
                name         = "Fungal visor",
                level        = 25,
                xp           = 15,
                material     = {1, "Mycelium visor web", 300, "Fungal flake"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Fungal leggings",
                level        = 25,
                xp           = 50,
                material     = {1, "Mycelium leggings web", 1000, "Fungal flake"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Fungal poncho",
                level        = 25,
                xp           = 125,
                material     = {1, "Mycelium poncho web", 2500, "Fungal flake"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Grifolic visor",
                level        = 60,
                xp           = 40,
                material     = {1, "Mycelium visor web", 400, "Grifolic flake"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Grifolic leggings",
                level        = 60,
                xp           = 120,
                material     = {1, "Mycelium leggings web", 1200, "Grifolic flake"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Grifolic poncho",
                level        = 60,
                xp           = 350,
                material     = {1, "Mycelium poncho web", 3500, "Grifolic flake"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Ganodermic visor",
                level        = 75,
                xp           = 100,
                material     = {1, "Mycelium visor web", 500, "Ganodermic flake"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Ganodermic leggings",
                level        = 75,
                xp           = 300,
                material     = {1, "Mycelium leggings web", 1500, "Ganodermic flake"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Ganodermic poncho",
                level        = 75,
                xp           = 1000,
                material     = {1, "Mycelium poncho web", 5000, "Ganodermic flake"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Yak-hide armour (legs)",
                level        = 43,
                xp           = 32,
                material     = {1, "Cured yak-hide", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Yak-hide armour (top)",
                level        = 46,
                xp           = 32,
                material     = {2, "Cured yak-hide", 0.2, "Thread"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Fremennik round shield",
                level        = 46,
                xp           = 34,
                material     = {2, "Arctic pine logs", 1, "Rope", 1, "Bronze nails"},
                mcount       = 3,
                members      = true
            }
        }
        return methods
    end

    -- Battlestaves
    if trainMethod == "Battlestaves" then
        local methods = 
        {
            {
                name         = "Water battlestaff",
                level        = 54,
                xp           = 100,
                material     = {1, "Battlestaff", 1, "Water orb"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Earth battlestaff",
                level        = 58,
                xp           = 112.5,
                material     = {1, "Battlestaff", 1, "Earth orb"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Fire battlestaff",
                level        = 62,
                xp           = 125,
                material     = {1, "Battlestaff", 1, "Fire orb"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Air battlestaff",
                level        = 66,
                xp           = 137.5,
                material     = {1, "Battlestaff", 1, "Air orb"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Armadyl battlestaff",
                level        = 77,
                xp           = 150,
                material     = {1, "Battlestaff", 1, "Orb of Armadyl"},
                members      = true
            }, {
                name         = "Skeletal staff of air",
                level        = 85,
                xp           = 130,
                material     = {1, "Staff of air", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal staff of earth",
                level        = 85,
                xp           = 130,
                material     = {1, "Staff of earth", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal staff of fire",
                level        = 85,
                xp           = 130,
                material     = {1, "Staff of fire", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal staff of water",
                level        = 85,
                xp           = 130,
                material     = {1, "Staff of water", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal battlestaff of air",
                level        = 85,
                xp           = 130,
                material     = {1, "Air battlestaff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal battlestaff of earth",
                level        = 85,
                xp           = 130,
                material     = {1, "Earth battlestaff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal battlestaff of fire",
                level        = 85,
                xp           = 130,
                material     = {1, "Fire battlestaff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal lava battlestaff",
                level        = 85,
                xp           = 130,
                material     = {1, "Lava battlestaff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal mud battlestaff",
                level        = 85,
                xp           = 130,
                material     = {1, "Mud battlestaff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal steam battlestaff",
                level        = 85,
                xp           = 130,
                material     = {1, "Steam battlestaff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Skeletal battlestaff of water",
                level        = 85,
                xp           = 130,
                material     = {1, "Water battlestaff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Necromancer's air staff",
                level        = 85,
                xp           = 130,
                material     = {1, "Mystic air staff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Necromancer's earth staff",
                level        = 85,
                xp           = 130,
                material     = {1, "Mystic earth staff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Necromancer's fire staff",
                level        = 85,
                xp           = 130,
                material     = {1, "Mystic fire staff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Necromancer's lava staff",
                level        = 85,
                xp           = 130,
                material     = {1, "Mystic lava staff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Necromancer's mud staff",
                level        = 85,
                xp           = 130,
                material     = {1, "Mystic mud staff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Necromancer's steam staff",
                level        = 85,
                xp           = 130,
                material     = {1, "Mystic steam staff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }, {
                name         = "Necromancer's water staff",
                level        = 85,
                xp           = 130,
                material     = {1, "Mystic water staff", 1, "Shade skull"},
                trade        = 0,
                members      = true
            }
        }
        return methods
    end

    -- Cutting gems
    if trainMethod == "Cutting gems" then
        local methods = 
        {
            {
                name         = "Opal",
                level        = 1,
                xp           = 15,
                material     = {1, "Uncut opal"},
            }, {
                name         = "Lapis lazuli gem",
                level        = 1,
                xp           = 20,
                material     = {1, "Uncut lapis lazuli"},
                mtrade       = 0,
                trade        = 0,
            }, {
                name         = "Jade",
                level        = 13,
                xp           = 20,
                material     = {1, "Uncut jade"},
            }, {
                name         = "Red topaz",
                level        = 16,
                xp           = 25,
                material     = {1, "Uncut red topaz"},
            }, {
                name         = "Sapphire",
                level        = 20,
                xp           = 50,
                material     = {1, "Uncut sapphire"},
            }, {
                name         = "Emerald",
                level        = 27,
                xp           = 67.5,
                material     = {1, "Uncut emerald"},
            }, {
                name         = "Ruby",
                level        = 34,
                xp           = 85,
                material     = {1, "Uncut ruby"},
            }, {
                name         = "Diamond",
                level        = 43,
                xp           = 107.5,
                material     = {1, "Uncut diamond"},
            }, {
                name         = "Dragonstone",
                level        = 55,
                xp           = 137.5,
                material     = {1, "Uncut dragonstone"},
                members      = true
            }, {
                name         = "Moonstone",
                level        = 67,
                xp           = 167.5,
                material     = {1, "Uncut moonstone"},
                members      = true
            }, {
                name         = "Onyx",
                level        = 72,
                xp           = 180,
                material     = {1, "Uncut onyx"},
                members      = true
            }, {
                name         = "Hydrix",
                level        = 79,
                xp           = 197.5,
                material     = {1, "Uncut hydrix"},
                members      = true
            }
        }
        return methods
    end

    -- Jewellery
    if trainMethod == "Jewellery" then
        local methods = 
        {
            {
                -- Marked as "Members only" ingame, but materials aren't..
                name         = "Lapis lazuli brooch",
                level        = 1,
                xp           = 30,
                material     = {1, "Unfinished wooden brooch", 1, "Lapis lazuli gem"},
                mtrade       = 0,
                trade        = 0
            }, {
                name         = "Opal ring",
                level        = 1,
                xp           = 10,
                material     = {1, "Opal", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Gold ring",
                level        = 5,
                xp           = 15,
                material     = {1, "Gold bar"}
            }, {
                name         = "Gold necklace",
                level        = 6,
                xp           = 20,
                material     = {1, "Gold bar"},
            }, {
                name         = "Gold bracelet",
                level        = 7,
                xp           = 25,
                material     = {1, "Gold bar"},
            }, {
                name         = "Gold amulet (unstrung)",
                level        = 8,
                xp           = 30,
                material     = {1, "Gold bar"},
            }, {
                name         = "Gold amulet",
                level        = 8,
                xp           = 34,
                material     = {1, "Gold bar", 1, "Ball of wool"},
                mcount       = 2,
            }, {
                name         = "Lapis lazuli ring",
                title        = "Lapis ring",
                level        = 11,
                xp           = 38,
                material     = {1, "Silver bar", 1, "Lapis lazuli gem"},
                mcount       = 2,
                mtrade       = 0,
                trade        = 0
            }, {
                name         = "Jade ring",
                level        = 13,
                xp           = 13,
                material     = {1, "Jade", 1, "Silver bar"},
                mcount       = 2,
                mcount       = 0,
                members      = true
            }, {
                name         = "Unstrung symbol",
                level        = 16,
                xp           = 50,
                material     = {1, "Silver bar"},
            }, {
                name         = "Unblessed symbol",
                level        = 16,
                xp           = 54,
                material     = {1, "Silver bar", 1, "Ball of wool"},
                mcount       = 2,
            }, {
                name         = "Topaz ring",
                level        = 16,
                xp           = 15,
                material     = {1, "Red topaz", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Opal necklace",
                level        = 16,
                xp           = 11.5,
                material     = {1, "Opal", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Conductor",
                level        = 20,
                xp           = 50,
                material     = {1, "Silver bar"},
                trade        = 0,
                members      = true
            }, {
                name         = "Unstrung emblem",
                level        = 17,
                xp           = 50,
                material     = {1, "Silver bar"},
                members      = true
            }, {
                name         = "Unpowered symbol",
                level        = 17,
                xp           = 54,
                material     = {1, "Silver bar", 1, "Ball of wool"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Silver sickle",
                level        = 18,
                xp           = 50,
                material     = {1, "Silver bar"},
                members      = true
            }, {
                name         = "Sapphire ring",
                level        = 20,
                xp           = 40,
                material     = {1, "Sapphire", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Silver bolts (unf)",
                level        = 21,
                xp           = 50,
                material     = {1, "Silver bar"},
            }, {
                name         = "Sapphire necklace",
                level        = 22,
                xp           = 55,
                material     = {1, "Sapphire", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Opal bracelet",
                level        = 22,
                xp           = 12.5,
                material     = {1, "Opal", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Tiara",
                level        = 23,
                xp           = 52.5,
                material     = {1, "Silver bar"},
            }, {
                name         = "Sapphire bracelet",
                level        = 23,
                xp           = 60,
                material     = {1, "Sapphire", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Sapphire amulet (unstrung)",
                level        = 24,
                xp           = 65,
                material     = {1, "Sapphire", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Sapphire amulet",
                level        = 24,
                xp           = 69,
                material     = {1, "Sapphire", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
            }, {
                name         = "Jade necklace",
                level        = 25,
                xp           = 25,
                material     = {1, "Jade", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Emerald ring",
                level        = 27,
                xp           = 55,
                material     = {1, "Emerald", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Opal amulet (unstrung)",
                level        = 27,
                xp           = 15,
                material     = {1, "Opal", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Opal amulet",
                level        = 27,
                xp           = 17.5,
                material     = {1, "Opal", 1, "Silver bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Emerald necklace",
                level        = 29,
                xp           = 60,
                material     = {1, "Emerald", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Jade bracelet",
                level        = 29,
                xp           = 17,
                material     = {1, "Jade", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Emerald bracelet",
                level        = 30,
                xp           = 65,
                material     = {1, "Emerald", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Emerald amulet (unstrung)",
                level        = 31,
                xp           = 70,
                material     = {1, "Emerald", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Emerald amulet",
                level        = 31,
                xp           = 74,
                material     = {1, "Emerald", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
            }, {
                name         = "Topaz necklace",
                level        = 32,
                xp           = 20,
                material     = {1, "Red topaz", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Ruby ring",
                level        = 34,
                xp           = 70,
                material     = {1, "Ruby", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Jade amulet (unstrung)",
                level        = 34,
                xp           = 20,
                material     = {1, "Jade", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Jade amulet",
                level        = 34,
                xp           = 22.5,
                material     = {1, "Jade", 1, "Silver bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Topaz bracelet",
                level        = 38,
                xp           = 25,
                material     = {1, "Red topaz", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Ruby necklace",
                level        = 40,
                xp           = 75,
                material     = {1, "Ruby", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Ruby bracelet",
                level        = 42,
                xp           = 80,
                material     = {1, "Ruby", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Diamond ring",
                level        = 43,
                xp           = 85,
                material     = {1, "Diamond", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Topaz amulet (unstrung)",
                level        = 45,
                xp           = 30,
                material     = {1, "Red topaz", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Topaz amulet",
                level        = 45,
                xp           = 32.5,
                material     = {1, "Red topaz", 1, "Silver bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Ruby amulet (unstrung)",
                level        = 50,
                xp           = 85,
                material     = {1, "Ruby", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Ruby amulet",
                level        = 50,
                xp           = 89,
                material     = {1, "Ruby", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
            }, {
                name         = "Dragonstone ring",
                level        = 55,
                xp           = 100,
                material     = {1, "Dragonstone", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Diamond necklace",
                level        = 56,
                xp           = 90,
                material     = {1, "Diamond", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Diamond bracelet",
                level        = 58,
                xp           = 95,
                material     = {1, "Diamond", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Moonstone ring",
                level        = 67,
                xp           = 130,
                material     = {1, "Moonstone", 1, "Ensouled bar"},
                mcount       = 2,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Diamond amulet (unstrung)",
                level        = 70,
                xp           = 100,
                material     = {1, "Diamond", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Diamond amulet",
                level        = 70,
                xp           = 104,
                material     = {1, "Diamond", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
            }, {
                name         = "Onyx ring",
                level        = 72,
                xp           = 115,
                material     = {1, "Onyx", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Dragonstone necklace",
                level        = 72,
                xp           = 105,
                material     = {1, "Dragonstone", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Dragonstone bracelet",
                level        = 74,
                xp           = 110,
                material     = {1, "Dragonstone", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Ring of slaying",
                level        = 75,
                xp           = 15,
                material     = {1, "Gold bar", 1, "Enchanted gem"},
                trade        = 0,
                members      = true
            }, {
                name         = "Harmonic dust",
                level        = 75,
                xp           = 80,
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Moonstone necklace",
                level        = 77,
                xp           = 135,
                material     = {1, "Moonstone", 1, "Ensouled bar"},
                mcount       = 2,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Moonstone bracelet",
                level        = 79,
                xp           = 140,
                material     = {1, "Moonstone", 1, "Ensouled bar"},
                mcount       = 2,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Hydrix ring",
                level        = 79,
                xp           = 130,
                material     = {1, "Hydrix", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Dragonstone amulet (unstrung)",
                level        = 80,
                xp           = 150,
                material     = {1, "Dragonstone", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Dragonstone amulet",
                level        = 80,
                xp           = 154,
                material     = {1, "Dragonstone", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Onyx necklace",
                level        = 82,
                xp           = 120,
                material     = {1, "Onyx", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Onyx bracelet",
                level        = 84,
                xp           = 125,
                material     = {1, "Onyx", 1, "Gold bar"},
                mcount       = 2
            }, {
                name         = "Moonstone amulet (unstrung)",
                level        = 85,
                xp           = 145,
                material     = {1, "Moonstone", 1, "Ensouled bar"},
                mcount       = 2,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Moonstone amulet",
                level        = 85,
                xp           = 149,
                material     = {1, "Moonstone", 1, "Ensouled bar", 1, "Ball of wool"},
                mcount       = 3,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Onyx amulet (unstrung)",
                level        = 90,
                xp           = 165,
                material     = {1, "Onyx", 1, "Gold bar"},
                mcount       = 2,
                trade        = 0
            }, {
                name         = "Onyx amulet",
                level        = 90,
                xp           = 169,
                material     = {1, "Onyx", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3
            }, {
                name         = "Hydrix necklace",
                level        = 90,
                xp           = 135,
                material     = {1, "Hydrix", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Shark's tooth necklace",
                level        = 91,
                xp           = 170,
                material     = {0.225, "Thread", 5, "Shark's tooth"},
                trade        = 0,
                members      = true
            }, {
                name         = "Alchemical onyx ring",
                level        = 91,
                xp           = 4115,
                material     = {1, "Alchemical onyx", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Alchemical onyx necklace",
                level        = 91,
                xp           = 4115,
                material     = {1, "Alchemical onyx", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Hydrix bracelet",
                level        = 94,
                xp           = 140,
                material     = {1, "Hydrix", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Hydrix amulet (unstrung)",
                level        = 99,
                xp           = 180,
                material     = {1, "Hydrix", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Hydrix amulet",
                level        = 99,
                xp           = 184,
                material     = {1, "Hydrix", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Lapis lazuli brooch",
				title        = "Lapis lazuli brooch (from uncut)",
                level        = 1,
                xp           = 50,
                material     = {1, "Unfinished wooden brooch", 1, "Uncut lapis lazuli"},
                mtrade       = 0,
                trade        = 0
            }, {
                name         = "Opal ring",
				title        = "Opal ring (from uncut)",
                level        = 1,
                xp           = 25,
                material     = {1, "Uncut opal", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Lapis lazuli ring",
                title        = "Lapis ring (from uncut)",
                level        = 11,
                xp           = 58,
                material     = {1, "Silver bar", 1, "Uncut lapis lazuli"},
                mcount       = 2,
                mtrade       = 0,
                trade        = 0
            }, {
                name         = "Jade ring",
				title        = "Jade ring (from uncut)",
                level        = 13,
                xp           = 33,
                material     = {1, "Uncut jade", 1, "Silver bar"},
                mcount       = 2,
                mcount       = 0,
                members      = true
            }, {
                name         = "Topaz ring",
				title        = "Topaz ring (from uncut)",
                level        = 16,
                xp           = 40,
                material     = {1, "Uncut red topaz", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Opal necklace",
				title        = "Opal necklace (from uncut)",
                level        = 16,
                xp           = 26.5,
                material     = {1, "Uncut opal", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Sapphire ring",
				title        = "Sapphire ring (from uncut)",
                level        = 20,
                xp           = 90,
                material     = {1, "Uncut sapphire", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Sapphire necklace",
				title        = "Sapphire necklace (from uncut)",
                level        = 22,
                xp           = 105,
                material     = {1, "Uncut sapphire", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Opal bracelet",
				title        = "Opal bracelet (from uncut)",
                level        = 22,
                xp           = 27.5,
                material     = {1, "Uncut opal", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Sapphire bracelet",
				title        = "Sapphire bracelet (from uncut)",
                level        = 23,
                xp           = 110,
                material     = {1, "Uncut sapphire", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Sapphire amulet (unstrung)",
				title        = "Sapphire amulet (unstrung, from uncut)",
                level        = 24,
                xp           = 115,
                material     = {1, "Uncut sapphire", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Sapphire amulet",
				title        = "Sapphire amulet (from uncut)",
                level        = 24,
                xp           = 119,
                material     = {1, "Uncut sapphire", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
            }, {
                name         = "Jade necklace",
				title        = "Jade necklace (from uncut)",
                level        = 25,
                xp           = 45,
                material     = {1, "Uncut jade", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Emerald ring",
				title        = "Emerald ring (from uncut)",
                level        = 27,
                xp           = 122.5,
                material     = {1, "Uncut emerald", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Opal amulet (unstrung)",
				title        = "Opal amulet (unstrung, from uncut)",
                level        = 27,
                xp           = 30,
                material     = {1, "Uncut opal", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Opal amulet",
				title        = "Opal amulet (from uncut)",
                level        = 27,
                xp           = 32.5,
                material     = {1, "Opal", 1, "Silver bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Emerald necklace",
				title        = "Emerald necklace (from uncut)",
                level        = 29,
                xp           = 127.5,
                material     = {1, "Uncut emerald", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Jade bracelet",
				title        = "Jade bracelet (from uncut)",
                level        = 29,
                xp           = 32,
                material     = {1, "Uncut jade", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Emerald bracelet",
				title        = "Emerald bracelet (from uncut)",
                level        = 30,
                xp           = 132.5,
                material     = {1, "Uncut emerald", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Emerald amulet (unstrung)",
				title        = "Emerald amulet (unstrung, from uncut)",
                level        = 31,
                xp           = 137.5,
                material     = {1, "Uncut emerald", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Emerald amulet",
				title        = "Emerald amulet (from uncut)",
                level        = 31,
                xp           = 141.5,
                material     = {1, "Uncut emerald", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
            }, {
                name         = "Topaz necklace",
				title        = "Topaz necklace (from uncut)",
                level        = 32,
                xp           = 45,
                material     = {1, "Uncut red topaz", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Ruby ring",
				title        = "Ruby ring (from uncut)",
                level        = 34,
                xp           = 155,
                material     = {1, "Uncut ruby", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Jade amulet (unstrung)",
				title        = "Jade amulet (unstrung, from uncut)",
                level        = 34,
                xp           = 45,
                material     = {1, "Uncut jade", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Jade amulet",
				title        = "Jade amulet (from uncut)",
                level        = 34,
                xp           = 42.5,
                material     = {1, "Uncut jade", 1, "Silver bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Topaz bracelet",
				title        = "Topaz bracelet (from uncut)",
                level        = 38,
                xp           = 50,
                material     = {1, "Uncut red topaz", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Ruby necklace",
				title        = "Ruby necklace (from uncut)",
                level        = 40,
                xp           = 160,
                material     = {1, "Uncut ruby", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Ruby bracelet",
				title        = "Ruby bracelet (from uncut)",
                level        = 42,
                xp           = 165,
                material     = {1, "Uncut ruby", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Diamond ring",
				title        = "Diamond ring (from uncut)",
                level        = 43,
                xp           = 192.5,
                material     = {1, "Uncut diamond", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Topaz amulet (unstrung)",
				title        = "Topaz amulet (unstrung, from uncut)",
                level        = 45,
                xp           = 55,
                material     = {1, "Uncut red topaz", 1, "Silver bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Topaz amulet",
				title        = "Topaz amulet (from uncut)",
                level        = 45,
                xp           = 57.5,
                material     = {1, "Uncut red topaz", 1, "Silver bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Ruby amulet (unstrung)",
				title        = "Ruby amulet (unstrung, from uncut)",
                level        = 50,
                xp           = 170,
                material     = {1, "Uncut ruby", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Ruby amulet",
				title        = "Ruby amulet (from uncut)",
                level        = 50,
                xp           = 174,
                material     = {1, "Uncut ruby", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
            }, {
                name         = "Dragonstone ring",
				title        = "Dragonstone ring (from uncut)",
                level        = 55,
                xp           = 237.5,
                material     = {1, "Uncut dragonstone", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Diamond necklace",
				title        = "Diamond necklace (from uncut)",
                level        = 56,
                xp           = 197.5,
                material     = {1, "Uncut diamond", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Diamond bracelet",
				title        = "Diamond bracelet (from uncut)",
                level        = 58,
                xp           = 202.5,
                material     = {1, "Uncut diamond", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Moonstone ring",
				title        = "Moonstone ring (from uncut)",
                level        = 67,
                xp           = 297.5,
                material     = {1, "Uncut moonstone", 1, "Ensouled bar"},
                mcount       = 2,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Diamond amulet (unstrung)",
				title        = "Diamond amulet (unstrung, from uncut)",
                level        = 70,
                xp           = 207.5,
                material     = {1, "Uncut diamond", 1, "Gold bar"},
                mcount       = 2,
            }, {
                name         = "Diamond amulet",
				title        = "Diamond amulet (from uncut)",
                level        = 70,
                xp           = 211.5,
                material     = {1, "Uncut diamond", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
            }, {
                name         = "Onyx ring",
				title        = "Onyx ring (from uncut)",
                level        = 72,
                xp           = 282.5,
                material     = {1, "Uncut onyx", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Dragonstone necklace",
				title        = "Dragonstone necklace (from uncut)",
                level        = 72,
                xp           = 242.5,
                material     = {1, "Uncut dragonstone", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Dragonstone bracelet",
				title        = "Dragonstone bracelet (from uncut)",
                level        = 74,
                xp           = 247.5,
                material     = {1, "Uncut dragonstone", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Moonstone necklace",
				title        = "Moonstone necklace (from uncut)",
                level        = 77,
                xp           = 302.5,
                material     = {1, "Uncut moonstone", 1, "Ensouled bar"},
                mcount       = 2,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Moonstone bracelet",
				title        = "Moonstone bracelet (from uncut)",
                level        = 79,
                xp           = 307.5,
                material     = {1, "Uncut moonstone", 1, "Ensouled bar"},
                mcount       = 2,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Hydrix ring",
				title        = "Hydrix ring (from uncut)",
                level        = 79,
                xp           = 327.5,
                material     = {1, "Uncut hydrix", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Dragonstone amulet (unstrung)",
				title        = "Dragonstone amulet (unstrung, from uncut)",
                level        = 80,
                xp           = 287.5,
                material     = {1, "Uncut dragonstone", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Dragonstone amulet",
				title        = "Dragonstone amulet (from uncut)",
                level        = 80,
                xp           = 291.5,
                material     = {1, "Uncut dragonstone", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Onyx necklace",
				title        = "Onyx necklace (from uncut)",
                level        = 82,
                xp           = 287.5,
                material     = {1, "Uncut onyx", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Onyx bracelet",
				title        = "Onyx bracelet (from uncut)",
                level        = 84,
                xp           = 292.5,
                material     = {1, "Uncut onyx", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Moonstone amulet (unstrung)",
				title        = "Moonstone amulet (unstrung, from uncut)",
                level        = 85,
                xp           = 312.5,
                material     = {1, "Uncut moonstone", 1, "Ensouled bar"},
                mcount       = 2,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Moonstone amulet",
				title        = "Moonstone amulet (from uncut)",
                level        = 85,
                xp           = 316.5,
                material     = {1, "Uncut moonstone", 1, "Ensouled bar", 1, "Ball of wool"},
                mcount       = 3,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Onyx amulet (unstrung)",
				title        = "Onyx amulet (unstrung, from uncut)",
                level        = 90,
                xp           = 332.5,
                material     = {1, "Uncut onyx", 1, "Gold bar"},
                mcount       = 2,
                trade        = 0,
                members      = true
            }, {
                name         = "Onyx amulet",
				title        = "Onyx amulet (from uncut)",
                level        = 90,
                xp           = 336.5,
                material     = {1, "Uncut onyx", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Hydrix necklace",
				title        = "Hydrix necklace (from uncut)",
                level        = 90,
                xp           = 332.5,
                material     = {1, "Uncut hydrix", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Hydrix bracelet",
				title        = "Hydrix bracelet (from uncut)",
                level        = 94,
                xp           = 337.5,
                material     = {1, "Uncut hydrix", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Hydrix amulet (unstrung)",
				title        = "Hydrix amulet (unstrung, from uncut)",
                level        = 99,
                xp           = 377.5,
                material     = {1, "Uncut hydrix", 1, "Gold bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Hydrix amulet",
				title        = "Hydrix amulet (from uncut)",
                level        = 99,
                xp           = 381.5,
                material     = {1, "Uncut hydrix", 1, "Gold bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Platinum ring",
                level        = 104,
                xp           = 214,
                material     = {1, "Dragonstone", 1, "Platinum bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Platinum necklace",
                level        = 105,
                xp           = 227,
                material     = {1, "Dragonstone", 1, "Platinum bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Platinum bracelet",
                level        = 106,
                xp           = 235,
                material     = {1, "Dragonstone", 1, "Platinum bar"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Platinum amulet",
                level        = 108,
                xp           = 263,
                material     = {1, "Dragonstone", 1, "Platinum bar", 1, "Ball of wool"},
                mcount       = 3,
                members      = true
            }, {
                name         = "Platinum anklet",
                level        = 109,
                xp           = 263,
                material     = {1, "Dragonstone", 1, "Platinum bar"},
                mcount       = 2,
                members      = true
            }
        }
        return methods
    end

    -- Pottery
    if trainMethod == "Pottery" then
        local methods = 
        {
            {
                name         = "Empty pot",
                level        = 1,
                xp           = 12.6,
                material     = {1, "Soft clay"}
            }, {
                name         = "Cracked mining urn (no rune)",
                level        = 1,
                xp           = 13 + 16.8,
                material     = {2, "Soft clay"}
            }, {
                name         = "Cracked cooking urn (no rune)",
                level        = 2,
                xp           = 13 + 18,
                material     = {2, "Soft clay"}
            }, {
                name         = "Cracked fishing urn (no rune)",
                level        = 2,
                xp           = 13 + 18,
                material     = {2, "Soft clay"}
            }, {
                name         = "Impious urn (no rune)",
                level        = 2,
                xp           = 12 + 18,
                material     = {2, "Soft clay"}
            }, {
                name         = "Cracked divination urn (no rune)",
                level        = 3,
                xp           = 13 + 18,
                material     = {2, "Soft clay"}
            }, {
                name         = "Cracked hunter urn (no rune)",
                level        = 3,
                xp           = 13 + 18,
                material     = {2, "Soft clay"}
            }, {
                name         = "Cracked runecrafting urn (no rune)",
                level        = 4,
                xp           = 14 + 18,
                material     = {2, "Soft clay"}
            }, {
                name         = "Cracked smithing urn (no rune)",
                level        = 4,
                xp           = 14 + 23.1,
                material     = {2, "Soft clay"}
            }, {
                name         = "Cracked woodcutting urn (no rune)",
                level        = 4,
                xp           = 14 + 23.1,
                material     = {2, "Soft clay"}
            }, {
                name         = "Cracked farming urn (no rune)",
                level        = 5,
                xp           = 14 + 18,
                material     = {2, "Soft clay"}
            }, {
                name         = "Pie dish",
                level        = 7,
                xp           = 25,
                material     = {1, "Soft clay"}
            }, {
                name         = "Bowl",
                level        = 8,
                xp           = 33,
                material     = {1, "Soft clay"}
            }, {
                name         = "Fragile cooking urn (no rune)",
                level        = 12,
                xp           = 18 + 24,
                material     = {2, "Soft clay"}
            }, {
                name         = "Fragile fishing urn (no rune)",
                level        = 15,
                xp           = 19 + 30,
                material     = {2, "Soft clay"}
            }, {
                name         = "Fragile woodcutting urn (no rune)",
                level        = 15,
                xp           = 19 + 30,
                material     = {2, "Soft clay"}
            }, {
                name         = "Fragile divination urn (no rune)",
                level        = 16,
                xp           = 20 + 24,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Fragile hunter urn (no rune)",
                level        = 17,
                xp           = 20 + 24,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Fragile mining urn (no rune)",
                level        = 17,
                xp           = 20 + 31.8,
                material     = {2, "Soft clay"}
            }, {
                name         = "Fragile smithing urn (no rune)",
                level        = 17,
                xp           = 20 + 31.8,
                material     = {2, "Soft clay"}
            }, {
                name         = "Fragile farming urn (no rune)",
                level        = 18,
                xp           = 21 + 24,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Fragile runecrafting urn (no rune)",
                level        = 18,
                xp           = 21 + 24,
                material     = {2, "Soft clay"}
            }, {
                name         = "Plant pot",
                level        = 19,
                xp           = 37.5,
                material     = {1, "Soft clay"},
                members      = true
            }, {
                name         = "Pot lid",
                level        = 25,
                xp           = 40,
                material     = {1, "Soft clay"},
                members      = true
            }, {
                name         = "Accursed urn (no rune)",
                level        = 26,
                xp           = 25 + 37.5,
                material     = {2, "Soft clay"}
            }, {
                name         = "Plain mining urn (no rune)",
                level        = 32,
                xp           = 28 + 40.8,
                material     = {2, "Soft clay"}
            }, {
                name         = "Plain runecrafting urn (no rune)",
                level        = 33,
                xp           = 28 + 42.9,
                material     = {2, "Soft clay"}
            }, {
                name         = "Plain hunter urn (no rune)",
                level        = 34,
                xp           = 29 + 42.9,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Plain smithing urn (no rune)",
                level        = 35,
                xp           = 29 + 42,
                material     = {2, "Soft clay"}
            }, {
                name         = "Plain cooking urn (no rune)",
                level        = 36,
                xp           = 30 + 42.9,
                material     = {2, "Soft clay"}
            }, {
                name         = "Plain divination urn (no rune)",
                level        = 38,
                xp           = 31 + 42.9,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Plain farming urn (no rune)",
                level        = 40,
                xp           = 32 + 42.9,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Plain fishing urn (no rune)",
                level        = 41,
                xp           = 32 + 46.8,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Plain woodcutting urn (no rune)",
                level        = 44,
                xp           = 34 + 48,
                material     = {2, "Soft clay"}
            }, {
                name         = "Strong mining urn (no rune)",
                level        = 48,
                xp           = 36 + 49.2,
                material     = {2, "Soft clay"}
            }, {
                name         = "Strong smithing urn (no rune)",
                level        = 49,
                xp           = 36 + 52,
                material     = {2, "Soft clay"}
            }, {
                name         = "Strong cooking urn (no rune)",
                level        = 51,
                xp           = 37 + 52.5,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Strong runecrafting urn (no rune)",
                level        = 52,
                xp           = 38 + 52.5,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Strong fishing urn (no rune)",
                level        = 53,
                xp           = 38 + 54,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Strong hunter urn (no rune)",
                level        = 55,
                xp           = 39 + 52.5,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Strong divination urn (no rune)",
                level        = 56,
                xp           = 40 + 52.5,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Strong farming urn (no rune)",
                level        = 58,
                xp           = 41 + 52.5,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Strong woodcutting urn (no rune)",
                level        = 61,
                xp           = 42 + 58.2,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Infernal urn (no rune)",
                level        = 62,
                xp           = 40 + 60,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Decorated fishing urn (no rune)",
                level        = 76,
                xp           = 50 + 72,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Decorated woodcutting urn (no rune)",
                level        = 76,
                xp           = 50 + 72,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Decorated runecrafting urn (no rune)",
                level        = 77,
                xp           = 50 + 78,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Decorated mining urn (no rune)",
                level        = 78,
                xp           = 51 + 57,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Decorated hunter urn (no rune)",
                level        = 79,
                xp           = 51 + 78,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Decorated smithing urn (no rune)",
                level        = 80,
                xp           = 52 + 78,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Decorated cooking urn (no rune)",
                level        = 81,
                xp           = 52 + 78,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Decorated divination urn (no rune)",
                level        = 82,
                xp           = 53 + 78,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Decorated farming urn (no rune)",
                level        = 84,
                xp           = 54 + 78,
                material     = {2, "Soft clay"},
                members      = true
            }, {
                name         = "Exquisite fishing urn (no gem)",
                level        = 104,
                xp           = 81.5 + 126.4,
                material     = {1, "Soft porcelain clay"},
                members      = true
            }, {
                name         = "Exquisite woodcutting urn (no gem)",
                level        = 106,
                xp           = 87 + 133.1,
                material     = {1, "Soft porcelain clay"},
                members      = true
            }, {
                name         = "Exquisite runecrafting urn (no gem)",
                level        = 107,
                xp           = 90.8 + 134.9,
                material     = {1, "Soft porcelain clay"},
                members      = true
            }, {
                name         = "Exquisite mining urn (no gem)",
                level        = 102,
                xp           = 78 + 120,
                material     = {1, "Soft porcelain clay"},
                members      = true
            }, {
                name         = "Exquisite hunter urn (no gem)",
                level        = 109,
                xp           = 96 + 141.2,
                material     = {1, "Soft porcelain clay"},
                members      = true
            }, {
                name         = "Exquisite smithing urn (no gem)",
                level        = 105,
                xp           = 84.7 + 130,
                material     = {1, "Soft porcelain clay"},
                members      = true
            }, {
                name         = "Exquisite cooking urn (no gem)",
                level        = 103,
                xp           = 80.2 + 123.7,
                material     = {1, "Soft porcelain clay"},
                members      = true
            }, {
                name         = "Exquisite divination urn (no gem)",
                level        = 108,
                xp           = 92.4 + 139,
                material     = {1, "Soft porcelain clay"},
                members      = true
            }, {
                name         = "Exquisite farming urn (no gem)",
                level        = 110,
                xp           = 99 + 144,
                material     = {1, "Soft porcelain clay"},
                members      = true
            }, {
                name         = "Exquisite fishing urn (no rune)",
                level        = 104,
                xp           = 81.5 + 126.4 + 126.4,
                material     = {1, "Soft porcelain clay", 1, "Sapphire"},
                members      = true
            }, {
                name         = "Exquisite woodcutting urn (no rune)",
                level        = 106,
                xp           = 87 + 133.1 + 133.1,
                material     = {1, "Soft porcelain clay", 1, "Diamond"},
                members      = true
            }, {
                name         = "Exquisite runecrafting urn (no rune)",
                level        = 107,
                xp           = 90.8 + 134.9 + 134.9,
                material     = {1, "Soft porcelain clay", 1, "Dragonstone"},
                members      = true
            }, {
                name         = "Exquisite mining urn (no rune)",
                level        = 102,
                xp           = 78 + 120 + 120,
                material     = {1, "Soft porcelain clay", 1, "Jade"},
                members      = true
            }, {
                name         = "Exquisite hunter urn (no rune)",
                level        = 109,
                xp           = 96 + 141.2 + 141.2,
                material     = {1, "Soft porcelain clay", 1, "Opal"},
                members      = true
            }, {
                name         = "Exquisite smithing urn (no rune)",
                level        = 105,
                xp           = 84.7 + 130 + 130,
                material     = {1, "Soft porcelain clay", 1, "Ruby"},
                members      = true
            }, {
                name         = "Exquisite cooking urn (no rune)",
                level        = 103,
                xp           = 80.2 + 123.7 + 123.7,
                material     = {1, "Soft porcelain clay", 1, "Red topaz"},
                members      = true
            }, {
                name         = "Exquisite divination urn (no rune)",
                level        = 108,
                xp           = 92.4 + 139 + 139,
                material     = {1, "Soft porcelain clay", 1, "Dragonstone"},
                members      = true
            }, {
                name         = "Exquisite farming urn (no rune)",
                level        = 110,
                xp           = 99 + 144 + 144,
                material     = {1, "Soft porcelain clay", 1, "Emerald"},
                members      = true
            }
        }
        return methods
    end

    -- Miscellaneous
    if trainMethod == "Miscellaneous" then
        local methods = 
        {
            {
                name         = "Molten glass",
                level        = 1,
                xp           = 20,
                material     = {1, "Bucket of sand", 1, "Soda ash"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Bowstring",
                level        = 1,
                xp           = 15,
                material     = {1, "Flax"},
            }, {
                name         = "Ball of black wool",
                level        = 1,
                xp           = 2.5,
                material     = {1, "Black wool"},
                trade        = 0,
            }, {
                name         = "Ball of wool",
                level        = 1,
                xp           = 2.5,
                material     = {1, "Wool"},
            }, {
                name         = "Beer glass",
                level        = 1,
                xp           = 17.5,
                material     = {1, "Molten glass"},
            }, {
                name         = "Candle lantern (empty)",
                level        = 4,
                xp           = 19,
                material     = {1, "Molten glass"},
                members      = true
            }, {
                name         = "Clockwork",
                level        = 8,
                xp           = 15,
                material     = {1, "Steel bar"},
                members      = true
            }, {
                name         = "Crossbow string",
                level        = 10,
                xp           = 15,
                material     = {1, "Sinew"},
            }, {
                name         = "Crossbow string",
                level        = 10,
                xp           = 15,
                material     = {1, "Oak roots"},
            }, {
                name         = "Crossbow string",
                level        = 10,
                xp           = 15,
                material     = {1, "Willow roots"},
            }, {
                name         = "Crossbow string",
                level        = 10,
                xp           = 15,
                material     = {1, "Maple roots"},
            }, {
                name         = "Crossbow string",
                level        = 10,
                xp           = 15,
                material     = {1, "Yew roots"},
            }, {
                name         = "Toy horsey (black)",
                level        = 10,
                xp           = 15,
                material     = {1, "Plank"},
                trade        = 0,
            }, {
                name         = "Toy horsey (brown)",
                level        = 10,
                xp           = 15,
                material     = {1, "Plank"},
                trade        = 0,
            }, {
                name         = "Toy horsey (grey)",
                level        = 10,
                xp           = 15,
                material     = {1, "Plank"},
                trade        = 0,
            }, {
                name         = "Toy horsey (white)",
                level        = 10,
                xp           = 15,
                material     = {1, "Plank"},
                trade        = 0,
            }, {
                name         = "Strip of cloth",
                level        = 10,
                xp           = 12,
                material     = {4, "Ball of wool"},
            }, {
                name         = "Strip of black cloth",
                level        = 10,
                xp           = 12,
                material     = {4, "Ball of black wool"},
                trade        = 0,
            }, {
                name         = "Oil lamp (empty)",
                level        = 12,
                xp           = 25,
                material     = {1, "Molten glass"},
                members      = true
            }, {
                name         = "Toy soldier",
                level        = 13,
                xp           = 15,
                material     = {1, "Clockwork", 1, "Plank"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Blood'n'tar snelm (pointed)",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Blamish red shell (pointed)"},
                members      = true
            }, {
                name         = "Blood'n'tar snelm (round)",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Blamish red shell (round)"},
                members      = true
            }, {
                name         = "Broken bark snelm (round)",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Blamish bark shell"},
                members      = true
            }, {
                name         = "Bruise blue snelm (pointed)",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Blamish blue shell (pointed)"},
                members      = true
            }, {
                name         = "Bruise blue snelm (round)",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Blamish blue shell (round)"},
                members      = true
            }, {
                name         = "Crab claw",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Fresh crab claw"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Crab helmet",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Fresh crab shell"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Myre snelm (pointed)",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Blamish myre shell (pointed)"},
                members      = true
            }, {
                name         = "Myre snelm (round)",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Blamish myre shell (round)"},
                members      = true
            }, {
                name         = "Ochre snelm (pointed)",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Blamish ochre shell (pointed)"},
                members      = true
            }, {
                name         = "Ochre snelm (round)",
                level        = 15,
                xp           = 32.5,
                material     = {1, "Blamish ochre shell (round)"},
                members      = true
            }, {
                name         = "Wooden cat",
                level        = 16,
                xp           = 15,
                material     = {1, "Plank", 1, "Fur"},
                members      = true
            }, {
                name         = "Toy doll",
                level        = 18,
                xp           = 15,
                material     = {1, "Clockwork", 1, "Plank"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Magic string",
                level        = 19,
                xp           = 30,
                material     = {1, "Magic roots"},
                members      = true
            }, {
                name         = "Empty sack",
                level        = 21,
                xp           = 38,
                material     = {4, "Jute fibre"},
                members      = true
            }, {
                name         = "Sextant",
                level        = 23,
                xp           = 15,
                material     = {1, "Steel bar"},
                trade        = 0,
                members      = true
            }, {
                name         = "Oil lantern (empty)",
                level        = 26,
                xp           = 50,
                material     = {1, "Oil lamp (empty)", 1, "Oil lantern frame"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Watch",
                level        = 28,
                xp           = 15,
                material     = {1, "Clockwork", 1, "Steel bar"},
                mcount       = 2,
                trade        = 0,
                members      = true
            }, {
                name         = "Rope",
                level        = 30,
                xp           = 25,
                material     = {1, "Hair"}
            }, {
                name         = "Clockwork suit",
                level        = 30,
                xp           = 15,
                material     = {1, "Clockwork", 1, "Plank", 1, "Silk"},
                mcount       = 3,
                trade        = 0,
                members      = true
            }, {
                name         = "Vial",
                level        = 33,
                xp           = 35,
                material     = {1, "Molten glass"},
            }, {
                name         = "Toy mouse",
                level        = 33,
                xp           = 15,
                material     = {1, "Clockwork", 1, "Plank"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Basket",
                level        = 36,
                xp           = 56,
                material     = {6, "Willow branch"},
                members      = true
            }, {
                name         = "Strung rabbit foot",
                title        = "Rabbit-foot necklace",
                level        = 37,
                xp           = 4,
                material     = {1, "Rabbit foot", 1, "Ball of wool"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Fishbowl",
                level        = 42,
                xp           = 42.5,
                material     = {1, "Molten glass"},
                members      = true
            }, {
                name         = "Unpowered orb",
                level        = 46,
                xp           = 52.5,
                material     = {1, "Molten glass"},
                members      = true
            }, {
                name         = "Lantern lens",
                level        = 49,
                xp           = 55,
                material     = {1, "Molten glass"},
                members      = true
            }, {
                name         = "Empty seaweed net",
                title        = "Seaweed net",
                level        = 52,
                xp           = 83,
                material     = {5, "Flax", 1, "Bronze wire"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Bomb vial",
                title        = "Bomb vial",
                level        = 54,
                xp           = 55,
                material     = {1, "Molten glass"},
                members      = true
            }, {
                name         = "Feather headdress (blue)",
                level        = 79,
                xp           = 50,
                material     = {1, "Studded leather coif", 20, "Blue feather"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Feather headdress (orange)",
                level        = 79,
                xp           = 50,
                material     = {1, "Studded leather coif", 20, "Orange feather"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Feather headdress (red)",
                level        = 79,
                xp           = 50,
                material     = {1, "Studded leather coif", 20, "Red feather"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Feather headdress (stripy)",
                level        = 79,
                xp           = 50,
                material     = {1, "Studded leather coif", 20, "Stripy feather"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Feather headdress (yellow)",
                level        = 79,
                xp           = 50,
                material     = {1, "Studded leather coif", 20, "Yellow feather"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Clockwork cat",
                level        = 85,
                xp           = 15,
                material     = {1, "Clockwork", 1, "Plank"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Empty light orb",
                level        = 87,
                xp           = 70,
                material     = {1, "Molten glass"},
                trade        = 0,
                members      = true
            }, {
                name         = "Light orb",
                level        = 87,
                xp           = 104,
                material     = {1, "Cave goblin wire", 1, "Empty light orb"},
                trade        = 0,
                members      = true
            }, {
                name         = "Light orb",
                title        = "Light orb (Scratch)",
                level        = 87,
                xp           = 174,
                material     = {1, "Molten glass", 1, "Cave goblin wire"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Crystal flask",
                level        = 89,
                xp           = 150,
                material     = {1, "Crystal glass"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Potion flask",
                level        = 89,
                xp           = 100,
                material     = {1, "Robust glass"},
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Death Lotus chaps",
                level        = 90,
                xp           = 20000,
                material     = {50, "Lacquer"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Death Lotus chestplate",
                level        = 90,
                xp           = 30000,
                material     = {80, "Lacquer"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Death Lotus hood",
                level        = 90,
                xp           = 10000,
                material     = {30, "Lacquer"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Leviathan ring",
                level        = 90,
                xp           = 10000,
                material     = {80, "Pearls"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Reefwalker's cape",
                level        = 90,
                xp           = 10000,
                material     = {80, "Koi Scales"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Superior Death Lotus chaps",
                level        = 90,
                xp           = 20000,
                material     = {60, "Lacquer"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Superior Death Lotus chestplate",
                level        = 90,
                xp           = 30000,
                material     = {100, "Lacquer"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Superior Death Lotus hood",
                level        = 90,
                xp           = 10000,
                material     = {40, "Lacquer"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Superior leviathan ring",
                level        = 90,
                xp           = 10000,
                material     = {100, "Pearls"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Superior reefwalker's cape",
                level        = 90,
                xp           = 10000,
                material     = {100, "Koi Scales"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Tortle shell bowl",
                level        = 91,
                xp           = 75,
                material     = {1, "Shell chippings"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }, {
                name         = "Shiny tortle shell bowl",
                level        = 92,
                xp           = 100,
                material     = {1, "Shiny shell chippings"},
                mtrade       = 0,
                trade        = 0,
                members      = true
            }
        }
        return methods
    end
    
    if trainMethod == "Starbloom Armour" then
        local methods = 
        {
            {
                name         = "Starbloom hat",
                level        = 100,
                xp           = 5280,
                material     = {2, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe top",
                level        = 100,
                xp           = 13200,
                material     = {5, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe bottom",
                level        = 100,
                xp           = 7920,
                material     = {3, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom gloves",
                level        = 100,
                xp           = 2640,
                material     = {1, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom boots",
                level        = 100,
                xp           = 2640,
                material     = {1, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom hat + 1",
                level        = 100,
                xp           = 5280,
                material     = {2, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe top + 1",
                level        = 100,
                xp           = 13200,
                material     = {5, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe bottom + 1",
                level        = 100,
                xp           = 7920,
                material     = {3, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom gloves + 1",
                level        = 100,
                xp           = 2640,
                material     = {1, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom boots + 1",
                level        = 100,
                xp           = 2640,
                material     = {1, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom hat + 2",
                level        = 100,
                xp           = 10560,
                material     = {4, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe top + 2",
                level        = 100,
                xp           = 26400,
                material     = {10, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe bottom + 2",
                level        = 100,
                xp           = 15480,
                material     = {6, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom gloves + 2",
                level        = 100,
                xp           = 5280,
                material     = {2, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom boots + 2",
                level        = 100,
                xp           = 5280,
                material     = {2, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom hat + 3",
                level        = 100,
                xp           = 21120,
                material     = {8, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe top + 3",
                level        = 100,
                xp           = 52800,
                material     = {20, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe bottom + 3",
                level        = 100,
                xp           = 31680,
                material     = {12, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom gloves + 3",
                level        = 100,
                xp           = 10560,
                material     = {4, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom boots + 3",
                level        = 100,
                xp           = 10560,
                material     = {4, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom hat + 4",
                level        = 100,
                xp           = 42240,
                material     = {16, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe top + 4",
                level        = 100,
                xp           = 105600,
                material     = {40, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe bottom + 4",
                level        = 100,
                xp           = 63360,
                material     = {24, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom gloves + 4",
                level        = 100,
                xp           = 21120,
                material     = {8, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom boots + 4",
                level        = 100,
                xp           = 21120,
                material     = {8, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom hat + 5",
                level        = 100,
                xp           = 84480,
                material     = {32, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe top + 5",
                level        = 100,
                xp           = 211200,
                material     = {80, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robe bottom + 5",
                level        = 100,
                xp           = 126720,
                material     = {48, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom gloves + 5",
                level        = 100,
                xp           = 42240,
                material     = {16, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom boots + 5",
                level        = 100,
                xp           = 42240,
                material     = {16, "Starbloom cloth"},
                members      = true
            }, {
                name         = "Starbloom robes (adorned)",
                level        = 100,
                xp           = 1317888,
                material     = {384, "Starbloom cloth"},
                trade        = 0,
                members      = true
            }
        }
        return methods
    end
    
    if trainMethod == "Apex Hide Armour" then
        local methods = 
        {
            {
                name         = "Apex hide cowl",
                level        = 100,
                xp           = 5280,
                material     = {2, "Apex leather", 2, "Apex sinew"},
                members      = true
            }, {
                name         = "Apex hide body",
                level        = 100,
                xp           = 13200,
                material     = {5, "Apex leather", 5, "Apex sinew", 1, "Steel studs", 1, "Steel bar"},
                members      = true
            }, {
                name         = "Apex hide chaps",
                level        = 100,
                xp           = 7920,
                material     = {3, "Apex leather", 3, "Apex sinew", 1, "Steel studs"},
                members      = true
            }, {
                name         = "Apex hide vambraces",
                level        = 100,
                xp           = 2640,
                material     = {1, "Apex leather", 1, "Apex sinew", 1, "Steel studs"},
                members      = true
            }, {
                name         = "Apex hide boots",
                level        = 100,
                xp           = 2640,
                material     = {1, "Apex leather", 1, "Apex sinew"},
                members      = true
            }, {
                name         = "Apex hide cowl + 1",
                level        = 100,
                xp           = 5280,
                material     = {2, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide body + 1",
                level        = 100,
                xp           = 13200,
                material     = {5, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide chaps + 1",
                level        = 100,
                xp           = 7920,
                material     = {3, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide vambraces + 1",
                level        = 100,
                xp           = 2640,
                material     = {1, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide boots + 1",
                level        = 100,
                xp           = 2640,
                material     = {1, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide cowl + 2",
                level        = 100,
                xp           = 10560,
                material     = {4, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide body + 2",
                level        = 100,
                xp           = 26400,
                material     = {10, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide chaps + 2",
                level        = 100,
                xp           = 15840,
                material     = {6, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide vambraces + 2",
                level        = 100,
                xp           = 5280,
                material     = {2, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide boots + 2",
                level        = 100,
                xp           = 5280,
                material     = {2, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide cowl + 3",
                level        = 100,
                xp           = 21120,
                material     = {8, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide body + 3",
                level        = 100,
                xp           = 52800,
                material     = {20, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide chaps + 3",
                level        = 100,
                xp           = 31680,
                material     = {12, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide vambraces + 3",
                level        = 100,
                xp           = 10560,
                material     = {4, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide boots + 3",
                level        = 100,
                xp           = 10560,
                material     = {4, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide cowl + 4",
                level        = 100,
                xp           = 42240,
                material     = {16, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide body + 4",
                level        = 100,
                xp           = 105600,
                material     = {40, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide chaps + 4",
                level        = 100,
                xp           = 63360,
                material     = {24, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide vambraces + 4",
                level        = 100,
                xp           = 21120,
                material     = {8, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide boots + 4",
                level        = 100,
                xp           = 21120,
                material     = {8, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide cowl + 5",
                level        = 100,
                xp           = 84480,
                material     = {32, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide body + 5",
                level        = 100,
                xp           = 211200,
                material     = {80, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide chaps + 5",
                level        = 100,
                xp           = 126720,
                material     = {48, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide vambraces + 5",
                level        = 100,
                xp           = 42240,
                material     = {16, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide boots + 5",
                level        = 100,
                xp           = 42240,
                material     = {16, "Apex leather"},
                members      = true
            }, {
                name         = "Apex hide armour (adorned)",
                level        = 100,
                xp           = 1317888,
                material     = {384, "Apex leather", 12, "Apex sinew", 3, "Steel studs", 1, "Steel bar"},
                trade        = 0,
                members      = true
            }
        }
        return methods
    end
    
    if trainMethod == "Dungeoneering Armour" then
        local methods = 
        {
            {
                name         = "Protoleather vambraces",
                level        = 1,
                xp           = 13.1,
                material     = {1, "Protomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Protoleather boots",
                level        = 3,
                xp           = 14.8,
                material     = {1, "Protomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Protoleather coif",
                level        = 5,
                xp           = 33,
                material     = {2, "Protomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Protoleather shield",
                level        = 6,
                xp           = 52.8,
                material     = {3, "Protomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Protoleather chaps",
                level        = 7,
                xp           = 54.6,
                material     = {3, "Protomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Protoleather body",
                level        = 9,
                xp           = 99.5,
                material     = {5, "Protomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Subleather vambraces",
                level        = 11,
                xp           = 21.6,
                material     = {1, "Submastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Subleather boots",
                level        = 13,
                xp           = 23.3,
                material     = {1, "Submastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Subleather coif",
                level        = 15,
                xp           = 50,
                material     = {2, "Submastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Subleather shield",
                level        = 16,
                xp           = 78.3,
                material     = {3, "Submastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Subleather chaps",
                level        = 17,
                xp           = 80.1,
                material     = {3, "Submastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Subleather body",
                level        = 19,
                xp           = 142,
                material     = {5, "Submastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Paraleather vambraces",
                level        = 21,
                xp           = 30.1,
                material     = {1, "Paramastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Paraleather boots",
                level        = 23,
                xp           = 31.8,
                material     = {1, "Paramastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Paraleather coif",
                level        = 25,
                xp           = 67,
                material     = {2, "Paramastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Paraleather shield",
                level        = 26,
                xp           = 103.8,
                material     = {3, "Paramastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Paraleather chaps",
                level        = 27,
                xp           = 105.6,
                material     = {3, "Paramastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Paraleather body",
                level        = 29,
                xp           = 184.5,
                material     = {5, "Paramastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Archleather vambraces",
                level        = 31,
                xp           = 38.6,
                material     = {1, "Archaemastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Archleather boots",
                level        = 33,
                xp           = 40.3,
                material     = {1, "Archaemastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Archleather coif",
                level        = 35,
                xp           = 84,
                material     = {2, "Archaemastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Archleather shield",
                level        = 36,
                xp           = 129.3,
                material     = {3, "Archaemastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Archleather chaps",
                level        = 37,
                xp           = 131.1,
                material     = {3, "Archaemastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Archleather body",
                level        = 39,
                xp           = 269.5,
                material     = {5, "Archaemastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Dromoleather vambraces",
                level        = 41,
                xp           = 47.1,
                material     = {1, "Dromomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Dromoleather boots",
                level        = 43,
                xp           = 48.8,
                material     = {1, "Dromomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Dromoleather coif",
                level        = 45,
                xp           = 101,
                material     = {2, "Dromomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Dromoleather shield",
                level        = 46,
                xp           = 154.8,
                material     = {3, "Dromomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Dromoleather chaps",
                level        = 47,
                xp           = 156.6,
                material     = {3, "Dromomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Dromoleather body",
                level        = 49,
                xp           = 269.5,
                material     = {5, "Dromomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Spinoleather vambraces",
                level        = 51,
                xp           = 55.6,
                material     = {1, "Spinomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Spinoleather boots",
                level        = 53,
                xp           = 57.3,
                material     = {1, "Spinomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Spinoleather coif",
                level        = 55,
                xp           = 118,
                material     = {2, "Spinomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Spinoleather shield",
                level        = 56,
                xp           = 180.3,
                material     = {3, "Spinomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Spinoleather chaps",
                level        = 57,
                xp           = 182.1,
                material     = {3, "Spinomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Spinoleather body",
                level        = 59,
                xp           = 312,
                material     = {5, "Spinomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0
            }, {
                name         = "Gallileather vambraces",
                level        = 61,
                xp           = 64.1,
                material     = {1, "Gallimastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Gallileather boots",
                level        = 63,
                xp           = 65.8,
                material     = {1, "Gallimastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Gallileather coif",
                level        = 65,
                xp           = 135,
                material     = {2, "Gallimastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Gallileather shield",
                level        = 66,
                xp           = 205.8,
                material     = {3, "Gallimastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Gallileather chaps",
                level        = 67,
                xp           = 207.6,
                material     = {3, "Gallimastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Gallileather body",
                level        = 69,
                xp           = 354.5,
                material     = {5, "Gallimastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Stegoleather vambraces",
                level        = 71,
                xp           = 72.6,
                material     = {1, "Stegomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Stegoleather boots",
                level        = 73,
                xp           = 74.3,
                material     = {1, "Stegomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Stegoleather coif",
                level        = 75,
                xp           = 152,
                material     = {2, "Stegomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Stegoleather shield",
                level        = 76,
                xp           = 231.3,
                material     = {3, "Stegomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Stegoleather chaps",
                level        = 77,
                xp           = 233.1,
                material     = {3, "Stegomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Stegoleather body",
                level        = 79,
                xp           = 397,
                material     = {5, "Stegomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Megaleather vambraces",
                level        = 81,
                xp           = 81.1,
                material     = {1, "Megamastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Megaleather boots",
                level        = 83,
                xp           = 82.8,
                material     = {1, "Megamastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Megaleather coif",
                level        = 85,
                xp           = 169,
                material     = {2, "Megamastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Megaleather shield",
                level        = 86,
                xp           = 256.8,
                material     = {3, "Megamastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Megaleather chaps",
                level        = 87,
                xp           = 258.6,
                material     = {3, "Megamastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Megaleather body",
                level        = 89,
                xp           = 439.5,
                material     = {5, "Megamastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Tyrannoleather vambraces",
                level        = 91,
                xp           = 89.6,
                material     = {1, "Tyrannomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Tyrannoleather boots",
                level        = 93,
                xp           = 91.3,
                material     = {1, "Tyrannomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Tyrannoleather coif",
                level        = 95,
                xp           = 186,
                material     = {2, "Tyrannomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Tyrannoleather shield",
                level        = 96,
                xp           = 282.3,
                material     = {3, "Tyrannomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Tyrannoleather chaps",
                level        = 97,
                xp           = 284.1,
                material     = {3, "Tyrannomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }, {
                name         = "Tyrannoleather body",
                level        = 99,
                xp           = 482,
                material     = {5, "Tyrannomastyx hide", 1, "Thread"},
                mcount       = 2,
                mtrade       = 0,
                trade       = 0,
                members      = true
            }
        }
        return methods
    end
end