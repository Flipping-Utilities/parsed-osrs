local p = {}

local params = require('Module:Paramtest')

function p.main(frame)
	local args = frame:getParent().args
	local steps_list = {}
	for i = 1, 10, 1 do
		local step = args['step'..i]
		if step and params.has_content(step) then
			local num = i
			local stepDetail = step

			table.insert(steps_list, {
				num = num,
				step = stepDetail
			} )
		end
	end
	
	local function make_step_row(num, step)
		return mw.html.create('tr')
			:tag('td'):css({['text-align'] = 'Left', ['word-break'] = 'break-word'}):wikitext(tostring(num)..'. '..step.step):done()
	end
		
	local instructionsTable = mw.html.create('table'):addClass('wikitable align-left-1')
	instructionsTable:tag('tr')
		:tag('th'):wikitext('Steps'):done()

		for i, v in ipairs(steps_list) do
			instructionsTable:node(make_step_row(i, v))
		end
	
	return tostring(instructionsTable)
end

return p