-- <pre>
local p = {}

function p.main(frame)
	local args = frame:getParent().args

	-- return tag
	local ret = mw.html.create('div')
				:addClass('seealso')

	local params = {}
	local ttl = 0

	-- collect and count arguments
	for _, v in ipairs(args) do
		ttl = ttl + 1
		table.insert(params,v)
	end

	-- main return text
	ret:wikitext('This transcript mentions the following: ')

	-- for all arguments
	for i, v in ipairs(params) do
		-- add links
		if i < ttl and ttl > 1 then
			ret:wikitext('[['..v..']]')
		-- if last link
		elseif i == ttl then
			-- if only link
			if ttl == 1 then
				ret:wikitext('[['..v..']]')
			-- if final link
			else
				ret:wikitext(' and [['..v..']]')
			end
		end

		-- if more to come, add commas
		if i < ttl and ttl > 2 then
			ret:wikitext(', ')
		end
	end

	-- period
	ret:wikitext('.')
	
	-- transcript property
	if mw.title.getCurrentTitle().namespace == 120 then
		npcs = {}
		for _, v in ipairs(params) do
			table.insert(npcs,string.match(v, "[^%|]+"))
		end
		bucket("transcript").put({npcs=npcs, is_dialogue = false})
	end

	return ret
end

function p.mentionedin(frame)
	local args = frame:getParent().args
	local pagename = mw.title.getCurrentTitle().fullText
	local type = string.lower(args[1] or '')
	local link = args[2] or 'Transcript:'..pagename
	local name = args[1] or pagename
	
	local out = mw.html.create()
		:wikitext('<div class="seealso"><small><center>This list is compiled as a part of an ongoing project and may be incomplete.</center></small></div>')
	
	local bucket_data = bucket('transcript')
		.select('page_name')
		.where('npcs', name)
		.where('is_dialogue', false)
		.where(bucket.Not('page_name', 'Transcript:'..pagename)) --Filter out your own transcript page
		.run()
	
	-- Display a list of pages
	if #bucket_data > 0 then
		local list = out:tag('div')
			:addClass('mw-collapsible messagebox speaksin')
			:tag('div')
				:addClass('speaksin-title')
				:wikitext("Transcripts " .. name .." is mentioned in:")
			:done()
			:tag('div')
				:addClass('speaksin-list')
				:tag('ul')
		
		for _,p in pairs(bucket_data) do
			local page = p.page_name:match('[^:]:(.+)')
			list:wikitext("<li>[["..p.page_name..'|'..page..']]</li>')	
		end
	else
		return 	mw.html.create()
		:tag('div')
		:addClass('messagebox speaksin')
		:cssText('border-left:none; padding: 0 10px;')
		:attr('align','center')
		:wikitext(name .. " is not mentioned in any dialogues currently transcribed on the wiki.")
	end
		
	return out:allDone()
end

return p