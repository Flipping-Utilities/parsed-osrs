-- <pre>
-- blank template
--[[
	[''] = { often = '', sometimes = '', rarely = '', itemqty = 1, compqty = 8,
			alias = {}, cat = '', name = '' },
--]]
-- NOTES:
-- Do not include an item quantity of 1, this is done in the parent module (other default amounts are fine to include)

local data = {
	-- basic stuff
	['default'] = { often = 'simple', rarely = 'variable', compqty = 1,
			cat = 'default', name = 'Default' },

	['all clothing'] = { group = true, often = 'cover, simple, padded', rarely = 'variable', compqty = 1, x10 = true,
			cat = 'clothing', name = 'Clothing',
			members = {
				['clothing'] = { compqty = 1 },
				['hunter gear'] = { compqty = 1, special = 'offcut', alias = { 'hunter clothing' } }
			} 
	},

	-- invention
	['all gizmos'] = {
		group = true,
		sometimes = 'simple',
		rarely = 'base, blade, clear, connector, cover, crafted, deflecting, delicate, flexible, head, magic, metallic, organic, padded, plated, smooth, spiked, spiritual, stave, tensile, clockwork, refined, dextrous, direct, enhancing, ethereal, evasive, healthy, heavy, imbued, light, living, pious, powerful, precious, precise, protective, sharp, strong, stunning, subtle, swift, variable, ',
		compqty = 3,
		x10 = true,
		cat = 'gizmo',
		name = 'Gizmos and relics',
		nocalc = true,
		members = {
			['gizmo'] = { compqty = 3, alias = {'gizmos'} },
			['gizmo shell'] = { compqty = 1, alias = {'gizmo shells'} },
			['gizmo6'] = { compqty = 6, alias = {'common relics'} },
			['gizmo9'] = { compqty = 9 }, --dragonfire ash etc
			['gizmo12'] = { compqty = 12, alias = {'uncommon relics'} },
		}
	},

	-- runecrafting
	['runes and talismans'] = {
		group = true,
		often = 'magic', sometimes = 'crafted', rarely = 'powerful',
		cat = 'runes', name = 'Runes and talismans',
		members = {
			['talisman'] = { compqty = 1, alias = { 'talismans' } },
			['rune'] = { compqty = 8, itemqty = 50,  alias = { 'runes' } }
		}
	},

	['binding rods'] = {
		compqty = 5,
		often = 'magic',
		sometimes = 'crafted',
		rarely = 'powerful, manufactured',
		cat = 'binding rods',
		name = 'Binding rods'
	},

	-- materials
	['food'] = { often = 'organic', sometimes = 'crafted', rarely = 'living, healthy, enhancing', compqty = 1,
			alias = { 'herbs', 'herb' }, cat = 'food', name = 'Food and herbs' },

	['all gems'] = {
		group = true,
		often = 'clear, delicate, smooth', rarely = 'precious, light, faceted',
		cat = 'gems', name = 'Gems',
		members = {
			['uncut gem'] = { compqty = 1,  alias = { 'uncut gems' } },
			['gem'] = { compqty = 2,  alias = { 'gems' } },
			['big gem'] = { compqty = 6 }
		}
	},

	['all log'] = {
		group = true,
		often = 'simple',
		rarely = 'living',
		cat = 'logs',
		name = 'Logs and hides',
		members = {
			['log'] = { compqty = 1, alias = { 'logs', 'hide', 'hides' } },
			['wooden incense sticks'] = { compqty = 2 },
			['log 6'] = { compqty = 6 },
			['log 8'] = { compqty = 8, alias = {'fur artefact 8'} }
		}
	},
		
	['ashed incense sticks'] = {
		often = 'organic, simple',
		rarely = 'living, pious, ethereal',
		compqty = 6,
		cat = 'ashed incense sticks',
		name = 'Ashed incense sticks',
		alias = { 'ashy incense sticks, ' }
	},
		
	['herbed incense sticks'] = {
		often = 'organic, simple',
		rarely = 'pious, ethereal, living, crafted, healthy, enhancing',
		compqty = 7,
		cat = 'herbed incense sticks',
		name = 'Herbed incense sticks',
		alias = { 'incense sticks', 'incense' }
	},

	['seed'] = { often = 'organic', rarely = 'living', compqty = 1,
			alias = { 'seeds' }, cat = 'seeds', name = 'Seeds' },

	['all potions'] = {
		group = true,
		often = 'delicate, organic, crafted', rarely = 'enhancing, healthy',
		cat = 'potions', name = 'Potions and flasks',
		members = {
				['potion'] = { compqty = 1, potion = true, alias = { 'potions', 'flask', 'flasks' } },
				['1 dose'] = { compqty = 1 },
				['2 dose'] = { compqty = 2 },
				['3 dose'] = { compqty = 3 },
				['4 dose'] = { compqty = 4 },
				['5 dose'] = { compqty = 5 },
				['6 dose'] = { compqty = 6 },
				['potion 10'] = { compqty = 10 }
		}
	},

	['ore'] = { often = 'simple', compqty = 1,
			alias = { 'ores' }, cat = 'ores', name = 'Ores' },
	
	['harmonic dust'] = { often = 'crystal', compqty = 1, nocalc = true,
			itemqty = 100, cat = 'harmonic dust', name = 'Harmonic dust' },

	['pb and l'] = {
		group = true,
		often = 'simple, crafted',
		cat = 'planks', name = 'Planks, bars, and leather',
		members = {
			['bar'] = { compqty = 2, alias = { 'bars' } },
			['flatpack'] = { compqty = 2, special = 'offcut[1]', alias = { 'flatpacks' } },
			['flatpack 2'] = { compqty = 2, special = 'offcut[2]', alias = { 'flatpacks 2' } },
			['plank'] = { compqty = 1, alias = { 'planks', 'leather' } }
		}
	},

	['fur'] = { often = 'simple', rarely = 'variable', compqty = 1, special = 'offcut',
			alias = { 'furs' }, cat = 'furs', name = 'Furs' },

	['all glass'] = {
		group = true,
		often = 'clear, delicate, smooth', rarely = 'enhancing',
		cat = 'glass', name = 'Glass items',
		members = {
			['glass 1'] = { compqty = 1, alias = { 'glass' } },
			['glass 2'] = { compqty = 2 },
			['glass 18'] = { compqty = 18 }
		}
	},

	['all faceted glass'] = {
		group = true,
		often = 'clear, delicate, smooth', rarely = 'faceted, enhancing',
		cat = 'faceted glass', name = 'Faceted glass items',
		members = {
			['faceted glass 1'] = { compqty = 1, alias = { 'faceted glass' } },
			['faceted glass 2'] = { compqty = 2 }
		}
	},

	['clockwork'] = { often = 'simple', sometimes = 'crafted', rarely = 'clockwork', compqty = 1,
			cat = 'clockwork', name = 'Clockwork items' },

	-- summoning
	['pouch'] = { often = 'spiritual, crafted, flexible', rarely = 'powerful', compqty = 3,
			alias = { 'pouches' }, cat = 'pouches', name = 'Pouches' },

	['scroll'] = { often = 'spiritual, crafted', rarely = 'powerful', itemqty = 10,  compqty = 2,
			alias = { 'scrolls' }, cat = 'scrolls', name = 'Scrolls' },

	['charm'] = { often = 'spiritual', compqty = 1,
			alias = { 'charms' }, cat = 'charms', name = 'Charms', nocalc = true },

	['divination'] = { often = 'magic', sometimes = 'crafted', rarely = 'ethereal', compqty = 3,
			alias = { 'divine location', 'portent', 'portents', 'sign', 'signs' }, cat = 'divination', name = 'Signs, portents, and divine locations' },

	-- prayer
	['bones and remains'] = {
		group = true,
		often = 'organic', rarely = 'pious',
		cat = 'bones', name = 'Bones and remains',
		members = {
			['remain'] = { compqty = 1,  alias = { 'remains' } },
			['bone'] = { compqty = 2,  alias = { 'bones' } },
			['bone 8'] = { compqty = 8, alias={ 'ceremonial artefact 8' } },
			['bone 10'] = { compqty = 10, alias={ 'ceremonial artefact 10' } }
		}
	},

	['ashes'] = { often = 'organic', rarely = 'pious, ethereal', compqty = 2,
			cat = 'ashes', name = 'Ashes' },

	-- misc
	['all crystal tool'] = {
		group = true,
		often = 'crystal, faceted', sometimes = 'clear, delicate, smooth',
		cat = 'crystal tool', name = 'Crystal tools and teleport seeds',
		nocalc = true,
		members = {
			['crystal tool'] = { compqty = 3, alias = { 'crystal tools' } },
			['crystal tool 1'] = { compqty = 1 },
				
		}
	},

	['crystal fruit'] = { often = 'simple, organic', sometimes = 'crystal', rarely = 'healthy', compqty = 5,
			cat = 'crystal fruit', name = 'Crystal tree blossoms', nocalc = true },

	-- salvage
	['bladed salvage'] = {
		group = true,
		cat = 'bladed salvage',
		name = 'Bladed salvage',
		often = 'base, blade, metallic', rarely = 'sharp, subtle, dextrous',
		members = {
			['tiny bladed salvage'] = {compqty=3},
			['small bladed salvage'] = {compqty=6},
			['medium bladed salvage'] = {compqty=9},
			['large bladed salvage'] = {compqty=12},
			['huge bladed salvage'] = {compqty=15},
		}
	},
	['blunt salvage'] = {
		group = true,
		cat = 'blunt salvage',
		name = 'Blunt salvage',
		often = 'stave, head, smooth', rarely = 'stunning, direct, strong',
		members = {
			['tiny blunt salvage'] = {compqty=3},
			['small blunt salvage'] = {compqty=6},
			['medium blunt salvage'] = {compqty=9},
			['large blunt salvage'] = {compqty=12},
			['huge blunt salvage'] = {compqty=15},
		}
	},
	['plated salvage'] = {
		group = true,
		cat = 'plated salvage',
		name = 'Plated salvage',
		often = 'cover, plated, deflecting', rarely = 'protective, heavy, strong',
		members = {
			['tiny plated salvage'] = {compqty=3},
			['small plated salvage'] = {compqty=6},
			['medium plated salvage'] = {compqty=9},
			['large plated salvage'] = {compqty=12},
			['huge plated salvage'] = {compqty=15},
		}
	},
	['spiky salvage'] = {
		group = true,
		cat = 'spiky salvage',
		name = 'Spiky salvage',
		often = 'connector, spiked, crafted', rarely = 'swift, precise, light',
		members = {
			['tiny spiky salvage'] = {compqty=3},
			['small spiky salvage'] = {compqty=6},
			['medium spiky salvage'] = {compqty=9},
			['large spiky salvage'] = {compqty=12},
			['huge spiky salvage'] = {compqty=15},
		}
	},

	-- =================
	-- EQUIPMENT
	-- =================
	['all jewellery'] = {
		group = true,
		often = 'delicate, connector, smooth', rarely = 'precious, enhancing', x10 = true,
		cat = 'jewellery', name = 'Jewellery',
		members = {
			['jewellery'] = { compqty = 5, alias = { 'jewelry' } },
			['unstrung jewellery'] = { compqty = 2, alias = { 'jewellery (u)' } },
			['jewellery 6'] = { compqty = 6 },
			['jewellery 8'] = { compqty = 8 },
			['jewellery 10'] = { compqty = 10 },
			['jewellery 14'] = { compqty = 14 },
			['jewellery 18'] = { compqty = 18 },
			['jewellery 24'] = { compqty = 24 },
		}
	},

	['all shields'] = {
		group = true,
		often = 'cover, base, deflecting', rarely = 'strong, protective', x10 = true,
		cat = 'shields', name = 'Shields',
		members = { 
			['shield'] = { compqty = 8, alias = { 'shield 8', 'melee shield', 'magic shield', 'ranged shield', 'hybrid shield', 'melee shield base' } },
			['melee shield + 1'] = { compqty = 16 },
			['melee shield + 2'] = { compqty = 32 },
			['melee shield + 3'] = { compqty = 64 },
			['melee shield + 4'] = { compqty = 128 },
			['shield 6'] = { compqty = 6 },
			['shield 10'] = { compqty = 10 },
			['shield 14'] = { compqty = 14 },
			['shield 18'] = { compqty = 18 },
			['shield 24'] = { compqty = 24 }
		}
	},

	['elder rune shields'] = {
		group = true,
		often = 'cover, base, deflecting', rarely = 'strong, protective', x10 = true,
		cat = 'elder rune shields', name = 'Elder rune shields',
		members = { 
			['er melee shield base'] = { compqty = 8 },
			['er melee shield + 1'] = { compqty = 16 },
			['er melee shield + 2'] = { compqty = 32 },
			['er melee shield + 3'] = { compqty = 64 },
			['er melee shield + 4'] = { compqty = 128 },
			['er melee shield + 5'] = { compqty = 256 }
		}
	},

	-- melee items
	['melee armour'] = {
		group = true,
		often = 'cover, plated, deflecting', rarely = 'strong, protective', x10 = true,
		cat = 'melee armour', name = 'Melee armour',
		members = {
			['melee 18'] = { compqty = 18 },
			['melee 8'] = { compqty = 8, alias = { 'melee body', 'melee legs', 'melee helm base', 'melee gloves + 1', 'melee boots + 1' } },
			['melee 6'] = { compqty = 6, alias = { 'melee cape', 'melee helm' } },
			['melee 4'] = { compqty = 4, alias = { 'melee boots', 'melee gloves', 'melee boots base', 'melee gloves base' } },
			['melee 2'] = { compqty = 2, alias = { 'melee crest' } },
			['melee 1'] = { compqty = 1, alias = { 'melee essence' } },
			['melee 12'] = { compqty = 12, alias = { 'melee legs base' } },
			['melee 16'] = { compqty = 16, alias = { 'melee gloves + 2', 'melee boots + 2', 'melee helm + 1' } },
			['melee 20'] = { compqty = 20, alias = { 'melee body base' } },
			['melee 24'] = { compqty = 24, alias = { 'melee legs + 1' } },
			['melee 32'] = { compqty = 32, alias = { 'melee gloves + 3', 'melee boots + 3', 'melee helm + 2' } },
			['melee 40'] = { compqty = 40, alias = { 'melee body + 1' } },
			['melee 48'] = { compqty = 48, alias = { 'melee legs + 2' } },
			['melee 64'] = { compqty = 64, alias = { 'melee gloves + 4', 'melee boots + 4', 'melee helm + 3' } },
			['melee 80'] = { compqty = 80, alias = { 'melee body + 2' } },
			['melee 96'] = { compqty = 96, alias = { 'melee legs + 3' } },
			['melee 128'] = { compqty = 128, alias = { 'melee helm + 4' } },
			['melee 160'] = { compqty = 160, alias = { 'melee body + 3' } },
			['melee 192'] = { compqty = 192, alias = { 'melee legs + 4' } },
			['melee 320'] = { compqty = 320, alias = { 'melee body + 4' } }
		}
	},

	['elder rune melee armour'] = {
		group = true,
		often = 'cover, plated, deflecting', rarely = 'strong, protective', x10 = true,
		cat = 'elder rune melee armour', name = 'Elder rune melee armour',
		members = {
			['er melee 8'] = { compqty = 8, alias = { 'er melee gloves + 1', 'er melee boots + 1', 'er melee helm base' } },
			['er melee 4'] = { compqty = 4, alias = { 'er melee boots base', 'er melee gloves base' } },
			['er melee 12'] = { compqty = 12, alias = { 'er melee legs base' } },
			['er melee 16'] = { compqty = 16, alias = { 'er melee gloves + 2', 'er melee boots + 2', 'er melee helm + 1' } },
			['er melee 20'] = { compqty = 20, alias = { 'er melee body base' } },
			['er melee 24'] = { compqty = 24, alias = { 'er melee legs + 1' } },
			['er melee 32'] = { compqty = 32, alias = { 'er melee gloves + 3', 'er melee boots + 3', 'er melee helm + 2' } },
			['er melee 40'] = { compqty = 40, alias = { 'er melee body + 1' } },
			['er melee 48'] = { compqty = 48, alias = { 'er melee legs + 2' } },
			['er melee 64'] = { compqty = 64, alias = { 'er melee gloves + 4', 'er melee boots + 4', 'er melee helm + 3' } },
			['er melee 80'] = { compqty = 80, alias = { 'er melee body + 2' } },
			['er melee 96'] = { compqty = 96, alias = { 'er melee legs + 3' } },
			['er melee 128'] = { compqty = 128, alias = { 'er melee gloves + 5', 'er melee boots + 5', 'er melee helm + 4' } },
			['er melee 160'] = { compqty = 160, alias = { 'er melee body + 3' } },
			['er melee 192'] = { compqty = 192, alias = { 'er melee legs + 4' } },
			['er melee 256'] = { compqty = 256, alias = { 'er melee helm + 5' } },
			['er melee 320'] = { compqty = 320, alias = { 'er melee body + 4' } },
			['er melee 384'] = { compqty = 384, alias = { 'er melee legs + 5' } },
			['er melee 640'] = { compqty = 640, alias = { 'er melee body + 5' } }
		}
	},

	['all dagger'] = {
		group = true,
		often = 'base, blade, spiked', rarely = 'precise, light', x10 = true,
		cat = 'dagger', name = 'Daggers',
		members = {
			['dagger'] = { compqty = 8, alias = { 'dagger base' } },
			['dagger + 1'] = { compqty = 16 },
			['dagger + 2'] = { compqty = 32 },
			['dagger + 3'] = { compqty = 64 },
			['dagger 6'] = { compqty = 6 },
			['dagger 14'] = { compqty = 14 },
			['dagger 18'] = { compqty = 18 }
		}
	},

	['all hatchet'] = {
		group = true,
		often = 'head, blade, connector', rarely = 'sharp, strong', x10 = true,
		cat = 'hatchet',
		name = 'Hatchets',
		members = {
			['hatchet'] = { compqty = 8 },
			['smithed hatchet'] = { compqty = 4 }
		}
	},

	['all maces'] = {
		group = true,
		often = 'base, head, smooth', rarely = 'heavy, dextrous', x10 = true,
		cat = 'mace', name = 'Maces',
		members = {
			['mace'] = { compqty = 8, alias = { 'mace base' } },
			['mace 10'] = { compqty = 10 },
			['mace 24'] = { compqty = 24 },
			['2h mace'] = { compqty = 12 },
			['mace + 1'] = { compqty = 16 },
			['mace + 2'] = { compqty = 32 },
			['mace + 3'] = { compqty = 64 }
		}
	},

	['all sword'] = {
		group = true,
		often = 'base, blade, metallic', rarely = 'precise, dextrous', x10 = true,
		cat = 'sword', name = 'Swords',
		members = {
			['sword'] = { compqty = 8, alias = { 'sword base' } },
			['sword + 1'] = { compqty = 16 },
			['sword + 2'] = { compqty = 32 },
			['sword + 3'] = { compqty = 64 },
			['sword 6'] = { compqty = 6 },
			['sword 10'] = { compqty = 10 },
			['sword 18'] = { compqty = 18 },
			['sword 24'] = { compqty = 24 }
		}
	},

	['all scimitar'] = {
		group = true,
		often = 'base, blade, metallic', rarely = 'sharp, subtle', x10 = true,
		cat = 'scimitar', name = 'Scimitars',
		members = {
			['scimitar'] = { compqty = 8, alias = { 'scimitar base' } },
			['scimitar + 1'] = { compqty = 16 },
			['scimitar + 2'] = { compqty = 32 },
			['scimitar + 3'] = { compqty = 64 }
		}
	},

	['all pickaxe'] = {
		group = true,
		often = 'base, head, spiked', rarely = 'heavy, direct', x10 = true,
		cat = 'pickaxe', name = 'Pickaxes and mattocks',
		members = {
			['pickaxe'] = { compqty = 8, alias = { 'pickaxe base', 'mattock' } },
			['pickaxe + 1'] = { compqty = 16 },
			['pickaxe + 2'] = { compqty = 32 },
			['pickaxe + 3'] = { compqty = 64 },
			['pickaxe + 4'] = { compqty = 128 },
			['pickaxe + 5'] = { compqty = 256 },
			['pickaxe 24'] = { compqty = 24 }
		}
	},

	['elder rune pickaxe'] = {
		group = true,
		often = 'base, head, spiked', rarely = 'heavy, direct', x10 = true,
		cat = 'elder rune pickaxe', name = 'Elder rune pickaxes',
		members = {
			['er pickaxe'] = { compqty = 8, alias = { 'er pickaxe base' } },
			['er pickaxe + 1'] = { compqty = 16 },
			['er pickaxe + 2'] = { compqty = 32 },
			['er pickaxe + 3'] = { compqty = 64 },
			['er pickaxe + 4'] = { compqty = 128 },
			['er pickaxe + 5'] = { compqty = 256 }
		}
	},

	['all maul'] = {
		group = true,
		often = 'base, head, plated', rarely = 'heavy, strong', x10 = true,
		cat = 'maul', name = 'Mauls',
		members = {
			['maul'] = { compqty = 12 },
			['maul 14'] = { compqty = 14 },
			['maul base'] = { compqty = 16 },
			['maul + 1'] = { compqty = 32 },
			['maul + 2'] = { compqty = 64 },
			['maul + 3'] = { compqty = 128 },
			['maul + 4'] = { compqty = 256 }
		}
	},

	['all longswords'] = {
		group = true,
		often = 'base, blade, metallic', rarely = 'sharp, dextrous', x10 = true,
		cat = 'longsword', name = 'Longswords',
		members = {
			['longsword'] = { compqty = 8, alias = { 'longsword base' } },
			['2h longsword'] = { compqty = 12, alias = { 'trouble brewing flags' } },
			['longsword + 1'] = { compqty = 16 },
			['longsword + 2'] = { compqty = 32 },
			['longsword + 3'] = { compqty = 64 },
			['longsword + 4'] = { compqty = 128 },
			['longsword 14'] = { compqty = 14 },
			['longsword 24'] = { compqty = 24 }
		}
	},

	['er longswords'] = {
		group = true,
		often = 'base, blade, metallic', rarely = 'sharp, dextrous', x10 = true,
		cat = 'elder rune longsword', name = 'Elder rune longswords',
		members = {
			['er longsword base'] = { compqty = 8 },
			['er longsword + 1'] = { compqty = 16 },
			['er longsword + 2'] = { compqty = 32 },
			['er longsword + 3'] = { compqty = 64 },
			['er longsword + 4'] = { compqty = 128 },
			['er longsword + 5'] = { compqty = 256 }
		}
	},

	['all warhammer'] = {
		group = true,
		often = 'base, head, smooth', rarely = 'heavy, strong', x10 = true,
		cat = 'warhammer', name = 'Warhammers',
		members = {
			['warhammer'] = { compqty = 8, alias = { 'warhammer base' } },
			['warhammer + 1'] = { compqty = 16 },
			['warhammer + 2'] = { compqty = 32 },
			['warhammer + 3'] = { compqty = 64 },
			['warhammer + 4'] = { compqty = 128 },
			['warhammer + 5'] = { compqty = 256 },
		}
	},

	['all battleaxe'] = {
		group = true,
		often = 'head, blade, smooth', rarely = 'sharp, direct', x10 = true,
		cat = 'battleaxe', name = 'Battleaxes',
		members = {
			['battleaxe'] = { compqty = 8, alias = { 'battleaxe base' } },
			['battleaxe + 1'] = { compqty = 16 },
			['battleaxe + 2'] = { compqty = 32 },
			['battleaxe + 3'] = { compqty = 64 },
			['battleaxe + 4'] = { compqty = 128 },
			['battleaxe 10'] = { compqty = 10 },
			['battleaxe 18'] = { compqty = 18 }
		}
	},

	['all claws'] = {
		group = true,
		often = 'connector, blade, spiked', rarely = 'sharp, swift', x10 = true,
		cat = 'claw', name = 'Claws',
		members = {
			['claw'] = { compqty = 8, alias = { 'claws', 'claw base' } },
			['2h claw'] = { compqty = 12, alias = { '2h claws' } },
			['claw + 1'] = { compqty = 16, alias = { 'claws + 1' } },
			['claw + 2'] = { compqty = 32, alias = { 'claws + 2' } },
			['claw + 3'] = { compqty = 64, alias = { 'claws + 3' } }
		}
	},

	['all 2h swords'] = {
		group = true,
		often = 'base, blade, metallic', rarely = 'sharp, strong', x10 = true,
		cat = '2h sword', name = 'Two-handed swords',
		members = {
			['2h sword'] = { compqty = 12 },
			['2h sword blade'] = { compqty = 6 },
			['2h sword blade part'] = { compqty = 4, alias = { 'godsword shards', '2h sword blade parts' } },
			['2h sword shard'] = { compqty = 2, alias = { 'godsword shard', '2h sword shards' } },
			['2h sword base'] = { compqty = 16 },
			['2h sword + 1'] = { compqty = 32 },
			['2h sword + 2'] = { compqty = 64 },
			['2h sword + 3'] = { compqty = 128 },
			['2h sword + 4'] = { compqty = 256 },
			['2h sword 24'] = { compqty = 24 }
		}
	},

	['elder rune 2h swords'] = {
		group = true,
		often = 'base, blade, metallic', rarely = 'sharp, strong', x10 = true,
		cat = 'elder rune 2h sword', name = 'Elder rune two-handed swords',
		members = {
			['er 2h sword base'] = { compqty = 16 },
			['er 2h sword + 1'] = { compqty = 32 },
			['er 2h sword + 2'] = { compqty = 64 },
			['er 2h sword + 3'] = { compqty = 128 },
			['er 2h sword + 4'] = { compqty = 256 },
			['er 2h sword + 5'] = { compqty = 512 }
		}
	},

	['spears and hastae'] = {
		group = true,
		often = 'stave, blade, crafted', rarely = 'precise, direct', x10 = true,
		cat = 'spear', name = 'Spears and hastae',
		members = {
			['spear 24'] = { compqty = 24 },
			['spear 18'] = { compqty = 18 },
			['spear'] = { compqty = 12 },
			['hasta'] = { compqty = 8 }
		}
	},

	['all halberds'] = {
		group = true,
		often = 'stave, blade, deflecting', rarely = 'sharp, stunning', x10 = true,
		cat = 'halberd', name = 'Halberds',
		members = {
			['halberd 24'] = { compqty = 24 },
			['halberd 18'] = { compqty = 18 },
			['halberd 10'] = { compqty = 10 },
			['halberd'] = { compqty = 12 },
			['1h halberd'] = { compqty = 8, alias = { 'mjolnir' } }
		}
	},

	['defender'] = { often = 'base, deflecting', sometimes = 'precise, subtle', compqty = 8, x10 = true,
			cat = 'defender', name = 'Defenders, reprisers, and rebounders', nocalc = true },


	['defender piece'] = { often = 'connector, deflecting', sometimes = 'variable, enhancing', compqty = 4, x10 = true,
			cat = 'defender piece', name = 'Defender pieces', nocalc = true },

	['all whip'] = {
		group = true,
		often = 'connector, blade, flexible',
		rarely = 'sharp, subtle',
		x10 = true,
		cat = 'whip', name = 'Whips',
		members = {
			['whip'] = { compqty = 8, alias =  { 'whips' } },
			['whip 14'] = { compqty = 14 },
			['whip 24'] = { compqty = 24 }
			}
		},

	-- magic items
	['magic armour'] = {
		group = true,
		often = 'cover, magic, deflecting', rarely = 'powerful, protective', x10 = true,
		cat = 'magic armour', name = 'Magic armour',
		members = {
			['magic 24'] = { compqty = 24 },
			['magic 10'] = { compqty = 10 },
			['magic 8'] = { compqty = 8, alias = { 'magic body', 'magic legs' } },
			['magic 6'] = { compqty = 6, alias = { 'magic cape', 'magic helm' } },
			['magic 4'] = { compqty = 4, alias = { 'magic boots', 'magic gloves' } },
			['magic 2'] = { compqty = 2, alias = { 'magic crest' } },
			['magic 1'] = { compqty = 1, alias = { 'magic essence' } },
			['tiara 2'] = { compqty = 6, special = 'manufactured[2]', alias = { 'tiaras 2' } },
			['tiara 1'] = { compqty = 6, special = 'manufactured[1]', alias = { 'tiaras' } }
		}
	},

	['all staff'] = {
		group = true,
		often = 'stave, magic, padded', rarely = 'powerful, imbued',
		cat = 'staff', name = 'Staves',
		members = {
			['staff'] = { compqty = 12, x10 = true, alias = { 'staves' } },
			['staff 4'] = {compqty = 4, x10 = true},
			['staff 8'] = {compqty = 8, x10 = true },
			['staff 10'] = { compqty = 10, x10 = true },
			['staff 14'] = { compqty = 14, x10 = true },
			['staff 16'] = { compqty = 16, x10 = true },
			['staff 24'] = { compqty = 24, x10 = true },
			['staff 32'] = { compqty = 32, x10 = true },
			['staff 64'] = { compqty = 64, x10 = true },
			['staff 128'] = { compqty = 128, x10 = true },
			['staff 256'] = { compqty = 256, x10 = true },
		}
	},

	['all wands'] = {
		group = true,
		often = 'base, head, magic', rarely = 'precise, imbued',
		x10 = true,
		cat = 'wand', name = 'Wands',
		members = {
			['wand'] = { compqty = 8, alias = { 'wands', 'wand 8' } },
			['wand 4'] = { compqty = 4 },
			['wand 16'] = { compqty = 16 },
			['wand 32'] = { compqty = 32 },
			['wand 64'] = { compqty = 64 },
			['wand 128'] = { compqty = 128 },
			['wand 256'] = { compqty = 256 },
		},
	},

	['all orb'] = {
		group = true,
		often = 'delicate, magic, smooth', rarely = 'enhancing, ethereal, faceted',
		x10 = true,
		cat = 'orb', name = 'Magic off-hand weapons',
		members = {
			['orb'] = { compqty = 8, alias = { 'orbs', 'book', 'books' } },
			['orb 10'] = { compqty = 10 }
		}
	},

	['all eternal orbs'] = {
		group = true,
		often = 'delicate, magic, smooth', rarely = 'enhancing, faceted',
		x10 = true,
		cat = 'eternal orbs', name = 'Eternal magic off-hand weapons',
		members = {
			['eternal orb 4'] = { compqty = 4, alias = { 'eternal orb' } },
			['eternal orb 8'] = { compqty = 8 },
			['eternal orb 16'] = { compqty = 16 },
			['eternal orb 32'] = { compqty = 32 },
			['eternal orb 64'] = { compqty = 64 },
			['eternal orb 128'] = { compqty = 128 },
			['eternal orb 256'] = { compqty = 256 },
		}
	},

	-- ranged items
	['ranged armour'] = {
		group = true,
		often = 'cover, tensile, padded', rarely = 'evasive, protective', x10 = true,
		cat = 'ranged armour', name = 'Ranged armour',
		members = {
			['ranged 14'] = { compqty = 14 },
			['ranged 10'] = { compqty = 10 },
			['ranged 8'] = { compqty = 8, alias = { 'ranged body', 'ranged legs' } },
			['ranged 6'] = { compqty = 6, alias = { 'ranged cape', 'ranged helm' } },
			['ranged 4'] = { compqty = 4, alias = { 'ranged boots', 'ranged gloves' } },
			['ranged 2'] = { compqty = 2, alias = { 'ranged crest' } },
			['ranged 1'] = { compqty = 1, alias = { 'ranged essence' } }
		}
	},

	['all shortbows'] = {
		group = true,
		often = 'stave, tensile, flexible', rarely = 'precise, dextrous', x10 = true,
		cat = 'shortbows', name = 'Shortbows',
		members = {
			['shortbow'] = { compqty = 12, alias = { 'shortbows' } },
			['unstrung shortbow'] = { compqty = 4,  alias = { 'unstrung shortbows' } }
		}
	},

	['all eternal shortbows'] = {
		group = true,
		often = 'stave, tensile, flexible', sometimes = 'precise, dextrous', x10 = true,
		cat = 'eternal shortbows', name = 'Eternal shortbows',
		members = {
			['eternal shortbow'] = { compqty = 16, alias = { 'eternal shortbows' } },
			['eternal shortbow mk. 1'] = { compqty = 32, alias = { 'eternal shortbow + 1' } },
			['eternal shortbow mk. 2'] = { compqty = 64, alias = { 'eternal shortbow + 2' } },
			['eternal shortbow mk. 3'] = { compqty = 128, alias = { 'eternal shortbow + 3' } },
			['eternal shortbow mk. 4'] = { compqty = 256, alias = { 'eternal shortbow + 4' } },
			['eternal shortbow mk. 5'] = { compqty = 512, alias = { 'eternal shortbow + 5' } },
		}
	},

	['all shieldbows'] = {
		group = true,
		often = 'stave, tensile, flexible', rarely = 'precise, strong', x10 = true,
		cat = 'shieldbows', name = 'Longbows and shieldbows',
		members = {
		-- 	['shieldbow 6'] = { compqty = 6, alias = { 'longbow 6' } }, --actually a bug
			['shieldbow'] = { compqty = 12, alias = { 'shieldbows', 'longbow', 'longbows' } },
			['shieldbow 24'] = { compqty = 24 },
			['unstrung shieldbow'] = { compqty = 4,  alias = { 'unstrung shieldbows', 'unstrung longbows', 'unstrung longbow' } }
		}
	},

	['all eternal longbows'] = {
		group = true,
		often = 'stave, tensile, flexible', sometimes = 'precise, strong', x10 = true,
		cat = 'eternal longbows', name = 'Eternal longbows',
		members = {
			['eternal longbow'] = { compqty = 16, alias = { 'eternal longbows', 'longbow 16' } },
		}
	},

	['arrows and arrowheads'] = {
		group = true,
		often = 'stave, head, crafted', rarely = 'precise',
		cat = 'arrows', name = 'Arrows and arrowheads',
		members = {
			['arrow'] = { itemqty = 50, compqty = 6,  alias = { 'arrows' } },
			['arrowhead'] = { itemqty = 50, compqty = 2,  alias = { 'arrowheads' } }
		}
	},

	['bolts and bolt tips'] = {
		group = true,
		often = 'base, head, spiked', rarely = 'stunning',
		cat = 'bolts', name = 'Bolts and bolt tips',
		members = {
			['bolt'] = { itemqty = 50, compqty = 6, alias = { 'bolts' } },
			['bolt tip'] = { itemqty = 50, compqty = 2, alias = { 'bolt tips' } },
			['bolt part'] = { itemqty = 1, compqty = 2 }
		}
	},

	['crossbows and stocks'] = {
		group = true,
		often = 'connector, tensile, spiked', rarely = 'stunning, dextrous', x10 = true,
		cat = 'crossbows', name = 'Crossbows and stocks',
		members = {
			['crossbow'] = { compqty = 8, alias = { 'crossbows' } },
			['unstrung crossbow'] = { compqty = 4, alias = { 'unstrung crossbows' } },
			['stock'] = { compqty = 2, alias = { 'stock', 'limbs' } }
		}
	},

	['all primal crossbows'] = {
		group = true,
		often = 'connector, tensile, spiked', sometimes = 'stunning, dextrous', x10 = true,
		cat = 'primal crossbows', name = 'Primal crossbows',
		members = {
			['primal crossbow'] = { compqty = 8, alias = { 'primal crossbows' } },
			['primal crossbow mk. 1'] = { compqty = 16, alias = { 'primal crossbow + 1' } },
			['primal crossbow mk. 2'] = { compqty = 32, alias = { 'primal crossbow + 2' } },
			['primal crossbow mk. 3'] = { compqty = 64, alias = { 'primal crossbow + 3' } },
			['primal crossbow mk. 4'] = { compqty = 128, alias = { 'primal crossbow + 4' } },
			['primal crossbow mk. 5'] = { compqty = 256, alias = { 'primal crossbow + 5' } },
		}
	},

	['primal 2h crossbow'] = {
		group = true,
		often = 'connector, tensile, crafted', sometimes = 'stunning, dextrous',
		x10 = true, cat = 'primal 2h crossbows', name = 'Primal two-handed crossbows',
		members = {
			['primal 2h crossbow'] = { compqty = 16, alias = { 'primal 2h crossbows', '2h crossbow 16' } },
		}
	},

	['2h crossbow'] = {
		group = true,
		often = 'connector, tensile, crafted', rarely = 'stunning, dextrous',
		x10 = true, cat = '2h crossbows', name = 'Two-handed crossbows',
		members = {
			['2h crossbow'] = { compqty = 12, alias = { '2h crossbows' }  },
			['2h crossbow 6'] = { compqty = 6 },
		}
	},

	['all darts'] = {
		group = true,
		often = 'simple, blade, spiked', rarely = 'sharp, swift',
		cat = 'darts', name = 'Darts',
		members = {
			['dart'] = { itemqty = 50, compqty = 8, alias = { 'darts', 'javelin', 'javelins' } },
			['big javelin'] = { compqty = 12, x10 = true }
		}
	},

	['throwing knives'] = {
		group = true,
		often = 'simple, blade, metallic', rarely = 'sharp, swift',
		cat = 'knives', name = 'Throwing knives',
		members = {
			['knife'] = { itemqty = 50, compqty = 8, alias = { 'knives' } }
		}
	},

	['all throw axes'] = {
		group = true,
		often = 'simple, blade, plated', rarely = 'sharp, swift',
		cat = 'throwing axes', name = 'Throwing axes',
		members = {
			['throwing axe'] = { itemqty = 50, compqty = 8, alias = { 'throwing axes' } },
			['chakram'] = { compqty = 8, x10 = true },
			['glaive'] = { compqty = 8, x10 = true, alias = { 'glaives' } },
			['throwing axe 10'] = { compqty = 10, x10 = true }
		}
	},

	['cannonball'] = { often = 'simple, head', rarely = 'stunning, direct', itemqty = 50, compqty = 8,
			alias = { 'cannonballs', 'bolas' }, cat = 'cannonballs', name = 'Cannonballs' },

	-- hybrid items
	['hybrid armour'] = {
		group = true,
		often = 'cover, deflecting', rarely = 'powerful, evasive, protective', x10 = true,
		cat = 'hybrid armour', name = 'Hybrid armour',
		members = {
			['hybrid 8'] = { compqty = 8, alias = { 'hybrid body', 'hybrid legs' } },
			['hybrid 6'] = { compqty = 6, alias = { 'hybrid cape', 'hybrid helm' } },
			['hybrid 4'] = { compqty = 4, alias = { 'hybrid boots', 'hybrid gloves' } },
			['hybrid 2'] = { compqty = 2, alias = { 'hybrid crest' } },
			['hybrid 1'] = { compqty = 1, alias = { 'hybrid essence' } }
		}
	},

	-- necromancy items
	['necromancy armour'] = {
		group = true,
		often = 'cover, spiritual, magic',
		rarely = 'ethereal, protective',
		x10 = true,
		cat = 'necromancy armour',
		name = 'Necromancy armour',
		members = {
			['necromancy 8'] = { compqty = 8, alias = { 'necromancy body', 'necromancy legs' } },
			['necromancy 6'] = { compqty = 6, alias = { 'necromancy cape', 'necromancy helm' } },
			['necromancy 4'] = { compqty = 4, alias = { 'necromancy boots', 'necromancy gloves' } }
		}
	},

	['all siphons'] = {
		group = true,
		often = 'base, deflecting, smooth', rarely = 'imbued, precious',
		x10 = true,
		cat = 'siphons', name = 'Siphons',
		members = {
			['siphons 8'] = { compqty = 8, alias = { 'siphons' } }
		}
	},

	['all conduits'] = {
		group = true,
		often = 'base, spiritual, delicate', rarely = 'direct, ethereal, powerful',
		x10 = true,
		cat = 'conduits', name = 'Conduits',
		members = {
			['conduits 8'] = { compqty = 8, alias = {'conduits'} }
		}
	},

	['ghostly ink'] = {
		often = 'organic',
		rarely = 'pious, ethereal',
		compqty = 1,
		cat = 'ghostly ink',
		name = 'Ghostly ink'
	},

	['all necroplasm'] = {
		group = true,
		often = 'simple',
		rarely = 'variable',
		cat = 'necroplasm', name = 'Necroplasm',
		members = {
			['necroplasm'] = { compqty = 1, itemqty = 20, special = 'manufactured' },
			['necroplasm 1'] = { compqty = 1, itemqty = 20, special = 'manufactured[1]' },
			['necroplasm 2'] = { compqty = 1, itemqty = 20, special = 'manufactured[2]{1/10}' }
		}
	},

	--[=[ 
	--		individial things
	--]=]
	['spider leg'] = {
		often = 'stave, simple',
		rarely = 'variable',
		compqty = 4,
		cat = 'spider legs', name = 'Spider legs',
		nocalc = true,
	},
	['spider eye'] = {
		often = 'magic',
		compqty = 4,
		x10 = true,
		cat = 'spider eye', name = 'Araxxi\'s eye',
		nocalc = true,
	},
	['spider web'] = {
		often = 'tensile',
		compqty = 4,
		x10 = true,
		cat = 'spider web', name = 'Araxxi\'s web',
		nocalc = true,
	},
	['spider fang'] = {
		often = 'blade',
		compqty = 4,
		x10 = true,
		cat = 'spider fang', name = 'Araxxi\'s fang',
		nocalc = true,
	},

	--[=[
	-- artefacts
	--]=]
	['magical artefacts'] = {
		group = true,
		often = 'magic, base, tensile',
		rarely = 'enhancing, swift',
		x10 = true,
		cat = 'magical artefacts', name = 'Magical artefacts',
		members = {
			['magical artefact 6'] = { compqty = 6 },
			['magical artefact 8'] = { compqty = 8 },
			['magical artefact 10'] = { compqty = 10 },
			['magical artefact 12'] = { compqty = 12 },
			['magical artefact 14'] = { compqty = 14 },
			['magical artefact 16'] = { compqty = 16 },
			['magical artefact 18'] = { compqty = 18 },
			['magical artefact 24'] = { compqty = 24 }
		}
	},
	['metallic artefacts'] = {
		group = true,
		often = 'metallic, base, plated',
		rarely = 'powerful, protective',
		x10 = true,
		cat = 'metallic artefacts', name = 'Metallic artefacts',
		members = {
			['metallic artefact 6'] = { compqty = 6 },
			['metallic artefact 8'] = { compqty = 8 },
			['metallic artefact 10'] = { compqty = 10 },
			['metallic artefact 12'] = { compqty = 12 },
			['metallic artefact 14'] = { compqty = 14 },
			['metallic artefact 16'] = { compqty = 16 },
			['metallic artefact 18'] = { compqty = 18 },
			['metallic artefact 24'] = { compqty = 24 }
		}
	},
	['decoration artefacts'] = {
		group = true,
		often = 'simple, crafted, organic',
		rarely = 'enhancing, living',
		x10 = true,
		cat = 'decoration artefacts', name = 'Decoration artefacts',
		members = {
			['decoration artefact 6'] = { compqty = 6 },
			['decoration artefact 8'] = { compqty = 8 },
			['decoration artefact 10'] = { compqty = 10 },
			['decoration artefact 12'] = { compqty = 12 },
			['decoration artefact 14'] = { compqty = 14 },
			['decoration artefact 16'] = { compqty = 16 },
			['decoration artefact 18'] = { compqty = 18 },
			['decoration artefact 24'] = { compqty = 24 }
		}
	},
	['ornament artefacts'] = {
		group = true,
		often = 'smooth, base, delicate',
		rarely = 'heavy, stunning',
		x10 = true,
		cat = 'ornament artefacts', name = 'Ornament artefacts',
		members = {
			['ornament artefact 6'] = { compqty = 6 },
			['ornament artefact 8'] = { compqty = 8 },
			['ornament artefact 10'] = { compqty = 10 },
			['ornament artefact 12'] = { compqty = 12 },
			['ornament artefact 14'] = { compqty = 14 },
			['ornament artefact 16'] = { compqty = 16 },
			['ornament artefact 18'] = { compqty = 18 },
			['ornament artefact 24'] = { compqty = 24 }
		}
	},
	['painting artefacts'] = {
		group = true,
		often = 'base, cover, delicate',
		rarely = 'imbued, subtle',
		x10 = true,
		cat = 'painting artefacts', name = 'Painting artefacts',
		members = {
			['painting artefact 6'] = { compqty = 6 },
			['painting artefact 8'] = { compqty = 8 },
			['painting artefact 10'] = { compqty = 10 },
			['painting artefact 12'] = { compqty = 12 },
			['painting artefact 14'] = { compqty = 14 },
			['painting artefact 16'] = { compqty = 16 },
			['painting artefact 18'] = { compqty = 18 },
			['painting artefact 24'] = { compqty = 24 }
		}
	},
	['mechanism artefacts'] = {
		group = true,
		often = 'crafted, base, delicate',
		rarely = 'direct, variable',
		x10 = true,
		cat = 'mechanism artefacts', name = 'Mechanism artefacts',
		members = {
			['mechanism artefact 6'] = { compqty = 6 },
			['mechanism artefact 8'] = { compqty = 8 },
			['mechanism artefact 10'] = { compqty = 10 },
			['mechanism artefact 12'] = { compqty = 12 },
			['mechanism artefact 14'] = { compqty = 14 },
			['mechanism artefact 16'] = { compqty = 16 },
			['mechanism artefact 18'] = { compqty = 18 },
			['mechanism artefact 24'] = { compqty = 24 }
		}
	}
}

-- copy of data with nested groups unpacked
local allcategories = {}

-- fields that are copied from group
local copiedfields = { 'often', 'sometimes', 'rarely', 'x10', 'name', 'cat', 'nocalc' }

-- nested grouping
for w, n in pairs(data) do
	-- if a group, then copy it
	if n.group then
		-- for each member, named "x", take "y"
		for x, y in pairs(n.members) do
			-- table to store
			local _temp = {}

			-- copy the group's fields
			-- do group first in case they need to be overridden
			for _, z in ipairs(copiedfields) do
				_temp[z] = n[z]
			end

			-- copy the unique fields
			for z, t in pairs(y) do
				_temp[z] = t
			end

			-- add to list
			allcategories[x] = _temp
		end
	-- otherwise store directly
	else
		allcategories[w] = n
	end
end

-- aliases

-- list of names to check
local names = {}

for w, _ in pairs(allcategories) do
	table.insert(names,w)
end

for _, v in ipairs(names) do
	local aliases = allcategories[v].alias or {}
	for _, y in ipairs(aliases) do
		allcategories[y] = allcategories[v]
	end
end

return allcategories