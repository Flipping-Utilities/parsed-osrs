local p = {}

local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean
local skillpic = require('Module:Skill clickpic')._main
local yesno = require('Module:Yesno')
local var = mw.ext.VariablesLua
local lang = mw.language.getContentLanguage()
local imgarg, membersarg, spellbookarg, spellbookdisp, daemonheimarg, daemonheimdisp, typearg, typedisp, levelarg, skillothersarg, skillothersdisp, runesarg, runesdisp, runesbucket, experiencearg, experiencedisp, autocastarg, autocastdisp, targetarg, targetdisp
local reqelementarg, elementarg, elementdisp, reqdamagearg, damagearg, damagedisp, damagescalearg, damagescaledisp, animarg, sfxarg, cooldownarg, cooldowndisp, durationarg, durationdisp
local historicalskillarg, historicalskilldisp
local iddisp, idbucket, make_chisel_links, bucketarg, legacybucketarg, addcategories

local left = '8'
local right = '12'
local damage_multiplier = 9.6

local function q_mark(text)
    text = text:gsub('"', '&quot;')
    return ' <sup class="hover-text noprint small" title="' .. text .. '">[?]</sup>'
end

function p.main(frame)
    local args = frame:getParent().args
    return p._main(args)
end

function p.enchant_crossbow_bolt(frame)
    local args = frame:getParent().args
    return p._enchant_crossbow_bolt(args)
end

function p.legacy(frame)
    local args = frame:getParent().args
    return p._legacy(args)
end

function p._main(args)
    local spell = infobox.new(args)
    spell:defineParams {
        { name = 'name', func = 'name' },       -- Module.Infobox default
        { name = 'image', func = { name = imgarg, params = { 'image' }, flag = 'd' } },
        { name = 'release', func = 'release' }, -- Module.Infobox default
        { name = 'removal', func = 'removal' }, -- Module.Infobox default
        { name = 'members', func = { name = membersarg, params = { 'members' }, flag = { 'p' } } },
        { name = 'spellbook', func = { name = spellbookarg, params = { 'spellbook' }, flag = { 'p' } } },
        { name = 'spellbook_disp', func = { name = spellbookdisp, params = { 'spellbook' }, flag = { 'd' } } },
        { name = 'daemonheim', func = { name = daemonheimarg, params = { 'spellbook', 'daemonheim' }, flag = { 'p' } } },
        { name = 'daemonheim_disp', func = { name = daemonheimdisp, params = { 'daemonheim' }, flag = { 'd' } } },
        { name = 'type', func = { name = typearg, params = { 'type' }, flag = { 'p' } } },
        { name = 'type_disp', func = { name = typedisp, params = { 'type' }, flag = { 'd' } } },
        { name = 'level', func = { name = levelarg, params = { 'level' }, flag = { 'd' } } },
        -- maximum 5 currently for all kinds of requirements
        { name = 'skill1lvl', func = 'numbers' },
        { name = 'skill2lvl', func = 'numbers' },
        { name = 'skill3lvl', func = 'numbers' },
        { name = 'skill4lvl', func = 'numbers' },
        { name = 'skill5lvl', func = 'numbers' },
        { name = 'skill_others', func = { name = skillothersarg, params = { 'skill1', 'skill1lvl', 'skill2', 'skill2lvl', 'skill3', 'skill3lvl', 'skill4', 'skill4lvl', 'skill5', 'skill5lvl' }, flag = 'd' } },
        { name = 'skill_others_disp', func = { name = skillothersdisp, params = { 'skill_others' }, flag = { 'd' } } },
        { name = 'rune1qty', func = 'numbers' },
        { name = 'rune2qty', func = 'numbers' },
        { name = 'rune3qty', func = 'numbers' },
        { name = 'rune4qty', func = 'numbers' },
        { name = 'rune5qty', func = 'numbers' },
        { name = 'runes', func = { name = runesarg, params = { 'rune', 'rune1', 'rune1qty', 'rune2', 'rune2qty', 'rune3', 'rune3qty', 'rune4', 'rune4qty', 'rune5', 'rune5qty' }, flag = 'd' } },
        { name = 'runes_disp', func = { name = runesdisp, params = { 'runes' }, flag = { 'd' } } },
        { name = 'runes_bucket', func = { name = runesbucket, params = { 'runes' }, flag = { 'd' } } },
        { name = 'experience', func = { name = experiencearg, params = { 'exp' }, flag = { 'p' } } },
        { name = 'experience_daemonheim', func = { name = experiencearg, params = { 'expdaemonheim' }, flag = { 'p' } } },
        { name = 'experience_disp', func = { name = experiencedisp, params = { 'exp', 'experience_daemonheim' }, flag = { 'd', 'd' } } },
        { name = 'autocast', func = { name = autocastarg, params = { 'autocast' }, flag = { 'p' } } },
        { name = 'autocast_disp', func = { name = autocastdisp, params = { 'autocast' }, flag = { 'd' } } },
        { name = 'unlock', func = 'has_content' },
        { name = 'equipment', func = 'has_content' },
        { name = 'target', func = { name = targetarg, params = { 'target' }, flag = { 'p' } } },
        { name = 'target_disp', func = { name = targetdisp, params = { 'target' }, flag = { 'd' } } },
        { name = 'req_element', func = { name = reqelementarg, params = { 'spellbook', 'type' }, flag = { 'd', 'd' } } },
        { name = 'element', func = { name = elementarg, params = { 'element' }, flag = { 'p' } } },
        { name = 'element_disp', func = { name = elementdisp, params = { 'element' }, flag = { 'd' } } },
        { name = 'hex', func = { name = hexarg, params = { 'hex' }, flag = { 'p' } } },
        { name = 'req_damage', func = { name = reqdamagearg, params = { 'spellbook', 'type' }, flag = { 'd', 'd' } } },
        { name = 'damage', func = { name = damagearg, params = { 'damage' }, flag = { 'p' } } },
        { name = 'damage_disp', func = { name = damagedisp, params = { 'damage' }, flag = { 'd' } } },
        { name = 'damage_scale', func = { name = damagescalearg, params = { 'damage_scale' }, flag = { 'p' } } },
        { name = 'damage_scale_disp', func = { name = damagescaledisp, params = { 'damage_scale' }, flag = { 'd' } } },
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
            'name', 'image', 'level', 'skill_others', 'experience', 'experience_daemonheim', 'unlock', 'spellbook', 'daemonheim', 'type', 'target',
            'runes', 'equipment', 'element', 'damage', 'damage_scale', 'cooldown', 'description', 'sort', 'anim', 'sfx', 'id' },
            flag = 'd' } },
    }

    spell:useBucket('infobox_spell', {
        members = 'is_members_only',
        name = 'name',
        level = 'level',
        spellbook = 'spellbook',
        type = 'type',
        experience = 'experience',
        target = 'target',
        runes_bucket = 'runes',
        bucketarg = 'json',
        id_bucket = 'struct_id',
    })

    spell:useBucket('struct_id', {
        id_bucket = 'id'
    })

    local skill_others_param = spell:param('skill_others')

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

    -- PARAMETER: spellbook
    spell:addRow {
        { tag = 'th', content = '[[Spellbook]]', colspan = left },
        { tag = 'argd', content = 'spellbook_disp', colspan = right }
    }

    -- PARAMETER: daemonheim
    if infobox.isDefined(spell:param('daemonheim_disp')) then
        spell:addRow {
            { tag = 'th', content = '[[Dungeoneering/Magic|Daemonheim]]' .. q_mark('Spell is visible and usable in Daemonheim.'), colspan = left },
            { tag = 'argd', content = 'daemonheim_disp', colspan = right }
        }
    end

    -- PARAMETER: type
    spell:addRow {
        { tag = 'th', content = 'Type', colspan = left },
        { tag = 'argd', content = 'type_disp', colspan = right }
    }

    -- PARAMETER: level
    if not spell:paramDefined('level') or spell:paramDefined('level') and spell:param('level') ~= 0 then
        spell:addRow {
            { tag = 'th', content = 'Level', colspan = left },
            { tag = 'argd', content = 'level', colspan = right }
        }
    end

    if infobox.isDefined(spell:param('skill_others_disp')) then
        spell:addRow {
            { tag = 'th', content = 'Level', colspan = left },
            { tag = 'argd', content = 'skill_others_disp', colspan = right }
        }
    end

    if spell:paramDefined('level_others') then
        spell:addRow {
            { tag = 'th', content = 'Level', colspan = left },
            { tag = 'argd', content = 'level', colspan = right }
        }
    end

    -- PARAMETER: experience
    spell:addRow {
        { tag = 'th', content = '[[Experience]]', colspan = left },
        { tag = 'argd', content = 'experience_disp', colspan = right }
    }

    -- PARAMETER: cost
    spell:addRow {
        { tag = 'th', content = '[[Runes]]', colspan = left },
        { tag = 'argd', content = 'runes_disp', colspan = right }
    }

    -- PARAMETER: autocast
    if spell:paramDefined('autocast') then
        spell:addRow {
            { tag = 'th', content = 'Auto-cast', colspan = left },
            { tag = 'argd', content = 'autocast_disp', colspan = right }
        }
    end

    -- PARAMETER: equipment
    if spell:paramDefined('equipment') then
        spell:addRow {
            { tag = 'th', content = 'Equipment', colspan = left },
            { tag = 'argd', content = 'equipment', colspan = right }
        }
    end

    -- PARAMETER: target
    if spell:paramDefined('target') then
        spell:addRow {
            { tag = 'th', content = 'Target', colspan = left },
            { tag = 'argd', content = 'target', colspan = right }
        }
    end

    -- PARAMETER: element
    if spell:param('req_element') or spell:paramDefined('element') then
        spell:addRow {
            { tag = 'th', content = '[[Attack types#Magic|Element]]', colspan = left },
            { tag = 'argd', content = 'element_disp', colspan = right }
        }
    end

    if spell:param('hex') == 'Yes' then
        spell:addRow {
            { tag = 'th', content = '[[Hex spells|Hex]]', colspan = left },
            { tag = 'td', content = 'Yes', colspan = right }
        }
    end

    -- PARAMETER: damage
    if spell:param('req_damage') or spell:paramDefined('damage') then
        spell:addRow {
            { tag = 'th', content = '[[Elemental spells#Spell damage and scaling|Base damage]]', colspan = left },
            { tag = 'argd', content = 'damage_disp', colspan = right }
        }

        if spell:paramDefined('damage_scale') then
            local damage_scale_param = spell:param('damage_scale')
            if not infobox.isDefined(damage_scale_param) or infobox.isDefined(damage_scale_param) and damage_scale_param > 0 then
                spell:addRow {
                    { tag = 'th', content = 'Scales to level', colspan = left },
                    { tag = 'argd', content = 'damage_scale_disp', colspan = right }
                }
            end
        end
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

    spell:addDropLevelVars('magic', 'level')

    if infobox.isDefined(skill_others_param) then
        for i, skill in ipairs(skill_others_param) do
            spell:addDropLevelVars(spell:param('skill' .. i .. 'lvl'):lower(), skill.name .. ' level')
        end
    end

    spell:finish()
    if onmain() then
        local a1 = spell:param('all')
        local a2 = spell:categoryData()
        spell:wikitext(addcategories(a1, a2))
    end

    return spell:tostring()
end

function p._enchant_crossbow_bolt(args)
    local spell = infobox.new(args)
    spell:defineParams {
        { name = 'name', func = 'name' },       -- Module.Infobox default
        { name = 'image', func = { name = imgarg, params = { 'image' }, flag = 'd' } },
        { name = 'release', func = 'release' }, -- Module.Infobox default
        { name = 'removal', func = 'removal' }, -- Module.Infobox default
        { name = 'members', func = { name = membersarg, params = { 'members' }, flag = { 'p' } } },
        { name = 'spellbook', func = { name = spellbookarg, params = { 'spellbook', 'standard' }, flag = { 'p', 'l' } } },
        { name = 'spellbook_disp', func = { name = spellbookdisp, params = { 'spellbook' }, flag = { 'd' } } },
        { name = 'type', func = { name = typearg, params = { 'type', 'skilling' }, flag = { 'p', 'l' } } },
        { name = 'type_disp', func = { name = typedisp, params = { 'type' }, flag = { 'd' } } },
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
        { name = 'target', func = { name = targetarg, params = { 'target', 'make-x' }, flag = { 'p', 'l' } } },
        { name = 'target_disp', func = { name = targetdisp, params = { 'target' }, flag = { 'd' } } },
        { name = 'description', func = { name = 'has_content', params = { 'Enchant crossbow bolts to have additional magical effects when they are fired.' }, flag = 'l' } },
        { name = 'anim', func = { name = animarg, params = { 'anim', 'animresize' }, flag = { 'p', 'p' } } },
        { name = 'animresize', func = 'has_content' },
        { name = 'sfx', func = { name = sfxarg, params = { 'sfx' }, flag = { 'p' } } },
        { name = 'sfx2', func = { name = sfxarg, params = { 'sfx2' }, flag = { 'p' } } },
        { name = 'id', func = { name = iddisp, params = { 'id' }, flag = 'p' } },
        { name = 'id_bucket', func = { name = idbucket, params = { 'id' }, flag = 'd' } },
        { name = 'chisel_links', func = { name = make_chisel_links, params = { 'id_bucket', 'name' }, flag = 'd' } },
        { name = 'bucketarg', func = { name = bucketarg, params = {
            'name', 'image', 'level', 'skill_others', 'experience', 'experience_daemonheim', 'unlock', 'spellbook', 'daemonheim', 'type', 'target',
            'runes', 'equipment', 'element', 'damage', 'damage_scale', 'cooldown', 'description', 'sort', 'anim', 'sfx', 'id' },
            flag = 'd' } },
    }

    spell:useBucket('infobox_spell', {
        members = 'is_members_only',
        name = 'name',
        level = 'level',
        spellbook = 'spellbook',
        type = 'type',
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

    -- PARAMETER: spellbook
    spell:addRow {
        { tag = 'th', content = '[[Spellbook]]', colspan = left },
        { tag = 'argd', content = 'spellbook_disp', colspan = right }
    }

    -- PARAMETER: type
    spell:addRow {
        { tag = 'th', content = 'Type', colspan = left },
        { tag = 'argd', content = 'type_disp', colspan = right }
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

    -- PARAMETER: autocast
    if spell:paramDefined('autocast') then
        spell:addRow {
            { tag = 'th', content = 'Auto-cast', colspan = left },
            { tag = 'argd', content = 'autocast_disp', colspan = right }
        }
    end

    -- PARAMETER: target
    if spell:paramDefined('target') then
        spell:addRow {
            { tag = 'th', content = 'Target', colspan = left },
            { tag = 'argd', content = 'target', colspan = right }
        }
    end

    -- Description subheader
    spell:pad(20)
    spell:addRow { { tag = 'th', content = 'Description', colspan = '20', class = 'description-header infobox-subheader' } }
    spell:addRow {
        { tag = 'argd', content = 'description', colspan = '20' }
    }

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

    spell:finish()
    if onmain() then
        local a1 = spell:param('all')
        local a2 = spell:categoryData()
        spell:wikitext(addcategories(a1, a2))
    end

    return spell:tostring()
end

function p._legacy(args)
    local spell = infobox.new(args)

    spell:defineParams {
        { name = 'name', func = 'name' },       -- Module.Infobox default
        { name = 'image', func = { name = imgarg, params = { 'image' }, flag = 'd' } },
        { name = 'release', func = 'release' }, -- Module.Infobox default
        { name = 'removal', func = 'removal' }, -- Module.Infobox default
        { name = 'members', func = { name = membersarg, params = { 'members' }, flag = { 'p' } } },
        { name = 'level', func = 'numbers' },
        { name = 'experience', func = { name = 'numbers', params = { 'exp' }, flag = { 'p' } } },
        { name = 'skill', func = { name = historicalskillarg, params = { 'skill' }, flag = { 'p' } } },
        { name = 'skill_disp', func = { name = historicalskilldisp, params = { 'skill', 'level' }, flag = { 'd', 'd' } } },
        { name = 'rune1qty', func = 'numbers' },
        { name = 'rune2qty', func = 'numbers' },
        { name = 'rune3qty', func = 'numbers' },
        { name = 'rune4qty', func = 'numbers' },
        { name = 'rune5qty', func = 'numbers' },
        { name = 'runes', func = { name = runesarg, params = { 'rune', 'rune1', 'rune1qty', 'rune2', 'rune2qty', 'rune3', 'rune3qty', 'rune4', 'rune4qty', 'rune5', 'rune5qty' }, flag = 'd' } },
        { name = 'runes_disp', func = { name = runesdisp, params = { 'runes' }, flag = { 'd' } } },
        { name = 'runes_bucket', func = { name = runesbucket, params = { 'runes' }, flag = { 'd' } } },
        { name = 'damage', func = { name = damagearg, params = { 'damage' }, flag = { 'p' } } },
        { name = 'description', func = 'has_content' },
        { name = 'bucketarg', func = { name = legacybucketarg, params = {
            'name', 'image', 'level', 'skill', 'experience', 'runes', 'damage', 'description' },
            flag = 'd' } },
    }

    spell:useBucket('infobox_spell', {
        members = 'is_members_only',
        name = 'name',
        level = 'level',
        spellbook = 'spellbook',
        type = 'type',
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
    spell:addRow {
        { tag = 'th', content = 'Level', colspan = left },
        { tag = 'argd', content = 'skill_disp', colspan = right }
    }

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

    -- PARAMETER: damage
    if spell:paramDefined('damage') then
        spell:addRow {
            { tag = 'th', content = 'Damage', colspan = left },
            { tag = 'argd', content = 'damage', colspan = right }
        }
    end

    -- Description subheader
    spell:pad(20)
    spell:addRow { { tag = 'th', content = 'Description', colspan = '20', class = 'description-header infobox-subheader' } }
    spell:addRow {
        { tag = 'argd', content = 'description', colspan = '20' }
    }

    spell:finish()
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
    end

    if string.find(anim, "%[%[") or string.find(anim, "<") then
        return anim
    end

    local size = infobox.isDefined(animresize) and animresize or "300"
    return string.format("[[File:%s|%spx|frameless]]", anim, size)
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

function spellbookarg(arg, default)
    if not infobox.isDefined(arg) then
        return default
    end

    local spellbook = string.lower(arg)

    if spellbook == 'standard' or spellbook == 'normal' then
        return 'standard'
    elseif spellbook == 'lunar' then
        return 'lunar'
    elseif spellbook == 'ancient' then
        return 'ancient'
    elseif spellbook == 'daemonheim' then
        return 'daemonheim'
    elseif spellbook == 'all' then
        return 'all'
    else
        return default
    end
end

function spellbookdisp(spellbook)
    if spellbook == 'standard' then
        return '[[Standard spells|Standard]]'
    elseif spellbook == 'lunar' then
        return '[[Lunar spells|Lunar]]'
    elseif spellbook == 'ancient' then
        return '[[Ancient Magicks|Ancient]]'
    elseif spellbook == 'daemonheim' then
        return '[[Dungeoneering/Magic|Daemonheim]]'
    elseif spellbook == 'all' then
        return 'All'
    else
        return nil
    end
end

function daemonheimarg(spellbook_arg, daemonheim_arg)
    if not infobox.isDefined(spellbook_arg) and not infobox.isDefined(daemonheim_arg) then
        return nil
    end

    return yesno(daemonheim_arg, false)
end

function daemonheimdisp(daemonheim_arg)
    if daemonheim_arg then
        return 'Yes'
    else
        return nil
    end
end

function typearg(arg, default)
    if not infobox.isDefined(arg) then
        return default
    end

    local type = string.lower(arg)

    if type == 'combat' then
        return 'combat'
    elseif type == 'teleport' then
        return 'teleport'
    elseif type == 'skilling' then
        return 'skilling'
    elseif type == 'lodestone' then
        return 'lodestone'
    elseif type == 'misc' or type == 'miscellaneous' then
        return 'miscellaneous'
    else
        return default
    end
end

function typedisp(type)
    if type == 'combat' then
        return '[[Combat spells|Combat]]'
    elseif type == 'teleport' then
        return '[[Teleport spells|Teleport]]'
    elseif type == 'skilling' then
        return '[[Skilling spells|Skilling]]'
    elseif type == 'lodestone' then
        return '[[Lodestone Network|Lodestone teleport]]'
    elseif type == 'misc' then
        return 'Miscellaneous'
    else
        return nil
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

function reqelementarg(spellbook, type)
    if type == 'combat' and (spellbook == 'standard' or spellbook == 'ancient') then
        return true
    end

    return false
end

function elementarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local element = string.lower(arg)

    if element == 'air' then
        return 'air'
    elseif element == 'water' then
        return 'water'
    elseif element == 'earth' then
        return 'earth'
    elseif element == 'fire' then
        return 'fire'
    elseif element == 'no' or element == 'none' then
        return 'none'
    else
        return nil
    end
end

function elementdisp(element)
    if element == 'air' then
        return '[[File:Air weakness icon.png|20px|link=Air spells]] [[Air spells|Air]]'
    elseif element == 'water' then
        return '[[File:Water weakness icon.png|20px|link=Water spells]] [[Water spells|Water]]'
    elseif element == 'earth' then
        return '[[File:Earth weakness icon.png|20px|link=Earth spells]] [[Earth spells|Earth]]'
    elseif element == 'fire' then
        return '[[File:Fire weakness icon.png|20px|link=Fire spells]] [[Fire spells|Fire]]'
    elseif element == 'none' then
        return 'None'
    else
        return nil
    end
end

function hexarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    if yesno(arg, false) then
        return 'Yes'
    else
        return nil
    end
end

function reqdamagearg(spellbook, type)
    if type == 'combat' and (spellbook == 'standard' or spellbook == 'ancient') then
        return true
    end

    return false
end

function damagearg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local lcarg = string.lower(arg)
    if lcarg == "no" or lcarg == "none" then
        return 0
    end

    local damage = tonumber(arg)

    if damage == nil or damage < 0 then
        return nil
    end

    var.vardefine('spell_damage', damage)
    return damage
end

function damagedisp(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    if arg == 0 then
        return 'None'
    end

    return lang:formatNum(arg)
end

function damagescalearg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local lcarg = string.lower(arg)
    if lcarg == "no" or lcarg == "none" then
        return 0
    end

    local scale = tonumber(arg)

    if scale == nil or scale < 0 or scale > 120 then
        return nil
    end

    local scale2 = math.floor(scale)
    if scale ~= scale2 then
        return nil
    end

    var.vardefine('spell_damage_scale', scale)
    return scale
end

function damagescaledisp(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    return arg
end

function skillothersarg(skill1, level1, skill2, level2, skill3, level3, skill4, level4, skill5, level5)
    if not infobox.isDefined(skill1) or not infobox.isDefined(level1) then
        return nil
    end

    local skills = { { name = skill1, level = level1 } }

    if not infobox.isDefined(skill2) or not infobox.isDefined(level2) then
        return skills
    end
    table.insert(skills, { name = skill2, level = level2 })

    if not infobox.isDefined(skill3) or not infobox.isDefined(level3) then
        return skills
    end
    table.insert(skills, { name = skill3, level = level3 })

    if not infobox.isDefined(skill4) or not infobox.isDefined(level4) then
        return skills
    end
    table.insert(skills, { name = skill4, level = level4 })

    if not infobox.isDefined(skill5) or not infobox.isDefined(level5) then
        return skills
    end
    table.insert(skills, { name = skill5, level = level5 })
end

function skillothersdisp(skills)
    if not infobox.isDefined(skills) then
        return nil
    end

    local skill_pics = '<ul>'
    for _, v in ipairs(skills) do
        skill_pics = skill_pics .. '<li>' .. skillpic(v.name, v.level, true) .. '</li>'
    end
    return skill_pics .. '</ul>'
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

function experiencedisp(experience, experience_daemonheim)
    if not infobox.isDefined(experience) then
        return nil
    end

    if infobox.isDefined(experience_daemonheim) then
        return string.format('%s<br>%s in Daemonheim', experience, experience_daemonheim)
    else
        return experience
    end
end

function autocastarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    return yesno(arg)
end

function autocastdisp(arg)
    if arg then
        return 'Available'
    else
        return nil
    end
end

function targetarg(arg, default)
    if infobox.isDefined(arg) then
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
    elseif target == 'item' then
        return 'item'
    elseif target == 'make-x' then
        return 'make-x'
    elseif target == 'varies' then
        return 'varies'
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
    elseif target == 'item' then
        return 'Item'
    elseif target == 'make-x' then
        return '[[Make-X]]'
    elseif target == 'varies' then
        return 'Varies'
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

function historicalskillarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local skill = string.lower(arg)

    if skill == 'goodmagic' then
        return 'GoodMagic'
    elseif skill == 'evilmagic' then
        return 'EvilMagic'
    end

    return nil
end

function historicalskilldisp(skill, level)
    return string.format('%d [[%s]]', level, skill)
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

function bucketarg(name, image, level, skill_others, experience, experience_daemonheim, unlock, spellbook, daemonheim, spell_type, target,
                   runes, equipment, element, damage, damage_scale, cooldown, description, sort, anim, sfx, id)
    local toJSON = {
        name = to_json_value(name),
        image = to_json_value(image),
        level = to_json_value(level),
        skill_others = to_json_value(skill_others),
        exp = to_json_value(experience),
        exp_daemonheim = to_json_value(experience_daemonheim),
        unlock = to_json_value(unlock),
        spellbook = to_json_value(spellbook),
        daemonheim = to_json_value(daemonheim),
        type = to_json_value(spell_type),
        target = to_json_value(target),
        runes = to_json_value(runes),
        equipment = to_json_value(equipment),
        element = to_json_value(element),
        damage = to_json_value(damage),
        damage_scale = to_json_value(damage_scale),
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

function legacybucketarg(name, image, level, skill, experience, runes, damage, description)
    local toJSON = {
        name = to_json_value(name),
        image = to_json_value(image),
        skill_others = { { name = to_json_value(skill), level = to_json_value(level) } },
        exp = to_json_value(experience),
        runes = to_json_value(runes),
        damage = to_json_value(damage),
        description = to_json_value(description),
    }

    for k, v in pairs(toJSON) do
        if v == '' or (type(v) == 'string' and string.find(v, 'action=edit')) then
            toJSON[k] = nil
        end
    end

    return mw.text.killMarkers(mw.text.jsonEncode(toJSON))
end

function addcategories(args, catargs)
    local ret = { 'Spells' }

    local cat_map = {
        -- Added if the parameter has content
        defined = {},
        -- Added if the parameter has no content
        notdefined = {
            image = 'Needs image',
            members = 'Needs members status',
            id = 'Spells missing id',
            anim = 'Spells missing animation',
            sfx = 'Spells missing sound effect',
            spellbook = 'Spells missing spellbook',
            type = 'Spells missing type',
            level = 'Spells missing level',
            experience = 'Spells missing experience',
            runes = 'Spells missing runes',
            cooldown = 'Spells missing cooldown'
        },
        notdefined_notexclusive = {
            release = 'Needs release date'
        },
        -- Parameters that have text
        -- map a category to a value
        grep = {
            members = { yes = 'Members\' spells', no = 'Free-to-play spells' },
            spellbook = { standard = 'Standard spells', lunar = 'Lunar spells', ancient = 'Ancient magicks', daemonheim = 'Dungeoneering spells' },
            type = { combat = 'Combat spells', skilling = 'Skilling spells', teleport = 'Teleport spells' },
            element = { air = 'Air spells', water = 'Water spells', earth = 'Earth spells', fire = 'Fire spells' },
            hex = { yes = 'Hex spells' }
        }
    }

    if args.req_damage and args.req_damage.d then
        cat_map.notdefined['damage'] = 'Spells missing damage'
    end

    if args.req_element and args.req_element.d then
        cat_map.notdefined['element'] = 'Spells missing element'
    end

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

    -- searches
    for n, v in pairs(cat_map.grep) do
        for m, w in pairs(v) do
            if args[n] then
                local val = args[n].d
                if infobox.isDefined(val) and string.find(string.lower(tostring(val) or ''), m) then
                    table.insert(ret, w)
                end
                if args[n].switches then
                    for _, x in ipairs(args[n].switches) do
                        if infobox.isDefined(x) and string.find(string.lower(tostring(x)), m) then
                            table.insert(ret, w)
                        end
                    end
                end
            end
        end
    end

    if args.damage and infobox.isDefined(args.damage.d) then
        local damage = args.damage.d
        local level = args.level and args.level.d or 1
        if damage > 0 and tostring(level * damage_multiplier) ~= tostring(damage) then
            table.insert(ret, 'Spells with irregular base damage scaling')
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