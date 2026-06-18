local p = {}

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end
	

function p._main(args)
	local contents = {}

	local i = 1
	while args['item'..i] do
		table.insert(contents, { text = args['text'..i] or ('Item '..i),
					content = '\n' .. args['item'..i] })
		i = i + 1
	end
	
	local ret = mw.html.create('div')
			:addClass('switch-infobox')
			:addClass('loading')
			:tag('span')
				:addClass('loading-button')
				:addClass('button')
				:addClass('navigation-not-searchable')
				:wikitext('Loading...')
			:done()
	
	local mah_triggers = ret:tag('div')
				:addClass('switch-infobox-triggers')
				:addClass('navigation-not-searchable')

	local float = {}
	if args.float ~= nil then
		float = args.float
		ret:css('float',float)
		:done()
		mah_triggers:css('justify-content', 'center')
		:done()
	end

	for i, v in ipairs(contents) do
		mah_triggers:tag('span')
					:addClass('trigger')
					:addClass('button')
					:attr('data-id',i)
					:wikitext(v.text)
				:done()

		ret	:tag('div')
				:addClass('item')
				:addClass(i==1 and 'showing' or '')
				:attr('data-id',i)
				:wikitext(v.content)
			:done()
	end

	return mw.getCurrentFrame():preprocess(tostring(ret))
end

return p