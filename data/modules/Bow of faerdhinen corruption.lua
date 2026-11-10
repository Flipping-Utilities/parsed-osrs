-- Calculates the crystal shards needed to corrupt a bow of Faerdhinen.
-- Corruption costs 2,000 shards in total. Each 1% of progress is worth 20 shards
-- (2,000 charges used), and each 100 charges in the bow is worth 1 shard.
local p = {}

local TOTAL_SHARDS = 2000
local SHARDS_PER_PERCENT = 20
local CHARGES_PER_SHARD = 100
local MAX_CHARGES = 20000

local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

function p.shardsNeeded(frame)
	local args = frame.args
	local progress = clamp(tonumber(args.progress) or 0, 0, 100)
	local charges = clamp(tonumber(args.charges) or 0, 0, MAX_CHARGES)

	local needed = TOTAL_SHARDS
		- (progress * SHARDS_PER_PERCENT)
		- math.floor(charges / CHARGES_PER_SHARD)

	return math.max(needed, 0)
end

return p