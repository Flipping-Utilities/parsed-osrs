-- <nowiki>
--------------------------
-- Module for {{Infobox Scenery}}
-- Please test changes to this module at [[Module:Infobox scenery/sandbox]] first
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local paramtest = require('Module:Paramtest')
local cleanimg = require('Module:Clean image').clean
local infobox = require('Module:Infobox')

local imgarg, imgback, txtarg, sizearg, sizedisp, examinearg, optionarg, optionbucket, maparg, mapdisp, mapmarkerarg
local restrictionarg, restrsurfarg, iddisp, idbucket, addcategories, mainiddisp, image_bucket, leaguesArg

-- location restriction
local restriction_map = {
    surface = 'surface',
    dungeoneering = 'dungeoneering',
    dg = 'dungeoneering',
    daemonheim = 'dungeoneering',
    quest = 'quest',
    minigame = 'minigame',
    activity = 'minigame',
    beta = 'removed',
    gone = 'removed',
    removed = 'removed',
    limited = 'limited',
    ['time limited'] = 'limited',
    th = 'microtransaction',
    sof = 'microtransaction',
    ['treasure hunter'] = 'microtransaction',
    ['squeal of fortune'] = 'microtransaction',
    cache = 'cache'
}

function p.main(frame)
    local args = frame:getParent().args
    local ret = infobox.new(args)

    ret:defineParams {
        { name = 'name',               func = 'name' },
        { name = 'aka',                func = 'has_content' },
        { name = 'image',              func = { name = imgarg, params = { 'image' }, flag = { 'd' } } },
        { name = 'image_bucket',       func = { name = image_bucket, params = { 'image' }, flag = 'p' } },
        { name = 'imagebackground',    func = { name = imgback, params = { 'imagebackground' }, flag = { 'd' } },                                                                 dupes = true },
        { name = 'vanchor',            func = { name = 'has_content', params = { 'version' }, flag = 'p' } },
        { name = 'release',            func = 'release' },
        { name = 'removal',            func = 'removal' },
        { name = 'members',            func = 'has_content' },
        { name = 'quest',              func = { name = 'has_content', params = { 'quest', 'No' }, flag = { 'd', 'r' } } },
        { name = 'width',              func = { name = sizearg, params = { 'width' }, flag = 'p' } },
        { name = 'length',             func = { name = sizearg, params = { 'length' }, flag = 'p' } },
        { name = 'size',               func = { name = sizedisp, params = { 'width', 'length' }, flag = 'p' } },
        { name = 'location',           func = { name = txtarg, params = { 'location' }, flag = 'd' } },
        { name = 'leagueRegion', func = leaguesArg },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
        { name = 'examine',            func = { name = examinearg, params = { 'examine' }, flag = { 'd' } } },
        { name = 'options',            func = { name = optionarg, params = { 'options', 'actions', 'examine' }, flag = 'd' } },
        { name = 'options_bucket',     func = { name = optionbucket, params = { 'options', 'actions', 'examine' }, flag = { 'p', 'p', 'd' } },                                    dupes = true },
        { name = 'map',                func = { name = maparg, params = { 'map' }, flag = { 'd' } } },
        { name = 'mapdisp',            func = { name = mapdisp, params = { 'map' }, flag = { 'd' } },                                                                             dupes = true },
        { name = 'map_marker',         func = { name = mapmarkerarg, params = { 'marker' }, flag = { 'd' } } },
        { name = 'restriction',        func = restrictionarg },
        { name = 'restrictionsurface', func = { name = restrsurfarg, params = { 'restriction', 'restriction', 'quest' }, flag = { 'd', 'p', 'd' } } },
        { name = 'id',                 func = { name = mainiddisp, params = { 'id', 'histid' }, flag = 'p' } },
        { name = 'npcid',              func = { name = iddisp, params = { 'npcid' }, flag = 'p' } },
        { name = 'histid',             func = { name = iddisp, params = { 'histid' }, flag = 'p' } },
        { name = 'id_bucket',          func = { name = idbucket, params = { 'id' }, flag = 'p' },                                                                                 dupes = true },
        { name = 'npcid_bucket',       func = { name = idbucket, params = { 'npcid' }, flag = 'p' },                                                                              dupes = true },
        { name = 'histid_bucket',      func = { name = idbucket, params = { 'histid' }, flag = 'p' },                                                                             dupes = true },
        { name = 'chisel_links',       func = { name = 'make_chisel_links', params = { 'name', '<br>', 'mrod', 'id', 'mrnd', 'npcid' }, flag = { 'd', 'r', 'r', 'p', 'r', 'p' } } },
        { name = 'hist_chisel_links',  func = { name = 'make_chisel_links', params = { 'name', '<br>', 'mrod', 'histid' }, flag = { 'd', 'r', 'r', 'p', 'r', 'p' } } },
        { name = 'f2pvisible',         func = 'has_content' },
        { name = 'interactive',        func = 'has_content' },
        { name = 'shopversion',        func = 'has_content' },
    }

    ret:useBucket('infobox_scenery', {
        id_bucket = 'object_id',
        histid_bucket = 'historical_object_id',
        npcid_bucket = 'npc_id',
        vanchor = 'version_anchor',
        name = 'object_name',
        image_bucket = 'image',
        members = 'is_members_only',
        location = 'scenery_location',
        restriction = 'location_restriction',
        options_bucket = 'options',
        examine = 'examine',
        leagueRegion_raw = 'league_region'
    })
    ret:useBucket('npc_id', {
        npcid_bucket = 'id'
    })
    ret:useBucket('object_id', {
        id_bucket = 'id'
    })

    ret:setMaxButtons(6)
    ret:create()
    ret:cleanParams()
    ret:customButtonPlacement(true)

    ret:linkParams {
        image = 'imagebackground'
    }

    ret:defineLinks()

    ret:defineName('Infobox Scenery')
    ret:addClass('infobox-scenery')

    ret:addButtonsCaption()

    -- PARAMETER: name
    ret:addRow {
        { tag = 'argh', content = 'name', class = 'infobox-header', colspan = '20' }
    }
        :pad(20)

    -- PARAMETER: image
    ret:addRow {
        { tag = 'argd', content = 'image', class = 'infobox-image infobox-full-width-content', colspan = '20' },
        meta = { addClass = ret:param('imagebackground', 'r') }
    }
        :pad(20)

    -- PARAMETER: release
    -- (update included automatically by infobox)
    ret:addRow {
        { tag = 'th',   content = 'Release', colspan = '8' },
        { tag = 'argd', content = 'release', colspan = '12' }
    }

    -- PARAMETER: removal
    if ret:paramDefined('removal') then
        ret:addRow {
            { tag = 'th',   content = 'Removal', colspan = '8' },
            { tag = 'argd', content = 'removal', colspan = '12' }
        }
    end

    -- PARAMETER: aka
    if ret:paramDefined('aka') then
        ret:addRow {
            { tag = 'th',   content = '[[Slang dictionary|AKA]]', colspan = '8' },
            { tag = 'argd', content = 'aka',                      colspan = '12' }
        }
    end

    -- PARAMETER: members
    ret:addRow {
        { tag = 'th',   content = '[[Members]]', colspan = '8' },
        { tag = 'argd', content = 'members',     colspan = '12' }
    }

    -- PARAMETER: quest
    ret:addRow {
        { tag = 'th',   content = '[[Quests|Quest]]', colspan = '8' },
        { tag = 'argd', content = 'quest',            colspan = '12' }
    }

    -- PARAMETER: width, length
    if ret:paramDefined('width', 'all') or ret:paramDefined('length', 'all') then
        ret:addRow {
            { tag = 'th',   content = '[[Game square|Size]]', colspan = '8' },
            { tag = 'argd', content = 'size',                 colspan = '12' }
        }
    end

    -- PARAMETER: location
    ret:addRow {
        { tag = 'th',   content = '[[Locations|Location]]', colspan = '8' },
        { tag = 'argd', content = 'location',               colspan = '12' }
    }

	-- PARAMETER: leagueRegion
	if ret:paramDefined('leagueRegion', 'all') then
		local leagues = require('Module:LeagueRegion')
		ret:addRow{
			{ tag = 'th', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] region', css = { ['vertical-align'] = 'middle' }, colspan = '8' },
			{ tag = 'argd', content = 'leagueRegion', css = { ['vertical-align'] = 'middle' }, colspan = '12' },
			meta = {addClass = 'leagues-global-flag'}
		}
	end

    -- PARAMETER: options (formerly actions)
    ret:addRow {
        { tag = 'th',   content = '[[Choose Option|Options]]', colspan = '8' },
        { tag = 'argd', content = 'options',                   colspan = '12' }
    }

    -- PARAMETER: examine
    ret:addRow {
        { tag = 'th',   content = '[[Examine]]', colspan = '8' },
        { tag = 'argd', content = 'examine',     colspan = '12' }
    }

    -- PARAMETER: marker
    if ret:paramDefined('map_marker', 'all') then
        ret:addRow {
            { tag = 'th',   content = '[[Minimap#Markers|Minimap marker]]', colspan = '8' },
            { tag = 'argd', content = 'map_marker',                         colspan = '12' }
        }
    end

    ret:pad(20)

    -- PARAMETER: map
    local map_defined = ret:paramGrep('mapdisp', function(x) return (x or 'false') ~= 'false' end)
    if map_defined == true then
        ret:addRow {
            { tag = 'th', content = 'Map', class = 'infobox-subheader', colspan = '20' }
        }
        ret:addRow {
            { tag = 'argd', content = 'map', class = 'infobox-image infobox-full-width-content', colspan = '20' }
        }
    end

    -- Advanced data
    ret:addRow {
        { tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '20' },
        meta = { addClass = 'advanced-data' } }
        :pad(20, 'advanced-data')

    local has_id = ret:paramGrep('id', function(x) return string.lower(x or 'none') ~= 'none' end)
    if has_id then
        ret:addRow {
            { tag = 'th',   content = 'Object ID', colspan = '8' },
            { tag = 'argd', content = 'id',        colspan = '12' },
            meta = { addClass = 'advanced-data' }
        }
    end

    local has_npcid = ret:paramDefined('npcid', 'all')
    if has_npcid then
        ret:addRow {
            { tag = 'th',   content = 'NPC ID', colspan = '8' },
            { tag = 'argd', content = 'npcid',  colspan = '12' },
            meta = { addClass = 'advanced-data' }
        }
    end

    ret:addRow {
        { tag = 'th',   content = 'Links',        colspan = '8' },
        { tag = 'argd', content = 'chisel_links', colspan = '12' },
        meta = { addClass = 'advanced-data' }
    }

    local has_histid = ret:paramDefined('histid', 'all')
    if has_histid then
        ret:addRow {
            { tag = 'th',   content = 'Historical ID', colspan = '8' },
            { tag = 'argd', content = 'histid',        colspan = '12' },
            meta = { addClass = 'advanced-data' }
        }
        ret:addRow {
            { tag = 'th',   content = 'Historical Links',  colspan = '8' },
            { tag = 'argd', content = 'hist_chisel_links', colspan = '12' },
            meta = { addClass = 'advanced-data' }
        }
    end

    ret:pad(20, 'advanced-data')

    -- Save vars for use by later templates
    if ret:paramDefined('shopversion', 'all') then
    	ret:addVersionBasedVars('ShopInfo_LeagueRegion', 'shopversion', 'leagueRegion_raw')
    	ret:addVersionBasedVars('LeagueRegion', 'dropversion', 'leagueRegion_raw')
    	
        ret:addVersionBasedVars('ShopInfo_location', 'shopversion', 'location')
        ret:addVersionBasedVars('ShopInfo_members', 'shopversion', 'members')
        
    else
    	ret:addVersionBasedVars('ShopInfo_LeagueRegion', 'shopversion', 'leagueRegion_raw')
    	ret:addVersionBasedVars('LeagueRegion', 'dropversion', 'leagueRegion_raw')
    	
        ret:addVersionBasedVars('ShopInfo_location', 'vanchor', 'location')
        ret:addVersionBasedVars('ShopInfo_members', 'vanchor', 'members')
    end

    ret:finish()

    if onmain() then
        local a1 = ret:param('all')
        local a2 = ret:categoryData()
        ret:wikitext(addcategories(a1, a2))
    end

    return ret:tostring()
end

function imgarg(arg)
    if infobox.isDefined(arg) then
        return cleanimg { file = arg, width = 300, height = 300 }
    end

    return nil
end

function imgback(arg)
    if infobox.isDefined(arg) and yesno(arg) then
        return 'infobox-imgbg'
    end

    return ''
end

function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end

function txtarg(txt)
    if not infobox.isDefined(txt) then
        return nil
    end

    local trimmed_text = mw.text.trim(txt)
    if string.sub(trimmed_text, 1, 1) == '*' then
        local ret = mw.html.create('ul')
        for x in mw.text.gsplit(trimmed_text, '\n%*%s*') do
            local _x = string.gsub(x, '^%*%s*', '')
            ret:tag('li'):wikitext(_x)
        end
        return tostring(ret)
        -- txt = '\n'..txt..'\n'
    end
    return trimmed_text
end

function optionarg(arg, arg_old, exam)
    if not infobox.isDefined(arg) then
        if infobox.isDefined(arg_old) then
            arg = arg_old
        else
            return nil
        end
    end

    local arg_low = arg:lower()
    if arg_low == 'none' or arg_low == 'examine' then
        if infobox.isDefined(exam) then
            local estr = exam:lower()
            if estr == 'no' or estr == 'none' or estr == 'n/a' then
                return 'None'
            end
        end

        return 'Examine'
    end

    local ret = {}
    local has_examine = false
    for x in mw.text.gsplit(arg, ',') do
        table.insert(ret, mw.text.trim(x))
        has_examine = has_examine or (string.find(x, 'Examine') ~= nil)
    end

    if not has_examine then
        table.insert(ret, 'Examine')
    end

    local ret_str = table.concat(ret, ', ')
    ret_str = mw.ustring.gsub(ret_str, '%[*[Ww]alk [Hh]ere%]*', '[[Walk here|Walk here]]')
    ret_str = mw.ustring.gsub(ret_str, '%[*[Ee]xamine%]*', 'Examine')

    return ret_str
end

function optionbucket(arg, arg_old, exam)
    if not infobox.isDefined(arg) then
        if infobox.isDefined(arg_old) then
            arg = arg_old
        else
            return nil
        end
    end

    local arg_low = arg:lower()
    if arg_low == 'none' or arg_low == 'examine' then
        if infobox.isDefined(exam) then
            local estr = exam:lower()
            if estr == 'no' or estr == 'none' or estr == 'n/a' then
                return 'None'
            end
        end

        return 'Examine'
    end

    local r = string.gsub(arg, ',%s*', infobox.splitpoint)
    r = mw.ustring.gsub(r, '%[*[Ww]alk [Hh]ere%]*', 'Walk here')
    r = mw.ustring.gsub(r, '%[*[Ee]xamine%]*', 'Examine')
    if not r:find('Examine') then
        r = r .. infobox.splitpoint .. 'Examine'
    end

    return r
end

function sizearg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local arg_num = tonumber(arg)
    if arg_num == nil or arg_num <= 1 or arg_num ~= math.floor(arg_num) then
        return nil
    end

    return arg_num
end

function sizedisp(width, length)
    if not (infobox.isDefined(width) or infobox.isDefined(length)) then
        return nil
    end

    local width_or_default = infobox.isDefined(width) and width or 1
    local length_or_default = infobox.isDefined(length) and length or 1
    return string.format('%sx%s', width_or_default, length_or_default)
end

function examinearg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local txt = mw.text.trim(arg)
    if string.sub(txt, 1, 1) ~= '*' then
        return txt
    end

    -- txt = '\n'..txt..'\n'
    local ret = mw.html.create('ul')
    for x in mw.text.gsplit(txt, '\n%*%s*') do
        local _x = string.gsub(x, '^%*%s*', '')
        ret:tag('li'):wikitext(_x)
    end
    return tostring(ret)
end

function mapmarkerarg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local low = arg:lower()
    if (yesno(low) == false) or (low == 'none') or (low == 'hide') then
        return "Hidden"
    elseif (yesno(low) == true) then
        return "Shown"
    else
        return arg
    end
end

function maparg(arg)
    if not infobox.isDefined(arg) then
        return nil
    end

    local low = arg:lower()
    if (yesno(low) == false) or (low == 'none') then
        return "''No map to display.''"
    elseif low == 'name' then
        return string.format('[[File:%s location.png]]', mw.title.getCurrentTitle().text)
    elseif string.find(low, '.png') then
        return cleanimg { file = arg, width = 250 }
    else
        return arg
    end
end

function mapdisp(map)
    return tostring(infobox.isDefined(map) and map ~= "''No map to display.''")
end

function restrictionarg(arg)
    if paramtest.is_empty(arg) then
        return nil
    end

    return restriction_map[string.lower(arg)]
end

function restrsurfarg(cleaned)
    if infobox.isDefined(cleaned) then
        return nil
    end

    return restriction_map.surface
end

function mainiddisp(id, histid)
    if not infobox.isDefined(id) and infobox.isDefined(histid) then
        return 'None'
    end

    return iddisp(id)
end

function image_bucket(arg)
    local _img = {}
    local _arg = arg:gsub('%[', ''):gsub('%]', ''):gsub('[Ff]ile:', '')

    for i in string.gmatch(_arg, '.-%.png') do
        table.insert(_img, 'File:' .. i)
    end

    for i in string.gmatch(_arg, '.-%.gif') do
        table.insert(_img, 'File:' .. i)
    end

    if #_img == 0 then
        return nil
    end

    return table.concat(_img, '&&SPLITPOINT&&')
end

function iddisp(id)
    if not infobox.isDefined(id) then
        return nil
    end

    local id_low = id:lower()
    if id_low ~= 'no' and id_low ~= 'none' then
        return string.gsub(id, ', *', ', ')
    elseif id_low == 'no' or id_low == 'none' then
        return 'None'
    end

    return nil
end

function idbucket(id)
    if not infobox.isDefined(id) then
        return nil
    end

    local id_low = id:lower()
    if id_low ~= 'no' and id_low ~= 'none' then
        return string.gsub(id, ', *', infobox.splitpoint)
    end

    return nil
end

-- Categories
function addcategories(args, catargs)
    local ret = {}
    table.insert(ret, 'Scenery')

    -- ID based categories
    local misID = {}
    local cachedScenery = false
    if args.id.switches then
        for i, v in ipairs(args.id.switches) do
            if infobox.isDefined(v) and v ~= 'None' then
                cachedScenery = true
            else
                misID[i] = true
            end
        end
    elseif infobox.isDefined(args.id.d) and args.id.d ~= 'None' then
        cachedScenery = true
    else
        misID[0] = true
    end

    if cachedScenery then
        table.insert(ret, 'Cache scenery')
    end

    if args.histid.switches then
        for i, v in ipairs(args.histid.switches) do
            if infobox.isDefined(v) and v ~= "None" and misID[i] then
                misID[i] = false
            end
        end
    end

    local cachedNpc = false
    if args.npcid.switches then
        for i, v in ipairs(args.npcid.switches) do
            if infobox.isDefined(v) and v ~= 'None' then
                cachedNpc = true
                if misID[i] then
                    misID[i] = false
                end
            end
        end
    elseif infobox.isDefined(args.npcid.d) and args.npcid.d ~= 'None' then
        cachedNpc = true
        misID = {}
    end

    if cachedNpc then
        table.insert(ret, 'Cache NPCs')
    end

    for _, v in pairs(misID) do
        if v then
            table.insert(ret, 'Needs scenery ID')
            break
        end
    end

    -- Manual or option-based interactivity
    local max_i = (args.interactive.switches and #args.interactive.switches) or
        (args.options_bucket.switches and #args.options_bucket.switches) or 1
    for i = 1, max_i do
        local override = yesno(args.interactive.switches and args.interactive.switches[i] or args.interactive.d, nil)
        local options = args.options_bucket.switches and args.options_bucket.switches[i] or args.options_bucket.d

        if override == true then
            table.insert(ret, 'Interactive scenery')
        elseif override == false then
            table.insert(ret, 'Non-interactive scenery')
        elseif infobox.isDefined(options) and (options == 'Examine' or options == 'None') then
            table.insert(ret, 'Non-interactive scenery')
        elseif infobox.isDefined(options) then
            table.insert(ret, 'Interactive scenery')
        end
    end

    -- Non-examinable scenery
    if args.examine.switches then
        for _, v in ipairs(args.examine.switches) do
            if infobox.isDefined(v) and v == 'N/A' then
                table.insert(ret, 'Non-examinable scenery')
            end
        end
    elseif infobox.isDefined(args.examine.d) and args.examine.d == 'N/A' then
        table.insert(ret, 'Non-examinable scenery')
    end

    if args.f2pvisible.switches then
        for _, v in ipairs(args.f2pvisible.switches) do
            if infobox.isDefined(v) and yesno(v) then
                table.insert(ret, 'Scenery that is visible but not interactive in free-to-play')
                break
            end
        end
    elseif infobox.isDefined(args.f2pvisible.d) and yesno(args.f2pvisible.d) then
        table.insert(ret, 'Scenery that is visible but not interactive in free-to-play')
    end

    local cat_map = {
        -- Added if the parameter has content
        defined = {
            aka = 'Pages with AKA',
            histid = "Objects with historical IDs",
			leagueRegion = 'Pages with League region',
        },
        -- Added if the parameter has no content
        notdefined = {
            image = 'Needs scenery image',
            members = 'Needs members status',
            release = 'Needs release date',
            options = 'Needs options added',
            examine = 'Needs scenery examine added',
            map = 'Needs map',
            location = 'Needs location',
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

    -- quest restriction
    -- first look for a link
    if args.quest.d:find('%[%[') then
        table.insert(ret, 'Quest scenery')
    end

    if args.quest.switches then
        for _, v in ipairs(args.quest.switches) do
            if v:find('%[%[') then
                table.insert(ret, 'Quest scenery')
                break
            end
        end
    end

    -- quest restriction pt 2
    -- look for a truthy value
    if args.quest.switches then
        for _, v in ipairs(args.quest.switches) do
            if infobox.isDefined(v) and yesno(v) then
                table.insert(ret, 'Quest scenery')
                break
            end
        end
    elseif infobox.isDefined(args.quest.d) and yesno(args.quest.d) then
        table.insert(ret, 'Quest scenery')
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
-- </nowiki>