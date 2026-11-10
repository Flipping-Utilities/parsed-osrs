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
		local key, key2, key3
		local tooltip

		if item:lower() == 'accept' then
			key = '&#x2713;'
			tooltip = '[Accept Quest]'
		elseif item:lower() == 'any' or item == '~' then
			key = '~'
			tooltip = '[Any option]'
		else
			key, key2, key3, tooltip = item:match('^([-?A-Za-z0-9#])/?([A-Za-z0-9]?)/?([A-Za-z0-9]?)%s-(.*)')
			-- Match first case-insensitive, alphanumeric character, "#", or "?"
			if key == '?' or key == '#' then
				key = '[Varies]'
			elseif key == '-' then
				key = '[No keybound]'
			else
				key = key:upper()
			end

			if key2 == '' then
				key2 = nil
			end

			if key3 == '' then
				key3 = nil
			end
		end

		table.insert(items, {
			key = key,
			key2 = key2,
			key3 = key3,
			tooltip = tooltip
		})
		i = i + 1
	end

	return p.render(items)
end

function p.render(items)
	local k, t, vals, tooltip_table
	tooltip_table = mw.html.create('table') -- Create tooltip table
	local c_options_arr = {}

	for _, v in ipairs(items) do
		-- Chat option key value
		k = ' '
		if v.key then
			k = v.key
		end
		if v.key2 then
			k = k .. '/' .. v.key2
		end
		if v.key3 then
			k = k .. '/' .. v.key3
		end
		t = v.tooltip -- Chat option text

		---
		--- Chat options list
		---
		vals = mw.html.create('span')      -- Create chat options number
		vals:wikitext(k)                   -- Set text to the key value
		if hasc(t) then                    -- If it has text to display
			vals:addClass('chat-options-underline') -- Underline it
				:attr('title', t)          -- Add hover title attrib with text
		end
		table.insert(c_options_arr, tostring(vals))

		---
		--- Chat options tooltip
		---
		tooltip_table:tag('tr')
			:tag('td'):wikitext("'''" .. k .. "'''"):done()
			:tag('td'):wikitext(t):done()
			:done()
	end

	-- Create chat options container
	local c_options_container = mw.html.create('span')
		:addClass('chat-options')
		:wikitext('(<i title="Chat options">[[File:Quick Chat icon.png|alt=Chat|link=]]</i> ')
		:wikitext(table.concat(c_options_arr, '&bull;')) -- Concat chat option numbers with hovers
		:wikitext(')')
	c_options_container = tostring(c_options_container)

	-- Create chat options tooltip
	local name = 'c_option-' .. mw.hash.hashValue('md5', c_options_container)
	local c_tooltip_button = tooltips._span({
			name = name,
			alt = '\'\'\'&hellip;\'\'\''
		})
		:addClass('chat-options-dialogue')
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