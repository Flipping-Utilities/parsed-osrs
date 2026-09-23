local p = {}

function p.main(frame)
    local b = bucket("feedback")
		.select('page_name', 'id', 'comment', 'resolved', 'timestamp', 'category')
		.orderBy('timestamp', 'DESC')
		.where('resolved', false)
		.offset(2500)
		.limit(2500)
	local data = b.run()
	local lang = mw.getContentLanguage()
	local outT = mw.html.create('table')
	local header = outT:addClass('wikitable sortable sticky-header align-center-2')
		:tag('tr')
			:tag('th')
				:wikitext('Page')
				:css({ ['width'] = '300px' })
				:done()
			:tag('th')
				:wikitext('Date')
				:css({ ['width'] = '115px' })
				:done()
			:tag('th')
				:wikitext('Feedback')
				:done()
		header:tag('th'):wikitext('Category')
	for i,v in ipairs(data) do
		local tr = outT:newline():tag('tr')
		local talkTitle = mw.title.new(v.page_name)
		local pageTitle = talkTitle.subjectPageTitle
		local fbdate = v['timestamp']
		local fbcat = table.concat(v['category'], ', ')
		local fbsort = 0
		if fbdate then
			fbsort = fbdate
			fbdate = lang:formatDate('Y-m-d', '@'..string.sub(fbdate,0,-4))
		else
			fbdate = ''
		end
		tr	:tag('td')
				:wikitext(string.format('[[%s]] ([[%s#gloop-feedback-scrollto-%s|talk]])',
					pageTitle.prefixedText, talkTitle.prefixedText, v['id'])
				):done()
			:tag('td')
				:attr('data-sort-value', fbsort):wikitext(fbdate):done()
			:tag('td')
				:wikitext(mw.text.nowiki(v['comment'])):done()
		tr:tag('td'):wikitext(fbcat)
	end
	return tostring(outT)
end

return p