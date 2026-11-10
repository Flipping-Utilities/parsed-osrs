local materials = {}

local list = {
	"Aetherium alloy",
	"Ancient vis",
	"Animal furs",
	"Armadylean yellow",
	"Banded limestone",
	"Blood of Orcus",
	"Burnt umber",
	"Cadmium red",
	"Carbon black",
	"Cashmere",
	"Chaotic brimstone",
	"Cobalt blue",
	"Compass rose",
	"Demonhide",
	"Dragon metal",
	"Everlight silvthril",
	"Eye of Dagon",
	"Felt",
	"Fossilised bone",
	"Goldrune",
	"Hellfire metal",
	"Imperial iron",
	"Imperial steel",
	"Ivory",
	"Keramos",
	"Leather scraps",
	"Malachite green",
	"Mark of the Kyzaj",
	"Orgone",
	"Orthenglass",
	"Pigments",
	"Purpleheart wood",
	"Quintessence",
	"Samite silk",
	"Soapstone",
	"Star of Saradomin",
	"Stormguard steel",
	"Third Age iron",
	"Triskelion",
	"Tyrian purple",
	"Vellum",
	"Vulcanised rubber",
	"Warforged bronze",
	"White marble",
	"White oak",
	"Wings of War",
	"Yu'biusk clay",
	"Zarosian insignia",
}

materials.list = list

-- Set of materials will be lowercase
local set = {}
for _, mat in ipairs(materials.list) do
	set[mat:lower()] = true
end

materials.set = set



function materials.to_pagename(u_material)
	-- Words that are capitalized in the article name parentheticals 
	local proper_nouns = {
		"Third", "Age", "Zarosian", "Tyrian", "Eye", "Dagon", "Everlight", "Star", "Saradomin", "Blood", "Orcus", "Stormguard", "Wings", "War", "Armadylean", "Kyzaj", "Mark", "Yu'biusk"
	}
	
	local proper_noun_map = {}
	for _, noun in ipairs(proper_nouns) do
		proper_noun_map[noun:lower()] = noun
	end
	local material = u_material:lower()
		
	local split_name = mw.text.split(material, " ")
	local pagename = {}
	for _, word in ipairs(split_name) do
		if proper_noun_map[word] then
			table.insert(pagename, proper_noun_map[word])
		else
			table.insert(pagename, word)
		end
	end
	return table.concat(pagename, " ")
end

return materials