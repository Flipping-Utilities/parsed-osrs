require('strict')
local pt = require('Module:Paramtest')
local yn = require('Module:Yesno')
local p = {}
p.yn=yn

-- Namespaces that should add categories and save data to Bucket
local enabled_namespaces = {
	['Talk'] = true,
	['Calculator_talk'] = true,
	['Guide_talk'] = true,
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
	['pvm']='pvm',
	['ironman']='ironman',
	['league']='leagues',
	['leagues']='leagues',
	none='none'
}
-- category key: details
local category_info = {
	beginner = {
		full='Actioning this feedback is beginner editor friendly',
		image='[[File:Stagger icon.png|20x20px|link=]]',
		bgcolor='var(--droptable-common-background)',
		txtcolor='var(--droptable-common-text-color)'
	},
	game = {
		full='Game knowledge/research needed to action this feedback',
		image='[[File:RS news icon.png|20x20px|link=]]',
		bgcolor='var(--droptable-uncommon-background)',
		txtcolor='var(--droptable-uncommon-text-color)'
	},
	wiki = {
		full='Wiki knowledge needed to action this feedback',
		image='[[File:RSW news icon.png|20x20px|link=]]',
		bgcolor='var(--droptable-always-background)',
		txtcolor='var(--droptable-always-text-color)'
	},
	pvm = {
		full='PvM knowledge needed to action this feedback'
	},
	leagues = {
		full='Leagues knowledge needed to action this feedback'
	},
	ironman = {
		full='Ironman knowledge needed to action this feedback'
	},
	none = {
		full='No categories set for this feedback',
		image='[[File:Information icon-grey.svg|20x20px|link=]]',
		bgcolor='var(--droptable-unknown-background)',
		txtcolor='var(--droptable-unknown-text-color)'
	}
}
-- order to put icons in
local category_order = {'beginner', 'game', 'pvm', 'ironman', 'leagues', 'wiki', 'none'}

function p.main(frame)
	return p._main(frame:getParent().args)
end

function p._main(args)
	local namespace = mw.title.getCurrentTitle().nsText
	local username
	if pt.has_content(args.user) then
		username = args.user
	end
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
	outDiv:tag('div')
		:addClass('gloop-feedback-comment')
		:wikitext(comment)
	outDiv:newline():newline()
		:tag('span')
		:css({
			['font-size'] = '0.9em'
		})
		:wikitext('—Submitted ' .. (username and ('by ' .. username) or '') .. ' via [[RuneScape:Article feedback|Article feedback]]')
	
	local headerDiv = outDiv:tag('div')
	headerDiv:addClass('gloop-feedback-header')
	
	local toggleDiv = headerDiv:tag('div')
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
		local catDiv = headerDiv:tag('div')
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
	if pt.has_content(args.show) then
		if string.lower(args.show) == 'resolved' then
			b.where('resolved', true)
		else
			b.where('resolved', false)
		end
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
				tr:tag('td'):wikitext('[[File:Yes check.svg|15px|link=|Resolved]]')
			else
				tr:tag('td'):wikitext('[[File:X mark.svg|15px|link=|Unresolved]]')
			end
		end
		tr:tag('td'):wikitext(fbcat)
	end
	return tostring(outT)
end

return p