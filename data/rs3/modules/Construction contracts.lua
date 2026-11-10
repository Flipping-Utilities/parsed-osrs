local data = mw.loadData('Module:Construction contracts/data')
local gemw = mw.loadJsonData('Module:GEPrices/data.json')
local curr = require('Module:Currency short')
local lang = mw.getContentLanguage()

local allowed_items = {
	nails = {
		Bronze = 'Bronze nails',
		Iron = 'Iron nails',
		Steel = 'Steel nails',
		Black = 'Black nails',
		Mithril = 'Mithril nails',
		Adamant = 'Adamant nails',
		Rune = 'Rune nails'
	},
	planks = {
		Wooden = 'Plank',
		Oak = 'Oak plank',
		Teak = 'Teak plank',
		Mahogany = 'Mahogany plank',
		Eternal = 'Eternal plank'
	},
	stove_map = {
		['Plank'] = 'Iron bar',
		['Oak plank'] = 'Steel bar',
		['Teak plank'] = 'Mithril bar',
		['Mahogany plank'] = 'Adamant bar',
		['Eternal plank'] = 'Adamant bar'
	}
}

local xp_each = {
	['Plank'] = 30,
	['Oak plank'] = 60,
	['Teak plank'] = 90,
	['Mahogany plank'] = 140,
	['Eternal plank'] = 520,
	['White candle'] = 5,
	['Bronze nails'] = 0,
	['Iron nails'] = 0,
	['Steel nails'] = 0,
	['Black nails'] = 0,
	['Mithril nails'] = 0,
	['Adamant nails'] = 0,
	['Rune nails'] = 0,
	['Iron bar'] = 10,
	['Steel bar'] = 20,
	['Mithril bar'] = 10,
	['Adamant bar'] = 10,
	['Bolt of cloth'] = 15,
}

local xp_bonus_plank_reward = {
	['Plank'] = 0,
	['Oak plank'] = 200,
	['Teak plank'] = 500,
	['Mahogany plank'] = 1000,
	['Eternal plank'] = 5000,
}
function plink(x)
	return string.format('[[File:%s.png|link=%s]] [[%s]]', x,x,x)
end
function gep(x)
	return gemw[x] or 0
end
function coins(x)
	return curr._amount(x, 'coins', true)
end
function fnum(x)
	return lang:formatNum(x)
end


local p = {}

function p.listFurniture()
	local l = {}
	for k,v in pairs(data) do
		table.insert(l,k)
	end
	table.sort(l)
	return 'None,'..table.concat(l, ',')
end

function p.main(frame)
	return p._main(frame:getParent().args)
end

function p._main(args)
	local plank = allowed_items.planks[args.plank] or 'Plank'
	local nails = allowed_items.nails[args.nails] or 'Steel nails'
	local furniture = {}
	local xp_reward, xp_bonus_reward = 15000, xp_bonus_plank_reward[plank] or 0
	
	local totals = {
		nails = 0,
		planks = 0,
		_extra = {}
	}
	for i=1,5 do
		local f = args['furniture'..i]
		local d = data[f]
		if d then
			table.insert(furniture, f)
			totals.planks = totals.planks + d.planks
			totals.nails = totals.nails + d.nails
			if d.additional then
				for j,v in ipairs(d.additional) do
					local vmat = v.mat
					if d.is_stove then
						-- stove is special
						vmat = allowed_items.stove_map[plank] or 'Iron bar'
					end
					if totals[vmat] then
						totals[vmat] = totals[vmat] + v.qty
					else
						totals[vmat] = v.qty
						table.insert(totals._extra, vmat)
					end
				end
			end
		end
	end
	table.sort(totals._extra)
	local totalprice = 0
	local totalxp = 10
	local outstr = 'To make '..table.concat(furniture, ', ')..', you will need:\n'
	local t = mw.html.create('table')
	t:addClass('wikitable sortable align-right-2 align-right-3')
		:tag('tr')
			:tag('th'):wikitext('Material'):done()
			:tag('th'):wikitext('Quantity'):done()
			:tag('th'):wikitext('GE Price'):done()
		:done()
	local plankrow = t:tag('tr')
	plankrow:tag('td'):wikitext(plink(plank)):done()
			:tag('td'):wikitext(totals.planks):done()
	local plankpricecell = plankrow:tag('td')
	if gep(plank) == 0 then
		plankpricecell:attr('data-sort-value', 0):addClass('table-na'):wikitext('N/A')
	else
		plankpricecell:wikitext(coins(gep(plank)*totals.planks))
		totalprice = totalprice + gep(plank)*totals.planks
	end
	totalxp = totalxp + (xp_each[plank] or 0)*totals.planks
	
	local nailsrow = t:tag('tr')
	nailsrow:tag('td'):wikitext(plink(nails)):done()
			:tag('td'):wikitext(totals.nails):done()
	local nailspricecell = nailsrow:tag('td')
	if gep(nails) == 0 then
		nailspricecell:attr('data-sort-value', 0):addClass('table-na'):wikitext('N/A')
	else
		nailspricecell:wikitext(coins(gep(nails)*totals.nails))
		totalprice = totalprice + gep(nails)*totals.nails
	end
	totalxp = totalxp + (xp_each[nails] or 0)*totals.nails
	
	for i,v in ipairs(totals._extra) do
		local extraqty = totals[v]
		local extrarow = t:tag('tr')
		extrarow:tag('td'):wikitext(plink(v)):done()
				:tag('td'):wikitext(extraqty):done()
		local extrapricecell = extrarow:tag('td')
		if gep(v) == 0 then
			extrapricecell:attr('data-sort-value', 0):addClass('table-na'):wikitext('N/A')
		else
			extrapricecell:wikitext(coins(gep(v)*extraqty))
			totalprice = totalprice + gep(v)*extraqty
		end
		totalxp = totalxp + (xp_each[v] or 0)*extraqty
	end
	
	t:tag('tr')
		:tag('th'):attr('colspan', 2):wikitext('Total price'):done()
		:tag('th'):wikitext(coins(totalprice)):done()
		
	
	return string.format("%s\n%s\n* XP from materials: %s\n* XP bonus for planks used: %s\n* XP reward: %s\n* '''Total XP: %s'''", outstr, tostring(t), fnum(totalxp), fnum(xp_bonus_reward), fnum(xp_reward), fnum(totalxp+xp_bonus_reward+xp_reward))
end

return p