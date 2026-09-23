local p = {}

function p.main(frame)
	return p._main(frame:getParent().args)
end

function p._main(args)
	local unlockedItems = args['wsdata-json']
	local pearlsPerHour = args['pearl']
	
	return "<p>Hi from module</p>"
end

function p.remainingTable(clog_data)
	return "Hi from remainingTable"
end

return p