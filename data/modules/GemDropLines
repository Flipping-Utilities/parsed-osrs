local drops_line = require('Module:DropsLine')._main

local RARITY_NOTES = {
	nothing = 'The "nothing" drop is removed while wearing a [[ring of wealth]].',
	row = 'The drop rate is increased while wearing a [[ring of wealth]] due to the "nothing" drop being removed.',
	legend = 'Only dropped if [[Legends\' Quest]] has been finished; if not, a talisman is dropped instead.',
	talisman = 'The talisman dropped depends on where the player is located ([[Gem drop table#Talisman|map]]); typically, a nature talisman will drop above ground level and a chaos talisman will drop underground.',
	salvageNothing = 'The single coin drop is removed while wearing a [[ring of wealth]].',
	salvageRow = 'The drop rate is increased while wearing a [[ring of wealth]] due to the single coin drop being removed.'
}

local UNKNOWN_RARITIES = {
	['Nothing'] = 'Rare',
	['Uncut sapphire'] = 'Rare',
	['Uncut emerald'] = 'Rare'
	-- ['Everything else'] = 'Very rare'
}

local p = {}

function expr(t)
    local noerr, val = pcall(mw.ext.ParserFunctions.expr, t)
    if noerr then
        return tonumber(val)
    else
        return false
    end
end

function round(num, places)
	local mult = 10 ^ places
	return math.floor(num * mult + 0.5) / mult
end

function calculate(rate, chaostalisman, naturetalisman)
	local results = {}
	table.insert(results, {
		item = 'Nothing',
		quantity = 1,
		rarity = rate * 63/128 + rate * 1/128 * 113/128,
		altrarity = 'Never',
		f2pRarity = rate * 70/128,
		notes = {'nothing'}
	})
	table.insert(results, {
		item = 'Uncut sapphire',
		quantity = 1,
		rarity = rate * 32/128,
		altrarity = rate * 32/65,
		f2pRarity = rate * 32/128,
		notes = {'row'}
	})
	table.insert(results, {
		item = 'Uncut emerald',
		quantity = 1,
		rarity = rate * 16/128,
		altrarity = rate * 16/65,
		f2pRarity = rate * 16/128,
		notes = {'row'}
	})
	table.insert(results, {
		item = 'Uncut ruby',
		quantity = 1,
		rarity = rate * 8/128,
		altrarity = rate * 8/65,
		f2pRarity = rate * 8/128,
		notes = {'row'}
	})
	if chaostalisman and naturetalisman then
		table.insert(results, {
			item = 'Chaos talisman',
			quantity = 1,
			rarity = rate * 3/128,
			altrarity = rate * 3/65,
			notes = {'row', 'talisman'}
		})
		table.insert(results, {
			item = 'Nature talisman',
			quantity = 1,
			rarity = rate * 3/128,
			altrarity = rate * 3/65,
			notes = {'row', 'talisman'}
		})
	elseif chaostalisman then
		table.insert(results, {
			item = 'Chaos talisman',
			quantity = 1,
			rarity = rate * 3/128,
			altrarity = rate * 3/65,
			notes = {'row'}
		})
	elseif naturetalisman then
		table.insert(results, {
			item = 'Nature talisman',
			quantity = 1,
			rarity = rate * 3/128,
			altrarity = rate * 3/65,
			notes = {'row'}
		})
	else
		table.insert(results, {
			item = 'Unknown talisman',
			quantity = 1,
			rarity = rate * 3/128,
			altrarity = rate * 3/65,
			notes = {'row', 'talisman'},
			image = 'Rare drop table talisman.png'
		})
	end
	table.insert(results, {
		item = 'Uncut diamond',
		quantity = 1,
		rarity = rate * 2/128,
		altrarity = rate * 2/65,
		f2pRarity = rate * 2/128,
		notes = {'row'}
	})
	table.insert(results, {
		item = 'Rune javelin',
		quantity = 5,
		rarity = rate * 1/128,
		altrarity = rate * 1/65,
		notes = {'row'}
	})
	table.insert(results, {
		item = 'Loop half of key',
		quantity = 1,
		rarity = rate * 1/128,
		altrarity = rate * 1/65,
		notes = {'row'}
	})
	table.insert(results, {
		item = 'Tooth half of key',
		quantity = 1,
		rarity = rate * 1/128,
		altrarity = rate * 1/65,
		notes = {'row'}
	})
	table.insert(results, {
		item = 'Rune spear',
		quantity = 1,
		rarity = rate * 1/128 * 8/128,
		altrarity = rate * 1/65 * 8/15,
		notes = {'row', 'legend'}
	})
	table.insert(results, {
		item = 'Shield left half',
		quantity = 1,
		rarity = rate * 1/128 * 4/128,
		altrarity = rate * 1/65 * 4/15,
		notes = {'row', 'legend'}
	})
	table.insert(results, {
		item = 'Dragon spear',
		quantity = 1,
		rarity = rate * 1/128 * 3/128,
		altrarity = rate * 1/65 * 3/15,
		notes = {'row', 'legend'}
	})
	return results
end

function make_row(frame, data, rolls, dtype, approx, unknown, f2p_only, f2p_subscript, salvage)
	local item = data['item']
	local qty = data['quantity']
	local rarity = data['rarity']
	local altrarity = data['altrarity']  -- can be nil
	local f2pRarity = data['f2pRarity']  -- can be nil
	local notes = data['notes']  -- can be nil
	local image = data['image']  -- can be nil

	if unknown then
		rarity = UNKNOWN_RARITIES[item] or 'Very rare'
		altrarity = nil
	elseif f2p_only then
		rarity = '1/' .. round(1 / f2pRarity, 2)
		altrarity = nil
	else
		rarity = '1/' .. round(1 / rarity, 2)

		if altrarity ~= nil and altrarity ~= 'Never' then
			altrarity = '1/' .. round(1 / altrarity, 2)
		end
	end

	if salvage then
		if item == 'Nothing' then
			item = 'Coins'
			qty = 1
		end
		for i, noteName in ipairs(notes) do
			if noteName == 'nothing' then
				notes[i] = 'salvageNothing'
			elseif noteName == 'row' then
				notes[i] = 'salvageRow'
			end
		end
	end

	if f2p_only then
		notes = {}  -- RoW and other notes don't apply on f2p worlds
	end

	local note_name, note_text
	local all_notes = ''
	if notes ~= nil then
		for _, note_name in ipairs(notes) do
			note_text = RARITY_NOTES[note_name]
			all_notes = all_notes .. frame:extensionTag(
				'ref', note_text, { name = note_name, group = 'd' }
			)
		end
	end

	local namenotes
	if f2p_subscript and f2pRarity == nil then
		namenotes = frame:expandTemplate{ title='(m)' }
	end

	local args = {
		name = item,
		quantity = tostring(qty),
		rarity = rarity,
		altrarity = altrarity,
		rolls = rolls,
		image = image,
		raritynotes = all_notes,
		approx = approx,
		rdt = 'yes',
		namenotes = namenotes
	}

	local frame_args = {
		dtype = dtype
	}

	return drops_line(args, frame_args)
end

function p.main(frame)
    local args = frame:getParent().args

	local rate = expr(args[1])
	local rolls = args.rolls
	local chaostalisman = args.chaostalisman
	local naturetalisman = args.naturetalisman
	local approx = args.approx
	local f2p_only = args.f2pOnly
	local f2p_subscript = args.f2p
	
	local salvage = false
	if args.salvage then
		salvage = true
	end

	local dtype = 'combat'
	if args.reward then
		dtype = 'reward'
	elseif args.skill ~= nil then
		dtype = string.lower(args.skill)
	end

	local unknown = false
	if not rate then
		unknown = true
		rate = 0
	end

	local drop_data = calculate(rate, chaostalisman, naturetalisman)

	local out_lines = {}
	for _, data in ipairs(drop_data) do
		-- skip members drops if we're doing f2p only
		if not (f2p_only and data['f2pRarity'] == nil) then
			table.insert(out_lines, 
				make_row(frame, data, rolls, dtype, approx, unknown, f2p_only, f2p_subscript, salvage)
			)
		end
	end

    return table.concat(out_lines, '\n')
end

return p