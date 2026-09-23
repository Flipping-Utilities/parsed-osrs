local p = {}

local colours = {
	["Hair"] = {
		["Dark brown"] = 0, -- #53411d
		["White"] = 1, -- #e4e1e1
		["Light grey"] = 2, -- #86907c
		["Dark grey"] = 3, -- #484444
		["Apricot"] = 4, -- #d9944e
		["Straw"] = 5, -- #d6b964
		["Light brown"] = 6, -- #a67b3c
		["Brown"] = 7, -- #7d5a39
		["Turquoise"] = 8, -- #129da2
		["Green"] = 9, -- #12a218
		["Ginger"] = 10, -- #b45015
		["Magenta"] = 11, -- #c718d0
		["Black"] = 12, -- #2d2b2b
		["Grey"] = 13, -- #796d60
		["Beige"] = 14, -- #bbba95
		["Peach"] = 15, -- #da9266
		["Light blue"] = 16, -- #90adca
		["Royal blue"] = 17, -- #3f41ae
		["Pale pink"] = 18, -- #b59291
		["Intense pink"] = 19, -- #cc655f
		["Maroon"] = 20, -- #571209
		["Light green"] = 21, -- #92cb93
		["Dark green"] = 22, -- #3c5950
		["Purple"] = 23, -- #8841b3
		["Light purple"] = 24, -- #ba8dc9
		["Navy blue"] = 25, -- #242543
		["Bright red"] = 26, -- #9b0d05
		["Yellow"] = 27, -- #f8cb12
		["Dark purple"] = 28, -- #38024a
		["Aqua"] = 29, -- #1f9b7f
	},

	["Skin"] = {
		["Pale"] = 0, -- #bb8f6a
		["Light"] = 1, -- #a47f5d
		["Slightly tan"] = 2, -- #9e7a49
		["Tan"] = 3, -- #836e42
		["Very tan"] = 4, -- #79582a
		["Dark"] = 5, -- #644e24
		["Very dark"] = 6, -- #4c3d09
		["Very pale"] = 7, -- #d5a985
		["Green"] = 8, -- #007f00
		["Black"] = 9, -- #644e24
		["White"] = 10, -- #ffffff
		["Cyan"] = 11, -- #05989f
		["Purple"] = 12, -- #6441a5
	},

	["Torso"] = {
		["Khaki"] = 0, -- #7b6e32
		["Charcoal"] = 1, -- #262323
		["Crimson"] = 2, -- #752F3b
		["Navy"] = 3, -- #3b3b4e
		["Straw"] = 4, -- #aa9045
		["White"] = 5, -- #ada481
		["Red"] = 6, -- #8b3b2a
		["Blue"] = 7, -- #2d5272
		["Green"] = 8, -- #2d723e
		["Yellow"] = 9, -- #a3970d
		["Purple"] = 10, -- #83537b
		["Orange"] = 11, -- #9f642f
		["Rose"] = 12, -- #a17067
		["Lime"] = 13, -- #829472
		["Cyan"] = 14, -- #728c94
		["Emerald"] = 15, -- #1c6135
		["Black"] = 16, -- #101010
		["Grey"] = 17, -- #404040
		["Onion"] = 18, -- #f8d890
		["Peach"] = 19, -- #f8be82
		["Lumbridge Blue"] = 20, -- #9696ff
		["Deep Blue"] = 21, -- #0000ff
		["Light Pink"] = 22, -- #ffbebe
		["Cadmium Red"] = 23, -- #c85032
		["Maroon"] = 24, -- #952800
		["Pale Green"] = 25, -- #c7fec7
		["Turquoise"] = 26, -- #007878
		["Deep Purple"] = 27, -- #960096
		["Light Purple"] = 28, -- #fe95fe
	},

	["Legs"] = {
		["Emerald"] = 0, -- #1c6135
		["Khaki"] = 1, -- #7b6e32
		["Charcoal"] = 2, -- #26232
		["Crimson"] = 3, -- #752F3b
		["Navy"] = 4, -- #3b3b4e
		["Straw"] = 5, -- #aa904
		["White"] = 6, -- #ada481
		["Red"] = 7, -- #8b3b2a
		["Blue"] = 8, -- #2d5272
		["Green"] = 9, -- #2d723e
		["Yellow"] = 10, -- #a3970d
		["Purple"] = 11, -- #83537b
		["Orange"] = 12, -- #9f642f
		["Rose"] = 13, -- #a17067
		["Lime"] = 14, -- #829472
		["Cyan"] = 15, -- #728c94
		["Black"] = 16, -- #101010
		["Grey"] = 17, -- #404040
		["Onion"] = 18, -- #f8d890
		["Peach"] = 19, -- #f8be82
		["Lumbridge Blue"] = 20, -- #9696ff
		["Deep Blue"] = 21, -- #0000ff
		["Light Pink"] = 22, -- #ffbebe
		["Cadmium Red"] = 23, -- #c85032
		["Maroon"] = 24, -- #952800
		["Pale Green"] = 25, -- #c7fec7
		["Turquoise"] = 26, -- #007878
		["Deep Purple"] = 27, -- #960096
		["Light Purple"] = 28, -- #fe95fe
	},

	["Shoe"] = {
		["Brown"] = 0, -- #3c2412
		["Khaki"] = 1, -- #2a2901
		["Ashen"] = 2, -- #6b5839
		["Dark"] = 3, -- #1c1919
		["Terracotta"] = 4, -- #4e2b0f
		["Grey"] = 5, -- #44443c
	},
}

local models = {
	["Torso"] = {
		["Plain"] = {274, 312},
		["Torn"] = {280, 316},
		["Sweater"] = {361, 345},
		["Cuffed Shirt"] = {362, 346},
		["Vest"] = {363, 347},
		["Light Buttons"] = {275, 521},
		["Dark Buttons"] = {276, 522},
		["Jacket"] = {277, 523},
		["Shirt"] = {278, 524},
		["Two-toned"] = {281, 526},
		["Regal"] = {364, 527},
		["Ripped Weskit"] = {365, 528},
		["Torn Weskit"] = {366, 529},
		["Crop Top"] = {510, 313},
		["Polo Neck"] = {511, 314},
		["Simple"] = {512, 315},
		["Frilly"] = {513, 348},
		["Corsetry"] = {514, 349},
		["Bodice"] = {515, 350},
		["Stitching"] = {279, 525},
	},

	["Arms"] = {
		["Regular"] = {282, 317},
		["Muscly"] = {283, 319},
		["Large Cuffs"] = {285, 321},
		["Loose Sleeves"] = {284, 504},
		["Thin Stripe"] = {288, 353},
		["White Cuffs"] = {341, 352},
		["Thin sleeves"] = {286, 505},
		["Shoulder Pads"] = {287, 506},
		["Regal"] = {342, 507},
		["Tatty"] = {343, 508},
		["Ripped"] = {344, 509},
		["Bare Sleeves"] = {516, 318},
		["Thick Stripes"] = {340, 351},
		["Tatty Shoulders"] = {519, 354},
		["Bare Shoulders"] = {520, 355},
		["Frilly"] = {518, 322},
		["Long Sleeved"] = {517, 320},
	},

	["Legs"] = {
		["Plain"] = {292, 326},
		["Flares"] = {294, 328},
		["Turn Ups"] = {295, 332},
		["Tatty"] = {296, 331},
		["Shorts"] = {293, 530},
		["Beach"] = {297, 531},
		["Regal"] = {356, 532},
		["Leggings"] = {357, 533},
		["Side Stripes"] = {358, 534},
		["Ripped"] = {359, 535},
		["Patched"] = {360, 536},
		["Skirt"] = {537, 327},
		["Long Skirt"] = {538, 329},
		["Narrow Skirt"] = {539, 330},
		["Short Skirt"] = {540, 333},
		["Layered"] = {541, 334},
		["Sash and Dots"] = {542, 391},
		["Big Hem"] = {543, 392},
		["Sash and Trousers"] = {544, 393},
		["Patterned"] = {545, 394},
		["Torn Skirt"] = {546, 395},
		["Patched Skirt"] = {547, 396},
	},

	["Hair"] = {
		["Bald"] = {256, 301},
		["Dreadlocks"] = {257, 303},
		["Long"] = {258, 304},
		["Medium"] = {259, 305},
		["Tonsure"] = {260, 430},
		["Short"] = {261, 307},
		["Cropped"] = {262, 308},
		["Wild spikes"] = {263, 309},
		["Spikes"] = {264, 310},
		["Mohawk"] = {265, 431},
		["Wind braids"] = {385, 376},
		["Quiff"] = {386, 432},
		["Samurai"] = {387, 433},
		["Princely"] = {388, 434},
		["Curtains"] = {389, 384},
		["Long curtains"] = {390, 435},
		["Front split"] = {407, 408},
		["Tousled"] = {400, 436},
		["Side wedge"] = {401, 437},
		["Front wedge"] = {402, 438},
		["Front spikes"] = {403, 439},
		["Frohawk"] = {404, 440},
		["Rear skirt"] = {405, 441},
		["Queue"] = {406, 442},
		["Bun"] = {477, 302},
		["Pigtails"] = {478, 306},
		["Earmuffs"] = {479, 311},
		["Side pony"] = {480, 374},
		["Curls"] = {481, 375},
		["Ponytail"] = {482, 377},
		["Braids"] = {483, 378},
		["Bunches"] = {484, 379},
		["Bob"] = {485, 380},
		["Layered"] = {486, 381},
		["Straight"] = {487, 382},
		["Straight Braids"] = {488, 383},
		["Two-back"] = {489, 399},
		["Mullet"] = {457, 410},
		["Undercut"] = {458, 411},
		["Low Bun"] = {472, 425},
		["Messy Bun"] = {473, 426},
		["Pompadour"] = {459, 412},
		["Afro"] = {460, 413},
		["Short locs"] = {461, 414},
		["Spiky Mohawk"] = {462, 415},
		["Slicked Mohawk"] = {463, 416},
		["Long Quiff"] = {464, 417},
		["Short Choppy"] = {465, 418},
		["Side Afro"] = {466, 419},
		["Punk"] = {467, 420},
		["Half-shaved"] = {468, 421},
		["Fremennik"] = {469, 422},
		["Elven"] = {470, 423},
		["Medium Coils"] = {471, 424},
		["High ponytail"] = {474, 427},
		["Plaits"] = {475, 428},
		["High Bunches"] = {476, 429},
	},

	["Hands"] = {
		["Basic"] = {289, 323},
		["Plain"] = {290, 324},
	},

	["Boots"] = {
		["Basic"] = {298, 335},
		["Elven"] = {299, 336},
	},

	["Jaw"] = {
		["None"] = {270, 552},
		["Goatee"] = {266, 548},
		["Long"] = {267, 549},
		["Handlebar"] = {367, 556},
		["Medium"] = {268, 550},
		["Moustache"] = {269, 551},
		["Short"] = {271, 553},
		["Pointy"] = {272, 554},
		["Split"] = {273, 555},
		["Mutton"] = {368, 557},
		["Full Mutton"] = {369, 558},
		["Big Moustache"] = {370, 559},
		["Waxed Moustache"] = {371, 560},
		["Dali"] = {372, 561},
		["Vizier"] = {373, 562},
	},
}


function p._main(args)
	return "Hello from module"
end

function p.generate_input()
	local paramsStr = ""
	local groupStr = "param = colorsgrp|Group||group|"
	for k,v in pairs(colours) do
		paramsStr = paramsStr .. "param = "
	end
end

return p