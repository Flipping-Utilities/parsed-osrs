local p = {}

local infobox = require('Module:Infobox')
local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local cleanimage = require('Module:Clean image').clean

local sizearg, placementargs, doorsarg, inoroutarg, rotationsarg, rotationsdisparg, blockingarg, overridesarg, jsonarg

local valid_placements = {
	wall = 'wall',
	floor = 'floor',
}
local valid_rotations = {
	-- number of rotations
	['1'] = 1,
	['2'] = 2,
	['4'] = 4,
	['8'] = 8,
	
	-- rotations in degrees
	['0'] = 1,
	['360'] = 1,
	['180'] = 2,
	['90'] = 4,
	['45'] = 8
}
local rotations_display = {
	[1] = 'Cannot be rotated (1 position)',
	[2] = '180° (2 positions)',
	[4] = '90° (4 positions)',
	[8] = '45° (8 positions)'
}

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)
	
	ret:defineParams{
		{ name='image', func={ name=imagearg, params={ 'image' }, flag='d' } },
		{ name='name', func='name' },
		{ name='category', func='has_content' },
		{ name='subcategory', func='has_content' },
		{ name='size', func={ name=sizearg, params={ 'size' }, flag='d' } },
		{ name='placement', func={ name=placementarg, params={ 'placement' }, flag='d' } },
		{ name='blocking', func={ name=blockingarg, params={ 'blocking' }, flag='d' } },
		{ name='placement_disp', func={ name=placementdisparg, params={ 'placement', 'blocking' }, flag='d' } },
		{ name='indoors', func={ name=doorsarg, params={ 'indoors' }, flag='d' } },
		{ name='outdoors', func={ name=doorsarg, params={ 'outdoors' }, flag='d' } },
		{ name='inorout', func={ name=inoroutarg, params={ 'indoors', 'outdoors' }, flag='d' } },
		{ name='rotations', func={ name=rotationsarg, params={ 'rotations' }, flag='d' } },
		{ name='rotations_disp', func={ name=rotationsdisparg, params={ 'rotations' }, flag='d' } },
		{ name='overrides', func={ name=overridesarg, params={ 'overrides' }, flag='d' } },
		{ name='dbrowid', func='has_content'},
		
		{ name='json', func={ name=jsonarg, params={ 'name', 'image', 'size', 'indoors', 'outdoors', 'rotations', 'blocks_movement', 'blocks_furniture', 'dbrowid' }, flag='d' } }
	}
	
	ret:create()
	ret:cleanParams()
	ret:useBucket('furniture', {
		category='category',
		subcategory='subcategory',
		json='json',
		dbrowid='dbrowid'
	})

	ret:addButtonsCaption()

	ret:defineName('Infobox Furniture')
	ret:addClass('infobox-furniture'):float('none')
	
	ret:addRow{
		{ tag='argh', content='name', class='infobox-header', colspan='5' }
	}
		:pad(5)

	ret:addRow {
		{ tag = 'argd', content = 'image', class = 'infobox-image infobox-full-width-content', colspan='5' },
	}
		:pad(5)
	
	ret:addRow {
		{ tag = 'th', content = 'Category', colspan = '2' },
		{ tag = 'argd', content = 'category', colspan = '3' },
	}
	ret:addRow {
		{ tag = 'th', content = 'Subcategory', colspan = '2' },
		{ tag = 'argd', content = 'subcategory', colspan = '3' },
	}
	ret:addRow {
		{ tag = 'th', content = 'Location', colspan = '2' },
		{ tag = 'argd', content = 'inorout', colspan = '3' },
	}
	ret:addRow {
		{ tag = 'th', content = 'Placement', colspan = '2' },
		{ tag = 'argd', content = 'placement_disp', colspan = '3' },
	}
	ret:addRow {
		{ tag = 'th', content = 'Size', colspan = '2' },
		{ tag = 'argd', content = 'size', colspan = '3' },
	}
	ret:addRow {
		{ tag = 'th', content = 'Rotations', colspan = '2' },
		{ tag = 'argd', content = 'rotations_disp', colspan = '3' },
	}
	if ret:paramDefined('overrides') then
		ret:addRow {
			{ tag = 'th', content = 'Overrides', colspan = '2' },
			{ tag = 'argd', content = 'overrides', colspan = '3' },
		}
	end
	ret:addRow {
			{ tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '5' },
			meta = { addClass = 'advanced-data' },
		}
		:pad(5)

	ret:addRow {
		meta={ addClass='advanced-data' },
		{ tag = 'th', content = 'DB Row ID', colspan = '2' },
		{ tag = 'argd', content = 'dbrowid', colspan = '3' },
	}

	if onmain() then
		ret:wikitext(addcategories(ret))
	end
	return ret:tostring()
end

function imagearg(arg)
	if not infobox.isDefined(arg) then return nil end
	return cleanimage{file=arg, height=200, width=200}
end

function sizearg(arg)
	if not infobox.isDefined(arg) then return nil end
	arg = mw.text.trim(arg)
	if string.find(arg, '^%d+[x×]%d+$') then
		return arg
	end
	return nil
end

function placementarg(arg)
	if not infobox.isDefined(arg) then return nil end
	arg = mw.text.trim(arg):lower()
	return valid_placements[arg]
end
function blockingarg(arg)
	return tostring(yesno(arg))
end
function placementdisparg(place, block)
	if not infobox.isDefined(place) then return nil end
	if place == 'wall' then
		return '<span class="hover-text" title="Wall mounted furniture cannot be placed in the same tiles as other wall mounted furniture, but do not block any floor placed items or movement.">Wall mounted</span>'
	end
	if place == 'floor' then
		if block == 'true' then
			return '<span class="hover-text" title="Blocking furniture cannot be placed in the same tiles as other blocking furniture, and cannot be walked through.">Floor (blocking)</span>'
		elseif block == 'false' then
			return '<span class="hover-text" title="Non-blocking furniture can be placed on the same tiles as any other furniture, and can be walked over/through.">Floor (non-blocking)</span>'
		end
	end
	return nil
end

function doorsarg(arg)
	if not infobox.isDefined(arg) then return nil end
	local val = yesno(mw.text.trim(arg))
	return tostring(val) --ensuring true/false/nil are kept and not interpretted by infobox item
end
function inoroutarg(inarg, outarg)
	if inarg == 'true' then
		if outarg == 'true' then
			return 'Indoors and outdoors'
		elseif outarg == 'false' then
			return 'Indoors only'
		end
	elseif inarg == 'false' then
		if outarg == 'true' then
			return 'Outdoors only'
		--elseif outarg == 'false' then
		--	return "Can't be placed???"
		end
	end
	return nil -- either is nil
end

function rotationsarg(arg)
	if not infobox.isDefined(arg) then return nil end
	return valid_rotations[mw.text.trim(arg)]
end
function rotationsdisparg(arg)
	if not infobox.isDefined(arg) then return nil end
	return rotations_display[arg]
end

function overridesarg(arg)
	if not infobox.isDefined(arg) then return nil end
	local out = {}
	for txt in mw.text.gsplit(arg, ';') do
		local t = mw.text.trim(txt)
		if t ~= '' then
			table.insert(out, '\n* [['..t..']]')
		end
	end
	if #out > 0 then
		return table.concat(out, '')
	end
	return nil
end

function jsonarg(name, image, size, indoors, outdoors, rotations, rotations_disp, placement, blocking, dbrowid)
	function isdef(x)
		if infobox.isDefined(x) then
			return x
		end
		return '?'
	end
	local j = {
		name=name,
		image=isdef(image),
		indoors=isdef(indoors),
		outdoors=isdef(outdoors),
		rotations=isdef(rotations),
		rotations_disp=isdef(rotations_disp),
		placement=isdef(placement),
		dbrowid=isdef(dbrowid)
	}
	if placement=='floor' then
		j['blocking'] = blocking
	end
	local jsonGood, encoded = pcall(mw.text.jsonEncode,j)
	if jsonGood then
		return encoded
	end
	return nil
end

function addcategories(ibox)
	local args = ibox:param('all')
	local catargs = ibox:categoryData()
	local cats = {'Furniture'}
	
	for i,v in ipairs({'indoors', 'outdoors', 'rotations', 'blocks_movement', 'blocks_furniture', 'dbrowid'}) do
		if not catargs[v].all_defined then
			table.insert('Missing furniture information')
			break
		end
	end
	
	if catargs.overrides.one_defined then
		table.insert(cats, 'Furniture with overrides')
	end
	local _cats = {}
	for i,v in ipairs(cats) do
		table.insert(_cats, '[[Category:'..v..']]')
	end
	return table.concat(_cats, '')
end

return p