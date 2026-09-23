-- <nowiki>
-- Implements Template:Purge
--

local p = {}

function p._purge(anchor, text, tag, noinplace)
	local page_title = mw.title.getCurrentTitle().fullText
	local link = string.format('[%s#%s %s]',tostring(mw.uri.fullUrl(page_title,'action=purge')),anchor or 'res', text or '(wrong?)')
	link = string.format('<%s class="plainlinks%s" id="res" title="If this information seems incorrect, click here to force an update.">%s</%s>', 
		tag or 'small', (noinplace and '') or ' jsPurgeLink', link, tag or 'small')
	return link
end

function p.purge(frame)
	return p._purge(frame:getParent().args.anchor)
end

return p