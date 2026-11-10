return {
	main = function(frame)
		local args = frame:getParent().args
		local keys = {}
		for k,v in pairs(args) do
			table.insert(keys, k)
		end
		table.sort(keys)
		local out = {}
		for i,k in ipairs(keys) do
			local k2 = string.gsub(k, '%%', '@')
			table.insert(out, k2..'='..args[k])
		end
		return '<pre>'..table.concat(out, '; ')..'</pre>'
	end
}