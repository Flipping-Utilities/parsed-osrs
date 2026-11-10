-- <nowiki>
--------------------------
-- Module for [[Template:Infobox Quest]]
--------------------------
-- Test changes at [[Module:Infobox Quest/sandbox]]
local p = {}

-- "imports"
local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean
local nameDisp, imgarg, yesnoParam, voiceParam, voiceDisp, difficultyParam, seriesParam, seriesNthParam, seriesDisp
local seriesBucket, subquestDisp, areaParam, areaDisp, areaBucket, ageParam, ageDisp, timelineParam, timelineDisp, combatParam
local combatDisp, combatBucket, iconimgarg, questTypeParam, questId, questIdDisp, iddisp, idbucket, make_chisel_links

local difficulties = {
	["novice"] = { 0, "Novice" },
	["intermediate"] = { 1, "Intermediate" },
	["experienced"] = { 2, "Experienced" },
	["master"] = { 3, "Master" },
	["grandmaster"] = { 4, "Grandmaster" },
	["special"] = { 250, "Special" },
	["none"] = { 251, "N/A" },
}

p.series_list = {
	["none"] = {
		"None", "None", "Standalone quests",
	},
	["blooming burrow"] = {
		"Blooming Burrow", "[[Blooming Burrow quest series|Blooming Burrow]]", "Blooming Burrow quest series",
	},
	["sunlight sands"] = {
		"Sunlight Sands", "[[Sunlight Sands quest series|Sunlight Sands]]", "Sunlight Sands quest series",
	},
	["harvest hollow"] = {
		"Harvest Hollow", "[[Harvest Hollow quest series|Harvest Hollow]]", "Harvest Hollow quest series",
	},
	["christmas village"] = {
		"Christmas Village", "[[Christmas Village quest series|Christmas Village]]", "Christmas Village quest series",
	},
	["delrith"] = {
		"Delrith", "[[Delrith quest series|Delrith]]", "Delrith quest series",
	},
	["camelot"] = {
		"Camelot", "[[Camelot quest series|Camelot]]", "Camelot quest series",
	},
	["fairy"] = {
		"Fairy", "[[Fairy quest series|Fairy]]", "Fairy quest series",
	},
	["gnome"] = {
		"Gnome", "[[Gnome quest series|Gnome]]", "Gnome quest series",
	},
	["ogre"] = {
		"Ogre", "[[Ogre quest series|Ogre]]", "Ogre quest series",
	},
	["troll"] = {
		"Troll", "[[Troll quest series|Troll]]", "Troll quest series",
	},
	["fremennik"] = {
		"Fremennik", "[[Fremennik quest series|Fremennik]]", "Fremennik quest series",
	},
	["elemental workshop"] = {
		"Elemental Workshop", "[[Elemental Workshop quest series|Elemental Workshop]]", "Elemental Workshop quest series",
	},
	["enchanted key"] = {
		"Enchanted Key", "[[Enchanted Key quest series|Enchanted Key]]", "Enchanted Key quest series",
	},
	["cave goblin"] = {
		"Cave Goblin", "[[Cave Goblin quest series|Cave Goblin]]", "Cave Goblin quest series",
	},
	["temple knight"] = {
		"Temple Knight", "[[Temple Knight quest series|Temple Knight]]", "Temple Knight quest series",
	},
	["odd old man"] = {
		"Odd Old Man", "[[Odd Old Man quest series|Odd Old Man]]", "Odd Old Man quest series",
	},
	["wise old man"] = {
		"Wise Old Man", "[[Wise Old Man quest series|Wise Old Man]]", "Wise Old Man quest series",
	},
	["summer"] = {
		"Summer", "[[Summer quest series|Summer]]", "Summer quest series",
	},
	["thieves' guild"] = {
		"Thieves' Guild", "[[Thieves' Guild quest series|Thieves' Guild]]", "Thieves' Guild quest series",
	},
	["void knight"] = {
		"Void Knight", "[[Void Knight quest series|Void Knight]]", "Void Knight quest series",
	},
	["fremennik sagas"] = {
		"Fremennik Sagas", "[[Fremennik Sagas]]", "Fremennik Sagas quest series",
	},
	["doric's tasks"] = {
		"Doric's Tasks", "[[Doric's Tasks quest series|Doric's Tasks]]", "Doric's Tasks quest series",
	},
	["boric's tasks"] = {
		"Boric's Tasks", "[[Boric's Tasks quest series|Boric's Tasks]]", "Boric's Tasks quest series",
	},
	["ariane"] = {
		"Ariane", "[[Ariane quest series|Ariane]]", "Ariane quest series",
	},
	["ozan"] = {
		"Ozan", "[[Ozan quest series|Ozan]]", "Ozan quest series",
	},
	["desert"] = {
		"Desert", "[[Desert quest series|Desert]]", "Desert quest series",
	},
	["tzhaar"] = {
		"TzHaar", "[[TzHaar quest series|TzHaar]]", "TzHaar quest series",
	},
	["dwarf (red axe)"] = {
		"Dwarf (Red Axe)", "[[Dwarf (Red Axe) quest series|Dwarf (Red Axe)]]", "Dwarf (Red Axe) quest series",
	},
	["elf (prifddinas)"] = {
		"Elf (Prifddinas)", "[[Elf (Prifddinas) quest series|Elf (Prifddinas)]]", "Elf (Prifddinas) quest series",
	},
	["myreque"] = {
		"Myreque", "[[Myreque quest series|Myreque]]", "Myreque quest series",
	},
	["pirate"] = {
		"Pirate", "[[Pirate quest series|Pirate]]", "Pirate quest series",
	},
	["penguin"] = {
		"Penguin", "[[Penguin quest series|Penguin]]", "Penguin quest series",
	},
	["tales of the arc"] = {
		"Tales of the Arc", "[[Tales of the Arc quest series|Tales of the Arc]]", "Tales of the Arc quest series",
	},
	["violet tendencies"] = {
		"Violet Tendencies", "[[Violet Tendencies quest series|Violet Tendencies]]", "Violet Tendencies quest series",
	},
	["mahjarrat mysteries"] = {
		"Mahjarrat Mysteries", "[[Mahjarrat Mysteries quest series|Mahjarrat Mysteries]]",
		"Mahjarrat Mysteries quest series",
	},
	["sliske's game"] = {
		"Sliske's Game", "[[Sliske's Game quest series|Sliske's Game]]", "Sliske's Game quest series",
	},
	["the elder god wars"] = {
		"The Elder God Wars", "[[The Elder God Wars quest series|The Elder God Wars]]", "The Elder God Wars quest series",
	},
	["legacy of zamorak"] = {
		"Legacy of Zamorak", "[[Legacy of Zamorak quest series|Legacy of Zamorak]]", "Legacy of Zamorak quest series",
	},
	["fort forinthry"] = {
		"Fort Forinthry", "[[Fort Forinthry quest series|Fort Forinthry]]", "Fort Forinthry quest series",
	},
	["the first necromancer"] = {
		"The First Necromancer", "[[The First Necromancer quest series|The First Necromancer]]",
		"The First Necromancer quest series",
	},
	["city of um"] = {
		"City of Um", "[[City of Um quest series|City of Um]]", "City of Um quest series",
	},
	["sanguine"] = {
		"Sanguine", "[[Sanguine quest series|Sanguine]]", "Sanguine quest series",
	},
}

local regions = {
	["blooming burrow"] = { "Blooming Burrow", "[[Blooming Burrow]]" },
	["sunlight sands"] = { "Sunlight Sands", "[[Sunlight Sands]]" },
	["harvest hollow"] = { "Harvest Hollow", "[[Harvest Hollow]]" },
	["christmas village"] = { "Christmas Village", "[[Christmas Village]]" },
	["burthorpe"] = { "Burthorpe", "[[Burthorpe]]" },
	["taverley"] = { "Taverley", "[[Taverley]]" },
	["taverley outskirts"] = { "Taverley Outskirts", "[[Taverley]] Outskirts" },
	["lumbridge"] = { "Lumbridge", "[[Lumbridge]]" },
	["draynor village"] = { "Draynor Village", "[[Draynor Village]]" },
	["draynor outskirts"] = { "Draynor Outskirts", "[[Draynor Village|Draynor]] Outskirts" },
	["wizards tower"] = { "Wizards' Tower", "[[Wizards' Tower]]" },
	["wizards' tower"] = { "Wizards' Tower", "[[Wizards' Tower]]" },
	["varrock"] = { "Varrock", "[[Varrock]]" },
	["varrock palace"] = { "Varrock Palace", "[[Varrock Palace]]" },
	["varrock outskirts"] = { "Varrock Outskirts", "[[Varrock]] Outskirts" },
	["silvarea"] = { "Silvarea", "[[Silvarea]]" },
	["edgeville"] = { "Edgeville", "[[Edgeville]]" },
	["wilderness"] = { "Wilderness", "[[Wilderness]]" },
	["ice mountain"] = { "Ice Mountain", "[[Ice Mountain]]" },
	["falador north"] = { "Falador North", "[[Falador]] North" },
	["falador castle"] = { "Falador Castle", "[[Falador Castle]]" },
	["falador park"] = { "Falador Park", "[[Falador Park]]" },
	["rimmington"] = { "Rimmington", "[[Rimmington]]" },
	["port sarim"] = { "Port Sarim", "[[Port Sarim]]" },
	["daemonheim"] = { "Daemonheim", "[[Daemonheim]]" },
	["al kharid"] = { "Al Kharid", "[[Al Kharid]]" },
	["kharidian desert"] = { "Kharidian Desert", "[[Kharidian Desert]]" },
	["menaphos and sophanem"] = { "Menaphos & Sophanem", "[[Menaphos]] & [[Sophanem]]" },
	["menaphos & sophanem"] = { "Menaphos & Sophanem", "[[Menaphos]] & [[Sophanem]]" },
	["morytania"] = { "Morytania", "[[Morytania]]" },
	["paterdomus"] = { "Paterdomus", "[[Paterdomus]]" },
	["canifis"] = { "Canifis", "[[Canifis]]" },
	["port phasmatys"] = { "Port Phasmatys", "[[Port Phasmatys]]" },
	["karamja"] = { "Karamja", "[[Karamja]]" },
	["entrana"] = { "Entrana", "[[Entrana]]" },
	["seers village"] = { "Seers' Village", "[[Seers' Village]]" },
	["seers' village"] = { "Seers' Village", "[[Seers' Village]]" },
	["fremennik province"] = { "Fremennik Province", "[[Fremennik Province]]" },
	["rellekka"] = { "Rellekka", "[[Rellekka]]" },
	["fremennik isles"] = { "Fremennik Isles", "[[Fremennik Isles]]" },
	["trollheim"] = { "Trollheim", "[[Trollheim]]" },
	["gnome village"] = { "Gnome Village", "[[Tree Gnome Village (location)|Gnome Village]]" },
	["gnome stronghold"] = { "Gnome Stronghold", "[[Gnome Stronghold]]" },
	["kandarin north-west"] = { "Kandarin North-west", "[[Kandarin]] North-west" },
	["kandarin west"] = { "Kandarin West", "[[Kandarin]] West" },
	["kandarin north"] = { "Kandarin North", "[[Kandarin]] North" },
	["ardougne"] = { "Ardougne", "[[Ardougne]]" },
	["ardougne zoo"] = { "Ardougne Zoo", "[[Ardougne Zoo]]" },
	["witchaven"] = { "Witchaven", "[[Witchaven]]" },
	["kandarin south"] = { "Kandarin South", "[[Kandarin]] South" },
	["yanille"] = { "Yanille", "[[Yanille]]" },
	["feldip hills"] = { "Feldip Hills", "[[Feldip Hills]]" },
	["keldagrim"] = { "Keldagrim", "[[Keldagrim]]" },
	["dorgesh-kaan"] = { "Dorgesh-Kaan", "[[Dorgesh-Kaan]]" },
	["tzhaar city"] = { "TzHaar City", "[[TzHaar City]]" },
	["player owned house"] = { "Player owned house", "[[Player-owned house]]" },
	["tirannwn"] = { "Tirannwn", "[[Tirannwn]]" },
	["anachronia"] = { "Anachronia", "[[Anachronia]]" },
	["wushanko isles"] = { "Wushanko Isles - Arc", "[[Wushanko Isles]] – [[Arc]]" },
	["fort forinthry"] = { "Fort Forinthry", "[[Fort Forinthry]]" },
	["underworld"] = { "Underworld", "[[Underworld]]" },
	["wendlewick"] = { "Wendlewick", "[[Wendlewick]]" },
}

p.timelines = {
	["seasonal"] = { "Seasonal", "Seasonal quests" },
	["pathfinder"] = { "Pathfinder", "Pathfinder quests" },
	["adventurer"] = { "Adventurer", "Adventurer quests" },
	["champion"] = { "Champion", "Champion quests" },
	["heroic"] = { "Heroic", "Heroic quests" },
	["legendary"] = { "Legendary", "Legendary quests" },
	["mythic"] = { "Mythic", "Mythic quests" },
	["world guardian"] = { "World Guardian", "World Guardian quests" },
	["age of chaos"] = { "Age of Chaos", "Age of Chaos quests" },
}

p.combat_list = {
	-- [input name] = {enum value, bucket value, display name, category}
	["seasonal"] = { 0, "seasonal", "Seasonal", "" },
	["none"] = { 1, "none", "None", "Quests without combat requirements" },
	["1"] = { 2, "1", "NPC combat level 1", "Quests involving monsters of combat level 1" },
	["2-3"] = { 3, "2-3", "NPC combat level 2–3", "Quests involving monsters of combat level 2 to 3" },
	["4-5"] = { 4, "4-5", "NPC combat level 4–5", "Quests involving monsters of combat level 4 to 5" },
	["6-9"] = { 5, "6-9", "NPC combat level 6–9", "Quests involving monsters of combat level 6 to 9" },
	["scaled"] = { 6, "scaled", "NPC combat level scaled", "Quests involving monsters of combat level scaled" },
	["10-19"] = { 7, "10-19", "NPC combat level 10–19", "Quests involving monsters of combat level 10 to 19" },
	["20-29"] = { 8, "20-29", "NPC combat level 20–29", "Quests involving monsters of combat level 20 to 29" },
	["30-39"] = { 9, "30-39", "NPC combat level 30–39", "Quests involving monsters of combat level 30 to 39" },
	["40-49"] = { 10, "40-49", "NPC combat level 40–49", "Quests involving monsters of combat level 40 to 49" },
	["50-59"] = { 11, "50-59", "NPC combat level 50–59", "Quests involving monsters of combat level 50 to 59" },
	["60-69"] = { 12, "60-69", "NPC combat level 60–69", "Quests involving monsters of combat level 60 to 69" },
	["70-79"] = { 13, "70-79", "NPC combat level 70–79", "Quests involving monsters of combat level 70 to 79" },
	["80-89"] = { 14, "80-89", "NPC combat level 80–89", "Quests involving monsters of combat level 80 to 89" },
	["90-99"] = { 15, "90-99", "NPC combat level 90–99", "Quests involving monsters of combat level 90 to 99" },
	["100-109"] = { 16, "100-109", "NPC combat level 100–109", "Quests involving monsters of combat level 100 to 109" },
	["110-119"] = { 17, "110-119", "NPC combat level 110–119", "Quests involving monsters of combat level 110 to 119" },
	["120-129"] = { 18, "120-129", "NPC combat level 120–129", "Quests involving monsters of combat level 120 to 129" },
	["130-139"] = { 19, "130-139", "NPC combat level 130–139", "Quests involving monsters of combat level 130 to 139" },
	["140-149"] = { 20, "140-149", "NPC combat level 140–149", "Quests involving monsters of combat level 140 to 149" },
	["150-159"] = { 21, "150-159", "NPC combat level 150–159", "Quests involving monsters of combat level 150 to 159" },
	["160-169"] = { 22, "160-169", "NPC combat level 160–169", "Quests involving monsters of combat level 160 to 169" },
	["170-179"] = { 23, "170-179", "NPC combat level 170–179", "Quests involving monsters of combat level 170 to 179" },
	["180-189"] = { 24, "180-189", "NPC combat level 180–189", "Quests involving monsters of combat level 180 to 189" },
	["190-199"] = { 25, "190-199", "NPC combat level 190–199", "Quests involving monsters of combat level 190 to 199" },
	["200+"] = { 26, "200+", "NPC combat level 200+", "Quests involving monsters with a minimum combat level of 200" },
}

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	p.defineParams(ret, 'quest')
	p.setup(ret)
	p.useBucket(ret)

	ret:defineName('Infobox Quest')
	p.display(ret, 'quest')

	ret:finish()
	if onmain() then
		local allargs = ret:param('all')
		local catargs = ret:categoryData()
		ret:wikitext(p.addcategories(allargs, catargs, 'quest'))
	end
	return ret:tostring()
end

function p.defineParams(ret, quest_type)
	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'nameDisp', func = { name = nameDisp, params = { 'name', 'number' } } },
		{ name = 'image', func = imgarg },
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'members', func = yesnoParam },
		{ name = 'number', func = 'has_content' },
		{ name = 'voice', func = voiceParam },
		{ name = 'voicedisp', func = { name = voiceDisp, params = { 'voice' } } },
		{ name = 'difficulty', func = difficultyParam },
		{ name = 'series', func = 'has_content' },
		{ name = 'main_series', func = seriesParam },
		{ name = 'series_nth', func = seriesNthParam },
		{ name = 'main_series_disp', func = { name = seriesDisp, params = { 'main_series', 'series_nth' } } },
		{ name = 'main_series_bucket', func = { name = seriesBucket, params = { 'main_series' } } },
		{ name = 'subquest', func = 'has_content' },
		{ name = 'subquest_disp', func = { name = subquestDisp, params = { 'subquest' } } },
		{ name = 'area', func = areaParam },
		{ name = 'area_disp', func = { name = areaDisp, params = { 'area' } } },
		{ name = 'area_bucket', func = { name = areaBucket, params = { 'area' } } },
		{ name = 'age', func = ageParam },
		{ name = 'age_disp', func = { name = ageDisp, params = { 'age' } } },
		{ name = 'timeline', func = timelineParam },
		{ name = 'timeline_disp', func = { name = timelineDisp, params = { 'timeline' } } },
		{ name = 'combat', func = combatParam },
		{ name = 'combat_disp', func = { name = combatDisp, params = { 'combat' } } },
		{ name = 'combat_bucket', func = { name = combatBucket, params = { 'combat' } } },
		{ name = 'entity_icon', func = iconimgarg },
		{ name = 'type', func = { name = questTypeParam, params = { quest_type, 'type' }, flag = { 'r', 'd' } } },
		{ name = 'override_seq', func = 'numbers' },
		{ name = 'quest_id', func = { name = questId, params = { 'quest_id', 'create_id' }, flag = 'p' } },
		{ name = 'quest_id_disp', func = { name = questIdDisp, params = { 'quest_id', 'create_id' }, flag = 'p' } },
		{ name = 'configname', func = 'name' },
		{ name = 'id', func = { name = iddisp, params = { 'id' }, flag = 'p' } },
		{ name = 'id_bucket', func = { name = idbucket, params = { 'id' }, flag = 'p' } },
		{ name = 'chisel_links', func = { name = make_chisel_links, params = { 'id_bucket' }, flag = 'd' } },
	}
end

function p.setup(ret)
	ret:setMaxButtons(4)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)
end

function p.useBucket(ret)
	ret:useBucket('infobox_quest', {
		id_bucket = 'id',
		configname = 'config_name',
		quest_id = 'create_id',
		override_seq = 'override_sequence',
		name = 'name',
		members = 'is_members_only',
		voice = 'voice_over',
		difficulty = 'official_difficulty',
		main_series_bucket = 'official_series',
		series_nth = 'official_nth_in_series',
		age = 'official_age',
		timeline_disp = 'official_timeline',
		area_bucket = 'start_area',
		type = 'quest_type',
		combat_bucket = 'official_combat',
		subquest = 'subquest_of',
		release = 'release_date',
		removal = 'removal_date',
	})
	ret:useBucket('quest_id', {
		id_bucket = 'id',
	})
end

function p.display(ret, quest_type)
	-- Display subquests as quests
	if quest_type == "subquest" then
		quest_type = "quest"
	end

	ret:addClass('infobox-quest')
	ret:defineLinks()

	-- PARAMETER: name
	ret:addRow {
		{ tag = 'argh', content = 'nameDisp', class = 'infobox-header', colspan = '20' },
	}

	-- PARAMETER: image
	ret:addRow {
		{ tag = 'argd', content = 'image', class = 'infobox-image infobox-full-width-content', colspan = '20' },
	}
		:pad(20)

	-- PARAMETER: release date
	ret:addRow {
		{ tag = 'th', content = 'Release date', colspan = '8' },
		{ tag = 'argd', content = 'release', colspan = '12' },
	}

	-- PARAMETER: removal date
	if ret:paramDefined('removal') then
		ret:addRow {
			{ tag = 'th', content = 'Removal date', colspan = '8' },
			{ tag = 'argd', content = 'removal', colspan = '12' },
		}
	end

	-- PARAMETER: members/f2p
	ret:addRow {
		{ tag = 'th', content = '[[Members]]', colspan = '8' },
		{ tag = 'argd', content = 'members', colspan = '12' },
	}

	-- PARAMETER: voice over
	ret:addRow {
		{ tag = 'th', content = '[[Voice Over]]', colspan = '8' },
		{ tag = 'argd', content = 'voicedisp', colspan = '12' },
	}

	-- PARAMTER: main series
	ret:addRow {
		{ tag = 'th', content = '[[List of quest series|Official series]]', colspan = '8' },
		{ tag = 'argd', content = 'main_series_disp', colspan = '12' },
	}

	-- PARAMETER: quest series
	if ret:paramDefined('series') then
		ret:addRow {
			{ tag = 'th', content = 'Quest series', colspan = '8' },
			{ tag = 'argd', content = 'series', colspan = '12' },
		}
	end

	if ret:paramDefined('subquest') then
		ret:addRow {
			{ tag = 'th', content = 'Subquest of', colspan = '8' },
			{ tag = 'argd', content = 'subquest_disp', colspan = '12' },
		}
	end

	-- PARAMTER: quest age
	local agelinkto = string.format('List of %ss by age', quest_type)
	ret:addRow {
		{ tag = 'th', content = '[[' .. agelinkto .. '|Age]]', colspan = '8' },
		{ tag = 'argd', content = 'age_disp', colspan = '12' },
	}

	-- PARAMETER: timeline
	if ret:paramDefined('timeline') then
		ret:addRow {
			{ tag = 'th', content = 'Timeline', colspan = '8' },
			{ tag = 'argd', content = 'timeline_disp', colspan = '12' },
		}
	end

	-- PARAMETER: area
	if ret:paramDefined('area') then
		ret:addRow {
			{ tag = 'th', content = 'Start area', colspan = '8' },
			{ tag = 'argd', content = 'area_disp', colspan = '12' },
		}
	end

	local difflinkto = string.format('List of %ss by difficulty', quest_type)
	ret:addRow {
		{ tag = 'th', content = '[[' .. difflinkto .. '|Official difficulty]]', colspan = '8' },
		{ tag = 'argd', content = 'difficulty', colspan = '12' },
	}

	-- PARAMETER: combat
	ret:addRow {
		{ tag = 'th', content = 'Combat<sup title="As displayed in-game" style="cursor:help;text-decoration:underline dotted">[?]</sup>', colspan = '8' },
		{ tag = 'argd', content = 'combat_disp', colspan = '12' },
	}

	-- PARAMETER: entity icon
	if ret:paramDefined('entity_icon') then
		ret:addRow {
			{ tag = 'th', content = '[[Entity icon]]', colspan = '8' },
			{ tag = 'argd', content = 'entity_icon', colspan = '12' },
		}
	end
	ret:pad(20)

	ret:addRow {
		{ tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '20' },
		meta = { addClass = 'advanced-data' },
	}
		:pad(20, 'advanced-data')
		:addRow {
			{ tag = 'th', content = 'Quest ID', colspan = '8' },
			{ tag = 'argd', content = 'quest_id_disp', colspan = '12' },
			meta = { addClass = 'advanced-data' },
		}
		:addRow {
			{ tag = 'th', content = 'Config ID', colspan = '8' },
			{ tag = 'argd', content = 'id', colspan = '12' },
			meta = { addClass = 'advanced-data' },
		}
		:addRow {
			{ tag = 'th', content = 'Config name', colspan = '8' },
			{ tag = 'argd', content = 'configname', colspan = '12' },
			meta = { addClass = 'advanced-data' },
		}

	if ret:paramDefined('override_seq') then
		ret:addRow {
			{ tag = 'th', content = 'Quest timeline<br />override sequence', colspan = '8' },
			{ tag = 'argd', content = 'override_seq', colspan = '12' },
			meta = { addClass = 'advanced-data' },
		}
	end

	if infobox.isDefined(ret:param('chisel_links')) then
		ret:addRow {
			{ tag = 'th', content = 'Links', colspan = '8' },
			{ tag = 'argd', content = 'chisel_links', colspan = '12' },
			meta = { addClass = 'advanced-data' },
		}
	end

	ret:pad(20, 'advanced-data')
end

function nameDisp(name, number)
	if infobox.isDefined(name) or infobox.isDefined(number) then
		local ret = {}
		if infobox.isDefined(name) then
			table.insert(ret, name)
		end
		if infobox.isDefined(number) then
			table.insert(ret, '<small>(#' .. number .. ')</small>')
		end
		return table.concat(ret, ' ')
	end
	return nil
end

function imgarg(arg)
	if infobox.isDefined(arg) then
		return cleanimg { file = arg, width = 300, height = 300 }
	end
	return nil
end

function iconimgarg(arg)
	if infobox.isDefined(arg) then
		return cleanimg { file = arg }
	end
	return nil
end

function yesnoParam(param)
	if infobox.isDefined(param) then
		local b = yesno(param)
		if b then
			return 'Yes'
		elseif not b then
			return 'No'
		else
			return nil
		end
	end
	return nil
end

function ageParam(d)
	if infobox.isDefined(d) then
		d = d:lower()
		if d == 'seasonal' then
			return 'seasonal'
		elseif d == '5' then
			return '5'
		elseif d == 'ambiguous' then
			return 'ambiguous'
		elseif d == '6' then
			return '6'
		elseif d == 'chaos' or d == 'age of chaos' then
			return 'chaos'
		else
			return nil
		end
	end
	return nil
end

function ageDisp(d)
	if infobox.isDefined(d) then
		if d == 'seasonal' then
			return 'Seasonal'
		elseif d == '5' then
			return '[[Fifth Age]]'
		elseif d == 'ambiguous' then
			return 'Ambiguous'
		elseif d == '6' then
			return '[[Sixth Age]]'
		elseif d == 'chaos' then
			return '[[Age of Chaos]] ([[Sixth Age]])'
		else
			return nil
		end
	end
	return nil
end

function voiceParam(d)
	if not infobox.isDefined(d) then
		return nil
	end

	local l = d:lower()
	if l == "no" or l == "partial" or l == "full" or l == "music" then
		return l
	else
		return nil
	end
end

local function help_message(display, text)
	return tostring(
		mw.html.create():tag('span')
		:css { ["border-bottom"] = "1px dotted", ["cursor"] = "help" }
		:attr('title', text)
		:wikitext(display)
	)
end

function voiceDisp(d)
	if not infobox.isDefined(d) then
		return nil
	end

	if d == "no" then
		return "No"
	elseif d == "partial" then
		return "Partial"
	elseif d == "full" then
		return "Full"
	elseif d == "music" then
		return help_message("Music focused",
			"This quest focuses on music. We suggest you keep your sound effects and music on to get the most out of it.")
	end

	return nil
end

function difficultyParam(d)
	if not infobox.isDefined(d) then
		return nil
	end

	return difficulties[d:lower()][2]
end

function questId(id, create_id)
	if infobox.isDefined(id) then
		local idl = id:lower()
		if idl ~= 'no' and idl ~= 'none' then
			return id
		end
	elseif infobox.isDefined(create_id) then
		local idl = create_id:lower()
		if idl ~= 'no' and idl ~= 'none' then
			return create_id
		end
	end

	return nil
end

function questIdDisp(id, create_id)
	if infobox.isDefined(id) then
		local idl = id:lower()
		if idl == 'no' or idl == 'none' then
			return 'None'
		else
			return id
		end
	elseif infobox.isDefined(create_id) then
		local idl = create_id:lower()
		if idl == 'no' or idl == 'none' then
			return 'None'
		else
			return create_id
		end
	end

	return nil
end

function iddisp(id)
	if infobox.isDefined(id) then
		if id:lower() ~= 'no' then
			local r = string.gsub(id, ', *', ', ')
			return r
		elseif id:lower() == 'no' or id:lower() == "none" then
			return 'None'
		end
	end
	return nil
end

function idbucket(id)
	if infobox.isDefined(id) and id:lower() ~= 'none' then
		local r = string.gsub(id, ', *', infobox.splitpoint)
		return r
	end
	return nil
end

function seriesParam(series_name)
	if not infobox.isDefined(series_name) then
		return nil
	end

	local name = series_name:lower()
	if name == "no" or name == "none" then
		return p.series_list["none"]
	end

	local series_value = p.series_list[name]
	if series_value == nil then
		return nil
	else
		return series_value
	end
end

function seriesDisp(series, no)
	if not infobox.isDefined(series) then
		return nil
	end

	local series_name = series[2]
	if series_name == "None" or not infobox.isDefined(no) then
		return series_name
	end

	return series_name .. " #" .. no
end

function seriesBucket(series)
	if not infobox.isDefined(series) then
		return nil
	end

	return series[1]
end

function subquestDisp(subquest)
	if not infobox.isDefined(subquest) then
		return nil
	end

	return "[[" .. subquest .. "]]"
end

function areaParam(region_name)
	if not infobox.isDefined(region_name) then
		return nil
	end

	local name = region_name:lower()
	if name == "no" or name == "none" then
		return nil
	end

	local region = regions[name]
	if region == nil then
		return nil
	else
		return region
	end
end

function areaDisp(region)
	if not infobox.isDefined(region) then
		return nil
	end

	return region[2]
end

function areaBucket(region)
	if not infobox.isDefined(region) then
		return nil
	end

	return region[1]
end

function seriesNthParam(nth)
	if not infobox.isDefined(nth) then
		return nil
	end

	return tonumber(nth)
end

function questTypeParam(quest_type, type)
	if infobox.isDefined(type) and type:lower() == 'saga' then
		return 'saga'
	end

	return quest_type
end

function timelineParam(d)
	if not infobox.isDefined(d) then
		return nil
	end

	local timeline_value = p.timelines[d:lower()]
	if timeline_value == nil then
		return nil
	else
		return timeline_value
	end
end

function timelineDisp(timeline)
	if not infobox.isDefined(timeline) then
		return nil
	end

	return timeline[1]
end

function combatParam(d)
	if not infobox.isDefined(d) then
		return nil
	end

	local combat_value = p.combat_list[d:lower()]
	if combat_value == nil then
		return nil
	else
		return combat_value
	end
end

function combatDisp(combat)
	if not infobox.isDefined(combat) then
		return nil
	end

	return combat[3]
end

function combatBucket(combat)
	if not infobox.isDefined(combat) then
		return nil
	end

	return combat[2]
end

function make_chisel_links(id)
	if not infobox.isDefined(id) then
		return nil
	end

	local link = 'https://chisel.weirdgloop.org/structs_rs3/index.html?type=quests'
	link = string.format('%s&id=%s', link, id)
	return string.format('[%s Quests]', link)
end

function p.addcategories(args, catargs, quest_type)
	-- Added if the parameter has no content
	local cat_map_notdefined = {
		image = 'Needs image',
		release = 'Needs quest release date added',
		age = 'Needs age added',
		id = 'Quests without ID',
		configname = 'Needs config name',
	}

	local cat_map_defined = {
		series = 'Pages with deprecated parameters',
	}

	local ret, difficulty_cat_format
	if quest_type == "quest" then
		ret = { 'Quests' }
		-- Added if the parameter has content
		cat_map_defined = {
			entity_icon = 'Quests with entity icons',
		}
		difficulty_cat_format = '%s quests'
	elseif quest_type == "miniquest" then
		ret = { 'Miniquests' }
		cat_map_defined = {
			entity_icon = 'Miniquests with entity icons',
		}
		difficulty_cat_format = '%s miniquests'
	elseif quest_type == "subquest" then
		ret = { 'Subquests', 'Quests' }
		cat_map_defined = {}
		difficulty_cat_format = '%s quests'
	end

	local age = args.age.d
	if infobox.isDefined(age) then
		local a = tostring(age):lower()
		if a == '5' then
			table.insert(ret, 'Fifth Age quests')
		elseif a == 'ambiguous' then
			table.insert(ret, 'Ambiguous age quests')
		elseif a == '6' then
			table.insert(ret, 'Sixth Age quests')
			-- elseif a == 'chaos' then
			-- Disabled as it conficts with timeline
			-- 	table.insert(ret, 'Age of chaos quests')
		end
	end

	local timeline = args.timeline.d
	if infobox.isDefined(timeline) then
		table.insert(ret, timeline[2])
	end

	local difficulty = args.difficulty.d
	if infobox.isDefined(difficulty) and difficulty ~= "N/A" then
		local diffCat = string.format(difficulty_cat_format, difficulty)
		table.insert(ret, diffCat)
	end

	local main_series = args.main_series.d
	if infobox.isDefined(main_series) then
		table.insert(ret, main_series[3])
	end

	local voiceover = args.voice.d
	if voiceover == "full" or voiceover == "partial" then
		table.insert(ret, 'Voice acted quests')
	end

	local combat = args.combat.d
	if infobox.isDefined(combat) then
		table.insert(ret, combat[4])
	end

	-- Run and add mapped categories
	for n, v in pairs(cat_map_defined) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret, v)
		end
	end
	for n, v in pairs(cat_map_notdefined) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret, v)
		end
	end

	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end
	return table.concat(ret, '')
end

return p
-- </nowiki>