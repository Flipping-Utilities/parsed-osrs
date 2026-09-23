local chart = require( 'Module:Chart data' )
local skillingSuccess = require( 'Module:Skilling success chart' )

local p = {}

-- s/tick
local tickRate = 0.6

function p._calculateDataSets(args)
	local dataSets = skillingSuccess._calculateDataSets(args)
	-- Assuming an xp drop every single action
	local tickDelay = args.ticksPerAction * tickRate
	local maxXpHr = (3600 / tickDelay) * args.xpPerAction * (1 + args.xpBonus)

	for i, dataSet in ipairs(dataSets) do
		if dataSet['data'] then
			for j, point in ipairs(dataSet['data']) do
				local successChance = point['y']
				local failureChance = 1 - successChance
				if args.failurePenalty <= 0 or failureChance == 0 then
					-- /Long-term/ expected xp/hr
					dataSets[i]['data'][j]['y'] = math.floor(maxXpHr * successChance)
				else
					-- need to recalculate max XP/hr, accounting for the expected tick penalty
					local expectedDelay = (tickDelay * successChance) + (args.failurePenalty * tickRate) * failureChance
					local adjustedMaxXpHr = (3600 / expectedDelay) * args.xpPerAction * (1 + args.xpBonus)
					
					dataSets[i]['data'][j]['y'] = math.floor(adjustedMaxXpHr * successChance)
				end
			end
		end
	end

	return dataSets
end

function p.main(frame)
	local args = frame:getParent().args
	args.ticksPerAction = tonumber(args.ticksPerAction or 4)
	args.failurePenalty = tonumber(args.failurePenalty or 0)
	-- silent failure
	args.xpPerAction = tonumber(args.xpPerAction or 0)
	args.xpBonus = tonumber(args.xpBonus or 0)
	args.yStep = tonumber(args.yStep or 5000)

    local plot = chart.newChart{ type = 'scatter' }
        :setTitle( args.label )
        :setDimensions( '540px', '400px', '540px', '400px', true )
        :setXLabel( args.xlabel or 'Level' )
        :setYLabel( args.ylabel or 'XP per hour' )
        :setXLimits( nil, nil, 1 )
        :setYLimits( (args.startAtZero == 'yes' and 0 or nil), nil, args.yStep )
        :setDatasetsPerGroup(3)
   
	local dataSets = p._calculateDataSets(args)
	for i, dataSet in ipairs(dataSets) do
		plot:newDataSet(dataSet)
	end

    return plot
end

return p