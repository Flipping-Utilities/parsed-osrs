local p = {}

function p.main(frame)
	
	local items = bucket('recipe')
		.where('Category:Item sets')
		.select('page_name','uses_material','production_output')
		.limit(5000)
		.offset(off)
		.run()

	local out = mw.html.create('table')
		:addClass('wikitable sortable')
		:tag('caption')
			:wikitext(#items..' found sets')
		:done()
		:tag('tr')
			:tag('th')
				:wikitext('page')
			:done()
			:tag('th')
				:wikitext('leftright')
			:done()
		:done()
	
	for _,item in ipairs(items) do
		local str = ''
		for i,mat in ipairs(item.uses_material) do
			str = str..'|left'..tostring(i)..'='..mat..'BRHR'
		end
		str = str..'|right1='..item.production_output[1]..'BRHR'
		out:tag('tr')
			:tag('td')
			:wikitext('[[')
				:wikitext(item.page_name)
			:wikitext(']]')
			:done()
			:tag('td')
				:wikitext(str)
			:done()
		:done()
	end
	
	return out
	
end

return p