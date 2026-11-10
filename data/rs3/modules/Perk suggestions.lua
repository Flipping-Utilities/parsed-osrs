local p = {}

local matnames = mw.loadData('Module:Disassemble/mats')
local perknames = mw.loadData('Module:Perks/data')
local perkmats = mw.loadData('Module:Perks/materials')
local yn = require('Module:Yesno')
local pt = require('Module:Paramtest')
local hc = pt.has_content
local dt = pt.default_to
local matprice = require('Module:Component costs')._price
local plinkp = require("Module:Plink")._plinkp
local coins = require('Module:Currency')._coins
local VariablesLua = mw.ext.VariablesLua

local gizmosmap = {
	weapon = 'Weapon',
	armour = 'Armour',
	tool = 'Tool',
}

local gizmoinfo = {
	['Weapon'] = {
		name = 'Weapon gizmo shell',
		mats = {
			blade = 10,
			crafted = 5,
			strong = 2,
		},
	},
	['Armour'] = {
		name = 'Armour gizmo shell',
		mats = {
			deflecting = 10,
			crafted = 5,
			protective = 2,
		},
	},
	['Tool'] = {
		name = 'Tool gizmo shell',
		mats = {
			head = 10,
			crafted = 5,
			precise = 2,
		},
	},
	['ancient Weapon'] = {
		name = 'Ancient weapon gizmo shell',
		mats = {
			blade = 20,
			historic = 20,
			classic = 2,
			strong = 2,
		},
	},
	['ancient Armour'] = {
		name = 'Ancient armour gizmo shell',
		mats = {
			deflecting = 20,
			historic = 20,
			classic = 2,
			protective = 2,
		},
	},
	['ancient Tool'] = {
		name = 'Ancient tool gizmo shell',
		mats = {
			head = 20,
			historic = 20,
			classic = 2,
			precise = 2,
		},
	},
}

local potions = {
	none = { name = nil, param = 'None' },
	normal = { name = 'Invention potion', param = 'Normal' },
	super = { name = 'Super invention', param = 'Super' },
	extreme = { name = 'Extreme invention', param = 'Extreme' },
}

local function plink(mat_raw)
	if hc(mat_raw) then
		local matplain = string.lower(mat_raw)
			:gsub('components?', '')
			:gsub('parts?', '')
		local mat = matplain
		mat = mw.text.trim(mat)

		mat = matnames[mat]
		assert(mat ~= nil, 'Unknown material: ' .. mat_raw)
		local class = ''
		if mat:find('parts') then
			class = 'gizmo-interface-parts'
		end
		return string.format('[[File:%s.png|link=%s]]', mat, mat), class, matplain, mat
	end

	return '', '', '', ''
end

local function perklink(perk)
	local working = mw.text.split(perk, '%[')
	local a = working[1]
	local b = working[2] or ''
	local c
	if b == '' then
		working = mw.text.split(a, '%(')
		a = working[1]
		c = working[2] or ''
	else
		working = mw.text.split(b, '%(')
		b = working[1] or ''
		c = working[2] or ''
	end

	b = b:gsub('%]', '')
		:gsub('-', '–')
	c = c:gsub('%)', '')

	local name
	local rankstr = ''
	local comment = ''

	if a then
		a = mw.text.trim(a:lower())
		name = perknames[a].name
		rankstr = ' ' .. mw.text.trim(b)
		if c ~= '' then
			comment = string.format(' (%s)', mw.text.trim(c))
		end
	else
		return nil
	end

	local span = mw.html.create('span')
	span:css {
		background = '#09222F',
		['border-radius'] = '111px',
		width = '35px',
		height = '35px',
		['line-height'] = '34px',
		['text-align'] = 'center',
		display = 'inline-table',
	}
		:wikitext(string.format('[[File:%s.png|25x25px|link=%s]]', name, name))
	return string.format('\n* %s [[%s|%s]]%s%s', tostring(span), name, name:gsub('%(perk%)', ''), rankstr, comment), a
end

local function otherperks(mats, perks, gizmos, ancient)
	local ret = {}

	-- validation for issues
	if not gizmos.weapon and not gizmos.armour and not gizmos.tool then
		return ret
	end

	local allperks = {}
	local fperks = {}
	for m, n in pairs(mats) do
		if perkmats[m] then
			for prk, t in pairs(perkmats[m].perks or (ancient and perkmats[m].ancientperks)) do
				if t[n] == nil then
					allperks[prk] = true
				elseif t[n][1] > 0 and t[n][2] > 0 then
					allperks[prk] = true
				end
			end
		end
	end

	--filter allperks
	for prk, _ in pairs(allperks) do
		local p2 = perknames[prk]
		for i, v in pairs(gizmos) do
			if v and p2[i] then
				fperks[prk] = p2.name
				break
			end
		end
	end

	-- make string
	for p, n in pairs(fperks) do
		if not perks[p] then
			table.insert(ret, string.format('\n:* [[%s|%s]]', n, n:gsub(' %(perk%)', '')))
		end
	end

	return ret
end

local function rawCalcLink(gizmo, mats, ancient, level, potion)
	local link = tostring(mw.uri.fullUrl('Calculator:Perks', {
		type = gizmo,
		ancient = ancient,
		lvl = level,
		potion = potion,
		top = mats[2],
		left = mats[3],
		middle = mats[1],
		right = mats[4],
		bottom = mats[5],
		["top-left"] = mats[6],
		["top-right"] = mats[7],
		["bottom-left"] = mats[8],
		["bottom-right"] = mats[9],
	}))

	--make mw.uri do the parsing of query string, then turn it into a hash
	return string.gsub(link, 'Calculator:Perks%?', 'Calculator:Perks#')
end

local function effLevel(lvl, potion)
	local boost = {
		['none'] = function(l) return 0 end,
	    ['normal'] = function(l) return 3 end,
	    ['super'] = function(l) return 5 end,
	    ['extreme'] = function(l)
	    	local potdata = { 25, 30, 33, 36, 38, 40, 42, 43, 44, 45, 47, 48, 49, 49, 50, 51, 52, 10000000 };
			for i, v in ipairs(potdata) do
				if (l < v) then
					return i - 1;
				end
			end
	    end,
	}
	return lvl + boost[string.lower(potion)](lvl)
end

local function makeCalcLink(perks, gizmos, mats, ancient, level, potion)
	if #gizmos == 0 then
		return ''
	end
	perks = string.gsub(perks, '%s*%b()', '') -- Strip comments in brackets
	perks = string.gsub(perks, '%s*,%s*', ',')
	local ret = {}
	for _, v in ipairs(gizmos) do
		local gizmo = v
		local link = rawCalcLink(v, mats, ancient, level, potion)
		if ancient then
			v = 'Ancient ' .. string.lower(v)
		end

		local span = mw.html.create('span')
    	   	:wikitext(string.format('[%s %s (calculated: (calculating) at level %d)]', link, v, effLevel(level or 120, potion or 'none')))
    	   	:addClass('perkcalc-link')
    		:attr('data-gizmo', gizmo)
			:attr('data-potion', potion)
			:attr('data-ancient', tostring(ancient))
			:attr('data-level', level)
			:attr('data-mats', table.concat(mats, ','))
			:attr('data-perks', perks)
			:attr('data-avoid', '')

		table.insert(ret, string.format('[[File:%s gizmo shell.png|link=%s]] %s', v, link, tostring(span)))
	end
	local div = mw.html.create('div')
		:addClass('plainlinks')
		:attr({
			style="clear:left",
		})
    	:wikitext("'''Open in calculator:''' ", table.concat(ret, ', '))
    return tostring(div)
end

local function makeVals(mats, gizmos)
	local ret = {
		tot = 0,
		dets = {},
		gizs = {},
	}
	for i, v in pairs(mats) do
		local price = 'Unknown'
		local mult = 1
		if i:find('parts') then mult = 5 end
		if v.price ~= nil and v.price > 0 then
			price = coins(v.price)
			ret.tot = ret.tot + (v.price * v.qty * mult)
		end
		local sname = i:gsub(' components?', ''):gsub(' parts?', '')
		local qty = v.qty * mult
		table.insert(ret.dets, string.format('\n* %sx [[RuneScape:Material prices#%s|%s]] %s each', qty, i, sname, price))
	end
	for i, v in pairs(gizmos) do
		local price = 'Unknown'
		local totprice = 'Unknown'
		if v > 0 then
			price = coins(v)
			totprice = coins(v + ret.tot)
		end
		local sname = i:gsub(' shell', '')
		table.insert(ret.dets, string.format('\n* [[%s|%s]] %s each', i, sname, price))
		table.insert(ret.gizs, string.format('[[File:%s.png|link=|%s]] %s', i, i, totprice))
	end
	table.insert(ret.dets, '\n See [[RuneScape:Material prices|RS:Material prices]] for details on how prices are approximated.')
	return ret
end

function p.calcLink(frame)
	local args = frame:getParent().args

	local mats = {}
	local numofmats = 0
	for i = 1, 9, 1 do
		local mat = args['mat' .. i] or args[i]
		if mat and mat ~= '' then
			numofmats = numofmats + 1
			local vals = { plink(mat) }
			mats[i] = vals[4]
		end
	end

	local gizmo = args.gizmo or args.Gizmo
	gizmo = gizmosmap[gizmo] or gizmo

	local potion = args.potion or args.Potion
	if potion and #potion > 0 then
		potion = mw.language.getContentLanguage():ucfirst(potion:lower())
	end
	local level = tonumber(args.level or args.Level)
	local ancient = yn(args.ancient) or numofmats > 5

	local nocalc = yn(args.nocalc)
	local perks = args.perks
	if not hc(perks) then
		nocalc = true
	end
	local avoid = dt(args.avoid, '')

	local txt
	if nocalc then
		txt = dt(args.text, 'Click here')
	else
		txt = dt(args.text, 'Probability: (calculating)')
	end

	local href = rawCalcLink(
			gizmo,
			mats,
			ancient,
			level,
			potion
		)
	local span = mw.html.create('span')
	span:wikitext('[', href, ' ', txt, ']')
	span:addClass('hover-text perkcalc-link')
	span:attr({
		style="cursor:initial;",
		title="Open in perk calculator",
	})
	if not nocalc then
		span:attr({
			['data-gizmo'] = gizmo,
			['data-potion'] = potion,
			['data-ancient'] = tostring(ancient),
			['data-level'] = level,
			['data-mats'] = table.concat(mats, ','),
			['data-perks'] = perks,
			['data-avoid'] = avoid
		})
	end

	return tostring(span)
end

function p.main(frame)
	local args = frame:getParent().args

	local ret = {}
	local matnums = {}
	local mati
	local numofmats = 0
	local vals = {}
	for i = 1, 9, 1 do
		mati = 'mat' .. i
		local mat = args[mati] or args[i]
		ret[mati] = { plink(mat) }
		if mat and mat ~= '' then
			mat = matnames[string.lower(mw.text.trim(mat))]
			if vals[mat] then
				vals[mat].qty = vals[mat].qty + 1
			elseif mat then
				vals[mat] = {}
				local hasprice, matiprice = pcall(matprice, mat)
				if hasprice then
					vals[mat].price = matiprice
				else
					vals[mat].price = 0
				end
				vals[mat].qty = 1
			end
		end
		if ret[mati][1] ~= '' then
			numofmats = numofmats + 1
			matnums[ret[mati][3]] = (matnums[ret[mati][3]] or 0) + 1
		end
	end
	ret.vals = vals

    ret.perksRaw = args.perks or args.Perks or ''
	local perks = mw.text.split(ret.perksRaw, '%s*,%s*')
	local perkl = {}
	local perkplain = {}
	local pl, pplain
	for _, v in ipairs(perks) do
		pl, pplain = perklink(v)
		if pl then
			table.insert(perkl, pl)
			perkplain[pplain] = true
		end
	end

	ret.perks = table.concat(perkl, '')

	ret.calcgizmo = {}
	local gizmos = {}
	for v in mw.text.gsplit(args.gizmo or args.Gizmo or '', '%s*,%s*') do
		if v == 'weapon' then
			table.insert(ret.calcgizmo, gizmosmap.weapon)
			gizmos.weapon = true
		elseif v == 'armour' then
			table.insert(ret.calcgizmo, gizmosmap.armour)
			gizmos.armour = true
		elseif v == 'tool' then
			table.insert(ret.calcgizmo, gizmosmap.tool)
			gizmos.tool = true
		end
	end

	ret.ancient = false
	if yn(args.ancient) or numofmats > 5 then
		ret.ancient = true
	end

	if not yn(args.otherperks or 'yes') then
		ret.other = ''
	else
		ret.other = table.concat(otherperks(matnums, perkplain, gizmos, ret.ancient), '')
	end

	ret.comment = args.comment or args.Comment

	ret.gizmovals = {}
	for _, v in ipairs(ret.calcgizmo) do
		if ret.ancient then
			v = 'ancient ' .. v
		end
		if gizmoinfo[v] then
			local gizprice = 0
			for i, j in pairs(gizmoinfo[v].mats) do
				local mat = matnames[i]
				local hasprice, matiprice = pcall(matprice, mat)
				if hasprice then
					gizprice = gizprice + (matiprice * j)
				end
			end
			ret.gizmovals[gizmoinfo[v].name] = gizprice
		end
	end

	local level = tonumber(args.level or args.Level)
	if level then
		ret.level = level
	end

	local potion = args.potion or args.Potion
	if potion and #potion > 0 then
		ret.potion = potions[potion:lower()] or potions.none
	else
		ret.potion = potions.none
	end

	return p._main(ret)
end

function p._main(args)
	local ret = mw.html.create('tr')
	local comment = args.comment
	if hc(comment) then
		comment = comment .. '<br>'
	end

	local assumption
	if args.potion.name ~= nil and hc(args.level) then
		assumption = 'Chance increases with ' .. plinkp(args.potion.name) .. ' and level ' .. args.level .. '.<br>'
	elseif args.potion.name ~= nil then
		assumption = 'Chance increases with ' .. plinkp(args.potion.name) .. ' and level 120.<br>'
	elseif hc(args.level) then
		assumption = 'The following assumes level ' .. args.level .. '.<br>'
	else
		assumption = 'The following assumes level 120.<br>'
	end

	local calclink = makeCalcLink(args.perksRaw, args.calcgizmo, {
		args.mat1[4],
		args.mat2[4],
		args.mat3[4],
		args.mat4[4],
		args.mat5[4],
		args.mat6[4],
		args.mat7[4],
		args.mat8[4],
		args.mat9[4],
	}, args.ancient, args.level, args.potion.param)

	local prices = makeVals(args.vals, args.gizmovals)
	local count = VariablesLua.var('perksugcnt', 0) + 1
	VariablesLua.vardefine('perksugcnt', count)

	ret:tag('td')
			:attr({ ['data-sort-value'] = count })
			:tag('table')
				:addClass('gizmo-interface')
				:addClass(args.ancient and 'gizmo-ancient' or '')
				:tag('tr')
					:tag('td')
						:addClass(args.mat6[2])
						:wikitext(args.mat6[1])
					:done()
					:tag('td')
						:addClass(args.mat2[2])
						:wikitext(args.mat2[1])
					:done()
					:tag('td')
						:addClass(args.mat7[2])
						:wikitext(args.mat7[1])
					:done()
				:done()
				:tag('tr')
					:tag('td')
						:addClass(args.mat3[2])
						:wikitext(args.mat3[1])
					:done()
					:tag('td')
						:addClass(args.mat1[2])
						:wikitext(args.mat1[1])
					:done()
					:tag('td')
						:addClass(args.mat4[2])
						:wikitext(args.mat4[1])
					:done()
				:done()
				:tag('tr')
					:tag('td')
						:addClass(args.mat8[2])
						:wikitext(args.mat8[1])
					:done()
					:tag('td')
						:addClass(args.mat5[2])
						:wikitext(args.mat5[1])
					:done()
					:tag('td')
						:addClass(args.mat9[2])
						:wikitext(args.mat9[1])
					:done()
				:done()
			:done()
		:done()
	local commentcell = ret:tag('td')
	commentcell
			:wikitext(assumption)
			:wikitext(comment)
			:wikitext(args.perks)
		:done()
	if args.other ~= '' then
		commentcell
			:wikitext('\n')
			:tag('div')
				:addClass('mw-collapsible mw-collapsed')
				:attr({
						['data-expandtext'] = 'show',
						['data-collapsetext'] = 'hide',
					})
				:wikitext('\n* Other possible perks:\n')
				:tag('div')
					:addClass('mw-collapsible-content')
					:wikitext(args.other)
				:done()
			:done()
		:done()
	end
	commentcell:wikitext(calclink)
	ret:tag('td')
		:attr({
			['data-sort-value'] = math.floor(prices.tot * 100 + 0.5) / 100
		})
		:tag('div')
			:addClass('mw-collapsible mw-collapsed')
			:attr({
					['data-expandtext'] = 'show details',
					['data-collapsetext'] = 'hide details',
				})
			:wikitext( table.concat(prices.gizs, '<br>') )
			:wikitext('\n')
			:tag('div')
				:addClass('mw-collapsible-content')
				:wikitext( table.concat(prices.dets, '') )
			:done()
		:done()

	return ret
end

return p