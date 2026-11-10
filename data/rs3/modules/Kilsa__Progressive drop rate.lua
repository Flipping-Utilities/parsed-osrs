local p = {}

local function formatRate(probability)
	if probability <= 0 then
		return "—"
	end

	local denominator = 1 / probability
	local rounded = math.floor(denominator + 0.5)

	if math.abs(denominator - rounded) < 0.005 then
		return "1/" .. rounded
	end

	return "1/" .. string.format("%.2f", denominator)
end

local function formatPercent(value)
	if value <= 0 then
		return "0%"
	end

	if value >= 1 then
		return "100%"
	end

	if value >= 0.99999999 then
		return string.format("%.8f%%", value * 100)
	elseif value >= 0.999999 then
		return string.format("%.6f%%", value * 100)
	elseif value >= 0.9999 then
		return string.format("%.4f%%", value * 100)
	else
		return string.format("%.2f%%", value * 100)
	end
end

function p.main(frame)
	local args = frame.args

	-- X = base drop-rate denominator.
	-- Example: X = 100 means a base drop rate of 1/100.
	local X = tonumber(args.X)

	-- Y = pity multiplier.
	-- Example: Y = 1.12 means pity begins at 1.12 × X kills.
	local pityMultiplier = tonumber(args.Y)

	if not X or X <= 0 then
		return "Please enter a valid base drop-rate denominator."
	end

	if not pityMultiplier or pityMultiplier <= 0 then
		pityMultiplier = 1.12
	end

	-- Calculate the KC at which pity begins.
	-- Example: 100 × 1.12 = 112.
	local pityThreshold = math.floor((X * pityMultiplier) + 0.5)

	-- During pity, the probability is:
	--
	--   KC / pityThreshold²
	--
	-- Therefore at the threshold:
	--
	--   112 / 112² = 1 / 112
	--
	-- and then:
	--
	--   113 / 112²
	--   114 / 112²
	--   115 / 112²
	--
	-- This avoids adding the pity increment to the old 1/X rate.
	local pityDenominatorSquared = pityThreshold * pityThreshold

	local maxKC = X * 10

	-- Probability of still having no drop using the actual pity system.
	local failure = 1

	local rows = {}

	for kc = 1, maxKC do
		local probability

		if kc < pityThreshold then
			-- Before pity, use the normal base rate.
			probability = 1 / X
		else
			-- At the pity threshold, the rate becomes:
			--
			-- pityThreshold / pityThreshold²
			-- = 1 / pityThreshold
			--
			-- Every KC afterwards increases the numerator by 1.
			probability = kc / pityDenominatorSquared
		end

		-- Cap the probability at 100%.
		if probability > 1 then
			probability = 1
		elseif probability < 0 then
			probability = 0
		end

		-- Update probability of remaining dry with the pity system.
		failure = failure * (1 - probability)

		-- Display every multiple of the base drop rate.
		if kc % X == 0 then
			local multiple = kc / X

			-- Cumulative chance of receiving the item
			-- with the pity system.
			local cumulative = 1 - failure

			-- Cumulative chance of receiving the item
			-- WITHOUT the pity system.
			--
			-- This assumes every kill always has exactly
			-- the base 1/X drop rate.
			--
			-- P(at least one drop) =
			-- 1 - P(no drops)
			-- 1 - (1 - 1/X)^KC
			local noSystemCumulative = 1 - ((1 - (1 / X)) ^ kc)

			table.insert(rows,
				string.format(
					"|-\n| %dx\n| %d\n| %s\n| %s\n| %s\n| %s",
					multiple,
					kc,
					formatRate(probability),
					formatPercent(cumulative),
					formatPercent(noSystemCumulative),
					formatPercent(failure)
				)
			)
		end
	end

	return "{| class=\"wikitable\"\n" ..
		"! Dryness\n" ..
		"! KC\n" ..
		"! Current drop rate\n" ..
		"! Chance of having received the item\n" ..
		"! Chance without pity system\n" ..
		"! Chance of still being dry\n" ..
		table.concat(rows, "\n") ..
		"\n|}"
end

return p