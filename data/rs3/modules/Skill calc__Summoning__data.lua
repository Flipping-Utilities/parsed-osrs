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
        * familiar: Link to related summoning familiar
        * familiarTitle: Alternative name for summoning familiar
        * familiarIcon: Image location for summoming familiars pouch icon
        * useXp: Experience from using a scroll
        * members:  Indicates whether an item is members-only content
--]=]
local skillData = {}
 
return function(trainMethod)
    local charmsMethods = {
    	Gold = 
    	{
             {
                name        = "Spirit wolf pouch",
                title       = "Spirit wolf",
                level       = 1,
                xp          = 4.8,
                charm       = "Gold",
                material    = {7, "Spirit shards", 1, "Wolf bones"},
                mcount      = 2
            }, {
                name        = "Dreadfowl pouch",
                title       = "Dreadfowl",
                level       = 4,
                xp          = 9.3,
                charm       = "Gold",
                material    = {8, "Spirit shards", 1, "Raw chicken"},
                mcount      = 2
            }, {
                name        = "Spirit spider pouch",
                title       = "Spirit spider",
                level       = 10,
                xp          = 12.6,
                charm       = "Gold",
                material    = {8, "Spirit shards", 1, "Spider carcass"},
                mcount      = 2,
                members     = true
            },  {
                name        = "Thorny snail pouch",
                title       = "Thorny snail",
                level       = 13,
                xp          = 12.6,
                charm       = "Gold",
                material    = {9, "Spirit shards", 1, "Thin snail"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Granite crab pouch",
                title       = "Granite crab",
                level       = 16,
                xp          = 21.6,
                charm       = "Gold",
                material    = {7, "Spirit shards", 1, "Iron ore"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit mosquito pouch",
                title       = "Spirit mosquito",
                level       = 17,
                xp          = 46.5,
                charm       = "Gold",
                material    = {1, "Spirit shards", 1, "Proboscis"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Jackalope pouch",
                title       = "Jackalope",
                level       = 30,
                xp          = 39.6,
                charm       = "Gold",
                material    = {10, "Spirit shards", 1, "Jackalope antlers"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Bull ant pouch",
                title       = "Bull ant",
                level       = 40,
                xp          = 52.8,
                charm       = "Gold",
                material    = {11, "Spirit shards", 1, "Marigolds"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit terrorbird pouch",
                title       = "Spirit terrorbird",
                level       = 52,
                xp          = 68.4,
                charm       = "Gold",
                material    = {12, "Spirit shards", 1, "Raw bird meat"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Barker toad pouch",
                title       = "Barker toad",
                level       = 66,
                xp          = 87,
                charm       = "Gold",
                material    = {11, "Spirit shards", 1, "Swamp toad"},
                mcount      = 2,
                members     = true
            }, {
                name        = "War tortoise pouch",
                title       = "War tortoise",
                level       = 67,
                xp          = 58.6,
                charm       = "Gold",
                material    = {1, "Spirit shards", 1, "Tortoise shell"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Arctic bear pouch",
                title       = "Arctic bear",
                level       = 71,
                xp          = 93.2,
                charm       = "Gold",
                material    = {14, "Spirit shards", 1, "Polar kebbit fur"},
                mcount      = 2,
                members     = true
            }
        },
    	Green = 
    	{
            {
                name        = "Desert wyrm pouch",
                title       = "Desert wyrm",
                level       = 18,
                xp          = 31.2,
                charm       = "Green",
                material    = {45, "Spirit shards", 1, "Bucket of sand"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Compost mound pouch",
                title       = "Compost mound",
                level       = 28,
                xp          = 49.8,
                charm       = "Green",
                material    = {47, "Spirit shards", 1, "Compost"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Beaver pouch",
                title       = "Beaver",
                level       = 33,
                xp          = 57.6,
                charm       = "Green",
                material    = {72, "Spirit shards", 1, "Willow logs"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Void ravager pouch",
                title       = "Void ravager",
                level       = 34,
                xp          = 59.6,
                charm       = "Green",
                material    = {74, "Spirit shards", 1, "Ravager charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Macaw pouch",
                title       = "Macaw",
                level       = 41,
                xp          = 72.4,
                charm       = "Green",
                material    = {78, "Spirit shards", 1, "Clean guam"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit cockatrice pouch",
                title       = "Spirit cockatrice",
                level       = 43,
                xp          = 75.2,
                charm       = "Green",
                material    = {88, "Spirit shards", 1, "Cockatrice egg"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit guthatrice pouch",
                title       = "Spirit guthatrice",
                level       = 43,
                xp          = 75.2,
                charm       = "Green",
                material    = {88, "Spirit shards", 1, "Guthatrice egg"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit saratrice pouch",
                title       = "Spirit saratrice",
                level       = 43,
                xp          = 75.2,
                charm       = "Green",
                material    = {88, "Spirit shards", 1, "Saratrice egg"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit zamatrice pouch",
                title       = "Spirit zamatrice",
                level       = 43,
                xp          = 75.2,
                charm       = "Green",
                material    = {88, "Spirit shards", 1, "Zamatrice egg"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit pengatrice pouch",
                title       = "Spirit pengatrice",
                level       = 43,
                xp          = 75.2,
                charm       = "Green",
                material    = {88, "Spirit shards", 1, "Pengatrice egg"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit coraxatrice pouch",
                title       = "Spirit coraxatrice",
                level       = 43,
                xp          = 75.2,
                charm       = "Green",
                material    = {88, "Spirit shards", 1, "Coraxatrice egg"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit vulatrice pouch",
                title       = "Spirit vulatrice",
                level       = 43,
                xp          = 75.2,
                charm       = "Green",
                material    = {88, "Spirit shards", 1, "Vulatrice egg"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Magpie pouch",
                title       = "Magpie",
                level       = 47,
                xp          = 83.2,
                charm       = "Green",
                material    = {88, "Spirit shards", 1, "Gold ring"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Abyssal parasite pouch",
                title       = "Abyssal parasite",
                level       = 54,
                xp          = 94.8,
                charm       = "Green",
                material    = {106, "Spirit shards", 1, "Abyssal charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Ibis pouch",
                title       = "Ibis",
                level       = 56,
                xp          = 98.8,
                charm       = "Green",
                material    = {109, "Spirit shards", 1, "Harpoon"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Abyssal lurker pouch",
                title       = "Abyssal lurker",
                level       = 62,
                xp          = 109.6,
                charm       = "Green",
                material    = {119, "Spirit shards", 1, "Abyssal charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Bunyip pouch",
                title       = "Bunyip",
                level       = 68,
                xp          = 119.2,
                charm       = "Green",
                material    = {110, "Spirit shards", 1, "Raw shark"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Fruit bat pouch",
                title       = "Fruit bat",
                level       = 69,
                xp          = 121.2,
                charm       = "Green",
                material    = {130, "Spirit shards", 1, "Banana"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Forge regent pouch",
                title       = "Forge regent",
                level       = 76,
                xp          = 134,
                charm       = "Green",
                material    = {141, "Spirit shards", 1, "Ruby harvest jar"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Giant ent pouch",
                title       = "Giant ent",
                level       = 78,
                xp          = 136.8,
                charm       = "Green",
                material    = {124, "Spirit shards", 1, "Willow branch"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Holy scarab pouch",
                title       = "Holy scarab",
                level       = 80,
                xp          = 283.4,
                charm       = "Green",
                material    = {154, "Spirit shards", 1, "Plain whirligig shell", 1, "Gliding whirligig shell", 1, "Swift whirligig shell", 1, "Hasty whirligig shell", 1, "Speedy whirligig shell"},
                mcount      = 6,
                members     = true
            }, {
                name        = "Hydra pouch",
                title       = "Hydra",
                level       = 80,
                xp          = 140.8,
                charm       = "Green",
                material    = {128, "Spirit shards", 1, "Water orb"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Unicorn stallion pouch",
                title       = "Unicorn stallion",
                level       = 88,
                xp          = 154.4,
                charm       = "Green",
                material    = {140, "Spirit shards", 1, "Unicorn horn"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Abyssal titan pouch",
                title       = "Abyssal titan",
                level       = 93,
                xp          = 163.2,
                charm       = "Green",
                material    = {113, "Spirit shards", 1, "Abyssal charm"},
                mcount      = 1,
                members     = true
            }
        },
    	Crimson = 
    	{
            {
                name        = "Spirit scorpion pouch",
                title       = "Spirit scorpion",
                level       = 19,
                xp          = 83.2,
                charm       = "Crimson",
                material    = {57, "Spirit shards", 1, "Bronze claws"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit tz-kih pouch",
                title       = "Spirit Tz-Kih",
                level       = 22,
                xp          = 96.8,
                charm       = "Crimson",
                material    = {64, "Spirit shards", 1, "Obsidian charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Vampyre bat pouch",
                title       = "Vampyre bat",
                level       = 31,
                xp          = 136,
                charm       = "Crimson",
                material    = {81, "Spirit shards", 1, "Vampyre dust"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Honey badger pouch",
                title       = "Honey badger",
                level       = 32,
                xp          = 140.8,
                charm       = "Crimson",
                material    = {84, "Spirit shards", 1, "Honeycomb"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Evil turnip pouch",
                title       = "Evil turnip",
                level       = 42,
                xp          = 184.8,
                charm       = "Crimson",
                material    = {104, "Spirit shards", 1, "Carved evil turnip"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Pyrelord pouch",
                title       = "Pyrelord",
                level       = 46,
                xp          = 202.4,
                charm       = "Crimson",
                material    = {111, "Spirit shards", 1, "Tinderbox"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Bloated leech pouch",
                title       = "Bloated leech",
                level       = 49,
                xp          = 215.2,
                charm       = "Crimson",
                material    = {117, "Spirit shards", 1, "Raw beef"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Smoke devil pouch",
                title       = "Smoke devil",
                level       = 61,
                xp          = 268,
                charm       = "Crimson",
                material    = {141, "Spirit shards", 1, "Goat horn dust"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit cobra pouch",
                title       = "Spirit cobra",
                level       = 63,
                xp          = 276.8,
                charm       = "Crimson",
                material    = {116, "Spirit shards", 1, "Snake hide"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Stranger plant pouch",
                title       = "Stranger plant",
                level       = 64,
                xp          = 281.6,
                charm       = "Crimson",
                material    = {128, "Spirit shards", 1, "Bagged plant 1"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Ravenous locust pouch",
                title       = "Ravenous locust",
                level       = 70,
                xp          = 132,
                charm       = "Crimson",
                material    = {79, "Spirit shards", 1, "Pot of flour"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Phoenix pouch",
                title       = "Phoenix (familiar)",
                title       = "Phoenix",
                level       = 72,
                xp          = 301,
                charm       = "Crimson",
                material    = {165, "Spirit shards", 1, "Phoenix quill"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Granite lobster pouch",
                title       = "Granite lobster",
                level       = 74,
                xp          = 325.6,
                charm       = "Crimson",
                material    = {166, "Spirit shards", 1, "Granite (500g)"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Praying mantis pouch",
                title       = "Praying mantis",
                level       = 75,
                xp          = 329.6,
                charm       = "Crimson",
                material    = {168, "Spirit shards", 1, "Red flowers"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Talon beast pouch",
                title       = "Talon beast",
                level       = 77,
                xp          = 1015.2,
                charm       = "Crimson",
                material    = {174, "Spirit shards", 1, "Talon beast charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Brawler demon pouch",
                title       = "Brawler demon",
                level       = 82,
                xp          = 346.9,
                charm       = "Crimson",
                material    = {136, "Spirit shards", 1, "Demon claw"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Deacon demon pouch",
                title       = "Deacon demon",
                level       = 82,
                xp          = 346.9,
                charm       = "Crimson",
                material    = {136, "Spirit shards", 1, "Demon claw"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Executioner demon pouch",
                title       = "Executioner demon",
                level       = 82,
                xp          = 346.9,
                charm       = "Crimson",
                material    = {136, "Spirit shards", 1, "Demon claw"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit dagannoth pouch",
                title       = "Spirit dagannoth",
                level       = 83,
                xp          = 364.8,
                charm       = "Crimson",
                material    = {1, "Spirit shards", 1, "Dagannoth hide"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Swamp titan pouch",
                title       = "Swamp titan",
                level       = 85,
                xp          = 373.6,
                charm       = "Crimson",
                material    = {150, "Spirit shards", 1, "Green salamander"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Wolpertinger pouch",
                title       = "Wolpertinger",
                level       = 92,
                xp          = 404.8,
                charm       = "Crimson",
                material    = {203, "Spirit shards", 1, "Raw rabbit", 1, "Wolf bones"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Iron titan pouch",
                title       = "Iron titan",
                level       = 95,
                xp          = 417.6,
                charm       = "Crimson",
                material    = {198, "Spirit shards", 1, "Iron ingot"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Pack yak pouch",
                title       = "Pack yak",
                level       = 96,
                xp          = 422.4,
                charm       = "Crimson",
                material    = {211, "Spirit shards", 1, "Yak-hide"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Pack mammoth pouch",
                title       = "Pack mammoth",
                level       = 99,
                xp          = 439.8,
                charm       = "Crimson",
                material    = {222, "Spirit shards", 1, "Mammoth tusk"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Steel titan pouch",
                title       = "Steel titan",
                level       = 99,
                xp          = 435.2,
                charm       = "Crimson",
                material    = {178, "Spirit shards", 1, "Steel ingot"},
                mcount      = 2,
                members     = true
            }
        },
    	Blue = 
    	{
            {
                name        = "Albino rat pouch",
                title       = "Albino rat",
                level       = 23,
                xp          = 202.4,
                charm       = "Blue",
                material    = {75, "Spirit shards", 1, "Raw rat meat"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit kalphite pouch",
                title       = "Spirit kalphite",
                level       = 25,
                xp          = 220,
                charm       = "Blue",
                material    = {51, "Spirit shards", 1, "Potato cactus"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Giant chinchompa pouch",
                title       = "Giant chinchompa",
                level       = 29,
                xp          = 255.2,
                charm       = "Blue",
                material    = {84, "Spirit shards", 1, "Chinchompa"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Void shifter pouch",
                title       = "Void shifter",
                level       = 34,
                xp          = 59.6,
                charm       = "Blue",
                material    = {74, "Spirit shards", 1, "Shifter charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Void spinner pouch",
                title       = "Void spinner",
                level       = 34,
                xp          = 59.6,
                charm       = "Blue",
                material    = {74, "Spirit shards", 1, "Spinner charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Void torcher pouch",
                title       = "Void torcher",
                level       = 34,
                xp          = 59.6,
                charm       = "Blue",
                material    = {74, "Spirit shards", 1, "Torcher charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Bronze minotaur pouch",
                title       = "Bronze minotaur",
                level       = 36,
                xp          = 316.8,
                charm       = "Blue",
                material    = {102, "Spirit shards", 1, "Bronze bar"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Iron minotaur pouch",
                title       = "Iron minotaur",
                level       = 46,
                xp          = 404.8,
                charm       = "Blue",
                material    = {125, "Spirit shards", 1, "Iron bar"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit jelly pouch",
                title       = "Spirit jelly",
                level       = 55,
                xp          = 484,
                charm       = "Blue",
                material    = {151, "Spirit shards", 1, "Jug of water"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Steel minotaur pouch",
                title       = "Steel minotaur",
                level       = 56,
                xp          = 492.8,
                charm       = "Blue",
                material    = {141, "Spirit shards", 1, "Steel bar"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit graahk pouch",
                title       = "Spirit graahk",
                level       = 57,
                xp          = 501.6,
                charm       = "Blue",
                material    = {154, "Spirit shards", 1, "Graahk fur"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit kyatt pouch",
                title       = "Spirit kyatt",
                level       = 57,
                xp          = 501.6,
                charm       = "Blue",
                material    = {153, "Spirit shards", 1, "Kyatt fur"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Spirit larupia pouch",
                title       = "Spirit larupia",
                level       = 57,
                xp          = 501.6,
                charm       = "Blue",
                material    = {155, "Spirit shards", 1, "Larupia fur"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Karam. overlord pouch",
                title       = "Karamthulhu overlord",
                level       = 58,
                xp          = 510.4,
                charm       = "Blue",
                material    = {144, "Spirit shards", 1, "Fishbowl"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Mithril minotaur pouch",
                title       = "Mithril minotaur",
                level       = 66,
                xp          = 580.8,
                charm       = "Blue",
                material    = {152, "Spirit shards", 1, "Mithril bar"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Obsidian golem pouch",
                title       = "Obsidian golem",
                level       = 73,
                xp          = 642.4,
                charm       = "Blue",
                material    = {195, "Spirit shards", 1, "Obsidian charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Adamant minotaur pouch",
                title       = "Adamant minotaur",
                level       = 76,
                xp          = 668.8,
                charm       = "Blue",
                material    = {144, "Spirit shards", 1, "Adamant bar"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Fire titan pouch",
                title       = "Fire titan",
                level       = 79,
                xp          = 695.2,
                charm       = "Blue",
                material    = {198, "Spirit shards", 1, "Fire talisman"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Ice titan pouch",
                title       = "Ice titan",
                level       = 79,
                xp          = 695.2,
                charm       = "Blue",
                material    = {198, "Spirit shards", 1, "Air talisman", 1, "Water talisman"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Moss titan pouch",
                title       = "Moss titan",
                level       = 79,
                xp          = 695.2,
                charm       = "Blue",
                material    = {202, "Spirit shards", 1, "Earth talisman"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Lava titan pouch",
                title       = "Lava titan",
                level       = 83,
                xp          = 730.4,
                charm       = "Blue",
                material    = {219, "Spirit shards", 1, "Obsidian charm"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Rune minotaur pouch",
                title       = "Rune minotaur",
                level       = 86,
                xp          = 756.8,
                charm       = "Blue",
                material    = {100, "Spirit shards", 1, "Rune bar"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Light creature pouch",
                title       = "Light creature",
                level       = 88,
                xp          = 771.6,
                charm       = "Blue",
                material    = {204, "Spirit shards", 1, "Light core"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Geyser titan pouch",
                title       = "Geyser titan",
                level       = 89,
                xp          = 783.2,
                charm       = "Blue",
                material    = {222, "Spirit shards", 1, "Water talisman"},
                mcount      = 2,
                members     = true
            },
        },
    	Elder = 
    	{  
            {
                name        = "Nightmare muspah pouch",
                title       = "Nightmare muspah",
                level       = 81,
                xp          = 145.3,
                charm       = "Elder",
                material    = {150, "Elder energy", 1, "Muspah spine"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Blood nihil pouch",
                title       = "Blood nihil",
                level       = 87,
                xp          = 355,
                charm       = "Elder",
                material    = {150, "Elder energy", 1, "Vampyre fangs"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Ice nihil pouch",
                title       = "Ice nihil",
                level       = 87,
                xp          = 355,
                charm       = "Elder",
                material    = {150, "Elder energy", 1, "Icyene feather"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Shadow nihil pouch",
                title       = "Shadow nihil",
                level       = 87,
                xp          = 355,
                charm       = "Elder",
                material    = {150, "Elder energy", 1, "Demon horn"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Smoke nihil pouch",
                title       = "Smoke nihil",
                level       = 87,
                xp          = 355,
                charm       = "Elder",
                material    = {150, "Elder energy", 1, "Aviansie talons"},
                mcount      = 1,
                members     = true
            }
        }
    }
    
    -- Gold
    if trainMethod == "Gold charms" then
        return charmsMethods.Gold
    end

    -- Green
    if trainMethod == "Green charms" then
        return charmsMethods.Green
    end

    -- Crimson
    if trainMethod == "Crimson charms" then
        return charmsMethods.Crimson
    end

    -- Blue
    if trainMethod == "Blue charms" then
        return charmsMethods.Blue
    end

    -- Other (Elder)
    if trainMethod == "Elder charms" then
        return charmsMethods.Elder
    end
 
    -- All charms
    if trainMethod == "All charms" then
        local methods = {}
	    for _, charm in pairs(charmsMethods) do
	        for _, method in ipairs(charm) do
	            methods[#methods + 1] = method
	        end
	    end
	
	    return methods
    end


    -- Scrolls
    if trainMethod == "Scrolls" then
        local methods = 
        {
            {
                name          = "Spirit Wolf scroll (Howl)",
                familiar      = "Spirit wolf",
                familiarIcon  = "Spirit wolf pouch",
                level         = 1,
                xp            = 0.1,
                multiplier    = 10
            }, {
                name          = "Dreadfowl scroll (Dreadfowl Strike)",
                familiar      = "Dreadfowl",
                familiarIcon  = "Dreadfowl pouch",
                level         = 4,
                xp            = 0.1,
                multiplier    = 10
            }, {
                name          = "Spirit Spider scroll (Egg Spawn)",
                familiar      = "Spirit spider",
                familiarIcon  = "Spirit spider pouch",
                level         = 10,
                xp            = 0.2,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Thorny Snail scroll (Slime Spray)",
                familiar      = "Thorny snail",
                familiarIcon  = "Thorny snail pouch",
                level         = 13,
                xp            = 0.2,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Granite Crab scroll (Stony Shell)",
                familiar      = "Granite crab",
                familiarIcon  = "Granite crab pouch",
                level         = 16,
                xp            = 0.2,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Mosquito scroll (Pester)",
                familiar      = "Spirit mosquito",
                familiarIcon  = "Spirit mosquito pouch",
                level         = 17,
                xp            = 0.5,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Desert Wyrm scroll (Electric Lash)",
                familiar      = "Desert wyrm",
                familiarIcon  = "Desert wyrm pouch",
                level         = 18,
                xp            = 0.4,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Scorpion scroll (Venom Shot)",
                familiar      = "Spirit scorpion",
                familiarIcon  = "Spirit scorpion pouch",
                level         = 19,
                xp            = 1.0,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Tz-Kih scroll (Fireball Assault)",
                familiar      = "Spirit tz-kih",
                familiarIcon  = "Spirit tz-kih pouch",
                level         = 22,
                xp            = 1.1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Albino Rat scroll (Cheese Feast)",
                familiar      = "Albino rat",
                familiarIcon  = "Albino rat pouch",
                level         = 23,
                xp            = 2.3,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Kalphite scroll (Sandstorm)",
                familiar      = "Spirit kalphite",
                familiarIcon  = "Spirit kalphite pouch",
                level         = 25,
                xp            = 2.5,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Compost Mound scroll (Generate Compost)",
                familiar      = "Compost mound",
                familiarIcon  = "Compost mound pouch",
                level         = 28,
                xp            = 0.6,
                multiplier    = 10,
                members       = true
            }, {
				name          = "Jackalope scroll (Dig for Soil)",
                familiar      = "Jackalope",
                familiarIcon  = "Jackalope pouch",
                level         = 30,
                xp            = 1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Giant Chinchompa scroll (Explode)",
                familiar      = "Giant chinchompa",
                familiarIcon  = "Giant chinchompa pouch",
                level         = 84,
                xp            = 2.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Vampyre Bat scroll (Vampyre Touch)",
                familiar      = "Vampyre bat",
                familiarIcon  = "Vampyre bat pouch",
                level         = 31,
                xp            = 1.5,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Honey Badger scroll (Insane Ferocity)",
                familiar      = "Honey badger",
                familiarIcon  = "Honey badger pouch",
                level         = 32,
                xp            = 1.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Beaver scroll (Multichop)",
                familiar      = "Beaver",
                familiarIcon  = "Beaver pouch",
                level         = 33,
                xp            = 0.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Void scroll (Call to Arms)",
                familiar      = "Void ravager",
                familiarIcon  = "Void ravager pouch",
                level         = 34,
                xp            = 0.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Void scroll (Call to Arms)",
                familiar      = "Void shifter",
                familiarIcon  = "Void shifter pouch",
                level         = 34,
                xp            = 0.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Void scroll (Call to Arms)",
                familiar      = "Void spinner",
                familiarIcon  = "Void spinner pouch",
                level         = 34,
                xp            = 0.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Void scroll (Call to Arms)",
                familiar      = "Void torcher",
                familiarIcon  = "Void torcher pouch",
                level         = 34,
                xp            = 0.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Bronze Minotaur scroll (Bronze Bull Rush)",
                familiar      = "Bronze minotaur",
                familiarIcon  = "Bronze minotaur pouch",
                level         = 36,
                xp            = 3.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Bull Ant scroll (Unburden)",
                familiar      = "Bull ant",
                familiarIcon  = "Bull ant pouch",
                level         = 40,
                xp            = 0.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Macaw scroll (Herbcall)",
                familiar      = "Macaw",
                familiarIcon  = "Macaw pouch",
                level         = 41,
                xp            = 0.8,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Evil Turnip scroll (Evil Flames)",
                familiar      = "Evil turnip",
                familiarIcon  = "Evil turnip pouch",
                level         = 42,
                xp            = 2.1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Cockatrice scroll (Petrifying Gaze)",
                familiar      = "Spirit cockatrice",
                familiarIcon  = "Spirit cockatrice pouch",
                level         = 43,
                xp            = 0.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Cockatrice scroll (Petrifying Gaze)",
                familiar      = "Spirit guthatrice",
                familiarIcon  = "Spirit guthatrice pouch",
                level         = 43,
                xp            = 0.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Cockatrice scroll (Petrifying Gaze)",
                familiar      = "Spirit saratrice",
                familiarIcon  = "Spirit saratrice pouch",
                level         = 43,
                xp            = 0.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Cockatrice scroll (Petrifying Gaze)",
                familiar      = "Spirit zamatrice",
                familiarIcon  = "Spirit zamatrice pouch",
                level         = 43,
                xp            = 0.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Cockatrice scroll (Petrifying Gaze)",
                familiar      = "Spirit pengatrice",
                familiarIcon  = "Spirit pengatrice pouch",
                level         = 43,
                xp            = 0.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Cockatrice scroll (Petrifying Gaze)",
                familiar      = "Spirit coraxatrice",
                familiarIcon  = "Spirit coraxatrice pouch",
                level         = 43,
                xp            = 0.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Cockatrice scroll (Petrifying Gaze)",
                familiar      = "Spirit vulatrice",
                familiarIcon  = "Spirit vulatrice pouch",
                level         = 43,
                xp            = 0.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Iron Minotaur scroll (Iron Bull Rush)",
                familiar      = "Iron minotaur",
                familiarIcon  = "Iron minotaur pouch",
                level         = 46,
                xp            = 4.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Pyrelord scroll (Immense Heat)",
                familiar      = "Pyrelord",
                familiarIcon  = "Pyrelord pouch",
                level         = 46,
                xp            = 2.3,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Magpie scroll (Thieving Fingers)",
                familiar      = "Magpie",
                familiarIcon  = "Magpie pouch",
                level         = 47,
                xp            = 0.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Bloated Leech scroll (Blood Drain)",
                familiar      = "Bloated leech",
                familiarIcon  = "Bloated leech pouch",
                level         = 49,
                xp            = 2.5,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Terrorbird scroll (Tireless Run)",
                familiar      = "Spirit terrorbird",
                familiarIcon  = "Spirit terrorbird pouch",
                level         = 52,
                xp            = 0.8,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Abyssal Parasite scroll (Abyssal Drain)",
                familiar      = "Abyssal parasite",
                familiarIcon  = "Abyssal parasite pouch",
                level         = 54,
                xp            = 1.1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Jelly scroll (Dissolve)",
                familiar      = "Spirit jelly",
                familiarIcon  = "Spirit jelly pouch",
                level         = 55,
                xp            = 5.5,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Ibis scroll (Fish Rain)",
                familiar      = "Ibis",
                familiarIcon  = "Ibis pouch",
                level         = 56,
                xp            = 1.1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Steel Minotaur scroll (Steel Bull Rush)",
                familiar      = "Steel minotaur",
                familiarIcon  = "Steel minotaur pouch",
                level         = 56,
                xp            = 5.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Graahk scroll (Goad)",
                familiar      = "Spirit graahk",
                familiarIcon  = "Spirit graahk pouch",
                level         = 57,
                xp            = 5.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Kyatt scroll (Ambush)",
                familiar      = "Spirit kyatt",
                familiarIcon  = "Spirit kyatt pouch",
                level         = 57,
                xp            = 5.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Larupia scroll (Rending)",
                familiar      = "Spirit larupia",
                familiarIcon  = "Spirit larupia pouch",
                level         = 57,
                xp            = 5.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Karamthulu Overlord scroll (Doomsphere)",
                familiar      = "Karam. overlord",
                familiarIcon  = "Karam. overlord pouch",
                level         = 58,
                xp            = 5.8,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Smoke Devil scroll (Dust Cloud)",
                familiar      = "Smoke devil",
                familiarIcon  = "Smoke devil pouch",
                level         = 61,
                xp            = 3.0,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Abyssal Lurker scroll (Abyssal Stealth)",
                familiar      = "Abyssal lurker",
                familiarIcon  = "Abyssal lurker pouch",
                level         = 62,
                xp            = 1.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Cobra scroll (Ophidian Incubation)",
                title         = "Spirit Cobra scroll (Ophidian Incubation)",
                familiar      = "Spirit cobra",
                familiarIcon  = "Spirit cobra pouch",
                level         = 63,
                xp            = 3.1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Stranger Plant scroll (Poisonous Blast)",
                familiar      = "Stranger plant",
                familiarIcon  = "Stranger plant pouch",
                level         = 64,
                xp            = 3.2,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Barker Toad scroll (Toad Bark)",
                familiar      = "Barker toad",
                familiarIcon  = "Barker toad pouch",
                level         = 66,
                xp            = 1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Mithril Minotaur scroll (Mithril Bull Rush)",
                familiar      = "Mithril minotaur",
                familiarIcon  = "Mithril minotaur pouch",
                level         = 66,
                xp            = 6.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "War Tortoise scroll (Testudo)",
                familiar      = "War tortoise",
                familiarIcon  = "War tortoise pouch",
                level         = 67,
                xp            = 0.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Bunyip scroll (Swallow Whole)",
                familiar      = "Bunyip",
                familiarIcon  = "Bunyip pouch",
                level         = 68,
                xp            = 1.4,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Fruit Bat scroll (Fruitfall)",
                familiar      = "Fruit bat",
                familiarIcon  = "Fruit bat pouch",
                level         = 69,
                xp            = 1.4,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Ravenous Locust scroll (Famine)",
                familiar      = "Ravenous locust",
                familiarIcon  = "Ravenous locust pouch",
                level         = 70,
                xp            = 1.5,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Arctic Bear scroll (Arctic Blast)",
                familiar      = "Arctic bear",
                familiarIcon  = "Arctic bear pouch",
                level         = 71,
                xp            = 1.1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Phoenix scroll (Rise From the Ashes)",
                familiar      = "Phoenix (familiar)",
                familiarTitle = "Phoenix",
                familiarIcon  = "Phoenix pouch",
                level         = 72,
                xp            = 8,
                useXp         = 5,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Obsidian Golem scroll (Volcanic Strength)",
                title         = "Obsidian Golem scroll (Volcanic Strength)",
                familiar      = "Obsidian golem",
                familiarIcon  = "Obsidian golem pouch",
                level         = 73,
                xp            = 7.3,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Granite Lobster scroll (Crushing Claw)",
                familiar      = "Granite lobster",
                familiarIcon  = "Granite lobster pouch",
                level         = 74,
                xp            = 3.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Praying Mantis scroll (Mantis Strike)",
                familiar      = "Praying mantis",
                familiarIcon  = "Praying mantis pouch",
                level         = 75,
                xp            = 3.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Forge Regent scroll (Inferno)",
                familiar      = "Forge regent",
                familiarIcon  = "Forge regent pouch",
                level         = 76,
                xp            = 1.5,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Adamant Minotaur scroll (Adamant Bull Rush)",
                familiar      = "Adamant minotaur",
                familiarIcon  = "Adamant minotaur pouch",
                level         = 76,
                xp            = 7.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Talon Beast scroll (Deadly Claw)",
                familiar      = "Talon beast",
                familiarIcon  = "Talon beast pouch",
                level         = 77,
                xp            = 11.4,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Giant Ent scroll (Acorn Missile)",
                familiar      = "Giant ent",
                familiarIcon  = "Giant ent pouch",
                level         = 78,
                xp            = 1.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Elemental Titan scroll (Titan's Constitution)",
                familiar      = "Fire titan",
                familiarIcon  = "Fire titan pouch",
                level         = 79,
                xp            = 7.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Elemental Titan scroll (Titan's Constitution)",
                familiar      = "Ice titan",
                familiarIcon  = "Ice titan pouch",
                level         = 79,
                xp            = 7.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Elemental Titan scroll (Titan's Constitution)",
                familiar      = "Moss titan",
                familiarIcon  = "Moss titan pouch",
                level         = 79,
                xp            = 7.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Holy scarab scroll (Bone Conjure)",
                familiar      = "Holy scarab",
                familiarIcon  = "Holy scarab pouch",
                level         = 80,
                xp            = 6.4,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Hydra scroll (Regrowth)",
                familiar      = "Hydra",
                familiarIcon  = "Hydra pouch",
                level         = 80,
                xp            = 1.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Muspah scroll (Siphon Self)",
                familiar      = "Nightmare muspah",
                familiarIcon  = "Nightmare muspah pouch",
                level         = 81,
                xp            = 1.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Lesser Demon scroll (Ring of Fire)",
                familiar      = "Brawler demon",
                familiarIcon  = "Brawler demon pouch",
                level         = 82,
                xp            = 3.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Lesser Demon scroll (Ring of Fire)",
                familiar      = "Deacon demon",
                familiarIcon  = "Deacon demon pouch",
                level         = 82,
                xp            = 3.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Lesser Demon scroll (Ring of Fire)",
                familiar      = "Executioner demon",
                familiarIcon  = "Executioner demon pouch",
                level         = 82,
                xp            = 3.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Spirit Dagannoth scroll (Spike Shot)",
                familiar      = "Spirit dagannoth",
                familiarIcon  = "Spirit dagannoth pouch",
                level         = 83,
                xp            = 4.1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Lava Titan scroll (Ebon Thunder)",
                familiar      = "Lava titan",
                familiarIcon  = "Lava titan pouch",
                level         = 83,
                xp            = 8.3,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Swamp Titan scroll (Swamp Plague)",
                familiar      = "Swamp titan",
                familiarIcon  = "Swamp titan pouch",
                level         = 85,
                xp            = 4.1,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Rune Minotaur scroll (Rune Bull Rush)",
                familiar      = "Rune minotaur",
                familiarIcon  = "Rune minotaur pouch",
                level         = 86,
                xp            = 8.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Nihil scroll (Annihilate)",
                familiar      = "Blood nihil",
                familiarIcon  = "Blood nihil pouch",
                level         = 87,
                xp            = 1.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Nihil scroll (Annihilate)",
                familiar      = "Ice nihil",
                familiarIcon  = "Ice nihil pouch",
                level         = 87,
                xp            = 1.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Nihil scroll (Annihilate)",
                familiar      = "Shadow nihil",
                familiarIcon  = "Shadow nihil pouch",
                level         = 87,
                xp            = 1.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Nihil scroll (Annihilate)",
                familiar      = "Smoke nihil",
                familiarIcon  = "Smoke nihil pouch",
                level         = 87,
                xp            = 1.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Unicorn Stallion scroll (Healing Aura)",
                familiar      = "Unicorn stallion",
                familiarIcon  = "Unicorn stallion pouch",
                level         = 88,
                xp            = 1.8,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Light Creature scroll (Enlightenment)",
                familiar      = "Light creature (familiar)",
                familiarTitle = "Light creature",
                familiarIcon  = "Light creature pouch",
                level         = 88,
                xp            = 8.7,
                useXp         = 1.2,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Geyser Titan scroll (Boil)",
                familiar      = "Geyser titan",
                familiarIcon  = "Geyser titan pouch",
                level         = 89,
                xp            = 8.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Wolpertinger scroll (Magic Focus)",
                familiar      = "Wolpertinger",
                familiarIcon  = "Wolpertinger pouch",
                level         = 92,
                xp            = 4.6,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Abyssal Titan scroll (Essence Shipment)",
                familiar      = "Abyssal titan",
                familiarIcon  = "Abyssal titan pouch",
                level         = 93,
                xp            = 1.9,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Iron Titan scroll (Iron Within)",
                familiar      = "Iron titan",
                familiarIcon  = "Iron titan pouch",
                level         = 95,
                xp            = 4.7,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Pack Yak scroll (Winter Storage)",
                familiar      = "Pack yak",
                familiarIcon  = "Pack yak pouch",
                level         = 96,
                xp            = 4.8,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Pack Mammoth scroll (Mammoth Feast)",
                familiar      = "Pack mammoth",
                familiarIcon  = "Pack mammoth pouch",
                level         = 99,
                xp            = 5,
                useXp         = 10,
                multiplier    = 10,
                members       = true
            }, {
                name          = "Steel Titan scroll (Steel of Legends)",
                familiar      = "Steel titan",
                familiarIcon  = "Steel titan pouch",
                level         = 99,
                xp            = 4.9,
                multiplier    = 10,
                members       = true
            }
        }
        return methods
    end

    -- Dungeoneering
    if trainMethod == "Dungeoneering - Pouches" then
        local methods = 
        {
            {
                name        = "Cub bloodrager",
                icon        = "Cub bloodrager pouch",
                level       = 1,
                xp          = 5,
                charm       = "Gold",
                material    = {1, "Novite ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cub deathslinger",
                icon        = "Cub deathslinger pouch",
                level       = 2,
                xp          = 5.7,
                charm       = "Gold",
                material    = {1, "Tangle gum branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cub stormbringer",
                icon        = "Cub stormbringer pouch",
                level       = 3,
                xp          = 6.4,
                charm       = "Gold",
                material    = {1, "Salve nettles"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cub hoardstalker",
                icon        = "Cub hoardstalker pouch",
                level       = 5,
                xp          = 7.1,
                charm       = "Gold",
                material    = {1, "Protomastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cub worldbearer",
                icon        = "Cub worldbearer pouch",
                level       = 7,
                xp          = 7.8,
                charm       = "Gold",
                material    = {1, "Protoleather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cub skinweaver",
                icon        = "Cub skinweaver pouch",
                level       = 9,
                xp          = 8.5,
                charm       = "Gold",
                material    = {2, "Heim crab"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Little bloodrager",
                icon        = "Little bloodrager pouch",
                level       = 11,
                xp          = 19.5,
                charm       = "Gold",
                material    = {1, "Bathus ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Little deathslinger",
                icon        = "Little deathslinger pouch",
                level       = 12,
                xp          = 21.5,
                charm       = "Gold",
                material    = {1, "Seeping elm branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Little stormbringer",
                icon        = "Little stormbringer pouch",
                level       = 13,
                xp          = 22.5,
                charm       = "Gold",
                material    = {1, "Wildercress"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Little hoardstalker",
                icon        = "Little hoardstalker pouch",
                level       = 15,
                xp          = 23.5,
                charm       = "Gold",
                material    = {1, "Submastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Little worldbearer",
                icon        = "Little worldbearer pouch",
                level       = 17,
                xp          = 24.5,
                charm       = "Gold",
                material    = {1, "Subleather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Little skinweaver",
                icon        = "Little skinweaver pouch",
                level       = 19,
                xp          = 24.5,
                charm       = "Gold",
                material    = {2, "Red-eye"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naïve bloodrager",
                icon        = "Naïve bloodrager pouch",
                level       = 21,
                xp          = 43,
                charm       = "Gold",
                material    = {1, "Marmaros ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naïve deathslinger",
                icon        = "Naïve deathslinger pouch",
                level       = 22,
                xp          = 44.4,
                charm       = "Gold",
                material    = {1, "Blood spindle branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naïve stormbringer",
                icon        = "Naïve stormbringer pouch",
                level       = 23,
                xp          = 45.8,
                charm       = "Gold",
                material    = {1, "Blightleaf"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naïve hoardstalker",
                icon        = "Naïve hoardstalker pouch",
                level       = 25,
                xp          = 47.2,
                charm       = "Gold",
                material    = {1, "Paramastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naïve worldbearer",
                icon        = "Naïve worldbearer pouch",
                level       = 27,
                xp          = 48.6,
                charm       = "Gold",
                material    = {1, "Paraleather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naïve skinweaver",
                icon        = "Naïve skinweaver pouch",
                level       = 29,
                xp          = 50,
                charm       = "Gold",
                material    = {2, "Dusk eel"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Keen bloodrager",
                icon        = "Keen bloodrager pouch",
                level       = 31,
                xp          = 68.5,
                charm       = "Green",
                material    = {1, "Kratonium ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Keen deathslinger",
                icon        = "Keen deathslinger pouch",
                level       = 32,
                xp          = 70.4,
                charm       = "Green",
                material    = {1, "Utuku branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Keen stormbringer",
                icon        = "Keen stormbringer pouch",
                level       = 33,
                xp          = 72.3,
                charm       = "Green",
                material    = {1, "Roseblood"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Keen hoardstalker",
                icon        = "Keen hoardstalker pouch",
                level       = 35,
                xp          = 74.2,
                charm       = "Green",
                material    = {1, "Archaemastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Keen worldbearer",
                icon        = "Keen worldbearer pouch",
                level       = 37,
                xp          = 76.1,
                charm       = "Green",
                material    = {1, "Archleather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Keen skinweaver",
                icon        = "Keen skinweaver pouch",
                level       = 39,
                xp          = 78,
                charm       = "Green",
                material    = {2, "Giant flatfish"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brave bloodrager",
                icon        = "Brave bloodrager pouch",
                level       = 41,
                xp          = 99.5,
                charm       = "Green",
                material    = {1, "Fractite ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brave deathslinger",
                icon        = "Brave deathslinger pouch",
                level       = 42,
                xp          = 102,
                charm       = "Green",
                material    = {1, "Spinebeam branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brave stormbringer",
                icon        = "Brave stormbringer pouch",
                level       = 43,
                xp          = 104.5,
                charm       = "Green",
                material    = {1, "Bryll"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brave hoardstalker",
                icon        = "Brave hoardstalker pouch",
                level       = 45,
                xp          = 107,
                charm       = "Green",
                material    = {1, "Dromomastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brave worldbearer",
                icon        = "Brave worldbearer pouch",
                level       = 47,
                xp          = 109.5,
                charm       = "Green",
                material    = {1, "Dromoleather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brave skinweaver",
                icon        = "Brave skinweaver pouch",
                level       = 49,
                xp          = 112,
                charm       = "Green",
                material    = {2, "Short-finned eel"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brah bloodrager",
                icon        = "Brah bloodrager pouch",
                level       = 51,
                xp          = 99.5,
                charm       = "Green",
                material    = {1, "Zephyrium ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brah deathslinger",
                icon        = "Brah deathslinger pouch",
                level       = 52,
                xp          = 102,
                charm       = "Green",
                material    = {1, "Bovistrangler branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brah stormbringer",
                icon        = "Brah stormbringer pouch",
                level       = 53,
                xp          = 104.5,
                charm       = "Green",
                material    = {1, "Duskweed"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brah hoardstalker",
                icon        = "Brah hoardstalker pouch",
                level       = 55,
                xp          = 107,
                charm       = "Green",
                material    = {1, "Spinomastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brah worldbearer",
                icon        = "Brah worldbearer pouch",
                level       = 57,
                xp          = 109.5,
                charm       = "Green",
                material    = {1, "Spinoleather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Brah skinweaver",
                icon        = "Brah skinweaver pouch",
                level       = 59,
                xp          = 112,
                charm       = "Green",
                material    = {2, "Web snipper"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naabe bloodrager",
                icon        = "Naabe bloodrager pouch",
                level       = 61,
                xp          = 220,
                charm       = "Crimson",
                material    = {1, "Argonite ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naabe deathslinger",
                icon        = "Naabe deathslinger pouch",
                level       = 62,
                xp          = 224.6,
                charm       = "Crimson",
                material    = {1, "Thigat branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naabe stormbringer",
                icon        = "Naabe stormbringer pouch",
                level       = 63,
                xp          = 229.2,
                charm       = "Crimson",
                material    = {1, "Soulbell"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naabe hoardstalker",
                icon        = "Naabe hoardstalker pouch",
                level       = 65,
                xp          = 233.8,
                charm       = "Crimson",
                material    = {1, "Gallimastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naabe worldbearer",
                icon        = "Naabe worldbearer pouch",
                level       = 67,
                xp          = 238.4,
                charm       = "Crimson",
                material    = {1, "Gallileather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Naabe skinweaver",
                icon        = "Naabe skinweaver pouch",
                level       = 69,
                xp          = 243,
                charm       = "Crimson",
                material    = {2, "Bouldabass"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Wise bloodrager",
                icon        = "Wise bloodrager pouch",
                level       = 71,
                xp          = 325,
                charm       = "Crimson",
                material    = {1, "Katagon ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Wise deathslinger",
                icon        = "Wise deathslinger pouch",
                level       = 72,
                xp          = 330.8,
                charm       = "Crimson",
                material    = {1, "Corpsethorn branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Wise stormbringer",
                icon        = "Wise stormbringer pouch",
                level       = 73,
                xp          = 336.6,
                charm       = "Crimson",
                material    = {1, "Ectograss"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Wise hoardstalker",
                icon        = "Wise hoardstalker pouch",
                level       = 75,
                xp          = 342.4,
                charm       = "Crimson",
                material    = {1, "Stegomastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Wise worldbearer",
                icon        = "Wise worldbearer pouch",
                level       = 77,
                xp          = 348.2,
                charm       = "Crimson",
                material    = {1, "Stegoleather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Wise skinweaver",
                icon        = "Wise skinweaver pouch",
                level       = 79,
                xp          = 354,
                charm       = "Crimson",
                material    = {2, "Salve eel"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Adept bloodrager",
                icon        = "Adept bloodrager pouch",
                level       = 81,
                xp          = 517.5,
                charm       = "Blue",
                material    = {1, "Gorgonite ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Adept deathslinger",
                icon        = "Adept deathslinger pouch",
                level       = 82,
                xp          = 524.6,
                charm       = "Blue",
                material    = {2, "Entgallow branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Adept stormbringer",
                icon        = "Adept stormbringer pouch",
                level       = 83,
                xp          = 531.7,
                charm       = "Blue",
                material    = {1, "Runeleaf"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Adept hoardstalker",
                icon        = "Adept hoardstalker pouch",
                level       = 85,
                xp          = 538.8,
                charm       = "Blue",
                material    = {1, "Megamastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Adept worldbearer",
                icon        = "Adept worldbearer pouch",
                level       = 87,
                xp          = 545.9,
                charm       = "Blue",
                material    = {1, "Megaleather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Adept skinweaver",
                icon        = "Adept skinweaver pouch",
                level       = 89,
                xp          = 553,
                charm       = "Blue",
                material    = {2, "Blue crab"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Sachem bloodrager",
                icon        = "Sachem bloodrager pouch",
                level       = 91,
                xp          = 810,
                charm       = "Blue",
                material    = {1, "Promethium ore"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Sachem deathslinger",
                icon        = "Sachem deathslinger pouch",
                level       = 92,
                xp          = 818.5,
                charm       = "Blue",
                material    = {2, "Grave creeper branches"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Sachem stormbringer",
                icon        = "Sachem stormbringer pouch",
                level       = 93,
                xp          = 827,
                charm       = "Blue",
                material    = {1, "Spiritbloom"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Sachem hoardstalker",
                icon        = "Sachem hoardstalker pouch",
                level       = 95,
                xp          = 835.5,
                charm       = "Blue",
                material    = {1, "Tyrannomastyx hide"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Sachem worldbearer",
                icon        = "Sachem worldbearer pouch",
                level       = 97,
                xp          = 844,
                charm       = "Blue",
                material    = {1, "Tyrannoleather torn bag"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Sachem skinweaver",
                icon        = "Sachem skinweaver pouch",
                level       = 99,
                xp          = 852.5,
                charm       = "Blue",
                material    = {2, "Cave moray"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            },
        }
        return methods
    end

    -- Dungeoneering scrolls
    if trainMethod == "Dungeoneering - Scrolls" then
        local methods = 
        {
            {
                name         = "Sundering strike (tier 1)",
                familiar     = "Cub bloodrager",
                familiarIcon = "Cub bloodrager pouch",
                level        = 1,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            },  {
                name         = "Poisonous shot (tier 1)",
                familiar     = "Cub deathslinger",
                familiarIcon = "Cub deathslinger pouch",
                level        = 2,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 1)",
                familiar     = "Cub stormbringer",
                familiarIcon = "Cub stormbringer pouch",
                level        = 3,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 1)",
                familiar     = "Cub hoardstalker",
                familiarIcon = "Cub hoardstalker pouch",
                level        = 5,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 1)",
                familiar     = "Cub worldbearer",
                familiarIcon = "Cub worldbearer pouch",
                level        = 7,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 1)",
                familiar     = "Cub skinweaver",
                familiarIcon = "Cub skinweaver pouch",
                level        = 9,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Sundering strike (tier 2)",
                familiar     = "Little bloodrager",
                familiarIcon = "Little bloodrager pouch",
                level        = 11,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Poisonous shot (tier 2)",
                familiar     = "Little deathslinger",
                familiarIcon = "Little deathslinger pouch",
                level        = 12,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 2)",
                familiar     = "Little stormbringer",
                familiarIcon = "Little stormbringer pouch",
                level        = 13,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 2)",
                familiar     = "Little hoardstalker",
                familiarIcon = "Little hoardstalker pouch",
                level        = 15,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 2)",
                familiar     = "Little worldbearer",
                familiarIcon = "Little worldbearer pouch",
                level        = 17,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 2)",
                familiar     = "Little skinweaver",
                familiarIcon = "Little skinweaver pouch",
                level        = 19,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Sundering strike (tier 3)",
                familiar     = "Naïve bloodrager",
                familiarIcon = "Naïve bloodrager pouch",
                level        = 21,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Poisonous shot (tier 3)",
                familiar     = "Naïve deathslinger",
                familiarIcon = "Naïve deathslinger pouch",
                level        = 22,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 3)",
                familiar     = "Naïve stormbringer",
                familiarIcon = "Naïve stormbringer pouch",
                level        = 23,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 3)",
                familiar     = "Naïve hoardstalker",
                familiarIcon = "Naïve hoardstalker pouch",
                level        = 25,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 3)",
                familiar     = "Naïve worldbearer",
                familiarIcon = "Naïve worldbearer pouch",
                level        = 27,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 3)",
                familiar     = "Naïve skinweaver",
                familiarIcon = "Naïve skinweaver pouch",
                level        = 29,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Sundering strike (tier 4)",
                familiar     = "Keen bloodrager",
                familiarIcon = "Keen bloodrager pouch",
                level        = 31,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Poisonous shot (tier 4)",
                familiar     = "Keen deathslinger",
                familiarIcon = "Keen deathslinger pouch",
                level        = 32,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 4)",
                familiar     = "Keen stormbringer",
                familiarIcon = "Keen stormbringer pouch",
                level        = 33,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 4)",
                familiar     = "Keen hoardstalker",
                familiarIcon = "Keen hoardstalker pouch",
                level        = 35,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 4)",
                familiar     = "Keen worldbearer",
                familiarIcon = "Keen worldbearer pouch",
                level        = 37,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 4)",
                familiar     = "Keen skinweaver",
                familiarIcon = "Keen skinweaver pouch",
                level        = 39,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Sundering strike (tier 5)",
                familiar     = "Brave bloodrager",
                familiarIcon = "Brave bloodrager pouch",
                level        = 41,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Poisonous shot (tier 5)",
                familiar     = "Brave deathslinger",
                familiarIcon = "Brave deathslinger pouch",
                level        = 42,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 5)",
                familiar     = "Brave stormbringer",
                familiarIcon = "Brave stormbringer pouch",
                level        = 43,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 5)",
                familiar     = "Brave hoardstalker",
                familiarIcon = "Brave hoardstalker pouch",
                level        = 45,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 5)",
                familiar     = "Brave worldbearer",
                familiarIcon = "Brave worldbearer pouch",
                level        = 47,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 6)",
                familiar     = "Brah skinweaver",
                familiarIcon = "Brah skinweaver pouch",
                level        = 49,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Sundering strike (tier 6)",
                familiar     = "Brah bloodrager",
                familiarIcon = "Brah bloodrager pouch",
                level        = 51,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Poisonous shot (tier 6)",
                familiar     = "Brah deathslinger",
                familiarIcon = "Brah deathslinger pouch",
                level        = 52,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 6)",
                familiar     = "Brah stormbringer",
                familiarIcon = "Brah stormbringer pouch",
                level        = 53,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 6)",
                familiar     = "Brah hoardstalker",
                familiarIcon = "Brah hoardstalker pouch",
                level        = 55,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 6)",
                familiar     = "Brah worldbearer",
                familiarIcon = "Brah worldbearer pouch",
                level        = 57,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 6)",
                familiar     = "Brah skinweaver",
                familiarIcon = "Brah skinweaver pouch",
                level        = 59,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Sundering strike (tier 7)",
                familiar     = "Naabe bloodrager",
                familiarIcon = "Naabe bloodrager pouch",
                level        = 61,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Poisonous shot (tier 7)",
                familiar     = "Naabe deathslinger",
                familiarIcon = "Naabe deathslinger pouch",
                level        = 62,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 7)",
                familiar     = "Naabe stormbringer",
                familiarIcon = "Naabe stormbringer pouch",
                level        = 63,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 7)",
                familiar     = "Naabe hoardstalker",
                familiarIcon = "Naabe hoardstalker pouch",
                level        = 65,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 7)",
                familiar     = "Naabe worldbearer",
                familiarIcon = "Naabe worldbearer pouch",
                level        = 67,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 7)",
                familiar     = "Naabe skinweaver",
                familiarIcon = "Naabe skinweaver pouch",
                level        = 69,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Sundering strike (tier 8)",
                familiar     = "Wise bloodrager",
                familiarIcon = "Wise bloodrager pouch",
                level        = 71,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Poisonous shot (tier 8)",
                familiar     = "Wise deathslinger",
                familiarIcon = "Wise deathslinger pouch",
                level        = 72,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 8)",
                familiar     = "Wise stormbringer",
                familiarIcon = "Wise stormbringer pouch",
                level        = 73,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 8)",
                familiar     = "Wise hoardstalker",
                familiarIcon = "Wise hoardstalker pouch",
                level        = 75,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 8)",
                familiar     = "Wise worldbearer",
                familiarIcon = "Wise worldbearer pouch",
                level        = 77,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 8)",
                familiar     = "Wise skinweaver",
                familiarIcon = "Wise skinweaver pouch",
                level        = 79,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Sundering strike (tier 9)",
                familiar     = "Adept bloodrager",
                familiarIcon = "Adept bloodrager pouch",
                level        = 81,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Poisonous shot (tier 9)",
                familiar     = "Adept deathslinger",
                familiarIcon = "Adept deathslinger pouch",
                level        = 82,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 9)",
                familiar     = "Adept stormbringer",
                familiarIcon = "Adept stormbringer pouch",
                level        = 83,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 9)",
                familiar     = "Adept hoardstalker",
                familiarIcon = "Adept hoardstalker pouch",
                level        = 85,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 9)",
                familiar     = "Adept worldbearer",
                familiarIcon = "Adept worldbearer pouch",
                level        = 87,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 9)",
                familiar     = "Adept skinweaver",
                familiarIcon = "Adept skinweaver pouch",
                level        = 89,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Sundering strike (tier 10)",
                familiar     = "Sachem bloodrager",
                familiarIcon = "Sachem bloodrager pouch",
                level        = 91,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Poisonous shot (tier 10)",
                familiar     = "Sachem deathslinger",
                familiarIcon = "Sachem deathslinger pouch",
                level        = 92,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Snaring wave (tier 10)",
                familiar     = "Sachem stormbringer",
                familiarIcon = "Sachem stormbringer pouch",
                level        = 93,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Aptitude (tier 10)",
                familiar     = "Sachem hoardstalker",
                familiarIcon = "Sachem hoardstalker pouch",
                level        = 95,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Second wind (tier 10)",
                familiar     = "Sachem worldbearer",
                familiarIcon = "Sachem worldbearer pouch",
                level        = 97,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Glimmer of light (tier 10)",
                familiar     = "Sachem skinweaver",
                familiarIcon = "Sachem skinweaver pouch",
                level        = 99,
                xp           = 0.5,
                multiplier   = 10,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }
        }
        return methods
    end
	
	-- Pets
    if trainMethod == "Pets" then
        local methods = 
        {
            {
                name        = "Bulldog",
                icon        = "Bulldog puppy (white)",
                food        = "Raw meat",
                level       = 1,
                xp          = 0,
                trade       = 0
            }, {
                name        = "Dalmatian",
                icon        = "Dalmatian puppy (black)",
                food        = "Raw meat",
                level       = 1.01,
                xp          = 0,
                trade       = 0
            }, {
                name        = "Greyhound",
                icon        = "Greyhound puppy (light brown)",
                food        = "Raw beef",
                level       = 1.02,
                xp          = 0,
                trade       = 0
            }, {
                name        = "Sheepdog",
                icon        = "Sheepdog puppy (grey)",
                food        = "Raw meat",
                level       = 1.03,
                xp          = 0,
                trade       = 0
            }, {
                name        = "Terrier",
                icon        = "Terrier puppy (tan)",
                multif      = {"[[Raw meat]]", "[[Bones]]"},
                level       = 1.04,
                xp          = 0,
                trade       = 0
            }, {
                name        = "Creeping hand",
                multif      = {"[[Gloves]]", "[[Leather gloves]]"},
                fcount      = 2,
                level       = 1.05,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Minitrice",
                food        = "Limpwurt root",
                level       = 1.06,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Baby basilisk",
                food        = "Eye of newt",
                level       = 1.07,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Baby kurask",
                food        = "Bones",
                level       = 1.08,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Abyssal minion",
                food        = "Ashes",
                level       = 1.09,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Rune guardian",
                level       = 1.1,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Baby Troll",
                title       = "Baby troll",
                level       = 1.11,
                xp          = 0,
                trade       = 0
            }, {
                name        = "Labrador",
                icon        = "Labrador puppy (black)",
                food        = "Raw meat",
                level       = 4,
                xp          = 0,
                trade       = 0
            }, {
                name        = "Gecko",
                icon        = "Baby gecko (orange)",
                multif      = {"[[Flies]]", "[[Beetle bits]]"},
                fcount      = 2,
                level       = 10,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Platypus",
                icon        = "Baby platypus (brown)",
                food        = "Raw fish",
                level       = 10.1,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Pig (pet)",
                title       = "Pet pig",
                multif      = {"[[Onion]]", "[[Wheat]]"},
                level       = 14,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Broav",
                food        = "Mort myre fungus",
                level       = 23,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Penguin (pet)",
                title       = "Penguin",
                icon        = "Baby penguin (grey)",
                food        = "Raw fish",
                level       = 30,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Tooth creature",
                title       = "Tooth pet",
                multif      = {"[[Milk]]", "[[Chocolatey milk]]"},
                fcount      = 2,
                level       = 37,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Giant crab",
                icon        = "Baby giant crab (brown and green)",
                food        = "Raw fish",
                level       = 40,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Raven",
                icon        = "Raven chick (black)",
                multif      = {"'''Chick''': [[Ground fishing bait]]", "'''Adult''': [[Fishing bait]]"},
                level       = 50,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Squirrel",
                icon        = "Baby squirrel (light grey)",
                food        = "Nuts",
                level       = 60,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Saradomin owl",
                icon        = "Saradomin chick",
                multif      = {"'''Chick''': [[Ground fishing bait]]", "'''Bird & adult''': [[Fishing bait]]"},
                level       = 70,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Guthix raptor",
                icon        = "Guthix chick",
                multif      = {"'''Chick''': [[Ground fishing bait]]", "'''Bird & adult''': [[Fishing bait]]"},
                level       = 70.1,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Zamorak hawk",
                icon        = "Zamorak chick",
                multif      = {"'''Chick''': [[Ground fishing bait]]", "'''Bird & hawk''': [[Fishing bait]]"},
                level       = 70.2,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Ex-ex-parrot",
                food        = "Rock fragments",
                level       = 71,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Phoenix eggling",
                title       = "Cute phoenix eggling",
                icon        = "Phoenix eggling (cute)",
                food        = "Ashes",
                level       = 72,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Phoenix eggling",
                title       = "Mean phoenix eggling",
                icon        = "Phoenix eggling (mean)",
                food        = "Ashes",
                level       = 72.1,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Hermit crab",
                food        = "Raw fish",
                level       = 75,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Raccoon",
                icon        = "Baby raccoon (grey)",
                multif      = {"[[Raw meat]]", "[[Raw fish]]"},
                fcount      = 2,
                level       = 80,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Sneakerpeeper",
                icon        = "Sneakerpeeper spawn",
                food        = "Eye of newt",
                level       = 80,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Vulture (pet)",
                title       = "Vulture",
                icon        = "Vulture chick (grey)",
                multif      = {"'''Chick''': [[Ground fishing bait]]", "'''Adult''': [[Fishing bait]]"},
                level       = 85,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Chameleon",
                food        = "Flies",
                icon        = "Baby chameleon",
                level       = 90,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Monkey (pet)",
                title       = "Monkey",
                icon        = "Baby monkey (orange)",
                food        = "Bananas",
                level       = 95,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Baby dragon (pet)",
                title       = "Dragon",
                icon        = "Hatchling dragon (green)",
                multif      = {"[[Raw meat]]", "[[Fish]]"},
                level       = 99,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "TzRek-Jad",
                title       = "TzRek Jad",
                level       = 99.1,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Frosty",
                level       = 99.2,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "King Black Dragonling",
                level       = 99.3,
                xp          = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Queen Black Dragonling",
                level       = 99.3,
                xp          = 0,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
end