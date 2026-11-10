--<nowiki>
--[[ Format:
	['Compenent name'] = {
		short = 'name', -- Short name used in Module:Disassemble/ data modules
		method = 'min', -- Method to calculate price (min or avg). Defaults to min
		reason = 'Some reasoning', -- Optional reasoning on why a given method and/or items is used
		special = true, -- Whether the comp is special or not
		iems = {'Item name', 'Item name 2'} -- List of the items to generate price from
	}
--]]
return {
	['Junk'] = {
		short = 'junk',
		method = 'min',
		reason = 'Almost any item can provide junk.',
		special = false,
		items = {'Weird gloop'}
		-- Has an override to use 1
	},
	['Base parts'] = {
		short = 'base',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Broad-tipped bolts', 'Eternal magic wand (inert)', 'Royal bolts', 'Blue dragonhide shield', 'Green dragonhide shield', 'Red dragonhide shield', 'Black dragonhide shield', 'Tiny bladed bronze salvage', 'Small bladed bronze salvage', 'Medium bladed bronze salvage', 'Large bladed bronze salvage', 'Huge bladed bronze salvage', 'Tiny bladed iron salvage', 'Small bladed iron salvage', 'Medium bladed iron salvage', 'Large bladed iron salvage', 'Huge bladed iron salvage', 'Tiny bladed steel salvage', 'Small bladed steel salvage', 'Medium bladed steel salvage', 'Large bladed steel salvage', 'Huge bladed steel salvage', 'Tiny bladed mithril salvage', 'Small bladed mithril salvage', 'Medium bladed mithril salvage', 'Large bladed mithril salvage', 'Huge bladed mithril salvage', 'Tiny bladed adamant salvage', 'Small bladed adamant salvage', 'Medium bladed adamant salvage', 'Large bladed adamant salvage', 'Huge bladed adamant salvage', 'Tiny bladed rune salvage', 'Small bladed rune salvage', 'Medium bladed rune salvage', 'Large bladed rune salvage', 'Huge bladed rune salvage', 'Tiny bladed orikalkum salvage', 'Small bladed orikalkum salvage', 'Medium bladed orikalkum salvage', 'Large bladed orikalkum salvage', 'Huge bladed orikalkum salvage', 'Tiny bladed necronium salvage'}
	},
	['Blade parts'] = {
		short = 'blade',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Steel dart', 'Off-hand steel dart', 'Mithril dart', 'Off-hand mithril dart', 'Adamant dart', 'Off-hand adamant dart', 'Rune dart', 'Off-hand rune dart', 'Dragon dart', 'Off-hand dragon dart', 'Tiny bladed bronze salvage', 'Small bladed bronze salvage', 'Medium bladed bronze salvage', 'Large bladed bronze salvage', 'Huge bladed bronze salvage', 'Tiny bladed iron salvage', 'Small bladed iron salvage', 'Medium bladed iron salvage', 'Large bladed iron salvage', 'Huge bladed iron salvage', 'Tiny bladed steel salvage', 'Small bladed steel salvage', 'Medium bladed steel salvage', 'Large bladed steel salvage', 'Huge bladed steel salvage', 'Tiny bladed mithril salvage', 'Small bladed mithril salvage', 'Medium bladed mithril salvage', 'Large bladed mithril salvage', 'Huge bladed mithril salvage', 'Tiny bladed adamant salvage', 'Small bladed adamant salvage', 'Medium bladed adamant salvage', 'Large bladed adamant salvage', 'Huge bladed adamant salvage', 'Tiny bladed rune salvage', 'Small bladed rune salvage', 'Medium bladed rune salvage', 'Large bladed rune salvage', 'Huge bladed rune salvage', 'Tiny bladed orikalkum salvage', 'Small bladed orikalkum salvage', 'Medium bladed orikalkum salvage', 'Large bladed orikalkum salvage', 'Huge bladed orikalkum salvage', 'Tiny bladed necronium salvage'}
	},
	['Clear parts'] = {
		short = 'clear',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Unpowered orb', 'Air orb', 'Water orb', 'Earth orb', 'Fire orb', 'Sapphire', 'Emerald', 'Ruby', 'Diamond', 'Dragonstone', 'Crystal flask', 'Powerburst vial', 'Vial'}
	},
	['Connector parts'] = {
		short = 'connector',
		method = 'min',
		special = false,
		threshold = 500,
		items = { 'Black salamander', 'Ring of slaying', 'Wooden stock', 'Oak stock', 'Willow stock', 'Teak stock', 'Maple stock', 'Mahogany stock', 'Yew stock', 'Magic stock', 'Eternal magic stock', 'Tiny spiky bronze salvage', 'Small spiky bronze salvage', 'Medium spiky bronze salvage', 'Large spiky bronze salvage', 'Huge spiky bronze salvage', 'Tiny spiky iron salvage', 'Small spiky iron salvage', 'Medium spiky iron salvage', 'Large spiky iron salvage', 'Huge spiky iron salvage', 'Tiny spiky steel salvage', 'Small spiky steel salvage', 'Medium spiky steel salvage', 'Large spiky steel salvage', 'Huge spiky steel salvage', 'Tiny spiky mithril salvage', 'Small spiky mithril salvage', 'Medium spiky mithril salvage', 'Large spiky mithril salvage', 'Huge spiky mithril salvage', 'Tiny spiky adamant salvage', 'Small spiky adamant salvage', 'Medium spiky adamant salvage', 'Large spiky adamant salvage', 'Huge spiky adamant salvage', 'Tiny spiky rune salvage', 'Small spiky rune salvage', 'Medium spiky rune salvage', 'Large spiky rune salvage', 'Huge spiky rune salvage', 'Tiny spiky orikalkum salvage', 'Small spiky orikalkum salvage', 'Medium spiky orikalkum salvage', 'Large spiky orikalkum salvage', 'Huge spiky orikalkum salvage', 'Huge spiky necronium salvage'}
	},
	['Cover parts'] = {
		short = 'cover',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Black wizard hat', 'Black wizard robe skirt', 'Black wizard robe top', 'Black dragonhide body', 'Black dragonhide boots', 'Black dragonhide chaps', 'Black dragonhide coif', 'Black dragonhide vambraces', 'Blue dragonhide body', 'Blue dragonhide boots', 'Blue dragonhide chaps', 'Blue dragonhide coif', 'Blue dragonhide vambraces', 'Carapace boots', 'Carapace gloves', 'Carapace helm', 'Carapace legs', 'Carapace torso', 'Green dragonhide body', 'Green dragonhide boots', 'Green dragonhide chaps', 'Green dragonhide coif', 'Green dragonhide vambraces', 'Leather shield', 'Hard leather shield', 'Tiny plated bronze salvage', 'Small plated bronze salvage', 'Medium plated bronze salvage', 'Large plated bronze salvage', 'Huge plated bronze salvage', 'Tiny plated iron salvage', 'Small plated iron salvage', 'Medium plated iron salvage', 'Large plated iron salvage', 'Huge plated iron salvage', 'Tiny plated steel salvage', 'Small plated steel salvage', 'Medium plated steel salvage', 'Large plated steel salvage', 'Huge plated steel salvage', 'Tiny plated mithril salvage', 'Small plated mithril salvage', 'Medium plated mithril salvage', 'Large plated mithril salvage', 'Huge plated mithril salvage', 'Tiny plated adamant salvage', 'Small plated adamant salvage', 'Medium plated adamant salvage', 'Large plated adamant salvage', 'Huge plated adamant salvage', 'Tiny plated rune salvage', 'Small plated rune salvage', 'Medium plated rune salvage', 'Large plated rune salvage', 'Huge plated rune salvage', 'Tiny plated orikalkum salvage', 'Small plated orikalkum salvage', 'Medium plated orikalkum salvage', 'Large plated orikalkum salvage', 'Huge plated orikalkum salvage', 'Small plated necronium salvage', 'Medium plated necronium salvage'}
	},
	['Crafted parts'] = {
		short = 'crafted',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Carved teak magic wardrobe (flatpack)', 'Mahogany table (flatpack)', 'Teak armchair (flatpack)','Mahogany armchair (flatpack)', 'Mahogany bench (flatpack)', 'Antipoison (3)', 'Antipoison (4)', 'Antipoison++ (3)', 'Antipoison++ (4)', 'Black salamander', 'Green salamander', 'Red salamander', 'Carbon black', 'Felt', 'Powerburst of masterstroke (4)', 'Powerburst of opportunity (4)', 'Powerburst of vitality (4)'}
	},
	['Crystal parts'] = {
		short = 'crystal',
		method = 'min',
		special = true,
		-- Do no put 'crystal teleport seed' or 'crystal chaos' as the 'prices' are not reliable, the price of harmonic dust is based on opportunity cost
		items = {'Crystal bow', 'Crystal chakram', 'Crystal chisel', 'Crystal dagger', 'Crystal deflector', 'Crystal orb', 'Crystal shield', 'Crystal staff', 'Crystal wand', 'Crystal ward', 'Off-hand crystal chakram', 'Off-hand crystal dagger', 'Crystal tinderbox', 'Augmented crystal tinderbox', 'Crystal hammer', 'Augmented crystal hammer', 'Crystal knife', 'Crystal chisel', 'Crystal saw (Prifddinas)', 'Crystal chime (Prifddinas)', 'Crystal fishing rod', 'Augmented crystal fishing rod'}
	},
	['Delicate parts'] = {
		short = 'delicate',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Unpowered orb', 'Air orb', 'Water orb', 'Earth orb', 'Fire orb', 'Sapphire', 'Emerald', 'Ruby', 'Diamond', 'Dragonstone', 'Molten glass' }
	},
	['Deflecting parts'] = {
		short = 'deflecting',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Black wizard hat', 'Black wizard robe skirt', 'Black wizard robe top', 'Leather shield', 'Hard leather shield', 'Tiny plated bronze salvage', 'Small plated bronze salvage', 'Medium plated bronze salvage', 'Large plated bronze salvage', 'Huge plated bronze salvage', 'Tiny plated iron salvage', 'Small plated iron salvage', 'Medium plated iron salvage', 'Large plated iron salvage', 'Huge plated iron salvage', 'Tiny plated steel salvage', 'Small plated steel salvage', 'Medium plated steel salvage', 'Large plated steel salvage', 'Huge plated steel salvage', 'Tiny plated mithril salvage', 'Small plated mithril salvage', 'Medium plated mithril salvage', 'Large plated mithril salvage', 'Huge plated mithril salvage', 'Tiny plated adamant salvage', 'Small plated adamant salvage', 'Medium plated adamant salvage', 'Large plated adamant salvage', 'Huge plated adamant salvage', 'Tiny plated rune salvage', 'Small plated rune salvage', 'Medium plated rune salvage', 'Large plated rune salvage', 'Huge plated rune salvage', 'Tiny plated orikalkum salvage', 'Small plated orikalkum salvage', 'Medium plated orikalkum salvage', 'Large plated orikalkum salvage', 'Huge plated orikalkum salvage', 'Small plated necronium salvage', 'Medium plated necronium salvage'}
	},
	['Flexible parts'] = {
		short = 'flexible',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Maple longbow', 'Maple longbow (unstrung)', 'Maple shortbow', 'Maple shortbow (unstrung)', 'Oak longbow', 'Oak longbow (unstrung)', 'Willow longbow', 'Willow longbow (unstrung)', 'Yew longbow', 'Yew longbow (unstrung)', 'Yew shortbow', 'Yew shortbow (unstrung)', 'Magic longbow', 'Magic longbow (unstrung)', 'Magic shortbow', 'Magic shortbow (unstrung)', 'Elder longbow', 'Elder longbow (unstrung)', 'Elder shortbow', 'Elder shortbow (unstrung)'}
	},
	['Head parts'] = {
		short = 'head',
		method = 'min',
		special = false,
		threshold = 500,
		items = { 'Iron arrow', 'Steel arrow', 'Mithril arrow', 'Adamant arrow', 'Dark arrow', 'Wild arrow', 'Stalker arrow', 'Saradomin arrows', 'Zamorak arrows', 'Guthix arrows', 'Iron bolts', 'Steel bolts (unf)', 'Steel bolts', 'Mithril bolts', 'Sapphire bolt tips', 'Sapphire bolts', 'Sapphire bolts (e)', 'Ruby bolt tips', 'Ruby bolts', 'Ruby bolts (e)', 'Opal bolt tips', 'Opal bolts', 'Opal bolts (e)', 'Topaz bolt tips', 'Topaz bolts', 'Topaz bolts (e)', 'Royal bolts', 'Broad-tipped bolts', 'Bolt rack', 'Tiny blunt bronze salvage', 'Small blunt bronze salvage', 'Medium blunt bronze salvage', 'Large blunt bronze salvage', 'Huge blunt bronze salvage', 'Tiny blunt iron salvage', 'Small blunt iron salvage', 'Medium blunt iron salvage', 'Large blunt iron salvage', 'Huge blunt iron salvage', 'Tiny blunt steel salvage', 'Small blunt steel salvage', 'Medium blunt steel salvage', 'Large blunt steel salvage', 'Huge blunt steel salvage', 'Tiny blunt mithril salvage', 'Small blunt mithril salvage', 'Medium blunt mithril salvage', 'Large blunt mithril salvage', 'Huge blunt mithril salvage', 'Tiny blunt adamant salvage', 'Small blunt adamant salvage', 'Medium blunt adamant salvage', 'Large blunt adamant salvage', 'Huge blunt adamant salvage', 'Tiny blunt rune salvage', 'Small blunt rune salvage', 'Medium blunt rune salvage', 'Large blunt rune salvage', 'Huge blunt rune salvage', 'Tiny blunt orikalkum salvage', 'Small blunt orikalkum salvage', 'Medium blunt orikalkum salvage', 'Large blunt orikalkum salvage', 'Huge blunt orikalkum salvage', 'Large blunt necronium salvage' }
	},
	['Magic parts'] = {
		short = 'magic',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Earth rune', 'Water rune', 'Fire rune', 'Body rune', 'Mind rune', 'Fire talisman', 'Earth talisman', 'Death talisman', 'Law talisman', 'Battlestaff', 'Magic staff', 'Staff',  'Portent of degradation II', 'Portent of restoration VIII', 'Portent of restoration IX', 'Wizard robe skirt', 'Wizard robe top', 'Black wizard robe skirt', 'Black wizard robe top'}
	},
	['Metallic parts'] = {
		short = 'metallic',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Tiny bladed bronze salvage', 'Small bladed bronze salvage', 'Medium bladed bronze salvage', 'Large bladed bronze salvage', 'Huge bladed bronze salvage', 'Tiny bladed iron salvage', 'Small bladed iron salvage', 'Medium bladed iron salvage', 'Large bladed iron salvage', 'Huge bladed iron salvage', 'Tiny bladed steel salvage', 'Small bladed steel salvage', 'Medium bladed steel salvage', 'Large bladed steel salvage', 'Huge bladed steel salvage', 'Tiny bladed mithril salvage', 'Small bladed mithril salvage', 'Medium bladed mithril salvage', 'Large bladed mithril salvage', 'Huge bladed mithril salvage', 'Tiny bladed adamant salvage', 'Small bladed adamant salvage', 'Medium bladed adamant salvage', 'Large bladed adamant salvage', 'Huge bladed adamant salvage', 'Tiny bladed rune salvage', 'Small bladed rune salvage', 'Medium bladed rune salvage', 'Large bladed rune salvage', 'Huge bladed rune salvage', 'Tiny bladed orikalkum salvage', 'Small bladed orikalkum salvage', 'Medium bladed orikalkum salvage', 'Large bladed orikalkum salvage', 'Huge bladed orikalkum salvage', 'Tiny bladed necronium salvage'}
	},
	['Organic parts'] = {
		short = 'organic',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Eye of newt', 'Jug of wine', 'Tuna', 'Desert sole', 'Beltfish', 'Salmon', 'Accursed ashes'}
	},
	['Padded parts'] = {
		short = 'padded',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Hard leather body', 'Hard leather boots', 'Hard leather chaps', 'Hard leather cowl', 'Hard leather gloves', 'Leather body', 'Leather chaps', 'Leather cowl', 'Green dragonhide body', 'Green dragonhide chaps', 'Green dragonhide boots', 'Green dragonhide vambraces', 'Blue dragonhide body', 'Blue dragonhide chaps', 'Blue dragonhide boots', 'Blue dragonhide vambraces', 'Red dragonhide body', 'Red dragonhide chaps', 'Red dragonhide boots', 'Red dragonhide vambraces', 'Royal dragonhide body', 'Royal dragonhide chaps', 'Royal dragonhide boots', 'Royal dragonhide vambraces', 'Staff', 'Battlestaff'}
	},
	['Plated parts'] = {
		short = 'plated',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Tiny plated bronze salvage', 'Small plated bronze salvage', 'Medium plated bronze salvage', 'Large plated bronze salvage', 'Huge plated bronze salvage', 'Tiny plated iron salvage', 'Small plated iron salvage', 'Medium plated iron salvage', 'Large plated iron salvage', 'Huge plated iron salvage', 'Tiny plated steel salvage', 'Small plated steel salvage', 'Medium plated steel salvage', 'Large plated steel salvage', 'Huge plated steel salvage', 'Tiny plated mithril salvage', 'Small plated mithril salvage', 'Medium plated mithril salvage', 'Large plated mithril salvage', 'Huge plated mithril salvage', 'Tiny plated adamant salvage', 'Small plated adamant salvage', 'Medium plated adamant salvage', 'Large plated adamant salvage', 'Huge plated adamant salvage', 'Tiny plated rune salvage', 'Small plated rune salvage', 'Medium plated rune salvage', 'Large plated rune salvage', 'Huge plated rune salvage', 'Tiny plated orikalkum salvage', 'Small plated orikalkum salvage', 'Medium plated orikalkum salvage', 'Large plated orikalkum salvage', 'Huge plated orikalkum salvage', 'Small plated necronium salvage', 'Medium plated necronium salvage'}
	},
	['Simple parts'] = {
		short = 'simple',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Steel dart', 'Off-hand steel dart', 'Mithril dart', 'Off-hand mithril dart', 'Adamant dart', 'Off-hand adamant dart', 'Rune dart', 'Off-hand rune dart', 'Dragon dart', 'Off-hand dragon dart', 'Acadia logs', 'Willow logs', 'Teak logs', 'Maple logs', 'Mahogany logs', 'Yew logs', 'Magic logs', 'Corrupted magic logs', 'Eternal magic logs', 'Gold bar', 'Harralander tar', 'Yak-hide'}
	},
	['Smooth parts'] = {
		short = 'smooth',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Unpowered orb', 'Air orb', 'Water orb', 'Earth orb', 'Fire orb', 'Sapphire', 'Emerald', 'Ruby', 'Diamond', 'Dragonstone', 'Molten glass', 'Ring of slaying' }
	},
	['Spiked parts'] = {
		short = 'spiked',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Steel dart', 'Off-hand steel dart', 'Mithril dart', 'Off-hand mithril dart', 'Adamant dart', 'Off-hand adamant dart', 'Rune dart', 'Off-hand rune dart', 'Dragon dart', 'Off-hand dragon dart', 'Royal bolts', 'Wooden stock', 'Oak stock', 'Willow stock', 'Teak stock', 'Maple stock', 'Mahogany stock', 'Yew stock', 'Magic stock', 'Eternal magic stock', 'Tiny spiky bronze salvage', 'Small spiky bronze salvage', 'Medium spiky bronze salvage', 'Large spiky bronze salvage', 'Huge spiky bronze salvage', 'Tiny spiky iron salvage', 'Small spiky iron salvage', 'Medium spiky iron salvage', 'Large spiky iron salvage', 'Huge spiky iron salvage', 'Tiny spiky steel salvage', 'Small spiky steel salvage', 'Medium spiky steel salvage', 'Large spiky steel salvage', 'Huge spiky steel salvage', 'Tiny spiky mithril salvage', 'Small spiky mithril salvage', 'Medium spiky mithril salvage', 'Large spiky mithril salvage', 'Huge spiky mithril salvage', 'Tiny spiky adamant salvage', 'Small spiky adamant salvage', 'Medium spiky adamant salvage', 'Large spiky adamant salvage', 'Huge spiky adamant salvage', 'Tiny spiky rune salvage', 'Small spiky rune salvage', 'Medium spiky rune salvage', 'Large spiky rune salvage', 'Huge spiky rune salvage', 'Tiny spiky orikalkum salvage', 'Small spiky orikalkum salvage', 'Medium spiky orikalkum salvage', 'Large spiky orikalkum salvage', 'Huge spiky orikalkum salvage', 'Huge spiky necronium salvage'}
	},
	['Spiritual parts'] = {
		short = 'spiritual',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Adamant Minotaur scroll (Adamant Bull Rush)', 'Arctic Bear scroll (Arctic Blast)', 'Barker Toad scroll (Toad Bark)', 'Beaver scroll (Multichop)', 'Bull Ant scroll (Unburden)', 'Bunyip scroll (Swallow Whole)', 'Compost Mound scroll (Generate Compost)', 'Dreadfowl scroll (Dreadfowl Strike)', 'Elemental Titan scroll (Titan\'s Constitution)', 'Forge Regent scroll (Inferno)', 'Fruit Bat scroll (Fruitfall)', 'Geyser Titan scroll (Boil)', 'Granite Lobster scroll (Crushing Claw)', 'Hydra scroll (Regrowth)', 'Ibis scroll (Fish Rain)', 'Macaw scroll (Herbcall)', 'Magpie scroll (Thieving Fingers)', 'Pack Yak scroll (Winter Storage)', 'Rune Minotaur scroll (Rune Bull Rush)', 'Spirit Dagannoth scroll (Spike Shot)', 'Spirit Terrorbird scroll (Tireless Run)', 'Smoke Devil scroll (Dust Cloud)', 'Unicorn Stallion scroll (Healing Aura)', 'War Tortoise scroll (Testudo)', 'Adamant minotaur pouch', 'Arctic bear pouch', 'Barker toad pouch', 'Beaver pouch', 'Bull ant pouch', 'Bunyip pouch', 'Compost mound pouch', 'Dreadfowl pouch', 'Forge regent pouch', 'Fruit bat pouch', 'Geyser titan pouch', 'Granite lobster pouch', 'Hydra pouch', 'Ibis pouch', 'Macaw pouch', 'Magpie pouch', 'Pack yak pouch', 'Rune minotaur pouch', 'Spirit dagannoth pouch', 'Spirit terrorbird pouch', 'Smoke devil pouch', 'Unicorn stallion pouch', 'War tortoise pouch', 'Mark of the Kyzaj', 'Eye of Dagon', 'Wings of War'}
	},
	['Stave parts'] = {
		short = 'stave',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Battlestaff', 'Elder longbow', 'Elder shortbow', 'Magic longbow', 'Magic shortbow', 'Magic staff', 'Maple longbow', 'Maple shortbow', 'Oak longbow', 'Oak shortbow', 'Staff', 'Willow longbow', 'Willow shortbow', 'Yew longbow', 'Yew shortbow'}
	},
	['Tensile parts'] = {
		short = 'tensile',
		method = 'min',
		special = false,
		threshold = 500,
		items = {'Black salamander', 'Elder longbow', 'Elder shortbow', 'Magic longbow', 'Magic shortbow', 'Maple longbow', 'Maple shortbow', 'Oak longbow', 'Oak shortbow', 'Willow longbow', 'Willow shortbow', 'Yew longbow', 'Yew shortbow'}
	},
	['Clockwork components'] = {
		short = 'clockwork',
		method = 'min',
		special = true,
		items = {'Dwarf multicannon'}
	},
	['Dextrous components'] = {
		short = 'dextrous',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Black salamander', 'Elder shortbow', 'Magic shortbow', 'Maple shortbow', 'Oak shortbow', 'Willow shortbow', 'Yew shortbow'}
	},
	['Direct components'] = {
		short = 'direct',
		method = 'min',
		reason = 'The minimum price/material for several items is used due to the low GE trade volumes of the sources.',
		special = false,
		threshold = 100,
		items = {'Noose wand', 'Black spear', 'Dragon spear', 'Iron mattock', 'Mithril mattock', 'Mithril spear', 'Rune spear', 'Steel mattock', 'Steel spear', 'Bronze pickaxe', 'Iron pickaxe', 'Steel pickaxe', 'Steel pickaxe + 1', 'Mithril pickaxe', 'Mithril pickaxe + 2', 'Adamant pickaxe', 'Adamant pickaxe + 2', 'Rune pickaxe', 'Rune pickaxe + 3', 'Orikalkum pickaxe', 'Orikalkum pickaxe + 3', 'Necronium pickaxe', 'Necronium pickaxe + 4', 'Bane pickaxe', 'Bane pickaxe + 4', 'Elder rune pickaxe', 'Elder rune pickaxe + 5', 'Tiny blunt bronze salvage', 'Small blunt bronze salvage', 'Medium blunt bronze salvage', 'Large blunt bronze salvage', 'Huge blunt bronze salvage', 'Tiny blunt iron salvage', 'Small blunt iron salvage', 'Medium blunt iron salvage', 'Large blunt iron salvage', 'Huge blunt iron salvage', 'Tiny blunt steel salvage', 'Small blunt steel salvage', 'Medium blunt steel salvage', 'Large blunt steel salvage', 'Huge blunt steel salvage', 'Tiny blunt mithril salvage', 'Small blunt mithril salvage', 'Medium blunt mithril salvage', 'Large blunt mithril salvage', 'Huge blunt mithril salvage', 'Tiny blunt adamant salvage', 'Small blunt adamant salvage', 'Medium blunt adamant salvage', 'Large blunt adamant salvage', 'Huge blunt adamant salvage', 'Tiny blunt rune salvage', 'Small blunt rune salvage', 'Medium blunt rune salvage', 'Large blunt rune salvage', 'Huge blunt rune salvage', 'Tiny blunt orikalkum salvage', 'Small blunt orikalkum salvage', 'Medium blunt orikalkum salvage', 'Large blunt orikalkum salvage', 'Huge blunt orikalkum salvage', 'Large blunt necronium salvage'}
	},
	['Enhancing components'] = {
		short = 'enhancing',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Unpowered orb', 'Air orb', 'Water orb', 'Earth orb', 'Fire orb'}
	},
	['Ethereal components'] = {
		short = 'ethereal',
		method = 'min',
		reason = 'The minimum price/material for several items is used due to the low GE trade volume and buy limit of the sources.',
		special = false,
		threshold = 100,
		items = {'Portent of degradation I', 'Portent of degradation II', 'Portent of degradation III', 'Portent of restoration I', 'Portent of restoration II', 'Portent of restoration III', 'Portent of restoration IV', 'Portent of restoration V', 'Portent of restoration VI', 'Portent of restoration VII', 'Portent of restoration VIII', 'Portent of restoration IX', 'Portent of restoration X', 'Sign of item protection', 'Sign of life', 'Sign of death', 'Sign of respite I', 'Sign of respite II', 'Sign of respite III', 'Accursed acadia incense sticks', 'Accursed maple incense sticks', 'Avantoe incense sticks', 'Bloodweed incense sticks', 'Cadantine incense sticks', 'Dwarf weed incense sticks', 'Fellstalk incense sticks', 'Harralander incense sticks', 'Impious oak incense sticks', 'Impious willow incense sticks', 'Infernal magic incense sticks', 'Infernal yew incense sticks', 'Irit incense sticks', 'Kwuarm incense sticks', 'Lantadyme incense sticks', 'Marrentill incense sticks', 'Ranarr incense sticks', 'Snapdragon incense sticks', 'Spirit weed incense sticks', 'Tarromin incense sticks', 'Toadflax incense sticks', 'Torstol incense sticks', 'Wergali incense sticks'}
	},
	['Evasive components'] = {
		short = 'evasive',
		method = 'min',
		threshold = 100,
		special = false,
		items = {'Carapace boots', 'Carapace gloves', 'Hard leather body', 'Hard leather boots', 'Hard leather chaps', 'Hard leather cowl', 'Hard leather gloves', 'Leather body', 'Green dragonhide body', 'Green dragonhide chaps', 'Green dragonhide boots', 'Green dragonhide vambraces', 'Blue dragonhide body', 'Blue dragonhide chaps', 'Blue dragonhide boots', 'Blue dragonhide vambraces', 'Red dragonhide body', 'Red dragonhide chaps', 'Red dragonhide boots', 'Red dragonhide vambraces', 'Royal dragonhide body', 'Royal dragonhide chaps', 'Royal dragonhide boots', 'Royal dragonhide vambraces'}
	},
	['Faceted components'] = {
		short = 'faceted',
		method = 'min',
		special = false,
		items = {'Empty light orb', 'Sapphire', 'Emerald', 'Ruby', 'Diamond', 'Dragonstone'}
	},
	['Healthy components'] = {
		short = 'healthy',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Armadylean yellow', 'Carbon black', 'Compass rose', 'Dragon metal', 'Felt', 'Antipoison (3)', 'Antipoison (4)', 'Antipoison++ (3)', 'Antipoison++ (4)', 'Powerburst of feats (4)', 'Powerburst of opportunity (4)', 'Powerburst of masterstroke (4)', 'Super invention (3)', 'Super invention (4)', 'Zamorak brew (3)', 'Zamorak brew (4)', 'Super restore (3)', 'Super restore (4)', 'Combat potion (3)', 'Combat potion (4)', 'Beltfish', 'Swordfish', 'Shark', 'Raw ghostly sole'}
	},
	['Heavy components'] = {
		short = 'heavy',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Bronze mace', 'Bronze mattock', 'Bronze off hand mace', 'Bronze off hand warhammer', 'Bronze warhammer', 'Iron mace', 'Iron mattock', 'Iron off hand mace', 'Iron off hand warhammer', 'Off-hand black mace', 'Off-hand black warhammer', 'Mithril mace', 'Mithril mattock', 'Mithril off hand mace', 'Mithril off hand warhammer', 'Mithril warhammer', 'Adamant mace', 'Adamant mattock', 'Adamant off hand mace', 'Adamant off hand warhammer', 'Adamant warhammer', 'Butterfly net', 'Tiny plated bronze salvage', 'Small plated bronze salvage', 'Medium plated bronze salvage', 'Large plated bronze salvage', 'Huge plated bronze salvage', 'Tiny plated iron salvage', 'Small plated iron salvage', 'Medium plated iron salvage', 'Large plated iron salvage', 'Huge plated iron salvage', 'Tiny plated steel salvage', 'Small plated steel salvage', 'Medium plated steel salvage', 'Large plated steel salvage', 'Huge plated steel salvage', 'Tiny plated mithril salvage', 'Small plated mithril salvage', 'Medium plated mithril salvage', 'Large plated mithril salvage', 'Huge plated mithril salvage', 'Tiny plated adamant salvage', 'Small plated adamant salvage', 'Medium plated adamant salvage', 'Large plated adamant salvage', 'Huge plated adamant salvage', 'Tiny plated rune salvage', 'Small plated rune salvage', 'Medium plated rune salvage', 'Large plated rune salvage', 'Huge plated rune salvage', 'Tiny plated orikalkum salvage', 'Small plated orikalkum salvage', 'Medium plated orikalkum salvage', 'Large plated orikalkum salvage', 'Huge plated orikalkum salvage', 'Small plated necronium salvage', 'Medium plated necronium salvage' }
	},
	['Imbued components'] = {
		short = 'imbued',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Battlestaff', 'Magic staff', 'Staff', 'Staff of air', 'Staff of earth', 'Staff of fire', 'Staff of water'}
	},
	['Light components'] = {
		short = 'light',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Sapphire', 'Emerald', 'Ruby', 'Diamond', 'Dragonstone'}
	},
	['Living components'] = {
		short = 'living',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Avocado seed', 'Barberry seed', 'Mango seed', 'Morchella mushroom spore', 'Stinkshroom spore', 'Prickly pear seed', 'Sunchoke seed', 'Fly trap seed', 'Reed seed', 'Magic logs', 'Jug of wine', 'Desert sole', 'Tuna', 'Beltfish', 'Lobster', 'Swordfish'}
	},
	['Offcut components'] = {
		short = 'offcut',
		method = 'traded-avg',
		special = true,
		threshold = 100,
		items = {'4-poster (flatpack)', 'Asgarnian ale (barrel) (flatpack)', 'Beer barrel (flatpack)', 'Carved oak bench (flatpack)', 'Carved oak magic wardrobe (flatpack)', 'Carved oak table (flatpack)', 'Carved teak bench (flatpack)', 'Carved teak magic wardrobe (flatpack)', 'Carved teak table (flatpack)', 'Chef\'s delight (barrel) (flatpack)', 'Cider barrel (flatpack)', 'Crude wooden chair (flatpack)', 'Dragon bitter (barrel) (flatpack)', 'Fancy teak dresser (flatpack)', 'Gilded 4-poster (flatpack)', 'Gilded bench (flatpack)', 'Gilded cape rack (flatpack)', 'Gilded clock (flatpack)', 'Gilded dresser (flatpack)', 'Gilded magic wardrobe (flatpack)', 'Gilded wardrobe (flatpack)', 'Greenman\'s ale (barrel) (flatpack)', 'Large oak bed (flatpack)', 'Large teak bed (flatpack)', 'Magical cape rack (flatpack)', 'Mahogany armchair (flatpack)', 'Mahogany armour case (flatpack)', 'Mahogany bench (flatpack)', 'Mahogany bookcase (flatpack)', 'Mahogany cape rack (flatpack)', 'Mahogany dresser (flatpack)', 'Mahogany fancy dress box (flatpack)', 'Mahogany magic wardrobe (flatpack)', 'Mahogany table (flatpack)', 'Mahogany toy box (flatpack)', 'Mahogany treasure chest (flatpack)', 'Mahogany wardrobe (flatpack)', 'Marble cape rack (flatpack)', 'Marble magic wardrobe (flatpack)', 'Oak armchair (flatpack)', 'Oak armour case (flatpack)', 'Oak bed (flatpack)', 'Oak bench (flatpack)', 'Oak bookcase (flatpack)', 'Oak cape rack (flatpack)', 'Oak chair (flatpack)', 'Oak clock (flatpack)', 'Oak dining table (flatpack)', 'Oak drawers (flatpack)', 'Oak dresser (flatpack)', 'Oak fancy dress box (flatpack)', 'Oak kitchen table (flatpack)', 'Oak magic wardrobe (flatpack)', 'Oak shaving stand (flatpack)', 'Oak toy box (flatpack)', 'Oak treasure chest (flatpack)', 'Oak wardrobe (flatpack)', 'Opulent table (flatpack)', 'Rocking chair (flatpack)', 'Shaving stand (flatpack)', 'Shoe box (flatpack)', 'Teak armchair (flatpack)', 'Teak armour case (flatpack)', 'Teak bed (flatpack)', 'Teak cape rack (flatpack)', 'Teak clock (flatpack)', 'Teak dining bench (flatpack)', 'Teak drawers (flatpack)', 'Teak dresser (flatpack)', 'Teak fancy dress box (flatpack)', 'Teak kitchen table (flatpack)', 'Teak magic wardrobe (flatpack)', 'Teak table (flatpack)', 'Teak toy box (flatpack)', 'Teak treasure chest (flatpack)', 'Teak wardrobe (flatpack)', 'Wood dining table (flatpack)', 'Wood kitchen table (flatpack)', 'Wooden bed (flatpack)', 'Wooden bench (flatpack)', 'Wooden bookcase (flatpack)', 'Wooden chair (flatpack)'}
	},
	['Pious components'] = {
		short = 'pious',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Bones', 'Big bones', 'Dragonkin bones', 'Dragon bones', 'Baby dragon bones', 'Fossilised bone', 'Tortured soul', 'Accursed ashes', 'Infernal ashes'}
	},
	['Powerful components'] = {
		short = 'powerful',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Battlestaff', 'Body rune', 'Earth rune', 'Body tiara', 'Earth tiara', 'Fire tiara', 'Nature tiara', 'Mind tiara', 'Magic staff', 'Staff', 'Wizard hat', 'Wizard robe top', 'Wizard robe skirt', 'Wizard gloves', 'Wizard boots', 'Black wizard hat', 'Black wizard robe top', 'Black wizard robe skirt', 'Black wizard gloves', 'Black wizard boots', 'Imphide hood', 'Imphide robe top', 'Imphide gloves', 'Imphide robe bottom', 'Imphide boots', 'Spirit Terrorbird scroll (Tireless Run)', 'Barker Toad scroll (Toad Bark)', 'Spirit Dagannoth scroll (Spike Shot)', 'Granite Crab scroll (Stony Shell)', 'Spirit terrorbird pouch', 'Barker toad pouch', 'Spirit dagannoth pouch', 'Granite crab pouch'}
	},
	['Precious components'] = {
		short = 'precious',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Sapphire', 'Emerald', 'Ruby', 'Diamond', 'Dragonstone', 'Gold ring', 'Ring of slaying'}
	},
	['Precise components'] = {
		short = 'precise',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Maple longbow (unstrung)', 'Maple longbow', 'Oak longbow (unstrung)', 'Oak longbow', 'Willow longbow (unstrung)', 'Willow longbow', 'Yew longbow (unstrung)', 'Yew longbow', 'Magic longbow (unstrung)', 'Magic longbow', 'Maple shortbow (unstrung)', 'Maple shortbow', 'Oak shortbow (unstrung)', 'Oak shortbow', 'Willow shortbow (unstrung)', 'Willow shortbow', 'Yew shortbow (unstrung)', 'Yew shortbow', 'Magic shortbow (unstrung)', 'Magic shortbow'}
	},
	['Protective components'] = {
		short = 'protective',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Carapace helm', 'Carapace torso', 'Carapace legs', 'Carapace boots', 'Carapace gloves', 'Hard leather body', 'Hard leather chaps', 'Hard leather boots', 'Hard leather gloves', 'Hard leather shield', 'Leather body', 'Leather chaps', 'Leather boots', 'Leather gloves', 'Leather shield', 'Black wizard hat', 'Black wizard robe top', 'Black wizard robe skirt', 'Imphide hood', 'Imphide robe bottom', 'Imphide robe top'}
	},
	['Refined components'] = {
		short = 'refined',
		method = 'min',
		reason = 'Based on the price of [[Junk refiner]] (assumes production of 20 components)',
		special = false,
		items = {'Darting shadow', 'Laboratory relic (common)', 'Reef relic (common)'}
		-- Has an override to use junk refiner cost in [[Module:Component costs]]
	},
	['Sharp components'] = {
		short = 'sharp',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Adamant dart', 'Mithril dart', 'Off-hand adamant dart', 'Off-hand mithril dart', 'Off-hand rune dart', 'Off-hand steel dart', 'Rune dart', 'Steel dart'}
	},
	['Strong components'] = {
		short = 'strong',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Hard leather shield', 'Leather shield', 'Maple longbow (unstrung)', 'Maple longbow', 'Oak longbow (unstrung)', 'Oak longbow', 'Willow longbow (unstrung)', 'Willow longbow', 'Yew longbow (unstrung)', 'Yew longbow', 'Magic longbow (unstrung)', 'Magic longbow'}
	},
	['Stunning components'] = {
		short = 'stunning',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Black salamander', 'Green salamander', 'Wooden stock', 'Oak stock', 'Willow stock', 'Teak stock', 'Maple stock', 'Mahogany stock', 'Yew stock', 'Magic stock', 'Eternal magic stock'}
	},
	['Subtle components'] = {
		short = 'subtle',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Bronze scimitar', 'Iron scimitar', 'Steel scimitar', 'Black scimitar', 'Mithril scimitar', 'Adamant scimitar', 'Rune scimitar', 'Tiny bladed bronze salvage', 'Small bladed bronze salvage', 'Medium bladed bronze salvage', 'Large bladed bronze salvage', 'Huge bladed bronze salvage', 'Tiny bladed iron salvage', 'Small bladed iron salvage', 'Medium bladed iron salvage', 'Large bladed iron salvage', 'Huge bladed iron salvage', 'Tiny bladed steel salvage', 'Small bladed steel salvage', 'Medium bladed steel salvage', 'Large bladed steel salvage', 'Huge bladed steel salvage', 'Tiny bladed mithril salvage', 'Small bladed mithril salvage', 'Medium bladed mithril salvage', 'Large bladed mithril salvage', 'Huge bladed mithril salvage', 'Tiny bladed adamant salvage', 'Small bladed adamant salvage', 'Medium bladed adamant salvage', 'Large bladed adamant salvage', 'Huge bladed adamant salvage', 'Tiny bladed rune salvage', 'Small bladed rune salvage', 'Medium bladed rune salvage', 'Large bladed rune salvage', 'Huge bladed rune salvage', 'Tiny bladed orikalkum salvage', 'Small bladed orikalkum salvage', 'Medium bladed orikalkum salvage', 'Large bladed orikalkum salvage', 'Huge bladed orikalkum salvage', 'Tiny bladed necronium salvage'}
	},
	['Swift components'] = {
		short = 'swift',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Adamant dart', 'Mithril dart', 'Off-hand adamant dart', 'Off-hand mithril dart', 'Off-hand rune dart', 'Off-hand steel dart', 'Rune dart', 'Steel dart'}
	},
	['Variable components'] = {
		short = 'variable',
		method = 'min',
		special = false,
		threshold = 100,
		items = {'Guam tar', 'Marrentill tar', 'Tarromin tar', 'Harralander tar'}
	},
	['Third-age components'] = {
		short = 'third-age',
		alias = {'third age', 'thirdage'},
		method = 'traded-avg',
		reason = 'The average price/material for several items is used due to the low GE trade limits of the sources.',
		special = true,
		items = {'Third age vambraces', 'Third age ranger coif', 'Third age mage hat', 'Third age ranger chaps', 'Third age ranger body', 'Third age druidic staff', 'Third age robe', 'Third age full helmet', 'Third age druidic cloak', 'Third age kiteshield'}
	},
	['Armadyl components'] = {
		short = 'armadyl',
		method = 'min',
		special = true,
		items = {'Armadyl boots', 'Armadyl buckler', 'Augmented Armadyl chainskirt', 'Augmented Armadyl chestplate', 'Armadyl gloves', 'Armadyl helmet', 'Augmented Armadyl godsword', 'Augmented Armadyl crossbow', 'Augmented off-hand Armadyl crossbow', 'Augmented Armadyl buckler'}
	},
	['Ascended components'] = {
		short = 'ascended',
		method = 'min',
		reason = 'The minimum price/material of several items is used due to the craftability of the items used for disassembly.',
		special = true,
		items = {'Ascension grips', 'Augmented sirenic chaps', 'Augmented sirenic hauberk', 'Sirenic mask'}
	},
	['Avernic components'] = {
		short = 'avernic',
		method = 'min',
		special = true,
		items = {'Augmented anima core body of Zamorak', 'Augmented anima core legs of Zamorak', 'Augmented refined anima core body of Zamorak', 'Augmented refined anima core legs of Zamorak', 'Augmented Blade of Avaryss', 'Augmented Blade of Nymora'}
	},
	['Bandos components'] = {
		short = 'bandos',
		method = 'min',
		special = true,
		items = {'Bandos boots', 'Bandos gloves', 'Bandos helmet', 'Augmented Bandos warshield', 'Augmented Bandos chestplate', 'Augmented Bandos tassets', 'Augmented Bandos godsword'}
	},
	['Brassican components'] = {
		short = 'brassican',
		method = 'min',
		special = true,
		items = {'Cabbage'}
	},
	['Corporeal components'] = {
		short = 'corporeal',
		method = 'min',
		special = true,
		items = {'Augmented blessed spirit shield', 'Spectral sigil', 'Augmented arcane spirit shield', 'Augmented divine spirit shield', 'Augmented elysian spirit shield', 'Augmented spectral spirit shield'}
	},
	['Culinary components'] = {
		short = 'culinary',
		method = 'avg',
		reason = 'The average price/material for several items is used due to the stock of Culinaromancer\'s Chest.',
		special = true,
		items = {'Cleaver', 'Egg whisk', 'Frying pan', 'Kitchen knife', 'Meat tenderiser', 'Rolling pin', 'Skewer', 'Spatula', 'Spork', 'Wooden spoon', 'Culinaromancer\'s gloves 1', 'Culinaromancer\'s gloves 2', 'Culinaromancer\'s gloves 3', 'Culinaromancer\'s gloves 4', 'Culinaromancer\'s gloves 5', 'Culinaromancer\'s gloves 6', 'Culinaromancer\'s gloves 7', 'Culinaromancer\'s gloves 8'}
	},
	['Cywir components'] = {
		short = 'cywir',
		method = 'min',
		special = true,
		items = {'Augmented anima core body of Seren', 'Augmented anima core legs of Seren', 'Augmented Orb of the Cywir elders', 'Augmented Wand of the Cywir elders', 'Augmented refined anima core body of Seren', 'Augmented refined anima core legs of Seren'}
	},
	['Dragonfire components'] = {
		short = 'dragonfire',
		method = 'min',
		special = true,
		items = {'Augmented dragonfire deflector', 'Augmented dragonfire shield', 'Augmented dragonfire ward', 'Augmented dragonfire shroud', 'Augmented royal crossbow'}
	},
	['Ecliptic components'] = {
		short = 'ecliptic',
		method = 'min',
		special = true,
		items = {'Augmented Roar of Awakening', 'Augmented Ode to Deceit', 'Augmented khopesh of Tumeken', 'Augmented khopesh of Elidinis', 'Augmented Devourer\'s Guard', 'Mask of Tumeken\'s resplendence', 'Augmented robe top of Tumeken\'s resplendence', 'Augmented robe bottom of Tumeken\'s resplendence', 'Gloves of Tumeken\'s resplendence', 'Boots of Tumeken\'s resplendence', 'Augmented Tumeken\'s Light'}
	},
	['Explosive components'] = {
		short = 'explosive',
		method = 'min',
		special = true,
		items = {'Hand cannon', 'Augmented hand cannon'}
	},
	['Fortunate components'] = {
		short = 'fortunate',
		method = 'traded-avg',
		reason = 'The average price/material for several items is used due to the low GE trade limits of the sources.',
		special = true,
		items = {'Bat mask', 'Black crossbow', 'Blessed dragonhide body (Armadyl)', 'Blessed dragonhide chaps (Bandos)', 'Blessed dragonhide coif (Zamorak)', 'Blessed dragonhide coif (Zaros)', 'Blessed dragonhide vambraces (Zaros)', 'Blue elegant skirt', 'Green elegant blouse', 'Green elegant skirt', 'Half-moon spectacles (black)', 'Half-moon spectacles (blue)', 'Half-moon spectacles (green)', 'Magic composite bow', 'Off-hand black crossbow', 'Penguin mask', 'Purple elegant blouse', 'Purple elegant legs', 'Purple elegant shirt', 'Purple elegant skirt', 'Red elegant blouse', 'Red elegant legs', 'Red elegant skirt', 'Round glasses (blue)', 'Round glasses (green)', 'Sheep mask', 'Stylish glasses (blue)', 'Stylish glasses (green)', 'White elegant skirt', 'Willow composite bow', 'Wolf mask', 'Yew composite bow'}
	},
	['Fungal components'] = {
		short = 'fungal',
		method = 'min',
		special = true,
		items = {'Ganodermic boots', 'Ganodermic gloves', 'Augmented ganodermic leggings', 'Augmented ganodermic poncho', 'Ganodermic visor', 'Augmented polypore staff', 'Earthborne staff', 'Augmented Mudborne staff'}
	},
	['Harnessed components'] = {
		short = 'harnessed',
		method = 'traded-avg',
		reason = 'The average price/material for several items is used due to the extremely low GE trade volumes of the sources.',
		special = true,
		items = {'Body body', 'Body boots', 'Body gloves', 'Body helmet', 'Body shield', 'Chaos body', 'Chaos boots', 'Chaos gloves', 'Chaos helmet', 'Chaos shield', 'Cosmic body', 'Cosmic boots', 'Cosmic gloves', 'Cosmic helmet', 'Cosmic shield', 'Mind body', 'Mind boots', 'Mind gloves', 'Mind helmet', 'Mind shield', 'Elemental body', 'Elemental boots', 'Elemental gloves', 'Elemental helmet', 'Elemental shield'}
	},
	['Ilujankan components'] = {
		short = 'ilujankan',
		method = 'min',
		special = true,
		items = {'Crest of Zaros', 'Zarosian essence', 'Augmented anima core body of Zaros', 'Augmented anima core legs of Zaros', 'Augmented Dragon Rider lance', 'Augmented refined anima core body of Zaros', 'Augmented refined anima core legs of Zaros'}
	},
	['Knightly components'] = {
		short = 'knightly',
		method = 'min',
		special = true,
		threshold = 10,
		items = {'Black 2h crossbow', 'Black 2h sword', 'Black battleaxe', 'Black boots', 'Black chainbody', 'Black claw', 'Black dagger', 'Black full helm', 'Black gauntlets', 'Black hatchet', 'Black helm', 'Black knife', 'Black longsword', 'Black mace', 'Black platebody', 'Black platelegs', 'Black scimitar', 'Black spear', 'Black sword', 'Black warhammer', 'Off-hand black battleaxe', 'Off-hand black claw', 'Off-hand black dagger', 'Off-hand black knife', 'Off-hand black longsword', 'Off-hand black mace', 'Off-hand black scimitar', 'Off-hand black sword', 'Off-hand black warhammer', 'Elite black full helm', 'Elite black platebody', 'Elite black platelegs', }
	},
	['Manufactured components'] = {
		short = 'manufactured',
		method = 'min',
		special = true,
		items = {'Lesser necroplasm', 'Greater necroplasm', 'Powerful necroplasm', 'Air talisman', 'Mind talisman', 'Water talisman', 'Earth talisman', 'Fire talisman', 'Body talisman', 'Cosmic talisman', 'Chaos talisman', 'Nature talisman', 'Law talisman', 'Death talisman', 'Blood talisman', 'Soul talisman'}
	},
	['Noxious components'] = {
		short = 'noxious',
		method = 'min',
		special = true,
		items = {'Augmented noxious longbow', 'Augmented noxious scythe', 'Augmented noxious staff'}
	},
	['Oceanic components'] = {
		short = 'oceanic',
		method = 'min',
		special = true,
		items = {'Seasinger\'s hood', 'Seasinger\'s robe bottom', 'Seasinger\'s robe top', 'Seasinger\'s robe top', 'Seasinger\'s robe bottom'}
	},
	['Pestiferous components'] = {
		short = 'pestiferous',
		method = 'min',
		reason = 'The minimum price/material for the [[Augmented Korasi\'s sword|augmented]] and normal versions of [[Korasi\'s sword]] is used because the augmented price/material is much lower but requires training to level 9.',
		special = true,
		items = {'Augmented Korasi\'s sword', 'Korasi\'s sword'}
	},
	['Resilient components'] = {
		short = 'resilient',
		method = 'min',
		special = true,
		items = {'Dinosaurhide boots', 'Dinosaurhide cowl', 'Dinosaurhide gloves', 'Tetsu body', 'Tetsu helm', 'Tetsu platelegs', 'Tetsu sword upgrade kit', 'Laceration boots', 'Augmented Masuta\'s warspear', 'Augmented mizuyari'}
	},
	['Rumbling components'] = {
		short = 'rumbling',
		method = 'min',
		special = true,
		items = {'Augmented drygore longsword', 'Augmented drygore mace', 'Augmented drygore rapier', 'Augmented off-hand drygore longsword', 'Augmented off-hand drygore mace', 'Augmented off-hand drygore rapier', 'Augmented seismic singularity', 'Augmented seismic wand', 'Augmented tectonic robe bottom', 'Augmented tectonic robe top'}
	},
	['Saradomin components'] = {
		short = 'saradomin',
		method = 'min',
		special = true,
		items = {'Saradomin mjolnir', 'Augmented Saradomin sword', 'Saradomin\'s hiss', 'Saradomin\'s murmur', 'Saradomin\'s whisper'}
	},
	['Seren components'] = {
		short = 'seren',
		method = 'min',
		reason = 'The minimum price/material for several items is used due to the low GE trade limits of the sources.',
		special = true,
		-- Although augmented attuned crystal weapons are a reliable source of the components, their price is insufficient to account for the computational cost. The same applies to the augmented crystal hatchet.
		items = {'Crystal helm', 'Crystal body', 'Crystal legs', 'Crystal boots', 'Crystal gloves', 'Augmented crystal shield', 'Augmented crystal ward', 'Augmented crystal deflector', 'Augmented crystal halberd', 'Augmented crystal orb', 'Augmented crystal staff', 'Augmented crystal wand', 'Augmented crystal bow', 'Augmented crystal dagger', 'Augmented crystal off-hand dagger'}
	},
	['Shadow components'] = {
		short = 'shadow',
		method = 'min',
		special = true,
		items = {'Augmented anima core body of Sliske', 'Augmented anima core legs of Sliske', 'Augmented Off-hand Shadow glaive', 'Augmented refined anima core body of Sliske', 'Augmented refined anima core legs of Sliske', 'Augmented Shadow glaive'}
	},
	['Shifting components'] = {
		short = 'shifting',
		method = 'min',
		special = true,
		items = {'Blast diffusion boots', 'Gloves of passage', 'Khopesh of the Kharidian', 'Fleeting boots'}
	},
	['Silent components'] = {
		short = 'silent',
		method = 'min',
		special = true,
		items = {'Augmented upgraded bone blowpipe', 'Augmented Laniakea\'s spear', 'Death lotus extract', 'Death Lotus hood', 'Death Lotus chestplate', 'Death Lotus chaps', 'Superior Death Lotus hood', 'Superior Death Lotus tekoh', 'Superior Death Lotus tabi'}
	},
	['Undead components'] = {
		short = 'undead',
		method = 'min',
		special = true,
		items = {'Augmented Linza\'s platebody', 'Augmented Linza\'s greaves', 'Linza\'s helm', 'Augmented malevolent cuirass', 'Augmented malevolent greaves', 'Malevolent helm', 'Augmented malevolent kiteshield', 'Augmented merciless kiteshield', 'Augmented vengeful kiteshield'}
	},
	['Zamorak components'] = {
		short = 'zamorak',
		method = 'min',
		special = true,
		items = {'Augmented Zamorak godsword', 'Augmented Zamorakian spear', 'Zamorak hilt', 'Augmented ward of subjugation', 'Augmented garb of subjugation', 'Augmented gown of subjugation', 'Hood of subjugation', 'Boots of subjugation', 'Gloves of subjugation', 'Zamorak mjolnir'}
	},
	['Zaros components'] = {
		short = 'zaros',
		method = 'min',
		special = true,
		items = {'Augmented Pernix body', 'Augmented Pernix chaps', 'Pernix cowl', 'Pernix boots', 'Pernix gloves', 'Augmented Virtus wand', 'Augmented Virtus book', 'Augmented Virtus robe top', 'Augmented Virtus robe legs', 'Virtus mask', 'Virtus boots', 'Virtus gloves', 'Augmented Torva platebody', 'Augmented Torva platelegs', 'Torva full helm', 'Torva boots', 'Torva gloves', 'Nightmare gauntlets', 'Enhanced nightmare gauntlets', 'Augmented Zaryte bow', 'Augmented imperium core', 'Augmented wand of the praesul'}
	},
	['Classic components'] = {
		short = 'classic',
		method = 'min',
		special = true,
		items = { 'Small crate (classic components)', 'Large crate (classic components)', 'Carbon black', 'Compass rose', 'Demonhide', 'Felt', 'Fossilised bone', 'Imperial steel', 'Leather scraps', 'Orthenglass', 'Vellum', 'White oak' }
	},
	['Timeworn components'] = {
		short = 'timeworn',
		method = 'min',
		special = true,
		items = {'Small crate (timeworn components)', 'Large crate (timeworn components)'}
	},
	['Historic components'] = {
		short = 'historic',
		method = 'min',
		special = true,
		items = {'Small crate (historic components)', 'Large crate (historic components)', 'Felt', 'Fossilised bone', 'Imperial steel', 'Leather scraps', 'Samite silk', 'Vellum', 'White oak'}
	},
	['Vintage components'] = {
		short = 'vintage',
		method = 'min',
		special = true,
		items = {'Small crate (vintage components)', 'Large crate (vintage components)'}
	},
}