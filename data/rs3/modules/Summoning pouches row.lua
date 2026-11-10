-- <nowiki>
local p = {}

local c = require('Module:Currency')._amount
local lang = mw.getContentLanguage()
local _plink = require("Module:Plink")
require("Module:Mw.html extension")

local map = {
    c = "Crimson",
    crim = "Crimson",
    go = "Gold",
    gr = "Green",
    b = "Blue",
    gold = "Gold",
    blue = "Blue",
    green = "Green",
    crimson = "Crimson",
}

local function plink(text)
    return _plink._plink(text)
end

local function plinkp(link)
    return _plink._plinkp(link)
end

local function charmpic(charm)
    return plinkp(charm .. " charm")
end

local function charmlink(charm)
    return string.format('[[%s charm|%s]]', charm, charm)
end

local geps = mw.loadJsonData("Module:GEPrices/data.json")
local function gep(item)
    return geps[item] or 0
end

function p.main(frame)
    local args = frame:getParent().args
    local params = {}
    params.familiar = args.familiar
    params.level = tonumber(args.level)
    params.xp = tonumber(args.xp)
    params.charm = map[args.charm:lower()]
    params.pouch = (args.pouch or args.familiar:gsub(" %(familiar%)", "")) .. " pouch"
    params.shards = tonumber(args.shards)
    params.shardcost = args.shards * 25
    params.swaplevel = tonumber(args.swaplevel)
    params.swapshards = tonumber(args.swapshards)
    params.swapshardscost = params.swapshards * 25
    params.alch = args.alch
    params.terts = { { name = lang:ucfirst(args.tert or args.tert1), qty = tonumber(args.tertqty or args.tert1qty) or 1 } }
    for i = 2, 5 do
        local name = args['tert' .. i]
        if name then
            table.insert(params.terts, { name = lang:ucfirst(name), qty = tonumber(args['tert' .. i .. 'qty']) or 1 })
        else
            break
        end
    end

    return p.row(params)
end

function p.row(params)
    -- {{Summoning pouches row|familiar=|level=|shards=|xp=|charm=|tert=|tert2=|tertqty=|tert2qty=|alch=}}
    local pouch_gep = gep(params.pouch)
    local terts_gep = 0
    for _, tert in ipairs(params.terts) do
        terts_gep = terts_gep + (gep(tert.name) or 0) * tert.qty
    end

    local per = (pouch_gep - params.shardcost + terts_gep) / params.xp
    local alchval = params.alch or (params.shards * 15 + 254)

    local rowspan = nil
    local num_rows = #params.terts
    if num_rows > 1 then
        rowspan = num_rows
    end

    local ret = mw.html.create()

    local row = ret:tr()
        :td { params.level, attr = { ['data-sort-value'] = params.pouch, rowspan = rowspan } }
        :td { plinkp(params.pouch), attr = { ['data-sort-value'] = params.pouch, rowspan = rowspan }, class = 'text-align-center' }
        :td { '[[' .. params.familiar .. ']]', attr = { rowspan = rowspan } }
        :td { params.shards, attr = { rowspan = rowspan } }
        :td { c(params.shardcost, "coins"), attr = { ['data-sort-value'] = params.shardcost, rowspan = rowspan } }
        :td { charmpic(params.charm) .. charmlink(params.charm), attr = { ['data-sort-value'] = params.charm, rowspan = rowspan } }
        :td { plinkp(params.terts[1].name), class = 'text-align-center' }
        :td { '[[' .. params.terts[1].name .. ']]' .. (params.terts[1].qty > 1 and ' × ' .. params.terts[1].qty or '') }

    if terts_gep > 0 then
        row:td { c(terts_gep, "coins"), attr = { ['data-sort-value'] = terts_gep, rowspan = rowspan } }
    else
        row:na()
    end

    row
        :td { params.xp, attr = { rowspan = rowspan } }
        :td { c(per, 'coins'), attr = { ['data-sort-value'] = per, rowspan = rowspan } }
        :td { c(alchval, 'coins'), attr = { ['data-sort-value'] = alchval, rowspan = rowspan } }
        :td { c(pouch_gep, "coins"), attr = { ['data-sort-value'] = pouch_gep, rowspan = rowspan } }

    if params.swaplevel > 0 then
        row
            :td { params.swaplevel, attr = { rowspan = rowspan } }
            :td { params.swapshards, attr = { rowspan = rowspan } }
            :td { c(params.swapshardscost, 'coins'), attr = { ['data-sort-value'] = params.swapshardscost, rowspan = rowspan } }
    else
        row:na():na():na()
    end

    if num_rows > 1 then
        for i = 2, num_rows do
            ret:tr()
                :td { plinkp(params.terts[i].name), class = 'text-align-center' }
                :td { '[[' .. params.terts[i].name .. ']]' .. (params.terts[i].qty > 1 and '×' .. params.terts[i].qty or '') }
        end
    end

    return ret
end

function p.header(frame)
    return [=[<table class="wikitable sticky-header sortable">
<tr>
	<th>Level</th>
	<th>Pouch</th>
	<th>Familiar</th>
	<th>[[Spirit shards|Shards]]</th>
	<th>Shards cost</th>
	<th>[[Charms]]</th>
	<th colspan="2" style="max-width:40ch">Tertiary ingredient</th>
    <th>Tertiary price</th>
	<th>Create XP</th>
	<th>Profit/XP</th>
	<th>[[High Level Alchemy|High Alch]]</th>
	<th>Pouch price</th>
	<th>Swap level</th>
	<th>Swap number</th>
	<th>Swap value</th>
</tr>]=]
end

return p

-- </nowiki>