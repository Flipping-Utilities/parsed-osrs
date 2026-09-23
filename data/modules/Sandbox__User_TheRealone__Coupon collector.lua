local chart = require('Module:Chart data')

local p = {}

local function parseNumber(value)
	if value == nil then
		return nil
	end

	value = mw.text.trim(tostring(value))

	if value == "" then
		return nil
	end

	local numerator, denominator =
		value:match("^([%+%-]?[%d%.]+)%s*/%s*([%+%-]?[%d%.]+)$")

	if numerator and denominator then
		numerator = tonumber(numerator)
		denominator = tonumber(denominator)

		if not numerator or not denominator or denominator == 0 then
			return nil
		end
		
		if numerator / denominator < 1e-12 then
			return nil
		end
		
		return numerator / denominator
	end

	return tonumber(value)
end


local function factorial(n)
	local result = 1

	for i = 2, n do
		result = result * i
	end

	return result
end


local function getCoupons(args)
	local coupons = {}

	for i = 1, 24 do
		local probabilityValue = args["p" .. i]
		local quotaValue = args["k" .. i]

		local probabilityEmpty =
			probabilityValue == nil or
			mw.text.trim(tostring(probabilityValue)) == ""

		-- A blank probability means that this coupon is unused.
		-- Its quota is ignored.
		if not probabilityEmpty then

			local probability = parseNumber(probabilityValue)

			if not probability then
				return nil,
					"Coupon " .. i ..
					" has an invalid probability."
			end

			if probability <= 0 or probability > 1 then
				return nil,
					"Coupon " .. i ..
					" probability must be greater than 0 and no greater than 1."
			end

			local quota = parseNumber(quotaValue)

			if not quota or quota < 1 or quota ~= math.floor(quota) then
				return nil,
					"Coupon " .. i ..
					" must have a positive integer quota."
			end
			
			if quota > 50 then
				return nil,
					"Coupon " .. i ..
					" must have a quota no greater than 50."
			end
			
			table.insert(coupons, {
				p = probability,
				k = quota
			})
		end
	end

	return coupons
end


-- Calculate the contribution of a particular subset S.
--
-- moment = 1:
--     integral_0^infinity
--     product Q_i(t) dt
--
-- moment = 2:
--     2 integral_0^infinity
--     t product Q_i(t) dt
--
-- where
--     Q_i(t) =
--     exp(-p_i t)
--     sum_{r=0}^{k_i-1} (p_i t)^r / r!
--
local function subsetMoment(
	coupons,
	indices,
	position,
	rSum,
	pSum,
	coefficient,
	moment
)

	if position > #indices then

		if moment == 1 then

			return coefficient *
				factorial(rSum) /
				(pSum ^ (rSum + 1))

		elseif moment == 2 then

			return 2 * coefficient *
				factorial(rSum + 1) /
				(pSum ^ (rSum + 2))
		end
	end

	local coupon = coupons[indices[position]]
	local total = 0

	for r = 0, coupon.k - 1 do

		local term =
			coupon.p ^ r /
			factorial(r)

		total = total +
			subsetMoment(
				coupons,
				indices,
				position + 1,
				rSum + r,
				pSum + coupon.p,
				coefficient * term,
				moment
			)
	end

	return total
end


-- Calculate a finite-sum moment using inclusion-exclusion.
-- moment = 1:
--     E[T]
-- moment = 2:
--     E[T^2]
local function calculateMoment(coupons, moment)

	local n = #coupons
	local result = 0

	for mask = 1, (2 ^ n) - 1 do

		local indices = {}
		local subsetSize = 0

		for i = 1, n do

			if math.floor(mask / (2 ^ (i - 1))) % 2 == 1 then
				table.insert(indices, i)
				subsetSize = subsetSize + 1
			end

		end

		local contribution =
			subsetMoment(
				coupons,
				indices,
				1,
				0,
				0,
				1,
				moment
			)

		if subsetSize % 2 == 1 then
			result = result + contribution
		else
			result = result - contribution
		end
	end

	return result
end

--CDF Survival function for Chart
local function cdfFunction(coupons, t)
	local product = 1

	for _, coupon in ipairs(coupons) do
		local x = coupon.p * t

		local truncatedExponential = 0
		local term = 1

		for r = 0, coupon.k - 1 do
			if r == 0 then
				term = 1
			else
				term = term * x / r
			end

			truncatedExponential =
				truncatedExponential + term
		end

		local q = math.exp(-x) * truncatedExponential

		product = product * (1 - q)
	end
	-- return CDF rather than survival rate
	return product
end

local function distributionCharts(
	coupons,
	expectation,
	variance,
	draws
)

	local cdfPlot =
		chart.newChart{ type = 'line' }

	cdfPlot:setDimensions(
		'10vw',
		'10vh',
		500,
		300,
		true
	)

	cdfPlot:setTitle(
		'Cumulative Distribution Function'
	)

	cdfPlot:setXLabel(
		'Number of draws'
	)

	cdfPlot:setYLabel(
		'P(T ≤ t)'
	)


	local pmfPlot =
		chart.newChart{ type = 'line' }

	pmfPlot:setDimensions(
		'10vw',
		'10vh',
		500,
		300,
		true
	)

	pmfPlot:setTitle(
		'Probability Mass Function'
	)

	pmfPlot:setXLabel(
		'Number of draws'
	)

	pmfPlot:setYLabel(
		'P(T = t)'
	)


	local cdfSet =
		cdfPlot:newDataSet()

	cdfSet.label = 'Probability of completion on or before t rolls'


	local pmfSet =
		pmfPlot:newDataSet()

	pmfSet.label = 'Probability of completion on the t-th roll'


	local cdfLabels = {}
	local pmfLabels = {}


	-- Always plot the 0 point.
	local cdfZero =
		cdfFunction(
			coupons,
			0
		)

	table.insert(
		cdfSet.data,
		cdfZero
	)

	table.insert(
		cdfLabels,
		'0'
	)

	table.insert(
		pmfSet.data,
		0
	)

	table.insert(
		pmfLabels,
		'0'
	)


	-- Plotting range: 0 through +3 sigma.
	local standardDeviation =
		math.sqrt(variance)

	local maximum =
		math.ceil(
			expectation +
			3 * standardDeviation
		)


	-- 50 evenly spaced n values.
	local pairs = 50

	local previousN = nil

	for i = 0, pairs - 1 do

		local n =
			math.floor(
				i * maximum / (pairs - 1)
				+ 0.5
			)

		if n ~= previousN then

			local nPlusOne =
				n + 1

			local cdfN =
				cdfFunction(
					coupons,
					n
				)

			local cdfNPlusOne =
				cdfFunction(
					coupons,
					nPlusOne
				)


			-- CDF: plot n + 1.
			table.insert(
				cdfSet.data,
				cdfNPlusOne
			)

			table.insert(
				cdfLabels,
				tostring(nPlusOne)
			)


			-- PMF: F(n+1) - F(n).
			table.insert(
				pmfSet.data,
				cdfNPlusOne - cdfN
			)

			table.insert(
				pmfLabels,
				tostring(nPlusOne)
			)


			previousN = n
		end
	end


	-- Calculate the requested completion
	-- probability.
	local completionProbability =
		cdfFunction(
			coupons,
			draws
		)

	cdfPlot:addDataLabels(
		cdfLabels
	)

	pmfPlot:addDataLabels(
		pmfLabels
	)


	return
		cdfPlot,
		pmfPlot,
		completionProbability
end

local function binomial(n, k)

	if k < 0 or k > n then
		return 0
	end

	if k == 0 or k == n then
		return 1
	end

	k = math.min(k, n - k)

	local result = 1

	for i = 1, k do
		result =
			result * (n - k + i) / i
	end

	return result
end

local function subsetExpectationSum(
	coupons,
	indices
)

	local probabilitySum = 0

	for _, index in ipairs(indices) do
		probabilitySum =
			probabilitySum +
			coupons[index].p
	end


	local total = 0


	local function recurse(
		position,
		rSum,
		productTerm
	)

		if position > #indices then

			total =
				total +
				factorial(rSum)
				/
				(
					probabilitySum ^
					(rSum + 1)
				)
				*
				productTerm

			return
		end


		local coupon =
			coupons[
				indices[position]
			]


		for r = 0, coupon.k - 1 do

			recurse(
				position + 1,
				rSum + r,
				productTerm
					*
					(
						coupon.p ^ r
						/
						factorial(r)
					)
			)

		end
	end


	recurse(
		1,
		0,
		1
	)


	return total
end

local function partialExpectations(coupons)

	local m =
		#coupons


	-- expectations[j] will contain
	--
	-- E[T_j^(K)(P)]
	local expectations = {}

	for j = 1, m do
		expectations[j] = 0
	end


	-- Enumerate every nonempty subset M.
	for mask = 1, (2 ^ m) - 1 do

		local indices = {}
		local subsetSize = 0


		for i = 1, m do

			if math.floor(
				mask / (2 ^ (i - 1))
			) % 2 == 1 then

				table.insert(
					indices,
					i
				)

				subsetSize =
					subsetSize + 1
			end
		end


		-- Calculate the expensive inner
		-- finite sum exactly once.
		local subsetSum =
			subsetExpectationSum(
				coupons,
				indices
			)


		-- This subset contributes to:
		--
		-- j >= m - |M| + 1
		local firstJ =
			m - subsetSize + 1


		for j = firstJ, m do

			local exponent =
				subsetSize
				- m
				+ j
				- 1


			local sign

			if exponent % 2 == 0 then
				sign = 1
			else
				sign = -1
			end


			local coefficient =
				sign
				*
				binomial(
					subsetSize - 1,
					m - j
				)


			expectations[j] =
				expectations[j]
				+
				coefficient
				*
				subsetSum
		end
	end


	return expectations
end

function p.main(frame)

	local args = frame:getParent().args
	
	local draws = tonumber(args.draws)
	
	if not (draws >= 0 and draws <= 1000000) then
		return '<strong class="error">' ..
			'Draws must be between 0 and 1m.' ..
			'</strong>'
	end
	
	local couponArgs = {}
	
	for key, value in pairs(args) do
		if key ~= 'draws' then
			couponArgs[key] = value
		end
	end

	local coupons, errorMessage = getCoupons(couponArgs)

	if not coupons then
		return '<strong class="error">' ..
			errorMessage ..
			'</strong>'
	end

	if #coupons == 0 then
		return '<strong class="error">' ..
			'Enter at least one coupon.' ..
			'</strong>'
	end

	local probabilitySum = 0

	for _, coupon in ipairs(coupons) do
		probabilitySum =
			probabilitySum + coupon.p
	end

	if probabilitySum > 1 + 1e-12 then
		return '<strong class="error">' ..
			'The coupon probabilities must sum to no more than 1.' ..
			'</strong>'
	end

	-- First moment:
	--
	-- E[T]
	--
	--local expectation = calculateMoment(coupons, 1)
	local expectations =
		partialExpectations(
			coupons
		)
	local expectation = expectations[#expectations]
	-- Second moment of the continuous-time
	-- Poissonized waiting time:
	--
	-- E[T_Poisson^2]
	--
	local poissonSecondMoment =
		calculateMoment(coupons, 2)

	
	-- The Poissonized waiting time is the sum of T
	-- independent Exp(1) interarrival times.
	--
	-- Therefore:
	--
	-- Var(T_Poisson) = Var(T) + E[T]
	--
	-- and hence:
	--
	-- Var(T) =
	-- E[T_Poisson^2] - E[T] - E[T]^2
	--
	local variance =
		poissonSecondMoment
		- expectation
		- expectation ^ 2
	
	local cdfPlot, pmfPlot, completionProbability = 
		distributionCharts(
			coupons
			, expectation
			, variance
			, draws
		)
		
	local dryProbability =
		1 - completionProbability
	
	local dryOdds
	
	if dryProbability > 0 then
		dryOdds = 1 / dryProbability
	else
		dryOdds = 0
	end
	
	local completionText =
		string.format(
			'%.2f%% of players will have completed the items by %d rolls. About 1 in %.1f players will go dryer than you.',
			completionProbability * 100,
			draws,
			dryOdds
		)
	
	local inputTable = mw.html.create('table')
		:addClass('wikitable')
		:addClass('align-center-1')
	
	local title = 
		inputTable:tag('tr')
	
	title
		:tag('th')
        :attr('colspan', '3')
        :attr('scope', 'colgroup')
        :wikitext('Inputs')
        :done()
        
	inputTable
		:tag('tr')
			:tag('th')
				:wikitext('Item')
				:done()
			:tag('th')
				:wikitext('Probability')
				:done()
			:tag('th')
				:wikitext('Quota')
				:done()
			:done()

	for i, coupon in ipairs(coupons) do

		inputTable
			:tag('tr')
				:tag('td')
					:wikitext(tostring(i))
					:done()
				:tag('td')
					:wikitext(string.format('%.12g', coupon.p))
					:done()
				:tag('td')
					:wikitext(tostring(coupon.k))
					:done()
				:done()

	end

	local resultTable = mw.html.create('table')
		:addClass('wikitable')
		:addClass('align-center-1')

	resultTable
		:tag('tr')
			:tag('th')
				:wikitext('Expected completion time')
				:done()
			:tag('td')
				:wikitext(string.format('%.2f', expectation))
				:done()
			:done()

	resultTable
		:tag('tr')
			:tag('th')
				:wikitext('Variance of completion times')
				:done()
			:tag('td')
				:wikitext(string.format('%.2f', variance))
				:done()

	local partialTable =
		mw.html.create('table')
	
	partialTable
		:addClass(
			'wikitable'
		)
	
	local title = 
		partialTable:tag('tr')
	
	title
		:tag('th')
        :attr('colspan', '2')
        :attr('scope', 'colgroup')
        :wikitext('Expected Duration Schedule')
        :done()
        
	local header =
		partialTable:tag('tr')
	
	header
		:tag('th')
			:wikitext(
				'Item-Quotas Completed'
			)
			:done()
	
	header
		:tag('th')
			:wikitext(
				'Expected Draws'
			)
			:done()
	
	
	for j = 1, #expectations do
	
		local row =
			partialTable:tag('tr')
	
		row
			:tag('td')
				:wikitext(j)
				:done()
	
		row
			:tag('td')
				:wikitext(
					string.format(
						'%.2f',
						expectations[j]
					)
				)
				:done()
	end

	return '<div class="cc-completion-text">'
		.. completionText
		.. '</div>'
		.. '<div style="display:flex;flex-wrap:wrap;align-items:center;">'
		..'<div>'
		.. tostring(inputTable)
		.. '</div>'
		..'<div>'
		.. tostring(partialTable)
		.. '</div>'
		.. '</div>'
		..'<div style="display:flex;flex-wrap:wrap;align-items:center;">'
		..'<div>'
		.. tostring(cdfPlot)
		.. '</div>'
		.. '<div>'
		.. tostring(pmfPlot)
		.. '</div>'
end

return p