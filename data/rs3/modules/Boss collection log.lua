require('strict')
require('Module:Mw.html extension')
local onMain = require('Module:Mainonly').on_main
local stripCommas = require('Module:Addcommas')._strip
local p = {}

local rarevals = {
	crafted = 4,
	special = 2,
	always = 1,
	common = 1/16,
	uncommon = 1/64,
	rare = 1/256,
	['very rare'] = 1/1024,
	varies = 1/4096,
}

--List of allowed drop sources with property 'Drop type' of 'reward'
local allowedRewardSources = {
	['The Barrows Brothers'] = true,
	['The Barrows: Rise of the Six'] = true,
	['Croesus'] = true,
	['The Gate of Elidinis'] = true,
	['Wyrm reward gland'] = true,
	['Zemouregal & Vorkath loot (story)'] = true,
	['Zemouregal & Vorkath loot (normal)'] = true,
	['Zemouregal & Vorkath loot (hard)'] = true,
}

--List of categories of pages to exclude from drops sources
local disallowedCategories = {
	"Category:Discontinued content",
	"Category:Future content",
	"Category:Historical article",
	"Category:Removed content",
}

local function raresort(x, rolls)
	local noerr, num
	x = string.lower(stripCommas(x))
	if rarevals[x] then
		num = rarevals[x]
	else
		noerr, num = pcall(mw.ext.ParserFunctions.expr, x)
		if not noerr then
			num = 1/65536
		end
	end
	num = tonumber(tostring(num * rolls), 10) or (1/65536)
	return num
end

function p._main(frame, args)
	-- Backwards compatibility and support custom tables and such
	if args.items then
		return args.items
	end

	local id = ''
	if args.id then
		id = 'Collection log - ' .. args.id
	end

	local t = mw.html.create('table')
		:addClass('wikitable lighttable sortable sticky-header align-center-1 align-center-3')
		:attrIf(id ~= '', 'data-tableid', id)
		:tag('tr')
			:tag('th')
			    :attr('colspan', '2')
				:wikitext('Item')
			:done()
			:tag('th')
				:wikitext('Rarity')
			:done()
		:done()

	local i = 1
	while args['item'..i] do
		local item = args['item'..i]
		local bucketitem = args['drop'..i] or item

		local bucketdata = bucket('dropsline')
			.select('page_name', 'drop_json')
			.where('item_name', bucketitem)
			.where(bucket.Not('page_name', "Raptor's chest of slaying"))
			.where(bucket.Not(bucket.Or(unpack(disallowedCategories))))
			.run()

		local rarity
		local rarities = {}
		if args['rarity'..i] then
			table.insert(rarities, { args['rarity'..i], raresort(args['rarity'..i], 1) })
		end
		for _, v in ipairs(bucketdata) do
			local j = mw.text.jsonDecode(v.drop_json)
			local dtype = j['Drop type']
			if dtype[1] == 'combat' or (dtype[1] == 'reward' and allowedRewardSources[j['Dropped from']]) then
				local rolls = j['Rolls'] or 1
				local rarity_str = j['Rarity']
				if rolls > 1 then
					rarity_str = tostring(rolls)..' × '..rarity_str
				end
				table.insert(rarities, { rarity_str, raresort(j['Rarity'], rolls) })

				local altRarity = j['Alt Rarity']
				if altRarity and altRarity ~= '' then
					local alt_rarity_str = altRarity
					if rolls > 1 then
						alt_rarity_str = tostring(rolls)..' × '..alt_rarity_str
					end
					table.insert(rarities, { alt_rarity_str, raresort(altRarity, rolls) })
				end
			end
		end

		if #rarities > 0 then
			table.sort(rarities, function(a, b) return a[2] > b[2] end)
			rarities[1][1] = mw.getContentLanguage():ucfirst(string.lower(rarities[1][1]))
			rarity = rarities[1][1]
			if table.getn(rarities) > 1 then
				rarity = rarity .. '<ref name="dr" group="n">This is the highest drop rate, see item page for drop rates per monster.</ref>'
			end
			if rarities[1][1] == 'Crafted' then
				rarity = rarity .. '<ref name="crafted" group="n">This item requires the player to craft it, see item page for recipe.</ref>'
			elseif rarities[1][1] == 'Special' then
				rarity = rarity .. '<ref name="special" group="n">This item has unique unlock requirements, see item page for more information.</ref>'
			end
		else
			rarity = '[[' .. item .. '|?]]<ref name="unknown" group="n">Drop rate not found, see item page.</ref>'
		end
		if bucketitem ~= item then
			rarity = rarity .. '<ref name="' .. bucketitem .. '" group="n">Showing rarity for dropped item [[' .. bucketitem .. ']].</ref>'
		end

		if args['note'..i] then
			local noteName = ''
			if args['note'..i..'name'] then
				noteName = ' name="' .. args['note'..i..'name'] .. '"'
			end
			rarity = string.format('%s<ref%s group="n">%s</ref>', rarity, noteName, args['note'..i])
		elseif args['note'..i..'name'] then
			rarity = string.format('%s<ref name="%s" group="n"/>', rarity, args['note'..i..'name'])
		end

		local img = item
		if args['img'..i] then
			img = args['img'..i]
		end

		local rowid = item
		local text = item
		if args['text'..i] then
			text = item .. '|' .. args['text'..i]
			rowid = args['text'..i]
		end

		t:tag('tr')
			:attrIf(id ~= '', 'data-rowid', rowid)
			:tag('td')
				:wikitext('[[File:' .. img .. '.png|link=' .. item .. ']]')
			:tag('td')
				:wikitext('[[' .. text .. ']]')
			:done()
			:tag('td')
				:wikitext(rarity)
			:done()
		:done()

		i = i + 1
	end

	return frame:preprocess(tostring(t:allDone()))
end

function p.main(frame)
	local args = frame:getParent().args
	
	if onMain() then
		bucket('boss_collection_log').put({
			id = args.id,
			json = mw.text.jsonEncode(args)
		})
	end
	
	return p._main(frame, args)
end

function p.page(frame)
	local args = frame:getParent().args
	local id = args[1] or mw.title.getCurrentTitle()
	local bucketJSON = bucket('boss_collection_log')
		.select('id', 'json')
		.where('id', id)
		.limit(1)
		.run()
	bucketJSON = bucketJSON[1] and bucketJSON[1].json
	assert(bucketJSON, 'No collection log found for title "' .. id .. '"')
	
	return p._main(frame, mw.text.jsonDecode(bucketJSON))
end

return p