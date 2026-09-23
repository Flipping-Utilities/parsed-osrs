local p = {}

local skillPic = require('Module:SCP')._main

local rumours = {
	["Tropical wagtail"] = {
		level = 19,
		method = "Bird snare"
	},
	["Wild kebbit"] = {
		level = 23,
		method = "Deadfall"
	},
	["Sapphire glacialis"] = {
		level = 25,
		method = "Butterfly net"
	},
	["Swamp lizard"] = {
		level = 29,
		method = "Net trap"
	},
	["Spined larupia"] = {
		level = 31,
		method = "Pitfall"
	},
	["Barb-tailed kebbit"] = {
		level = 33,
		method = "Deadfall"
	},
	["Snowy knight"] = {
		level = 35,
		method = "Butterfly net"
	},
	["Prickly kebbit"] = {
		level = 37,
		method = "Deadfall"
	},
	["Embertailed jerboa"] = {
		level = 39,
		method = "Box trap"
	},
	["Horned graahk"] = {
		level = 41,
		method = "Pitfall"
	},
	["Spotted kebbit"] = {
		level = 43,
		method = "Falconry"
	},
	["Black warlock"] = {
		level = 45,
		method = "Butterfly net"
	},
	["Orange salamander"] = {
		level = 47,
		method = "Net trap"
	},
	["Razor-backed kebbit"] = {
		level = 49,
		method = "Tracking"
	},
	["Sabre-toothed kebbit"] = {
		level = 51,
		method = "Deadfall"
	},
	["Grey chinchompa"] = {
		level = 53,
		method = "Box trap"
	},
	["Sabre-toothed kyatt"] = {
		level = 55,
		method = "Pitfall"
	},
	["Dark kebbit"] = {
		level = 57,
		method = "Falconry"
	},
	["Pyre fox"] = {
		level = 57,
		method = "Deadfall"
	},
	["Red salamander"] = {
		level = 59,
		method = "Net trap"
	},
	["Wyrmscraig Goat"] = {
		level = 60,
		method = "Goat pit"
	},
	["Red chinchompa"] = {
		level = 63,
		method = "Box trap"
	},
	["Dashing kebbit"] = {
		level = 69,
		method = "Falconry"
	},
	["Sunlight antelope"] = {
		level = 72,
		method = "Pitfall"
	},
	["Sunlight Moth"] = {
		level = 75,
		method = "Butterfly net"
	},
	["Tecu salamander"] = {
		level = 79,
		method = "Net trap"
	},
	["Herbiboar"] = {
		level = 80,
		method = "Tracking",
		icon = "Magic secateurs"
	},
	["Moonlight moth"] = {
		level = 85,
		method = "Butterfly net"
	},
	["Moonlight antelope"] = {
		level = 91,
		method = "Pitfall"
	}
}

method_icons = {
	["Bird snare"] = "Bird snare",
	["Butterfly net"] = "Butterfly net",
	["Box trap"] = "Box trap",
	["Deadfall"] = "Logs",
	["Falconry"] = "Falconer's glove",
	["Goat pit"] = "Cattleprod",
	["Net trap"] = "Rope",
	["Pitfall"] = "Teasing stick",
	["Tracking"] = "Noose wand"
}

local masters = {
	Gilman = {
		"Tropical wagtail",
		"Wild kebbit",
		"Sapphire glacialis",
		"Swamp lizard",
		"Spined larupia",
		"Barb-tailed kebbit",
		"Snowy knight",
		"Prickly kebbit",
		"Embertailed jerboa",
		"Horned graahk",
		"Spotted kebbit",
		"Black warlock",
		"Orange salamander",
		"Razor-backed kebbit",
		"Sabre-toothed kebbit",
		"Grey chinchompa",
		"Sabre-toothed kyatt",
		"Dark kebbit",
		"Pyre fox",
		"Red salamander",
		"Wyrmscraig Goat",
		"Red chinchompa",
		"Dashing kebbit",
		"Sunlight antelope",
		"Sunlight Moth",
		"Tecu salamander",
		"Herbiboar",
		"Moonlight moth",
		"Moonlight antelope"
	},

	Cervus = {
		"Swamp lizard",
		"Horned graahk",
		"Spotted kebbit",
		"Black warlock",
		"Orange salamander",
		"Razor-backed kebbit",
		"Sabre-toothed kebbit",
		"Grey chinchompa",
		"Dark kebbit",
		"Pyre fox",
		"Wyrmscraig Goat",
		"Red chinchompa",
		"Sunlight Moth"
	},

	Ornus = {
		"Spined larupia",
		"Snowy knight",
		"Embertailed jerboa",
		"Spotted kebbit",
		"Orange salamander",
		"Sabre-toothed kebbit",
		"Sabre-toothed kyatt",
		"Pyre fox",
		"Red salamander",
		"Red chinchompa"
	},

	Aco = {
		"Orange salamander",
		"Sabre-toothed kebbit",
		"Grey chinchompa",
		"Sabre-toothed kyatt",
		"Dark kebbit",
		"Red salamander",
		"Red chinchompa",
		"Dashing kebbit",
		"Sunlight antelope",
		"Tecu salamander",
		"Moonlight moth"
	},

	Teco = {
		"Sabre-toothed kebbit",
		"Grey chinchompa",
		"Sabre-toothed kyatt",
		"Dark kebbit",
		"Red salamander",
		"Wyrmscraig Goat",
		"Red chinchompa",
		"Dashing kebbit",
		"Sunlight antelope",
		"Sunlight Moth",
		"Herbiboar"
	},

	Wolf = {
		"Red salamander",
		"Red chinchompa",
		"Dashing kebbit",
		"Sunlight antelope",
		"Tecu salamander",
		"Herbiboar",
		"Moonlight moth",
		"Moonlight antelope"
	}
}


local lists = {
	Desert = {
		"Orange salamander"
	},

	Fremennik = {
		"Sapphire glacialis",
		"Snowy knight",
		"Sabre-toothed kebbit",
		"Sabre-toothed kyatt"
	},

	Kandarin = {
		"Tropical wagtail",
		"Wild kebbit",
		"Spined larupia",
		"Barb-tailed kebbit",
		"Prickly kebbit",
		"Spotted kebbit",
		"Black warlock",
		"Razor-backed kebbit",
		"Grey chinchompa",
		"Dark kebbit",
		"Red salamander",
		"Red chinchompa",
		"Dashing kebbit"
	},

	Karamja = {
		"Horned graahk"
	},

	Kourend = {
		"Sapphire glacialis",
		"Snowy knight",
		"Black warlock",
		"Grey chinchompa"
	},

	Misthalin = {
		"Grey chinchompa",
		"Herbiboar"
	},

	Morytania = {
		"Swamp lizard"
	},

	Tirannwn = {
		"Red chinchompa"
	},

	Varlamore = {
		"Sapphire glacialis",
		"Snowy knight",
		"Embertailed jerboa",
		"Pyre fox",
		"Sunlight antelope",
		"Sunlight Moth",
		"Tecu salamander",
		"Moonlight moth",
		"Moonlight antelope",
		"Red chinchompa",
		"Black warlock",
		"Tropical wagtail",
		"Wild kebbit"
	}
}

local master_requirements = {
	Gilman = {
		tier = "Novice",
		level = 46
	},
	Cervus = {
		tier = "Adept",
		level = 57
	},
	Ornus = {
		tier = "Adept",
		level = 57
	},
	Aco = {
		tier = "Expert",
		level = 72
	},
	Teco = {
		tier = "Expert",
		level = 72
	},
	Wolf = {
		tier = "Master",
		level = 91,
		quests = {
			"eaglesPeak",
			"atFirstLight"
		}
	}
}

local tier_masters = {
	Novice = {
		"Gilman"
	},
	Adept = {
		"Cervus",
		"Ornus"
	},
	Expert = {
		"Aco",
		"Teco"
	},
	Master = {
		"Wolf"
	}
}

-- Requirements that affect whether an individual rumour can be assigned.
-- These are also exposed to the browser so the JavaScript does not need
-- its own hard-coded copy of the same rules.
local creature_requirements = {
	["Embertailed jerboa"] = {
		quests = {
			"eaglesPeak"
		}
	},
	["Grey chinchompa"] = {
		quests = {
			"eaglesPeak"
		}
	},
	["Red chinchompa"] = {
		quests = {
			"eaglesPeak"
		}
	},
	["Swamp lizard"] = {
		quests = {
			"priestInPeril"
		}
	},
	["Herbiboar"] = {
		quests = {
			"boneVoyage"
		},
		skills = {
			herbloreLvl = 31
		}
	},
	["Wyrmscraig Goat"] = {
		quests = {
			"sheepHerder"
		},
		skills = {
			sailingLvl = 62
		}
	}
}

local function meets_requirements(
	creature,
	requirements
)
	local creature_requirement =
		creature_requirements[creature]

	if not creature_requirement then
		return true
	end

	for _, quest
		in ipairs(creature_requirement.quests or {}) do

		if not requirements[quest] then
			return false
		end
	end

	for skill, level
		in pairs(creature_requirement.skills or {}) do

		if (requirements[skill] or 1) < level then
			return false
		end
	end

	return true
end

local function get_available_tasks(
	active_master,
	player_level,
	unlocked_lists,
	active_tasks,
	requirements
)

	local unlocked_creatures = {}

	if unlocked_lists ~= "All" then
		for regionName, enabled
			in pairs(unlocked_lists) do

			if enabled
				and lists[regionName] then

				for _, creature
					in pairs(lists[regionName]) do

					unlocked_creatures[creature] = true
				end
			end
		end
	end

	local good_tasks = {}

	for _, creature
		in pairs(masters[active_master]) do

		local rumour = rumours[creature]

		if (
			(
				unlocked_lists == "All"
				or unlocked_creatures[creature]
			)
			and player_level >= rumour.level
			and not active_tasks[creature]
			and meets_requirements(
				creature,
				requirements
			)
		) then

			table.insert(
				good_tasks,
				{
					creature = creature,
					level = rumour.level,
					method = rumour.method,
					icon = rumour.icon
				}
			)
		end
	end

	return good_tasks
end

function p.client_data()
	return mw.text.jsonEncode({
		rumours = rumours,
		masters = masters,
		lists = lists,
		masterRequirements = master_requirements,
		tierMasters = tier_masters,
		creatureRequirements = creature_requirements
	})
end

function p.invoke_main(frame)
	return p.main(frame:getParent().args)
end

function p.main(args)
	local hunterLvl = tonumber(args.HunterLevel_Input) or 1
	local herbloreLvl = tonumber(args.HerbloreLevel_Input) or 1
	local sailingLvl = tonumber(args.SailingLevel_Input) or 1
	local master = args.master

	local unlocked_lists = {}

	if args.leaguesRegions == 'true' then
		unlocked_lists = {
			Varlamore = true
		}

		for entry in string.gmatch(
			args.regionOptions or '',
			'([^,]+)'
		) do
			unlocked_lists[entry] = true
		end
	else
		unlocked_lists = "All"
	end

	local active_tasks = {}

	if args.blockList == 'true' then
		active_tasks[args.gilman] = true
		active_tasks[args.cervus] = true
		active_tasks[args.ornus] = true
		active_tasks[args.aco] = true
		active_tasks[args.teco] = true
		active_tasks[args.wolf] = true
	end

	local requirements = {
		eaglesPeak = args.eaglesPeak == 'true',
		atFirstLight = args.atFirstLight == 'true',
		priestInPeril = args.priestInPeril == 'true',
		boneVoyage = args.boneVoyage == 'true',
		sheepHerder = args.sheepHerder == 'true',
		herbloreLvl = herbloreLvl,
		sailingLvl = sailingLvl
	}


	-- Decide which master or masters should be calculated.
	local target_masters = {
		master
	}

	if args.smartList == 'true' then

		if args.smartListMode == 'Master' then
			target_masters = {
				args.smartListMaster
			}

		elseif args.smartListMode == 'Tier' then
			target_masters =
				tier_masters[args.smartListTier]
				or {
					master
				}
		end
	end

	-- Main result container.
	-- Masters sit next to each other when room is available.
	local results = mw.html.create('div')
		:css('display', 'flex')
		:css('flex-wrap', 'wrap')
		:css('gap', '1em')
		:css('align-items', 'flex-start')
		:css('justify-content', 'center')

	-- Avoid duplicate level errors for multi-master Smart List tiers.
	if args.smartList == 'true'
		and args.smartListMode == 'Tier' then

		local tier_level_requirements = {
			Adept = 57,
			Expert = 72
		}

		local required_level =
			tier_level_requirements[args.smartListTier]

		if required_level
			and hunterLvl < required_level then

			results
				:tag('div')
				:css('flex', '0 1 auto')
				:tag('p')
				:wikitext(
					args.smartListTier ..
					" rumours require level " ..
					required_level ..
					" Hunter."
				)

			return tostring(results)
		end
	end

	for _, target_master in ipairs(target_masters) do

		-- Each master gets its own flex item.
		local master_result = results
			:tag('div')
			:css('flex', '0 1 auto')

		local requirement =
			master_requirements[target_master]

		-- Wolf requires Eagles' Peak and At First Light.
		if target_master == "Wolf"
			and (
				not requirements.eaglesPeak
				or not requirements.atFirstLight
			) then
		
			local wolf_message =
				"Wolf requires both [[Eagles' Peak]] and " ..
				"[[At First Light]] to assign rumours."
		
			if hunterLvl < requirement.level then
				wolf_message =
					"Wolf requires level " ..
					requirement.level ..
					" Hunter and completion of both [[Eagles' Peak]] and " ..
					"[[At First Light]] to assign rumours."
			end
		
			master_result
				:tag('p')
				:wikitext(wolf_message)
		
		-- Check Hunter level separately for each master.
		elseif requirement
			and hunterLvl < requirement.level then
		
			master_result
				:tag('p')
				:wikitext(
					target_master ..
					" assigns " ..
					requirement.tier ..
					" rumours, which require level " ..
					requirement.level ..
					" Hunter."
				)

		else
			local matched_tasks =
				get_available_tasks(
					target_master,
					hunterLvl,
					unlocked_lists,
					active_tasks,
					requirements
				)

			if #matched_tasks == 0 then

				master_result
					:tag('p')
					:wikitext(
						"No available rumours from " ..
						target_master ..
						" with the current settings."
					)

			else
				local chance =
					1 / #matched_tasks

				master_result
					:tag('p')
					:wikitext(
						"Chance of receiving any specific available rumour from " ..
						target_master ..
						": " ..
						string.format(
							'%.2f',
							chance * 100
						):gsub('%.?0+$', '') ..
						"%"
					)

				local wikitable =
					mw.html.create('table')
						:addClass(
							'wikitable sortable align-center-1 align-center-2 align-center-4'
						)
						:css('margin-left', 'auto')
						:css('margin-right', 'auto')

				wikitable
					:tag('tr')
						:tag('th')
							:wikitext(
								skillPic('Hunter') ..
								' Level'
							)
							:done()
						:tag('th')
							:attr(
								'colspan',
								2
							)
							:wikitext(
								'Creature'
							)
							:done()
						:tag('th')
							:wikitext(
								'Method'
							)
							:done()
				for _, task in pairs(matched_tasks) do

					local method_icon =
						task.icon
						or method_icons[task.method]

					wikitable
						:tag('tr')
							:tag('td')
								:wikitext(
									task.level
								)
								:done()
							:tag('td')
								:wikitext(
									'[[File:' ..
									task.creature ..
									' icon.png]]'
								)
								:done()
							:tag('td')
								:wikitext(
									'[[' ..
									task.creature ..
									']]'
								)
								:done()
							:tag('td')
								:attr(
									'data-sort-value',
									task.method
								)
								:wikitext(
									'[[File:' ..
									method_icon ..
									'.png|link=|x32px]]'
								)
								:done()
				end

				master_result:node(
					wikitable
				)
			end
		end
	end

	return tostring(results)
end

return p