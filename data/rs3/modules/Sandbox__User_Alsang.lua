local yn = require('Module:Yesno')

local p = {}

function p.main(frame)
	
	local args = frame:getParent().args
	local nobucket = yn(args.nobucket)
	
	-- keys have to be numbers
	-- repeated keys are impossible
	local data = {}
	for val,state in pairs(args) do
		if type(val)=='number' then
			table.insert(data,{val=val,state=state})
		end
	end
	
	-- sort to numerical order of key
	local function val_sort(a,b)
		local a_val = a and type(a)=='table' and a.val or 0
		local b_val = b and type(b)=='table' and b.val or 0
		return a_val < b_val
	end
	table.sort(data,val_sort)
	
	-- create the output table
	local out = mw.html.create('table')
		:addClass('wikitable')
		:tag('tr')
			:tag('th')
				:wikitext('Value')
			:done()
			:tag('th')
				:wikitext('State')
			:done()
		:done()
	
	-- add in each value and state
	for _,d in pairs(data) do
		if not nobucket then
			bucket('varbit_state').put(d) -- write to bucket (in numerical order)
		end
		out:tag('tr')
			:tag('td')
				:wikitext(d.val)
			:done()
			:tag('td')
				:wikitext(d.state)
			:done()
		:done()
	end
	
	out:done()
	return out
	
end

return p