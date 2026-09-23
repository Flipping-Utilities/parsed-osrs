-- Note: This module is not meant to be invoked directly, and instead is intended to be used from other modules.
local exchange = require('Module:Exchange')
local yesno = require('Module:Yesno')

local p = {}

-- Obtain information about which version of an item is the default version of the item
-- if no switch infoobox is present, the item name itself will be returned.
function p.defaultVersion(itemname)
	if not itemname or itemname == '' then
		return nil
	end
	-- Order by page name sub so we get the actual sub name
	local item = bucket("infobox_item")
		.select("page_name_sub")
		.where("page_name", itemname)
		.where("default_version", true)
		.limit(1)
		.run()
	if #item == 0 then
		return nil
	end
	item = item[1]
	return item['page_name_sub']
end

-- Get item value from its page based on name.
-- If a switch infobox is present on the entered page, the price for the item version that is shown by default is fetched.
function p.value(itemname)
	if not itemname or itemname == '' then
		return 0
	end
	local item = bucket("infobox_item")
		.select("page_name_sub", "value")
		.where("page_name", itemname)
		.where("default_version", true)
		.limit(1)
		.run()
	if #item == 0 then
		return -1
	end
	item = item[1]
	return item['value']
end

function undoSort(pages, statslist)
	local lookup = {}
	for i, page in ipairs(pages) do
		lookup[string.lower(page)] = i
	end
	local ret = {}
	for _, stats in ipairs(statslist) do
		local i = ""
		if stats["page_name_sub"] then
			i = lookup[string.lower(stats["page_name_sub"])]
			assert(i ~= nil, string.format("Cannot use `sort=no` for redirect pages. Ensure the item \"%s\" is a direct link to the page", stats["page_name_sub"]))
		end
		-- if i==nil then an item was referred to by their redirect page; cannot undo sorting
		ret[i] = stats
	end
	return ret
end

-- Fetches equipment stats, image, and weight for a list of pages. 
-- First argument: a list of pages
-- Second argument: the sort keys for the returned data (array of keys); if equal to {'no'} the order used in the first parameter is used.
-- Third argument: the order in which these sort keys should be (asc / desc / reverse / random)
-- Fourth: any other filters (kvarray of filter_field:value which are ANDed together)
function p.equipmentStats(pages, keys, orders, filters)
	-- mw.logObject(keys)
	if keys == nil then
		keys = {}
		orders = {}
	elseif orders == nil then
		orders = {}
	end
	if filters == nil then
		filters = {}
	end
	
	-- if #keys > 1 or #orders > 1 then
	-- 	error("Using more than 1 key or more than 1 order")	
	-- end
	
    local mapping = {
        astab = "stab_attack_bonus",
    	aslash = "slash_attack_bonus",
    	acrush = "crush_attack_bonus",
    	amagic = "magic_attack_bonus",
    	arange = "range_attack_bonus",
    	dstab = "stab_defence_bonus",
    	dslash = "slash_defence_bonus",
    	dcrush = "crush_defence_bonus",
    	dmagic = "magic_defence_bonus",
    	drange = "range_defence_bonus",
    	str = "strength_bonus",
    	mdmg = "magic_damage_bonus",
    	rstr = "ranged_strength_bonus",
    	prayer = "prayer_bonus",
    	weight = "infobox_item.weight",
    	image = "infobox_item.image",
    	membs = "infobox_item.is_members_only",
    	name = "page_name_sub",
    	range = "weapon_attack_range",
    	speed = "weapon_attack_speed"
    }
    
    local reverse_mapping = {}

	local selects = {}
	for k,v in pairs(mapping) do
		table.insert(selects, v)
		reverse_mapping[v] = k
	end
	
	local pages_condition = {}
    for _, p in ipairs(pages) do
    	table.insert(pages_condition, {"page_name_sub", p})
    end
    
    -- Build query
    local b = mw.ext.bucket("infobox_bonuses")
    	.select(unpack(selects))
    	.join("infobox_item", "infobox_item.page_name_sub", "infobox_bonuses.page_name_sub")
    if #pages_condition>0 then
    	b.where(mw.ext.bucket.Or(pages_condition))
    end
    for k,v in pairs(filters) do
    	b.where(filters)
    	break
    end

    -- Fetch the data
    local t1 = os.clock()
    local bucketdata = b.run()
    local t2 = os.clock()
    
    -- Post-process the data
    if keys[1] and not yesno(keys[1], true) then
    	bucketdata = undoSort(pages, bucketdata)
    else
    	if #keys > 0 then
    		table.sort(bucketdata, function(one, two)
	    		for i, k in ipairs(keys) do
		    		local order = orders[i]
		    		if one[mapping[k]] ~= two[mapping[k]] then
		    			if order == "desc" then --TODO MUDSCAPE this doesn't handle "random" or "reverse"
		    				return one[mapping[k]] > two[mapping[k]] 
		    			else
		    				return one[mapping[k]] < two[mapping[k]] 
		    			end
		    		end
	    		end
			end)
    	end
    end

    local data = {}

    for _, result in ipairs(bucketdata) do
    	local ret_result = {}
    	for k, v in pairs(result) do
	    	ret_result[reverse_mapping[k]] = v
    	end
    	ret_result.image = ret_result.image[1]
        table.insert(data, ret_result)
    end

    return data
end

return p