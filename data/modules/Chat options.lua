-- <pre>
local p = {}
 
local hasc = require('Module:Paramtest').has_content
local tooltips = require('Module:Tooltip')
 
function p.main(frame)
	local args = frame:getParent().args
	local items = {}
 
	local i = 1
	while hasc(args[i]) do
		local item = mw.text.trim(args[i])
		local key
		local tooltip
 
		if item:lower() == 'accept' then
			key = '&#x2713;'
			tooltip = '[Accept Quest]'
		elseif item:lower() == 'any' or item == '~' then
			key = '~'
			tooltip = '[Any option]'
		else -- Match first case-insensitive, alphanumeric character
			key = item:match('^[\?A-Za-z0-9#]')
			if key then
				tooltip = mw.text.trim(mw.ustring.sub(item, 2))
			end
		end
 
		table.insert(items, { key, tooltip })
		i = i + 1
	end
 
	return p.render(items)
end
 
function p.render(items)
 
	local k,t,vals,tooltip_table
	tooltip_table = mw.html.create('table') -- Create tooltip table
	local c_options_arr = {}
 
	for i,v in ipairs(items) do
		k = mw.text.trim(v[1]) -- Chat option key value
		t = mw.text.trim(v[2]) -- Chat option text
 
		---
		--- Chat options list
		---
		vals = mw.html.create('span') -- Create chat options number
		vals:wikitext(k) -- Set text to the key value
		if hasc(t) then -- If it has text to display
			vals:addClass('chat-options-underline') -- Underline it
				:attr('title', t) -- Add hover title attrib with text
		end
		table.insert(c_options_arr, tostring(vals))
 
		---
		--- Chat options tooltip
		---
		tooltip_table	:tag('tr')
							:tag('td'):wikitext('\'\'\''..k..'\'\'\''):done()
							:tag('td'):wikitext(t):done()
						:done()
	end
 
	-- Create chat options container
	local c_options_container = mw.html.create('span')
			:addClass('chat-options')
			:wikitext('(<i title="Chat options">[[File:Quick chat button.png|alt=Chat|link=]]</i> ')
			:wikitext(table.concat(c_options_arr, '&bull;')) -- Concat chat option numbers with hovers
			:wikitext(')')
	c_options_container = tostring(c_options_container)
 
	-- Create chat options tooltip
	local name = 'c_option-' .. mw.hash.hashValue('md5', c_options_container)
	local c_tooltip_button = tooltips._span({
			name = name,
			alt = '\'\'\'&hellip;\'\'\''
			})
			:css({
				['background'] = 'none',
				['border'] = 'none',
				['color'] = 'grey'
			})
	local c_tooltip_container = tooltips._div({
			name = name,
			hasarrow = true,
			limitwidth = true,
			content = tostring(tooltip_table)
			}):css('padding', '0')
	c_tooltip_button = tostring(c_tooltip_button)
	c_tooltip_container = tostring(c_tooltip_container)
 
 
	return c_options_container .. c_tooltip_button .. c_tooltip_container
end
 
return p