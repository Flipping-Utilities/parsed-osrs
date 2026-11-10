--<nowiki>
local p = {}
local coins = require('Module:Currency')._amount
local curr_image = require('Module:Currency Image')

function p.main(frame)
	local args = frame:getParent().args
	
	local item = args['item'] or args[1]
	item = mw.text.trim(item)
	local store = args['store'] or args[2]
	store = mw.text.trim(store or '')
	local img = false
	if args['image'] or args[3] then
		img = true
	end
	
	local ret = p._main(item, store, img)
	if img then
		return ret
	else
		return ret[1]
	end
end
	
function p._main(item, store, img)
	-- Bucket
	local b = bucket('storeline')
		.select('page_name_sub', 'store_sell_price', 'store_currency')
		.where('sold_item', item)
		.limit(1)
		
	if store and store ~= '' then
		b.where('page_name_sub', store)
	end
	
	local data = b.run()
	if data == nil or #data == 0 then
		if store and store ~= '' then
			error('The item "' .. item .. '" is not sold in the "'..store..'" store, please check for typos', 0)
		else
			error('The item "' .. item .. '" is not sold in any shop, please check for typos', 0)
		end
	end
	
	local price = data[1]['store_sell_price']
	local curr = data[1]['store_currency'][1]
	local pstore = data[1]['page_name_sub']
	
	if not tonumber(price, 10) then
		error('The price "' .. price .. '" found is not a number', 0)
	end
	
	if img then
		if string.lower(curr) == 'coins' then
			return coins(price, 'coins')
		else
			local currimg = curr_image(curr, price)
			return string.format('<span class="inventory-image">[[File:%s|x22px|link=]]</span> %s', currimg, price)
		end
	end
	return {price, curr, pstore}
end

return p