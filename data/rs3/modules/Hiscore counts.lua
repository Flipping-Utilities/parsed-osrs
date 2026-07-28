local p = {}

--
-- Data for 120s (includes virtual 120s)
-- [[Template:120s]]
--
local count_120s = {}
count_120s["agility"] = "33,595"
count_120s["archaeology"] = "87,689"
count_120s["attack"] = "37,936"
count_120s["constitution"] = "62,167"
count_120s["construction"] = "26,387"
count_120s["cooking"] = "24,977"
count_120s["crafting"] = "26,590"
count_120s["defence"] = "56,620"
count_120s["divination"] = "27,421"
count_120s["dungeoneering"] = "76,228"
count_120s["farming"] = "74,868"
count_120s["firemaking"] = "34,172"
count_120s["fishing"] = "32,902"
count_120s["fletching"] = "26,050"
count_120s["herblore"] = "92,439"
count_120s["hunter"] = "32,871"
count_120s["invention"] = "127,472"
count_120s["magic"] = "51,171"
count_120s["mining"] = "38,852"
count_120s["necromancy"] = "66,492"
count_120s["prayer"] = "29,126"
count_120s["ranged"] = "45,666"
count_120s["runecrafting"] = "29,228"
count_120s["slayer"] = "76,583"
count_120s["smithing"] = "31,634"
count_120s["strength"] = "36,112"
count_120s["summoning"] = "33,304"
count_120s["thieving"] = "63,649"
count_120s["woodcutting"] = "31,151"
-- @notes this isn't updated by [[User:Cresbot]]
count_120s["overall"] = "62"
count_120s["updated"] = "28 July 2026"

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
count_120s_ironman["agility"] = "806"
count_120s_ironman["archaeology"] = "8,741"
count_120s_ironman["attack"] = "2,410"
count_120s_ironman["constitution"] = "5,346"
count_120s_ironman["construction"] = "706"
count_120s_ironman["cooking"] = "699"
count_120s_ironman["crafting"] = "696"
count_120s_ironman["defence"] = "4,380"
count_120s_ironman["divination"] = "866"
count_120s_ironman["dungeoneering"] = "3,796"
count_120s_ironman["farming"] = "6,783"
count_120s_ironman["firemaking"] = "1,039"
count_120s_ironman["fishing"] = "1,229"
count_120s_ironman["fletching"] = "796"
count_120s_ironman["herblore"] = "5,359"
count_120s_ironman["hunter"] = "1,303"
count_120s_ironman["invention"] = "13,831"
count_120s_ironman["magic"] = "4,016"
count_120s_ironman["mining"] = "1,552"
count_120s_ironman["necromancy"] = "4,826"
count_120s_ironman["prayer"] = "1,038"
count_120s_ironman["ranged"] = "3,574"
count_120s_ironman["runecrafting"] = "701"
count_120s_ironman["slayer"] = "4,358"
count_120s_ironman["smithing"] = "913"
count_120s_ironman["strength"] = "2,273"
count_120s_ironman["summoning"] = "718"
count_120s_ironman["thieving"] = "6,031"
count_120s_ironman["woodcutting"] = "1,218"
-- @notes this isn't updated by [[User:Cresbot]]
count_120s_ironman["overall"] = "0"
count_120s_ironman["updated"] = "28 July 2026"

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
count_99s["agility"] = "204,162"
count_99s["archaeology"] = "173,051"
count_99s["attack"] = "261,743"
count_99s["constitution"] = "288,463"
count_99s["construction"] = "195,335"
count_99s["cooking"] = "242,662"
count_99s["crafting"] = "214,923"
count_99s["defence"] = "280,380"
count_99s["divination"] = "193,377"
count_99s["dungeoneering"] = "198,923"
count_99s["farming"] = "198,944"
count_99s["firemaking"] = "251,597"
count_99s["fishing"] = "219,599"
count_99s["fletching"] = "238,841"
count_99s["herblore"] = "251,774"
count_99s["hunter"] = "192,637"
count_99s["invention"] = "185,400"
count_99s["magic"] = "280,638"
count_99s["mining"] = "231,298"
count_99s["necromancy"] = "159,717"
count_99s["prayer"] = "243,817"
count_99s["ranged"] = "256,193"
count_99s["runecrafting"] = "185,737"
count_99s["slayer"] = "223,194"
count_99s["smithing"] = "240,411"
count_99s["strength"] = "275,735"
count_99s["summoning"] = "217,480"
count_99s["thieving"] = "213,745"
count_99s["woodcutting"] = "237,334"
-- @notes this isn't updated by [[User:Cresbot]]
count_99s["overall"] = "2"
-- @notes this isn't updated by [[User:Cresbot]]
count_99s["overall f2p"] = "8"
count_99s["updated"] = "28 July 2026"

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
count_99s_ironman["agility"] = "13,079"
count_99s_ironman["archaeology"] = "19,394"
count_99s_ironman["attack"] = "17,805"
count_99s_ironman["constitution"] = "24,808"
count_99s_ironman["construction"] = "14,544"
count_99s_ironman["cooking"] = "15,678"
count_99s_ironman["crafting"] = "16,338"
count_99s_ironman["defence"] = "23,801"
count_99s_ironman["divination"] = "21,021"
count_99s_ironman["dungeoneering"] = "15,192"
count_99s_ironman["farming"] = "23,094"
count_99s_ironman["firemaking"] = "16,387"
count_99s_ironman["fishing"] = "19,441"
count_99s_ironman["fletching"] = "15,817"
count_99s_ironman["herblore"] = "19,451"
count_99s_ironman["hunter"] = "15,808"
count_99s_ironman["invention"] = "20,958"
count_99s_ironman["magic"] = "23,251"
count_99s_ironman["mining"] = "26,211"
count_99s_ironman["necromancy"] = "17,601"
count_99s_ironman["prayer"] = "17,522"
count_99s_ironman["ranged"] = "17,758"
count_99s_ironman["runecrafting"] = "14,218"
count_99s_ironman["slayer"] = "19,501"
count_99s_ironman["smithing"] = "22,128"
count_99s_ironman["strength"] = "17,495"
count_99s_ironman["summoning"] = "15,489"
count_99s_ironman["thieving"] = "26,176"
count_99s_ironman["woodcutting"] = "17,081"
-- @notes this isn't updated by [[User:Cresbot]]
count_99s_ironman["overall"] = "0"
-- @notes this isn't updated by [[User:Cresbot]]
count_99s_ironman["overall f2p"] = "0"
count_99s_ironman["updated"] = "28 July 2026"

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
count_200mxp["agility"] = "12,041"
count_200mxp["archaeology"] = "25,411"
count_200mxp["attack"] = "12,360"
count_200mxp["constitution"] = "31,343"
count_200mxp["construction"] = "9,260"
count_200mxp["cooking"] = "9,303"
count_200mxp["crafting"] = "9,357"
count_200mxp["defence"] = "23,656"
count_200mxp["divination"] = "9,754"
count_200mxp["dungeoneering"] = "17,297"
count_200mxp["farming"] = "24,544"
count_200mxp["firemaking"] = "12,137"
count_200mxp["fishing"] = "11,358"
count_200mxp["fletching"] = "9,535"
count_200mxp["herblore"] = "17,078"
count_200mxp["hunter"] = "10,632"
count_200mxp["invention"] = "39,714"
count_200mxp["magic"] = "22,234"
count_200mxp["mining"] = "13,452"
count_200mxp["necromancy"] = "18,841"
count_200mxp["prayer"] = "10,262"
count_200mxp["ranged"] = "17,759"
count_200mxp["runecrafting"] = "10,702"
count_200mxp["slayer"] = "18,558"
count_200mxp["smithing"] = "11,123"
count_200mxp["strength"] = "12,185"
count_200mxp["summoning"] = "11,940"
count_200mxp["thieving"] = "21,878"
count_200mxp["woodcutting"] = "11,483"
count_200mxp["overall"] = "6,114"
count_200mxp["updated"] = "28 July 2026"

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
count_200mxp_ironman["agility"] = "259"
count_200mxp_ironman["archaeology"] = "2,207"
count_200mxp_ironman["attack"] = "684"
count_200mxp_ironman["constitution"] = "2,490"
count_200mxp_ironman["construction"] = "213"
count_200mxp_ironman["cooking"] = "227"
count_200mxp_ironman["crafting"] = "238"
count_200mxp_ironman["defence"] = "1,782"
count_200mxp_ironman["divination"] = "276"
count_200mxp_ironman["dungeoneering"] = "497"
count_200mxp_ironman["farming"] = "2,087"
count_200mxp_ironman["firemaking"] = "342"
count_200mxp_ironman["fishing"] = "360"
count_200mxp_ironman["fletching"] = "265"
count_200mxp_ironman["herblore"] = "679"
count_200mxp_ironman["hunter"] = "354"
count_200mxp_ironman["invention"] = "3,273"
count_200mxp_ironman["magic"] = "1,705"
count_200mxp_ironman["mining"] = "455"
count_200mxp_ironman["necromancy"] = "1,672"
count_200mxp_ironman["prayer"] = "357"
count_200mxp_ironman["ranged"] = "1,117"
count_200mxp_ironman["runecrafting"] = "223"
count_200mxp_ironman["slayer"] = "1,111"
count_200mxp_ironman["smithing"] = "314"
count_200mxp_ironman["strength"] = "669"
count_200mxp_ironman["summoning"] = "254"
count_200mxp_ironman["thieving"] = "2,099"
count_200mxp_ironman["woodcutting"] = "403"
count_200mxp_ironman["overall"] = "159"
count_200mxp_ironman["updated"] = "28 July 2026"

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
lowest_ranks["agility.rank"] = "845,814"
lowest_ranks["archaeology"] = "15"
lowest_ranks["archaeology.rank"] = "507,134"
lowest_ranks["attack"] = "15"
lowest_ranks["attack.rank"] = "1,385,760"
lowest_ranks["constitution"] = "15"
lowest_ranks["constitution.rank"] = "1,657,796"
lowest_ranks["construction"] = "15"
lowest_ranks["construction.rank"] = "724,410"
lowest_ranks["cooking"] = "15"
lowest_ranks["cooking.rank"] = "1,253,041"
lowest_ranks["crafting"] = "15"
lowest_ranks["crafting.rank"] = "1,064,728"
lowest_ranks["defence"] = "15"
lowest_ranks["defence.rank"] = "1,392,452"
lowest_ranks["divination"] = "15"
lowest_ranks["divination.rank"] = "573,423"
lowest_ranks["dungeoneering"] = "15"
lowest_ranks["dungeoneering.rank"] = "797,916"
lowest_ranks["farming"] = "15"
lowest_ranks["farming.rank"] = "663,722"
lowest_ranks["firemaking"] = "15"
lowest_ranks["firemaking.rank"] = "1,214,247"
lowest_ranks["fishing"] = "15"
lowest_ranks["fishing.rank"] = "1,123,846"
lowest_ranks["fletching"] = "15"
lowest_ranks["fletching.rank"] = "883,588"
lowest_ranks["herblore"] = "15"
lowest_ranks["herblore.rank"] = "753,206"
lowest_ranks["hunter"] = "15"
lowest_ranks["hunter.rank"] = "682,776"
lowest_ranks["invention"] = "15"
lowest_ranks["invention.rank"] = "329,046"
lowest_ranks["magic"] = "15"
lowest_ranks["magic.rank"] = "1,204,514"
lowest_ranks["mining"] = "15"
lowest_ranks["mining.rank"] = "1,362,642"
lowest_ranks["necromancy"] = "15"
lowest_ranks["necromancy.rank"] = "361,340"
lowest_ranks["prayer"] = "15"
lowest_ranks["prayer.rank"] = "1,197,032"
lowest_ranks["ranged"] = "15"
lowest_ranks["ranged.rank"] = "1,091,933"
lowest_ranks["runecrafting"] = "15"
lowest_ranks["runecrafting.rank"] = "891,517"
lowest_ranks["slayer"] = "15"
lowest_ranks["slayer.rank"] = "788,064"
lowest_ranks["smithing"] = "15"
lowest_ranks["smithing.rank"] = "1,224,074"
lowest_ranks["strength"] = "15"
lowest_ranks["strength.rank"] = "1,368,801"
lowest_ranks["summoning"] = "15"
lowest_ranks["summoning.rank"] = "632,710"
lowest_ranks["thieving"] = "15"
lowest_ranks["thieving.rank"] = "823,803"
lowest_ranks["woodcutting"] = "15"
lowest_ranks["woodcutting.rank"] = "1,345,102"
lowest_ranks["overall"] = "49"
lowest_ranks["overall.rank"] = "2,000,000"
lowest_ranks["updated"] = "28 July 2026"

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