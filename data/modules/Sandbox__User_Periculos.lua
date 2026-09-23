local p = {}

local itemData = mw.loadJsonData("Module:Collection_log/data.json")

function p.getCategories()
    local categories = {}
    local seen = {}

    for _, item in ipairs(itemData) do
        for _, tab in ipairs(item.tabs) do
            if not seen[tab] then
                seen[tab] = true
                table.insert(categories, tab)
            end
        end
    end

    table.sort(categories)

    return categories
end

function p.categories()
    local categories = p.getCategories()

    local json = mw.text.jsonEncode(categories)

    return mw.html.create("div")
        :attr("id", "collection-log-categories")
        :attr("data-categories", json)
        :css("display", "none")
end


return p