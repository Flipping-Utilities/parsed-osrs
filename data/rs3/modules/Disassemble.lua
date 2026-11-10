-- <nowiki>
--------------------------
-- Module for [[Template:Disassembly]]
-- Please test changes to this module at [[Module:Disassembly]] first
--------------------------
local p = {}

local infobox = require('Module:Infobox')
local onmain = require('Module:Mainonly').on_main
local tooltips = require('Module:Tooltip')
local yesno = require('Module:Yesno')
local commas = require('Module:Addcommas')._add
local userError = require('Module:User error')
local formatCalcvalue = require('Module:Calcvalue formatter').main
local geprice = require('Module:ExchangeLite').price
local paramtest = require('Module:Paramtest')

-- foundational material data by category
local dis_cat_data = mw.loadData('Module:Disassemble/data')
-- short to full name mappings
local materials = mw.loadData('Module:Disassemble/mats')
-- material chances for each category when disassembling items
local mat_chance_data = mw.loadData('Module:Disassembly material calculator/data')
-- short to material category mappings
local mat_cat_info = mw.loadData('Module:Disassemble/matinfo')

local var = mw.ext.VariablesLua
local isDefined = infobox.isDefined
local has_content = paramtest.has_content
local is_empty = paramtest.is_empty
local default_to = paramtest.default_to
local expr = mw.ext.ParserFunctions.expr

-- cached divine charge price
local _divineChargePrice
local function divineChargePrice()
    if _divineChargePrice == nil then
        _divineChargePrice = geprice('Divine charge')
    end
    return _divineChargePrice
end

-- cached augmentor price
local _augmentorPrice
local function augmentorPrice()
    if _augmentorPrice == nil then
        _augmentorPrice = geprice('Augmentor')
    end
    return _augmentorPrice
end

local getCategory, getCategoryNames, getCategoryLink, getNormalMatChances, getNormalMatList, getX10, getXP, getJunk, getJunkDisp, getCompQty, getItemQty, getSpecialMats, getSpecialMatList, getSpecialMatsGuaranteed, getAugmented, augmentedDisp
local getReturnedItems, getReturnedItemsCost, getBaseCost, estcostarg, estcostperarg, estcosteval, estcostpretty, calcvalueStr, getRecurcost, getRecurcostPer, recurcostEval, recurcostPretty, getSimplifiedPriceForCalculator
local allspecsarg, bucketarg, sigfig, addCategories

-- {item level, 1/1000}
local junk_past_75 = {
    [75] = 42,
    [76] = 38,
    [77] = 34,
    [78] = 30,
    [79] = 27,
    [80] = 23,
    [81] = 20,
    [82] = 17,
    [83] = 14,
    [84] = 12,
    [85] = 10,
    [86] = 8,
    [87] = 6,
    [88] = 4,
    [89] = 3,
}

-- {Invention level, 100%}
local junk_reduction = {
    { 34, 99 },
    { 49, 97 },
    { 64, 95 },
    { 69, 93 },
    { 78, 91 },
    { 83, 88 },
    { 91, 86 },
    { 95, 83 },
    { 105, 80 },
}

local left = '5'
local right = '2'
local full = '7'

local function round(num, dp)
    if type(num) ~= 'number' then
        num = tonumber(num)
        if num == nil then
            return nil
        end
    end

    local mult = 10 ^ (dp or 0)
    if num >= 0 then
        return math.floor(num * mult + 0.5) / mult
    else
        return math.ceil(num * mult - 0.5) / mult
    end
end

-- plink function for materials
local function matRow(builder, matname, chance, total)
    builder:addClass('disassembly-material-row')

    local mc = builder:tag('th')
        :attr {
            ['colspan'] = left,
            ['data-discalc-mat'] = matname,
        }
        :css { ['text-align'] = 'left', ['font-weight'] = 'normal' }

    mc:tag('span')
        :css {
            ['text-align'] = 'center',
            ['display'] = 'inline-block',
            ['width'] = '25px',
            ['padding-right'] = '0.5em',
        }
        :wikitext(string.format('[[File:%s.png|link=%s|25x25px]]', matname, matname))
        :done()

    mc:wikitext(string.format('[[%s]]', matname))

    if type(chance) == 'number' and type(total) == 'number' then
        local frac = chance .. '/' .. total
        local oneover = '1/' .. sigfig(total / chance, 4)
        local percent = sigfig(100 * chance / total, 4)
        local permil = sigfig(1000 * chance / total, 5)
        local permyriad = sigfig(10000 * chance / total, 6)

        builder:tag('td')
            :attr('colspan', right)
            :wikitext(frac)
            :css('text-align', 'right')
            :attr {
                ['title'] = 'These are the chances of getting this material from one of the rolls for this item, after junk. See FAQ for more information.',
                ['data-discalc-chance'] = percent,
                ['data-discalc-chance-percent'] = percent,
                ['data-discalc-chance-permil'] = permil,
                ['data-discalc-chance-permyriad'] = permyriad,
                ['data-discalc-chance-fraction'] = frac,
                ['data-discalc-chance-oneover'] = oneover,

            }
            :done()
    else
        builder:tag('td')
            :attr('colspan', right)
            :wikitext(chance)
            :css('text-align', 'right')
    end
end

local function specRow(special_row, mat, spec_guaranteed)
    if mat.error then
        special_row:tag('th')
            :attr('colspan', left)
            :css { ['text-align'] = 'left', ['font-weight'] = 'normal' }
            :wikitext(mat.name or 'Unknown material')
            :tag('td')
            :attr('colspan', right)
            :wikitext(mat.error)
        return
    end

    special_row:addClass('disassembly-material-row-special')
    local matname, quantity = mat.name, mat.quantity
    local sc = special_row:tag('th')
        :attr {
            ['colspan'] = left,
            ['data-discalc-special-qty'] = quantity,
            ['data-discalc-special-name'] = matname,
        }

    sc:tag('span')
        :css {
            ['text-align'] = 'center',
            ['display'] = 'inline-block',
            ['width'] = '25px',
            ['padding-right'] = '0.5em',
        }
        :wikitext(string.format('[[File:%s.png|link=%s|25x25px]]', matname, matname))
        :done()

    sc:wikitext(string.format('[[%s]] × %s', matname, quantity))
        :css { ['text-align'] = 'left', ['font-weight'] = 'normal' }

    local spcell, sptitle
    local percent, permil, permyriad, frac, oneover

    local approx, chance, denominator = mat.approx, mat.chance, mat.denominator
    if type(chance) == 'number' and type(denominator) == 'number' then
        if chance == denominator then
            percent = 100
            permil = 1000
            permyriad = 10000
            oneover = '100/100'
            frac = ' Always'
            spcell = 'Always'
        else
            percent = sigfig(100 * chance / denominator, 4)
            permil = sigfig(1000 * chance / denominator, 5)
            permyriad = sigfig(10000 * chance / denominator, 6)
            oneover = '1/' .. sigfig(denominator / chance, 4)
            frac = chance .. '/' .. denominator
            spcell = frac
            sptitle = 'The chance of getting this material by disassembling this item - as a special material, this ignores junk chance. See FAQ for more information.'
        end
    elseif chance then
        spcell = chance
    elseif spec_guaranteed == false then
        spcell = 'Not 100%'
        sptitle = 'This special material is not guaranteed, and the actual chance of getting it is not known. See FAQ for more information.'
    else
        spcell = 'Unknown'
        sptitle = 'The chance of receiving this special material is not known, including whether it is guaranteed or not. See FAQ for more information.'
    end

    special_row:tag('td')
        :attr('colspan', right)
        :css { ['text-align'] = 'right', ['vertical-align'] = 'middle' }
        :wikitext(spcell)
        :attr {
            ['title'] = sptitle,
            ['data-discalc-chance-approx'] = approx and 'true' or 'false',
            ['data-discalc-chance-percent'] = percent,
            ['data-discalc-chance-permil'] = permil,
            ['data-discalc-chance-permyriad'] = permyriad,
            ['data-discalc-chance-oneover'] = oneover,
            ['data-discalc-chance-fraction'] = frac,
            ['data-discalc-special-chance'] = percent,
        }
        :done()
end

function p.main(frame)
    local args = frame:getParent().args

    local ret = infobox.new(args)

    ret:defineParams {
        { name = 'name', func = 'name', params = { 'name' } },

        ---
        --- category
        ---
        { name = 'category', func = { name = getCategory, params = { 'category' }, flag = { 'd' } }, dupes = true },
        { name = 'catnames', func = { name = getCategoryNames, params = { 'category' }, flag = { 'd' } }, dupes = true },
        { name = 'catlink', func = { name = getCategoryLink, params = { 'category' }, flag = { 'd' } }, dupes = true },

        ---
        --- normal chance
        ---
        { name = 'mat_chances', func = { name = getNormalMatChances, params = { 'category', 'often', 'sometimes', 'rarely' }, flag = { 'd', 'd', 'd', 'd' } }, dupes = true },
        { name = 'normal_mat_list', func = { name = getNormalMatList, params = { 'mat_chances' } }, dupes = true },

        ---
        --- experience
        ---
        { name = 'x10', func = { name = getX10, params = { 'category', 'x10' } }, dupes = true },
        { name = 'xp', func = { name = getXP, params = { 'level', 'x10' } } },

        ---
        --- junk chance
        ---
        { name = 'level', func = 'numbers', dupes = true },
        { name = 'junk', func = { name = getJunk, params = { 'level' } } },
        { name = 'junk_disp', func = { name = getJunkDisp, params = { 'junk' } } },

        ---
        --- special chance
        ---
        { name = 'special_mats_guaranteed', func = { name = getSpecialMatsGuaranteed, params = { 'special_guaranteed', 'alwaysgivesaspecialmaterial' } } },
        { name = 'special_mats', func = { name = getSpecialMats, params = { 'special', 'category', 'special_mats_guaranteed' } }, dupes = true },
        { name = 'special_mat_list', func = { name = getSpecialMatList, params = { 'special_mats' } }, dupes = true },

        ---
        --- Upfront acquisition cost
        ---
        { name = 'augmented', func = getAugmented },
        { name = 'augmented_disp', func = { name = augmentedDisp, params = { 'augmented' }, flag = { 'd' } } },

        { name = 'base_cost', func = { name = getBaseCost, params = { 'augmented', 'version' }, flag = { 'd' } }, dupes = true },

        { name = 'calcvalue', func = { name = calcvalueStr, params = { 'calcvalue' }, flag = { 'd' } } },

        { name = 'calccomp', func = 'hascontent' },

        -- estcost (estimated creation cost of items not listed on the GE)
        { name = 'estcost', func = { name = estcostarg, params = { 'base_cost', 'estcost', 'calcvalue' }, flag = { 'd', 'd', 'd' } } },
        { name = 'estcostper', func = { name = estcostperarg, params = { 'base_cost', 'estcostper', 'calccomp' }, flag = { 'd', 'd', 'd' } } },

        { name = 'estcost_eval', func = { name = estcosteval, params = { 'base_cost', 'estcost' }, flag = { 'd', 'd', 'd' } } },
        { name = 'estcost_pretty', func = { name = estcostpretty, params = { 'estcost', 'base_cost' }, flag = { 'd' } } },

        ---
        --- Cost recovered
        ---
        { name = 'returnsitems', func = { name = getReturnedItems, params = { 'returnsitems' }, flag = { 'd' } } },
        { name = 'returned_items_cost', func = { name = getReturnedItemsCost, params = { 'returnsitems' }, flag = { 'd' } } },

        ---
        --- Cost of recurring remanufacturing
        ---
        { name = 'recurcost', func = { name = getRecurcost, params = { 'recurcost' }, flag = { 'd' } } },
        { name = 'recurcostper', func = { name = getRecurcostPer, params = { 'recurcostper' }, flag = { 'd', 'd' } } },

        { name = 'recurcost_eval', func = { name = recurcostEval, params = { 'recurcost' }, flag = { 'd' } } },
        { name = 'recurcost_pretty', func = { name = recurcostPretty, params = { 'recurcost' }, flag = { 'd' } } },

        { name = 'simplified_price_for_calculator', func = { name = getSimplifiedPriceForCalculator, params = { 'estcost_eval', 'estcostper', 'returned_items_cost', 'recurcost_eval', 'recurcostper' }, flag = { 'd', 'd', 'd', 'd', 'd' } } },

        { name = 'compqty', func = { name = getCompQty, params = { 'category', 'compqty' }, flag = { 'd', 'p' } } },
        { name = 'itemqty', func = { name = getItemQty, params = { 'category', 'itemqty' }, flag = { 'd', 'p' } } },

        { name = 'nocalc', func = 'hascontent' },
        { name = 'allspecmats', func = allspecsarg },

        { name = 'JSON', func = { name = bucketarg, params = {
            'version', 'name', 'category', 'mat_chances', 'level', 'xp', 'junk', 'itemqty', 'compqty', 'special_mats', 'base_cost', 'estcost', 'estcost_eval', 'returnsitems', 'recurcost', 'estcostper', 'augmented', 'nocalc' }, flag = { 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd' } },
        },
        { name = 'bucketJSON', func = { name = mw.text.nowiki, params = { 'JSON' } } },
    }

    ret:setMaxButtons(8)
    ret:setNameCheck(false)

    ret:create()
    ret:cleanParams()
    ret:customButtonPlacement(true)

    ret:defineLinks { links = {
    	{ 'Template:%s', '[view]' }, 
    	{ 'Template talk:%s', '[talk]' }, 
    	{ 'Template:Disassembly/FAQ', '[FAQ]' }
    } }

    -- Unique anchor for linking from Infobox Item
    ret:addClass('rsw-infobox-disassembly infobox-disassembly-migration')
    ret:attr { id = 'DisassemblyT' }
    ret:float('none')
    ret:css {
        width = 'max-content',
        ['min-width'] = '300px',
        float = 'none',
        margin = '.8em 0',
    }

    ret:useBucket('disassembly', {
        name = 'name',
        category = 'category',
        level = 'level',
        normal_mat_list = 'normal_materials',
        special_mat_list = 'special_materials',
        augmented = 'augmented',
        estcost = 'estimated_cost',
        estcostper = 'estimated_cost_per',
        returnsitems = 'transformed_items',
        recurcost = 'recurring_cost',
        recurcost_cqty = 'recurring_cost_per',
        itemqty = 'required_quantity',
        compqty = 'normal_material_quantity',
        JSON = 'json',
    })

    ret:defineName('Disassembly')

    ret:addButtonsCaption()

    ret:addRow {
        { tag = 'argh', class = 'infobox-header', content = 'name', colspan = full },
    }

    ---
    --- Basic information
    ---
    ret:pad(full)
        :addRow {
            { tag = 'th', content = '[[Template:Disassembly/FAQ#What is disassembly category?|Disassembly category]]', css = { ['text-align'] = 'left' },
                title = 'Disassembly group this item belongs to', colspan = left },
            { tag = 'argd', content = 'catlink', css = { ['text-align'] = 'right' }, colspan = right },
        }
        :addRow {
            { tag = 'th', content = '[[Disassemble#Experience|Disassembly XP]]', css = { ['text-align'] = 'left' },
                title = 'Experience received for disassembling', colspan = left },
            { tag = 'argd', content = 'xp', css = { ['text-align'] = 'right' },
                attr = { ['data-discalc-xp'] = ret:param('xp', 'r') }, colspan = right },
        }

        :addRow {
            { tag = 'th', content = 'Item quantity required', css = { ['text-align'] = 'left' },
                title = 'Amount disassembled per action', colspan = left },
            { tag = 'argd', content = 'itemqty', css = { ['text-align'] = 'right' },
                attr = { ['data-discalc-iqty'] = ret:param('itemqty', 'r') }, colspan = right },
        }

        :pad(full)

    ---
    --- Returned items
    ---
    local returneditems = ret:param('returnsitems', 'd')
    if returneditems[1] and returneditems[1]:find('%S') then
        ret:addRow {
            { tag = 'th', content = 'Returned items', colspan = full, class = 'infobox-subheader',
                css = { ['border-bottom'] = 'none' } },
        }

        ret:pad(full)

        for _, returned in ipairs(returneditems) do
            local rc = ret:tag('tr'):tag('td')
                :attr('colspan', left)

            rc:tag('span')
                :css {
                    ['text-align'] = 'center',
                    ['display'] = 'inline-block',
                    ['width'] = '25px',
                    ['padding-right'] = '0.5em',
                }
                :wikitext(string.format('[[File:%s.png|link=%s|25x25px]]', returned, returned))
                :done()

            rc:wikitext(string.format('[[%s]]', returned))
        end

        ret:pad(full)
    end

    ---
    --- Special chance
    ---
    local spec = ret:param('special_mats', 'd')
    local spec_guaranteed = ret:param('special_mats_guaranteed', 'd')

    -- only add row if specials are there
    if spec[1] then
    	local spec_help = ' <sup class="hover-text noprint" style="border: 0;" title="The number of materials received (if any are received); the number of special materials received is independent of the total materials and junk chance listed below. See FAQ for more information.">[?]</sup>'
        ret:addRow {
            { tag = 'th', content = 'Special chance' .. spec_help, colspan = full, class = 'infobox-subheader' },
        }
        ret:pad(full)

        for _, v in ipairs(spec) do
            specRow(ret:tag('tr'), v, spec_guaranteed)
        end
        ret:pad(full)
    end

    ---
    --- Often/Sometimes/Rarely
    ---
    if spec[1] then
        ret:addRow {
            { tag = 'th', content = 'Normal chance', colspan = full, class = 'infobox-subheader' },
        }
    else
        ret:addRow {
            { tag = 'th', content = 'Material chance', colspan = full, class = 'infobox-subheader' },
        }
    end

    ret:pad(full)

    local compqty = ret:param('compqty', 'r')
    local junk = ret:param('junk', 'r')
    ret
        :addRow {
            { tag = 'th', content = 'Base [[junk]] chance', css = { ['text-align'] = 'left' },
                title = 'Base chance of receiving junk', colspan = left },
            { tag = 'argd', content = 'junk_disp', css = { ['text-align'] = 'right' },
                attr = { ['data-discalc-junk'] = isDefined(junk) and (junk / 10) or nil }, colspan = right },
        }
        :addRow {
            { tag = 'th', content = 'Material count', css = { ['text-align'] = 'left' },
                title = 'The number of materials received normally (not including specials); shown in chat window', colspan = left },
            { tag = 'argd', content = 'compqty', css = { ['text-align'] = 'right' },
                attr = { ['data-discalc-cqty'] = compqty }, colspan = right },
        }

    local chances = ret:param('mat_chances', 'd')
    -- only add row if often mats are there
    for _, v in ipairs(chances) do
        matRow(ret:tag('tr'), v.name, v.chance, chances._total)
    end

    ---
    --- Open calculator
    ---
    local simplified_price_for_calculator = ret:param('simplified_price_for_calculator', 'd')
    if not isDefined(simplified_price_for_calculator) then
        simplified_price_for_calculator = nil
    end

    local augmented = ret:param('augmented', 'd')
    ret:addRow { {
        tag = 'td',
        content = '',
        colspan = full,
        class = 'disassembly-materials-header',
        css = { ['text-align'] = 'center' },
        attr = {
            ['data-discalc-mastermod'] = chances['_master_modifier'],
            ['data-discalc-isaugmented'] = isDefined(augmented) and tostring(augmented) or 'false',
            ['data-discalc-divchprice'] = divineChargePrice(),
            ['data-discalc-calcval'] = simplified_price_for_calculator,
            ['data-discalc-calccomp'] = compqty,
        },
    } }

    ret:addRow {
        { tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '60' },
        meta = { addClass = 'advanced-data' },
    }
        :pad(full, 'advanced-data')

    ret:addRow {
        { tag = 'th', content = 'Raw category', css = { ['text-align'] = 'left', width = '70%' }, colspan = left },
        { tag = 'argd', content = 'category', css = { ['text-align'] = 'right' }, colspan = right },
        meta = { addClass = 'advanced-data' },
    }

    -- not adding this row on the top as it would probably just add confusion with a required level
    ret:addRow {
        { tag = 'th', content = '[[Disassemble#Item level|Item level]] (for junk chance)', css = { ['text-align'] = 'left', width = '70%' }, title = 'Internal item level for disassembly (this is not a requirement)', colspan = left },
        { tag = 'argd', content = 'level', css = { ['text-align'] = 'right' }, colspan = right },
        meta = { addClass = 'advanced-data' },
    }

    if ret:paramDefined('augmented') then
        ret:addRow {
            { tag = 'th', content = 'Augmented', css = { ['text-align'] = 'left', width = '70%' }, colspan = left },
            { tag = 'argd', content = 'augmented_disp', css = { ['text-align'] = 'right' }, colspan = right },
            meta = { addClass = 'advanced-data' },
        }
    end

    ret:pad(full, 'advanced-data')

    ---
    --- Estimated cost
    ---
    local estcost_eval = ret:param('estcost_eval', 'd')
    if isDefined(estcost_eval) then
        ret:addRow {
            { tag = 'th', content = 'Estimated cost', class = 'infobox-subheader', colspan = full },
            meta = { addClass = 'advanced-data' },
        }

        ret:pad(full, 'advanced-data')

        ret:addRow {
            { tag = 'th', content = 'Parsed', css = { ['text-align'] = 'left', width = '70%' }, colspan = left },
            { tag = 'argd', content = 'estcost_eval', css = { ['text-align'] = 'right' }, colspan = right },
            meta = { addClass = 'advanced-data' },
        }

        local estcost_pretty = ret:param('estcost_pretty', 'd')
        if isDefined(estcost_pretty) then
            ret:addRow {
                { tag = 'td', content = '<div style="width:300px">' .. estcost_pretty .. '</div>', css = { ['line-break'] = 'revert' }, colspan = full },
                meta = { addClass = 'advanced-data' },
            }
        else
            ret:pad(full, 'advanced-data')
        end
    end

    -- categories
    if onmain() then
        local a1 = ret:param('all')
        local a2 = ret:categoryData()
        ret:wikitext(addCategories(a1, a2))
    end

    ret:finish()
    return ret:tostring()
end

function sigfig(n, f)
    f = math.floor(f - 1)
    if n == 0 then return 0 end
    local m = math.floor(math.log10(n))
    local v = n / (10 ^ (m - f))
    v = math.floor(v) * 10 ^ (m - f)
    return v
end

-- param parsing

-- gets the category table
function getCategory(arg)
    if not isDefined(arg) then
        return nil
    end

    arg = string.lower(arg or '')

    if arg == 'no' or arg == 'custom' then
        return 'custom'
    elseif dis_cat_data[arg] then
        return arg
    else
        return nil
    end
end

-- category name, for categorising article
function getCategoryNames(arg)
    if not isDefined(arg) then
        return nil
    end


    if arg == 'custom' then
        return 'custom'
    end

    local parent = dis_cat_data[arg]
    if not parent then
        return nil
    end

    return parent.cat or 'custom'
end

-- category link
function getCategoryLink(arg)
    if not isDefined(arg) then
        return nil
    end

    local noneRet = 'None'

    if arg == 'custom' then
        return noneRet
    end

    local parent = dis_cat_data[arg]
    if not parent then
        return nil
    end

    local text = parent.name
    local cat = parent.cat
    if not cat or not text then
        return noneRet
    end

    return string.format('[[:Category:Disassemble category/%s|%s]]', cat, text)
end

-- table of mats
-- only accepts materials that exist in the /mats page
-- arg is value passed to template, unused unless custom
local function parseMats(arg)
    local ret = {}

    if not isDefined(arg) then
        return ret
    end

    arg = string.lower(arg or '')

    for _, v in ipairs(mw.text.split(arg, '%s*,%s*')) do
        local _v = v
            :gsub(' *components?', '')
            :gsub(' *parts?', '')

        local name = materials[_v]
        if name then
            local short = name:lower()
                :gsub(' *components?', '')
                :gsub(' *parts?', '')
            ret[short] = { name = name }
        end
    end

    return ret
end

local function mergeChances(often, sometimes, rarely, source)
    local target = {}

    for k, v in pairs(often) do
        target[k] = v
        -- assuming (20/100, 100/100)
        v.chance = 'Often'
        v.sort = 19.9
    end

    for k, v in pairs(sometimes) do
        target[k] = v
        -- assuming (10/100, 20/100]
        v.chance = 'Sometimes'
        v.sort = 9.9
    end

    for k, v in pairs(rarely) do
        target[k] = v
        -- assuming (0/100, 10/100]
        v.chance = 'Rarely'
        v.sort = 0
    end

    for k, v in pairs(source) do
        if string.sub(k, 1, 1) ~= '_' then
            local parent = target[k]

            if parent == nil then
                parent = { name = materials[k] }
                target[k] = parent
            end

            parent.chance = v
            parent.sort = v
        end
    end

    local sorted = {}

    local incomplete = false
    local common_total = 0
    local uncommon_total = 0
    for k, v in pairs(target) do
        local chance = v.chance
        if type(chance) == 'string' then
            incomplete = true
        end

        if not incomplete then
            if mat_cat_info[k] and mat_cat_info[k] == 'common' then
                common_total = common_total + chance
            else
                uncommon_total = uncommon_total + chance
            end
        end

        table.insert(sorted, v)
    end

    table.sort(sorted, function(a, b)
        if a.sort == b.sort then
            return a.name < b.name
        else
            return a.sort > b.sort
        end
    end)

    if not incomplete then
        local total = common_total + uncommon_total
        sorted._total = total

        if common_total > 0 and uncommon_total > 0 then
            sorted._master_modifier = (total - uncommon_total * 1.2) / common_total
        else
            sorted._master_modifier = 1
        end
    else
        sorted._incomplete = incomplete
    end

    return sorted
end

-- material chances
function getNormalMatChances(cat_name, often_arg, sometimes_arg, rarely_arg)
    local ret = {}

    if not isDefined(cat_name) then
        return ret
    end

    local often_mats, sometimes_mats, rarely_mats, chances
    if cat_name == 'custom' then
        often_mats = parseMats(often_arg)
        sometimes_mats = parseMats(sometimes_arg)
        rarely_mats = parseMats(rarely_arg)
        chances = {}
    else
        local parent = dis_cat_data[cat_name]
        often_mats = parseMats(parent.often)
        sometimes_mats = parseMats(parent.sometimes)
        rarely_mats = parseMats(parent.rarely)
        chances = mat_chance_data[parent.cat or ''] or {}
    end

    return mergeChances(often_mats, sometimes_mats, rarely_mats, chances)
end

function getNormalMatList(mats)
    if not isDefined(mats) then
        return {}
    end

    local mat_names = {}
    for _, mat in ipairs(mats) do
        table.insert(mat_names, mat.name)
    end

    return mat_names
end

local function matchMatString(raw_mat)
    -- Example: armadyl components[1]{24/2000}, armadyl [ ] { 24 / 2000 }, armadyl[]{24}, armadyl[]{often}, armadyl[]{~24/1000}
    local mat, qty, approx, raw_chance, raw_total = raw_mat:match('(%l[%l -]+%l)%s*%[%s*(%d*)%s*%]%s*%{%s*(~?)%s*([%l%d]*)%s*/?%s*(%d*)%s*%}')
    if not is_empty(mat) then
        return default_to(mat), default_to(qty), default_to(approx), default_to(raw_chance), default_to(raw_total)
    end

    -- Example: armadyl components {24/2000}, armadyl {24 / 2000}, armadyl{24}, armadyl{often}, armadyl { ~ 24 / 1000 }
    mat, approx, raw_chance, raw_total = raw_mat:match('(%l[%l -]+%l)%s*%{%s*(~?)%s*([%l%d]*)%s*/?%s*(%d*)%s*%}')
    if not is_empty(mat) then
        return default_to(mat), nil, default_to(approx), default_to(raw_chance), default_to(raw_total)
    end

    -- Example: armadyl components[1], armadyl[ ], armadyl[]
    mat, qty = raw_mat:match('(%l[%l -]+%l)%s*%[%s*(%d*)%s*%]')
    if not is_empty(mat) then
        return default_to(mat), default_to(qty), nil, nil, nil
    end

    -- Example: armadyl components, armadyl
    mat = raw_mat:match('(%l[%l -]+%l)')
    if not is_empty(mat) then
        return default_to(mat), nil, nil, nil, nil
    end

    return nil
end

local function parseEachMatString(ret, raw_mat, approx_set)
    -- Example: armadyl components[1]{24/2000}, ascended[1]{}, bandos[]{10/2000}, avernic, resilient[1]{96/2000}, rumbling[1], armadyl{often}
    local mat, qty, approx, raw_chance, raw_total = matchMatString(raw_mat)
    if not mat then
        mw.log('Found invalid material string: ' .. raw_mat)
        table.insert(ret, { error = userError('It cannot recognise this material: ' .. tostring(raw_mat)) })
        return
    end

    local mat_name = materials[mat]
    if not mat_name then
        mw.log('Found invalid material name: ' .. mat)
        table.insert(ret, { error = userError('It cannot recognise this material: ' .. tostring(raw_mat)) })
        return
    end

    local quantity = tonumber(qty) or '?'

    if raw_chance == nil then
        table.insert(ret, { name = mat_name, quantity = quantity, chance = nil })
        return
    end

    local approx_chance = approx_set[raw_chance]
    if approx_chance then
        table.insert(ret, { name = mat_name, quantity = quantity, chance = approx_chance })
        return
    elseif raw_chance == 'always' then
        table.insert(ret, { name = mat_name, quantity = quantity, chance = 100, denominator = 100 })
        return
    end

    -- Numerator and denominator
    local chance = tonumber(raw_chance)
    local denominator = tonumber(raw_total)
    if chance == nil or denominator == nil then
        mw.log('Found invalid material chance: ' .. tostring(raw_chance))
        table.insert(ret, { name = mat_name, error = userError('It cannot recognise this material: ' .. tostring(raw_mat)) })
        return
    end

    local maybe_approx = approx == '~'
    table.insert(ret, { name = mat_name, quantity = quantity, chance = chance, denominator = denominator, approx = maybe_approx })
end

local function parseMatString(raw_mats)
    local ret = {}

    if not raw_mats then
        return ret
    end

    raw_mats = string.lower(raw_mats)
        :gsub(' ?components?', '')
        :gsub(' ?parts?', '')

    local approx_set = { ['common'] = 'Common', ['uncommon'] = 'Uncommon', ['rare'] = 'Rare', ['very rare'] = 'Very rare' }
    -- local approx_set = { ['often'] = 'Often', ['sometimes'] = 'Sometimes', ['rarely'] = 'Rarely' }
    for _, raw_mat in ipairs(mw.text.split(raw_mats, '%s*,%s*')) do
        parseEachMatString(ret, raw_mat, approx_set)
    end

    return ret
end

-- special materials
-- handled differently from normal mats
function getSpecialMats(arg, category, spec_guaranteed)
    local raw_mats

    if isDefined(arg) then
        raw_mats = arg or ''
    elseif category ~= 'custom' then
        local cat = dis_cat_data[category] or {}
        if cat['special'] then
            raw_mats = cat['special']
        end
    end

    if not raw_mats then
        return {}
    end

    local ret = parseMatString(raw_mats)

    if table.maxn(ret) == 1 and spec_guaranteed == true then
        ret[1].chance = 1
        ret[1].denominator = 1
    end

    return ret
end

function getSpecialMatList(mats)
    if not isDefined(mats) then
        return {}
    end

    local mat_names = {}
    for _, mat in ipairs(mats) do
        table.insert(mat_names, mat.name)
    end

    return mat_names
end

function getSpecialMatsGuaranteed(arg1, arg2)
    if isDefined(arg1) then
        return yesno(arg1)
    elseif isDefined(arg2) then
        return yesno(arg2)
    else
        return nil --unknown
    end
end

-- raw value of junk for parsing and properties
function getJunk(arg)
    local l = tonumber(arg)

    if not l then
        return nil
    end

    if l >= 90 then
        return 0
    end

    if l >= 75 then
        return junk_past_75[l]
    end

    local junk = 1000 - 11 * l

    junk = math.floor(junk)

    return junk
end

local function junkRound(num, dp)
    dp = dp or 0
    local mult = 10 ^ dp
    return string.format('%.' .. dp .. 'f', math.ceil(mult * num) / mult)
end

function getJunkDisp(arg)
    local junk_chance = tonumber(arg)

    if not junk_chance then
        return nil
    end

    local junk_out = '<span class="rsw-discalc-junknum">' .. junkRound(junk_chance / 10, 1) .. '</span>%'

    if junk_chance == 0 then
        return junk_out
    end

    -- add tooltip if not 0 junk
    local junktstr = '<p>Your actual junk chance depends on your junk chance reduction researched.<br />See the table below for all values, and [[Junk]] for more information.</p>'

    local junk_table = mw.html.create('table')
    junk_table:addClass('wikitable')
        :css {
            ['text-align'] = 'right',
            margin = '0 auto',
        }

    junk_table:tag('tr')
        :tag('th')
        :wikitext('Reduction')
        :done()
        :tag('th')
        :wikitext('[[File:Invention-icon.png|link=Invention]]')
        :done()
        :tag('th')
        :wikitext('Junk chance')
        :done()

    junk_table:tag('tr')
        :tag('td')
        :wikitext('None')
        :done()
        :tag('td')
        :wikitext(1)
        :done()
        :tag('td')
        :wikitext(junkRound(junk_chance / 10, 1) .. '%')
        :done()

    for i, v in ipairs(junk_reduction) do
        junk_table:tag('tr')
            :tag('td')
            :wikitext(i)
            :done()
            :tag('td')
            :wikitext(v[1])
            :done()
            :tag('td')
            :wikitext(junkRound(junk_chance * v[2] / 1000, 1) .. '%')
            :done()
    end

    local tooltip_span = tostring(tooltips._span { 'junkchance' .. junk_chance }) .. '&nbsp;&nbsp;'
    local tooltip_div = tooltips._div {
        name = 'junkchance' .. junk_chance,
        content = junktstr .. '\n' .. tostring(junk_table),
    }

    return tooltip_span .. junk_out .. tostring(tooltip_div)
end

-- experience multiplier
-- taken from category
-- uses value passed to template if custom
function getX10(_cat, x10)
    local xx10
    if _cat == 'custom' then
        xx10 = string.lower(x10 or 'no')
    else
        local cat = dis_cat_data[_cat] or {}
        xx10 = tostring(cat.x10)
    end

    return yesno(xx10, false)
end

-- get xp from level
function getXP(_l, x10)
    local l = tonumber(_l) or 1

    local mult = yesno(tostring(x10)) and 10 or 1

    local xp = math.max(math.floor(l * 0.03 * mult * 1000 + 0.009) / 1000, 0.1)

    xp = math.floor(xp * 10 + 0.05) / 10

    local xp_string = tostring(xp)
    if xp % 1 == 0 then
        xp_string = xp_string .. '.0'
    end

    return xp_string
end

-- get number of materials received
function getCompQty(_cat, qty)
    if _cat == 'custom' or _cat == '' then
        return tonumber(qty) or 0
    else
        local cat = dis_cat_data[_cat] or {}
        return tonumber(cat.compqty) or 0
    end
end

-- get number of items disassembled per action
function getItemQty(_cat, qty)
    if _cat == 'custom' or _cat == '' then
        return tonumber(qty) or 1
    else
        local cat = dis_cat_data[_cat] or {}
        return tonumber(cat.itemqty) or 1
    end
end

function getAugmented(arg)
    if not isDefined(arg) then
        return nil
    end

    return yesno(arg)
end

function augmentedDisp(arg)
    if not isDefined(arg) then
        return nil
    end

    if arg then
        return 'Yes'
    else
        return 'No'
    end
end

-- spec amounts
function allspecsarg(arg)
    return string.lower(arg or 'no')
end

-- returned items eg refined anima core
function getReturnedItems(arg)
    if not isDefined(arg) then
        return {}
    end

    return mw.text.split(arg, '%s*;%s*')
end

function getReturnedItemsCost(items)
    if not isDefined(items) then
        return 0
    end

    local cost = 0

    for _, item in ipairs(items) do
        local price = geprice(item)
        if price ~= nil then
            cost = cost + price
        end
    end

    return cost
end

function getBaseCost(augmented, version)
    local gep_raw
    if not isDefined(version) then
        gep_raw = var.var('ItemInfo_gep_DEFAULT')
    else
        gep_raw = var.var('ItemInfo_gep_' .. version)
    end

    if isDefined(gep_raw) then
        local gep = tonumber(gep_raw)
        if gep ~= nil then
            return {
                type = 'gemw',
                value = gep,
                portion = 1,
                quantity = 1,
            }
        else
            local gep_raw_default = var.var('ItemInfo_gep_DEFAULT')
            if isDefined(gep_raw_default) then
                local geps = mw.text.split(gep_raw_default, "%s*,%s*")
                if #geps > 0 then
                    gep = tonumber(geps[#geps - 1])
                end
            end

            if gep ~= nil then
                -- Found versioned prices but the infobox has no version
                -- Use the 'last' price
                mw.log('Found versioned prices but the infobox has no version')
                return {
                    type = 'gemw',
                    value = gep,
                    portion = 1,
                    quantity = 1,
                    error = 'mismatch_version',
                }
            else
                mw.log('Found invalid geprice: ' .. gep_raw)
                return nil
            end
        end
    end

    local shop = tonumber(var.var('ShopInfo_sell_coins_1'))
    if shop ~= nil then
        return {
            type = 'store',
            value = shop,
            portion = 1,
            quantity = 1,
        }
    end

    local recipe = tonumber(var.var('Recipe_profit_coins_1'))
    if recipe ~= nil then
        if augmented then
            -- Skip augmentor only cost
            -- recipe should be a negative number
            if recipe + augmentorPrice() == 0 then
                return nil
            end
        end

        -- For simplicity, assuming the first one in the recipe for display
        local portion = tonumber(var.var('Recipe_output1ea_1')) or 1
        local quantity = tonumber(var.var('Recipe_output1qty_1')) or 1
        return {
            type = 'recipe',
            value = recipe * -1,
            portion = portion,
            quantity = quantity,
        }
    end

    return nil
end

function estcostarg(base_cost, code, calcvalue)
    if isDefined(base_cost) then
        return nil
    end

    if isDefined(code) then
        return mw.text.unstripNoWiki(code)
    end

    if isDefined(calcvalue) then
        return calcvalue
    end

    return nil
end

function estcostperarg(base_cost, estcostper, calccomp)
    if isDefined(base_cost) then
        return base_cost.portion * base_cost.quantity
    end

    if isDefined(estcostper) then
        return tonumber(estcostper) or 1
    end

    if isDefined(calccomp) then
        return tonumber(calccomp) or 1
    end

    return nil
end

local function costeval(code)
    if tonumber(code) then
        return code
    end

    local val = expr(mw.getCurrentFrame():preprocess(code))
    local val_number = tonumber(val)
    if val_number then
        val_number = round(val_number, 2)
    else
        return error('Cannot evaluate "' .. val .. '" as a number');
    end

    return val_number
end

function estcosteval(base_cost, code)
    if isDefined(base_cost) then
        return base_cost.value
    end

    if not isDefined(code) then
        return nil
    end

    return costeval(code)
end

function estcostpretty(code, base_cost)
    if isDefined(base_cost) then
        return base_cost.type
    end

    if not isDefined(code) then
        return nil
    end

    return formatCalcvalue(code)
end

function calcvalueStr(arg)
    if not isDefined(arg) then
        -- empty, nil return
        return nil
    end

    if tonumber(arg) then
        -- already a number, just return that
        return arg
    end

    -- do calcvalue string substitutions
    -- calcvalue strings look like {GEP¦Gold bar} + 1
    -- so recreate the template
    local _arg = string.gsub(arg, '{', '{{')
    _arg = string.gsub(_arg, '}', '}}')
    _arg = string.gsub(_arg, '¦', '|')

    return _arg
end

function getRecurcost(code)
    if not isDefined(code) then
        return nil
    end

    return mw.text.unstripNoWiki(code)
end

function getRecurcostPer(qty)
    if isDefined(qty) then
        return tonumber(qty) or 1
    end

    return nil
end

function recurcostEval(code)
    if not isDefined(code) then
        return nil
    end

    return costeval(code)
end

function recurcostPretty(code)
    if not isDefined(code) then
        return nil
    end

    return formatCalcvalue(code)
end

function getSimplifiedPriceForCalculator(estcost_eval, estcostper, returned_items_cost, recurcost_eval, recurcostper)
    if isDefined(recurcost_eval) then
        if isDefined(recurcostper) then
            recurcostper = recurcostper
        else
            recurcostper = 1
        end

        return round(recurcost_eval / recurcostper, 2)
    end

    if isDefined(estcost_eval) then
        if isDefined(estcostper) then
            estcostper = estcostper
        else
            estcostper = 1
        end

        if isDefined(returned_items_cost) then
            return round((estcost_eval - returned_items_cost) / estcostper, 2)
        else
            return round(estcost_eval / estcostper, 2)
        end
    end

    return nil
end

-- Bucket JSON
--  'version', 'name', 'category', 'mat_chances', 'level', 'xp', 'junk', 'itemqty', 'compqty', 'special_mats', 'base_cost', 'estcost', 'returnsitems', 'recurcost', 'estcostper', 'augmented', 'nocalc'
function bucketarg(version, name, category, mat_chances, level, xp, junk, itemqty, compqty, special_mats, base_cost, estcost, estcost_eval, returnsitems, recurcost, estcostper, augmented, nocalc)
    local pack = {
        category = category,
        item_quantity = itemqty,
        mat_quantity = compqty,
        level = level,
        xp = xp,
        materials = {},
        mastermod = mat_chances['_master_modifier'],
        totalweight = mat_chances['_total'],
    }

    if isDefined(version) then
        pack.version = version
    end

    if isDefined(name) then
        pack.name = name
    end

    if isDefined(nocalc) then
        pack.nocalc = true
    end

    if type(junk) == 'number' then
        pack.junk = { junk / 10 }
        for _, v in ipairs(junk_reduction) do
            table.insert(pack.junk, junk * v[2] / 1000)
        end
    end

    if not mat_chances._incomplete then
        local normal_total = mat_chances._total
        if type(normal_total) == 'number' then
            for _, v in ipairs(mat_chances) do
                local chance_100 = v.chance
                if chance_100 / normal_total >= 1 then
                    pack.materials[v.name] = v.chance / normal_total
                else
                    pack.materials[v.name] = v.chance * 100 / normal_total
                end
            end
        end
    end

    if #special_mats > 0 then
        pack.special = {}
        for _, spec in ipairs(special_mats) do
            if type(spec.denominator) == 'number' then
                pack.special[spec.name] = { quantity = spec.quantity, chance = spec.chance * 100 / spec.denominator }
            end
        end
    end

    if isDefined(base_cost) then
        pack.base_cost_method = base_cost.type
    end

    if isDefined(estcost_eval) then
        if not isDefined(base_cost) or base_cost.type ~= 'gemw' then
            pack.calcvalue = estcost_eval
            if isDefined(estcostper) then
                pack.calccomp = estcostper
            end
        end
    end

    if type(returnsitems) == 'table' and #returnsitems > 0 then
        pack.transformed_items = returnsitems
    end

    if isDefined(recurcost) then
        pack.recurring_cost = recurcost
    end

    if isDefined(augmented) then
        pack.augmented = true
    end

    local jsg, jsonstr = pcall(mw.text.jsonEncode, pack)
    if not jsg then
        return nil
    end

    return jsonstr
end

local function foreach_switched_args(args, func)
    if not args then
        return
    end

    if func(args.d) then
        return
    end

    if args.switches then
        for _, x in ipairs(args.switches) do
            if func(x) then
                return
            end
        end
    end
end

local function args_to_list(args)
    local list = {}
    if args then
        if isDefined(args.d) then
            table.insert(list, args.d)
        end
        if args.switches then
            for _, x in ipairs(args.switches) do
                if isDefined(x) then
                    table.insert(list, x)
                end
            end
        end
    end
    return list
end

local function addJunkCategory(ret, args)
    local dis_per_hour = 3000
    local calc_cat_limit = 19999
    local junkraw_list = args_to_list(args.junk)
    local compqty_lsit = args_to_list(args.compqty)

    for _, vj in ipairs(junkraw_list) do
        if type(vj) == 'number' then
            for _, vc in ipairs(compqty_lsit) do
                if type(vc) == 'number' then
                    if vj / 100 * vc * dis_per_hour > calc_cat_limit then
                        table.insert(ret, 'Disassembly junk calculator')
                        return
                    end
                end
            end
        end
    end
end

-- categories
function addCategories(args, catargs)
    local ret = {}

    -- new table for special materials' names only
    local special_mats_list = args_to_list(args.special_mats)
    if #special_mats_list > 0 then
        table.insert(ret, 'Items that disassemble into special materials')
    end

    for _, special_mats in ipairs(special_mats_list) do
        for _, v in ipairs(special_mats) do
            if v.name then
                table.insert(ret, string.format('Items that disassemble into %s', v.name))
            end

            -- check that all materials have quantity and chance set
            if type(v.quantity) ~= 'number' or type(v.chance) ~= 'number' or type(v.denominator) ~= 'number' then
                table.insert(ret, 'Missing special material information')
            end

            if v.error then
                table.insert(ret, 'Invalid special material information')
            end
        end
    end

    -- iterate over all materials and add categories
    local mat_chances_list = args_to_list(args.mat_chances)
    for _, mat_chances_args in ipairs(mat_chances_list) do
        for _, v in ipairs(mat_chances_args) do
            if v.name then
                table.insert(ret, string.format('Items that disassemble into %s', v.name))
            end
        end
    end

    -- add category based on disassembly category
    -- custom = nothing
    -- not defined = tracking category
    foreach_switched_args(args.catnames, function(catnames)
        if catnames == 'custom' then
            table.insert(ret, 'Custom disassembly category')
        elseif isDefined(catnames) then
            table.insert(ret, string.format('Disassemble category/%s', catnames))
        else
            table.insert(ret, 'Missing disassembly category')
        end
    end)

    foreach_switched_args(args.junk, function(junkraw)
        if junkraw == 0 then
            table.insert(ret, 'Items that cannot disassemble into Junk')
            return true
        end
    end)

    -- if default level isn't defined
    -- see if switches exist
    -- if any switch isn't defined and default isn't, add maintenance cat
    -- if switches don't exist, and default isn't defined, add maintenance cat
	if not isDefined(args.level.d) then
		if args.level.switches then
			for _, v in ipairs(args.level.switches) do
				if not isDefined(v) then
					table.insert(ret, 'Missing Invention disassembly level')
					break
				end
			end
		else
			table.insert(ret, 'Missing Invention disassembly level')
		end
	end

    foreach_switched_args(args.base_cost, function(base_cost)
        if isDefined(base_cost) and base_cost.error == 'mismatch_version' then
            table.insert(ret, 'Erroneous parameter')
            return true
        end
    end)

    if catargs.calcvalue and catargs.calcvalue.one_defined then
        table.insert(ret, 'Disassembly calculator override')
        -- table.insert(ret, 'Pages with deprecated parameters')
    end

    if catargs.calccomp and catargs.calccomp.one_defined then
        table.insert(ret, 'Pages with deprecated parameters')
    end

    if catargs.allspec and catargs.allspec.one_defined then
        table.insert(ret, 'Pages with deprecated parameters')
    end

    foreach_switched_args(args.returnsitems, function(returnsitems)
        if isDefined(returnsitems) and #returnsitems > 0 then
            table.insert(ret, 'Items that disassemble into certain items')
        end
    end)

    -- add to the disassembly calculator for junk if the base junk is more than 20000 per hour
    addJunkCategory(ret, args)

    -- clean return string
    local cats = {}

    local seen_cats = {}
    for _, v in ipairs(ret) do
        if not seen_cats[v] then
            table.insert(cats, string.format('[[Category:%s]]', v))
            seen_cats[v] = true
        end
    end

    return table.concat(cats, '\n')
end

return p
--</nowiki>