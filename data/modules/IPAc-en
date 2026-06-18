-- This module implements [[Template:IPAc-en]].

local data = mw.loadData('Module:IPAc-en/data')
local p = {}

-- Global container for tracking categories
-- local categoryHandler = require('Module:Category handler').main
-- local categories = {}

-- Trims whitespace from a string
local function trim(s)
	return s:match('^%s*(.-)%s*$')
end

local function makeNowrapSpan(s)
	local span = mw.html.create('span')
		:addClass('rt-commentedText') -- Works with [[MediaWiki:Gadget-ReferenceTooltips.js]]
		:addClass('nowrap')
		:wikitext(s)
	return tostring(span)
end

local function makePronunciationText(id)
	id = id and string.lower(trim(id))
	if id and id ~= '' and data.pronunciation[id] then
		return data.pronunciation[id].text
	end
end

-- This adds a tooltip icon to a label.
local function makeTooltip(label, tooltip)
	local span = mw.html.create('span')
		:attr('title', tooltip)
		:wikitext(label)
	return tostring(span)
end

local function formatPhonemeGroup(phonemes)
	if #phonemes > 0 then
		local span = mw.html.create('span')
			:css('border-bottom', '1px dotted')
			:wikitext(table.concat(phonemes))
		return tostring(span)
	else
		return ''
	end
end
--[==[ don't need
local function renderCategories()
	local ret = ''
	
	if categoryHandler { true } then
		ret = {}
		for cat in pairs(categories) do
			table.insert(ret, string.format('[[Category:%s]]', cat))
		end
		table.sort(ret)
		ret = table.concat(ret)
	else
		ret = ''
	end
	return ret
end
]==]--
function p._main(args)
	local ret = {}
	local i = 0 -- Keeps track of numbered args

	-- Pronunciation
	do
		local pron = {}
		while true do
			i = i + 1
			local pronItem = makePronunciationText(args[i])
			if pronItem then
				pron[#pron + 1] = pronItem
				pron[#pron + 1] = ' '
			else
				break
			end
		end
		if #pron > 0 then
			local strtbl = table.concat(pron)
			local pronformat = string.find( strtbl, 'Jagex') and '%s' or '<small>%s</small>'
			ret[#ret + 1] = string.format(
				pronformat,
				strtbl
			)
		end
	end

	-- Phonemes
	do
		-- Loop through the numbered args, separating them into phoneme groups
		-- and separator strings (both called "words" for convenience). We only
		-- underline the phoneme groups, not the separators.
		local words = {}
		words[#words + 1] = '/' -- Opening slash
		i = i - 1 -- Set up i again as it was changed in the pronunciation loop
		local id
		repeat
			local phonemes = {}
			local isWordEnd = false
			while not isWordEnd do
				i = i + 1
				id = args[i]
				id = id and trim(id)
				if not id then
					isWordEnd = true
					words[#words + 1] = formatPhonemeGroup(phonemes)
				elseif id ~= '' then
					local t = data.phonemes[id]
					if not t then
						-- We were passed an invalid id.
						isWordEnd = true
					--	categories["Ill-formatted IPAc-en transclusions"] = true
						words[#words + 1] = formatPhonemeGroup(phonemes)
						words[#words + 1] = makeTooltip(
							string.format(
								"<strong class=\"error\">[invalid input: '%s']</strong>",
								id
								),
							'Unrecognized symbol'
						)
					elseif not t.label then
						-- The data module contains bad data, so throw an error.
						error(string.format(
							"no label was found for id '%s'",
							tostring(id)
						))
					elseif t.tooltip then
						-- We are dealing with a regular phoneme.
						phonemes[#phonemes + 1] = makeTooltip(
							t.label,
							t.tooltip
						)
					else
						-- We are dealing with a separator.
						isWordEnd = true
						words[#words + 1] = formatPhonemeGroup(phonemes)
						words[#words + 1] = t.label						
					end
				end
			end
		until not id
		words[#words + 1] = '/' -- Closing slash

		-- Wrap the words in a link to IPA help.
		local span = mw.html.create('span')
			-- Suppress Navigation popups and Page Previews (aka Hovercards)
			:addClass('IPA nopopups noexcerpt')
			:attr('lang', 'en-fonipa')
			:wikitext(string.format(
				'[[wikipedia:Help:IPA/English|%s]]',
				table.concat(words)
			))
		
		ret[#ret + 1] = tostring(span)
	end
	
	-- Audio link
	do
		local file = args.audio and trim(args.audio)
		if file and file ~= '' then
		--	categories["Pages including recorded pronunciations"] = true
			ret[#ret + 1] = '&#32;'
			local span = mw.html.create('span')
				:addClass('nowrap')
				:css('font-size', '85%')
				:wikitext(string.format(
					'(%s)',
					mw.getCurrentFrame():expandTemplate{
					title = 'Template:Inline audio', args = { file, 'listen', help = 'no' } }
				))
			ret[#ret + 1] = tostring(span)
		end
	end
	
	-- Nowrap and categories
	ret = makeNowrapSpan(table.concat(ret)) -- .. renderCategories()

	-- Reset the categories table in case we are run again.
	categories = {}

	return ret
end

function p.main(frame)
	return p._main(frame:getParent().args)
end

return p