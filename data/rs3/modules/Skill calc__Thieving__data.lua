--[=[
     Notations found in this Module:
        * name:     Name of product
        * icon:     Alternate image location
        * iconSize: Used to modify large images into an icon
        * title:    Alternate link location
            - Used to clarify the difference from a similar object or offer a cleaner name
        * level:    Level required to complete
        * xp:       Experience gained
        * members:  Indicates whether an item is members-only content
--]=]

--[=[
    Testing first before adding the rest
--]=]
return function(trainMethod,subMethod)
    --Sorceress' Garden
    if trainMethod == "Sorceress' Garden" or trainMethod == "Sorceress Garden" then
        local methods = 
        {
            {
                name        = "Winter sq'irkjuice",
                title       = "Winter Sq'irk Juice",
                level       = 1,
                xp          = 350,
                material    = {5, "Winter sq'irk"},
                mtrade      = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Spring sq'irkjuice",
                title       = "Spring Sq'irk Juice",
                level       = 25,
                xp          = 1350,
                material    = {4, "Spring sq'irk"},
                mtrade      = 0,
                trade       = 0,
                members     = true
            }, {
                name        = "Autumn sq'irkjuice",
                title       = "Autumn Sq'irk Juice",
                level       = 45,
                xp          = 2350,
                material    = {3, "Autumn sq'irk"},
                mtrade      = 0,
                trade       = 0,
                members     = true 
            }, {
                name        = "Summer sq'irkjuice",
                title       = "Summer Sq'irk Juice",
                level       = 65,
                xp          = 3000,
                material    = {2, "Summer sq'irk"},
                mtrade      = 0,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    --Milestones
    --Pickpocket
    if trainMethod == "Pickpocket" then
        local methods = 
        {
            {
                name        = "Man",
                title       = "Man or Woman",
                icon        = "Man chathead",
                iconSize    = 21,
                level       = 1,
                xp          = 8,
                trade       = 0,
                members     = true
            }, {
                name        = "Gullible tourist",
                icon        = "Gullible tourist",
                iconSize    = 21,
                level       = 1,
                xp          = 29.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Farmer",
                icon        = "Farmer icon",
                level       = 10,
                xp          = 14.5,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. member",
                title       = "Female H.A.M. member",
                icon        = "H.A.M. Member (female) chathead",
                iconSize    = 21,
                level       = 15,
                xp          = 18.5,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. member",
                title       = "Male H.A.M. member",
                icon        = "H.A.M. Member (male) chathead",
                iconSize    = 21,
                level       = 20,
                xp          = 22.2,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. Guard",
                icon        = "H.A.M. Guard chathead",
                iconSize    = 21,
                level       = 23,
                xp          = 22.2,
                trade       = 0,
                members     = true
            }, {
                name        = "Dig Site workman",
                icon        = "Dig Site workman chathead",
                iconSize    = 21,
                level       = 25,
                xp          = 10.4,
                trade       = 0,
                members     = true
            }, {
                name        = "Desert Phoenix",
                icon        = "Desert Phoenix",
                iconSize    = 21,
                level       = 25,
                xp          = 26,
                trade       = 0,
                members     = true
            }, {
                name        = "Warrior woman",
                iconSize    = 21,
                level       = 25,
                xp          = 26,
                trade       = 0,
                members     = true
            }, {
                name        = "Rogue",
                iconSize    = 21,
                level       = 32,
                xp          = 12,
                trade       = 0,
                members     = true
            }, {
                name        = "Cave goblin",
                icon        = "Cave goblin (Dorgesh-Kaan)",
                iconSize    = 21,
                level       = 36,
                xp          = 40,
                trade       = 0,
                members     = true
            }, {
                name        = "Master Farmer",
                iconSize    = 21,
                level       = 38,
                xp          = 43,
                trade       = 0,
                members     = true
            }, {
                name        = "Guard",
                icon        = "Guard (Falador, sword)",
                iconSize    = 21,
                level       = 40,
                xp          = 46.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Ghotistix",
                icon        = "Ghotistix chathead",
                iconSize    = 21,
                level       = 42,
                xp          = 43,
                trade       = 0,
                members     = true
            }, {
                name        = "Druid (Garden of Kharid)",
                icon        = "Polletix_chathead",
                iconSize    = 21,
                level       = 42,
                xp          = 58,
                trade       = 0,
                members     = true
            }, {
                name        = "Brigand",
                icon        = "Brigand_chathead",
                iconSize    = 21,
                level       = 45,
                xp          = 65,
                trade       = 0,
                members     = true
            }, {
                name        = "Fremennik citizen",
                icon        = "Pontak",
                iconSize    = 21,
                level       = 45,
                xp          = 65,
                trade       = 0,
                members     = true
            }, {
                name        = "Menaphite marketeer",
                iconSize    = 21,
                level       = 46,
                xp          = 29.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Trainee archaeologist",
                icon		= "Trainee archaeologist icon",
                iconSize    = 21,
                level       = 50,
                xp          = 75,
                trade       = 0,
                members     = true
            }, {
                name        = "Bandit (Kharid Bandit Camp)",
                title       = "Desert Bandit",
                icon        = "Bandit (Kharidian Desert Bandit Camp) icon",
                iconSize    = 21,
                level       = 53,
                xp          = 79.4,
                trade       = 0,
                members     = true
            }, {
                name        = "Bandit (Pollnivneach)",
                title       = "Pollnivian Bandit",
                icon        = "Bandit (Pollnivneach) chathead",
                iconSize    = 21,
                level       = 55,
                xp          = 84.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Knight of Ardougne",
                iconSize    = 21,
                level       = 55,
                xp          = 84.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Wizards' Tower mage",
                icon        = "Wizards' Tower mage icon",
                iconSize    = 21,
                level       = 64,
                xp          = 94.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Watchman (Yanille)",
                title       = "Yanille Watchman",
                icon        = "Watchman",
                iconSize    = 21,
                level       = 65,
                xp          = 96.2,
                trade       = 0,
                members     = true
            }, {
                name        = "Monkey knife fighter",
                icon        = "Monkey knife fighter chathead",
                iconSize    = 21,
                level       = 70,
                xp          = 150,
                trade       = 0,
                members     = true
            }, {
                name        = "Paladin",
                icon        = "Paladin icon",
                level       = 70,
                xp          = 106.2,
                trade       = 0,
                members     = true
            }, {
                name        = "Gnome",
                icon        = "Local Gnome chathead",
                iconSize    = 21,
                level       = 75,
                xp          = 138.83,
                trade       = 0,
                members     = true
            }, {
                name        = "Archaeologist",
                icon        = "Archaeologist icon",
                iconSize    = 21,
                level       = 78,
                xp          = 168,
                trade       = 0,
                members     = true
            }, {
                name        = "Hero",
                iconSize    = 21,
                level       = 80,
                xp          = 191.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Crux Eqal Knight",
                iconSize    = 21,
                level       = 83,
                xp          = 194.2,
                trade       = 0,
                members     = true
            }, {
                name        = "Elf",
                icon        = "Ilfeen chathead",
                iconSize    = 21,
                level       = 85,
                xp          = 247.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Trader",
                title       = "Dwarf trader",
                icon        = "Trader (Yellow Fortune) 2",
                iconSize    = 21,
                level       = 90,
                xp          = 389.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Iorwerth worker",
                icon        = "Iorwerth worker icon",
                iconSize    = 21,
                level       = 91,
                xp          = 125,
                trade       = 0,
                members     = true
            }, {
                name        = "Ithell worker",
                icon        = "Ithell worker icon",
                iconSize    = 21,
                level       = 92,
                xp          = 130,
                trade       = 0,
                members     = true
            }, {
                name        = "Rogue Captain",
                iconSize    = 21,
                level       = 92,
                xp          = 125,
                trade       = 0,
                members     = true
            }, {
                name        = "Cadarn worker",
                icon        = "Cadarn worker icon",
                iconSize    = 21,
                level       = 93,
                xp          = 135,
                trade       = 0,
                members     = true
            }, {
                name        = "Amlodd worker",
                icon        = "Amlodd worker icon",
                iconSize    = 21,
                level       = 94,
                xp          = 140,
                trade       = 0,
                members     = true
            }, {
                name        = "Trahaearn worker",
                icon        = "Trahaearn worker icon",
                iconSize    = 21,
                level       = 95,
                xp          = 145,
                trade       = 0,
                members     = true
            }, {
                name        = "Hefin worker",
                icon        = "Hefin worker icon",
                iconSize    = 21,
                level       = 96,
                xp          = 150,
                trade       = 0,
                members     = true
            }, {
                name        = "Crwys worker",
                icon        = "Crwys worker icon",
                iconSize    = 21,
                level       = 97,
                xp          = 155,
                trade       = 0,
                members     = true
            }, {
                name        = "Meilyr worker",
                icon        = "Meilyr worker icon",
                iconSize    = 21,
                level       = 98,
                xp          = 170,
                trade       = 0,
                members     = true
            }, {
                name        = "Vyrewatch tither",
                icon        = "Vyrewatch tither icon",
                iconSize    = 21,
                level       = 100,
                xp          = 422,
                trade       = 0,
                members     = true
            }, {
                name        = "Goebie scavenger",
                icon        = "Goebie scavenger icon",
                iconSize    = 21,
                level       = 102,
                xp          = 441,
                trade       = 0,
                members     = true
            }, {
                name        = "Menaphos market guard",
                icon        = "Menaphos market guard icon",
                iconSize    = 21,
                level       = 104,
                xp          = 462,
                trade       = 0,
                members     = true
            }, {
                name        = "Wizards' Tower master mage",
                icon        = "Wizards' Tower master mage icon",
                iconSize    = 21,
                level       = 106,
                xp          = 483,
                trade       = 0,
                members     = true
            }, {
                name        = "Archaeology professor",
                icon        = "Archaeology professor icon",
                iconSize    = 21,
                level       = 108,
                xp          = 493.5,
                trade       = 0,
                members     = true
            }, {
                name        = "TzHaar-Hur trader",
                icon        = "TzHaar-Hur trader icon",
                iconSize    = 21,
                level       = 111,
                xp          = 504,
                trade       = 0,
                members     = true
            }, {
                name        = "Fairy trader",
                icon        = "Fairy trader icon",
                iconSize    = 21,
                level       = 113,
                xp          = 525,
                trade       = 0,
                members     = true
            }, {
                name        = "Vyrelord consumer",
                icon        = "Vyrelord consumer icon",
                iconSize    = 21,
                level       = 118,
                xp          = 577.5,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    --Milestones
    --Pickpocket
    if trainMethod == "Pickpocket (Sticky Fingers)" then
        local methods = 
        {
            {
                name        = "Man",
                title       = "Man or Woman",
                icon        = "Man chathead",
                iconSize    = 21,
                level       = 1,
                xp          = 5.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Gullible tourist",
                icon        = "Gullible tourist",
                iconSize    = 21,
                level       = 1,
                xp          = 19.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Farmer",
                icon        = "Farmer icon",
                level       = 10,
                xp          = 9.6,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. member",
                title       = "Female H.A.M. member",
                icon        = "H.A.M. Member (female) chathead",
                iconSize    = 21,
                level       = 15,
                xp          = 12.3,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. member",
                title       = "Male H.A.M. member",
                icon        = "H.A.M. Member (male) chathead",
                iconSize    = 21,
                level       = 20,
                xp          = 14.8,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. Guard",
                icon        = "H.A.M. Guard chathead",
                iconSize    = 21,
                level       = 23,
                xp          = 14.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Dig Site workman",
                icon        = "Dig Site workman chathead",
                iconSize    = 21,
                level       = 25,
                xp          = 6.9,
                trade       = 0,
                members     = true
            }, {
                name        = "Desert Phoenix",
                icon        = "Desert Phoenix",
                iconSize    = 21,
                level       = 25,
                xp          = 17.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Warrior woman",
                iconSize    = 21,
                level       = 25,
                xp          = 17.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Rogue",
                iconSize    = 21,
                level       = 32,
                xp          = 8,
                trade       = 0,
                members     = true
            }, {
                name        = "Cave goblin",
                icon        = "Cave goblin (Dorgesh-Kaan)",
                iconSize    = 21,
                level       = 36,
                xp          = 26.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Master Farmer",
                iconSize    = 21,
                level       = 38,
                xp          = 28.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Guard",
                icon        = "Guard (Falador, sword)",
                iconSize    = 21,
                level       = 40,
                xp          = 31.2,
                trade       = 0,
                members     = true
            }, {
                name        = "Ghotistix",
                icon        = "Ghotistix chathead",
                iconSize    = 21,
                level       = 42,
                xp          = 29.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Druid (Garden of Kharid)",
                icon        = "Polletix_chathead",
                iconSize    = 21,
                level       = 42,
                xp          = 38.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Brigand",
                icon        = "Brigand_chathead",
                iconSize    = 21,
                level       = 45,
                xp          = 43.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Fremennik citizen",
                icon        = "Pontak",
                iconSize    = 21,
                level       = 45,
                xp          = 43.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Menaphite marketeer",
                iconSize    = 21,
                level       = 46,
                xp          = 19.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Trainee archaeologist",
                icon		= "Trainee archaeologist icon",
                iconSize    = 21,
                level       = 50,
                xp          = 50,
                trade       = 0,
                members     = true
            }, {
                name        = "Bandit (Kharid Bandit Camp)",
                title       = "Desert Bandit",
                icon        = "Bandit (Kharidian Desert Bandit Camp) icon",
                iconSize    = 21,
                level       = 53,
                xp          = 52.9,
                trade       = 0,
                members     = true
            }, {
                name        = "Bandit (Pollnivneach)",
                title       = "Pollnivian Bandit",
                icon        = "Bandit (Pollnivneach) chathead",
                iconSize    = 21,
                level       = 55,
                xp          = 56.2,
                trade       = 0,
                members     = true
            }, {
                name        = "Knight of Ardougne",
                iconSize    = 21,
                level       = 55,
                xp          = 56.2,
                trade       = 0,
                members     = true
            }, {
                name        = "Wizards' Tower mage",
                icon        = "Wizards' Tower mage icon",
                iconSize    = 21,
                level       = 64,
                xp          = 63,
                trade       = 0,
                members     = true
            }, {
                name        = "Watchman (Yanille)",
                title       = "Yanille Watchman",
                icon        = "Watchman",
                iconSize    = 21,
                level       = 65,
                xp          = 64.1,
                trade       = 0,
                members     = true
            }, {
                name        = "Monkey knife fighter",
                icon        = "Monkey knife fighter chathead",
                iconSize    = 21,
                level       = 70,
                xp          = 100,
                trade       = 0,
                members     = true
            }, {
                name        = "Paladin",
                icon        = "Paladin icon",
                level       = 70,
                xp          = 70.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Gnome",
                icon        = "Local Gnome chathead",
                iconSize    = 21,
                level       = 75,
                xp          = 92.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Archaeologist",
                icon        = "Archaeologist icon",
                iconSize    = 21,
                level       = 78,
                xp          = 112,
                trade       = 0,
                members     = true
            }, {
                name        = "Hero",
                iconSize    = 21,
                level       = 80,
                xp          = 127.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Crux Eqal Knight",
                iconSize    = 21,
                level       = 83,
                xp          = 129.4,
                trade       = 0,
                members     = true
            }, {
                name        = "Elf",
                icon        = "Ilfeen chathead",
                iconSize    = 21,
                level       = 85,
                xp          = 164.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Trader",
                title       = "Dwarf trader",
                icon        = "Trader (Yellow Fortune) 2",
                iconSize    = 21,
                level       = 90,
                xp          = 259.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Iorwerth worker",
                icon        = "Iorwerth worker icon",
                iconSize    = 21,
                level       = 91,
                xp          = 83.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Ithell worker",
                icon        = "Ithell worker icon",
                iconSize    = 21,
                level       = 92,
                xp          = 86.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Rogue Captain",
                iconSize    = 21,
                level       = 92,
                xp          = 83.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Cadarn worker",
                icon        = "Cadarn worker icon",
                iconSize    = 21,
                level       = 93,
                xp          = 90,
                trade       = 0,
                members     = true
            }, {
                name        = "Amlodd worker",
                icon        = "Amlodd worker icon",
                iconSize    = 21,
                level       = 94,
                xp          = 93.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Trahaearn worker",
                icon        = "Trahaearn worker icon",
                iconSize    = 21,
                level       = 95,
                xp          = 96.6,
                trade       = 0,
                members     = true
            }, {
                name        = "Hefin worker",
                icon        = "Hefin worker icon",
                iconSize    = 21,
                level       = 96,
                xp          = 100,
                trade       = 0,
                members     = true
            }, {
                name        = "Crwys worker",
                icon        = "Crwys worker icon",
                iconSize    = 21,
                level       = 97,
                xp          = 103.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Meilyr worker",
                icon        = "Meilyr worker icon",
                iconSize    = 21,
                level       = 98,
                xp          = 113.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Vyrewatch tither",
                icon        = "Vyrewatch tither icon",
                iconSize    = 21,
                level       = 100,
                xp          = 281.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Goebie scavenger",
                icon        = "Goebie scavenger icon",
                iconSize    = 21,
                level       = 102,
                xp          = 294,
                trade       = 0,
                members     = true
            }, {
                name        = "Menaphos market guard",
                icon        = "Menaphos market guard icon",
                iconSize    = 21,
                level       = 104,
                xp          = 308,
                trade       = 0,
                members     = true
            }, {
                name        = "Wizards' Tower master mage",
                icon        = "Wizards' Tower master mage icon",
                iconSize    = 21,
                level       = 106,
                xp          = 322,
                trade       = 0,
                members     = true
            }, {
                name        = "Archaeology professor",
                icon        = "Archaeology professor icon",
                iconSize    = 21,
                level       = 108,
                xp          = 329,
                trade       = 0,
                members     = true
            }, {
                name        = "TzHaar-Hur trader",
                icon        = "TzHaar-Hur trader icon",
                iconSize    = 21,
                level       = 111,
                xp          = 336,
                trade       = 0,
                members     = true
            }, {
                name        = "Fairy trader",
                icon        = "Fairy trader icon",
                iconSize    = 21,
                level       = 113,
                xp          = 350,
                trade       = 0,
                members     = true
            }, {
                name        = "Vyrelord consumer",
                icon        = "Vyrelord consumer icon",
                iconSize    = 21,
                level       = 118,
                xp          = 385,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    --TBD
    if trainMethod == "Other" then
        local methods = 
        {
            {
                name        = "Desert Phoenix",
                iconSize    = 21,
                level       = 25,
                xp          = 26,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    --Stalls
    if trainMethod == "Stalls" then
        local methods = 
        {
            {
                name        = "Vegetable stall",
                icon        = "Cabbage",
                iconSize    = 21,
                level       = 1,
                xp          = 10,
                trade       = 0,
                members     = true
            }, {
                name        = "Baker's stall",
                icon        = "Cake",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Crafting stall",
                icon        = "Chisel",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Monkey Food stall",
                icon        = "Banana",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Monkey general store",
                icon        = "Pot of flour",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Tea stall",
                icon        = "Cup of tea",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Rock cake stall",
                icon        = "Rock cake",
                iconSize    = 21,
                level       = 15,
                xp          = 6.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Silk stall",
                icon        = "Silk",
                iconSize    = 21,
                level       = 20,
                xp          = 24,
                trade       = 0,
                members     = true
            }, {
                name        = "Wine stall",
                icon        = "Bottle of wine",
                iconSize    = 21,
                level       = 22,
                xp          = 27,
                trade       = 0,
                members     = true
            }, {
                name        = "Seed stall",
                icon        = "Barley seed 5",
                iconSize    = 21,
                level       = 27,
                xp          = 10,
                trade       = 0,
                members     = true
            }, {
                name        = "Fur stall",
                icon        = "Bear fur",
                iconSize    = 21,
                level       = 35,
                xp          = 36,
                trade       = 0,
                members     = true
            }, {
                name        = "Fish stall",
                icon        = "Raw salmon",
                iconSize    = 21,
                level       = 42,
                xp          = 42,
                trade       = 0,
                members     = true
            }, {
                name        = "Lamp stall",
                icon        = "Antique lamp (Medium Daemonheim Tasks)",
                iconSize    = 21,
                level       = 46,
                xp          = 30,
                trade       = 0,
                members     = true
            }, {
                name        = "Crossbow stall",
                icon        = "Bronze crossbow",
                iconSize    = 21,
                level       = 49,
                xp          = 52,
                trade       = 0,
                members     = true
            }, {
                name        = "Silver stall",
                icon        = "Silver ore",
                iconSize    = 21,
                level       = 50,
                xp          = 54,
                trade       = 0,
                members     = true
            }, {
                name        = "Customs evidence files",
                icon        = "Sealed clue scroll (medium)",
                iconSize    = 21,
                level       = 63,
                xp          = 75,
                trade       = 0,
                members     = true
            }, {
                name        = "Ardougne Spice Stall",
                icon        = "Gnome spice",
                iconSize    = 21,
                level       = 65,
                xp          = 81,
                trade       = 0,
                members     = true
            }, {
                name        = "Magic stall",
                icon        = "Air rune",
                level       = 65,
                xp          = 100,
                trade       = 0,
                members     = true
            }, {
                name        = "Scimitar stall",
                icon        = "Iron scimitar",
                iconSize    = 21,
                level       = 65,
                xp          = 160,
                trade       = 0,
                members     = true
            }, {
                name        = "Gem stall",
                icon        = "Sapphire",
                iconSize    = 21,
                level       = 75,
                xp          = 160,
                trade       = 0,
                members     = true
            }, {
                name        = "Zanaris Market spirit stall",
                icon        = "Luminite stone spirit",
                iconSize    = 21,
                level       = 107,
                xp          = 1025.9,
                trade       = 0,
                members     = true
            }, {
                name        = "Zanaris Market seed stall",
                icon        = "Spirit weed seed 5",
                iconSize    = 21,
                level       = 114,
                xp          = 1234.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Darkmeyer meat stall",
                icon        = "Meaty mush",
                iconSize    = 21,
                level       = 115,
                xp          = 1264.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Zanaris Market trinket stall",
                icon        = "Dragon scale dust",
                iconSize    = 21,
                level       = 116,
                xp          = 1294.0,
                trade       = 0,
                members     = true
            }, {
                name        = "Darkmeyer magic stall",
                icon        = "Blood rune",
                iconSize    = 21,
                level       = 117,
                xp          = 1323.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Darkmeyer potion stall",
                icon        = "Super Zamorak brew (1)",
                iconSize    = 21,
                level       = 119,
                xp          = 1404.6,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
     
    --Chests
    if trainMethod == "Chests" then
        local methods = 
        {
            {
                sLink       = "Chests in",
                name        = "Ardougne",
                title       = "Ardougne,",
                eLink       = "[[Rellekka]] and the [[Wilderness]]",
                icon        = "Coins 100",
                level       = 13,
                xp          = 7,
                trade       = 0,
                members     = true
            }, {
                sLink       = "Chests upstairs in",
                name        = "Ardougne",
                eLink       = "and [[Rellekka]]",
                icon        = "Nature rune",
                level       = 28,
                xp          = 25,
                trade       = 0,
                members     = true
            }, {
                sLink       = "Chests upstairs in",
                name        = "Ardougne",
                icon        = "Coins 100",
                level       = 43,
                xp          = 125,
                trade       = 0,
                members     = true
            }, {
                sLink       = "Chests in",
                name        = "Hemenster",
                icon        = "Steel arrowheads",
                level       = 47,
                xp          = 150,
                trade       = 0,
                members     = true
            }, {
                sLink       = "Chests in",
                name        = "Rellekka",
                icon        = "Coins 100",
                level       = 47,
                xp          = 150,
                trade       = 0,
                members     = true
            }, {
                sLink       = "Chests in",
                name        = "Dorgesh-Kaan",
                icon        = "Oil lantern (empty)",
                level       = 52,
                xp          = 200,
                trade       = 0,
                members     = true
            }, {
                sLink       = "Chests in the",
                name        = "Chaos Druid Tower",
                title       = "Chaos Druid Tower,",
                eLink       = "north of [[Ardougne]]",
                icon        = "Blood rune",
                level       = 59,
                xp          = 250,
                trade       = 0,
                members     = true
            }, {
                sLink       = "Chests in King Lathas's",
                name        = "Ardougne Castle",
                title       = "castle",
                eLink       = "in [[Ardougne]]",
                icon        = "Raw shark",
                level       = 72,
                xp          = 500,
                trade       = 0,
                members     = true
            }, {
                sLink       = "Chests in",
                name        = "Dorgesh-Kaan",
                icon        = "Uncut sapphire",
                level       = 78,
                xp          = 650,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
   
    --Chests
    if trainMethod == "Multi-step chests" then
        local methods = 
        {
            {
                name        = "Chest (Dwarven mines, Thieving)",
                title       = "Dwarven mines chest",
                icon        = "Double ammo mould",
                level       = 71,
                xp          = 1078.4,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Chaos Druid Tower, 75 Thieving)",
                title       = "Chaos Druid Tower chest",
                icon        = "Grimy spirit weed",
                level       = 75,
                xp          = 1282,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Wizards' Tower)",
                title       = "Wizards' Tower chest",
                icon        = "Mist rune",
                level       = 77,
                xp          = 1400,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (White Knights' Castle)",
                title       = "White Knights' Castle chest",
                icon        = "White full helm",
                level       = 88,
                xp          = 2274,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Keldagrim, Thieving)",
                title       = "Keldagrim chest",
                icon        = "Necronium bar",
                level       = 94,
                xp          = 2892,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Black Knights' Fortress)",
                title       = "Black Knights' Fortress chest",
                icon        = "Black battleaxe",
                level       = 98,
                xp          = 3638,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Living Rock Caverns)",
                title       = "Living Rock Caverns chest",
                icon        = "Banite ore",
                level       = 101,
                xp          = 3874,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Cadarn district)",
                title       = "Cadarn district chest",
                icon        = "Crystal acorn",
                level       = 103,
                xp          = 4144,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Ourania Cave)",
                title       = "Ourania Cave chest",
                icon        = "Pure essence",
                level       = 107,
                xp          = 4689,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Wizards' Guild)",
                title       = "Wizards' Guild chest",
                icon        = "Mystic cloth",
                level       = 110,
                xp          = 5098,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (City of Um)",
                title       = "City of Um chest",
                icon        = "Greater flaming skull",
                level       = 112,
                xp          = 5370,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Darkmeyer, Thieving)",
                title       = "Darkmeyer chest",
                icon        = "Congealed blood 1000",
                level       = 116,
                xp          = 5914,
                trade       = 0,
                members     = true
            }, {
                name        = "Chest (Rasial's Citadel)",
                title       = "Rasial's Citadel chest",
                icon        = "Miasma rune",
                level       = 119,
                xp          = 6422,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end

    --Safes (needs icon, or set to show no icon?)
    if trainMethod == "Safes" then
        local methods = 
        {
            {
                name        = "Safecracking#Misthalin",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Misthalin",
                eLink       = "safes",
                level       = 62,
                xp          = 2815,
                noIcon      = 0,
                location    = "",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Misthalin",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Misthalin",
                eLink       = "safes",
                level       = 65,
                xp          = 2815,
                location    = "In the treasury room on the roof of the [[Varrock palace]]",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Kharidian Desert",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Kharidian desert",
                eLink       = "safes",
                level       = 69,
                xp          = 5195,
                location    = "",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Asgarnia",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Asgarnia",
                eLink       = "safes",
                level       = 76,
                xp          = 6995,
                location    = "",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Kandarin",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Kandarin",
                eLink       = "safes",
                level       = 83,
                xp          = 8825,
                location    = "",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Hidden",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Hidden",
                eLink       = "safes",
                level       = 90,
                xp          = 10867,
                location    = "[[Zemouregal's fort]]",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Hidden",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Hidden",
                eLink       = "safes",
                level       = 90.1,
                xp          = 11575,
                location    = "[[Zanaris marketplace]]",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Hidden",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Hidden",
                eLink       = "safes",
                level       = 90.2,
                xp          = 19145,
                location    = "[[Rogues' Castle]]",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Hidden",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Hidden",
                eLink       = "safes",
                level       = 92,
                xp          = 11210,
                location    = "[[Zemouregal's fort]]",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Hidden",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Hidden",
                eLink       = "safes",
                level       = 94,
                xp          = 11576,
                location    = "[[Zemouregal's fort]]",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Hidden",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Hidden",
                eLink       = "safes",
                level       = 94.1,
                xp          = 11575,
                location    = "[[Zanaris marketplace]]",
                trade       = 0,
                members     = true
            }, {
                name        = "Safecracking#Hidden",
                icon        = "Thieving",
                iconSize    = 21,
                title       = "Hidden",
                eLink       = "safes",
                level       = 96,
                xp          = 11943,
                location    = "[[Zemouregal's fort]]",
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
    
    --Doors
    if trainMethod == "Doors" then
       local methods = 
        {
            {
                name        = "Door to 10-coin chest",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 1,
                xp          = 3.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Door to Nature rune chest",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 14,
                xp          = 15,
                trade       = 0,
                members     = true
            }, {
                name        = "Ardougne house door",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 14,
                xp          = 15,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. entrance",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 15,
                xp          = 3.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Thieves' Guild north doors",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 15,
                xp          = 160,
                trade       = 0,
                members     = true
            }, {
                name        = "Thieves' Guild south doors",
                icon        = "Lockpick",
                iconSize    = 21,
                level       = 35,
                xp          = 215,
                trade       = 0,
                members     = true
            }, {
                name        = "Magic axe hut door",
                icon        = "Lockpick",
                iconSize    = 21,
                level       = 32,
                xp          = 25,
                trade       = 0,
                members     = true
            }, {
                name        = "Ardougne sewer gate",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 32,
                xp          = 25,
                trade       = 0,
                members     = true
            }, {
                name        = "Pirates' Hideout",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 39,
                xp          = 35,
                trade       = 0,
                members     = true
            }, {
                name        = "Chaos druid tower",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 46,
                xp          = 37.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Paladin door",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 61,
                xp          = 50,
                trade       = 0,
                members     = true
            }, {
                name        = "Yanille dungeon door",
                icon        = "Lockpick",
                iconSize    = 21,
                level       = 82,
                xp          = 50,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
	
	
	--Pickpocket Stalls Doors
    if trainMethod == "Pickpocket Stalls and Doors" then
       local methods = 
        {
		 {
                name        = "Man",
                icon        = "Man chathead",
                iconSize    = 21,
                level       = 1,
                xp          = 8,
                trade       = 0,
                members     = true
            }, {
                name        = "Farmer",
                icon        = "Farmer icon",
                level       = 10,
                xp          = 14.5,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. member",
                title       = "Female H.A.M. member",
                icon        = "H.A.M. Member (female) chathead",
                iconSize    = 21,
                level       = 15,
                xp          = 18.5,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. member",
                title       = "Male H.A.M. member",
                icon        = "H.A.M. Member (male) chathead",
                iconSize    = 21,
                level       = 20,
                xp          = 22.2,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. Guard",
                icon        = "H.A.M. Guard chathead",
                iconSize    = 21,
                level       = 23,
                xp          = 22.2,
                trade       = 0,
                members     = true
            }, {
                name        = "Warrior woman",
                iconSize    = 21,
                level       = 25,
                xp          = 26,
                trade       = 0,
                members     = true
            }, {
                name        = "Rogue",
                iconSize    = 21,
                level       = 32,
                xp          = 36.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Cave goblin",
                icon        = "Cavegoblin",
                iconSize    = 21,
                level       = 36,
                xp          = 40,
                trade       = 0,
                members     = true
            }, {
                name        = "Master Farmer",
                iconSize    = 21,
                level       = 38,
                xp          = 43,
                trade       = 0,
                members     = true
            }, {
                name        = "Guard",
                icon        = "Guard (Lvl 21)",
                iconSize    = 21,
                level       = 40,
                xp          = 46.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Bearded Pollnivnian bandit",
                icon        = "Bandit chathead",
                iconSize    = 21,
                level       = 45,
                xp          = 65,
                trade       = 0,
                members     = true
            }, {
                name        = "Fremennik citizen",
                icon        = "Pontak",
                iconSize    = 21,
                level       = 45,
                xp          = 65,
                trade       = 0,
                members     = true
            }, {
                name        = "Menaphite marketeer",
                iconSize    = 21,
                level       = 46,
                xp          = 29.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Bandit (Kharid Bandit Camp)",
                title       = "Desert Bandit",
                icon        = "Bandit Kharid chathead",
                iconSize    = 21,
                level       = 53,
                xp          = 79.4,
                trade       = 0,
                members     = true
            }, {
                name        = "Knight of Ardougne",
                iconSize    = 21,
                level       = 55,
                xp          = 84.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Bandit (Pollnivneach)",
                title       = "Pollnivian Bandit",
                icon        = "Pollnivneach bandit chathead",
                iconSize    = 21,
                level       = 55.1,
                xp          = 84.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Watchman (Yanille)",
                title       = "Yanille Watchman",
                icon        = "Yannile Watchman",
                iconSize    = 21,
                level       = 65,
                xp          = 137.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Menaphite Thug",
                icon        = "Menaphite thug chathead",
                iconSize    = 21,
                level       = 65.1,
                xp          = 137.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Paladin",
                icon        = "Paladin icon",
                level       = 70,
                xp          = 151.8,
                trade       = 0,
                members     = true
            }, {
                name        = "Monkey knife fighter",
                icon        = "Monkey knife fighter chathead",
                iconSize    = 21,
                level       = 70,
                xp          = 150,
                trade       = 0,
                members     = true
            }, {
                name        = "Gnome",
                icon        = "Local Gnome chathead",
                iconSize    = 21,
                level       = 75,
                xp          = 198.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Hero",
                iconSize    = 21,
                level       = 80,
                xp          = 273.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Elf",
                icon        = "Ilfeen chathead",
                iconSize    = 21,
                level       = 85,
                xp          = 353.3,
                trade       = 0,
                members     = true
            }, {
                name        = "Trader",
                title       = "Dwarf trader",
                icon        = "Trader (dwarf)",
                iconSize    = 21,
                level       = 90,
                xp          = 389.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Iorwerth worker",
                icon        = "Iorwerth worker icon",
                iconSize    = 21,
                level       = 91,
                xp          = 125,
                trade       = 0,
                members     = true
            }, {
                name        = "Ithell worker",
                icon        = "Ithell worker icon",
                iconSize    = 21,
                level       = 92,
                xp          = 130,
                trade       = 0,
                members     = true
            }, {
                name        = "Rogue Captain",
                iconSize    = 21,
                level       = 92,
                xp          = 125,
                trade       = 0,
                members     = true
            }, {
                name        = "Cadarn worker",
                icon        = "Cadarn worker icon",
                iconSize    = 21,
                level       = 93,
                xp          = 135,
                trade       = 0,
                members     = true
            }, {
                name        = "Amlodd worker",
                icon        = "Amlodd worker icon",
                iconSize    = 21,
                level       = 94,
                xp          = 140,
                trade       = 0,
                members     = true
            }, {
                name        = "Trahaearn worker",
                icon        = "Trahaearn worker icon",
                iconSize    = 21,
                level       = 95,
                xp          = 145,
                trade       = 0,
                members     = true
            }, {
                name        = "Hefin worker",
                icon        = "Hefin worker icon",
                iconSize    = 21,
                level       = 96,
                xp          = 150,
                trade       = 0,
                members     = true
            }, {
                name        = "Crwys worker",
                icon        = "Crwys worker icon",
                iconSize    = 21,
                level       = 97,
                xp          = 155,
                trade       = 0,
                members     = true
            }, {
                name        = "Meilyr worker",
                icon        = "Meilyr worker icon",
                iconSize    = 21,
                level       = 98,
                xp          = 170,
                trade       = 0,
                members     = true
            }, {
                name        = "Vegetable stall",
                icon        = "Cabbage",
                iconSize    = 21,
                level       = 1,
                xp          = 10,
                trade       = 0,
                members     = true
            }, {
                name        = "Baker's stall",
                icon        = "Cake",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Crafting stall",
                icon        = "Chisel",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Monkey Food stall",
                icon        = "Banana",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Monkey general store",
                icon        = "Pot of flour",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Tea stall",
                icon        = "Cup of tea",
                iconSize    = 21,
                level       = 5,
                xp          = 16,
                trade       = 0,
                members     = true
            }, {
                name        = "Rock cake stall",
                icon        = "Rock cake",
                iconSize    = 21,
                level       = 15,
                xp          = 6.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Silk stall",
                icon        = "Silk",
                iconSize    = 21,
                level       = 20,
                xp          = 24,
                trade       = 0,
                members     = true
            }, {
                name        = "Wine stall",
                icon        = "Bottle of wine",
                iconSize    = 21,
                level       = 22,
                xp          = 27,
                trade       = 0,
                members     = true
            }, {
                name        = "Seed stall",
                icon        = "Barley seed 5",
                iconSize    = 21,
                level       = 27,
                xp          = 10,
                trade       = 0,
                members     = true
            }, {
                name        = "Fur stall",
                icon        = "Bear fur",
                iconSize    = 21,
                level       = 35,
                xp          = 36,
                trade       = 0,
                members     = true
            }, {
                name        = "Fish stall",
                icon        = "Raw salmon",
                iconSize    = 21,
                level       = 42,
                xp          = 42,
                trade       = 0,
                members     = true
            }, {
                name        = "Lamp stall",
                icon        = "Antique lamp (Medium Daemonheim Tasks)",
                iconSize    = 21,
                level       = 46,
                xp          = 30,
                trade       = 0,
                members     = true
            }, {
                name        = "Crossbow stall",
                icon        = "Bronze crossbow",
                iconSize    = 21,
                level       = 49,
                xp          = 52,
                trade       = 0,
                members     = true
            }, {
                name        = "Silver stall",
                icon        = "Silver ore",
                iconSize    = 21,
                level       = 50,
                xp          = 54,
                trade       = 0,
                members     = true
            }, {
                name        = "Customs evidence files",
                icon        = "Clue scroll",
                iconSize    = 21,
                level       = 63,
                xp          = 81,
                trade       = 0,
                members     = true
            }, {
                name        = "Ardougne Spice Stall",
                icon        = "Gnome spice",
                iconSize    = 21,
                level       = 65,
                xp          = 81,
                trade       = 0,
                members     = true
            }, {
                name        = "Magic stall",
                icon        = "Air rune",
                level       = 65,
                xp          = 100,
                trade       = 0,
                members     = true
            }, {
                name        = "Scimitar stall",
                icon        = "Iron scimitar",
                iconSize    = 21,
                level       = 65,
                xp          = 160,
                trade       = 0,
                members     = true
            }, {
                name        = "Gem stall",
                icon        = "Sapphire",
                iconSize    = 21,
                level       = 75,
                xp          = 160,
                trade       = 0,
                members     = true
            }, {
                name        = "Door to 10-coin chest",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 1,
                xp          = 3.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Door to Nature rune chest",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 14,
                xp          = 15,
                trade       = 0,
                members     = true
            }, {
                name        = "Ardougne house door",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 14,
                xp          = 15,
                trade       = 0,
                members     = true
            }, {
                name        = "H.A.M. entrance",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 15,
                xp          = 3.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Thieves' Guild north doors",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 15,
                xp          = 160,
                trade       = 0,
                members     = true
            }, {
                name        = "Thieves' Guild south doors",
                icon        = "Lockpick",
                iconSize    = 21,
                level       = 35,
                xp          = 215,
                trade       = 0,
                members     = true
            }, {
                name        = "Magic axe hut door",
                icon        = "Lockpick",
                iconSize    = 21,
                level       = 32,
                xp          = 25,
                trade       = 0,
                members     = true
            }, {
                name        = "Ardougne sewer gate",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 32,
                xp          = 25,
                trade       = 0,
                members     = true
            }, {
                name        = "Pirates' Hideout",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 39,
                xp          = 35,
                trade       = 0,
                members     = true
            }, {
                name        = "Chaos druid tower",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 46,
                xp          = 37.5,
                trade       = 0,
                members     = true
            }, {
                name        = "Paladin door",
                icon        = "Thieving",
                iconSize    = 21,
                level       = 61,
                xp          = 50,
                trade       = 0,
                members     = true
            }, {
                name        = "Yanille dungeon door",
                icon        = "Lockpick",
                iconSize    = 21,
                level       = 82,
                xp          = 50,
                trade       = 0,
                members     = true
            }
        }
        return methods
    end
  
end