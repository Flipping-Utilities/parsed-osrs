local chart = require('Module:Chart data')
local p ={}

-- Calculates the cumulative geometric distribution for a given probability of
-- success up to a maximum number of attempts. 
local function geometric(prob, max_attempts)
	local sum = 0
	local results = {1}
	for k = 1, max_attempts do
	    local val = ((1 - prob) ^ (k - 1)) * prob
	    sum = sum + val
	    results[k + 1] = 1 - sum
	end
	
	return results
end

local max_attempts = 55
local x_data = geometric(0.1, max_attempts)
p.x = x_data

function p.bar()
    local plot = chart.newChart{ type = 'bar' }
        :setDimensions( '40vw', '30vh', 300, 300, true )
        :setTitle( 'Probability of chopping at least x Bloodwood logs' )
        :setXLabel( 'Logs chopped' )
        :setYLabel( 'Probability' )

    local set = plot:newDataSet()
    local labels = {}
    for x = 1, max_attempts + 1 do
        set:addDataPoint(x_data[x])
        labels[x] = x
    end
    set.label = 'All levels'
    set.color = chart.colorPallets.green[3]

    plot:addDataLabels( labels )
    return plot
end



return p