--[[

Color palettes for general use. One representing the bronze/iron/steel/etc tiers, some fancy ones from online, and the existing builtins.

]]--

return {
-- Based on the bronze -> primal tiers, interspersed with dragon, crystal, imcando, E&S/E&G/T&S, and L&D/B&B
	{
		name = "tiers",
		[1] = "#8b4513",	-- Bronze
		[2] = "#696969",	-- Iron
		[3] = "#d3d3d3",	-- Steel
		[4] = "#000000",	-- Black
		[5] = "#6a5acd",	-- Mithril
		[6] = "#2e8b57",	-- Adamant
		[7] = "#4682b4",	-- Rune
		[8] = "#922222",	-- Orikalkum
		[9] = "#b22222",	-- Dragon
		[10] = "#22b222",	-- Necronium
		[11] = "#87cefa",	-- Crystal
		[12] = "#222242",	-- Bane
		[13] = "#daa520",	-- Imcando
		[14] = "#46b2e4",	-- Elder Rune
		[15] = "#87cefa",	-- E&S/E&G/T&S
		[16] = "#424242",	-- Primal
		[17] = "#424272",	-- L&D/B&B
	},
-- Categoricals, from https://www.heavy.ai/blog/12-color-palettes-for-telling-better-stories-with-your-data
{name = "retro_metro",     [1] = "#ea5545", [2] = "#f46a9b", [3] = "#ef9b20", [4] = "#edbf33", [5] = "#ede15b", [6] = "#bdcf32", [7] = "#87bc45", [8] = "#27aeef", [9] = "#b33dc6"},
{name = "dutch_field",     [1] = "#e60049", [2] = "#0bb4ff", [3] = "#50e991", [4] = "#e6d800", [5] = "#9b19f5", [6] = "#ffa300", [7] = "#dc0ab4", [8] = "#b3d4ff", [9] = "#00bfa0"},
{name = "river_nights",    [1] = "#b30000", [2] = "#7c1158", [3] = "#4421af", [4] = "#1a53ff", [5] = "#0d88e6", [6] = "#00b7c7", [7] = "#5ad45a", [8] = "#8be04e", [9] = "#ebdc78"},
{name = "spring_pastels",  [1] = "#fd7f6f", [2] = "#7eb0d5", [3] = "#b2e061", [4] = "#bd7ebe", [5] = "#ffb55a", [6] = "#ffee65", [7] = "#beb9db", [8] = "#fdcce5", [9] = "#8bd3c7"},
-- Sequentials
{name = "blue_to_yellow",  [1] = "#115f9a", [2] = "#1984c5", [3] = "#22a7f0", [4] = "#48b5c4", [5] = "#76c68f", [6] = "#a6d75b", [7] = "#c9e52f", [8] = "#d0ee11", [9] = "#d0f400"},
{name = "grey_to_red",     [1] = "#d7e1ee", [2] = "#cbd6e4", [3] = "#bfcbdb", [4] = "#b3bfd1", [5] = "#a4a2a8", [6] = "#df8879", [7] = "#c86558", [8] = "#b04238", [9] = "#991f17"},
{name = "black_to_pink",   [1] = "#2e2b28", [2] = "#3b3734", [3] = "#474440", [4] = "#54504c", [5] = "#6b506b", [6] = "#ab3da9", [7] = "#de25da", [8] = "#eb44e8", [9] = "#ff80ff"},
{name = "blues",           [1] = "#0000b3", [2] = "#0010d9", [3] = "#0020ff", [4] = "#0040ff", [5] = "#0060ff", [6] = "#0080ff", [7] = "#009fff", [8] = "#00bfff", [9] = "#00ffff"},
-- Divergents
{name = "blue_to_red",     [1] = "#1984c5", [2] = "#22a7f0", [3] = "#63bff0", [4] = "#a7d5ed", [5] = "#e2e2e2", [6] = "#e1a692", [7] = "#de6e56", [8] = "#e14b31", [9] = "#c23728"},
{name = "orange_to_purple",[1] = "#ffb400", [2] = "#d2980d", [3] = "#a57c1b", [4] = "#786028", [5] = "#363445", [6] = "#48446e", [7] = "#5e569b", [8] = "#776bcd", [9] = "#9080ff"},
{name = "pink_foam",       [1] = "#54bebe", [2] = "#76c8c8", [3] = "#98d1d1", [4] = "#badbdb", [5] = "#dedad2", [6] = "#e4bcad", [7] = "#df979e", [8] = "#d7658b", [9] = "#c80064"},
{name = "salmon_to_aqua",  [1] = "#e27c7c", [2] = "#a86464", [3] = "#6d4b4b", [4] = "#503f3f", [5] = "#333333", [6] = "#3c4e4b", [7] = "#466964", [8] = "#599e94", [9] = "#6cd4c5"},
-- Builtins
{name = "qualitative",     [1] = "#A6CEE3", [2] = "#1F78B4", [3] = "#B2DF8A", [4] = "#33A02C", [5] = "#FB9A99", [6] = "#E31A1C", [7] = "#FDBF6F", [8] = "#FF7F00", [9] = "#CAB2D6", [10] = "#6A3D9A"},
{name = "blue",            [1] = "#D0D1E6", [2] = "#A6BDDB", [3] = "#67A9CF", [4] = "#3690C0", [5] = "#02818A", [6] = "#016C59", [7] = "#014636"},
{name = "green",           [1] = "#D9F0A3", [2] = "#ADDD8E", [3] = "#78C679", [4] = "#41AB5D", [5] = "#238443", [6] = "#006837", [7] = "#00452A"},
{name = "blueGreen",       [1] = "#CCECE6", [2] = "#99D8C9", [3] = "#66C2A4", [4] = "#41AE76", [5] = "#238B45", [6] = "#006D2C", [7] = "#00441B"},
{name = "orange",          [1] = "#FEE391", [2] = "#FEC44F", [3] = "#FE9929", [4] = "#EC7014", [5] = "#CC4C02", [6] = "#993404", [7] = "#662506"}
}