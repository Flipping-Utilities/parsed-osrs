local weaknesses_data = {
	-- Magic weaknesses
	['magic'] = { image = 'Magic weakness icon.png', link = 'Magic', category = 'Weak to magic attacks' },
	['air'] = { image = 'Air weakness icon.png', link = 'Air spells', category = 'Weak to air spells' },
	['water'] = { image = 'Water weakness icon.png', link = 'Water spells', category = 'Weak to water spells' },
	['earth'] = { image = 'Earth weakness icon.png', link = 'Earth spells', category = 'Weak to earth spells' },
	['fire'] = { image = 'Fire weakness icon.png', link = 'Fire spells', category = 'Weak to fire spells' },
	['ancients'] = { image = 'Ice Barrage icon.png', link = 'Ancient Magicks', category = 'Susceptible to Ancient Magicks', _suscept = true},
	-- Melee weaknesses
	['melee'] = { image = 'Melee weakness icon.png', link = 'Melee', category = 'Weak to melee attacks' },
	['crush'] = { image = 'Crush weakness icon.png', link = 'Crush weapons', text = 'Crush', category = 'Weak to crush attacks', aliases={'crushing'} },
	['slash'] = { image = 'Slash weakness icon.png', link = 'Slash weapons', text = 'Slash', category = 'Weak to slash attacks', aliases={'slashing'} },
	['stab'] = { image = 'Stab weakness icon.png', link = 'Stab weapons', text = 'Stab', category = 'Weak to stab attacks', aliases={'stabbing'} },
	-- Ranged weaknesses
	['ranged'] = { image = 'Ranged weakness icon.png', link = 'Ranged weapons', text = 'Ranged', category = 'Weak to ranged attacks', aliases={'range'} },
	['arrows'] = { image = 'Arrow weakness icon.png', link = 'Arrows', category = 'Weak to arrows', aliases={'arrow'} },
	['bolts'] = { image = 'Bolt weakness icon.png', link = 'Bolts', category = 'Weak to bolts', aliases={'bolt'} },
	['thrown'] = { image = 'Thrown weakness icon.png', link = 'Thrown weapons', text = 'Thrown', category = 'Weak to thrown weapons', aliases={'throwing'} },
	-- Necromancy weaknesses
	['necromancy'] = { image = 'Necromancy weakness icon.png', link = 'Necromancy', category = 'Weak to Necromancy', aliases={'necro'} },
	-- Specific weapons
	['blisterwood'] = { image = 'Blisterwood staff.png', link = 'Blisterwood', category = 'Susceptible to blisterwood weapons', aliases={'sunspear'}, _suscept = true },
	['keris'] = { image = 'Keris.png', link = 'Keris', category = {'Susceptible to keris','Susceptible to consecrated keris'}, _suscept = true }, -- extra 00240F
	['consecrated keris'] = { image = 'Consecrated keris.png', link = 'Consecrated keris', category = 'Susceptible to consecrated keris', _suscept = true, aliases={'consecratedkeris'} }, -- extra 002410
	['balmung'] = { image = 'Balmung.png', link = 'Balmung', category = 'Susceptible to Balmung', _suscept = true },
	['gadderhammer'] = { image = 'Gadderhammer.png', link = 'Gadderhammer', category = 'Susceptible to Gadderhammer', _suscept = true },
	['brutal'] = { image = 'Steel brutal 2.png', link = 'Brutal arrows', category = 'Susceptible to brutal arrows', _suscept = true },
	['magic secateurs'] = { image = 'Magic secateurs.png', link = 'Magic secateurs', aliases={'magicsecateurs'}, _suscept = true },
	['korasi'] = { image = "Korasi's sword.png", link = "Korasi's sword", _suscept = true },
	['ancient mace'] = { image = 'Ancient mace.png', link = 'Ancient mace', aliases={'ancientmace'}, _suscept = true },
	['pickaxe'] = { image = 'Rune pickaxe.png', link = 'Pickaxes', _suscept = true },
	['leaf-bladed'] = { image = 'Leaf-bladed spear.png', link = 'Leaf-bladed weapon', _suscept = true },
	['silver'] = { image = 'Silver sickle.png', link = 'Silver weapon', _suscept = true },
	['spear'] = { image = 'Dragon spear.png', link = 'Spear', _suscept = true },
	['gorajo'] = { image = 'Sachem bloodrager pouch.png', link = 'Dungeoneering/Summoning', text = 'Gorajo familiars', _suscept = true },
	['ruinous'] = { image = 'Warped stone.png', link = 'Ruinous weapons', category = 'Susceptible to ruinous weapons', aliases={'warpbane','warp'}, _suscept = true },
	['havensilver'] = { image = 'Havensilver longsword.png', link = 'Havensilver weapons', category = 'Susceptible to havensilver', aliases={'haven'}, _suscept = true },
	
	-- styles
	['inquisitor staff'] = { image = 'Inquisitor staff.png', link='Inquisitor staff', category='Susceptible to inquisitor staff', _suscept=true, aliases={'inquisitor'} },
	['terrasaur maul'] = { image = 'Terrasaur maul.png', link='Terrasaur maul', category='Susceptible to terrasaur maul', _suscept=true, aliases={'terrasaur'} },
	['hexhunter bow'] = { image = 'Hexhunter bow.png', link='Hexhunter bow', category='Susceptible to hexhunter bow', _suscept=true, aliases={'hexhunter'} },
	['hexhunter bow dungeoneering'] = { image = 'Hexhunter bow (Dungeoneering).png', link='Hexhunter bow (Dungeoneering)', category='Susceptible to hexhunter bow', _suscept=true, aliases={'hexhunter dungeoneering','hexhunterdungeoneering'} },
	
	-- banes
	-- generic for legacy support
	['bane'] = { image = 'Tune Bane icon.png', link = 'Bane ammunition', category = 'Susceptible to bane ammunition', _suscept = true },
	
	['basilisk bane'] = { image = 'Basilisk head.png', link = 'Basiliskbane ammunition', category = 'Susceptible to basilisk bane', _suscept = true, aliases={'basilisk'} },
	
	['wallasalki bane'] = { image = 'Skull piece.png', link = 'Wallasalkibane ammunition', category = 'Susceptible to wallasalki bane', _suscept = true, aliases={'wallasalki'} },
	
	['abyssal bane'] = { image = 'Abyssal head.png', link = 'Abyssal bane equipment', category = 'Susceptible to abyssal bane', _suscept = true, aliases={'abyssal'} },
	-- perks
	['revenant bane'] = { image = "Corrupt Vesta's longsword.png", link = 'Revenant bane equipment', category = 'Susceptible to revenant bane', _suscept = true, aliases={'revenant'} },
	
	['demon slayer'] = { image = 'Demon Slayer (perk).png', link = 'Demon slayer (effect)', text = 'Demon slayer', category = 'Susceptible to demon slayer', _suscept = true, aliases={'demon','silverlight','darklight','holy water','holy','demon gear','demon_equipment'} },
	
	['undead slayer'] = { image = 'Undead Slayer.png', link = 'Undead slayer (effect)', text = 'Undead slayer', category = 'Susceptible to undead slayer', _suscept = true, aliases={'undead','salve'} },
	
	['dragon slayer'] = { image = 'Dragon Slayer (perk).png', link = 'Dragon slayer (effect)', text = 'Dragon slayer', category = 'Susceptible to dragon slayer', _suscept = true, aliases={'dragon','dragon bane','dbane'} },
	
	['nopenopenope'] = { image = 'NopeNopeNope perk (self status).png', link = 'NopeNopeNope perk', text = 'NopeNopeNope', category = 'Susceptible to NopeNopeNope', _suscept = true, aliases={'spider'} },
	
	['vampyre slayer'] = { image = 'Vampyre Slayer (ability).png', link = 'Vampyre Slayer (ability)', text = 'Vampyre slayer', category = 'Susceptible to vampyre slayer', _suscept = true, aliases={'vampyre','vampyric','vampyre slayer','vbane','vampyre bane'} },
	
	-- gear
	['ghost hunter'] = { image = 'Ghost hunter backpack.png', link = 'Ghost hunter equipment', category = 'Susceptible to ghost hunter', _suscept = true, aliases={'ghost'} },
	
	['salamancy'] = { image = 'Necklace of Salamancy.png', link = 'Necklace of Salamancy', category = 'Susceptible to necklace of Salamancy', _suscept = true },
	
	-- Misc weaknesses
	['nothing'] = { image = 'Zero weakness icon.png', link = 'No weakness', text = 'Nothing', category = 'Weak to nothing', aliases={'none'} }
}

local weaknesses = {}
for k,v in pairs(weaknesses_data) do
	if not v.name then
		v.name = k
	end
	weaknesses[k] = v
	if v.aliases then
		for _,n in ipairs(v.aliases) do
			weaknesses[n] = v
		end
	end
end

return weaknesses