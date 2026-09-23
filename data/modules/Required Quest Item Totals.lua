-- Module:Required Quest Item Totals
-- Backend for the remaining-items calculator on [[Required Quest Item Totals]].
-- Generated from each quest's items-required section; regenerate with the page.
local p = {}

local quests = {
  {id="q1", name="Animal Magnetism", page="Animal Magnetism", f2p=false, items={{"Ecto-token", "Ecto-token", 20, false}, {"Ghostspeak amulet", "Ghostspeak amulet", 1, false}, {"Hammer", "Hammer", 1, false}, {"Hard leather", "Hard leather", 1, false}, {"Holy symbol", "Holy symbol", 1, false}, {"Iron bar", "Iron bar", 5, false}, {"Mithril axe", "Mithril axe", 1, false}, {"Polished buttons", "Polished buttons", 1, false}}},
  {id="q2", name="Another Slice of H.A.M.", page="Another Slice of H.A.M.", f2p=false, items={{"Light sources", "Light sources", 1, false}, {"Specimen brush", "Specimen brush", 1, true}, {"Trowel", "Trowel", 1, true}}},
  {id="q3", name="At First Light", page="At First Light", f2p=false, items={{"Hammer", "Hammer", 1, true}, {"Jerboa tail", "Jerboa tail", 2, true}, {"Needle", "Needle", 1, false}}},
  {id="q4", name="Below Ice Mountain", page="Below Ice Mountain", f2p=true, items={{"Beer", "Beer", 1, true}, {"Bread", "Bread", 1, false}, {"Cooked meat", "Cooked meat", 1, true}, {"Knife", "Knife", 1, false}}},
  {id="q5", name="Beneath Cursed Sands", page="Beneath Cursed Sands", f2p=false, items={{"Coal", "Coal", 1, false}, {"Cooked meat", "Cooked meat", 1, true}, {"Iron bar", "Iron bar", 1, false}, {"Spade", "Spade", 1, true}, {"Tinderbox", "Tinderbox", 1, true}}},
  {id="q6", name="Between a Rock...", page="Between a Rock...", f2p=false, items={{"Ammo mould", "Ammo mould", 1, true}, {"Coins", "Coins", 830, false}, {"Gold bar", "Gold bar", 4, false}, {"Hammer", "Hammer", 1, false}, {"Pickaxe", "Pickaxe", 1, false}}},
  {id="q7", name="Big Chompy Bird Hunting", page="Big Chompy Bird Hunting", f2p=false, items={{"Axe", "Axe", 1, false}, {"Cabbage", "Cabbage", 1, true}, {"Chisel", "Chisel", 1, false}, {"Doogle leaves", "Doogle leaves", 1, true}, {"Equa leaves", "Equa leaves", 1, true}, {"Feather", "Feather", 1, false}, {"Knife", "Knife", 1, false}, {"Onion", "Onion", 1, true}, {"Potato", "Potato", 1, true}, {"Tomato", "Tomato", 1, true}, {"Wolf bones", "Wolf bones", 4, true}}},
  {id="q8", name="Biohazard", page="Biohazard", f2p=false, items={{"Gas mask", "Gas mask", 1, false}, {"Priest gown (top)", "Priest gown (top)", 1, true}}},
  {id="q9", name="Black Knights' Fortress", page="Black Knights' Fortress", f2p=true, items={{"Bronze med helm", "Bronze med helm", 1, false}, {"Cabbage", "Cabbage", 1, false}, {"Iron chainbody", "Iron chainbody", 1, false}}},
  {id="q10", name="The Blood Moon Rises", page="The Blood Moon Rises", f2p=false, items={{"Blisterwood flail", "Blisterwood flail", 1, false}, {"Blisterwood logs", "Blisterwood logs", 1, true}, {"Chisel", "Chisel", 1, true}, {"Hammer", "Hammer", 1, true}, {"Knife", "Knife", 1, true}, {"Pickaxe", "Pickaxe", 1, true}, {"Tinderbox", "Tinderbox", 1, true}, {"Vyre noble clothing", "Vyre noble clothing", 1, true}}},
  {id="q11", name="Bone Voyage", page="Bone Voyage", f2p=false, items={{"Marrentill potion (unf)", "Marrentill potion (unf)", 1, false}, {"Vodka", "Vodka", 2, false}}},
  {id="q12", name="Client of Kourend", page="Client of Kourend", f2p=false, items={{"Feather", "Feather", 1, false}}},
  {id="q13", name="Clock Tower", page="Clock Tower", f2p=false, items={{"Bucket of water", "Bucket of water", 1, true}}},
  {id="q14", name="Cold War", page="Cold War", f2p=false, items={{"Clockwork", "Clockwork", 1, false}, {"Cowbells", "Cowbells", 1, true}, {"Feather", "Feather", 5, false}, {"Hammer", "Hammer", 1, false}, {"Leather", "Leather", 1, false}, {"Mahogany plank", "Mahogany plank", 1, false}, {"Oak plank", "Oak plank", 10, false}, {"Plank", "Plank", 1, false}, {"Raw cod", "Raw cod", 1, false}, {"Silk", "Silk", 1, false}, {"Spade", "Spade", 1, false}, {"Steel nails", "Steel nails", 10, false}, {"Swamp tar", "Swamp tar", 1, false}}},
  {id="q15", name="Contact!", page="Contact!", f2p=false, items={{"Light sources", "Light sources", 1, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q16", name="Cook's Assistant", page="Cook's Assistant", f2p=true, items={{"Bucket of milk", "Bucket of milk", 1, false}, {"Egg", "Egg", 1, true}, {"Pot of flour", "Pot of flour", 1, false}}},
  {id="q17", name="The Corsair Curse", page="The Corsair Curse", f2p=true, items={{"Spade", "Spade", 1, true}, {"Tinderbox", "Tinderbox", 1, true}}},
  {id="q18", name="Creature of Fenkenstrain", page="Creature of Fenkenstrain", f2p=false, items={{"Bronze wire", "Bronze wire", 3, false}, {"Coins", "Coins", 50, false}, {"Ghostspeak amulet", "Ghostspeak amulet", 1, false}, {"Needle", "Needle", 1, false}, {"Silver bar", "Silver bar", 1, false}, {"Spade", "Spade", 1, false}, {"Thread", "Thread", 5, false}}},
  {id="q19", name="Current Affairs", page="Current Affairs", f2p=false, items={{"Charcoal", "Charcoal", 1, true}, {"Coins", "Coins", 50, false}}},
  {id="q20", name="The Curse of Arrav", page="The Curse of Arrav", f2p=false, items={{"Crossbow (weapon)", "Crossbow", 1, false}, {"Dwellberries", "Dwellberries", 3, false}, {"Insulated boots", "Insulated boots", 1, false}, {"Mith grapple", "Mith grapple", 1, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Ring of life", "Ring of life", 1, false}}},
  {id="q21", name="Darkness of Hallowvale", page="Darkness of Hallowvale", f2p=false, items={{"Hammer", "Hammer", 1, false}, {"Knife", "Knife", 1, true}, {"Nails", "Nails", 8, false}, {"Plank", "Plank", 2, false}}},
  {id="q22", name="Death Plateau", page="Death Plateau", f2p=false, items={{"Asgarnian ale", "Asgarnian ale", 1, false}, {"Bread", "Bread", 10, false}, {"Coins", "Coins", 60, false}, {"Iron bar", "Iron bar", 1, false}, {"Trout", "Trout", 10, false}}},
  {id="q23", name="Death to the Dorgeshuun", page="Death to the Dorgeshuun", f2p=false, items={{"H.A.M. robes", "H.A.M. robes", 2, true}, {"Light sources", "Light sources", 1, false}, {"Pickaxe", "Pickaxe", 1, false}}},
  {id="q24", name="Defender of Varrock", page="Defender of Varrock", f2p=false, items={{"Barronite deposit", "Barronite deposit", 1, false}, {"Chaos core", "Chaos core", 1, true}}},
  {id="q25", name="Demon Slayer", page="Demon Slayer", f2p=true, items={{"Bones", "Bones", 25, false}, {"Bucket of water", "Bucket of water", 1, true}, {"Coins", "Coins", 1, false}}},
  {id="q26", name="Desert Treasure I", page="Desert Treasure I", f2p=false, items={{"Ashes", "Ashes", 1, false}, {"Blood rune", "Blood rune", 1, false}, {"Bones", "Bones", 1, false}, {"Cake", "Cake", 1, false}, {"Charcoal", "Charcoal", 1, false}, {"Climbing boots", "Climbing boots", 1, false}, {"Coins", "Coins", 650, false}, {"Facemask", "Facemask", 1, false}, {"Garlic powder", "Garlic powder", 1, false}, {"Lockpick", "Lockpick", 20, false}, {"Magic logs", "Magic logs", 12, false}, {"Molten glass", "Molten glass", 6, false}, {"Shantay pass (item)", "Shantay pass", 10, false}, {"Silver bar", "Silver bar", 1, false}, {"Spice", "Spice", 1, false}, {"Spiked boots", "Spiked boots", 1, true}, {"Steel bar", "Steel bar", 6, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q27", name="Desert Treasure II - The Fallen Empire", page="Desert Treasure II - The Fallen Empire", f2p=false, items={{"Facemask", "Facemask", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, true}, {"Pickaxe", "Pickaxe", 1, true}, {"Ring of visibility", "Ring of visibility", 1, false}, {"Tinderbox", "Tinderbox", 1, true}}},
  {id="q28", name="Devious Minds", page="Devious Minds", f2p=false, items={{"Bow string", "Bow string", 1, false}, {"Large pouch", "Large pouch", 1, false}, {"Mithril 2h sword", "Mithril 2h sword", 1, false}}},
  {id="q29", name="The Dig Site", page="The Dig Site", f2p=false, items={{"Charcoal", "Charcoal", 1, true}, {"Cup of tea", "Cup of tea", 1, false}, {"Opal", "Opal", 1, false}, {"Panning tray", "Panning tray", 1, true}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Rope", "Rope", 2, false}, {"Specimen brush", "Specimen brush", 1, true}, {"Specimen jar", "Specimen jar", 1, true}, {"Tinderbox", "Tinderbox", 1, false}, {"Trowel", "Trowel", 1, true}, {"Vial", "Vial", 1, false}}},
  {id="q30", name="Doric's Quest", page="Doric's Quest", f2p=true, items={{"Clay", "Clay", 6, false}, {"Copper ore", "Copper ore", 4, false}, {"Iron ore", "Iron ore", 2, false}}},
  {id="q31", name="Dragon Slayer I", page="Dragon Slayer I", f2p=true, items={{"Anti-dragon shield", "Anti-dragon shield", 1, true}, {"Coins", "Coins", 2000, false}, {"Hammer", "Hammer", 1, false}, {"Lobster pot", "Lobster pot", 1, false}, {"Plank", "Plank", 3, false}, {"Silk", "Silk", 1, false}, {"Steel nails", "Steel nails", 90, false}, {"Unfired bowl", "Unfired bowl", 1, false}, {"Wizard's mind bomb", "Wizard's mind bomb", 1, false}}},
  {id="q32", name="Dragon Slayer II", page="Dragon Slayer II", f2p=false, items={{"Astral rune", "Astral rune", 1, false}, {"Axe", "Axe", 1, false}, {"Catspeak amulet", "Catspeak amulet", 1, false}, {"Dragonstone", "Dragonstone", 1, false}, {"Ghostspeak amulet", "Ghostspeak amulet", 1, false}, {"Glassblowing pipe", "Glassblowing pipe", 1, false}, {"Goutweed", "Goutweed", 1, false}, {"Hammer", "Hammer", 1, false}, {"Machete", "Machete", 1, false}, {"Molten glass", "Molten glass", 2, false}, {"Nails", "Nails", 12, false}, {"Oak plank", "Oak plank", 8, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Saw", "Saw", 1, false}, {"Seal of passage", "Seal of passage", 1, false}, {"Spade", "Spade", 1, false}, {"Swamp paste", "Swamp paste", 10, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q33", name="Dream Mentor", page="Dream Mentor", f2p=false, items={{"Astral rune", "Astral rune", 1, false}, {"Goutweed", "Goutweed", 1, false}, {"Hammer", "Hammer", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Seal of passage", "Seal of passage", 1, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q34", name="Druidic Ritual", page="Druidic Ritual", f2p=false, items={{"Raw bear meat", "Raw bear meat", 1, false}, {"Raw beef", "Raw beef", 1, false}, {"Raw chicken", "Raw chicken", 1, false}, {"Raw rat meat", "Raw rat meat", 1, false}}},
  {id="q35", name="Dwarf Cannon", page="Dwarf Cannon", f2p=false, items={{"Hammer", "Hammer", 1, true}}},
  {id="q36", name="Eadgar's Ruse", page="Eadgar's Ruse", f2p=false, items={{"Climbing boots", "Climbing boots", 1, false}, {"Grain", "Grain", 10, true}, {"Logs", "Logs", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Pineapple chunks", "Pineapple chunks", 1, false}, {"Ranarr potion (unf)", "Ranarr potion (unf)", 1, false}, {"Raw chicken", "Raw chicken", 5, false}, {"Vodka", "Vodka", 1, false}}},
  {id="q37", name="Eagles' Peak", page="Eagles' Peak", f2p=false, items={{"Coins", "Coins", 50, false}, {"Swamp tar", "Swamp tar", 1, false}, {"Yellow dye", "Yellow dye", 1, false}}},
  {id="q38", name="Elemental Workshop I", page="Elemental Workshop I", f2p=false, items={{"Coal", "Coal", 4, false}, {"Hammer", "Hammer", 1, false}, {"Knife", "Knife", 1, true}, {"Leather", "Leather", 1, true}, {"Needle", "Needle", 1, true}, {"Pickaxe", "Pickaxe", 1, false}, {"Thread", "Thread", 1, false}}},
  {id="q39", name="Elemental Workshop II", page="Elemental Workshop II", f2p=false, items={{"Battered key", "Battered key", 1, false}, {"Elemental metal", "Elemental metal", 2, false}, {"Hammer", "Hammer", 1, false}, {"Pickaxe", "Pickaxe", 1, true}}},
  {id="q40", name="Enakhra's Lament", page="Enakhra's Lament", f2p=false, items={{"Bread", "Bread", 1, false}, {"Candle", "Candle", 1, false}, {"Chisel", "Chisel", 1, false}, {"Coal", "Coal", 1, true}, {"Granite", "Granite", 1, true}, {"Logs", "Logs", 1, false}, {"Maple logs", "Maple logs", 1, false}, {"Oak logs", "Oak logs", 1, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Sandstone", "Sandstone", 1, true}, {"Soft clay", "Soft clay", 1, true}, {"Tinderbox", "Tinderbox", 1, false}, {"Willow logs", "Willow logs", 1, false}}},
  {id="q41", name="Enlightened Journey", page="Enlightened Journey", f2p=false, items={{"Ball of wool", "Ball of wool", 1, false}, {"Bowl", "Bowl", 1, true}, {"Candle", "Candle", 1, true}, {"Empty sack", "Empty sack", 8, false}, {"Logs", "Logs", 10, false}, {"Papyrus", "Papyrus", 3, false}, {"Potatoes", "Potatoes", 1, false}, {"Red dye", "Red dye", 1, false}, {"Silk", "Silk", 10, false}, {"Tinderbox", "Tinderbox", 1, false}, {"Willow branch", "Willow branch", 12, false}, {"Yellow dye", "Yellow dye", 1, false}}},
  {id="q42", name="Ernest the Chicken", page="Ernest the Chicken", f2p=true, items={{"Fish food", "Fish food", 1, true}, {"Poison (item)", "Poison", 1, true}, {"Spade", "Spade", 1, true}}},
  {id="q43", name="The Eyes of Glouphrie", page="The Eyes of Glouphrie", f2p=false, items={{"Bucket of sap", "Bucket of sap", 1, false}, {"Hammer", "Hammer", 1, false}, {"Maple logs", "Maple logs", 1, false}, {"Mud rune", "Mud rune", 1, false}, {"Oak logs", "Oak logs", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Saw", "Saw", 1, false}}},
  {id="q44", name="Fairytale I - Growing Pains", page="Fairytale I - Growing Pains", f2p=false, items={{"Dramen staff", "Dramen staff", 1, false}, {"Draynor skull", "Draynor skull", 1, true}, {"Ghostspeak amulet", "Ghostspeak amulet", 1, false}, {"Secateurs", "Secateurs", 1, false}, {"Spade", "Spade", 1, true}}},
  {id="q45", name="Fairytale II - Cure a Queen", page="Fairytale II - Cure a Queen", f2p=false, items={{"Dramen staff", "Dramen staff", 1, false}, {"Nuff's certificate", "Nuff's certificate", 1, true}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Vial of water", "Vial of water", 1, false}}},
  {id="q46", name="Fallen From Grace", page="Fallen From Grace", f2p=false, items={{"Chisel", "Chisel", 1, true}, {"Pickaxe", "Pickaxe", 1, true}}},
  {id="q47", name="Family Crest", page="Family Crest", f2p=false, items={{"Antipoison", "Any poison cure", 1, false}, {"Bass", "Bass", 1, false}, {"Necklace mould", "Necklace mould", 1, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Ring mould", "Ring mould", 1, false}, {"Ruby", "Ruby", 2, false}, {"Salmon", "Salmon", 1, false}, {"Shrimps", "Shrimps", 1, false}, {"Swordfish", "Swordfish", 1, false}, {"Tuna", "Tuna", 1, false}}},
  {id="q48", name="The Feud", page="The Feud", f2p=false, items={{"Beer", "Beer", 3, true}, {"Bucket", "Bucket", 1, true}, {"Coins", "Coins", 501, false}, {"Fake beard", "Fake beard", 1, false}, {"Gloves", "Gloves", 1, false}, {"Kharidian headpiece", "Kharidian headpiece", 1, false}, {"Snake basket", "Snake basket", 1, true}, {"Snake charm", "Snake charm", 1, true}}},
  {id="q49", name="Fight Arena", page="Fight Arena", f2p=false, items={{"Coins", "Coins", 5, false}}},
  {id="q50", name="The Final Dawn", page="The Final Dawn", f2p=false, items={{"Beer", "Beer", 1, true}, {"Bones", "Bones", 1, false}, {"Knife", "Knife", 1, true}, {"Twilight Emissary Robes", "Twilight Emissary Robes", 1, false}}},
  {id="q51", name="Fishing Contest", page="Fishing Contest", f2p=false, items={{"Coins", "Coins", 5, false}, {"Fishing rod", "Fishing rod", 1, false}, {"Garlic", "Garlic", 1, true}, {"Red vine worm", "Red vine worm", 1, true}, {"Spade", "Spade", 1, false}}},
  {id="q52", name="Forgettable Tale...", page="Forgettable Tale...", f2p=false, items={{"Ale yeast", "Ale yeast", 1, true}, {"Barley malt", "Barley malt", 2, false}, {"Beer", "Beer", 2, true}, {"Beer glass", "Beer glass", 1, true}, {"Bucket of water", "Bucket of water", 2, false}, {"Coins", "Coins", 400, false}, {"Kebab", "Kebab", 1, true}, {"Rake", "Rake", 1, true}, {"Seed dibber", "Seed dibber", 1, false}}},
  {id="q53", name="The Forsaken Tower", page="The Forsaken Tower", f2p=false, items={{"Tinderbox", "Tinderbox", 1, true}}},
  {id="q54", name="The Fremennik Exiles", page="The Fremennik Exiles", f2p=false, items={{"Astral rune", "Astral rune", 100, false}, {"Fishing rod", "Fishing rod", 1, false}, {"Fremennik shield", "Fremennik shield", 1, false}, {"Glassblowing pipe", "Glassblowing pipe", 1, false}, {"Hammer", "Hammer", 1, false}, {"Ice gloves", "Ice gloves", 1, false}, {"Keg of beer", "Keg of beer", 2, false}, {"Lunar bar", "Lunar bar", 3, false}, {"Mirror shield", "Mirror shield", 1, false}, {"Molten glass", "Molten glass", 1, false}, {"Pet rock", "Pet rock", 1, false}, {"Seal of passage", "Seal of passage", 1, false}}},
  {id="q55", name="The Fremennik Isles", page="The Fremennik Isles", f2p=false, items={{"Coins", "Coins", 5000, false}, {"Knife", "Knife", 1, false}, {"Neitiznot shield", "Neitiznot shield", 1, false}, {"Raw tuna", "Raw tuna", 1, true}, {"Rope", "Rope", 9, true}, {"Silly jester costume", "Silly jester costume", 1, true}, {"Split log", "Split log", 8, true}, {"Tin ore", "Tin ore", 1, false}, {"Yak-hide armour (top)", "Yak-hide armour (top)", 1, false}}},
  {id="q56", name="The Fremennik Trials", page="The Fremennik Trials", f2p=false, items={{"Beer tankard", "Beer tankard", 1, true}, {"Coins", "Coins", 5252, false}, {"Lyre", "Lyre", 1, false}, {"Raw shark", "Raw shark", 1, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q57", name="The Garden of Death", page="The Garden of Death", f2p=false, items={{"Secateurs", "Secateurs", 1, true}}},
  {id="q58", name="Garden of Tranquillity", page="Garden of Tranquillity", f2p=false, items={{"Cabbage seed", "Cabbage seed", 3, false}, {"Filled plant pot", "Filled plant pot", 1, false}, {"Hammer", "Hammer", 1, false}, {"Marigold seed", "Marigold seed", 1, false}, {"Onion seed", "Onion seed", 3, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Plant cure", "Plant cure", 2, false}, {"Ring of Charos", "Ring of Charos", 1, false}, {"Rune essence", "Rune essence", 1, false}, {"Ultracompost", "Ultracompost", 2, false}}},
  {id="q59", name="Gertrude's Cat", page="Gertrude's Cat", f2p=false, items={{"Bucket of milk", "Bucket of milk", 1, false}, {"Coins", "Coins", 100, false}, {"Seasoned sardine", "Seasoned sardine", 1, false}}},
  {id="q60", name="Getting Ahead", page="Getting Ahead", f2p=false, items={{"Bear fur", "Bear fur", 1, false}, {"Hammer", "Hammer", 1, false}, {"Knife", "Knife", 1, false}, {"Nails", "Nails", 6, false}, {"Needle", "Needle", 1, false}, {"Plank", "Plank", 2, false}, {"Pot of flour", "Pot of flour", 1, false}, {"Red dye", "Red dye", 1, false}, {"Saw", "Saw", 1, false}, {"Soft clay", "Soft clay", 1, false}, {"Thread", "Thread", 1, false}}},
  {id="q61", name="Ghosts Ahoy", page="Ghosts Ahoy", f2p=false, items={{"Bucket of milk", "Bucket of milk", 1, false}, {"Bucket of slime", "Bucket of slime", 1, false}, {"Coins", "Coins", 400, false}, {"Dye", "Dye", 3, false}, {"Ecto-token", "Ecto-token", 1, false}, {"Ghostspeak amulet", "Ghostspeak amulet", 1, false}, {"Knife", "Knife", 1, false}, {"Needle", "Needle", 1, false}, {"Nettle tea", "Nettle tea", 1, false}, {"Oak longbow", "Oak longbow", 1, false}, {"Silk", "Silk", 1, false}, {"Spade", "Spade", 1, false}}},
  {id="q62", name="The Giant Dwarf", page="The Giant Dwarf", f2p=false, items={{"Coal", "Coal", 1, true}, {"Coins", "Coins", 200, false}, {"Iron bar", "Iron bar", 1, false}, {"Logs", "Logs", 1, false}, {"Redberry pie", "Redberry pie", 1, false}, {"Sapphire", "Sapphire", 3, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q63", name="Goblin Diplomacy", page="Goblin Diplomacy", f2p=true, items={{"Blue dye", "Blue dye", 1, false}, {"Goblin mail", "Goblin mail", 3, true}, {"Orange dye", "Orange dye", 1, false}}},
  {id="q64", name="The Golem", page="The Golem", f2p=false, items={{"Papyrus", "Papyrus", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Phoenix feather", "Phoenix feather", 1, false}, {"Shantay pass (item)", "Shantay pass", 1, false}, {"Soft clay", "Soft clay", 4, false}, {"Vial", "Vial", 1, false}}},
  {id="q65", name="The Grand Tree", page="The Grand Tree", f2p=false, items={{"Coins", "Coins", 1000, false}}},
  {id="q66", name="The Great Brain Robbery", page="The Great Brain Robbery", f2p=false, items={{"Diving apparatus", "Diving apparatus", 1, false}, {"Fishbowl helmet", "Fishbowl helmet", 1, false}, {"Hammer", "Hammer", 1, false}, {"Holy symbol", "Holy symbol", 1, false}, {"Nails", "Nails", 100, false}, {"Plank", "Plank", 8, false}, {"Ring of Charos", "Ring of Charos", 1, true}, {"Wooden cat", "Wooden cat", 10, false}}},
  {id="q67", name="Grim Tales", page="Grim Tales", f2p=false, items={{"Axe", "Axe", 1, false}, {"Leather gloves", "Leather gloves", 1, true}, {"Seed dibber", "Seed dibber", 1, false}, {"Tarromin potion (unf)", "Tarromin potion (unf)", 2, false}, {"Watering can", "Watering can", 1, false}}},
  {id="q68", name="The Hand in the Sand", page="The Hand in the Sand", f2p=false, items={{"Beer", "Beer", 1, true}, {"Bucket of sand", "Bucket of sand", 1, true}, {"Coins", "Coins", 150, false}, {"Earth rune", "Earth rune", 5, false}, {"Lantern lens", "Lantern lens", 1, false}, {"Redberries", "Redberries", 1, true}, {"Vial", "Vial", 1, false}, {"White berries", "White berries", 1, false}}},
  {id="q69", name="Haunted Mine", page="Haunted Mine", f2p=false, items={{"Chisel", "Chisel", 1, true}}},
  {id="q70", name="The Heart of Darkness", page="The Heart of Darkness", f2p=false, items={{"Coins", "Coins", 30, false}, {"Pickaxe", "Pickaxe", 1, true}}},
  {id="q71", name="Heroes' Quest", page="Heroes' Quest", f2p=false, items={{"Black full helm", "Black full helm", 1, false}, {"Black platebody", "Black platebody", 1, false}, {"Black platelegs", "Black platelegs", 1, false}, {"Dusty key", "Dusty key", 1, true}, {"Fishing bait", "Fishing bait", 1, true}, {"Fishing rod", "Fishing rod", 1, true}, {"Harralander potion (unf)", "Harralander potion (unf)", 1, false}, {"Ice gloves", "Ice gloves", 1, true}, {"Pickaxe", "Pickaxe", 1, false}}},
  {id="q72", name="Holy Grail", page="Holy Grail", f2p=false, items={{"Excalibur", "Excalibur", 1, false}}},
  {id="q73", name="Horror from the Deep", page="Horror from the Deep", f2p=false, items={{"Air rune", "Air rune", 1, false}, {"Arrows", "Arrows", 1, false}, {"Earth rune", "Earth rune", 1, false}, {"Fire rune", "Fire rune", 1, false}, {"Hammer", "Hammer", 1, false}, {"Molten glass", "Molten glass", 1, false}, {"Plank", "Plank", 2, false}, {"Steel nails", "Steel nails", 60, false}, {"Swamp tar", "Swamp tar", 1, false}, {"Sword", "Any sword or longsword", 1, false}, {"Tinderbox", "Tinderbox", 1, false}, {"Water rune", "Water rune", 1, false}}},
  {id="q74", name="Icthlarin's Little Helper", page="Icthlarin's Little Helper", f2p=false, items={{"Bag of salt", "Bag of salt", 1, false}, {"Bucket of sap", "Bucket of sap", 1, false}, {"Cat", "Cat", 1, false}, {"Linen (Icthlarin's Little Helper)", "Linen (Icthlarin's Little Helper)", 1, true}, {"Shantay pass (item)", "Shantay pass", 1, false}, {"Tinderbox", "Tinderbox", 1, false}, {"Waterskin", "Waterskin", 1, false}, {"Willow logs", "Willow logs", 1, false}}},
  {id="q75", name="Imp Catcher", page="Imp Catcher", f2p=true, items={{"Black bead", "Black bead", 1, false}, {"Red bead", "Red bead", 1, false}, {"White bead", "White bead", 1, false}, {"Yellow bead", "Yellow bead", 1, false}}},
  {id="q76", name="In Aid of the Myreque", page="In Aid of the Myreque", f2p=false, items={{"Bronze axe", "Bronze axe", 10, false}, {"Bucket", "Bucket", 1, false}, {"Coal", "Coal", 1, false}, {"Hammer", "Hammer", 1, false}, {"Mithril bar", "Mithril bar", 1, false}, {"Nails", "Nails", 44, true}, {"Pickaxe", "Pickaxe", 1, false}, {"Plank", "Plank", 11, false}, {"Raw mackerel", "Raw mackerel", 10, false}, {"Rope", "Rope", 1, false}, {"Sapphire", "Sapphire", 1, false}, {"Silver bar", "Silver bar", 1, false}, {"Soft clay", "Soft clay", 1, false}, {"Spade", "Spade", 1, false}, {"Steel bar", "Steel bar", 2, false}, {"Swamp paste", "Swamp paste", 1, false}, {"Tinderbox", "Tinderbox", 4, false}}},
  {id="q77", name="In Search of the Myreque", page="In Search of the Myreque", f2p=false, items={{"Coins", "Coins", 10, false}, {"Druid pouch", "Druid pouch", 1, false}, {"Hammer", "Hammer", 1, false}, {"Plank", "Plank", 6, false}, {"Steel dagger", "Steel dagger", 1, false}, {"Steel longsword", "Steel longsword", 1, false}, {"Steel mace", "Steel mace", 1, false}, {"Steel nails", "Steel nails", 225, false}, {"Steel sword", "Steel sword", 2, false}, {"Steel warhammer", "Steel warhammer", 1, false}}},
  {id="q78", name="King's Ransom", page="King's Ransom", f2p=false, items={{"Animate rock scroll", "Animate rock scroll", 1, true}, {"Black equipment", "Full black armour", 1, false}, {"Bronze med helm", "Bronze med helm", 1, false}, {"Granite", "Granite", 1, false}, {"Iron chainbody", "Iron chainbody", 1, false}}},
  {id="q79", name="A Kingdom Divided", page="A Kingdom Divided", f2p=false, items={{"Axe", "Axe", 1, false}, {"Dark essence block", "Dark essence block", 1, false}, {"Defence potion", "Defence potion", 1, false}, {"Molten glass", "Molten glass", 1, false}, {"Volcanic sulphur", "Volcanic sulphur", 1, false}}},
  {id="q80", name="The Knight's Sword", page="The Knight's Sword", f2p=true, items={{"Blurite ore", "Blurite ore", 1, true}, {"Iron bar", "Iron bar", 2, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Redberry pie", "Redberry pie", 1, false}}},
  {id="q81", name="Land of the Goblins", page="Land of the Goblins", f2p=false, items={{"Black dye", "Black dye", 1, true}, {"Blue dye", "Blue dye", 1, false}, {"Coins", "Coins", 5, false}, {"Fishing rod", "Fishing rod", 1, false}, {"Goblin mail", "Goblin mail", 1, true}, {"Light sources", "Light sources", 1, false}, {"Orange dye", "Orange dye", 1, false}, {"Purple dye", "Purple dye", 1, false}, {"Raw slimy eel", "Raw slimy eel", 1, false}, {"Toadflax potion (unf)", "Toadflax potion (unf)", 1, false}, {"Yellow dye", "Yellow dye", 1, false}}},
  {id="q82", name="Legends' Quest", page="Legends' Quest", f2p=false, items={{"Ardrigal", "Ardrigal", 1, true}, {"Charcoal", "Charcoal", 1, true}, {"Diamond", "Diamond", 1, false}, {"Earth rune", "Earth rune", 1, false}, {"Emerald", "Emerald", 1, false}, {"Gold bar", "Gold bar", 2, false}, {"Hammer", "Hammer", 1, false}, {"Jade", "Jade", 1, false}, {"Law rune", "Law rune", 2, false}, {"Lockpick", "Lockpick", 1, false}, {"Machete (weapon)", "Machete", 1, true}, {"Mind rune", "Mind rune", 1, false}, {"Opal", "Opal", 1, false}, {"Papyrus", "Papyrus", 3, true}, {"Pickaxe", "Pickaxe", 1, false}, {"Red topaz", "Red topaz", 1, false}, {"Rope", "Rope", 1, false}, {"Ruby", "Ruby", 1, false}, {"Rune axe", "Rune axe", 1, false}, {"Sapphire", "Sapphire", 1, false}, {"Snake weed", "Snake weed", 1, true}, {"Soul rune", "Soul rune", 1, false}, {"Unpowered orb", "Unpowered orb", 1, false}, {"Vial of water", "Vial of water", 1, false}}},
  {id="q83", name="Lost City", page="Lost City", f2p=false, items={{"Axe", "Axe", 1, true}, {"Knife", "Knife", 1, false}}},
  {id="q84", name="The Lost Tribe", page="The Lost Tribe", f2p=false, items={{"Light sources", "Light sources", 1, false}, {"Pickaxe", "Pickaxe", 1, false}}},
  {id="q85", name="Lunar Diplomacy", page="Lunar Diplomacy", f2p=false, items={{"Air talisman", "Air talisman", 1, false}, {"Axe", "Axe", 1, true}, {"Bullseye lantern", "Bullseye lantern", 1, true}, {"Coins", "Coins", 1, false}, {"Dramen staff", "Dramen staff", 1, false}, {"Guam leaf", "Guam leaf", 1, true}, {"Hammer", "Hammer", 1, false}, {"Marrentill", "Marrentill", 1, true}, {"Needle", "Needle", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Spade", "Spade", 1, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q86", name="Making Friends with My Arm", page="Making Friends with My Arm", f2p=false, items={{"Bolt of cloth", "Bolt of cloth", 1, false}, {"Bucket of water", "Bucket of water", 1, true}, {"Cadava berries", "Cadava berries", 1, false}, {"Climbing boots", "Climbing boots", 1, false}, {"Hammer", "Hammer", 1, true}, {"Mahogany plank", "Mahogany plank", 5, false}, {"Pickaxe", "Pickaxe", 1, true}, {"Rope", "Rope", 1, true}, {"Saw", "Saw", 1, false}}},
  {id="q87", name="Making History", page="Making History", f2p=false, items={{"Ghostspeak amulet", "Ghostspeak amulet", 1, false}, {"Sapphire amulet", "Sapphire amulet", 1, false}, {"Spade", "Spade", 1, false}}},
  {id="q88", name="Merlin's Crystal", page="Merlin's Crystal", f2p=false, items={{"Bat bones", "Bat bones", 1, true}, {"Bread", "Bread", 1, false}, {"Bucket of wax", "Bucket of wax", 1, true}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q89", name="Misthalin Mystery", page="Misthalin Mystery", f2p=true, items={{"Bucket", "Bucket", 1, true}, {"Knife", "Knife", 1, true}, {"Tinderbox", "Tinderbox", 1, true}}},
  {id="q90", name="Monk's Friend", page="Monk's Friend", f2p=false, items={{"Jug of water", "Jug of water", 1, false}, {"Logs", "Logs", 1, false}}},
  {id="q91", name="Monkey Madness I", page="Monkey Madness I", f2p=false, items={{"Ball of wool", "Ball of wool", 1, false}, {"Banana", "Banana", 1, true}, {"Gold bar", "Gold bar", 1, false}, {"Monkey bones", "Monkey bones", 1, true}}},
  {id="q92", name="Monkey Madness II", page="Monkey Madness II", f2p=false, items={{"Chisel", "Chisel", 1, true}, {"Grapes", "Grapes", 1, false}, {"Hammer", "Hammer", 1, true}, {"Lemon", "Lemon", 1, false}, {"Light sources", "Light sources", 1, false}, {"Logs", "Logs", 1, false}, {"M'speak amulet", "M'speak amulet", 1, false}, {"Monkey talisman", "Monkey talisman", 1, true}, {"Ninja monkey greegree", "Ninja monkey greegree", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Slash weapons", "Slash weapons", 1, false}, {"Translation book", "Translation book", 1, true}}},
  {id="q93", name="Mountain Daughter", page="Mountain Daughter", f2p=false, items={{"Axe", "Axe", 1, false}, {"Gloves", "Gloves", 1, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Plank", "Plank", 1, false}, {"Rope", "Rope", 1, false}, {"Staff", "Staff or pole", 1, true}}},
  {id="q94", name="Mourning's End Part I", page="Mourning's End Part I", f2p=false, items={{"Barrel of naphtha", "Barrel of naphtha", 1, false}, {"Bear fur", "Bear fur", 1, true}, {"Bucket of water", "Bucket of water", 1, true}, {"Dye", "Dye", 1, true}, {"Feather", "Feather", 1, false}, {"Leather", "Leather", 1, false}, {"Magic logs", "Magic logs", 1, false}, {"Ogre bellows", "Ogre bellows", 1, true}, {"Rotten apple", "Rotten apple", 1, true}, {"Silk", "Silk", 2, false}, {"Toad crunchies", "Toad crunchies", 1, false}}},
  {id="q95", name="Mourning's End Part II", page="Mourning's End Part II", f2p=false, items={{"Chisel", "Chisel", 1, false}, {"Death talisman", "Death talisman", 1, false}, {"Mourner gear", "Mourner gear", 1, false}, {"Rope", "Rope", 1, false}}},
  {id="q96", name="Murder Mystery", page="Murder Mystery", f2p=false, items={{"Pot", "Pot", 1, false}}},
  {id="q97", name="My Arm's Big Adventure", page="My Arm's Big Adventure", f2p=false, items={{"Bucket", "Bucket", 1, true}, {"Climbing boots", "Climbing boots", 1, false}, {"Ugthanki dung", "Ugthanki dung", 3, false}}},
  {id="q98", name="Nature Spirit", page="Nature Spirit", f2p=false, items={{"Ghostspeak amulet", "Ghostspeak amulet", 1, false}, {"Silver sickle", "Silver sickle", 1, false}}},
  {id="q99", name="A Night at the Theatre", page="A Night at the Theatre", f2p=false, items={{"Axe", "Axe", 1, false}, {"Ghostspeak amulet", "Ghostspeak amulet", 1, false}, {"Ivandis flail", "Ivandis flail", 1, false}, {"Saw", "Saw", 1, false}}},
  {id="q100", name="Observatory Quest", page="Observatory Quest", f2p=false, items={{"Bronze bar", "Bronze bar", 1, false}, {"Molten glass", "Molten glass", 1, false}, {"Plank", "Plank", 3, false}}},
  {id="q101", name="Olaf's Quest", page="Olaf's Quest", f2p=false, items={{"Axe", "Axe", 1, false}, {"Rope", "Rope", 6, true}, {"Spade", "Spade", 1, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q102", name="One Small Favour", page="One Small Favour", f2p=false, items={{"Bronze bar", "Bronze bar", 1, false}, {"Chisel", "Chisel", 1, true}, {"Guthix rest", "Guthix rest", 1, false}, {"Hammer", "Hammer", 1, true}, {"Iron bar", "Iron bar", 1, false}, {"Pigeon cage", "Pigeon cage", 5, true}, {"Pot", "Pot", 1, true}, {"Soft clay", "Soft clay", 1, true}, {"Steel bar", "Steel bar", 4, false}}},
  {id="q103", name="Pandemonium", page="Pandemonium", f2p=false, items={{"Hammer", "Hammer", 1, true}, {"Saw", "Saw", 1, true}}},
  {id="q104", name="The Path of Glouphrie", page="The Path of Glouphrie", f2p=false, items={{"Crossbow (weapon)", "Crossbow", 1, false}, {"Key (Tree Gnome Village Dungeon)", "Key (Tree Gnome Village Dungeon)", 1, true}, {"Mith grapple", "Mith grapple", 1, false}}},
  {id="q105", name="Perilous Moons", page="Perilous Moons", f2p=false, items={{"Big fishing net", "Big fishing net", 1, true}, {"Knife", "Knife", 1, true}, {"Pestle and mortar", "Pestle and mortar", 1, true}, {"Rope", "Rope", 1, true}}},
  {id="q106", name="Pirate's Treasure", page="Pirate's Treasure", f2p=true, items={{"Banana", "Banana", 10, true}, {"Coins", "Coins", 60, false}, {"Karamjan rum", "Karamjan rum", 1, true}, {"Spade", "Spade", 1, true}, {"White apron", "White apron", 1, true}}},
  {id="q107", name="Plague City", page="Plague City", f2p=false, items={{"Bucket of water", "Bucket of water", 1, false}, {"Dwellberries", "Dwellberries", 1, false}, {"Hangover cure", "Hangover cure", 1, false}, {"Picture", "Picture", 1, false}, {"Rope", "Rope", 1, false}, {"Spade", "Spade", 1, false}}},
  {id="q108", name="A Porcine of Interest", page="A Porcine of Interest", f2p=false, items={{"Knife", "Knife", 1, true}, {"Rope", "Rope", 1, false}}},
  {id="q109", name="Priest in Peril", page="Priest in Peril", f2p=false, items={{"Bucket", "Bucket", 1, true}, {"Rune essence", "Rune essence", 50, false}}},
  {id="q110", name="Prince Ali Rescue", page="Prince Ali Rescue", f2p=true, items={{"Ashes", "Ashes", 1, false}, {"Ball of wool", "Ball of wool", 3, false}, {"Beer", "Beer", 3, false}, {"Bronze bar", "Bronze bar", 1, false}, {"Bucket of water", "Bucket of water", 1, true}, {"Coins", "Coins", 30, false}, {"Pink skirt", "Pink skirt", 1, false}, {"Pot of flour", "Pot of flour", 1, false}, {"Redberries", "Redberries", 1, false}, {"Rope", "Rope", 1, true}, {"Soft clay", "Soft clay", 1, false}, {"Yellow dye", "Yellow dye", 1, false}}},
  {id="q111", name="Prying Times", page="Prying Times", f2p=false, items={{"Captain's log", "Captain's log", 1, false}, {"Hammer", "Hammer", 1, true}, {"Redberry pie", "Redberry pie", 1, false}, {"Steel bar", "Steel bar", 1, false}}},
  {id="q112", name="The Queen of Thieves", page="The Queen of Thieves", f2p=false, items={{"Stew", "Stew", 1, true}}},
  {id="q113", name="Rag and Bone Man I", page="Rag and Bone Man I", f2p=false, items={{"Coins", "Coins", 8, false}, {"Logs", "Logs", 8, false}, {"Pot", "Pot", 8, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q114", name="Rag and Bone Man II", page="Rag and Bone Man II", f2p=false, items={{"Dusty key", "Dusty key", 1, false}, {"Fishing explosive", "Fishing explosive", 1, false}, {"Ice cooler", "Ice cooler", 1, false}, {"Jug of vinegar", "Jug of vinegar", 27, false}, {"Light sources", "Light sources", 1, false}, {"Logs", "Logs", 27, false}, {"Mirror shield", "Mirror shield", 1, false}, {"Pot", "Pot", 27, false}, {"Rope", "Rope", 1, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q115", name="Ratcatchers", page="Ratcatchers", f2p=false, items={{"Bucket of milk", "Bucket of milk", 1, false}, {"Cat", "Cat", 1, false}, {"Catspeak amulet", "Catspeak amulet", 1, false}, {"Cheese", "Cheese", 4, false}, {"Coins", "Coins", 101, false}, {"Marrentill", "Marrentill", 1, false}, {"Pot of weeds", "Pot of weeds", 1, false}, {"Rat poison", "Rat poison", 1, true}, {"Snake charm", "Snake charm", 1, true}, {"Tinderbox", "Tinderbox", 1, false}, {"Unicorn horn dust", "Unicorn horn dust", 1, false}}},
  {id="q116", name="Recipe for Disaster - Another Cook's Quest", page="Recipe for Disaster/Another Cook's Quest", f2p=false, items={{"Ashes", "Ashes", 1, false}, {"Eye of newt", "Eye of newt", 1, false}, {"Fruit blast", "Fruit blast", 1, false}, {"Greenman's ale", "Greenman's ale", 1, false}, {"Rotten tomato", "Rotten tomato", 1, false}}},
  {id="q117", name="Recipe for Disaster - Culinaromancer", page="Recipe for Disaster/Defeating the Culinaromancer", f2p=false, items={{"Ice gloves", "Ice gloves", 1, false}, {"Menaphite remedy", "Menaphite remedy", 1, false}, {"Shark", "Shark", 1, false}}},
  {id="q118", name="Recipe for Disaster - Evil Dave", page="Recipe for Disaster/Freeing Evil Dave", f2p=false, items={{"Cat", "Cat", 1, false}, {"Stew", "Stew", 1, false}}},
  {id="q119", name="Recipe for Disaster - King Awowogei", page="Recipe for Disaster/Freeing King Awowogei", f2p=false, items={{"Banana", "Banana", 1, true}, {"Gorilla greegree", "Gorilla greegree", 1, false}, {"Karamjan monkey greegree", "Karamjan monkey greegree", 1, false}, {"Knife", "Knife", 1, false}, {"M'speak amulet", "M'speak amulet", 1, false}, {"Monkey nuts", "Monkey nuts", 1, true}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Rope", "Rope", 1, false}}},
  {id="q120", name="Recipe for Disaster - Pirate Pete", page="Recipe for Disaster/Freeing Pirate Pete", f2p=false, items={{"Bread", "Bread", 1, false}, {"Bronze wire", "Bronze wire", 3, false}, {"Fishbowl", "Fishbowl", 1, false}, {"Knife", "Knife", 1, false}, {"Needle", "Needle", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Raw cod", "Raw cod", 1, false}}},
  {id="q121", name="Recipe for Disaster - Sir Amik Varze", page="Recipe for Disaster/Freeing Sir Amik Varze", f2p=false, items={{"Bucket of milk", "Bucket of milk", 1, false}, {"Dramen branch", "Dramen branch", 1, false}, {"Dramen staff", "Dramen staff", 1, false}, {"Ice gloves", "Ice gloves", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Pot of cornflour", "Pot of cornflour", 1, false}, {"Pot of cream", "Pot of cream", 1, false}, {"Raw chicken", "Raw chicken", 1, false}, {"Vanilla pod", "Vanilla pod", 1, false}}},
  {id="q122", name="Recipe for Disaster - Skrach Uglogwee", page="Recipe for Disaster/Freeing Skrach Uglogwee", f2p=false, items={{"Axe", "Axe", 1, false}, {"Ball of wool", "Ball of wool", 1, false}, {"Iron spit", "Iron spit", 1, false}, {"Logs", "Logs", 1, true}, {"Ogre arrow", "Ogre arrow", 1, false}, {"Ogre bellows", "Ogre bellows", 1, true}, {"Ogre bow", "Ogre bow", 1, true}, {"Pickaxe", "Pickaxe", 1, false}, {"Raw chompy", "Raw chompy", 1, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q123", name="Recipe for Disaster - Wartface & Bentnoze", page="Recipe for Disaster/Freeing the Goblin generals", f2p=false, items={{"Blue dye", "Blue dye", 1, false}, {"Bread", "Bread", 1, false}, {"Bucket of water", "Bucket of water", 1, false}, {"Charcoal", "Charcoal", 1, false}, {"Fishing bait", "Fishing bait", 1, false}, {"Orange slices", "Orange slices", 1, false}, {"Spice", "Spice", 1, false}}},
  {id="q124", name="Recipe for Disaster - Lumbridge Guide", page="Recipe for Disaster/Freeing the Lumbridge Guide", f2p=false, items={{"Bucket of milk", "Bucket of milk", 1, false}, {"Cake tin", "Cake tin", 1, false}, {"Egg", "Egg", 1, false}, {"Necklace of passage", "Necklace of passage", 1, false}, {"Pot of flour", "Pot of flour", 1, false}}},
  {id="q125", name="Recipe for Disaster - Mountain Dwarf", page="Recipe for Disaster/Freeing the Mountain Dwarf", f2p=false, items={{"Asgarnian ale", "Asgarnian ale", 4, true}, {"Bowl of water", "Bowl of water", 1, false}, {"Bucket of milk", "Bucket of milk", 1, false}, {"Coins", "Coins", 306, false}, {"Egg", "Egg", 1, false}, {"Gloves", "Gloves", 1, false}, {"Pot of flour", "Pot of flour", 1, false}}},
  {id="q126", name="Regicide", page="Regicide", f2p=false, items={{"Bow", "Bow", 1, false}, {"Coal", "Coal", 5, false}, {"Cooked rabbit", "Cooked rabbit", 1, true}, {"Gloves", "Gloves", 1, false}, {"Limestone", "Limestone", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Pot", "Pot", 1, true}, {"Rope", "Rope", 2, false}, {"Spade", "Spade", 1, false}, {"Strip of cloth", "Strip of cloth", 1, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q127", name="The Ribbiting Tale of a Lily Pad Labour Dispute", page="The Ribbiting Tale of a Lily Pad Labour Dispute", f2p=false, items={{"Bronze axe", "Bronze axe", 1, true}}},
  {id="q128", name="Romeo & Juliet", page="Romeo & Juliet", f2p=true, items={{"Cadava berries", "Cadava berries", 1, true}}},
  {id="q129", name="Roving Elves", page="Roving Elves", f2p=false, items={{"Glarial's pebble", "Glarial's pebble", 1, true}, {"Key (Waterfall Dungeon)", "Key (Waterfall Dungeon)", 1, true}, {"Rope", "Rope", 1, false}, {"Spade", "Spade", 1, false}}},
  {id="q130", name="Royal Trouble", page="Royal Trouble", f2p=false, items={{"Coal", "Coal", 5, true}, {"Plank", "Plank", 1, true}, {"Rope", "Rope", 2, true}}},
  {id="q131", name="Rum Deal", page="Rum Deal", f2p=false, items={{"Bucket", "Bucket", 1, true}, {"Rake", "Rake", 1, true}, {"Seed dibber", "Seed dibber", 1, true}}},
  {id="q132", name="Rune Mysteries", page="Rune Mysteries", f2p=true, items={{"Air talisman", "Air talisman", 1, true}}},
  {id="q133", name="Scorpion Catcher", page="Scorpion Catcher", f2p=false, items={{"Dusty key", "Dusty key", 1, true}}},
  {id="q134", name="Scrambled!", page="Scrambled!", f2p=false, items={{"Bowl of water", "Bowl of water", 1, false}, {"Hammer", "Hammer", 1, false}, {"Nails", "Nails", 6, false}, {"Plank", "Plank", 2, false}, {"Saw", "Saw", 1, false}}},
  {id="q135", name="Sea Slug", page="Sea Slug", f2p=false, items={{"Swamp paste", "Swamp paste", 1, false}}},
  {id="q136", name="Secrets of the North", page="Secrets of the North", f2p=false, items={{"Coins", "Coins", 100, false}, {"Lockpick", "Lockpick", 1, false}, {"Tinderbox", "Tinderbox", 1, true}}},
  {id="q137", name="Shades of Mort'ton", page="Shades of Mort'ton", f2p=false, items={{"Ashes", "Ashes", 2, false}, {"Coins", "Coins", 1000, false}, {"Hammer", "Hammer", 1, false}, {"Logs", "Logs", 1, false}, {"Tarromin potion (unf)", "Tarromin potion (unf)", 2, true}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q138", name="Shadow of the Storm", page="Shadow of the Storm", f2p=false, items={{"Black dye", "Black dye", 1, false}, {"Shantay pass (item)", "Shantay pass", 1, false}, {"Silver bar", "Silver bar", 1, false}, {"Silverlight", "Silverlight", 1, true}, {"Strange implement", "Strange implement", 1, true}}},
  {id="q139", name="Shadows of Custodia", page="Shadows of Custodia", f2p=false, items={{"Fishing rod", "Fishing rod", 1, true}, {"Hammer", "Hammer", 1, true}, {"Maple logs", "Maple logs", 4, true}, {"Willow longbow", "Willow longbow", 4, false}}},
  {id="q140", name="Sheep Herder", page="Sheep Herder", f2p=false, items={{"Coins", "Coins", 100, false}}},
  {id="q141", name="Sheep Shearer", page="Sheep Shearer", f2p=true, items={{"Ball of wool", "Ball of wool", 20, false}}},
  {id="q142", name="Shield of Arrav", page="Shield of Arrav", f2p=true, items={{"Coins", "Coins", 1, false}, {"Phoenix crossbow", "Phoenix crossbow", 1, true}}},
  {id="q143", name="Shilo Village", page="Shilo Village", f2p=false, items={{"Bones", "Bones", 3, true}, {"Bronze wire", "Bronze wire", 1, false}, {"Chisel", "Chisel", 1, false}, {"Rope", "Rope", 1, false}, {"Spade", "Spade", 1, false}, {"Torch", "Torch", 1, false}}},
  {id="q144", name="Sins of the Father", page="Sins of the Father", f2p=false, items={{"Axe", "Axe", 1, false}, {"Chisel", "Chisel", 1, false}, {"Ivandis flail", "Ivandis flail", 1, false}, {"Knife", "Knife", 1, true}, {"Ruby", "Ruby", 1, false}, {"Vyrewatch outfit", "Vyrewatch outfit", 1, true}}},
  {id="q145", name="Sleeping Giants", page="Sleeping Giants", f2p=false, items={{"Bucket of water", "Bucket of water", 1, true}, {"Chisel", "Chisel", 1, false}, {"Hammer", "Hammer", 1, false}, {"Nails", "Nails", 10, false}, {"Oak logs", "Oak logs", 3, false}, {"Wool", "Wool", 1, false}}},
  {id="q146", name="The Slug Menace", page="The Slug Menace", f2p=false, items={{"Chisel", "Chisel", 1, false}, {"Commorb", "Commorb", 1, false}, {"Dead sea slug", "Dead sea slug", 1, true}, {"Rune essence", "Rune essence", 5, false}, {"Swamp paste", "Swamp paste", 1, false}}},
  {id="q147", name="Song of the Elves", page="Song of the Elves", f2p=false, items={{"Adamant chainbody", "Adamant chainbody", 1, true}, {"Axe", "Axe", 1, false}, {"Black knife", "Black knife", 1, false}, {"Cabbage", "Cabbage", 1, true}, {"Cadantine seed", "Cadantine seed", 1, false}, {"Flowers", "Flowers", 1, false}, {"Hammer", "Hammer", 1, false}, {"Limestone brick", "Limestone brick", 1, false}, {"Mourner gear", "Mourner gear", 1, false}, {"Nature rune", "Nature rune", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Purple dye", "Purple dye", 1, false}, {"Red dye", "Red dye", 1, false}, {"Rope", "Rope", 1, false}, {"Runite bar", "Runite bar", 1, false}, {"Saw", "Saw", 1, false}, {"Seed dibber", "Seed dibber", 1, false}, {"Silk", "Silk", 1, false}, {"Spade", "Spade", 1, false}, {"Steel full helm", "Steel full helm", 1, false}, {"Steel platebody", "Steel platebody", 1, false}, {"Steel platelegs", "Steel platelegs", 1, false}, {"Tinderbox", "Tinderbox", 1, false}, {"Vial of water", "Vial of water", 1, false}, {"Wine of Zamorak", "Wine of Zamorak", 1, false}}},
  {id="q148", name="A Soul's Bane", page="A Soul's Bane", f2p=false, items={{"Rope", "Rope", 1, false}}},
  {id="q149", name="Spirits of the Elid", page="Spirits of the Elid", f2p=false, items={{"Crush weapons", "Crush weapons", 1, false}, {"Knife", "Knife", 1, false}, {"Light sources", "Light sources", 1, false}, {"Needle", "Needle", 1, false}, {"Pickaxe", "Pickaxe", 1, true}, {"Rope", "Rope", 1, false}, {"Shortbow", "Shortbow", 1, true}, {"Slash weapons", "Slash weapons", 1, false}, {"Stab weapons", "Stab weapons", 1, false}, {"Thread", "Thread", 1, false}}},
  {id="q150", name="Swan Song", page="Swan Song", f2p=false, items={{"Airtight pot", "Airtight pot", 1, false}, {"Blood rune", "Blood rune", 5, false}, {"Bones", "Bones", 7, true}, {"Brown apron", "Brown apron", 1, true}, {"Hammer", "Hammer", 1, true}, {"Iron bar", "Iron bar", 5, false}, {"Lava rune", "Lava rune", 10, false}, {"Logs", "Logs", 1, false}, {"Mist rune", "Mist rune", 10, false}, {"Small fishing net", "Small fishing net", 1, true}, {"Tinderbox", "Tinderbox", 1, true}}},
  {id="q151", name="Tai Bwo Wannai Trio", page="Tai Bwo Wannai Trio", f2p=false, items={{"Agility potion", "Agility potion", 1, false}, {"Iron spear", "Iron spear", 1, true}, {"Jogre bones", "Jogre bones", 1, true}, {"Karamjan rum", "Karamjan rum", 1, false}, {"Knife", "Knife", 1, false}, {"Logs", "Logs", 2, false}, {"Pestle and mortar", "Pestle and mortar", 1, true}, {"Seaweed", "Seaweed", 1, true}, {"Sliced banana", "Sliced banana", 1, true}, {"Small fishing net", "Small fishing net", 1, false}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q152", name="A Tail of Two Cats", page="A Tail of Two Cats", f2p=false, items={{"Bucket of milk", "Bucket of milk", 1, false}, {"Cat", "Cat", 1, false}, {"Catspeak amulet", "Catspeak amulet", 1, false}, {"Chocolate cake", "Chocolate cake", 1, false}, {"Death rune", "Death rune", 5, false}, {"Desert robe", "Desert robe", 1, true}, {"Desert shirt", "Desert shirt", 1, true}, {"Logs", "Logs", 1, false}, {"Potato seed", "Potato seed", 4, false}, {"Rake", "Rake", 1, false}, {"Seed dibber", "Seed dibber", 1, false}, {"Shears", "Shears", 1, false}, {"Tinderbox", "Tinderbox", 1, false}, {"Vial of water", "Vial of water", 1, false}}},
  {id="q153", name="Tale of the Righteous", page="Tale of the Righteous", f2p=false, items={{"Pickaxe", "Pickaxe", 1, false}, {"Rope", "Rope", 1, false}}},
  {id="q154", name="A Taste of Hope", page="A Taste of Hope", f2p=false, items={{"Chisel", "Chisel", 1, false}, {"Coins", "Coins", 1000, false}, {"Emerald", "Emerald", 1, false}, {"Knife", "Knife", 1, false}, {"Pestle and mortar", "Pestle and mortar", 1, true}, {"Rod of Ivandis", "Rod of Ivandis", 1, true}, {"Vial of water", "Vial of water", 1, true}}},
  {id="q155", name="Tears of Guthix", page="Tears of Guthix", f2p=false, items={{"Chisel", "Chisel", 1, false}, {"Pickaxe", "Pickaxe", 1, false}, {"Rope", "Rope", 1, false}, {"Sapphire lantern", "Sapphire lantern", 1, false}}},
  {id="q156", name="Temple of Ikov", page="Temple of Ikov", f2p=false, items={{"Bow", "Bow", 1, false}, {"Limpwurt root", "Limpwurt root", 20, false}}},
  {id="q157", name="Temple of the Eye", page="Temple of the Eye", f2p=false, items={{"Bucket of water", "Bucket of water", 1, false}, {"Chisel", "Chisel", 1, true}, {"Pickaxe", "Pickaxe", 1, true}}},
  {id="q158", name="Throne of Miscellania", page="Throne of Miscellania", f2p=false, items={{"Gold ring", "Any plain ring", 1, false}, {"Iron bar", "Iron bar", 1, false}, {"Logs", "Logs", 1, true}}},
  {id="q159", name="The Tourist Trap", page="The Tourist Trap", f2p=false, items={{"Bronze bar", "Bronze bar", 1, false}, {"Desert shirt", "Desert shirt", 1, false}, {"Feather", "Feather", 1, false}, {"Hammer", "Hammer", 1, false}, {"Shantay pass (item)", "Shantay pass", 1, false}}},
  {id="q160", name="Tower of Life", page="Tower of Life", f2p=false, items={{"Beer", "Beer", 1, false}, {"Hammer", "Hammer", 1, false}, {"Saw", "Saw", 1, false}}},
  {id="q161", name="Tree Gnome Village", page="Tree Gnome Village", f2p=false, items={{"Logs", "Logs", 6, true}}},
  {id="q162", name="Troll Romance", page="Troll Romance", f2p=false, items={{"Climbing boots", "Climbing boots", 1, false}, {"Iron bar", "Iron bar", 1, false}, {"Maple logs", "Maple logs", 1, false}, {"Rope", "Rope", 1, false}, {"Wax", "Wax", 1, false}}},
  {id="q163", name="Troll Stronghold", page="Troll Stronghold", f2p=false, items={{"Climbing boots", "Climbing boots", 1, false}}},
  {id="q164", name="Troubled Tortugans", page="Troubled Tortugans", f2p=false, items={{"Axe", "Axe", 1, true}, {"Hammer", "Hammer", 1, true}, {"Saw", "Saw", 1, true}}},
  {id="q165", name="Underground Pass", page="Underground Pass", f2p=false, items={{"Arrows", "Arrows", 1, false}, {"Bow", "Bow", 1, false}, {"Bucket", "Bucket", 1, true}, {"Rope", "Rope", 1, false}, {"Spade", "Spade", 1, false}, {"Tinderbox", "Tinderbox", 1, true}}},
  {id="q166", name="Vampyre Slayer", page="Vampyre Slayer", f2p=true, items={{"Beer", "Beer", 1, true}, {"Hammer", "Hammer", 1, false}, {"Stake", "Stake", 1, true}}},
  {id="q167", name="Wanted!", page="Wanted!", f2p=false, items={{"Coins", "Coins", 10000, false}, {"Light sources", "Light sources", 1, false}, {"Rune essence", "Rune essence", 20, false}}},
  {id="q168", name="Watchtower", page="Watchtower", f2p=false, items={{"Bat bones", "Bat bones", 1, true}, {"Coins", "Coins", 20, false}, {"Death rune", "Death rune", 1, true}, {"Dragon bones", "Dragon bones", 1, false}, {"Gold bar", "Gold bar", 1, false}, {"Guam potion (unf)", "Guam potion (unf)", 1, false}, {"Jangerberries", "Jangerberries", 1, true}, {"Light sources", "Light sources", 1, true}, {"Pestle and mortar", "Pestle and mortar", 1, true}, {"Pickaxe", "Pickaxe", 1, false}, {"Rope", "Rope", 2, true}, {"Tinderbox", "Tinderbox", 1, false}}},
  {id="q169", name="Waterfall Quest", page="Waterfall Quest", f2p=false, items={{"Air rune", "Air rune", 6, false}, {"Earth rune", "Earth rune", 6, false}, {"Rope", "Rope", 1, false}, {"Water rune", "Water rune", 6, false}}},
  {id="q170", name="What Lies Below", page="What Lies Below", f2p=false, items={{"Bowl", "Bowl", 1, false}, {"Chaos rune", "Chaos rune", 15, false}}},
  {id="q171", name="While Guthix Sleeps", page="While Guthix Sleeps", f2p=false, items={{"Air rune", "Air rune", 1, false}, {"Bronze med helm", "Bronze med helm", 1, false}, {"Cosmic rune", "Cosmic rune", 1, false}, {"Iron chainbody", "Iron chainbody", 1, false}, {"Knife", "Knife", 1, false}, {"Lantern lens", "Lantern lens", 1, false}, {"Logs", "Logs", 1, false}, {"Mort myre fungus", "Mort myre fungus", 1, false}, {"Papyrus", "Papyrus", 1, false}, {"Pink dye", "Pink dye", 1, false}, {"Restore potion", "Restore potion", 1, false}, {"Ring of Charos", "Ring of Charos", 1, false}, {"Sapphire lantern", "Sapphire lantern", 1, false}, {"Seed dibber", "Seed dibber", 1, false}, {"Snapdragon seed", "Snapdragon seed", 1, false}, {"Unpowered orb", "Unpowered orb", 1, false}}},
  {id="q172", name="Witch's House", page="Witch's House", f2p=false, items={{"Cheese", "Cheese", 1, false}, {"Leather gloves", "Leather gloves", 1, true}}},
  {id="q173", name="Witch's Potion", page="Witch's Potion", f2p=true, items={{"Burnt meat", "Burnt meat", 1, false}, {"Eye of newt", "Eye of newt", 1, false}, {"Onion", "Onion", 1, false}, {"Rat's tail", "Rat's tail", 1, true}}},
  {id="q174", name="X Marks the Spot", page="X Marks the Spot", f2p=true, items={{"Spade", "Spade", 1, false}}},
  {id="q175", name="Zogre Flesh Eaters", page="Zogre Flesh Eaters", f2p=false, items={{"Knife", "Knife", 1, true}}},
}

-- reusable tools/equipment: show the largest single-quest amount, not the sum
local reusable = {
  ["Anti-dragon shield"] = true,
  ["Axe"] = true,
  ["Big fishing net"] = true,
  ["Bow"] = true,
  ["Bronze axe"] = true,
  ["Bronze med helm"] = true,
  ["Bucket"] = true,
  ["Bullseye lantern"] = true,
  ["Cat"] = true,
  ["Catspeak amulet"] = true,
  ["Chisel"] = true,
  ["Climbing boots"] = true,
  ["Commorb"] = true,
  ["Crossbow (weapon)"] = true,
  ["Crush weapons"] = true,
  ["Desert robe"] = true,
  ["Desert shirt"] = true,
  ["Diving apparatus"] = true,
  ["Dramen staff"] = true,
  ["Dusty key"] = true,
  ["Excalibur"] = true,
  ["Facemask"] = true,
  ["Fake beard"] = true,
  ["Fishbowl helmet"] = true,
  ["Fishing rod"] = true,
  ["Gas mask"] = true,
  ["Ghostspeak amulet"] = true,
  ["Glassblowing pipe"] = true,
  ["Gloves"] = true,
  ["Hammer"] = true,
  ["Holy symbol"] = true,
  ["Ice gloves"] = true,
  ["Insulated boots"] = true,
  ["Iron chainbody"] = true,
  ["Ivandis flail"] = true,
  ["Kharidian headpiece"] = true,
  ["Knife"] = true,
  ["Leather gloves"] = true,
  ["Light sources"] = true,
  ["Lobster pot"] = true,
  ["M'speak amulet"] = true,
  ["Machete"] = true,
  ["Machete (weapon)"] = true,
  ["Mirror shield"] = true,
  ["Mith grapple"] = true,
  ["Mourner gear"] = true,
  ["Needle"] = true,
  ["Ogre bellows"] = true,
  ["Ogre bow"] = true,
  ["Pestle and mortar"] = true,
  ["Pickaxe"] = true,
  ["Rake"] = true,
  ["Ring of Charos"] = true,
  ["Rod of Ivandis"] = true,
  ["Sapphire lantern"] = true,
  ["Saw"] = true,
  ["Seal of passage"] = true,
  ["Secateurs"] = true,
  ["Seed dibber"] = true,
  ["Shears"] = true,
  ["Silverlight"] = true,
  ["Slash weapons"] = true,
  ["Small fishing net"] = true,
  ["Snake charm"] = true,
  ["Spade"] = true,
  ["Specimen brush"] = true,
  ["Spiked boots"] = true,
  ["Stab weapons"] = true,
  ["Tinderbox"] = true,
}

function p.remaining(frame)
    local args = frame:getParent().args
    local f2pOnly = (args.f2p == "yes")
    local lang = mw.getContentLanguage()
    local remaining = {}
    local order = {}
    local incomplete, completed = 0, 0
    for _, q in ipairs(quests) do
        if not f2pOnly or q.f2p then
            if args[q.id] == "yes" then
                completed = completed + 1
            else
                incomplete = incomplete + 1
                for _, it in ipairs(q.items) do
                    local page, disp, qty, during = it[1], it[2], it[3], it[4]
                    local e = remaining[page]
                    if not e then
                        e = {qty = 0, max = 0, disp = disp, quests = {}}
                        remaining[page] = e
                        table.insert(order, page)
                    end
                    e.qty = e.qty + qty
                    if qty > e.max then e.max = qty end
                    table.insert(e.quests, {q.page, q.name, qty, during})
                end
            end
        end
    end
    if incomplete == 0 then
        return "'''Nothing left!''' Every quest that needs items is ticked as complete."
    end
    table.sort(order, function(a, b) return a:lower() < b:lower() end)
    local out = {}
    table.insert(out, string.format(
        "'''%s''' distinct item%s still needed for '''%s''' remaining quest%s (%s ticked as complete).",
        lang:formatNum(#order), #order == 1 and "" or "s",
        lang:formatNum(incomplete), incomplete == 1 and "" or "s",
        lang:formatNum(completed)))
    table.insert(out, '{| class="wikitable sortable align-left-1 align-left-3"')
    table.insert(out, "! Item")
    table.insert(out, '! style="width:7em" | Still needed')
    table.insert(out, "! Needed for")
    for _, page in ipairs(order) do
        local e = remaining[page]
        local links = {}
        for _, qq in ipairs(e.quests) do
            local ann = {}
            if qq[3] > 1 then table.insert(ann, lang:formatNum(qq[3])) end
            if qq[4] then table.insert(ann, "acquired during quest") end
            local link = qq[1] == qq[2] and ("[[" .. qq[1] .. "]]")
                or ("[[" .. qq[1] .. "|" .. qq[2] .. "]]")
            if #ann > 0 then link = link .. " (" .. table.concat(ann, ", ") .. ")" end
            table.insert(links, link)
        end
        table.insert(out, "|-")
        local itemlink = page == e.disp and ("[[" .. page .. "]]")
            or ("[[" .. page .. "|" .. e.disp .. "]]")
        if reusable[page] then
            itemlink = itemlink .. " ''(reusable)''"
        end
        table.insert(out, "| " .. itemlink)
        table.insert(out, "| " .. lang:formatNum(reusable[page] and e.max or e.qty))
        table.insert(out, "| " .. table.concat(links, ", "))
    end
    table.insert(out, "|}")
    return table.concat(out, "\n")
end

return p