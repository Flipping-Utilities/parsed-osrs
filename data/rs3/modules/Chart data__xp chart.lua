local xp = mw.loadData('Module:Experience/dataunr')
local xp_elite = mw.loadData('Module:Experience/elitedataunr')
local helper = require('Module:Chart data')

local palette = "spring_pastels"
local colors = {
	tostring(helper.colorPalettes[palette][1]:fade(0.2)),
	tostring(helper.colorPalettes[palette][1]),
	tostring(helper.colorPalettes[palette][2]:fade(0.2)),
	tostring(helper.colorPalettes[palette][2])
}

local xp_sliced = {}

local i = 1
while xp[i] < 2e8 do
	xp_sliced[i] = xp[i]
	i = i + 1
end

local data = {
	type = 'scatter',
	data = {
		datasets = {
			{
				label = 'Standard skill',
				showLine = true,
				fill = false,
				backgroundColor = colors[1],
				borderColor = colors[2],
				data = helper.convertToXYFormat(xp_sliced)
			},
			{
				label = 'Elite skill',
				showLine = true,
				fill = false,
				backgroundColor = colors[3],
				borderColor = colors[4],
				pointStyle = 'crossRot',
				pointRadius = 6,
				data = helper.convertToXYFormat(xp_elite)
			}
		}
	},
	options = {
		maintainAspectRatio = false,
		tooltips = {
			mode = 'x',
			position = 'nearest',
			intersect = false
		},
		scales = {
			x = {
				scaleLabel = {
					display = true,
					labelString = 'Level'
				}
			},
			y = {
				scaleLabel = {
					display = true,
					labelString = 'Experience'
				}
			}
		}
	}
}

return data