--[[

Hatchets, their required levels, their required power, and their image links.
Field 'tier_primary' lets us select only the main hatchets later down the line.

]]--
local hatchets = {}

hatchets.all_hatchets = {
	[1] = { short = 'bronze', label = 'Bronze', level = 1, power = 100, tier_primary = true },
	[2] = { short = 'dwarven_army', label = 'Dwarven army axe', image = 'Dwarven army axe', level = 1, power = 100, tier_primary = false },
	[3] = { short = 'iron', label = 'Iron', level = 10, power = 200, tier_primary = true },
	[4] = { short = 'steel', label = 'Steel', level = 20, power = 300, tier_primary = true },
	[5] = { short = 'black', label = 'Black', level = 25, power = 350, tier_primary = true },
	[6] = { short = 'mithril', label = 'Mithril', level = 30, power = 420, tier_primary = true },
	[7] = { short = 'adamant', label = 'Adamant', level = 40, power = 525, tier_primary = true },
	[8] = { short = 'rune', label = 'Rune', level = 50, power = 630, tier_primary = true },
	[9] = { short = 'sacred_clay', label = 'Sacred clay', level = 50, power = 630, tier_primary = false },
	[10] = { short = 'volatile_clay', label = 'Volatile clay', level = 50, power = 630, tier_primary = false },
	[11] = { short = 'orikalkum', label = 'Orikalkum', level = 60, power = 770, tier_primary = true },
	[12] = { short = 'dragon', label = 'Dragon', level = 60, power = 800, tier_primary = true, augmentable = true },
	[13] = { short = 'inferno_adze', label = 'Inferno adze', image = 'Inferno adze', level = 60, power = 800, tier_primary = false },
	[14] = { short = 'necronium', label = 'Necronium', level = 70, power = 880, tier_primary = true },
	[15] = { short = 'crystal', label = 'Crystal', level = 70, power = 910, tier_primary = true, augmentable = true },
	[16] = { short = 'bane', label = 'Bane', level = 80, power = 990, tier_primary = true },
	[17] = { short = 'imcando', label = 'Imcando', level = 80, power = 1070, tier_primary = true, augmentable = true },
	[18] = { short = 'elder_rune', label = 'Elder rune', level = 90, power = 1150, tier_primary = true },
	[19] = { short = 'ember_and_glade', label = 'Ember and glade', image = 'Hatchet of ember and glade', level = 90, power = 1185, tier_primary = true, augmentable = true },
	[20] = { short = 'primal', label = 'Primal', level = 100, proficiency = { level = 106, power = 20 }, power = 1265, tier_primary = true },
	[21] = { short = 'bloom_and_blight', label = 'Bloom and blight', image = 'Hatchet of bloom and blight', level = 100, proficiency = { level = 106, power = 20 }, power = 1300, tier_primary = true, augmentable = true },
}

-- This is used in woodcutting success chance. Here because it's a reference number even though it's not directly hatchet-related.
hatchets.mult = 10000

for _, hatchet in ipairs(hatchets.all_hatchets) do
	hatchet.image = (hatchet.image or hatchet.label .. ' hatchet') .. '.png'
	hatchet.mult = hatchets.mult
end

-- Just the primary tier ones - we use this enough it's worth being a separate thing
hatchets.hatchets = {}
for _, hatchet in ipairs(hatchets.all_hatchets) do
	if hatchet.tier_primary then
		table.insert(hatchets.hatchets, hatchet)
	end
end

return hatchets