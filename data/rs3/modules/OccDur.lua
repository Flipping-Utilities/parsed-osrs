local p = {}

function p.invoke_main(frame)
	local args = frame:getParent().args
	return p.main(args)
end

function p.main(args)
	if args[1] == nil then
		return '<div class="noprint seealso">No argument has been specified for [[Template:OccDur]].</div>'
	end
	local MAX_PARAMS = 7
	local text = '<div class="noprint seealso">The following takes place during '
	for i,v in ipairs(args) do
		if ( i > MAX_PARAMS ) then
			break
		end
		local link = '[[' .. v .. ']]'
		-- if the next two parameters exist, use a comma as separator
		-- if only one more paramater exists, use "and"
		if args[i+2] then
			link = link .. ', '
		elseif args[i+1] then
			link = link .. ' and '
		end
		text = text .. link
	end
	text = text .. '.\'\''
	if args[MAX_PARAMS+1] then
		text = text .. '&#32; (too many parameters in [[Template:OccDur]].)'
	end
	text = text .. '</div>'
	
	return text
end

return p