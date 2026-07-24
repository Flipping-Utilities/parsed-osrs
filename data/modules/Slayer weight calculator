local Paramtest = require( 'Module:Paramtest' )
local Slayerlib = require ('Module:Slayer_task_library' )

local p = {}

function p.invoke_main( frame )
	local result = p.main( frame:getParent().args )
	
	return result
end


function p.tobool(str)
	if str == 'true' then
		return true
	end
	return false
end

function p.main( args )
	-- Handle inputs
	local combatLevel, slayerLevel, defenceLevel, agilityLevel, rangedLevel, strengthLevel, hitpointsLevel, sailingLevel, thievingCheck, firemakingCheck, magicCheck = Paramtest.defaults{
		{ tonumber(args.combatLevel), 1 },
		{ tonumber(args.slayerLevel), 1 },
		{ tonumber(args.defenceLevel), 1 },
		{ tonumber(args.agilityLevel), 1 },
		{ tonumber(args.rangedLevel), 1 },
		{ tonumber(args.strengthLevel), 1 },
		{ tonumber(args.hitpointsLevel), 10 },
		{ tonumber(args.sailingLevel), 1},
		{ args.thievingCheck, true },
		{ args.firemakingCheck, true },
		{ args.magicCheck, true }
	}

	-- Build a master specific block list
	local blocks = {}
	for i = 1, 7 do
	  local key = string.lower(args.master) .. 'Block' .. i
	  local v = args[key]
	  if v == nil or v == '' then
	    v = 'None'
	  end
	  blocks[i] = v
	end

	-- Magic number 23 since this is the highest level required for thieving (magic axes)
	local thievingLevel = 23
	if p.tobool(thievingCheck) == false then
		thievingLevel = 1
	end

	-- Magic number 33 since this is the highest level required for firemaking
	local firemakingLevel = 33
	if p.tobool(firemakingCheck) == false then
		firemakingLevel = 1
	end

	-- Magic number 50 since this is the highest level required for magic
	local magicLevel = 50
	if p.tobool(magicCheck) == false then
		magicLevel = 1
	end
	
	-- Need to create a stats table, unlocks table, quests table, and other table
	local stats = {
		Combat = combatLevel,
		Slayer = slayerLevel,
		Magic = magicLevel,
		Agility = agilityLevel,
		Strength = strengthLevel,
		Firemaking = firemakingLevel,
		Defence = defenceLevel,
		Hitpoints = hitpointsLevel,
		Ranged = rangedLevel,
		Thieving = thievingLevel,
		Sailing = sailingLevel
	}

	-- Since the checkboxes return the name of the unlock (same as in UNLOCK_IDS)
	-- if checked and nil if not checked, this array will only be the names of
	-- activated unlocks.
	local unlocks = { args.seeingRed, args.iHopeYouMithMe, args.watchTheBirdie,
		args.hotStuff, args.reptileGotRipped, args.likeABoss, args.stopTheWyvern, 
		args.basilocked, args.unlockedVamps, args.iWildyMoreSlayer, args.warpedreality,
		args.luredIn, args.wingsSpread, args.chanceOfHeavyFrost
	}

	-- Similarly, this will become a list of completed quests.
	local quests = {
		args.priestInPeril,
		args.dragonSlayerII,
		args.dragonSlayer,
		args.cabinFever,
		args.horrorFromTheDeep,
		args.mourningsEndPartII,
		args.desertTreasure,
		args.regicide,
		args.boneVoyage,
		args.lostCity,
		args.elementalWorkshopI,
		args.deathPlateau,
		args.lunarDiplomacy,
		args.olafsQuest,
		args.contact,
		args.rumDeal,
		args.skippyAndTheMogres,
		args.deathToTheDorgeshuun,
		args.legendsQuest,
		args.ernestTheChicken,
		args.royalTrouble,
		args.hauntedMine,
		args.porcineOfInterest,
		args.SecretsOfTheNorth,
		args.DesertTreasure2,
		args.perilousMoons,
		args.shadowsOfCustodia,
		args.troubledTortugans,
		args.bloodMoonRises
	}
	
	-- List of completed other activities.
	local accessGWD = nil
	if stats["Strength"] >= 60 or stats["Agility"] >= 60 then
		accessGWD = 'Access GWD'
	end
	local other = {
		args.ancientCavern,
		accessGWD,
		args.brittleKey,
		args.accessAbyss
	}
	
	-- Create the player status given our various inputs
	status = Slayerlib.create_status(stats, quests, unlocks, other, blocks)

	-- Get the entire task table of the chosen slayer master.
	masterTable = Slayerlib.get_table(args.master)
	
	-- Get the tables of available and unavailable tasks.
	effectiveTable, unavailableTable = Slayerlib.get_effective_table(masterTable, status, true)

	-- Pass these to calculate percents.
	local results, subResults = p.calculate_percents(effectiveTable, unavailableTable)
	
	-- Render the results
	local resultsDiv = mw.html.create( 'div' )
	local renderedResults = p.render_table(results, (args.master .. ' Main Task Table'), 'Monster Name')
	renderedResults:css({display = 'inline-block',
	float = 'left'})
	resultsDiv:node(tostring(renderedResults))
	if next(subResults) ~= nil then
		local renderedSubResults = p.render_table(subResults, (args.master .. ' Boss Subtable'), 'Boss Name')
		renderedSubResults:css({display = 'inline-block'})
		resultsDiv:node(tostring(renderedSubResults))
	end

	return resultsDiv
end

--
-- Calculates the percent chance of getting each task from effectiveTable.
--
-- @param effectiveTable {table} A table of all tasks the player can be assigned.
-- @param unavailableTable {table} A table of all tasks the player cannot be assigned.
--
-- @return {table} Returns a table that contains the task name as key and the
--					percent chance (decimal form) of getting it as the value.
--
function p.calculate_percents(effectiveTable, unavailableTable)
	local totalWeight = 0
	for k, v in pairs(effectiveTable) do
		totalWeight = totalWeight + v['weight']
	end

	local percentageTable = {}
	local subPercentageTable = {}
	for k, v in pairs(effectiveTable) do
		if v['subtable'] ~= nil then
			subtablePercents = p.calculate_percents(v['subtable'], v['unavailableSubtable'])
			subtableMult = v['weight']/totalWeight
			for sK, sV in pairs(subtablePercents) do
				subPercentageTable[sK] = sV*subtableMult
			end
		end
		percentageTable[v['name']] = v['weight']/totalWeight
	end

	for k, v in pairs(unavailableTable) do
		percentageTable[v['name']] = 0
	end
	
	return percentageTable, subPercentageTable
end


function pairs_by_keys(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
    	i = i + 1
    	if a[i] == nil then return nil
    	else return a[i], t[a[i]]
    	end
	end
	return iter
end
    
-- Render the results table.
function p.render_table(results, headerName, monsterColumnTitle)
	local resultsTable = mw.html.create( 'table' )
	resultsTable:addClass( 'wikitable' )
		:addClass( 'sortable')
		:addClass( 'align-center-1' )
		:tag( 'tr' )
			:tag( 'th' )
				:wikitext( headerName )
				:attr( 'colspan', 2 )
			:done()
		:done()
		:tag( 'tr' )
			:tag( 'th' )
				:wikitext( monsterColumnTitle )
			:done()
			:tag( 'th' )
				:wikitext( 'Assignment Chance')
			:done()
		:done()
	:done()

	for k, v in pairs_by_keys(results) do
		resultsTable:tag( 'tr' )
			:tag( 'td' )
				:wikitext( k )
			:done()
			:tag( 'td' )
				:wikitext( string.format("%.2f", 100*v ) .. "%")
				:attr( 'align', 'right' )
			:done()
		:done()
	end

	return resultsTable
end

return p