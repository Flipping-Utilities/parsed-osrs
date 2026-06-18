-- <pre>
local p = {}

function p.main(frame)
	local hat = require('Module:Hatnote')
	local args = frame:getParent().args
	local ret = mw.html.create('')

	-- list of all articles
	local params = {}
	-- total arguments counted counted
	local ttl = 0
	for _, v in ipairs(args) do
		ttl = ttl + 1
		table.insert(params,v)
	end

	-- main return string
	ret:wikitext('Main article'..(#params > 1 and 's' or '')..': ')

	-- helper function
	local function link(article)
		article = string.gsub(article,'_',' ')
		article = mw.text.trim(article)
		-- replace anchors with section symbol
		if article:find('#',1,true) then
			local article_t = mw.text.split(article,'#')
			article_t = table.concat(article_t,' § ')
			-- article|alttext
			article = article..'|'..article_t
		end
		-- link article
		return '[['..article..']]'
	end

	-- additional articles
	for i, v in ipairs(params) do
		-- add article link
		if i < ttl and ttl > 1 then
			ret:wikitext(link(v))
		-- if last argument
		elseif i == ttl then
			-- only one argument, just add link
			if ttl == 1 then
				ret:wikitext(link(v))
			-- otherwise finish with "and"
			else
				ret:wikitext(' and '..link(v))
			end
		end

		-- if more to come, add commas
		if i < ttl and ttl > 2 then
			ret:wikitext(', ')
		end
	end

	-- return finished string
	return hat._hatnote(tostring(ret))
end

return p