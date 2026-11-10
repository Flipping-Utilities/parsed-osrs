local yesno = require("Module:Yesno")
local p = {}

function p.hastranscript(frame)
	local args = frame:getParent().args
	local pagename = mw.title.getCurrentTitle().fullText
	local type = string.lower(args[1] or '')
	local link = args[2] or 'Transcript:'..pagename
	local name = args["name"] or pagename
	local headerText = "This article has an associated transcript page.<br>'''[["..link.."|Click here]]''' for the transcript."
	
	if type == 'npc' then
		headerText = "This article on an [[non-player character]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for a transcript of possible conversations and other messaging related to this character."	
	end
	
	if type == 'familiar' then
		headerText = "This article on a [[Summoning familiars|Summoning familiar]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for a transcript of possible conversations and other messaging related to this familiar."
	end
	
	if type == 'pet' then
		headerText = "This article on a [[pet]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for a transcript of possible conversations and other messaging related to this pet."
	end
	
	if type == 'quest' then
		headerText = "This article on a [[Quests|quest]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for a transcript of possible conversations and other messaging encountered throughout the quest."
		if yesno(args.journal or 'yes') then
			headerText = headerText .. "<br>'''[["..link.."/Journal|Click here]]''' for a transcript of the quest's journal entry."
		end
	end
	
	if type == 'miniquest' then
		headerText= "This article on a [[Miniquests|miniquest]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for a transcript of possible conversations and other messaging encountered throughout the miniquest."
	end
	
	if type == 'saga' then
		headerText = "This article on a [[Fremennik Sagas|Fremennik Saga]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for a transcript of possible conversations and other messaging encountered throughout the saga."
	end
	
	if type == 'event' then
		headerText = "This article on an [[Events|event]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for a transcript of possible conversations and other messaging encountered throughout the event."
	end
	
	if type == 'item' then
		headerText = "This article on an [[Items|item]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for the transcript."
	end
	
	if type == 'tutorial' then
		headerText = "This article on a [[Tutorials|tutorial]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for the transcript."
	end
	
	if type == 'case' then
		headerText = "This article on a [[Court Cases|court case]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for a transcript of possible conversations and other messaging encountered throughout the case."
	end
	
	if type == 'voyage' then
		headerText = "This article on a [[Player-owned port#Voyages|voyage]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for the transcript of the conversations and other messaging encountered during the voyage."
	end
	
	if type == 'mystery' then
		headerText = "This article on an [[Mysteries|Archaeology mystery]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for the transcript."
	end
	
	if type == 'research' then
		headerText = "This article on [[Research|Archaeology research]] has an associated transcript page.<br>'''[["..link.."|Click here]]''' for the transcript."
	end
	
	if type == 'scenery' then
		headerText = "This article on [[scenery]] has an associated transcript page.<br>'''[["..link.."|Click here]]'''  for the messaging of possible dialogue encountered while interacting with it."
	end
	
	
	local out = mw.html.create()
		:tag('div')
		:addClass('messagebox hasdialogue standard-talk plainlinks')
		:cssText('border-left:none; padding: 2px 13px 4px 13px; width: fit-content;')
		:attr('align','center')
		:wikitext(headerText)
		:allDone()
	
	local bucket_data = bucket('transcript')
		.select('page_name')
		.where('npcs', name)
		.where('is_dialogue', true)
		.where(bucket.Not('page_name', 'Transcript:'..pagename)) --Filter out your own transcript page
		.run()
	
	-- Display a list of pages
	if #bucket_data > 0 then
		local list = out:tag('div')
			:addClass('mw-collapsible messagebox speaksin')
			:tag('div')
				:addClass('speaksin-title')
				:wikitext(name.." speaks in:")
			:done()
			:tag('div')
				:addClass('speaksin-list')
				:tag('ul')
		
		for _,p in pairs(bucket_data) do
			local page = p.page_name:match('[^:]:(.+)')
			list:wikitext("<li>[["..p.page_name..'|'..page..']]</li>')	
		end
	end
		
	return out:allDone()
end

function p.main(frame)
	local args = frame:getParent().args

	-- return tag
	local ret = mw.html.create('div')
				:addClass('seealso')

	local params = {}
	local ttl = 0
	
	-- noplayer
	local hasplayer = true

	-- collect and count arguments
	for _, v in ipairs(args) do
		if string.lower(v) == 'noplayer' then
			hasplayer = false
		elseif string.lower(v) ~= 'player' then
			ttl = ttl + 1
			table.insert(params,v)
		end
	end
	-- increase count if player
	if hasplayer then
		ttl = ttl + 1
	end

	-- main return text
	ret:wikitext('This transcript involves dialogue with ')

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
	
	-- add player
	if hasplayer then
		if ttl == 1 then
			ret:wikitext('[[Player character|the player]]')
		else
			ret:wikitext(' and [[Player character|the player]]')
		end
	end

	-- period
	ret:wikitext('.')
	
	-- transcript npcs property
	if mw.title.getCurrentTitle().namespace == 120 then
		npcs = {}
		for _, v in ipairs(params) do
			v = string.match(v, "[^%|#]+")
			v = v:gsub("^%l", string.upper)
			table.insert(npcs, v)
		end
		if hasplayer then
			table.insert(npcs,'Player character')
		end
		bucket("transcript").put{npcs = npcs, is_dialogue = true}
	end

	return ret
end

function p.worksby(frame)
	local args = frame:getParent().args
	local pagename = mw.title.getCurrentTitle().fullText
	local type = string.lower(args[1] or '')
	local link = args[2] or 'Transcript:'..pagename
	local name = args[1] or pagename
	
	local out = mw.html.create()
	
	local bucket_data = bucket('transcript')
		.select('page_name')
		.where('author', name)
		.where('is_dialogue', false)
		.where(bucket.Not('page_name', 'Transcript:'..pagename)) --Filter out your own transcript page
		.run()
	
	-- Display a list of pages
	if #bucket_data > 0 then
		local list = out:tag('div')
			:addClass('mw-collapsible messagebox speaksin')
			:tag('div')
				:addClass('speaksin-title')
				:wikitext("Transcripts " .. name .." is the author or co-author of:")
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
		:addClass('messagebox hasdialogue standard-talk plainlinks')
		:cssText('border-left:none; padding: 0 10px;')
		:attr('align','center')
		:wikitext(name .. " is not the author or co-author of any works currently transcribed on the wiki.")
	end
		
	return out:allDone()
end

function p.speaksin(frame)
	local args = frame:getParent().args
	local pagename = mw.title.getCurrentTitle().fullText
	local type = string.lower(args[1] or '')
	local link = args[2] or 'Transcript:'..pagename
	local name = args[1] or pagename
	
	local out = mw.html.create()
	
	local bucket_data = bucket('transcript')
		.select('page_name')
		.where('npcs', name)
		.where('is_dialogue', true)
		.where(bucket.Not('page_name', 'Transcript:'..pagename)) --Filter out your own transcript page
		.run()
	
	-- Display a list of pages
	if #bucket_data > 0 then
		local list = out:tag('div')
			:addClass('mw-collapsible messagebox speaksin')
			:tag('div')
				:addClass('speaksin-title')
				:wikitext("Transcripts " .. name .." speaks in:")
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
		:addClass('messagebox hasdialogue standard-talk plainlinks')
		:cssText('border-left:none; padding: 0 10px;')
		:attr('align','center')
		:wikitext(name .. " does not speak in any dialogues (currently transcribed on the wiki).")
	end
		
	return out:allDone()
end

return p