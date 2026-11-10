local p = {}

function p.pick()
	local terms = mw.text.jsonDecode(mw.title.new('Module:RF2026/terms.json'):getContent())
	math.randomseed(os.time() + os.clock() * 1e6)
	local picked = {}
	while #picked < 20 and #terms > 0 do
		local title = mw.title.new(table.remove(terms, math.random(#terms)))
		if title and title.namespace == 0 and not title.exists then
			table.insert(picked, title.text)
		end
	end
	return mw.text.jsonEncode(picked)
end

return p