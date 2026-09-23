-- <nowiki>
-- Implements [[Template:Globals]]

local p = {}

local globals = mw.loadData('Module:Globals/data')
local opairs = require('Module:Utils').opairs
 
function p.main(frame)
	local args = frame:getParent().args
	local global = args[1] -- The arg that was passed
	local val = globals[global][2] -- The value associated with the arg
	
	if (val == nil) then
		val = ''
	end

	return val
end

function p.doc_list()
	local ret_table = ''
	-- opairs modifies table and loadData is read-only
	globals = require('Module:Globals/data')
	
	for k,v in opairs(globals) do
		ret_table = ret_table .. string.format("*''<kbd>%s</kbd>'' &mdash; returns %s: %s\n", k, v[1], v[2])
	end
	
	ret_table = ret_table:sub(1, -2)
	
	return ret_table
end
 
return p