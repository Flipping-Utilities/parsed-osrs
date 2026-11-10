local p = {}
local hc = require('Module:Paramtest').has_content
local yn = require('Module:Yesno')
local _version_separator_ = '¦'

p._sortFunc = function(a,b)
	return a.id < b.id
end

p.main = function(frame)
	local args = frame:getParent().args
	local parsed = { {id=0, switch_id=0, content=args.default or '', showing = true} }
	local buttons = yn(args.buttons, false)
	parsed[1].nodefault = yn(args.nodefault, false)
	
	if buttons then
		if hc(args.defbutton) then
			parsed[1].button = args.defbutton
		else
			parsed[1].button = 'Other'
		end
	end
	
	for k,v in pairs(args) do
		local s = tostring(k):match('version(%d+)')
		if hc(v) and s then
			local btext, text = ''
			if hc(args['text'..s]) then
				btext = mw.text.trim(args['text'..s])
				text = string.gsub(btext, '%s', '_')
				if not string.find(text, '#') then
					text = '#'..text
				end
			end
			local obj = {id=tonumber(s),
						switch_id=(args['switch_id'..s] or s),
						text=text,
						content=v}
			if obj.id == 1 then
				obj.showing = true
				parsed[1].showing = false
			end
			if buttons then
				obj.button = btext
			end
			
			local vers = mw.text.split(btext, _version_separator_)
			if vers and #vers > 0 then
				local i, versC = -1, {}
				for _,k in ipairs(vers) do
					local vtext = mw.text.trim(k)
					if #vtext > 0 then
						vtext = string.gsub(vtext, '%s', '_')
						if not string.find(vtext, '#') then
							vtext = '#'..vtext
						end
					else
						vtext = nil
					end
					if i == -1 then
						obj.text = vtext
						if buttons then
							obj.button = mw.text.trim(k)
						end
					else
						table.insert(versC, vtext)
					end
					
					i = i + 1
				end
				obj.versions = versC
			end
			
			if buttons and args['button'..s] and #args['button'..s] > 0 then
				obj.button = args['button'..s]
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
	local buttons_div
	if args[1].button then
		outer_div:addClass('has-buttons')
		buttons_div = outer_div:tag('div')
		buttons_div :addClass('synced-buttons')
	end
	if args[1].nodefault then
		outer_div:attr('data-nodefault','')
	end
	for i,v in ipairs(args) do
		local inner_div = outer_div:tag('div')
		inner_div	:addClass('rsw-synced-switch-item')
					:attr({
						['data-item'] = v.switch_id,
						['data-item-text'] = v.text
					})
					:wikitext(v.content)
		if v.showing then
			inner_div:addClass('showing')
		end
		if v.versions and #v.versions > 0 then
			inner_div:attr('data-item-vers', table.concat(v.versions)..'#')
		end
		if v.button then
			local button = buttons_div:tag('span')
			button	:addClass('button')
					:attr({
						['data-item'] = v.switch_id,
						['data-item-text'] = v.text
					})
					:wikitext(v.button)
			if v.showing then
				button:addClass('button-selected')
			end
			if v.id == 0 then
				button:addClass('default-button')
			end
			if v.versions and #v.versions > 0 then
				button:attr('data-item-vers', table.concat(v.versions)..'#')
			end
		end
	end
	return outer_div
end

return p