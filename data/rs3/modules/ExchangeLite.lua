-- <nowiki>
--
-- 
---- Lightweight version of Module:Exchange
local p = {}
local mwLoadData = mw.loadData

local function loadData( item )
    return mwLoadData( 'Module:Exchange/' .. item )
end

function p.load( t )
	if t.args then
		local args = t.args
		return loadData( args[1] )[args[2]]
	else
		return loadData( t.item or t[1] )[t.dataType or t[2]]
	end
end

function p.price( item )
	local data = mw.loadJsonData('Module:GEPrices/data.json')
	if data[item] then
		return data[item]
	end
	item = string.gsub( item or '', '&#0?39;', "'" ):gsub( '_', ' ' ):gsub( '  +', ' ' ):gsub( '^.', string.upper )
	return data[item]
end

function p.volume( item )
	local data = mw.loadJsonData('Module:GEVolumes/data.json')
	if data[item] then
		return data[item]
	end
	item = string.gsub( item or '', '&#0?39;', "'" ):gsub( '_', ' ' ):gsub( '  +', ' ' ):gsub( '^.', string.upper )
	return data[item]
end

return p
-- </nowiki>