local p = {}

function p.main(frame)
	local args = frame:getParent().args
	local bucket_name = mw.text.trim(args[1] or '')
	local select_field = mw.text.trim(args[2] or '')
	
	local b = bucket(bucket_name)
		.select(select_field)
		.limit(1)
	
	for k, v in pairs(args) do
		if k ~= 1 and k ~= 2 then
			b.where(k, v)
		end
	end
	
	local data = b.run()
	
	if data[1] and data[1][select_field] then
		data = data[1][select_field]
		
		if type(data) == 'table' then
			data = data[1]
		end
		
		return data
	end
	
	mw.log(string.format("BucketShow did not find the requested value. %s.%s", bucket_name, select_field))
end

return p