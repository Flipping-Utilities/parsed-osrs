local names = {
    acorn =  'Acorn',
    willow = 'Willow seed',
    maple =  'Maple seed',
    yew =    'Yew seed',
    magic =  'Magic seed',
    elder =  'Elder seed',
    
    apple =     'Apple tree seed',
    banana =    'Banana tree seed',
    orange =    'Orange tree seed',
    curry =     'Curry tree seed',
    pineapple = 'Pineapple tree seed',
    papaya =    'Papaya tree seed',
    palm =      'Palm tree seed',
    ciku =      'Ciku seed',
    guarana =   'Guarana seed',
    carambola = 'Carambola seed'
}

local payments = {
    [names.acorn] =  { name = 'Tomato',             count = 1 },
    [names.willow] = { name = 'Cooking apple',      count = 1 },
    [names.maple] =  { name = 'Orange',             count = 1 },
    [names.yew] =    { name = 'Cactus spine',       count = 10 },
    [names.magic] =  { name = 'Coconut',            count = 25 },
    [names.elder] =  { name = 'Morchella mushroom', count = 25 },

    [names.apple] =     { name = 'Sweetcorn',      count = 9 },
    [names.banana] =    { name = 'Cooking apple',  count = 4 },
    [names.orange] =    { name = 'Strawberry',     count = 3 },
    [names.curry] =     { name = 'Bananas',        count = 5 },
    [names.pineapple] = { name = 'Watermellon',    count = 10 },
    [names.papaya] =    { name = 'Pineapple',      count = 10 },
    [names.palm] =      { name = 'Papaya fruit',   count = 15 },
    [names.ciku] =      { name = 'Zygomite fruit', count = 6 },
    [names.guarana] =   { name = 'Tombshroom',     count = 11 },
    [names.carambola] = { name = 'Dragonfruit',    count = 9 }
}

local harvests = {
    [names.apple] =     { name = 'Cooking apple', count = 6 },
    [names.banana] =    { name = 'Banana',        count = 6 },
    [names.orange] =    { name = 'Orange',        count = 6 },
    [names.curry] =     { name = 'Curry leaf',    count = 6 },
    [names.pineapple] = { name = 'Pineapple',     count = 6 },
    [names.papaya] =    { name = 'Papaya fruit',  count = 6 },
    [names.palm] =      { name = 'Coconut',       count = 6 },
    [names.ciku] =      { name = 'Ciku',          count = 6 },
    [names.guarana] =   { name = 'Guarana',       count = 6 },
    [names.carambola] = { name = 'Carambola',     count = 6 }
}

local experience = {
    [names.acorn] =  { plant = 14,    check = 467.3 },
    [names.willow] = { plant = 25,    check = 1456.5 },
    [names.maple] =  { plant = 45,    check = 3403.4 },
    [names.yew] =    { plant = 81,    check = 7069.9 },
    [names.magic] =  { plant = 145.5, check = 13768.3 },
    [names.elder] =  { plant = 311,   check = 23162 },

    [names.apple] =     { plant = 22,    check = 1199.5,  harvest = 8.5,    harvests = 6 },
    [names.banana] =    { plant = 28,    check = 1750.5,  harvest = 10.5,   harvests = 6 },
    [names.orange] =    { plant = 35.5,  check = 2470.2,  harvest = 13.5,   harvests = 6 },
    [names.curry] =     { plant = 40,    check = 2906.9,  harvest = 15,     harvests = 6 },
    [names.pineapple] = { plant = 57,    check = 4605.7,  harvest = 21.5,   harvests = 6 },
    [names.papaya] =    { plant = 72,    check = 6146.4,  harvest = 27,     harvests = 6 },
    [names.palm] =      { plant = 110.5, check = 10150.1, harvest = 41.5,   harvests = 6 },
    [names.ciku] =      { plant = 471,   check = 22047,   harvest = 1048.7, harvests = 3 },
    [names.guarana] =   { plant = 590.6, check = 28157,   harvest = 1339.8, harvests = 3 },
    [names.carambola] = { plant = 811.4, check = 35057.7, harvest = 1795.3, harvests = 3 }
}

local levels = {
    [names.acorn] =  15,
    [names.willow] = 30,
    [names.maple] =  45,
    [names.yew] =    60,
    [names.magic] =  75,
    [names.elder] =  90,

    [names.apple] =     27,
    [names.banana] =    33,
    [names.orange] =    39,
    [names.curry] =     42,
    [names.pineapple] = 51,
    [names.papaya] =    57,
    [names.palm] =      68,
    [names.ciku] =      101,
    [names.guarana] =   107,
    [names.carambola] = 113
}

local urns = {
    ['Cracked'] = { order = 1, name = 'Cracked farming urn (no rune)', base = 1100, max_level = 12 },
    ['Fragile'] = { order = 2,  name = 'Fragile farming urn (no rune)', base = 2500, max_level = 30 },
    ['Plain'] = { order = 3, name = 'Plain farming urn (no rune)', base = 4500, max_level = 53 },
    ['Strong'] = { order = 4, name = 'Strong farming urn (no rune)', base = 5500, max_level = 72 },
    ['Decorated'] = { order = 5, name = 'Decorated farming urn (no rune)', base = 7000, max_level = 120 }
}

return {
    names = names,
    payments = payments,
    harvests = harvests,
    experience = experience,
    levels = levels,
    urns = urns
}