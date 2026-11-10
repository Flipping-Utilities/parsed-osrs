-- <pre>
local p = {}

function p.main(frame)
	local args = frame:getParent().args

	local ret = mw.html.create('span')
				:css('white-space','nowrap')

	local sep = args.sep or '+'
	local keys = {}
	local tblsize = 0

	for i, v in ipairs(args) do
		tblsize = i
		table.insert(keys,v)
	end

	for i, v in ipairs(keys) do
		ret	:tag('kbd')
				:addClass('keypress')
				:wikitext(v)
			:done()

		if i < tblsize then
			ret:wikitext(sep)
		end
	end

	return tostring(ret)
end

return p