
-- manually curated lore data. Had to approximate on some dates
local lore_data = {
	{
		date = "2003-10-16",
		name = "Foreword by Reldo",
		link = "https://oldschool.runescape.wiki/w/Transcript:Lores_and_Histories",
	},
	{
		date = "2003-10-16",
		name = "A Brief History of Runescape",
		link = "https://oldschool.runescape.wiki/w/Transcript:A_Brief_History_of_RuneScape",
	},
	{
		date = "2003-10-16",
		name = "The Legend of Arrav - Part 1: Childhood of a Hero",
		link = "https://oldschool.runescape.wiki/w/Transcript:The_Legend_of_Arrav#Childhood_of_a_Hero",
	},
	{
		date = "2003-10-29",
		name = "A True and Concise History of the Discovery of the Runes",
		link = "https://oldschool.runescape.wiki/w/Transcript:A_True_and_Concise_History_of_the_Discovery_of_the_Runes",
	},
	{
		date = "2003-10-29",
		name = "Spirit of the Pass",
		link = "https://oldschool.runescape.wiki/w/Transcript:Spirit_of_the_Pass",
	},
	{
		date = "2003-11-24",
		name = "Gnomic Negotiations",
		link = "https://oldschool.runescape.wiki/w/Transcript:Gnomic_Negotiations",
	},
	{
		date = "2003-12-20",
		name = "The Legend of Arrav - Part 2: A Curse in the Land of Dreams, An Encounter Most Strange, A Meeting with the Imcando",
		link = "https://oldschool.runescape.wiki/w/Transcript:The_Legend_of_Arrav#A_Curse_in_the_Land_of_Dreams",
	},
	{
		date = "2006-08-10",
		name = "History of RuneScape",
		link = "https://oldschool.runescape.wiki/w/Transcript:History_of_RuneScape",
	},
	{
		date = "2007-05-29",
		name = "The Legend of Arrav - Part 3: A Battle of the Soul, Avarrocka burnt",
		link = "https://oldschool.runescape.wiki/w/Transcript:The_Legend_of_Arrav#A_Battle_of_the_Soul",
	},
	{
		date = "2007-05-29",
		name = "The Legend of Arrav - Part 4: The Curse Renewed, The Shield Given, Arrav's Fate Fulfilled",
		link = "https://oldschool.runescape.wiki/w/Transcript:The_Legend_of_Arrav#A_Battle_of_the_Soul",
	},
	{
		date = "2007-07-24",
		name = "The Fall of Six",
		link = "https://oldschool.runescape.wiki/w/Transcript:The_Fall_of_Six",
	},
	{
		date = "2021-05-18",
		name = "A Curious Client",
		link = "https://oldschool.runescape.wiki/w/Transcript:A_Curious_Client",
	},
	{
		date = "2021-05-21",
		name = "Lab Notes",
		link = "https://oldschool.runescape.wiki/w/Transcript:Lab_Notes",
	},
	{
		date = "2021-05-27",
		name = "The Plot and the Potion",
		link = "https://oldschool.runescape.wiki/w/Transcript:The_Plot_And_The_Potion",
	},
	{
		date = "2021-06-02",
		name = "A Kingdom United",
		link = "https://oldschool.runescape.wiki/w/Transcript:A_Kingdom_United",
	},
	{
		date = "2021-06-08",
		name = "The Man in the Tower",
		link = "https://oldschool.runescape.wiki/w/Transcript:The_Man_In_The_Tower",
	},
	{
		date = "2021-06-15",
		name = "The Ascent",
		link = "https://oldschool.runescape.wiki/w/Transcript:The_Ascent",
	},
	{
		date = "2025-11-11",
		name = "The Journal of Owen Clearstone - Entry 1",
		link = "https://oldschool.runescape.wiki/w/Transcript:Entry_1",
	},
	{
		date = "2025-11-14",
		name = "The Journal of Owen Clearstone - Entry 2",
		link = "https://oldschool.runescape.wiki/w/Transcript:Entry_2",
	},
	{
		date = "2025-11-17",
		name = "The Journal of Owen Clearstone - Entry 3",
		link = "https://oldschool.runescape.wiki/w/Transcript:Entry_3",
	},
	{
		date = "2025-11-18",
		name = "The Journal of Owen Clearstone - Entry 4",
		link = "https://oldschool.runescape.wiki/w/Transcript:Entry_4",
	},
	{
		date = "2025-11-18",
		name = "The Journal of Owen Clearstone - Entry 5",
		link = "https://oldschool.runescape.wiki/w/Transcript:Entry_5",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - Reldo's Foreword",
		link = "https://classic.runescape.wiki/w/Foreword_by_Reldo_(Tales_from_the_Tavern)",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - The Miners' Tale",
		link = "https://classic.runescape.wiki/w/The_Miners%27_Tale",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - Boots, Gloves, and Caskets",
		link = "https://classic.runescape.wiki/w/Boots,_Gloves,_And_Caskets",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - Prayer to Guthix",
		link = "https://classic.runescape.wiki/w/Prayer_To_Guthix",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - The Tale of the Twelve Apple Pies",
		link = "https://classic.runescape.wiki/w/The_Tale_Of_The_Twelve_Apple_Pies",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - Untitled",
		link = "https://classic.runescape.wiki/w/Untitled",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - The Wilderness",
		link = "https://classic.runescape.wiki/w/The_Wilderness_(Tales_from_the_Tavern)",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - Arfard the Barbarian",
		link = "https://classic.runescape.wiki/w/Arfard_the_Barbarian",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - Farmlands",
		link = "https://classic.runescape.wiki/w/Farmlands",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - The Archer, the Mage, and the Knight",
		link = "https://classic.runescape.wiki/w/The_Archer,_The_Mage,_and_The_Knight",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - The Battle of Edgeville",
		link = "https://classic.runescape.wiki/w/The_Battle_of_Edgeville",
	},
	{
		date = "2003-01-11",
		name = "Tales from the Tavern - Saga of the Antihero",
		link = "https://classic.runescape.wiki/w/Saga_of_the_Antihero",
	},
	{
		date = "2003-05-30",
		name = "Library of Varrock Bestiary",
		link = "https://classic.runescape.wiki/w/Bestiary_(Library_of_Varrock)",
	},
}

return lore_data