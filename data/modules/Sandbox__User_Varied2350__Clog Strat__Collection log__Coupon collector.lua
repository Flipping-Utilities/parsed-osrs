-- Implements various calculations useful for
-- determining average expected time to complete 
-- a collection log of a given state.

-- Original source: @TheRealOne (https://docs.google.com/spreadsheets/d/1jaL66o5KW7OKJLpYFlGFL2HOfmZU5Z2iHvmIJsa6-t0/)
local p = {}

function p.combinations(array, k, callback)
	if k == 0 then
		callback({})
		return
	end
	
	local indices = {}
	
	for i=1, k do
		indices[i] = i
	end
	
	while true do
		-- make a copy
		local combinations = {}
		for i = 1, k do
			combinations[i] = indices[i]
		end
		
		callback(indices)
		
		local i = k
		while i >= 1 and indices[i] == n - k + i do
			i = i - 1
		end
		
		if i == 0 then
			break
		end
		
		indices[i] = indices[i] + 1
		
		for j = i + 1, k do
			indices[j] = indices[j - 1] + 1
		end
	end
end

function p.binomialCoefficient(n, k)
	if k == 0 or k == n then
		return 1
	end
	
	return binomialCoefficient(n - 1, k - 1) + binomialCoefficient(n - 1, k)
end

function p.partialCompletion(m, j, p)
	local result = 0.0
	
	for q=0, j - 1 do
		local binomialCoeff1 = math.pow(-1, j - 1 - q) * binomialCoefficient(m - q - 1, m - j)
		
		combinations(#p, q, function(J)
			local sumPJ = 0
			
			for _, idx in ipairs(J) do
				sumPJ = sumPJ + p[idx]
			end
			
			result = result + binomialCoeff1 / (1 - sumPJ)
		end)
	end
	return result
end


return p