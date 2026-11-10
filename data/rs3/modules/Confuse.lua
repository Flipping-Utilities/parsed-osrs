-- <pre>
local p = {}

function p.main(frame)
	local hat = require('Module:Hatnote')
	local args = frame:getParent().args

	-- no tag; added by Module:Hatnote
	local ret = mw.html.create('')

	local params = {}
	local ttl = 0

	-- collect and count arguments
	for _, v in ipairs(args) do
		ttl = ttl + 1
		table.insert(params,v)
	end

	-- main return text
	ret:wikitext('Not to be confused with ')

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
				ret:wikitext(' or [['..v..']]')
			end
		end

		-- if more to come, add commas
		if i < ttl and ttl > 2 then
			ret:wikitext(', ')
		end
	end

	-- period
	ret:wikitext('.')

	return hat._hatnote(tostring(ret))
end

return p