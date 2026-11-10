-- <nowiki>
-- Copied from https://runescape.wiki/w/Module:Probability
local checkType = require( 'libraryUtil' ).checkType
local arr = require 'Module:Array'
local min = math.min
local max = math.max
local log10 = math.log10
local floor = math.floor
local ceil = math.ceil

local prob = {}

local function round( num, dp )
    dp = dp or 0
    return floor( num * 10^dp + 0.5 ) / 10^dp
end

local function ceilClip( x, low, high )
    return max( min( ceil( x ), high ), low )
end

local function fastLog( x )
    if x < 1e0 then
        return 0
    elseif x < 1e1 then
        return 1
    elseif x < 1e2 then
        return 2
    elseif x < 1e3 then
        return 3
    elseif x < 1e4 then
        return 4
    elseif x < 1e5 then
        return 5
    elseif x < 1e6 then
        return 6
    else
        return log10( x )
    end
end

-- choose(n, p) * p^k * (1 - p)^(n - k)
-- Interleaves this calculation to reduce chance of overflow/underflow on large n and k
---@param p number ∈ [0, 1] Chance of success
---@param n integer Number of trials
---@param k integer Number of successes
---@return number ∈ [0, 1]
function prob.binomialPMF( p, n, k )
    if k > n or k < 0 then
        return 0
    end

    local res = 1
    local dc = 0
    local ndc = 0
    local i = n
    local logDroprate = log10( p )
    local logNoDroprate = log10( 1 - p )

    for d = min( k, n - k ), 1, -1 do
        res = res * (i / d)
        i = i - 1

        if res > 1 and dc < k then
            local adjustCount = ceilClip( -fastLog( res ) / logDroprate, 0, k - dc )
            res = res * p^adjustCount
            dc = dc + adjustCount
        end

        if res > 1 and ndc < n - k then
            local adjustCount = ceilClip( -fastLog( res ) / logNoDroprate, 0, n - k - ndc )
            res = res * (1 - p)^adjustCount
            ndc = ndc + adjustCount
        end
    end

    res = res * p^(k - dc) * (1 - p)^(n - k - ndc)

    return res
end

---@param p number ∈ [0, 1] Chance of success
---@param n integer Number of trials
---@param startK integer Start number of successes. Inclusive
---@param endK integer End number of successes. Inclusive
---@return number ∈ [0, 1]
function prob.binomialCDF( p, n, startK, endK )
    local highChanceDropCount = 0
    local highChanceVal = 0

    if startK > endK or n < startK then
        return 0
    end

    if startK == 0 then
        highChanceVal = (1 - p)^n
    end

    if highChanceVal < 1e-300 then
        highChanceDropCount = ceilClip( p * n, startK, endK )
        highChanceVal = prob.binomialPMF( p, n, highChanceDropCount )
    end

    local inc = 0
    local res = highChanceVal

    inc = highChanceVal
    for i = highChanceDropCount + 1, endK do
        -- f(p, n, k) = choose(n, k) * p^k * (1-p)^(n-k)
        -- f(p, n, k+1) = choose(n, k+1) * p^(k+1) * (1-p)^(n-k-1)
        --     = n!/((k+1)!*(n-k-1)!) * p * p^k * (1-p)^(n-k) / (1-p)
        --     = choose(n, k) * p^k * (1-p)^(n-k) * p * (n-k) / ((k+1) * (1-p))
        --     = f(p, k, n) * p * (n-k) / ((k+1) * (1-p))
        inc = inc * p * (n - (i - 1)) / (i * (1 - p))
        res = res + inc

        if inc / res < 1e-13 or res == 0 then
            break
        end
    end

    inc = highChanceVal
    for i = highChanceDropCount - 1, startK, -1 do
        -- f(p, n, k) = choose(n, k) * p^k * (1-p)^(n-k)
        -- f(p, n, k-1) = choose(n, k-1) * p^(k-1) * (1-p)^(n-k+1)
        --     = n!/((k-1)!*(n-k+1)!) * p^k * (1-p)^(n-k) * (1-p) / p
        --     = choose(n, k) * p^k * (1-p)^(n-k) * (1-p) * k / (p * (n-k+1))
        --     = f(p, k, n) * (1-p) * k / (p * (n-k+1))
        inc = inc * (1 - p) * (i + 1) / (p * (n - i))
        res = res + inc

        if inc / res < 1e-13 or res == 0 then
            break
        end
    end

    return res
end

-- Returns the number of trials needed to reach a given CDF value
---@param chance number ∈ [0, 1]; CDF value
---@param p number ∈ [0, 1]; Chance of success
---@param k integer ∈ N; Number of successes
---@param threshold integer ∈ N; Optional, multiplies p by ceil(n / threshold) capping at 10
---@return integer n Number of trials
function prob.inverseBinomialCDF( chance, p, k, threshold )
    if threshold then
        local c = 0
        local m = 1
        local kc = 0

        while true do
            local newC = 1 - (1 - c) * (1 - m * p)^threshold

            if newC >= chance then
                kc = kc + log10( (1 - chance) / (1 - c) ) / log10( (1 - m * p) )
                return ceil( kc )
            else
                kc = kc + threshold
                c = newC
            end

            m = min( m + 1, 10 )
        end
    else
        if k > 1 then
            local function calcChance( kc )
                if kc < k then
                    return 0
                end
                return 1 - prob.binomialCDF( p, kc, 0, k - 1 )
            end

            -- Use binary search to find the required n
            local low = 0
            local high = ceil( 5 / p )
            while calcChance( high ) < chance do
                low = high
                high = high * 2
            end
            while true do
                local mid = round( (high + low) / 2 )
                local P = calcChance( mid )
                if P > chance then
                    high = mid
                else
                    low = mid
                end
                if high == low or high == low + 1 then
                    return low
                end
            end
        elseif k == 1 then
            return ceil( log10( 1 - chance ) / log10( 1 - p ) )
        else
            return 0
        end
    end
end

---Returns an array of binomial PMF values
---@param p number ∈ [0, 1]; Chance of success
---@param n integer ∈ N; Number of trials
---@param startK integer ∈ N; Number of successes to start the array from
---@param endK integer ∈ N
---@param stepSize integer ∈ N; Stepsize of k
---@return number[]
function prob.binomialPMFArr( p, n, startK, endK, stepSize )
    local mean = n * p
    local highChanceDropCount = ceilClip( mean, startK, endK )
    local highChanceVal
    local isSorted = false

    if n > 1000 * (1 - p) / p and startK < mean and mean < endK then
        local sd = math.sqrt( n * p * (1 - p) )
        highChanceVal = 1 / (sd * math.sqrt( 2 * math.pi )) * math.exp( -0.5 * ((highChanceDropCount - mean) / sd)^2 ) -- normal approximation
    elseif startK == 0 and (1 - p)^n > 1e-300 then
        highChanceVal = (1 - p)^n
        highChanceDropCount = 0
        isSorted = true
    else
        highChanceVal = prob.binomialPMF( p, n, highChanceDropCount )
    end

    local chanceArr = arr{ { x=highChanceDropCount, y=highChanceVal } }
    local val = 0

    val = highChanceVal
    for i = highChanceDropCount + 1, endK do
        val = val * p * (n - (i - 1)) / (i * (1 - p))

        if stepSize == 1 or i % stepSize == 0 then
            table.insert( chanceArr, { x=i, y=val } )
        end
    end

    val = highChanceVal
    for i = highChanceDropCount - 1, startK, -1 do
        val = val * (1 - p) * (i+1) / (p * (n - i))

        if stepSize == 1 or i % stepSize == 0 then
            table.insert( chanceArr, { x=i, y=val } )
        end
    end

    if not isSorted then
        table.sort( chanceArr, function(lhs, rhs) return lhs.x < rhs.x end )
    end

    return chanceArr
end

---Returns an array of binomial CDF values
---@param p number ∈ [0, 1]; Chance of success
---@param n integer ∈ N; Number of trials
---@param endK integer ∈ N
---@return number[]
function prob.binomialCDFArr( p, n, endK )
    local chanceArr = prob.binomialPMFArr( p, n, 0, endK, 1 )

    for i = 2, #chanceArr do
        chanceArr[i].y = chanceArr[i].y + chanceArr[i-1].y
    end

    return chanceArr
end

---Calculates the average kc per drop for drops with thresholds
---@param droprate number ∈ [0, 1]
---@param threshold integer ∈ N
---@return number
function prob.calcAverageKc( droprate, threshold )
    local averageKC = 0

    -- sum(r^n, n=0..t-1)
	local function powerSeries1( r, t )
	    return (r^t - 1) / (r - 1)
	end

	-- sum(n*r^n, n=0..t-1)
	local function powerSeries2( r, t )
	    return ((t - 1) * r^(t + 1) - t * r^t + r) / (r - 1)^2
	end

    if threshold then
        -- Calculate the weigthed average over the probability distribution from 0 to inf (we can stop sooner as values become insignificant small)
        -- => Calculate the sum of the prodcuct of each kill count value with the chance to obtain it at that kill count
        --
        -- l = start of each threshold bin. If threshold = 1000 then l = 1, 1001, 2001, ...
        -- c = combined succes and fail chance from previous threshold bins. In bin one c = droprate, bin two c = 2 * droprate * (1 - droprate)^threshold,
        -- bin three c = 3 * droprate * (1 - droprate)^threshold * (1 - 2 * droprate)^threshold, ...
        -- r = (1 - multiplier * droprate)
        --
        -- Each threshold bin can then be written as
        -- l*c + (l+1)*c*r + (l+2)*c*r^2 + (l+3)*c*r^3 + ... + (l + threshold - 1)*c*r^(threshold - 1)
        -- => c*(l + l*r + r + l*r^2 + 2*r^2 + l*r^3 + 3*r^3 + ...)
        -- => c*(l*(1 + r + r^2 + r^3 + ...) + r + 2r^2 + 3r^3 + ...)
        -- (1 + r + r^2 + r^3 + ...) and (r + 2r^2 + 3r^3 + ...) are powerseries
        local c = droprate
        for m = 1, 10 do
            local r = 1 - min( m * droprate, 1 )
            local l = (m - 1) * threshold + 1
            if m == 10 then
            	averageKC = averageKC + c * (l / (1 - r) + r / (r - 1)^2)
        	else
            	averageKC = averageKC + c * (l * powerSeries1( r, threshold ) + powerSeries2( r, threshold ))
            end
            c = c * r^threshold * (1 + 1 / m)
        end
    else
        averageKC = 1 / droprate
    end

    return averageKC
end

function prob.dropRateAtKillCount( droprate, threshold, kills )
    return min( droprate * (threshold and min( ceil( kills / threshold ), 10 ) or 1), 1 )
end

function prob.noThreshold( droprate, kills )
    return 1 - (1 - droprate)^kills
end

function prob.noThresholdArr( droprate, kills )
    local res = arr{}

    for kc = 1, kills do
        res[kc] = 1 - (1 - droprate)^kc
    end

    return res
end

function prob.withThreshold( droprate, threshold, beginKC, kills )
    local K = beginKC + kills
    local lm = threshold and min( ceil( (beginKC + 1) / threshold ), 10 ) or 1
    local um = threshold and min( ceil( K / threshold ), 10 ) or 1

    if lm == um then
        local res = (1 - lm * droprate)^(K - beginKC)
        return 1 - res, res
    elseif lm < um then
        local res = (1 - lm  * droprate)^(threshold - (beginKC % threshold)) * (1 - um * droprate)^max( (K - 1) % threshold + 1, K - 9 * threshold )
        for m = lm + 1, um - 1 do
            res = res * (1 - m * droprate)^threshold
        end
        return 1 - res, res
    end

    return 0, 1
end

-- let:
--  a = droprate
--  k = start killcount
--  K = end killcount
--  t = threshold
-- f(a, k, K, t) = ∏((1-m*a)^t, m=ceil(k/t)+1..ceil(K/t)-1) * (1-ceil(k/t)*a)^(t - k % t) * (1-ceil(K/t)*a)^(K % t)
-- f(a, k, K+1, t) = f(a, k, K, t) * (1-ceil((K+1)/t)*a) -- if k < K+1 else 1
function prob.withThresholdArr( droprate, threshold, beginKC, kills )
    if threshold == nil then
        return prob.noThresholdArr( droprate, kills )
    end

    local res = arr{ [0]=1 }
    for k = 1, kills do
        res[k] = res[k - 1] * (1 - min( ceil( (k + beginKC) / threshold ), 10 ) * droprate)
    end

    return 1 - res
end

function prob.multiDropCountArr( droprate, dropcount, kills )
    local res = arr{}

    for kc = 1, kills do
        res[kc] = 1 - prob.binomialCDF( droprate, kc, 0, dropcount - 1 )
    end

    return res
end

function prob.dependentDropsArr( args, beginKC, kills )
    for i, v in ipairs( args ) do
        if type( v ) == 'number' then
            args[i] = {{d=v}}
        elseif type( v ) == 'table' then
            if v.d then
                args[i] = {v}
            else
                for j, k in ipairs( v ) do
                    if type( k ) == 'number' then
                        args[i][j] = {d=k}
                    end
                end
            end
        end
    end

    local function failChance( kc, data )
        local res = 1
        for _, v in ipairs( data ) do
            local m = v.t and math.min( math.ceil( (kc + beginKC) / v.t ), 10 ) or 1
            res = res * (1 - m * v.d)
        end
        return res
    end

    local chanceArr = arr.rep( 1, kills )

    for i, data in ipairs( args ) do
        if i == 1 then
            for _, v in ipairs( data ) do
                chanceArr = chanceArr * prob.withThresholdArr( v.d, v.t, beginKC, kills )
            end
            chanceArr[0] = 0
        else
            local a = arr.rep( 0, kills )
            local b = arr.rep( 1, kills )

            for j = 1, #data do
                for _, comb in prob.combinationPairs( data, j ) do
                    local h = 0
                    for k = 1, kills do
                        local fc = failChance( k, comb )
                        a[k] = a[k] + (-1)^(j+1) * h * fc
                        b[k] = b[k] + (-1)^j * fc
                        h = h * fc + chanceArr[k-1] * (1 - fc)
                    end
                end
            end

            local prevArr = chanceArr
            chanceArr = arr{ [0]=0 }
            for k = 1, kills do
                chanceArr[k] = a[k] + prevArr[k-1] * b[k]
            end
        end
    end

    return chanceArr
end

--[[
Given X distributed over a negative hypergeometric distribution with
provided parameter N, K = N - 1 and r = 1, describes the probability
distribution of X.

Given an urn with N balls, one of which is a success, X is the number
of balls that need to be drawn until the successful ball is drawn.

An optional parameter, threshold, gives a number after which balls
will be replaced, i.e., the probability to stop will never decrease
below 1 / threshold.

The optional parameter percentage will return a percentage instead of
a probability if given and true
--]]
local negativeHypergeometric = {}
prob.negativeHypergeometric = negativeHypergeometric

-- P(X = x | X >= x)  (i.e., the chance that the xth trial would be a success)
function negativeHypergeometric.f(x, N, threshold, percentage)
	local whole = percentage and 100 or 1
	if x < 1 then
		return 0.0	
	end
	if threshold and x + threshold >= N then
		return whole / threshold
	end
	if x >= N then
		return 0.0
	end
	return whole / (N + 1 - x)
end

-- P(X = x)  (x must be an integer)
function negativeHypergeometric.pdf(x, N, threshold, percentage)
	local whole = percentage and 100 or 1
	threshold = threshold or 0
	if x < 1 then
		return 0.0	
	end
	if x + threshold <= N then
		return whole / N
	end
	x = x - (N - threshold)
	-- Now this is a regular geometric distribution
	if threshold == 0 then
		return 0.0
	end
	local geoPdf = (1 - prob.noThreshold(1 / threshold, x - 1)) * (1 / threshold)
	-- (1 - cdf) accounts for the probability that you reach the threshold in the first place
	return (1 - negativeHypergeometric.cdf(N - threshold, N, 0, percentage)) * geoPdf
end

-- P(X <= x)
function negativeHypergeometric.cdf(x, N, threshold, percentage)
	local whole = percentage and 100.0 or 1.0
	threshold = threshold or 0
	x = math.floor(x)
	if x < 1 then
		return 0.0	
	end
	if x + threshold <= N then
		if x >= N then
			return whole
		end
		return (whole * x) / N
	end

	return (whole * (N - threshold)) / N * prob.noThreshold(1 / threshold, x - threshold)
end

-- P(X <= x) >= q where X ~ Geo(p) [Where P(X = 0) = 0]
local function inverseGeometricCdf(p, q)
	return math.ceil(math.log(1 - q) / math.log(1 - p))
end

-- min x s.t. P(X <= x) >= q
function negativeHypergeometric.inverseCdf(q, N, threshold)
	-- P(X <= x) >= q
	-- x / N >= q
	local withoutThreshold = math.ceil(q * N)
	if not threshold or withoutThreshold + threshold <= N then
		return withoutThreshold
	end

	local thresholdTrial = N - threshold
	local probabilityMassAtThreshold = negativeHypergeometric.cdf(thresholdTrial, N)
	return thresholdTrial - 1 + inverseGeometricCdf(1 / threshold, q - probabilityMassAtThreshold)
end

-- E[X]
function negativeHypergeometric.mean(N, threshold)
	threshold = threshold or 0
	-- return (N - threshold) * (N - threshold + 1) / 2 / N + threshold
	return (N * (N + 1) + threshold * (threshold - 1)) / (2 * N)
end

--[[
Negative binomial distribution. Similar to negative hypergeometric, but its urn model includes
replacement. Special case of the discrete phase-type distribution. Specifically models the number 
of iid Bernoulli trial failures k before a certain number of successes r are observed, 
where r has probability of success p.
]]--
local nbinomial = {}
prob.nbinomial = nbinomial

--[[ 
Factorial and choose functions. This negative binomial distribution code was created for 
small n (n<=14), and so we implement basic factorial and combination math. 
Generating more elegant and stable calculations similar to those of the standard 
binomial above is left as an exercise to the reader with a need for numeric stability.
]]--
function nbinomial.choose(n, k)
	-- Nil propagates through; returns nil if string isn't an integer, returns the tonumber otherwise
	local function to_int_if_int(str)
	  return tonumber(tostring(str):match("^%-?%d+$"))
	end
	
	local function fact(n)
		if n < 0 then 
			return nil
		elseif n == 0 then
	        return 1
	    end
	    return n * fact(n - 1)
	end
	
	n = to_int_if_int(n)
	k = to_int_if_int(k)
	if not type(n) == "number" and type(k) == "number" then
		return nil
	end
    return fact(n) / (fact(k) * fact(n - k))
end

-- P(X=k)
function nbinomial.f(p, r, k)
	return nbinomial.choose(k+r-1, k)*((1-p)^k)*(p^r)
end

-- E[X]. Note that this is expected _failures_; expected _trials_ is below
function nbinomial.mean(p, r)
	return r * (1 - p) / p
end

-- Total expected trials until r successes; equal to E[X] + r
function nbinomial.trials(p, r)
	return r/p
end

---Returns an array of negative binomial PMF values representing the likelihood
-- of observing k failures before r successes
---@param p number ∈ [0, 1]; Chance of success
---@param r integer ∈ N; Number of successes to be seen
---@param threshold number ∈ [0, 1]; lower probability threshold to conclude calculation
---@return table{[integer] = number} where the number of observed failures indexes the 
-- probability. 0-indexed.
function nbinomial.pmf(p, r, threshold)
	threshold = threshold or 0.001
	local mean = nbinomial.mean(p, r)
	local pmf = {}
	local k = 0 -- Start at 0, which affects indexing
	local nbf = nbinomial.f(p, r, k)
	-- k < mean ensures we don't look at too few; prob > threshold ensures we don't look at too many
	while k < mean or nbf > threshold do
		pmf[k] = nbf
		k = k + 1
		nbf = nbinomial.f(p, r, k)
	end
	return pmf
end

-- =======================
--       Iterators
-- =======================

local function makePairFunction( arr, p, iter )
    local it, _, indexes = iter( #arr, p )

    return function()
        indexes = it( nil, indexes )
        if indexes then
            local res = {}
            for i, j in ipairs( indexes ) do
                res[i] = arr[j]
            end
            return indexes, res
        end
    end
end

function prob.combinationIterator( n, p )
    checkType( 'Module:prob.combinationIterator', 1, n, 'number' )
    checkType( 'Module:prob.combinationIterator', 2, p, 'number' )
    if p < 0 or n < 0 or n < p then
        return function() end
    elseif p == 0 or n == 0 then
        return function( _, i )
            if i == 0 then
                return {}
            end
        end, nil, 0
    end

    local indexArr = {}
    for i = 1, p - 1 do
        indexArr[i] = i
    end
    indexArr[p] = p - 1

    return function()
        if indexArr[p] == n then
            local i = 0
            while indexArr[p - i] == n - i and i < p do
                i = i + 1
            end

            if i == p then
                return nil
            end

            indexArr[p - i] = indexArr[p - i] + 1

            for j = 1, i do
                indexArr[p - i + j] = indexArr[p - i + j - 1] + 1
            end
        else
            indexArr[p] = indexArr[p] + 1
        end

        return indexArr
    end
end

function prob.combinationPairs( arr, p )
    checkType( 'Module:prob.combinationPairs', 1, arr, 'table' )
    checkType( 'Module:prob.combinationPairs', 2, p, 'number' )
    return makePairFunction( arr, p, prob.combinationIterator )
end

function prob.combinationRepIterator( n, p )
    checkType( 'Module:prob.combinationRepIterator', 1, n, 'number' )
    checkType( 'Module:prob.combinationRepIterator', 2, p, 'number' )
    if p < 0 or n < 0 then
        return function() end
    elseif p == 0 or n == 0 then
        return function( _, i )
            if i == 0 then
                return {}
            end
        end, nil, 0
    elseif n == 1 then
        return function( _, i )
            if i == 0 then
                local res = {}
                for j = 1, p do
                    res[j] = 1
                end
                return res
            end
        end, nil, 0
    end

    local indexArr = {}
    for i = 1, p - 1 do
        indexArr[i] = 1
    end
    indexArr[p] = 0

    return function()
        if indexArr[1] == n then
            return nil
        end

        indexArr[p] = indexArr[p] + 1

        if indexArr[p] > n then
            local hasInc = false
            for i = 1, p - 1 do
                if indexArr[i + 1] >= n then
                    if not hasInc then
                        indexArr[i] = indexArr[i] + 1
                        hasInc = true
                    end
                    indexArr[i + 1] = indexArr[i]
                end
            end
        end

        return indexArr
    end
end

function prob.combinationRepPairs( arr, p )
    checkType( 'Module:prob.combinationRepPairs', 1, arr, 'table' )
    checkType( 'Module:prob.combinationRepPairs', 2, p, 'number' )
    return makePairFunction( arr, p, prob.combinationRepIterator )
end

function prob.permutationIterator( n )
    checkType( 'Module:prob.permutationIterator', 1, n, 'number' )
    if n < 0 then
        return function() end
    end

    local c = {}
    local A = {}
    for i = 1, n do
        c[i] = 1
        A[i] = i
    end
    local i = 0

    return function()
        if i == 0 then
            i = 1
            return A
        end

        while i <= n do
            if c[i] < i then
                if i%2 == 1 then
                    A[1], A[i] = A[i], A[1]
                else
                    A[c[i]], A[i] = A[i], A[c[i]]
                end

                c[i] = c[i] + 1
                i = 1

                return A
            else
                c[i] = 1
                i = i + 1
            end
        end

        return nil
    end
end

function prob.permutationPairs( arr )
    checkType( 'Module:prob.permutationPairs', 1, arr, 'table' )
    return makePairFunction( arr, nil, prob.permutationIterator )
end

function prob.permutationRepIterator( counts )
    checkType( 'Module:prob.permutationRepIterator', 1, counts, 'table' )

    local A = {}
    for i = 1, #counts do
        for j = 1, counts[i] do
            A[#A+1] = i
        end
    end

    local res = {}

    local function rotateRight( arr, i, j )
        for k = j, i + 1, -1 do
            arr[k], arr[k - 1] = arr[k - 1], arr[k]
        end
    end

    local function clone( t )
        local res = {}
        for i = 1, #t do
            res[i] = t[i]
        end
        return res
    end

    local function generate( k, A )
        if k == 1 then
            table.insert( res, clone( A ) )
        else
            local seen = {}
            local permSubset = true
            for i = 0, k - 1  do
                if permSubset then
                    generate( k - 1, A )
                end

                permSubset = false
                if k%2 == 0 then
                    if A[i + 1] ~= A[k] and i < k - 1 then
                        seen[A[k]] = true
                        A[i+1], A[k] = A[k], A[i+1]

                        if not seen[A[k]] then
                            permSubset = true
                        end
                    end
                else
                    if A[1] ~= A[k] then
                        seen[A[k]] = true
                        A[1], A[k] = A[k], A[1]

                        if not seen[A[k]] then
                            permSubset = true
                        end
                    end

                    if not permSubset and i < k - 1 then
                        rotateRight( A, 1, k - 1 )
                    end
                end
            end
        end
    end

    generate( #A, A )

    local i = 0
    return function()
        i = i + 1
        return res[i]
    end
end

function prob.permutationRepPairs( arr, counts )
    checkType( 'Module:prob.permutationRepPairs', 1, arr, 'table' )
    checkType( 'Module:prob.permutationRepPairs', 2, counts, 'table', true )

    local values = {}

    if counts then
        values = arr
    else
        counts = {}
        for k, v in pairs( arr ) do
            if type( k ) == 'number' then
                assert( type( v ) == 'number', string.format( "Invalid value at index  (expected number, got %s)", k, type( v ) ) )
            else
                assert( type( v ) == 'number', string.format( "Value '%s' has no count given (expected number, got %s)", k, type( v ) ) )
            end
            table.insert( values, k )
            table.insert( counts, v )
        end
    end

    local it = prob.permutationRepIterator( counts )

    return function( it )
        local indexes = it()
        if indexes then
            local res = {}
            for i, j in ipairs( indexes ) do
                res[i] = values[j]
            end
            return indexes, res
        end
    end, it
end

function prob.variationIterator( n, p )
    checkType( 'Module:prob.variationIterator', 1, n, 'number' )
    checkType( 'Module:prob.variationIterator', 2, p, 'number' )
    if p < 0 or n < 0 or n < p then
        return function() end
    elseif p == 0 or n == 0 then
        return function( _, i )
            if i == 0 then
                return {}
            end
        end, nil, 0
    end

    local combIt = prob.combinationIterator( n, p )
    local comb = combIt()
    local permIt = prob.permutationPairs( comb )

    return function()
        local _, res = permIt()

        if res ~= nil then
            return res
        end

        comb = combIt()

        if comb ~= nil then
            permIt = prob.permutationPairs( comb )
            _, res = permIt()
            return res
        end

        return nil
    end
end

function prob.variationPairs( arr, p )
    checkType( 'Module:prob.variationPairs', 1, arr, 'table' )
    checkType( 'Module:prob.variationPairs', 2, p, 'number' )
    return makePairFunction( arr, p, prob.variationIterator )
end

function prob.variationRepIterator( n, p )
    checkType( 'Module:prob.variationRepIterator', 1, n, 'number' )
    checkType( 'Module:prob.variationRepIterator', 2, p, 'number' )
    if not p or p < 0 then
        p = 0
    end

    local indexArr = {}
    for i = 1, p do
        indexArr[i] = 1
    end
    indexArr[1] = 0

    return function()
        indexArr[1] = indexArr[1] + 1

        for i = 1, p do
            if indexArr[i] > n then
                indexArr[i] = 1
                indexArr[i+1] = indexArr[i+1] and indexArr[i+1] + 1
            else
                return indexArr
            end
        end

        if p == 0 and indexArr[1] == 1 then
            return {}
        end
    end
end

function prob.variationRepPairs( arr, p )
    checkType( 'Module:prob.variationRepPairs', 1, arr, 'table' )
    checkType( 'Module:prob.variationRepPairs', 2, p, 'number' )
    return makePairFunction( arr, p, prob.variationRepIterator )
end

return prob
-- </nowiki>