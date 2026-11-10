local chart = require('Module:Chart data')
local pt = require('Module:Paramtest')
local hc = pt.has_content

local p = {}

function p.stat_random(low, high, level)
	-- RS3's interpolation function. Not monotonically increasing!!!!
	local function jagex_interpolate(low, high, level)
	    return math.floor((low * (99 - level)) / 98) + math.floor((high * (level - 1)) / 98)
	end

    return jagex_interpolate(low, high, level) * 10000 / 2550001
end

-- Strictly constrain probabilities to be between 0 and 1 (there's some numerical instability in the interpolation functions)
local function clamp(value)
    return math.max(math.min(value, 1), 0)
end

local function invert_chance_postroll(chance,level)
	return 1 - chance
end

-- This function rolls stat_random with normal low/high values first,
-- then rolls stat_random again with a "bonus" low/high if the first roll fails.
-- Same as a not mutually exclusive or: P(A OR B) = P(A) + P(B) - P(A AND B)
function p.bonus_interp(low, high, bonuslow, bonushigh, level)
	local base_roll = clamp(p.stat_random(low, high, level))
	local bonus_roll = clamp(p.stat_random(bonuslow, bonushigh, level))
	return base_roll + bonus_roll - base_roll * bonus_roll
end

function p.cascade_interp(regimes, level, index)
	local rate = 1.0
	for idx, regime in ipairs(regimes) do
		local low = (level >= regime.altreq) and regime.altlow or regime.low
		local high = (level >= regime.altreq) and regime.althigh or regime.high
		if idx == index then
			return rate * p.stat_random(low, high, level)
		end
		if level >= regime.req then
			rate = rate * (1 - p.stat_random(low, high, level))
		end
	end
end

local function generalInputParse(args)
    local regimes = {}
    local i = 1
	while hc(args['label' .. i]) do
		local low = tonumber(args['low' .. i] or 0)
		local high = tonumber(args['high' .. i] or 255)
		table.insert(regimes, {
			label = args['label' .. i],
			low = low,
			high = high,
			bonuslow = args['bonuslow' .. i],
			bonushigh = args['bonushigh' .. i],
			req = tonumber(args['req' .. i] or 1),
			altlow = args['altlow' .. i] or low,
			althigh = args['althigh' .. i] or high,
			altreq = tonumber(args['altreq' .. i] or math.huge),
			image = args['image' .. i],
			color = args['color' .. i],
			exponent = tonumber(args['exponent' .. i] or 1),
			mult = tonumber(args['mult' .. i] or 1),
			pre_roll_modifier = args['pre_roll_modifier' .. i],
    		post_roll_modifier = args['post_roll_modifier' .. i]
		})
		i = i + 1
	end

    return regimes
end

local function createSkillDataSets(regimes, minLevel, maxLevel, showbefore, roll_type)
    local dataSets = {}

    for index, regime in ipairs(regimes) do
        local under_data = {}
        local at_data = {}
        local max_data = {}

        for level = minLevel, maxLevel do
		    local low = regime.low
		    local high = regime.high
		
		    if regime.pre_roll_modifier and type(regime.pre_roll_modifier) == "function" then
		        low, high = regime.pre_roll_modifier(low, high, level)
		    end

		    local chance
        	-- #TODO: add "type=bonus" to all the bonus interp calls
		    if roll_type == "bonus" or regime.bonuslow then
		        chance = p.bonus_interp(low, high, regime.bonuslow, regime.bonushigh, level)
		    elseif roll_type == "cascade" then
		        chance = p.cascade_interp(regimes, level, index)
		    else
		        chance = p.stat_random(low, high, level)
		    end
		    
		    if regime.post_roll_modifier then
		    	if type(regime.post_roll_modifier) == "function" then
		        	chance = regime.post_roll_modifier(chance, level)
		    	elseif regime.post_roll_modifier == 'invert' then
		    		chance = invert_chance_postroll(chance,level)
	        	end
		    end
		    
        	chance = chance * (1/regime.mult)
			chance = chance ^ regime.exponent -- exponent is 1 by default

			chance = clamp(chance)

            if (level < regime.req) and showbefore then
                table.insert(under_data, { x = level, y = chance })
            end
            if level >= regime.req then
                table.insert(at_data, { x = level, y = chance })

                if chance >= 0.999 and #max_data == 0 then
                    table.insert(max_data, { x = level, y = chance })
                end
            end
        end

        -- Line at level requirement (first in group so the tooltip shows it at req)
        table.insert(dataSets, {
            data = at_data,
            label = regime.label .. "  ",
            baseColor = regime.color,
            borderDash = {},
            borderCapStyle = 'round',
            pointRadius = 0,
            pointStyleImg = regime.image,
        })

        -- Dashed line before level requirement
        table.insert(dataSets, {
            data = under_data,
            label = regime.label .. "  ",
            baseColor = regime.color,
            borderDash = { 5, 5 },
            borderCapStyle = 'round',
            pointRadius = 0,
            pointStyleImg = regime.image,
        })

        -- Circle at max chance
        table.insert(dataSets, {
            data = max_data,
            label = regime.label .. "  ",
            baseColor = regime.color,
            borderDash = {},
            borderCapStyle = 'round',
            pointRadius = 5,
            pointStyleImg = regime.image,
        })
    end
    return dataSets
end

function p.main(frame)
    local args = frame:getParent().args
    return p._main(args)
end

function p._main(args)
    local skill = string.lower(args.skill or '')
    local minLevel = tonumber(args.lowLevel or 1)
    local maxLevel = tonumber(args.highLevel or 99)
    local showbefore = string.lower(args.showbefore or '') ~= 'no'
	local roll_type
	if args.cascade == "yes" then
		roll_type = "cascade"
	end
	local regimes = generalInputParse(args)
    
    local dataSets = createSkillDataSets(regimes, minLevel, maxLevel, showbefore, roll_type)
    
    local plot = chart.newChart { type = 'scatter' }
        :setTitle(args.label)
        :setDimensions('540px', '400px', '300px', '300px', true)
        :setTooltipFormat('skillingSuccess')
    	:setDatasetsPerGroup(3)
        
        :setXLabel(args.xlabel or 'Level')
        :setXLimits(nil, nil, 1)
        
        :setYLabel(args.ylabel or 'Success chance')
	    :setYLimits(nil, nil, 0.1)
		:setYFormat('percent')
        :setOptions{
			tooltips = {
				mode = 'nearest',
				axis = 'x',
				intersect = false
			}
		}


    if skill ~= '' then
        plot.options.colorPalette = chart.colorPalettes.tiers
    end

    for _, dataSet in ipairs(dataSets) do
        plot:newDataSet(dataSet)
    end

    return plot
end

return p