-- Removes 'File:' prefix, just in case
-- Replace {{!}} with | instead of preprocessing
-- Turn into a nice wiki file link
local p = {}
local defaultMaxSize = {
	h = 300,
	w = 300
}
p.main = function(frame)
	return p.clean(frame:getParent().args)
end

p.clean = function(args)
	local file = args.file
	if not file or (file and (file:lower() == 'no' or file == '')) then
		return nil
	end
	if not file:find('%[%[File:.-%]%]') then
		return nil
	end
	local fileRaw = file
	file = fileRaw:gsub('%[',''):gsub('%]',''):gsub('[Ff]ile:',''):gsub('{{!}}','|')
	local fileParts = mw.text.split(file, '|')
	file = fileParts[1]
	
	local filepage = mw.title.new(file, 'File')
	
	if not (filepage.exists and filepage.file.exists) then
		return nil
	end
	local aspect = filepage.file.width / filepage.file.height
	
	local maxSize = {
		h = tonumber(args.maxH) or defaultMaxSize.h,
		w = tonumber(args.maxW) or defaultMaxSize.w
	}
	local size = {
		h = filepage.file.height,
		w = filepage.file.width
	}
	
	-- iterate in reverse to preserve normal behaviour
	-- i.e. [[File:a.png|50px|100px]] will be 100px wide
	for i=#fileParts,2,-1 do
		local filePart = mw.text.trim(fileParts[i])
		if filePart:find('%d+px') then
			local mw,mh = filePart:match('^(%d+)x(%d+)px$')
			if mh and mw then
				size = {
					h = mh,
					w = mw
				}
			else
				mh = filePart:match('^x(%d+)px$')
				if mh then
					size.h = mh
				else
					mw = filePart:match('^(%d+)px$')
					if mw then
						size.w = mw
					end
				end
			end
			if size.h or size.w then
				break
			end
		end
	end
	local newSize = {}
	if size.h == nil and size.w == nil then
	end
	
	local newSize = {
		h = math.floor(math.min(filepage.file.height, maxSize.h, maxSize.w / aspect, size.h, size.w / aspect)),
		w = math.floor(math.min(filepage.file.width, maxSize.w, maxSize.h * aspect, size.w, size.h * aspect))
	}
	return {string.format('[[File:%s|%sx%spx]]', file, newSize.w, newSize.h), newSize.w, newSize.h}
end
return p