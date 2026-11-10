
local arr = require('Module:Array')
local curr = require('Module:Currency')._amount
local dpl = require('Module:DPLlua')
local geprices = mw.loadJsonData('Module:GEPrices/data.json')

local p = {}

local function get_bound(name, val)
    -- If the value isn't nil, and its tonumber isn't nil, set it to its tonumber, else 0.
    local bound = val and tonumber(val) or 0
    -- Error if the value is 0 (means it or its tonumber is nil)
    return {name=name, value=bound, error=(bound == 0)}
end

local function get_price(item, alchonly, alchprice, gemw, alch)
    local price
    -- parse price
    if item:lower() == "coins" then
        -- Coins get a price of 1
        price = 1 or 0 -- I know, but just let me think about this one for a bit there's more abstraction we can do
    elseif alchonly then
        -- Alchprice if alchable
        price = alchprice or 0
    else
        -- GE price otherwise
        -- replace w/ a space for lookup; 'Prayer potion#(4)' to 'Prayer potion (4)'
        price = geprices[item:gsub('#',' ')] or 0
        if price == 0 and gemw == false then
        	price = alchprice or 0
        end
	end
    return {name="price", value=price, error=(price == 0)}
end

-- pcall is inconvenient for me
local function pcall_wrapper(fn, arg)
    local worked, result = pcall(fn, arg)
    if worked then return result
    else return nil
    end
end

local function get_rarity(rarity_string)
    local rarity
	-- parse rarity
	if rarity_string:lower() == 'always' then
        -- Always has a rarity of 1
		rarity = 1 or 0
	else
		local rarity_val_result = pcall_wrapper(mw.ext.ParserFunctions.expr, rarity_string:gsub(',', ''))
        rarity = tonumber(rarity_val_result) or 0
	end
    return {name="rarity", value=rarity, error=(rarity == 0)}
end

-- TODO: parse multiple values; e.g coins [2000; 3000] or coins [2000-2500]. For further information,
-- check Imperial warrior akh erroneous calculation.
-- returns: value, isError
local function calcValue(item, lowqty, highqty, rarity, rolls, alchprice, alchonly, gemw, alch)
    local low_table = get_bound("low", lowqty)
    local high_table = get_bound("high", highqty)
    local price_table = get_price(item, alchonly, alchprice, gemw, alch)
    local rarity_table = get_rarity(rarity)

    local data = {low_table, high_table, price_table, rarity_table}

    for _, val_table in ipairs(data) do
        if val_table.error then mw.log("0 " .. val_table.name .. " recorded for item: " .. item) end
    end

    local anyError = arr.any(arr.map(data, function (elem) return elem.error end))

	local avgqty = (low_table.value + high_table.value) / 2
    local total_value = price_table.value * avgqty * rarity_table.value * rolls
    -- mw.log(string.format('ADV: %s %s', item, total_value))
	return total_value, anyError
end

local function _DPLcontains(array, str)
	for _, value in ipairs(array) do
		if value == str then return true end
	end
	return false
end

function p.getDropData(mob)
	--modified from loadData in [[Module:Bestiary]]
	local bucket_data = {}
	bucket_data = bucket("dropsline").select("drop_json").where("page_name_sub", mob).limit(500).run()
	if bucket_data and bucket_data ~= {} and bucket_data ~='' then
		return bucket_data --drops were successfully retrieved for the mob
	end
	--failed to retrieve drops for mob, fall back to mobroot (e.g. 'Barbarian' rather than 'Barbarian#level 8')
	mobroot, _ = mob:match('([^#]*)#?(.*)') -- not ideal that this is repeat code however it removes the need for the mobs table
	if mobroot ~= mob then
		bucket_data = bucket("dropsline").select("drop_json").where("page_name", mobroot).limit(500).run()
		if bucket_data and bucket_data ~= {} and bucket_data ~='' then
			return bucket_data --data was successfully retrieved for the mobroot
		end
	end
	--failed to retrieve drops for mob log error
	local errorstring = string.format("Failed to retrieve drops for %s%s",mob,mobroot~=mob and ' or ' .. mobroot or '')
	mw.log(errorstring)
	return bucket_data
end

function p.totalvalfromdata(data, itemOptions, category, categoryFilter, exclude, excludeFilter, alchonly)
	--used in [[Module:Bestiary]] too
	if (not data) or data == {} or data == '' then
        return nil
	end
	local totalval = 0
	local totalnum = 0
	local badnum = 0
	--local options = itemOptions or {}
	for _, v in ipairs(data) do
		local j = mw.text.jsonDecode(v.drop_json or '{}')
		if (not category) or _DPLcontains(categoryFilter,j['Dropped item']) then
			if (not exclude) or (not _DPLcontains(excludeFilter,j['Dropped item'])) then
				local val, valError = calcValue(
					j['Dropped item'] or j['Dropped item from RDT'],
					j['Quantity Low'],
					j['Quantity High'],
					j['Rarity'],
					j['Rolls'],
					j['Drop Value'],
					alchonly,
					j['Drop GEMW'],
					j['Drop Alch']
				)

				if j['Dropped item'] then
					-- manual exclusions for [[Template:Wilderness shared loot table]]
					-- unlike the RDT, this drop table unfortunately has no identifying properties/values
					if not (j['Dropped item'] == 'Wilderness hilt' and j['Rarity'] == 'Rare') or
					   (j['Dropped item'] == 'Adrenaline crystal' and j['Rarity'] == 'Uncommon') or
					   (j['Dropped item'] == 'Preserved meat' and j['Rarity'] == 'Common') or
					   (j['Dropped item'] == 'Fremennik equipment patch' and j['Rarity'] == 'Uncommon') or
					   (j['Dropped item'] == "Ancient warriors' equipment patch" and j['Rarity'] == 'Very rare') or
					   (j['Dropped item'] == 'Revenant drop enhancer' and j['Rarity'] == 'Rare') or
					   (j['Dropped item'] == 'Bloodweed seed' and j['Rarity'] == 'Uncommon') or
					   (j['Dropped item']:match('^Brawling gloves %(')) then
						totalnum = totalnum + 1
						if valError then
							badnum = badnum + 1
						end
					end
				end
				totalval = totalval + val
			end
		end
	end
	if totalnum > 0 and badnum / totalnum > 0.25 then
		mw.log(string.format("Too many estimated rarities or unknown drops parameters (%d/%d);"..
		" remove Average drop value template", badnum, totalnum))
	end
	return totalval
end

function p.totalval(mob, itemOptions, category, categoryFilter, exclude, excludeFilter, alchonly)
	return p.totalvalfromdata(p.getDropData(mob), itemOptions, category, categoryFilter, exclude, excludeFilter, alchonly)
end

function p.main(frame)
	return p._main(frame:getParent().args)
end

function p._main(args)
	local lang = mw.getContentLanguage()
	local pageName = mw.title.getCurrentTitle().text
	local mob

	if args.mob or args[1] then
		mob = args.mob or args[1]
	else
		mob = pageName
	end
	local mobname = mob

	local mobroot, moblevel = mob:match('([^#]*)#?(.*)')
	if args.mobname then
		mobname = args.mobname
	elseif moblevel ~= "" then
		mobname = string.format('%s (%s)',mobroot, moblevel)
	end

	if lang:ucfirst(mobroot) ~= lang:ucfirst(pageName) then --link to the mob if it's from a different page
		mobname = string.format('[[%s|%s]]',mobroot,mobname)
	end

	local alchstr = ''
	local worthstr = ''
	if args.alch then
		alchstr = 'high alch value of a'
	else
		worthstr = 'worth '
	end

	local droptext = args.droptext or 'kill'
	local itemOptions = {}
	local categoryFilter = {}
	local excludeFilter = {}
	local catReportString = ""
	local function filter (cat)
		return  dpl.ask({
				namespace = '',
				category = cat,
				allowcachedresults = 'true'
			})
	end
	if args.category then
		categoryFilter = filter(args.category)
		catReportString = 'counting only '..(args.category:lower())..' '
	end
	if args.exclude then
		excludeFilter = filter(args.exclude)
		catReportString = catReportString..'excluding all '..(args.exclude:lower())..' '
	end

	local totalval = p.totalval(mob, itemOptions, args.category,
		categoryFilter, args.exclude, excludeFilter, args.alch)

	if not totalval then --failed
		return ''
	end

	if args.round then
		totalval = math.floor(totalval)
	end

	if args.raw then
		return totalval
	end

	local coinString = curr(math.floor(totalval+0.5), 'nocoinsc')
	return string.format('The average %s %s %s %sis %s%s.',
		alchstr, mobname, droptext, catReportString, worthstr, coinString)
end

return p