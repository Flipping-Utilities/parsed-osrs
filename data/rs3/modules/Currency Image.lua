-- <nowiki>
local libraryUtil = require( 'libraryUtil' )

-- Static table to map currency names to filename and available quantities
local currencies = mw.loadData("Module:Currency Image/data");

--
-- Like Module:Coins image, but for multiple currency types
--
return function(name, quantity)
	libraryUtil.checkType( 'Currency Image', 1, name, 'string' )
	libraryUtil.checkTypeMulti( 'Currency Image', 2, quantity, {'string', 'number'} )
	
	local coinType = currencies[string.lower(name)]
	if coinType == nil then
		-- Unrecognized currency type
		return
	end
	
	local max_q = 1
	if type( quantity ) == 'number' then
		max_q = math.abs( quantity )
	else
		for v in mw.text.gsplit( tostring( quantity or '' ), '[,%-–]' ) do
			local value = math.abs( tonumber( v ) or 0 )
			if value > max_q then
				max_q =  value
			end
		end
	end

	local q = 1
	for _, bin in ipairs( coinType.bins ) do
		if max_q >= bin then
			q = bin
		else
			break
		end
	end
	
	return string.format( coinType.filename, q )
end
-- </nowiki>