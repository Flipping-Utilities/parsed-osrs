local p = {}

--imports

local gePriceData = mw.loadJsonData('Module:GEPrices/data.json')
local geVolumeData = mw.loadJsonData('Module:GEVolumes/data.json')
local minutesToTime = require('Module:Time')._m_to_c
local paramtest = require('Module:Paramtest')
local yesno = require('Module:Yesno')
local round = require('Module:Number')._round
local currency = require('Module:Currency')
local sc = require('Module:Skill clickpic')._main
local vdf = mw.ext.VariablesLua.vardefine
local lang = mw.getContentLanguage()
local on_main = require('Module:Mainonly').on_main
local cvjson = require('Module:Calcvalue formatter json')
require('Module:Mw.html extension')

-- Config constants, change as needed
local MEM_ICON = {
	[false] = "[[File:F2P icon.png|20px|center|link=Free-to-play]]",
	[true]  = "[[File:P2P icon.png|20px|center|link=Members]]"
}

local allowed_categories = {
	['combat'] = true,
	['combat/high'] = true,
	['combat/mid'] = true,
	['combat/low'] = true,
	['combat/boss'] = true,
	['gathering'] = true,
	['processing'] = true,
	['collecting'] = true
}

local cur_frame = mw.getCurrentFrame()

-- Local utility functions
local _refs = {}
local function getRef( text )
	vdf( "mmg_uses_refs", "1" )
	if not _refs[text] then
		_refs[text] = cur_frame:extensionTag{ name = "ref", content = text }
	end
	
	return _refs[text]
end

local function coins(v)
	return currency._amount(v, 'coins')
end

local function nocoins(v, is_item_line)
	--TEMP(?): [[MediaWiki:Gadget-dynamicMMG-core.js]] is broken/out-of-sync with this module since the tabular format and requires the following updates:
	--	Lines 47, 90, 91: `span.coins` --> `span.nocoins`
	-- until then, workaround is to add back the coins class (but don't set the coins-# class that would add the stack of coins image)
	----return currency._amount(v, 'nocoins')
	local ret = currency._amount(v, 'nocoins')
	if is_item_line then
		ret = ret:gsub('nocoins', 'nocoins coins', 1)
	end

	return ret
end

local function expr(x)
	local e_g, e = pcall(mw.ext.ParserFunctions.expr, x)
	if e_g then
		return tonumber(e)
	end
	return nil
end

local function sigfig(x, p)
	local x_sign = x < 0 and -1 or 1
	local x = math.abs(x)
	local n = math.floor(math.log10(x)) + 1 - p
	return x_sign * math.pow(10, n) * round(x / math.pow(10, n), 0)
end

local function autoround(x, f)
	x = tonumber(x) or 0
	local _x
	if x == 0 then
		_x = 0
	elseif math.abs(x) < 0.1 then
		_x = sigfig(x, 2)
	elseif math.abs(x) > 999 then
		_x = round(x, 0)
	else
		_x = round(x, 2)
	end
	if f then
		return lang:formatNum(_x)
	end
	return _x
end
-- export autoround for other modules to do formatting of MMG-related values
-- leave function as local since it is accessed numerous times
p.autoround = autoround

local function handleXP(args)
	local items = {}
	local textlines = {}
	local is_per_kill = yesno(args.isperkill)
	local defaultKPH = tonumber(args.kph) or 1
	local i = 0
	while true do
		i = i + 1
		if not args['Experience'..i] then break end
		local pri = 'Experience'..i
		local span = mw.html.create('div')
		span:addClass('mmg-xpline')

		local skill = args[pri]
		local qty_param = args[pri..'num']
		local actual_qty = tonumber(qty_param) or expr(qty_param) or 0
		local is_per_hour = not is_per_kill
		if is_per_kill and yesno(args[pri..'isph']) then
			is_per_hour = true
		end
		local this_item_value, attrName
		if is_per_kill and not is_per_hour then
			span:addClass('mmg-varieswithkph')
			this_item_value = actual_qty * defaultKPH
			attrName = 'data-mmg-xp-pk'
		else
			this_item_value = actual_qty
			attrName = 'data-mmg-xp-ph'
		end

		span
			:attr(attrName, actual_qty)
			:wikitext(sc(skill, autoround(this_item_value, true)))

		if paramtest.has_content(args[pri..'note']) then
			span:tag('span'):addClass('mmg-note'):wikitext(' ',args[pri..'note'])
		end

		table.insert(textlines, span)
		table.insert(items, { skill = skill, xp = actual_qty, isph = is_per_hour })
	end

	return { spans = textlines, items = items }
end

local function gePrice(item)
	item = string.gsub(item or '', '&#0?39;', "'"):gsub('_', ' '):gsub('  +', ' '):gsub('^.', string.upper)
	return gePriceData[item]
end

local function geVolume(item)
	item = string.gsub(item or '', '&#0?39;', "'"):gsub('_', ' '):gsub('  +', ' '):gsub('^.', string.upper)
	return geVolumeData[item]
end

-- Creates a neat little warning message
local function warning(msg)
	return cur_frame:expandTemplate{title='Hover', args={'*', msg, 'border-bottom: 1px red dotted; color: red; cursor: help;'}}
end

-- checks if the input string is a calcvalue and expands it as appropriate
local function check_calcvalue(str)
	if paramtest.is_empty(str) then
		return 'nil', nil
	end
	if string.find(str, '¦') then
		local cv = string.gsub(str, '{', '{{')
		cv = string.gsub(cv, '}', '}}')
		cv = string.gsub(cv, '¦', '|')
		cv = mw.getCurrentFrame():preprocess(cv)
		return 'calcvalue', {raw=str, val=tonumber(cv)}
	end
	return 'value', {raw=str, val=tonumber(str) or expr(str)}
end

-- Implements handleInputs and handleOutputs
-- See those functions for further details
local function handleIteratedArgs(args, dyndef, prefix, noHtml, deduct_tax)
	local items = {}
	local total_item_value = 0
	local textlines = {}
	local textlines_tableRow = {}
	local is_per_kill = yesno(args.isperkill)
	local has_dynam_inp = paramtest.has_content(args['UInput1text'])
	local defaultKPH = tonumber(args.kph) or 1
	local value_per_kill = 0
	local value_per_hour = 0
	local i = 0
	while true do
		i = i + 1
		local pri = prefix..i
		if paramtest.is_empty(args[pri]) then break end
		local span, tableRow

		if not noHtml then
			span = mw.html.create('div')
			span:addClass('mmg-itemline mmg-'..prefix:lower())

			tableRow = mw.html.create('tr')
			tableRow:addClass('mmg-itemline mmg-'..prefix:lower())
		end

		local name = args[pri]
		local qty_param = args[pri..'num']
		local actual_qty = nil
		local value_type, value_param = check_calcvalue(args[pri..'value'])
		local actual_value = nil
		local raw_value = nil
		local is_per_hour = not is_per_kill
		if is_per_kill and yesno(args[pri..'isph']) then
			is_per_hour = true
		end

		-- Keep track of sanity check states - we want to handle them gracefully later.
		local invalid_qty_present = false
		local invalid_value_present = false
		local failed_ge_lookup = false
		local pricetype = ''

		if paramtest.has_content(qty_param) then
			actual_qty = tonumber(qty_param) or expr(qty_param)
			invalid_qty_present = not actual_qty
			actual_qty = actual_qty or 1
			-- If the given quantity doesn't look like a number, we'll default to 1
			--   but we should probably alert the user
			--   since they might want to fix that
		else
			-- Default value of 1
			actual_qty = 1
		end
		if value_type ~= 'nil' then
			actual_value = value_param.val
			invalid_value_present = not actual_value
			pricetype = value_type
			raw_value = value_param.raw
		end

		local pretax_value = actual_value
		-- If we got the value earlier, skip this part
		if not actual_value then
			-- Here we try to find an exchange price
			-- If we get here, and we can't get an exchange price
			-- we default to 0.
			-- This is almost certainly not what the user wants,
			-- so we warn them about it.
			pretax_value = gePrice(name)
			failed_ge_lookup = not pretax_value
			pretax_value = pretax_value or 0
			pricetype = 'gemw'
			if deduct_tax and name ~= 'Bond' and pretax_value > 49 then
				actual_value = pretax_value - math.floor(pretax_value / 50)
			else
				actual_value = pretax_value
			end
		end
		local trade_volume = geVolume(name) or nil

		local this_item_value, this_item_qty, attrName
		local attrVal = actual_qty * actual_value

		if is_per_kill and not is_per_hour then
			if not noHtml then
				span:addClass('mmg-varieswithkph')
				tableRow:addClass('mmg-varieswithkph')
			end
			if args[pri..'dynam'] then
				if not noHtml then
					span:addClass('mmg-variesdynm')
					span:attr('data-dynam-inputs', args[pri..'dynam'])
					tableRow:addClass('mmg-variesdynm')
					tableRow:attr('data-dynam-inputs', args[pri..'dynam'])
				end
				local mult = 1
				for j in string.gmatch(args[pri..'dynam'], "%d+") do
					--mw.logObject(dyndef)
					if dyndef['dyn'..j][3] then
						mult = mult * dyndef['dyn'..j][2] / dyndef['dyn'..j][1]
					else
						mult = mult * dyndef['dyn'..j][1] * dyndef['dyn'..j][2]
					end
				end
				this_item_qty = actual_qty * defaultKPH * mult
				this_item_value = attrVal * defaultKPH * mult
			else
				this_item_qty = actual_qty * defaultKPH
				this_item_value = attrVal * defaultKPH
			end
			value_per_kill = value_per_kill + attrVal
			attrName = 'data-mmg-cost-pk'
		else
			if args[pri..'dynam'] then
				if not noHtml then
					span:addClass('mmg-variesdynm')
					span:attr('data-dynam-inputs', args[pri..'dynam'])
					tableRow:addClass('mmg-variesdynm')
					tableRow:attr('data-dynam-inputs', args[pri..'dynam'])
				end
				local mult = 1
				for i in string.gmatch(args[pri..'dynam'], "%d+") do
					if dyndef['dyn'..i][3] then
						mult = mult * dyndef['dyn'..i][2] / dyndef['dyn'..i][1]
					else
						mult = mult * dyndef['dyn'..i][1] * dyndef['dyn'..i][2]
					end
				end
				this_item_qty = actual_qty * mult
				this_item_value = attrVal * mult
			else
				this_item_qty = actual_qty
				this_item_value = attrVal
			end
			value_per_hour = value_per_hour + attrVal
			attrName = 'data-mmg-cost-ph'
		end
		total_item_value = total_item_value + this_item_value

		if not noHtml then
			span:tag('span'):addClass('mmg-quantity'):attr('data-mmg-qty', actual_qty):wikitext(autoround(this_item_qty, true))
			local tableRow_qty = mw.html.create('td')
			tableRow_qty:addClass('mmg-quantity'):attr('data-mmg-qty', actual_qty):wikitext(autoround(this_item_qty, true))

			if invalid_qty_present then
				span:node(warning('Could not interpret \''..qty_param..'\' as a number, defaulting to 1'))
				tableRow_qty:node(warning('Could not interpret \''..qty_param..'\' as a number, defaulting to 1'))
			end
			tableRow_qty:done()

			span:wikitext(string.format(' × [[File:%s.png|link=%s]] [[%s]] (', name, name, name))
			local tableRow_img = mw.html.create('td')
			tableRow_img:wikitext(string.format('[[File:%s.png|link=%s|x32px]]', name, name)):css('height', '32px'):done()
			local tableRow_item = mw.html.create('td')
			local note = paramtest.has_content(args[pri..'note']) and getRef(args[pri..'note']) or ''
			tableRow_item:css('text-align','left'):addClass('mmg-item'):attr('data-mmg-item', name):wikitext(string.format('[[%s]]%s', name, note)):done()

			local title = nil
			if math.abs(pretax_value) > 0.01 then
				title = ('%s each'):format(lang:formatNum(math.floor(pretax_value * 100 + 0.5) / 100))
				if pretax_value ~= actual_value then
					title = ('%s (%s after tax)'):format(title, lang:formatNum(math.floor(actual_value * 100 + 0.5) / 100))
				end
			end

			span:tag('span'):addClass('mmg-cost'):attr(attrName, attrVal):wikitext(nocoins(autoround(this_item_value)))
			span:wikitext(')' .. note)
			local tableRow_cost = mw.html.create('td')
			tableRow_cost:addClass('mmg-cost'):attr(attrName, attrVal):attr('title', title):css('text-align','right'):wikitext(nocoins(autoround(this_item_value), true))
			if invalid_value_present then
				span:node(warning('Could not interpret \''..value_param..'\' as a number, ignoring.'))
				tableRow_cost:node(warning('Could not interpret \''..value_param..'\' as a number, ignoring.'))
			end
			if failed_ge_lookup then
				span:node(warning('Could not find exchange price for item \''..name..'\', please double-check the spelling'))
				tableRow_cost:node(warning('Could not find exchange price for item \''..name..'\', please double-check the spelling'))
				if on_main() then
					span:wikitext('[[Category:Money making guides with a failed GE lookup]]')
					tableRow_cost:wikitext('[[Category:Money making guides with a failed GE lookup]]')
				end				
			end
			tableRow_cost:attr({
				['data-mmg-cost-type']=pricetype,
				['data-mmg-cost-val']=actual_value,
				['data-mmg-cost-raw']=raw_value --nil for GEP, which removes this attr
			})
			if pricetype == 'calcvalue' then
				local calcvaljs_ok,calcvaljs = cvjson.json(raw_value)
				if calcvaljs_ok then
					tableRow_cost:attr('data-mmg-cost-json', calcvaljs)
				else
					tableRow_cost:attr('data-mmg-cost-json-error', calcvaljs)
				end
			end
			tableRow_cost:done()

			local tableRow_volume
			if prefix == 'Input' and yesno(args['Input volume'] or false, false) or
				prefix == 'Output' and yesno(args['Output volume'] or true, true) then
				tableRow_volume = mw.html.create('')
					:IF(trade_volume)
						:tag('td')
							:css('text-align','right')
							:wikitext(autoround(trade_volume, true))
						:done()
					:ELSE()
						:na()
					:END()
				:done()
			end

			tableRow:node(tableRow_img):node(tableRow_item):node(tableRow_qty):node(tableRow_cost)
				:IF(tableRow_volume)
					:node(tableRow_volume)
				:END()
			:done()

			table.insert(textlines, span)
			table.insert(textlines_tableRow, tableRow)
		end
		local itemdata = {name = name, qty = actual_qty, value = actual_value, isph = is_per_hour, pricetype = pricetype}
		if pricetype == 'calcvalue' then
			itemdata.raw_value = raw_value
		end
		table.insert(items, itemdata)
	end

	return {value = total_item_value, valuepk = value_per_kill, valueph = value_per_hour, spans = textlines, spans_tableRow = textlines_tableRow, list = items}
end

-- args are the args supplied to the template, (or a subset of them contining all input arguments)
-- Returns a table. The table has three keys: 'value', 'text', and 'as_table'
---- 'value' contains the total value of the inputs specified by args
---- 'text' contains a formatted string based on the inputs specified by args. This can be directly plugged into the HTML table.
---- 'list' contains all the inputs as a Lua list. Each input is represented by a table with the following keys
------ 'name' being the name of the item
------ 'value' being the value of the item in question
------ 'qty' being the quantity specified for the item
local function handleInputs(args, dyndef, noHtml)
	return handleIteratedArgs(args, dyndef, 'Input', noHtml, false)
end

-- args are the args supplied to the template, (or a subset of them contining all output arguments)
-- Returns a table. The table has two keys: 'value', and 'text'
---- 'value' contains the total value of the outputs specified by args
---- 'text' contains a formatted string based on the outputs specified by args. This can be directly plugged into the HTML table.
---- 'list' contains all the outputs as a Lua list. Each output is represented by a table with the following keys
------ 'name' being the name of the item
------ 'value' being the value of the item in question
------ 'qty' being the quantity specified for the item
local function handleOutputs(args, dyndef, noHtml)
	return handleIteratedArgs(args, dyndef, 'Output', noHtml, true)
end

local function handleDynamics(args)
	local attr = { ['data-default-kph'] = args.kph }
	attr['data-default-kph-name'] = args['kph name'] or 'Kills per hour'

	local defs = {}

	if paramtest.has_content(args['UInput1text']) then
		local i = 1
		while paramtest.has_content(args['UInput'..i..'text']) do
			attr['data-dynam'..i..'-text'] = args['UInput'..i..'text']
			attr['data-dynam'..i..'-def'] = tonumber(args['UInput'..i..'def']) or 1
			attr['data-dynam'..i..'-fact'] = tonumber(args['UInput'..i..'fact']) or 1

			local isdiv = yesno(args['UInput'..i..'isdiv'], false)
			attr['data-dynam'..i..'-isdiv'] = tostring(isdiv)

			defs['dyn'..i] = {(tonumber(args['UInput'..i..'def']) or 1), (tonumber(args['UInput'..i..'fact']) or 1), isdiv}

			attr['data-num-dynamics'] = i

			i = i + 1
		end
	end

	return { defs = defs, attr = attr }
end

local function generateInputTable(args, tbl, parsedInput)
	tbl:css('padding', '0'):css('vertical-align', 'top')
	local inputTable = mw.html.create('table')
	inputTable:addClass('wikitable')
		:addClass('sortable')
		:css('font-size', '1em')
		:css('width', 'calc(100% + 2px)')
		:css('margin', '-1px')
		:css('text-align', 'center')
		:tag('tr')
			:tag('th')
				:wikitext('Item')
				:attr('colspan', 2)
			:done()
			:tag('th')
				:wikitext('Quantity')
			:done()
			:tag('th')
				:wikitext('GE price')
			:done()
			-- Daily volume for inputs is hidden by default
			:IF(yesno(args['Input volume'] or false, false))
				:tag('th')
					:attr('data-sort-type', 'number')
					:wikitext('[[Grand Exchange#Volume|Daily volume]]')
				:done()
			:END()
		:done()

	for _, v in ipairs(parsedInput.spans_tableRow) do
		inputTable:node(v)
	end

	tbl:node(inputTable)
end

local function generateOutputTable(args, tbl, parsedOutput)
	tbl:css('padding', '0'):css('vertical-align', 'top')
	local outputTable = mw.html.create('table')
	outputTable:addClass('wikitable')
		:addClass('sortable')
		:css('font-size', '1em')
		:css('width', 'calc(100% + 2px)')
		:css('margin', '-1px')
		:css('text-align', 'center')
		:tag('tr')
			:tag('th')
				:wikitext('Item')
				:attr('colspan', 2)
			:done()
			:tag('th')
				:wikitext('Quantity')
			:done()
			:tag('th')
				:wikitext('GE price after [[Grand Exchange#Trade tariff|tax]]')
			:done()
			-- Daily volume for outputs is shown by default
			:IF(yesno(args['Output volume'] or true, true))
				:tag('th')
					:attr('data-sort-type', 'number')
					:wikitext('[[Grand Exchange#Volume|Daily volume]]')
				:done()
			:END()
		:done()

	for _, v in ipairs(parsedOutput.spans_tableRow) do
		outputTable:node(v)
	end

	tbl:node(outputTable)
end

function p.testmmgtable(args)
	return p._mmgtable(cur_frame, args)
end

function p.mmgtable(frame)
	local args = frame:getParent().args
	return p._mmgtable(frame, args)
end

-- Create a MMG table.
-- Frame is the frame the module was invoked from.
-- Args are the template arguments used when creating the table.
function p._mmgtable(frame, args)
	local _ = args['Define variables'] -- Needs to be the first read param to make sure {{#vardefine:}} variables are set before they are needed by other params
	local isperkill = yesno(args.isperkill)
	local tblattr, dyndef = {}, {}
	if isperkill then
		local tmpdyn = handleDynamics(args)
		tblattr = tmpdyn.attr
		dyndef = tmpdyn.defs
	end

	local parsedInput = handleInputs(args, dyndef)
	local parsedOutput = handleOutputs(args, dyndef)
	local parsedXP = handleXP(args)
	local ret = mw.html.create('')

	--mw.logObject(dyndef)
	--mw.logObject(parsedInput)
	--mw.logObject(parsedOutput)

	local tbl = ret:tag('table')
			:addClass('wikitable')
			:addClass('mmgtable')
			:attr('style', 'width: 100%; text-align: center;')
			:tag('caption')
				-- Members status (default to yes)
				:wikitext(MEM_ICON[yesno(args['Members'] or 'yes', true)])
				:wikitext(args['Activity'] or '{{{Activity}}}')
			:done()
			:tag('tr')
				:tag('th')
					:attr('colspan', '2')
					:wikitext('Requirements')
				:done()
				:tag('td')
					:addClass('image-container')
					:attr('rowspan', '11')
					:wikitext(paramtest.default_to(args['Image'], '{{{Image}}}'))
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:attr('colspan', '2')
					:wikitext('Skills')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:attr('colspan', '2')
					:addClass('no-list-style')
					-- Can leave blank if no reqs.
					:newline()
					:wikitext(paramtest.default_to(args['Skill'], 'None')) 
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:attr('colspan', '2')
					:wikitext('Items')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:attr('colspan', '2')
					:addClass('no-list-style')
					-- Can leave blank if no reqs.
					:newline()
					:wikitext(paramtest.default_to(args['Item'], 'None'))
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:attr('colspan', '2')
					:wikitext('Quests')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:attr('colspan', '2')
					:addClass('no-list-style')
					-- Can leave blank if no reqs
					:newline()
					:wikitext(paramtest.default_to(args['Quest'], 'None'))
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:attr('colspan', '2')
					:wikitext('Other')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:attr('colspan', '2')
					:addClass('no-list-style')
					-- Can leave blank if no reqs
					:newline()
					:wikitext(paramtest.default_to(args['Other'], 'None'))
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:attr('colspan', '2')
					:wikitext('Intensity')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:attr('colspan', '2')
					:wikitext(paramtest.default_to(args['Intensity'], '{{{Intensity}}}'))
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:attr('colspan', '3')
					:wikitext('Results')
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:wikitext('Profit')
				:done()
				:tag('th')
					:wikitext('[[wikipedia:Return on investment|ROI]]')
				:done()
				:tag('th')
					:wikitext('Experience gained')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					if args['Profit'] then
						tbl:wikitext(coins(args['Profit']))
					elseif isperkill then
						tbl
							:addClass('mmg-varieswithkph')
							:attr('data-mmg-cost-ph', parsedOutput.valueph - parsedInput.valueph)
							:attr('data-mmg-cost-pk', parsedOutput.valuepk - parsedInput.valuepk)
							:wikitext(coins(autoround(parsedOutput.value - parsedInput.value)), ' after [[Grand Exchange#Trade tariff|tax]]')
					else
						tbl:wikitext(coins(autoround(parsedOutput.value - parsedInput.value)), ' after [[Grand Exchange#Trade tariff|tax]]')
					end
					tbl = tbl
				:done()
				:tag('td')
					if args['Profit'] then
						tbl:wikitext(tostring(args['Profit'] / args['Input'] * 100)..'%')
					elseif isperkill then
						tbl
							:addClass('mmg-varieswithkph mmg-roi')
							:attr({
								['data-mmg-roi-out-ph'] = parsedOutput.valueph,
								['data-mmg-roi-in-ph'] = parsedInput.valueph,
								['data-mmg-roi-out-pk'] = parsedOutput.valuepk,
								['data-mmg-roi-in-pk'] = parsedInput.valuepk
							})
							:wikitext(autoround((parsedOutput.value - parsedInput.value) / parsedInput.value * 100)..'%')
					else
						tbl:wikitext(autoround((parsedOutput.value - parsedInput.value) / parsedInput.value * 100)..'%')
					end
					tbl = tbl
				:done()
				:tag('td')
					if args['Other Benefits'] and not (args['Other Benefits'] == nil) and not (args['Other Benefits'] == '') then
						tbl:wikitext(args['Other Benefits'])
					elseif #parsedXP.spans > 0 then
						for _, v in ipairs(parsedXP.spans) do
							tbl:node(v)
						end
					else
						tbl:wikitext('None')
					end
					tbl = tbl
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:attr('colspan', '2')
					:wikitext('Inputs')
					if parsedInput.value ~= 0 then
						tbl:wikitext(' (')
						if isperkill then
							tbl
								:tag('span')
									:addClass('mmg-varieswithkph')
									:addClass('mmg-input-sum')
									:attr('data-mmg-cost-ph', parsedInput.valueph)
									:attr('data-mmg-cost-pk', parsedInput.valuepk)
									:wikitext(coins(autoround(parsedInput.value)))
								:done()
						else
							tbl:wikitext(coins(autoround(parsedInput.value)))
						end
						tbl:wikitext(')')
					end
					tbl = tbl
				:done()
				:tag('th')
					:wikitext('Outputs')
					if parsedOutput.value ~= 0 then
						tbl:wikitext(' (')
						if isperkill then
							tbl
								:tag('span')
									:addClass('mmg-varieswithkph')
									:addClass('mmg-output-sum')
									:attr('data-mmg-cost-ph', parsedOutput.valueph)
									:attr('data-mmg-cost-pk', parsedOutput.valuepk)
									:wikitext(coins(autoround(parsedOutput.value)), ' after [[Grand Exchange#Trade tariff|tax]]')
								:done()
						else
							tbl:wikitext(coins(autoround(parsedOutput.value)), ' after [[Grand Exchange#Trade tariff|tax]]')
						end
						tbl:wikitext(')')
					end
					tbl = tbl
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:attr('colspan', '2')
					if args['Inputs'] then
						tbl:wikitext(args['Inputs'])
					elseif #parsedInput.spans > 0 then
						generateInputTable(args, tbl, parsedInput)
					elseif parsedInput.text then
						tbl:wikitext(parsedInput.text)
					else
						tbl:wikitext('None')
					end
					tbl = tbl
				:done()
				:tag('td')
					if args['Outputs'] then
						tbl:wikitext(args['Outputs'])
					elseif #parsedOutput.spans > 0 then
						generateOutputTable(args, tbl, parsedOutput)
					elseif parsedOutput.text then
						tbl:wikitext(parsedOutput.text)
					else
						tbl:wikitext('None')
					end
					tbl = tbl
				:done()
			:done()

	if isperkill then
		tbl
			:addClass('mmg-isdynamic')
			--:attr('data-default-kph', args.kph)
			--:attr('data-default-kph-name', args['kph name'] or 'Kills per hour')
			:attr(tblattr)
	end

	if not(yesno(args.noexports)) then
		if yesno(args.isperkill) then
			vdf('kph', string.format('<span class="mmg-variable mmg-kph">%s</span>', autoround(args.kph, true)))
			vdf('default_kph', args.kph)
			vdf('inputPH', string.format('<span class="mmg-variable mmg-input-ph" data-mmg-cost-ph="%s">%s</span>', parsedInput.valueph, nocoins(autoround(parsedInput.valueph))))
			vdf('inputPK', string.format('<span class="mmg-variable mmg-input-pk" data-mmg-cost-pk="%s">%s</span>', parsedInput.valuepk, nocoins(autoround(parsedInput.valuepk))))
			vdf('input', string.format('<span class="mmg-variable mmg-input" data-mmg-cost-ph="%s" data-mmg-cost-pk="%s">%s</span>', parsedInput.valueph, parsedInput.valuepk, nocoins(autoround(parsedInput.value))))
			vdf('outputPH', string.format('<span class="mmg-variable mmg-output-ph" data-mmg-cost-ph="%s">%s</span>', parsedOutput.valueph, nocoins(autoround(parsedOutput.valueph))))
			vdf('outputPK', string.format('<span class="mmg-variable mmg-output-pk" data-mmg-cost-pk="%s">%s</span>', parsedOutput.valuepk, nocoins(autoround(parsedOutput.valuepk))))
			vdf('output', string.format('<span class="mmg-variable mmg-varieswithkph mmg-output" data-mmg-cost-ph="%s", data-mmg-cost-pk="%s">%s</span>', parsedOutput.valueph, parsedOutput.valuepk, nocoins(autoround(parsedOutput.value))))
			vdf('profitPH', string.format('<span class="mmg-variable mmg-profit-ph" data-mmg-cost-ph="%s">%s</span>', parsedOutput.valueph-parsedInput.valueph, nocoins(autoround(parsedOutput.valueph-parsedInput.valueph))))
			vdf('profitPK', string.format('<span class="mmg-variable mmg-profit-pk" data-mmg-cost-pk="%s">%s</span>', parsedOutput.valuepk-parsedInput.valuepk, nocoins(autoround(parsedOutput.valuepk-parsedInput.valuepk))))
			vdf('profit', string.format('<span class="mmg-variable mmg-varieswithkph mmg-profit" data-mmg-cost-ph="%s" data-mmg-cost-pk="%s">%s</span>', parsedOutput.valueph-parsedInput.valueph, parsedOutput.valuepk-parsedInput.valuepk, nocoins(autoround(parsedOutput.value-parsedInput.value))))
			if parsedInput.value ~= 0 then
				vdf('roi', string.format('<span class="mmg-variable mmg-varieswithkph mmg-roi" data-mmg-roi-out-ph="%s" data-mmg-roi-in-ph="%s" data-mmg-roi-out-pk="%s" data-mmg-roi-in-pk="%s">%s</span>', parsedOutput.valueph, parsedInput.valueph, parsedOutput.valuepk, parsedInput.valuepk, nocoins(autoround((parsedOutput.value-parsedInput.value)/parsedInput.value*100))))
			else
				vdf('roi', string.format('<span class="mmg-variable mmg-varieswithkph mmg-roi" data-mmg-roi-out-ph="%s" data-mmg-roi-in-ph="%s" data-mmg-roi-out-pk="%s" data-mmg-roi-in-pk="%s">infinite</span>', parsedOutput.valueph, parsedInput.valueph, parsedOutput.valuepk, parsedInput.valuepk))
			end
		else
			vdf('input', string.format('<span class="mmg-input">%s</span>', parsedInput.value, nocoins(autoround(parsedInput.value))))
			vdf('output', string.format('<span class="mmg-output">%s</span>', parsedOutput.value, nocoins(autoround(parsedOutput.value))))
			vdf('profit', string.format('<span class="mmg-profit">%s</span>', parsedOutput.value - parsedInput.value, nocoins(autoround(parsedOutput.value-parsedInput.value))))
			if parsedInput.value ~= 0 then
				vdf('roi', string.format('<span class="mmg-roi">%s</span>', nocoins(autoround((parsedOutput.value-parsedInput.value)/parsedInput.value*100))))
			else
				vdf('roi', '<span class="mmg-roi">infinite</span>')
			end
			vdf('input_raw', parsedInput.value)
			vdf('output_raw', parsedOutput.value)
			vdf('profit_raw', parsedOutput.value-parsedInput.value)
			vdf('roi_raw', (parsedOutput.value-parsedInput.value)/parsedInput.value*100)
		end
	end

	if args['Profit'] or args['Inputs'] or args['Outputs'] then
		if on_main() then
			ret:wikitext('[[Category:Pages with deprecated parameters]]')
		end
	end
	if not allowed_categories[tostring(args.Category):lower()] then
		if on_main() then
			ret:wikitext('[[Category:Money making guides without category]]')
		end
	end

	local set_bucket = on_main()
	if yesno(args.Exclude) and on_main() then
		ret:wikitext('[[Category:Obsolete money making guides]]')
	end

	if set_bucket then
		local skill_names = {}
		for s in args.Skill:gmatch('data%-mmg%-skill=\"([^"]+)\"') do -- Capture the skill name out of the provided arg
			table.insert(skill_names, s)
		end
		local bucket_data = {
			members = yesno(args.Members or 'yes', true),
			skill = args.Skill,
			activity = args.Activity,
			category = args.Category,
			intensity = args.Intensity,
			isperkill = isperkill,
			version = args.Version,
			other = args.Other,
			quest = args.Quest,
			item = args.Item,
			xp = parsedXP.items,
			inputs = parsedInput.list,
			outputs = parsedOutput.list
		}
		local xpstr = {}
		for i,v in ipairs(parsedXP.spans) do
			table.insert(xpstr, tostring(v))
		end
		bucket_data.xp_str = table.concat(xpstr, '')
		if isperkill then
			bucket_data.prices = {
				input_perhour=parsedInput.valueph,
				input_perkill=parsedInput.valuepk,
				output_perhour=parsedOutput.valueph,
				output_perkill=parsedOutput.valuepk,
				default_kph=tonumber(args.kph) or 1,
				default_value=parsedOutput.value - parsedInput.value,
			}
		else
			bucket_data.prices = {
				input=parsedInput.value,
				output=parsedOutput.value,
				value=parsedOutput.value - parsedInput.value
			}
		end
		bucket_data = mw.text.jsonEncode(bucket_data)
		bucket('money_making_guide').sub(args.Version or '').put({
			value = parsedOutput.value - parsedInput.value,
			skill = skill_names,
			recurring = false,
			obsolete = args.Exclude or (parsedOutput.value - parsedInput.value) <= 0,
			json = bucket_data
		})
	end

	return ret
end

-- Calculate the profit and do nothing else.
function p.profit(frame)
	local frame = frame or cur_frame
	local args = frame:getParent().args -- Template args, NOT #invoke args
	local _ = args['Define variables'] -- Needs to be the first read param to make sure {{#vardefine:}} variables are set before they are needed by other params
	local isperkill = yesno(args.isperkill)
	local dyndef = {}
	if isperkill then
		local tmpdyn = handleDynamics(args)
		dyndef = tmpdyn.defs
	end
	local i = handleInputs(args, dyndef, true).value
	local o = handleOutputs(args, dyndef, true).value
	return o - i
end

-- Calculate the cost and do nothing else.
function p.cost(frame)
	local frame = frame or cur_frame
	local args = frame:getParent().args -- Template args, NOT #invoke args
	local _ = args['Define variables'] -- Needs to be the first read param to make sure {{#vardefine:}} variables are set before they are needed by other params
	local isperkill = yesno(args.isperkill)
	local dyndef = {}
	if isperkill then
		local tmpdyn = handleDynamics(args)
		dyndef = tmpdyn.defs
	end
	return handleInputs(args, dyndef, true).value
end

-- Generate the line(s) of experience gained
-- Used by {{Mmgtable/row2}}
function p.xp(frame)
	local frame = frame or cur_frame
	local args = frame:getParent().args
	local _ = args['Define variables'] -- Needs to be the first read param to make sure {{#vardefine:}} variables are set before they are needed by other params
	local ret = {}
	local items = handleXP(args).spans

	if #items > 0 then
		for _, v in ipairs(items) do
			table.insert(ret, tostring(v))
		end
	end

	return table.concat(ret)
end

function p.recurringTable(frame)
	return p._recurringTable(frame, frame:getParent().args)	
end

function p._recurringTable(frame, args)
	local _ = args['Define variables'] -- Needs to be the first read param to make sure {{#vardefine:}} variables are set before they are needed by other params
	local parsedInput = handleInputs(args)
	local parsedOutput = handleOutputs(args)
	local parsedXP = handleXP(args)
	local timeAsString = nil
	local numMinutes = expr(args['Activity Time']) or 1
	local ret = mw.html.create('')
	local tbl = ret:tag('table')

	if numMinutes < 1 then
		local seconds = numMinutes * 60
		timeAsString = seconds..' '..lang:plural(seconds, 'second', 'seconds')
	else
		timeAsString = numMinutes..' '..lang:plural(numMinutes, 'minute', 'minutes')
	end


	tbl = tbl
		:addClass('wikitable')
		:addClass('mmgtable')
		:attr('style', 'width: 100%; text-align: center;')
		:tag('tr')
			:tag('th')
				:attr('colspan', '2')
				:wikitext(MEM_ICON[yesno(args['Members'] or 'yes', true)])
				:wikitext(args['Activity'])
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Profit per instance')
			:done()
			:tag('td')
				:addClass('image-container')
				:attr('rowspan', '8')
				:wikitext(args['Image'])
			:done()
		:done()
		:tag('tr')
			:tag('td')
				if args['Profit'] then
					tbl:wikitext(coins(round(args['Profit'], 0)))
				else
					tbl:wikitext(coins(round(parsedOutput.value - parsedInput.value), 0), ' per instance, after [[Grand Exchange#Trade tariff|tax]]')
				end
				tbl = tbl
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Activity time')
			:done()
		:done()
		:tag('tr')
			:tag('td')
				:wikitext(timeAsString)
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Minimum recurrence time')
			:done()
		:done()
		:tag('tr')
			:tag('td')
				:wikitext(args['Recurrence Time'])
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Effective profit')
			:done()
		:done()
		:tag('tr')
			:tag('td')
				if args['Profit'] then
					tbl:wikitext(coins('('..args['Profit']..') * 60 / ('..args['Activity Time']..') round 0'))
				else
					-- A bit messy but it should do the job. Assuming Activity Time is a well-behaved number, of course.
					tbl:wikitext(coins(tostring(parsedOutput.value - parsedInput.value)..' * 60 / ('..args['Activity Time']..') round 0'))
				end
				tbl = tbl:wikitext(' per hour')
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Skill requirements')
			:done()
			:tag('th')
				:wikitext('Quest requirements')
			:done()
		:done()
		:tag('tr')
			:tag('td')
				:addClass('no-list-style')
				:newline()
				:wikitext(paramtest.default_to(args['Skill'], 'None'))
			:done()
			:tag('td')
				:addClass('no-list-style')
				:newline()
				:wikitext(paramtest.default_to(args['Quest'], 'None'))
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Item requirements')
			:done()
			:tag('th')
				:wikitext('Other requirements')
			:done()
		:done()
		:tag('tr')
			:tag('td')
				:addClass('no-list-style')
				:newline()
				:wikitext(paramtest.default_to(args['Item'], 'None'))
			:done()
			:tag('td')
				:addClass('no-list-style')
				:newline()
				:wikitext(paramtest.default_to(args['Other'], 'None'))
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Experience gained')
			:done()
			:tag('th')
				:wikitext('Location')
			:done()
		:done()
		:tag('tr')
			:tag('td')
				:addClass('no-list-style')
				:newline()
				if args['Other Benefits'] and not (args['Other Benefits'] == nil) and not (args['Other Benefits'] == '') then
					tbl:wikitext(args['Other Benefits'])
				elseif #parsedXP.spans > 0 then
					for _, v in ipairs(parsedXP.spans) do
						tbl:node(v)
					end
				else
					tbl:wikitext('None')
				end
				tbl = tbl
			:done()
			:tag('td')
				-- Sensible enough as a default
				:wikitext(paramtest.default_to(args['Location'], 'Anywhere'))
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Inputs')
				if parsedInput.value ~= 0 then
					tbl:wikitext(' (', coins(round(parsedInput.value, 0)), ')')
				end
				tbl = tbl
			:done()
			:tag('th')
				:wikitext('Outputs')
				if parsedOutput.value ~= 0 then
					tbl:wikitext(' (', coins(round(parsedOutput.value, 0)), ' after [[Grand Exchange#Trade tariff|tax]])')
				end
				tbl = tbl
			:done()
		:done()
		:tag('tr')
			:tag('td')
					if args['Inputs'] then
						tbl:wikitext(args['Inputs'])
					elseif #parsedInput.spans > 0 then
						generateInputTable(args, tbl, parsedInput)
					elseif parsedInput.text then
						tbl:wikitext(parsedInput.text)
					else
						tbl:wikitext('None')
					end
				tbl = tbl
			:done()
			:tag('td')
					if args['Outputs'] then
						tbl:wikitext(args['Outputs'])
					elseif #parsedOutput.spans > 0 then
						generateOutputTable(args, tbl, parsedOutput)
					elseif parsedOutput.text then
						tbl:wikitext(parsedOutput.text)
					else
						tbl:wikitext('None')
					end
				tbl = tbl
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:attr('colspan', '2')
				:wikitext('Details')
			:done()
		:done()
	:done()

	if args['Profit'] or args['Inputs'] or args['Outputs'] then
		if on_main() then
			ret:wikitext('[[Category:Pages with deprecated parameters]]')
		end
	end

	local set_bucket = on_main()
	if yesno(args.Exclude) and on_main() then
		ret:wikitext('[[Category:Obsolete money making guides]]')
	end

	if set_bucket then
		local skill_names = {}
		for s in args.Skill:gmatch('data%-mmg%-skill=\"([^"]+)\"') do -- Capture the skill name out of the provided arg
			table.insert(skill_names, s)
		end
		local bucket_data = {
			members = yesno(args.Members or 'yes', true),
			skill = args.Skill,
			activity = args.Activity,
			category = args.Category,
			intensity = args.Intensity,
			version = args.Version,
			other = args.Other,
			quest = args.Quest,
			item = args.Item,
			xp = parsedXP.items,
			time = numMinutes,
			recurrence = args['Recurrence Time'],
			prices = {
				input=parsedInput.value,
				output=parsedOutput.value,
				value=parsedOutput.value - parsedInput.value
			},
			inputs = parsedInput.list,
			outputs = parsedOutput.list
		}
		bucket_data = mw.text.jsonEncode(bucket_data)
		bucket('money_making_guide').sub(args.Version or '').put({
			value = parsedOutput.value - parsedInput.value,
			skill = skill_names,
			recurring = true,
			obsolete = args.Exclude or (parsedOutput.value - parsedInput.value) <= 0,
			json = bucket_data
		})
	end

	return ret
end

return p