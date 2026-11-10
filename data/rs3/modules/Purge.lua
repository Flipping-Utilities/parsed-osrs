-- <nowiki>
-- Implements Template:Purge
--

local p = {}

function p._purge(anchor, text, tag, noinplace)
	if type( anchor ) == 'table' then -- Allow function to be called with named argruments
		text = anchor.text
		tag = anchor.tag
		noinplace = anchor.noinplace
		anchor = anchor.anchor
	end
	local page_title = mw.title.getCurrentTitle().fullText
	local link = string.format('[%s#%s %s]',tostring(mw.uri.fullUrl(page_title,'action=purge')),anchor or 'res', text or '(wrong?)')
	link = string.format('<%s class="plainlinks%s" id="res" title="If this information seems incorrect, click here to force an update.">%s</%s>', 
		tag or 'sup', (noinplace and '') or ' jsPurgeLink', link, tag or 'sup')
	return link
end

function p.purge(frame)
	return p._purge(frame:getParent().args.anchor)
end

return p