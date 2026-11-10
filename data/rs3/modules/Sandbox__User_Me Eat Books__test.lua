local p = {}

local commas   = require('Module:Addcommas')._add
local currency = require('Module:Currency')._amount
local exchange = require('Module:Exchange')
local plinkt   = require('Module:Plink')._plinkt
local skillpic = require('Module:Skill clickpic')._main
local hc       = require('Module:Paramtest').has_content

require('Module:Mw.html extension')

local price_cache = {}

local function normalize(value, lower_case)
    if not hc(value) then
        return ''
    end

    if lower_case then
        return mw.ustring.lower(mw.text.trim(value))
    end

    return mw.text.trim(value)
end

local function plinkqty(item_name, image, qty)
    local image_text = ''

    if hc(image) then
        image_text = string.format(
            '[[File:%s|link=%s|alt=RuneScape inventory image of %s]]',
            image,
            item_name,
            item_name
        )
    end

    return mw.html.create()
        :td {
            string.format('%s &#215;', commas(qty)),
            css = {
                ['white-space'] = 'pre',
                ['text-align'] = 'right'
            }
        }
        :td {
            image_text,
            css = { ['text-align'] = 'center' }
        }
        :td {
            string.format('[[%s|%s]]', item_name, item_name),
            css = { ['text-align'] = 'left' }
        }
        :allDone()
end

local function get_plinkt_image_args(image)
    if not hc(image) then
        return nil
    end

    image = normalize(image, false)

    local file_name = mw.ustring.match(
        image,
        '^(.*)%.[Pp][Nn][Gg]$'
    )

    if file_name then
        return {
            pic = file_name
        }
    end

    file_name = mw.ustring.match(
        image,
        '^(.*)%.[Gg][Ii][Ff]$'
    )

    if file_name then
        return {
            pic = file_name,
            gif = true
        }
    end

    error('Invalid image file type. Only .png and .gif files are supported')
end

local function add_plinkt_cells(
    row,
    name,
    custom_text,
    image
)
    local display_text = hc(custom_text)
        and custom_text
        or name
    local args = get_plinkt_image_args(image)

    if not args then
        row:td()
            :addClass('plinkt-image')
            :addClass('no-border')

        row:td()
            :addClass('plinkt-link')
            :addClass('no-border')
            :wikitext(string.format(
                '[[%s|%s]]',
                name,
                display_text
            ))

        return
    end

    args.txt = display_text

    row:node(plinkt(name, args))
end

local function add_or_na(row, value)
    if value then
        row:addOrNa(value)
    else
        row:td()
            :addClass('table-na')
            :css('text-align', 'center')
            :wikitext('N/A')
    end
end

local function format_number(value)
    if not value then
        return nil
    end

    return commas(value)
end

local function format_currency(value, currency_name)
    if not value then
        return nil
    end

    return currency(value, currency_name)
end

local function get_material_price(material_name)
    if price_cache[material_name] ~= nil then
        return price_cache[material_name]
    end

    local price = exchange._price(material_name, 1, nil, nil, 0)
    price = tonumber(price) or 0

    price_cache[material_name] = price

    return price
end

local function calculate_material_cost(materials)
    local total_cost = 0
    local has_cost = false

    for _, material in ipairs(materials or {}) do
        local quantity = tonumber(material.quantity, 10) or 1
        local material_name = normalize(material.name, true)
        local price = material_name == 'coins' and 1 or get_material_price(material.name)

        local total_price = price * quantity

        if total_price > 0 then
            has_cost = true
        end

        total_cost = total_cost + total_price
    end

    if not has_cost then
        return nil
    end

    return total_cost
end

local function get_recipes()
    local recipe_index = {}

    local query = bucket('furniture')
        .join('recipe', 'furniture.page_name', 'recipe.page_name')
        .select('furniture.page_name', 'furniture.page_name_sub', 'furniture.category', 'furniture.subcategory', 'furniture.plans', 'recipe.production_json')
        .where("Category:Wall decor furniture")
        .limit(5000)

    local data = query.run()

    for _, data_row in ipairs(data) do
        local lowercase_name = normalize(data_row["furniture.page_name"], true)
        recipe_index[lowercase_name] = {
            name = data_row["furniture.page_name"],
            recipe = data_row["recipe.production_json"],
            category = data_row["furniture.category"],
            subcategory = data_row["furniture.subcategory"],
            plans = data_row["furniture.plans"]
        }
    end

    return recipe_index
end

local function convert_recipe(row)
    local furniture = {
        level = nil,
        image = nil,
        materials = {}
    }

    if not row then
        return furniture
    end

    local production = mw.text.jsonDecode(
        row.recipe or '{}'
    )

    if not production then
        return furniture
    end

    for _, skill in ipairs(production.skills or {}) do
        if skill.name == 'Construction' then
            furniture.level = tonumber(skill.level, 10)
            break
        end
    end

    local outputs = production.outputs or {}
    local furniture_name = normalize(row.page_name, true)

    for _, output in ipairs(outputs) do
        local output_name = output.page or output.name

        if normalize(output_name, true) == furniture_name then
            furniture.image = output.image
            break
        end
    end

    if not hc(furniture.image) and outputs[1] then
        furniture.image = outputs[1].image
    end

    for _, material in ipairs(production.materials or {}) do
        local material_name = material.page or material.name

        if hc(material_name) then
            table.insert(furniture.materials, {
                name = material_name,
                image = material.image,
                quantity = tonumber(
                    material.quantity,
                    10
                ) or 1
            })
        end
    end

    furniture.material_cost = calculate_material_cost(
        furniture.materials
    )

    return furniture
end

local function format_materials(materials)
    if not materials or #materials == 0 then
        return nil
    end

    local ret = mw.html.create('table')
        :addClass('products-materials')
        :attr('cellspacing', '1')
        :css('margin', '0')

    local has_materials

    for _, material in ipairs(materials) do
        if hc(material.name) then
            local quantity = material.quantity or 1

            ret:tr()
                :addClass('nohighlight')
                :node(plinkqty(
                    material.name,
                    material.image,
                    quantity
                ))

            has_materials = true
        end
    end

    return has_materials and tostring(ret:allDone()) or nil
end

local function get_table_top()
    local classes = 'wikitable smalllistmargin lighttable sticky-header sortable align-center-3 align-center-4 align-center-5 align-right-7'

    local ret = mw.html.create()
        :wikitext(
            '<table class="' ..
            classes ..
            '" data-tableid="Furniture">'
        )

    ret:tag('tr')
        :th {
            'Furniture',
            attr = { colspan = '2' }
        }
        :th {
            skillpic('Construction') .. '<br>level',
            attr = { ['data-sort-type'] = 'number' }
        }
        :th('Category')
        :th('Subcategory')
        :th('Materials')
        :th {
            'Mat. cost',
            attr = { ['data-sort-type'] = 'number' }
        }

    return tostring(ret:allDone())
end

local function get_table_row(data_row, recipe)
    local row = mw.html.create('tr')
        :attr('data-rowid', data_row.name)

    local furniture_image = hc(data_row.image) and data_row.image or recipe.image

    add_plinkt_cells(
        row,
        data_row.name,
        data_row.text,
        furniture_image
    )

    add_or_na(row, recipe.level and {
        format_number(recipe.level),
        attr = { ['data-sort-value'] = recipe.level }
    })

    add_or_na(row, data_row.category)
    add_or_na(row, data_row.subcategory)
    add_or_na(row, format_materials(recipe.materials))

    add_or_na(row, recipe.material_cost and {
        format_currency(recipe.material_cost, 'coins'),
        attr = { ['data-sort-value'] = recipe.material_cost }
    })

    return tostring(row:allDone())
end

function p.main()
    local ret = mw.html.create()
    local furniture_rows = {}
    local furniture_data = get_recipes()

    ret:wikitext(get_table_top())

    for page_name, data_row in pairs(furniture_data) do
        table.insert(furniture_rows, {
            page = page_name,
            data = data_row,
            recipe = convert_recipe(data_row)
        })
    end

    table.sort(furniture_rows, function(a, b)
        local a_level, b_level = a.recipe.level, b.recipe.level
        local a_name, b_name = a.data.text or a.data.name, b.data.text or b.data.name

        if a_level ~= b_level then
            if a_level == nil then
                return false
            end

            if b_level == nil then
                return true
            end

            return a_level < b_level
        end

        return a_name < b_name
    end)

    for _, furniture_row in ipairs(furniture_rows) do
        ret:wikitext(get_table_row(
            furniture_row.data,
            furniture_row.recipe
        ))
    end

    ret:wikitext('</table>')

    return tostring(ret:allDone())
end

return p