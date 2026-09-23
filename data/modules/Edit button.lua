-- {{Helper module|name=Edit button|fname1=(text)|ftype1=string|fuse1=Creates an edit button for the current page that the module is invoked on<br><br><code>text</code> defaults to "edit"}}
-- Creates a link that opens the editor screen for whatever page this module is invoked on
 
return function(text, page)
	local page_title = page or mw.title.getCurrentTitle().fullText
	local url = tostring(mw.uri.fullUrl(page_title,'action=edit'))
	return '['..url..' '..(text or 'edit')..']'
end