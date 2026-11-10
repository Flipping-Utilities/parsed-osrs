require('strict')
local yesno = require('Module:Yesno')
local members = require('Module:Members').icon
local questSeriesList = require('Module:Infobox Quest').series_list
local questCombatList = require('Module:Infobox Quest').combat_list
local questLengthList = require('Module:QuestDetails').lengths

local p = {}

local function timelineSortKey(quest)
    local sortIdKey

    local override_sequence = tonumber(quest.override_sequence)
    if override_sequence ~= nil and override_sequence > 1999 then
        sortIdKey = (override_sequence - 1999) * 1000
    else
        sortIdKey = ((tonumber(quest['quest.official_release_year']) or 1999) - 1999) * 1000
    end

    if override_sequence ~= nil and override_sequence <= 1999 then
        return sortIdKey + override_sequence + 1.5
    end

    local release_year_nth = tonumber(quest['quest.release_year_nth'])
    if release_year_nth ~= nil then
        return sortIdKey + release_year_nth + 1
    else
        return sortIdKey + quest.create_id
    end
end

function p.main(frame)
    local args = frame:getParent().args
    local category = args['category']
    local subcategory = args['subcategory']
    local header = args['header'] or 'There are currently %TOTALRECORDS% quests.'
    local limit = args['limit'] or 5000
    local type = args['type']

    -- Get list of applicable quests
    local query = bucket('infobox_quest')
        .join('quest', 'page_name', 'quest.page_name')
        .join('quest_rewards', 'page_name', 'quest_rewards.page_name')
        .select(
        	'page_name_sub',
            'name',
            'is_members_only',
            'quest.official_length',
            'official_age',
            'official_combat',
            'official_difficulty',
            'quest_rewards.quest_points',
            'official_series',
            'official_nth_in_series',
            'quest.official_release_year',
            'quest.release_year_nth',
            'override_sequence',
            'release_date',
            'create_id',
            'id'
        )
        .limit(limit)
        .orderBy('name', 'asc')

    query.where(bucket.Not('Category:Removed content'))
    query.where('id', '>', 0) -- Only look at quests with id's defined (why?)

    if type then
        query.where('quest_type', type)
    else
        query.where('quest_type', '!=', 'subquest')
    end


    if category == 'age' then
        query.where('official_age', subcategory)
    end

    if category == 'difficulty' then
        query.where('official_difficulty', subcategory)
    end

    if category == 'length' then
        query.where('quest.official_length', subcategory)
    end

    if category == 'members' then
        query.where('is_members_only', yesno(subcategory))
    end

    if category == 'timeline' then
        query.where('official_timeline', subcategory)
    end

    local quests = query.run()

    if category == 'timeline' then
        for _, quest in ipairs(quests) do
            quest.sortKey = timelineSortKey(quest)
        end

        table.sort(quests, function(quest1, quest2)
            return quest1.sortKey < quest2.sortKey
        end)
    end

    -- Display table header
    local tbl = mw.html.create('table')
        :addClass('wikitable sortable qc-active lighttable sticky-header')

    local tr = tbl:tag('tr')

    -- Table headers
    tr:tag('th'):wikitext('Name')
    if category ~= 'members' then
        tr:tag('th'):wikitext(members())
    end
    if category ~= 'length' then
        tr:tag('th'):wikitext('Length')
    end
    if category ~= 'age' then
        tr:tag('th'):wikitext('Age')
    end
	if category ~= 'difficulty' then
        tr:tag('th'):wikitext('Difficulty')
    end
    tr:tag('th'):wikitext('Combat')
    tr:tag('th'):wikitext('QP')
    tr:tag('th'):wikitext('Series')
    tr:tag('th'):wikitext('Release date')


    -- Table content
    for _, row in ipairs(quests) do
        tr = tbl:tag('tr')

        -- Name
        tr:tag('td'):wikitext('[[' .. row.page_name_sub ..'|'..row.name.. ']]')

        -- Members
        if category ~= 'members' then
            tr:tag('td'):wikitext(members(row.is_members_only)):css('text-align', 'center')
        end

        -- Length
        if category ~= 'length' then
            if row['quest.official_length'] == nil then
                tr:tag('td'):wikitext('?'):attr('data-sort-value', 999)
            else
                local length = questLengthList[string.lower(row['quest.official_length'])] or { 0, row['quest.official_length'] }
                tr:tag('td'):wikitext(length[2]):attr('data-sort-value', length[1])
            end
        end

        -- Age
        if category ~= 'age' then
            if row.official_age == '5' then
                tr:tag('td'):wikitext('[[Fifth Age]]'):attr('data-sort-value', 0)
            elseif row.official_age == 'ambiguous' then
                tr:tag('td'):wikitext('Ambiguous'):attr('data-sort-value', 1)
            elseif row.official_age == '6' then
                tr:tag('td'):wikitext('[[Sixth Age]]'):attr('data-sort-value', 2)
            elseif row.official_age == 'chaos' then
                tr:tag('td'):wikitext('[[Age of Chaos]]'):attr('data-sort-value', 3)
            else
                tr:tag('td'):wikitext('Unknown'):attr('data-sort-value', 4)
            end
        end
        
        -- Difficulty
        if category ~= 'difficulty' then
        	tr:tag('td'):wikitext(row['official_difficulty'])
        end

        -- Combat
        local combatData = questCombatList[string.lower(row.official_combat or '')] or { 0, row.official_combat }
        tr:tag('td'):wikitext(combatData[3]):attr('data-sort-value', combatData[1])

        -- Quest points
        tr:tag('td'):wikitext(row['quest_rewards.quest_points']):css('text-align', 'center')

        -- Series
        if row.official_series == nil or row.official_series == 'None' then
            tr:tag('td'):wikitext("N/A"):attr('data-sort-value', '0'):addClass("table-na nohighlight")
        else
            local seriesData = questSeriesList[string.lower(row.official_series)] or { 0, row.official_series }
            tr:tag('td'):wikitext(seriesData[2]):attr('data-sort-value', seriesData[1])
        end

        -- Release date
        tr:tag('td'):wikitext(row.release_date)
    end

    return header:gsub("%%TOTALRECORDS%%", #quests) .. tostring(tbl)
end

return p