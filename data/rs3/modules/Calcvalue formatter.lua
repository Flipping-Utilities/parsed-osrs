local templateUtil = require("Module:TemplateUtil")
local marker = templateUtil.marker

local p = {}
local priceStr = '<span class="text-grey">Price</span>([[%s]])'

local trim = mw.text.trim

local START_TEMPLATE_NW	= mw.text.nowiki("{{")
local END_TEMPLATE_NW	= mw.text.nowiki("}}")

local function parseTemplateParams( template )
	if (type(template) == "table") then
		return template
	end

	return templateUtil.parseTemplateParams(template)
end

local function parseMaterialName( mat )
	local aliases = mw.loadData('Module:Disassemble/mats')
	local _mat = string.lower(trim(mat or ''))
	return aliases[_mat] or mat
end

local function formatGETotalqty( template )
    local params = parseTemplateParams( template )
    local res = {}
    
    local function f( nameprefix, qtyprefix )
    	local i = 1
    	local isMaterial = nameprefix == 'mat'
    	while params[ nameprefix..i ] ~= nil do
    		local name = isMaterial and parseMaterialName( params[ nameprefix..i ] ) or params[ nameprefix..i ]
        	if params[ qtyprefix..i ] == nil or params[ qtyprefix..i ] == '1' then
	            table.insert( res, string.format( priceStr, name ) )
        	else
	            table.insert( res, string.format( '%s &times; ' .. priceStr, params[ qtyprefix..i ], name ) )
        	end
	        i = i + 1
    	end
    end
    
    f( 'name', 'qty' )
    f( 'mat', 'matqty' )

    return table.concat( res, ' + ' )
end

local function formatMatcost( template )
	local params = parseTemplateParams( template)
	
	return string.format( priceStr, parseMaterialName( params[1] ) )
end

local function formatGETotal( template )
    local params = parseTemplateParams( template )

    for i, v in ipairs( params ) do
        params[i] = string.format( priceStr, params[i] )
    end

    return table.concat( params, ' + ' )
end

local function formatExpr( str )
    str = trim( str )
    str = string.gsub( str, '%s*([%+%-%*%/])%s*', function(x) return ' '..x..' ' end )
    str = string.gsub( str, '%*', '&times;' )
    str = string.gsub( str, '(%d+) / (%d+)', '%1/%2' )
    str = string.gsub( str, '%s+round%s+%d+', '' )
    return str
end

local function formatGEP( template )
    local params = parseTemplateParams( template )

    if params[2] then
        return string.format( '%s &times; ' .. priceStr, formatExpr( params[2] ), params[1] )
    end

    return string.format( priceStr, params[1] )
end

local function formatMatCostPrice(template)
	local params = parseTemplateParams(template);
	local mat = parseMaterialName(params[1]);
	local multi = params[2];

	if (multi) then
		return string.format('%s &times; ' .. priceStr, formatExpr(multi), mat);
	else
		return string.format(priceStr, mat);
	end
end

local function formatSimple( template )
    local params = parseTemplateParams( template )
    return string.format( priceStr, params[1] )
end

local function formatFunction( template, name )
    local params = parseTemplateParams( template )
    return string.format( '<span class="text-green">%s</span>(%s)', name, table.concat( params, ', ' ) )
end

local function makeFormatGEPMinMax(name)
	return function (template)
		local params = parseTemplateParams(template)

		for i, v in ipairs(params) do
			params[i] = string.format(priceStr, params[i])
		end

		return formatFunction(params, name)
	end
end

-- See [[Module:MinMax]].sum{ ... }
local function implFormatSum(params)
	local count = #params

	local sum = {}
	for i = 1, count do
		sum[i] = formatExpr(params[i])
	end
	
	return table.concat(sum, " + ", 1, count)
end

-- See [[Module:MinMax]].average{ ... }
local function formatAverage(template)
	local params = parseTemplateParams(template)
	return string.format(
		"(%s) / %s",
		implFormatSum(params),
		#params
	)
end

local formatters = {
    ['#expr'] = formatExpr,
    getotal = formatGETotal,
    getotalqty = formatGETotalqty,
    gep = formatGEP,
	gepmin = makeFormatGEPMinMax("min"),
	gepmax = makeFormatGEPMinMax("max"),
    min = function(t) return formatFunction( t, 'min' ) end,
    max = function(t) return formatFunction( t, 'max' ) end,
	sum = function(template)
		local params = parseTemplateParams(template)
		return implFormatSum(params)
	end,
    average = formatAverage,
    ovlcost = function() return formatFunction( '', 'overload_cost' ) end,
    nrcvp = function(t)
		return formatFunction(t, "ritual component cost")
	end,
	["ritual candle cost"] = function(t)
		return formatFunction(t, "ritual candle cost")
	end,
    potioncost = formatGEP,
    ['smuggler price'] = formatSimple,
    calcvalue = formatSimple,
    matcost = formatMatcost,
	-- {{CVTotal}} uses the same argument format as {{GETotal}}
	cvtotal = formatGETotal,
	-- {{CVP}} uses the same argument format as {{GEP}}
	cvp = formatGEP,
	-- {{CVP}} uses the same argument format as {{GEP}}, but taking a material
	mcp = formatMatCostPrice,
}

local function checkIfBracketsNeeded( parent, child, mark )
    local mult = (string.find( parent, mark..' &times;' ) or string.find( parent, '&times; '..mark ))
            and string.find( child, ' [%+%-] ')

    local div = (string.find( parent, mark..' %/' ) and string.find( child, ' [%+%-] '))
    		or (string.find( parent, '%/ '..mark ) and (string.find( child, ' [%+%-%/] ') or string.find( child, '&times;' )))

    local minus = string.find( parent, '- '..mark ) and string.find( child, ' [%+%-] ' )

    return mult or div or minus
end

function p.main( template )
    local templateList, n = templateUtil.recursiveTemplateMatch(template)

    for k, v in pairs( templateList ) do
        local templateName = string.lower(trim(string.match( v, '^([^:|]+)' ) or ''))

		templateName = string.gsub(templateName, "/clone %d+$", "")
        if formatters[templateName] ~= nil then
            v = string.gsub( v, '^.-[:|]', '' )
            templateList[k] = formatters[templateName](v)
        else
        	templateList[k] = START_TEMPLATE_NW .. v .. END_TEMPLATE_NW
        end
    end

    local res = templateList[ marker( n - 1 ) ]
    for i = n - 2, 1, -1 do
        if checkIfBracketsNeeded( res, templateList[ marker(i) ], marker(i) ) then
            res = string.gsub( res, marker(i), '(' .. templateList[ marker(i) ] .. ')' )
        else
            res = string.gsub( res, marker(i), templateList[ marker(i) ] )
        end
    end

    return res
end

return p