--[=[
     Notations found in this Module:
        * name:     Name of product
        * icon:     Alternate image location
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
        * noBurn:   Indicates when an item can no longer be burned. Not currently used.
        * mtrade:   Indicates whether the materials needed can be found in the GE
        * trade:    Indicates whether the product can be found in the GE
        * currency: Indicates an alternative currency being used
        * value:    Specifies the products value in alternative currency
--]=]
local skillData = {}
local methods = {}

return function(trainMethod)
    ---------------------------------  Meat  ---------------------------------------------
    methods["Meat"] = {
            {
                name        = "Cooked meat",
                level       = 1,
                xp          = 23.5,
                material    = {1, "Raw beef"}
            }, {
                name        = "Cooked meat",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw rat meat"}
            }, {
                name        = "Cooked meat",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw bear meat"}
            }, {
                name        = "Cooked meat",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw yak meat"}
            }, {
                name        = "Cooked meat",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw pawya meat"}
            }, {
                name        = "Ugthanki meat",
                level       = 1,
                xp          = 40,
                material    = {1, "Raw ugthanki meat"},
                members     = true
            }, {
                name        = "Cooked chicken",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw chicken"}
            }, {
                name        = "Cooked rabbit",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw rabbit"}
            }, {
                name        = "Ugthanki kebab",
                level       = 1,
                xp          = 40,
                material    = {1, "Kebab mix", 1, "Pitta bread"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Ugthanki kebab",
                title       = "Ugthanki kebab (Scratch)",
                level       = 1,
                xp          = 40,
                material    = {1, "Onion", 1, "Tomato", 1, "Ugthanki meat", 1, "Pitta bread"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Roast bird meat",
                title       = "Roasted bird meat",
                level       = 11,
                xp          = 62,
                material    = {1, "Skewered bird meat"},
                members     = true
            }, {
                name        = "Thin snail meat",
                level       = 12,
                xp          = 70,
                material    = {1, "Thin snail"},
                members     = true
            }, {
                name        = "Bacon",
                level       = 14,
                xp          = 68,
                material    = {1, "Raw bacon"},
                mtrade      = 0,
                members     = true
            }, {
                name        = "Spider on stick",
                level       = 16,
                xp          = 80,
                material    = {1, "Spider on stick (raw)"},
                members     = true
            }, {
                name        = "Roast rabbit",
                title       = "Roasted rabbit",
                level       = 16,
                xp          = 72,
                material    = {1, "Raw rabbit"},
                members     = true
            }, {
                name        = "Lean snail meat",
                level       = 17,
                xp          = 80,
                material    = {1, "Lean snail"},
                members     = true
            }, {
                name        = "Roast beast meat",
                title       = "Roasted beast meat",
                level       = 21,
                xp          = 82,
                material    = {1, "Raw beast meat"},
                members     = true
            }, {
                name        = "Cooked crab meat",
                title       = "Giant crab meat",
                level       = 21,
                xp          = 100,
                material    = {1, "Crab meat"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Fat snail meat",
                level       = 22,
                xp          = 95,
                material    = {1, "Fat snail"},
                members     = true
            }, {
                name        = "Bacon stack",
                level       = 24,
                xp          = 88,
                material    = {1, "Raw bacon stack"},
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cooked chompy",
                title       = "Roasted chompy",
                level       = 30,
                xp          = 140,
                material    = {1, "Raw chompy"},
                members     = true
            }, {
                name        = "Cooked fishcake",
                level       = 31,
                xp          = 100,
                material    = {1, "Ground cod", 1, "Ground kelp", 1, "Ground crab meat", 1, "Breadcrumbs"},
                mcount      = 4,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Bacon pile",
                level       = 34,
                xp          = 108,
                material    = {4, "Raw bacon"},
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cooked jubbly",
                title       = "Jubbly",
                level       = 41,
                xp          = 160,
                material    = {1, "Raw jubbly"},
                members     = true
            }, {
                name        = "Bacon heap",
                level       = 44,
                xp          = 135,
                material    = {8, "Raw bacon"},
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cooked oomlie wrap",
                title       = "Oomlie wrap",
                level       = 50,
                xp          = 110,
                material    = {1, "Wrapped oomlie"},
                members     = true
            }, {
                name        = "Cooked oomlie wrap",
                title       = "Oomlie wrap (Scratch)",
                level       = 50,
                xp          = 110,
                material    = {1, "Raw oomlie"},
                members     = true
            }, {
                name        = "Bacon mound",
                level       = 54,
                xp          = 158,
                material    = {16, "Raw bacon"},
                mtrade      = 0,
                members     = true
            }, {
                name        = "Arcane apoterrasaur meat",
                level       = 75,
                xp          = 150,
                material    = {1, "Raw arcane apoterrasaur meat"},
                members     = true
            }, {
                name        = "Scimitops meat",
                level       = 75,
                xp          = 150,
                material    = {1, "Raw scimitops meat"},
                members     = true
            }, {
                name        = "Bagrada rex meat",
                level       = 75,
                xp          = 150,
                material    = {1, "Raw bagrada rex meat"},
                members     = true
            }, {
                name        = "Spicati apoterrasaur meat",
                level       = 81,
                xp          = 155,
                material    = {1, "Raw spicati apoterrasaur meat"},
                members     = true
            }, {
                name        = "Asciatops meat",
                level       = 81,
                xp          = 160,
                material    = {1, "Raw asciatops meat"},
                members     = true
            }, {
                name        = "Corbicula rex meat",
                level       = 81,
                xp          = 170,
                material    = {1, "Raw corbicula rex meat"},
                members     = true
            }, {
                name        = "Oculi apoterrasaur meat",
                level       = 89,
                xp          = 215,
                material    = {1, "Raw oculi apoterrasaur meat"},
                members     = true
            }, {
                name        = "Malletops meat",
                level       = 89,
                xp          = 215,
                material    = {1, "Raw malletops meat"},
                members     = true
            }, {
                name        = "Pavosaurus rex meat",
                level       = 89,
                xp          = 215,
                material    = {1, "Raw pavosaurus rex meat"},
                members     = true
            }, {
                name        = "Cooked pekin",
                title       = "Pekin chicken",
                level       = 91,
                xp          = 30,
                material    = {9, 1, "Raw pekin"},
                currency    = "chimes",
                value       = 9,
                mtrade      = 0,
                trade       = 0,
                members     = true
                }, {
                name        = "Giant chinchompa meat",
                level       = 99,
                xp          = 420,
                material    = {1, "Raw giant chinchompa meat"},
                members     = true
            }, {
                name        = "Giant kebbit meat",
                level       = 99,
                xp          = 420,
                material    = {1, "Raw giant kebbit meat"},
                members     = true
            }
        }
    
    ---------------------------------  Fish  --------------------------------------------
    methods["Fish"] = {
            {
                name        = "Shrimps",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw shrimps"},
                noBurn      = 34
            }, {
                name        = "Crayfish",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw crayfish"},
                noBurn      = 32
            }, {
                name        = "Anchovies",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw anchovies"},
                noBurn      = 34
            }, {
                name        = "Sardine",
                level       = 1,
                xp          = 40,
                material    = {1, "Raw sardine"},
                noBurn      = 38
            }, {
                name        = "Karambwanji",
                level       = 1,
                xp          = 10,
                material    = {1, "Raw karambwanji"},
                trade       = 0,
                mtrade      = 0,
                noBurn      = 28,
                members     = true
            }, {
                name        = "Cooked karambwan",
                level       = 1,
                xp          = 190,
                material    = {1, "Raw karambwan"},
                members     = true
            }, {
                name        = "Minnow",
                level       = 1,
                xp          = 30,
                material    = {1, "Raw minnow"},
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Herring",
                level       = 5,
                xp          = 50,
                material    = {1, "Raw herring"},
                noBurn      = 41
            }, {
                name        = "Mackerel",
                level       = 10,
                xp          = 30,
                material    = {1, "Raw mackerel"},
                noBurn      = 45,
                members     = true
            }, {
                name        = "Trout",
                level       = 15,
                xp          = 70,
                material    = {1, "Raw trout"},
                noBurn      = 50
            }, {
                name        = "Cod",
                level       = 18,
                xp          = 75,
                material    = {1, "Raw cod"},
                noBurn      = 52,
                members     = true
            }, {
                name        = "Pike",
                level       = 20,
                xp          = 80,
                material    = {1, "Raw pike"},
                noBurn      = 53
            }, {
                name        = "Salmon",
                level       = 25,
                xp          = 90,
                material    = {1, "Raw salmon"},
                noBurn      = 58
            }, {
                name        = "Cooked slimy eel",
                level       = 28,
                xp          = 95,
                material    = {1, "Slimy eel"},
                noBurn      = 58,
                members     = true
            }, {
                name        = "Tuna",
                level       = 30,
                xp          = 100,
                material    = {1, "Raw tuna"},
                noBurn      = 65
            }, {
                name        = "Rainbow fish",
                level       = 35,
                xp          = 110,
                material    = {1, "Raw rainbow fish"},
                noBurn      = 60,
                members     = true
            }, {
                name        = "Cave eel",
                level       = 38,
                xp          = 115,
                material    = {1, "Raw cave eel"},
                noBurn      = 40,
                members     = true
            }, {
                name        = "Lobster",
                level       = 40,
                xp          = 120,
                material    = {1, "Raw lobster"},
                noBurn      = 74
            }, {
                name        = "Bass",
                level       = 43,
                xp          = 130,
                material    = {1, "Raw bass"},
                noBurn      = 80,
                members     = true
            }, {
                name        = "Swordfish",
                level       = 45,
                xp          = 140,
                material    = {1, "Raw swordfish"},
                noBurn      = 86
            }, {
                name        = "Desert sole",
                level       = 52,
                xp          = 142.5,
                material    = {1, "Raw desert sole"},
                members     = true
            }, {
                            name        = "Ghostly sole",
                level       = 66,
                xp          = 160,
                material    = {1, "Raw ghostly sole"},
                members     = true
            }, {
                name        = "Lava eel",
                level       = 53,
                xp          = 30,
                material    = {1, "Raw lava eel"},
                noBurn      = 53,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Catfish",
                level       = 60,
                xp          = 145,
                material    = {1, "Raw catfish"},
                members     = true
            }, {
                name        = "Monkfish",
                level       = 64,
                xp          = 150,
                material    = {1, "Raw monkfish"},
                noBurn      = 92,
                members     = true
            }, {
                name        = "Beltfish",
                level       = 72,
                xp          = 165,
                material    = {1, "Raw beltfish"},
                members     = true
            }, {
                name        = "Green blubber jellyfish",
                level       = 72,
                xp          = 165,
                material    = {1, "Raw green blubber jellyfish"},
                members     = true
            }, {
                name        = "Shark",
                level       = 80,
                xp          = 210,
                material    = {1, "Raw shark"},
                members     = true
            }, {
                name        = "Sea turtle",
                level       = 82,
                xp          = 211.3,
                material    = {1, "Raw sea turtle"},
                members     = true
            }, {
                name        = "Great maki",
                level       = 84,
                xp          = 150,
                urns        = false,
                material    = {1, "Raw great white shark", 1, "Seaweed"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Great white shark",
                level       = 84,
                xp          = 212,
                material    = {1, "Raw great white shark"},
                members     = true
            }, {
                name        = "Giant crayfish",
                level       = 86,
                xp          = 212,
                material    = {1, "Raw giant crayfish"},
                members     = true
            }, {
                name        = "Cavefish",
                level       = 88,
                xp          = 214,
                material    = {1, "Raw cavefish"},
                members     = true
            }, {
                name        = "Manta ray",
                level       = 91,
                xp          = 216.3,
                material    = {1, "Raw manta ray"},
                members     = true
            }, {
                name        = "Fish oil",
                icon        = "Fish oil 20",
                level       = 91,
                xp          = 120,
                material    = {9, 1, "Raw tarpon"},
                currency    = "chimes",
                value       = 9,
                mtrade      = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Fish oil",
                icon        = "Fish oil 20",
                level       = 91,
                xp          = 120,
                material    = {6, 1, "Raw seerfish"},
                currency    = "chimes",
                value       = 9,
                mtrade      = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Fish oil",
                icon        = "Fish oil 20",
                level       = 91,
                xp          = 120,
                material    = {3, 2, "Raw sillago"},
                currency    = "chimes",
                value       = 9,
                mtrade      = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Great gunkan",
                level       = 91,
                xp          = 180,
                urns        = false,
                material    = {1, "Raw great white shark", 1, "Kelp"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Rocktail",
                level       = 93,
                xp          = 225,
                material    = {1, "Raw rocktail"},
                members     = true
            }, {
                name        = "Rocktail soup",
                level       = 93,
                xp          = 500,
                urns        = false,
                material    = {1, "Rocktail", 1, "Spices"},
                members     = true
            }, {
                name        = "Rocktail soup",
                title       = "Rocktail soup (Scratch)",
                level       = 93,
                xp          = 725,
                urns        = false,
                material    = {1, "Raw rocktail", 1, "Spices"},
                members     = true
            }, {
                name        = "Arc gumbo",
                level       = 94,
                xp          = 130,
                material    = {1, 9, "Fish oil 1,Fish oil", 1, 4, "Sea salt", 1, 11, "Bundle of bamboo", 1, 2, "Rumberry", 1, 9, "Tortle shell bowl"},
                mcount      = 5,
                currency    = "chimes",
                value       = 65,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Tiger shark",
                level       = 95,
                xp          = 230,
                material    = {1, "Raw tiger shark"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Blue blubber jellyfish",
                level       = 95,
                xp          = 235,
                material    = {1, "Raw blue blubber jellyfish"},
                members     = true
            }, {
                name        = "Wobbegong oil",
                icon        = "Wobbegong oil 20",
                level       = 96,
                xp          = 240,
                material    = {2, 3, "Raw wobbegong"},
                currency    = "chimes",
                value       = 12,
                mtrade      = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Shark soup",
                title       = "Shark soup",
                level       = 96,
                xp          = 240,
                material    = {1, 12, "Wobbegong oil 1,Wobbegong oil", 1, 5, "Alaea sea salt", 1, 11, "Bundle of bamboo", 1, 11, "Sliced mushrooms (The Arc)", 1, 12, "Shiny tortle shell bowl"},
                mcount      = 5,
                trade       = 0,
                mtrade      = 0,
                currency    = "chimes",
                value       = 85,
                members     = true
            }, {
                name        = "Sailfish",
                level       = 99,
                xp          = 270,
                material    = {1, "Raw sailfish"},
                members     = true
            }, {
                name        = "Sailfish soup",
                level       = 99,
                xp          = 600,
                urns        = false,
                material    = {1, "Sailfish", 1, "Spices"},
                members     = true
            }, {
                name        = "Sailfish soup",
                title       = "Sailfish soup (Scratch)",
                level       = 99,
                xp          = 870,
                urns        = false,
                material    = {1, "Raw sailfish", 1, "Spices"},
                members     = true
            }
        }
    
    ---------------------------------  Pie  ---------------------------------------------
    methods["Pie"] = {
            {
                name        = "Redberry pie",
                level       = 10,
                xp          = 78,
                material    = {1, "Uncooked berry pie"},
                noBurn      = 55
            }, {
                name        = "Redberry pie",
                title       = "Redberry pie (Scratch)",
                level       = 10,
                xp          = 78,
                material    = {1, "Redberries", 1, "Pie shell"},
                mcount      = 2,
                noBurn      = 55
            }, {
                name        = "Meat pie",
                level       = 20,
                xp          = 110,
                material    = {1, "Uncooked meat pie"}
            }, {
                name        = "Meat pie",
                title       = "Meat pie (Scratch)",
                level       = 20,
                xp          = 110,
                material    = {1, "Cooked chicken", 1, "Pie shell"},
                mcount      = 2
            }, {
                name        = "Mud pie",
                level       = 29,
                xp          = 128,
                material    = {1, "Raw mud pie"},
                members     = true
            }, {
                name        = "Mud pie",
                title       = "Mud pie (Scratch)",
                level       = 29,
                xp          = 128,
                material    = {1, "Compost", 1, "Pie shell", 1, "Bucket of water"},
                mcount      = 3
            }, {
                name        = "Apple pie",
                level       = 30,
                xp          = 130,
                material    = {1, "Uncooked apple pie"}
            }, {
                name        = "Apple pie",
                title       = "Apple pie (Scratch)",
                level       = 30,
                xp          = 130,
                material    = {1, "Cooking apple", 1, "Pie shell"},
                mcount      = 2
            }, {
                name        = "Garden pie",
                level       = 34,
                xp          = 138,
                material    = {1, "Raw garden pie"},
                members     = true
            }, {
                name        = "Garden pie",
                title       = "Garden pie (Scratch)",
                level       = 34,
                xp          = 138,
                material    = {1, "Tomato", 1, "Onion", 1, "Cabbage", 1, "Pie shell"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Fish pie",
                level       = 47,
                xp          = 164,
                material    = {1, "Raw fish pie"},
                members     = true
            }, {
                name        = "Fish pie",
                title       = "Fish pie (Scratch)",
                level       = 47,
                xp          = 164,
                material    = {1, "Trout", 1, "Cod", 1, "Raw potato", 1, "Pie shell"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Admiral pie",
                level       = 70,
                xp          = 210,
                material    = {1, "Raw admiral pie"},
                members     = true
            }, {
                name        = "Admiral pie",
                title       = "Admiral pie (Scratch)",
                level       = 70,
                xp          = 210,
                material    = {1, "Salmon", 1, "Tuna", 1, "Raw potato", 1, "Pie shell"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Pork pie",
                level       = 74,
                xp          = 210,
                material    = {1, "Uncooked pork pie"},
                mtrade      = 0,
                members     = true
            }, {
                name        = "Pork pie",
                title       = "Pork pie (Semi-Scratch)",
                level       = 74,
                xp          = 210,
                material    = {3, "Bacon", 1, "Pie shell"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Pork pie",
                title       = "Pork pie (Scratch)",
                level       = 74,
                xp          = 210,
                material    = {1, "Pie shell", 3, "Raw bacon"},
                mcount      = 1,
                members     = true
            }, {
                name        = "Wild pie",
                level       = 85,
                xp          = 240,
                material    = {1, "Part wild pie (raw bear meat)", 1, "Part wild pie (raw chompy)"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Wild pie",
                title       = "Wild pie (Scratch)",
                level       = 85,
                xp          = 240,
                material    = {1, "Raw bear meat", 1, "Raw chompy", 1, "Raw rabbit", 1, "Pie shell"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Wilder pie",
                level       = 85,
                xp          = 250,
                material    = {1, "Raw wild pie", 1, "Crushed dragonstone"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Wilder pie",
                level       = 85,
                xp          = 250,
                material    = {1, "Raw wild pie", 1, "Dragonstone"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Wilder pie",
                title       = "Wilder pie (Semi-Scratch)",
                level       = 85,
                xp          = 240,
                material    = {1, "Raw bear meat", 1, "Raw chompy", 1, "Raw rabbit", 1, "Dragonstone", 1, "Pie shell"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Wilder pie",
                title       = "Wilder pie (Scratch)",
                level       = 85,
                xp          = 240,
                material    = {1, "Raw bear meat", 1, "Raw chompy", 1, "Raw rabbit", 1, "Crushed dragonstone", 1, "Pie shell"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Summer pie",
                level       = 95,
                xp          = 260,
                material    = {1, "Raw summer pie"},
                members     = true
            }, {
                name        = "Summer pie",
                title       = "Summer pie (Scratch)",
                level       = 95,
                xp          = 260,
                material    = {1, "Strawberry", 1, "Watermelon", 1, "Cooking apple", 1, "Pie shell"},
                mcount      = 4,
                members     = true
            }
        }
    
    ---------------------------------  Cheesecake  ------------------------------------------
    methods["Cheesecake"] = {
            {
                name        = "Cheesecake",
                level       = 32,
                xp          = 170,
                material    = {1, "Biscuits", 1, "Cream cheese", 1, "Pot of cream"},
                mcount      = 3
            }, {
                name        = "Vanilla cheesecake",
                level       = 32,
                xp          = 180,
                material    = {1, "Biscuits", 1, "Vanilla cream cheese", 1, "Pot of cream"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Chocolate cheesecake",
                level       = 32,
                xp          = 190,
                material    = {1, "Biscuits", 1, "Chocolate cream cheese", 1, "Pot of cream"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Strawberry cheesecake",
                level       = 47,
                xp          = 200,
                material    = {1, "Biscuits", 1, "Strawberry cream cheese", 1, "Pot of cream"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Lemon cheesecake",
                level       = 52,
                xp          = 210,
                material    = {1, "Biscuits", 1, "Cream cheese", 1, "Pot of cream", 1, "Lemon"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Bacon cheesecake",
                level       = 57,
                xp          = 220,
                material    = {1, "Biscuits", 1, "Cream cheese", 1, "Pot of cream", 1, "Bacon"},
                mcount      = 4,
                members     = true
            }
        }

    ---------------------------------  Pizza  ---------------------------------------------
    methods["Pizza"] = {
            {
                name        = "Plain pizza",
                level       = 35,
                xp          = 143,
                material    = {1, "Uncooked pizza"},
                noBurn      = 68
            }, {
                name        = "Plain pizza",
                title       = "Plain pizza (Scratch)",
                level       = 35,
                xp          = 143,
                material    = {1, "Tomato", 1, "Cheese", 1, "Pizza base"},
                mcount      = 3,
                noBurn      = 68
            }, {
                name        = "Meat pizza",
                level       = 45,
                xp          = 26,
                material    = {1, "Plain pizza", 1, "Cooked chicken"},
                mcount      = 2
            }, {
                name        = "Meat pizza",
                title       = "Meat pizza (Scratch)",
                level       = 45,
                xp          = 169,
                material    = {1, "Tomato", 1, "Cheese", 1,"Cooked chicken", 1, "Pizza base"},
                mcount      = 4
            }, {
                name        = "Anchovy pizza",
                level       = 55,
                xp          = 39,
                material    = {1, "Plain pizza", 1, "Anchovies"},
                mcount      = 2
            }, {
                name        = "Anchovy pizza",
                title       = "Anchovy pizza (Scratch)",
                level       = 55,
                xp          = 182,
                material    = {1, "Tomato", 1, "Cheese", 1,"Anchovies", 1, "Pizza base"},
                mcount      = 4,
                noBurn      = 68
            }, {
                name        = "Pineapple pizza",
                level       = 65,
                xp          = 45,
                material    = {1, "Plain pizza", 1, "Pineapple ring"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Pineapple pizza",
                title       = "Pineapple pizza (Scratch)",
                level       = 65,
                xp          = 188,
                material    = {1, "Tomato", 1, "Cheese", 1,"Pineapple ring", 1, "Pizza base"},
                mcount      = 4,
                noBurn      = 68,
                members     = true
            }, {
                name        = "Banana pizza",
                level       = 85,
                xp          = 89,
                material    = {1, "Plain pizza", 1, "Sliced banana", 1, "Nuts", 1, "Curry leaf", 1, "Cooked chicken"},
                trade		= 0,
                mcount      = 5,
                members     = true
            }, {
                name        = "Banana pizza",
                title       = "Banana pizza (Scratch)",
                level       = 85,
                xp          = 232,
                material    = {1, "Tomato", 1, "Cheese", 1, "Pizza base", 1, "Banana", 1, "Nuts", 1, "Curry leaf", 1, "Cooked chicken"},
                trade		= 0,
                mcount      = 7,
                noBurn      = 68,
                members     = true
            }
        }

    ---------------------------------  Potatoes  ---------------------------------------------
    methods["Potatoes"] = {
            {
                name        = "Baked potato",
                level       = 7,
                xp          = 15,
                material    = {1, "Raw potato"}
            }, {
                name        = "Potato with butter",
                level       = 39,
                xp          = 15,
                material    = {1, "Raw potato", 1, "Pat of butter"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Potato with butter",
                title       = "Potato with butter (Scratch)",
                level       = 39,
                xp          = 55,
                material    = {1, "Raw potato", 1, "Pat of butter"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Chilli potato",
                level       = 41,
                xp          = 15,
                material    = {1, "Potato with butter", 1, "Chilli con carne"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Chilli potato",
                title       = "Chilli potato (Scratch)",
                level       = 41,
                xp          = 120,
                material    = {1, "Raw potato", 1, "Pat of butter", 1, "Cooked meat", 1, "Garlic", 1, "Gnome spice"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Potato with cheese",
                level       = 47,
                xp          = 40,
                material    = {1, "Potato with butter", 1, "Cheese"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Potato with cheese",
                title       = "Potato with cheese (Scratch)",
                level       = 47,
                xp          = 95,
                material    = {1, "Raw potato", 1, "Pat of butter", 1, "Cheese"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Egg potato",
                level       = 51,
                xp          = 45,
                material    = {1, "Potato with butter", 1,"Egg and tomato"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Egg potato",
                title       = "Egg potato (Scratch)",
                level       = 51,
                xp          = 200,
                material    = {1, "Raw potato", 1, "Pat of butter", 1,"Egg", 1,"Tomato"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Mushroom potato",
                level       = 64,
                xp          = 55,
                material    = {1, "Potato with butter", 1, "Mushroom & onion"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Mushroom potato",
                title       = "Mushroom potato (Scratch)",
                level       = 64,
                xp          = 352,
                material    = {1, "Raw potato", 1, "Pat of butter", 1, "Onion", 1, "Bittercap mushroom"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Tuna potato",
                level       = 68,
                xp          = 10,
                material    = {1, "Potato with butter", 1, "Tuna and corn"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Tuna potato",
                title       = "Tuna potato (Semi-Scratch)",
                level       = 68,
                xp          = 214,
                material    = {1, "Potato with butter", 1, "Tuna", 1, "Sweetcorn"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Tuna potato",
                title       = "Tuna potato (Scratch)",
                level       = 68,
                xp          = 433,
                material    = {1, "Raw potato", 1, "Pat of butter", 1, "Raw tuna", 1, "Sweetcorn"},
                mcount      = 4,
                members     = true
            }
        }

    ---------------------------------  Brewing  ---------------------------------------------
    methods["Brewing"] = {
            {
                name        = "Nettle tea",
                level       = 20,
                xp          = 53,
                urns        = false,
                material    = {1, "Bowl of water", 1, "Nettles"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Jug of wine",
                level       = 35,
                xp          = 200,
                urns        = false,
                material    = {1, "Jug of water", 1, "Grapes"},
                mcount      = 2
            }, {
                name        = "Cider (4)",
                level       = 14,
                xp          = 182,
                urns        = false,
                material    = {16, "Cooking apple", 1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Dwarven stout (4)",
                level       = 19,
                xp          = 215,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 4, "Hammerstone hops", 1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5
            }, {
                name        = "Asgarnian ale (4)",
                level       = 24,
                xp          = 248,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 4, "Asgarnian hops", 1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5
            }, {
                name        = "Greenman's ale (4)",
                level       = 29,
                xp          = 281,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 4, "Clean harralander", 1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Mind bomb (4)",
                level       = 34,
                xp          = 314,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 4, "Yanillian hops",  1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5
            }, {
                name        = "Dragon bitter (4)",
                level       = 39,
                xp          = 347,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 4, "Krandorian hops",  1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Moonlight mead (4)",
                level       = 44,
                xp          = 380,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 4, "Bittercap mushroom", 1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Axeman's folly (4)",
                level       = 49,
                xp          = 413,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 1, "Oak roots", 1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Chef's delight (4)",
                level       = 54,
                xp          = 446,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 4, "Chocolate dust", 1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Slayer's respite (4)",
                level       = 59,
                xp          = 479,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 4, "Wildblood hops", 1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Pigswill (4)",
                level       = 64,
                xp          = 380,
                urns        = false,
                material    = { 2, "Bucket of water", 2, "Barley malt", 1, "Ale yeast", 2, "Calquat keg"},
                mcount      = 5,
                members     = true
            }
        }

    ---------------------------------  Churning  ---------------------------------------------
    methods["Churning"] = {
            {
                name        = "Pot of cream",
                level       = 21,
                xp          = 18,
                material    = {1, "Bucket of milk"}
            }, {
                name        = "Cream cheese",
                level       = 32,
                xp          = 80,
                material    = {1, "Bucket of milk"}
            }, {
                name        = "Chocolate cream cheese",
                level       = 35,
                xp          = 100,
                material    = {1, "Chocolatey milk"},
                mtrade      = 0,
                members     = true
            }, {
                name        = "Vanilla cream cheese",
                level       = 35,
                xp          = 90,
                material    = {1, "Vanilla milk"},
                members     = true
            }, {
                name        = "Pat of butter",
                level       = 38,
                xp          = 22.5,
                material    = {1, "Pot of cream"}
            }, {
                name        = "Pat of butter",
                title       = "Pat of butter (Scratch)",
                level       = 38,
                xp          = 40.5,
                material    = {1, "Bucket of milk"}
            }, {
                name        = "Strawberry cream cheese",
                level       = 45,
                xp          = 110,
                material    = {1, "Strawberry milk"},
                members     = true
            }, {
                name        = "Cheese",
                level       = 48,
                xp          = 23.5,
                material    = {1, "Pat of butter"}
            }, {
                name        = "Cheese",
                title       = "Cheese (Semi-Scratch)",
                level       = 48,
                xp          = 46,
                material    = {1, "Pot of cream"}
            }, {
                name        = "Cheese",
                title       = "Cheese (Scratch)",
                level       = 48,
                xp          = 64,
                material    = {1, "Bucket of milk"}
            }
        }
    
    ---------------------------------  Other  ---------------------------------------------
    methods["Other"] = {
            {
                name        = "Bread",
                level       = 1,
                xp          = 40,
                material    = {1, "Bread dough"}
            }, {
                name        = "Chilli con carne",
                level       = 11,
                xp          = 25,
                material    = {1, "Garlic", 1, "Gnome spice", 1, "Cooked meat", 1, "Bowl"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Scrambled egg",
                level       = 13,
                xp          = 50,
                material    = {1, "Egg", 1, "Bowl"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Egg and tomato",
                level       = 23,
                xp          = 50,
                material    = {1, "Egg", 1, "Tomato", 1, "Bowl"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Stew",
                level       = 25,
                xp          = 117,
                material    = {1, "Raw potato", 1, "Cooked meat", 1, "Bowl of water"},
                mcount      = 3
            }, {
                name        = "Spicy sauce",
                level       = 9,
                xp          = 25,
                material    = {1, "Garlic", 1, "Gnome spice", 1, "Bowl"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Cooked sweetcorn",
                level       = 28,
                xp          = 104,
                material    = {1, "Sweetcorn"},
                members     = true
            }, {
                name        = "Biscuits",
                level       = 32,
                xp          = 100,
                material    = {1, "Biscuit dough"}
            }, {
                name        = "Biscuits",
                title       = "Biscuits (Scratch)",
                level       = 32,
                xp          = 101,
                material    = {1, "Pot of flour", 1, "Pat of butter"},
                mcount      = 2
            }, {
                name        = "Cake",
                level       = 40,
                xp          = 180,
                material    = {1, "Egg", 1, "Pot of flour", 1, "Bucket of milk"},
                mcount      = 3
            }, {
                name        = "Fried onions",
                level       = 42,
                xp          = 60,
                material    = {1, "Onion", 1,"Bowl"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Chocolate cake",
                level       = 50,
                xp          = 30,
                material    = {1, "Cake", 1, "Chocolate bar"},
                mcount      = 2
            }, {
                name        = "Chocolate cake",
                title       = "Chocolate cake (Scratch)",
                level       = 50,
                xp          = 210,
                material    = {1, "Egg", 1, "Pot of flour", 1, "Bucket of milk", 1, "Chocolate bar"},
                mcount      = 4
            }, {
                name        = "Fried mushrooms",
                level       = 46,
                xp          = 60,
                material    = {1, "Bittercap mushroom", 1, "Bowl"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Mushroom & onion",
                level       = 57,
                xp          = 120,
                material    = {1, "Bittercap mushroom", 1, "Onion", 1, "Bowl"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Pitta bread",
                level       = 58,
                xp          = 40,
                material    = {1, "Pitta dough"},
                members     = true
            }, {
                name        = "Curry",
                level       = 60,
                xp          = 280,
                material    = {1, "Raw potato", 1, "Cooked meat", 3, "Curry leaf", 1, "Bowl"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Curry",
                level       = 60,
                xp          = 280,
                material    = {1, "Raw potato", 1, "Cooked meat", 1, "Spice", 1, "Bowl"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Tuna and corn",
                level       = 67,
                xp          = 204,
                material    = {1, "Raw tuna", 1, "Sweetcorn", 1, "Bowl"},
                mcount      = 3,
                members     = true
            }
        }

    ---------------------------------  Gnome Drinks  ---------------------------------------------
    methods["Gnome Drinks"] = {
            {
                name        = "Fruit Blast",
                level       = 6,
                xp          = 50,
                material    = {2, "Lemon", 1, "Pineapple", 1, "Orange"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Pineapple Punch",
                level       = 8,
                xp          = 70,
                material    = {1, "Lemon", 2, "Orange", 3, "Pineapple", 1, "Lime"},
                mcount      = 4
            }, {
                name        = "Wizard Blizzard",
                level       = 18,
                xp          = 110,
                material    = {2, "Vodka", 1, "Gin", 1, "Orange", 2, "Lime", 1, "Lemon", 2, "Pineapple"},
                mcount      = 6,
                members     = true
            }, {
                name        = "Short Green Guy",
                level       = 20,
                xp          = 120,
                material    = {1, "Vodka", 4, "Lime", 1, "Equa leaves"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Drunk Dragon",
                level       = 32,
                xp          = 160,
                material    = {1, "Vodka", 1, "Gin", 1, "Dwellberries", 1, "Pineapple", 1, "Pot of cream"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Chocolate Saturday",
                level       = 33,
                xp          = 170,
                material    = {1, "Whisky", 1, "Equa leaves", 1, "Bucket of milk", 1, "Chocolate dust", 1, "Pot of cream", 1, "Chocolate bar"},
                mcount      = 6,
                members     = true
            }, {
                name        = "Blurberry Special",
                level       = 37,
                xp          = 180,
                material    = {1, "Vodka", 1, "Brandy", 1, "Gin", 1, "Equa leaves", 2, "Orange", 3, "Lemon", 1, "Lime"},
                mcount      = 7,
                members     = true
            }
        }

    ---------------------------------  Gnome Baking  ----------------------------------
    methods["Gnome Baking"] = {
            {
                name        = "Toad crunchies",
                level       = 10,
                xp          = 100,
                material    = {1, "Equa leaves", 1, "Gianne dough", 1, "Toad's legs"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Spicy crunchies",
                level       = 12,
                xp          = 100,
                material    = {2, "Equa leaves", 1, "Gianne dough"},
                mcount      = 2,
                members     = true
            }, {
                name        = "Worm crunchies",
                level       = 14,
                xp          = 100,
                material    = {1, "Equa leaves", 1, "Gianne dough", 2, "King worm"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Chocchip crunchies",
                title		= "Chocolate chip crunchies",
                level       = 16,
                xp          = 100,
                material    = {1, "Gianne dough", 2, "Chocolate bar", 1, "Chocolate dust"},
                mcount      = 3,
                members     = true
            }, {
                name        = "Fruit batta",
                level       = 25,
                xp          = 150,
                material    = {4, "Equa leaves", 1, "Gianne dough", 1, "Orange chunks", 1, "Lime chunks", 1, "Pineapple chunks"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Toad batta",
                level       = 26,
                xp          = 152,
                material    = {1, "Equa leaves", 1, "Gianne dough", 1, "Toad's legs", 1, "Cheese"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Worm batta",
                level       = 27,
                xp          = 154,
                material    = {1, "Equa leaves", 1, "Gianne dough", 1, "King worm", 1, "Cheese"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Vegetable batta",
                level       = 28,
                xp          = 156,
                material    = {1, "Equa leaves", 1, "Gianne dough", 2, "Tomato", 1, "Dwellberries", 1, "Cabbage", 1, "Cheese", 1, "Onion"},
                mcount      = 7,
                members     = true
            }, {
                name        = "Cheese+tom batta",
                title       = "Cheese and tomato batta",
                level       = 29,
                xp          = 158,
                material    = {1, "Equa leaves", 1, "Gianne dough", 1, "Tomato", 1, "Cheese"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Worm hole",
                level       = 30,
                xp          = 170,
                material    = {1, "Equa leaves", 1, "Gianne dough", 4, "King worm", 2, "Onion"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Veg ball",
                level       = 35,
                xp          = 175,
                material    = {1, "Equa leaves", 1, "Gianne dough", 2, "Onion", 2, "Raw potato"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Tangled toads' legs",
                level       = 40,
                xp          = 185,
                material    = {2, "Equa leaves", 1, "Gianne dough", 4, "Toad's legs", 2, "Cheese", 1, "Dwellberries"},
                mcount      = 5,
                members     = true
            }, {
                name        = "Chocolate bomb",
                level       = 42,
                xp          = 190,
                material    = {1, "Equa leaves", 1, "Gianne dough", 4, "Chocolate bar", 2, "Pot of cream", 1, "Chocolate dust"},
                mcount      = 5,
                members     = true
            }
        }

    ---------------------------------  Primal Feast  --------------------------------
    methods["Primal Feast"] = {
            {
                name        = "Primal dessert",
                level       = 99,
                xp          = 800,
                material    = {1, "Dragonfruit", 1, "Golden watermelon", 1, "Mango", 1, "White strawberry"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Primal feast",
                level       = 115,
                xp          = 1000,
                material    = {1, "Primal dessert", 1, "Primal main course", 1, "Primal starter"},
                mcount      = 3,
                trade       = 0,
                members     = true
            }, {
                name        = "Primal starter",
                level       = 99,
                xp          = 800,
                material    = {1, "Cannonball cabbage", 1, "Sweet potato", 1, "Rainbow sweetcorn", 1, "Raw oculi apoterrasaur meat"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Primal main course",
                level       = 99,
                xp          = 800,
                material    = {1, "Heirloom tomato", 1, "Raw malletops meat", 1, "Raw pavosaurus rex meat", 1, "Red onion"},
                mcount      = 4,
                members     = true
            }, {
                name        = "Primal feast",
                title       = "Primal feast (Scratch)",
                level       = 115,
                xp          = 3400,
                material    = {1, "Cannonball cabbage", 1, "Sweet potato", 1, "Rainbow sweetcorn", 1, "Raw oculi apoterrasaur meat", 1, "Heirloom tomato", 1, "Raw malletops meat", 1, "Raw pavosaurus rex meat", 1, "Red onion", 1, "Dragonfruit", 1, "Golden watermelon", 1, "Mango", 1, "White strawberry"},
                mcount      = 12,
                trade       = 0,
                members     = true
            }
        }

    ---------------------------------  Dungeoneering  --------------------------------
    methods["Dungeoneering"] = {
            {
                name        = "Baked cave potato",
                title       = "Cave potato",
                level       = 1,
                xp          = 9,
                urns        = false,
                material    = {1, "Raw cave potato"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Gissel potato",
                level       = 1,
                xp          = 12.5,
                urns        = false,
                material    = {1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Edicap potato",
                level       = 1,
                xp          = 7.7,
                urns        = false,
                material    = {1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Heim crab",
                level       = 1,
                xp          = 22,
                urns        = false,
                material    = {1, "Raw heim crab"},
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Heim crab potato",
                level       = 3,
                xp          = 31,
                urns        = false,
                material    = {1, "Heim crab", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Heim crab & gissel potato",
                level       = 6,
                xp          = 41.4,
                urns        = false,
                material    = {1, "Heim crab", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Heim crab & gissel potato",
                level       = 6,
                xp          = 41.4,
                urns        = false,
                material    = {1, "Heim crab potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Heim crab & edicap potato",
                level       = 9,
                xp          = 51.9,
                urns        = false,
                material    = {1, "Heim crab", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Heim crab & edicap potato",
                level       = 9,
                xp          = 51.9,
                urns        = false,
                material    = {1, "Heim crab potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Red-eye",
                level       = 10,
                xp          = 41,
                urns        = false,
                material    = {1, "Raw red-eye"},
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Red-eye potato",
                level       = 13,
                xp          = 50,
                urns        = false,
                material    = {1, "Red-eye", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Red-eye & gissel potato",
                level       = 16,
                xp          = 65.8,
                urns        = false,
                material    = {1, "Red-eye", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Red-eye & gissel potato",
                level       = 16,
                xp          = 65.8,
                urns        = false,
                material    = {1, "Red-eye potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Red-eye & edicap potato",
                level       = 19,
                xp          = 82.3,
                urns        = false,
                material    = {1, "Red-eye", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Red-eye & edicap potato",
                level       = 19,
                xp          = 82.3,
                urns        = false,
                material    = {1, "Red-eye potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Dusk eel",
                level       = 20,
                xp          = 61,
                urns        = false,
                material    = {1, "Raw dusk eel"},
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Dusk eel potato",
                level       = 23,
                xp          = 70,
                urns        = false,
                material    = {1, "Dusk eel", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Dusk eel & gissel potato",
                level       = 26,
                xp          = 91.8,
                urns        = false,
                material    = {1, "Dusk eel", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Dusk eel & gissel potato",
                level       = 26,
                xp          = 91.8,
                urns        = false,
                material    = {1, "Dusk eel potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Dusk eel & edicap potato",
                level       = 29,
                xp          = 114.3,
                urns        = false,
                material    = {1, "Dusk eel", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Dusk eel & edicap potato",
                level       = 29,
                xp          = 114.3,
                urns        = false,
                material    = {1, "Dusk eel potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Giant flatfish",
                level       = 30,
                xp          = 82,
                urns        = false,
                material    = {1, "Raw giant flatfish"},
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Giant flatfish potato",
                title       = "Flatfish potato",
                level       = 33,
                xp          = 91,
                urns        = false,
                material    = {1, "Giant flatfish", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Flatfish & gissel potato",
                level       = 36,
                xp          = 119.1,
                urns        = false,
                material    = {1, "Giant flatfish", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Flatfish & gissel potato",
                level       = 36,
                xp          = 119.1,
                urns        = false,
                material    = {1, "Giant flatfish potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Flatfish & edicap potato",
                level       = 39,
                xp          = 147.9,
                urns        = false,
                material    = {1, "Giant flatfish", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Flatfish & edicap potato",
                level       = 39,
                xp          = 147.9,
                urns        = false,
                material    = {1, "Giant flatfish potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Short-finned eel",
                level       = 40,
                xp          = 103,
                urns        = false,
                material    = {1, "Raw short-finned eel"},
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Short-fin eel potato",
                title       = "Short-fin potato",
                level       = 43,
                xp          = 112,
                urns        = false,
                material    = {1, "Short-finned eel", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Short-fin & gissel potato",
                level       = 46,
                xp          = 146.4,
                urns        = false,
                material    = {1, "Short-finned eel", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Short-fin & gissel potato",
                level       = 46,
                xp          = 146.4,
                urns        = false,
                material    = {1, "Short-fin eel potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Short-fin & edicap potato",
                level       = 49,
                xp          = 181.5,
                urns        = false,
                material    = {1, "Short-finned eel", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Short-fin & edicap potato",
                level       = 49,
                xp          = 181.5,
                urns        = false,
                material    = {1, "Short-fin eel potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Web snipper",
                level       = 50,
                xp          = 124,
                urns        = false,
                material    = {1, "Raw web snipper"},
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Snipper potato",
                level       = 53,
                xp          = 133,
                urns        = false,
                material    = {1, "Web snipper", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Snipper & gissel potato",
                level       = 56,
                xp          = 173.7,
                urns        = false,
                material    = {1, "Web snipper", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Snipper & gissel potato",
                level       = 56,
                xp          = 173.7,
                urns        = false,
                material    = {1, "Snipper potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Snipper & edicap potato",
                level       = 59,
                xp          = 215.1,
                urns        = false,
                material    = {1, "Web snipper", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Snipper & edicap potato",
                level       = 59,
                xp          = 215.1,
                urns        = false,
                material    = {1, "Snipper potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Bouldabass",
                level       = 60,
                xp          = 146,
                urns        = false,
                material    = {1, "Raw bouldabass"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Bouldabass potato",
                level       = 63,
                xp          = 155,
                urns        = false,
                material    = {1, "Bouldabass", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Bouldabass & gissel potato",
                level       = 66,
                xp          = 202.3,
                urns        = false,
                material    = {1, "Bouldabass", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Bouldabass & gissel potato",
                level       = 66,
                xp          = 202.3,
                urns        = false,
                material    = {1, "Bouldabass potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Bouldabass & edicap potato",
                level       = 69,
                xp          = 250.3,
                urns        = false,
                material    = {1, "Bouldabass", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Bouldabass & edicap potato",
                level       = 69,
                xp          = 250.3,
                urns        = false,
                material    = {1, "Bouldabass potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Salve eel",
                level       = 70,
                xp          = 168,
                urns        = false,
                material    = {1, "Raw salve eel"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Salve eel potato",
                level       = 73,
                xp          = 177,
                urns        = false,
                material    = {1, "Salve eel", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Salve eel & gissel potato",
                level       = 76,
                xp          = 230.9,
                urns        = false,
                material    = {1, "Salve eel", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Salve eel & gissel potato",
                level       = 76,
                xp          = 230.9,
                urns        = false,
                material    = {1, "Salve eel potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Salve eel & edicap potato",
                level       = 79,
                xp          = 285.5,
                urns        = false,
                material    = {1, "Salve eel", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Salve eel & edicap potato",
                level       = 79,
                xp          = 285.5,
                urns        = false,
                material    = {1, "Salve eel potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Blue crab",
                level       = 80,
                xp          = 191,
                urns        = false,
                material    = {1, "Raw blue crab"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Blue crab potato",
                level       = 83,
                xp          = 200,
                urns        = false,
                material    = {1, "Blue crab", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Blue crab & gissel potato",
                level       = 86,
                xp          = 260.8,
                urns        = false,
                material    = {1, "Blue crab", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Blue crab & gissel potato",
                level       = 86,
                xp          = 260.8,
                urns        = false,
                material    = {1, "Blue crab potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Blue crab & edicap potato",
                level       = 89,
                xp          = 322.3,
                urns        = false,
                material    = {1, "Blue crab", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Blue crab & edicap potato",
                level       = 89,
                xp          = 322.3,
                urns        = false,
                material    = {1, "Blue crab potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cave moray",
                level       = 90,
                xp          = 215,
                urns        = false,
                material    = {1, "Raw cave moray"},
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Cave moray potato",
                title       = "Moray potato",
                level       = 93,
                xp          = 224,
                urns        = false,
                material    = {1, "Cave moray", 1, "Raw cave potato"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Moray & gissel potato",
                level       = 96,
                xp          = 292,
                urns        = false,
                material    = {1, "Cave moray", 1, "Raw cave potato", 1, "Gissel mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Moray & gissel potato",
                level       = 96,
                xp          = 292,
                urns        = false,
                material    = {1, "Cave moray potato", 1, "Gissel mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Moray & edicap potato",
                level       = 99,
                xp          = 360.7,
                urns        = false,
                material    = {1, "Cave moray", 1, "Raw cave potato", 1, "Edicap mushroom"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Moray & edicap potato",
                level       = 99,
                xp          = 360.7,
                urns        = false,
                material    = {1, "Cave moray potato", 1, "Edicap mushroom"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }
        }
    
    ---------------------------------  Urns  -------------------------------------
    methods["Urns"] ={
            {
                name        = "Cracked cooking urn",
                xp          = 2400,
                urns        = false,
                maxLevel    = 10,
                material    = {1, "Cracked cooking urn (no rune)", 1, "Fire rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Cracked cooking urn",
                title       = "Cracked cooking urn (Urn Enhancer)",
                xp          = 2500,
                urns        = false,
                maxLevel    = 10,
                material    = {1, "Cracked cooking urn (no rune)", 1, "Fire rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Fragile cooking urn",
                xp          = 3300,
                urns        = false,
                maxLevel    = 25,
                material    = {1, "Fragile cooking urn (no rune)", 1, "Fire rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Fragile cooking urn",
                title       = "Fragile cooking urn (Urn Enhancer)",
                xp          = 3437.5,
                urns        = false,
                maxLevel    = 25,
                material    = {1, "Fragile cooking urn (no rune)", 1, "Fire rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Plain cooking urn",
                xp          = 5700,
                urns        = false,
                maxLevel    = 40,
                material    = {1, "Plain cooking urn (no rune)", 1, "Fire rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Plain cooking urn",
                title       = "Plain cooking urn (Urn Enhancer)",
                xp          = 5937.5,
                urns        = false,
                maxLevel    = 40,
                material    = {1, "Plain cooking urn (no rune)", 1, "Fire rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Strong cooking urn",
                xp          = 6300,
                urns        = false,
                maxLevel    = 55,
                material    = {1, "Strong cooking urn (no rune)", 1, "Fire rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Strong cooking urn",
                title       = "Strong cooking urn (Urn Enhancer)",
                xp          = 6562.5,
                urns        = false,
                maxLevel    = 55,
                material    = {1, "Strong cooking urn (no rune)", 1, "Fire rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Decorated cooking urn",
                xp          = 9285,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated cooking urn (no rune)", 1, "Fire rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Decorated cooking urn",
                title       = "Decorated cooking urn (Urn Enhancer)",
                xp          = 9671.875,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated cooking urn (no rune)", 1, "Fire rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Exquisite cooking urn",
                xp          = 14037.5,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite cooking urn (no rune)", 1, "Fire rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Exquisite cooking urn",
                title       = "Exquisite cooking urn (Urn Enhancer)",
                xp          = 14739.375,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite cooking urn (no rune)", 1, "Fire rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }
        }
        
    if trainMethod == "All" then
        -- All
        all_methods = {}
        loop_all = 0
        
        for _,v in pairs(methods) do
            for _,u in pairs (v) do
                loop_all = loop_all + 1
                all_methods[loop_all] = u
            end
        end
        return all_methods
    else
        -- Returns selection
        return methods[trainMethod]
    end
end