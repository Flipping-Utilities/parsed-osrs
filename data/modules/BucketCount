local p = {}

function p.main(frame)
	local args = frame:getParent().args
	local bucket_name = mw.text.trim(args[1] or '')
	local select_field = mw.text.trim(args[2] or '')
	local count = 0
	while(true) do
		local b = bucket(bucket_name).select(select_field).limit(5000).offset(count)
		for k, v in pairs(args) do
			if k ~= 1 and k ~= 2 then
				v = mw.text.decode(v) -- {{PAGENAME}} will urlencode apostrophe, so we have to undo it
				if string.sub(k, 1, 1) == '!' then
					k = string.sub(k, 2, #k)
					b.where(bucket.Not({k, v}))	
				else
					b.where(k, v)
				end
					
			end
		end

		local data = b.run()
		count = count + #data
		
		if #data < 5000 then
			return count
		end
	end
end

return p