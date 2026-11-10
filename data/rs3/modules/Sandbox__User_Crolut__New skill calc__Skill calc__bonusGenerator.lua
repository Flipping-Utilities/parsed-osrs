local p = {}

local checkType, checkTypeForNamedArg
do
	local libraryUtil = require("libraryUtil")
	checkType            = libraryUtil.checkType
	checkTypeForNamedArg = libraryUtil.checkTypeForNamedArg
end

local experienceBuffs = require("Module:Sandbox/User:Crolut/New skill calc/Calculator/Experience Buffs")
local buffFilters     = require("Module:Sandbox/User:Crolut/New skill calc/Skill calc/buffFilters")
local common          = require("Module:Sandbox/User:Crolut/New skill calc/Skill calc/common")
local featherExp      = mw.loadData("Module:Silverhawks/data")

local debugLog = common._debugLogger("bonusGenerator")

local level, xp
do
	local experience = require("Module:Experience")
	level, xp = experience.level_at_xp, experience.xp_at_level
end

-- forward declarations
local getSkillCurrent, getCustomLevelBoost, getEffectiveCurrentLevel,
      getMethodLevelSkill, remainingExp, listMatches, whenMatches,
      numberConditionsMatch, ruleMatches, applyExperienceBuffRules,
      normalizeExperienceBuffArgs, calculateLevelBoost, getNoBxpArgs,
      getUrnTotalXpMultiplier, canUseUrnForItem, calculateUrnsForActions,
      calculateAnimalStatMultiplier, calculateRaisingAnimalBonusMultiplier,
      calculateRaisingAnimalXp, calculateRaisingAnimalStageXp,
      calculateCuringAnimalAgeMultiplier, calculateCuringAnimalXp,
      calculateBigGameHunterXp, calculateActionXp, calculateActionTotals,
      calculateBaseMethodActionValues, applyBigGameHunterActionValues,
      applyRaisingAnimalActionValues, applyCuringAnimalActionValues,
      applyMethodSpecialCaseActionValues, getMethodUrnData,
      getSlayerResultFields, makeMethodResult, calculateSilverhawkFeathers,
      calculateWildernessAgilityCourse, calculateMethods,
      getMethodRequiredLevel, getMethodStatus, getSlayerStrategyGuide


-- data/loading and goal helpers --
--[=[ getSkillCurrent
-- Gets the current level or experience input for one skill
-- Inputs:
--      args    calculator arguments
--      skill   optional skill name to check
-- Returns:
--      skill-specific current input, generic current input, or nil
--]=]
function getSkillCurrent(args, skill)
	checkType("getSkillCurrent", 1, args, "table")
	checkType("getSkillCurrent", 2, skill, "string", true)

	local targetSkill = skill or args.skill

	if type(targetSkill) == "string" then
		local skillCurrent = args[targetSkill .. "Current"]

		if skillCurrent ~= nil then
			return skillCurrent
		end
	end

	if skill == nil or targetSkill == args.skill then
		-- Once all calculators use <skill>Current, replace this fallback with:
		-- return nil
		return args.current
	end

	return nil
end

--[=[ getCustomLevelBoost
-- Gets the custom level boost input for one skill
-- Inputs:
--      args    calculator arguments
--      skill   optional skill name to check
-- Returns:
--      custom level boost, or 0 when missing or invalid
--]=]
function getCustomLevelBoost(args, skill)
	checkType("getCustomLevelBoost", 1, args, "table")
	checkType("getCustomLevelBoost", 2, skill, "string", true)

	local targetSkill = skill or args.skill

	if type(targetSkill) == "string" then
		local customLevelBoost = args[targetSkill .. "CustomLvlBuff"]

		if customLevelBoost ~= nil then
			return tonumber(customLevelBoost) or 0
		end
	end

	if skill == nil or targetSkill == args.skill then
		-- Once all calculators use <skill>CustomLvlBuff, replace this
		-- fallback with:
		-- return 0
		return tonumber(args.customLvlBuff) or 0
	end

	return 0
end

--[=[ getEffectiveCurrentLevel
-- Adds one skill's custom level boost to a current level
-- Inputs:
--      currLevel  real current level
--      args       calculator arguments
--      skill      optional skill name to check
-- Returns:
--      current level plus any custom level boost
--]=]
function getEffectiveCurrentLevel(currLevel, args, skill)
	checkType("getEffectiveCurrentLevel", 2, args, "table")
	checkType("getEffectiveCurrentLevel", 3, skill, "string", true)

	return (tonumber(currLevel) or 0) + getCustomLevelBoost(args, skill)
end

--[=[ getMethodLevelSkill
-- Gets the skill used for a method's level requirement
-- Inputs:
--      method  method data row being checked
--      args    calculator arguments
-- Returns:
--      skill name used for the method level requirement
--]=]
function getMethodLevelSkill(method, args)
	checkType("getMethodLevelSkill", 1, method, "table")
	checkType("getMethodLevelSkill", 2, args, "table")

	if type(method.levelSkill) == "string" then
		return method.levelSkill
	end

	return args.skill
end

--[=[ remainingExp
-- Converts the current and goal inputs into comparable levels and XP values,
-- then calculates remaining XP and available stored bonus XP
-- Inputs:
--      curr         current level or experience input
--      goal         target level, experience, or additional experience input
--      curr_intent  whether curr is a Level or Experience value
--      goal_intent  whether goal is Level, Experience, or Additional XP
--      isElite      whether the selected skill uses elite skill XP data
--      hasBxp       whether stored bonus experience is enabled
--      bxpNum       amount of stored bonus experience available
-- Returns:
--      current level, current XP, goal level, goal XP, base XP needed,
--      actual XP remaining, and stored bonus XP available
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
		goalLevel = level({ args = { math.min(goalXP, 200000000),
			elite = elite } })
	else
		goalLevel = level({ args = { goal, elite = elite } })
		goalXP    = tonumber(goal)
	end

	local bonusXP = 0
	if hasBxp == true then
		bonusXP = tonumber(bxpNum) or 0
	end

	-- Prevent negative values
	local actualRemaining = math.ceil(goalXP - currXP)
	if actualRemaining < 0 then
		actualRemaining = 0
	end

	local baseExpNeeded = actualRemaining

	return currLevel, currXP, goalLevel, goalXP, baseExpNeeded,
		actualRemaining, bonusXP
end


-- experience buff filtering --
--[=[ listMatches
-- Checks a rule list against a value, treating a nil rule list as a wildcard
-- that matches all values
-- Inputs:
--      values  optional list of values accepted by the rule
--      value   value being checked against the optional list
-- Returns:
--      true if values is nil or contains value, otherwise false
--]=]
function listMatches(values, value)
	if values == nil then
		return true
	end

	if value == nil then
		return false
	end

	for _, ruleValue in ipairs(values) do
		if ruleValue == value then
			return true
		end
	end

	return false
end

--[=[ whenMatches
-- Checks whether the calculator arguments satisfy every condition in a rule's
-- when table, including boolean values
-- Inputs:
--      when    optional table of required argument values
--      args    calculator arguments being checked against the rule
-- Returns:
--      true if all conditions match or no conditions exist, otherwise false
--]=]
function whenMatches(when, args)
	if when == nil then
		return true
	end

	for argName, expectedValue in pairs(when) do
		local actualValue = args[argName]

		if type(expectedValue) == "boolean" then
			if actualValue ~= expectedValue then
				return false
			end
		elseif actualValue == nil then
			return false
		elseif actualValue ~= expectedValue
			and tostring(actualValue) ~= tostring(expectedValue)
		then
			return false
		end
	end

	return true
end

--[=[ numberConditionsMatch
-- Checks numeric argument conditions that must be above configured values
-- Inputs:
--      conditions  optional argument names and exclusive minimum values
--      args        calculator arguments being checked against the rule
-- Returns:
--      true if every numeric condition matches, otherwise false
--]=]
function numberConditionsMatch(conditions, args)
	if conditions == nil then
		return true
	end

	for argName, minimum in pairs(conditions) do
		local value        = tonumber(args[argName])
		local minimumValue = tonumber(minimum)

		if value == nil
			or minimumValue == nil
			or value <= minimumValue
		then
			return false
		end
	end

	return true
end

--[=[ ruleMatches
-- Checks whether a rule applies to the current skill, category, method name,
-- exclusions, argument values, and numeric argument conditions
-- Inputs:
--      rule    rule containing optional matching conditions
--      method  method data row being calculated
--      args    calculator arguments for the current calculation
-- Returns:
--      true if the rule applies to the method and arguments, otherwise false
--]=]
function ruleMatches(rule, method, args)
	checkType("ruleMatches", 1, rule, "table")
	checkType("ruleMatches", 2, method, "table")
	checkType("ruleMatches", 3, args, "table")

	return listMatches(rule.skill, args.skill)
		and listMatches(rule.disp, args.disp)
		and listMatches(rule.method, method.name)
		and (rule.excludeSkill == nil
			or not listMatches(rule.excludeSkill, args.skill))
		and (rule.excludeDisp == nil
			or not listMatches(rule.excludeDisp, args.disp))
		and (rule.excludeMethod == nil
			or not listMatches(rule.excludeMethod, method.name))
		and whenMatches(rule.when, args)
		and numberConditionsMatch(rule.numberAbove, args)
end

--[=[ applyExperienceBuffRules
-- Applies ordered Experience Buff rules to one working argument table
-- Inputs:
--      ret     copied calculator argument table to modify
--      method  method data row being calculated
--      rules   ordered list of rules to apply
--]=]
function applyExperienceBuffRules(ret, method, rules)
	checkType("applyExperienceBuffRules", 1, ret, "table")
	checkType("applyExperienceBuffRules", 2, method, "table")
	checkType("applyExperienceBuffRules", 3, rules, "table")

	for _, rule in ipairs(rules) do
		if ruleMatches(rule, method, ret) then
			local before = mw.clone(ret)
			for _, argName in ipairs(rule.disable or {}) do
				ret[argName] = nil
			end

			for argName, value in pairs(rule.set or {}) do
				ret[argName] = value
			end

			if rule.transform ~= nil then
				local transforms = buffFilters.transforms
				local transform = transforms and transforms[rule.transform]

				if type(transform) ~= "function" then
					error(
						"Unknown Experience Buff "
							.. "transformation: "
							.. tostring(
								rule.transform
							),
						2
					)
				end

				if rule.fields ~= nil then
					for _, argName in ipairs(
						rule.fields
					) do
						ret[argName] = transform(
							ret[argName],
							rule.default
						)
					end
				elseif rule.source ~= nil then
					local target = rule.target or rule.source

					ret[target] = transform(
						ret[rule.source],
						rule.default
					)
				else
					error("Transform rule is missing source or fields", 2)
				end
			end
			debugLog("Applied Experience Buff rule", {
				method = method,
				rule = rule,
				before = before,
				after = ret,
			})
		end
	end
end

--[=[ normalizeExperienceBuffArgs
-- Applies all ordered Experience Buff rules to calculator arguments
-- Inputs:
--      method  method data row being calculated
--      args    original calculator arguments
-- Returns:
--      copied and prepared Calculator/Experience Buffs arguments
--]=]
function normalizeExperienceBuffArgs(method, args)
	checkType("normalizeExperienceBuffArgs", 1, method, "table")
	checkType("normalizeExperienceBuffArgs", 2, args, "table")

	local ret = mw.clone(args)

	applyExperienceBuffRules(ret, method, buffFilters.rules)

	debugLog("Normalized Experience Buff arguments", {
		method = method,
		originalArgs = args,
		normalizedArgs = ret,
	})

	return ret
end

--[=[ calculateLevelBoost
-- Calculates temporary visible skill level boosts from configured rules so
-- unlock status can use boosted levels
-- Inputs:
--      args    filtered calculator arguments for the current method
-- Returns:
--      total temporary skill level boost
--]=]
function calculateLevelBoost(args)
	checkType("calculateLevelBoost", 1, args, "table")

	local boost = 0

	for _, rule in ipairs(buffFilters.levelBoostRules) do
		local value = args[rule.arg]
		local add = tonumber(rule.values[value]) or 0

		for _, skill in ipairs(rule.excludeSkill or {}) do
			if args.skill == skill then
				add = 0
				break
			end
		end

		boost = boost + add
	end

	return boost
end

--[=[ getNoBxpArgs
-- Builds a copied calculator argument table with stored bonus experience
-- disabled so the method can be recalculated after BXP runs out
-- Inputs:
--      args    calculator arguments that may include stored BXP settings
-- Returns:
--      copied calculator arguments with bxp, bxpnum, and bonus removed
--]=]
function getNoBxpArgs(args)
	checkType("getNoBxpArgs", 1, args, "table")

	local ret = mw.clone(args)
	ret.bxp    = nil
	ret.bxpnum = nil
	ret.bonus  = nil

	return ret
end


-- urn helpers --
--[=[ getUrnTotalXpMultiplier
-- Determines the total XP multiplier represented by an urn row, including
-- the extra multiplier from Exquisite urns and Urn Enhancers
-- Inputs:
--      urn     urn data row from the selected skill's Urns data
-- Returns:
--      configured total urn XP multiplier
--]=]
function getUrnTotalXpMultiplier(urn)
	checkType("getUrnTotalXpMultiplier", 1, urn, "table")

	local title       = urn.title or ""
	local name        = urn.name or ""
	local multipliers = buffFilters.urnMultipliers
	local isEnhancer  = string.find(title, "Urn Enhancer", 1, true) ~= nil
	local isExquisite = string.find(name, "Exquisite", 1, true)     ~= nil

	if isEnhancer and isExquisite then
		return multipliers.exquisiteEnhancer
	elseif isEnhancer then
		return multipliers.enhancer
	elseif isExquisite then
		return multipliers.exquisite
	end

	return multipliers.default
end

--[=[ canUseUrnForItem
-- Checks whether the selected urn can be filled by a method based on the
-- method level, urn maximum level, and any method-level urn exclusion
-- Inputs:
--      urnData     selected urn calculation data
--      item        method data row being checked
-- Returns:
--      true if the method can fill the selected urn, otherwise false
--]=]
function canUseUrnForItem(urnData, item)
	if urnData == nil or item == nil then
		return false
	end

	local maxLevel  = tonumber(urnData.maxLevel)
	local itemLevel = tonumber(item.level)

	if maxLevel == nil
		or itemLevel == nil
		or item.urns == false
	then
		return false
	end

	if maxLevel == -1 then
		return true
	end

	return itemLevel <= maxLevel
end

--[=[ calculateUrnsForActions
-- Calculates how many complete urns are filled by a number of actions and
-- how much reward XP those completed urns add
-- Inputs:
--      actions       number of completed actions
--      actionBaseXp  base XP that contributes to urn fill progress
--      urnData       selected urn calculation data, or nil
-- Returns:
--      completed urn count and total urn reward XP
--]=]
function calculateUrnsForActions(actions, actionBaseXp, urnData)
	actions      = tonumber(actions)      or 0
	actionBaseXp = tonumber(actionBaseXp) or 0

	if urnData == nil or actions <= 0 or actionBaseXp <= 0 then
		return 0, 0
	end

	local baseXpToFill = tonumber(urnData.baseXpToFill) or 0
	local rewardXp     = tonumber(urnData.rewardXp)     or 0

	if baseXpToFill <= 0 or rewardXp <= 0 then
		return 0, 0
	end

	local urnsFilled = math.floor((actions * actionBaseXp) / baseXpToFill)

	return urnsFilled, urnsFilled * rewardXp
end


-- special xp helpers --
--[=[ calculateAnimalStatMultiplier
-- Calculates the Farming animal checked-stat XP multiplier from configured
-- minimum-stat and divisor values
-- Inputs:
--      args    calculator arguments containing checked animal stats
-- Returns:
--      checked-stat multiplier used by animal XP calculations
--]=]
function calculateAnimalStatMultiplier(args)
	checkType("calculateAnimalStatMultiplier", 1, args, "table")

	local stat1 = tonumber(args.stat1)
	local stat2 = tonumber(args.stat2)

	if stat1 == nil or stat2 == nil then
		return 1
	end

	local config      = buffFilters.raisingAnimal
	local averageStat = math.ceil((stat1 + stat2) / 2)

	if averageStat < config.minimumAverageStat then
		averageStat = config.minimumAverageStat
	end

	return averageStat / config.statDivisor
end

--[=[ calculateRaisingAnimalBonusMultiplier
-- Calculates the Farming Raising Animals XP multiplier from configured shiny
-- and trait modifiers
-- Inputs:
--      args    calculator arguments containing shiny and trait selections
-- Returns:
--      Raising Animals trait and shiny XP multiplier
--]=]
function calculateRaisingAnimalBonusMultiplier(args)
	checkType("calculateRaisingAnimalBonusMultiplier", 1, args, "table")

	local config   = buffFilters.raisingAnimal
	local bonusExp = 0

	if args.shiny == true then
		bonusExp = bonusExp + config.shinyBonus
	end

	for _, argName in ipairs({
		"trait1",
		"trait2",
		"trait3",
	}) do
		bonusExp = bonusExp + (config.traitBonuses[args[argName]] or 0)
	end

	bonusExp = bonusExp + (config.thirdTraitBonuses[args.trait3] or 0)

	return bonusExp + 1
end

--[=[ calculateRaisingAnimalXp
-- Applies checked stats, shiny status, and trait modifiers to a Raising
-- Animals base XP value
-- Inputs:
--      baseXp  base Raising Animals XP value to modify
--      args    calculator arguments containing stat and trait selections
-- Returns:
--      modified Raising Animals XP, or nil if baseXp is not numeric
--]=]
function calculateRaisingAnimalXp(baseXp, args)
	checkType("calculateRaisingAnimalXp", 2, args, "table")

	local xpValue = tonumber(baseXp)
	if xpValue == nil then
		return nil
	end

	return xpValue
		* calculateAnimalStatMultiplier(args)
		* calculateRaisingAnimalBonusMultiplier(args)
end

--[=[ calculateRaisingAnimalStageXp
-- Calculates one Raising Animals growth-stage XP value by reading the stage
-- field from the method row and applying animal stat and trait modifiers
-- Inputs:
--      method     method data row containing growth-stage XP fields
--      args       calculator arguments containing stat and trait selections
--      stageName  name of the growth-stage field to calculate
-- Returns:
--      modified growth-stage XP, or nil if the stage value is not numeric
--]=]
function calculateRaisingAnimalStageXp(method, args, stageName)
	checkType("calculateRaisingAnimalStageXp", 1, method, "table")
	checkType("calculateRaisingAnimalStageXp", 2, args, "table")
	checkType("calculateRaisingAnimalStageXp", 3, stageName, "string")

	return calculateRaisingAnimalXp(method[stageName], args)
end

--[=[ calculateCuringAnimalAgeMultiplier
-- Gets the configured Farming Curing Animals XP multiplier for the selected
-- animal age
-- Inputs:
--      args    calculator arguments containing the selected animal age
-- Returns:
--      Curing Animals age multiplier, or 0 when no age matches
--]=]
function calculateCuringAnimalAgeMultiplier(args)
	checkType("calculateCuringAnimalAgeMultiplier", 1, args, "table")

	return buffFilters.curingAnimalAgeMultipliers[args.age] or 0
end

--[=[ calculateCuringAnimalXp
-- Applies checked stats and the selected age multiplier to a Curing Animals
-- base XP value
-- Inputs:
--      baseXp  base Curing Animals XP value to modify
--      args    calculator arguments containing stat and age selections
-- Returns:
--      modified Curing Animals XP, or nil if baseXp is not numeric
--]=]
function calculateCuringAnimalXp(baseXp, args)
	checkType("calculateCuringAnimalXp", 2, args, "table")

	local xpValue = tonumber(baseXp)
	if xpValue == nil then
		return nil
	end

	return xpValue
		* calculateAnimalStatMultiplier(args)
		* calculateCuringAnimalAgeMultiplier(args)
end

--[=[ calculateBigGameHunterXp
-- Applies the configured Big Game Hunter flat XP bonus without changing
-- stored BXP consumption
-- Inputs:
--      actionExp  calculated action XP before the bonus
--      args       calculator arguments containing the bonus option
-- Returns:
--      adjusted action XP and the flat bonus applied
--]=]
function calculateBigGameHunterXp(actionExp, args)
	checkType("calculateBigGameHunterXp", 1, actionExp, "number")
	checkType("calculateBigGameHunterXp", 2, args, "table")

	local config = buffFilters.bigGameHunter

	if args.skill == config.skill
		and args.disp == config.disp
		and args[config.arg] == true
	then
		return actionExp + config.bonusXp, config.bonusXp
	end

	return actionExp, 0
end


-- core action calculation --
--[=[ calculateActionXp
-- Calculates the final XP gained from one action by filtering invalid boosts,
-- normalising arguments, and delegating boost math to Experience Buffs
-- Inputs:
--      method  method data row containing the base XP value
--      args    calculator arguments containing selected XP boosts
-- Returns:
--      action XP, bonus XP above base, consumed stored BXP, and festive XP
--]=]
function calculateActionXp(method, args)
	checkType("calculateActionXp", 1, method, "table")
	checkType("calculateActionXp", 2, args, "table")

	local boostArgs = normalizeExperienceBuffArgs(method, args)
	boostArgs.base = tonumber(method.xp) or 0

	local total, bonus, consumedBxp, consumedXpFestive =
		experienceBuffs.skillCalc({
			getParent = function()
				return { args = boostArgs }
			end
		})

	debugLog("Calculated action XP", {
		method = method,
		args = args,
		boostArgs = boostArgs,
		total = total or 0,
		bonus = bonus or 0,
		consumedBxp = consumedBxp or 0,
		consumedXpFestive = consumedXpFestive or 0,
	})

	return total or 0, bonus or 0, consumedBxp or 0, consumedXpFestive or 0
end

--[=[ calculateActionTotals
-- Finds the action count and resulting XP totals while accounting for stored
-- BXP depletion, partial final BXP actions, and urn reward XP
-- Inputs:
--      source  action calculation values and optional urn data
--          - fixedActions         optional exact action count
--          - remaining            XP still needed to reach the target
--          - actionExp            XP per action while stored BXP applies
--          - actionExpWithoutBxp  XP per action after stored BXP runs out
--          - consumedBxp          stored BXP consumed per action
--          - bonusXP              stored BXP available at the start
--          - actionBaseXp         base XP used for urn fill progress
--          - urnData              selected urn calculation data, or nil
-- Returns:
--      action count, total XP, BXP used and remaining, urns, and urn XP
--]=]
function calculateActionTotals(source)
	checkType("calculateActionTotals", 1, source, "table")

	local fixedActions        = tonumber(source.fixedActions)
	local remaining           = tonumber(source.remaining) or 0
	local actionExp           = tonumber(source.actionExp) or 0
	local actionExpWithoutBxp = tonumber(source.actionExpWithoutBxp) or 0
	local consumedBxp         = tonumber(source.consumedBxp) or 0
	local bonusXP             = tonumber(source.bonusXP) or 0
	local actionBaseXp        = tonumber(source.actionBaseXp) or 0
	local urnData             = source.urnData

	if actionExpWithoutBxp <= 0 then
		actionExpWithoutBxp = actionExp
	end

	local function totalExpForActions(actions)
		actions = math.floor(actions)

		if actions <= 0 then
			return 0
		end

		local totalExp = 0

		if bonusXP <= 0 or consumedBxp <= 0 then
			totalExp = actions * actionExp
		else
			local fullBxpActions =
				math.min(actions, math.floor(bonusXP / consumedBxp))

			totalExp = fullBxpActions * actionExp

			local actionsLeft  = actions - fullBxpActions
			local bxpRemaining = bonusXP - (fullBxpActions * consumedBxp)

			if actionsLeft > 0 and bxpRemaining > 0 then
				totalExp = totalExp + actionExpWithoutBxp + bxpRemaining

				actionsLeft = actionsLeft - 1
			end

			totalExp = totalExp + (actionsLeft * actionExpWithoutBxp)
		end

		local _, urnRewardXp =
			calculateUrnsForActions(actions, actionBaseXp, urnData)

		return totalExp + urnRewardXp
	end

	if fixedActions ~= nil then
		local actions      = math.max(math.floor(fixedActions), 0)
		local totalExp     = totalExpForActions(actions)
		local bxpUsed      = math.min(bonusXP, actions * consumedBxp)
		local bxpRemaining = bonusXP - bxpUsed
		local urnsFilled, urnRewardXp =
			calculateUrnsForActions(
				actions,
				actionBaseXp,
				urnData
			)

		return {
			actions      = actions,
			totalExp     = totalExp,
			bxpUsed      = bxpUsed,
			bxpRemaining = bxpRemaining,
			urnsFilled   = urnsFilled,
			urnRewardXp  = urnRewardXp,
		}
	end

	if remaining <= 0 or actionExp <= 0 then
		return {
			actions      = 0,
			totalExp     = 0,
			bxpUsed      = 0,
			bxpRemaining = bonusXP,
			urnsFilled   = 0,
			urnRewardXp  = 0,
		}
	end

	local low = 0
	local high = 1

	while totalExpForActions(high) < remaining do
		high = high * 2
	end

	while low + 1 < high do
		local mid = math.floor((low + high) / 2)

		if totalExpForActions(mid) >= remaining then
			high = mid
		else
			low = mid
		end
	end

	local actions      = high
	local totalExp     = totalExpForActions(actions)
	local bxpUsed      = math.min(bonusXP, actions * consumedBxp)
	local bxpRemaining = bonusXP - bxpUsed
	local urnsFilled, urnRewardXp =
		calculateUrnsForActions(actions, actionBaseXp, urnData)

	return {
		actions      = actions,
		totalExp     = totalExp,
		bxpUsed      = bxpUsed,
		bxpRemaining = bxpRemaining,
		urnsFilled   = urnsFilled,
		urnRewardXp  = urnRewardXp,
	}
end


-- method action value helpers --
--[=[ calculateBaseMethodActionValues
-- Calculates the standard action XP values for one method before removable
-- method-specific special cases are applied
-- Inputs:
--      method   method data row being calculated
--      args     calculator arguments for the current method calculation
--      bonusXP  stored bonus experience available at the start
-- Returns:
--      action value table containing base XP, boosted XP, no-BXP XP,
--      consumed BXP, and an empty special-case result field table
--]=]
function calculateBaseMethodActionValues(method, args, bonusXP)
	checkType("calculateBaseMethodActionValues", 1, method, "table")
	checkType("calculateBaseMethodActionValues", 2, args, "table")

	bonusXP = tonumber(bonusXP) or 0

	local actionExp, _, consumedBxp = calculateActionXp(method, args)

	local actionExpWithoutBxp = actionExp
	if bonusXP > 0 and consumedBxp > 0 then
		local noBxpArgs = getNoBxpArgs(args)

		actionExpWithoutBxp = calculateActionXp(method, noBxpArgs)
	end

	return {
		actionBaseXp        = tonumber(method.xp) or 0,
		actionExp           = actionExp,
		actionExpWithoutBxp = actionExpWithoutBxp,
		consumedBxp         = consumedBxp,
		resultFields        = {},
	}
end

--[=[ applyBigGameHunterActionValues
-- Applies Big Game Hunter action XP adjustments and records the BGH-specific
-- result fields without affecting unrelated method rows
-- Inputs:
--      values  action value table to modify
--      args    calculator arguments containing the Big Game Hunter option
-- Returns:
--      modified action value table with BGH result fields attached
--]=]
function applyBigGameHunterActionValues(values, args)
	checkType("applyBigGameHunterActionValues", 1, values, "table")
	checkType("applyBigGameHunterActionValues", 2, args, "table")

	values.resultFields = values.resultFields or {}

	values.actionExp, values.resultFields.bghBonusXp =
		calculateBigGameHunterXp(values.actionExp, args)

	values.actionExpWithoutBxp =
		calculateBigGameHunterXp(values.actionExpWithoutBxp, args)

	values.actionBaseXp =
		(tonumber(values.actionBaseXp) or 0)
		+ (tonumber(values.resultFields.bghBonusXp) or 0)

	return values
end

--[=[ applyRaisingAnimalActionValues
-- Applies Farming Raising Animals action XP adjustments, growth-stage XP
-- calculations, and consumed BXP recalculation
-- Inputs:
--      values  action value table to modify
--      method  Raising Animals method row containing total and stage XP
--      args    calculator arguments containing stat, shiny, and trait data
-- Returns:
--      modified action value table with Raising Animals fields attached
--]=]
function applyRaisingAnimalActionValues(values, method, args)
	checkType("applyRaisingAnimalActionValues", 1, values, "table")
	checkType("applyRaisingAnimalActionValues", 2, method, "table")
	checkType("applyRaisingAnimalActionValues", 3, args, "table")

	values.resultFields = values.resultFields or {}

	values.resultFields.stage1Xp =
		calculateRaisingAnimalStageXp(method, args, "stage1")
	values.resultFields.stage2Xp =
		calculateRaisingAnimalStageXp(method, args, "stage2")
	values.resultFields.stage3Xp =
		calculateRaisingAnimalStageXp(method, args, "stage3")
	values.resultFields.stage4Xp =
		calculateRaisingAnimalStageXp(method, args, "stage4")

	values.actionBaseXp        = calculateRaisingAnimalXp(method.xp, args) or 0
	values.actionExp           = calculateRaisingAnimalXp(values.actionExp, args) or 0
	values.actionExpWithoutBxp =
		calculateRaisingAnimalXp(values.actionExpWithoutBxp, args) or 0
	values.consumedBxp         =
		math.max(values.actionExp - values.actionExpWithoutBxp, 0)

	return values
end

--[=[ applyCuringAnimalActionValues
-- Applies Farming Curing Animals action XP adjustments and records the age
-- multiplier used by the calculation
-- Inputs:
--      values  action value table to modify
--      method  Curing Animals method row containing base XP
--      args    calculator arguments containing stat and age selections
-- Returns:
--      modified action value table with Curing Animals fields attached
--]=]
function applyCuringAnimalActionValues(values, method, args)
	checkType("applyCuringAnimalActionValues", 1, values, "table")
	checkType("applyCuringAnimalActionValues", 2, method, "table")
	checkType("applyCuringAnimalActionValues", 3, args, "table")

	values.resultFields = values.resultFields or {}

	values.resultFields.ageMultiplier = calculateCuringAnimalAgeMultiplier(args)
	values.actionBaseXp               = calculateCuringAnimalXp(method.xp, args) or 0
	values.actionExp                  = calculateCuringAnimalXp(values.actionExp, args) or 0
	values.actionExpWithoutBxp        =
		calculateCuringAnimalXp(values.actionExpWithoutBxp, args) or 0
	values.consumedBxp                =
		math.max(values.actionExp - values.actionExpWithoutBxp, 0)

	return values
end

--[=[ applyMethodSpecialCaseActionValues
-- Routes a method through each removable action-value special case that
-- applies to the selected skill and sub-category
-- Inputs:
--      method  method data row being calculated
--      args    calculator arguments for the current calculation
--      values  base action value table to modify
-- Returns:
--      action value table after all applicable special cases are applied
--]=]
function applyMethodSpecialCaseActionValues(method, args, values)
	checkType("applyMethodSpecialCaseActionValues", 1, method, "table")
	checkType("applyMethodSpecialCaseActionValues", 2, args, "table")
	checkType("applyMethodSpecialCaseActionValues", 3, values, "table")

	if args.skill == "Hunter" and args.disp == "Big Game Hunting" then
		values = applyBigGameHunterActionValues(values, args)
	end

	if args.skill == "Farming" and args.disp == "Raising Animals" then
		values = applyRaisingAnimalActionValues(values, method, args)
	elseif args.skill == "Farming" and args.disp == "Curing Animals" then
		values = applyCuringAnimalActionValues(values, method, args)
	end

	return values
end

--[=[ getMethodUrnData
-- Returns the selected urn data only when the current method is eligible to
-- fill that urn, and reports when the method exceeds the urn's maximum level
-- Inputs:
--      method           method data row being calculated
--      selectedUrnData  selected urn calculation data, or nil
-- Returns:
--      selected urn data for eligible methods, otherwise nil
--      true when the method exceeds the selected urn's maximum level
--]=]
function getMethodUrnData(method, selectedUrnData)
	checkType("getMethodUrnData", 1, method, "table")

	if selectedUrnData == nil then
		return nil, false
	end

	local maxLevel  = tonumber(selectedUrnData.maxLevel)
	local itemLevel = tonumber(method.level)
	local exceedsMaxLevel =
		method.urns ~= false
		and maxLevel ~= nil
		and maxLevel ~= -1
		and itemLevel ~= nil
		and itemLevel > maxLevel

	if canUseUrnForItem(selectedUrnData, method) then
		return selectedUrnData, false
	end

	return nil, exceedsMaxLevel
end

--[=[ getSlayerResultFields
-- Builds Slayer-specific result fields, including Slayer level and optional
-- assignment strategy guide links
-- Inputs:
--      method  Slayer method data row being calculated
--      args    calculator arguments containing skill and disp
-- Returns:
--      table of Slayer result fields, or an empty table for other skills
--]=]
function getSlayerResultFields(method, args)
	checkType("getSlayerResultFields", 1, method, "table")
	checkType("getSlayerResultFields", 2, args, "table")

	if args.skill ~= "Slayer" then
		return {}
	end

	local ret = {level2 = method.level2,}

	if args.disp == "Assignments" then
		ret.slayerGuide = getSlayerStrategyGuide(method)
	end

	return ret
end

--[=[ makeMethodResult
-- Builds the final calculated method result row from common method fields,
-- shared goal context, action totals, and optional special-case fields
-- Inputs:
--      method        method data row being calculated
--      args          calculator arguments for status and special fields
--      context       shared level, XP, goal, BXP, and urn context
--      values        calculated action XP values for the method
--      actionTotals  calculated actions, XP totals, BXP, and urn totals
--      extraFields   optional special-case fields to merge into the result
-- Returns:
--      calculated method result row used by tests and future table output
--]=]
function makeMethodResult(
	method, args, context, values, actionTotals, extraFields
)
	checkType("makeMethodResult", 1, method, "table")
	checkType("makeMethodResult", 2, args, "table")
	checkType("makeMethodResult", 3, context, "table")
	checkType("makeMethodResult", 4, values, "table")
	checkType("makeMethodResult", 5, actionTotals, "table")

	local statusCurrLevel = context.effectiveCurrLevel or context.currLevel
	local statusGoalLevel = context.effectiveGoalLevel or context.goalLevel

	local ret = {
		name               = method.name,
		level              = method.level,
		requiredLevel      = getMethodRequiredLevel(method, args),
		status             = getMethodStatus(
			method, args, statusCurrLevel, statusGoalLevel
		),
		levelBoost         = context.levelBoost or 0,
		effectiveCurrLevel = statusCurrLevel,
		effectiveGoalLevel = statusGoalLevel,
		baseXp             = method.xp,
		actionBaseXp       = values.actionBaseXp,
		actionXp           = values.actionExp,
		actionXpNoBxp      = values.actionExpWithoutBxp,
		consumedBxp        = values.consumedBxp,
		actionsNeeded      = actionTotals.actions,
		currLevel          = context.currLevel,
		currXP             = context.currXP,
		goalLevel          = context.goalLevel,
		goalXP             = context.goalXP,
		baseExpNeeded      = context.baseExpNeeded,
		actualRemaining    = context.actualRemaining,
		bonusXP            = context.bonusXP,
		bxpUsed            = actionTotals.bxpUsed,
		bxpRemaining       = actionTotals.bxpRemaining,
		totalExp           = actionTotals.totalExp,
		urnsFilled         = actionTotals.urnsFilled,
		urnRewardXp        = actionTotals.urnRewardXp,
	}

	return common._copyFields(ret, extraFields)
end


-- special calculators / single-result calculators --
--[=[ calculateSilverhawkFeathers
-- Calculates the number of silverhawk feathers needed for an Agility target,
-- including boosts, stored BXP depletion, and level-based feather XP changes
-- Inputs:
--      args    calculator arguments for the Silverhawk Feathers category
-- Returns:
--      single calculated result row for the Silverhawk Feathers category
--]=]
function calculateSilverhawkFeathers(args)
	checkType("calculateSilverhawkFeathers", 1, args, "table")

	local currLevel, currXP, goalLevel, goalXP, baseExpNeeded,
		actualRemaining, bonusXP =
		remainingExp(
			getSkillCurrent(args),
			args.goal,
			args.currToggle,
			args.goalToggle,
			false,
			args.bxp,
			args.bxpnum
		)

	local feathers     = 0
	local totalExp     = 0
	local bxpUsed      = 0
	local bxpRemaining = bonusXP
	local workingXP    = currXP

	while workingXP < goalXP do
		local workingLevel =
			level({ args = { math.min(workingXP, 200000000) } })
		local baseFeatherXp = tonumber(featherExp[workingLevel]) or 0

		if baseFeatherXp <= 0 then
			break
		end

		local method = {
			name  = "Silverhawk feathers",
			level = workingLevel,
			xp    = baseFeatherXp,
		}

		local actionExp, _, consumedBxp = calculateActionXp(method, args)
		local actionExpNoBxp            = actionExp
		local actionBxpUsed             = 0

		if bonusXP > 0 and consumedBxp > 0 then
			local noBxpArgs = getNoBxpArgs(args)

			actionExpNoBxp = calculateActionXp(method, noBxpArgs)

			if bxpRemaining > 0 then
				actionBxpUsed = math.min(consumedBxp, bxpRemaining)
				actionExp     = actionExpNoBxp + actionBxpUsed
				bxpUsed       = bxpUsed + actionBxpUsed
				bxpRemaining  = bxpRemaining - actionBxpUsed
			else
				actionExp = actionExpNoBxp
			end
		end

		if actionExp <= 0 then
			break
		end

		feathers  = feathers  + 1
		totalExp  = totalExp  + actionExp
		workingXP = workingXP + actionExp
	end

	return {
		name            = "Silverhawk feathers",
		level           = currLevel,
		status          = "unlocked",
		baseXp          = featherExp[currLevel],
		actionXp        = nil,
		actionXpNoBxp   = nil,
		consumedBxp     = nil,
		actionsNeeded   = feathers,
		currLevel       = currLevel,
		currXP          = currXP,
		goalLevel       = goalLevel,
		goalXP          = goalXP,
		baseExpNeeded   = baseExpNeeded,
		actualRemaining = actualRemaining,
		bonusXP         = bonusXP,
		bxpUsed         = bxpUsed,
		bxpRemaining    = bxpRemaining,
		totalExp        = totalExp,
		urnsFilled      = 0,
		urnRewardXp     = 0,
	}
end

--[=[ calculateWildernessAgilityCourse
-- Calculates Wilderness Agility Course laps as a single-result method because
-- the category is handled outside normal method data table output
-- Inputs:
--      args    calculator arguments for the Wilderness Agility Course category
-- Returns:
--      single calculated result row for Wilderness Agility Course laps
--]=]
function calculateWildernessAgilityCourse(args)
	checkType("calculateWildernessAgilityCourse", 1, args, "table")

	local currLevel, currXP, goalLevel, goalXP, baseExpNeeded,
		actualRemaining, bonusXP =
		remainingExp(
			getSkillCurrent(args),
			args.goal,
			args.currToggle,
			args.goalToggle,
			false,
			args.bxp,
			args.bxpnum
		)

	local config = buffFilters.wildernessAgilityCourse
	local method = {name = config.name, xp = config.xp,}

	local actionExp, _, consumedBxp = calculateActionXp(method, args)
	local actionExpWithoutBxp       = actionExp

	if bonusXP > 0 and consumedBxp > 0 then
		local noBxpArgs = getNoBxpArgs(args)

		actionExpWithoutBxp = calculateActionXp(method, noBxpArgs)
	end

	local actionTotals =
		calculateActionTotals({
			remaining           = actualRemaining,
			actionExp           = actionExp,
			actionExpWithoutBxp = actionExpWithoutBxp,
			consumedBxp         = consumedBxp,
			bonusXP             = bonusXP,
			actionBaseXp        = method.xp,
		})

	return {
		name            = method.name,
		level           = nil,
		status          = nil,
		baseXp          = method.xp,
		actionXp        = actionExp,
		actionXpNoBxp   = actionExpWithoutBxp,
		consumedBxp     = consumedBxp,
		actionsNeeded   = actionTotals.actions,
		lapsNeeded      = actionTotals.actions,
		currLevel       = currLevel,
		currXP          = currXP,
		goalLevel       = goalLevel,
		goalXP          = goalXP,
		baseExpNeeded   = baseExpNeeded,
		actualRemaining = actualRemaining,
		bonusXP         = bonusXP,
		bxpUsed         = actionTotals.bxpUsed,
		bxpRemaining    = actionTotals.bxpRemaining,
		totalExp        = actionTotals.totalExp,
		urnsFilled      = 0,
		urnRewardXp     = 0,
	}
end


-- main method calculation --
--[=[ calculateMethods
-- Calculates every method row for the selected skill category from loaded
-- method data, shared goal context, special cases, and action totals
-- Inputs:
--      args             calculator arguments for the selected skill category
--      data             loaded method data rows for the selected category
--      selectedUrnData  selected urn calculation data, or nil
-- Returns:
--      table of calculated method result rows
--]=]
function calculateMethods(args, data, selectedUrnData)
	checkType("calculateMethods", 1, args, "table")
	checkType("calculateMethods", 2, data, "table", true)
	checkType("calculateMethods", 3, selectedUrnData, "table", true)
	debugLog("Starting method calculations", {
		args = args,
		data = data,
		selectedUrnData = selectedUrnData,
	})

	if args.skill == "Agility" and args.disp == "Silverhawk Feathers" then
		local results = {calculateSilverhawkFeathers(args)}

		debugLog("Finished Silverhawk calculations", results)

		return results
	end

	local wildernessConfig = buffFilters.wildernessAgilityCourse

	if args.skill == wildernessConfig.skill
		and args.disp == wildernessConfig.disp
	then
		local results = {
			calculateWildernessAgilityCourse(args),
		}

		debugLog("Finished Wilderness Agility Course calculations", results)

		return results
	end

	data = mw.clone(data or {})

	local isEliteSkill = buffFilters.eliteSkills[args.skill] or false

	local currLevel, currXP, goalLevel, goalXP, baseExpNeeded,
		actualRemaining, bonusXP =
		remainingExp(
			getSkillCurrent(args),
			args.goal,
			args.currToggle,
			args.goalToggle,
			isEliteSkill,
			args.bxp,
			args.bxpnum
		)

	local context = {
		currLevel       = currLevel,
		currXP          = currXP,
		goalLevel       = goalLevel,
		goalXP          = goalXP,
		baseExpNeeded   = baseExpNeeded,
		actualRemaining = actualRemaining,
		bonusXP         = bonusXP,
		selectedUrnData = selectedUrnData,
	}

	debugLog("Calculated shared context", context)

	local results = {}

	for i, method in ipairs(data) do
		local levelSkill      = getMethodLevelSkill(method, args)
		local customLvlBuff   = getCustomLevelBoost(args, levelSkill)
		local statusCurrLevel = context.currLevel
		local statusGoalLevel = context.goalLevel

		if levelSkill ~= args.skill then
			statusCurrLevel = tonumber(getSkillCurrent(args, levelSkill)) or 1
			statusGoalLevel = statusCurrLevel
		end

		local levelBoostArgs = normalizeExperienceBuffArgs(method, args)
		local levelBoost     = calculateLevelBoost(levelBoostArgs)
		local methodContext  = mw.clone(context)

		methodContext.levelSkill = levelSkill
		methodContext.levelBoost = levelBoost
		methodContext.effectiveCurrLevel =
			statusCurrLevel + levelBoost + customLvlBuff
		methodContext.effectiveGoalLevel = statusGoalLevel + levelBoost

		debugLog("Prepared method context", {
			index = i,
			method = method,
			levelBoostArgs = levelBoostArgs,
			context = methodContext,
		})

		local values =
			calculateBaseMethodActionValues(method, args, context.bonusXP)

		debugLog("Calculated base action values", {
			index = i,
			method = method,
			values = values,
		})

		values = applyMethodSpecialCaseActionValues(method, args, values)

		debugLog("Applied special-case action values", {
			index = i,
			method = method,
			values = values,
		})

		local urnData, urnLevelExceeded =
			getMethodUrnData(method, context.selectedUrnData)

		debugLog("Selected method urn data", {
			index = i,
			method = method,
			urnData = urnData,
			urnLevelExceeded = urnLevelExceeded,
		})

		local actionTotalSource = {
			fixedActions = method.actions,
			remaining = context.actualRemaining,
			actionExp = values.actionExp,
			actionExpWithoutBxp = values.actionExpWithoutBxp,
			consumedBxp = values.consumedBxp,
			bonusXP = context.bonusXP,
			actionBaseXp = values.actionBaseXp,
			urnData = urnData,
		}

		local actionTotals = calculateActionTotals(actionTotalSource)

		if urnLevelExceeded then
			actionTotals.urnsFilled = nil
		end

		debugLog("Calculated action totals", {
			index = i,
			method = method,
			source = actionTotalSource,
			totals = actionTotals,
		})

		local extraFields = {
			customLvlBuff = customLvlBuff,
			levelSkill    = levelSkill,
		}

		common._copyFields(extraFields, values.resultFields)
		common._copyFields(extraFields, getSlayerResultFields(method, args))

		debugLog("Built extra result fields", {
			index = i,
			method = method,
			extraFields = extraFields,
		})

		results[i] =
			makeMethodResult(
				method,
				args,
				methodContext,
				values,
				actionTotals,
				extraFields
			)

		debugLog("Built method result", {
			index = i,
			method = method,
			result = results[i],
		})

	end

	debugLog("Finished method calculations", results)

	return results
end


-- status/display-prep helpers --
--[=[ getMethodRequiredLevel
-- Gets the level used to decide a method's unlock status, including Slayer's
-- separate Slayer level requirement when present
-- Inputs:
--      method  method data row being checked
--      args    calculator arguments containing skill and disp
-- Returns:
--      required level used for unlock status comparisons
--]=]
function getMethodRequiredLevel(method, args)
	checkType("getMethodRequiredLevel", 1, method, "table")
	checkType("getMethodRequiredLevel", 2, args, "table")

	if args.skill == "Slayer"
		and (args.disp == "Assignments" or args.disp == "Monsters")
		and method.level2 ~= nil
	then
		return tonumber(method.level2) or 1
	end

	return tonumber(method.level) or 1
end

--[=[ getMethodStatus
-- Gets the unlock status of a method based on current and goal levels
-- Inputs:
--      method       method data row
--      args         calculator arguments
--      currLevel    current skill level
--      goalLevel    goal skill level
-- Returns:
--      method status:
--          unlocked     current level is high enough
--          future       unlocks before or at the goal level
--          unavailable  unlocks above the goal level
--]=]
function getMethodStatus(method, args, currLevel, goalLevel)
	checkType("getMethodStatus", 1, method, "table")
	checkType("getMethodStatus", 2, args, "table")
	checkType("getMethodStatus", 3, currLevel, "number")
	checkType("getMethodStatus", 4, goalLevel, "number")

	local levelRequired = math.floor(getMethodRequiredLevel(method, args))

	if levelRequired <= currLevel then
		return "unlocked"
	elseif levelRequired <= goalLevel then
		return "future"
	else
		return "unavailable"
	end
end

--[=[ getSlayerStrategyGuide
-- Gets the strategy guide link for a Slayer assignment row
-- Inputs:
--      method      Slayer assignment data row
-- Returns:
--      strategy guide link,
--      nil if the row is not a Slayer assignment guide row
--]=]
function getSlayerStrategyGuide(method)
	checkType("getSlayerStrategyGuide", 1, method, "table")

	if method.noStrat == 0 then
		return "[[" .. method.name .. "/Strategies|Strategy]]"
	elseif method.noStrat == 1 then
		return "[[" .. method.name .. method.strat .. "]]"
	elseif method.noStrat == 2 then
		return "[[" .. method.strat .. "]]"
	end

	return nil
end



-- Exported for testing
p._calculateActionXp               = calculateActionXp
p._calculateBaseMethodActionValues = calculateBaseMethodActionValues
p._calculateActionTotals           = calculateActionTotals

p._getUrnTotalXpMultiplier         = getUrnTotalXpMultiplier
p._canUseUrnForItem                = canUseUrnForItem
p._calculateUrnsForActions         = calculateUrnsForActions
p._getMethodUrnData                = getMethodUrnData

p._getSlayerResultFields  = getSlayerResultFields
p._makeMethodResult       = makeMethodResult
p._getMethodRequiredLevel = getMethodRequiredLevel
p._getMethodStatus        = getMethodStatus
p._getSlayerStrategyGuide = getSlayerStrategyGuide

p._calculateAnimalStatMultiplier         = calculateAnimalStatMultiplier
p._calculateRaisingAnimalBonusMultiplier = calculateRaisingAnimalBonusMultiplier
p._calculateRaisingAnimalXp              = calculateRaisingAnimalXp
p._calculateRaisingAnimalStageXp         = calculateRaisingAnimalStageXp
p._calculateCuringAnimalAgeMultiplier    = calculateCuringAnimalAgeMultiplier
p._calculateCuringAnimalXp               = calculateCuringAnimalXp
p._calculateBigGameHunterXp              = calculateBigGameHunterXp

p._applyBigGameHunterActionValues        = applyBigGameHunterActionValues
p._applyRaisingAnimalActionValues        = applyRaisingAnimalActionValues
p._applyCuringAnimalActionValues         = applyCuringAnimalActionValues
p._applyMethodSpecialCaseActionValues    = applyMethodSpecialCaseActionValues

p._calculateSilverhawkFeathers      = calculateSilverhawkFeathers
p._calculateWildernessAgilityCourse = calculateWildernessAgilityCourse

p._setDebug = common._setDebug

p._calculateMethods = calculateMethods

return p