local p = {}

local purge = require('Module:Purge')._purge
local make_line = require('Module:Get drop info').makeLine
local var = mw.ext.VariablesLua

function default_to(val, default)
	if val == nil or val == '' then
		return default
	end
	return val
end

function is_on_main(page_name)
	for v in string.gmatch(page_name, '([^:]+)') do
		if mw.site.namespaces[v] then
			return false
		end
		return true
	end
end

function get_level(drop_version, drop_type)
	if drop_type == 'reward' then
		return nil
	end

	local version_key = default_to(drop_version, 'DEFAULT')
	local skill = string.lower(drop_type)  -- 'combat' (default) or a skill skill

	local seen_levels = {}
	for version in string.gmatch(version_key, ' *([^,]+) *') do
		local drop_level_var = string.format("DropLevel_%s_%s", skill, version)
		local cur_drop_level_values = var.var(drop_level_var)
		for cur_drop_level in string.gmatch(cur_drop_level_values, ' *([^,]+) *') do
			seen_levels[cur_drop_level] = true
		end
	end

	local ordered_levels = {}
	for level, _ in pairs(seen_levels) do
		local n = tonumber(level)
		if n ~= nil then
			table.insert(ordered_levels, n)
		end
	end
	table.sort(ordered_levels)
	return default_to(table.concat(ordered_levels, ','), nil)
end

function p.get(frame)
	local args = frame.args
	local table_name = args['table_name']

	local query = bucket('drop_table_sources')
		.select(
			'page_name_sub', 'drop_level', 'quantity', 'rarity', 'drop_type', 'rolls', 'approx'
		)
		.where('table_name', table_name)

	local t1 = os.clock()
	local bucketdata = query.run()
	local t2 = os.clock()

    if not bucketdata then
        return ":''No drop sources found. To force an update, click "
                ..purge('dml-'..mw.uri.anchorEncode(item), 'here', 'span')
                ..".''[[Category:Empty drop lists]]"
    end
    mw.log(string.format('Bucket: entries: %d, time elapsed: %.3f ms.', #bucketdata, (t2 - t1) * 1000))

    local ret = {}
    local rowdata
    if bucketdata then
        for _, v in ipairs(bucketdata) do
        	-- don't list stuff from user pages and such
        	if is_on_main(v['page_name_sub']) then
				rowdata = {
					['Dropped from'] = v['page_name_sub'],
					['Drop level'] = v['drop_level'],
					['Drop Quantity'] = v['quantity'],
					['Rarity'] = v['rarity'],
					['Drop type'] = v['drop_type'],
					['Rolls'] = v['rolls'],
					['Approx'] = v['approx']
				}
				table.insert(ret, make_line(item, rowdata))
			end
        end
    end

	local t = mw.html.create('table')
    t   :addClass('wikitable sortable filterable item-drops align-center-2 align-center-3 align-center-4 autosort=4,a')
        :tag('tr')
            :tag('th'):addClass('drop-disp-btn btn-first'):wikitext('Source'):done()
            :tag('th'):wikitext('Level'):done()
            :tag('th'):wikitext('Quantity'):done()
            :tag('th'):wikitext('Rarity'):addClass('drops-rarity-header'):done()

    for i, v in ipairs(ret) do
        t:node(v)
    end
    
    return tostring(t)
end

function p.set(frame)
	local args = frame.args

	local _bucket = default_to(args['bucket'], true)
	if _bucket ~= true then
		return
	end

	local table_name = args['table_name']
	local quantity = default_to(args['quantity'], 1)
	local rolls = default_to(args['rolls'], 1)
	local rarity = default_to(args['rarity'], 'Unknown')
	local approx = default_to(args['approx'], false)
	local drop_type = default_to(args['drop_type'], 'combat')
	local drop_version = default_to(args['drop_version'], '')
	local drop_level = get_level(drop_version, drop_type)

	if tonumber(rarity) == 1 then
		rarity = 'Always'
	end

	bucket('drop_table_sources')
		.sub(drop_version)
		.put({
			table_name = table_name,
			quantity = quantity,
			rolls = rolls,
			rarity = rarity,
			approx = approx,
			drop_type = drop_type,
			drop_level = drop_level
		})
	return
end

return p