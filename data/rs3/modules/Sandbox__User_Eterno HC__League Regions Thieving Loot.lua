-- Module:Equilibrium League thieving loot
--
-- Generates tables of all Thieving loot obtainable in the Equilibrium League,
-- filtered by the regions a player has unlocked.
--
-- Sources (NPCs, stalls, chests, safes) are found with the same recipe-bucket
-- query used by [[Module:League Regions Skill Table]]. Their loot comes from
-- the dropsline bucket, using only lines with drop type "thieving", so combat
-- drops from pickpocketable NPCs are excluded. Drop lines carry their own
-- league regions, levels, quantities and rarities; the recipe/infobox data is
-- used as a fallback when a line lacks them.
--
-- Usage:
--   {{#invoke:Equilibrium League thieving loot|items|regions=Karamja, Desert, Kandarin}}
--       One row per obtainable item, with the sources and regions it comes from.
--   {{#invoke:Equilibrium League thieving loot|sources|regions=Karamja, Desert, Kandarin}}
--       One row per thieving source with its loot.
--
-- Misthalin and Havenhythe are always included, since every league account
-- starts with them. Pass |regions=all to show every region. |main| is an
-- alias for |items|.

local p = {}

---- region handling ----

local ALWAYS_UNLOCKED = { 'Misthalin', 'Havenhythe' }

local REGION_ORDER = {
	'Misthalin',
	'Havenhythe',
	'Karamja',
	'Anachronia',
	'Asgarnia',
	'Desert',
	'Fremennik',
	'Kandarin',
	'Morytania',
	'Tirannwn',
	'Wilderness',
}

-- lowercase alias -> canonical region name
local REGION_ALIASES = {
	['misthalin'] = 'Misthalin',
	['havenhythe'] = 'Havenhythe',
	['karamja'] = 'Karamja',
	['anachronia'] = 'Anachronia',
	['asgarnia'] = 'Asgarnia',
	['desert'] = 'Desert',
	['kharidian desert'] = 'Desert',
	['the desert'] = 'Desert',
	['fremennik'] = 'Fremennik',
	['fremennik province'] = 'Fremennik',
	['kandarin'] = 'Kandarin',
	['morytania'] = 'Morytania',
	['tirannwn'] = 'Tirannwn',
	['wilderness'] = 'Wilderness',
	['the wilderness'] = 'Wilderness',
}

local currentLeagueRegions = {}
for _, region in ipairs(REGION_ORDER) do
	table.insert(currentLeagueRegions, '#' .. region)
end

local allowedSubpages = {
	'#Barehanded',
}

local function makeError(msg)
	return '<span class="error">Equilibrium League thieving loot: ' .. msg .. '</span>'
end

-- Adds every recognised region in a string like
-- "Asgarnia,Kandarin, Misthalin" to the given set.
local function addRegions(set, str)
	if type(str) ~= 'string' or str == '' then
		return
	end
	for part in mw.text.gsplit(str, ',') do
		local canonical = REGION_ALIASES[mw.ustring.lower(mw.text.trim(part))]
		if canonical then
			set[canonical] = true
		end
	end
end

-- Returns (unlockedSet, orderedList, errMsg). Starting regions are always
-- included; |regions=all selects everything; no argument shows starting
-- regions only.
local function parseRegions(args)
	local unlocked = {}
	local raw = mw.text.trim(args.regions or args[1] or '')

	if raw == '' then
		for _, r in ipairs(ALWAYS_UNLOCKED) do
			unlocked[r] = true
		end
	elseif mw.ustring.lower(raw) == 'all' then
		for _, r in ipairs(REGION_ORDER) do
			unlocked[r] = true
		end
	else
		for _, r in ipairs(ALWAYS_UNLOCKED) do
			unlocked[r] = true
		end
		for part in mw.text.gsplit(raw, ',') do
			local name = mw.text.trim(part)
			if name ~= '' then
				local canonical = REGION_ALIASES[mw.ustring.lower(name)]
				if not canonical then
					return nil, nil, makeError(
						'unknown region "' .. name .. '". Valid regions: ' ..
						table.concat(REGION_ORDER, ', ') .. '.')
				end
				unlocked[canonical] = true
			end
		end
	end

	local ordered = {}
	for _, r in ipairs(REGION_ORDER) do
		if unlocked[r] then
			table.insert(ordered, r)
		end
	end
	return unlocked, ordered, nil
end

---- source discovery (mirrors Module:League Regions Skill Table) ----

local function asList(v)
	if v == nil then
		return {}
	elseif type(v) == 'table' then
		return v
	end
	return { v }
end

local function areBlankRegions(row)
	for _, league_region_field in ipairs({
		'infobox_scenery.league_region',
		'infobox_npc.league_region',
		'infobox_monster.league_region'
	}) do
		for _, v in ipairs(asList(row[league_region_field])) do
			if v ~= '' and mw.ustring.upper(v) ~= 'NO' then
				return false
			end
		end
	end
	return true
end

-- Minimum level for the given skill across a list of production_json
-- strings; nil if none specify it.
local function skillLevel(production_json, skill)
	local level = nil

	for _, jsonStr in ipairs(production_json) do
		local ok, data = pcall(mw.text.jsonDecode, jsonStr)
		if ok and type(data) == 'table' and type(data.skills) == 'table' then
			for _, s in ipairs(data.skills) do
				if s.name == skill then
					local l = tonumber(s.level)
					if l and (not level or l < level) then
						level = l
					end
				end
			end
		end
	end

	return level
end

-- Fallback loot from production_json outputs, for sources without any
-- thieving drop lines. Returns a list of { item, quantity }.
local function outputsFromJson(production_json)
	local items = {}
	local seen = {}

	for _, jsonStr in ipairs(production_json) do
		local ok, data = pcall(mw.text.jsonDecode, jsonStr)
		if ok and type(data) == 'table' and type(data.outputs) == 'table' then
			for _, o in ipairs(data.outputs) do
				local page = o.page or o.name
				if page and page ~= '' and not seen[page] then
					seen[page] = true
					table.insert(items, { item = page, quantity = o.quantity })
				end
			end
		end
	end

	return items
end

-- Queries the recipe bucket for all sources with a recipe using the given
-- skill. Returns a list of entries keyed by base page name:
-- { page_name, regions = set, production = {json strings}, level }.
-- Region-variant subpages (e.g. "Master Farmer#Kandarin") are folded into
-- their base page; drop lines carry per-region data anyway.
local function buildSources(skill)
	local rows = bucket('recipe')
		.select(
			'recipe.page_name',
			'recipe.page_name_sub',
			'infobox_scenery.league_region',
			'infobox_npc.league_region',
			'infobox_monster.league_region',
			'recipe.production_json'
		)
		.join('infobox_scenery', 'infobox_scenery.page_name', 'recipe.page_name')
		.join('infobox_npc', 'infobox_npc.page_name', 'recipe.page_name')
		.join('infobox_monster', 'infobox_monster.page_name', 'recipe.page_name')
		.where('recipe.uses_skill', skill)
		.where(bucket.Not('Category:Thievable quest entities'))
		.where(bucket.Not('Category:Quest NPCs'))
		.where(bucket.Not('Category:Quest monsters'))
		.limit(5000)
		.run()

	local res = {}
	local byPage = {}

	for _, row in ipairs(rows) do
		local page = row['recipe.page_name']

		if page and page ~= '' and not areBlankRegions(row) then
			local entry = byPage[page]
			if not entry then
				entry = {
					page_name = page,
					regions = {},
					production = {}, productionSeen = {},
				}
				byPage[page] = entry
				table.insert(res, entry)
			end

			for _, field in ipairs({
				'infobox_scenery.league_region',
				'infobox_npc.league_region',
				'infobox_monster.league_region'
			}) do
				for _, v in ipairs(asList(row[field])) do
					addRegions(entry.regions, v)
				end
			end

			for _, v in ipairs(asList(row['recipe.production_json'])) do
				if v ~= '' and not entry.productionSeen[v] then
					entry.productionSeen[v] = true
					table.insert(entry.production, v)
				end
			end
		end
	end

	for _, entry in ipairs(res) do
		entry.level = skillLevel(entry.production, skill)
	end

	return res, byPage
end

---- drop lines ----

local DROPLINE_CHUNK = 40

-- Fetches all drop lines for the given source entries and returns thieving
-- loot lines: { page, item, level, quantity, rarity, regions = set|nil }.
local function fetchLootLines(sources)
	local lines = {}
	local seen = {}

	for start = 1, #sources, DROPLINE_CHUNK do
		local conds = {}
		for i = start, math.min(start + DROPLINE_CHUNK - 1, #sources) do
			table.insert(conds, { 'dropsline.page_name', '=', sources[i].page_name })
		end

		local offset = 0
		repeat
			local rows = bucket('dropsline')
				.select('dropsline.page_name', 'dropsline.item_name', 'dropsline.drop_json')
				.where(bucket.Or(unpack(conds)))
				.limit(5000)
				.offset(offset)
				.run()

			for _, row in ipairs(rows) do
				local ok, d = pcall(mw.text.jsonDecode, row['dropsline.drop_json'] or '')
				if ok and type(d) == 'table'
					and mw.ustring.lower(d['Drop type'] or '') == 'thieving' then
					local item = d['Dropped item'] or row['dropsline.item_name']
					if item and item ~= '' then
						local regionStr = d['League region'] or ''
						local key = table.concat({
							row['dropsline.page_name'], item,
							tostring(d['Drop level']), tostring(d['Drop Quantity']),
							tostring(d['Rarity']), regionStr,
						}, '|')
						if not seen[key] then
							seen[key] = true
							local regions = nil
							if regionStr ~= '' then
								regions = {}
								addRegions(regions, regionStr)
							end
							table.insert(lines, {
								page = row['dropsline.page_name'],
								item = item,
								level = tonumber(d['Drop level']),
								quantity = d['Drop Quantity'],
								rarity = d['Rarity'],
								regions = regions,
							})
						end
					end
				end
			end

			local more = #rows == 5000
			offset = offset + 5000
		until not more
	end

	return lines
end

-- Skills each of the given items can be used in, via recipes that list the
-- item as a material. Returns a map of item name -> sorted skill list.
local function fetchUsedInSkills(itemNames)
	local used = {}
	local seen = {}
	for _, name in ipairs(itemNames) do
		used[name] = {}
		seen[name] = {}
	end

	for start = 1, #itemNames, DROPLINE_CHUNK do
		local conds = {}
		for i = start, math.min(start + DROPLINE_CHUNK - 1, #itemNames) do
			table.insert(conds, { 'recipe.uses_material', '=', itemNames[i] })
		end

		local offset = 0
		repeat
			local rows = bucket('recipe')
				.select('recipe.uses_material', 'recipe.uses_skill')
				.where(bucket.Or(unpack(conds)))
				.limit(5000)
				.offset(offset)
				.run()

			for _, row in ipairs(rows) do
				for _, material in ipairs(asList(row['recipe.uses_material'])) do
					if used[material] then
						for _, skill in ipairs(asList(row['recipe.uses_skill'])) do
							if skill ~= '' and not seen[material][skill] then
								seen[material][skill] = true
								table.insert(used[material], skill)
							end
						end
					end
				end
			end

			local more = #rows == 5000
			offset = offset + 5000
		until not more
	end

	for _, skills in pairs(used) do
		table.sort(skills)
	end
	return used
end

---- rendering helpers ----

-- Intersection of a region set with the unlocked set, in canonical order.
local function intersectRegions(set, unlocked)
	local out = {}
	for _, r in ipairs(REGION_ORDER) do
		if set[r] and unlocked[r] then
			table.insert(out, r)
		end
	end
	return out
end

local function regionIcons(frame, regions)
	local parts = {}
	for _, region in ipairs(regions) do
		table.insert(parts, frame:expandTemplate{
			title = 'LeagueRegionIcon',
			args = { region },
		})
	end
	return table.concat(parts, ', ')
end

-- Numeric drop chance for sorting: "695/1,000" -> 0.695, "Always" -> 1,
-- named tiers get rough values, unknown -> 0.
local function rarityValue(r)
	if not r or r == '' then
		return 0
	end
	local rl = mw.ustring.lower(r)
	if rl == 'always' then
		return 1
	end
	local named = {
		['common'] = 0.5,
		['uncommon'] = 0.05,
		['rare'] = 0.005,
		['very rare'] = 0.0005,
	}
	if named[rl] then
		return named[rl]
	end
	local a, b = mw.ustring.match(r, '([%d,%.]+)%s*/%s*([%d,%.]+)')
	if a and b then
		a = tonumber((string.gsub(a, ',', '')))
		b = tonumber((string.gsub(b, ',', '')))
		if a and b and b > 0 then
			return a / b
		end
	end
	return 0
end

-- Largest number in a quantity string, for sorting: "50–100" -> 100,
-- "1,000" -> 1000, unknown -> 0.
local function quantityValue(q)
	if not q or q == '' then
		return 0
	end
	local best = 0
	for n in mw.ustring.gmatch(string.gsub(tostring(q), ',', ''), '%d+') do
		best = math.max(best, tonumber(n) or 0)
	end
	return best
end

-- Item link with its inventory icon, via {{plink}}.
local function itemLink(frame, name, quantity)
	local link = frame:expandTemplate{
		title = 'plink',
		args = { name },
	}
	if quantity and quantity ~= '' and tostring(quantity) ~= '1' then
		return tostring(quantity) .. ' × ' .. link
	end
	return link
end

local function caption(kind, orderedRegions)
	return 'Thieving ' .. kind .. ' available with regions: ' ..
		table.concat(orderedRegions, ', ')
end

-- Shared pipeline: parse args, discover sources, fetch loot lines, filter
-- everything to unlocked regions. Returns (model, errMsg). The model is a
-- list of source records sorted by level:
--   { page_name, level, regions = ordered list, loot = { {item, level,
--     quantity, rarity, regions = ordered list} } }
local function gather(frame)
	local args = {}
	for k, v in pairs(frame.args) do
		args[k] = v
	end
	if frame.getParent and frame:getParent() then
		for k, v in pairs(frame:getParent().args) do
			if args[k] == nil then
				args[k] = v
			end
		end
	end

	local unlocked, orderedRegions, err = parseRegions(args)
	if err then
		return nil, nil, err
	end

	local skill = args.skill or 'Thieving'
	local sources, byPage = buildSources(skill)
	local lootLines = fetchLootLines(sources)

	-- attach loot lines to their sources
	for _, entry in ipairs(sources) do
		entry.loot = {}
	end
	for _, line in ipairs(lootLines) do
		local entry = byPage[line.page]
		if entry then
			table.insert(entry.loot, line)
		end
	end

	local model = {}
	for _, entry in ipairs(sources) do
		local sourceRegions = intersectRegions(entry.regions, unlocked)

		-- a line counts if its own regions intersect the unlocked set,
		-- falling back to the source's regions when it has none
		local loot = {}
		for _, line in ipairs(entry.loot) do
			local lineRegions
			if line.regions then
				lineRegions = intersectRegions(line.regions, unlocked)
			else
				lineRegions = sourceRegions
			end
			if #lineRegions > 0 then
				table.insert(loot, {
					item = line.item,
					level = line.level or entry.level or 1,
					quantity = line.quantity,
					rarity = line.rarity,
					regions = lineRegions,
				})
			end
		end

		-- sources with no drop lines at all fall back to recipe outputs
		if #entry.loot == 0 and #sourceRegions > 0 then
			for _, o in ipairs(outputsFromJson(entry.production)) do
				table.insert(loot, {
					item = o.item,
					level = entry.level or 1,
					quantity = o.quantity,
					regions = sourceRegions,
				})
			end
		end

		-- region column: union of the visible loot lines' regions, or the
		-- source's own regions when it has no usable loot data
		local visibleSet = {}
		for _, l in ipairs(loot) do
			for _, r in ipairs(l.regions) do
				visibleSet[r] = true
			end
		end
		local visibleRegions = intersectRegions(visibleSet, unlocked)
		if #visibleRegions == 0 then
			visibleRegions = sourceRegions
		end

		if #visibleRegions > 0 then
			table.sort(loot, function(a, b)
				if a.level ~= b.level then
					return a.level < b.level
				end
				return a.item < b.item
			end)
			table.insert(model, {
				page_name = entry.page_name,
				level = entry.level or 1,
				regions = visibleRegions,
				loot = loot,
			})
		end
	end

	table.sort(model, function(a, b)
		if a.level ~= b.level then
			return a.level < b.level
		end
		return a.page_name < b.page_name
	end)

	return model, orderedRegions, nil
end

---- one row per thieving source ----

function p.sources(frame)
	local model, orderedRegions, err = gather(frame)
	if err then
		return err
	end

	local out = mw.html.create('table')
		:addClass('wikitable sortable')
	out:tag('caption'):wikitext(caption('sources', orderedRegions))
	out:tag('tr')
		:tag('th'):wikitext('Source'):done()
		:tag('th'):wikitext('Level'):done()
		:tag('th'):wikitext('Regions'):done()
		:tag('th'):addClass('unsortable'):wikitext('Loot'):done()

	for _, entry in ipairs(model) do
		local lootParts = {}
		for _, l in ipairs(entry.loot) do
			local part = itemLink(frame, l.item, l.quantity)
			if l.rarity and l.rarity ~= '' then
				part = part .. ' <small>(' .. l.rarity .. ')</small>'
			end
			table.insert(lootParts, part)
		end
		local lootText = table.concat(lootParts, ', ')
		if lootText == '' then
			lootText = "''See [[" .. entry.page_name .. "]]''"
		end

		out:tag('tr')
			:tag('td'):wikitext(string.format('[[%s]]', entry.page_name)):done()
			:tag('td')
				:attr('data-sort-value', entry.level)
				:wikitext(tostring(entry.level)):done()
			:tag('td'):wikitext(regionIcons(frame, entry.regions)):done()
			:tag('td'):wikitext(lootText):done()
	end

	return tostring(out)
end

---- one row per obtainable item ----

function p.items(frame)
	local model, orderedRegions, err = gather(frame)
	if err then
		return err
	end

	-- item name -> { minLevel, sources = ordered {page, level}, regions = set }
	local items = {}
	local order = {}

	for _, entry in ipairs(model) do
		for _, l in ipairs(entry.loot) do
			local agg = items[l.item]
			if not agg then
				agg = { minLevel = l.level, sources = {}, sourceSeen = {}, regions = {} }
				items[l.item] = agg
				table.insert(order, l.item)
			end
			if l.level < agg.minLevel then
				agg.minLevel = l.level
			end
			local src = agg.sourceSeen[entry.page_name]
			if not src then
				src = {
					page = entry.page_name,
					level = l.level,
					rarities = {}, raritySeen = {},
					quantities = {}, quantitySeen = {},
				}
				agg.sourceSeen[entry.page_name] = src
				table.insert(agg.sources, src)
			end
			if l.rarity and l.rarity ~= '' and not src.raritySeen[l.rarity] then
				src.raritySeen[l.rarity] = true
				table.insert(src.rarities, l.rarity)
			end
			local qty = l.quantity and tostring(l.quantity) or ''
			if qty ~= '' and not src.quantitySeen[qty] then
				src.quantitySeen[qty] = true
				table.insert(src.quantities, qty)
			end
			for _, r in ipairs(l.regions) do
				agg.regions[r] = true
			end
		end
	end

	table.sort(order, function(a, b)
		if items[a].minLevel ~= items[b].minLevel then
			return items[a].minLevel < items[b].minLevel
		end
		return a < b
	end)

	local usedIn = fetchUsedInSkills(order)

	local out = mw.html.create('table')
		:addClass('wikitable sortable')
	out:tag('caption'):wikitext(caption('loot', orderedRegions))
	out:tag('tr')
		:tag('th'):wikitext('Item'):done()
		:tag('th'):wikitext('Level'):done()
		:tag('th'):addClass('unsortable'):wikitext('Obtained from'):done()
		:tag('th'):wikitext('Quantity'):done()
		:tag('th'):wikitext('Rarity'):done()
		:tag('th'):wikitext('Used in'):done()
		:tag('th'):wikitext('Regions'):done()

	for _, name in ipairs(order) do
		local agg = items[name]

		table.sort(agg.sources, function(a, b)
			if a.level ~= b.level then
				return a.level < b.level
			end
			return a.page < b.page
		end)

		local srcParts = {}
		for _, s in ipairs(agg.sources) do
			table.insert(srcParts, string.format('[[%s]] (%d)', s.page, s.level))
		end

		-- Quantity and Rarity columns: one value when every source agrees,
		-- otherwise per-source values in the same order as the Obtained
		-- from column. Collapses a per-source list built by listFn.
		local function perSourceColumn(listFn)
			local distinct = {}
			local parts = {}
			for _, s in ipairs(agg.sources) do
				local text = table.concat(listFn(s), ' / ')
				if text ~= '' then
					distinct[text] = true
					table.insert(parts, text)
				end
			end
			local distinctCount = 0
			for _ in pairs(distinct) do
				distinctCount = distinctCount + 1
			end
			if distinctCount == 0 then
				return '—'
			elseif distinctCount == 1 then
				return parts[1]
			end
			return table.concat(parts, ', ')
		end

		local rarityText = perSourceColumn(function(s) return s.rarities end)
		local quantityText = perSourceColumn(function(s) return s.quantities end)

		local bestChance = 0
		local maxQuantity = 0
		for _, s in ipairs(agg.sources) do
			for _, r in ipairs(s.rarities) do
				bestChance = math.max(bestChance, rarityValue(r))
			end
			for _, q in ipairs(s.quantities) do
				maxQuantity = math.max(maxQuantity, quantityValue(q))
			end
		end

		local itemRegions = {}
		for _, r in ipairs(REGION_ORDER) do
			if agg.regions[r] then
				table.insert(itemRegions, r)
			end
		end

		local skillParts = {}
		for _, skill in ipairs(usedIn[name] or {}) do
			table.insert(skillParts, frame:expandTemplate{
				title = 'Skill clickpic',
				args = { skill },
			})
		end
		local skillText = table.concat(skillParts, ', ')
		if skillText == '' then
			skillText = '—'
		end

		out:tag('tr')
			:tag('td'):wikitext(itemLink(frame, name)):done()
			:tag('td')
				:attr('data-sort-value', agg.minLevel)
				:wikitext(tostring(agg.minLevel)):done()
			:tag('td'):wikitext(table.concat(srcParts, ', ')):done()
			:tag('td')
				:attr('data-sort-value', maxQuantity)
				:wikitext(quantityText):done()
			:tag('td')
				:attr('data-sort-value', string.format('%.6f', bestChance))
				:wikitext(rarityText):done()
			:tag('td'):wikitext(skillText):done()
			:tag('td'):wikitext(regionIcons(frame, itemRegions)):done()
	end

	return tostring(out)
end

p.main = p.items

return p