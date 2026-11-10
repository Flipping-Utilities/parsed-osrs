-- <pre>
-- Implements [[Template:DungTable]]
--
local p = {}

local yesno = require('Module:Yesno')
require("Module:Mw.html extension")

-- Table to iterate through for tiers
-- Includes the respective materials for each tier
local tiers = {
	-- {level,{metal,leather,cloth,wood}}
	-- spaces put here to avoid an extra catch for ecto items
	{ '1', { 'Novite ', 'Protoleather ', 'Salve ', 'Tangle gum ' } },
	{ '10', { 'Bathus ', 'Subleather ', 'Wildercress ', 'Seeping elm ' } },
	{ '20', { 'Marmaros ', 'Paraleather ', 'Blightleaf ', 'Blood spindle ' } },
	{ '30', { 'Kratonite ', 'Archleather ', 'Roseblood ', 'Utuku ' } },
	{ '40', { 'Fractite ', 'Dromoleather ', 'Bryll ', 'Spinebeam ' } },
	{ '50', { 'Zephyrium ', 'Spinoleather ', 'Duskweed ', 'Bovistrangler ' } },
	{ '60', { 'Argonite ', 'Gallileather ', 'Soulbell ', 'Thigat ' } },
	{ '70', { 'Katagon ', 'Stegoleather ', 'Ecto', 'Corpsethorn ' } },
	{ '80', { 'Gorgonite ', 'Megaleather ', 'Runic ', 'Entgallow ' } },
	{ '90', { 'Promethium ', 'Tyrannoleather ', 'Spiritbloom ', 'Grave creeper ' } },
	{ '99', { 'Primal ', 'Sagittarian ', 'Celestial ', 'Sagittarian ' } }
}

local catalytics = {
	{ '40', 'Catalytic ' },
	{ '90', 'Empowered catalytic ' },
	{ '99', 'Celestial catalytic ' },
}

-- Skills required and material index for each item type
local reqs = {
	-- type = {{skills},Y for tier[X][Y]}
	['dagger'] = { { 'Attack' }, 1 },
	['rapier'] = { { 'Attack' }, 1 },
	['longsword'] = { { 'Attack' }, 1 },
	['battleaxe'] = { { 'Attack' }, 1 },
	['warhammer'] = { { 'Attack' }, 1 },
	['spear'] = { { 'Attack' }, 1 },
	['2h sword'] = { { 'Attack' }, 1 },
	['maul'] = { { 'Strength' }, 1 },
	['pickaxe'] = { { 'Mining' }, 1 },
	['hatchet'] = { { 'Attack', 'Woodcutting' }, 1 },
	['full helm'] = { { 'Defence' }, 1 },
	['chainbody'] = { { 'Defence' }, 1 },
	['platebody'] = { { 'Defence' }, 1 },
	['plateskirt'] = { { 'Defence' }, 1 },
	['platelegs'] = { { 'Defence' }, 1 },
	['kiteshield'] = { { 'Defence' }, 1 },
	['melee boots'] = { { 'Defence' }, 1 },
	['gauntlets'] = { { 'Defence' }, 1 },
	['shortbow'] = { { 'Ranged' }, 4 },
	['longbow'] = { { 'Ranged' }, 4 },
	['arrows'] = { { 'Ranged' }, 1 },
	['knife'] = { { 'Ranged' }, 1 },
	['coif'] = { { 'Ranged', 'Defence' }, 2 },
	['body'] = { { 'Ranged', 'Defence' }, 2 },
	['chaps'] = { { 'Ranged', 'Defence' }, 2 },
	['vambraces'] = { { 'Ranged', 'Defence' }, 2 },
	['ranged shield'] = { { 'Ranged', 'Defence' }, 2 },
	['ranged boots'] = { { 'Ranged', 'Defence' }, 2 },
	['staff'] = { { 'Magic' }, 4 },
	['wand'] = { { 'Magic' }, 4 },
	['orb'] = { { 'Magic' }, 3 },
	['hood'] = { { 'Magic', 'Defence' }, 3 },
	['robe top'] = { { 'Magic', 'Defence' }, 3 },
	['robe bottom'] = { { 'Magic', 'Defence' }, 3 },
	['gloves'] = { { 'Magic', 'Defence' }, 3 },
	['shoes'] = { { 'Magic', 'Defence' }, 3 },
	['magic shield'] = { { 'Magic', 'Defence' }, 3 }
}

-- types that can have offhands
local off_hands = {
	['dagger'] = true,
	['rapier'] = true,
	['longsword'] = true,
	['battleaxe'] = true,
	['warhammer'] = true,
	['knife'] = true
}

function p.main(frame)
	local args = frame:getParent().args
	local item = string.lower(args[1] or 'dagger')

	local type = args.type
	if type and reqs[type:lower()] then
		item = type:lower() .. ' ' .. item
	end

	local offhand = yesno(args.offhand)
	if offhand and off_hands[item] then
		offhand = true
	else
		offhand = false
	end

	return p._main(item, offhand)
end

function p._main(item, offhand)
	local ret = mw.html.create('table')
		:addClass('wikitable')

	ret:tr()
		:th { "Item", attr = { colspan = 2 } }
		:th('Level to use')

	local req = reqs[item]
	local skill_req = req[1]
	local mat_idx = req[2]

	for i, v in ipairs(tiers) do
		local level = v[1]
		local mats = v[2]
		local mat_name = mats[mat_idx]

		local item_name = mat_name .. item
		if offhand then
			item_name = 'Off-hand ' .. item_name:lower()
		end

		-- catch for oddballs
		if i == 8 and item == 'orb' then
			item_name = 'Ectosphere'
		elseif i == 11 then
			if item == 'arrows' then
				item_name = 'Sagittarian arrows'
			elseif item == 'staff' then
				break
			elseif item == 'wand' then
				break
			elseif item == 'orb' then
				break
			end
		end

		ret:tr()
			:td('[[File:' .. item_name .. '.png|link=' .. item_name .. ']]')
			:td('[[' .. item_name .. ']]')
			:td(skill_reqs(skill_req, level))
	end

	if item == 'staff' or item == 'wand' or item == 'orb' then
		skill_req = { 'Magic' }
		for _, v in ipairs(catalytics) do
			local level = v[1]
			local mats = v[2]

			local item_name = mats .. item

			ret:tr()
				:td('[[File:' .. item_name .. '.png|link=' .. item_name .. ']]')
				:td('[[' .. item_name .. ']]')
				:td(skill_reqs(skill_req, level))
		end
	end

	return ret
end

-- Function to handle string for skill reqs
function skill_reqs(skill, level)
	local ret = ''

	for i, v in ipairs(skill) do
		ret = ret .. level .. ' [[File:' .. v .. '-icon.png|link=' .. v .. ']]'
		if i < #skill then
			ret = ret .. '; '
		end
	end

	return ret
end

return p