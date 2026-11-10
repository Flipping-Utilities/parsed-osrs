local p = {}
local plinkt = require( "Module:Plink" )._plinkt
local round = require( "Module:Round").round
local uclc = require( "Module:Paramtest" ).ucflc
require( "Module:Mw.html extension" )

-- display parameters
local MAX_IMG_SIZE = "34x34"
local NUM_PERC_DP = 2

-- urn type = {max level, xp to fill}
local urns = {
	cooking = {
		cracked = {10, 2000},
		fragile = {25, 2750},
		plain = {40, 4750},
		strong = {55, 5250},
		decorated = {math.huge, 7737.5},
		exquisite = {math.huge, 11230.0},
	},
	divination = {
		cracked = {10, 1050},
		fragile = {30, 1750},
		plain = {50, 2500},
		strong = {70, 4000},
		decorated = {math.huge, 9500},
		exquisite = {math.huge, 12980.0},
	},
	farming = {
		cracked = {12, 1100},
		fragile = {30, 2500},
		plain = {53, 4500},
		strong = {72, 5500},
		decorated = {math.huge, 7000},
		exquisite = {math.huge, 11300.0},
	},
	fishing = {
		cracked = {10, 750},
		fragile = {30, 1750},
		plain = {50, 2500},
		strong = {70, 3000},
		decorated = {math.huge, 9500},
		exquisite = {math.huge, 13300.0},
	},
	hunter = {
		cracked = {11, 1100},
		fragile = {29, 2500},
		plain = {53, 5000},
		strong = {74, 7000},
		decorated = {math.huge, 8000},
		exquisite = {math.huge, 11040.0},
	},
	mining = {
		cracked = {10, 437.5},
		fragile = {30, 1000},
		plain= {50, 1625},
		strong = {70, 2000},
		decorated = {math.huge, 3125},
		exquisite = {math.huge, 4375.0},
	},
	prayer = {
		impious = {1, 100},
		accursed = {1, 312.5},
		infernal = {1, 1562.5},
	},
	runecrafting = {
		cracked = {9, 1050},
		fragile = {27, 1750},
		plain = {54, 3500},
		strong = {77, 5000},
		decorated = {math.huge, 7000},
		exquisite = {math.huge, 9450.0},
	},
	smithing = {
		cracked = {10, 200.0},
		fragile = {30, 1430.0},
		plain = {50, 2980.0},
		strong = {70, 7254.0},
		decorated = {math.huge, 9470.0},
		exquisite = {math.huge, 12130.0},
	},
	woodcutting = {
		cracked = {10, 800},
		fragile = {35, 2125},
		plain = {58, 4125},
		strong = {75, 8312.5},
		decorated = {math.huge, 9500},
		exquisite = {math.huge, 13015.0},
	},
}
--Main functions
local function load_data( frame, skill )
	local args = frame:getParent().args
	local urn_type = string.lower( args[1] or "" )
	local src_type = args[2] and args[2]:lower()
	
	local urn_data = urns[string.lower( skill or "" )]
	if not urn_data then
		error( "Unrecognised skill: " .. skill )
	end
	
	urn_data = urn_data[urn_type]
	if not urn_data then
        local types = {}
        for k, _ in pairs( urn_data ) do
            table.insert( types, k )
        end
		error( 'Unrecognised urn type. Use: "' .. table.concat( types, '", "' ) .. '".' )
	end
	
	skill = uclc( skill )
    local TEMP_data_new = true
	local data_ok, skill_data = pcall( mw.loadData, string.format( "Module:Urn table/%sData", skill ) )
	
	--TEMP: load old data structures during migration period
	local TEMP_data_new = data_ok
    if not TEMP_data_new then
        data_ok, skill_data = pcall( mw.loadData, "Module:" .. skill .. " urn/Data" )
    end
	
	if not data_ok then
		error( "Unrecognised skill: " .. skill )
	end
	
    local has_filter = src_type and src_type ~= ""
    local filtered_skill_data = {}
    if not TEMP_data_new then
        -- TEMP: handle old data structure during migration period
        for _, v in ipairs( skill_data ) do
            if not has_filter or (v.food or v.type or v.trap) == src_type then
                table.insert( filtered_skill_data, v )
            end
        end
    else
        if has_filter then
            if not skill_data[src_type] then
                local types = {}
                for k, _ in pairs( skill_data ) do
                    table.insert( types, k )
                end
                
                if #types > 0 then
                    error( 'Unrecognised XP source type. Use: "' .. table.concat( types, '", "' ) .. '".' )
                end
                error( 'Unrecognised XP source type. Skill data has no source types defined.' )
            end
            filtered_skill_data = skill_data[src_type]
        else
            if skill_data[1] then
                filtered_skill_data = skill_data
            else
                for _, src_tbl in pairs( skill_data ) do
                    for _, v in ipairs( src_tbl ) do
                        table.insert( filtered_skill_data, v )
                    end
                end
            end
        end
    end
	
	-- filter out sources beyond urn's max level
	local ret_skill_data = {}
	for _, v in ipairs( filtered_skill_data ) do
		if v.level <= urn_data[1] then
			table.insert( ret_skill_data, v )
		end
	end

	return urn_data, ret_skill_data, src_type
end

local function gen_table( urn_data, sources, src_col_txt, note_col_txt )
	local lang = mw.getContentLanguage()
	local max_xp = urn_data[2]
	local ret_table = mw.html.create( "table" )
			:addClass( "wikitable sortable sticky-header" )
			:addClass( "text-align-right align-center-1 align-left-2 align-center-3" )
			:IF( note_col_txt ):addClass( "align-left-5" ):END()

	local ret_row = ret_table:tr()
		:th{ src_col_txt, attr = { "colspan", "2" } }
		:th( "Level" )
		:th( "Experience" )
		:IF( note_col_txt )
			:th( note_col_txt )
		:END()
		:th( "% filling" )
		:th( "# to fill" )
	
	-- check if any source has decimal XP value; if so, display decimals for all (aligns better)
	local xp_has_dec = false
	for _, v in ipairs( sources ) do
		if math.floor( v.xp ) ~= v.xp then
			xp_has_dec = true
			break
		end
	end

	for _, v in ipairs( sources ) do
		local src_level = v.level
		local src_name = v.name
		--local src_link = v.link or src_name
        --TEMP: handle old data structure during migration period
		local src_link = v.id or v.link or src_name
		local src_file = v.image or src_link
		local src_xp = v.xp
		local src_note = v.note
		local filling = round( ( src_xp / max_xp ) * 100, NUM_PERC_DP, true )
		local to_fill = lang:formatNum( math.max( 1, math.ceil( max_xp / src_xp ) ) )
		if tonumber( filling ) == 0 then
			filling = "< 0." .. string.rep( "0", NUM_PERC_DP - 1 ) .. "1"
		end

		ret_table:tr()
			:node( plinkt( src_link, { pic = src_file, txt = src_name, size = "frameless|" .. MAX_IMG_SIZE } ) )
			:td( src_level )
			:td( ( xp_has_dec and round( src_xp, 1, true ) ) or lang:formatNum( src_xp ) )
			:IF( note_col_txt )
				:td( src_note )
			:END()
			:td{ filling .. "%", attr = { ["data-sort-value"] = tostring( src_xp / max_xp ) } }
			:td( to_fill )
	end

	return ret_table:allDone()
end

--
-- Fishing urns
--
function p.fishing( frame )
	local urn_data, skill_data, src_type = load_data( frame, "Fishing" )

	return gen_table( urn_data, skill_data, "Fish" )
end

--
-- Cooking urns
--
function p.cooking( frame )
	local urn_data, skill_data, src_type = load_data( frame, "Cooking" )

	return gen_table( urn_data, skill_data, "Food" )
end

--
-- Smithing urns
--
function p.smithing( frame )
	local urn_data, skill_data, src_type = load_data( frame, "Smithing" )
	 return gen_table(urn_data,skill_data,src_type)
end
--
-- Woodcutting urns
--
function p.woodcutting( frame )
	local urn_data, skill_data, src_type = load_data( frame, "Woodcutting" )

	return gen_table( urn_data, skill_data, "Logs" )
end

--
-- Divination urns
--
function p.divination( frame )
	local urn_data, skill_data, src_type = load_data( frame, "Divination" )
	
	if src_type == 'hall' then
		return gen_table( urn_data, skill_data, "Object" )
	end
	return gen_table( urn_data, skill_data, "Wisp" )
end

--
-- Hunter urns
--
function p.hunter( frame )
	local urn_data, skill_data, src_type = load_data( frame, "Hunter" )

	return gen_table( urn_data, skill_data, "Creature" )
end

--
-- Farming urns
--
function p.farming( frame )
	local urn_data, skill_data, src_type = load_data( frame, "Farming" )

	return gen_table( urn_data, skill_data, "Produce" )
end

--
-- Runecrafting urns
--
function p.runecrafting(frame)
	local urn_data, skill_data, src_type = load_data( frame, "Runecrafting" )
	
	--TODO: move this into the data module in a meta-like (p.config = {}) field
	--      then move load_data into gen_table
	--      then all of these p.SKILL funcs can just be:
	--      return gen_table( "SKILL" )
	local src_col_txt, note_col_txt
	if src_type == "runespan" then
		src_col_txt = "Creature or node"
		note_col_txt = "Rune"
	elseif src_type == "regular" then
		src_col_txt = "Runes"
		note_col_txt = "Altar"
	end

	return gen_table( urn_data, skill_data, src_col_txt, note_col_txt )
end

function p.getUrnXPReward( frame )
	local args = frame.args
	local skill = string.lower( args.skill or error( "Missing skill parameter" ) )
	local tier = string.lower( args.tier or error( "Missing urn tier parameter" ) )
	local enhancer = string.lower( args.enh or "false" ) == "true"

	if not urns[skill] then
		error( "Invalid skill: " .. skill )
	elseif not urns[skill][tier] then
		error( "Invalid urn tier: " .. tier )
	end
	
	local tier_mult
	if skill == "prayer" then
		tier_mult = 1.2
	elseif tier == "exquisite" then
		tier_mult = 0.25
	else
		tier_mult = 0.2
	end
	local enh_mult = enhancer and 1.25 or 1.0
	local xp = math.floor( urns[skill][tier][2] * tier_mult * enh_mult * 10 ) / 10

	return xp
end

function p.getUrnFillXP( frame )
	local args = frame.args
	local skill = string.lower( args.skill or error( "Missing skill parameter" ) )
	local tier = string.lower( args.tier or error( "Missing urn tier parameter" ) )
	
	if not urns[skill] then
		error( "Invalid skill: " .. skill )
	elseif not urns[skill][tier] then
		error( "Invalid urn tier: " .. tier )
	end
	
	return urns[skill][tier][2]
end

return p