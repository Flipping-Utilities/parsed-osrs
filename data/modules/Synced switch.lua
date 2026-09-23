local p = {}
local hc = require('Module:Paramtest').has_content

p._sortFunc = function(a,b)
	return a.id < b.id
end

p.main = function(frame)
	local args = frame:getParent().args
	local parsed = { {id=0, content=args.default or '', showing = true} }
	
	for k,v in pairs(args) do
		local s = tostring(k):match('version(%d+)')
		if hc(v) and s then
			local obj = {id=tonumber(s), text=args['text'..s], content=v}
			if obj.id == 1 then
				obj.showing = true
				parsed[1].showing = false
			end
			table.insert(parsed, obj)
		end
	end
	table.sort(parsed, p._sortFunc)
	
	return p._main(parsed)
end

p._main = function(args)
	local outer_div = mw.html.create('div')
	outer_div:addClass('rsw-synced-switch')
	for i,v in ipairs(args) do
		local inner_div = outer_div:tag('div')
		inner_div	:addClass('rsw-synced-switch-item')
					:attr({
						['data-item'] = v.id,
						['data-item-text'] = v.text
					})
					:wikitext(v.content)
		if v.showing then
			inner_div:addClass('showing')
		end
	end
	return outer_div
end

return p