local templateUtil = require("Module:TemplateUtil")
local stringUtil = require('Module:StringUtil')
local marker = templateUtil.marker

local p = {}

local trim = mw.text.trim

local START_TEMPLATE_NW	= mw.text.nowiki("{{");
local END_TEMPLATE_NW	= mw.text.nowiki("}}");

local function expr(x)
	local val_good, val = pcall(mw.ext.ParserFunctions.expr, x)
	if val_good then
		return tonumber(val) or x
	end
	return x
end

local function parseTemplateParams( template )
	if (type(template) == "table") then
		return template
	end

	return templateUtil.parseTemplateParams(template)
end

local function handleCalcvalue(str)
	if type(str) ~= 'string' then
		return str
	end
	if string.find(str, '¦') then
		local cv = string.gsub(str, '{', '{{')
		cv = string.gsub(cv, '}', '}}')
		cv = string.gsub(cv, '¦', '|')
		return cv
	end
	return str
end

local function formatGETotalqty( template )
    local params = parseTemplateParams( template )
    local res = {}
    
    local function f( nameprefix, qtyprefix )
    	local i = 1
    	while params[ nameprefix..i ] ~= nil do
            table.insert( res, {op='gep', item=params[ nameprefix..i ], qty=expr(params[ qtyprefix..i ]) or 1} )
	        i = i + 1
    	end
    end
    
    f( 'name', 'qty' )
    f( 'mat', 'matqty' )

    return {op='+', vals=res}
end

local function formatGETotal( template )
    local params = parseTemplateParams( template )

    for i, v in ipairs( params ) do
        params[i] = {op='gep', item=params[i], qty=1}
    end

    return {op='+', vals=params}
end

local function getnumberedparams(params)
	local out = {}
	for k,v in pairs(params) do
		if type(k) == 'number' then
			out[k] = v
		end
	end
	return out
end
local mathfuncs = {
	unary = { ceil=true, trunc=true, floor=true, abs=true, exp=true, ln=true, sin=true, cos=true, tan=true, acos=true, asin=true, atan=true, sqrt=true },
	binary = { ['+']=true, ['-']=true, ['^']=true, ['*']=true, ['/']=true, div=true, mod=true, fmod=true }
}
local function formatCalcExpr( template )
    local params = parseTemplateParams( template )
    if params.op then
    	if params.op == '+' then
    		-- specifically + is allowed to provide any number of args
    		return {op='+', vals= getnumberedparams(params)}
    	elseif mathfuncs.unary[params.op] then
    		return {op=params.op, vals={expr(params[1])}}
    	end
    end
    local op = params.op or params[2]
	return {op=op, vals={expr(params[1]), expr(params[3])}}
end

local function formatGEP( template )
    local params = parseTemplateParams( template )
    return {op='gep', item=params[1], qty=expr(params[2])}
end

local function formatSimple( template )
    local params = parseTemplateParams( template )
    return string.format( priceStr, params[1] )
end

local function formatFunction( template, name )
    local params = parseTemplateParams( template )
    return {op=name, vals=params}
end

local function makeFormatGEPMinMax(name)
	return function (template)
		local params = parseTemplateParams(template)

		for i, v in ipairs(params) do
			params[i] = formatGEP(params[i])
		end

		return formatFunction(params, name)
	end
end

local potiondata = nil
-- basic recreation of {{potioncost}} without modifiers
local function formatPotioncost(template)
	function potion(potname)
		local pvals = {}
		local pdata = potiondata[potname]
		if pdata.type == 'crystal' then
			-- add crystal flask price if necessary
			table.insert(pvals, {op='gep', item='Crystal flask', qty=1})
		end
		if pdata.basepot then
			-- add basepot cost (elder ovls use this)
			table.insert(pvals, potion(pdata.basepot))
		end
		-- add ingredients
		for k,v in ipairs(pdata.ingredients) do
			if type(v) == 'string' then
				-- if string => just GEP of 1 of them
				table.insert(pvals, {op='gep', item=v, qty=1})
			elseif type(v) == 'table' then
				-- if val specified, that's the fixed price per item
				-- just to save space, skip if val == 0
				if v.val then
					if v.val ~= 0 then
						table.insert(pvals, v.val * (v.qty or 1))
					end
				else
					-- r = recurse
					if v.r then
						if v.qty then
							table.insert(pvals, {op='*', vals={potion(v[1]), v.qty}})
						else
							-- skip the mult if just 1 needed
							table.insert(pvals, potion(v[1]))
						end
					else
						-- don't recurse, so probably just a tradeable with qty
						table.insert(pvals, {op='gep', item=v[1], qty=v.qty})
					end
				end
			end
		end
		return {op='+', vals=pvals}
	end
	local params = parseTemplateParams(template)
	if not potiondata then
		potiondata = mw.loadData('Module:Potion price/data')
	end
	local potionname = params[1]:lower():gsub('potion', ''):gsub('%(%d%)', ''):gsub("_", " ")
	if not potiondata[potionname] then
		return formatGEP(params[1])
	end
	return potion(potionname)
end

local function formatOvlcost(template)
	local params = parseTemplateParams(template)
	return formatPotioncost({'overload', params[1] or 4/3})
end


-- See [[Module:MinMax]].average{ ... }
local function formatAverage(template)
	local params = parseTemplateParams(template)
	local count = #params
	return {op='/', vals={{op='+', vals=params}, count}}
end
local function formatExpr(x)
	error('expr is not supported, use {{cvexpr}} instead')
end
local formatters = {
    ['#expr'] = formatExpr,
    cvexpr = formatCalcExpr,
    getotal = formatGETotal,
    getotalqty = formatGETotalqty,
    gep = formatGEP,
	gepmin = makeFormatGEPMinMax("min"),
	gepmax = makeFormatGEPMinMax("max"),
    min = function(t) return formatFunction( t, 'min' ) end,
    max = function(t) return formatFunction( t, 'max' ) end,
    average = formatAverage,
    ovlcost = function() return formatFunction( {}, 'overload_cost' ) end,
    nrcvp = function(t)
		return formatFunction(t, "ritual component cost")
	end,
	["ritual candle cost"] = function(t)
		return formatFunction(t, "ritual candle cost")
	end,
    ovlcost = formatOvlcost,
    potioncost = formatPotioncost,
    ['smuggler price'] = formatSimple,
    calcvalue = formatSimple,
    matcost = formatSimple,
	-- {{CVTotal}} uses the same argument format as {{GETotal}}
	cvtotal = formatGETotal,
	-- {{CVP}} uses the same argument format as {{GEP}}
	cvp = formatGEP,
}

local function expand(res, templateList)
	local newvals = {}
	for k,v in ipairs(res.vals or {}) do
		if type(v) == 'string' then
			if templateList[v] then
				newvals[k] = expand(templateList[v], templateList)
			elseif tonumber(v) then
				newvals[k] = tonumber(v)
			end
		end
	end
	for k,v in pairs(newvals) do
		res.vals[k] = v
	end
	return res
end

function p.main( template, noerr )
	template = handleCalcvalue(template)
    local templateList, n = templateUtil.recursiveTemplateMatch(template)
    --mw.logObject(templateList, 'before')
    for i=1,n,1 do
    	local k = marker(i)
    	local v = templateList[k]
        local templateName = string.lower(trim(string.match( v, '^([^:|]+)' ) or ''))

		templateName = string.gsub(templateName, "/clone %d+$", "")
        if formatters[templateName] ~= nil then
            v = string.gsub( v, '^.-[:|]', '' )
            templateList[k] = formatters[templateName](v)
        else
        	if i == n or noerr then
        		templateList[k] = START_TEMPLATE_NW .. v .. END_TEMPLATE_NW
        	else
        		error('unsupported template used: '..START_TEMPLATE_NW .. v .. END_TEMPLATE_NW)
        	end
        end
    end
    --mw.logObject(templateList, 'after')

    local res = templateList[ marker( n - 1 ) ]
    res = expand(res, templateList)
    return res
end
-- returns true, jsonstr OR false, errormsg
-- if nowiki is true, applies mw.text.nowiki
-- errors in p.main and mw.text.jsonEncode are caught
function p.json(template, nowiki)
	local res_ok, res_val = pcall(p.main, template)
	if not res_ok then
		return res_ok, res_val
	end
	local js_ok, js_val = pcall(mw.text.jsonEncode, res_val)
	if not js_ok then
		return js_ok, js_val
	end
	if nowiki then
		return js_ok, mw.text.nowiki(js_val)
	end
	return js_ok, js_val
end

return p