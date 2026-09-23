local pt = require('Module:Paramtest')
local yn = require('Module:Yesno')
local p = {}
p.yn=yn

-- Namespaces that should add categories and save data to Bucket
local enabled_namespaces = {
	['Talk'] = true,
	['Calculator_talk'] = true,
	['Transcript_talk'] = true,
}

-- user input string: category key 
local allowed_categories = {
	['beginner'] = 'beginner',
	['beginner friendly'] = 'beginner',
	['game knowledge']='game',
	['wiki knowledge']='wiki',
	['wiki']='wiki',
	['game']='game',
	['technical']='wiki',
	['combat']='combat',
	['sailing']='sailing',
	none='none'
}
-- category key: details
local category_info = {
	beginner = {
		full='Actioning this feedback is beginner editor friendly',
	},
	game = {
		full='Game knowledge/research needed to action this feedback',
	},
	wiki = {
		full='Wiki knowledge needed to action this feedback',
	},
	combat = {
		full='This feedback is related to combat mechanics/strategies/equipment'
	},
	sailing = {
		full='Related to the sailing skill',
	},
	none = {
		full='No categories set for this feedback',
	}
}
-- order to put icons in
local category_order = {'beginner', 'game','wiki','combat','sailing','none'}

function p.main(frame)
	return p._main(frame:getParent().args)
end

function p._main(args)
	local namespace = mw.title.getCurrentTitle().nsText
	local isResolved = false
	if pt.has_content(args.resolved) then
		isResolved = yn(args.resolved)
	end
	local comment = pt.default_to(args.feedback, "''No comment provided''")
	local id = pt.default_to(args.id, '')
	local fbdate = nil
	if pt.has_content(args.date) then
		fbdate = args.date
	end
	local categories = {}
	local categories_as_list = {}
	if pt.has_content(args.category) then
		for cat in mw.text.gsplit(args.category, ',', true) do
			cat = string.lower(mw.text.trim(cat))
			if allowed_categories[cat] then
				if not categories[allowed_categories[cat]] then
					categories[allowed_categories[cat]]=true
					table.insert(categories_as_list,allowed_categories[cat])
				end
			end
		end
	end
	-- add none if there aren't any specified
	if #categories_as_list==0 then
	-- temp disabled - won't add the icon when no categories provided
	--	categories.none = true
	-- will still add the property
		categories_as_list[1]='none'
	end
	
	local outDiv = mw.html.create('div')
	outDiv:addClass('tile gloop-feedback-wrapper')
		:attr('id', 'gloop-feedback-scrollto-'..id)
		:attr('data-id', id)
		:css({
			['margin-bottom'] = '0.75em'
		})
	local toggleDiv = outDiv:tag('div')
	toggleDiv:css({
			['float'] = 'right',
			['padding'] = '0.25em 0.5em',
			['border-radius'] = '5px',
			['font-size'] = '0.85em',
			['font-weight'] = '800',
			['margin'] = '0 0 10px 10px'
		})
	if isResolved then
		toggleDiv:addClass('table-bg-green gloop-feedback-resolve-toggle')
			:tag('span')
				:wikitext('Resolved')
				:wikitext(enabled_namespaces[namespace] and '[[Category:Pages with resolved feedback]]' or '')
	else
		toggleDiv:addClass('table-bg-red gloop-feedback-resolve-toggle')
			:tag('span')
				:wikitext('Unresolved')
				:wikitext(enabled_namespaces[namespace] and '[[Category:Pages with unresolved feedback]]' or '')
		
		-- category icons only if not resolved
		local catDiv = outDiv:tag('div')
		catDiv:addClass('gloop-feedback-categories')
		for _,cat in ipairs(category_order) do
			if categories[cat] then
				local data = category_info[cat]
				catDiv:tag('span')
					:attr('title', data.full)
					:addClass('gloop-feedback-category gloop-feedback-category-'..cat)
					:wikitext(cat)
			end
		end
	end
	outDiv:newline():newline()
	outDiv:tag('div')
			:addClass('gloop-feedback-comment')
			:wikitext(comment)
	outDiv:newline():newline()
		:tag('span')
		:css({
			['font-size'] = '0.9em'
		})
		:wikitext('—Submitted via [[RuneScape:Article feedback|Article feedback]]')

	if enabled_namespaces[namespace] then
		bucket("feedback").put({
			resolved = yn(isResolved),
			comment = comment,
			id = id,
			category = categories_as_list,
			timestamp = fbdate
		})
	end
	
	return tostring(outDiv)
end

function p.list(frame)
	return p._list(frame:getParent().args)
end
function p._list(args)
	local b = bucket("feedback")
		.select('page_name', 'id', 'comment', 'resolved', 'timestamp', 'category')
		.orderBy('timestamp', 'DESC')
		.limit(2500)
		
	if pt.has_content(args.page) then
		b.where('page_name', args.page)
	end
	if pt.has_content(args.show) and string.lower(args.show) == 'resolved' then
		b.where('resolved', true)
	else
		b.where('resolved', false)
	end
	
	if pt.has_content(args.category) then
		local cat = mw.text.trim(string.lower(args.category))
		if allowed_categories[cat] then
			b.where('category', allowed_categories[cat])
		else
			error('Invalid category provided '..cat..'; please use one of '..table.concat(category_order, ' '))
		end
	end
	
	local data = b.run()
	if #data == 0 then
		return tostring('No feedback to display.')
	end
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
		if pt.has_content(args.show) and string.lower(args.show) == 'all' then
			header:tag('th'):wikitext('Resolved'):done()
		end
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
		if pt.has_content(args.show) and string.lower(args.show) == 'all' then
			if yn(v['resolved']) then
				tr:tag('td'):wikitext('[[File:Yes check.svg|15px|link=]]')
			else
				tr:tag('td'):wikitext('[[File:X mark.svg|15px|link=]]')
			end
		end
		tr:tag('td'):wikitext(fbcat)
	end
	return tostring(outT)
end


function p.stats()
	local results = {}
	local batchSize = 5000
	local offset = 0
	
	while true do
		local batchResults = bucket("feedback")
			.select('page_name', 'resolved')
			.offset(offset)
			.limit(batchSize)
			.run()
			
			for _, entry in ipairs(batchResults) do
				if results[entry.page_name] == nil then
					results[entry.page_name] = {page_name = entry.page_name, resolved = 0, unresolved = 0, unresolvedPerc = 0}
				end
				if entry.resolved then
					results[entry.page_name].resolved = results[entry.page_name].resolved + 1	
				else
					results[entry.page_name].unresolved = results[entry.page_name].unresolved + 1
				end
			end
			
			offset = offset + batchSize
			
			if #batchResults < batchSize then
				break;
			end
	end
	
	local outT = mw.html.create('table')
	local header = outT:addClass('wikitable sortable sticky-header align-center-2')
		:tag('tr')
			:tag('th')
				:wikitext('Page')
				:css({ ['width'] = '300px' })
				:done()
			:tag('th')
				:wikitext('Total')
				:done()
			:tag('th')
				:wikitext('Resolved')
				:done()
			:tag('th')
				:wikitext('Unresolved')
				:done()
			:tag('th')
				:wikitext('Unresolved %')
				:done()
	for i,v in pairs(results) do
		local tr = outT:newline():tag('tr')
		local talkTitle = mw.title.new(v.page_name)
		local pageTitle = talkTitle.subjectPageTitle
		local total = v.resolved + v.unresolved
		local unresolvedPerc = 100 * v.unresolved / total
		unresolvedPerc = string.format('%.2f%%', unresolvedPerc):gsub(".(00)%%", "%%")
		tr	:tag('td')
				:wikitext(string.format('[[%s]] ([[%s|talk]])',
					pageTitle.prefixedText, talkTitle.prefixedText)
				):done()
		tr:tag('td'):wikitext(total)
		tr:tag('td'):wikitext(v.resolved)
		tr:tag('td'):wikitext(v.unresolved)
		tr:tag('td'):wikitext(unresolvedPerc)
	end
	
	return tostring(outT)
end

return p