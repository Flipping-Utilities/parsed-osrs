local p = {}
 
local yn = require('Module:Yesno')
local hc = require('Module:Paramtest').has_content
 
 
-- module access point for div
p._div = function(args)
	local name = args.name
	if not hc(name) then
		error('Name is required!')
	end
 
	local content = args.content
	local hasarrow = yn(args.arrow or 'yes', true)
	local arrowsize = tonumber(args.arrowsize) or 10
	local limitwidthbool = yn(args.limitwidth or 'yes', true)
	local style = hc(args.style) and args.style or nil
 
	local tagname = yn(args.inline or 'no', false) and 'span' or 'div' -- let it use spans for inline use
	local div = mw.html.create(tagname)
 
	local arrow = 'no'
	if hasarrow then
		arrow = 'yes'
	end
 
	local limitwidth = 'no'
	if limitwidthbool then
		limitwidth = 'yes'
	end
 
	local attrs = {
		['data-tooltip-for'] = name,
		['data-tooltip-arrow'] = arrow,
		['data-tooltip-arrow-size'] = arrowsize,
		['data-tooltip-limit-width'] = limitwidth,
	}
	
	div	:addClass('hidden js-tooltip-wrapper')
		:cssText(style)
		:css('display', 'none')
		:attr(attrs)
		:tag(tagname)
			:addClass('js-tooltip-text')
			:wikitext(content)
			:done()
		:done()
 
	return div
end
 
p._span = function(args)
	local name = args.name or args[1] or nil
	if not hc(name) then
		error('Name is required!')
	end
	local alt = args.alt or args[2] or '?'
	-- Keep the trigger visible without JS (for triggers that wrap real content)
	local visible = yn(args.visible or 'no', false)

	local span = mw.html.create('span')
	span:addClass('js-tooltip-click')
		:attr('data-tooltip-name', name)
		:wikitext(alt)

	if not visible then
		span:addClass('hidden')
			:css('display', 'none')
	end

	return span
end
 
-- template access points
p.div = function(frame)
	return p._div(frame:getParent().args)
end
p.span = function(frame)
	return p._span(frame:getParent().args)
end

return p