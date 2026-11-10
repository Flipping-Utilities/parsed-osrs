--------------------------
-- Module for [[Template:Infobox Dungeon]]
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local paramtest = require('Module:Paramtest')
local infobox = require('Module:Infobox')

-- Main function called with invokes
function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	ret:defineParams{
		{ name = 'name', func = 'name' },
		{ name = 'floors', func = 'has_content' },
		{ name = 'cannon', func = 'has_content' },
		{ name = 'resource dungeon', func = 'has_content' },
		{ name = 'requirements', func = 'has_content' }
	}

	ret:setMaxButtons(4)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)
	
	ret:defineLinks({ hide = true })

	ret:defineName('Infobox Dungeon')
	ret:addClass('infobox-dungeon left-info')

	ret:addButtonsCaption()

	-- PARAMETER: name
	ret:addRow{
		{ tag = 'argh', content = 'name', class='infobox-header',  colspan = '10' }
	}
	ret:pad(10)
	
	-- PARAMETER: floors
	if ret:paramDefined('floors') then
		ret:addRow{
			{ tag = 'th', content = 'Floors', colspan = '4' },
			{ tag = 'argd', content = 'floors', colspan = '6' }
		}
	end
	
	-- PARAMETER: cannon
	if ret:paramDefined('cannon') then
		ret:addRow{
			{ tag = 'th', content = '[[Cannons]] allowed', colspan = '4' },
			{ tag = 'argd', content = 'cannon', colspan = '6' }
		}
	end
	
	-- PARAMETER: resource dungeon
	if ret:paramDefined('resource dungeon') then
		ret:addRow{
			{ tag = 'th', content = 'Resource dungeon', colspan = '4' },
			{ tag = 'argd', content = 'resource dungeon', colspan = '6' }
		}
	end
	
	-- PARAMETER: requirements
	if ret:paramDefined('requirements') then
		ret:addRow{
			{ tag = 'th', content = 'Requirements', colspan = '4' },
			{ tag = 'argd', content = 'requirements', colspan = '6' }
		}
	end
	ret:pad(10)
	
	ret:finish()
	
	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function addcategories(args, catargs)
	local ret = { 'Dungeons' }
	
	local cat_map = {
		-- Added if the parameter has content
		defined = {
			
		},
		-- Added if the parameter has no content
		notdefined = {
			cannon = 'Needs dwarf cannon added',
			floors = 'Needs floors added'
		},
	}
	
	-- Run and add mapped categories
	for n, v in pairs(cat_map.defined) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret,v)
		end
	end
	for n, v in pairs(cat_map.notdefined) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret,v)
		end
	end
	
	-- Add the associated category if the parameter is valued at yes
	if args['resource dungeon'] then
		if string.lower(args['resource dungeon'].d or '') == 'yes' then
			table.insert(ret, 'Resource dungeons')
		end
	end

	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end

	return table.concat(ret, '')
end

return p