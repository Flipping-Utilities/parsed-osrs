--[[
{{Helper module|name=Mainonly
|fname1=_main(arg)
|ftype1=Any value
|fuse1=If the module is invoked in the content namespace, it will return arg, otherwise, it will return an empty string
|fname2=on_main()
|ftype2=N/A
|fuse2=Returns true if invoked in the content namespace, otherwise false
}}
--]]
--
-- Module to return text only when invoked in the content namespace
--

local p = {}

function p.main(frame)
	local ret = frame:getParent().args[1] or ''
	return p._main(ret)
end

function p._main(text)
	if mw.title.getCurrentTitle().namespace == 0 then
		return text
	else
		return ''
	end
end

--
-- Boolean for whether or not the page is in the mainspace
-- Sometimes it might be better to just check first
-- Rather than spend processing time on something that won't be used
function p.on_main()
	return mw.title.getCurrentTitle().namespace == 0
end

return p