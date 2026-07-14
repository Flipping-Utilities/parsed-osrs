--------------------------
-- Module for [[Template:Infobox Spell]] 
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')
local skillpic = require('Module:SCP')._main
local yesno = require('Module:Yesno')

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)
	
	ret:defineParams{
		{ name = 'name', func = 'name' },
		{ name = 'image', func = 'image' },
		{ name = 'release', func = 'release' }, --Also handles update
		{ name = 'removal', func = 'removal' },
		{ name = 'members', func = 'has_content' },
		{ name = 'members_bucket', func = { name = yesno, params = { 'members' } } },
		{ name = 'level', func = level },
		{ name = 'level_bucket', func = { name = string.lower, params = { 'level' }, flag = { 'p' } } },
		{ name = 'slayerlevel', func = slayerlevel },
		{ name = 'spellbook', func = spellbook },
		{ name = 'spellbook_bucket', func = { name = string.lower, params = { 'spellbook' }, flag = { 'p' } } },
		{ name = 'type', func = spell_type },
		{ name = 'exp', func = 'has_content' },
		{ name = 'element', func = element },
		{ name = 'damage', func = 'has_content' },
		{ name = 'cost', func = 'has_content' },
		{ name = 'cost_bucket', func = { name = cost_bucket, params = { 'cost' } } },
		{ name = 'speed', func = 'has_content' },
		{ name = 'cooldown', func = 'has_content' },
		{ name = 'quest', func = { name = quest, params = { 'quest', 'spellbook' } } },
		{ name = 'lectern', func = 'has_content' },
		{ name = 'description', func = 'has_content' },
		{ name = 'anim', func = 'has_content' },
		{ name = 'sound', func = 'has_content' },
		{ name = 'json', func = { name = json_bucket, params = { 'level', 'slayerlevel', 'exp', 'cost', 'type', 'spellbook' }, flag = { 'p', 'p', 'p', 'p', 'p', 'p' } } },
	}
	
	ret:defineLinks({ hide = true })
	
	ret:create()
	ret:cleanParams()
	
	ret:useBucket("infobox_spell", {
		image = 'image',
		members_bucket = 'is_members_only',
		spellbook_bucket = 'spellbook',
		cost_bucket = 'uses_material',
		json = 'json'
	})
	
	ret:customButtonPlacement(true)
	ret:addButtonsCaption()
	
	ret:defineName('Infobox Spell')
	ret:addClass('infobox-spell')
	
	ret:addRow{
		{ tag = 'argh', content = 'name', class='infobox-header', colspan = '5' }
	}
	:pad(5)
	
	ret:addRow{
		{ tag = 'argd', content = 'image', class='infobox-image inventory-image infobox-full-width-content', colspan = '5' }
	}
	:pad(5)
	
	ret:addRow{
		{ tag = 'th', content = 'Released', colspan = '2' },
		{ tag = 'argd', content = 'release', colspan = '3' }
	}

	if ret:paramDefined('removal') then
		ret:addRow{
			{ tag = 'th', content = 'Removal', colspan = '2' },
			{ tag = 'argd', content = 'removal', colspan = '3' }
		}
	end
	
	ret:addRow{
		{ tag = 'th', content = '[[Members]]', colspan = '2' },
		{ tag = 'argd', content = 'members', colspan = '3' }
	}
	
	ret:addRow{
		{ tag = 'th', content = '[[Magic|Level]]', colspan = '2' },
		{ tag = 'argd', content = 'level', colspan = '3' }
	}
	
	if ret:paramDefined('slayerlevel') then
		ret:addRow{
			{ tag = 'th', content = '', colspan = '2' },
			{ tag = 'argd', content = 'slayerlevel', colspan = '3' }
		}	
	end
	
	ret:addRow{
		{ tag = 'th', content = '[[Spellbook]]', colspan = '2' },
		{ tag = 'argd', content = 'spellbook', colspan = '3' }
	}
	
	ret:addRow{
		{ tag = 'th', content = 'Type', colspan = '2' },
		{ tag = 'argd', content = 'type', colspan = '3' }
	}
	
	ret:addRow{
		{ tag = 'th', content = '[[Experience]]', colspan = '2' },
		{ tag = 'argd', content = 'exp', colspan = '3' }
	}

	if ret:paramDefined('element') then
		ret:addRow{
			{ tag = 'th', content = '[[Attack style|Element]]', colspan = '2' },
			{ tag = 'argd', content = 'element', colspan = '3' }
		}	
	end
	
	if ret:paramDefined('damage') then
		ret:addRow{
			{ tag = 'th', content = '[[Maximum magic hit|Base max hit]]', colspan = '2' },
			{ tag = 'argd', content = 'damage', colspan = '3' }
		}	
	end
	
	ret:addRow{
		{ tag = 'th', content = '[[Runes]]', colspan = '2' },
		{ tag = 'argd', content = 'cost', colspan = '3' }
	}
	
	ret:addRow{
		{ tag = 'th', content = '[[RuneScape clock#Magic|Casting speed]]', colspan = '2' },
		{ tag = 'argd', content = 'speed', colspan = '3' }
	}
	
	if ret:paramDefined('cooldown') then
		ret:addRow{
			{ tag = 'th', content = 'Cooldown', colspan = '2' },
			{ tag = 'argd', content = 'cooldown', colspan = '3' }
		}	
	end
	
	if ret:paramDefined('quest', 'all') then
		ret:addRow{
			{ tag = 'th', content = '[[Quest]]', colspan = '2' },
			{ tag = 'argd', content = 'quest', colspan = '3' }
		}
	end
	
	if ret:paramDefined('lectern') then
		ret:addRow{
			{ tag = 'th', content = '[[Lectern]]', colspan = '2' },
			{ tag = 'argd', content = 'lectern', colspan = '3' }
		}
	end
	
	ret:addRow{
		{ tag = 'th', content = 'Description', colspan = '2' },
		{ tag = 'argd', content = 'description', colspan = '3' }
	}
	:pad(5)
	
	if ret:paramDefined('anim') then
		ret:addRow{
			{ tag = 'th', content = 'Animation', class = 'infobox-subheader', colspan = '5' }
		}
		ret:addRow{
			{ tag = 'argd', content = 'anim', class = "infobox-full-width-content", colspan = '5' } 
		}
	end
	
	if ret:paramDefined('sound') then
		ret:addRow{
			{ tag = 'th', content = 'Sound effect', class = 'infobox-subheader', colspan = '5' }
		}
		ret:addRow{
			{ tag = 'argd', content = 'sound', class = "infobox-full-width-content infobox-media-player", colspan = '5' } 
		}
	end
	
	if onmain() then
		local a1 = ret:param('all')	
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function cost_bucket(arg)
	--The input is a fully parsed {{RuneReq}}. Grab the link targets.
	local materials = {}
	-- Pattern to match the link target produced by {{RuneReq}}
	for m in string.gmatch(arg, '%[%[[^|]+%|[^|]+%|link=([^|%]]+)%]%]') do
		table.insert(materials, m)
	end
	
	return materials
end

function json_bucket(level, slayerlevel, exp, cost, spell_type, spellbook)
	local json = {
		level = level,
		slayerlevel = slayerlevel,
		exp = exp,
		cost = cost,
		type = spell_type,
		spellbook = spellbook
	}
	return mw.text.jsonEncode(json)
end

function level(arg)
	if not infobox.isDefined(arg) then
		return nil
	end
	return skillpic("Magic", arg )
end

function slayerlevel(arg)
	if not infobox.isDefined(arg) then
		return nil
	end
	
	return skillpic("Slayer", arg )
end

function spellbook(arg)
	if not infobox.isDefined(arg) then
		return nil
	end
	
	local function link(s)
		if s == 'normal' then
			return "[[Standard spellbook|Standard]]"
		end
		if s == 'ancient' then
			return "[[Ancient Magicks|Ancient]]"
		end
		if s == 'lunar' then
			return "[[Lunar spellbook|Lunar]]"
		end
		if s == 'arceuus' then
			return "[[Arceuus spellbook|Arceuus]]"
		end
		if s == 'all' then
			local all = { link('normal'), link('ancient'), link('lunar'), link('arceuus') }
			return table.concat(all, "<br>")
		end
	end
	
	return link(string.lower(arg))
end

function spell_type(arg)
	if not infobox.isDefined(arg) then
		return nil
	end
	arg = string.lower(arg)
	if arg == 'combat' then
		return "[[Combat spells|Combat]]"
	end
	if arg == 'teleport' then
		return "[[Teleportation spells|Teleport]]"
	end
	if arg == 'utility' then
		return "[[Utility spells|Utility]]"
	end
end

function element(arg)
	if not infobox.isDefined(arg) then
		return nil
	end
	
	return "[[" .. arg .. " spells|" .. arg .. "]]"
end

function quest(quest, spellbook)
	spellbook = string.lower(spellbook)
	if infobox.isDefined(quest) then
		if spellbook == 'ancient' then
			return quest .. "<br>(plus [[Desert Teasure I]])"
		end
		return quest
	end
	
	if spellbook == 'ancient' then
		return "[[Desert Treasure I]]"
	end
	if spellbook == 'lunar' then
		return "[[Lunar Diplomacy]]"
	end
end

function addcategories(args, catargs)
	local ret = { 'Spells' }

 	-- Add the associated category if the parameter has content
	local defined_args = {
		cooldown = 'Spells with cooldowns',
	}
	for n, v in pairs(defined_args) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret, v)
		end
	end

 	-- Add the associated category if the parameter doesn't have content
 	local notdefined_args = {
 		image = 'Needs image',
 		release = 'Needs release date',
 		update = 'Needs update',
 		members = 'Needs members status',
 		exp = 'Needs experience info',
 		sound = 'Needs sound effect added'
 		
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
	
	local cat_map = {
		-- Parameters that have text
		-- map a category to a value
		matches = {
			members = { yes = 'Members\' spells', no = 'Free-to-play spells' },
		}
	}
	
	-- searches
	for n, v in pairs(cat_map.matches) do
		for m, w in pairs(v) do
			if args[n] then
				if string.lower(tostring(args[n].d) or '') == m then
					table.insert(ret, w)
				end
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