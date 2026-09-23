-- <pre>
local hat = require('Module:Hatnote')._hatnote
local p = {}

local remove_templates = {
	'transcript',
	'fromgame',
	'god letter',
	'incomplete',
	'inuse',
	'construction',
	'lore',
	'postbag',
	'transcript list'
}

local ignore_templates = {
	'!',
	'*',
	'anchortext',
	'clear',
	'color',
	'colour',
	'kg',
	'nbsp',
	'qact',
	'quote',
	'mes',
	'sic',
	'titleanchor'
}

local headerSize = {
	['=='] = 1.25,
	['==='] = 1.2,
	['===='] = 1,
	['====='] = 0.95,
	['======'] = 0.9
}

function p.main(frame)
	local args = frame:getParent().args
	local ret = {}

	-- for handling multiple transcript transclusions on single page
	for _, v in ipairs(args) do
		table.insert(ret, p._main(v))
	end

	-- default
	if #ret == 0 then
		ret = {p._main(mw.title.getCurrentTitle().text)}
	end

	return frame:preprocess(table.concat(ret, '\n'))
end

function p._main(title)
	local ret = mw.html.create('div')

	if title == nil then
		ret:wikitext(hat(string.format(
				'[[Transcript:%s]] does not exist. Please create this page or correct this query.',
				title
			)))
		return tostring(ret)
        end

	local _t = mw.title.new('Transcript:' .. title)

	if not _t.exists then
		ret:wikitext(hat(string.format(
				'[[Transcript:%s]] does not exist. Please create this page or correct this query.',
				title
				)))
		return tostring(ret)
	end

	local _tsplit = mw.text.split(_t:getContent(),'\n')

	
	ret:wikitext(hat(string.format(
			'The following text is transcluded from [[Transcript:%s]].',
			title
			), {extraclasses = 'transcript-hatnote'}))

	local txt = ret:tag('div')
			:addClass('transcript')

	for _, _v in ipairs(_tsplit) do
		local v = _v:lower()

		local lineToAdd = _v

		local addLine = true
		-- look for lines that are a single template
		if v:find('^{{.*}}$') then
			-- filter template name
			local t_name = v:gsub('template:',''):match('{{(.-)[|}]')

			-- check the kill list
			for _, w in ipairs(remove_templates) do
				if w == t_name then
					addLine = false
					break
				end
			end

			-- other templates
			-- we'll see later
		end

		-- formatting for headers changes
		if addLine then
			local headingtype, headingtitle = _v:match('(=+)(.-)(=+)')

			if headingtype and headingtitle and headerSize[headingtype] then
				addLine = false
				txt	:tag('div')
						:css({ ['font-size'] = headerSize[headingtype] .. 'em', ['font-weight'] = 'bold', ['padding-top'] = '0.5em' })
						:wikitext(headingtitle)
					:done()
					:tag('hr')
					:done()
			end

			-- remove category transclusion
			lineToAdd = lineToAdd:gsub('%[%[[Cc]ategory:.-%]%]','')
						-- remove default sorting
						:gsub('{{DEFAULTSORT.+}}','')
		end

		if addLine then
			txt:newline()
			txt:wikitext(lineToAdd)
		end

	end

	return tostring(ret)
end

return p