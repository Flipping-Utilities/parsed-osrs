--------------------------
-- Module for {{Infobox Mine}}
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')
local addcategories

local rockparams = {
	["tin"] = { txt = "[[tin rock]] [[File:Tin ore.png]]", cat = "tin rocks" },
	["copper"] = { txt = "[[copper rock]] [[File:Copper ore.png]]", cat = "copper rocks" },
	["iron"] = { txt = "[[iron rock]] [[File:Iron ore.png]]", cat = "iron rocks" },
	["silver"] = { txt = "[[silver rock]] [[File:Silver ore.png]]", cat = "silver rocks" },
	["coal"] = { txt = "[[coal rock]] [[File:Coal.png]]", cat = "coal rocks" },
	["concentrated coal"] = { txt = "[[concentrated coal deposit]] [[File:Coal.png]]", cat = "concentrated coal deposits" },
	["gold"] = { txt = "[[gold rock]] [[File:Gold ore.png]]", cat = "gold rocks" },
	["concentrated gold"] = { txt = "[[concentrated gold deposit]] [[File:Gold ore.png]]", cat = "concentrated gold deposits" },
	["mithril"] = { txt = "[[mithril rock]] [[File:Mithril ore.png]]", cat = "mithril rocks" },
	["adamantite"] = { txt = "[[adamantite rock]] [[File:Adamantite ore.png]]", cat = "adamantite rocks" },
	["runite"] = { txt = "[[runite rock]] [[File:Runite ore.png]]", cat = "runite rocks" },
	["blurite"] = { txt = "[[blurite rock]] [[File:Blurite ore.png]]", cat = "blurite rocks" },
	["magic stone"] = { txt = "[[Rocks (Tears of Guthix)|magic stone rocks]] [[File:Magic stone (Tears of Guthix).png]]", cat = "magic stone rocks" },
	["daeyalt"] = { txt = "[[daeyalt vein]] [[File:Daeyalt ore.png]]", cat = "daeyalt veins" },
	["rubium"] = { txt = "[[rubium vein]] [[File:Rubium.png]]", cat = "rubium veins" },
	["sandstone"] = { txt = "[[sandstone rock]] [[File:Sandstone (10kg).png]]", cat = "sandstone rocks" },
	["mineral deposit"] = { txt = "[[mineral deposit]] [[File:Sandstone (10kg).png]]", cat = "mineral deposits" },
	["banite"] = { txt = "[[banite rock]] [[File:Banite ore.png]]", cat = "banite rocks" },
	["clay"] = { txt = "[[clay rock]] [[File:Clay.png]]", cat = "clay rocks" },
	["soft clay"] = { txt = "[[soft clay rock]] [[File:Soft clay.png]]", cat = "soft clay rocks" },
	["gem"] = { txt = "[[Gem rock (Tai Bwo Wannai)]] [[File:Uncut lapis lazuli.png]]", cat = "gem rocks" },
	["common gem"] = { txt = "[[common gem rock]] [[File:Uncut jade.png]]", cat = "common gem rocks" },
	["uncommon gem"] = { txt = "[[uncommon gem rock]] [[File:Uncut sapphire.png]]", cat = "uncommon gem rocks" },
	["precious gem"] = { txt = "[[precious gem rock]] [[File:Uncut ruby.png]]", cat = "precious gem rocks" },
	["rare gem"] = { txt = "[[rare gem rock]] [[File:Uncut diamond.png]]", cat = "rare gem rocks" },
	["prifddinas gem"] = { txt = "[[Prifddinas gem rock]] [[File:Uncut dragonstone.png]]", cat = "Prifddinas gem rocks" },
	["kalgerion gem"] = { txt = "[[Kal'gerion gem rock]] [[File:Uncut dragonstone.png]]", cat = "Kal'gerion gem rocks" },
	["granite"] = { txt = "[[granite rock]] [[File:Granite (5kg).png]]", cat = "granite rocks" },
	["limestone"] = { txt = "[[limestone rock]] [[File:Limestone.png]]", cat = "limestone rocks" },
	["essence"] = { txt = "[[rune essence rock]] [[File:Rune essence.png]]", cat = "essence rocks" },
	["rune essence"] = { txt = "[[rune essence rock]] [[File:Rune essence.png]]", cat = "essence rocks" },
	["drakolith"] = { txt = "[[drakolith rock]] [[File:Drakolith.png]]", cat = "drakolith rocks" },
	["orichalcite"] = { txt = "[[orichalcite rock]] [[File:Orichalcite ore.png]]", cat = "orichalcite rocks" },
	["luminite"] = { txt = "[[luminite rock]] [[File:Luminite.png]]", cat = "luminite rocks" },
	["necrite"] = { txt = "[[necrite rock]] [[File:Necrite ore.png]]", cat = "necrite rocks" },
	["phasmatite"] = { txt = "[[phasmatite rock]] [[File:Phasmatite.png]]", cat = "phasmatite rocks" },
	["light animica"] = { txt = "[[light animica rock]] [[File:Light animica.png]]", cat = "light animica rocks" },
	["dark animica"] = { txt = "[[dark animica rock]] [[File:Dark animica.png]]", cat = "dark animica rocks" },
	["salty crabletine"] = { txt = "[[salty crabletine]] [[File:Sea salt.png]]", cat = "salty crabletines" },
	["salty crablet"] = { txt = "[[salty crablet]] [[File:Sea salt.png]]", cat = "salty crablets" },
	["alaea crablet"] = { txt = "[[alaea crablet]] [[File:Alaea sea salt.png]]", cat = "alaea crablets" },
	["stone slab vein"] = { txt = "[[Stone slab vein]] [[File:Stone slab.png]]", cat = "stone slab veins" },
	["perfect gold"] = { txt = "[['Perfect' gold rock]] [[File:'Perfect' gold ore.png]]", cat = "'perfect' gold rocks" },
	["red sandstone"] = { txt = "[[red sandstone (rock)]] [[File:Red sandstone.png]]", cat = "red sandstones" },
	["punishment rock"] = { txt = "[[punishment rock]] [[File:Punishment rock (ore).png]]", cat = "punishment rocks" },
	["crystal-flecked sandstone"] = { txt = "[[crystal-flecked sandstone (rock)]] [[File:Crystal-flecked sandstone.png]]", cat = "crystal-flecked sandstones" },
	["feldip swamp"] = { txt = "[[feldip swamp rock]] [[File:Rock (ore).png]]", cat = "feldip swamp rocks" },
	["solid crystal"] = { txt = "[[solid crystal]] [[File:Crystal fragment.png]]", cat = "solid crystals" },
	["moulding guard"] = { txt = "[[moulding guard]] [[File:Enriched calcified fungus.png]]", cat = "moulding guards" },
	["crust"] = { txt = "[[crust]]", cat = "crust" },
	["soggy copper"] = { txt = "[[copper rock (Beneath Cursed Tides)]] [[File:Soggy copper ore.png]]", cat = "soggy copper rocks" },
	["soggy tin"] = { txt = "[[tin rock (Beneath Cursed Tides)]] [[File:Soggy tin ore.png]]", cat = "soggy tin rocks" },
	["novite"] = { txt = "[[novite rock]] [[File:Novite ore.png]]", cat = "novite rocks" },
	["kratonium"] = { txt = "[[kratonium rock]] [[File:Kratonium ore.png]]", cat = "kratonium rocks" },
	["fractite"] = { txt = "[[fractite rock]] [[File:Fractite ore.png]]", cat = "fractite rocks" },
	["bathus"] = { txt = "[[bathus rock]] [[File:Bathus ore.png]]", cat = "bathus rocks" },
	["promethium"] = { txt = "[[promethium rock]] [[File:Promethium ore.png]]", cat = "promethium rocks" },
	["gorgonite"] = { txt = "[[gorgonite rock]] [[File:Gorgonite ore.png]]", cat = "gorgonite rocks" },
	["marmaros"] = { txt = "[[marmaros rock]] [[File:Marmaros ore.png]]", cat = "marmaros rocks" },
	["zephyrium"] = { txt = "[[zephyrium rock]] [[File:Zephyrium ore.png]]", cat = "zephyrium rocks" },
	["katagon"] = { txt = "[[katagon rock]] [[File:Katagon ore.png]]", cat = "katagon rocks" },
	["argonite"] = { txt = "[[argonite rock]] [[File:Argonite ore.png]]", cat = "argonite rocks" },
	["seren stone"] = { txt = "[[seren stone]] [[File:Corrupted ore.png]]", cat = "seren stones" },
	["porcelain clay"] = { txt = "[[porcelain clay rock]] [[File:Porcelain clay.png]]", cat = "porcelain clay rocks" },
	["platinum"] = { txt = "[[platinum rock]] [[File:Platinum ore.png]]", cat = "platinum rocks" },
	["meteorite"] = { txt = "[[Meteorite (Zolarea)|meteorite]] [[File:Meteorite chunk.png]]", cat = "meteorites" },
	["havensilver"] = { txt = "[[havensilver rock]] [[File:Havensilver ore.png]]", cat = "havensilver rocks" },
}

local function requirements_arg(arg)
	if not infobox.isDefined(arg) then
		return 'None'
	end

	return arg
end

local function get_resource_from_string(rocks, resources_i)
	if not infobox.isDefined(resources_i) then
		return
	end
	local name, qty = resources_i:match('(.+),%s*(%d+)')
	if name ~= nil then
		table.insert(rocks, { name, qty })
	end
end

local function get_name_from_rock(rocks, i, key)
	if not infobox.isDefined(rocks) then
		return
	end

	local rock = rocks[tonumber(i)]
	if rock == nil then
		return
	end

	return rock[tonumber(key)]
end

local function rock_arg(rock, resource1, resource2, resource3, resource4, resource5)
	local rocks = {}
	if infobox.isDefined(rock) then
		local rock_args = mw.text.split(rock, '%s*,%s*')
		for _, name in ipairs(rock_args) do
			table.insert(rocks, { name })
		end
	end

	get_resource_from_string(rocks, resource1)
	get_resource_from_string(rocks, resource2)
	get_resource_from_string(rocks, resource3)
	get_resource_from_string(rocks, resource4)
	get_resource_from_string(rocks, resource5)

	return rocks
end

local function rock_disp(rocks)
	if not infobox.isDefined(rocks) then
		return {}
	end

	local res = {}

	for _, rock in ipairs(rocks) do
		local qty = rock[2]
		local out = "\n* "
		if qty then
			out = out .. qty .. " × "
		end

		local name = rock[1]
		local data = rockparams[name]
		if data then
			table.insert(res, out .. data.txt)
		else
			table.insert(res, out .. name)
		end
	end

	return table.concat(res, '\n')
end

-- lazy-load Module
local function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end

-- Main function called with invokes
function p.main(frame)
	local args = frame:getParent().args
	-- collect_resources(args)

	local ret = infobox.new(args)

	-- Build params table
	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'requirements', func = requirements_arg },
		{ name = 'rock', func = { name = rock_arg, params = { 'rock', 'resource1', 'resource2', 'resource3', 'resource4', 'resource5' }, flag = { 'p', 'p', 'p', 'p', 'p', 'p' } }, dupes = true },
		{ name = 'rock_disp', func = { name = rock_disp, params = { 'rock' }, flag = 'd' } },
		{ name = 'leagueRegion', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
		{ name = 'leagueRegion_disp', func = { name = leaguesArg, params = { 'leagueRegion' }, flag = 'd' } },
		{ name = 'location_type', func = { params = { 'mine' }, flag = 'r' } },
		{ name = 'rock1', func = { name = get_name_from_rock, params = { 'rock', '1', '1' }, flag = { 'd', 'r', 'r' } } },
		{ name = 'count1', func = { name = get_name_from_rock, params = { 'rock', '1', '2' }, flag = { 'd', 'r', 'r' } } },
		{ name = 'rock2', func = { name = get_name_from_rock, params = { 'rock', '2', '1' }, flag = { 'd', 'r', 'r' } } },
		{ name = 'count2', func = { name = get_name_from_rock, params = { 'rock', '2', '2' }, flag = { 'd', 'r', 'r' } } },
		{ name = 'rock3', func = { name = get_name_from_rock, params = { 'rock', '3', '1' }, flag = { 'd', 'r', 'r' } } },
		{ name = 'count3', func = { name = get_name_from_rock, params = { 'rock', '3', '2' }, flag = { 'd', 'r', 'r' } } },
		{ name = 'rock4', func = { name = get_name_from_rock, params = { 'rock', '4', '1' }, flag = { 'd', 'r', 'r' } } },
		{ name = 'count4', func = { name = get_name_from_rock, params = { 'rock', '4', '2' }, flag = { 'd', 'r', 'r' } } },
		{ name = 'rock5', func = { name = get_name_from_rock, params = { 'rock', '5', '1' }, flag = { 'd', 'r', 'r' } } },
		{ name = 'count5', func = { name = get_name_from_rock, params = { 'rock', '5', '2' }, flag = { 'd', 'r', 'r' } } },
	}

	ret:useBucket('resource_locations', {
		name = 'location',
		location_type = 'resource_location_type',
		skill = 'skill',
		requirements = 'requirements',
		leagueRegion = 'league_region',
	})

	ret:setMaxButtons(4)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)
	ret:defineLinks { hide = true }
	ret:defineName('Infobox Mine')
	ret:addClass('infobox-mine left-info')
	ret:addButtonsCaption()

	-- PARAMETER: name
	ret:addRow {
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '3' },
	}
	ret:pad(3)

	-- PARAMETER: requirements
	ret:addRow {
		{ tag = 'th', content = 'Requirements' },
		{ tag = 'argd', content = 'requirements', colspan = '2' },
	}

	ret:addRow {
		{ tag = 'th', content = 'Rocks' },
		{ tag = 'argd', content = 'rock_disp', colspan = '2' },
	}

	-- PARAMETER: leagueRegion
	if ret:paramDefined('leagueRegion') then
		local leagues = require('Module:LeagueRegion')
		ret:addRow {
			{ tag = 'th', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] region' },
			{ tag = 'argd', content = 'leagueRegion_disp', colspan = '2' },
			meta = { addClass = 'leagues-global-flag' },
		}
	end

	ret:pad(3)

	ret:finish()

	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function addcategories(args, catargs)
	local ret = { 'Mines' }

	local cat_map = {
		-- Added if the parameter has content
		-- Rock params are handled separately below
		defined = {
			leagueRegion = 'Pages with League region',
		},
		-- Added if the parameter has no content
		notdefined = {
			leagueRegion = 'Needs League region',
		},
	}

	-- Run and add mapped categories
	for n, v in pairs(cat_map.defined) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret, v)
		end
	end
	for n, v in pairs(cat_map.notdefined) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret, v)
		end
	end

	-- -- Add categories for rock types found in resource params
	-- for name, rock in pairs(p.rockparams) do
	-- 	if usedRocks[name] then
	-- 		table.insert(ret, "Mines with " .. rock.cat)
	-- 	end
	-- end

	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end

	return table.concat(ret, '')
end

return p