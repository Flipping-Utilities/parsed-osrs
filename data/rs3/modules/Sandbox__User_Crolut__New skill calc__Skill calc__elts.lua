--[=[ elts
-- These determine and return the table headers for calculators.
-- No calculations are done on this page; this purely an array of headers.
-- To create a new one:
--   - if there is no base skill yet, use ["Skillname"]
--   - if the goal is a specific sub-set of a skill that requires different 
--     headers, use ["Skillname-Subset"]. 
--     The Subset should be the option displayed in the calculator.
--   - All elts should follow this exact template where possible:
--     {'Name', 'Level', 'XP', '# needed', ...} where the ellipse includes additional columns
--]=]
local p2pf2p = "[[File:P2P-F2P icon.png|30px|link=|alt=Members]]"

return {
    ["Agility"] = 
        {'Name', 'Level', 'XP', '# needed', p2pf2p},
    ["Agility-Basic"] = 
        {'Name', 'Level', p2pf2p},
    ["Construction"] = 
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Unit cost', 'Cost', 'XP cost', p2pf2p},
    ["Construction-Rooms"] = 
        {'Name','Level','Cost', p2pf2p},
    ["Construction-Flatpacks"] = 
        {'Name', 'Bench', 'Level', 'XP', '# needed', 'Wood', 'Materials', 'Unit cost', 'Cost', 'XP cost', p2pf2p},
    ["Construction-Milestones"] =
        {'Name','Level','XP','Cost', p2pf2p},
    ["Construction-Other"] = 
        {'Name', 'Level', 'XP', '# needed', 'Materials', p2pf2p},
    ["Cooking"] = 
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss',  'Profit/XP', p2pf2p},
    ["Cooking-No Burn"] = 
        {'Name', 'Level', 'Stop burning', 'XP', '# needed', '# urns', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss',  'Profit/XP', p2pf2p},
    ["Cooking-Brewing"] = 
        {'Name', 'Level', 'Stop burning', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss',  'Profit/XP', p2pf2p},
    ["Cooking-Dungeoneering"] = 
        {'Name', 'Level', 'Stop burning', 'XP', '# needed', 'Materials', p2pf2p},
    ["Crafting"] = 
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Crafting-Dungeoneering Armour"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', p2pf2p},
    ["Divination"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Product cost', 'Profit', 'Profit/XP', p2pf2p},
    ["Divination-Boons"] =
        {'Name', 'Level', 'XP', 'Materials', 'Raw cost', 'XP cost', p2pf2p},
    ["Divination-Conversion /w Energy"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Materials', 'Raw cost', 'XP cost', p2pf2p},
    ["Divination-Materials"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Materials', p2pf2p},
    ["Divination-Materials (no urns)"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', p2pf2p},
    ["Divination-Other"] =
        {'Name', 'Level', p2pf2p},
    ["Divination-Profit/Loss"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Divination-Profit/Loss (no urns)"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Dungeons"] =
        {'Name', 'Level', 'XP', '# needed', p2pf2p},
    ["Dungeons-Materials"] = 
        {'Name', 'Level', 'XP', '# needed', 'Materials', p2pf2p},
    ["Farming"] = 
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Seed', 'Raw cost', p2pf2p},
    ["Farming-Curing Animals"] = 
        {'Name', 'Level', 'XP', '# needed', '# urns', p2pf2p},
    ["Farming-Raising Animals"] = 
        {'Name', 'Level', 'Egg to baby', 'Baby to adolescent', 'Adolescent to adult', 'Adult to elder', 'Total XP', '# needed', '# urns', p2pf2p},
    ["Farming-Manure"] = 
        {'Name', 'Level', 'XP', '# needed', '# urns', p2pf2p},
    ["Firemaking"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Unit cost', 'Raw cost', 'XP cost', p2pf2p},
    ["Firemaking-Barbarian"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', p2pf2p},
    ["Firemaking-Char"] =
        {'Name', 'Level', 'XP', '# needed', p2pf2p},
    ["Firemaking-Milestones"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Unit cost', 'Raw cost', 'XP cost', p2pf2p},
    ["Firemaking-Other"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', p2pf2p},
    ["Firemaking-Incense Sticks (scratch + ashing)"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Fishing"] =
        {'Name', 'Tool', 'Bait', 'Level', 'XP', '# needed', '# urns', 'Raw cost', 'Product cost', 'Profit', p2pf2p},
    ["Fishing-Deep Sea"] =
        {'Name', 'Tool', 'Level', 'XP', '# needed', '# urns', 'Product cost', 'Profit', p2pf2p},
    ["Fishing-Dungeoneering"] =
        {'Name', 'Tool', 'Bait', 'Level', 'XP', '# needed', p2pf2p},
    ["Fletching"] = 
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Fletching-Dungeoneering"] = 
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'XP cost', p2pf2p},
    ["Herblore"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Hunter"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Output', 'Product cost', p2pf2p},
    ["Hunter-Anachronia"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Output', p2pf2p},
    ["Hunter-Bait"] = 
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Bait', 'Output', 'Product cost', p2pf2p},
    ["Hunter-No Bait No Product"] = 
    	{'Name', 'Level', 'XP', '# needed', '# urns', p2pf2p},
    ["Hunter-No Product"] =
    	{'Name', 'Level', 'XP', '# needed', '# urns', 'Bait', p2pf2p},
    ["Invention"] =
    	{'Name', 'Level', 'XP', '# needed', p2pf2p},
    ["Invention-Manufacturing"] =
    	{'Name', 'Level', 'XP', '# needed', 'Materials', 'Tech tree', p2pf2p},
    ["Invention-Manufacturing - Ancient"] =
    	{'Name', 'Level', 'XP', '# needed', 'Materials', p2pf2p},
    ["Magic"] = 
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Cost with<br/>[[Elemental battlestaff]]', p2pf2p},
    ["Mining"] = 
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Profit', p2pf2p},
    ["Mining-Gems"] = 
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Rock type', 'Location', 'Profit', p2pf2p},
    ["Prayer"] =
        {'Name', 'XP', '# needed', 'Raw cost', 'XP cost', p2pf2p},
    ["Prayer-Incense sticks"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss',  'Profit/XP', p2pf2p},
    ["Runecrafting"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', p2pf2p},
    ["Runecrafting-Runes"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Materials', 'Raw cost', 'Output', 'Product cost', 'Profit/Loss', p2pf2p},
    ["Runecrafting-Tiaras"] =
        {'Name', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', p2pf2p},
    ["Runecrafting-Runespan - Free"] =
        {'Name', 'Level', 'XP', '# needed', p2pf2p},
    ["Runecrafting-Runespan - Members"] =
        {'Name', 'Level', 'XP', '# needed', p2pf2p},
    ["Slayer"] = 
        {'Name', 'Level', 'Slayer Level', 'XP', '# needed', p2pf2p},
    ["Slayer-Assignments"] = 
        {'Name', 'Level', 'Slayer Level', 'XP', '# needed','Guide', p2pf2p},
    ["Slayer-Basic"] = 
        {'Name', 'Level', p2pf2p},
    ["Smithing"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Smithing-Basic"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', p2pf2p},
    ["Smithing-Burial sets"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Materials', 'Raw cost', 'XP cost', p2pf2p},
    ["Smithing-Forging"] =
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Unit cost', 'XP cost', p2pf2p},
    ["Smithing-Profit/Loss"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Smithing-Raw cost"] =
        {'Name', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'XP cost', p2pf2p},
    ["Summoning"] =
        {'Name', 'Charm', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Summoning-Scrolls"] =
        {'Name', 'Level', 'XP', '# needed', 'Pouch', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
    ["Summoning-Dungeoneering - Pouches"] =
        {'Name', 'Charm', 'Level', 'XP', '# needed', 'Materials', 'Raw cost', 'Product cost', 'Profit/Loss', 'Profit/XP', p2pf2p},
	["Summoning-Dungeoneering - Scrolls"] = 
        {'Name', 'Level', 'XP', '# needed', 'Materials', p2pf2p,},
    ["Thieving"] = 
        {'Name', 'Level', 'XP', '# needed', p2pf2p},
    ["Thieving-Safes"] = 
        {'Name', 'Level', 'XP', '# needed', 'Location', p2pf2p},
    ["Thieving-Sorceress Garden"] = 
        {'Name', 'Level', 'XP', '# needed', 'Fruit', p2pf2p},
    ["Woodcutting"] = 
        {'Name', 'Level', 'XP', '# needed', '# urns', 'Profit', p2pf2p},
    ["Woodcutting-Dungeoneering"] =
        {'Name', 'Level', 'XP', '# needed', 'Profit', p2pf2p},
    ["Woodcutting-Other"] =
        {'Name', 'Level', 'XP', '# needed', p2pf2p},
    ["Urns"] =
        {'Name', 'XP', '# needed', 'Materials', 'Cost', 'XP cost', p2pf2p}
}