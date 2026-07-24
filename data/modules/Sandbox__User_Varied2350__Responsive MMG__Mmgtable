local p = {}

-- imports
local gePrice = require('Module:Exchange')._price
local yn = require('Module:Yesno')
local round = require('Module:Number')._round
local _coins = require('Module:Currency')._amount
local vdf = mw.ext.VariablesLua.vardefine
local lang = mw.getContentLanguage()
local title = mw.title.getCurrentTitle()
local onmain = require('Module:Mainonly').on_main
local pagesWithCats = require('Module:PageListTools').pageswithcatsdpl

function expr(x)
	local e_g, e = pcall(mw.ext.ParserFunctions.expr, x)
	if e_g then
		return e
	end
	return nil
end

function sigfig(x, p)
	local x_sign = x < 0 and '-1' or '1'
	local x = math.abs(x)
	if x == 0 then
		return 0
	end
	local n = math.floor(math.log10(x)) + 1 - p
	return tonumber(x_sign) * math.pow(10,n) * round(x/math.pow(10, n), 0)
end

function autoround(x, f)
	x = tonumber(x) or 0
	local _x
	if x < 0.1 and x > -0.1 then
		_x = sigfig(x,2)
	elseif x >= 100 or x <= -100 then
		_x = round(x, 0)
	else
		_x = round(x, 2)
	end
	if f then
		return lang:formatNum(_x)
	end
	return _x
end

function deduct_tax(name, val)
	local tax_excluded = false
	for _, v in ipairs(pagesWithCats({'Items exempt from Grand Exchange tax'})) do
		if type(v) == "table" then
			v = v[1]
		end
		local item = string.match(v, '%|(.*)]]$')
		if item == name then
			tax_excluded = true
		end
	end
	if not tax_excluded then
		return val - math.min(math.floor(val * 0.02), 5000000)
	end
	return val
end

-- Config constants, change as needed
MAX_INPUTS = 75
MAX_OUTPUTS = 75
MAX_XP = 75

function p.testmmgtable(args)
	return p._mmgtable(mw.getCurrentFrame(), args)
end

function p.mmgtable(frame)
	local args = frame:getParent().args
	return p._mmgtable(frame, args)
end

-- Create an MMG table.
-- Frame is the frame the module was invoked from.
-- Args are the template arguments used when creating the table.
function p._mmgtable(frame, args)
	local _ = args['Define variables'] -- Needs to be the first read param to make sure {{#vardefine:}} variables are set before they are needed by other params
	local parsedInput = handleInputs(args)
	local parsedOutput = handleOutputs(args)
	local parsedXP = handleXP(args)
	local is_per_kill = yn(args.isperkill)
	local ret = mw.html.create('')
	
	mw.logObject(parsedInput)
	mw.logObject(parsedOutput)
	mw.logObject(parsedXP)
	
	local tbl = ret:tag('table'):addClass('wikitable mmg-table')
			:cssText('width:100%;text-align:center;')
			:tag('caption')
				:wikitext(args['Activity'])
			:done()
			:tag('tr')
				:tag('th')
					:addClass('mmg-row-req-th')
					:wikitext('Requirements')
				:done()
				:tag('td')
					:addClass('mmg-table-img-td')
					:attr('rowspan', '9')
					:wikitext(args['Image'] or '{{{Image}}}')
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:addClass('mmg-table-skill-th')
					:wikitext('Skills')
					:cssText('font-weight:normal')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:addClass('plainlist')
					:addClass('mmg-row-skill-td')
					:newline()
					:wikitext(args['Skill'] or 'None') -- Can leave blank if no reqs.
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:addClass('mmg-row-item-th')
					:wikitext('Items')
					:cssText('font-weight:normal')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:addClass('plainlist')
					:addClass('mmg-row-item-td')
					:newline()
					:wikitext(args['Item'] or 'None') -- Can leave blank if no reqs.
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:addClass('mmg-row-quest-th')
					:wikitext('Quest')
					:cssText('font-weight:normal')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:addClass('plainlist')
					:addClass('mmg-row-quest-td')
					:newline()
					:wikitext(args['Quest'] or 'None') -- Can leave blank if no reqs
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:addClass('mmg-row-other-th')
					:wikitext('Other')
					:cssText('font-weight:normal')
				:done()
			:done()
			:tag('tr')
				:tag('td')
					:addClass('mmg-row-other-td')
					:addClass('plainlist')
					:newline()
					:wikitext(args['Other'] or 'None') -- Can leave blank if no reqs
				:done()
			:done()
			:tag('tr')
				:tag('th')
					:addClass('mmg-row-res-th')
					:attr('colspan', '2')
					:wikitext('Results')
				:done()
			:done()
			:tag('tr')
				:addClass('mmg-row-res-tr')
				:tag('th')
					:addClass('mmg-row-profit-th')
					:wikitext('Profit')
					:cssText('font-weight:normal')
				:done()
				:tag('th')
					:addClass('mmg-row-exp-th')
					:wikitext('Experience gained')
					:cssText('font-weight:normal')
				:done()
			:done()
			
	local xpTR = tbl:tag('tr'):addClass('mmg-row-res-vals-tr')
	local profitTD = xpTR:tag('td')
	profitTD:addClass('mmg-varieswithkph'):addClass('mmg-row-profit-td')
		:attr({['data-mmg-cost-ph'] = parsedOutput.valueph-parsedInput.valueph, ['data-mmg-cost-pk'] = parsedOutput.valuepk-parsedInput.valuepk})
		:wikitext(_coins(autoround(parsedOutput.value - parsedInput.value), 'coins')..', after [[Grand Exchange#Convenience fee and item sink|tax]]')
	
	local xpTD = xpTR:tag('td'):addClass('mmg-row-exp-td')
	if args['Other Benefits'] then
		xpTD:newline():wikitext(args['Other Benefits']):addClass('plainlist')
	elseif #parsedXP.spans > 0 then
		for i,v in ipairs(parsedXP.spans) do
			xpTD:node(v)
		end
	else
		xpTD:wikitext('None')
	end
	
	local putsTRH = tbl:tag('tr'):addClass('mmg-row-io-tr')
	local inputTH = putsTRH:tag('th'):cssText('font-weight:normal'):addClass('mmg-row-in-th')
	inputTH:wikitext('Inputs')
	if parsedInput.value ~= 0 then
		inputTH:wikitext(' (')
			:tag('span')
				:addClass('mmg-varieswithkph')
				:attr({['data-mmg-cost-ph'] = parsedInput.valueph, ['data-mmg-cost-pk'] = parsedInput.valuepk})
				:wikitext(_coins(autoround(parsedInput.value), 'coins'))
			:done()
			:wikitext(')')
	end
	
	local outputTH = putsTRH:tag('th'):cssText('font-weight:normal'):addClass('mmg-row-out-th')
	outputTH:wikitext('Outputs')
	if parsedOutput.value ~= 0 then
		outputTH:wikitext(' (')
			:tag('span')
				:addClass('mmg-varieswithkph')
				:attr({['data-mmg-cost-ph'] = parsedOutput.valueph, ['data-mmg-cost-pk'] = parsedOutput.valuepk})
				:wikitext(_coins(autoround(parsedOutput.value), 'coins'))
			:done()
			:wikitext(', after [[Grand Exchange#Convenience fee and item sink|tax]])')
	end
	
	local inputTR = tbl:tag('tr'):addClass('mmg-row-io-vals-tr')
	local inputTD = inputTR:tag('td'):addClass('mmg-row-in-td')
	local outputTD = inputTR:tag('td'):addClass('mmg-row-out-td')
	for i,v in ipairs(parsedInput.spans) do
		inputTD:node(v)
	end
	for i,v in ipairs(parsedOutput.spans) do
		outputTD:node(v)
	end
	
	local kph_text = args['kph name'] or 'Kills per hour'
	if is_per_kill then
		tbl:addClass('mmg-isperkill')
			:attr('data-default-kph', tonumber(args.kph))
			:attr('data-default-kph-name', kph_text)
	end
	
	if not(yn(args.noexports)) then
		if is_per_kill then
			vdf('kph', string.format('<span class="mmg-variable mmg-kph">%s</span>', tonumber(args.kph)))
			vdf('default_kph', string.format("%d", args.kph))
			vdf('inputPH', string.format('<span class="mmg-variable mmg-input-ph" data-mmg-cost-ph="%s">%s</span>', parsedInput.valueph, _coins(autoround(parsedInput.valueph), 'nocoins')))
			vdf('inputPK', string.format('<span class="mmg-variable mmg-input-pk" data-mmg-cost-pk="%s">%s</span>', parsedInput.valuepk, _coins(autoround(parsedInput.valuepk), 'nocoins')))
			vdf('input', string.format('<span class="mmg-variable mmg-input" data-mmg-cost-ph="%s", data-mmg-cost-pk="%s">%s</span>', parsedInput.valueph, parsedInput.valuepk, _coins(autoround(parsedInput.value), 'nocoins')))
			vdf('outputPH', string.format('<span class="mmg-variable mmg-output-ph" data-mmg-cost-ph="%s">%s</span>', parsedOutput.valueph, _coins(autoround(parsedOutput.valueph), 'nocoins')))
			vdf('outputPK', string.format('<span class="mmg-variable mmg-output-pk" data-mmg-cost-pk="%s">%s</span>', parsedOutput.valuepk, _coins(autoround(parsedOutput.valuepk), 'nocoins')))
			vdf('output', string.format('<span class="mmg-variable mmg-varieswithkph mmg-output" data-mmg-cost-ph="%s", data-mmg-cost-pk="%s">%s</span>', parsedOutput.valueph, parsedOutput.valuepk, _coins(autoround(parsedOutput.value), 'nocoins')))
			vdf('profitPH', string.format('<span class="mmg-variable mmg-profit-ph" data-mmg-cost-ph="%s">%s</span>', parsedOutput.valueph-parsedInput.valueph, _coins(autoround(parsedOutput.valueph-parsedInput.valueph), 'nocoins')))
			vdf('profitPK', string.format('<span class="mmg-variable mmg-profit-pk" data-mmg-cost-pk="%s">%s</span>', parsedOutput.valuepk-parsedInput.valuepk, _coins(autoround(parsedOutput.valuepk-parsedInput.valuepk), 'nocoins')))
			vdf('profit', string.format('<span class="mmg-variable mmg-varieswithkph mmg-profit" data-mmg-cost-ph="%s", data-mmg-cost-pk="%s">%s</span>', parsedOutput.valueph-parsedInput.valueph, parsedOutput.valuepk-parsedInput.valuepk, _coins(autoround(parsedOutput.value-parsedInput.value), 'nocoins')))
		else
			vdf('input', string.format('<span class="mmg-input">%s</span>', parsedInput.value, _coins(autoround(parsedInput.value), 'nocoins')))
			vdf('output', string.format('<span class="mmg-input">%s</span>', parsedOutput.value, _coins(autoround(parsedOutput.value), 'nocoins')))
			vdf('profit', string.format('<span class="mmg-input">%s</span>', parsedOutput.value-parsedInput.value, _coins(autoround(parsedOutput.value-parsedInput.value), 'nocoins')))
			vdf('input_raw', parsedInput.value)
			vdf('output_raw', parsedOutput.value)
			vdf('profit_raw', parsedOutput.value-parsedInput.value)
		end
	end
	
	frame:callParserFunction('DISPLAYTITLE', title.subpageText)
	frame:callParserFunction('DEFAULTSORT', title.subpageText)
	
	local cats = '[[Category:Money making guides]]'
	
	if args['Members'] == nil then
		cats = cats .. '[[Category:Money making guides without a membership status]]'
	elseif not(yn(args['Members'])) then
		cats = cats .. '[[Category:MMG/F2P]]'
	end
	
	local final_profit = parsedOutput.value - parsedInput.value
	
	local set_bucket = true
 	if final_profit <= 100000 and yn(args['Members']) then
		cats = cats .. '[[Category:Obsolete money making guides]]'
	elseif ((final_profit <= 20000) and (parsedInput.value>0) ) then
		cats = cats .. '[[Category:Obsolete money making guides]]'
	elseif final_profit <= 15000 then
		cats = cats .. '[[Category:Obsolete money making guides]]'
	elseif yn(args.Exclude) then
		cats = cats .. '[[Category:Obsolete money making guides]]'
	else
		cats = cats .. '[[Category:Worthwhile money making guides]]'
	end
	
	if args["Category"] then
		local mmgcat = ({
			["Combat/Low"] = "[[Category:MMG/Combat]]",
			["Combat/Mid"] = "[[Category:MMG/Combat]]",
			["Combat/High"] = "[[Category:MMG/Combat]]",
			["Combat"] = "[[Category:MMG/Combat]]",
			["Skilling"] = "[[Category:MMG/Skilling]]",
			["Processing"] = "[[Category:MMG/Processing]]",
			["Recurring"] = "[[Category:MMG/Recurring]]",
			["Collecting"] = "[[Category:MMG/Collecting]]",
			["Ironman"] = "[[Category:MMG/Ironman]]"
		})[args["Category"]]
		if mmgcat == nil then
			cats = cats .. '[[Category:Money making guides with an invalid category]]'
		else
			cats = cats .. mmgcat
		end
	else
		cats = cats .. '[[Category:Money making guides without a category]]'
	end
	
	if not onmain() then
		set_bucket = false
		cats = ''
	end
	
	if set_bucket then
		local bucket_data = {
			members = yn(args.Members or 'yes', true),
			skill = args.Skill,
			quest = args.Quest,
			activity = args.Activity,
			category = args.Category,
			skillcategory = args.SkillCategory,
			intensity = args.Intensity,
			isperkill = is_per_kill,
			version = args.Version,
			inputs = parsedInput.list,
			outputs = parsedOutput.list
		}
		if is_per_kill then
			bucket_data.prices = {
				input_perhour=parsedInput.valueph,
				input_perkill=parsedInput.valuepk,
				output_perhour=parsedOutput.valueph,
				output_perkill=parsedOutput.valuepk,
				default_kph=tonumber(args.kph) or 1,
				kph_text=kph_text,
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
		
		bucket("money_making_guide").put({
			value = parsedOutput.value - parsedInput.value,
			recurring = false,
			json = bucket_data
		})
	end
	
	return ret, cats
end

-- Calculate the profit and do nothing else.
function p.profit(frame)
	local frame = frame or mw.getCurrentFrame()
	local args = frame:getParent().args -- Template args, NOT #invoke args
	local _ = args['Define variables'] -- Needs to be the first read param to make sure {{#vardefine:}} variables are set before they are needed by other params
	
	return handleOutputs(args).value - handleInputs(args).value
end

-- Implements handleInputs and handleOutputs
-- See those functions for further details
function handleIteratedArgs(args, prefix, max_iters)
	local frame = mw.getCurrentFrame()
	local items = {}
	local total_item_value = 0
	local textlines = {}
	local is_per_kill = yn(args.isperkill)
	local defaultKPH = tonumber(args.kph) or 1
	local value_per_kill = 0
	local value_per_hour = 0
	
	for i=1,max_iters,1 do
		if not args[prefix..i] or args[prefix..i] == '' then break end
		local pri = prefix..i
		local span = mw.html.create('span')
		span:addClass('mmg-itemline mmg-'..prefix:lower())
		
		local name = args[pri]
		local qty_param = args[pri..'num']
		local actual_qty = nil
		local value_param = args[pri..'value']
		local actual_value = nil
		local is_per_hour = not is_per_kill
		if is_per_kill and yn(args[pri..'isph']) then
			is_per_hour = true
		end
		
		-- Keep track of sanity check states - we want to handle them gracefully later.
		local invalid_qty_present = false
		local invalid_value_present = false
		local failed_ge_lookup = false
		local pricetype = ''
		
		if qty_param then
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
		
		if value_param then
			-- Again, if it was specified, it should be a number
			-- If it isn't, we pretend it wasn't specified
			--   but we alert the user because it's probably not what they want
			actual_value = tonumber(value_param) or expr(value_param)
			invalid_value_present = not actual_value
			pricetype = 'value'
		end
		
		-- If we got the value earlier, skip this part
		if not actual_value then
			-- Here we try to find an exchange price
			-- If we get here, and we can't get an exchange price
			-- we default to 0.
			-- This is almost certainly not what the user wants,
			-- so we warn them about it.
			local success, price = pcall(gePrice, name)
			actual_value = success and tonumber(price) -- This is awful but still pleasant somehow
			failed_ge_lookup = not actual_value
			actual_value = actual_value or 0
			
			-- GE takes 2% (rounding down) tax on items sold for > 49gp
			-- except for a few random ones (chisel, spade, etc)
			if prefix == 'Output' and actual_value > 49 then
				actual_value = deduct_tax(name, actual_value)
			end
			pricetype = 'gemw'
		end
	
		local this_item_value, this_item_qty, attrName
		local attrVal = actual_qty * actual_value
		if is_per_kill and not is_per_hour then
			span:addClass('mmg-varieswithkph')
			this_item_qty = actual_qty * defaultKPH
			this_item_value = attrVal * defaultKPH
			value_per_kill = value_per_kill + attrVal
			attrName = 'data-mmg-cost-pk'
		else
			this_item_qty = actual_qty
			this_item_value = attrVal
			value_per_hour = value_per_hour + attrVal
			attrName = 'data-mmg-cost-ph'
		end
		total_item_value = total_item_value + this_item_value
		
		span:tag('span'):addClass('mmg-quantity'):attr('data-mmg-qty', actual_qty):wikitext(autoround(this_item_qty, true))
		if invalid_qty_present then
			span:node(warning('Could not interpret \''..qty_param..'\' as a number, defaulting to 1'))
		end
		span:wikitext(string.format(' × [[File:%s.png|link=%s]] [[%s]] (', name, name, name))
		span:tag('span'):addClass('mmg-cost'):attr(attrName, attrVal):wikitext(_coins(autoround(this_item_value), 'nocoins'))
		span:wikitext(')')
		if invalid_value_present then
			span:node(warning('Could not interpret \''..value_param..'\' as a number, ignoring.'))
		end
		if failed_ge_lookup then
			span:node(warning('Could not find exchange price for item \''..name..'\', please double-check the spelling'))
			span:wikitext('[[Category:Money making guides with a failed GE lookup]]')
		end
		if args[pri..'note'] then
			span:tag('span'):addClass('mmg-note'):wikitext(' ',args[pri..'note'])
		end
		
		table.insert(textlines, span)
			
		table.insert(items, {name = name, qty = actual_qty, value = actual_value, isph = is_per_hour, pricetype=pricetype})
	end
	
	return {value = total_item_value, valuepk = value_per_kill, valueph = value_per_hour, spans = textlines, list = items}
end

-- args are the args supplied to the template, (or a subset of them contining all input arguments)
-- Returns a table. The table has three keys: 'value', 'text', and 'as_table'
---- 'value' contains the total value of the inputs specified by args
---- 'text' contains a formatted string based on the inputs specified by args. This can be directly plugged into the HTML table.
---- 'list' contains all the inputs as a Lua list. Each input is represented by a table with the following keys
------ 'name' being the name of the item
------ 'value' being the value of the item in question
------ 'qty' being the quantity specified for the item
function handleInputs(args)
	return handleIteratedArgs(args, 'Input', MAX_INPUTS)
end

-- args are the args supplied to the template, (or a subset of them contining all output arguments)
-- Returns a table. The table has two keys: 'value', and 'text'
---- 'value' contains the total value of the outputs specified by args
---- 'text' contains a formatted string based on the outputs specified by args. This can be directly plugged into the HTML table.
---- 'list' contains all the outputs as a Lua list. Each output is represented by a table with the following keys
------ 'name' being the name of the item
------ 'value' being the value of the item in question
------ 'qty' being the quantity specified for the item
function handleOutputs(args)
	return handleIteratedArgs(args, 'Output', MAX_OUTPUTS)
end


function handleXP(args)
	local frame = mw.getCurrentFrame()
	local items = {}
	local textlines = {}
	local is_per_kill = yn(args.isperkill)
	local defaultKPH = tonumber(args.kph) or 1
	
	for i=1,MAX_XP,1 do
		if not args['Experience'..i] then break end
		local pri = 'Experience'..i
		local span = mw.html.create('span')
		span:addClass('mmg-xpline')
		
		local skill = args[pri]
		local qty_param = args[pri..'num']
		local actual_qty = tonumber(qty_param) or expr(qty_param) or 0
		local is_per_hour = not is_per_kill
		if is_per_kill and yn(args[pri..'isph']) then
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
		
		-- TODO modulise SCP
		span:attr(attrName, actual_qty)
			:wikitext(frame:expandTemplate{title='SCP', args = { skill, autoround(this_item_value, true) }})
		
		table.insert(textlines, span)
		table.insert(items, { skill = skill, xp = actual_qty, isph = is_per_hour })
	end
	
	return { spans = textlines, items = items }
end

-- Creates a neat little warning message
function warning(msg)
	return mw.html.create('span')
				:addClass('mmg-warning')
				:css({
					['border-bottom'] = '1px red dotted',
					color = 'red',
					cursor = 'help'
				})
				:attr('title', msg)
				:wikitext('*')
end

function p.recurringTable(frame)
	return p._recurringTable(frame, frame:getParent().args)	
end

function p._recurringTable(frame, args)
	local _ = args['Define variables'] -- Needs to be the first read param to make sure {{#vardefine:}} variables are set before they are needed by other params
	local parsedInput = handleInputs(args)
	local parsedOutput = handleOutputs(args)
	local timeAsString = nil
	local num_good, numMinutes = pcall(mw.ext.ParserFunctions.expr, args['Activity Time'])
	numMinutes = tonumber(numMinutes)
	if not num_good or not numMinutes then
		numMinutes = 1
	end
	if numMinutes < 1 then
		local seconds = numMinutes * 60
		timeAsString = seconds..' '..lang:plural(seconds, 'second', 'seconds')
	else
		timeAsString = numMinutes..' '..lang:plural(numMinutes, 'minute', 'minutes')
	end
	local tbl = mw.html.create('table')
	local inputTR = mw.html.create('tr')
	local inputTD = inputTR:tag('td')
	local outputTD = inputTR:tag('td')
	for i,v in ipairs(parsedInput.spans) do
		inputTD:node(v)
	end
	for i,v in ipairs(parsedOutput.spans) do
		outputTD:node(v)
	end

	
	-- This is one statement, defining a single variable. It goes on for 120 lines. I don't know how I feel about this tbh.
	 -- I mean how the heck would you even document this, for a start?
	tbl:addClass('wikitable') -- I guess it's pretty self-documenting if you know HTML
		:cssText('width:100%;text-align:center;') -- But like...
		:tag('tr')
			:tag('caption')
				:wikitext(args['Activity'])
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Profit per instance')
			:done()
			:tag('td')
				:attr('rowspan', '8')
				:wikitext(args['Image'])
			:done()
		:done()
		:tag('tr')
			:tag('td')
				:wikitext(_coins(round(parsedOutput.value - parsedInput.value, 0), 'coins'), ' per instance, after [[Grand Exchange#Convenience fee and item sink|tax]]')
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
				:wikitext(_coins(tostring(parsedOutput.value - parsedInput.value)..' * 60 / ('..args['Activity Time']..') round 0', 'coins') .. ' per hour, after [[Grand Exchange#Convenience fee and item sink|tax]]') -- A bit messy but it should do the job. Assuming Activity Time is a well-behaved number, of course.
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
				:addClass('plainlist')
				:newline()
				:wikitext(args['Skill'] or 'None')
			:done()
			:tag('td')
				:addClass('plainlist')
				:newline()
				:wikitext(args['Quest'] or 'None')
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
				:addClass('plainlist')
				:newline()
				:wikitext(args['Item'] or 'None')
			:done()
			:tag('td')
				:addClass('plainlist')
				:newline()
				:wikitext(args['Other'] or 'None')
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
				:wikitext(args['Other Benefits'] or 'None')
			:done()
			:tag('td')
				:wikitext(args['Location'] or 'Anywhere') -- Sensible enough as a default
			:done()
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('Inputs')
				:wikitext(' (', _coins(round(parsedInput.value, 0), 'coins'), ')')
			:done()
			:tag('th')
				:wikitext('Outputs')
				:wikitext(' (', _coins(round(parsedOutput.value, 0), 'coins'), ', after [[Grand Exchange#Convenience fee and item sink|tax]])')
			:done()
		:done()
		:node(inputTR)
	:done()
	
	frame:callParserFunction('DISPLAYTITLE', title.subpageText)
	frame:callParserFunction('DEFAULTSORT', title.subpageText)
	
	local cats = '[[Category:Money making guides]][[Category:MMG/Recurring]]'
	
	local final_profit = parsedOutput.value - parsedInput.value
	
	local set_bucket = true
	if final_profit <= 0 then
		cats = cats .. '[[Category:Obsolete money making guides]]'
	elseif yn(args.Exclude) then
		cats = cats .. '[[Category:Obsolete money making guides]]'
	else
		cats = cats .. '[[Category:Worthwhile money making guides]]'
	end
	
	if not onmain() then
		set_bucket = false
		cats = ''
	end
	
	if set_bucket then
		local bucket_data = {
			members = yn(args.Members or 'yes', true),
			skill = args.Skill,
			quest = args.Quest,
			other = args.Other,
			activity = args.Activity,
			category = args.Category,
			version = args.Version,
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
		
		bucket("money_making_guide").put({
			value = parsedOutput.value - parsedInput.value,
			recurring = true,
			json = bucket_data
		})
	end
	
	return tbl, cats
end

return p