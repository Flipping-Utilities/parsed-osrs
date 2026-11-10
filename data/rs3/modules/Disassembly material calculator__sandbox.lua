-- <nowiki>
-- code for [[Template:Disassembly material calculator/t]]
-- 	and [[Template:Disassembly material calculator/t2]]
-- -> [[Calculator:Disassembly by material]]
-- test changes using [[Module:Disassembly material calculator/sandbox]]
local p = {}

local geprices = mw.loadJsonData('Module:GEPrices/data.json')
local buylimits = mw.loadJsonData('Module:GELimits/data.json')
local yesno = require('Module:Yesno')
local hc = require('Module:Paramtest').has_content
local cats = mw.loadData('Module:Disassemble/data')
local materials = mw.loadData('Module:Disassemble/mats')
local matinfo = mw.loadData('Module:Disassemble/matinfo')
local coin = require('Module:Coins')._amount
local info = mw.loadData('Module:Disassembly category calculator/data') -- versioning info here
local chances = mw.loadData('Module:Disassembly material calculator/data') -- chance info here
local commas = require('Module:Addcommas')._add
local Title = mw.title.getCurrentTitle()
local spn = Title.subpageText
local ignorebuylimitfilter = false

local limitFilteredMaterials = {
	['Simple parts'] = true,
	['Organic parts'] = true,
	['Enhancing components'] = true,
	['Variable components'] = true
}

local pagination = {
	offset = 0,
	page = 1
}
local MAX_PER_PAGE = 900

-- get the material name from a passed in string m
-- returns material name,true if successful
-- returns m (or the empty string), false if material not found
local function get_mat(m)
	local str = mw.text.trim(string.gsub(string.gsub(string.lower(m), ' parts?', ''), ' components?', ''))
 
	if materials[str] then
		return materials[str], true
	else
		return (m or ''), false
	end
end
local pagemat

function filterStrs(s)
	if s == nil then
		return nil
	end
	s = mw.text.trim(s)
	if s == '' then
		return nil
	end
	return s
end

function getMoreData(ret, cat, offset, lfilter)
	local r = mw.getCurrentFrame():preprocess(string.format([=[
{{#dpl:
|namespace =
|category = Items that disassemble into %s
|category = Grand Exchange items¦Disassembly calculator override
|notcategory = Pages using information from game APIs or cache
%s
|uses = Module:Disassemble
|include = {Disassembly}::category:level:calcvalue:calccomp:special:alwaysgivesaspecialmaterial:allspecmats:augmented
|allowcachedresults=true
|ordermethod=title
|format = ,\n@@%%PAGE%%,,
|noresultsheader=<nowiki />
|offset=%s
|count=%s
}}
]=], pagemat, lfilter, offset, math.min(500, MAX_PER_PAGE-500)))
	for v in mw.text.gsplit(r, '@@') do
		if v ~= '' then
			local d = mw.text.split(v, '|')
			d[1] = filterStrs(d[1])
			local itemData = {
				['%TITLE%'] = d[1],
				['%PAGE%'] = d[1],
				category = filterStrs(d[2]),
				level = filterStrs(d[3]),
				calcvalue = filterStrs(d[4]),
				calccomp = filterStrs(d[5]),
				special = filterStrs(d[6]),
				specialchance = filterStrs(d[7]),
				allspecmats = filterStrs(d[8]),
				augmented = filterStrs(d[9])
			}
			if itemData.category ~= nil and itemData.level ~= nil then
				table.insert(ret, itemData)
			end
		end
	end
end

function p._getData(cat,special)
	pagemat = get_mat(cat)
	local lfilter = ''
	if limitFilteredMaterials[pagemat] and not ignorebuylimitfilter then
		lfilter = '|notcategory=Low buy limit'
	end
	local str = string.format([=[
{{#dpl:
|namespace =
|category = Items that disassemble into %s
|category = Grand Exchange items¦Disassembly calculator override
|notcategory = Pages using information from game APIs or cache
%s
|uses = Module:Disassemble
|include = {Disassembly}::category:level:calcvalue:calccomp:special:alwaysgivesaspecialmaterial:allspecmats:augmented
|allowcachedresults=true
|ordermethod=title
|format = ,\n@@%%PAGE%%,,
|resultsheader = &&%%TOTALPAGES%%&&
|noresultsheader=&nbsp;
|offset=%s
|count=%s
}}
]=], pagemat, lfilter, pagination.offset, math.min(MAX_PER_PAGE, 500))
	local r = mw.getCurrentFrame():preprocess(str)
	local count = r:match('&&(%d+)&&')
	r = r:gsub('&&%d+&&\n', '')
	count = tonumber(count) or 500
	local ret = {}
	for v in mw.text.gsplit(r, '@@') do
		if v ~= '' then
			local d = mw.text.split(v, '|')
			d[1] = filterStrs(d[1])
			local itemData = {
				['%TITLE%'] = d[1],
				['%PAGE%'] = d[1],
				category = filterStrs(d[2]),
				level = filterStrs(d[3]),
				calcvalue = filterStrs(d[4]),
				calccomp = filterStrs(d[5]),
				special = filterStrs(d[6]),
				specialchance = filterStrs(d[7]),
				allspecmats = filterStrs(d[8]),
				augmented = filterStrs(d[9])
			}
			if itemData.category ~= nil and itemData.level ~= nil then
				table.insert(ret, itemData)
			end
		end
	end
	if count > 500 and MAX_PER_PAGE > 500 then
		getMoreData(ret, cat, pagination.offset+500, lfilter)
	end
	return count, ret
end

function getPagination(count)
	if pagination.offset == 0 and count < MAX_PER_PAGE then 
		return string.format('<br />Showing items 1 to %s', count)
	end
	local page_min = pagination.offset+1
	local page_max = math.min(count, pagination.offset + MAX_PER_PAGE)
	
	local ret = { string.format('[[Category:Large disassembly calculators]]<br />Showing items %s to %s', page_min, page_max) }
	local page_url = string.gsub(Title.fullText, '/%d+', '')
	local _ret = { string.format('[[%s|Page 1]]', page_url) }
	for i = 2,math.ceil(count/MAX_PER_PAGE) do
		table.insert(_ret, string.format('[[%s/%s|%s]]', page_url, i, i))
	end
	table.insert(ret, table.concat(_ret, ' - '))
	
	return table.concat(ret, ' &bull; ')
end

-- from a given category in the disassemble template, and a material, return the chance of that material
-- returns chance (as a decimal between 0 and 1) if successful
-- returns -1 if not
local function get_chance(c, m)
	local function check(ca, va, ma)
		if ca[va] then
			if ca[va]:find(ma, 0, true) ~= nil then
				return true, 0
			end
		end
		return false, 0
	end

	-- strip off the excess stuff
	local m = mw.text.trim(string.gsub(string.gsub(string.lower(m), ' parts?', ''), ' components?', ''))
	
	local cat
	if type(c) == 'table' then
		cat = c
	else
		cat = cats[c]
	end
	
	local chs, ch
	if cat then
		if check(cat, 'often', m) or check(cat, 'sometimes', m) or check(cat, 'rarely', m) then
			chs = chances[cat.cat]
			if chs then
				ch = chs[m]
				if ch then
					return ch, chs._total, chs._master_modifier
				end
			end
		else
			return -2, 0, 0
		end
	end
	return -1, 0, 0
end

local function gep(item)
	item = info.gemwnames[item] or info.names[item] or item
	local price = geprices[item]
	if price then
		return price, buylimits[item] or -1
	end
	return 0, -1
end

local function img(item)
	return info.imgnames[item] or info.names[item] or item
end

local function junk(lv)
	local junkpast75 = {
		[75] = 4.2, [76] = 3.8, [77] = 3.4, [78] = 3.0, [79] = 2.7,
		[80] = 2.3, [81] = 2.0, [82] = 1.7, [83] = 1.4, [84] = 1.2,
		[85] = 1.0, [86] = 0.8, [87] = 0.6, [88] = 0.4, [89] = 0.3 }
	
	lv = tonumber(lv) or 1
	if lv >= 90 then
		return 0
	elseif lv >= 75 then
		return junkpast75[lv]
	else
		return 100 - 1.1 * lv
	end
end

local function plink(page, name, img)
	return string.format('[[File:%s.png|link=%s]] [[%s|%s]]', img, page, page, name)
end

local function coins(td, am)
	if tonumber(am) == nil or tonumber(am) == 0 then
		td	:wikitext("''N/A''")
			:addClass('table-na')
			:attr('data-sort-value', '10000000000')
	else
		td	:wikitext(coin(am, false))
			:attr('data-sort-value', am)
			
	end
end


local function round(n)
	-- significant figure funciton
	-- only applies to numbers < 1
	local function sigfig(n, f)
		f = math.floor(f)
		if n > 1 or f < 1 then
			return n
		end
		local prec = 0
		for i = 3, 10, 1 do
			if n * 10^i >= 1 then
				prec = i + f - 2
				break
			end
		end
		
		if prec == 0 then 
			return 0
		end
		
		return string.format('%.' .. prec .. 'f', n)
	end
	if n >= 10 then
		return string.format('%.1f', n)
	elseif n >= 0.1 then
		return string.format('%.2f', n)
	else
		return sigfig(n, 2)
	end
end



-- row creation for special materials
-- item | number per item | always? | junk | price each | buy limit | mat cost
local function make_row_special(data)
	local tr = mw.html.create('tr')
	local str
	
	data.cqty = data.sqty
	
	if data.iqty > 1 then
		str = string.format('%s %s %s', data.iqty, '×', plink(data.page, data.name, data.img))
	else
		str = plink(data.page, data.name, data.img)
	end
	if data.isaugmented then
		str = str .. '<br/><span style="font-size:smaller;">(item level 9+)</span>'
	end
	
	local spcstring = 'Always'
	local spcstringsort = 100
	local chance = 1
	local val_override = false
	if data.chance and data.chance ~= -1 then
		chance = data.chance / 100
		spcstringsort = data.chance
		spcstring = data._string
	elseif not data.spchance then
		spcstring = "''Unknown chance''"
		spcstringsort = -1
		val_override = true
	end
	local val = data.price * data.iqty / (data.cqty * chance)
	if val < 100 then
		val = string.format("%.2f", val)
	else
		val = string.format("%.0f", val)
	end
	tr	:tag('td')
			:css('text-align','left')
			:wikitext(str)
			:attr('data-sort-value', data.name)
		:done()
		:tag('td')
			:wikitext(data.cqty)
			:attr('data-sort-value', data.cqty)
		:done()
		:tag('td')
			:wikitext(spcstring)
			:attr('data-sort-value', tostring(spcstringsort))
		:done()
		:tag('td')
			:wikitext(string.format('%.1f%%', data.junk))
			:attr('data-sort-value', data.junk)
		:done()
		
	coins(tr:tag('td'), data.price)
	if tonumber(data.limit) and data.limit > 0 then
		tr	:tag('td')
				:attr('data-sort-value', data.limit)
				:wikitext(commas(data.limit))
			:done()
	elseif tonumber(data.limit) and data.limit < 0 then
		tr	:tag('td')
				:attr('data-sort-value', 0)
				:wikitext("''N/A''")
				:addClass('table-na')
			:done()
	else
		tr	:tag('td')
				:attr('data-sort-value', 0)
				:wikitext("''Unknown''")
			:done()
	end
	if val_override then
		tr:tag('td'):attr('data-sort-value', 0):wikitext("''Unknown''")
	else
		if spcstringsort == -1 then
			tr:tag('td')
				:attr('data-sort-value', 2147000000)
				:addClass('discalc-expectedvalue-unknownprice')
				:css('text-align', 'center')
				:wikitext("''?''")
		else
			coins(tr:tag('td'), val)
		end
	end
	return tr
end

-- special mat in a non-special table eg crystal, clockwork, faceted
-- item | cqty | junk | price per dis | buy limit | chance of mat per nonjunk | overall chance per item | cost per mat | mats per hour
local function make_row_mixedspecial(data)
	local tr = mw.html.create('tr')
	local chance = {}
	local val = {}
	
	local str
	if data.iqty > 1 then
		str = string.format('%s %s %s', data.iqty, '×', plink(data.page, data.name, data.img))
	else
		str = plink(data.page, data.name, data.img)
	end
	if data.isaugmented then
		str = str .. '<br/><span style="font-size:smaller;">(item level 9+)</span>'
	end
	
	local spcstring = '100%'
	local spcstringsort = 100
	local chance = 1
	local avspcstring = '100%'
	local avspcstringsort = 100
	local priceperdis = data.price * data.iqty
	if data.chance and data.chance ~= -1 then
		chance = data.chance / 100
		spcstringsort = data.chance
		spcstring = data._string
		avspcstringsort = data.chance * data.cqty
		if avspcstringsort == math.floor(avspcstringsort) then
			avspcstring = avspcstringsort .. '%'
		else
			avspcstring = string.format('%.2f%%', avspcstringsort)
		end
		val.base = priceperdis / (data.cqty * chance)
		val.matsperhour = 3000 * chance
		for i,v in pairs(val) do
			if v < 100 then
				val[i] = string.format("%.2f", v)
			else
				val[i] = string.format("%.0f", v)
			end
		end
	elseif not data.spchance then
		spcstring = "''Unknown chance''"
		spcstringsort = 0
		avspcstringsort = 0
		avspcstring = '-'
		val.base = 0
		val.matsperhour = '-'
	end

	tr:addClass('dis-calc-row')
		:tag('td')
			:css('text-align','left')
			:wikitext(str)
			:attr('data-sort-value', data.name)
		:done()
		:tag('td')
			:wikitext(data.cqty)
			:attr('data-sort-value', data.cqty)
		:done()
		:tag('td')
			:tag('span')
				:css('border-bottom', '1px dotted #999')
				:wikitext("''Special''")
			:done()
			:attr({
				['data-sort-value'] = 0,
				title = "This item gives the material as a 'Special' material, which is independent of junk chance.",
			})
		:done()
	coins(tr:tag('td'), priceperdis)
	if tonumber(data.limit) and data.limit > 0 then
		tr	:tag('td')
				:addClass('data-dis-limitcell')
				:attr('data-sort-value', data.limit)
				:wikitext(commas(data.limit))
			:done()
	elseif tonumber(data.limit) and data.limit < 0 then
		tr	:tag('td')
				:attr('data-sort-value', 0)
				:wikitext("''N/A''")
				:addClass('data-dis-limitcell table-na')
			:done()
	else
		tr	:tag('td')
				:addClass('data-dis-limitcell')
				:attr('data-sort-value', 0)
				:wikitext("''Unknown''")
			:done()
	end
	tr	:tag('td')
			:wikitext(spcstring)
			:attr('data-sort-value', tostring(spcstringsort))
		:done()
		:tag('td')
			:wikitext(avspcstring)
			:attr('data-sort-value', tostring(avspcstringsort))
		:done()
	coins(tr:tag('td'):addClass('data-dis-costcell'), val.base)
	
	tr	:tag('td')
			:attr('data-sort-value', val.matsperhour)
			:addClass('data-dis-mphcell')
			:wikitext(val.matsperhour == '-' and '-' or commas(val.matsperhour))
		:done()
	tr:tag('td'):addClass('data-dis-timevaluecell')
	
	return tr
end


-- non-special mat row
-- item | cqty | junk | price per dis | buy limit | chance of mat per nonjunk | overall chance per item | cost per mat | mats per hour
local function make_row(data)
	if data.isspecial then
		return make_row_special(data)
	end
	if data.ismixed then
		return make_row_mixedspecial(data)
	end
	
	local tr = mw.html.create('tr')
	local chance = {}
	local val = {}
	
	local str
	
	if data.iqty > 1 then
		str = string.format('%s %s %s', data.iqty, '×', plink(data.page, data.name, data.img))
	else
		str = plink(data.page, data.name, data.img)
	end
	if data.isaugmented then
		str = str .. '<br/><span style="font-size:smaller;">(item level 9+)</span>'
	end
	chance.before = data.chance * 100
	if data.iscomponent then
		chance.master = math.min(1, data.chance * 1.2) * 100
	else
		chance.master = math.min(1, data.chance * (data.mastermodifier or 1)) * 100
	end
	
	chance.base = (1 - data.junk/100) * data.chance * data.cqty
	
	local priceperdis = data.price * data.iqty
	
	val.base = priceperdis / chance.base
	
	chance.base = round(chance.base * 100)
	
	val.matsperhour = 3000 * chance.base/100
	
	
	--round to 0dp if >100, else 2dp
	for i,v in pairs(val) do
		if v < 100 then
			val[i] = string.format("%.2f", v)
		else
			val[i] = string.format("%.0f", v)
		end
	end
	
	tr	:attr({
		['data-dis-mats'] = data.cqty,
		['data-dis-junk'] = data.junk,
		['data-dis-price'] = priceperdis,
		['data-dis-raw'] = chance.before,
		['data-dis-rawmaster'] = chance.master,
		})
		:addClass('dis-calc-row')
		:tag('td')
			:css('text-align','left')
			:wikitext(str)
			:attr('data-sort-value', data.name)
		:done()
		:tag('td')
			:wikitext(data.cqty)
			:attr('data-sort-value', data.cqty)
		:done()
		:tag('td')
			:wikitext(string.format('%.1f%%', data.junk))
			:attr('data-sort-value', data.junk)
			:addClass('data-dis-junkcell')
		:done()
	coins(tr:tag('td'), priceperdis)
	if tonumber(data.limit) and data.limit > 0 then
		tr	:tag('td')
				:addClass('data-dis-limitcell')
				:attr('data-sort-value', data.limit)
				:wikitext(commas(data.limit))
			:done()
	elseif tonumber(data.limit) and data.limit < 0 then
		tr	:tag('td')
				:addClass('data-dis-limitcell')
				:attr('data-sort-value', 0)
				:wikitext("''N/A''")
				:addClass('table-na')
			:done()
	else
		tr	:tag('td')
				:addClass('data-dis-limitcell')
				:attr('data-sort-value', 0)
				:wikitext("''Unknown''")
			:done()
	end
	
	tr	:tag('td')
			:attr('data-sort-value', chance.before)
			:wikitext(chance.before)
			:addClass('data-dis-rawchancecell')
		:done()
		
	tr	:tag('td')
			:attr('data-sort-value', chance.base)
			:wikitext(chance.base .. '%')
			:addClass('data-dis-chancecell')
		:done()
		
	local costtd = tr:tag('td')
	costtd:addClass('data-dis-costcell')
	coins(costtd, val.base)
	
	tr	:tag('td')
			:attr('data-sort-value', val.matsperhour)
			:wikitext(commas(val.matsperhour))
			:addClass('data-dis-mphcell')
		:done()
	
	tr:tag('td'):addClass('data-dis-timevaluecell')
	
	return tr
	
end

-- special case: potions
-- cqty does not vary, it might actually idk
local function potion(data)
	local rows = {}
 
	if data.calcvalue and data.calccomp then
		data.name = string.format('%s (%s)', data.page, data.calccomp)
		data.img = img(data.name)
		data.cqty = data.calccomp
		data.price = data.calcvalue
		data.limit = -1
		return make_row(data)
	end
 
	-- setup 6-dose
	data.name = data.page .. ' (6)'
	data.img = img(data.name)
	data.cqty = 6
	data.price, data.limit = gep(data.name)
 
	if data.price > 0 then
		-- if 6-dose has a price, then this is a flask; only show 6 dose (5 and lower not GE-able)
		return make_row(data)
	else
		data.name = data.page .. ' (4)'
		data.price, data.limit = gep(data.name)
		if data.price > 0 then
		-- if 4 dose has a price, this is a 4-dose vial
			for i = 4, 1, -1 do
				data.name = string.format('%s (%s)',data.page,i)
				data.img = img(data.name)
				data.cqty = i
				data.price, data.limit = gep(data.name)
				table.insert(rows, make_row(data))
			end
		else
			-- if 4 dose does not have a price, this is a 2-dose mix
			for i = 2, 1, -1 do
				data.name = string.format('%s (%s)',data.page,i)
				data.img = img(data.name)
				data.cqty = i
				data.price, data.limit = gep(data.name)
				table.insert(rows, make_row(data))
			end
		end
		return true, rows
	end
end

function getSpecMat(spec, mat, spch, allspm)
	local ret = { q = -1, c = {-1,-1}, spc = -1 }
	
	local _special = mw.text.split(spec, '%s*,%s*')
	local numsp = 1
	local chsp = nil
	local specmatcount = table.maxn(_special)
	for i,v in ipairs(_special) do
		v = string.lower(v)
			:gsub(' ?components?','')
			:gsub(' ?parts?','')
		local _m,_q,_c = v:match('([%w -]+)%s*%[?(%d*)%]?%s*%{?(%d*%.?%d*/?%d*%.?%d*)%}?')
		local _name, matb = get_mat(_m)
		local _chance = {-1, -1}
		local _quant = tonumber(_q) or 1
		
		if type(_c) == 'string' and _c ~= '' then
			if _c:find('/') then
				_c = mw.text.split(_c,'/')
				_chance = { tonumber(_c[1]), tonumber(_c[2]) }
			else
				_c = tonumber(_c)
				if math.floor(100/_c) == 100/_c then
					_chance = { 1, 100/_c }
				else
					_chance = { _c, 100 }
				end
			end
		end
		
		
		_name = mw.text.trim(_name)
		if v:find('%S') then
			if matb and _name == mat then
				numsp = _quant
				chsp = _chance
				break
			end
		end
	end
	
	if not yesno(spch or '') then
		ret.spc = false
	else
		if specmatcount == 1 then
			ret.spc = true
		elseif allspm then
			ret.spc = true
		else
			ret.spc = false
		end
	end
	ret.q = numsp
	ret.c = chsp
	
	return ret
end


-- main parsing function and module entry point
p._main = function (args)
	local cat = cats[string.lower(args.category)]
	
	if not cat then
		if args.category == 'no' then
			cat = {}
		else
			return ''
		end
	end
	
	local data = {}
	local rows = {}
	local pot = args.potion or cat.potion or false
	pot = string.lower(tostring(pot))
	data.simplematname = mw.text.trim(string.gsub(string.gsub(string.lower(pagemat), ' ?parts?', ''), ' ?components?', ''))
	data.iscomponent = matinfo[data.simplematname] == 'rare' or matinfo[data.simplematname] == 'uncommon' or matinfo[data.simplematname] == 'ancient'
	data.isspecial = args.isspecial
	data.isaugmented = yesno(args.augmented)
	
	if data.isspecial then
		-- if is special, get the number of special mat per item out of the template
		local _special = getSpecMat(args.special or '', pagemat, args.specialchance, args.allspecmats)
		data.spchance = _special.spc
		if data.spchance then
			data.chance = 100
			data._string = '100%'
		else
			data._numer = _special.c[1]
			data._denom = _special.c[2]
			if data._numer == -1 or data._demon == -1 then
				data._string = "''Unknown''"
				data.chance = -1
			else
				data._string = data._numer..'/'..data._denom
				data.chance = data._numer/data._denom*100
			end
		end
		data.cqty = _special.q
		data.sqty = _special.q
	else
		data._numer, data._denom, data.mastermodifier = get_chance(cat, pagemat)
		if data._numer == -1 then
			-- mat present in cat, but no chances available
			-- don't display anything
			return ''
		end
		if data._numer == -2 then
			if args.nomixed then
				-- override for no mixing
				return ''
			end
				
			-- mat not present in cat, so must be special mat
			if args.special == nil or not string.find(args.special, '%S') then
				return ''
			end
			local _special = getSpecMat(args.special or '', pagemat, args.specialchance, args.allspecmats)
			data.spchance = _special.spc
			if data.spchance then
				data.chance = 100
				data._string = '100%'
			else 
				if _special.c then
					data._numer = _special.c[1]
					data._denom = _special.c[2]
					if data._numer == -1 or data._demon == -1 then
						data._string = "''Unknown''"
						data.chance = -1
					else
						data._string = data._numer..'/'..data._denom
						data.chance = data._numer/data._denom*100
					end
				end
			end
			data.cqty = _special.q
			data.sqty = _special.q
			data.ismixed = true
		else
			data.chance = data._numer/data._denom
			data.cqty = tonumber(cat.compqty) or 1
		end
	end
	
	data.iqty = tonumber(cat.itemqty) or 1
	data.page = args['%PAGE%']
	
	if data.isaugmented then
		data.junk = 0
		data.cqty = data.cqty * 4
		if data.sqty then
			data.sqty = data.sqty * 4
		end
	else
		data.junk = junk(args.level)
	end
	
	-- defaults
	data.name = data.page
	data.img = img(data.page)
	data.calcvalue = tonumber(args.calcvalue) or nil
	data.calccomp = tonumber(args.calccomp) or nil
	
	if yesno(pot) then
		return potion(data)
	end
	
	if info.versions[args['%PAGE%']] then
		for i,v in ipairs(info.versions[args['%PAGE%']]) do
			data.name = v
			if data.calcvalue then
				data.price, data.limit = data.calcvalue, -1
			else
				data.price, data.limit = gep(v)
			end
			data.img = img(v)
			table.insert(rows, make_row(data))
		end
		return true, rows
	else
		if data.calcvalue then
			data.price, data.limit = data.calcvalue, -1
		else
			data.price, data.limit = gep(data.page)
		end
		return make_row(data)
	end
end

function p._newmain(args)
	local _mat = args.mat or mw.text.split(Title.text, '/')[2] -- allow pagination
	pagination.page = tonumber(mw.text.split(Title.text, '/')[3]) or 1
	pagination.offset = (pagination.page-1) * MAX_PER_PAGE
	local mat = _mat
	if hc(args[1]) then
		mat = mat .. ' parts'
	else
		mat = mat .. ' components'
	end
	
	local t = mw.html.create('table')
	t	:addClass('wikitable sticky-header sortable align-left-1')
		:css('text-align', 'right')
		:attr('id', 'dis-calc-table')
		:tag('tr')
			:tag('th')
				:wikitext('Item')
			:done()
			:tag('th')
				:wikitext('Materials<br />each')
			:done()
			:tag('th')
				:wikitext('Junk')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('Price per<br />disassemble')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('[[Grand Exchange#Trade restrictions|Buy<br />limit]]')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('Raw<br />chance')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('Avg. number')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('Cost per mat')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('Mats per hour')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('Efficiency ratio')
				:addClass('data-dis-timevaluecell')
				:attr('data-sort-type', 'number')
			:done()
			
	local count, r = p._getData(mat)
	for i,v in ipairs(r) do
		v.isspecial = args.isspecial
		v.nomixed = args.nomixed
		local d1, d2 = p._main(v)
		if d1 == true then
			for j,k in ipairs(d2) do
				t:node(k)
			end
		else
			t:node(d1)
		end
	end
	
	local msg = ''
	if limitFilteredMaterials[pagemat] and not ignorebuylimitfilter then
		msg = string.format([=[
{| class="messagebox"
| [[File:Information icon.svg|40px|link=]]
| This is a pre-filtered list, considering only items with a buy limit of 1000 or more. See the full list [[Calculator:Disassembly by material full/%s|here]].
|}%s]=], _mat, '\n')
	end
	
	local pagination = getPagination(count)
	
	return string.format("%s'''Total items: %s'''%s\n%s", msg, count, pagination, tostring(t))
end


function p._newspecial(args)
	local mat = _mat
	local mat = args.mat or mw.text.split(Title.text, '/')[2] -- allow pagination
	pagination.page = tonumber(mw.text.split(Title.text, '/')[3]) or 1
	pagination.offset = (pagination.page-1) * MAX_PER_PAGE
	local mat2
	if hc(args[1]) then
		mat2 = mat .. ' parts'
	else
		mat2 = mat .. ' components'
	end
	
	local t = mw.html.create('table')
	t	:addClass('wikitable sticky-header sortable align-left-1')
		:css('text-align', 'right')
		:attr('id', 'dis-calc-table')
		:tag('tr')
			:tag('th')
				:wikitext('Item')
			:done()
			:tag('th')
				:wikitext('Number of<br />'..mat)
			:done()
			:tag('th')
				:wikitext('Chance')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('Junk')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('Price each')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('[[Grand Exchange#Trade restrictions|Buy<br />limit]]')
				:attr('data-sort-type', 'number')
			:done()
			:tag('th')
				:wikitext('Effective cost')
				:attr('data-sort-type', 'number')
			:done()
			
	local count, r = p._getData(mat2, true)
	for i,v in ipairs(r) do
		v.isspecial = args.isspecial
		v.nomixed = args.nomixed
		local d1, d2 = p._main(v)
		if d1 == true then
			for j,k in ipairs(d2) do
				t:node(k)
			end
		else
			t:node(d1)
		end
	end
	
	local msg = ''
	if limitFilteredMaterials[pagemat] and not ignorebuylimitfilter then
		msg = string.format([=[
{| class="messagebox"
| [[File:Information icon.svg|40px|link=]]
| This is a pre-filtered list, considering only items with a buy limit of 1000 or more. See the full list [[Calculator:Disassembly by material full/%s|here]].
|}%s]=], _mat, '\n')
	end
	
	local pagination = getPagination(count)
	
	return string.format("%s'''Total items: %s'''%s\n%s", msg, count, pagination, tostring(t))
end

-- special component entry point
p.special = function(frame)
	local args = frame:getParent().args
	args.isspecial = true
	args.nomixed = false
	ignorebuylimitfilter = yesno(args.ignorelimit)
	return p._newspecial(args)
end

-- normal component entry point
p.main = function(frame)
	local args = frame:getParent().args
	args.isspecial = false
	args.nomixed = false
	ignorebuylimitfilter = yesno(args.ignorelimit)
	if tonumber(args.maxperpage) then
		MAX_PER_PAGE = tonumber(args.maxperpage)
	end
	return p._newmain(args)
end

return p