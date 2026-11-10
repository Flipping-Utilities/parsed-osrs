local p = {}
local s = '<sup class="noprint fact">&#91;<span class="fact%-text" title="The preceding quote has been reproduced verbatim and is not a transcription error%.">sic</span>&#93;</sup>'
function p.main(frame)
	local a = frame.args[1]
	return p._main(a)
end

function p._main(a)
	a = a:gsub(s, '')
	return a
end

return p