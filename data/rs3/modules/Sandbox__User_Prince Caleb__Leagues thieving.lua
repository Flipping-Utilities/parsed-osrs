--[[
Leagues (Equilibrium) pickpocketing planner.

Reads every target's loot straight out of the wiki's `dropsline` bucket, so
there is no copied data to maintain. Each row's drop_json carries the rarity,
quantity, Thieving requirement AND the league regions, so this module needs
only one companion page: the roster of pickpocket targets.

  Module:Sandbox/User:Prince Caleb/Leagues thieving/targets

Model: Golden Touch makes every pickpocket succeed and triples the loot (coins
excepted), so a target is a fixed-rate faucet:

    items/hour = (3600 / interval) / rarity * quantity * rolls * multiplier

interval is 1.2s with Sticky Fingers harnessed, 1.8s without.
--]]

local p = {}

local TARGETS = mw.loadData('Module:Sandbox/User:Prince Caleb/Leagues thieving/targets')
local lang = mw.language.getContentLanguage()

local BUCKET   = 'dropsline'
local DROP_TYPE = 'thieving'   -- ignores combat drops on the same NPC pages

-- Golden Touch triples ordinary loot but treats coins separately.
local COIN_MULT  = 100
local COIN_ITEMS = { ['Coins'] = true }

-- Items never worth listing: event-only or otherwise pure noise. Exact names
-- go in EXCLUDE_ITEMS; anything sharing a leading string goes in
-- EXCLUDE_PREFIXES, which catches every "Flame fragment (...)" variant at once.
local EXCLUDE_ITEMS = {
	['Dodgy flyer'] = true,
}
local EXCLUDE_PREFIXES = {
	'Flame fragment',
}

-- Splits a free-text filter box into terms and reports whether any matches.
-- Plain substring search (find with plain=true) so punctuation in item names
-- such as "H.A.M. robe" or "Super attack (1)" cannot be read as a pattern.
local function splitTerms(raw)
	local terms = {}
	for term in tostring(raw or ''):gmatch('[^,]+') do
		term = term:match('^%s*(.-)%s*$'):lower()
		if term ~= '' then terms[#terms + 1] = term end
	end
	return terms
end

local function matchesAny(text, terms)
	if #terms == 0 then return true end   -- empty box means no filtering
	local hay = tostring(text or ''):lower()
	for _, term in ipairs(terms) do
		if hay:find(term, 1, true) then return true end
	end
	return false
end

-- Whole-name match, case-insensitive. Used for "Only these targets" so that
-- typing Farmer selects Farmer alone and not Master Farmer as well.
local function matchesExact(text, terms)
	if #terms == 0 then return true end
	local hay = tostring(text or ''):lower()
	for _, term in ipairs(terms) do
		if hay == term then return true end
	end
	return false
end

local function excludedItem(item)
	if EXCLUDE_ITEMS[item] then return true end
	for _, prefix in ipairs(EXCLUDE_PREFIXES) do
		if item:sub(1, #prefix) == prefix then return true end
	end
	return false
end

-- Targets are queried in small batches. One big query would exceed the row
-- cap, because killable targets also store their whole combat drop table in
-- this bucket and those rows are only filtered out afterwards.
local BATCH_SIZE = 8
local ROW_LIMIT  = 5000

local REGIONS = {
	'Anachronia', 'Asgarnia', 'Desert', 'Fremennik', 'Havenhythe', 'Kandarin',
	'Karamja', 'Misthalin', 'Morytania', 'Tirannwn', 'Wilderness'
}

-- The wiki records league regions with inconsistent capitalisation
-- ("Kandarin" on some pages, "kandarin" on others), so all matching is done
-- lowercase and the canonical spelling is used only for display.
local CANON = {}
for _, r in ipairs(REGIONS) do CANON[r:lower()] = r end

local TICK_STICKY, TICK_PLAIN = 1.2, 1.8
local NOTICE = 'margin:.5em 0;padding:.35em 0 .35em .75em;border-left:3px solid #a08050'
local FOOT   = 'font-size:90%;opacity:.7;margin-top:.5em'

local unpack = unpack or table.unpack

-------------------------------------------------------------------- helpers --

local function yes(v)
	v = string.lower(tostring(v or ''))
	return v == 'true' or v == 'yes' or v == 'y' or v == '1' or v == 'on'
end

-- "695/1,000" -> 1.439 (the "1 in N" denominator). Word rarities are skipped
-- rather than guessed at.
local function parseRarity(raw)
	if raw == nil then return nil end
	local s = tostring(raw):gsub(',', ''):gsub('%s', '')
	local num, den = s:match('^(%d+%.?%d*)/(%d+%.?%d*)$')
	if num and den then
		num, den = tonumber(num), tonumber(den)
		if num and den and num > 0 then return den / num end
		return nil
	end
	if s:lower() == 'always' then return 1 end
	return nil
end

local function num(v)
	if type(v) == 'number' then return v end
	if type(v) == 'string' then
		local n = tonumber((v:gsub(',', '')))
		if n then return n end
	end
	return nil
end

local function fmtNum(n)
	if n >= 1000 then return lang:formatNum(math.floor(n + 0.5))
	elseif n >= 100 then return string.format('%.0f', n)
	elseif n >= 10 then return string.format('%.1f', n)
	elseif n >= 1 then return string.format('%.2f', n) end
	return string.format('%.3f', n)
end

local function fmtQty(n)
	if n == math.floor(n) then return tostring(math.floor(n)) end
	local s = string.format('%.2f', n):gsub('0+$', ''):gsub('%.$', '')
	return s
end

-- drop_json may arrive already decoded, or as a JSON string.
local function decode(v)
	if type(v) == 'table' then return v end
	if type(v) ~= 'string' or v == '' then return nil end
	local ok, t = pcall(mw.text.jsonDecode, v)
	if ok and type(t) == 'table' then return t end
	return nil
end

--------------------------------------------------------------------- output --

function p.main(frame)
	local args = frame.args
	local level      = tonumber(args.level) or 120
	local sticky     = yes(args.sticky)
	-- Golden Touch is assumed, not optional: this tool exists for players who
	-- have taken the relic, so there is nothing useful to compare against.
	local golden     = true
	local showLocked = yes(args.showLocked)
	local hideCoins  = yes(args.hideCoins)
	local itemTerms    = splitTerms(args.itemFilter)
	local targetTerms  = splitTerms(args.targetFilter)

	local interval = sticky and TICK_STICKY or TICK_PLAIN
	local attempts = 3600 / interval
	local mult     = golden and 3 or 1

	local selected, nSelected = {}, 0
	for _, r in ipairs(REGIONS) do
		if yes(args[r]) then selected[r:lower()] = true; nSelected = nSelected + 1 end
	end
	if nSelected == 0 then
		return '<div style="' .. NOTICE .. '">Tick at least one region to see what you can steal.</div>'
	end

	-- Restrict the query to known pickpocket targets.
	local conds, isTarget, fallbackLvl = {}, {}, {}
	local nTargets = 0
	for _, t in ipairs(TARGETS) do
		nTargets = nTargets + 1
		conds[#conds + 1] = { 'page_name', t.name }
		isTarget[t.name] = true
		fallbackLvl[t.name] = t.lvl
	end

	local rows, fetched, batches = {}, 0, 0
	for i = 1, #conds, BATCH_SIZE do
		local chunk = {}
		for j = i, math.min(i + BATCH_SIZE - 1, #conds) do
			chunk[#chunk + 1] = conds[j]
		end
		local ok, part = pcall(function()
			local q = bucket(BUCKET)
				.select('page_name', 'item_name', 'drop_json')
				.limit(ROW_LIMIT)
			if #chunk == 1 then q.where(chunk[1][1], chunk[1][2])
			else q.where(bucket.Or(unpack(chunk))) end
			return q.run()
		end)
		if not ok then
			return '<div style="' .. NOTICE .. '">Could not read <code>' .. BUCKET ..
				'</code>: <code>' .. mw.text.nowiki(tostring(part)) .. '</code></div>'
		end
		batches = batches + 1
		for _, r in ipairs(part or {}) do
			rows[#rows + 1] = r
			fetched = fetched + 1
		end
	end

	local shown, totals, seen, skipped, unrated, removed = {}, {}, {}, 0, 0, 0
	-- Funnel counters: each row is counted at the stage it survives to, so a
	-- column that drops to zero names the filter responsible.
	local diag = {}
	local function slot(npcName)
		local d = diag[npcName]
		if not d then
			d = { rows = 0, thieving = 0, levelok = 0, regionok = 0, kept = 0,
			      sregion = nil, srarity = nil, sqty = nil }
			diag[npcName] = d
		end
		return d
	end
	local function bump(npcName, key)
		local d = slot(npcName)
		d[key] = d[key] + 1
	end

	for _, row in ipairs(rows or {}) do
		local npc = row.page_name
		local d   = decode(row.drop_json)
		if npc and isTarget[npc] and d then
			bump(npc, 'rows')
			-- Pickpocket drops only.
			local dtype = tostring(d['Drop type'] or ''):lower()
			if dtype == DROP_TYPE then
				bump(npc, 'thieving')
				local req = num(d['Drop level']) or fallbackLvl[npc] or 1
				local unlocked = level >= req
				do
					local sl = slot(npc)
					if sl.sregion == nil then
						sl.sregion = tostring(d['League region'] or '')
						sl.srarity = tostring(d['Rarity'] or '')
						sl.sqty    = tostring(d['Quantity Low'] or '?') .. '-' ..
						             tostring(d['Quantity High'] or '?')
					end
				end
				if unlocked or showLocked then
					bump(npc, 'levelok')

					-- Regions live in the drop itself, comma separated.
					local regs, inRegion = {}, false
					local raw = tostring(d['League region'] or '')
					for r in raw:gmatch('[^,]+') do
						r = r:match('^%s*(.-)%s*$')
						if r ~= '' then
							local key = r:lower()
							regs[#regs + 1] = CANON[key] or r
							if selected[key] then inRegion = true end
						end
					end
					if #regs == 0 then inRegion = true end -- unrecorded: show it

					if inRegion then
						bump(npc, 'regionok')
						local item   = row.item_name or d['Dropped item'] or '?'
						local hidden = excludedItem(item)
							or (hideCoins and COIN_ITEMS[item])
							or not matchesAny(item, itemTerms)
							or not matchesExact(npc, targetTerms)
						local chance = parseRarity(d['Rarity'])
						local lo, hi = num(d['Quantity Low']), num(d['Quantity High'])
						local qty
						if lo and hi then qty = (lo + hi) / 2
						elseif lo then qty = lo end
						local rolls = num(d['Rolls']) or 1

						-- Coins take their own Golden Touch multiplier.
						local m = mult
						if COIN_ITEMS[item] then
							m = golden and COIN_MULT or 1
						end

						if hidden then
							removed = removed + 1
						elseif qty then
							-- A word rarity ("Common") is shown as-is rather than
							-- converted into a number I would be inventing.
							local perHour = chance and (attempts / chance * qty * rolls * m) or nil
							shown[#shown + 1] = {
								item = item, qty = qty * rolls, chance = chance,
								rlabel = tostring(d['Rarity'] or '?'),
								npc = npc, lvl = req, perHour = perHour,
								mult = m, regions = regs, locked = not unlocked,
							}
							seen[npc] = true
							bump(npc, 'kept')
							if perHour and unlocked then
								totals[npc] = (totals[npc] or 0) + perHour
							else
								unrated = unrated + 1
							end
						else
							skipped = skipped + 1
						end
					end
				end
			end
		end
	end

	if #shown == 0 then
		return '<div style="' .. NOTICE .. '">Nothing to steal with these settings. ' ..
			'Try more regions, a higher Thieving level, or tick "Show targets above my level".</div>'
	end

	table.sort(shown, function(a, b)
		local pa, pb = a.perHour, b.perHour
		if pa and not pb then return true end
		if pb and not pa then return false end
		if pa and pb and pa ~= pb then return pa > pb end
		if a.item ~= b.item then return a.item < b.item end
		return a.npc < b.npc
	end)

	local buf = {}
	buf[#buf + 1] = '<div style="' .. NOTICE .. '">' .. string.format(
		'Thieving %d &middot; %s &middot; %s &middot; one pickpocket every %ss (%s attempts/hour)',
		level,
		"'''Golden Touch''' on",
		sticky and "'''Sticky Fingers''' on" or 'Sticky Fingers off',
		tostring(interval), lang:formatNum(math.floor(attempts))) .. '</div>'

	if #itemTerms > 0 or #targetTerms > 0 then
		local bits = {}
		if #targetTerms > 0 then
			bits[#bits + 1] = "targets named exactly '''" .. table.concat(targetTerms, "''', '''") .. "'''"
		end
		if #itemTerms > 0 then
			bits[#bits + 1] = "items matching '''" .. table.concat(itemTerms, "''', '''") .. "'''"
		end
		buf[#buf + 1] = '<div style="' .. NOTICE .. '">Filtered to ' ..
			table.concat(bits, ' and ') .. '. Clear the filter boxes to see everything again.</div>'
	end

	local order = {}
	for npcName in pairs(seen) do order[#order + 1] = npcName end
	table.sort(order, function(a, b) return (totals[a] or 0) > (totals[b] or 0) end)

	buf[#buf + 1] = '{| class="wikitable sortable" style="margin-bottom:1em"'
	buf[#buf + 1] = '! Target !! Thieving !! Total items/hour'
	for _, npcName in ipairs(order) do
		buf[#buf + 1] = '|-'
		buf[#buf + 1] = '| [[' .. npcName .. ']] || style="text-align:center" | ' ..
			(fallbackLvl[npcName] or '?') .. ' || style="text-align:right" | ' ..
			fmtNum(totals[npcName] or 0)
	end
	buf[#buf + 1] = '|}'

	buf[#buf + 1] = '{| class="wikitable sortable"'
	buf[#buf + 1] = '! Item !! Per catch !! Rate !! Items/hour !! Target !! Lvl !! Region(s)'
	for _, r in ipairs(shown) do
		local regCells = {}
		for _, reg in ipairs(r.regions) do
			regCells[#regCells + 1] = selected[reg:lower()] and ("'''" .. reg .. "'''")
				or ('<span style="opacity:.55">' .. reg .. '</span>')
		end
		local perCatch = r.qty * r.mult
		buf[#buf + 1] = r.locked and '|- style="opacity:.5"' or '|-'
		buf[#buf + 1] = table.concat({
			'| [[' .. r.item .. ']]' .. (COIN_ITEMS[r.item] and golden
				and ' <span style="opacity:.55">(&times;' .. COIN_MULT .. ')</span>' or ''),
			'| style="text-align:center" data-sort-value="' .. perCatch .. '" | ' .. fmtQty(perCatch),
			r.chance
				and ('| style="text-align:center" data-sort-value="' .. r.chance .. '" | 1/' .. fmtQty(r.chance))
				or  ('| style="text-align:center" data-sort-value="999999999" | <span style="opacity:.7">' .. r.rlabel .. '</span>'),
			r.perHour
				and ('| style="text-align:right" data-sort-value="' .. r.perHour .. '" | ' .. fmtNum(r.perHour))
				or  '| style="text-align:right" data-sort-value="-1" | <span style="opacity:.55">not rated</span>',
			'| [[' .. r.npc .. ']]' .. (r.locked and ' <span style="opacity:.55">(locked)</span>' or ''),
			'| style="text-align:center" | ' .. r.lvl,
			'| ' .. (table.concat(regCells, ', ')),
		}, '\n')
	end
	buf[#buf + 1] = '|}'

	local foot = 'Loot, rarities, Thieving levels and regions all read live from the <code>' ..
		BUCKET .. '</code> bucket. Averages over an uninterrupted hour. ' ..
		'Golden Touch does not triple coins.'
	if unrated > 0 then
		foot = foot .. ' ' .. unrated .. ' drop(s) are listed as "not rated": the wiki gives ' ..
			'them a word rarity such as "Common" rather than a fraction, so they are shown ' ..
			'without an hourly figure instead of one being invented. They are excluded from ' ..
			'the per-target totals.'
	end
	if skipped > 0 then
		foot = foot .. ' ' .. skipped .. ' drop(s) hidden: no usable quantity.'
	end
	if removed > 0 then
		foot = foot .. ' ' .. removed .. ' drop(s) filtered out'
			.. (hideCoins and ' (including coins)' or '') .. '.'
	end
	buf[#buf + 1] = '<div style="' .. FOOT .. '">' .. foot .. '</div>'

	if yes(args.diag) then
		buf[#buf + 1] = '=== Diagnostics ==='
		buf[#buf + 1] = '<div style="' .. FOOT .. '">' .. batches .. ' queries, ' ..
			fetched .. ' rows fetched, ' .. nTargets .. ' targets in roster. ' ..
			'Read each row left to right: the column that falls to zero is the filter ' ..
			'that removed it.</div>'
		buf[#buf + 1] = '{| class="wikitable sortable"'
		buf[#buf + 1] = '! Target !! Rows !! Thieving !! Level OK !! Region OK !! Shown ' ..
			'!! Sample League region !! Sample rarity !! Sample qty'
		local keys = {}
		for k in pairs(diag) do keys[#keys + 1] = k end
		table.sort(keys)
		for _, k in ipairs(keys) do
			local d = diag[k]
			local reg = (d.sregion == nil or d.sregion == '')
				and "<span style=\"opacity:.55\">(empty)</span>" or d.sregion
			buf[#buf + 1] = '|-'
			buf[#buf + 1] = '| [[' .. k .. ']] || ' .. d.rows .. ' || ' .. d.thieving ..
				' || ' .. d.levelok .. ' || ' .. d.regionok .. ' || ' .. d.kept ..
				' || ' .. reg .. ' || ' .. (d.srarity or '') .. ' || ' .. (d.sqty or '')
		end
		buf[#buf + 1] = '|}'
	end

	return table.concat(buf, '\n')
end

return p