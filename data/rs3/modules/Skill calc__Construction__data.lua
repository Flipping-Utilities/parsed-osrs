--[=[
     Notations found in this Module:
        * name:     Name of object
        * title:    Alternative name of object
            - Used to clarify the difference from a similar object or offer a cleaner name
        * icon:     Alternate image location
        * multi:    Used when multiple items are needed in the product icon space
        * level:    Level required to complete
        * xp:       Experience gained
        * material: Materials required { #, "Item name", ...}
        * mcount:   Material count - Number of materials required
            - This allows for exclusion of items not found in the GE
        * bench:    Bench required for flatpacks
        * wood:     Type of wood required
--]=]
local skillData = {}
return function(trainMethod)
    -- Supplies
    if trainMethod == "Supplies" then
        local methods =
        {
            {   
                name        = "Plank & Nail",
                multi       = {"Plank", "Iron nails"},
                level       = 1,
                xp          = 29,
                material    = {1, "Plank", 1, "Iron nails"},
                mcount      = 2
            }, {
                name        = "Bolt of cloth",
                level       = 2,
                xp          = 15,
                material    = {1, "Bolt of cloth"}
            }, {
                name        = "Soft clay",
                level       = 3,
                xp          = 10,
                material    = {1, "Soft clay"}
            }, {
                name        = "Iron bar",
                level       = 5,
                xp          = 10,
                material    = {1, "Iron bar"}
            }, {
                name        = "Limestone brick",
                level       = 5.1,
                xp          = 20,
                material    = {1, "Limestone brick"}
            }, {
                name        = "Steel bar",
                level       = 7,
                xp          = 20,
                material    = {1, "Steel bar"}
            }, {
                name        = "Oak plank",
                level       = 15,
                xp          = 60,
                material    = {1, "Oak plank"},
                members     = true
            }, {
                name        = "Teak plank",
                level       = 35,
                xp          = 90,
                material    = {1, "Teak plank"},
                members     = true
            }, {
                name        = "Mahogany plank",
                level       = 40,
                xp          = 140,
                material    = {1, "Mahogany plank"},
                members     = true
            }, {
            	name        = "Eternal plank",
            	level       = 99,
            	xp          = 520,
            	material    = {1, "Eternal plank"},
            	members     = true
            }
        }
        return methods
    end

	-- All furniture
    if trainMethod == "Furniture" then
    	-- this is currently being updated from bucket
    	-- see https://runescape.wiki/w/User:Umlaught/Construction_xp_gen for up to date data
        local methods = 
        {
			{
				name        = "Oak table",
				level       = 32,
				xp          = 240,
				icon        = "Oak table",
				material    = {4, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Wooden table",
				level       = 12,
				xp          = 115,
				icon        = "Wooden table",
				material    = {4, "Plank", 4, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Gold sink",
				level       = 115,
				xp          = 10067,
				icon        = "Gold sink",
				material    = {15, "Gold bar", 100000000, "Coins"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Amulet of glory (furniture)",
				level       = 47,
				xp          = 290,
				icon        = "Amulet of glory (furniture)",
				material    = {3, "Teak plank", 1, "Amulet of glory"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "King Arthur portrait",
				level       = 35,
				xp          = 211,
				icon        = "King Arthur portrait",
				material    = {2, "Teak plank", 1, "Arthur portrait"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Miscellanians portrait",
				level       = 55,
				xp          = 311,
				icon        = "Miscellanians portrait",
				material    = {2, "Mahogany plank", 1, "Misc. portrait"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Helmet pluming stand",
				level       = 16,
				xp          = 120,
				icon        = "Helmet pluming stand",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Armour repair stand",
				level       = 55,
				xp          = 500,
				icon        = "Armour repair stand",
				material    = {8, "Oak plank", 1, "Limestone brick"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak chair",
				level       = 35,
				xp          = 180,
				icon        = "Teak chair",
				material    = {2, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Banner making stand",
				level       = 66,
				xp          = 510,
				icon        = "Banner making stand",
				material    = {8, "Oak plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany chair",
				level       = 50,
				xp          = 280,
				icon        = "Mahogany chair",
				material    = {2, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak bench",
				level       = 38,
				xp          = 360,
				icon        = "Teak bench",
				material    = {4, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Guthix altar",
				level       = 105,
				xp          = 5899,
				icon        = "Guthix altar",
				material    = {2, "Marble block", 2, "Gold leaf", 3, "Magic stone", 3, "Stone of binding", 4, "Triskelion", 8, "Banded limestone"},
				members     = true,
				mcount      = 6
			},
			{
				name        = "Steel framed workbench",
				level       = 46,
				xp          = 440,
				icon        = "Steel framed workbench",
				material    = {6, "Oak plank", 4, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Steel torch",
				level       = 45,
				xp          = 40,
				icon        = "Steel torch",
				material    = {2, "Steel bar"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Floatsam prawnbroker",
				level       = 73,
				xp          = 1120,
				icon        = "Floatsam prawnbroker",
				material    = {8, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Salvage hunter diving suit",
				level       = 80,
				xp          = 26,
				icon        = "Salvage hunter diving suit",
				material    = {1, "Fishbowl", 5, "Bronze bar", 1, "Telescope lenses"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Portal nexus",
				level       = 74,
				xp          = 2000,
				icon        = "Portal nexus",
				material    = {4, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Anti-dragon shield (furniture)",
				level       = 47,
				xp          = 280,
				icon        = "Anti-dragon shield (furniture)",
				material    = {3, "Teak plank", 1, "Anti-dragon shield"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Cape of legends (furniture)",
				level       = 47,
				xp          = 300,
				icon        = "Cape of legends (furniture)",
				material    = {3, "Teak plank", 1, "Cape of legends"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mermaid hunter diving suit",
				level       = 72,
				xp          = 26,
				icon        = "Mermaid hunter diving suit",
				material    = {1, "Fishbowl", 5, "Bronze bar", 1, "Porthole"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Mahogany bed",
				level       = 53,
				xp          = 450,
				icon        = "Mahogany bed",
				material    = {3, "Mahogany plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Seren altar",
				level       = 105,
				xp          = 6378,
				icon        = "Seren altar",
				material    = {2, "Marble block", 2, "Gold leaf", 3, "Magic stone", 3, "Stone of binding", 100, "Corrupted ore", 1, "Cleansing crystal"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 6
			},
			{
				name        = "Basic jewellery box",
				level       = 81,
				xp          = 861,
				icon        = "Basic jewellery box",
				material    = {3, "Mahogany plank", 1, "Gold leaf", 3, "Ring of duelling (8)", 3, "Games necklace (8)", 3, "Ring of respawn (new)"},
				members     = true,
				mcount      = 5
			},
			{
				name        = "Fancy jewellery box",
				level       = 86,
				xp          = 1577,
				icon        = "Fancy jewellery box",
				material    = {1, "Basic jewellery box", 2, "Mahogany plank", 2, "Gold leaf", 5, "Combat bracelet (4)", 5, "Enlightened amulet (new)", 5, "Skills necklace (4)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 6
			},
			{
				name        = "Grandmaster portal nexus",
				level       = 104,
				xp          = 9000,
				icon        = "Grandmaster portal nexus",
				material    = {5, "Magic stone", 5, "Gold leaf", 5, "Marble block"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Ornate jewellery box",
				level       = 91,
				xp          = 1629,
				icon        = "Ornate jewellery box",
				material    = {1, "Fancy jewellery box", 2, "Mahogany plank", 2, "Gold leaf", 7, "Amulet of glory (4)", 7, "Ring of slaying (8)", 7, "Ring of Wealth (4)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 6
			},
			{
				name        = "Adamant armour stand",
				level       = 28,
				xp          = 150,
				icon        = "Adamant armour stand",
				material    = {2, "Oak plank", 1, "Adamant platebody", 1, "Adamant plateskirt", 1, "Adamant full helm"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "Astronomical chart",
				level       = 63,
				xp          = 45,
				icon        = "Astronomical chart",
				material    = {3, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Basic decorative armour stand",
				level       = 28,
				xp          = 135,
				icon        = "Basic decorative armour stand",
				material    = {2, "Oak plank", 1, "Basic decorative platebody", 1, "Basic decorative shield", 1, "Basic decorative helm"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 4
			},
			{
				name        = "Bluebells",
				level       = 76,
				xp          = 122,
				icon        = "Bluebells",
				material    = {1, "Bagged bluebells"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Bush (furniture)",
				level       = 6,
				xp          = 70,
				icon        = "Bush (furniture)",
				material    = {1, "Bagged plant 2"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Clay fireplace",
				level       = 3,
				xp          = 30,
				icon        = "Clay fireplace",
				material    = {3, "Soft clay"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Cloth altar",
				level       = 56,
				xp          = 390,
				icon        = "Cloth altar",
				material    = {4, "Teak plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Combat dummy",
				level       = 30,
				xp          = 84,
				icon        = "Combat dummy",
				material    = {3, "Plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Consecrated pet house",
				level       = 92,
				xp          = 1560,
				icon        = "Consecrated pet house",
				material    = {4, "Mahogany plank", 1, "Magic stone"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Crude wooden chair",
				level       = 1,
				xp          = 58,
				icon        = "Crude wooden chair",
				material    = {2, "Plank", 2, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Crystal ball",
				level       = 42,
				xp          = 280,
				icon        = "Crystal ball",
				material    = {3, "Teak plank", 1, "Unpowered orb"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Crystal of power",
				level       = 66,
				xp          = 890,
				icon        = "Crystal of power",
				material    = {2, "Mahogany plank", 1, "Unpowered orb", 2, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Crystal throne",
				level       = 95,
				xp          = 15000,
				icon        = "Crystal throne",
				material    = {15, "Magic stone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Daffodils",
				level       = 71,
				xp          = 100,
				icon        = "Daffodils",
				material    = {1, "Bagged daffodils"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Darklight (furniture)",
				level       = 42,
				xp          = 202,
				icon        = "Darklight (furniture)",
				material    = {2, "Teak plank", 1, "Darklight"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Dartboard",
				level       = 54,
				xp          = 290,
				icon        = "Dartboard",
				material    = {3, "Teak plank", 1, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Decorative rock",
				level       = 5,
				xp          = 100,
				icon        = "Decorative rock",
				material    = {5, "Limestone brick"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Demon lectern",
				level       = 47,
				xp          = 120,
				icon        = "Demon lectern",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Demonic throne",
				level       = 99,
				xp          = 25000,
				icon        = "Demonic throne",
				material    = {25, "Magic stone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Detailed decorative armour stand",
				level       = 28,
				xp          = 150,
				icon        = "Detailed decorative armour stand",
				material    = {2, "Oak plank", 1, "Detailed decorative platebody", 1, "Detailed decorative shield", 1, "Detailed decorative helm"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 4
			},
			{
				name        = "Dock leaf",
				level       = 1,
				xp          = 31,
				icon        = "Dock leaf",
				material    = {1, "Bagged plant 1"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Eagle lectern",
				level       = 47,
				xp          = 129,
				icon        = "Eagle lectern",
				material    = {2, "Oak plank", 2, "Bronze bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Excalibur (furniture)",
				level       = 42,
				xp          = 194,
				icon        = "Excalibur (furniture)",
				material    = {2, "Teak plank", 1, "Excalibur"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Fancy hedge",
				level       = 72,
				xp          = 158,
				icon        = "Fancy hedge",
				material    = {1, "Fancy hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Fancy range",
				level       = 42,
				xp          = 160,
				icon        = "Fancy range",
				material    = {8, "Steel bar"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Firepit",
				level       = 5,
				xp          = 40,
				icon        = "Firepit",
				material    = {1, "Steel bar", 2, "Soft clay"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Firepit with hook",
				level       = 11,
				xp          = 60,
				icon        = "Firepit with hook",
				material    = {2, "Steel bar", 2, "Soft clay"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Firepit with pot",
				level       = 17,
				xp          = 80,
				icon        = "Firepit with pot",
				material    = {3, "Steel bar", 2, "Soft clay"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Gilded altar",
				level       = 75,
				xp          = 2230,
				icon        = "Gilded altar",
				material    = {2, "Marble block", 2, "Bolt of cloth", 4, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Gold candlesticks",
				level       = 57,
				xp          = 39,
				icon        = "Gold candlesticks",
				material    = {3, "Gold bar", 3, "White candle"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Huge plant",
				level       = 12,
				xp          = 100,
				icon        = "Huge plant",
				material    = {1, "Bagged plant 3"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Intricate decorative armour stand",
				level       = 28,
				xp          = 165,
				icon        = "Intricate decorative armour stand",
				material    = {2, "Oak plank", 1, "Intricate decorative platebody", 1, "Intricate decorative shield", 1, "Intricate decorative helm"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 4
			},
			{
				name        = "Large fountain",
				level       = 75,
				xp          = 1000,
				icon        = "Large fountain",
				material    = {2, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Large leaf bush",
				level       = 6,
				xp          = 70,
				icon        = "Large leaf bush",
				material    = {1, "Bagged plant 2"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Large oven",
				level       = 29,
				xp          = 100,
				icon        = "Large oven",
				material    = {5, "Steel bar"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Large statue",
				level       = 89,
				xp          = 1500,
				icon        = "Large statue",
				material    = {3, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Limestone altar",
				level       = 64,
				xp          = 910,
				icon        = "Limestone altar",
				material    = {6, "Mahogany plank", 2, "Bolt of cloth", 2, "Limestone brick"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Mahogany altar",
				level       = 60,
				xp          = 590,
				icon        = "Mahogany altar",
				material    = {4, "Mahogany plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany armchair",
				level       = 57,
				xp          = 310,
				icon        = "Mahogany armchair",
				material    = {2, "Mahogany plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany armour case",
				level       = 82,
				xp          = 420,
				icon        = "Mahogany armour case",
				material    = {3, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany bench",
				level       = 57,
				xp          = 560,
				icon        = "Mahogany bench",
				material    = {4, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany bookcase",
				level       = 64,
				xp          = 420,
				icon        = "Mahogany bookcase",
				material    = {3, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany demon lectern",
				level       = 67,
				xp          = 580,
				icon        = "Mahogany demon lectern",
				material    = {2, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany dresser",
				level       = 64,
				xp          = 281,
				icon        = "Mahogany dresser",
				material    = {2, "Mahogany plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany eagle lectern",
				level       = 67,
				xp          = 580,
				icon        = "Mahogany eagle lectern",
				material    = {2, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany fancy dress box",
				level       = 80,
				xp          = 280,
				icon        = "Mahogany fancy dress box",
				material    = {2, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany incense burners",
				level       = 65,
				xp          = 300,
				icon        = "Mahogany incense burners",
				material    = {2, "Mahogany plank", 1, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany magic wardrobe",
				level       = 78,
				xp          = 560,
				icon        = "Mahogany magic wardrobe",
				material    = {4, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany pet house",
				level       = 67,
				xp          = 560,
				icon        = "Mahogany pet house",
				material    = {4, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany portal",
				level       = 65,
				xp          = 420,
				icon        = "Mahogany portal",
				material    = {3, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany table",
				level       = 64,
				xp          = 560,
				icon        = "Mahogany table",
				material    = {4, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany telescope",
				level       = 84,
				xp          = 281,
				icon        = "Mahogany telescope",
				material    = {2, "Mahogany plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany throne",
				level       = 74,
				xp          = 2200,
				icon        = "Mahogany throne",
				material    = {5, "Mahogany plank", 3, "Marble block"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany toy box",
				level       = 86,
				xp          = 280,
				icon        = "Mahogany toy box",
				material    = {2, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany treasure chest",
				level       = 84,
				xp          = 280,
				icon        = "Mahogany treasure chest",
				material    = {2, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany wardrobe",
				level       = 75,
				xp          = 420,
				icon        = "Mahogany wardrobe",
				material    = {3, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Marble altar",
				level       = 70,
				xp          = 1030,
				icon        = "Marble altar",
				material    = {2, "Marble block", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Marble fireplace",
				level       = 63,
				xp          = 1000,
				icon        = "Marble fireplace",
				material    = {2, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Marble incense burners",
				level       = 69,
				xp          = 520,
				icon        = "Marble incense burners",
				material    = {1, "Marble block", 1, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Marble magic wardrobe",
				level       = 96,
				xp          = 500,
				icon        = "Marble magic wardrobe",
				material    = {1, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Marble portal",
				level       = 80,
				xp          = 1500,
				icon        = "Marble portal",
				material    = {3, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Medium statue",
				level       = 69,
				xp          = 500,
				icon        = "Medium statue",
				material    = {1, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mithril armour stand",
				level       = 28,
				xp          = 135,
				icon        = "Mithril armour stand",
				material    = {2, "Oak plank", 1, "Mithril platebody", 1, "Mithril plateskirt", 1, "Mithril full helm"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "Natural pet house",
				level       = 92,
				xp          = 1560,
				icon        = "Natural pet house",
				material    = {4, "Mahogany plank", 1, "Magic stone"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Nice tree",
				level       = 10,
				xp          = 44,
				icon        = "Nice tree",
				material    = {1, "Bagged nice tree"},
				mtrade      = 0,
				trade       = 0,
				members     = false,
				mcount      = 1
			},
			{
				name        = "Oak altar",
				level       = 45,
				xp          = 240,
				icon        = "Oak altar",
				material    = {4, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak armchair",
				level       = 26,
				xp          = 135,
				icon        = "Oak armchair",
				material    = {2, "Oak plank", 1, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak armour case",
				level       = 46,
				xp          = 180,
				icon        = "Oak armour case",
				material    = {3, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak bed",
				level       = 30,
				xp          = 210,
				icon        = "Oak bed",
				material    = {3, "Oak plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak bench",
				level       = 22,
				xp          = 240,
				icon        = "Oak bench",
				material    = {4, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak bookcase",
				level       = 29,
				xp          = 180,
				icon        = "Oak bookcase",
				material    = {3, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak chair",
				level       = 15,
				xp          = 120,
				icon        = "Oak chair",
				material    = {2, "Oak plank"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Oak clock",
				level       = 25,
				xp          = 142,
				icon        = "Oak clock",
				material    = {2, "Oak plank", 1, "Clockwork"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak drawers",
				level       = 27,
				xp          = 120,
				icon        = "Oak drawers",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak dresser",
				level       = 37,
				xp          = 121,
				icon        = "Oak dresser",
				material    = {2, "Oak plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak fancy dress box",
				level       = 44,
				xp          = 120,
				icon        = "Oak fancy dress box",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak incense burners",
				level       = 61,
				xp          = 140,
				icon        = "Oak incense burners",
				material    = {2, "Oak plank", 1, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak larder",
				level       = 33,
				xp          = 480,
				icon        = "Oak larder",
				material    = {8, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak lectern",
				level       = 40,
				xp          = 60,
				icon        = "Oak lectern",
				material    = {1, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak magic wardrobe",
				level       = 42,
				xp          = 240,
				icon        = "Oak magic wardrobe",
				material    = {4, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak pet house",
				level       = 37,
				xp          = 240,
				icon        = "Oak pet house",
				material    = {4, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak shelves 1",
				level       = 28,
				xp          = 240,
				icon        = "Oak shelves 1",
				material    = {3, "Oak plank", 6, "Soft clay"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak shelves 2",
				level       = 34,
				xp          = 240,
				icon        = "Oak shelves 2",
				material    = {3, "Oak plank", 6, "Soft clay"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak throne",
				level       = 60,
				xp          = 800,
				icon        = "Oak throne",
				material    = {5, "Oak plank", 1, "Marble block"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak toy box",
				level       = 50,
				xp          = 120,
				icon        = "Oak toy box",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak treasure chest",
				level       = 48,
				xp          = 120,
				icon        = "Oak treasure chest",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak wardrobe",
				level       = 39,
				xp          = 180,
				icon        = "Oak wardrobe",
				material    = {3, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Plant (furniture)",
				level       = 1,
				xp          = 31,
				icon        = "Plant (furniture)",
				material    = {1, "Bagged plant 1"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Posh fountain",
				level       = 81,
				xp          = 1500,
				icon        = "Posh fountain",
				material    = {3, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Profound decorative armour stand",
				level       = 28,
				xp          = 180,
				icon        = "Profound decorative armour stand",
				material    = {2, "Oak plank", 1, "Profound decorative platebody", 1, "Profound decorative shield", 1, "Profound decorative helm"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 4
			},
			{
				name        = "Reeds (furniture)",
				level       = 12,
				xp          = 100,
				icon        = "Reeds (furniture)",
				material    = {1, "Bagged plant 3"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Repair bench",
				level       = 15,
				xp          = 120,
				icon        = "Repair bench",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Rune armour stand",
				level       = 28,
				xp          = 165,
				icon        = "Rune armour stand",
				material    = {2, "Oak plank", 1, "Rune platebody", 1, "Rune plateskirt", 1, "Rune full helm"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "Shoe box",
				level       = 20,
				xp          = 58,
				icon        = "Shoe box",
				material    = {2, "Plank", 2, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Short plant",
				level       = 1,
				xp          = 31,
				icon        = "Short plant",
				material    = {1, "Bagged plant 1"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Silverlight (furniture)",
				level       = 42,
				xp          = 187,
				icon        = "Silverlight (furniture)",
				material    = {2, "Teak plank", 1, "Silverlight"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Sink (furniture)",
				level       = 47,
				xp          = 300,
				icon        = "Sink (furniture)",
				material    = {15, "Steel bar"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Skeleton throne",
				level       = 88,
				xp          = 7012,
				icon        = "Skeleton throne",
				material    = {5, "Magic stone", 4, "Marble block", 5, "Bones", 2, "Skull"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 4
			},
			{
				name        = "Small fern",
				level       = 6,
				xp          = 70,
				icon        = "Small fern",
				material    = {1, "Bagged plant 2"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small fountain",
				level       = 71,
				xp          = 500,
				icon        = "Small fountain",
				material    = {1, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small statue",
				level       = 49,
				xp          = 40,
				icon        = "Small statue",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Steel candlesticks",
				level       = 53,
				xp          = 69,
				icon        = "Steel candlesticks",
				material    = {3, "Steel bar", 3, "White candle"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Steel range",
				level       = 34,
				xp          = 120,
				icon        = "Steel range",
				material    = {6, "Steel bar"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone fireplace",
				level       = 33,
				xp          = 40,
				icon        = "Stone fireplace",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Sunflower (furniture)",
				level       = 66,
				xp          = 70,
				icon        = "Sunflower (furniture)",
				material    = {1, "Bagged sunflower"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tall fancy hedge",
				level       = 76,
				xp          = 223,
				icon        = "Tall fancy hedge",
				material    = {1, "Tall fancy hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tall plant",
				level       = 12,
				xp          = 100,
				icon        = "Tall plant",
				material    = {1, "Bagged plant 3"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak altar",
				level       = 50,
				xp          = 360,
				icon        = "Teak altar",
				material    = {4, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak armchair",
				level       = 42,
				xp          = 195,
				icon        = "Teak armchair",
				material    = {2, "Teak plank", 1, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak armour case",
				level       = 64,
				xp          = 270,
				icon        = "Teak armour case",
				material    = {3, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak bed",
				level       = 40,
				xp          = 300,
				icon        = "Teak bed",
				material    = {3, "Teak plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak clock",
				level       = 55,
				xp          = 202,
				icon        = "Teak clock",
				material    = {2, "Teak plank", 1, "Clockwork"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak demon lectern",
				level       = 57,
				xp          = 180,
				icon        = "Teak demon lectern",
				material    = {2, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak drawers",
				level       = 51,
				xp          = 180,
				icon        = "Teak drawers",
				material    = {2, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak dresser",
				level       = 46,
				xp          = 181,
				icon        = "Teak dresser",
				material    = {2, "Teak plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak eagle lectern",
				level       = 57,
				xp          = 189,
				icon        = "Teak eagle lectern",
				material    = {2, "Teak plank", 2, "Bronze bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak fancy dress box",
				level       = 62,
				xp          = 180,
				icon        = "Teak fancy dress box",
				material    = {2, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak larder",
				level       = 45,
				xp          = 750,
				icon        = "Teak larder",
				material    = {8, "Teak plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak magic wardrobe",
				level       = 60,
				xp          = 360,
				icon        = "Teak magic wardrobe",
				material    = {4, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak pet house",
				level       = 52,
				xp          = 360,
				icon        = "Teak pet house",
				material    = {4, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak portal",
				level       = 50,
				xp          = 270,
				icon        = "Teak portal",
				material    = {3, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak shelves 1",
				level       = 50,
				xp          = 330,
				icon        = "Teak shelves 1",
				material    = {3, "Teak plank", 6, "Soft clay"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak shelves 2",
				level       = 56,
				xp          = 330,
				icon        = "Teak shelves 2",
				material    = {3, "Teak plank", 6, "Soft clay"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak table",
				level       = 52,
				xp          = 360,
				icon        = "Teak table",
				material    = {4, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak telescope",
				level       = 64,
				xp          = 181,
				icon        = "Teak telescope",
				material    = {2, "Teak plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak throne",
				level       = 67,
				xp          = 1450,
				icon        = "Teak throne",
				material    = {5, "Teak plank", 2, "Marble block"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak toy box",
				level       = 68,
				xp          = 180,
				icon        = "Teak toy box",
				material    = {2, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak treasure chest",
				level       = 66,
				xp          = 180,
				icon        = "Teak treasure chest",
				material    = {2, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak wardrobe",
				level       = 63,
				xp          = 270,
				icon        = "Teak wardrobe",
				material    = {3, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Thistle (furniture)",
				level       = 6,
				xp          = 70,
				icon        = "Thistle (furniture)",
				material    = {1, "Bagged plant 2"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Whetstone",
				level       = 35,
				xp          = 260,
				icon        = "Whetstone",
				material    = {4, "Oak plank", 1, "Limestone brick"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Wooden bed",
				level       = 20,
				xp          = 117,
				icon        = "Wooden bed",
				material    = {3, "Plank", 3, "Steel nails", 2, "Bolt of cloth"},
				members     = false,
				mcount      = 3
			},
			{
				name        = "Wooden bench",
				level       = 10,
				xp          = 115,
				icon        = "Wooden bench",
				material    = {4, "Plank", 4, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Wooden bookcase",
				level       = 6,
				xp          = 115,
				icon        = "Wooden bookcase",
				material    = {4, "Plank", 4, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Wooden larder",
				level       = 16,
				xp          = 228,
				icon        = "Wooden larder",
				material    = {8, "Plank", 8, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Wooden shelves 1",
				level       = 6,
				xp          = 87,
				icon        = "Wooden shelves 1",
				material    = {3, "Plank", 3, "Bronze nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Wooden shelves 2",
				level       = 12,
				xp          = 147,
				icon        = "Wooden shelves 2",
				material    = {3, "Plank", 3, "Steel nails", 6, "Soft clay"},
				members     = false,
				mcount      = 3
			},
			{
				name        = "Wooden shelves 3",
				level       = 23,
				xp          = 147,
				icon        = "Wooden shelves 3",
				material    = {3, "Plank", 3, "Steel nails", 6, "Soft clay"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Wooden telescope",
				level       = 44,
				xp          = 121,
				icon        = "Wooden telescope",
				material    = {2, "Oak plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Wooden workbench",
				level       = 17,
				xp          = 143,
				icon        = "Wooden workbench",
				material    = {5, "Plank", 5, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Seren teleport stone",
				level       = 85,
				xp          = 1762,
				icon        = "Seren teleport stone",
				material    = {1000, "Corrupted ore", 10, "Cleansing crystal", 1, "Attuned crystal teleport seed"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 3
			},
			{
				name        = "Falador massacre painting",
				level       = 65,
				xp          = 451,
				icon        = "Falador massacre painting",
				material    = {3, "Mahogany plank", 1, "Falador massacre painting (unframed)"},
				mtrade      = 0,
				trade       = 0,
				members     = false,
				mcount      = 2
			},
			{
				name        = "Master portal nexus",
				level       = 94,
				xp          = 2600,
				icon        = "Master portal nexus",
				material    = {2, "Magic stone", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Spirit tree (furniture)",
				level       = 75,
				xp          = 2,
				icon        = "Spirit tree (furniture)",
				material    = {1, "Spirit sapling"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Arcane potion cauldron",
				level       = 110,
				xp          = 10602,
				icon        = "Arcane potion cauldron",
				material    = {15, "Bane bar", 3, "Magic stone", 25, "Soul rune", 1, "Eye of newt"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "Zamorak rug",
				level       = 75,
				xp          = 15,
				icon        = "Zamorak rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal gilded magic wardrobe",
				level       = 114,
				xp          = 2160,
				icon        = "Eternal gilded magic wardrobe",
				material    = {3, "Eternal plank", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded armour case",
				level       = 110,
				xp          = 1860,
				icon        = "Eternal gilded armour case",
				material    = {3, "Eternal plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal fancy dress box",
				level       = 102,
				xp          = 1040,
				icon        = "Eternal fancy dress box",
				material    = {2, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Fairy ring (furniture)",
				level       = 85,
				xp          = 31,
				icon        = "Fairy ring (furniture)",
				material    = {10, "Bittercap mushroom", 1, "Fairy enchantment"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal desk",
				level       = 101,
				xp          = 1560,
				icon        = "Eternal desk",
				material    = {3, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal wardrobe",
				level       = 104,
				xp          = 1560,
				icon        = "Eternal wardrobe",
				material    = {3, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Ritual marker (furniture)",
				level       = 75,
				xp          = 2000,
				icon        = "Ritual marker (furniture)",
				material    = {4, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tied ritual marker",
				level       = 75,
				xp          = 2010,
				icon        = "Tied ritual marker",
				material    = {4, "Marble block", 2, "Rope"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Warped ritual marker",
				level       = 75,
				xp          = 2010,
				icon        = "Warped ritual marker",
				material    = {4, "Marble block", 1, "Warped stone"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Bob rug",
				level       = 75,
				xp          = 15,
				icon        = "Bob rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Bubbling potion cauldron",
				level       = 95,
				xp          = 6366,
				icon        = "Bubbling potion cauldron",
				material    = {10, "Bane bar", 4, "Gold leaf", 50, "Blood rune", 1, "Eye of newt"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "Broken stool",
				level       = 1,
				xp          = 28,
				icon        = "Broken stool",
				material    = {1, "Plank"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Broken round table",
				level       = 1,
				xp          = 56,
				icon        = "Broken round table",
				material    = {2, "Plank"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Altar of war (furniture)",
				level       = 75,
				xp          = 3824,
				icon        = "Altar of war (furniture)",
				material    = {3, "Stone of binding", 2, "Magic stone", 2, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Eternal armchair",
				level       = 99,
				xp          = 1070,
				icon        = "Eternal armchair",
				material    = {2, "Eternal plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal table",
				level       = 100,
				xp          = 2080,
				icon        = "Eternal table",
				material    = {4, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal long table",
				level       = 110,
				xp          = 4160,
				icon        = "Eternal long table",
				material    = {8, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal round table",
				level       = 106,
				xp          = 3120,
				icon        = "Eternal round table",
				material    = {6, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Huge mahogany pedestal",
				level       = 75,
				xp          = 1740,
				icon        = "Huge mahogany pedestal",
				material    = {6, "Mahogany plank", 3, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Huge stone pedestal",
				level       = 35,
				xp          = 120,
				icon        = "Huge stone pedestal",
				material    = {6, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Broken chair",
				level       = 1,
				xp          = 56,
				icon        = "Broken chair",
				material    = {2, "Plank"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Eternal screen",
				level       = 100,
				xp          = 1560,
				icon        = "Eternal screen",
				material    = {3, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal bookcase",
				level       = 99,
				xp          = 1560,
				icon        = "Eternal bookcase",
				material    = {3, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Broken table",
				level       = 1,
				xp          = 84,
				icon        = "Broken table",
				material    = {3, "Plank"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Eternal drawers",
				level       = 100,
				xp          = 1040,
				icon        = "Eternal drawers",
				material    = {2, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal small table",
				level       = 98,
				xp          = 1040,
				icon        = "Eternal small table",
				material    = {2, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal chair",
				level       = 96,
				xp          = 1040,
				icon        = "Eternal chair",
				material    = {2, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal stool",
				level       = 94,
				xp          = 520,
				icon        = "Eternal stool",
				material    = {1, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal large bed",
				level       = 104,
				xp          = 2630,
				icon        = "Eternal large bed",
				material    = {5, "Eternal plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Wooden armchair",
				level       = 8,
				xp          = 73,
				icon        = "Wooden armchair",
				material    = {2, "Plank", 2, "Steel nails", 1, "Bolt of cloth"},
				members     = false,
				mcount      = 3
			},
			{
				name        = "Wooden small table",
				level       = 10,
				xp          = 58,
				icon        = "Wooden small table",
				material    = {2, "Plank", 2, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Eternal bench",
				level       = 104,
				xp          = 2080,
				icon        = "Eternal bench",
				material    = {4, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Wooden round table",
				level       = 14,
				xp          = 172,
				icon        = "Wooden round table",
				material    = {6, "Plank", 6, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Tool storage 1",
				level       = 15,
				xp          = 120,
				icon        = "Tool storage 1",
				material    = {2, "Oak plank"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Eternal throne",
				level       = 110,
				xp          = 4100,
				icon        = "Eternal throne",
				material    = {5, "Eternal plank", 3, "Marble block"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak stool",
				level       = 15,
				xp          = 60,
				icon        = "Oak stool",
				material    = {1, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Wooden long table",
				level       = 16,
				xp          = 228,
				icon        = "Wooden long table",
				material    = {8, "Plank", 8, "Steel nails"},
				members     = false,
				mcount      = 2
			},
			{
				name        = "Kitchen cabinet (jars)",
				level       = 22,
				xp          = 121,
				icon        = "Kitchen cabinet (jars)",
				material    = {2, "Oak plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal bed",
				level       = 103,
				xp          = 1590,
				icon        = "Eternal bed",
				material    = {3, "Eternal plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal dresser",
				level       = 102,
				xp          = 1041,
				icon        = "Eternal dresser",
				material    = {2, "Eternal plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Kitchen cabinet (chopping board)",
				level       = 22,
				xp          = 132,
				icon        = "Kitchen cabinet (chopping board)",
				material    = {2, "Oak plank", 1, "Onion", 1, "Bread", 1, "Knife"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "Kitchen cabinet (washing up)",
				level       = 22,
				xp          = 155,
				icon        = "Kitchen cabinet (washing up)",
				material    = {2, "Oak plank", 1, "Steel bar", 1, "Bolt of cloth"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Kitchen cabinet (pots)",
				level       = 22,
				xp          = 140,
				icon        = "Kitchen cabinet (pots)",
				material    = {2, "Oak plank", 2, "Soft clay"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak kitchen cabinet (small)",
				level       = 22,
				xp          = 120,
				icon        = "Oak kitchen cabinet (small)",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak kitchen cabinet (corner)",
				level       = 22,
				xp          = 180,
				icon        = "Oak kitchen cabinet (corner)",
				material    = {3, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak kitchen cabinet (large)",
				level       = 27,
				xp          = 180,
				icon        = "Oak kitchen cabinet (large)",
				material    = {3, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak kitchen cabinet (small)",
				level       = 38,
				xp          = 180,
				icon        = "Teak kitchen cabinet (small)",
				material    = {2, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak kitchen cabinet (corner)",
				level       = 38,
				xp          = 270,
				icon        = "Teak kitchen cabinet (corner)",
				material    = {3, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak kitchen cabinet (large)",
				level       = 43,
				xp          = 270,
				icon        = "Teak kitchen cabinet (large)",
				material    = {3, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany kitchen cabinet (small)",
				level       = 60,
				xp          = 280,
				icon        = "Mahogany kitchen cabinet (small)",
				material    = {2, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany kitchen cabinet (corner)",
				level       = 60,
				xp          = 420,
				icon        = "Mahogany kitchen cabinet (corner)",
				material    = {3, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany kitchen cabinet (large)",
				level       = 65,
				xp          = 420,
				icon        = "Mahogany kitchen cabinet (large)",
				material    = {3, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tool storage 2",
				level       = 25,
				xp          = 120,
				icon        = "Tool storage 2",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak small table",
				level       = 30,
				xp          = 120,
				icon        = "Oak small table",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak stool",
				level       = 31,
				xp          = 90,
				icon        = "Teak stool",
				material    = {1, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak large bed",
				level       = 34,
				xp          = 330,
				icon        = "Oak large bed",
				material    = {5, "Oak plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak round table",
				level       = 34,
				xp          = 360,
				icon        = "Oak round table",
				material    = {6, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak screen",
				level       = 34,
				xp          = 180,
				icon        = "Oak screen",
				material    = {3, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tool storage 3",
				level       = 35,
				xp          = 180,
				icon        = "Tool storage 3",
				material    = {3, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak desk",
				level       = 35,
				xp          = 60,
				icon        = "Oak desk",
				material    = {1, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak long table",
				level       = 36,
				xp          = 480,
				icon        = "Oak long table",
				material    = {8, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak bookcase",
				level       = 40,
				xp          = 270,
				icon        = "Teak bookcase",
				material    = {3, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tool storage 4",
				level       = 44,
				xp          = 180,
				icon        = "Tool storage 4",
				material    = {3, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oak shelves 3",
				level       = 45,
				xp          = 240,
				icon        = "Oak shelves 3",
				material    = {3, "Oak plank", 6, "Soft clay"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak large bed",
				level       = 45,
				xp          = 480,
				icon        = "Teak large bed",
				material    = {5, "Teak plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany stool",
				level       = 46,
				xp          = 140,
				icon        = "Mahogany stool",
				material    = {1, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak screen",
				level       = 48,
				xp          = 270,
				icon        = "Teak screen",
				material    = {3, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak desk",
				level       = 50,
				xp          = 270,
				icon        = "Teak desk",
				material    = {3, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak small table",
				level       = 50,
				xp          = 180,
				icon        = "Teak small table",
				material    = {2, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak round table",
				level       = 54,
				xp          = 540,
				icon        = "Teak round table",
				material    = {6, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tool storage 5",
				level       = 55,
				xp          = 180,
				icon        = "Tool storage 5",
				material    = {3, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak long table",
				level       = 56,
				xp          = 720,
				icon        = "Teak long table",
				material    = {8, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany large bed",
				level       = 57,
				xp          = 730,
				icon        = "Mahogany large bed",
				material    = {5, "Mahogany plank", 2, "Bolt of cloth"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded bed",
				level       = 60,
				xp          = 1050,
				icon        = "Mahogany gilded bed",
				material    = {3, "Mahogany plank", 2, "Bolt of cloth", 2, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Mahogany gilded chair",
				level       = 60,
				xp          = 580,
				icon        = "Mahogany gilded chair",
				material    = {2, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Banquet",
				level       = 60,
				xp          = 1180,
				icon        = "Banquet",
				material    = {4, "Mahogany plank", 2, "Gold leaf", 1, "Steel bar"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Mahogany small table",
				level       = 60,
				xp          = 280,
				icon        = "Mahogany small table",
				material    = {2, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany gilded bench",
				level       = 61,
				xp          = 1760,
				icon        = "Mahogany gilded bench",
				material    = {4, "Mahogany plank", 4, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded table",
				level       = 108,
				xp          = 2380,
				icon        = "Eternal gilded table",
				material    = {4, "Eternal plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany large gilded bed",
				level       = 65,
				xp          = 1330,
				icon        = "Mahogany large gilded bed",
				material    = {5, "Mahogany plank", 2, "Bolt of cloth", 2, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Mahogany screen",
				level       = 66,
				xp          = 420,
				icon        = "Mahogany screen",
				material    = {3, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Teak shelves 3",
				level       = 67,
				xp          = 330,
				icon        = "Teak shelves 3",
				material    = {3, "Teak plank", 6, "Soft clay"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded armchair",
				level       = 67,
				xp          = 610,
				icon        = "Mahogany gilded armchair",
				material    = {2, "Mahogany plank", 2, "Bolt of cloth", 1, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Mahogany desk",
				level       = 68,
				xp          = 420,
				icon        = "Mahogany desk",
				material    = {3, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany round table",
				level       = 68,
				xp          = 840,
				icon        = "Mahogany round table",
				material    = {6, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany gilded small table",
				level       = 68,
				xp          = 580,
				icon        = "Mahogany gilded small table",
				material    = {2, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany long table",
				level       = 72,
				xp          = 1120,
				icon        = "Mahogany long table",
				material    = {8, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany gilded table",
				level       = 72,
				xp          = 860,
				icon        = "Mahogany gilded table",
				material    = {4, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Vault door",
				level       = 72,
				xp          = 560,
				icon        = "Vault door",
				material    = {20, "Steel bar", 8, "Limestone brick"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded dresser",
				level       = 78,
				xp          = 1020,
				icon        = "Mahogany gilded dresser",
				material    = {3, "Mahogany plank", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany drawers",
				level       = 75,
				xp          = 280,
				icon        = "Mahogany drawers",
				material    = {2, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany gilded round table",
				level       = 76,
				xp          = 1440,
				icon        = "Mahogany gilded round table",
				material    = {6, "Mahogany plank", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded screen",
				level       = 76,
				xp          = 1020,
				icon        = "Mahogany gilded screen",
				material    = {3, "Mahogany plank", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded desk",
				level       = 78,
				xp          = 1020,
				icon        = "Mahogany gilded desk",
				material    = {3, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded long table",
				level       = 80,
				xp          = 2020,
				icon        = "Mahogany gilded long table",
				material    = {8, "Mahogany plank", 3, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded throne",
				level       = 81,
				xp          = 2600,
				icon        = "Mahogany gilded throne",
				material    = {5, "Mahogany plank", 2, "Marble block", 3, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Mahogany gilded drawers",
				level       = 87,
				xp          = 580,
				icon        = "Mahogany gilded drawers",
				material    = {2, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded magic wardrobe",
				level       = 87,
				xp          = 860,
				icon        = "Mahogany gilded magic wardrobe",
				material    = {4, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded wardrobe",
				level       = 87,
				xp          = 720,
				icon        = "Mahogany gilded wardrobe",
				material    = {3, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Clockmaker's bench 1",
				level       = 16,
				xp          = 240,
				icon        = "Clockmaker's bench 1",
				material    = {4, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Clockmaker's bench 2",
				level       = 25,
				xp          = 248,
				icon        = "Clockmaker's bench 2",
				material    = {1, "Clockmaker's bench 1", 4, "Oak plank", 1, "Molten glass"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 3
			},
			{
				name        = "Pump and drain sink",
				level       = 27,
				xp          = 200,
				icon        = "Pump and drain sink",
				material    = {10, "Steel bar"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Clockmaker's bench 3",
				level       = 34,
				xp          = 249,
				icon        = "Clockmaker's bench 3",
				material    = {1, "Clockmaker's bench 2", 4, "Oak plank", 2, "Molten glass"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 3
			},
			{
				name        = "Shield painting easel",
				level       = 41,
				xp          = 240,
				icon        = "Shield painting easel",
				material    = {4, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small obelisk (furniture)",
				level       = 41,
				xp          = 676,
				icon        = "Small obelisk (furniture)",
				material    = {1, "Marble block", 1000, "Spirit shards", 10, "Gold charm", 10, "Green charm", 10, "Crimson charm", 10, "Blue charm"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 6
			},
			{
				name        = "Clockmaker's bench 4",
				level       = 42,
				xp          = 250,
				icon        = "Clockmaker's bench 4",
				material    = {1, "Clockmaker's bench 3", 4, "Oak plank", 3, "Molten glass"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 3
			},
			{
				name        = "Oak cape store",
				level       = 54,
				xp          = 240,
				icon        = "Oak cape store",
				material    = {4, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Reinforced steel framed workbench",
				level       = 62,
				xp          = 600,
				icon        = "Reinforced steel framed workbench",
				material    = {8, "Oak plank", 6, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Teak cape store",
				level       = 63,
				xp          = 360,
				icon        = "Teak cape store",
				material    = {4, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany cape store",
				level       = 72,
				xp          = 560,
				icon        = "Mahogany cape store",
				material    = {4, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Basic potion cauldron",
				level       = 80,
				xp          = 2618,
				icon        = "Basic potion cauldron",
				material    = {5, "Bane bar", 25, "Blood rune", 1, "Eye of newt"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Obelisk (furniture)",
				level       = 80,
				xp          = 2570,
				icon        = "Obelisk (furniture)",
				material    = {4, "Marble block", 1, "Ancient crystal"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded cape store",
				level       = 81,
				xp          = 860,
				icon        = "Mahogany gilded cape store",
				material    = {4, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal toy box",
				level       = 101,
				xp          = 1040,
				icon        = "Eternal toy box",
				material    = {2, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal treasure chest",
				level       = 101,
				xp          = 1040,
				icon        = "Eternal treasure chest",
				material    = {2, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Lumbridge sandcastle (furniture)",
				level       = 20,
				xp          = 2,
				icon        = "Lumbridge sandcastle (furniture)",
				material    = {4, "Bucket of sand"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Bait barrel",
				level       = 74,
				xp          = 577,
				icon        = "Bait barrel",
				material    = {4, "Mahogany plank", 100, "Fishing bait"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Bathysphere",
				level       = 63,
				xp          = 60,
				icon        = "Bathysphere",
				material    = {1, "Fishbowl", 5, "Bronze bar", 5, "Porthole", 5, "Telescope lenses"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "Boutique prawnbroker",
				level       = 81,
				xp          = 1130,
				icon        = "Boutique prawnbroker",
				material    = {8, "Mahogany plank", 1, "Porthole"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Driftwood prawnbroker",
				level       = 63,
				xp          = 720,
				icon        = "Driftwood prawnbroker",
				material    = {8, "Teak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Maps",
				level       = 66,
				xp          = 150,
				icon        = "Maps",
				material    = {1, "Mahogany plank", 1, "Message in a bottle"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Shark jaw",
				level       = 71,
				xp          = 150,
				icon        = "Shark jaw",
				material    = {1, "Mahogany plank", 1, "Shark jawbone"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Twin anchors",
				level       = 69,
				xp          = 55,
				icon        = "Twin anchors",
				material    = {5, "Iron bar", 1, "Rope"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Wizard's tower sandcastle (furniture)",
				level       = 40,
				xp          = 3,
				icon        = "Wizard's tower sandcastle (furniture)",
				material    = {6, "Bucket of sand"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Pyramid sandcastle (furniture)",
				level       = 50,
				xp          = 3,
				icon        = "Pyramid sandcastle (furniture)",
				material    = {7, "Bucket of sand"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Grand exchange sandcastle (furniture)",
				level       = 30,
				xp          = 3,
				icon        = "Grand exchange sandcastle (furniture)",
				material    = {5, "Bucket of sand"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Bob rug (patterned)",
				level       = 84,
				xp          = 15,
				icon        = "Bob rug (patterned)",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Marble cape store",
				level       = 90,
				xp          = 500,
				icon        = "Marble cape store",
				material    = {1, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Desecrated pet house",
				level       = 92,
				xp          = 1560,
				icon        = "Desecrated pet house",
				material    = {4, "Mahogany plank", 1, "Magic stone"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Shabby oval rug",
				level       = 1,
				xp          = 15,
				icon        = "Shabby oval rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Magical cape store",
				level       = 99,
				xp          = 1000,
				icon        = "Magical cape store",
				material    = {1, "Magic stone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Armadyl rug",
				level       = 75,
				xp          = 15,
				icon        = "Armadyl rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Bandos rug",
				level       = 75,
				xp          = 15,
				icon        = "Bandos rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Diamonds rug",
				level       = 70,
				xp          = 15,
				icon        = "Diamonds rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Concentric rug",
				level       = 64,
				xp          = 15,
				icon        = "Concentric rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "House portal (wood)",
				level       = 1,
				xp          = 83,
				icon        = "House portal (wood)",
				material    = {2, "Plank", 1, "Law rune", 1, "Earth rune", 1, "Air rune"},
				members     = false,
				mcount      = 4
			},
			{
				name        = "Clover rug",
				level       = 58,
				xp          = 15,
				icon        = "Clover rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "House portal (teak)",
				level       = 50,
				xp          = 207,
				icon        = "House portal (teak)",
				material    = {2, "Teak plank", 1, "Law rune", 1, "Earth rune", 1, "Air rune"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "House portal (mahogany)",
				level       = 65,
				xp          = 307,
				icon        = "House portal (mahogany)",
				material    = {2, "Mahogany plank", 1, "Law rune", 1, "Earth rune", 1, "Air rune"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "House portal (marble)",
				level       = 89,
				xp          = 1527,
				icon        = "House portal (marble)",
				material    = {3, "Marble block", 1, "Law rune", 1, "Earth rune", 1, "Air rune"},
				members     = true,
				mcount      = 4
			},
			{
				name        = "Circular snake patterned rug",
				level       = 86,
				xp          = 15,
				icon        = "Circular snake patterned rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Fur rug",
				level       = 12,
				xp          = 15,
				icon        = "Fur rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Icon blue rug",
				level       = 32,
				xp          = 15,
				icon        = "Icon blue rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Large blue patterned rug",
				level       = 94,
				xp          = 15,
				icon        = "Large blue patterned rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Large red tasseled rug",
				level       = 88,
				xp          = 15,
				icon        = "Large red tasseled rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Large snake patterned rug",
				level       = 92,
				xp          = 15,
				icon        = "Large snake patterned rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Greater portal nexus",
				level       = 84,
				xp          = 4600,
				icon        = "Greater portal nexus",
				material    = {8, "Marble block", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Long blue rug",
				level       = 16,
				xp          = 15,
				icon        = "Long blue rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Long green rug",
				level       = 20,
				xp          = 15,
				icon        = "Long green rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Red patterned rug",
				level       = 90,
				xp          = 15,
				icon        = "Red patterned rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Semicircular red rug",
				level       = 28,
				xp          = 15,
				icon        = "Semicircular red rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Shabby blue rug",
				level       = 3,
				xp          = 15,
				icon        = "Shabby blue rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small blue rug",
				level       = 6,
				xp          = 15,
				icon        = "Small blue rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tile patterned rug",
				level       = 76,
				xp          = 15,
				icon        = "Tile patterned rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Lobster rug",
				level       = 86,
				xp          = 15,
				icon        = "Lobster rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Storage chest (furniture)",
				level       = 8,
				xp          = 87,
				icon        = "Storage chest (furniture)",
				material    = {3, "Plank", 3, "Steel nails"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Armadyl altar (furniture)",
				level       = 105,
				xp          = 5899,
				icon        = "Armadyl altar (furniture)",
				material    = {2, "Marble block", 2, "Gold leaf", 3, "Magic stone", 3, "Stone of binding", 4, "Wings of War", 8, "Stormguard steel"},
				members     = true,
				mcount      = 6
			},
			{
				name        = "Bandos altar (furniture)",
				level       = 105,
				xp          = 5899,
				icon        = "Bandos altar (furniture)",
				material    = {2, "Marble block", 2, "Gold leaf", 3, "Magic stone", 3, "Stone of binding", 4, "Mark of the Kyzaj", 8, "Warforged bronze"},
				members     = true,
				mcount      = 6
			},
			{
				name        = "Saradomin altar (furniture)",
				level       = 105,
				xp          = 5899,
				icon        = "Saradomin altar (furniture)",
				material    = {2, "Marble block", 2, "Gold leaf", 3, "Magic stone", 3, "Stone of binding", 4, "Star of Saradomin", 8, "Everlight silvthril"},
				members     = true,
				mcount      = 6
			},
			{
				name        = "Saradomin rug",
				level       = 75,
				xp          = 15,
				icon        = "Saradomin rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Zamorak altar (furniture)",
				level       = 105,
				xp          = 5899,
				icon        = "Zamorak altar (furniture)",
				material    = {2, "Marble block", 2, "Gold leaf", 3, "Magic stone", 3, "Stone of binding", 4, "Eye of Dagon", 8, "Hellfire metal"},
				members     = true,
				mcount      = 6
			},
			{
				name        = "Zaros altar (furniture)",
				level       = 105,
				xp          = 5899,
				icon        = "Zaros altar (furniture)",
				material    = {2, "Marble block", 2, "Gold leaf", 3, "Magic stone", 3, "Stone of binding", 4, "Zarosian insignia", 8, "Imperial steel"},
				members     = true,
				mcount      = 6
			},
			{
				name        = "Guthix rug",
				level       = 75,
				xp          = 15,
				icon        = "Guthix rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Zaros rug",
				level       = 75,
				xp          = 15,
				icon        = "Zaros rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Seren rug",
				level       = 75,
				xp          = 15,
				icon        = "Seren rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Brown patterned rug",
				level       = 82,
				xp          = 15,
				icon        = "Brown patterned rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Long red rug",
				level       = 24,
				xp          = 15,
				icon        = "Long red rug",
				material    = {1, "Bolt of cloth"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Wall mount",
				level       = 60,
				xp          = 280,
				icon        = "Wall mount",
				material    = {2, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Cowhide rug",
				level       = 9,
				xp          = 1,
				icon        = "Cowhide rug",
				material    = {3, "Cowhide"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Large wall mount",
				level       = 65,
				xp          = 420,
				icon        = "Large wall mount",
				material    = {3, "Mahogany plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Bearskin rug",
				level       = 52,
				xp          = 5,
				icon        = "Bearskin rug",
				material    = {3, "Bear fur"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small mahogany pedestal",
				level       = 60,
				xp          = 580,
				icon        = "Small mahogany pedestal",
				material    = {2, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Large mahogany pedestal",
				level       = 65,
				xp          = 1100,
				icon        = "Large mahogany pedestal",
				material    = {4, "Mahogany plank", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Decorative dragon and unicorn rug",
				level       = 100,
				xp          = 875,
				icon        = "Decorative dragon and unicorn rug",
				material    = {10, "Bolt of cloth", 2, "Golden thread"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Large stone pedestal",
				level       = 35,
				xp          = 80,
				icon        = "Large stone pedestal",
				material    = {4, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small stone pedestal",
				level       = 35,
				xp          = 40,
				icon        = "Small stone pedestal",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Decorative blue rug",
				level       = 100,
				xp          = 152,
				icon        = "Decorative blue rug",
				material    = {10, "Bolt of cloth", 1, "Blue dye"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Decorative green rug",
				level       = 100,
				xp          = 152,
				icon        = "Decorative green rug",
				material    = {10, "Bolt of cloth", 1, "Green dye"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Decorative black rug",
				level       = 100,
				xp          = 152,
				icon        = "Decorative black rug",
				material    = {10, "Bolt of cloth", 1, "Black mushroom ink"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Decorative red rug",
				level       = 100,
				xp          = 152,
				icon        = "Decorative red rug",
				material    = {10, "Bolt of cloth", 1, "Red dye"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Decorative purple rug",
				level       = 100,
				xp          = 152,
				icon        = "Decorative purple rug",
				material    = {10, "Bolt of cloth", 1, "Purple dye"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Decorative yellow rug",
				level       = 100,
				xp          = 152,
				icon        = "Decorative yellow rug",
				material    = {10, "Bolt of cloth", 1, "Yellow dye"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Rune display case (elemental)",
				level       = 41,
				xp          = 198,
				icon        = "Rune display case (elemental)",
				material    = {2, "Teak plank", 2, "Molten glass", 1, "Air rune", 1, "Water rune", 1, "Earth rune", 1, "Fire rune"},
				members     = true,
				mcount      = 6
			},
			{
				name        = "Rune display case (catalytic)",
				level       = 41,
				xp          = 231,
				icon        = "Rune display case (catalytic)",
				material    = {2, "Teak plank", 2, "Molten glass", 1, "Body rune", 1, "Cosmic rune", 1, "Chaos rune", 1, "Nature rune"},
				members     = true,
				mcount      = 6
			},
			{
				name        = "Teak mirror",
				level       = 44,
				xp          = 91,
				icon        = "Teak mirror",
				material    = {1, "Teak plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded clock",
				level       = 109,
				xp          = 1362,
				icon        = "Eternal gilded clock",
				material    = {2, "Eternal plank", 1, "Clockwork", 1, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Eternal clock",
				level       = 103,
				xp          = 1062,
				icon        = "Eternal clock",
				material    = {2, "Eternal plank", 1, "Clockwork"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Huge gold pile",
				level       = 90,
				xp          = 12704,
				icon        = "Huge gold pile",
				material    = {1, "Small stone pedestal", 100000000, "Coins", 3, "Marble block", 4, "Gold leaf"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 4
			},
			{
				name        = "Small ceramic flower pot",
				level       = 4,
				xp          = 10,
				icon        = "Small ceramic flower pot",
				material    = {1, "Soft clay"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Ceramic flower pot",
				level       = 6,
				xp          = 20,
				icon        = "Ceramic flower pot",
				material    = {2, "Soft clay"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small terracotta flower pot",
				level       = 10,
				xp          = 10,
				icon        = "Small terracotta flower pot",
				material    = {1, "Soft clay"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Mahogany gilded cape stand",
				level       = 85,
				xp          = 580,
				icon        = "Mahogany gilded cape stand",
				material    = {2, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Terracotta flower pot",
				level       = 12,
				xp          = 20,
				icon        = "Terracotta flower pot",
				material    = {2, "Soft clay"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stacked terracotta flower pots (level 14)",
				level       = 14,
				xp          = 40,
				icon        = "Stacked terracotta flower pots (level 14)",
				material    = {4, "Soft clay"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stacked terracotta flower pots (level 16)",
				level       = 16,
				xp          = 40,
				icon        = "Stacked terracotta flower pots (level 16)",
				material    = {4, "Soft clay"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone planter",
				level       = 64,
				xp          = 40,
				icon        = "Stone planter",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "White picket fence",
				level       = 71,
				xp          = 35,
				icon        = "White picket fence",
				material    = {5, "White oak"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal gilded bed",
				level       = 111,
				xp          = 2190,
				icon        = "Eternal gilded bed",
				material    = {3, "Eternal plank", 2, "Bolt of cloth", 2, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Eternal gilded large bed",
				level       = 117,
				xp          = 3230,
				icon        = "Eternal gilded large bed",
				material    = {5, "Eternal plank", 2, "Bolt of cloth", 2, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Mahogany clock",
				level       = 70,
				xp          = 302,
				icon        = "Mahogany clock",
				material    = {2, "Mahogany plank", 1, "Clockwork"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 24,
				xp          = 126,
				icon        = "Flower planter (wood, sunflower)",
				material    = {2, "Plank", 1, "Bagged sunflower"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 28,
				xp          = 184,
				icon        = "Flower planter (wood, chrysanthemum)",
				material    = {3, "Plank", 1, "Bagged chrysanthemum"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 32,
				xp          = 234,
				icon        = "Flower planter (wood, rose)",
				material    = {4, "Plank", 1, "Bagged roses"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 70,
				xp          = 74,
				icon        = "Flower planter (stone, sunflower)",
				material    = {1, "Stone planter", 1, "Bagged sunflower"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 72,
				xp          = 104,
				icon        = "Flower planter (stone, chrysanthemum)",
				material    = {1, "Stone planter", 1, "Bagged chrysanthemum"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 75,
				xp          = 104,
				icon        = "Flower planter (stone, daffodil)",
				material    = {1, "Stone planter", 1, "Bagged daffodils"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 80,
				xp          = 126,
				icon        = "Flower planter (stone, rose)",
				material    = {1, "Stone planter", 1, "Bagged roses"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 82,
				xp          = 8,
				icon        = "Flower planter (stone, hollyhock)",
				material    = {1, "Stone planter", 1, "Bagged hollyhock"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 83,
				xp          = 8,
				icon        = "Flower planter (stone, iris)",
				material    = {1, "Stone planter", 1, "Bagged desert irises"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 84,
				xp          = 8,
				icon        = "Flower planter (stone, hydrangea)",
				material    = {1, "Stone planter", 1, "Bagged desert hydrangeas"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flower planter",
				level       = 85,
				xp          = 8,
				icon        = "Flower planter (stone, oakleaf)",
				material    = {1, "Stone planter", 1, "Bagged desert oakleaf flowers"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded clock",
				level       = 85,
				xp          = 602,
				icon        = "Mahogany gilded clock",
				material    = {2, "Mahogany plank", 1, "Clockwork", 1, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Stacked ceramic flower pots (level 8)",
				level       = 8,
				xp          = 40,
				icon        = "Stacked ceramic flower pots (level 8)",
				material    = {4, "Soft clay"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stacked ceramic flower pots (level 10)",
				level       = 10,
				xp          = 40,
				icon        = "Stacked ceramic flower pots (level 10)",
				material    = {4, "Soft clay"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Oyster hunter diving suit",
				level       = 63,
				xp          = 16,
				icon        = "Oyster hunter diving suit",
				material    = {1, "Fishbowl", 5, "Bronze bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Beehive (furniture)",
				level       = 44,
				xp          = 188,
				icon        = "Beehive (furniture)",
				material    = {3, "Oak plank", 1, "Steel nails", 5, "Honeycomb"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "The lake of fire painting (furniture)",
				level       = 35,
				xp          = 360,
				icon        = "The lake of fire painting (furniture)",
				material    = {2, "Teak plank", 1, "'The Lake of Fire' painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Pride of padosan painting (furniture)",
				level       = 35,
				xp          = 409,
				icon        = "Pride of padosan painting (furniture)",
				material    = {2, "Teak plank", 1, "'The Pride of Padosan' painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Hallowed be the everlight painting (furniture)",
				level       = 35,
				xp          = 409,
				icon        = "Hallowed be the everlight painting (furniture)",
				material    = {2, "Teak plank", 1, "'Hallowed Be the Everlight' painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Prima legio painting (furniture)",
				level       = 35,
				xp          = 422,
				icon        = "Prima legio painting (furniture)",
				material    = {2, "Teak plank", 1, "'Prima Legio' painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Consensus ad idem painting (furniture)",
				level       = 35,
				xp          = 372,
				icon        = "Consensus ad idem painting (furniture)",
				material    = {2, "Teak plank", 1, "'Consensus ad Idem' painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Disorder painting (furniture)",
				level       = 35,
				xp          = 289,
				icon        = "Disorder painting (furniture)",
				material    = {2, "Teak plank", 1, "'Disorder' painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Solem in umbra painting (furniture)",
				level       = 35,
				xp          = 291,
				icon        = "Solem in umbra painting (furniture)",
				material    = {2, "Teak plank", 1, "'Solem in Umbra' painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "The lord of light painting (furniture)",
				level       = 35,
				xp          = 409,
				icon        = "The lord of light painting (furniture)",
				material    = {2, "Teak plank", 1, "'The Lord of Light' painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Well (furniture)",
				level       = 45,
				xp          = 160,
				icon        = "Well (furniture)",
				material    = {8, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "King Alvis painting",
				level       = 35,
				xp          = 211,
				icon        = "King Alvis painting",
				material    = {2, "Teak plank", 1, "Keldagrim portrait"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Lumbridge painting (furniture)",
				level       = 44,
				xp          = 314,
				icon        = "Lumbridge painting (furniture)",
				material    = {3, "Teak plank", 1, "Lumbridge painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Desert painting (furniture)",
				level       = 44,
				xp          = 314,
				icon        = "Desert painting (furniture)",
				material    = {3, "Teak plank", 1, "Desert painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Morytania painting (furniture)",
				level       = 44,
				xp          = 314,
				icon        = "Morytania painting (furniture)",
				material    = {3, "Teak plank", 1, "Morytania painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Karamja painting (furniture)",
				level       = 65,
				xp          = 464,
				icon        = "Karamja painting (furniture)",
				material    = {3, "Mahogany plank", 1, "Karamja painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Isafdar painting (furniture)",
				level       = 65,
				xp          = 464,
				icon        = "Isafdar painting (furniture)",
				material    = {3, "Mahogany plank", 1, "Isafdar painting"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal armour case",
				level       = 103,
				xp          = 1560,
				icon        = "Eternal armour case",
				material    = {3, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small map (furniture)",
				level       = 38,
				xp          = 211,
				icon        = "Small map (furniture)",
				material    = {2, "Teak plank", 1, "Small map"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Medium map (furniture)",
				level       = 58,
				xp          = 451,
				icon        = "Medium map (furniture)",
				material    = {3, "Mahogany plank", 1, "Medium map"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Large map (furniture)",
				level       = 78,
				xp          = 591,
				icon        = "Large map (furniture)",
				material    = {4, "Mahogany plank", 1, "Large map"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Fern (furniture)",
				level       = 12,
				xp          = 100,
				icon        = "Fern (furniture)",
				material    = {1, "Bagged plant 3"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Big fern",
				level       = 1,
				xp          = 31,
				icon        = "Big fern",
				material    = {1, "Bagged plant 1"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Dead tree (furniture)",
				level       = 5,
				xp          = 31,
				icon        = "Dead tree (furniture)",
				material    = {1, "Bagged dead tree"},
				mtrade      = 0,
				trade       = 0,
				members     = false,
				mcount      = 1
			},
			{
				name        = "Oak tree (furniture)",
				level       = 15,
				xp          = 70,
				icon        = "Oak tree (furniture)",
				material    = {1, "Bagged oak tree"},
				mtrade      = 0,
				trade       = 0,
				members     = false,
				mcount      = 1
			},
			{
				name        = "Willow tree (furniture)",
				level       = 30,
				xp          = 100,
				icon        = "Willow tree (furniture)",
				material    = {1, "Bagged willow tree"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Maple tree (furniture)",
				level       = 45,
				xp          = 122,
				icon        = "Maple tree (furniture)",
				material    = {1, "Bagged maple tree"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Yew tree (furniture)",
				level       = 60,
				xp          = 141,
				icon        = "Yew tree (furniture)",
				material    = {1, "Bagged yew tree"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Magic tree (furniture)",
				level       = 75,
				xp          = 223,
				icon        = "Magic tree (furniture)",
				material    = {1, "Bagged magic tree"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal gilded bench",
				level       = 113,
				xp          = 3280,
				icon        = "Eternal gilded bench",
				material    = {4, "Eternal plank", 4, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Mahogany gilded armour case",
				level       = 87,
				xp          = 720,
				icon        = "Mahogany gilded armour case",
				material    = {3, "Mahogany plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded screen",
				level       = 107,
				xp          = 2160,
				icon        = "Eternal gilded screen",
				material    = {3, "Eternal plank", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded desk",
				level       = 108,
				xp          = 2160,
				icon        = "Eternal gilded desk",
				material    = {3, "Eternal plank", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Runefest display case",
				level       = 43,
				xp          = 363,
				icon        = "Runefest display case",
				material    = {4, "Teak plank", 4, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Elena portrait (furniture)",
				level       = 35,
				xp          = 211,
				icon        = "Elena portrait (furniture)",
				material    = {2, "Teak plank", 1, "Elena portrait"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Swordfish fish-head",
				level       = 65,
				xp          = 158,
				icon        = "Swordfish fish-head",
				material    = {1, "Mahogany plank", 1, "Raw swordfish"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Shark fish-head",
				level       = 70,
				xp          = 157,
				icon        = "Shark fish-head",
				material    = {1, "Mahogany plank", 1, "Raw shark"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Great white shark fish-head",
				level       = 76,
				xp          = 158,
				icon        = "Great white shark fish-head",
				material    = {1, "Mahogany plank", 1, "Raw great white shark"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Fishing net (furniture)",
				level       = 64,
				xp          = 7,
				icon        = "Fishing net (furniture)",
				material    = {5, "Wool", 1, "Rope"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Figurehead (furniture)",
				level       = 78,
				xp          = 150,
				icon        = "Figurehead (furniture)",
				material    = {1, "Mahogany plank", 1, "Ship figurehead"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Statue of Dahmaroc plinth",
				level       = 55,
				xp          = 1,
				icon        = "Statue of Dahmaroc plinth",
				material    = {1, "Statue plinth (item)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Safe (furniture)",
				level       = 58,
				xp          = 160,
				icon        = "Safe (furniture)",
				material    = {8, "Steel bar"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Wooden torch",
				level       = 49,
				xp          = 29,
				icon        = "Wooden torch",
				material    = {1, "Plank", 1, "Steel nails"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Organ (furniture)",
				level       = 69,
				xp          = 680,
				icon        = "Organ (furniture)",
				material    = {4, "Mahogany plank", 6, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Trellis archway",
				level       = 65,
				xp          = 920,
				icon        = "Trellis archway",
				material    = {6, "Mahogany plank", 4, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Chrysanthemum",
				level       = 71,
				xp          = 100,
				icon        = "Chrysanthemum",
				material    = {1, "Bagged chrysanthemum"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Roses (furniture)",
				level       = 76,
				xp          = 122,
				icon        = "Roses (furniture)",
				material    = {1, "Bagged roses"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Lavender (furniture)",
				level       = 66,
				xp          = 70,
				icon        = "Lavender (furniture)",
				material    = {1, "Bagged lavender"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small box hedge (1-tile)",
				level       = 64,
				xp          = 122,
				icon        = "Small box hedge (1-tile)",
				material    = {1, "Small box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small box hedge (2-tile)",
				level       = 67,
				xp          = 173,
				icon        = "Small box hedge (2-tile)",
				material    = {2, "Small box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small box hedge (4-tile)",
				level       = 67,
				xp          = 244,
				icon        = "Small box hedge (4-tile)",
				material    = {4, "Small box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small box hedge (6-tile)",
				level       = 67,
				xp          = 300,
				icon        = "Small box hedge (6-tile)",
				material    = {6, "Small box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small box hedge (8-tile)",
				level       = 67,
				xp          = 346,
				icon        = "Small box hedge (8-tile)",
				material    = {8, "Small box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Eternal gilded drawers",
				level       = 106,
				xp          = 1340,
				icon        = "Eternal gilded drawers",
				material    = {2, "Eternal plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded wardrobe",
				level       = 112,
				xp          = 1860,
				icon        = "Eternal gilded wardrobe",
				material    = {3, "Eternal plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Tall box hedge (1-tile)",
				level       = 80,
				xp          = 316,
				icon        = "Tall box hedge (1-tile)",
				material    = {1, "Tall box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tall box hedge (2-tile)",
				level       = 83,
				xp          = 447,
				icon        = "Tall box hedge (2-tile)",
				material    = {2, "Tall box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tall box hedge (4-tile)",
				level       = 83,
				xp          = 632,
				icon        = "Tall box hedge (4-tile)",
				material    = {4, "Tall box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tall box hedge (6-tile)",
				level       = 83,
				xp          = 774,
				icon        = "Tall box hedge (6-tile)",
				material    = {6, "Tall box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Tall box hedge (8-tile)",
				level       = 83,
				xp          = 894,
				icon        = "Tall box hedge (8-tile)",
				material    = {8, "Tall box hedge (bagged)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 1
			},
			{
				name        = "Iron railings (1-tile)",
				level       = 67,
				xp          = 60,
				icon        = "Iron railings (1-tile)",
				material    = {2, "Iron bar", 2, "Limestone brick"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Iron railings (2-tile)",
				level       = 70,
				xp          = 120,
				icon        = "Iron railings (2-tile)",
				material    = {4, "Iron bar", 4, "Limestone brick"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Iron railings (4-tile)",
				level       = 70,
				xp          = 180,
				icon        = "Iron railings (4-tile)",
				material    = {6, "Iron bar", 6, "Limestone brick"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Picket fence (1-tile)",
				level       = 71,
				xp          = 120,
				icon        = "Picket fence (1-tile)",
				material    = {2, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Picket fence (2-tile)",
				level       = 74,
				xp          = 240,
				icon        = "Picket fence (2-tile)",
				material    = {4, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Picket fence (4-tile)",
				level       = 74,
				xp          = 360,
				icon        = "Picket fence (4-tile)",
				material    = {6, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Picket fence (6-tile)",
				level       = 74,
				xp          = 480,
				icon        = "Picket fence (6-tile)",
				material    = {8, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Picket fence (8-tile)",
				level       = 74,
				xp          = 600,
				icon        = "Picket fence (8-tile)",
				material    = {10, "Oak plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Trellis (2-tile)",
				level       = 75,
				xp          = 220,
				icon        = "Trellis (2-tile)",
				material    = {2, "Teak plank", 2, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Trellis (4-tile)",
				level       = 78,
				xp          = 440,
				icon        = "Trellis (4-tile)",
				material    = {4, "Teak plank", 4, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Trellis (6-tile)",
				level       = 78,
				xp          = 660,
				icon        = "Trellis (6-tile)",
				material    = {6, "Teak plank", 6, "Steel bar"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Light cobblestone path (straight)",
				level       = 35,
				xp          = 40,
				icon        = "Light cobblestone path (straight)",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light cobblestone path (thin)",
				level       = 35,
				xp          = 40,
				icon        = "Light cobblestone path (thin)",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light cobblestone path (edge)",
				level       = 35,
				xp          = 40,
				icon        = "Light cobblestone path (edge)",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light cobblestone path (diagonal 1)",
				level       = 35,
				xp          = 40,
				icon        = "Light cobblestone path (diagonal 1)",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light cobblestone path (diagonal 2)",
				level       = 35,
				xp          = 40,
				icon        = "Light cobblestone path (diagonal 2)",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light cobblestone path (end)",
				level       = 35,
				xp          = 40,
				icon        = "Light cobblestone path (end)",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light cobblestone path (curved)",
				level       = 35,
				xp          = 100,
				icon        = "Light cobblestone path (curved)",
				material    = {5, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Dark cobblestone path (straight)",
				level       = 68,
				xp          = 41,
				icon        = "Dark cobblestone path (straight)",
				material    = {2, "Limestone brick", 1, "Black mushroom ink"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Dark cobblestone path (thin)",
				level       = 68,
				xp          = 41,
				icon        = "Dark cobblestone path (thin)",
				material    = {2, "Limestone brick", 1, "Black mushroom ink"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Dark cobblestone path (edge)",
				level       = 68,
				xp          = 41,
				icon        = "Dark cobblestone path (edge)",
				material    = {2, "Limestone brick", 1, "Black mushroom ink"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Dark cobblestone path (diagonal 1)",
				level       = 68,
				xp          = 41,
				icon        = "Dark cobblestone path (diagonal 1)",
				material    = {2, "Limestone brick", 1, "Black mushroom ink"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Dark cobblestone path (diagonal 2)",
				level       = 68,
				xp          = 41,
				icon        = "Dark cobblestone path (diagonal 2)",
				material    = {2, "Limestone brick", 1, "Black mushroom ink"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Dark cobblestone path (end)",
				level       = 68,
				xp          = 41,
				icon        = "Dark cobblestone path (end)",
				material    = {2, "Limestone brick", 1, "Black mushroom ink"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Dark cobblestone path (curved)",
				level       = 68,
				xp          = 101,
				icon        = "Dark cobblestone path (curved)",
				material    = {5, "Limestone brick", 1, "Black mushroom ink"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Grass (sparse)",
				level       = 1,
				xp          = 5,
				icon        = "Grass (sparse)",
				material    = {1, "Bagged grass seed"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Grass (full)",
				level       = 1,
				xp          = 5,
				icon        = "Grass (full)",
				material    = {1, "Bagged grass seed"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Grass (edge)",
				level       = 1,
				xp          = 5,
				icon        = "Grass (edge)",
				material    = {1, "Bagged grass seed"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Grass (corner)",
				level       = 1,
				xp          = 5,
				icon        = "Grass (corner)",
				material    = {1, "Bagged grass seed"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Terracotta sunflower pot",
				level       = 70,
				xp          = 90,
				icon        = "Terracotta sunflower pot",
				material    = {2, "Soft clay", 1, "Bagged sunflower"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Terracotta chrysanthemum pot",
				level       = 72,
				xp          = 120,
				icon        = "Terracotta chrysanthemum pot",
				material    = {2, "Soft clay", 1, "Bagged chrysanthemum"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Terracotta daffodil pot",
				level       = 75,
				xp          = 120,
				icon        = "Terracotta daffodil pot",
				material    = {2, "Soft clay", 1, "Bagged daffodils"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Terracotta rose pot",
				level       = 80,
				xp          = 142,
				icon        = "Terracotta rose pot",
				material    = {2, "Soft clay", 1, "Bagged roses"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Terracotta hollyhock pot",
				level       = 82,
				xp          = 24,
				icon        = "Terracotta hollyhock pot",
				material    = {2, "Soft clay", 1, "Bagged hollyhock"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Terracotta iris pot",
				level       = 83,
				xp          = 24,
				icon        = "Terracotta iris pot",
				material    = {2, "Soft clay", 1, "Bagged desert irises"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Terracotta hydrangea pot",
				level       = 84,
				xp          = 24,
				icon        = "Terracotta hydrangea pot",
				material    = {2, "Soft clay", 1, "Bagged desert hydrangeas"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Terracotta oakleaf pot",
				level       = 85,
				xp          = 24,
				icon        = "Terracotta oakleaf pot",
				material    = {2, "Soft clay", 1, "Bagged desert oakleaf flowers"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal magic wardrobe",
				level       = 105,
				xp          = 1560,
				icon        = "Eternal magic wardrobe",
				material    = {3, "Eternal plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Cobweb (1)",
				level       = 1,
				xp          = 6,
				icon        = "Cobweb (1)",
				material    = {10, "Thread"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Cobweb (2)",
				level       = 1,
				xp          = 6,
				icon        = "Cobweb (2)",
				material    = {10, "Thread"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Cobweb (3)",
				level       = 1,
				xp          = 6,
				icon        = "Cobweb (3)",
				material    = {10, "Thread"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Cobweb (4)",
				level       = 1,
				xp          = 6,
				icon        = "Cobweb (4)",
				material    = {10, "Thread"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Ceramic sunflower pot",
				level       = 66,
				xp          = 90,
				icon        = "Ceramic sunflower pot",
				material    = {2, "Soft clay", 1, "Bagged sunflower"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Ceramic chrysanthemum pot",
				level       = 68,
				xp          = 120,
				icon        = "Ceramic chrysanthemum pot",
				material    = {2, "Soft clay", 1, "Bagged chrysanthemum"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Ceramic daffodil pot",
				level       = 71,
				xp          = 120,
				icon        = "Ceramic daffodil pot",
				material    = {2, "Soft clay", 1, "Bagged daffodils"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Ceramic rose pot",
				level       = 76,
				xp          = 142,
				icon        = "Ceramic rose pot",
				material    = {2, "Soft clay", 1, "Bagged roses"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Ceramic hollyhock pot",
				level       = 78,
				xp          = 24,
				icon        = "Ceramic hollyhock pot",
				material    = {2, "Soft clay", 1, "Bagged hollyhock"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Ceramic iris pot",
				level       = 79,
				xp          = 24,
				icon        = "Ceramic iris pot",
				material    = {2, "Soft clay", 1, "Bagged desert irises"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Ceramic hydrangea pot",
				level       = 80,
				xp          = 24,
				icon        = "Ceramic hydrangea pot",
				material    = {2, "Soft clay", 1, "Bagged desert hydrangeas"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Ceramic oakleaf pot",
				level       = 81,
				xp          = 24,
				icon        = "Ceramic oakleaf pot",
				material    = {2, "Soft clay", 1, "Bagged desert oakleaf flowers"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded dresser",
				level       = 107,
				xp          = 1342,
				icon        = "Eternal gilded dresser",
				material    = {2, "Eternal plank", 2, "Molten glass", 1, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Mahogany mirror",
				level       = 62,
				xp          = 141,
				icon        = "Mahogany mirror",
				material    = {1, "Mahogany plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Oak mirror",
				level       = 35,
				xp          = 61,
				icon        = "Oak mirror",
				material    = {1, "Oak plank", 1, "Molten glass"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded long table",
				level       = 116,
				xp          = 5060,
				icon        = "Eternal gilded long table",
				material    = {8, "Eternal plank", 3, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded round table",
				level       = 112,
				xp          = 3720,
				icon        = "Eternal gilded round table",
				material    = {6, "Eternal plank", 2, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded small table",
				level       = 104,
				xp          = 1340,
				icon        = "Eternal gilded small table",
				material    = {2, "Eternal plank", 1, "Gold leaf"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Eternal gilded throne",
				level       = 118,
				xp          = 4500,
				icon        = "Eternal gilded throne",
				material    = {5, "Eternal plank", 2, "Marble block", 3, "Gold leaf"},
				members     = true,
				mcount      = 3
			},
			{
				name        = "Stool",
				level       = 1,
				xp          = 29,
				icon        = "Stool",
				material    = {1, "Plank"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light stone wall (corner flat)",
				level       = 63,
				xp          = 100,
				icon        = "Light stone wall (corner flat)",
				material    = {5, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light stone wall (2-tile)",
				level       = 63,
				xp          = 200,
				icon        = "Light stone wall (2-tile)",
				material    = {10, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light stone wall (corner ball)",
				level       = 63,
				xp          = 100,
				icon        = "Light stone wall (corner ball)",
				material    = {5, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Light stone wall (1-tile)",
				level       = 63,
				xp          = 100,
				icon        = "Light stone wall (1-tile)",
				material    = {5, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Dark stone wall (corner ball)",
				level       = 63,
				xp          = 100,
				icon        = "Dark stone wall (corner ball)",
				material    = {5, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Dark stone wall (corner flat)",
				level       = 63,
				xp          = 100,
				icon        = "Dark stone wall (corner flat)",
				material    = {5, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Dark stone wall (1-tile)",
				level       = 63,
				xp          = 100,
				icon        = "Dark stone wall (1-tile)",
				material    = {5, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Dark stone wall (2-tile)",
				level       = 63,
				xp          = 100,
				icon        = "Dark stone wall (2-tile)",
				material    = {5, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Dark stone wall (4-tile)",
				level       = 63,
				xp          = 200,
				icon        = "Dark stone wall (4-tile)",
				material    = {10, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Dark stone wall (6-tile)",
				level       = 63,
				xp          = 300,
				icon        = "Dark stone wall (6-tile)",
				material    = {15, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Dark stone wall (8-tile)",
				level       = 63,
				xp          = 400,
				icon        = "Dark stone wall (8-tile)",
				material    = {20, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Granite farm wall (1)",
				level       = 5,
				xp          = 1,
				icon        = "Granite farm wall (1)",
				material    = {2, "Granite (5kg)"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Granite farm wall (2)",
				level       = 5,
				xp          = 1,
				icon        = "Granite farm wall (2)",
				material    = {2, "Granite (5kg)"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Granite farm wall (crumbling 1)",
				level       = 5,
				xp          = 1,
				icon        = "Granite farm wall (crumbling 1)",
				material    = {2, "Granite (5kg)"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Granite farm wall (crumbling 2)",
				level       = 5,
				xp          = 1,
				icon        = "Granite farm wall (crumbling 2)",
				material    = {2, "Granite (5kg)"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Candelabra (bronze)",
				level       = 45,
				xp          = 20,
				icon        = "Candelabra (bronze)",
				material    = {3, "Bronze bar", 3, "White candle"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Candelabra (iron)",
				level       = 49,
				xp          = 39,
				icon        = "Candelabra (iron)",
				material    = {3, "Iron bar", 3, "White candle"},
				members     = true,
				mcount      = 2
			},
			{
				name        = "Cobweb (ceiling 1)",
				level       = 1,
				xp          = 6,
				icon        = "Cobweb (ceiling 1)",
				material    = {10, "Thread"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Cobweb (ceiling 2)",
				level       = 1,
				xp          = 6,
				icon        = "Cobweb (ceiling 2)",
				material    = {10, "Thread"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Cobweb (ceiling 3)",
				level       = 1,
				xp          = 6,
				icon        = "Cobweb (ceiling 3)",
				material    = {10, "Thread"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Cobweb (ceiling 4)",
				level       = 1,
				xp          = 6,
				icon        = "Cobweb (ceiling 4)",
				material    = {10, "Thread"},
				members     = false,
				mcount      = 1
			},
			{
				name        = "Wood trim",
				level       = 33,
				xp          = 29,
				icon        = "Wood trim",
				material    = {1, "Plank", 1, "Nails"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Wood trim (corner)",
				level       = 33,
				xp          = 58,
				icon        = "Wood trim (corner)",
				material    = {2, "Plank", 2, "Nails"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Wood trim (post)",
				level       = 33,
				xp          = 29,
				icon        = "Wood trim (post)",
				material    = {1, "Plank", 1, "Nails"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Stone trim",
				level       = 33,
				xp          = 20,
				icon        = "Stone trim",
				material    = {1, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone trim (corner)",
				level       = 33,
				xp          = 40,
				icon        = "Stone trim (corner)",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone trim (post)",
				level       = 33,
				xp          = 20,
				icon        = "Stone trim (post)",
				material    = {1, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Flowerbed trim (wood) (2-tile)",
				level       = 33,
				xp          = 58,
				icon        = "Flowerbed trim (wood) (2-tile)",
				material    = {2, "Plank", 2, "Nails"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flowerbed trim (wood) (4-tile)",
				level       = 33,
				xp          = 115,
				icon        = "Flowerbed trim (wood) (4-tile)",
				material    = {4, "Plank", 4, "Nails"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flowerbed trim (wood) (6-tile)",
				level       = 33,
				xp          = 172,
				icon        = "Flowerbed trim (wood) (6-tile)",
				material    = {6, "Plank", 6, "Nails"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flowerbed trim (wood) (8-tile)",
				level       = 33,
				xp          = 228,
				icon        = "Flowerbed trim (wood) (8-tile)",
				material    = {8, "Plank", 8, "Nails"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Flowerbed trim (stone) (2-tile)",
				level       = 33,
				xp          = 40,
				icon        = "Flowerbed trim (stone) (2-tile)",
				material    = {2, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Flowerbed trim (stone) (4-tile)",
				level       = 33,
				xp          = 80,
				icon        = "Flowerbed trim (stone) (4-tile)",
				material    = {4, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Flowerbed trim (stone) (6-tile)",
				level       = 33,
				xp          = 120,
				icon        = "Flowerbed trim (stone) (6-tile)",
				material    = {6, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Flowerbed trim (stone) (8-tile)",
				level       = 33,
				xp          = 160,
				icon        = "Flowerbed trim (stone) (8-tile)",
				material    = {8, "Limestone brick"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (2-tile)",
				level       = 5,
				xp          = 4,
				icon        = "Stone farm wall (2-tile)",
				material    = {2, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (4-tile)",
				level       = 5,
				xp          = 6,
				icon        = "Stone farm wall (4-tile)",
				material    = {4, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (6-tile)",
				level       = 5,
				xp          = 7,
				icon        = "Stone farm wall (6-tile)",
				material    = {6, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (8-tile)",
				level       = 5,
				xp          = 8,
				icon        = "Stone farm wall (8-tile)",
				material    = {8, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (crumbling 1)",
				level       = 5,
				xp          = 4,
				icon        = "Stone farm wall (crumbling 1)",
				material    = {2, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (crumbling 2)",
				level       = 5,
				xp          = 4,
				icon        = "Stone farm wall (crumbling 2)",
				material    = {2, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (capped, 2-tile)",
				level       = 5,
				xp          = 5,
				icon        = "Stone farm wall (capped, 2-tile)",
				material    = {3, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (capped, 4-tile)",
				level       = 5,
				xp          = 7,
				icon        = "Stone farm wall (capped, 4-tile)",
				material    = {6, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (capped, 6-tile)",
				level       = 5,
				xp          = 8,
				icon        = "Stone farm wall (capped, 6-tile)",
				material    = {8, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (capped, 8-tile)",
				level       = 5,
				xp          = 10,
				icon        = "Stone farm wall (capped, 8-tile)",
				material    = {10, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (capped, 2-tile 2)",
				level       = 5,
				xp          = 5,
				icon        = "Stone farm wall (capped, 2-tile 2)",
				material    = {3, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Stone farm wall (2-tile 2)",
				level       = 5,
				xp          = 5,
				icon        = "Stone farm wall (2-tile 2)",
				material    = {3, "Limestone"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Lamp post",
				level       = 52,
				xp          = 115,
				icon        = "Lamp post",
				material    = {4, "Plank", 1, "Candle lantern (lit white)"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Large gold pile",
				level       = 80,
				xp          = 9775,
				icon        = "Large gold pile",
				material    = {1, "Small stone pedestal", 50000000, "Coins", 3, "Marble block", 4, "Gold leaf"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 4
			},
			{
				name        = "Medium gold pile",
				level       = 70,
				xp          = 4940,
				icon        = "Medium gold pile",
				material    = {1, "Small stone pedestal", 5000000, "Coins", 3, "Marble block", 4, "Gold leaf"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 4
			},
			{
				name        = "Small gold pile",
				level       = 60,
				xp          = 3704,
				icon        = "Small gold pile",
				material    = {1, "Small stone pedestal", 1000000, "Coins", 3, "Marble block", 4, "Gold leaf"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 4
			},
			{
				name        = "Tiny gold pile",
				level       = 50,
				xp          = 104,
				icon        = "Tiny gold pile",
				material    = {1, "Small stone pedestal", 10000, "Coins"},
				mtrade      = 0,
				trade       = 0,
				members     = true,
				mcount      = 2
			},
			{
				name        = "Large grass patch",
				level       = 1,
				xp          = 14,
				icon        = "Large grass patch",
				material    = {1, "Watering can", 9, "Bagged grass seed"},
				mtrade      = 0,
				trade       = 0,
				members     = false,
				mcount      = 2
			},
			{
				name        = "Orange candles (3 candles)",
				level       = 4,
				xp          = 5,
				icon        = "Orange candles (3 candles)",
				material    = {1, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Orange candles (2 candles)",
				level       = 8,
				xp          = 7,
				icon        = "Orange candles (2 candles)",
				material    = {2, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Orange candles (4 candles 1)",
				level       = 12,
				xp          = 9,
				icon        = "Orange candles (4 candles 1)",
				material    = {3, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Orange candles (4 candles 2)",
				level       = 16,
				xp          = 10,
				icon        = "Orange candles (4 candles 2)",
				material    = {4, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Candles (2 candles)",
				level       = 20,
				xp          = 7,
				icon        = "Candles (2 candles)",
				material    = {2, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Blue candles (2 candles)",
				level       = 24,
				xp          = 7,
				icon        = "Blue candles (2 candles)",
				material    = {2, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Candles (4 candles 1)",
				level       = 28,
				xp          = 9,
				icon        = "Candles (4 candles 1)",
				material    = {3, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Blue candles (4 candles 1)",
				level       = 32,
				xp          = 9,
				icon        = "Blue candles (4 candles 1)",
				material    = {3, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Candles (4 candles 2)",
				level       = 36,
				xp          = 10,
				icon        = "Candles (4 candles 2)",
				material    = {4, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Blue candles (4 candles 2)",
				level       = 40,
				xp          = 10,
				icon        = "Blue candles (4 candles 2)",
				material    = {4, "White candle"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Small marble pedestal",
				level       = 80,
				xp          = 1000,
				icon        = "Small marble pedestal",
				material    = {2, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Large marble pedestal",
				level       = 83,
				xp          = 2000,
				icon        = "Large marble pedestal",
				material    = {4, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Huge marble pedestal",
				level       = 86,
				xp          = 3000,
				icon        = "Huge marble pedestal",
				material    = {6, "Marble block"},
				members     = true,
				mcount      = 1
			},
			{
				name        = "Garden bench",
				level       = 25,
				xp          = 250,
				icon        = "Garden bench",
				material    = {1, "Iron bar", 4, "Oak plank"},
				members     = true,
				mcount      = 2
			}
		}
        return methods
    end
    
    -- Forinthry
    if trainMethod == "Fort Forinthry" then
        local methods = 
        {
            {   
                name        = "Workshop (Tier 1)",
                icon		= "Workshop (Tier 1)",
                level       = 1,
                xp          = 2304,
                material    = {8, "Wooden frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, { 
                name        = "Workshop (Tier 2)",
                icon		= "Workshop (Tier 2)",
                level       = 35,
                xp          = 17280,
                material    = {20, "Teak frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Workshop (Tier 3)",
                icon		= "Workshop (Tier 3)",
                level       = 75,
                xp          = 110592,
                material    = {48, "Yew frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Town hall (Tier 1)",
                icon		= "Town hall (Tier 1)",
                level       = 10,
                xp          = 4320,
                material    = {10, "Oak frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Town hall (Tier 2)",
                icon		= "Town hall (Tier 2)",
                level       = 45,
                xp          = 25344,
                material    = {22, "Maple frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Town hall (Tier 3)",
                icon		= "Town hall (Tier 3)",
                level       = 80,
                xp          = 167040,
                material    = {60, "Magic frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Chapel (Tier 1)",
                icon		= "Chapel (Tier 1)",
                level       = 15,
                xp          = 4320,
                material    = {10, "Oak frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Chapel (Tier 2)",
                icon		= "Chapel (Tier 2)",
                level       = 55,
                xp          = 35712,
                material    = {24, "Acadia frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Chapel (Tier 3)",
                icon		= "Chapel (Tier 3)",
                level       = 90,
                xp          = 165600,
                material    = {50, "Elder frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Command centre (Tier 1)",
                icon		= "Command centre (Tier 1)",
                level       = 25,
                xp          = 7488,
                material    = {12, "Willow frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Command centre (Tier 2)",
                icon		= "Command centre (Tier 2)",
                level       = 70,
                xp          = 59904,
                material    = {26, "Yew frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Command centre (Tier 3)",
                icon		= "Command centre (Tier 3)",
                level       = 99,
                xp          = 264960,
                material    = {80, "Elder frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Kitchen (Tier 1)",
                icon		= "Kitchen (Tier 1)",
                level       = 25,
                xp          = 7488,
                material    = {12, "Willow frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Kitchen (Tier 2)",
                icon		= "Kitchen (Tier 2)",
                level       = 50,
                xp          = 32736,
                material    = {22, "Acadia frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Kitchen (Tier 3)",
                icon		= "Kitchen (Tier 3)",
                level       = 85,
                xp          = 139200,
                material    = {50, "Magic frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
            	name        = "Guardhouse (Tier 1)",
            	icon		= "Guardhouse (Tier 1)",
                level       = 40,
                xp          = 16128,
                material    = {14, "Maple frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Guardhouse (Tier 2)",
                icon		= "Guardhouse (Tier 2)",
                level       = 65,
                xp          = 48672,
                material    = {26, "Mahogany frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Guardhouse (Tier 3)",
                icon		= "Guardhouse (Tier 3)",
                level       = 95,
                xp          = 231840,
                material    = {70, "Elder frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
            	name        = "Grove cabin (Tier 1)",
            	icon		= "Grove cabin (Tier 1)",
                level       = 50,
                xp          = 2304,
                material    = {8, "Wooden frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Grove cabin (Tier 2)",
                icon		= "Grove cabin (Tier 2)",
                level       = 50,
                xp          = 17280,
                material    = {20, "Teak frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Grove cabin (Tier 3)",
                icon		= "Grove cabin (Tier 3)",
                level       = 60,
                xp          = 89856,
                material    = {48, "Mahogany frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
            	name        = "Ranger's Workroom (Tier 1)",
            	icon		= "Ranger's Workroom (Tier 1)",
                level       = 50,
                xp          = 20832,
                material    = {14, "Acadia frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Ranger's Workroom (Tier 2)",
                icon		= "Ranger's Workroom (Tier 2)",
                level       = 65,
                xp          = 44928,
                material    = {24, "Mahogany frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Ranger's Workroom (Tier 3)",
                icon		= "Ranger's Workroom (Tier 3)",
                level       = 80,
                xp          = 116928,
                material    = {42, "Magic frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
            	name        = "Botanist's Workbench (Tier 1)",
            	icon		= "Botanist's Workbench (Tier 1)",
                level       = 54,
                xp          = 5952,
                material    = {4, "Acadia frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Botanist's Workbench (Tier 2)",
                icon		= "Botanist's Workbench (Tier 2)",
                level       = 78,
                xp          = 18432,
                material    = {8, "Yew frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Botanist's Workbench (Tier 3)",
                icon		= "Botanist's Workbench (Tier 3)",
                level       = 92,
                xp          = 39744,
                material    = {12, "Elder frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }, {
                name        = "Eternal reinforcement",
                icon		= "Eternal reinforcement",
                level       = 105,
                xp          = 499200,
                material    = {65, "Eternal frame", 6, "Stone wall segment"},
                mcount      = 2,
                members		= true
            }
        }
        return methods
    end
    
    -- Forinthry Processing
	if trainMethod == "Fort Forinthry - Processing" then
    	local methods = 
	    {
			{
			    name     = "Plank",
			    icon     = "Plank",
			    level    = "1",
			    xp       = 3,
			    material = {1, "Logs"},
			    members  = true
			},
			{
			    name     = "Refined planks",
			    icon     = "Refined planks",
			    level    = "1",
			    xp       = 12,
			    material = {4, "Plank"},
			    members  = true
			},
			{
			    name     = "Wooden frame",
			    icon     = "Wooden frame",
			    level    = "1",
			    xp       = 54,
			    material = {3, "Refined planks"},
			    members  = true
			},
			{
			    name     = "Wooden frame",
			    eLink    = "(from logs)",
			    icon     = "Wooden frame",
			    level    = "1",
			    xp       = 126,
			    material = {12, "Logs"},
			    members  = true
			},
			{
			    name     = "Wooden frame",
			    eLink    = "(from planks)",
			    icon     = "Wooden frame",
			    level    = "1",
			    xp       = 90,
			    material = {12, "Plank"},
			    members  = true
			},
			{
			    name     = "Oak plank",
			    icon     = "Oak plank",
			    level    = "10",
			    xp       = 4.5,
			    material = {1, "Oak logs"},
			    members  = true
			},
			{
			    name     = "Refined Oak planks",
			    icon     = "Refined Oak planks",
			    level    = "10",
			    xp       = 18,
			    material = {4, "Oak plank"},
			    members  = true
			},
			{
			    name     = "Oak frame",
			    icon     = "Oak frame",
			    level    = "10",
			    xp       = 81,
			    material = {3, "Refined Oak planks"},
			    members  = true
			},
			{
			    name     = "Oak frame",
			    eLink    = "(from logs)",
			    icon     = "Oak frame",
			    level    = "10",
			    xp       = 189.0,
			    material = {12, "Oak logs"},
			    members  = true
			},
			{
			    name     = "Oak frame",
			    eLink    = "(from planks)",
			    icon     = "Oak frame",
			    level    = "10",
			    xp       = 135,
			    material = {12, "Oak plank"},
			    members  = true
			},
			{
			    name     = "Willow plank",
			    icon     = "Willow plank",
			    level    = "20",
			    xp       = 6.5,
			    material = {1, "Willow logs"},
			    members  = true
			},
			{
			    name     = "Refined Willow planks",
			    icon     = "Refined Willow planks",
			    level    = "20",
			    xp       = 26,
			    material = {4, "Willow plank"},
			    members  = true
			},
			{
			    name     = "Willow frame",
			    icon     = "Willow frame",
			    level    = "20",
			    xp       = 117,
			    material = {3, "Refined Willow planks"},
			    members  = true
			},
			{
			    name     = "Willow frame",
			    eLink    = "(from logs)",
			    icon     = "Willow frame",
			    level    = "20",
			    xp       = 273.0,
			    material = {12, "Willow logs"},
			    members  = true
			},
			{
			    name     = "Willow frame",
			    eLink    = "(from planks)",
			    icon     = "Willow frame",
			    level    = "20",
			    xp       = 195,
			    material = {12, "Willow plank"},
			    members  = true
			},
			{
			    name     = "Teak plank",
			    icon     = "Teak plank",
			    level    = "30",
			    xp       = 9,
			    material = {1, "Teak logs"},
			    members  = true
			},
			{
			    name     = "Refined Teak planks",
			    icon     = "Refined Teak planks",
			    level    = "30",
			    xp       = 36,
			    material = {4, "Teak plank"},
			    members  = true
			},
			{
			    name     = "Teak frame",
			    icon     = "Teak frame",
			    level    = "30",
			    xp       = 162,
			    material = {3, "Refined Teak planks"},
			    members  = true
			},
			{
			    name     = "Teak frame",
			    eLink    = "(from logs)",
			    icon     = "Teak frame",
			    level    = "30",
			    xp       = 378,
			    material = {12, "Teak logs"},
			    members  = true
			},
			{
			    name     = "Teak frame",
			    eLink    = "(from planks)",
			    icon     = "Teak frame",
			    level    = "30",
			    xp       = 270,
			    material = {12, "Teak plank"},
			    members  = true
			},
			{
			    name     = "Maple plank",
			    icon     = "Maple plank",
			    level    = "40",
			    xp       = 12,
			    material = {1, "Maple logs"},
			    members  = true
			},
			{
			    name     = "Refined Maple planks",
			    icon     = "Refined Maple planks",
			    level    = "40",
			    xp       = 48,
			    material = {3, "Maple plank"},
			    members  = true
			},
			{
			    name     = "Maple frame",
			    icon     = "Maple frame",
			    level    = "40",
			    xp       = 216,
			    material = {4, "Refined Maple planks"},
			    members  = true
			},
			{
			    name     = "Maple frame",
			    eLink    = "(from logs)",
			    icon     = "Maple frame",
			    level    = "40",
			    xp       = 504,
			    material = {12, "Maple logs"},
			    members  = true
			},
			{
			    name     = "Maple frame",
			    eLink    = "(from planks)",
			    icon     = "Maple frame",
			    level    = "40",
			    xp       = 360,
			    material = {12, "Maple plank"},
			    members  = true
			},
			{
			    name     = "Acadia plank",
			    icon     = "Acadia plank",
			    level    = "50",
			    xp       = 15.5,
			    material = {1, "Acadia logs"},
			    members  = true
			},
			{
			    name     = "Refined Acadia planks",
			    icon     = "Refined Acadia planks",
			    level    = "50",
			    xp       = 62,
			    material = {4, "Acadia plank"},
			    members  = true
			},
			{
			    name     = "Acadia frame",
			    icon     = "Acadia frame",
			    level    = "50",
			    xp       = 279,
			    material = {3, "Refined Acadia planks"},
			    members  = true
			},
			{
			    name     = "Acadia frame",
			    eLink    = "(from logs)",
			    icon     = "Acadia frame",
			    level    = "50",
			    xp       = 651.0,
			    material = {12, "Acadia logs"},
			    members  = true
			},
			{
			    name     = "Acadia frame",
			    eLink    = "(from planks)",
			    icon     = "Acadia frame",
			    level    = "50",
			    xp       = 465,
			    material = {12, "Acadia plank"},
			    members  = true
			},
			{
			    name     = "Mahogany plank",
			    icon     = "Mahogany plank",
			    level    = "60",
			    xp       = 19.5,
			    material = {1, "Mahogany logs"},
			    members  = true
			},
			{
			    name     = "Refined Mahogany planks",
			    icon     = "Refined Mahogany planks",
			    level    = "60",
			    xp       = 78,
			    material = {4, "Mahogany plank"},
			    members  = true
			},
			{
			    name     = "Mahogany frame",
			    icon     = "Mahogany frame",
			    level    = "60",
			    xp       = 351,
			    material = {3, "Refined Mahogany planks"},
			    members  = true
			},
			{
			    name     = "Mahogany frame",
			    eLink    = "(from logs)",
			    icon     = "Mahogany frame",
			    level    = "60",
			    xp       = 819.0,
			    material = {12, "Mahogany logs"},
			    members  = true
			},
			{
			    name     = "Mahogany frame",
			    eLink    = "(from planks)",
			    icon     = "Mahogany frame",
			    level    = "60",
			    xp       = 585,
			    material = {12, "Mahogany plank"},
			    members  = true
			},
			{
			    name     = "Yew plank",
			    icon     = "Yew plank",
			    level    = "70",
			    xp       = 24,
			    material = {1, "Yew logs"},
			    members  = true
			},
			{
			    name     = "Refined Yew planks",
			    icon     = "Refined Yew planks",
			    level    = "70",
			    xp       = 96,
			    material = {4, "Yew plank"},
			    members  = true
			},
			{
			    name     = "Yew frame",
			    icon     = "Yew frame",
			    level    = "70",
			    xp       = 432,
			    material = {3, "Refined Yew planks"},
			    members  = true
			},
			{
			    name     = "Yew frame",
			    eLink    = "(from logs)",
			    icon     = "Yew frame",
			    level    = "70",
			    xp       = 1008,
			    material = {12, "Yew logs"},
			    members  = true
			},
			{
			    name     = "Yew frame",
			    eLink    = "(from planks)",
			    icon     = "Yew frame",
			    level    = "70",
			    xp       = 720,
			    material = {12, "Yew plank"},
			    members  = true
			},
			{
			    name     = "Magic plank",
			    icon     = "Magic plank",
			    level    = "80",
			    xp       = 29,
			    material = {1, "Magic logs"},
			    members  = true
			},
			{
			    name     = "Refined Magic planks",
			    icon     = "Refined Magic planks",
			    level    = "80",
			    xp       = 116,
			    material = {4, "Magic plank"},
			    members  = true
			},
			{
			    name     = "Magic frame",
			    icon     = "Magic frame",
			    level    = "80",
			    xp       = 522,
			    material = {3, "Refined Magic planks"},
			    members  = true
			},
			{
			    name     = "Magic frame",
			    eLink    = "(from logs)",
			    icon     = "Magic frame",
			    level    = "80",
			    xp       = 1218,
			    material = {12, "Magic logs"},
			    members  = true
			},
			{
			    name     = "Magic frame",
			    eLink    = "(from planks)",
			    icon     = "Magic frame",
			    level    = "80",
			    xp       = 870,
			    material = {12, "Magic plank"},
			    members  = true
			},
			{
			    name     = "Elder plank",
			    icon     = "Elder plank",
			    level    = "90",
			    xp       = 34.5,
			    material = {1, "Elder logs"},
			    members  = true
			},
			{
			    name     = "Refined Elder planks",
			    icon     = "Refined Elder planks",
			    level    = "90",
			    xp       = 138,
			    material = {4, "Elder plank"},
			    members  = true
			},
			{
			    name     = "Elder frame",
			    icon     = "Elder frame",
			    level    = "90",
			    xp       = 621,
			    material = {3, "Refined Elder planks"},
			    members  = true
			},
			{
			    name     = "Elder frame",
			    eLink    = "(from logs)",
			    icon     = "Elder frame",
			    level    = "90",
			    xp       = 1449.0,
			    material = {12, "Elder logs"},
			    members  = true
			},
			{
			    name     = "Elder frame",
			    eLink    = "(from planks)",
			    icon     = "Elder frame",
			    level    = "90",
			    xp       = 1035,
			    material = {12, "Elder plank"},
			    members  = true
			},
			{
				name     = "Eternal plank",
				icon     = "Eternal plank",
				level	 = "95",
				xp       = 40,
				material = {1, "Eternal magic logs"},
				members  = true
			},
			{
			    name     = "Refined Eternal planks",
			    icon     = "Refined Eternal planks",
			    level    = "95",
			    xp       = 160,
			    material = {4, "Eternal plank"},
			    members  = true
			},
			{
			    name     = "Eternal frame",
			    icon     = "Eternal frame",
			    level    = "95",
			    xp       = 720,
			    material = {3, "Refined Eternal planks"},
			    members  = true
			},
			{
			    name     = "Eternal frame",
			    eLink    = "(from logs)",
			    icon     = "Eternal frame",
			    level    = "95",
			    xp       = 1680.0,
			    material = {12, "Eternal magic logs"},
			    members  = true
			},
			{
			    name     = "Eternal frame",
			    eLink    = "(from planks)",
			    icon     = "Eternal frame",
			    level    = "95",
			    xp       = 1200.0,
			    material = {12, "Eternal plank"},
			    members  = true
			}
		}
	    return methods
	end
	
	-- Construction Contracts
	if trainMethod == "Construction Contracts" then
		local methods = 
		{
			{
				name     = "Plank",
				icon     = "Plank",
				level    = "40",
				xp       = 564.3,
				material = {1, "Plank"},
				members  = true
			},
			{
				name     = "Oak plank",
				icon     = "Oak plank",
				level    = "50",
				xp       = 632.1,
				material = {1, "Oak plank"},
				members  = true
			},
			{
				name     = "Teak plank",
				icon     = "Teak plank",
				level    = "60",
				xp       = 714.3,
				material = {1, "Teak plank"},
				members  = true
			},
			{
				name     = "Mahogany plank",
				icon     = "Mahogany plank",
				level    = "70",
				xp       = 857.1,
				material = {1, "Mahogany plank"},
				members  = true
			},
			{
				name     = "Eternal plank",
				icon     = "Eternal plank",
				level    = "100",
				xp       = 1928.6,
				material = {1, "Eternal plank"},
				members  = true
			}
		}
	    return methods
	end
end