local p = {}

local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)
	
	ret:defineParams{
		{ name = 'name', func = 'name' },
		{ name = 'image', func = 'image' },
		{ name = 'image_bucket', func = { name = image_bucket, params = { 'image' }, flag = 'p' } },
		{ name = 'icon', func = 'has_content' },
		{ name = 'icon_bucket', func = { name = image_bucket, params = { 'icon' }, flag = 'p' } },
		{ name = 'type', func = 'has_content' },
		{ name = 'release', func = 'release' },
		{ name = 'hotspot', func = 'has_content' },
		{ name = 'options', func = 'has_content' },
		{ name = 'examine', func = 'has_content' },
        { name = 'usesinfobox', func = { name = tostring, params = { 'Ship Part' }, flag = 'r' } },
		{ name = 'id', func = 'has_content' },
		{ name = 'id_bucket', func = { name = idbucket, params = { 'id' }, flag = 'p' } },
		{ name = 'itemid', func = 'has_content' },
		{ name = 'item_id_bucket', func = { name = idbucket, params = { 'itemid' }, flag = 'p' } },
	}
	
	ret:defineLinks({ hide = true })
	
	ret:useBucket("infobox_ship_part", {
		image_bucket = 'image',
		icon_bucket = 'icon',
		id_bucket = 'object_id',
		item_id_bucket = 'item_id'
	})
	
	ret:useBucket('item_id', {
		item_id_bucket = 'id'
	})

	ret:useBucket('object_id', {
		id_bucket = 'id'
	})

	ret:create()
	ret:cleanParams()

	ret:customButtonPlacement(true)
	ret:addButtonsCaption()

	ret:defineName('Infobox Sailing')
	ret:addClass('infobox-sailing')

	ret:addRow{
		{ tag = 'argh', content = 'name', class='infobox-header', colspan = '20' }
	}
	:pad(20)
	:addRow{
		{ tag = 'argd', content = 'image', class='infobox-image infobox-full-width-content', colspan = '20' }
	}
	:pad(20)
	:addRow{
		{ tag = 'th', content = 'Icon', colspan = '7' },
		{ tag = 'argd', content = 'icon', colspan = '13' }
	}
	if ret:paramDefined('type') then
		ret:addRow{
			{ tag = 'th', content = 'Type', colspan = '7' },
			{ tag = 'argd', content = 'type', colspan = '13' }
		}
	end
	ret:addRow{
		{ tag = 'th', content = 'Released', colspan = '7' },
		{ tag = 'argd', content = 'release', colspan = '13' }
	}
	if ret:paramDefined('hotspot') then
		ret:addRow{
			{ tag = 'th', content = '[[Hotspot]]', colspan = '7' },
			{ tag = 'argd', content = 'hotspot', colspan = '13' }
		}
	end
	if ret:paramDefined('options') then
		ret:addRow{
			{ tag = 'th', content = 'Options', colspan = '7' },
			{ tag = 'argd', content = 'options', colspan = '13' }
		}
	end
	ret:addRow{
		{ tag = 'th', content = 'Examine', colspan = '7' },
		{ tag = 'argd', content = 'examine', colspan = '13' }
	}
	:pad(20)
	:addRow{
		{ tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '20' },
		meta = {addClass = 'advanced-data'}
	}
	:pad(20, 'advanced-data')
	:addRow{
		{ tag = 'th', content = 'Object ID', colspan = '7' },
		{ tag = 'argd', content = 'id',  colspan = '13' },
		meta = {addClass = 'advanced-data'}
	}
	:addRow{
		{ tag = 'th', content = 'Icon Item ID', colspan = '7' },
		{ tag = 'argd', content = 'itemid',  colspan = '13' },
		meta = {addClass = 'advanced-data'}
	}
	:pad(20, 'advanced-data')

	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function experiencearg(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	local argNoCommas = string.gsub(arg, ',', '')
	if tonumber(argNoCommas) == nil then
		return arg
	else
		return string.format('<span class="infobox-quantity" data-val-each="%s"><span class="infobox-quantity-replace">%s</span> xp</span>', argNoCommas, arg)
	end
end

function numericarg(level)
	if infobox.isDefined(level) then
		local r = tonumber(level)
		return r
	end
	return nil
end

-- Filter non-numerical IDs and separate with splitpoint for use in Bucket
-- Example: '123 ,hist234, 456' => '123&&SPLITPOINT&&456'
function idbucket(id)
	if not infobox.isDefined(id) then
		return nil
	end
	local res = {}
	for id_i in string.gmatch(id, "[^,]+") do
		local trimmed = id_i:gsub("^%s*(.-)%s*$", "%1")
		if tonumber(trimmed) then
			table.insert(res, trimmed)
		end
	end
	return table.concat(res, '&&SPLITPOINT&&')
end

-- split items with multiple images for bucket (e.g. [[File:Arrow 1.png]] [[File:Arrow 2.png]])
function image_bucket(arg)
	local _img = {}
	for i in string.gmatch(arg, "[Ff]ile:.-%.png") do
		table.insert(_img, i)
	end
	if #_img == 0 then
		return nil
	end
	return table.concat(_img, '&&SPLITPOINT&&')
end

function is_default_version(default_bucketVer, default_textVer, bucketVer, textVer)
	if default_bucketVer ~= '' then
		local tmp = default_bucketVer == bucketVer
		return tmp
	end
	if default_textVer ~= '' then
		local tmp = default_textVer == textVer
		return tmp
	end
	return true --If we don't have any versions then we are the default version
end

function addcategories(args, catargs)
	local ret = { 'Ship part' }

	-- Add the associated category if the parameter doesn't have content
	local notdefined_args = {
		image = 'Needs image',
		members = 'Needs members status',
		release = 'Needs release date',
		experience = 'Needs experience info',
		examine = 'Needs examine added',
		id = 'Needs ID',
		itemid = 'Needs ID',
	}
	for n, v in pairs(notdefined_args) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret, v)
		end
	end
	
    -- release year
    local year = args.release.d:match('%d%d%d%d')
    if year then
        table.insert(ret, 'Content released in '..year)
    end
    if args.release.switches then
        for _, v in ipairs(args.release.switches) do
            year = v:match('%d%d%d%d')
            if year then
                table.insert(ret, 'Content released in '..year)
            end
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