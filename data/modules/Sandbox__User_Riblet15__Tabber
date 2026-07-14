local p = {}

-- Access point for other modules
-- argument format: {{"tab 1 label", "tab 1 content"}, {"tab 2 label", "tab 2 content"}, {"etc", "..."}}
function p.tabber(tabs)
	preprocess = preprocess == nil and true or preprocess -- if no preprocess defined, set to true
	local tabber = ""
	for i, tab in ipairs(tabs) do
		if i > 1 then
			tabber = tabber .. "|-|"
		end
		tabber = tabber .. mw.text.trim(tab[1]) .. '=' .. tab[2]
	end
	return mw.getCurrentFrame():callParserFunction( '#tag', { 'tabber', tabber } )
end

-- [[Template:Tabber]]
function p.main(frame)
	local args = frame:getParent().args
	local i = 1
	local tabs = {}
	while args['tab'..tostring(i)] do
		local tab = 'tab'..tostring(i)
		table.insert(tabs, { args[tab], args[tab..'content'] or ''})
		i = i+1
	end
	return p.tabber(tabs)
end

return p