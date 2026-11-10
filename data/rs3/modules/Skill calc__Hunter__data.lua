--[=[
     Notations found in this Module:
        * name:     Name of target
        * icon:      Alternate image location
        * level:    Level required to complete
        * xp:       Experience gained
        * urns:     Indicates whether the item fills urns
        * maxLevel: Highest level of an item an urn can be filled
        * Product:  Main reward from capturing target
        * title:    Alternative name of object
            - Used to clarify the difference from a similar object or offer a cleaner name
        * trade:    Indicates whether the product can be found in the GE
        * currency: Indicates an alternative currency being used
        * value:    Specifies the products value in alternative currency
        * members:  Indicates whether an item is members-only content
--]=]
local skillData = {}
 
return function(trainMethod)
    -- Tracking & Falconry
    if trainMethod == "Tracking and Falconry" then
        local methods = 
        {
            {
                name        = "Polar kebbit",
                level       = 1,
                xp          = 17.5,
                product     = "Polar kebbit fur"
            }, {
                name        = "Common kebbit",
                level       = 3,
                xp          = 41,
                product     = "Common kebbit fur",
                members     = true
            }, {
                name        = "Feldip weasel",
                icon        = "Feldip weasel icon",
                level       = 7,
                xp          = 54.5,
                product     = "Feldip weasel fur",
                members     = true
            }, {
                name        = "Desert devil",
                level       = 13,
                xp          = 93,
                product     = "Desert devil fur",
                members     = true
            }, {
                name        = "Spotted kebbit",
                level       = 42,
                xp          = 104,
                product     = "Spotted kebbit fur",
                members     = true
            }, {
                name        = "Penguin (Hunter)",
                title       = "Penguin",
                icon        = "Penguin (item)",
                level       = 45,
                xp          = 250,
                members     = true
            }, {
                name        = "Razor-backed kebbit",
                icon        = "Razor-backed kebbit",
                level       = 49,
                xp          = 470,
                product     = "Long kebbit spike",
                members     = true
            }, {
                name        = "Dark kebbit",
                level       = 57,
                xp          = 99,
                product     = "Dark kebbit fur",
                members     = true
            }, {
                name        = "Dashing kebbit",
                level       = 69,
                xp          = 156,
                product     = "Dashing kebbit fur",
                members     = true
            }
        }
        return methods
    end

    -- Snaring
    if trainMethod == "Snaring" then
        local methods = 
        {
            {
                name        = "Crimson swift",
                icon        = "Crimson swift icon",
                level       = 1,
                xp          = 22,
                product     = "Red feather"
            }, {
                name        = "Golden warbler",
                icon        = "Golden warbler icon",
                level       = 5,
                xp          = 41,
                product     = "Yellow feather",
                members     = true
            }, {
                name        = "Copper longtail",
                icon        = "Copper longtail icon",
                level       = 9,
                xp          = 55,
                product     = "Orange feather",
                members     = true
            }, {
                name        = "Cerulean twitch",
                icon        = "Cerulean twitch icon",
                level       = 11,
                xp          = 61,
                product     = "Blue feather",
                members     = true
            }, {
                name        = "Tropical wagtail",
                icon        = "Tropical wagtail icon",
                level       = 19,
                xp          = 100,
                product     = "Stripy feather",
                members     = true
            }, {
                name        = "White rabbit",
                icon        = "White rabbit icon",
                level       = 27,
                xp          = 144,
                product     = "Rabbit foot",
                members     = true
            }, {
                name        = "Jackalope",
                icon        = "Jackalope icon",
                level       = 32,
                xp          = 202,
                product     = "Jackalope antlers",
                members     = true
            }, {
                name        = "Wimpy bird",
                icon        = "Wimpy bird icon",
                level       = 39,
                xp          = 167,
                product     = "Wimpy feather",
                members     = true
            }
        }
        return methods
    end

    -- Nets & Sprites
    if trainMethod == "Nets and Sprites" then
        local methods = 
        {
            {
                name        = "Ruby harvest",
                icon        = "Ruby harvest icon",
                level       = 15,
                xp          = 24,
                product     = "Ruby harvest jar",
                members     = true
            }, {
                name        = "Sapphire glacialis",
                icon        = "Sapphire glacialis icon",
                level       = 25,
                xp          = 34,
                product     = "Sapphire glacialis jar",
                members     = true
            }, {
                name        = "Orange salamander (Hunter)",
                title       = "Orange salamander",
                icon        = "Orange salamander",
                level       = 29,
                xp          = 204,
                bait        = "Marrentill tar",
                product     = "Orange salamander",
                members     = true
            }, {
                name        = "Squirrel",
                icon        = "Baby squirrel (light grey)",
                level       = 29.1,
                xp          = 152,
                bait        = "Nuts",
                product     = "Baby squirrel (light grey), Baby squirrel",
                trade       = 0,
                members     = true
            }, {
                name        = "Green salamander (Hunter)",
                title       = "Green salamander",
                icon        = "Green salamander",
                level       = 29.2,
                xp          = 76,
                bait        = "Guam tar",
                product     = "Green salamander",
                members     = true
            }, {
                name        = "Snowy knight",
                icon        = "Snowy knight icon",
                level       = 35,
                xp          = 44,
                product     = "Snowy knight jar",
                members     = true
            }, {
                name        = "Black warlock",
                icon        = "Black warlock icon",
                level       = 45,
                xp          = 54,
                product     = "Black warlock jar",
                members     = true
            }, {
                name        = "Penguin (Hunter)",
                title       = "Penguin",
                icon        = "Penguin (item)",
                level       = 50,
                xp          = 250,
                bait        = "Cod",
                product     = "Penguin (item), Penguin",
                trade       = 0,
                members     = true
            }, {
                name        = "Red salamander (Hunter)",
                title       = "Red salamander",
                icon        = "Red salamander",
                level       = 59,
                xp          = 224,
                bait        = "Tarromin tar",
                product     = "Red salamander",
                members     = true
            }, {
                name        = "Black salamander (Hunter)",
                title       = "Black salamander",
                icon        = "Black salamander",
                level       = 67,
                xp          = 517,
                bait        = "Harralander tar",
                product     = "Black salamander",
                members     = true
            }, {
                name        = "Gleaelg",
                icon        = "Sprite lure",
                level       = 72,
                xp          = 145.5,
                members     = true
            }, {
                name        = "Slithtils",
                icon        = "Sprite lure",
                level       = 72.1,
                xp          = 400,
                members     = true
            }, {
                name        = "Tranart",
                icon        = "Sprite lure",
                level       = 72.2,
                xp          = 222,
                members     = true
            }, {
                name        = "Ruby harvest",
                title       = "Ruby harvest (Barehanded)",
                icon        = "Ruby harvest icon",
                level       = 80,
                xp          = 276,
                members     = true
            }, {
                name        = "Sapphire glacialis",
                title       = "Sapphire glacialis (Barehanded)",
                icon        = "Sapphire glacialis icon",
                level       = 85,
                xp          = 318,
                members     = true
            }, {
                name        = "Charming moth",
                icon        = "Charming moth icon",
                level       = 88,
                xp          = 665,
                product     = "Blue charm",
                trade       = 0,
                members     = true
            }, {
                name        = "Snowy knight",
                title       = "Snowy knight (Barehanded)",
                icon        = "Snowy knight icon",
                level       = 90,
                xp          = 335,
                members     = true
            }, {
                name        = "Black warlock",
                title       = "Black warlock (Barehanded)",
                icon        = "Black warlock icon",
                level       = 95,
                xp          = 475,
                members     = true
            }
        }
        return methods
    end
    
    if trainMethod == "Croesus" then
        local methods = 
        {
            {
                name        = "Fungal spore",
                level       = 88,
                xp          = 375,
                product     = "Fungal spore"
            }, {
                name        = "Enriched fungal spore",
                level       = 92,
                xp          = 520,
                product     = "Enriched fungal spore"
            }
        }
        return methods
    end

    -- Impling Netting - Puro-puro
    if trainMethod == "Impling Netting (Puro-Puro)" then
        local methods = 
        {
            {
                name        = "Baby impling",
                icon        = "Baby impling jar",
                level       = 17,
                xp          = 20,
                product     = "Baby impling jar",
                members     = true
            }, {
                name        = "Young impling",
                icon        = "Young impling jar",
                level       = 22,
                xp          = 48,
                product     = "Young impling jar",
                members     = true
            }, {
                name        = "Gourmet impling",
                icon        = "Gourmet impling jar",
                level       = 28,
                xp          = 82,
                product     = "Gourmet impling jar",
                members     = true
            }, {
                name        = "Earth impling",
                icon        = "Earth impling jar",
                level       = 36,
                xp          = 126,
                product     = "Earth impling jar",
                members     = true
            }, {
                name        = "Essence impling",
                icon        = "Essence impling jar",
                level       = 42,
                xp          = 160,
                product     = "Essence impling jar",
                members     = true
            }, {
                name        = "Eclectic impling",
                icon        = "Eclectic impling jar",
                level       = 50,
                xp          = 205,
                product     = "Eclectic impling jar",
                members     = true
            }, {
                name        = "Spirit impling",
                icon        = "Spirit impling jar",
                level       = 54,
                xp          = 227,
                product     = "Spirit impling jar",
                members     = true
            }, {
                name        = "Nature impling",
                icon        = "Nature impling jar",
                level       = 58,
                xp          = 250,
                product     = "Nature impling jar",
                members     = true
            }, {
                name        = "Magpie impling",
                icon        = "Magpie impling jar",
                level       = 65,
                xp          = 289,
                product     = "Magpie impling jar",
                members     = true
            }, {
                name        = "Ninja impling",
                icon        = "Ninja impling jar",
                level       = 74,
                xp          = 339,
                product     = "Ninja impling jar",
                members     = true
            }, {
                name        = "Pirate impling",
                icon        = "Pirate impling jar",
                level       = 76,
                xp          = 350,
                product     = "Pirate impling jar",
                members     = true
            }, {
                name        = "Divine impling",
                icon        = "Divine impling jar",
                level       = 79,
                xp          = 375,
                product     = "Divine impling jar",
                members     = true
            }, {
                name        = "Dragon impling",
                icon        = "Dragon impling jar",
                level       = 83,
                xp          = 390,
                product     = "Dragon impling jar",
                members     = true
            }, {
                name        = "Zombie impling",
                icon        = "Zombie impling jar",
                level       = 87,
                xp          = 412,
                product     = "Zombie impling jar",
                members     = true
            }, {
                name        = "Kingly impling",
                icon        = "Kingly impling jar",
                level       = 91,
                xp          = 434,
                product     = "Kingly impling jar",
                members     = true
            }, {
                name        = "Crystal impling",
                icon        = "Crystal impling jar",
                level       = 95,
                xp          = 525,
                product     = "Crystal impling jar",
                members     = true
            }
        }
        return methods
    end

    -- Impling Netting - Gielinor
    if trainMethod == "Impling Netting (Gielinor)" then
        local methods = 
        {
            {
                name        = "Baby impling",
                icon        = "Baby impling jar",
                level       = 17,
                xp          = 25,
                product     = "Baby impling jar",
                members     = true
            }, {
                name        = "Young impling",
                icon        = "Young impling jar",
                level       = 22,
                xp          = 65,
                product     = "Young impling jar",
                members     = true
            }, {
                name        = "Gourmet impling",
                icon        = "Gourmet impling jar",
                level       = 28,
                xp          = 113,
                product     = "Gourmet impling jar",
                members     = true
            }, {
                name        = "Earth impling",
                icon        = "Earth impling jar",
                level       = 36,
                xp          = 177,
                product     = "Earth impling jar",
                members     = true
            }, {
                name        = "Essence impling",
                icon        = "Essence impling jar",
                level       = 42,
                xp          = 225,
                product     = "Essence impling jar",
                members     = true
            }, {
                name        = "Eclectic impling",
                icon        = "Eclectic impling jar",
                level       = 50,
                xp          = 289,
                product     = "Eclectic impling jar",
                members     = true
            }, {
                name        = "Spirit impling",
                icon        = "Spirit impling jar",
                level       = 54,
                xp          = 321,
                product     = "Spirit impling jar",
                members     = true
            }, {
                name        = "Nature impling",
                icon        = "Nature impling jar",
                level       = 58,
                xp          = 353,
                product     = "Nature impling jar",
                members     = true
            }, {
                name        = "Magpie impling",
                icon        = "Magpie impling jar",
                level       = 65,
                xp          = 409,
                product     = "Magpie impling jar",
                members     = true
            }, {
                name        = "Ghost impling",
                icon        = "Ghost impling jar",
                level       = 68,
                xp          = 442,
                product     = "Ghost impling jar",
                members     = true
            }, {
                name        = "Ninja impling",
                icon        = "Ninja impling jar",
                level       = 74,
                xp          = 481,
                product     = "Ninja impling jar",
                members     = true
            }, {
                name        = "Pirate impling",
                icon        = "Pirate impling jar",
                level       = 76,
                xp          = 497,
                product     = "Pirate impling jar",
                members     = true
            }, {
                name        = "Divine impling",
                icon        = "Divine impling jar",
                level       = 79,
                xp          = 520,
                product     = "Divine impling jar",
                members     = true
            }, {
                name        = "Dragon impling",
                icon        = "Dragon impling jar",
                level       = 83,
                xp          = 553,
                product     = "Dragon impling jar",
                members     = true
            }, {
                name        = "Zombie impling",
                icon        = "Zombie impling jar",
                level       = 87,
                xp          = 585,
                product     = "Zombie impling jar",
                members     = true
            }, {
                name        = "Kingly impling",
                icon        = "Kingly impling jar",
                level       = 91,
                xp          = 617,
                product     = "Kingly impling jar",
                members     = true
            }, {
                name        = "Crystal impling",
                icon        = "Crystal impling jar",
                level       = 95,
                xp          = 820,
                product     = "Crystal impling jar",
                members     = true
            }
        }
        return methods
    end

    -- Deadfall & Pitfall
    if trainMethod == "Deadfall and Pitfall" then
        local methods = 
        {
            {
                name        = "Wild kebbit",
                level       = 23,
                xp          = 128,
                bait        = "Raw beef",
                product     = "Kebbit claws",
                members     = true
            }, {
                name        = "Spined larupia",
                icon		= "Spined larupia icon",
                level       = 31,
                xp          = 165,
                product     = "Larupia fur",
                members     = true
            }, {
                name        = "Barb-tailed kebbit",
                icon        = "Barb-tailed kebbit",
                level       = 33,
                xp          = 93,
                bait        = "Raw rainbow fish",
                product     = "Barb-tail harpoon",
                members     = true
            }, {
                name        = "Prickly kebbit",
                level       = 37,
                xp          = 155,
                bait        = "Barley",
                product     = "Kebbit spike",
                members     = true
            }, {
                name        = "Horned graahk",
                icon		= "Horned graahk icon",
                level       = 41,
                xp          = 231,
                product     = "Graahk fur",
                members     = true
            }, {
                name        = "Diseased kebbit",
                level       = 44,
                xp          = 200,
                bait        = "Fever grass",
                product     = "Diseased kebbit fur",
                members     = true
            }, {
                name        = "Penguin (Hunter)",
                title       = "Penguin",
                icon        = "Penguin (item)",
                level       = 51,
                xp          = 210,
                bait        = "Raw cod",
                members     = true
            }, {
                name        = "Sabre-toothed kebbit",
                icon        = "Sabre-toothed kebbit",
                level       = 51.1,
                xp          = 200,
                bait        = "Raw beef",
                product     = "Kebbit teeth",
                members     = true
            }, {
                name        = "Sabre-toothed kyatt",
                icon        = "Sabre-toothed kyatt icon",
                level       = 55,
                xp          = 315,
                product     = "Kyatt fur",
                members     = true
            }, {
                name        = "Wild broav",
                icon        = "Unconscious broav",
                level       = 55.1,
                xp          = 19.2,
                product     = "Unconscious broav",
                trade       = 0,
                members     = true
            }, {
                name        = "Plover bird",
                iconSize    = 27,
                level       = 73,
                xp          = 510,
                product     = "Plover bird (item)",
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    -- Box Trapping
    if trainMethod == "Box Trapping" then
        local methods = 
        {
            {
                name        = "Cobalt skillchompa (Hunter)",
                title       = "Cobalt skillchompa",
                icon        = "Cobalt skillchompa",
                level       = 27,
                xp          = 121,
                bait        = "Spicy tomato",
                product     = "Cobalt skillchompa",
                members     = true
            }, {
                name        = "Ferret",
                level       = 27.1,
                xp          = 115,
                product     = "Ferret",
                trade       = 0,
                members     = true
            }, {
                name        = "Gecko",
                icon        = "Gecko (red)",
                level       = 27.2,
                xp          = 100,
                product     = "Gecko (red), Gecko",
                trade       = 0,
                members     = true
            }, {
                name        = "Monkey",
                icon        = "Monkey (brown and beige)",
                level       = 27.3,
                xp          = 100,
                product     = "Monkey (brown and beige), Monkey",
                trade       = 0,
                members     = true
            }, {
                name        = "Raccoon",
                icon        = "Baby raccoon (grey)",
                level       = 27.4,
                xp          = 100,
                product     = "Baby raccoon (grey), Raccoon",
                trade       = 0,
                members     = true
            }, {
                name        = "Viridian skillchompa (Hunter)",
                title       = "Viridian skillchompa",
                icon        = "Viridian skillchompa",
                level       = 46,
                xp          = 176,
                bait        = "Spicy tomato",
                product     = "Viridian skillchompa",
                members     = true
            }, {
                name        = "Chinchompa (Hunter)",
                title       = "Chinchompa",
                icon        = "Chinchompa",
                level       = 53,
                xp          = 198.4,
                bait        = "Spicy tomato",
                product     = "Chinchompa",
                members     = true
            }, {
                name        = "Penguin (Hunter)",
                title       = "Penguin",
                icon        = "Penguin (item)",
                level       = 56,
                xp          = 150,
                bait        = "Raw cod",
                product     = "Penguin (item), Penguin",
                trade       = 0,
                members     = true
            }, {
                name        = "Carnivorous chinchompa",
                icon        = "Red chinchompa",
                level       = 63,
                xp          = 230.5,
                bait        = "Spicy minced meat",
                product     = "Red chinchompa",
                members     = true
            }, {
                name        = "Pawya",
                icon        = "Pawya icon",
                level       = 66,
                xp          = 400,
                bait        = "Papaya fruit",
                product     = "Raw pawya meat",
                members     = true
            }, {
                name        = "Azure skillchompa (Hunter)",
                title       = "Azure skillchompa",
                icon        = "Azure skillchompa",
                level       = 68,
                xp          = 199,
                bait        = "Spicy tomato",
                product     = "Azure skillchompa",
                members     = true
            }, {
                name        = "Imp-in-a-box",
                icon        = "Imp-in-a-box (2)",
                level       = 71,
                xp          = 450,
                product     = "Imp-in-a-box (2)",
                trade       = 0,
                members     = true
            }, {
                name        = "Volatile chinchompa",
                icon        = "Black chinchompa",
                level       = 73,
                xp          = 270,
                bait        = "Spicy tomato",
                product     = "Black chinchompa",
                members     = true
            }, {
                name        = "Grenwall",
                icon        = "Grenwall icon",
                level       = 77,
                xp          = 726,
                bait        = "Raw pawya meat",
                product     = "Grenwall spikes",
                members     = true
            }, {
                name        = "Crimson skillchompa (Hunter)",
                title       = "Crimson skillchompa",
                icon        = "Crimson skillchompa",
                level       = 89,
                xp          = 309,
                bait        = "Spicy tomato",
                product     = "Crimson skillchompa",
                members     = true
            }, {
                name        = "Crystal skillchompa (Hunter)",
                title       = "Crystal skillchompa",
                icon        = "Crystal skillchompa",
                level       = 97,
                xp          = 410,
                bait        = "Spicy tomato",
                product     = "Crystal skillchompa",
                members     = true
            },
        }
        return methods
    end

    -- Herblore Habitat
    if trainMethod == "Herblore Habitat" then
        local methods = 
        {
            {
                name        = "Common jadinko",
                icon        = "Common jadinko icon",
                level       = 70,
                xp          = 200,
                product     = "Withered vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Draconic jadinko",
                icon        = "Draconic jadinko icon",
                level       = 71,
                xp          = 554,
                product     = "Draconic vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Shadow jadinko",
                icon        = "Shadow jadinko icon",
                level       = 71.1,
                xp          = 600,
                product     = "Shadow vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Igneous jadinko",
                icon        = "Igneous jadinko icon",
                level       = 74,
                xp          = 500,
                product     = "Marble vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Cannibal jadinko",
                icon        = "Cannibal jadinko icon",
                level       = 75,
                xp          = 510,
                product     = "Plant teeth",
                trade       = 0,
                members     = true
            }, {
                name        = "Aquatic jadinko",
                icon        = "Aquatic jadinko icon",
                level       = 76,
                xp          = 570,
                product     = "Aquatic vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Amphibious jadinko",
                icon        = "Amphibious jadinko icon",
                level       = 77,
                xp          = 450,
                product     = "Oily vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Carrion jadinko",
                icon        = "Carrion jadinko icon",
                level       = 78,
                xp          = 635,
                product     = "Pungent vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Diseased jadinko",
                icon        = "Diseased jadinko icon",
                level       = 78.1,
                xp          = 950,
                product     = "Corrupt vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Camouflaged jadinko",
                icon        = "Camouflaged jadinko icon",
                level       = 79,
                xp          = 975,
                product     = "Striped vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Guthix jadinko",
                icon        = "Saradomin jadinko icon",
                level       = 81,
                xp          = 453,
                product     = "Guthix vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Saradomin jadinko",
                icon        = "Saradomin jadinko icon",
                level       = 81.1,
                xp          = 453,
                product     = "Saradomin vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Zamorak jadinko",
                icon        = "Saradomin jadinko icon",
                level       = 81.2,
                xp          = 453,
                product     = "Zamorak vine",
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
    
    -- Anachronia
    if trainMethod == "Anachronia" then
        local methods = 
        {
            {
                name        = "Common jadinko",
                icon        = "Common jadinko icon",
                level       = 80,
                xp          = 200,
                product     = "Withered vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Draconic jadinko",
                icon        = "Draconic jadinko icon",
                level       = 90,
                xp          = 554,
                product     = "Draconic vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Shadow jadinko",
                icon        = "Shadow jadinko icon",
                level       = 81,
                xp          = 473,
                product     = "Shadow vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Igneous jadinko",
                icon        = "Igneous jadinko icon",
                level       = 84,
                xp          = 500,
                product     = "Marble vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Cannibal jadinko",
                icon        = "Cannibal jadinko icon",
                level       = 85,
                xp          = 510,
                product     = "Plant teeth",
                trade       = 0,
                members     = true
            }, {
                name        = "Aquatic jadinko",
                icon        = "Aquatic jadinko icon",
                level       = 86,
                xp          = 570,
                product     = "Aquatic vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Amphibious jadinko",
                icon        = "Amphibious jadinko icon",
                level       = 87,
                xp          = 450,
                product     = "Oily vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Carrion jadinko",
                icon        = "Carrion jadinko icon",
                level       = 88,
                xp          = 635,
                product     = "Pungent vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Diseased jadinko",
                icon        = "Diseased jadinko icon",
                level       = 88,
                xp          = 500,
                product     = "Corrupt vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Camouflaged jadinko",
                icon        = "Camouflaged jadinko icon",
                level       = 89,
                xp          = 515,
                product     = "Striped vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Guthix jadinko",
                icon        = "Saradomin jadinko icon",
                level       = 81,
                xp          = 453,
                product     = "Guthix vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Saradomin jadinko",
                icon        = "Saradomin jadinko icon",
                level       = 81.1,
                xp          = 453,
                product     = "Saradomin vine",
                trade       = 0,
                members     = true
            }, {
                name        = "Zamorak jadinko",
                icon        = "Saradomin jadinko icon",
                level       = 81.2,
                xp          = 453,
                product     = "Zamorak vine",
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    -- The Arc
    if trainMethod == "The Arc" then
        local methods = 
        {
            {
                name        = "Ancestral bakami",
                icon        = "Ancestral bakami jar",
                level       = 90.01,
                xp          = 625,
                product     = "Ancestral bakami jar",
                currency    = "Chimes",
                value       = 150,
                trade       = 0,
                members     = true
            }, {
                name        = "Bundling bakami",
                icon        = "Bundling bakami jar",
                level       = 90.02,
                xp          = 525,
                product     = "Bundling bakami jar",
                currency    = "Chimes",
                value       = 110,
                trade       = 0,
                members     = true
            }, {
                name        = "Foraging bakami",
                icon        = "Foraging bakami jar",
                level       = 90.03,
                xp          = 600,
                product     = "Foraging bakami jar",
                currency    = "Chimes",
                value       = 140,
                trade       = 0,
                members     = true
            }, {
                name        = "Fortunate bakami",
                icon        = "Fortunate bakami jar",
                level       = 90.04,
                xp          = 675,
                product     = "Fortunate bakami jar",
                currency    = "Chimes",
                value       = 200,
                trade       = 0,
                members     = true
            }, {
                name        = "Murderous bakami",
                icon        = "Murderous bakami jar",
                level       = 90.05,
                xp          = 650,
                product     = "Murderous bakami jar",
                currency    = "Chimes",
                value       = 160,
                trade       = 0,
                members     = true
            }, {
                name        = "Oily bakami",
                icon        = "Oily bakami jar",
                level       = 90.06,
                xp          = 500,
                product     = "Oily bakami jar",
                currency    = "Chimes",
                value       = 100,
                trade       = 0,
                members     = true
            }, {
                name        = "Salty bakami",
                icon        = "Salty bakami jar",
                level       = 90.07,
                xp          = 550,
                product     = "Salty bakami jar",
                currency    = "Chimes",
                value       = 120,
                trade       = 0,
                members     = true
            }, {
                name        = "Stalking bakami",
                icon        = "Stalking bakami jar",
                level       = 90.08,
                xp          = 575,
                product     = "Stalking bakami jar",
                currency    = "Chimes",
                value       = 130,
                trade       = 0,
                members     = true
            }, {
                name        = "Tortle",
                icon        = "Shell chippings",
                level       = 90,
                xp          = 329,
                product     = "Shell chippings",
                currency    = "Chimes",
                value       = 1,
                trade       = 0,
                members     = true
            }, {
                name        = "Ancestral orokami",
                icon        = "Ancestral orokami jar",
                level       = 95,
                xp          = 1250,
                product     = "Ancestral orokami jar",
                currency    = "Chimes",
                value       = 320,
                trade       = 0,
                members     = true
            }, {
                name        = "Bundling orokami",
                icon        = "Bundling orokami jar",
                level       = 95.01,
                xp          = 1050,
                product     = "Bundling orokami jar",
                currency    = "Chimes",
                value       = 240,
                trade       = 0,
                members     = true
            }, {
                name        = "Foraging orokami",
                icon        = "Foraging orokami jar",
                level       = 95.02,
                xp          = 1200,
                product     = "Foraging orokami jar",
                currency    = "Chimes",
                value       = 300,
                trade       = 0,
                members     = true
            }, {
                name        = "Fortunate orokami",
                icon        = "Fortunate orokami jar",
                level       = 95.03,
                xp          = 1350,
                product     = "Fortunate orokami jar",
                currency    = "Chimes",
                value       = 400,
                trade       = 0,
                members     = true
            }, {
                name        = "Murderous orokami",
                icon        = "Murderous orokami jar",
                level       = 95.04,
                xp          = 1300,
                product     = "Murderous orokami jar",
                currency    = "Chimes",
                value       = 340,
                trade       = 0,
                members     = true
            }, {
                name        = "Oily orokami",
                icon        = "Oily orokami jar",
                level       = 95.05,
                xp          = 1000,
                product     = "Oily orokami jar",
                currency    = "Chimes",
                value       = 220,
                trade       = 0,
                members     = true
            }, {
                name        = "Salty orokami",
                icon        = "Salty orokami jar",
                level       = 95.06,
                xp          = 1100,
                product     = "Salty orokami jar",
                currency    = "Chimes",
                value       = 260,
                trade       = 0,
                members     = true
            }, {
                name        = "Stalking orokami",
                icon        = "Stalking orokami jar",
                level       = 95,
                xp          = 1150,
                product     = "Stalking orokami jar",
                currency    = "Chimes",
                value       = 280,
                trade       = 0,
                members     = true
            }, {
                name        = "Ornate tortle",
                icon        = "Shiny shell chippings",
                level       = 96,
                xp          = 698,
                product     = "Shiny shell chippings",
                currency    = "Chimes",
                value       = 2,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    -- Dungeoneering
    if trainMethod == "Dungeoneering - Trapping" then
        local methods = 
        {
            {
                name        = "Protomastyx",
                icon        = "Protomastyx hide",
                level       = 1,
                xp          = 55,
                urns        = false,
                product     = "Protomastyx hide",
                trade       = 0,
                members     = true
            }, {
                name        = "Submastyx",
                icon        = "Submastyx hide",
                level       = 10,
                xp          = 94.5,
                urns        = false,
                product     = "Submastyx hide",
                trade       = 0,
                members     = true
            }, {
                name        = "Paramastyx",
                icon        = "Paramastyx hide",
                level       = 20,
                xp          = 164,
                urns        = false,
                product     = "Paramastyx hide",
                trade       = 0,
                members     = true
            }, {
                name        = "Archaemastyx",
                icon        = "Archaemastyx hide",
                level       = 30,
                xp          = 247,
                urns        = false,
                product     = "Archaemastyx hide",
                trade       = 0,
                members     = true
            }, {
                name        = "Dromomastyx",
                icon        = "Dromomastyx hide",
                level       = 40,
                xp          = 330,
                urns        = false,
                product     = "Dromomastyx hide",
                trade       = 0,
                members     = true
            }, {
                name        = "Spinomastyx",
                icon        = "Spinomastyx hide",
                level       = 50,
                xp          = 435.5,
                urns        = false,
                product     = "Spinomastyx hide",
                trade       = 0,
                members     = true
            }, {
                name        = "Gallimastyx",
                icon        = "Gallimastyx hide",
                level       = 60,
                xp          = 519,
                urns        = false,
                product     = "Gallimastyx hide",
                trade       = 0,
                members     = true
            }, {
                name        = "Stegomastyx",
                icon        = "Stegomastyx hide",
                level       = 70,
                xp          = 599.5,
                urns        = false,
                product     = "Stegomastyx hide",
                trade       = 0,
                members     = true
            }, {
                name        = "Megamastyx",
                icon        = "Megamastyx hide",
                level       = 80,
                xp          = 673,
                urns        = false,
                product     = "Megamastyx hide",
                trade       = 0,
                members     = true
            }, {
                name        = "Tyrannomastyx",
                icon        = "Tyrannomastyx hide",
                level       = 90,
                xp          = 745.5,
                urns        = false,
                product     = "Tyrannomastyx hide",
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    if trainMethod == "Big Game Hunting" then
        local methods = 
        {
            {
                name        = "Arcane apoterrasaur",
                icon        = "Arcane apoterrasaur icon",
                level       = 75,
                xp          = 6000,
                bait        = "Raw shark",
                members     = true
            }, {
                name        = "Scimitops",
                icon        = "Scimitops icon",
                level       = 75,
                xp          = 6000,
                bait        = "Raw sailfish",
                members     = true
            }, {
                name        = "Bagrada rex",
                icon        = "Bagrada rex icon",
                level       = 75,
                xp          = 6000,
                bait        = "Raw manta ray",
                members     = true
            }, {
                name        = "Spicati apoterrasaur",
                icon        = "Spicati apoterrasaur icon",
                level       = 80,
                xp          = 12000,
                bait        = "Raw bagrada rex meat",
                members     = true
            }, {
                name        = "Asciatops",
                icon        = "Asciatops icon",
                level       = 85,
                xp          = 12000,
                bait        = "Raw arcane apoterrasaur meat",
                members     = true
            }, {
                name        = "Corbicula rex",
                icon        = "Corbicula rex icon",
                level       = 90,
                xp          = 12000,
                bait        = "Raw scimitops meat",
                members     = true
            }, {
                name        = "Oculi apoterrasaur",
                icon        = "Oculi apoterrasaur icon",
                level       = 94,
                xp          = 21000,
                bait        = "Raw asciatops meat",
                members     = true
            }, {
                name        = "Malletops",
                icon        = "Malletops icon",
                level       = 95,
                xp          = 21000,
                bait        = "Raw corbicula rex meat",
                members     = true
            }, {
                name        = "Pavosaurus rex",
                icon        = "Pavosaurus rex icon",
                level       = 96,
                xp          = 21000,
                bait        = "Raw spicati apoterrasaur meat",
                members     = true
            }, {
                name        = "Giant chinchompa",
                icon        = "Giant chinchompa (Big Game Hunter) icon",
                level       = 96,
                xp          = 21000,
                bait        = "Raw shark",
                members     = true
            }, {
                name        = "Giant kebbit",
                icon        = "Giant kebbit icon",
                level       = 98,
                xp          = 25750,
                bait        = "Raw giant chinchompa meat",
                members     = true
            }, {
                name        = "Giant carnivorous chinchompa",
                icon        = "Giant carnivorous chinchompa icon",
                level       = 100,
                xp          = 28500,
                bait        = "Raw giant kebbit meat",
                members     = true
            }, {
                name        = "Giant spiked kebbit",
                icon        = "Giant spiked kebbit icon",
                level       = 102,
                xp          = 33750,
                bait        = "Raw giant chinchompa meat",
                members     = true
            }, {
                name        = "Giant volatile chinchompa",
                icon        = "Giant volatile chinchompa icon",
                level       = 104,
                xp          = 48500,
                bait        = "Raw giant kebbit meat",
                members     = true
            }, {
                name        = "Giant diseased kebbit",
                icon        = "Giant diseased kebbit icon",
                level       = 106,
                xp          = 60000,
                bait        = "Raw giant chinchompa meat",
                members     = true
            }, {
                name        = "Giant golden chinchompa",
                icon        = "Giant golden chinchompa icon",
                level       = 108,
                xp          = 62500,
                bait        = "Raw giant kebbit meat",
                members     = true
            }, {
                name        = "Giant dashing kebbit",
                icon        = "Giant dashing kebbit icon",
                level       = 110,
                xp          = 75000,
                bait        = "Raw giant chinchompa meat",
                members     = true
            }
        }
        return methods
    end

    if trainMethod == "Soporith Moths" then
        local methods = 
        {
            {
                name        = "Red soporith moth",
                icon        = "Red soporith moth detail",
                iconSize    = 27,
                level       = 1,
                xp          = 15,
                members     = true
            }, {
                name        = "Orange soporith moth",
                icon        = "Orange soporith moth detail",
                iconSize    = 27,
                level       = 13,
                xp          = 50,
                members     = true
            }, {
                name        = "Yellow soporith moth",
                icon        = "Yellow soporith moth detail",
                iconSize    = 27,
                level       = 26,
                xp          = 150,
                members     = true
            }, {
                name        = "Green soporith moth",
                icon        = "Green soporith moth detail",
                iconSize    = 27,
                level       = 39,
                xp          = 250,
                members     = true
            }, {
                name        = "Blue soporith moth",
                icon        = "Blue soporith moth detail",
                iconSize    = 27,
                level       = 52,
                xp          = 300,
                members     = true
            }, {
                name        = "Purple soporith moth",
                icon        = "Purple soporith moth detail",
                iconSize    = 27,
                level       = 65,
                xp          = 320,
                members     = true
            }, {
                name        = "Grey soporith moth",
                icon        = "Grey soporith moth detail",
                iconSize    = 27,
                level       = 78,
                xp          = 400,
                members     = true
            }, {
                name        = "Black soporith moth",
                icon        = "Black soporith moth detail",
                iconSize    = 27,
                level       = 91,
                xp          = 450,
                members     = true
            }
        }
        return methods
    end
     -- Het's Oasis Scarab catching
    if trainMethod == "Het's Oasis Scarabs" then
        local methods = 
        {
            {
                name        = "Plain whirligig",
                icon		= "Plain whirligig icon",
                level       = 1,
                xp          = 20,
                product     = "Plain whirligig shell",
                members     = true
            }, {
                name        = "Dazzling whirligig",
                icon		= "Dazzling whirligig icon",
                level       = 1,
                xp          = 100,
                bait        = "Golden roses",
                product     = "Dazzling whirligig shell",
                members     = true
            }, {
                name        = "Gliding whirligig",
                icon        = "Gliding whirligig icon",
                level       = 30,
                xp          = 100,
                bait        = "Roses (Het's Oasis)|Roses",
                product     = "Gliding whirligig shell",
                members     = true
            }, {
                name        = "Swift whirligig",
                icon        = "Swift whirligig icon",
                level       = 50,
                xp          = 180,
                bait        = "Irises",
                product     = "Swift whirligig shell",
                members     = true
            }, {
                name        = "Hasty whirligig",
                icon		= "Hasty whirligig icon",
                level       = 70,
                xp          = 300,
                bait        = "Hydrangeas",
                product     = "Hasty whirligig shell",
                members     = true
            }, {
                name        = "Speedy whirligig",
                icon		= "Speedy whirligig icon",
                level       = 90,
                xp          = 500,
                bait        = "Hollyhocks",
                product     = "Speedy whirligig shell",
                members     = true
            }
        }
        return methods
    end

    ---------------------------------   Urns   ---------------------------------------------

    if trainMethod == "Urns" then
        local methods = 
        {
            {
                name        = "Cracked hunter urn",
                xp          = 1320,
                urns        = false,
                maxLevel    = 11,
                material    = {1, "Cracked hunter urn (no rune)", 1, "Mud rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Cracked hunter urn",
                title		= "Cracked hunter urn (Urn Enhancer)",
                icon		= "Cracked hunter urn",
                xp          = 1375,
                urns        = false,
                maxLevel    = 11,
                material    = {1, "Cracked hunter urn (no rune)", 1, "Mud rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Fragile hunter urn",
                xp          = 3000,
                urns        = false,
                maxLevel    = 29,
                material    = {1, "Fragile hunter urn (no rune)", 1, "Mud rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Fragile hunter urn",
                title		= "Fragile hunter urn (Urn Enhancer)",
                icon		= "Fragile hunter urn",
                xp          = 3125,
                urns        = false,
                maxLevel    = 29,
                material    = {1, "Fragile hunter urn (no rune)", 1, "Mud rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Plain hunter urn",
                xp          = 6000,
                urns        = false,
                maxLevel    = 53,
                material    = {1, "Plain hunter urn (no rune)", 1, "Mud rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0
            }, {
                name        = "Plain hunter urn",
                title		= "Plain hunter urn (Urn Enhancer)",
                icon		= "Plain hunter urn",
                xp          = 6250,
                urns        = false,
                maxLevel    = 53,
                material    = {1, "Plain hunter urn (no rune)", 1, "Mud rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Strong hunter urn",
                xp          = 8400,
                urns        = false,
                maxLevel    = 74,
                material    = {1, "Strong hunter urn (no rune)", 1, "Mud rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Strong hunter urn",
                title		= "Strong hunter urn (Urn Enhancer)",
                icon		= "Strong hunter urn",
                xp          = 8750,
                urns        = false,
                maxLevel    = 74,
                material    = {1, "Strong hunter urn (no rune)", 1, "Mud rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Decorated hunter urn",
                xp          = 9600,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated hunter urn (no rune)", 1, "Mud rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Decorated hunter urn",
                title		= "Decorated hunter urn (Urn Enhancer)",
                icon		= "Decorated hunter urn",
                xp          = 10000,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Decorated hunter urn (no rune)", 1, "Mud rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Exquisite hunter urn",
                xp          = 13800,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite hunter urn (no rune)", 1, "Mud rune"},
                mcount      = 2,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }, {
                name        = "Exquisite hunter urn",
                title		= "Exquisite hunter urn (Urn Enhancer)",
                icon		= "Exquisite hunter urn",
                xp          = 14490,
                urns        = false,
                maxLevel    = -1,
                material    = {1, "Exquisite hunter urn (no rune)", 1, "Mud rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                mtrade      = 0,
                members     = true
            }
        }
        return methods
    end
 
    if trainMethod == "Birdhouses" then
        local methods = {
            {
                name		= "Birdhouse",
                title		= "Regular",
                icon		= "Birdhouse",
                level		= 5,
                xp			= 18,
                members 	= true
            }, {
                name		= "Oak birdhouse",
                title		= "Oak",
                icon		= "Oak birdhouse",
                level		= 11,
                xp			= 35,
                members 	= true
            }, {
                name		= "Willow birdhouse",
                title		= "Willow",
                icon		= "Willow birdhouse",
                level		= 21,
                xp			= 70,
                members 	= true
            }, {
                name		= "Teak birdhouse",
                title		= "Teak",
                icon		= "Teak birdhouse",
                level		= 31,
                xp			= 155,
                members 	= true
            }, {
                name		= "Maple birdhouse",
                title		= "Maple",
                icon		= "Maple birdhouse",
                level		= 41,
                xp			= 235,
                members 	= true
            }, {
                name		= "Acadia birdhouse",
                title		= "Acadia",
                icon		= "Acadia birdhouse",
                level		= 51,
                xp			= 335,
                members 	= true
            }, {
                name		= "Mahogany birdhouse",
                title		= "Mahogany",
                icon		= "Mahogany birdhouse",
                level		= 61,
                xp			= 485,
                members 	= true
            }, {
                name		= "Yew birdhouse",
                title		= "Yew",
                icon		= "Yew birdhouse",
                level		= 71,
                xp			= 605,
                members 	= true
            }, {
                name		= "Magic birdhouse",
                title		= "Magic",
                icon		= "Magic birdhouse",
                level		= 81,
                xp			= 745,
                members 	= true
            }, {
                name		= "Elder birdhouse",
                title		= "Elder",
                icon		= "Elder birdhouse",
                level		= 91,
                xp			= 905,
                members 	= true
            }, {
                name		= "Eternal birdhouse",
                title		= "Eternal magic",
                icon		= "Eternal birdhouse",
                level		= 101,
                xp			= 1255,
                members 	= true
            }
        }
        return methods
    end
end