-- <nowiki>
require('strict')
local hasc = require('Module:Paramtest').has_content
local p = {}

local function formatAmount(_x)
	local x = tonumber(_x) or 1
	if x < 100000 then
		return x, 'qty-1'
	elseif x < 10000000 then
		return tostring(math.floor(x / 1000)) .. 'K', 'qty-100k'
	else
		return tostring(math.floor(x / 1000000)) .. 'M', 'qty-10m'
	end
end

function p._main(items, align, caption)
	local ret = mw.html.create('table')
		:addClass('inventorytable inventory-image')
	
	if align == 'left' or align == 'right' or align == 'center' then
		ret:addClass('float-' .. align)
	end
	
	if hasc(caption) then
		ret:tag('caption')
			:addClass('thumbcaption')
			:wikitext(caption)
		:done()
	end
	
	local slot = 0
	for row = 1, 7 do
		local tr = mw.html.create('tr')
		for col = 1, 4 do
			local td = mw.html.create('td')
			slot = slot + 1
			local name = items[slot].name
			local quantity = items[slot].quantity
			local noted = items[slot].noted
			local image = items[slot].image
			
			if hasc(name) then
				if noted then
					td:addClass('noted-item')
				end
				td:wikitext(string.format('[[File:%s.png|link=%s|32x32px|frameless]]', image, name))
				
				if quantity > 1 or noted then
					local qtyNum, qtyClass = formatAmount(quantity)
					td:tag('span')
						:addClass('inv-quantity-text')
						:addClass(qtyClass)
						:wikitext(qtyNum)
					:done()
				end
			end
			tr:node(td)
		end
		ret:node(tr)
	end
	return ret:allDone()
end

function p.main(frame)
	local args = frame:getParent().args
	local align = mw.text.trim((args.align or ''):lower())
	local caption = mw.text.trim(args.caption or '')
	local items = {}
	
	for i = 1, 28 do
		local item = mw.text.trim(args[i] or '')
		local name, quantity, noted, image
		
		if hasc(item) then
			item = item:gsub('[%[%]]', '')
			quantity = tonumber(item:match('\\(%d+)')) or 1
			noted = item:match(';n') == ';n'
			name = mw.text.split(item, '[;\\]')[1]
		end
		
		local img = mw.text.trim(args['image' .. i] or '')
		image = hasc(img) and img or name
		
		table.insert(items, {
			name = name,
			quantity = quantity,
			noted = noted,
			image = image
		})
	end
	
	return p._main(items, align, caption)
end

return p
-- </nowiki>