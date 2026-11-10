return {
    -- prayer variants
    -- super renewal is tradeable
    ['super prayer'] = {
        type = 'potion',
        ingredients = {
            'Prayer potion (3)',
            'Wyvern bones'
        }
    },
    ['extreme prayer'] = {
        type = 'potion',
        ingredients = {
            'Super prayer (3)',
            'Spark chitin',
            'Primal extract'
        }
    },
    
    -- adrenaline and variants
    ['adrenaline'] = {
        type = 'potion',
        ingredients = {
            'Super energy (3)',
            'Papaya fruit'
        }
    },
    ['super adrenaline'] = {
        type = 'potion',
        ingredients = {
            { r = true, 'adrenaline' },
            'Adrenaline crystal'
        }
    },
    ['replenishment'] = {
        type = 'crystal',
        ingredients = {
            'Super restore (4)',
            { r = true, 'adrenaline', qty=4/3 }
        }
    },
    ['enhanced replenishment'] = {
        type = 'special',
        ingredients = {
            { r=true, 'replenishment' },
            'Adrenaline crystal'
        }
    },

    ['wyrmfire'] = {
        type = 'crystal',
        ingredients = {
        	'Super antifire (4)',
            'Antifire (4)'
        }
    },
    ['brightfire'] = {
        type = 'crystal',
        ingredients = {
        	'Super antifire (4)',
            'Prayer renewal (4)'
        }
    },

    -- extremes and variants
    ['extreme attack'] = {
        type = 'potion',
        ingredients = {
            'Super attack (3)',
            'Clean avantoe'
        }
    },
    ['extreme strength'] = {
        type = 'potion',
        ingredients = {
            'Super strength (3)',
            'Clean dwarf weed'
        }
    },
    ['extreme defence'] = {
        type = 'potion',
        ingredients = {
            'Super defence (3)',
            'Clean lantadyme'
        }
    },
    ['extreme ranging'] = {
        type = 'potion',
        ingredients = {
            'Super ranging potion (3)',
            { 'Grenwall spikes', qty=5 }
        }
    },
    ['extreme magic'] = {
        type = 'potion',
        ingredients = {
            'Super magic potion (3)',
            'Ground mud runes'
        }
    },
    ['extreme necromancy'] = {
        type = 'potion',
        ingredients = {
            'Super necromancy (3)',
            'Ground miasma rune'
        }
    },    
    ['extreme brawler'] = {
        type = 'crystal',
        ingredients = {
	        'Extreme attack (4)',
	        'Extreme strength (4)',
	        'Extreme defence (4)'
        }
    },
    ['extreme battlemage'] = {
        type = 'crystal',
        ingredients = {
	        'Extreme defence (4)',
	        'Extreme magic (4)'
        }
    },
    ['extreme sharpshooter'] = {
        type = 'crystal',
        ingredients = {
	        'Extreme defence (4)',
	        'Extreme ranging (4)'
        }
    },
    ['extreme warmaster'] = {
        type = 'crystal',
        ingredients = {
	        'Extreme attack (4)',
	        'Extreme strength (4)',
	        'Extreme defence (4)',
	        'Extreme ranging (4)',
	        'Extreme magic (4)'
        }
    },

    -- supremes
    ['supreme attack'] = {
        type = 'crystal',
        ingredients = {
	        'Extreme attack (4)',
	        'Super attack (4)'
        }
    },
    ['supreme strength'] = {
        type = 'crystal',
        ingredients = {
	        'Extreme strength (4)',
	        'Super strength (4)'
        }
    },
    ['supreme defence'] = {
        type = 'crystal',
        ingredients = {
	        'Extreme defence (4)',
	        'Super defence (4)'
        }
    },
    ['supreme magic'] = {
        type = 'crystal',
        ingredients = {
	        'Extreme magic (4)',
	        'Super magic potion (4)'
        }
    },
    ['supreme ranging'] = {
        type = 'crystal',
        ingredients = {
	        'Extreme ranging (4)',
	        'Super ranging potion (4)'
        }
    },

    -- overload and variants
    overload = {
        type = 'overload',
        herb120 = true,
        ingredients = {
            'Extreme attack (3)',
            'Extreme strength (3)',
            'Extreme defence (3)',
            'Extreme ranging (3)',
            'Extreme magic (3)',
            'Extreme necromancy (3)',
            'Clean torstol'
        },
    },
    ['holy overload'] = {
        type = 'crystal',
        ingredients = {
            { r=true, 'overload', qty=4/3 },
            'Prayer renewal (4)'
        }
    },
    ['searing overload'] = {
        type = 'crystal',
        ingredients = {
            { r=true, 'overload', qty=4/3 },
        	'Super antifire (4)'
        }
    },
    ['aggroverload'] = {
        type = 'crystal',
        ingredients = {
            { r=true, 'overload', qty=4/3 },
            'Aggression potion (4)',
            'Clean arbuck'
        }
    },
    ['holy aggroverload'] = {
        type = 'crystal',
        ingredients = {
            { r=true, 'overload', qty=4/3 },
            'Aggression potion (4)',
            'Prayer renewal potion (4)',
            'Spider venom'
        }
    },
    ['overload salve'] = {
        type = 'crystal',
        ingredients = {
            { r=true, 'overload', qty=4/3 },
        	'Super antifire (4)',
            'Antifire (4)',
            'Prayer renewal (4)',
            'Prayer potion (4)',
            'Super antipoison (4)'
        }
    },
    ['supreme overload'] = {
        type = 'crystal',
        herb120 = true,
        ingredients = {
            { r=true, 'overload', qty=4/3 },
            'Super attack (4)',
            'Super strength (4)',
            'Super defence (4)',
            'Super magic potion (4)',
            'Super ranging potion (4)',
            'Super necromancy (4)'
        }
    },
    ['supreme overload salve'] = {
        type = 'crystal',
        ingredients = {
            { r=true, 'supreme overload' },
        	'Super antifire (4)',
            'Antifire (4)',
            'Prayer renewal (4)',
            'Prayer potion (4)',
            'Super antipoison (4)'
        }
    },
    ['elder overload'] = {
        type = 'combination',
        basepot = 'supreme overload',
        herb120 = true,
        ingredients = {
            --{ r=true, 'supreme overload' },
            'Primal extract',
            'Clean fellstalk'
        }
    },
    ['elder overload salve'] = {
    	type = 'combination',
        basepot = 'elder overload',
        ingredients = {
            --{ r=true, 'elder overload' },
        	'Super antifire (4)',
            'Antifire (4)',
            'Prayer renewal (4)',
            'Prayer potion (4)',
            'Super antipoison (4)'
        }
    },
    ['elder overload salve alt'] = {
    	type = 'combination',
        basepot = 'supreme overload salve',
        ingredients = {
            --{ r=true, 'supreme overload salve' },
            'Primal extract',
            'Clean fellstalk'
        }
    },
    ['perfect plus'] = {
        type = 'crystal',
        ingredients = {
            { r=true, 'overload', qty=4/3 },
            'Harmony moss',
            { 'Crystal tree blossom', val=0 }
        }
    },
    
    -- powerbursts
    ['adrenaline renewal'] = {
    	type = 'special',
        ingredients = {
            { r=true, 'super adrenaline', qty=4/3 },
            'Primal extract',
            { 'Bottled dinosaur roar', qty=2 },
            'Clean arbuck',
        }
    },
    ['adrenaline renewal 2'] = {
    	type = 'special',
        ingredients = {
            { r=true, 'super adrenaline' },
            'Primal extract',
            'Bottled dinosaur roar',
            'Clean arbuck',
        }
    },
    ['overkill'] = {
    	type = 'special',
        ingredients = {
            { r=true, 'super adrenaline', qty=4/3 },
            'Primal extract',
            { 'Bottled dinosaur roar', qty=2 },
            'Clean arbuck',
        }
    },
    ['overkill 2'] = {
    	type = 'special',
        ingredients = {
            { r=true, 'super adrenaline' },
            'Primal extract',
            'Bottled dinosaur roar',
            'Clean arbuck',
        }
    },
    
    -- bombs
    -- no untradeable ones atm
    
    -- skilling
    ['stamina'] = {
    	type = 'special',
        ingredients = {
            'Super energy (3)',
            'Arbuck potion (unfinished)',
        }
    },
    ['extreme divination'] = {
    	type = 'special',
        ingredients = {
            'Super divination (3)',
            'Yak tuft',
        }
    },
    ['extreme hunter'] = {
    	type = 'special',
        ingredients = {
            'Super hunter (3)',
            'Bull horns',
        }
    },
    ['extreme invention'] = {
    	type = 'special',
        ingredients = {
            'Super invention (3)',
            'Mycelial webbing',
        }
    },
    ['extreme runecrafting'] = {
    	type = 'special',
        ingredients = {
            'Super runecrafting (3)',
            'Spider venom',
        }
    },
    ['extreme cooking'] = {
    	type = 'special',
        ingredients = {
            'Super cooking (3)',
            'Primal extract',
            'Beak snot',
        }
    }
}