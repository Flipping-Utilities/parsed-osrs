local p = {}

function p._main(args)
	local ret = {}
	for i, v in ipairs(args) do
		v = mw.text.trim(v)
		-- Compatibility: Ignore arguments that only contain an apostrophe
		if v ~= '' and v ~= "'" then
			if ret[#ret]
				and not (ret[#ret]:find('_') or ret[#ret]:find('%-%)?$'))
				and not (v:find('_') or v:find('^%(?%-'))
			then
				table.insert(ret, '-')
			end
			if v:find('^[%u%(%)]+$') then
				v = '<span style="font-size:90%">' .. v .. '</span>'
			end
			table.insert(ret, v)
		end
	end
	ret = '<i title="English pronunciation respelling">' ..
		table.concat(ret):gsub('_', ' ')
			 -- Avoid dangling hyphens
			:gsub(' %-', ' -&#8288;')
			:gsub('^%-', '-&#8288;')
		.. '</i>'
	return ret
end

function p.main(frame)
	return p._main(frame:getParent().args)
end

return p