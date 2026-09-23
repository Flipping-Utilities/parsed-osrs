-- <pre>
local p = {}
 
local hasc = require('Module:Paramtest').has_content
local tooltips = require('Module:Sandbox/User:Notso/Tooltip Upgrade')
 
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

	local k,t,vals
	-- Two-column grid built from spans (a <table> here would break paragraphs)
	local tooltip_grid = mw.html.create('span')
		:css{
			display = 'inline-grid',
			['vertical-align'] = 'top',
			['grid-template-columns'] = 'auto 1fr',
			['column-gap'] = '0.75em',
			['row-gap'] = '0.25em',
			padding = '0 0.5em',
		}
	local c_options_arr = {}

	for i,v in ipairs(items) do
		k = mw.text.trim(v[1]) -- Chat option key value
		t = mw.text.trim(v[2]) -- Chat option text

		-- Chat options list (unchanged)
		vals = mw.html.create('span')
		vals:wikitext(k)
		if hasc(t) then
			vals:addClass('chat-options-underline')
				:attr('title', t)
		end
		table.insert(c_options_arr, tostring(vals))

		-- Chat options tooltip: one key cell, one text cell
		tooltip_grid
			:tag('span'):wikitext("'''"..k.."'''"):done()
			:tag('span'):wikitext(t):done()
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
				arrow = 'yes',
				limitwidth = 'yes',
				content = tostring(tooltip_grid),
				inline = 'yes'
				}):css('padding', '0')
	c_tooltip_button = tostring(c_tooltip_button)
	c_tooltip_container = tostring(c_tooltip_container)
 
 
	return c_options_container .. c_tooltip_button .. c_tooltip_container
end
 
return p