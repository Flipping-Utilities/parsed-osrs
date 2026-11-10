local p = {}

function p.main(frame)
	local args = frame:getParent().args
	local bucket_name = mw.text.trim(args[1] or '')
	local sub_name = mw.text.trim(args[2] or '')
	out_args = {}
	for k, v in pairs(args) do
		if v == '' then
			out_args[k] = nil
		else
			out_args[k] = v
		end
	end
	--Clean up the args that aren't fields
	out_args[1] = nil
	out_args[2] = nil
	bucket(bucket_name).sub(sub_name).put(out_args)
end

return p