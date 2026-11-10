local p = {}

--
-- Data for 120s (includes virtual 120s)
-- [[Template:120s]]
--
local count_120s = {}
count_120s["agility"] = "33,526"
count_120s["archaeology"] = "87,951"
count_120s["attack"] = "38,544"
count_120s["constitution"] = "62,442"
count_120s["construction"] = "26,889"
count_120s["cooking"] = "25,026"
count_120s["crafting"] = "26,620"
count_120s["defence"] = "56,814"
count_120s["divination"] = "27,476"
count_120s["dungeoneering"] = "75,937"
count_120s["farming"] = "74,783"
count_120s["firemaking"] = "34,331"
count_120s["fishing"] = "32,963"
count_120s["fletching"] = "26,126"
count_120s["herblore"] = "92,118"
count_120s["hunter"] = "32,897"
count_120s["invention"] = "127,909"
count_120s["magic"] = "51,348"
count_120s["mining"] = "38,976"
count_120s["necromancy"] = "66,255"
count_120s["prayer"] = "29,246"
count_120s["ranged"] = "46,137"
count_120s["runecrafting"] = "29,211"
count_120s["slayer"] = "76,482"
count_120s["smithing"] = "31,631"
count_120s["strength"] = "36,741"
count_120s["summoning"] = "33,153"
count_120s["thieving"] = "65,132"
count_120s["woodcutting"] = "31,470"
-- @notes this isn't updated by [[User:Cresbot]]
count_120s["overall"] = "62"
count_120s["updated"] = "22 September 2026"

function p.get_120s ( frame )
    local skill = string.lower( frame.args[1] )
    if not count_120s[skill] then
        return 0
    end

    return count_120s[skill]
end

--
-- End 120s
--

--
-- Data for ironman with 120s (includes virtual 120s)
-- [[Template:Ironman with 120s]]
--
local count_120s_ironman = {}
count_120s_ironman["agility"] = "824"
count_120s_ironman["archaeology"] = "8,848"
count_120s_ironman["attack"] = "2,489"
count_120s_ironman["constitution"] = "5,419"
count_120s_ironman["construction"] = "809"
count_120s_ironman["cooking"] = "711"
count_120s_ironman["crafting"] = "719"
count_120s_ironman["defence"] = "4,413"
count_120s_ironman["divination"] = "884"
count_120s_ironman["dungeoneering"] = "3,840"
count_120s_ironman["farming"] = "6,845"
count_120s_ironman["firemaking"] = "1,078"
count_120s_ironman["fishing"] = "1,247"
count_120s_ironman["fletching"] = "828"
count_120s_ironman["herblore"] = "5,412"
count_120s_ironman["hunter"] = "1,315"
count_120s_ironman["invention"] = "13,986"
count_120s_ironman["magic"] = "4,062"
count_120s_ironman["mining"] = "1,585"
count_120s_ironman["necromancy"] = "4,891"
count_120s_ironman["prayer"] = "1,087"
count_120s_ironman["ranged"] = "3,627"
count_120s_ironman["runecrafting"] = "722"
count_120s_ironman["slayer"] = "4,394"
count_120s_ironman["smithing"] = "933"
count_120s_ironman["strength"] = "2,359"
count_120s_ironman["summoning"] = "733"
count_120s_ironman["thieving"] = "6,466"
count_120s_ironman["woodcutting"] = "1,289"
-- @notes this isn't updated by [[User:Cresbot]]
count_120s_ironman["overall"] = "0"
count_120s_ironman["updated"] = "22 September 2026"

function p.get_120s_ironman ( frame )
    local skill = string.lower( frame.args[1] )
    if not count_120s_ironman[skill] then
        return 0
    end

    return count_120s_ironman[skill]
end

--
-- End ironman with 120s
--

--
-- Data for 99s (including overall)
-- [[Template:99s]]
--
local count_99s = {}
count_99s["agility"] = "203,854"
count_99s["archaeology"] = "173,202"
count_99s["attack"] = "262,234"
count_99s["constitution"] = "288,983"
count_99s["construction"] = "194,999"
count_99s["cooking"] = "242,756"
count_99s["crafting"] = "214,635"
count_99s["defence"] = "280,627"
count_99s["divination"] = "193,354"
count_99s["dungeoneering"] = "198,600"
count_99s["farming"] = "199,307"
count_99s["firemaking"] = "251,695"
count_99s["fishing"] = "219,671"
count_99s["fletching"] = "238,795"
count_99s["herblore"] = "251,555"
count_99s["hunter"] = "192,529"
count_99s["invention"] = "185,905"
count_99s["magic"] = "280,835"
count_99s["mining"] = "231,548"
count_99s["necromancy"] = "159,718"
count_99s["prayer"] = "243,867"
count_99s["ranged"] = "256,379"
count_99s["runecrafting"] = "185,407"
count_99s["slayer"] = "223,139"
count_99s["smithing"] = "240,259"
count_99s["strength"] = "276,248"
count_99s["summoning"] = "217,199"
count_99s["thieving"] = "216,388"
count_99s["woodcutting"] = "237,576"
-- @notes this isn't updated by [[User:Cresbot]]
count_99s["overall"] = "2"
-- @notes this isn't updated by [[User:Cresbot]]
count_99s["overall f2p"] = "8"
count_99s["updated"] = "22 September 2026"

function p.get_99s ( frame )
    local skill = string.lower( frame.args[1] )
    if not count_99s[skill] then
        return 0
    end

    return count_99s[skill]
end

--
-- End 99s
--

--
-- Data for ironman 99s
-- [[Template:Ironman with 99s]]
--
local count_99s_ironman = {}
count_99s_ironman["agility"] = "13,214"
count_99s_ironman["archaeology"] = "19,607"
count_99s_ironman["attack"] = "17,998"
count_99s_ironman["constitution"] = "25,047"
count_99s_ironman["construction"] = "14,664"
count_99s_ironman["cooking"] = "15,816"
count_99s_ironman["crafting"] = "16,526"
count_99s_ironman["defence"] = "24,008"
count_99s_ironman["divination"] = "21,236"
count_99s_ironman["dungeoneering"] = "15,447"
count_99s_ironman["farming"] = "23,308"
count_99s_ironman["firemaking"] = "16,556"
count_99s_ironman["fishing"] = "19,606"
count_99s_ironman["fletching"] = "15,977"
count_99s_ironman["herblore"] = "19,616"
count_99s_ironman["hunter"] = "15,935"
count_99s_ironman["invention"] = "21,224"
count_99s_ironman["magic"] = "23,386"
count_99s_ironman["mining"] = "26,456"
count_99s_ironman["necromancy"] = "17,932"
count_99s_ironman["prayer"] = "17,674"
count_99s_ironman["ranged"] = "17,909"
count_99s_ironman["runecrafting"] = "14,347"
count_99s_ironman["slayer"] = "19,641"
count_99s_ironman["smithing"] = "22,355"
count_99s_ironman["strength"] = "17,672"
count_99s_ironman["summoning"] = "15,616"
count_99s_ironman["thieving"] = "27,299"
count_99s_ironman["woodcutting"] = "17,270"
-- @notes this isn't updated by [[User:Cresbot]]
count_99s_ironman["overall"] = "0"
-- @notes this isn't updated by [[User:Cresbot]]
count_99s_ironman["overall f2p"] = "0"
count_99s_ironman["updated"] = "22 September 2026"

function p.get_99s_ironman ( frame )
    local skill = string.lower( frame.args[1] )
    if not count_99s_ironman[skill] then
        return 0
    end

    return count_99s_ironman[skill]
end

--
-- End ironman 99s
--

--
-- Data for 200mxp
-- [[Template:200mxp]]
--
local count_200mxp = {}
count_200mxp["agility"] = "12,098"
count_200mxp["archaeology"] = "25,492"
count_200mxp["attack"] = "12,561"
count_200mxp["constitution"] = "31,551"
count_200mxp["construction"] = "9,342"
count_200mxp["cooking"] = "9,390"
count_200mxp["crafting"] = "9,435"
count_200mxp["defence"] = "23,769"
count_200mxp["divination"] = "9,820"
count_200mxp["dungeoneering"] = "17,292"
count_200mxp["farming"] = "24,579"
count_200mxp["firemaking"] = "12,278"
count_200mxp["fishing"] = "11,471"
count_200mxp["fletching"] = "9,605"
count_200mxp["herblore"] = "17,063"
count_200mxp["hunter"] = "10,687"
count_200mxp["invention"] = "39,994"
count_200mxp["magic"] = "22,201"
count_200mxp["mining"] = "13,539"
count_200mxp["necromancy"] = "18,826"
count_200mxp["prayer"] = "10,367"
count_200mxp["ranged"] = "17,905"
count_200mxp["runecrafting"] = "10,758"
count_200mxp["slayer"] = "18,656"
count_200mxp["smithing"] = "11,156"
count_200mxp["strength"] = "12,393"
count_200mxp["summoning"] = "11,912"
count_200mxp["thieving"] = "22,323"
count_200mxp["woodcutting"] = "11,670"
count_200mxp["overall"] = "6,206"
count_200mxp["updated"] = "22 September 2026"

function p.get_200mxp(frame)
    local skill = string.lower(frame.args[1])

    if not count_200mxp[skill] then
        return 0
    end

    return count_200mxp[skill]
end

--
-- End 200mxp
--

--
-- Data for ironman with 200mxp
-- [[Template:Ironman with 200mxp]]
--
local count_200mxp_ironman = {}
count_200mxp_ironman["agility"] = "268"
count_200mxp_ironman["archaeology"] = "2,221"
count_200mxp_ironman["attack"] = "707"
count_200mxp_ironman["constitution"] = "2,538"
count_200mxp_ironman["construction"] = "232"
count_200mxp_ironman["cooking"] = "236"
count_200mxp_ironman["crafting"] = "248"
count_200mxp_ironman["defence"] = "1,799"
count_200mxp_ironman["divination"] = "286"
count_200mxp_ironman["dungeoneering"] = "513"
count_200mxp_ironman["farming"] = "2,121"
count_200mxp_ironman["firemaking"] = "353"
count_200mxp_ironman["fishing"] = "374"
count_200mxp_ironman["fletching"] = "272"
count_200mxp_ironman["herblore"] = "698"
count_200mxp_ironman["hunter"] = "367"
count_200mxp_ironman["invention"] = "3,323"
count_200mxp_ironman["magic"] = "1,712"
count_200mxp_ironman["mining"] = "467"
count_200mxp_ironman["necromancy"] = "1,703"
count_200mxp_ironman["prayer"] = "368"
count_200mxp_ironman["ranged"] = "1,127"
count_200mxp_ironman["runecrafting"] = "233"
count_200mxp_ironman["slayer"] = "1,134"
count_200mxp_ironman["smithing"] = "327"
count_200mxp_ironman["strength"] = "692"
count_200mxp_ironman["summoning"] = "262"
count_200mxp_ironman["thieving"] = "2,201"
count_200mxp_ironman["woodcutting"] = "417"
count_200mxp_ironman["overall"] = "167"
count_200mxp_ironman["updated"] = "22 September 2026"

function p.get_200mxp_ironman(frame)
    local skill = string.lower(frame.args[1])

    if not count_200mxp_ironman[skill] then
        return 0
    end

    return count_200mxp_ironman[skill]
end

--
-- End ironman with 200mxp
--

--
-- Data for Hiscores lowest rank
-- [[Template:Hiscores lowest rank]]
--
local lowest_ranks = {}
lowest_ranks["agility"] = "15"
lowest_ranks["agility.rank"] = "852,811"
lowest_ranks["archaeology"] = "15"
lowest_ranks["archaeology.rank"] = "512,111"
lowest_ranks["attack"] = "15"
lowest_ranks["attack.rank"] = "1,392,645"
lowest_ranks["constitution"] = "15"
lowest_ranks["constitution.rank"] = "1,664,861"
lowest_ranks["construction"] = "15"
lowest_ranks["construction.rank"] = "731,419"
lowest_ranks["cooking"] = "15"
lowest_ranks["cooking.rank"] = "1,260,651"
lowest_ranks["crafting"] = "15"
lowest_ranks["crafting.rank"] = "1,072,638"
lowest_ranks["defence"] = "15"
lowest_ranks["defence.rank"] = "1,400,359"
lowest_ranks["divination"] = "15"
lowest_ranks["divination.rank"] = "577,755"
lowest_ranks["dungeoneering"] = "15"
lowest_ranks["dungeoneering.rank"] = "802,265"
lowest_ranks["farming"] = "15"
lowest_ranks["farming.rank"] = "668,783"
lowest_ranks["firemaking"] = "15"
lowest_ranks["firemaking.rank"] = "1,220,580"
lowest_ranks["fishing"] = "15"
lowest_ranks["fishing.rank"] = "1,130,981"
lowest_ranks["fletching"] = "15"
lowest_ranks["fletching.rank"] = "891,132"
lowest_ranks["herblore"] = "15"
lowest_ranks["herblore.rank"] = "759,122"
lowest_ranks["hunter"] = "15"
lowest_ranks["hunter.rank"] = "686,633"
lowest_ranks["invention"] = "15"
lowest_ranks["invention.rank"] = "329,981"
lowest_ranks["magic"] = "15"
lowest_ranks["magic.rank"] = "1,212,105"
lowest_ranks["mining"] = "15"
lowest_ranks["mining.rank"] = "1,371,672"
lowest_ranks["necromancy"] = "15"
lowest_ranks["necromancy.rank"] = "366,892"
lowest_ranks["prayer"] = "15"
lowest_ranks["prayer.rank"] = "1,205,066"
lowest_ranks["ranged"] = "15"
lowest_ranks["ranged.rank"] = "1,097,898"
lowest_ranks["runecrafting"] = "15"
lowest_ranks["runecrafting.rank"] = "897,359"
lowest_ranks["slayer"] = "15"
lowest_ranks["slayer.rank"] = "794,663"
lowest_ranks["smithing"] = "15"
lowest_ranks["smithing.rank"] = "1,232,240"
lowest_ranks["strength"] = "15"
lowest_ranks["strength.rank"] = "1,375,528"
lowest_ranks["summoning"] = "15"
lowest_ranks["summoning.rank"] = "637,304"
lowest_ranks["thieving"] = "15"
lowest_ranks["thieving.rank"] = "831,922"
lowest_ranks["woodcutting"] = "15"
lowest_ranks["woodcutting.rank"] = "1,352,857"
lowest_ranks["overall"] = "52"
lowest_ranks["overall.rank"] = "2,000,000"
lowest_ranks["updated"] = "22 September 2026"

function p.get_lowest_ranks(frame)
    local skill = string.lower(frame.args[1])

    if not lowest_ranks[skill] then
        return 0
    end

    return lowest_ranks[skill]
end

--
-- End Hiscores lowest rank
--
return p