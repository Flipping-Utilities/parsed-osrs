local p = {}

local function buildRegions(page_name, requested_buckets)
    local res = {}

    local function absorb(rows)
        for _, row in ipairs(rows) do
            local league_region = row.league_region
            if league_region and league_region ~= '' and res[row.page_name] == nil then
                res[row.page_name] = league_region
            end
        end
    end
    
    for _, requested_bucket in ipairs(requested_buckets) do
    	local query = bucket(requested_bucket)
    		.select('page_name', 'league_region')
    		.where('page_name', page_name)
    		.limit(100)
    	absorb(query.run())
    end

    return res[page_name] or ''
end

function p.main(frame)
    local page_name
    local buckets = {}
    for i, v in ipairs(frame.args) do
        v = mw.text.trim(v)
        if i == 1 then
            page_name = v
        elseif v ~= '' then
            buckets[#buckets + 1] = v
        end
    end
    return buildRegions(page_name, buckets)
end

return p