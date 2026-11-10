--<nowiki>

-- IMPORTS
local pt = require('Module:Paramtest')
local hc = pt.has_content
local dt = pt.default_to
local top_icons -- [[Module:Top icons]]
local contains -- [[Module:Array]]
local ordinal -- [[Module:Ordinal]]
local pagesWithCats = require('Module:PageListTools').pageswithcatsdpl

-- exposed table
local p = {}

--[=[
--  
-- HELPER TABLES AND FUNCTIONS
-- 
--]=]

-- replacement before calling encode
-- as lua patterns
local repl_before = {
	['%('] = '',
	['%)'] = '',
	['%!'] = '',
}

-- replacements after calling encode
-- as lua patterns
local repl_after = {
	['%+'] = '-',
	['%%2C'] = '',
	['%%2F'] = '',
	['%%3F'] = '',
	['%%26%%2338%%3B'] = '',
	['%%E2%%80%%93'] = '',
	['%.'] = '',
	['%%26quot%%3B'] = '',
	['%%E2%%80%%99'] = '',
	['%%26%%2339%%3B'] = '',
	['%%C3%%B6'] = 'o',
	['%%3A'] = '',
}

-- converting month names to hex for sortkeys
local hexmonthconv = {
	January = '1',
	February = '2',
	March = '3',
	April = '4',
	May = '5',
	June = '6',
	July = '7',
	August = '8',
	September = '9',
	October = 'A',
	November = 'B',
	December = 'C',
}

-- used by datePage func
local monthNumbers = {
	January = 1,
	February = 2,
	March = 3,
	April = 4,
	May = 5,
	June = 6,
	July = 7,
	August = 8,
	September = 9,
	October = 10,
	November = 11,
	December = 12
}

-- used by year func
local monthNames = {
	[1] = 'January',
	[2] = 'February',
	[3] = 'March',
	[4] = 'April',
	[5] = 'May',
	[6] = 'June',
	[7] = 'July',
	[8] = 'August',
	[9] = 'September',
	[10] = 'October',
	[11] = 'November',
	[12] = 'December'
}

local patchNotesType = 'Patch Notes'

-- category mapping: {category name, type for use on date pages (eg [[28 November]])
local category_info = {
	bts = {'Behind the Scenes updates', 'Behind the Scenes'},
	community = {'Community updates', 'Community'},
	devblog = {'Developer Blogs', 'Developer Blog'},
	event = {'Event updates', 'Event update'},
	game = {'Game updates', 'Game update'},
	future = {'Future Updates', 'Future update'},
	mobile = {'Mobile updates', 'Mobile update'},
	shop = {'Shop updates', 'Shop update'},
	support = {'Support updates', 'Support'},
	technical = {'Technical updates', 'Technical'},
	website = {'Website updates', 'Website update'},
	yourfeedback = {'Your Feedback updates', 'Your Feedback'},
	forum = {'Forum post updates', 'Forum post'},
	competitions = {'Competition updates', 'Competitions'},
	['#default'] = {'Missing update category', ''},
}
-- input mapping: accepted inputs -> keys for above table
local cat_switch = {
	bts = 'bts',
	['behind the scenes'] = 'bts',
	comm = 'community',
	community = 'community',
	dev = 'devblog',
	blog = 'devblog',
	['dev blog'] = 'devblog',
	devblog = 'devblog',
	['dev blogs'] = 'devblog',
	['developer blogs'] = 'devblog',
	event = 'event',
	events = 'event',
	game = 'game',
	feedback= 'yourfeedback',
	forum = 'forum',
	['forum post'] = 'forum',
	future = 'future',
	mobile = 'mobile',
	shop = 'shop',
	cs = 'support',
	competition = 'competitions',
	competitions = 'competitions',
	customer = 'support',
	['customer support'] = 'support',
	support = 'support',
	tech = 'technical',
	technical = 'technical',
	th = 'th',
	site = 'website',
	ws = 'website',
	website = 'website',
	yourfeedback= 'yourfeedback',
	['your feedback'] = 'yourfeedback',
	['#default'] = '#default'
}

-- given a supported 'category' code, return the name of the category
function get_update_category(catarg)
	if hc(catarg) then
		catarg = string.gsub(string.lower(catarg), ' ?updates?', '')
		if cat_switch[catarg] and category_info[cat_switch[catarg]] then
			return category_info[cat_switch[catarg]][1]
		else
			return category_info[cat_switch['#default']][1]
		end
	else
		return category_info[cat_switch['#default']][1]
	end
end

-- given d,m,y, return the relevant time-based categories (with sorting)
function get_time_categories(day, month, year)
	local ret = {}
	local hexmonth, dayzero
		
	if not day or not month or not hexmonthconv[month] or not year then
		table.insert(ret, '[[Category:Missing update date]]')
	else
		dayzero = ((tonumber(day) < 10 and '0'..day) or day)
		hexmonth = hexmonthconv[month]
		-- [[Category:28 November updates]], sorted by year (eg 2015)
		table.insert(ret, string.format('[[Category:%s %s updates|%s%s%s]]', day, month, year, hexmonth, dayzero))
		
		-- [[Category:2015 updates]], sorted by monthday, months converted to hex, eg B28 (28 November)
		table.insert(ret, string.format('[[Category:%s updates|%s%s]]', year, hexmonth, dayzero))
	
		-- [[Category:Updates by date]], sorted year month day
		table.insert(ret, string.format('[[Category:Updates by date|%s%s%s]]', year, hexmonth, dayzero))
	
	end

	local external = {}
	hexmonthnr = tonumber(hexmonthconv[month], 16)
	-- Historical or OSRS updates
	if tonumber(year) < 2008 then
		table.insert(ret, '[[Category:Historical updates]]')
		table.insert(external, 'rs')
		if tonumber(year) < 2004 or (tonumber(year) == 2004 and (hexmonthnr < 3 or (hexmonthnr == 3 and tonumber(day) <= 29))) then
			table.insert(external, 'rsc')
		end
	else
		table.insert(ret, '[[Category:Old School RuneScape updates]]')
	end
	if #external then
		top_icons = require('Module:Top icons')._main
		table.insert(ret, top_icons(external))
	end
	
	return table.concat(ret)
end

-- lang for formatting date
local lang = mw.getContentLanguage()
-- current title
local title = mw.title.getCurrentTitle()

--[=[
-- 
-- TEMPLATES
-- 
--]=]

-- [[Template:Update]]
function p.update(frame)
	local a = frame:getParent().args
	
	local div = mw.html.create('div')
		:addClass('update')
		:done()
		
	local link
	local reldo = ''
	local url = a.link or a.url
	local postDateInfo
	
	if hc(url) then
		if url == 'no' then
			link = 'official news post'
		else
			link = '[' .. url .. ' official news post]'
			reldo = ' Snapshots of the web page are archived [https://reldo.runescape.wiki/snapshots.html?url=' .. mw.uri.encode(url) .. ' here].'
		end
	else
		link = string.lower(title.baseText)
		for i,v in pairs(repl_before) do
			link = string.gsub(link, i, v)
		end
		link = mw.uri.encode(link)
		for i,v in pairs(repl_after) do
			link = string.gsub(link, i, v)
		end
		
		link = 'https://secure.runescape.com/m=news/' .. link
		reldo = ' Snapshots of the web page are archived [https://reldo.runescape.wiki/snapshots.html?url=' .. link .. ' here].'
		link = string.format('[%s official news post]', link)
	end
	
	local date_link, day, month, year, timestamp
	if hc(a.date) then
		day = lang:formatDate('j', a.date)
		month = lang:formatDate('F', a.date)
		year = lang:formatDate('Y', a.date)
		timestamp = os.time({year = year, month = lang:formatDate('m', a.date), day = day})
		date_link = '[[' .. day .. ' ' .. month .. ']] [[' .. year .. ']]'
	else
		date_link = '(missing date)'
	end
	
	local day_rev, month_rev, year_rev = '', '', ''
	local timestamp_rev
	if hc(a.rev) then
		day_rev = lang:formatDate('j', a.rev)
		month_rev = lang:formatDate('F', a.rev)
		year_rev = lang:formatDate('Y', a.rev)
		timestamp_rev = os.time({year = year_rev, month = lang:formatDate('m', a.rev), day = day_rev})
		date_link = date_link .. ', and revised on ' .. string.format('[[%s %s]] [[%s]]', day_rev, month_rev, year_rev)
	end
	
	if hc(a.author) then
		date_link = date_link .. ' by ' .. a.author
	end
	
	if url == 'no' then
		postDateInfo = 'It was added on ' .. date_link .. ' but has since been removed.'
	else
		postDateInfo = 'It was added on ' .. date_link .. '.'
	end
	postDateInfo = postDateInfo .. reldo
	
	-- Determine whether message is historical (pre-osrs), osrs.
	local message = ''
	local website = ''
	
	if hc(a.time) then
		--Historical updates
		if a.time == 'historical' then
			message = ' is from before the launch of <i>Old School RuneScape</i> and is copied verbatim from the '
			website = '[https://www.runescape.com/community <i>RuneScape</i> website]'
		end
	--OSRS updates	
	else
		message = ' is copied verbatim from the '
		website = '[https://oldschool.runescape.com/ <i>Old School RuneScape</i> website]'
	end
	
	div:wikitext('This ' .. link .. message)
		:tag('span')
			:addClass('plainlinks')
			:wikitext(website)
		:done()
		:wikitext('. It is copyrighted by [[Jagex]].')
		:tag('br'):done()
		:wikitext(postDateInfo)
	:done()
	
	local div2 = ''

	if hc(a.article) then
		div2 = mw.html.create('div')
			:addClass('update-redirect')
			:addClass('tile')
			-- css was previously at common.css but now here because it was unused
			:cssText('text-align:center;font-weight:bold;font-size:2em;line-height:1.5em;padding:1em;margin-left:auto;margin-right:auto;')
			:wikitext('This is a newspost. For the wiki article, see [[' .. a.article .. ']]')
			:done()
		
		if hc(a.nuke) then
			if a.nuke == 'yes' then
				div2:addClass('nuke'):cssText('margin-bottom:20%;')
			end
		end
	end
	
	local cat = ''
	-- cats only in update namespace
	if title.namespace == 112 then
		cat = '[[Category:' .. get_update_category(a.category) .. '|' .. title.text .. ']]'
		cat = cat .. get_time_categories(day, month, year)
		
		local bucketYear, bucketMonth, bucketDay
		bucketYear = lang:formatDate('Y', a.date)
		bucketMonth = lang:formatDate('n', a.date)
		bucketDay = lang:formatDate('j', a.date)
		
		local bucketYearRev, bucketMonthRev, bucketDayRev
		if hc(a.rev) then
			bucketYearRev = lang:formatDate('Y', a.rev)
			bucketMonthRev = lang:formatDate('n', a.rev)
			bucketDayRev = lang:formatDate('j', a.rev)
		end
		
		bucket('update').put({
			date = timestamp,
			date_rev = timestamp_rev,
			type = get_update_category(a.category),
			year = bucketYear,
			month = bucketMonth,
			day = bucketDay,
			year_rev = bucketYearRev,
			month_rev = bucketMonthRev,
			day_rev = bucketDayRev
		})
	end
	
	local ret = '__NOTOC__ __NOEDITSECTION__' .. tostring(div2) .. tostring(div) .. cat
	
	return ret
end

-- [[Template:Patch Notes]] no links available as Patch Note Archive have been removed from Jagex's website
function p.patchnotes(frame)
	local a = frame:getParent().args
	
	local div = mw.html.create('div')
		:addClass('update')
		:done()
		
	local date_link, timestamp, timestamp_rev
	local day, month, year = '', '', ''
	if hc(a.date) then
		day = lang:formatDate('j', a.date)
		month = lang:formatDate('F', a.date)
		year = lang:formatDate('Y', a.date)
		timestamp = os.time({year = year, month = lang:formatDate('m', a.date), day = day})
		date_link = string.format('[[%s %s]] [[%s]]', day, month, year)
	else
		date_link = '(missing date)'
	end
	
	local day_rev, month_rev, year_rev = '', '', ''
	local timestamp_rev
	if hc(a.rev) then
		day_rev = lang:formatDate('j', a.rev)
		month_rev = lang:formatDate('F', a.rev)
		year_rev = lang:formatDate('Y', a.rev)
		timestamp_rev = os.time({year = year_rev, month = lang:formatDate('m', a.rev), day = day_rev})
		date_link = date_link .. ', and revised on ' .. string.format('[[%s %s]] [[%s]]', day_rev, month_rev, year_rev)
	end
	
	div:wikitext('These official [[Patch Notes]] are copied verbatim from the Patch Notes Archive which is no longer available. It is copyrighted by [[Jagex]].')
		:done()
		:tag('br'):done()
		:wikitext('These Patch Notes were announced on ' .. date_link .. '.')
	:done()
	
	local cat = ''
	-- cats only in update namespace
	if title.namespace == 112 then
		cat = cat .. '[[Category:Patch Notes|*' .. lang:formatDate('md', day .. ' ' .. month) .. ']]'
		cat = cat .. get_time_categories(day, month, year)

		local bucketYear, bucketMonth, bucketDay
		bucketYear = lang:formatDate('Y', a.date)
		bucketMonth = lang:formatDate('n', a.date)
		bucketDay = lang:formatDate('j', a.date)
		
		local bucketYearRev, bucketMonthRev, bucketDayRev
		if hc(a.rev) then
			bucketYearRev = lang:formatDate('Y', a.rev)
			bucketMonthRev = lang:formatDate('n', a.rev)
			bucketDayRev = lang:formatDate('j', a.rev)
		end
		
		local patchParent = hc(a.parent) and 'Update:' .. a.parent or nil
		
		bucket('update').put({
			date = timestamp,
			date_rev = timestamp_rev,
			type = patchNotesType,
			year = bucketYear,
			month = bucketMonth,
			day = bucketDay,
			year_rev = bucketYearRev,
			month_rev = bucketMonthRev,
			day_rev = bucketDayRev,
			patch_parent = patchParent
		})
	end

	local ret = frame:getParent():preprocess(string.format('{{Parentitle override|Update:Patch Notes|(%s %s %s)}}', day, month, year)) .. '__NOEDITSECTION__' .. tostring(div) .. cat .. '<div style="float:right">__TOC__</div>'
	
	return ret
end


--[=[
-- 
-- CATEGORY FORMATTERS
-- 
--]=]

-- [[Category:28 November updates]] etc
function p.date_cat(frame)
	local f = frame:getParent()
	local d
	if hc(f.args[1]) then
		d = f.args[1]
	else
		-- assumes 2016 so that leap years work
		d = string.gsub(title.text, ' ?updates?', '') .. ' 2016'
	end
	
	local ret = 'This category contains updates posted on ' .. lang:formatDate('[[j F]]', d) .. ', sorted chronologically.'
	-- cats only in category namespace
	if title.namespace == 14 then
		--updates by day, sorted by hexmonth,day: B28 (28 November)
		ret = ret .. '[[Category:Updates by day|' .. hexmonthconv[lang:formatDate('F', d)] .. lang:formatDate('d', d) .. ']]'
		--updates by month, sorted by [space]day
		ret = ret .. '[[Category:' .. lang:formatDate('F', d) .. ' updates| ' .. lang:formatDate('d', d) .. ']]'
	end
	
	return ret
end

-- [[Category:2015 updates]] etc
function p.year_cat(frame)
	local f = frame:getParent()
	local d
	if hc(f.args[1]) then
		d = f.args[1]
	else
		d = string.gsub(title.text, ' ?updates?', '')
	end
	
	local ret = 'This category contains updates posted in [[' .. d .. ']], sorted chronologically.'
	-- cats only in category namespace
	if title.namespace == 14 then
		--updates by year, sorted by [space]year
		ret = ret .. '[[Category:Updates by year| ' .. d .. ']]'
	end
	
	return ret
end


--[=[
-- 
-- [[Bucket:Update]] query + processing for {{Old School RuneScape Wiki/On this day}}
-- and date pages e.g. [[1 January]]. Invoked by {{Date page}}
-- 
--]=]
function p.datePage(frame)
	local args = frame:getParent().args
	local dateName = args[1] or mw.title.getCurrentTitle().text

	local dayNum, monthName = unpack(mw.text.split(dateName, '%s'))
	dayNum = tonumber(dayNum)
	monthNum = monthNumbers[monthName]

	if dayNum == nil or monthNum == nil then
		return '* ... Nothing interesting happened.'
	end

	local updateInfos = bucket('update')
		.select('page_name', 'type', 'year', 'day_rev', 'month_rev', 'year_rev')
		.where(bucket.Or(
			bucket.And({'day', dayNum}, {'month', monthNum}),
			bucket.And({'day_rev', dayNum}, {'month_rev', monthNum})
		))
		.run()

	if #updateInfos == 0 or #updateInfos > 100 then
		return '* ... Nothing interesting happened.'
	end
	
	table.sort(updateInfos, function(a, b)
		local yearA = (a['day_rev'] == dayNum and a['month_rev'] == monthNum) and a['year_rev'] or a['year']
		local yearB = (b['day_rev'] == dayNum and b['month_rev'] == monthNum) and b['year_rev'] or b['year']
		return yearA > yearB
	end)

	local i, updateInfo, pageYear, pageType, pageTypeClean, pageName, isRevision
	local outStrings = {}
	for i, updateInfo in ipairs(updateInfos) do
		pageName = string.gsub(updateInfo['page_name'], '^Update:', '')
		pageTypeClean = string.gsub(string.lower(updateInfo['type']), ' ?updates?', '')
		isRevision = updateInfo['day_rev'] == dayNum and updateInfo['month_rev'] == monthNum

		if pageTypeClean == string.lower(patchNotesType) then
			pageType = patchNotesType
		else
			pageType = category_info[cat_switch[pageTypeClean]][2]
		end

		if isRevision then
			pageYear = updateInfo['year_rev']
			outStrings[i] = string.format("*'''%s''' – %s: [[Update:%s|%s]] ''(revision)''", pageYear, pageType, pageName, pageName)
		else
			pageYear = updateInfo['year']
			outStrings[i] = string.format("*'''%s''' – %s: [[Update:%s|%s]]", pageYear, pageType, pageName, pageName)
		end
	end

	return table.concat(outStrings, '\n')
end


--[=[
-- 
-- YEAR DPL HANDLERS
-- 
--]=]

function p.year(frame)
	return p._year(frame:getParent().args)
end

function p._year(args)
	local year = args[1] or mw.title.getCurrentTitle().text
	local yearNum = tonumber(year)

	local data = bucket('update')
		.select('page_name', 'type', 'day', 'month', 'year', 'day_rev', 'month_rev', 'year_rev', 'patch_parent')
		.where(bucket.Or(
			{'year', yearNum},
			{'year_rev', yearNum}
		))
		.run()

	if #data == 0 then
		return '<i>No updates have been released this year so far. If you believe this is a mistake, leave a message in [[Module talk:Updates|this talk page]].</i>'
	end

	local updatesByMonth = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
		[8] = {},
		[9] = {},
		[10] = {},
		[11] = {},
		[12] = {}
	}
	
	local patch_children_lookup_by_parent = {}  -- { [parent update] = child patch }
	local patch_children = {}  -- { [child patch] = true }
	for i, update in ipairs(data) do
		if update['type'] == patchNotesType and update['patch_parent'] ~= nil then
			patch_children_lookup_by_parent[update['patch_parent']] = update['page_name']
			patch_children[update['page_name']] = true
		end
	end
	
	for i, update in ipairs(data) do
		is_patch = update['type'] == patchNotesType
		is_child_patch = is_patch and (patch_children[update['page_name']] ~= nil)
		
		-- not adding lines to the page for child patches, only standalone patches
		if not is_child_patch then
			-- One update post should produce two entries on this page
			-- when it's revised in the same year
			if update['year'] == yearNum then
				table.insert(updatesByMonth[update['month']], {
					['page_name'] = update['page_name'],
					['is_game_update'] = update['type'] == category_info['game'][1],
					['is_patch'] = is_patch,
					['is_revision'] = false,
					['day'] = update['day'],
					['linked_patch'] = patch_children_lookup_by_parent[update['page_name']]
				})
			end
			if update['year_rev'] == yearNum then
				table.insert(updatesByMonth[update['month_rev']], {
					['page_name'] = update['page_name'],
					['is_game_update'] = update['type'] == category_info['game'][1],
					['is_patch'] = is_patch,
					['is_revision'] = true,
					['day'] = update['day_rev'],
					['linked_patch'] = patch_children_lookup_by_parent[update['page_name']]
				})
			end
		end
	end
	
	ordinal = require('Module:Ordinal')._main
	
	local ret = {'<i>Note:</i> Titles in bold indicate a [[Game updates|game update]].\n'}
	
	for m = 12, 1, -1 do
		local postsThisMonth = updatesByMonth[m]
		if #postsThisMonth > 0 then
			table.sort(postsThisMonth, function(a, b)
				return a['day'] > b['day']  -- descending
			end)
			
			local monthName = monthNames[m]
			table.insert(ret, '\n==' .. monthName .. '==\n')
			
			local dayStr, postNameFull, postNameShort, postLink
			for _, post in ipairs(postsThisMonth) do
				dayStr = string.format('%d%s', post['day'], ordinal(post['day'], {nosup = true, nonum = true}))
				
				if post['is_patch'] then
					postLink = string.format('<i>[[%s|Patch Notes]]</i>', post['page_name'])
				else
					postNameFull = post['page_name']
					postNameShort = string.match(postNameFull, '^Update:(.*)')
					if post['is_game_update'] then
						postLink = string.format('<b>[[%s|%s]]</b>', postNameFull, postNameShort)
					else
						postLink = string.format('[[%s|%s]]', postNameFull, postNameShort)
					end
				end
				
				if post['is_revision'] then
					postLink = postLink .. ' <i>(revision)</i>'
				end
				
				if post['linked_patch'] ~= nil then
					postLink = postLink .. string.format(' <i>([[%s|Patch Notes]])</i>', post['linked_patch'])
				end
				
				table.insert(ret, string.format("* %s – %s\n", dayStr, postLink))
			end
		end
	end
	
	return mw.text.trim(table.concat(ret, ''))
end

--TODO
--p.updatedpl
--p.patchnotesdpl
--etc

return p