local p = {}

-- Divine charge slot names and drain multipliers
local DIVINE_CHARGE_SLOTS = {
	["2h"] = {
		["name"] = "Two-handed",
		["chargeDrainMult"] = 1.5
	},
	["main hand"] = {
		["name"] = "Main hand",
		["chargeDrainMult"] = 1.0
	},
	["weapon"] = {
		["name"] = "Main hand",
		["chargeDrainMult"] = 1.0
	},
	["torso"] = {
		["name"] = "Torso",
		["chargeDrainMult"] = 1.0
	},
	["body"] = {
		["name"] = "Torso",
		["chargeDrainMult"] = 1.0
	},
	["legs"] = {
		["name"] = "Legs",
		["chargeDrainMult"] = 1.0
	},
	["off-hand"] = {
		["name"] = "Off-hand",
		["chargeDrainMult"] = 0.5
	},
	["off-hand weapon"] = {
		["name"] = "Off-hand",
		["chargeDrainMult"] = 0.5
	},
	["shield"] = {
		["name"] = "Off-hand",
		["chargeDrainMult"] = 0.5
	},
	["tool"] = {
		["name"] = "Tool",
		["chargeDrainMult"] = 0.25
	},
}

p.DIVINE_CHARGE_SLOTS = DIVINE_CHARGE_SLOTS

local COMBAT_RATES = {
	{ rate = 30, name = "Average"},
	{ rate = 60, name = "High"},
	{ rate = 100, name = "Maximum"}
}

p.COMBAT_RATES = COMBAT_RATES

-- Given an invention level, return its charge drain reduction multiplier
function p.chargeDrainResearch(lvl)
	lvl = tonumber(lvl)
	if lvl>=1 and lvl<34 then
		return 1.00
	elseif lvl<49 then
		return 0.99
	elseif lvl<64 then
		return 0.97
	elseif lvl<69 then
		return 0.95
	elseif lvl<78 then
		return 0.93
	elseif lvl<83 then
		return 0.91
	elseif lvl<91 then
		return 0.88
	elseif lvl<95 then
		return 0.86
	elseif lvl<105 then
		return 0.83
	elseif lvl<=120 then
		return 0.80
	else
		error("Unexpected Invention level: "..lvl)
	end
end

-- Given an item level, return its charge drain reduction modifier
function p.chargeDrainItemLvl(lvl)
	lvl = tonumber(lvl)
	if lvl>=1 and lvl<5 then
		return 1.00
	elseif lvl<14 then
		return 0.9
	elseif lvl<18 then
		return 0.875
	elseif lvl<=20 then
		return 0.85
	else
		error("Unexpected item level: "..lvl)
	end
end

return p