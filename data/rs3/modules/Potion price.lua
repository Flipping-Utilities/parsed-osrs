-- todo modulise

local yn = require('Module:Yesno')
local round = require('Module:Number')._round
local var = mw.ext.VariablesLua
local GEPrices = mw.loadJsonData('Module:GEPrices/data.json')
local data = mw.loadData('Module:Potion price/data')
local infoOrder = { 'scroll', 'mask', 'well', 'brooch', 'factory', 'amulet', 'noamuletcost', 'desert', 'improved', 'herb120' }
local improvedMap = {[0] = '', [1] = ' 1', [2] = ' 2'}
local info = {}
local amuletCostPerPotion = 0

local p = {}

local function expr(x)
	local expr_good, expr_val = pcall(mw.ext.ParserFunctions.expr, x)
	if expr_good then
		return expr_val
	else
		return 1
	end
end

local function gep(i)
    local pr = GEPrices[i]
    if pr then
        return pr
    end
    return 0
end

local function calcPotion(pot, num)
	local variableKey = {}
    for i,v in ipairs(infoOrder) do
        if type(info[v]) == 'number' then
        	table.insert(variableKey, tostring(info[v]))
    	elseif info[v] then
            table.insert(variableKey, '1')
        else
            table.insert(variableKey, '0')
        end
    end
    variableKey = string.format('%s_%s', pot, table.concat(variableKey,''))
    local variableKeyExists = var.varexists(variableKey)
    if variableKeyExists and variableKeyExists ~= '' then
    	return (tonumber(var.var(variableKey)) or 0) * num
    end
    local dataKey = pot:gsub("_", " ")
    local pdata = data[dataKey]
    if pdata.improvable then
    	pdata = data[dataKey..improvedMap[tonumber(info.improved) or 0]]
    end
    local total = 0
    local ingredNumber = 0
    local isBatch = pdata.herb120 and info.herb120
    
    for i,v in ipairs(pdata.ingredients) do
        local name, price, qty
        if type(v) == 'string' then
            name = v
            qty = 1
            price = gep(name)
        else
            name = v[1]
            qty = v.qty or 1
            if v.val then
                price = v.val
            elseif v.r then
                price = calcPotion(name,1)
            else
                price = gep(name)
            end
        end
        local add = qty * price
        if pdata.type == 'potion' and i == 2 and info.scroll then
        	-- standard potion - only secondary has a chance at being saved
        	add = add * 0.9
        end
        total = total + add
        ingredNumber = i
    end
    if pdata.type ~= 'potion' and info.scroll then
        -- overloads and crystal potions - saves any one of the ingredients with a reduced rate
        -- 10% for any saving, equally between all ingreds = overall (10/#ingreds)% saving
    	total = total * (1 - 0.1/ingredNumber)
    end
    local doublePotChance = 1
    if pdata.type == 'powerburst' then
    	total = total + gep('Powerburst vial')
    elseif pdata.type == 'bomb' then
    	total = total + gep('Bomb vial')
    elseif pdata.type == 'crystal' then
    	-- if it is crystal, add crystal flask price
    	total = total + gep('Crystal flask')
    elseif pdata.type == 'combination' and pdata.basepot then
    	total = total + calcPotion(pdata.basepot, 1)
    end
    if pdata.type ~= 'crystal' and pdata.type ~= 'combination' then
        -- these do not apply to crystal flasks
        if info.well then
        	local well_double_chance = 0.05
        	if info.brooch then
        		well_double_chance = 0.1
        	end
        	if isBatch then
        		-- when it procs on batches it gives +1 potion per 4 ingredients
        		-- instead of +1 potion per ingredient - effectively 1/4 the chance
        		doublePotChance = doublePotChance + well_double_chance/4
        	else	
            -- portable well duplication
    			doublePotChance = doublePotChance + well_double_chance
    		end
        end
        -- 4-instead-of-3-dose potions from factory outfit and botanist amulet
        -- we aren't considering morytania legs, as they're only used to make prayer renewals, which are tradeable
    	local doseMul = 0
    	if info.factory and not isBatch then
    		-- factory outfit
    		-- batches don't work
    		doseMul = doseMul + 0.1
    	end
    	if info.desert and pdata.desert then
    		-- desert amulet overriding botanist amulet
    		doseMul = doseMul + 0.2
    	elseif info.amulet and not isBatch then
    		-- botanist amulet
    		-- batches don't work
    		doseMul = doseMul + 0.05
    	end
    	-- X chance of making 4 dose
    	-- the 4 dose ones have a per-dose cost that is 3/4 of making a normal 3-dose
    	-- thus you have X that cost 3/4 and (1-X) that cost normal amount
    	-- = (1-X)*1 + 3/4*X
    	-- = 1 + (3/4-1)*X
    	-- = 1 - 1/4*X = 1-X/4
    	total = total * (1 - doseMul/4)
    	if not isBatch then
    		total = total + amuletCostPerPotion
    	end
    end
    if info.mask then
        -- modified botanist mask duplication
        if isBatch then
			-- when it procs on batches it gives +1 potion per 4 ingredients
    		-- instead of +1 potion per ingredient - effectively 1/4 the chance
        	doublePotChance = doublePotChance + 0.05/4
        else
    		doublePotChance = doublePotChance + 0.05
    	end
    end
    if isBatch then
    	total = total * 4/5
    end
    total = total / doublePotChance
    var.vardefine(variableKey, total)
    return total * num
end


function p.main(frame)
    return p._main(frame:getParent().args)
end

function p._main(args)
    local potion = args[1]:lower():gsub('potion', ''):gsub('%(%d%)', ''):gsub("_", " ")
    potion = mw.text.trim(potion)
    if not data[potion] then
        return 'Invalid potion name: '..args[1]
    end
    for i,v in ipairs(infoOrder) do
        info[v] = yn(args[v], false) or false
    end
    if info.amulet then
    	if not info.noamuletcost then
    		amuletCostPerPotion = gep("Botanist's amulet") / 100
    	end
    end
    info.improved = tonumber(args.improved) or 0
    local pprice = calcPotion(potion, expr(args[2]) or 1)
    if tonumber(args.round) then
    	pprice = round(pprice, args.round)
    end
    return pprice
end

function p._list()
	local l = {}
	local lang = mw.getContentLanguage()
	for k,v in pairs(data) do
		table.insert(l, k .. ' - '..lang:formatNum(calcPotion(k, 1)))
	end
	table.sort(l)
	return '* '..table.concat(l, '\n* ')
end

return p