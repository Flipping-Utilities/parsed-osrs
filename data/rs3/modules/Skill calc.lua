--[=[
	dependencies
	[[Module:Addcommas]]
	[[Module:Tables]]
	[[Module:Currency]]
	[[Module:GETotal]]
	[[Module:Number]]
	[[Module:Experience]]
	[[Module:Silverhawks/data]]
	[[Module:Skill_calc/eltGenerator]]
	[[Module:Skill_calc/bonusGenerator]]
	TODO
		Get input on bonus stacking
		Making a module to handle bxp jericowrahl 11:25 am MST 11/02/18

		Note: Once all existing calculators have been converted, this Module will be cleaned
			  up to remove any spaghetti code.

		To change data in this calculator, navigate to its appropriate page:
			e.g. Module:Skill calc/SKILLNAME/data
		Follow the guides on that page and try to emulate the items around it.
--]=]
-- <nowiki>

local p = {}

local checkType, checkTypeForNamedArg
do
	local _libraryUtil = require("libraryUtil")
	checkType = _libraryUtil.checkType
	checkTypeForNamedArg = _libraryUtil.checkTypeForNamedArg
end
local commas     = require("Module:Addcommas")._add
local tables     = require("Module:Tables")
local currency   = require("Module:Currency")._amount
local gePrice    = require("Module:GETotal")._quantity
local numbers    = require("Module:Number")._round


local level, xp
do
	local _module_experience = require("Module:Experience")
	level, xp = _module_experience.level_at_xp, _module_experience.xp_at_level
end

local featherExp = mw.loadData("Module:Silverhawks/data")
local getArgs    = require("Module:Arguments").getArgs
local yn         = require("Module:Yesno");

-- This houses most of the processing power
local eltGenerator   = require("Module:Skill_calc/eltGenerator")
local bonusGenerator = require("Module:Skill_calc/bonusGenerator")

local displayExp, remainingExp, calculateBonus, insertAfterNeeded, getSelectedUrn, getUrnTotalXpMultiplier, canUseUrnForItem, calculateUrnsNeeded, calculateUrnUsage, silverhawkFeathers, wildernessAC, findItem, sortTable, getPrice

local function copySequence(src)
	checkType("copySequence", 1, src, "table")
	local dst = {}
	for i, v in ipairs(src) do
		dst[i] = v
	end
	return dst
end

local function loadSkillData(args)
	checkType("loadSkillData", 1, args, "table")

	local skill, disp = args.skill, args.disp
	checkTypeForNamedArg("loadSkillData", "skill", skill, "string")
	checkTypeForNamedArg("loadSkillData", "disp", disp, "string")

	local moduleName = skill
	local isData, dataRet

	local subtype = disp
	if skill == "Slayer" and disp == "Assignments" then
		subtype = args.creature
		checkTypeForNamedArg("loadSkillData", "creature", subtype, "string")
		moduleName = "Slayer/Assignments"
		isData, dataRet = pcall(mw.loadData, "Module:Skill calc/Slayer/Assignments/data")
	else
		if skill == "Smithing" and disp == "Equipment" then
			subtype = args.equipment
			checkTypeForNamedArg("loadSkillData", "equipment", subtype, "string")
		end
		isData, dataRet = pcall(mw.loadData, "Module:Skill calc/" .. skill .. "/data")
	end

	local data
	if isData then
		-- `mw.loadData` compatible
		return dataRet[subtype]
	end

	-- Module is a function, must use `require`
	dataRet = require("Module:Skill calc/" .. moduleName .. "/data")
	if skill == "Slayer" and disp == "Assignments" then
		return dataRet(disp, subtype)
	else
		return dataRet(subtype)
	end
end
-- Exported for testing
p._loadSkillData = loadSkillData

function p.noValue(frame)
	local args         = getArgs(frame)
	local pctExpBoost  = 0 -- Account for outfits, avatar, tools, etc
	local flatExpBoost = 0 -- Account for flat experience boosts
	local links, elts
	local prayerBoost -- This is needed to account for popular methods

	local message, testMessage
	if args.testing == "active" then
		testMessage = "This calculator is being used to test new features."
	end
	-- These sub-sections have different table elts than their parent skill
	local exceptions = {
		"Agility-Other",
		"Divination-Boons",
		"Divination-Dungeoneering",
		"Divination-Hall of Memories",
		"Divination-Hall of Memories (2 tick)",
		"Divination-Memory-storage bots",
		"Divination-Other",
		"Farming-Curing Animals",
		"Farming-Raising Animals",
		"Farming-Manure",
		"Farming-Testing",
		"Firemaking-Barbarian",
		"Firemaking-Char",
		"Firemaking-Other",
		"Firemaking-Incense Sticks (scratch + ashing)",
		"Prayer-Incense sticks",
		"Fishing-Dungeoneering",
		"Flatpacks",
		"Forging",
		"Invention-Manufacturing",
		"Invention-Manufacturing - Ancient",
		"Masters",
		"Milestones",
		"Mining-Gems",
		"Multiples",
		"Rooms",
		"Runespan - Free",
		"Runespan - Members",
		"Scrolls",
		"Summoning-Pets",
		"Summoning-Dungeoneering - Pouches",
		"Slayer-Assignments",
		"Tiaras",
		"Thieving-Sorceress Garden",
		"Thieving-Safes",
		"Woodcutting-Dungeoneering",
		"Woodcutting-Other",
	}
	local exceptionsAgility = { "Milestones", "Multiples", "Other" }
	local exceptionsDiv = {
		"Conversion",
		"Conversion /w Energy",
		"Divine locations",
		"Milestones",
		"Signs and Portents",
		"Transmutation",
	}
	local exceptionsSlayer   = { "Items", "Masters", "Milestones" }
	local exceptionsSmithing = { "Kethsian", "Masterwork (unfinished)", "Obsidian" }
	local bonusExceptions    = { "Dungeoneering", "Blast furnace" }
	local abyssExceptions    = {
		"Impure Runes",
		"Pouches",
		"Runespan - Free",
		"Runespan - Members",
		"Tiaras",
	}
	local boonExceptions     = {
		"Boons",
		"Divine locations",
		"Dungeoneering",
		"Hall of Memories",
		"Hall of Memories (2 tick)",
		"Memory-storage bots",
		"Milestones",
		"Other",
		"Signs and Portents",
		"Transmutation",
	}
	local urnExceptions      = { "Urns", }
	-- These skills have no special considerations in Dungeoneering
	local basicDungeons      = { "Mining", "Woodcutting" }
	-- Elite skills
	local eliteSkills        = { ["Invention"] = true,	}
	local freeToPlay = {
		"Free-to-Play",
		"Runecrafting-Runespan - Free",
	}
	local isEliteSkill = eliteSkills[args.skill] or false
	
	-- Hold bonuses and boosts
	local bonusPct = pctExpBoost

	-- Double Experience Weekend
	if tonumber(args.dxp) == 1 then
		pctExpBoost = pctExpBoost + 1.0
	end

	-- Torstol Incense Sticks (0.5% base XP boost per potency level)
	if args.torstol and args.torstol ~= "None" then
		local torstol_potency = tonumber(args.torstol) or 0
		pctExpBoost = pctExpBoost + (0.005 * torstol_potency)
	end

	-- Gather all relative experience boosts to find new base experience
	if not (args.avatar == nil) and not (args.disp == "Urns") then
		pctExpBoost = pctExpBoost
			+ bonusGenerator({
				skill  = args.skill,
				object = "avatar",
				pieces = tonumber(args.avatar),
			})
	end

	-- Only elite that gives xp boost is dungeoneering
	if not (args.elite == nil) and not (args.disp == "Urns") and args.skill == "Dungeoneering" then
		pctExpBoost = pctExpBoost
			+ bonusGenerator({
				skill  = args.skill,
				object = "elite",
				pieces = tonumber(args.elite),
			})
	end

	-- Some bonuses can not be used on some sub-sections (E.G. Dungeoneering)
	if not findItem(bonusExceptions, args.disp) then
		if (yn(args.abyss) == true or args.abyss == "Demonic Skull")
			and not findItem(abyssExceptions, args.disp)
		then
			pctExpBoost = pctExpBoost
				+ bonusGenerator({
					skill    = args.skill,
					category = args.disp,
					object   = "abyss",
					item     = args.abyss
				})
		end

		if not (args.extra == nil) and args.abyss == nil then
			if not (
				args.skill == "Divination"
				and findItem(boonExceptions, args.disp)
			) then
				pctExpBoost = pctExpBoost
					+ bonusGenerator({
						skill    = args.skill,
						category = args.disp,
						object   = "extra",
						item     = args.extra,
					})
			end
		end

		if not (args.outfit == nil) and not (args.altar=='Ectofuntus') then
			pctExpBoost = pctExpBoost
				+ bonusGenerator({
					skill  = args.skill,
					object = "outfit",
					pieces = tonumber(args.outfit),
				})
		end

		if yn(args.portable) == true then
			pctExpBoost = pctExpBoost
				+ bonusGenerator({
					skill  = args.skill,
					object = "portable",
					pieces = 1,
				})
		end

		if yn(args.workroom) == true then
			pctExpBoost = pctExpBoost
				+ bonusGenerator({
					skill  = args.skill,
					object = "workroom"
				})
		end

		if not (args.tool == nil) then
			flatExpBoost = flatExpBoost
				+ bonusGenerator({
					skill  = args.skill,
					object = "tool",
					item   = args.tool,
				})
		end

		--[=[
		-- Anachronia spa
		if not (args.spa == nil) and args.disp == "Courses" then
			pctExpBoost = pctExpBoost +
				bonusGenerator
					{
						skill       = args.skill,
						category    = args.disp,
						object      = "spa",
						item        = args.spa
					}
		end
		--]=]
		if not (tonumber(args.custom) == nil) then
			if args.abyss == nil or yn(args.abyss) == false then
				pctExpBoost = pctExpBoost
					+ bonusGenerator({
						skill    = args.skill,
						category = args.disp,
						object   = "custom",
						item     = args.custom,
					})
			end
		end

		if not (args.wild == nil) then
			pctExpBoost = pctExpBoost
				+ bonusGenerator({
					skill  = args.skill,
					object = "wild",
					item   = args.wild,
				})
		end

		--[=[
		if not (args.age == nil) and args.disp == "Curing Animals" then
			pctExpBoost = bonusGenerator
					{
						skill       = args.skill,
						category    = args.disp,
						object      = "age",
						item        = args.age
					}
		end
		--]=]
	end

	-- Translate goals into experience comparisons
	-- Calculate iterations to goal
	local currLv, currXP, goalLv, goalXP, remaining, actualRemainig, bonusXP
		= remainingExp(
			args.current, args.goal,
			args.currToggle, args.goalToggle,
			isEliteSkill,
			args.bxp, args.bxpnum
		);

	-- Try to catch Silverhawk feathers early..
	if args.disp == "Silverhawk Feathers" then
		local message = silverhawkFeathers(currLv, goalLv, currXP, goalXP, remaining, pctExpBoost)
		local msgRet  = mw.html.create("div"):css({ ["font-size"] = "16px", ["font-weight"] = "bold" }):wikitext(message)
		return tostring(msgRet)
	end

	-- Prevent the Wilderness Agility Course with no Demonic Skull bonus from displaying a table (same XP for every level)
	-- if args.disp == "Wilderness Agility Course" and (args.wild == "No" or args.wild == "Wilderness Sword 2+") then
	if args.testing == "active" and args.disp == "Wilderness Agility Course" then
		if args.wild == "No" or args.wild == "Wilderness Sword 2+" then
			local message = wildernessAC(currLv, goalLv, currXP, goalXP, remaining, pctExpBoost)
			local msgRet =
				mw.html.create("div"):css({ ["font-size"] = "16px", ["font-weight"] = "normal" }):wikitext(message)
			return tostring(msgRet)
		end
	elseif args.disp == "Wilderness Agility Course" then
		local message = wildernessAC(currLv, goalLv, currXP, goalXP, remaining, pctExpBoost)
		local msgRet =
			mw.html.create("div"):css({ ["font-size"] = "16px", ["font-weight"] = "normal" }):wikitext(message)
		return tostring(msgRet)
	end

	-- Hold skill-related data
	local data = copySequence(loadSkillData(args))

	table.sort(data, function(a, b)
		return sortTable(a, b)
	end)

	local ret = mw.html.create("table"):addClass("wikitable sortable sticky-header")

	--[=[
	-- Find columns from pool
	-- Some require specific parameters due to common phrases
	--]=]
	local eltsRet = mw.loadData("Module:Skill calc/elts")
	elts = eltsRet[args.skill]

	-- Filter out exceptions (re-organized to allow skill-specific filters to catch some exceptions early)
	if args.skill == "Agility" and findItem(exceptionsAgility, args.disp) then
		elts = eltsRet[args.skill .. "-Basic"]
	elseif args.skill == "Construction" and args.disp == "Other" then
		elts = eltsRet[args.skill .. "-Other"]
	elseif args.skill == "Divination" and findItem(exceptionsDiv, args.disp) then
		elts = eltsRet[args.skill .. "-Profit"]
	elseif args.skill == "Slayer" and findItem(exceptionsSlayer, args.disp) then
		elts = eltsRet[args.skill .. "-Basic"]
	elseif args.skill == "Smithing" and args.disp == "Equipment" and findItem(exceptionsSmithing, args.equipment) then
		elts = eltsRet["Smithing-Equipment"]
	elseif findItem(exceptions, args.disp) or findItem(exceptions, args.skill .. "-" .. args.disp) then
		elts = eltsRet[args.skill .. "-" .. args.disp]
	-- All urns share the same format; special exception
	elseif args.disp == "Urns" then
		elts = eltsRet[args.disp]
	-- Cooking in Daemonheim
	elseif args.skill == "Cooking" and args.disp == "Dungeoneering" then
		elts = eltsRet["Cooking-Dungeoneering"]
	-- Basic dungeon format
	elseif args.disp == "Dungeons" then
		elts = eltsRet["Dungeons"]
	-- Dungeons with materials
	elseif string.find(args.disp, "Dungeoneering - ") then
		elts = eltsRet["Dungeons-Materials"]
	-- Hunter methods with bait
	elseif
		args.skill == "Hunter"
		and (args.disp == "Nets and Sprites" or args.disp == "Deadfall and Pitfall" or args.disp == "Box Trapping")
	then
		elts = eltsRet["Hunter-Bait"]
	elseif args.skill == "Hunter" and args.disp == "Big Game Hunting" then
		elts = eltsRet["Hunter-BGH"]
	elseif args.testing == "active" and (args.skill == "Hunter" and args.disp == "Box Trapping") then
		elts = eltsRet["Hunter-Anachronia"]
	elseif args.skill == "Fishing" and args.disp == "Deep Sea" then
		elts = eltsRet["Fishing-Deep Sea"]
	end


	local subCategoryAllowsUrns = true
	local subCategoryIsFreeToPlay = false

	if args.skill ~= nil and args.disp ~= nil then
		subCategoryAllowsUrns = not (
			findItem(urnExceptions, args.disp)
			or findItem(urnExceptions, args.skill .. "-" .. args.disp)
		)

		subCategoryIsFreeToPlay = findItem(freeToPlay, args.disp)
			or findItem(freeToPlay, args.skill .. "-" .. args.disp)
	end

	local showUrnsNeeded = subCategoryAllowsUrns
		and args.urn ~= nil
		and args.urn ~= ""
		and args.urn ~= "None"

	local urnColumn
	local selectedUrnData
	local selectedUrnIsMembers = false

	if showUrnsNeeded then
		selectedUrnData = getSelectedUrn(args)
		showUrnsNeeded  = selectedUrnData ~= nil
	end

	if selectedUrnData then
		selectedUrnIsMembers = selectedUrnData.members == true
	end

	if showUrnsNeeded then
		elts, urnColumn = insertAfterNeeded(elts, "# urns")
	end

	tables._row(ret:tag("tr"), elts, true)

	if args.skill == "Crafting" then
		if
			yn(args.amuletOfOfferings) == true
		then
			pctExpBoost = pctExpBoost + 0.03
		end
	end

	for _, v in ipairs(data) do
		-- Leave common calculations outside of the function calls
		-- Material count
		local mcount = 1
		if v.mcount then
			mcount = v.mcount
		end

		-- Get total cost of materials
		local cost = 0
		local productCost = 0
		-- For magic spells using elemental staff
		local elementalCost = 0

		if v.material then
			-- Adding scroll of cleansing effect
			if yn(args.SOCleansing) == true then
				for i, w in ipairs(v.material) do
					if (i % 2) > 0 then
						if type(w) == "number" then
							v.material[i] = w
								* ((1 - (1 / (10 - 1) / (table.maxn(v.material) / 2 - 1))) ^ 1)
									^ (math.min(i, 2) - 1) -- Taking into account scroll of cleansing on all but the first ingredient
						end
					end
				end
			end

			if (v.mtrade ~= 0) or ((args.disp == "Urns") and not v.currency) then
				cost = gePrice(v.material, mcount)
				if args.skill == "Magic" then
					-- Gets a material list without elemental runes
					local nonElementalMaterial = {}
					local nonElementalCount = 0

					for i,val in ipairs(v.material) do
						local mname = v.material[i+1]
						if i % 2 == 1 and not(string.lower(mname) == "air rune" or string.lower(mname) == "water rune" or string.lower(mname) == "earth rune" or string.lower(mname) == "fire rune") then
							table.insert(nonElementalMaterial, val)
							table.insert(nonElementalMaterial, mname)
							nonElementalCount = nonElementalCount + 1
						end
					end
					elementalCost = gePrice(nonElementalMaterial, nonElementalCount)
				end
			end
		elseif args.skill == "Prayer" and args.disp ~= "Incense sticks" then
			if not v.currency then
				cost = gePrice({ 1, v.name }, 1)
			else
				cost = v.value
			end
		elseif args.disp == "Scrolls" then
			cost = gePrice({ 1, v.familiarIcon }, 1)
		end

		if
			v.trade ~= 0
			and not v.currency
			and (
				args.skill    ~= "Agility"
				and args.skill ~= "Construction"
				and args.skill ~= "Farming"
				and args.skill ~= "Dungeoneering"
				and not (args.skill == "Prayer" and args.disp ~= "Incense sticks")
				and args.skill ~= "Invention"
				and args.skill ~= "Slayer"
			)
		then
			if
				(
					args.skill    == "Woodcutting"
					or args.skill == "Mining"
					or args.skill == "Runecrafting"
					or args.skill == "Divination"
				) and not (v.icon == nil)
			then
				productCost = gePrice({ 1, v.icon }, 1)
			elseif args.skill == "Hunter" then
				if v.product then
					productCost = gePrice({ 1, v.product }, 1)
				end
			else
				productCost = gePrice({ 1, v.name }, 1)
			end
		end
		-- If a multiplier is set, it is applied to the product's value for profit calculations
		if v.multiplier then
			productCost = productCost * v.multiplier
		end

		-- If a portable location is being used, multiply the productCost by however many extra products the portable gives
		local portableBoost       = 0
		local multiplicativeBoost = 0 -- This boost stacks entirely multiplicatively with everything.  EG factory outfit
		local additiveBoost       = 0 -- This boost stacks additively with the portable boost. EG modified botanist's mask

		if yn(args.brooch) == true then
			portableBoost = portableBoost * 2
		end
		productCost = math.floor(productCost * (1 + portableBoost + additiveBoost) * (1 + multiplicativeBoost))

		-- Check for other currencies
		if (v.currency or v.currency2) and not (args.skill == "Prayer" and args.disp ~= "Incense sticks") then
			productCost = v.value
			if v.materialCost then
				cost = v.materialCost
			end
		end

		local portableMaterialCostReduction = 0
		if args.skill == "Fletching" then
			if
				yn(args.portable) == true
				and (args.disp    == "Arrows"
				or args.disp      == "Bolts"
				or args.disp      == "Darts"
				or args.disp      == "Bows - Unstrung")
			then
				portableMaterialCostReduction = 0.1
			end
		end

		if args.skill == "Crafting" then
			if
				yn(args.portable) == true
			then
				portableMaterialCostReduction = 0.1
			end
		end

		if args.brooch == "true" then
			portableMaterialCostReduction = portableMaterialCostReduction * 2
		end

		if portableMaterialCostReduction ~= 0 then
			cost = cost * (1 - portableMaterialCostReduction)
		end

		-- Brewing makes two batches
		if args.disp == "Brewing" then
			productCost = productCost * 2
		end

		-- Establish any experience boosts
		local abyss = false
		if (yn(args.abyss) == true or args.abyss == "Demonic Skull")
			and not findItem(abyssExceptions, args.disp)
		then
			abyss = true
		end

		local unitExp = calculateBonus({
			base      = v.xp,
			currLv    = currLv,
			boost     = pctExpBoost,
			-- boostSw = pctExpBoostSw,
			flatBoost = flatExpBoost,
			abyss     = abyss,
			settings  = args,
			item      = v,
		})

		-- Calculate needed iterations
		local needed     = 0
		local urnsNeeded = 0

		if not (unitExp == 0 or unitExp == nil) then
			if selectedUrnData
				and subCategoryAllowsUrns
				and not (subCategoryIsFreeToPlay and selectedUrnIsMembers)
				and canUseUrnForItem(selectedUrnData, v)
			then
				needed, urnsNeeded = calculateUrnUsage({
					remaining    = remaining,
					actionExp    = unitExp,
					actionBaseXp = v.xp,
					baseXpToFill = selectedUrnData.baseXpToFill,
					rewardXp     = selectedUrnData.rewardXp,
				})
			else
				needed = tonumber(math.ceil(remaining / unitExp))
			end
		end

		local generatedElts;
		-- Keep this as the first check to prevent double generation
		if args.testing == "active" then
			-- Pass the current elts as a variable for elt generation
			generatedElts = eltGenerator.generate_elts({
				args = {
					v,
					args,
					unitExp,
					needed,
					remaining,
					cost,
					productCost,
					elts,
					currLv,
					urnsNeeded,
					urnColumn
				},
			})

		-- No Profit, No Loss skills
		else
			if
				args.skill    == "Agility"
				or args.skill == "Thieving"
				or args.skill == "Slayer"
				or args.skill == "Invention"
			then
				elts = eltGenerator.generate_NoProfitNoLoss({ args = { v, unitExp, needed, args, remaining, currLv, urnsNeeded, urnColumn } })

			-- No Loss, Profit skills (Gathering)
			elseif
				args.skill    == "Mining"
				or args.skill == "Fishing"
				or args.skill == "Woodcutting"
				or args.skill == "Runecrafting"
				or args.skill == "Divination"
				or args.skill == "Hunter"
			then
				elts = eltGenerator.generate_ProfitNoLoss({
					args = { v, unitExp, needed, cost, args, productCost, remaining, currLv, urnsNeeded, urnColumn },
				})

			-- No Profit, Loss skills (Survival)
			elseif
				(args.skill    == "Firemaking" and not string.find(args.disp, "Incense"))
				or (args.skill == "Prayer" and args.disp ~= "Incense sticks")
				or args.skill  == "Construction"
			then
				elts = eltGenerator.generate_NoProfitLoss({
					args = { v, unitExp, needed, cost, args, productCost, remaining, currLv, nil, urnsNeeded, urnColumn },
				})
			elseif args.skill == "Magic"
			then
				elts = eltGenerator.generate_NoProfitLoss({
					args = { v, unitExp, needed, cost, args, productCost, remaining, currLv, elementalCost, urnsNeeded, urnColumn },
				})

			-- Profit and Loss skills (Artisan)
			-- Fletching, Cooking, Farming, Smithing, Herblore, Summoning
			else
				elts = eltGenerator.generate_ProfitLoss({
					args = { v, unitExp, needed, cost, args, productCost, remaining, currLv, urnsNeeded, urnColumn  },
				})
			end
		end

		-- Allow for items with no level requirement
		local levelRequired = 1
		if args.skill == "Slayer" and (args.disp == "Assignments" or args.disp == "Monsters") then
			if v.level2 then
				levelRequired = v.level2
			end
		else
			if v.level then
				levelRequired = v.level
			end
		end
		levelRequired = math.floor(levelRequired)
		local class = "table-bg-yellow sortbottom"
		if levelRequired > goalLv then
			class = "table-bg-red sortbottom"
		elseif levelRequired <= currLv then
			class = "table-bg-green"
		end

		if args.testing == "active" then
			tables._row(ret:tag("tr"):addClass(class), generatedElts, false)
		else
			tables._row(ret:tag("tr"):addClass(class), elts, false)
		end
	end

	message = displayExp({
		display   = args.disp,
		skill     = args.skill,
		remaining = remaining,
		goalLv    = goalLv,
		goalXP    = goalXP,
		currLv    = currLv,
		currXP    = currXP,
	})

	if args.testing == "active" then
		local testNotice =
			mw.html.create("div"):css({ ["font-size"] = "16px", ["font-weight"] = "bold" }):wikitext(testMessage)
		return tostring(testNotice) .. tostring(message) .. tostring(ret)
	else
		return tostring(message) .. tostring(ret)
	end
end

--[=[ insertAfterNeeded
-- Copies a header table and inserts a new header after the # needed column
-- Inputs:
--      elts            table headers
--      value           header value to insert
--  Returns:
--      copied table headers,
--      index where the new header was inserted
--]=]
function insertAfterNeeded(elts, value)
	local ret = copySequence(elts)

	for i, header in ipairs(ret) do
		if header == "# needed" then
			table.insert(ret, i + 1, value)
			return ret, i + 1
		end
	end

	return ret, nil
end

--[=[ getUrnTotalXpMultiplier
-- Gets the total XP multiplier represented by an urn row
-- Inputs:
--      urn			urn data row
-- Returns:
--      total XP multiplier for the urn row
--]=]
function getUrnTotalXpMultiplier(urn)
	local title       = urn.title or ""
	local name        = urn.name  or ""
	local isEnhancer  = string.find(title, "Urn Enhancer", 1, true) ~= nil
	local isExquisite = string.find(name, "Exquisite", 1, true) ~= nil

	if isEnhancer and isExquisite then
		return 1.3125
	elseif isEnhancer or isExquisite then
		return 1.25
	end

	return 1.2
end

--[=[ getSelectedUrn
-- Finds and returns the selected urn from the skill's Urns data
-- Inputs:
--      settings		calculator arguments
-- Returns:
--      selected urn data if a matching urn is found,
--      nil if no urn is selected or no matching urn is found
--]=]
function getSelectedUrn(settings)
	local selectedUrn = settings.urn
	local useEnhancer = yn(settings.urnEnhancer) or false

	if selectedUrn == nil or selectedUrn == "" or selectedUrn == "None" then
		return nil
	end

	if settings.disp == "Urns" then
		return nil
	end

	local urns = loadSkillData({
		skill = settings.skill,
		disp  = "Urns",
	})

	if urns == nil then
		return nil
	end

	for _, urn in ipairs(urns) do
		local title      = urn.title or ""
		local isEnhancer = string.find(title, "Urn Enhancer", 1, true) ~= nil

		if string.find(urn.name, selectedUrn, 1, true)
			and isEnhancer == useEnhancer
		then
			local totalXp           = tonumber(urn.xp) or 0
			local totalXpMultiplier = getUrnTotalXpMultiplier(urn)
			local baseXpToFill      = totalXp / totalXpMultiplier

			return {
				name         = urn.name,
				title        = urn.title,
				tier         = selectedUrn,
				isEnhancer   = isEnhancer,
				totalXp      = totalXp,
				baseXpToFill = baseXpToFill,
				rewardXp     = totalXp - baseXpToFill,
				maxLevel     = urn.maxLevel,
				material     = urn.material,
				mcount       = urn.mcount,
				members      = urn.members,
			}
		end
	end

	return nil
end

--[=[ calculateUrnsNeeded
-- Calculates and returns the number of completed urns filled by a number of actions
-- Inputs:
--      needed			required iterations for goal
--      actionBaseXp	base experience gained per action
--      baseXpToFill	base experience needed to fill one urn
-- Returns:
--      number of completed urns
--]=]
function calculateUrnsNeeded(needed, actionBaseXp, baseXpToFill)
	needed       = tonumber(needed)       or 0
	actionBaseXp = tonumber(actionBaseXp) or 0
	baseXpToFill = tonumber(baseXpToFill) or 0

	if needed <= 0 or actionBaseXp <= 0 or baseXpToFill <= 0 then
		return 0
	end

	return math.floor((needed * actionBaseXp) / baseXpToFill)
end

--[=[ calculateUrnUsage
-- Finds and returns the amount of actions and completed urns needed to reach the goal
-- Inputs:
--      source      table of urn calculation values
--          - remaining		experience remaining to reach the goal
--          - actionExp		experience gained from the training method per action
--          - actionBaseXp	base experience gained from the training method per action
--          - baseXpToFill	base experience needed to fill one urn
--          - rewardXp		experience rewarded by one completed urn
--  Returns:
--      actions needed to reach the goal,
--      completed urns needed to reach the goal
--]=]
function calculateUrnUsage(source)
	local remaining    = tonumber(source.remaining)    or 0
	local actionExp    = tonumber(source.actionExp)    or 0
	local actionBaseXp = tonumber(source.actionBaseXp) or 0
	local baseXpToFill = tonumber(source.baseXpToFill) or 0
	local rewardXp     = tonumber(source.rewardXp)     or 0

	if remaining <= 0 or actionExp <= 0 then
		return 0, 0
	end

	if actionBaseXp <= 0 or baseXpToFill <= 0 or rewardXp <= 0 then
		local actions = tonumber(math.ceil(remaining / actionExp)) or 0
		return actions, calculateUrnsNeeded(actions, actionBaseXp, baseXpToFill)
	end

	local function totalExpForActions(actions)
		local urnsFilled = calculateUrnsNeeded(actions, actionBaseXp, baseXpToFill)

		return (actions * actionExp) + (urnsFilled * rewardXp)
	end

	local low  = 0
	local high = tonumber(math.ceil(remaining / actionExp)) or 0

	if high < 1 then
		high = 1
	end

	while totalExpForActions(high) < remaining do
		high = high * 2
	end

	while low < high do
		local mid = math.floor((low + high) / 2)

		if totalExpForActions(mid) >= remaining then
			high = mid
		else
			low  = mid + 1
		end
	end

	return high, calculateUrnsNeeded(high, actionBaseXp, baseXpToFill)
end

--[=[ canUseUrnForItem
-- Checks whether an urn can be filled by the current training method
-- Inputs:
--      urnData		selected urn data
--      item		current training method row
-- Returns:
--      true if the urn can be used for the method,
--      false otherwise
--]=]
function canUseUrnForItem(urnData, item)
	if urnData == nil or item == nil then
		return false
	end

	if item.urns ~= nil and yn(item.urns) == false then
		return false
	end

	local maxLevel  = tonumber(urnData.maxLevel)
	local itemLevel = tonumber(item.level)

	if maxLevel == nil or itemLevel == nil then
		return false
	end

	if maxLevel == -1 then
		return true
	end

	return itemLevel <= maxLevel
end

--[=[ displayExp
-- Creates a text string output for the goal calculations
-- Inputs:
--      params      Incoming parameters to generate string
--          - display   Current set of sub-categorical data
--          - skill     Current skill
--          - remaining Experience needed for goal
--          - goalXP    Expected experience
--          - goalLv    Expected level
--          - currXP    Current experience
--          - currLv    Current level
-- Returns:
--      msg     String created from params
--          -   this may be appended with a warning specifically for flatpacks
--]=]
function displayExp(params)
	local msg -- Converted from message to avoid conflict
	local display   = params.display
	local skill     = params.skill
	local remaining = params.remaining
	local goalXP    = params.goalXP
	local goalLv    = params.goalLv
	local currXP    = params.currXP
	local currLv    = params.currLv

	msg = "To train "
		.. skill
		.. " from "
		.. commas(currXP)
		.. " experience (level "
		.. currLv
		.. ") to "
		.. commas(goalXP)
		.. " experience (level "
		.. goalLv
		.. "), "
		.. commas(remaining)
		.. " experience is required."

	if display == "Flatpacks" then
		msg = msg
			.. "<div style='color:red; font-size:0.9em;'>Levels refer to the minimum needed to use the associated workbench if otherwise lower.</div>"
	elseif display == "Boons" then
		msg = msg .. "<div style='color:red; font-size:0.9em;'>Each boon can only be made once.</div>"
	end
	local ret = mw.html.create("div"):css({ ["font-size"] = "1.1em", ["font-weight"] = "bold" }):wikitext(msg)
	return tostring(ret)
end

--[=[ remainingExp
-- Finds and returns experiences and levels based on inputs
-- Inputs:
--      curr            current value
--      goal            goal value
--      curr_intent     what the current is (level/experience)
--      goal_intent     what the goal is (level/experience/additional experience)
--      isElite         whether the current skill is an [[Elite skill]]
--      hasBxp          whether the current skill has stored bonus experience
--      bxpNum          the amount of stored bonus experience
-- Returns:
--      current level,
--      current experience,
--      goal level,
--      goal experience,
--      base experience needed,
--      actual experience remaining,
--      the amount of bonus experience to use in calculations
--]=]
function remainingExp(
	curr, goal,
	curr_intent, goal_intent,
	isElite,
	hasBxp, bxpNum
)
	local goalLevel, currLevel, goalXP, currXP
	local elite = nil
	if isElite then
		elite = "1"
	end

	if curr_intent == "Level" and tonumber(curr) <= 120 then
		currLevel = tonumber(curr)
		currXP    = xp({ args = { curr, elite = elite } })
	else
		currLevel = level({ args = { curr, elite = elite } })
		currXP    = tonumber(curr)
	end

	if goal_intent == "Level" and tonumber(goal) <= 120 then
		goalLevel = tonumber(goal)
		goalXP    = xp({ args = { goal, elite = elite } })
	elseif goal_intent == "Additional Experience" then
		goalXP    = tonumber(goal) + currXP
		goalLevel = level({ args = { math.min(goalXP, 200000000), elite = elite } })
	else
		goalLevel = level({ args = { goal, elite = elite } })
		goalXP    = tonumber(goal)
	end

	local bonusXP = 0;
	if yn(hasBxp) then
		bonusXP = tonumber(bxpNum) or 0
	end

	-- Prevent negative values
	local actualRemaining = math.ceil(goalXP - currXP);
	if actualRemaining < 0 then
		actualRemaining = 0;
	end

	local baseExpNeeded = actualRemaining;
	if bonusXP > 0 then
		local consumedBxp = math.min(baseExpNeeded / 2, bonusXP);
		baseExpNeeded = baseExpNeeded - consumedBxp;
	end

	return currLevel, currXP, goalLevel, goalXP, baseExpNeeded,
		actualRemaining, bonusXP;
end

--[=[ calculateBonus
-- Inputs:
--      source        Incoming data
--          - base      Base experience for item
--          - boost     Percent experience boost, expressed as a decimal percentage
--              - ava       Avatar bonus
--              - outfit    Outfit bonus
--              - tools     Extra bonuses
--          - flatBoost Flat experience boost
-- Returns:
--  Numeric value of new base experience including bonuses
--]=]
function calculateBonus(source)
	local total     = source.base -- Base experience
	local currLv    = source.currLv
	local boost     = source.boost -- Bonus percentage
	local boostSw   = source.boostSw -- Value not being set?
	local flatBoost = source.flatBoost
	local abyss     = source.abyss
	local settings  = source.settings -- Calculator
	local item      = source.item -- ../data
	local cLv -- Holder for current level
	local baseXpMultiplier = 1.0

	-- Calculate increase in base multiplier for summoning
	if yn(source.settings.spiritWeaver) == true then
		-- Spirit Weaver relic provides a 50% base xp increase before boosts.
		baseXpMultiplier = baseXpMultiplier + 0.5
	end

	if yn(source.settings.summoningFocus) == true then
		-- Summoning focus provides a 20% base xp increase before boosts.
		baseXpMultiplier = baseXpMultiplier + 0.2
	end
	total = total * baseXpMultiplier
	-- End of summoning XP multipier calculation

	if
		settings.disp == "Wilderness Agility Course"
		or (item.page == "Wilderness Agility Course" and settings.disp ~= "Milestones")
	then
		if settings.disp == "Wilderness Agility Course" then
			cLv = item.level
		else
			cLv = currLv
		end
		if settings.wild == "Demonic Skull" then
			total = total + 498.9
			if cLv > 50 then
				total = (((cLv - 21) * boost) * total)
			end
		elseif settings.wild == "Both" then
			total = ((total * ((cLv - 21) * boost)) + ((((cLv - 21) * boost) + 0.05) * 498.9))
			-- total = ((total*((cLv-21)*boost))+((((cLv-21)*boost)+boostSw)*498.9))
		elseif settings.wild == "Wilderness Sword 2+" then
			-- total = total + (498.9*(1+boostSw))
			total = total + (498.9 * 1.05) -- 1+0.05
		else
			total = total + 498.9
		end
	-- elseif settings.skill == "Agility" and item.name == "Anachronia Agility Course" then
	-- total = total * (1 + boost)
	elseif item.skill == "Firemaking" and item.bonus ~= nil then
		total = total + (item.bonus * (1 + boost))
	-- elseif settings.skill == "Farming" and settings.disp == "Curing Animals" then
	-- total = math.floor((total * source.boost)*10)/10
	-- total = total * source.boost
	else
		total = total * (1 + boost)
	end
	if not (settings == nil) then
		-- Check for additional modifiers. These must be done on an item to item basis
		--  to filter out items that may not be affected by certain boosts
		local potionSetting, vosSetting, auraSetting, aotSetting, altarSetting
		if settings.potion then
			potionSetting = settings.potion
		end
		if settings.vos then
			if yn(settings.vos) == true then
				vosSetting = "VoiceOfSeren"
			else
				vosSetting = "No"
			end
		end
		if settings.aura then
			auraSetting = settings.aura
		end
		if settings.aot then
			if yn(settings.aot) == true then
				aotSetting = "AvgOverTime"
			else
				aotSetting = "No"
			end
		end
		if settings.altar
			and item.name ~= "Cleansing crystal"
			and item.name ~= "Colossal bone"
			and settings.disp ~= "Incense sticks"
		then
			altarSetting = settings.altar
		else
			altarSetting = "None"
		end

		-- Check for JuJu potion modifier
		if potionSetting ~= nil then
			total = total
				* bonusGenerator({
					skill      = settings.skill,
					name       = item.name,
					object     = "potion",
					item       = potionSetting,
					setting    = vosSetting,
					subSetting = aotSetting,
				})
		end

		-- Check for VoS modifier
		if vosSetting ~= "No" then
			total = total
				* bonusGenerator({
					skill      = settings.skill,
					name       = item.name,
					object     = "VoiceOfSeren",
					setting    = potionSetting,
					subSetting = aotSetting,
				})
		end

		-- Check for aura modifier
		if auraSetting ~= "No" then
			total = total
				* bonusGenerator({
					skill  = settings.skill,
					name   = item.name,
					object = "aura",
					item   = auraSetting,
				})
		end

		-- Check for altar modifier
		if altarSetting ~= "None" then
			total = total
				* bonusGenerator({
					skill   = settings.skill,
					name    = item.name,
					object  = "altar",
					item    = altarSetting,
					setting = settings.disp,
				})
		end
	end
	-- If the abyss is active, do not add 1
	--   Not sure how it all stacks :: NEED INPUT
	if source.abyss == true then
		total = source.base * source.boost
	end
	total = total + source.flatBoost

	return numbers(total, 1)
end

--[=[ silverhawkFeathers
--  Inputs:
--      currlv      Current level
--      goalLv      Goal Level
--      currXP      Current Experience
--      goalXP      Goal Experience
--      remaining   Difference from goal
--      pctExpBoost Calculated boost to base exp
--  Returns:
--      String including needed feathers, remaining experience, and current GE cost for feathers
--]=]
function silverhawkFeathers(currLv, goalLv, currXP, goalXP, remaining, pctExpBoost)
	local feathers  = 0
	local featherXP
	local desc      = ""
	local workingXP = currXP
	local workingLv = currLv
	while workingXP < goalXP do
		feathers  = feathers + 1
		workingLv = level({ args = { workingXP } })
		featherXP = featherExp[workingLv] + (featherExp[workingLv] * pctExpBoost)

		workingXP = workingXP + featherXP
	end
	return "To train from "
		.. commas(currXP)
		.. " experience (level "
		.. currLv
		.. ") to "
		.. commas(goalXP)
		.. " experience (level "
		.. goalLv
		.. "), "
		.. commas(remaining)
		.. " experience is needed. This requires '''"
		.. commas(feathers)
		.. " [[Silverhawk feathers|feathers]]''' and, at current GE Prices, will cost "
		.. currency(gePrice({ feathers, "Silverhawk feathers" }, 1), "coins")
		.. " coins."
end

function wildernessAC(currLv, goalLv, currXP, goalXP, remaining, pctExpBoost)
	local nXP      = numbers(571.4 * (1 + pctExpBoost), 1)
	local lapsToDo = numbers(remaining / nXP)

	return "To train from '''"
		.. commas(currXP)
		.. " experience''' (level "
		.. currLv
		.. ") to '''"
		.. commas(goalXP)
		.. " experience''' (level "
		.. goalLv
		.. "), '''"
		.. commas(remaining)
		.. " experience''' is needed.<br/>This requires '''"
		.. commas(lapsToDo)
		.. " laps''' to be completed at '''"
		.. nXP
		.. " XP''' per lap."
end

-- Make it easier to find items in a set
-- A little heavy : if someone can find a better way, replace.
function findItem(list, item)
	local status = false
	for _, v in pairs(list) do
		if v == item then
			status = true
			break
		end
	end
	return status
end

function sortTable(a, b)
	local value = false
	if a.level and b.level and a.level ~= b.level then
		value = a.level < b.level
	elseif a.name and b.name and a.name == b.name and (a.title or b.title) then
		if a.title and not b.title then
			value = a.title < b.name
		elseif not a.title and b.title then
			value = a.name < b.title
		else
			value = a.title < b.title
		end
	else
		value = a.xp < b.xp
	end

	return value
end

--[[
Modified version of GETotal.
Will add together the price of a * 4 and b / 4
Can recognize and parse vulgar fractions
All fractions and decimals will be truncated off the final price
Technically unlimited

To use:
variable 'a' = array of {quantity, value, "item name", etc...}
variable 'b' = number of unique items to be included
--]]
function getPrice(a, b)
	local values = a or {}
	local count  = b or 0
	local price  = 0
	local prices = {}

	for i = 1, (count * 3), 3 do
		local valuex = a[i + 1]
		local itemx  = a[i + 2]
		if itemx then
			local qtyx   = a[i] or 1
			local qtyret = tonumber(qtyx) or frac(qtyx) or 1
			table.insert(prices, math.floor(valuex * qtyret))
		end
	end

	for _, v in ipairs(prices) do
		price = price + v
	end
	return price
end


return p