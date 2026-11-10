require('Module:Mw.html extension')
local geprice = require('Module:ExchangeLite').price
local plinkt = require("Module:Plink")._plinkt
local coins = require('Module:Coins')._amount
local hc = require('Module:Paramtest').has_content
local yn = require('Module:Yesno')

local p = {}

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

local function search_args_side(args,side)
	
	local items = {}
	local i = 1
	
	while i do
		local matroot = side..tostring(i)
		local matimg = matroot..'img'
		local matname = matroot..'name'
		local matqty = matroot..'qty'
		
		if args[matroot] then
			items[i] = {
				link = args[matroot],
				pic = args[matimg] or args[matroot],
				name = args[matname] or args[matroot],
				qty = args[matqty] and tonumber(args[matqty]) or 1,
				beforeLink = args[matqty] and tostring(tonumber(args[matqty]))..'x ' or ''
			}
			i = i + 1
		else
			i=nil
			break
		end
	end
	
	return items
	
end

local function parse_facility(facility)
	if yn(facility)==false then 
		facility = nil
	elseif not hc(facility) then
		facility = ('[%s (edit)]'):format(mw.title.getCurrentTitle():fullUrl({ action = 'edit' }))
	else
		facility = string.gsub(facility,'^%s*%[%[','')
		facility = string.gsub(facility,'%[%[%s*$','')
		facility = ('[[%s]]'):format(facility)
	end
	return facility
end

function p._main(args)
	
	-- whether to include prices or not
	local showGE = yn(args.showGE,false)
	
	--facility
	local facility = parse_facility(args.facility)
	
	--comparison
	local compare = yn(args.compare,false)
	
	-- iterate through items
	local args_left = search_args_side(args,'left') 
	local args_right = search_args_side(args,'right') 
	
	-- create table

	return p.create_table(showGE,facility,compare,args_left,args_right)

end

function p.create_table(showGE,facility,compare,args_left,args_right)
	
	local N_cols = showGE and 3 or 2
	local N_rows = math.max(#args_left,#args_right)
	local N_rows_divider = N_rows+1+(showGE and 1 or 0)+(compare and 1 or 0)
	
	local nullrow = mw.html.create('td')
		:addClass('table-na')
		:attr({colspan=N_cols})
		:wikitext('-')
	:done()
	
	local nullval = mw.html.create('td')
		:addClass('table-na')
		:wikitext('-')
	:done()
	
	local total_left = 0
	local total_right = 0
	
	local tab = mw.html.create('table')
		:addClass('wikitable')
		:tag('tr')
			:tag('th')
				:attr({colspan=N_cols*2+2})
				:wikitext('Item exchange')
			:done()
		:done()
	
	if facility then
		tab:tag('tr')
			:tag('td')
				:attr({colspan=N_cols+1})
				:wikitext('[[File:World Map icon.png|21px|link=]] Facility')
			:done()
			:tag('td')
				:attr({colspan=N_cols+1})
				:wikitext(facility or '')
			:done()
		:done()
	end
		
		tab:tag('tr')
			:tag('th')
				:attr({colspan=N_cols})
				:wikitext('Item')
			:done()
			:tag('th')
				:attr({rowspan=N_rows_divider,colspan=2})
				:wikitext('↔')
			:done()
			:tag('th')
				:attr({colspan=N_cols})
				:wikitext('Item')
			:done()
		:done()
	:done()
	
	for i=1,N_rows do
		
		local left_item = args_left[i] and args_left[i].link
		local left_plinkt = args_left[i] and plinkt(_,args_left[i]) or nullrow
		local left_showval = showGE and left_item
       	local left_val = left_showval and ((geprice(left_item) or 0) * (tonumber(args_left[i].qty) or 1)) or 0
		local left_valdisp = mw.html.create('td'):wikitext(coins(left_val)):done()
		if left_val==0 then left_valdisp=nullval end
		total_left = total_left + left_val
		
		local right_item = args_right[i] and args_right[i].link 
		local right_plinkt = args_right[i] and plinkt(_,args_right[i]) or nullrow
		local right_showval = showGE and right_item
		local right_val = right_showval and ((geprice(right_item) or 0) * (tonumber(args_right[i].qty) or 1)) or 0
		local right_valdisp = mw.html.create('td'):wikitext(coins(right_val)):done()
		if right_val==0 then right_valdisp=nullval end
		total_right = total_right + right_val
		
		local row = tab:tag('tr')
			:node(left_plinkt)
		if left_showval then 
			row:node(left_valdisp)
		end
		row:node(right_plinkt)
		if right_showval then 
			row:node(right_valdisp)
		end
		row:done()
	end
	
	if showGE then
		tab:tagIf(showGE,'tr')
			:tag('th')
				:attr({colspan=2})
				:css('align=right')
				:wikitext('Total')
			:done()
			:tag('th')
				:wikitext(coins(total_left))
			:done()
			:tag('th')
				:attr({colspan=2})
				:css('align=right')
				:wikitext('Total')
			:done()
			:tag('th')
				:wikitext(coins(total_right))
			:done()
		:done()
	end
	
	if compare and showGE then
		tab:tag('tr')
			:tag('td')
				:attr({colspan=3})
				:addClass('table-na')
				:wikitext('-')
			:done()
			:tag('th')
				:attr({colspan=2})
				:css('align=right')
				:wikitext('Difference')
			:done()
			:tag('th')
				:wikitext(coins(total_right-total_left))
			:done()
		:done()
	end
	
	return tab

end

return p