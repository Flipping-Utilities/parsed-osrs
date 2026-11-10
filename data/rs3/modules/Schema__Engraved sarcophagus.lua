return {
	["title"] = "Engraved sarcophagus",
	["sample"] = "plundered",
	["dropsLine"] = "DropsLineThieving",
	["fields"] = {
		{
			["name"] = "total",
			["type"] = "number",
			["icon"] = nil,
			["label"] = "Total plundered",
			["info"] = "The amount of sarcophagi you have plundered",
			["required"] = true
		},
		{
			["name"] = "goldSeal",
			["type"] = "number",
			["icon"] = "Gold seal.png",
			["label"] = "Gold seal",
			["info"] = "The amount of gold seals you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Gold seal",
			["estimatedRarity"] = "Uncommon"
		},
		{
			["name"] = "goldenScarab",
			["type"] = "number",
			["icon"] = "Golden scarab.png",
			["label"] = "Golden scarab",
			["info"] = "The amount of golden scarabs you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Golden scarab",
			["estimatedRarity"] = "Common"
		},
		{
			["name"] = "goldenStatuette",
			["type"] = "number",
			["icon"] = "Golden statuette.png",
			["label"] = "Golden statuette",
			["info"] = "The amount of golden statuettes you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Golden statuette",
			["estimatedRarity"] = "Common"
		},
		{
			["name"] = "jewelledGoldenStatuette",
			["type"] = "number",
			["icon"] = "Jewelled golden statuette.png",
			["label"] = "Jewelled golden statuette",
			["info"] = "The amount of jewelled golden statuettes you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Jewelled golden statuette",
			["estimatedRarity"] = "Uncommon"
		},
		{
			["name"] = "jewelledDiamondStatuette",
			["type"] = "number",
			["icon"] = "Jewelled diamond statuette.png",
			["label"] = "Jewelled diamond statuette",
			["info"] = "The amount of jewelled diamond statuette you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Jewelled diamond statuette",
			["estimatedRarity"] = "Uncommon",
			["altValue"] = 12500,
		},
		{
			["name"] = "sceptreOfTheGods",
			["type"] = "number",
			["icon"] = "Sceptre of the gods.png",
			["label"] = "Sceptre of the gods",
			["info"] = "The amount of sceptres of the gods you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Sceptre of the gods",
			["overrideRarity"] = "1/480",
			["altRarity"] = "1/20",
			["altRarityDash"] = "yes",
			["rarityNotes"] = "{{DropNote|1/475 with tier 2 luck, 1/470 with tier 3 luck, 1/465 with tier 4 luck.}}{{DropNote|Every unsuccessful attempt reduces the denominator by 1. This will keep decreasing down to 1/20. The counter resets once the sceptre is looted.}}",
		},
		{
			["name"] = "pharaohsSceptre",
			["type"] = "number",
			["icon"] = "Pharaoh's sceptre.png",
			["label"] = "Pharaoh's sceptre",
			["info"] = "The amount of pharaoh's sceptres you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Pharaoh's sceptre",
			["overrideRarity"] = "1/1000",
			["rarityNotes"] = "{{DropNote|1/1000 base chance. Only rolls when no mummy spawns. The chance improves in higher rooms. Tier 2 luck (Ring of Wealth) or higher further improves the chance.}}"
		},
		{
			["name"] = "evidence",
			["type"] = "text",
			["icon"] = nil,
			["label"] = "Evidence",
			["placeholder"] = "Optional",
			["info"] = "Any notes or a link to an image",
			["required"] = false
		}
	}
}