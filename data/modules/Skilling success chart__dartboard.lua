local interp = require('Module:Skilling success chart').interp
local chart = require('Module:Chart data')
local function clamp(value)
    return math.max(math.min(value, 1), 0)
end

local chance_data = {
	dartboard = {
		_order={1,2,3},
		[1] = {75,240,'yellow'},
		[2] = {50,240, 'blue'},
		[3] = {15,160, 'green'}
	},
	archery = {
		_order = {1,2,3,5,10},
		[1] = {150,240, 'yellow'},
		[2] = {75,240, 'darkgrey'},
		[3] = {50,240, 'purple'},
		[5] = {15,160, 'blue'},
		[10] = {8,120,'green'}
	}
}
local max_level = 99

local p = {}

function p.main(frame)
	local args = frame.args
	local charttype = args[1]
	local chances = chance_data[charttype]
	if not chances then
		error('invalid type provided')
	end
	local calced = {[0]={}}
	for i,v in ipairs(chances._order) do
		calced[i]={}
	end
	for lvl=1,max_level do
		local ch_at_lv = {}
		for i,v in ipairs(chances._order) do
			ch_at_lv[i] = clamp(interp(chances[v][1], chances[v][2], lvl))
		end
		local ch_so_far = 1
		for i,v in ipairs(chances._order) do
			local ch
			ch_so_far = ch_so_far * ch_at_lv[i]
			if i == #chances._order then
				ch = ch_so_far
			else
				ch = ch_so_far * (1-ch_at_lv[i+1])
			end
			ch = clamp(ch)
			table.insert(calced[i], {x=lvl,y=ch})
			
			if i == 1 then
				table.insert(calced[0], {x=lvl,y=clamp(1-ch_so_far)})
			end
		end
	end
	
	local datasets = {}
	for i=0,#chances._order do
		local ch_val, ch_num
		if i == 0 then
			ch_num = 0
			ch_val = {[3]='red'}
		else
			ch_num = chances._order[i]
			ch_val = chances[ch_num]
		end
		table.insert(datasets, {
			data = calced[i],
			color = ch_val[3],
			borderDash={},
			borderCapStyle='round',
			pointRadius=0,
			label='Score '.. ch_num .. ' points  '
		})
	end
	local plot = chart.newChart{ type = 'scatter' }
        :setTitle(args.label)
        :setDimensions('540px', '400px', '300px', '300px', true)
        :setTooltipFormat('skillingSuccess')
        
        :setXLabel(args.xlabel or 'Level')
        :setXLimits(nil, nil, 1)
        
        :setYLabel(args.ylabel or 'Success chance')
	    :setYLimits(nil, nil, 0.1)
		:setYFormat('percent')
    for _, dataSet in ipairs(datasets) do
        plot:newDataSet(dataSet)
    end
	return plot
end

return p