--------------------------
-- Module for [[Template:Infobox Pet]]
------------------------
local p = {}

-- "imports"
local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean

local intcats = {
	boss = 'Boss pets',
	companion = 'Companion pets',
	follower = 'Follower pets',
	legendary = 'Legendary pets',
	skilling = 'Skilling pets',
}

local overridecats = {
	boss = true,
	companion = true,
	follower = false,
	legendary = true,
	skilling = true,
}

local no_food = {
	boss = true,
}

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	ret:defineParams{
		{ name = 'name', func = 'name' },
		{ name = 'image', func = has_content },
		{ name = 'caption', func = { name = captionarg, params = { 'image', 'name' }, flag = 'p' } },
		{ name = 'vanchor', func = { name = 'has_content', params = { 'version' }, flag = 'p' } },
		{ name = 'location', func = 'has_content' },
		{ name = 'interface', func = 'has_content' },
		{ name = 'intcat', func = intcatarg },
		{ name = 'override', func = { name = overridearg, params = { 'override', 'intcat' }, flag = { 'p', 'p' } } },
		{ name = 'skillrequired', func = 'has_content' },
		{ name = 'questrequired', func = 'has_content' },
		{ name = 'food', func = { name = foodarg, params = { 'food', 'intcat' }, flag = { 'p', 'p' } } },
		{ name = 'growthtime', func = { name = growthtimearg, params = { 'growthtime', 'intcat' }, flag = { 'p', 'p' } } },
		{ name = 'colours', func = 'has_content' },
		{ name = 'bucketarg', func = { name = bucketarg, params = { 'json_image' }, flag = 'd' } },
	}

	ret:setMaxButtons(4)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)

	ret:useBucket('infobox_cosmetic_override', {
		bucketarg = 'json',
	})

	ret:linkParams{
		image = 'imagebackground'
	}
	
	ret:defineLinks({ hide = true })

	ret:defineName('Infobox Pet details')
	ret:addClass('left-info')

	ret:addButtonsCaption()

	-- PARAMETER: caption
	ret:addRow{
		{ tag = 'argh', content = 'caption', colspan = '3', class = 'infobox-header' }
	}

	-- PARAMETER: location
	ret:pad(3)
	ret:addRow{
		{ tag = 'th', content = 'Source' },
		{ tag = 'argd', content = 'location', colspan = '2' }
	}
	
	-- PARAMETER: interface
	:addRow{
		{ tag = 'th', content = '[[Pet#Interface pets|Interface]]' },
		{ tag = 'argd', content = 'interface', colspan = '2' }
	}
	
	-- PARAMETER: intcat
	if ret:paramGrep('interface', function(x) return yesno(x) ~= false end) then
		ret:addRow{
			{ tag = 'th', content = 'Category' },
			{ tag = 'argd', content = 'intcat', colspan = '2' }
		}
	end
	
	-- PARAMETER: override
	if ret:paramGrep('interface', function(x) return yesno(x) ~= false end) then
		ret:addRow{
			{ tag = 'th', content = 'Override' },
			{ tag = 'argd', content = 'override', colspan = '2' }
		}
	end
	
	-- PARAMETER: skillrequired
	ret:addRow{
		{ tag = 'th', content = '[[Skills|Skill]] req.' },
		{ tag = 'argd', content = 'skillrequired', colspan = '2' }
	}
	
	-- PARAMETER: questrequired
	:addRow{
		{ tag = 'th', content = '[[Quests|Quest]] req.' },
		{ tag = 'argd', content = 'questrequired', colspan = '2' }
	}
	
	-- PARAMETER: food
	:addRow{
		{ tag = 'th', content = 'Food' },
		{ tag = 'argd', content = 'food', colspan = '2' }
	}
	
	-- PARAMETER: growthtime
	:addRow{
		{ tag = 'th', content = 'Growth time' },
		{ tag = 'argd', content = 'growthtime', colspan = '2' }
	}
	
	-- PARAMETER: colours
	:addRow{
		{ tag = 'th', content = 'Colours' },
		{ tag = 'argd', content = 'colours', colspan = '2' }
	}
	ret:pad(3)
	
	ret:finish()
	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

-- Add [[File: and |link=...]] to image, if it's defined
function captionarg(image, name)
	local link = mw.title.getCurrentTitle().text
	
	if not infobox.isDefined(name) then
		name = link
	end
	
	if infobox.isDefined(image) then
		image = '[[File:' .. image:gsub('File:', '') .. '|link=' .. link .. ']]'
	-- anti-redlink
	elseif link == 'Infobox Pet details/preload'
			or link == 'PreloadPage/Orphanage' then
		image = ''
	else
		image = '[[File:' .. name .. '.png|link=' .. name ..']]'
	end
	
	return image .. ' ' .. name
end

function intcatarg(intcat)
	if infobox.isDefined(intcat) then
		local cat = intcats[string.lower(intcat)]
		if cat then
			return '[[:Category:' .. cat .. '|' .. intcat .. ']]'
		end
	end
end

function overridearg(override, intcat)
	if infobox.isDefined(override) then
		return override
	end
	if infobox.isDefined(intcat) then
		local overrideable = overridecats[string.lower(intcat)]
		if overrideable == true then
			return 'Yes'
		elseif overrideable == false then
			return 'No'
		else
			return 'Unknown'
		end
	end
end

function foodarg(food, intcat)
	if infobox.isDefined(food) then
		return food
	elseif infobox.isDefined(intcat) then
		if no_food[string.lower(intcat)] then
			return 'No'
		end
	end
end

function growthtimearg(growthtime, intcat)
	if infobox.isDefined(growthtime) then
		if tonumber(growthtime) then
			return growthtime .. ' minutes'
		else
			return growthtime
		end
	elseif infobox.isDefined(intcat) then
		if no_food[string.lower(intcat)] then
			return 'No'
		end
	end
end

function bucketarg(json_image)
	local toJSON = {
		image = json_image,
	}
	for k,v in pairs(toJSON) do
		if v == '' or (type(v) == 'string' and string.find(v,'action=edit')) then
			--toJSON[k] = nil
			return nil
		end
	end
	return mw.text.jsonEncode(toJSON)
end

function addcategories(args, catargs)
	function is_def(x, y)
		y = y or 'd'
		if infobox.isDefined(x) then
			return infobox.isDefined(x[y])
		end
		return false
	end
	
	local ret = { 'Pets' }
	
	local cat_map = {
		-- Added if the parameter has content
		defined = {
		},
		-- Added if the parameter has no content
		notdefined = {
		},
	}
	
	-- Interface category
	if args.intcat.switches then
		for i,v in ipairs(args.intcat.switches) do
			if infobox.isDefined(v) then
				for k,cat in pairs(intcats) do
					local catmatch = string.lower(v):find(k)
					if catmatch then
						table.insert(ret, cat)
					end
				end
				
			end
		end
	elseif args.intcat.d and infobox.isDefined(args.intcat.d) then
		for k,cat in pairs(intcats) do
			local catmatch = string.lower(args.intcat.d):find(k)
			if catmatch then
				table.insert(ret, cat)
			end
		end
	end
	
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
	
	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end

	return table.concat(ret, '')
end

return p