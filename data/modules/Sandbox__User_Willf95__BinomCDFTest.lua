local p = {}
local chart = require('Module:Chart data')

local function pieceProb(n)
    -- P(X >= 4) for X ~ Binomial(n, 1/12)
    local p1, q1 = 1/12, 11/12
    local sum = 0
    for k = 0, 3 do
        local binom = 1
        for j = 0, k-1 do
            binom = binom * (n - j) / (j + 1)
        end
        sum = sum + binom * p1^k * q1^(n-k)
    end
    return 1 - sum
end

function p.main()
	mw.log('Making chart')
	
	local plot = chart.newChart{ type = 'scatter' }
    plot:setDimensions('40vw', 400, 400, 400, true)
    plot:setXLabel('Trawler games (contribution ≥ 50)')
    plot:setYLabel('Chance of complete outfit')
    plot:setTooltipFormat('skillingSuccess')
    plot:setYLimits(0, 1, 0.1)
    
	local set = plot:newDataSet()
    set.data = chart.generateXYFromFunc(pieceProb, 0, 100)
    mw.logObject(data)
    set.label = 'Angler\'s outfit'
    set.showLine = true

	--mw.logObject(plot:makeMwLoadDataCompatible())
    return plot--:makeMwLoadDataCompatible()
    
end

return p