require("strict")
require('Module:Mw.html extension')
local has_content = require('Module:Paramtest').has_content

local p = {}

local EXCLUDED_CATEGORIES = {
    'Unlisted music tracks',
    'Removed content',
    'SoundCloud-exclusive music',
    'Download-only music',
    'Pages using information from game APIs or cache',
    'Unused music',
    'Jingles',
}

local function query_tracks(category, excluded_categories)
    local q = bucket('music')
        .select('page_name', 'display_name', 'music_number', 'sort_string', 'hint', 'is_members_only', 'duration',
             'release', 'file')
        .orderBy('sort_string', 'asc')
        .limit(5000)

    for _, cat in ipairs(excluded_categories) do
        q.where(bucket.Not('Category:' .. cat))
    end

    if category then
        q.where('Category:' .. category)
    end

    return q.run()
end

local function build_table(tracks, category)
    local tbl = mw.html.create('table')
        :addClass(
            'wikitable embed-audio-links lighttable sticky-header sortable align-center-3')
        :attr('data-tableid', 'Music')

    local tr = tbl:tr()
        --:th('#')
        tr:th('Title')
        :th('Unlock hint')
        :th('Length')
        if not category then
        	tr:th('Members')
        end
        tr:th('Release')
        :th('Music track')

        
    for _, track in ipairs(tracks) do
        local title = ('[[%s|%s]]'):format(track.page_name, track.display_name or track.page_name)
        local file = has_content(track.file) and ('[[:File:%s|Play track]]'):format(track.file) or ''
        local release = ''
		if track.release then
			local day, year = string.match(track.release, '(%d+%s%a+)%s(%d+)')
			release = '[[' .. day .. ']] [[' .. year .. ']]'
			else
			release = 'Unknown'
		end

        tr = tbl:tr { attr = { ['data-rowid'] = track.music_number } }
            --:td(track.music_number)
            tr:td { title, attr = { ['data-sort-value'] = track.sort_string or track.page_name } }
            :td(track.hint)
            :td(track.duration)

		if not category then
			tr:td(track.is_members_only and 'Yes' or 'No')
		end
    	tr:td(release)
            :td(file)
    end

    return tbl
end

function p.main(frame)
    return p._main(frame:getParent().args)
end

function p._main(args)
    local category = args[1] or args.category
    local use_exclusions = args.exclusions ~= 'false'

    local excluded = {}
    if use_exclusions then
        for _, cat in ipairs(EXCLUDED_CATEGORIES) do
            if cat ~= category then
            	table.insert(excluded, cat)
            end
        end
    end

    local tracks = query_tracks(category, excluded)
    return build_table(tracks, category)
end

return p