--------------------------
-- Module for [[Template:Infobox City details]]
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
		{ name = 'leader', func = 'has_content' },
		{ name = 'race', func = 'has_content' },
		{ name = 'demonym', func = 'has_content' },
		{ name = 'guilds', func = 'has_content' },
		{ name = 'banks', func = 'has_content' },
		{ name = 'altars', func = 'has_content' },
		{ name = 'obelisks', func = 'has_content' },
		{ name = 'hotspots', func = 'has_content' },
	}

	ret:setMaxButtons(4)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)
	
	ret:defineLinks({ hide = true })

	ret:defineName('Infobox City details')
	ret:addClass('infobox-city-details left-info')

	ret:addButtonsCaption()

	-- PARAMETER: name
	ret:addRow{
		{ tag = 'argh', content = 'name', class='infobox-header',  colspan = '3' }
	}
	ret:pad(3)
	
	-- PARAMETER: leader
	if ret:paramDefined('leader') then
		ret:addRow{
			{ tag = 'th', content = 'Leader' },
			{ tag = 'argd', content = 'leader', colspan = '2' }
		}
	end
	
	-- PARAMETER: race
	if ret:paramDefined('race') then
		ret:addRow{
			{ tag = 'th', content = 'Inhabitants' },
			{ tag = 'argd', content = 'race', colspan = '2' }
		}
	end
	
	-- PARAMETER: demonym
	if ret:paramDefined('demonym') then
		ret:addRow{
			{ tag = 'th', content = 'Demonym' },
			{ tag = 'argd', content = 'demonym', colspan = '2' }
		}
	end
	
	-- PARAMETER: guilds
	if ret:paramDefined('guilds') then
		ret:addRow{
			{ tag = 'th', content = '[[Guilds]]' },
			{ tag = 'argd', content = 'guilds', colspan = '2' }
		}
	end
	
	-- PARAMETER: banks, altars, obelisks, hotspots
	if ret:paramDefined('banks') or ret:paramDefined('altars') or ret:paramDefined('obelisks') or ret:paramDefined('hotspots') then
		local features = {}
		if ret:paramDefined('banks') then
			table.insert(features,'[[File:Bank map icon.png|15px|link=Bank]] '..ret:param('banks'))
		end
			if ret:paramDefined('altars') then
			table.insert(features,'[[File:Altar map icon.png|15px|link=Altar]] '..ret:param('altars'))
			end
		if ret:paramDefined('obelisks') then
			table.insert(features,'[[File:Small Summoning obelisk map icon.png|15px|link=Obelisk]] '..ret:param('obelisks'))
		end
			if ret:paramDefined('hotspots') then
			table.insert(features,'[[File:Excavation site map icon.png|15px|link=Excavation hotspot]] '..ret:param('hotspots'))
		end
		ret:addRow{
			{ tag = 'th', content = 'Features' },
			{ tag = 'td', content = table.concat(features,', '), colspan = '2' }
		}
	end
	ret:pad(3)
	
	ret:finish()
	
	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function addcategories(args, catargs)
	local ret = { 'Cities' }

	-- Add the associated category if the parameter doesn't have content
	local notdefined_args = {

	}
	
	for n, v in pairs(notdefined_args) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret, v)
		end
	end
	
	-- Add the associated category if the parameter does have content
	local defined_args = {
		
	}
	for n, v in pairs(defined_args) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret, v)
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