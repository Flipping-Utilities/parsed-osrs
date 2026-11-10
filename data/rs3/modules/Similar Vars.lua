local navbox = require('Module:Navbox')
local VariablesLua = mw.ext.VariablesLua
local p = {}

-- Create a link the the varb/varp page with the text 'NAME(index)'
local function generatePagelink(t)
	if t['index'] and t['name'] then
		return '*[['..t['page_name']..'|'..t['name']..'('..t['index']..')]]'
	end
	-- If missing any of the required bucket data, just return the pagelink
	return '*[['..t.page_name..']]'
end

local function getRelatedVars(content)
	local data = bucket("varbit")
		.select("page_name", "name", "index")
		.where("content", content)
		.orderBy("index", "asc")
		.run()
	local lineTable = {}
	if data == nil then
		return ''
	end
	for _, t in ipairs(data) do
		table.insert(lineTable, generatePagelink(t))
	end
	return table.concat(lineTable, "\n")
end

function p.main(frame)
	local args = frame:getParent().args
	local content = VariablesLua.var('content_var', 'Unknown')
	local raw_content = VariablesLua.var('raw_content_var', 'Unknown')

	args = {}
	args['name'] = 'Similar Vars'
	args['title'] = raw_content .. ' vars'
	
	args['group1'] = getRelatedVars(content)
	args['style1'] = 'text-align:center;'
	if args['group1'] ~= '' then
		return navbox._navbox(args)
	else
		return ''
	end
end

return p