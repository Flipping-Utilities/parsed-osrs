return {
	["title"] = "Crystal geode",
	["sample"] = "shattered",
	["dropsLine"] = "DropsLineRW",
	["fields"] = {
		{
			["name"] = "total",
			["type"] = "number",
			["icon"] = nil,
			["label"] = "Total shattered",
			["placeholder"] = "# shattered",
			["info"] = "The amount of geodes you have shattered",
			["required"] = true
		},
		{
			["name"] = "sapphire",
			["type"] = "number",
			["icon"] = "Uncut sapphire.png",
			["label"] = "Sapphire",
			["placeholder"] = "# uncut sapphires",
			["info"] = "The amount of uncut sapphires you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Uncut sapphire",
			["estimatedRarity"] = "Common"
		},
		{
			["name"] = "emerald",
			["type"] = "number",
			["icon"] = "Uncut emerald.png",
			["label"] = "Emerald",
			["placeholder"] = "# uncut emeralds",
			["info"] = "The amount of uncut emeralds you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Uncut emerald",
			["estimatedRarity"] = "Common"
		},
		{
			["name"] = "ruby",
			["type"] = "number",
			["icon"] = "Uncut ruby.png",
			["label"] = "Ruby",
			["placeholder"] = "# uncut rubies",
			["info"] = "The amount of uncut rubies you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Uncut ruby",
			["estimatedRarity"] = "Common"
		},
		{
			["name"] = "diamond",
			["type"] = "number",
			["icon"] = "Uncut diamond.png",
			["label"] = "Diamond",
			["placeholder"] = "# uncut diamonds",
			["info"] = "The amount of uncut diamonds you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Uncut diamond",
			["estimatedRarity"] = "Common"
		},
		{
			["name"] = "dragonstone",
			["type"] = "number",
			["icon"] = "Uncut dragonstone.png",
			["label"] = "Dragonstone",
			["placeholder"] = "# uncut dragonstones",
			["info"] = "The amount of uncut dragonstones you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Uncut dragonstone",
			["estimatedRarity"] = "Uncommon"
		},
		{
			["name"] = "triskelionFragment",
			["type"] = "number",
			["icon"] = "Crystal triskelion fragment 1.png",
			["label"] = "Crystal trikelion fragment",
			["placeholder"] = "# crystal trikelion fragments",
			["info"] = "The amount of crystal trikelion fragment you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Crystal triskelion",
			["estimatedRarity"] = "Rare"
		},
		{
			["name"] = "weaponSeed",
			["type"] = "number",
			["icon"] = "Crystal weapon seed.png",
			["label"] = "Crystal weapon seed",
			["placeholder"] = "# crystal weapon seeds",
			["info"] = "The amount of crystal weapon seeds you earned",
			["required"] = true,
			["quantity"] = 1,
			["page"] = "Crystal weapon seed",
			["estimatedRarity"] = "Very rare",
			["rarityNotes"] = "{{Refn|group=d|name=crystal weapon seed|Completion of [[Roving Elves]] required.}}"
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