-- <nowiki>
-- Copied from https://runescape.wiki/w/Module:Drop_rate_calculator
local yesno = require( 'Module:Yesno' )
local chart = require( 'Module:Chart data' )
local array = require( 'Module:Array' )
local addCommas = require( 'Module:Addcommas' )._add
local prob = require( 'Module:Sandbox/User:Cheeseyx/Probability' )
local binomialPMF = prob.binomialPMF
local binomialCDF = prob.binomialCDF
local min = math.min
local max = math.max
local log10 = math.log10
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local inf = 1/0

local p = {}

local function formatDecimal( num, isTrueMinMax )
    num = max( min( num, 100 - 1e-9 ), 0 )
    local x = num

    if num > 99 then
        x = abs( 100 - num )
    end

    local mag = min( max( -floor( math.log10( x ) ) + 2, 2 ), 9 )
    local res = string.format( '%.' .. mag .. 'f', num  ):gsub( '0+$', '' ):gsub(  '%.$', '.0' ) .. '%'

    if num == 100 - 1e-9 then
        if isTrueMinMax then
            res = '100%'
        else
            res = '99.999999999...%'
        end
    end

    if num < 2^-1074 then
        if isTrueMinMax then
            res = '0%'
        else
            res = res .. string.format( ' (<span class="hover-text" title="Exact value can\'t be show as it is smaller than the lowest value that can be represented by a 64 bit floating point">Less than</span> %.2e%%)', 2^-1074 )
        end
    elseif num < 1e-4 then
        res = res .. string.format( ' (%.2e%%)', num )
    end

    return res
end

local function round( num, dp )
    dp = dp or 0
    return floor( num * 10^dp + 0.5 ) / 10^dp
end

local function processDroprate( droprate )
    local d = tonumber( mw.ext.ParserFunctions.expr( droprate ) ) or 1

    if d > 1 then
        return 1 / d
    end

    return d
end

-- Chart.js doesn't like very small values with logarithmic axis so change those to zero instead
local function fixedPointToZero( t, removeZeroValues )
    for i = 1, #t do
        if t[i].y < 2^-1022 then
            t[i].y = 0
        end
    end

    if removeZeroValues then
        for i = #t, 1, -1 do
            if t[i].y == 0 then
                table.remove( t, i )
            end
        end
    end

    return t
end

local function plural( val )
    return val == 1 and '' or 's'
end

local function genKcArr( kills, dropCount, viewOptions )
    local lowerBound = dropCount
    local upperBound = 2 * kills

    if viewOptions.useCustomViewRange and viewOptions.customViewRangeType == 'Kill count' then
        lowerBound = viewOptions.lowerBound
        upperBound = viewOptions.upperBound
    end

    local stepSize = max( ceil( (upperBound - lowerBound) / 500 ), 1 )
    local kcArr = array.range( lowerBound, upperBound, stepSize )
    kcArr.stepSize = stepSize

    return kcArr
end

local function calcChanceVsKcArrays( kcArr, kills, droprate, dropCount, threshold, viewOptions )
    local atLeastProbArrThreshold = {}
    local atLeastProbArrNoThreshold = {}
    local exactProbArrNoThreshold = {}

    local mean = (1 / droprate) * dropCount
    local needsMorePrecision = (viewOptions.scaleType == 'logarithmic')
        or (viewOptions.useCustomViewRange == false and kills * 2 < mean)
        or (viewOptions.useCustomViewRange == true and (mean < viewOptions.lowerBound or viewOptions.upperBound < mean))

    for _, kc in ipairs( kcArr ) do
        if threshold then
            local atLeastProbNoThreshold = prob.noThreshold( droprate, kc ) * 100
            table.insert( atLeastProbArrNoThreshold, { x=kc, y=atLeastProbNoThreshold } )

            local probThreshold = prob.withThreshold( droprate, threshold, 0, kc ) * 100
            table.insert( atLeastProbArrThreshold, { x=kc, y=probThreshold } )
        else
            local exactProbNoThreshold = binomialPMF( droprate, kc, dropCount )
            table.insert( exactProbArrNoThreshold, { x=kc, y=100 * exactProbNoThreshold } )

            local atLeastProbNoThreshold = max( 2^-1020, 1 - binomialCDF( droprate, kc, 0, dropCount - 1 ) )
            if atLeastProbNoThreshold < 1e-9 and (abs( kc - kills ) <= kcArr.stepSize or needsMorePrecision) then
                atLeastProbNoThreshold = binomialCDF( droprate, kc, dropCount, inf )
            end
            table.insert( atLeastProbArrNoThreshold, { x=kc, y=math.max( 100 * atLeastProbNoThreshold, 0 ) } )
        end
    end

    return atLeastProbArrNoThreshold, exactProbArrNoThreshold, atLeastProbArrThreshold
end

local function setYAxisTickFormat( plot, axisType, ... )
    local findMin = function( arr )
        local val = array.max_by( arr, function(val) return val.y == 0 and -inf or -val.y end )
        return val and val.y or inf
    end
    local findMax = function( arr )
        local val = array.max_by( arr, function(val) return val.y end )
        return val and val.y or -inf
    end
    local minVal = inf
    local maxVal = -inf
    local setToScientific = false

    if axisType == 'logarithmic' then
        for _, arr in pairs{ ... } do
            minVal = min( minVal, findMin( arr ) )
            if minVal < 1e-6 then
                setToScientific = true
                break
            end
        end
    else
        for _, arr in pairs{ ... } do
            maxVal = max( maxVal, findMax( arr ) )
        end
        if maxVal < 1e-3 then
            setToScientific = true
        end
    end

    if setToScientific then
        plot:setOptions{
            scales = {
                y = {
                    ticks = {
                        format = {
                            notation = 'scientific',
                            maximumSignificantDigits = 3
                        }
                    }
                },
            }
        }
    end
end

local function genChanceVsKcPlot( atLeastProbArrNoThreshold, exactProbArrNoThreshold, atLeastProbArrThreshold, kills,
                                  dropCount, hasThreshold, atLeastDropCountProb, exactDropCountProb, viewOptions )
    local plot = chart.newChart{ type='scatter' }
        :setTitle( 'Chance vs kill count' )
        :setDimensions( 'max(1100px, 50vw)', 'max(500px, 45vh)' )
        :setXLabel( 'Kill count' )
        :setYLabel( 'Chance [%]' )
        :setYAxisType( viewOptions.scaleType )

    if dropCount == 0 then
        plot:setTitle( 'Chance to get no drop' )
            :showLegend( false )
    --[[
    else
        plot.options.colorPalette = {
            chart.colorPalettes.qualitative[1],
            chart.colorPalettes.qualitative[3],
            chart.colorPalettes.qualitative[2],
        }
    --]]
    end

    setYAxisTickFormat( plot, viewOptions.scaleType, atLeastProbArrNoThreshold, exactProbArrNoThreshold, atLeastProbArrThreshold )

    if dropCount > 0 then
        plot:newDataSet{
            data = atLeastProbArrNoThreshold,
            pointRadius = 0,
            label = hasThreshold and 'Without threshold' or ('At least ' .. dropCount .. ' drop' .. plural( dropCount ))
        }
    end

    if hasThreshold then
        plot:newDataSet{
            data = atLeastProbArrThreshold,
            pointRadius = 0,
            label = 'With threshold',
        }
    else
        plot:newDataSet{
            data = exactProbArrNoThreshold,
            pointRadius = 0,
            label = 'Exactly ' .. dropCount .. ' drop' .. plural( dropCount )
        }
    end

    if viewOptions.useCustomViewRange and viewOptions.customViewRangeType == 'Kill count' then
        plot:setXLimits( viewOptions.lowerBound, viewOptions.upperBound,
            10^round( log10( viewOptions.upperBound - viewOptions.lowerBound ) - 1 ) )
    else
        local y = atLeastDropCountProb
        if dropCount == 0 then
            y = exactDropCountProb
        end
        plot:newDataSet{
            data = fixedPointToZero{ {x=0, y=y}, {x=kills, y=y}, {x=kills, y=0} },
            pointRadius = 0,
            borderDash = {10, 10},
            borderWidth = 1,
            lineTension = 0,
            label = '- - -'
        }
    end

    return plot
end

local function calcChanceVsDropCount( droprate, kc, viewOptions )
    local sd = math.sqrt( kc * droprate * (1 - droprate) )
    local mean = kc * droprate
    local lowerBound = max( 0, mean - 5 * sd )
    local upperBound = max( 5, mean + 5 * sd )

    if viewOptions.scaleType == 'logarithmic' then
        lowerBound = max( 0, mean - 7.5 * sd )
        upperBound = max( 5, mean + 7.5 * sd )
    end

    if viewOptions.useCustomViewRange and viewOptions.customViewRangeType == 'Drop count' then
        lowerBound = viewOptions.lowerBound
        upperBound = viewOptions.upperBound
    end

    local stepSize = max( floor( (upperBound - lowerBound) / 250 ), 1 )
    local chanceArr = prob.binomialPMFArr( droprate, kc, lowerBound, upperBound, stepSize )

    for i = 1, #chanceArr do
        chanceArr[i].y = chanceArr[i].y * 100
    end

    return chanceArr
end

local function genChanceVsDropCountPlot( chanceArr, kc, viewOptions )
    local plot = chart.newChart{ type='scatter' }
        :setTitle( 'Chance to get n drops in ' .. addCommas( kc ) .. ' kill' .. plural( kc ) )
        :setDimensions( 'max(1100px, 50vw)', 'max(450px, 40vh)' )
        :setXLabel( 'Drop count' )
        :setYLabel( 'Chance [%]' )
        :setYAxisType( viewOptions.scaleType )
        :showLegend( false )

    setYAxisTickFormat( plot, viewOptions.scaleType, chanceArr )

    if viewOptions.useCustomViewRange and viewOptions.customViewRangeType == 'Drop count' then
        plot:setXLimits( viewOptions.lowerBound, viewOptions.upperBound,
            10^round( log10( viewOptions.upperBound - viewOptions.lowerBound ) - 1 ) )
    end

    local set = plot:newDataSet{
        data = chanceArr,
        pointRadius = 4,
        backgroundAlpha = 1,
        hoverRadius = 6
    }

    if #chanceArr > 50 then
        set.pointRadius = 3
        set.hoverRadius = 5
    end
    if #chanceArr > 100 then
        set.pointRadius = 0
        set.hoverRadius = 0
    end

    return plot
end

function p.main( frame )
    return p._main( frame.args ) -- TODO: debugging - was frame:getParent().args in the rs3 page version that used templates, but osrs wiki module calcs seem to get args right off the frame
end

function p._main( args )
    local kills = tonumber( args.kills ) or 1
    local droprate = processDroprate( args.droprate )
    local hasThreshold = yesno( args.hasThreshold ) or false
    local threshold = hasThreshold and tonumber( args.threshold )
    local dropCount = not hasThreshold and tonumber( args.dropCount ) or 1
    local viewOptions = {
        scaleType = args.scaleType or 'linear',
        useCustomViewRange = yesno( args.useCustomViewRange ) or false,
        customViewRangeType = args.customViewRangeType,
        lowerBound = tonumber( args.lowerBound ) or 0,
        upperBound = tonumber( args.upperBound ) or 1
    }

    if droprate == nil then
        return 'Error in processing droprate'
    end
    if droprate <= 0 or droprate >= 1 then
        return 'Droprate must be between 0 and 1'
    end
    if viewOptions.lowerBound >= viewOptions.upperBound then
        return 'View range lower bound must be smaller than the upper bound'
    end

    local kcArr = genKcArr( kills, dropCount, viewOptions )
    local atLeastProbArrNoThreshold, exactProbArrNoThreshold, atLeastProbArrThreshold =
        calcChanceVsKcArrays( kcArr, kills, droprate, dropCount, threshold, viewOptions )

    local averageKC = round( prob.calcAverageKc( droprate, threshold ), 1 )
    local dropRateAtKillCount = prob.dropRateAtKillCount( droprate, threshold, kills )
    local killCountAt50 = prob.inverseBinomialCDF( 0.50, droprate, max( dropCount, 1 ), threshold )
    local killCountAt90 = prob.inverseBinomialCDF( 0.90, droprate, max( dropCount, 1 ), threshold )
    local killCountAt99 = prob.inverseBinomialCDF( 0.99, droprate, max( dropCount, 1 ), threshold )

    local atLeastDropCountProb = 0
    local exactDropCountProb = 0
    local lessThanOrEqualDropCountProb = 0
    local noDropProb
    local chanceVsDropCountArr = {}

    if hasThreshold then
        atLeastDropCountProb, noDropProb = prob.withThreshold( droprate, threshold, 0, kills )
        atLeastDropCountProb = atLeastDropCountProb * 100
        noDropProb = noDropProb * 100
    else
        atLeastDropCountProb = prob.binomialCDF( droprate, kills, max( dropCount, 1 ), inf ) * 100
        exactDropCountProb = prob.binomialPMF( droprate, kills, dropCount ) * 100
        lessThanOrEqualDropCountProb = 100 - atLeastDropCountProb + exactDropCountProb
        if lessThanOrEqualDropCountProb < 1e-6 then
            lessThanOrEqualDropCountProb = binomialCDF( droprate, kills, 0, dropCount ) * 100
        end
        chanceVsDropCountArr = calcChanceVsDropCount( droprate, kills, viewOptions )
    end

    fixedPointToZero( atLeastProbArrThreshold, true )
    fixedPointToZero( atLeastProbArrNoThreshold, true )
    fixedPointToZero( exactProbArrNoThreshold, true )
    fixedPointToZero( chanceVsDropCountArr, true )

    local chanceVsKcPlot = genChanceVsKcPlot( atLeastProbArrNoThreshold, exactProbArrNoThreshold, atLeastProbArrThreshold,
        kills, dropCount, hasThreshold, atLeastDropCountProb, exactDropCountProb, viewOptions )
    local chanceVsDropCountPlot = hasThreshold and '' or genChanceVsDropCountPlot( chanceVsDropCountArr, kills, viewOptions )

    local res = ''

    if hasThreshold == true then
        res = res .. string.format( 'Drop rate at %s kill%s: 1/%s or %s',
            addCommas( kills ),
            plural( kills ),
            string.format( '%.3f', 1 / dropRateAtKillCount ):gsub( '%.?0+$', '' ),
            formatDecimal( dropRateAtKillCount * 100 )
        )
    else
        res = res .. string.format( 'Drop rate: 1/%s or %s',
            string.format( '%.3f', 1 / dropRateAtKillCount ):gsub( '%.?0+$', '' ),
            formatDecimal( dropRateAtKillCount * 100 )
        )
    end

    res = res .. string.format( '\n* %s chance to get at least %s drop%s',
        formatDecimal( atLeastDropCountProb, kills < dropCount or kills == 0 ),
        addCommas( max( dropCount, 1 ) ),
        plural( max( dropCount, 1 ) )
    )
    .. string.format( string.rep( '\n** %s at %s kill%s', 3 ),
        '50%', addCommas( killCountAt50 ), plural( killCountAt50 ),
        '90%', addCommas( killCountAt90 ), plural( killCountAt90 ),
        '99%', addCommas( killCountAt99 ), plural( killCountAt99 )
    )

    if hasThreshold == true or dropCount == 0 then
        res = res .. string.format( '\n* %s chance to get no drop', formatDecimal( noDropProb or exactDropCountProb, kills == 0 ) )
    else
        res = res .. string.format( '\n* %s chance to get exactly %s',
            formatDecimal( exactDropCountProb, kills < dropCount ),
            addCommas( dropCount )
        )
        .. string.format( '\n* %s chance to get %s or less',
            formatDecimal( lessThanOrEqualDropCountProb, kills <= dropCount ),
            addCommas( dropCount )
        )
    end

    if dropCount > 0 then
        res = res .. '\nAverage kill count: ' .. addCommas( averageKC * dropCount )
    end

    res = res .. tostring( chanceVsKcPlot ) .. tostring( chanceVsDropCountPlot )

    return res
end

return p
-- </nowiki>