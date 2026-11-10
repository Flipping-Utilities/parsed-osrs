local p = {}

local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean
local yesno = require('Module:Yesno')
local var = mw.ext.VariablesLua
local lang = mw.language.getContentLanguage()
local imgarg, membersarg, levelarg, runesarg, runesdisp, runesbucket, experiencearg, targetarg, targetdisp
local animarg, sfxarg, cooldownarg, cooldowndisp, durationarg, durationdisp
local iddisp, idbucket, make_chisel_links, bucketarg, addcategories

local left = '8'
local right = '12'

function p.main(frame)
    local args = frame:getParent().args
    return p._main(args)
end

function p._main(args)
    local spell = infobox.new(args)
    spell:defineParams {
        { name = 'name', func = 'name' },       -- Module.Infobox default
        { name = 'image', func = { name = imgarg, params = { 'image' }, flag = 'd' } },
        { name = 'release', func = 'release' }, -- Module.Infobox default
        { name = 'removal', func = 'removal' }, -- Module.Infobox default
        { name = 'members', func = { name = membersarg, params = { 'members' }, flag = { 'p' } } },
        { name = 'level', func = { name = levelarg, params = { 'level' }, flag = { 'd' } } },
        -- maximum 5 currently for all kinds of requirements
        { name = 'rune1qty', func = 'numbers' },
        { name = 'rune2qty', func = 'numbers' },
        { name = 'rune3qty', func = 'numbers' },
        { name = 'rune4qty', func = 'numbers' },
        { name = 'rune5qty', func = 'numbers' },
        { name = 'runes', func = { name = runesarg, params = { 'rune', 'rune1', 'rune1qty', 'rune2', 'rune2qty', 'rune3', 'rune3qty', 'rune4', 'rune4qty', 'rune5', 'rune5qty' }, flag = 'd' } },
        { name = 'runes_disp', func = { name = runesdisp, params = { 'runes' }, flag = { 'd' } } },
        { name = 'runes_bucket', func = { name = runesbucket, params = { 'runes' }, flag = { 'd' } } },
        { name = 'experience', func = { name = experiencearg, params = { 'exp' }, flag = { 'p' } } },
        { name = 'unlock', func = 'has_content' },
        { name = 'target', func = { name = targetarg, params = { 'target' }, flag = { 'p' } } },
        { name = 'target_disp', func = { name = targetdisp, params = { 'target' }, flag = { 'd' } } },
        { name = 'cooldown', func = { name = cooldownarg, params = { 'cooldown' }, flag = { 'p' } } },
        { name = 'cooldown_disp', func = { name = cooldowndisp, params = { 'cooldown' }, flag = { 'd' } } },
        { name = 'duration', func = { name = durationarg, params = { 'duration' }, flag = { 'p' } } },
        { name = 'duration_disp', func = { name = durationdisp, params = { 'duration' }, flag = { 'd' } } },
        { name = 'description', func = 'has_content' },
        { name = 'sort', func = 'numbers' },
        { name = 'anim', func = { name = animarg, params = { 'anim', 'animresize' }, flag = { 'p', 'p' } } },
        { name = 'animresize', func = 'has_content' },
        { name = 'sfx', func = { name = sfxarg, params = { 'sfx' }, flag = { 'p' } } },
        { name = 'sfx2', func = { name = sfxarg, params = { 'sfx2' }, flag = { 'p' } } },
        { name = 'id', func = { name = iddisp, params = { 'id' }, flag = 'p' } },
        { name = 'id_bucket', func = { name = idbucket, params = { 'id' }, flag = 'p' } },
        { name = 'chisel_links', func = { name = make_chisel_links, params = { 'id_bucket', 'name' }, flag = 'd' } },
        { name = 'bucketarg', func = { name = bucketarg, params = {
            'name', 'image', 'level', 'experience', 'unlock', 'target',
            'runes', 'cooldown', 'description', 'sort', 'anim', 'sfx', 'id' },
            flag = 'd' } },
    }

	spell:useBucket('infobox_incantation', {
		members = 'is_members_only',
        name = 'name',
        level = 'level',
        experience = 'experience',
        target = 'target',
        runes_bucket = 'runes',
        bucketarg = 'json',
        id_bucket = 'struct_id',
	})

	spell:useBucket('struct_id', {
		id_bucket = 'id'
	})

    spell:create()
    spell:cleanParams()
    spell:addButtonsCaption()

    spell:defineLinks()

    spell:defineName('Infobox Spell')
    spell:addClass('infobox-spell')

    -- PARAMETER: name
    spell:addRow {
        { tag = 'argh', content = 'name', class = 'infobox-header', colspan = '20' }
    }
        :pad(20)

    -- PARAMETER: image
    spell:addRow {
        { tag = 'argd', content = 'image', class = 'infobox-image infobox-full-width-content', colspan = '20' }
    }
        :pad(20)

    -- PARAMETER: release
    -- (update included automatically by infobox)
    spell:addRow {
        { tag = 'th', content = 'Release', colspan = left },
        { tag = 'argd', content = 'release', colspan = right }
    }

    -- PARAMETER: removal
    -- (update included automatically by infobox)
    if spell:paramDefined('removal') then
        spell:addRow {
            { tag = 'th', content = 'Removal', colspan = left },
            { tag = 'argd', content = 'removal', colspan = right }
        }
    end

    -- PARAMETER: members
    spell:addRow {
        { tag = 'th', content = '[[Members]]', colspan = left },
        { tag = 'argd', content = 'members', colspan = right }
    }

    -- PARAMETER: level
    if not spell:paramDefined('level') or spell:paramDefined('level') and spell:param('level') ~= 0 then
        spell:addRow {
            { tag = 'th', content = 'Level', colspan = left },
            { tag = 'argd', content = 'level', colspan = right }
        }
    end

    -- PARAMETER: experience
    spell:addRow {
        { tag = 'th', content = '[[Experience]]', colspan = left },
        { tag = 'argd', content = 'experience', colspan = right }
    }

    -- PARAMETER: cost
    spell:addRow {
        { tag = 'th', content = '[[Runes]]', colspan = left },
        { tag = 'argd', content = 'runes_disp', colspan = right }
    }

    -- PARAMETER: target
    if spell:paramDefined('target') then
        spell:addRow {
            { tag = 'th', content = 'Target', colspan = left },
            { tag = 'argd', content = 'target_disp', colspan = right }
        }
    end

    -- PARAMETER: cooldown
    spell:addRow {
        { tag = 'th', content = 'Cooldown', colspan = left },
        { tag = 'argd', content = 'cooldown_disp', colspan = right }
    }

    -- PARAMETER: duration
    if spell:paramDefined('duration') then
        spell:addRow {
            { tag = 'th', content = 'Duration', colspan = left },
            { tag = 'argd', content = 'duration_disp', colspan = right }
        }
    end

    -- Description subheader
    spell:pad(20)
    spell:addRow { { tag = 'th', content = 'Description', colspan = '20', class = 'description-header infobox-subheader' } }
    spell:addRow {
        { tag = 'argd', content = 'description', colspan = '20' }
    }

    -- Unlock message subheader
    if spell:paramDefined('unlock') then
        -- PARAMETER: unlock
        spell:addRow { { tag = 'th', content = 'Unlock hint', colspan = '20', class = 'description-header infobox-subheader' } }
        spell:addRow {
            { tag = 'argd', content = 'unlock', colspan = '20' }
        }
    end

    -- Animation subheader
    if spell:paramDefined('anim') and spell:param('anim') ~= "None" then
        spell:addRow { { tag = 'th', content = 'Animation', colspan = '20', class = 'animation-header infobox-subheader' } }
        spell:addRow {
            { tag = 'argd', content = 'anim', class = 'infobox-image infobox-full-width-content', colspan = '20' }
        }
    end

    -- PARAMETER: sfx
    if spell:paramDefined('sfx') and spell:param('sfx') ~= "None" then
        spell:addRow { { tag = 'th', content = 'Sound effect', colspan = '20', class = 'sfx-header infobox-subheader' } }
        spell:addRow {
            { tag = 'argd', content = 'sfx', class = 'infobox-full-width-content infobox-media-player', colspan = '20' }
        }
        -- PARAMETER: sfx2
        if spell:paramDefined('sfx2') then
            spell:addRow {
                { tag = 'argd', content = 'sfx2', class = 'infobox-full-width-content infobox-media-player', colspan = '20' }
            }
        end
    end

    -- Advanced data
    spell:addRow {
        { tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '20' },
        meta = { addClass = 'advanced-data' }
    }
        :pad(20, 'advanced-data')
    -- PARAMETER: id
        :addRow {
            { tag = 'th', content = 'Struct ID', colspan = left },
            { tag = 'argd', content = 'id', colspan = right },
            meta = { addClass = 'advanced-data' }
        }

    -- PARAMETER: sort
    if spell:paramDefined('sort') then
        spell:addRow {
            { tag = 'th', content = 'Sort', colspan = left },
            { tag = 'argd', content = 'sort', colspan = right },
            meta = { addClass = 'advanced-data' }
        }
    end

    -- PARAMETER: links
    if infobox.isDefined(spell:param('chisel_links')) then
        spell:addRow {
            { tag = 'th', content = 'Links', colspan = left },
            { tag = 'argd', content = 'chisel_links', colspan = right },
            meta = { addClass = 'advanced-data' }
        }
    end
    spell:pad(20, 'advanced-data')

    spell:addDropLevelVars('necromancy', 'level')

    spell:finish()
    if onmain() then
        local a1 = spell:param('all')
        local a2 = spell:categoryData()
        spell:wikitext(addcategories(a1, a2))
    end

    return spell:tostring()
end

function imgarg(arg)
    if infobox.isDefined(arg) then
        return cleanimg { file = arg, width = 30, height = 30 }
    end

    return nil
end

function animarg(anim, animresize)
    if not infobox.isDefined(anim) or string.lower(anim) == "no" or string.lower(anim) == "none" then
        return "None"
	else
		if string.find(anim, "%[%[File:") then
			return anim
		end
		local size = infobox.isDefined(animresize) and animresize or "300"
		return string.format("[[File:%s|%spx|frameless]]", anim, size)
    end
end

function sfxarg(arg)
    if string.match(arg, "(%.ogg)$") or string.match(arg, "(%.mp3)$") or string.match(arg, "(%.wav)$") then
        local frame = mw.getCurrentFrame()
        return frame:expandTemplate { title = 'Listen inline', args = { filename = arg } }
    elseif string.lower(arg) == "no" or string.lower(arg) == "none" then
        return "None"
    end

    return nil
end

function membersarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    if yesno(arg) then
        return 'Yes'
    else
        return 'No'
    end
end

function levelarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local level = tonumber(arg)

    if level == nil or level < 0 then
        return nil
    end

    var.vardefine('magic_level', level)
    return level
end

function runesarg(rune, rune1, qty1, rune2, qty2, rune3, qty3, rune4, qty4, rune5, qty5)
    local lcarg = rune:lower()
    if infobox.isDefined(rune) and (lcarg == 'no' or lcarg == 'none') then
        return {}
    end

    if not infobox.isDefined(rune1) then
        return nil
    end

    qty1 = infobox.isDefined(qty1) and qty1 or 1
    local runes = { { name = rune1, qty = qty1 } }
    var.vardefine('rune1', rune1)
    var.vardefine('rune1qty', qty1)

    if not infobox.isDefined(rune2) then
        return runes
    end
    qty2 = infobox.isDefined(qty2) and qty2 or 1
    table.insert(runes, { name = rune2, qty = qty2 })
    var.vardefine('rune2', rune2)
    var.vardefine('rune2qty', qty2)

    if not infobox.isDefined(rune3) then
        return runes
    end
    qty3 = infobox.isDefined(qty3) and qty3 or 1
    table.insert(runes, { name = rune3, qty = qty3 })
    var.vardefine('rune3', rune3)
    var.vardefine('rune3qty', qty3)

    if not infobox.isDefined(rune4) then
        return runes
    end
    qty4 = infobox.isDefined(qty4) and qty4 or 1
    table.insert(runes, { name = rune4, qty = qty4 })
    var.vardefine('rune4', rune4)
    var.vardefine('rune4qty', qty4)

    if not infobox.isDefined(rune5) then
        return runes
    end
    qty5 = infobox.isDefined(qty5) and qty5 or 1
    table.insert(runes, { name = rune5, qty = qty5 })
    var.vardefine('rune5', rune5)
    var.vardefine('rune5qty', qty5)
end

function runesdisp(runes)
    if not infobox.isDefined(runes) then
        return nil
    elseif #runes == 0 then
        return 'None'
    end

    local rune_pics = '<span style="white-space:nowrap">'
    for _, rune in ipairs(runes) do
        rune_pics = rune_pics .. string.format('<sup>%d</sup>[[File:%s.png|20px|%s|link=%s]]', rune.qty, rune.name, rune.name, rune.name)
    end
    return rune_pics .. '</span>'
end

function runesbucket(runes)
    if not infobox.isDefined(runes) then
        return nil
    end

    if type(runes) == "table" then
        if #runes == 0 then
            return nil
        end

        local rune_names = {}
        for _, rune in ipairs(runes) do
            table.insert(rune_names, rune.name)
        end

        return table.concat(rune_names, infobox.splitpoint)
    end
end

function experiencearg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local lcarg = string.lower(arg)
    if lcarg == "no" or lcarg == "none" then
        return 0
    elseif lcarg == "varies" then
        return 'Varies'
    end

    local experience = tonumber(arg)

    if experience == nil or experience < 0 then
        return nil
    end

    return experience
end

function targetarg(arg, default)
    if not infobox.isDefined(arg) then
        return default
    end

    local target = string.lower(arg)

    if target == 'single' then
        return 'single'
    elseif target == 'multi' then
        return 'multi'
    elseif target == 'self' then
        return 'self'
    elseif target == 'area' then
        return 'area'
    end

    return default
end

function targetdisp(target)
    if target == 'single' then
        return '[[File:Ability single-target.png|30px|Single-target ability]] Single-target'
    elseif target == 'multi' then
        return '[[File:Ability multi-target.png|30px|Multi-target ability]] Multi-target'
    elseif target == 'self' then
        return '[[File:Ability self-target.png|30px|Self-target ability]] Self-target'
    elseif target == 'area' then
        return '[[File:Ability area-target.png|30px|Area-target ability]] Area-target'
    end

    return nil
end

function cooldownarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local lcarg = string.lower(arg)
    if lcarg == "none" or lcarg == "no" then
        return 0
    elseif lcarg == 'daily' then
        return 'daily'
    elseif lcarg == 'weekly' then
        return 'weekly'
    end

    local cooldown = tonumber(arg)

    if cooldown == nil or cooldown < 0 then
        return nil
    end

    local cooldown2 = math.floor(cooldown)
    if cooldown ~= cooldown2 then
        return nil
    end

    return cooldown
end

function cooldowndisp(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    if arg == 0 then
        return "None"
    elseif arg == 'daily' then
        return 'Reset at 00:00 game time'
    elseif arg == 'weekly' then
        return 'Reset every Wednesday at 00:00 game time'
    else
        return string.format('[[File:Ability timer.png|20px]] %s %s (%ss)', lang:formatNum(arg), arg == 1 and 'tick' or 'ticks', lang:formatNum(arg * 0.6))
    end
end

function durationarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local lcarg = string.lower(arg)
    if lcarg == "none" or lcarg == "no" then
        return 0
    end

    local duration = tonumber(arg)

    if duration == nil or duration < 0 then
        return nil
    end

    local duration2 = math.floor(duration)
    if duration ~= duration2 then
        return nil
    end

    return duration
end

function durationdisp(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    if arg == 0 then
        return "None"
    else
        return string.format('%s %s (%ss)', lang:formatNum(arg), arg == 1 and 'tick' or 'ticks', lang:formatNum(arg * 0.6))
    end
end

function iddisp(id)
    if infobox.isDefined(id) then
        if id:lower() ~= 'no' and id:lower() ~= 'none' then
            local r = string.gsub(id, ', *', ', ')
            return r
        elseif id:lower() == 'no' or id:lower() == 'none' then
            return 'None'
        end
    end
    return nil
end

function idbucket(id)
    if infobox.isDefined(id) and id:lower() ~= 'no' and id:lower() ~= 'none' then
        local r = string.gsub(id, ', *', infobox.splitpoint)
        return r
    end
    return nil
end

function make_chisel_links(id)
    local link1 = 'https://chisel.weirdgloop.org/structs_rs3/'
    if infobox.isDefined(id) then
        link1 = link1 .. "index.html?type=structs&id=" .. id
        return string.format('[%s Struct%s]', link1, id)
    else
        return nil
    end
end

-- bucket JSON
local function to_json_value(value, default)
    if infobox.isDefined(value) then
        return value
    else
        return default
    end
end

function bucketarg(name, image, level, experience, unlock, target,
                runes, cooldown, description, sort, anim, sfx, id)
    local toJSON = {
        name = to_json_value(name),
        image = to_json_value(image),
        level = to_json_value(level),
        exp = to_json_value(experience),
        unlock = to_json_value(unlock),
        target = to_json_value(target),
        runes = to_json_value(runes),
        cooldown = to_json_value(cooldown),
        description = to_json_value(description),
        sort = to_json_value(sort),
        anim = to_json_value(anim),
        sfx = to_json_value(sfx),
        id = to_json_value(id),
    }

    for k, v in pairs(toJSON) do
        if v == '' or (type(v) == 'string' and string.find(v, 'action=edit')) then
            toJSON[k] = nil
        end
    end

    return mw.text.killMarkers(mw.text.jsonEncode(toJSON))
end

function addcategories(args, catargs)
    local ret = { 'Incantations' }

    local cat_map = {
        -- Added if the parameter has content
        defined = {},
        -- Added if the parameter has no content
        notdefined = {
            image = 'Needs image',
            members = 'Needs members status',
            id = 'Incantations missing id',
            anim = 'Incantations missing animation',
            sfx = 'Incantations missing sound effect',
            level = 'Incantations missing level',
            experience = 'Incantations missing experience',
            runes = 'Incantations missing runes',
            cooldown = 'Incantations missing cooldown'
        },
        notdefined_notexclusive = {
            release = 'Needs release date'
        },
    }

    -- Run and add mapped categories
    for n, v in pairs(cat_map.defined) do
        if catargs[n] and catargs[n].one_defined then
            table.insert(ret, v)
        end
    end
    for n, v in pairs(cat_map.notdefined) do
        if catargs[n] and catargs[n].all_defined == false then
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