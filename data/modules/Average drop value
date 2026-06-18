local curr = require('Module:Currency')._amount
local dpl = require('Module:DPLlua')
local geprices = mw.loadJsonData('Module:GEPrices/data.json')

local p = {}

function calcValue(item, lowqty, highqty, rarity, rolls, alchprice, alchonly, options)
	-- prevent it from breaking entirely if an item is missing a quantity
	lowqty=lowqty or 0
	highqty=highqty or 0
	
	local avgqty = (tonumber(lowqty) + tonumber(highqty)) / 2
	local rar_good, price
	-- parse price
	local i_lo = item:lower()
	if i_lo == 'brimstone key' and options.brimstone ~= nil then
		price = p.totalval('Brimstone chest', nil, nil, nil, nil, nil, alchonly)
    elseif (i_lo == 'larran\'s key' or i_lo == 'slayer\'s enchantment') and options.wildernessslayer == nil then
        price = 0
    elseif i_lo == 'larran\'s key' and options.wildernessslayer ~= nil and alchonly then
    	price = p.totalval('Larran\'s big chest', nil, nil, nil, nil, nil, true)
	elseif i_lo == 'ecumenical key' then
		price = 0
	elseif alchonly then
		price = alchprice or 0
	else
		-- strip '#' or replace w/ a space for lookup
		-- 'Prayer potion#(4)' to 'Prayer potion(4)'
		-- 'Iron dart#(p)' to 'Iron dart (p)'
		price = geprices[item:gsub('#','')] or geprices[item:gsub('#',' ')] or alchprice or 0
	end
	if not price then
		--mw.log('0 price for '..item)
		return 0
	end
	-- parse rarity
	if rarity:lower() == 'always' then
		rarity = 1
	else
		rarity = rarity:gsub(',', '')
		rar_good, rarity= pcall(mw.ext.ParserFunctions.expr, rarity)
		if not rar_good then
		--mw.log('0 rarity for '..item)
			return 0
		end
		rarity = tonumber(rarity)
		if not rarity then
		--mw.log('0 rarity for '..item)
			return 0
		end
	end
	
	local val = price * avgqty * rarity * rolls
	--mw.log(string.format('item %s: %s * %s * %s * %s = %s', item, price, lowqty, rarity, rolls, val))
	return val
end

function _DPLcontains(arr,s)
	for k, v in ipairs(arr) do
		if v == s then return true end
	end
	return false
end

function p.getDropData(mob)
	local bucket_data = {}
	bucket_data = bucket("dropsline")
		.select("drop_json")
		.where("page_name_sub", mob)
		.limit(500)
		.run()
	if bucket_data and #bucket_data > 0 then
		return bucket_data --drops were successfully retrieved for the mob
	end
	--failed to retrieve drops for mob, fall back to mobroot (e.g. 'Barbarian' rather than 'Barbarian#level 8')
	mobroot, _ = mob:match('([^#]*)#?(.*)') -- not ideal that this is repeat code however it removes the need for the mobs table
	if mobroot ~= mob then
		bucket_data = bucket("dropsline")
			.select("drop_json")
			.where("page_name", mobroot)
			.limit(500)
			.run()
		if bucket_data and #bucket_data > 0 then
			return bucket_data --data was successfully retrieved for the mobroot
		end
	end
	--failed to retrieve drops for mob log error
	local errorstring = string.format("Failed to retrieve drops for %s%s",mob,mobroot~=mob and ' or ' .. mobroot or '')
	mw.log(errorstring)
	return bucket_data
end

function p.totalvalfromdata(data,itemOptions,category, categoryFilter, exclude, excludeFilter, alchonly)
	--used in [[Module:Bestiary]] too
	if (not data) or data == {} or data =='' then 
		return '?'
	end
	local totalval = 0
	local options = itemOptions or {}
	for i,v in ipairs(data) do
		local j = mw.text.jsonDecode(v['drop_json'] or '{}')
		if (not category) or _DPLcontains(categoryFilter,j['Dropped item']) then
			if (not exclude) or (not _DPLcontains(excludeFilter,j['Dropped item'])) then
				totalval = totalval + calcValue(j['Dropped item'], j['Quantity Low'], j['Quantity High'], j['Rarity'], j['Rolls'], j['Drop Value'], alchonly, options)
			end
		end
	end
	return totalval
end

function p.totalval(mob, itemOptions, category, categoryFilter, exclude, excludeFilter, alchonly)
	local data = p.getDropData(mob)
	return p.totalvalfromdata(data,itemOptions,category, categoryFilter, exclude, excludeFilter, alchonly)
end

function p.main(frame)
	return p._main(frame, frame:getParent().args)
end

function p._main(frame, args)
	local pageName = mw.title.getCurrentTitle().text
	local mob = ''
	
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
	
	if mobroot ~= pageName then --link to the mob if it's from a different page 
		mobname = string.format('[[%s|%s]]',mobroot,mobname) 
	end
	
	local alchstr = ''
	local worthstr = ''
	if args.alch then
		alchstr = 'high alch value of a'
	else
		worthstr = 'worth '
	end
	
	local killname = args.killname or 'kill'
	local itemOptions = {
		brimstone = args.brimstone,
		wildernessslayer = args.wildernessslayer
	}
	local categoryFilter = {}
	local excludeFilter = {}
	local catReportString = ""
	filter = function(cat)
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

	if totalval == '?' then --failed
		return ''
	end
	
	if args.round then
		totalval = math.floor(totalval)
	end
	
	if args.raw then
		return totalval
	end
	
	local brimString = args.brimstone ~= nil and ' while on a [[Konar]] task' or ''
	local wildyString = args.wildernessslayer ~= nil and ' while on a [[Krystilia]] task' or ''
	if args.wildernessslayer ~= nil and args.alch then
		wildyString = wildyString..' opening [[Larran\'s big chest]]'
	end
	local coinString = curr(totalval, 'coins')
	return string.format('The average %s %s %s%s%s %sis %s%s.', 
		alchstr, mobname, killname, brimString, wildyString, catReportString, worthstr, coinString)
end


return p