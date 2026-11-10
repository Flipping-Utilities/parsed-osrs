--[=[
     Notations found in this Module:
        * name:     Name of target
        * icon:      Alternate image location
        * level:    Level required to complete
        * xp:       Experience gained
        * Product:  Main reward from capturing target
        * title:    Alternative name of object
            - Used to clarify the difference from a similar object or offer a cleaner name
        * trade:    Indicates whether the product can be found in the GE
        * currency: Indicates an alternative currency being used
        * value:    Specifies the product's value in alternative currency
        * members:  Indicates whether an item is members-only content
--]=]

return function(trainMethod)
    local methods = {}
    -- Bones and Ashes
    if trainMethod == "Bones and Ashes" then
        methods = {
            {
                name         = "Impious ashes",
                xp           = 4
            }, {
                name         = "Bones",
                xp           = 4.5
            }, {
                name         = "Wolf bones",
                xp           = 4.5
            }, {
                name         = "Burnt bones",
                xp           = 4.5
            }, {
                name         = "Monkey bones",
                xp           = 5
            }, {
--[=[
                name         = "Small zombie monkey bones",
                xp           = 5,
                trade        = 0,
                members      = true
            }, {
                name         = "Large zombie monkey bones",
                xp           = 5,
                trade        = 0,
                members      = true
            }, {
--]=]
                name         = "Bat bones",
                xp           = 5.3
            }, {
                name         = "Accursed ashes",
                xp           = 12.5
            }, {
                name         = "Jogre bones",
                xp           = 15,
                members      = true
            }, {
                name         = "Big bones",
                xp           = 15
            }, {
--[=[
                name         = "Long bone",
                xp           = 15,
                trade        = 0,
                members      = true
            }, {
                name         = "Curved bone",
                xp           = 15,
                trade        = 0,
                members      = true
            }, {
                name         = "Gorilla bones",
                xp           = 18,
                trade        = 0,
                members      = true
            }, {
--]=]
                name         = "Zogre bones",
                xp           = 22.5,
                members      = true
            }, {
                name         = "Shaikahan bones",
                xp           = 25,
                members      = true
            }, {
                name         = "Baby dragon bones",
                xp           = 30
            }, {
                name         = "Wyvern bones",
                xp           = 50,
                members      = true
            }, {
                name         = "Infernal ashes",
                xp           = 62.5,
                members      = true
            }, {
                name         = "Dragon bones",
                xp           = 72
            }, {
                name         = "Fayrg bones",
                xp           = 84,
                members      = true
            }, {
                name         = "Tortured ashes",
                xp           = 90,
                members      = true
            }, {
                name         = "Raurg bones",
                xp           = 96,
                members      = true
            }, {
                name         = "Dagannoth bones",
                xp           = 125,
                members      = true
            }, {
                name         = "Airut bones",
                xp           = 132.5,
                members      = true
            }, {
                name         = "Ourg bones",
                xp           = 140,
                members      = true
            }, {
                name         = "Ourg bones (General Graardor)",
                xp           = 140,
                members      = true
            }, {
                name         = "Hardened dragon bones",
                xp           = 144,
                members      = true
            }, {
                name         = "Dragonkin bones",
                xp           = 160,
                members      = true
            }, {
                name         = "Dinosaur bones",
                xp           = 170,
                members      = true
            }, {
                name         = "Frost dragon bones",
                xp           = 180,
                members      = true
            }, {
                name         = "Reinforced dragon bones",
                xp           = 190,
                members      = true
            }, {
                name         = "Searing ashes",
                xp           = 200,
                members      = true
            }, {
                name         = "Colossal bone",
                xp           = 400,
                currency     = "Coins",
                value        = 0,
                trade        = 0
            }, {
                name         = "Cleansing crystal",
                xp           = 9800,
                currency     = "Coins",
                value        = 110000,
                trade        = 0,
                members      = true
            }
        }
    	return methods
    end

    -- Prayer urns
    if trainMethod == "Urns" then
        methods = {
            {
                name         = "Impious urn",
                xp           = 120,
                material     = {1, "Impious urn (no rune)", 1, "Air rune"},
                mcount       = 2,
                trade        = 0
            }, {
                name        = "Impious urn",
                title		= "Impious urn (Urn Enhancer)",
                xp          = 150,
                material    = {1, "Impious urn (no rune)", 1, "Air rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members     = true
            }, {
                name         = "Accursed urn",
                xp           = 375,
                material     = {1, "Accursed urn (no rune)", 1, "Air rune"},
                mcount       = 2,
                trade        = 0
            }, {
                name        = "Accursed urn",
                title		= "Accursed urn (Urn Enhancer)",
                xp          = 468.75,
                material    = {1, "Accursed urn (no rune)", 1, "Air rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members     = true
            }, {
                name        = "Infernal urn",
                xp          = 1875,
                material    = {1, "Infernal urn (no rune)", 1, "Air rune"},
                mcount      = 2,
                trade       = 0,
                members     = true
            }, {
                name        = "Infernal urn",
                title		= "Infernal urn (Urn Enhancer)",
                xp          = 2343.75,
                material    = {1, "Infernal urn (no rune)", 1, "Air rune", 1/150, "Divine charge"},
                mcount      = 3,
                trade       = 0,
                members     = true
            }
        }
    	return methods
    end

    -- Bones for Cremation
    if trainMethod == "Bones for Cremation" then
        methods = {
            {
                name         = "Bones",
                xp           = 11.2
            }, {
                name         = "Wolf bones",
                xp           = 11.2
            }, {
                name         = "Burnt bones",
                xp           = 11.2
            }, {
                name         = "Monkey bones",
                xp           = 12.5
            }, {
--[=[
                name         = "Small zombie monkey bones",
                xp           = 12.5,
                trade        = 0,
                members      = true
            }, {
                name         = "Large zombie monkey bones",
                xp           = 12.5,
                trade        = 0,
                members      = true
            }, {
--]=]
                name         = "Bat bones",
                xp           = 13.2
            }, {
                name         = "Jogre bones",
                xp           = 37.5,
                members      = true
            }, {
                name         = "Big bones",
                xp           = 37.5
            }, {
--[=[
                name         = "Long bone",
                xp           = 37.5,
                trade        = 0,
                members      = true
            }, {
                name         = "Curved bone",
                xp           = 37.5,
                trade        = 0,
                members      = true
            }, {
                name         = "Gorilla bones",
                xp           = 45,
                trade        = 0,
                members      = true
            }, {
--]=]
                name         = "Zogre bones",
                xp           = 56.2,
                members      = true
            }, {
                name         = "Shaikahan bones",
                xp           = 62.5,
                members      = true
            }, {
                name         = "Baby dragon bones",
                xp           = 75
            }, {
                name         = "Wyvern bones",
                xp           = 125,
                members      = true
            }, {
                name         = "Dragon bones",
                xp           = 180
            }, {
                name         = "Fayrg bones",
                xp           = 210,
                members      = true
            }, {
                name         = "Raurg bones",
                xp           = 240,
                members      = true
            }, {
                name         = "Dagannoth bones",
                xp           = 312.5,
                members      = true
            }, {
                name         = "Airut bones",
                xp           = 331.2,
                members      = true
            }, {
                name         = "Ourg bones",
                xp           = 350,
                members      = true
            }, {
                name         = "Ourg bones (General Graardor)",
                xp           = 350,
                members      = true
            }, {
                name         = "Hardened dragon bones",
                xp           = 360,
                members      = true
            }, {
                name         = "Dragonkin bones",
                xp           = 400,
                members      = true
            }, {
                name         = "Dinosaur bones",
                xp           = 425,
                members      = true
            }, {
                name         = "Frost dragon bones",
                xp           = 450,
                members      = true
            }, {
                name         = "Reinforced dragon bones",
                xp           = 475,
                members      = true
            }
        }
    	return methods
    end
    
    if trainMethod == "Incense sticks" then
        methods = {
            {
                name         = "Impious incense sticks",
                level        = 1,
                xp           = 8,
                material     = {1, "Wooden incense sticks", 2, "Impious ashes"},
                mcount       = 2
            }, {
                name         = "Impious oak incense sticks",
                level        = 1,
                xp           = 10,
                material     = {1, "Oak incense sticks", 2, "Impious ashes"},
                mcount       = 2
            }, {
                name         = "Impious willow incense sticks",
                level        = 1,
                xp           = 12,
                material     = {1, "Willow incense sticks", 2, "Impious ashes"},
                mcount       = 2
            }, {
                name         = "Accursed maple incense sticks",
                level        = 1,
                xp           = 20,
                material     = {1, "Maple incense sticks", 2, "Accursed ashes"},
                mcount       = 2
            }, {
                name         = "Accursed acadia incense sticks",
                level        = 1,
                xp           = 22.5,
                material     = {1, "Acadia incense sticks", 2, "Accursed ashes"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Infernal yew incense sticks",
                level        = 1,
                xp           = 100,
                material     = {1, "Yew incense sticks", 2, "Infernal ashes"},
                mcount       = 2,
                members      = true
            }, {
                name         = "Infernal magic incense sticks",
                level        = 1,
                xp           = 125,
                material     = {1, "Magic incense sticks", 2, "Infernal ashes"},
                mcount       = 2,
                members      = true
            }
        }
    	return methods
    end

    if trainMethod == "Ectofuntus" then
        methods = {
            {
                name         = "Impious ashes",
                xp           = 16
            }, {
                name         = "Bones",
                xp           = 18
            }, {
                name         = "Wolf bones",
                xp           = 18
            }, {
                name         = "Burnt bones",
                xp           = 18
            }, {
                name         = "Monkey bones",
                xp           = 20
            }, {
--[=[
                name         = "Small zombie monkey bones",
                xp           = 20,
                trade        = 0,
                members      = true
            }, {
                name         = "Large zombie monkey bones",
                xp           = 20,
                trade        = 0,
                members      = true
            }, {
--]=]
                name         = "Bat bones",
                xp           = 21.2
            }, {
                name         = "Accursed ashes",
                xp           = 50
            }, {
                name         = "Jogre bones",
                xp           = 60,
                members      = true
            }, {
                name         = "Big bones",
                xp           = 60
            }, {
--[=[
                name         = "Long bone",
                xp           = 60,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Curved bone",
                xp           = 60,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
                name         = "Gorilla bones",
                xp           = 72,
                trade        = 0,
                mtrade       = 0,
                members      = true
            }, {
--]=]
                name         = "Zogre bones",
                xp           = 90,
                members      = true
            }, {
                name         = "Shaikahan bones",
                xp           = 100,
                members      = true
            }, {
                name         = "Baby dragon bones",
                xp           = 120
            }, {
                name         = "Wyvern bones",
                xp           = 200,
                members      = true
            }, {
                name         = "Infernal ashes",
                xp           = 250,
                members      = true
            }, {
                name         = "Dragon bones",
                xp           = 288
            }, {
                name         = "Fayrg bones",
                xp           = 336,
                members      = true
            }, {
                name         = "Tortured ashes",
                xp           = 360,
                members      = true
            }, {
                name         = "Raurg bones",
                xp           = 384,
                members      = true
            }, {
                name         = "Dagannoth bones",
                xp           = 500,
                members      = true
            }, {
                name         = "Airut bones",
                xp           = 530
            }, {
                name         = "Ourg bones (General Graardor)",
                xp           = 560
            }, {
                name         = "Ourg bones",
                xp           = 560
            }, {
                name         = "Hardened dragon bones",
                xp           = 576
            }, {
                name         = "Dragonkin bones",
                xp           = 640,
                members      = true
            }, {
                name         = "Dinosaur bones",
                xp           = 680
            }, {
                name         = "Frost dragon bones",
                xp           = 720
            }, {
                name         = "Reinforced dragon bones",
                xp           = 760
            }, {
                name         = "Searing ashes",
                xp           = 800
            }
        }
    	return methods
    end
end