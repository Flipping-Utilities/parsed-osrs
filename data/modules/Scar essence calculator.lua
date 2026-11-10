local p = {}

-- Runic extracts: coins per extract (paid into Hagus' coffer) and bonus runes per extract.
local EXTRACTS = {
Warped = { cost = 1250, bonus = 250 },
Twisted = { cost = 6000, bonus = 60 },
Mangled = { cost = 12000, bonus = 60 },
Scarred = { cost = 24000, bonus = 60 },
}

-- lv = Runecraft levels at which the base runes per essence goes up to 1x, 2x, 3x, ...
-- req = Runecraft level needed to craft the rune
-- kind = nil (normal), 'sunfire', 'aether' or 'combo'
local RUNES = {
{ name = 'Air rune', ext = 'Warped', lv = { 1, 11, 22, 33, 44, 55, 66, 77, 88, 99 }, req = 1 },
{ name = 'Mind rune', ext = 'Warped', lv = { 2, 14, 28, 42, 56, 70, 84, 98 }, req = 2 },
{ name = 'Water rune', ext = 'Warped', lv = { 5, 19, 38, 57, 76, 95 }, req = 5 },
{ name = 'Earth rune', ext = 'Warped', lv = { 9, 26, 52, 78, 104 }, req = 9 },
{ name = 'Fire rune', ext = 'Warped', lv = { 14, 35, 70 }, req = 14 },
{ name = 'Body rune', ext = 'Warped', lv = { 20, 46, 92 }, req = 20 },
{ name = 'Cosmic rune', ext = 'Twisted', lv = { 27, 59 }, req = 27 },
{ name = 'Chaos rune', ext = 'Twisted', lv = { 35, 74 }, req = 35 },
{ name = 'Sunfire rune', ext = 'Twisted', lv = { 33, 49, 98 }, req = 33, kind = 'sunfire' },
{ name = 'Astral rune', ext = 'Mangled', lv = { 40, 82 }, req = 40 },
{ name = 'Nature rune', ext = 'Mangled', lv = { 44, 91 }, req = 44 },
{ name = 'Law rune', ext = 'Mangled', lv = { 54, 95 }, req = 54 },
{ name = 'Death rune', ext = 'Mangled', lv = { 65, 99 }, req = 65 },
{ name = 'Blood rune', ext = 'Scarred', lv = { 77 }, req = 77 },
{ name = 'Soul rune', ext = 'Scarred', lv = { 90 }, req = 90 },
{ name = 'Wrath rune', ext = 'Scarred', lv = { 95 }, req = 95 },
{ name = 'Aether rune', ext = 'Scarred', lv = { 90 }, req = 90, kind = 'aether' },
{ name = 'Mist rune', ext = 'Twisted', lv = { 6 }, req = 6, kind = 'combo', opts = { 'Air', 'Water' } },
{ name = 'Dust rune', ext = 'Twisted', lv = { 10 }, req = 10, kind = 'combo', opts = { 'Air', 'Earth' } },
{ name = 'Mud rune', ext = 'Twisted', lv = { 13 }, req = 13, kind = 'combo', opts = { 'Water', 'Earth' } },
{ name = 'Smoke rune', ext = 'Twisted', lv = { 15 }, req = 15, kind = 'combo', opts = { 'Air', 'Fire' } },
{ name = 'Steam rune', ext = 'Twisted', lv = { 19 }, req = 19, kind = 'combo', opts = { 'Water', 'Fire' } },
{ name = 'Lava rune', ext = 'Twisted', lv = { 23 }, req = 23, kind = 'combo', opts = { 'Earth', 'Fire' } },
}

-- Number formatting: thousands separators, up to 2 decimals, trailing zeros removed
local function fmt(n)
local s = string.format('%.2f', n)
s = s:gsub('%.?0+$', '')
local int, dec = s:match('^(-?%d+)(.*)$')
if not int then
return s
end
int = int:reverse():gsub('(%d%d%d)', '%1,'):reverse()
int = int:gsub('^,', ''):gsub('^%-,', '-')
return int .. dec
end

local function ceilSafe(n)
return math.ceil(n - 1e-9)
end

local function findRune(name)
for _, r in ipairs(RUNES) do
if r.name == name then
return r
end
end
return nil
end

-- Inventory icon only
local function icon(file, link)
return '[[File:' .. file .. '.png|link=' .. link .. '|28px]]'
end

-- Inventory icon followed by a linked label
local function item(file, link, label)
return icon(file, link) .. ' [[' .. link .. '|' .. (label or link) .. ']]'
end

local function outfitBonus(pieces)
if pieces >= 4 then
return 0.6
end
return pieces * 0.1
end

local function lanternBonus(lantern, runeName)
if lantern == 'Willow/Redwood' then
return 0.05
elseif lantern == 'Magic' then
return 0.10
elseif lantern == 'Blisterwood' and runeName == 'Blood rune' then
return 0.20
end
return 0
end

local function baseRate(r, level)
local n = 0
for _, l in ipairs(r.lv) do
if level >= l then
n = n + 1
end
end
return n
end

local function newTable(caption, headers)
local t = mw.html.create('table')
:addClass('wikitable align-left-1')
:attr('style', 'text-align:right;margin-bottom:1em')
t:tag('caption'):wikitext(caption)
local tr = t:tag('tr')
for _, h in ipairs(headers) do
tr:tag('th'):wikitext(h)
end
return t
end

local function addRow(t, cells)
local tr = t:tag('tr')
for i, c in ipairs(cells) do
local td = tr:tag('td'):wikitext(c)
if i == 1 then
td:attr('style', 'text-align:left')
end
end
end

-- Materials row: icon | item name | quantity
local function addMaterial(t, file, link, qty, label)
local tr = t:tag('tr')
tr:tag('td'):attr('style', 'text-align:center'):wikitext(icon(file, link))
tr:tag('td'):attr('style', 'text-align:left'):wikitext('[[' .. link .. '|' .. (label or link) .. ']]')
tr:tag('td'):wikitext(qty)
end

function p.main(frame)
local args = frame:getParent().args

local runeName = args.Rune_Input or ''
local amount = tonumber(args.Amount_Input) or 0
local level = tonumber(args.Level_Input) or 99
local pieces = math.floor(tonumber(args.Outfit_Input) or 0)
local lantern = args.Lantern_Input or 'None'

pieces = math.max(0, math.min(4, pieces))

local r = findRune(runeName)
if not r then
return '<strong>Select a rune above.</strong>'
end
if amount < 1 then
return '<strong>Please enter an amount greater than zero.</strong>'
end

local base = baseRate(r, level)
if base < 1 then
return '<strong>Runecraft level ' .. r.req .. ' is required to craft ' .. runeName .. 's.</strong>'
end

local ext = EXTRACTS[r.ext]
local extractName = r.ext .. ' extract'

-- Bonuses (outfit and lantern are additive and only act on the base runes)
local outfitPct = outfitBonus(pieces)
local lanternPct = lanternBonus(lantern, runeName)
local bonusPerEssence = base * (outfitPct + lanternPct)

-- Sunfire runes need one twisted extract per base rune crafted, everything else one per essence
local extractsPerEssence = 1
if r.kind == 'sunfire' then
extractsPerEssence = base
end
local extractBonusPerEssence = ext.bonus * extractsPerEssence

local perEssence = base + bonusPerEssence + extractBonusPerEssence

-- Totals (extracts are always rounded up to a whole number)
local essence = ceilSafe(amount / perEssence)
local extracts = essence * extractsPerEssence
local total = essence * perEssence
local coins = extracts * ext.cost
-- Pure essence costs 2 tainted essence each, every extract costs 1, and a chunk is worth 5
local tainted = essence * 2 + extracts
local chunks = ceilSafe(tainted / 5)

local div = mw.html.create('div')

-- Output
local ot = newTable('Output', { 'Rune', 'Requested', 'Crafted' })
addRow(ot, { item(runeName, runeName), fmt(amount), fmt(total) })

-- Runes per essence breakdown
local rt = newTable('Runes per essence', { 'Source', 'Runes' })
addRow(rt, { 'Base (level ' .. level .. ')', fmt(base) })
if bonusPerEssence > 0 then
addRow(rt, { 'Outfit and lantern (+' .. fmt((outfitPct + lanternPct) * 100) .. '%)', fmt(bonusPerEssence) })
end
addRow(rt, { 'Extract bonus', fmt(extractBonusPerEssence) })
local totalRow = rt:tag('tr')
totalRow:tag('th'):attr('style', 'text-align:left'):wikitext('Total')
totalRow:tag('th'):wikitext(fmt(perEssence))

-- Materials (icon | item | quantity): chunks, coins, extracts, essence, then extras
local mt = newTable('Materials required', { '', 'Item', 'Quantity' })
addMaterial(mt, 'Tainted essence chunk', 'Tainted essence chunk', fmt(chunks))
addMaterial(mt, 'Coins 10000', 'Coins', fmt(coins), 'Coins (Hagus\' coffer)')
addMaterial(mt, extractName, extractName, fmt(extracts))
addMaterial(mt, 'Pure essence', 'Pure essence', fmt(essence))

if r.kind == 'sunfire' then
addMaterial(mt, 'Fire rune', 'Fire rune', fmt(essence))
addMaterial(mt, 'Sunfire splinters', 'Sunfire splinters', fmt(essence))
elseif r.kind == 'aether' then
addMaterial(mt, 'Soul rune', 'Soul rune', fmt(essence))
addMaterial(mt, 'Aether catalyst', 'Aether catalyst', fmt(ceilSafe(total)))
end

div:node(ot):node(rt):node(mt)

-- Combination runes: one elemental rune per essence, either of the two types
if r.kind == 'combo' then
local o1, o2 = r.opts[1], r.opts[2]
div:tag('p'):wikitext(
'Each essence also needs one elemental rune: ' ..
fmt(essence) .. ' ' .. item(o1 .. ' rune', o1 .. ' rune') ..
' <strong>or</strong> ' ..
fmt(essence) .. ' ' .. item(o2 .. ' rune', o2 .. ' rune') ..
'. See [[Combination rune]] for details.'
)
end

return tostring(div)
end

return p