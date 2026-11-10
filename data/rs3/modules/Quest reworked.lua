local onmain = require('Module:Mainonly').on_main
local arr = require('Module:Array')
local p = {}
require("Module:Mw.html extension")

function p.main(frame)
	local args = frame:getParent().args
	local reworked_from = mw.title.getCurrentTitle().text
	local reworked_to = {}
	local i = 1
	while args[i] do
		table.insert(reworked_to, args[i])
		i = i + 1
	end
	-- NB: If we ever get a quest reworked to more than two quests, this grammar will be off.
	local reworked_to_string = table.concat(reworked_to, " and ") 
	
	local template_box = mw.html.create('table'):addClass("messagebox obsolete")
	template_box:tr()
		:td('[[File:Saw.png|center|link=]]'):css('width', '40px')
		:td('<strong>'..reworked_from..' was replaced by '..reworked_to_string..
			'.</strong><br clear="all"><div style="font-size:0.85em; line-height:1.4em;">'..
			'This article is kept for historical purposes.</div>')
	local out_string = tostring(template_box)
	if onmain() then
		out_string = out_string .. '[[Category:Removed quests]][[Category:Removed content]]'
	end
	
	return out_string
end

return p