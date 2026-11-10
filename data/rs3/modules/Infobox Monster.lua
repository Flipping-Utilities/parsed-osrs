--------------------------
-- Module for {{Infobox Monster}}
-- Please test changes to this module at [[Module:Infobox Monster/sandbox]] first
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local paramtest = require('Module:Paramtest')
local yesno = require('Module:Yesno')
local commas = require('Module:Addcommas')._add
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean
local attack_speed_bar = require('Module:Attack speed bar').monster

local standard_hp_to_xp_mod = 20
local slay_masters = {
	turael = { text = '[[Turael]] or [[Spria]]', chathead = 'turael chathead', category = 'Monsters assigned by Turael or Spria' },
	jacquelyn = { text = '[[Jacquelyn]]', chathead = 'jacquelyn chathead', category = 'Monsters assigned by Jacquelyn' },
	mazchna = { text = '[[Mazchna]] or [[Achtryn]]', chathead = 'mazchna chathead', category = 'Monsters assigned by Mazchna or Achtryn' },
	vannaka = { text = '[[Vannaka]]', chathead = 'vannaka chathead', category = 'Monsters assigned by Vannaka' },
	chaeldar = { text = '[[Chaeldar]]', chathead = 'chaeldar chathead', category = 'Monsters assigned by Chaeldar' },
	sumona = { text = '[[Sumona]]', chathead = 'sumona chathead', category = 'Monsters assigned by Sumona' },
	duradel = { text = '[[Duradel]] or [[Lapalok]]', chathead = 'duradel chathead', category = 'Monsters assigned by Duradel or Lapalok' },
	kuradal = { text = '[[Kuradal]]', chathead = 'kuradal chathead', category = 'Monsters assigned by Kuradal' },
	morvran = { text = '[[Morvran]]', chathead = 'morvran chathead', category = 'Monsters assigned by Morvran' },
	mandrith = { text = '[[Mandrith]]', chathead = 'Mandrith chathead', category = 'Monsters assigned by Mandrith', isMandrith = true },
	laniakea = { text = '[[Laniakea]]', chathead = 'Laniakea chathead', category = 'Monsters assigned by Laniakea' },
	raptor = { text = '[[The Raptor]]', chathead = 'The Raptor chathead', category = 'Monsters assigned by the Raptor' },
}
local slay_masters_map = {
	turael = 'Turael',
	spria = 'Turael',
	jacquelyn = 'Jacquelyn',
	mazchna = 'Mazchna',
	achtryn = 'Mazchna',
	vannaka = 'Vannaka',
	chaeldar = 'Chaeldar',
	sumona = 'Sumona',
	duradel = 'Duradel',
	lapalok = 'Duradel',
	kuradal = 'Kuradal',
	morvran = 'Morvran',
	mandrith = 'Mandrith',
	laniakea = 'Laniakea',
	raptor = 'Raptor',
	no = 'none',
	none = 'none',
	['n/a'] = 'none'
}
local slay_masters_order = { 'Turael', 'Jacquelyn', 'Raptor', 'Vannaka', 'Mazchna', 'Chaeldar', 'Sumona', 'Duradel', 'Kuradal', 'Morvran', 'Laniakea', 'Mandrith' }
local slayer_info = require('Module:Slayer assignments')
local slayer_disambig = require('Module:Slayer assignments/disambig')
local slayer_race = mw.loadData('Module:NPC races/Slayer')
local race_info = mw.loadData('Module:NPC races')
local ability_info = mw.loadData('Module:Abilities/data')
local prayer_info = mw.loadData('Module:Prayers/data')

--[[
 -- Mapping
--]]
local attack_styles = {
	melee = { image = 'Attack-icon', link = 'Melee' },
	ranged = { image = 'Ranged-icon', link = 'Ranged' },
	magic = { image = 'Magic-icon', link = 'Magic' },
	necromancy = { image = 'Necromancy-icon', link = 'Necromancy' },
	dragonfire = { image = 'Dragonfire icon', link = 'Dragonfire' },
	na = { image = 'Zero weakness icon', link = '' },
	typeless = { image = 'Zero weakness icon', link = '' }
}

local styles_map = {
	melee = 'melee',
	magic = 'magic',
	mage = 'magic',
	range = 'ranged',
	ranged = 'ranged',
	ranging = 'ranged',
	necro = 'necromancy',
	necromancy = 'necromancy',
	dragonfire = 'dragonfire',
	['dragon fire'] = 'dragonfire',
	dragonbreath = 'dragonfire',
	['dragon breath'] = 'dragonfire',
	['n/a'] = 'na',
	na = 'na',
	none = 'na'
}

local primary_styles = {
	melee = 'inquisitor',
	ranged = 'terrasaur',
	magic = 'hexhunter',
	magic_dungeoneering = 'hexhunter dungeoneering',
}

local speed_map = {
	['1'] = 1,
	['2'] = 2,
	['3'] = 3,
	['4'] = 4,
	['5'] = 5,
	['6'] = 6,
	['7'] = 7,
	['8'] = 8,
	['9'] = 9,
	['10'] = 10,
	['n/a'] = 0,
	['random'] = 'random',
	['0'] = 0
}
local bucket_speed_map = {
	['1'] = 1,
	['2'] = 2,
	['3'] = 3,
	['4'] = 4,
	['5'] = 5,
	['6'] = 6,
	['7'] = 7,
	['8'] = 8,
	['9'] = 9,
	['10'] = 10,
	['n/a'] = 0,
	['random'] = -1,
	['0'] = 0
}

-- load weaknesses instead of remapping
local weaknesses = mw.loadData('Module:Weakness clickpic/data')

-- location restriction
local restriction_map = {
	surface = 'surface',
	dungeoneering = 'dungeoneering',
	dg = 'dungeoneering',
	daemonheim = 'dungeoneering',
	quest = 'quest',
	minigame = 'minigame',
	activity = 'minigame',
	familiar = 'familiar',
	gone = 'removed',
	removed = 'removed',
	limited = 'limited'
}

local imgarg, imgback, numberargs, combatarg, numargcommas, numargraw, numargraw2,
sizearg, sizedisp, hpxparg, xparg, xpmodarg, wepxparg, boolargs, boolbucketargs, immuneargs, immunebucketargs,
poisonarg, stylearg, styleimgarg, styletxtarg, leaguesArg,
primarystylebucketarg, weaknessarg, weaknessimgarg, weaknesstxtarg,
explicitwkarg, aff_weakness_arg, aff_weakness_bucket_arg, generalweaknessarg,
wkcats, susceptarg_bucket, susceptarg, slayercatarg, slayercatdisparg,
slayercatbucketarg, slaycats, slayerarg, slayerimgarg, slayerbucketarg, racearg, racedisp,
notassarg, abilistarg, abilbucketarg, abildisparg, prayerarg, prayerbucketarg, prayerdisparg,
speedarg, speed_bucket, restrictionarg, iddisp, idbucket, optionarg, optionbucket,
make_chisel_links, badarg, dropversionparg, bucketarg, addcategories

-- Main function called with invokes
function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)
	local yn_args = {
		'aggressive',
		'in_wilderness'
	}
	local immune_args = {
		'immune_to_poison', 'immune_to_deflect',
		'immune_to_stun', 'immune_to_drain'
	}
	local num_args = {
		'slaylvl', 'slayxp',
		'attack', 'strength', 'defence', 'ranged', 'magic', 'necromancy',
		'max_melee', 'max_ranged', 'max_magic', 'max_necromancy', 'max_spec',
		'acc_melee', 'acc_ranged', 'acc_magic', 'acc_necromancy', 'armour',
		'aff_melee', 'aff_ranged', 'aff_magic', -- aff_weakness has a special func, no aff_necromancy as it does not exist
	}

	for _, v in ipairs(yn_args) do
		ret:defineParams { { name = v, func = { name = boolargs, params = { v, v }, flag = { 'p', 'r' } } } }
		ret:defineParams { { name = v .. '_bucket', func = { name = boolbucketargs, params = { v }, flag = { 'd' } } } }
	end
	for _, v in ipairs(immune_args) do
		ret:defineParams { { name = v, func = { name = immuneargs, params = { v, v }, flag = { 'p', 'r' } } } }
		ret:defineParams { { name = v .. '_bucket', func = { name = immunebucketargs, params = { v }, flag = { 'd' } } } }
	end

	for _, v in ipairs(num_args) do
		ret:defineParams {
			{ name = v, func = { name = numargcommas, params = { v, v }, flag = { 'p', 'r' } } },
			{ name = v .. '_bucket', func = { name = numargraw2, params = { v }, flag = 'd' } }
		}
	end
	-- Define parameters
	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'image', func = { name = imgarg, params = { 'image' }, flag = 'd' } },
		{ name = 'imagebackground', func = { name = imgback, params = { 'imagebackground' }, flag = { 'd' } }, dupes = true },
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'aka', func = 'has_content' },
		{ name = 'size', func = { name = sizearg, params = { 'size' }, flag = 'p' } },
		{ name = 'size_disp', func = { name = sizedisp, params = { 'size' }, flag = 'p' } },
		{ name = 'members', func = 'has_content' },
		{ name = 'examine', func = 'has_content' },
		{ name = 'leagueRegion', func = leaguesArg },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
		{ name = 'restriction', func = restrictionarg },
		{ name = 'poisonous', func = { name = poisonarg, params = { 'poisonous' }, flag = 'p' } },
		{ name = 'poisonous_bucket', func = { name = boolbucketargs, params = { 'poisonous' }, flag = 'd' } },
		{ name = 'speed', func = speedarg },
		{ name = 'speed_bucket', func = { name = speed_bucket, params = { 'speed' }, flag = 'p' } },
		{ name = 'level', func = combatarg },
		{ name = 'level_bucket', func = { name = numargraw2, params = { 'level' }, flag = 'p' } },
		{ name = 'style', func = stylearg },
		{ name = 'styleimg', func = { name = styleimgarg, params = { 'style' }, flag = 'p', dupes = true } },
		{ name = 'styletxt', func = { name = styletxtarg, params = { 'style' }, flag = 'p', dupes = true } },
		{ name = 'primarystyle_bucket', func = { name = primarystylebucketarg, params = { 'primarystyle' }, flag = 'p', dupes = true } },
		{ name = 'lifepoints', func = { name = numargcommas, params = { 'lifepoints', 'lifepoints' }, flag = { 'd', 'r' } } },
		{ name = 'lpraw', func = { name = numargraw, params = { 'lifepoints' }, flag = 'p' } },
		{ name = 'experience', func = { name = xparg, params = { 'experience', 'lifepoints' }, flag = { 'd', 'p' } } },
		{ name = 'xpraw', func = { name = numargraw2, params = { 'experience' }, flag = 'd' } },
		{ name = 'xpmod', func = { name = xpmodarg, params = { 'experience', 'lifepoints' }, flag = 'p' } },
		{ name = 'hpxp', func = { name = hpxparg, params = { 'experience' } } },
		{ name = 'wepxp2h', func = { name = numargcommas, params = { 'wepxp2h', 'wepxp2h' }, flag = { 'd', 'r' } } },
		{ name = 'wepxpmhandarmour', func = { name = numargcommas, params = { 'wepxpmhandarmour', 'wepxpmhandarmour' }, flag = { 'd', 'r' } } },
		{ name = 'wepxpoh', func = { name = numargcommas, params = { 'wepxpoh', 'wepxpoh' }, flag = { 'd', 'r' } } },
		{ name = 'wepxp', func = { name = wepxparg, params = { 'experience', 'wepxp2h', 'wepxpmhandarmour', 'wepxpoh' } } },
		{ name = 'weakness', func = weaknessarg },
		{ name = 'generalweakness', func = { name = generalweaknessarg, params = { 'aff_melee', 'aff_ranged', 'aff_magic' } } },
		{ name = 'weaknessimg', func = { name = weaknessimgarg, params = { 'weakness' }, flag = 'p', dupes = true } },
		{ name = 'weaknesstxt', func = { name = weaknesstxtarg, params = { 'weakness' }, flag = 'p', dupes = true } },
		{ name = 'explicit_weakness', func = { name = explicitwkarg, params = { 'weakness' }, flag = 'p' } },
		{ name = 'aff_weakness', func = { name = aff_weakness_arg, params = { 'aff_weakness', 'aff_weakness', 'weakness' }, flag = { 'p', 'r', 'p' } } },
		{ name = 'aff_weakness_bucket', func = { name = aff_weakness_bucket_arg, params = { 'aff_weakness', }, flag = { 'd' } } },
		{ name = 'susceptibility_bucket', func = { name = susceptarg_bucket, params = { 'susceptibility', 'weakness', 'primarystyle', 'derived_susceptibility', 'restriction' }, flag = { 'p', 'p', 'p', 'p', 'd' } } },
		{ name = 'susceptibility', func = { name = susceptarg, params = { 'susceptibility_bucket' }, flag = 'd' } },
		{ name = 'abilities', func = abilistarg },
		{ name = 'abilities_disp', func = { name = abildisparg, params = { 'abilities' }, flag = 'd' } },
		{ name = 'abilities_bucket', func = { name = abilbucketarg, params = { 'abilities' }, flag = 'd' } },
		{ name = 'prayers', func = prayerarg },
		{ name = 'prayers_disp', func = { name = prayerdisparg, params = { 'prayers' }, flag = 'd' } },
		{ name = 'prayers_bucket', func = { name = prayerbucketarg, params = { 'prayers' }, flag = 'd' } },
		{ name = 'slayercat', func = slayercatarg },
		{ name = 'slayercat_disp', func = { name = slayercatdisparg, params = { 'slayercat' }, flag = 'd' } },
		{ name = 'slayercat_bucket', func = { name = slayercatbucketarg, params = { 'slayercat' }, flag = 'd' } },
		{ name = 'race', func = { name = racearg, params = { 'race', 'slayercat' }, flag = { 'p', 'd' } } },
		{ name = 'race_disp', func = { name = racedisp, params = { 'race' }, flag = { 'd' } } },
		{ name = 'assigned_by_raw', func = { name = slayerarg, params = { 'slayercat', 'assigned_by_override', 'assigned_by', 'in_wilderness_bucket' }, flag = 'd' } },
		{ name = 'assigned_by_img', func = { name = slayerimgarg, params = { 'assigned_by_raw' }, flag = 'd', dupes = true } },
		{ name = 'assigned_by_bucket', func = { name = slayerbucketarg, params = { 'assigned_by_raw' }, flag = 'd' } },
		{ name = 'not_assigned', func = { name = notassarg, params = { 'assigned_by_raw' }, flag = 'd' } },
		{ name = 'gender', func = 'has_content' },
		{ name = 'options', func = { name = optionarg, params = { 'options', 'actions' }, flag = 'd' } },
		{ name = 'options_bucket', func = { name = optionbucket, params = { 'options', 'actions' }, flag = 'p' }, dupes = true },
		{ name = 'voice', func = 'has_content' },
		{ name = 'thievelvl', func = { name = numberargs, params = { 'thievelvl', 'thievelvl' }, flag = { 'p', 'r' } } },
		{ name = 'thievelvl_bucket', func = { name = numargraw2, params = { 'thievelvl' }, flag = 'p' } },
		{ name = 'vanchor', func = { name = 'has_content', params = { 'version' }, flag = 'p' } },

		-- not used; only for categories
		{ name = 'id', func = iddisp },
		{ name = 'id_bucket', func = { name = idbucket, params = { 'id' }, flag = 'p' } },
		{ name = 'chisel_links', func = { name = make_chisel_links, params = { 'id_bucket', 'name' }, flag = 'd' } },
		{ name = 'rscid', func = 'numbers' },
		{ name = 'dropversion', func = { name = dropversionparg, params = { 'dropversion', 'version' }, flag = 'd' } },
		{ name = 'dropversion_bucket', func = { name = dropversionbucketparg, params = { 'name', 'dropversion', 'version' }, flag = 'd' } },
		{ name = 'bucketarg', func = { name = bucketarg, params = { 'id_bucket', 'name', 'vanchor', 'level_bucket', 'size', 'examine', 'leagueRegion_raw', 'xpraw', 'thievelvl_bucket', 'members',
			'options_bucket', 'styleimg', 'styletxt', 'primarystyle_bucket', 'lpraw', 'weaknessimg', 'weaknesstxt', 'generalweakness',
			'susceptibility_bucket', 'slayercat_bucket', 'slaylvl_bucket', 'slayxp_bucket', 'assigned_by_bucket', 'restriction',
			'attack_bucket', 'magic_bucket', 'ranged_bucket', 'defence_bucket', 'max_melee_bucket', 'max_magic_bucket', 'max_ranged_bucket',
			'max_spec_bucket', 'acc_melee_bucket', 'acc_magic_bucket', 'acc_ranged_bucket', 'armour_bucket', 'aff_melee_bucket',
			'aff_magic_bucket', 'aff_ranged_bucket', 'aff_weakness_bucket', 'aggressive_bucket', 'poisonous_bucket',
			'immune_to_poison_bucket', 'immune_to_deflect_bucket', 'immune_to_stun_bucket', 'immune_to_drain_bucket', 'speed_bucket',
			'abilities_bucket', 'prayers_bucket', 'dropversion_bucket'}, flag = 'd', dupes = true } }
	}

	ret:useBucket('infobox_monster', {
		id_bucket = 'id',
		name = 'name',
		vanchor = 'version_anchor',
		level_bucket = 'combat_level',
		size = 'size',
		examine = 'examine',
		leagueRegion_raw = 'league_region',
		xpraw = 'combat_experience',
		thievelvl_bucket = 'thieving_level',
		members = 'is_members_only',
		options_bucket = 'options',
		styleimg = 'attack_style',
		styletxt = 'attack_style_text',
		primarystyle_bucket = 'primary_attack_style',
		lpraw = 'life_points',
		weaknessimg = 'weakness',
		weaknesstxt = 'weakness_text',
		generalweakness = 'weakness_by_class',
		susceptibility_bucket = 'susceptible_to',
		slayercat_bucket = 'slayer_category',
		slaylvl_bucket = 'slayer_level',
		slayxp_bucket = 'slayer_experience',
		assigned_by_bucket = 'assigned_by',
		restriction = 'location_restriction',
		attack_bucket = 'attack_level',
		magic_bucket = 'magic_level',
		ranged_bucket = 'ranged_level',
		defence_bucket = 'defence_level',
		max_melee_bucket = 'melee_max_hit',
		max_magic_bucket = 'magic_max_hit',
		max_ranged_bucket = 'ranged_max_hit',
		max_spec_bucket = 'special_max_hit',
		acc_melee_bucket = 'melee_accuracy',
		acc_magic_bucket = 'magic_accuracy',
		acc_ranged_bucket = 'ranged_accuracy',
		armour_bucket = 'armour',
		aff_melee_bucket = 'melee_affinity',
		aff_magic_bucket = 'magic_affinity',
		aff_ranged_bucket = 'ranged_affinity',
		aff_weakness_bucket = 'weakness_affinity',
		aggressive_bucket = 'is_aggressive',
		poisonous_bucket = 'is_poisonous',
		immune_to_poison_bucket = 'susceptible_to_poison',
		immune_to_deflect_bucket = 'susceptible_to_deflect',
		immune_to_stun_bucket = 'susceptible_to_stun',
		immune_to_drain_bucket = 'susceptible_to_drain',
		speed_bucket = 'attack_rate',
		abilities_bucket = 'uses_ability',
		prayers_bucket = 'uses_prayer',
        dropversion_bucket = 'dropversion',
		bucketarg = 'json',
	})

	ret:useBucket('npc_id', {
		id_bucket = 'id'
	})

	ret:linkParams {
		image = 'imagebackground'
	}
	ret:defineLinks({
		links = {
			{ 'Template:Infobox Monster', '[view]' },
			{ 'Template talk:Infobox Monster', '[talk]' }
		}
	})
	ret:customButtonPlacement(true)
	ret:create()
	ret:cleanParams()
	ret:addButtonsCaption()
	ret:defineName('Infobox Monster')
	ret:addClass('infobox-monster')
	-- Slayer information
	-- dynamic size, dependent on whether or not the monster is assigned
	local slayer_level = ret:paramDefined('slaylvl', 'all')
	local not_assigned = ret:param('not_assigned', 'f')
	local _not_assigned = true
	if not_assigned.d == false then
		_not_assigned = false
	elseif not_assigned.switches then
		for _, v in ipairs(not_assigned.switches) do
			if v == false then
				_not_assigned = false
				break
			end
		end
	end
	-- PARAMETER: name
	ret:addRow {
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '60' }
	}
		:pad(60)
	-- PARAMETER: image
	ret:addRow {
		{ tag = 'argd', content = 'image', class = 'infobox-image infobox-full-width-content', colspan = '60' },
		meta = { addClass = ret:param('imagebackground', 'r') }
	}
		:pad(60)
	-- PARAMETER: release
	-- (update included automatically by infobox)
	ret:addRow { { tag = 'th', content = 'Release', colspan = '20' },
		{ tag = 'argd', content = 'release', css = { ['text-align'] = 'left' }, colspan = '40' } }
	-- PARAMETER: removal
	if ret:paramDefined('removal') then
		ret:addRow { { tag = 'th', content = 'Removal', colspan = '20' },
			{ tag = 'argd', content = 'removal', css = { ['text-align'] = 'left' }, colspan = '40' } }
	end
	-- PARAMETER: aka
	-- add only if it exists
	if ret:paramDefined('aka') then
		ret:addRow { { tag = 'th', content = 'AKA', colspan = '20' },
			{ tag = 'argd', content = 'aka', css = { ['text-align'] = 'left', ['max-width'] = '100px' }, colspan = '40' } }
	end
	-- PARAMETER: members
	ret:addRow { { tag = 'th', content = '[[Members]]', colspan = '20' },
		{ tag = 'argd', content = 'members', css = { ['text-align'] = 'left' }, colspan = '40' } }
	-- PARAMETER: gender
	-- add only if it exists
	local gender = ret:param('gender', 'f')
	local _gender = false
	if infobox.isDefined(gender.d) and gender.d ~= 'None' then
		_gender = true
	end
	if not _gender and gender.switches then
		for _, v in ipairs(gender.switches) do
			if v ~= nil then
				_gender = true
				break
			end
		end
	end
	if _gender then
		ret:addRow { { tag = 'th', content = '[[Gender]]', colspan = '20' },
			{ tag = 'argd', content = 'gender', css = { ['text-align'] = 'left' }, colspan = '40' } }
	end
	-- PARAMETER: options
	ret:addRow { { tag = 'th', content = '[[Choose Option|Options]]', colspan = '20' },
		{ tag = 'argd', content = 'options', css = { ['text-align'] = 'left' }, colspan = '40' } }
	-- PARAMETER: race
	ret:addRow { { tag = 'th', content = '[[List of races|Race]]', colspan = '20' },
		{ tag = 'argd', content = 'race_disp', css = { ['text-align'] = 'left' }, colspan = '40' } }
	-- PARAMETER: size
	if ret:paramDefined('size', 'all') then
		ret:addRow {
			{ tag = 'th', content = '[[Game square|Size]]', colspan = '20' },
			{ tag = 'argd', content = 'size_disp', css = { ['text-align'] = 'left' }, colspan = '40' }
		}
	end
	-- PARAMETER: examine
	ret:addRow { 
		{ tag = 'th', content = '[[Examine]]', colspan = '20' },
		{ tag = 'argd', content = 'examine', css = { ['text-align'] = 'left' }, colspan = '40' } }
	
	-- PARAMETER: leagueRegion
	if ret:paramDefined('leagueRegion', 'all') then
		local leagues = require('Module:LeagueRegion')
		ret:addRow{
			{ tag = 'th', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] region', css = { ['vertical-align'] = 'middle' },  colspan = '20' },
			{ tag = 'argd', content = 'leagueRegion', css = {['text-align'] = 'left', ['vertical-align'] = 'middle' }, colspan = '40' },
			meta = {addClass = 'leagues-global-flag'}
		}
	end

	-- COMBAT INFO
	ret:pad(60)
		:addRow { { tag = 'th', content = 'Combat info', colspan = '60', class = 'infobox-subheader' } }
		:pad(60)
		:addRow { { tag = 'th', content = '[[Combat level]]', colspan = '20' },
			{ tag = 'argd', content = 'level', css = { ['text-align'] = 'left' }, colspan = '40' } }
		:addRow { { tag = 'th', content = '[[Life points]]', colspan = '20' },
			{ tag = 'argd', content = 'lifepoints', css = { ['text-align'] = 'left' }, colspan = '40' } }
		:addRow { { tag = 'th', content = '[[Aggressiveness|Aggressive]]', colspan = '20' },
			{ tag = 'argd', content = 'aggressive', css = { ['text-align'] = 'left' }, colspan = '40' } }
		:addRow { { tag = 'th', content = '[[Poison|Poisonous]]', colspan = '20' },
			{ tag = 'argd', content = 'poisonous', css = { ['text-align'] = 'left' }, colspan = '40' } }
	-- COMBAT INFO
		:pad(60)
		:addRow { { tag = 'th', content = 'Combat experience', colspan = '60', class = 'combat-info-header infobox-subheader' } }
		:pad(60)
	-- PARAKATER: "Number of kills" - MediaWiki:Gadget-killCalc.js contains the JS element that varies the combat XP based on the input
	-- PARAMETER: level | lifepoints | experience | hpxp
		:addRow { { tag = 'th', content = '[[File:Multicombat.png|link=|20px]] XP', colspan = '20' },
			{ tag = 'argd', class = 'mob-cb-xp', css = { ['text-align'] = 'left' }, content = 'experience', colspan = '40' } }
	if _not_assigned == false or slayer_level == true then
		ret:addRow { { tag = 'th', content = '[[File:Slayer-icon.png|link=|20px]] XP', colspan = '20' },
			{ tag = 'argd', class = 'mob-slay-xp', css = { ['text-align'] = 'left' }, content = 'slayxp', colspan = '40' } }
	end
	ret:addRow { { tag = 'th', content = '[[File:Constitution-icon.png|link=|20px]] XP', colspan = '20' },
		{ tag = 'argd', class = 'mob-hp-xp', css = { ['text-align'] = 'left' }, content = 'hpxp', colspan = '40' } }
		:addRow { { tag = 'th', content = '[[File:Invention-icon.png|link=|20px]] [[Equipment level#Equipment experience|XP]]', colspan = '20' },
			{ tag = 'argd', class = 'mob-eq-xp', css = { ['text-align'] = 'left' }, content = 'wepxp', colspan = '40' } }
	if _not_assigned == false or slayer_level == true then
		ret:pad(60)
			:addRow { {
				tag = 'th',
				content = 'Slayer info',
				colspan = '60',
				class = { "infobox-subheader", "slayer-header" },
			} }
			:pad(60)
			:addRow { { tag = 'th', content = '[[File:Slayer-icon.png|link=|20px]] Level', colspan = '20' },
				{ tag = 'argd', content = 'slaylvl', css = { ['text-align'] = 'left' }, colspan = '40' } }
			:addRow { { tag = 'th', content = '[[Slayer assignment|Assignment]]', colspan = '20' },
				{ tag = 'argd', content = 'slayercat_disp', css = { ['text-align'] = 'left' }, colspan = '40' } }
			:addRow { { tag = 'th', content = 'Master', colspan = '20' },
				{ tag = 'argd', content = 'assigned_by_img', css = { ['text-align'] = 'left' }, colspan = '40' } }
	end

	----------------
	-- OFFENSIVE STATS
	local max_disc = 'This value is the standard, non-legacy value. The number reflects the BASE maximum hit used by the monster in damage calculations. Damage-boosting mechanics such as enrage are not taken into consideration.'
	ret:pad(60)
		:addRow { { tag = 'th', content = 'Offensive', class = { 'infobox-subheader', 'offensive-header' }, colspan = '60' } }

		:addRow { { tag = 'th', content = '[[Maximum hit|Max hit]]', class = { 'infobox-subheader', 'offensive-subheader' }, colspan = '60' } }
	-- PARAMETER: max_melee | max_ranged | max_magic | max_necromancy | max_spec
		:addRow { { tag = 'td', content = '[[File:Attack-icon.png|20px|link=]]', title = 'Maximum standard melee hit', colspan = '12' },
			{ tag = 'td', content = '[[File:Ranged-icon.png|20px|link=]]', title = 'Maximum standard ranged hit', colspan = '12' },
			{ tag = 'td', content = '[[File:Magic-icon.png|20px|link=]]', title = 'Maximum standard magic hit', colspan = '12' },
			{ tag = 'td', content = '[[File:Necromancy-icon.png|20px|link=]]', title = 'Maximum standard necromancy hit', colspan = '12' },
			{ tag = 'td', content = '[[File:Weapon Special Attack.png|20px|link=]]', title = 'Maximum typeless/special hit', colspan = '12' } }
		:addRow { { tag = 'argd', content = 'max_melee', title = max_disc, colspan = '12' },
			{ tag = 'argd', content = 'max_ranged', title = max_disc, colspan = '12' },
			{ tag = 'argd', content = 'max_magic', title = max_disc, colspan = '12' },
			{ tag = 'argd', content = 'max_necromancy', title = max_disc, colspan = '12' },
			{ tag = 'argd', content = 'max_spec', title = max_disc, colspan = '12' } }

	-- PARAMETER: style | rate (formely speed)
		:addRow { { tag = 'th', content = 'Style', class = { 'infobox-subheader', 'offensive-subheader' }, colspan = '30' },
			{ tag = 'th', content = '[[Attack rate|Rate]]', class = { 'infobox-subheader', 'offensive-subheader' }, colspan = '30' } }

		:addRow { { tag = 'argd', content = 'style', colspan = '30' },
			{ tag = 'argd', content = 'speed', colspan = '30' } }

		:addRow { { tag = 'th', content = 'Combat levels', class = { 'infobox-subheader', 'offensive-subheader' }, colspan = '60' } }

	-- Accuracy parameters
	local levels_disc = "This is the monster's level in this combat skill. It functions in the same way a player's does - it affects the accuracy or armour in the same way (but not damage)."

	-- PARAMETER: attack | ranged | magic | necromancy
	ret:addRow {
		{ tag = 'td', content = '[[File:Attack-icon.png|20px|link=]]', title = 'Attack level', colspan = '15' },
		{ tag = 'td', content = '[[File:Ranged-icon.png|20px|link=]]', title = 'Ranged level', colspan = '15' },
		{ tag = 'td', content = '[[File:Magic-icon.png|20px|link=]]', title = 'Magic level', colspan = '15' },
		{ tag = 'td', content = '[[File:Necromancy-icon.png|20px|link=]]', title = 'Necromancy level', colspan = '15' }
	}

		:addRow {
			{ tag = 'argd', content = 'attack', title = levels_disc, colspan = '15' },
			{ tag = 'argd', content = 'ranged', title = levels_disc, colspan = '15' },
			{ tag = 'argd', content = 'magic', title = levels_disc, colspan = '15' },
			{ tag = 'argd', content = 'necromancy', title = levels_disc, colspan = '15' }
		}

	-- PARAMETER: acc_melee | acc_ranged | acc_magic | acc_necromancy
		:addRow {
			{ tag = 'th', content = '[[Hit chance|Accuracy]]', class = { 'infobox-subheader', 'offensive-subheader' }, colspan = '60' }
		}

		:addRow {
			{ tag = 'td', content = '[[File:Attack-icon.png|20px|link=]]', title = 'Melee accuracy as a function of 2.5 * f(x)', colspan = '15' },
			{ tag = 'td', content = '[[File:Ranged-icon.png|20px|link=]]', title = 'Ranged accuracy as a function of 2.5 * f(x)', colspan = '15' },
			{ tag = 'td', content = '[[File:Magic-icon.png|20px|link=]]', title = 'Magic accuracy as a function of 2.5 * f(x)', colspan = '15' },
			{ tag = 'td', content = '[[File:Necromancy-icon.png|20px|link=]]', title = 'Necromancy accuracy as a function of 2.5 * f(x)', colspan = '15' }
		}

		:addRow {
			{ tag = 'argd', content = 'acc_melee', colspan = '15' },
			{ tag = 'argd', content = 'acc_ranged', colspan = '15' },
			{ tag = 'argd', content = 'acc_magic', colspan = '15' },
			{ tag = 'argd', content = 'acc_necromancy', colspan = '15' }
		}

	-- PARAMETER: abilities
	-- only add if they exist
	local abilities = ret:param('abilities_disp', 'f')
	local _abilities = false
	if infobox.isDefined(abilities.d) and abilities.d ~= 'None' then
		_abilities = true
	end
	if not _abilities and abilities.switches then
		for _, v in ipairs(abilities.switches) do
			if v ~= nil then
				_abilities = true
				break
			end
		end
	end
	if _abilities then
		ret:addRow { { tag = 'th', content = 'Abilities used', class = { 'infobox-subheader', 'offensive-subheader' }, colspan = '60' } }
			:addRow { { tag = 'argd', content = 'abilities_disp', colspan = '60' } }
	end

	-- PARAMETER: prayers
	-- only add if they exist
	local prayers = ret:param('prayers_disp', 'f')
	local _prayers = false
	if infobox.isDefined(prayers.d) and prayers.d ~= 'None' then
		_prayers = true
	end
	if not _prayers and prayers.switches then
		for _, v in ipairs(prayers.switches) do
			if v ~= nil then
				_prayers = true
				break
			end
		end
	end
	if _prayers then
		ret:addRow { { tag = 'th', content = 'Prayers used', class = { 'infobox-subheader', 'offensive-subheader' }, colspan = '60' } }
			:addRow { { tag = 'argd', content = 'prayers_disp', colspan = '60' } }
	end
	-- DEFENSIVE STATS
	ret:addRow { { tag = 'th', content = 'Defensive', class = { 'infobox-subheader', 'defensive-header' }, colspan = '60' } }
	-- PARAMETER: armour | defence | weakness
		:addRow { { tag = 'th', content = 'Armour', class = { 'infobox-subheader', 'defensive-subheader' }, css = { ['padding-left'] = '0', ['padding-right'] = '0' }, colspan = '10' },
			{ tag = 'th', content = '[[File:Defence-icon.png|link=]]', class = { 'infobox-subheader', 'defensive-subheader' }, title = 'Defence level', colspan = '10' },
			{ tag = 'th', content = '[[Weakness]]', class = { 'infobox-subheader', 'defensive-subheader' }, colspan = '15' },
			{ tag = 'th', content = '[[Susceptibility|Susceptible]]', class = { 'infobox-subheader', 'defensive-subheader' }, colspan = '25' } }
		:addRow { { tag = 'argd', content = 'armour', colspan = '10' },
			{ tag = 'argd', content = 'defence', title = levels_disc, colspan = '10' },
			{ tag = 'argd', content = 'weakness', colspan = '15' },
			{ tag = 'argd', content = 'susceptibility', colspan = '25', class = "infobox-monster-susceptibility-cell" } }

	-- PARAMETER: explicit_weakness
	-- PARAMETER: aff_weakness | aff_melee | aff_ranged | aff_magic
		:addRow { { tag = 'th', content = '[[Affinity|Base hit chance]]', class = { 'infobox-subheader', 'defensive-subheader' }, colspan = '60' } }
		:addRow { { tag = 'argd', content = 'explicit_weakness', title = 'Affinity value of the monster\'s explicit weakness', colspan = '15' },
			{ tag = 'td', content = '[[File:Attack-icon.png|20px|link=]]', title = 'Affinity value of the monster against melee attacks', colspan = '15' },
			{ tag = 'td', content = '[[File:Ranged-icon.png|20px|link=]]', title = 'Affinity value of the monster against ranged attacks', colspan = '15' },
			{ tag = 'td', content = '[[File:Magic-icon.png|20px|link=]]', title = 'Affinity value of the monster against magic attacks', colspan = '15' } }
		:addRow { { tag = 'argd', content = 'aff_weakness', colspan = '15' },
			{ tag = 'argd', content = 'aff_melee', colspan = '15' },
			{ tag = 'argd', content = 'aff_ranged', colspan = '15' },
			{ tag = 'argd', content = 'aff_magic', colspan = '15' } }

	-- PARAMETER: immune_to_poison | immune_to_deflect | immune_to_stun | immune_to_drain
		:addRow { { tag = 'th', content = 'Immunities', class = { 'infobox-subheader', 'defensive-subheader' }, colspan = '60' } }
		:addRow { { tag = 'td', content = '[[File:Poison immunity icon.png|27x27px|frameless|link=]]', title = 'Immune to poison?', colspan = '15' },
			{ tag = 'td', content = '[[File:Deflect immunity icon.png|27x27px|frameless|link=]]', title = 'Immune to deflect?', colspan = '15' },
			{ tag = 'td', content = '[[File:Stun immunity icon.png|27x27px|frameless|link=]]', title = 'Immune to stun?', colspan = '15' },
			{ tag = 'td', content = '[[File:Drain immunity icon.png|27x27px|frameless|link=]]', title = "Immune to stat drain?", colspan = '15' } }
		:addRow { meta = { addClass = 'infobox-monster-immunites-row' },
			{ tag = 'argd', content = 'immune_to_poison', colspan = '15' },
			{ tag = 'argd', content = 'immune_to_deflect', colspan = '15' },
			{ tag = 'argd', content = 'immune_to_stun', colspan = '15' },
			{ tag = 'argd', content = 'immune_to_drain', colspan = '15' } }

	-- advanced data
	ret:addRow {
		{ tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '60' },
		meta = { addClass = 'advanced-data' }
	}
		:pad(60, 'advanced-data')
		:addRow {
			{ tag = 'th', content = 'NPC ID', colspan = '15' },
			{ tag = 'argd', content = 'id', css = { ['text-align'] = 'left' }, colspan = '45' },
			meta = { addClass = 'advanced-data' }
		}
		:addRow {
			{ tag = 'th', content = 'Links', colspan = '15' },
			{ tag = 'argd', content = 'chisel_links', css = { ['text-align'] = 'left' }, colspan = '45' },
			meta = { addClass = 'advanced-data' }
		}
		:pad(60, 'advanced-data')

	ret:addDropLevelVars('combat', 'level_bucket')
	ret:addDropLevelVars('slayer', 'slaylvl_bucket')
	ret:addVersionBasedVars('LeagueRegion', 'dropversion', 'leagueRegion_raw')

	-- For infobox hit calc
	--ret:addRow{ { tag = 'th', content = 'Hit calculator', class = 'rsw-ihc-header infobox-header', colspan = '60' } }
	--	:addRow{ meta = { addClass = 'infobox-hitcalc' },
	--		{ tag = 'td', content = 'JavaScript is required for the hit calculator to function!', colspan = '60' } }

	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	else
		ret.suppressAllBucket = true
	end
	ret:finish()

	return ret:tostring()
end

-- For clean images
function imgarg(arg)
	if infobox.isDefined(arg) then
		return cleanimg { file = arg, width = 300, height = 300 }
	end
	return nil
end

function imgback(arg)
	if infobox.isDefined(arg) then
		if yesno(arg) then
			return 'infobox-imgbg'
		end
	end
	return ''
end

-- For numerical args
function numberargs(arg, arg_name)
	local arg_v = (arg or ''):find('%S') and string.gsub(arg, ',', '') or -1
	local arg_i
	if arg_v == -1 then
		arg_i = nil
	elseif string.lower(arg_v) == 'n/a' then
		arg_i = 'N/A'
	elseif string.lower(arg_v) == 'varies' then
		arg_i = 'Varies'
	else
		arg_i = tonumber(arg_v:gsub(',', ''), 10)
		if not arg_i then
			arg_i = badarg(arg_name, 'should be a single numerical value.')
		end
	end
	return arg_i
end

-- For combat level
function combatarg(arg)
	local arg_v = (arg or ''):find('%S') and string.gsub(arg, ',', '') or -1
	local arg_i
	if arg_v == -1 then
		arg_i = nil
	elseif string.lower(arg_v) == 'n/a' or tonumber(arg_v) == 0 then
		arg_i = 'N/A'
	else
		arg_i = tonumber(arg_v:gsub(',', ''), 10)
		if not arg_i then
			arg_i = badarg('level', 'should be a single numerical value.')
		else
			arg_i = commas(arg_i)
		end
	end
	return arg_i
end

-- For numbers (adds commas)
function numargcommas(arg, arg_name)
	local ret = numberargs(arg, arg_name)
	if type(ret) == 'number' then
		return commas(ret)
	else
		return ret
	end
end

-- For numbers
function numargraw(arg)
	if not arg then return 0 end
	if type(arg) ~= 'number' then
		arg = tostring(arg)
		arg = arg:gsub(',', '')
	end
	return tonumber(arg) or 0
end

function numargraw2(arg)
	if not arg then return nil end
	if type(arg) ~= 'number' then
		arg = tostring(arg)
		arg = arg:gsub(',', '')
	end
	return tonumber(arg)
end

-- For hp xp
function hpxparg(arg)
	local xp = string.gsub(arg or '', ',', '')
	if string.lower(xp) == 'n/a' then
		return 'N/A'
	end
	local xp_num = tonumber(xp)
	if type(xp_num) == 'number' then
		return commas(math.floor(xp_num * 3.3) / 10)
	else
		return nil
	end
end

function xparg(experience, lifepoints)
	local xp = numberargs(experience, 'experience')

	if xp == nil then
		local lp = string.lower(string.gsub(lifepoints or '', ',', ''))
		if lp ~= 'n/a' and lp ~= 'Varies' then
			local lp_num = tonumber(lp)
			if type(lp_num) == 'number' then
				return commas(math.floor(10 * lp_num / standard_hp_to_xp_mod) / 10)
			end
		end

		return nil
	elseif type(xp) == 'number' then
		return commas(xp)
	else
		return xp
	end
end

function xpmodarg(experience, lifepoints)
	local xp = string.lower(string.gsub(experience or '', ',', ''))
	local lp = string.lower(string.gsub(lifepoints or '', ',', ''))

	if xp == 'n/a' or xp == 'Varies' or lp == 'n/a' or lp == 'Varies' then
		return 0
	elseif not xp or not tonumber(xp) or not lp or not tonumber(lp) then
		return -1
	end

	return tonumber(lp) / tonumber(xp)
end

-- weapon xp
function wepxparg(combatxp, wepxp2h, wepxpmhandarmour)
	local xp = string.gsub(combatxp or '', ',', '')
	local xp2h = string.gsub(wepxp2h or '', ',', '')
	local xpmh = string.gsub(wepxpmhandarmour or '', ',', '')

	if string.lower(xp) == 'n/a' then
		return 'N/A'
	else
		xp = tonumber(xp)
	end

	if string.lower(xp2h) ~= '' then
		xp2h = tonumber(xp2h)
	end

	if string.lower(xpmh) ~= '' then
		xpmh = tonumber(xpmh)
	end

	if type(xp) == 'number' then
		local th, mh

		if type(xp2h) == 'number' then
			th = xp2h
		else
			th = math.floor(xp * .09)
		end

		if type(xpmh) == 'number' then
			mh = xpmh
		else
			mh = math.floor(xp * .045)
		end

		return string.format('%s (two-handed)<br>%s (one-handed and armour)', commas(th), commas(mh))
	else
		return nil
	end
end

-- For true/false
function boolargs(arg, argr)
	local arg_v = (arg or ''):find('%S') and arg or -1
	local arg_ret

	if arg_v == -1 then
		arg_ret = nil
	else
		arg_v = yesno(arg_v)
		local argf = '<span title="This monster is%s %s.">%s</span>'
		local f1, f3
		local f2 = string.gsub(argr, '_', ' ')

		if arg_v then
			f1 = ''
			f3 = '[[File:Yes check.svg|20px|alt=Yes|link=]]'
		else
			f1 = ' not'
			f3 = '[[File:X mark.svg|20px|alt=No|link=]]'
		end

		arg_ret = string.format(argf, f1, f2, f3)
	end

	return arg_ret
end

function boolbucketargs(arg)
	if infobox.isDefined(arg) then
		arg = string.lower(arg)
		if arg:find('yes check') then
			return 'true'
		elseif arg:find('x mark') then
			return 'false'
		end
	end
	return nil
end

function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end

function immuneargs(arg, argr)
	local arg_v = (arg or ''):find('%S') and arg or -1

	local arg_ret

	if arg_v == -1 then
		arg_ret = nil
	else
		arg_v = yesno(arg_v)
		local argf = '<span class="infobox-monster-%s infobox-monster-%s monster-%s-%s" title="This monster is%s %s.">%s</span>'
		local f1, f3, f4
		local f2 = string.gsub(argr, '_', ' ')
		local f5 = string.gsub(argr, 'immune_to_', '')

		if arg_v then
			f1 = ''
			f3 = 'Immune'
			f4 = 'immune'
		else
			f1 = ' not'
			f3 = 'Not immune'
			f4 = 'susceptible'
		end

		arg_ret = string.format(argf, f4, f5, f5, f4, f1, f2, f3)
	end

	return arg_ret
end

function immunebucketargs(arg)
	if infobox.isDefined(arg) then
		arg = string.lower(arg)
		if arg:find('is not immune') then
			return 'true'
		elseif arg:find('is immune') then
			return 'false'
		end
	end
	return nil
end

-- Poison
function poisonarg(arg)
	arg = string.gsub(arg or '', ',', '')
	arg = string.lower(arg)

	if arg == 'yes' then
		arg = '<span title="This monster is poisonous but has no base value defined. Change the |poisonous parameter to a number.">[[File:Yes check.svg|20px|alt=Yes|link=]] ???</span>'
	elseif tonumber(arg) then
		arg = '<span title="This monster is poisonous. The number shown is the base value at which poison damage starts.">[[File:Yes check.svg|20px|alt=Yes|link=]] ' .. tonumber(arg) .. '</span>'
	else
		arg = '<span title="This monster is not poisonous.">[[File:X mark.svg|20px|alt=No|link=]]</span>'
	end

	return arg
end

-- style
function stylearg(arg)
	-- split by commas
	local atts = mw.text.split(string.lower(arg or ''), '%s*,%s*')
	local _atts = {}
	-- remake the list as a table, remove anything that's blank/doesn't exist
	for _, v in ipairs(atts) do
		local att_x = styles_map[v]
		if att_x then
			table.insert(_atts, attack_styles[att_x])
		end
	end
	local p_att
	if #_atts == 0 then
		p_att = nil
	else
		p_att = {}
		for _, v in ipairs(_atts) do
			table.insert(p_att, string.format('[[File:%s.png|25px|link=%s]]', v.image, v.link))
		end
		p_att = table.concat(p_att, ' ')
	end
	return p_att
end

function styleimgarg(arg)
	-- split by commas
	local atts = mw.text.split(string.lower(arg or ''), '%s*,%s*')
	local _atts = {}
	-- remake the list as a table, remove anything that's blank/doesn't exist
	for _, v in ipairs(atts) do
		local att_x = styles_map[v]
		if att_x then
			table.insert(_atts, attack_styles[att_x])
		end
	end
	local p_att = {}
	if #_atts > 0 then
		for _, v in ipairs(_atts) do
			table.insert(p_att, string.format('File:%s.png', v.image))
		end
	end
	return table.concat(p_att, infobox.splitpoint)
end

function styletxtarg(arg)
	-- split by commas
	local atts = mw.text.split(string.lower(arg or ''), '%s*,%s*')
	local _atts = {}
	-- remake the list as a table, remove anything that's blank/doesn't exist
	for _, v in ipairs(atts) do
		local att_x = styles_map[v]
		if att_x then
			table.insert(_atts, att_x)
		end
	end
	return table.concat(_atts, infobox.splitpoint)
end

function primarystylebucketarg(ps)
	if infobox.isDefined(ps) then
		ps = mw.text.trim(ps:lower())
	end
	if primary_styles[ps] or ps == 'necromancy' then
		return ps
	end
	return nil
end

-- weakness
function weaknessarg(arg)
	-- split by commas
	local wk = mw.text.split(string.lower(arg or ''), '%s*,%s*')
	local _wk = {}

	-- remake the list as a table, remove anything that's blank/doesn't exist
	for _, v in ipairs(wk) do
		local wk_x = weaknesses[v]
		if wk_x and not wk_x._suscept then
			table.insert(_wk, wk_x)
		end
	end
	local p_wk
	if #_wk == 0 then
		p_wk = nil
	else
		p_wk = {}
		for _, v in ipairs(_wk) do
			table.insert(p_wk, string.format('[[File:%s|25px|link=%s]]', v.image, v.link))
		end
		p_wk = table.concat(p_wk, ' ')
	end
	return p_wk
end

function weaknessimgarg(arg)
	-- split by commas
	local wk = mw.text.split(string.lower(arg or ''), '%s*,%s*')
	local _wk = {}

	-- remake the list as a table, remove anything that's blank/doesn't exist
	for _, v in ipairs(wk) do
		local wk_x = weaknesses[v]
		if wk_x then
			table.insert(_wk, wk_x)
		end
	end
	local p_wk = {}
	for _, v in ipairs(_wk) do
		table.insert(p_wk, string.format('File:%s', v.image))
	end
	return table.concat(p_wk, infobox.splitpoint)
end

function weaknesstxtarg(arg)
	-- split by commas
	local wk = mw.text.split(string.lower(arg or ''), '%s*,%s*')
	local _wk = {}

	-- remake the list as a table, remove anything that's blank/doesn't exist
	for _, v in ipairs(wk) do
		local wk_x = weaknesses[v]
		if wk_x then
			table.insert(_wk, v)
		end
	end
	return table.concat(_wk, infobox.splitpoint)
end

-- Explicit weakness
-- weakness / explicit weakness
function explicitwkarg(arg)
	-- split by commas
	local wk = mw.text.split(string.lower(arg or ''), '%s*,%s*')
	local _wk = weaknesses[wk[1]]
	if _wk then
		return string.format('[[File:%s|20px|link=]]', _wk.image)
	else
		return nil
	end
end

function aff_weakness_arg(aff, aff_r, weakness)
	-- split by commas
	local wk = mw.text.split(string.lower(weakness or ''), '%s*,%s*')
	local _wk = weaknesses[wk[1]]
	if _wk and _wk.text == 'Nothing' then
		return '-'
	else
		return numberargs(aff, aff_r)
	end
end

function aff_weakness_bucket_arg(aff)
	if tonumber(aff) then
		return tonumber(aff)
	end
	return nil
end

-- generally weak to (class)
--	looks for the class that the mob is weakest to
--	if multiple equally weak, then none
function generalweaknessarg(aff_melee, aff_ranged, aff_magic)
	aff_melee = tonumber(aff_melee) or 0
	aff_ranged = tonumber(aff_ranged) or 0
	aff_magic = tonumber(aff_magic) or 0
	local max = math.max(aff_melee, aff_magic, aff_ranged)
	if max == 0 then
		return 'none'
	end
	local ret = {}

	if aff_melee == max then
		table.insert(ret, 'melee')
	end
	if aff_ranged == max then
		table.insert(ret, 'ranged')
	end
	if aff_magic == max then
		table.insert(ret, 'magic')
	end
	if #ret == 1 then
		return ret[1]
	end
	return 'none'
end

function wkcats(arg, tbl)
	for v in mw.text.gsplit(arg, infobox.splitpoint) do
		local weakness = weaknesses[v]
		if weakness then
			if weakness.category then
				local category = weakness.category
				if type(category) == "string" then
					table.insert(tbl, category)
				elseif type(category) == "table" then
					for _, c in ipairs(category) do
						table.insert(tbl, c)
					end
				end
			end
		elseif arg == 'inquisitor' then
			table.insert(tbl, 'Susceptible to inquisitor staff')
		elseif arg == 'terrasaur' then
			table.insert(tbl, 'Susceptible to terrasaur maul')
		elseif arg == 'hexhunter' then
			table.insert(tbl, 'Susceptible to hexhunter bow')
		end
	end
end

function susceptarg_bucket(sus, wk, ps, derived_susceptibility, restriction)
	local sus_check = {}
	local suscepts = {}

	-- lowercase parameters
	if infobox.isDefined(ps) then
		ps = mw.text.trim(ps:lower())
	end
	sus = string.lower(sus)

	-- legacy weakness parameter values
	if infobox.isDefined(wk) then
		if wk:find('darklight') or wk:find('silverlight') then
			sus = sus .. ',demon'
		end
	end

	if infobox.isDefined(derived_susceptibility) then
		derived_susceptibility = yesno(derived_susceptibility)
	else
		derived_susceptibility = true
	end

	-- combat style specific susceptibilities
	if restriction == 'dungeoneering' then
		-- dungeoneering only accept hexhunter
		if ps == 'magic' then
			local sus_key = primary_styles.magic_dungeoneering
			sus_check[sus_key] = true
			table.insert(suscepts, sus_key)
		end
	elseif primary_styles[ps] and derived_susceptibility then
		local sus_key = primary_styles[ps]
		sus_check[sus_key] = true
		table.insert(suscepts, sus_key)
	end

	for v in mw.text.gsplit(sus, '%s*,%s*') do
		local u = weaknesses[v]
		if u and u._suscept and not sus_check[u] then
			sus_check[u] = true
			table.insert(suscepts, u.name or v)
		end
	end

	if #suscepts == 0 then
		return nil
	end
	return table.concat(suscepts, infobox.splitpoint)
end

function susceptarg(sus_bucket)
	local suscepts = {}
	if not infobox.isDefined(sus_bucket) then
		return "None"
	end
	for v in mw.text.gsplit(sus_bucket, infobox.splitpoint) do
		local u = weaknesses[v]
		if u then
			table.insert(suscepts, string.format('[[File:%s|25px|frameless|link=%s]]', u.image, u.link))
		end
	end
	if #suscepts == 0 then
		return "None"
	end
	return table.concat(suscepts, ' ')
end

function slayercatarg(arg)
	if string.match(arg or '', '%S') then
		local sl = string.lower(tostring(arg))
		if sl == 'n/a' or sl == 'no' or sl == 'none' then
			return 'N/A'
		end
		local out = {}
		for i in mw.text.gsplit(arg, '%s*,%s*') do
			table.insert(out, mw.text.trim(i))
		end
		return table.concat(out, ', ')
	end
	return nil
end

function slayercatdisparg(arg)
	if infobox.isDefined(arg) then
		if arg == 'N/A' then
			return 'N/A'
		end
		local out = {}
		for i in mw.text.gsplit(arg, ', ') do
			table.insert(out, string.format(slayer_disambig.disambig(i, true)))
		end
		return table.concat(out, ', ')
	end
	return nil
end

function slayercatbucketarg(cat)
	if infobox.isDefined(cat) then
		cat = string.lower(tostring(cat))
		if cat == 'n/a' or cat == 'no' or cat == 'none' then
			return nil
		end
		cat = string.gsub(cat, '[][]', '')
		cat = string.gsub(cat, '%s?,%s?', infobox.splitpoint)
		return cat
	end
	return nil
end

function slaycats(arg, tbl)
	for k, v in pairs(arg) do
		if v then
			local slay_master = slay_masters[string.lower(k)]
			if slay_master and slay_master.category then
				table.insert(tbl, slay_master.category)
			end
		end
	end
end

-- Slayer assigners
function slayerarg(cat, assignedbyoverride, assignedby, in_wilderness)
	-- check for +override & fallback
	local override = nil
	if infobox.isDefined(assignedbyoverride) then
		override = assignedbyoverride
	elseif not infobox.isDefined(cat) and infobox.isDefined(assignedby) then
		override = assignedby
	end
	if override then
		local slayer_master_list = {
			turael = false,
			spria = false,
			jacquelyn = false,
			mazchna = false,
			achtryn = false,
			vannaka = false,
			chaeldar = false,
			sumona = false,
			duradel = false,
			lapalok = false,
			kuradal = false,
			morvran = false,
			mandrith = false,
			raptor = false,
			all_none = true
		}
		local override_assignedby = mw.text.split(string.lower(override), '%s*,%s*')
		for _, v in ipairs(override_assignedby) do
			local slay_master = slay_masters_map[v]
			if slay_master then
				slayer_master_list[slay_master] = true
				slayer_master_list.all_none = false
			end
		end
		return slayer_master_list
	end

	if not infobox.isDefined(cat) then
		return { all_none = true }
	end

	local slayer_master_list = { none = {}, all_none = true }
	local clean_cats = mw.text.split(cat, ', ')
	for _, clean_cat in ipairs(clean_cats) do
		local master_amounts = slayer_info.getAllAmounts(clean_cat)
		slayer_master_list.none[clean_cat] = master_amounts.none
		slayer_master_list.all_none = slayer_master_list.all_none and master_amounts.none
		for j, amt in pairs(master_amounts) do
			if not slayer_master_list[j] then
				slayer_master_list[j] = {}
			end
			slayer_master_list[j][clean_cat] = amt
		end
	end
	if in_wilderness == 'false' then
		slayer_master_list.Mandrith = nil
	end
	return slayer_master_list
end

function slayerimgarg(slayer_master_list)
	if slayer_master_list.all_none then
		return 'Not assigned'
	end

	local out = {}
	for _, n in ipairs(slay_masters_order) do
		local v = slayer_master_list[n]
		if v then
			local amtstr
			if v == true then -- literal true testing for override/fallback method
				amtstr = 'assigned quantities unknown'
			else
				local amt_list = {}
				for _, amt in pairs(v) do
					table.insert(amt_list, string.format('%s–%s', amt.min, amt.max))
				end
				amtstr = table.concat(amt_list, '; ')
			end
			table.insert(out, string.format('[[%s]]: %s', n == "Raptor" and "The Raptor" or n, amtstr))
		end
	end
	return table.concat(out, '<br>')
end

function slayerbucketarg(slayer_master_list)
	if slayer_master_list.all_none then
		return nil
	end

	local out = {}
	for _, n in ipairs(slay_masters_order) do
		if slayer_master_list[n] then
			table.insert(out, n)
		end
	end
	return table.concat(out, infobox.splitpoint)
end

function racearg(race_arg, slayercats)
	if infobox.isDefined(race_arg) then
		local races = {}
		local raceStr = string.lower(race_arg)
		for race in mw.text.gsplit(raceStr, ',') do
			race = mw.text.trim(race)
			if race_info[race] then
				table.insert(races, race)
			end
		end

		return races
	end

	-- Based on slayer cats
	local races = {}
	for cat in mw.text.gsplit(slayercats or '', ',') do
		local race = slayer_race[mw.text.trim(cat)]
		if race_info[race] and not races[race] then
			table.insert(races, race)
			races[race] = true -- Prevent dubplicates
		end
	end

	return races
end

-- Race
function racedisp(races)
	if not type(races) == 'table' then
		return nil
	end

	local ret = {}

	for _, race in ipairs(races) do
		local info = race_info[race]
		if info then
			if info.racelink then
				table.insert(ret, string.format('[[%s|%s]]', info.racelink, info.racedisp and info.racedisp or info.racelink))
			elseif info.racedisp then
				table.insert(ret, info.racedisp)
			end
		end
	end

	if #ret == 0 then
		return nil
	end

	return table.concat(ret, ', ')
end

-- Not assigned
function notassarg(slayer_master_list)
	return not slayer_master_list or slayer_master_list.all_none
end

-- Abilities used
function abilistarg(arg)
	arg = paramtest.default_to(arg, false)
	if not arg then
		return nil
	elseif arg:lower() == 'none' then
		return 'None'
	else
		local out = {}
		for i in mw.text.gsplit(arg:lower(), ',') do
			i = mw.text.trim(i)
			if ability_info[i] then
				table.insert(out, i)
			end
		end
		return table.concat(out, ',')
	end
end

function abilbucketarg(arg)
	arg = paramtest.default_to(arg, false)
	if not arg or arg == 'nil' or not infobox.isDefined(arg) then
		return nil
	elseif arg:lower() == 'none' then
		return nil
	else
		local out = {}
		for v in mw.text.gsplit(arg, ',') do
			table.insert(out, ability_info[v].link)
		end
		return table.concat(out, infobox.splitpoint)
	end
end

function abildisparg(arg)
	arg = paramtest.default_to(arg, false)
	if not arg or tostring(arg) == 'nil' or not infobox.isDefined(arg) then
		return nil
	elseif arg:lower() == 'none' then
		return 'None'
	else
		local _text = {}
		for v in mw.text.gsplit(arg, ',') do
			table.insert(_text, string.format('[[File:%s.png|30x30px|frameless|link=%s]]', ability_info[v].image or ability_info[v].link, ability_info[v].link))
		end
		return table.concat(_text, ' ')
	end
end

-- Prayers used
function prayerarg(arg)
	arg = paramtest.default_to(arg, false)
	if not arg then
		return nil
	elseif arg:lower() == 'none' then
		return 'None'
	else
		local out = {}
		for i in mw.text.gsplit(arg:lower(), ',') do
			i = mw.text.trim(i)
			if prayer_info[i] then
				table.insert(out, i)
			end
		end
		return table.concat(out, ',')
	end
end

function prayerbucketarg(arg)
	arg = paramtest.default_to(arg, false)
	if not arg or arg == 'nil' or not infobox.isDefined(arg) then
		return nil
	elseif arg:lower() == 'none' then
		return nil
	else
		local out = {}
		for v in mw.text.gsplit(arg, ',') do
			table.insert(out, prayer_info[v].link)
		end
		return table.concat(out, infobox.splitpoint)
	end
end

function prayerdisparg(arg)
	arg = paramtest.default_to(arg, false)
	if not arg or tostring(arg) == 'nil' or not infobox.isDefined(arg) then
		return nil
	elseif arg:lower() == 'none' then
		return 'None'
	else
		local _text = {}
		for v in mw.text.gsplit(arg, ',') do
			table.insert(_text, string.format('[[File:%s.png|30x30px|frameless|link=%s]]', prayer_info[v].image or prayer_info[v].link, prayer_info[v].link))
		end
		return table.concat(_text, ' ')
	end
end

-- Attacks speed
function speedarg(arg)
	if not infobox.isDefined(arg) then
		return nil
	end
	local _, _, arg_find = string.find(arg:lower() .. ' ', '^(.-)%s')
	arg_find = tostring(attack_speed_bar(speed_map[arg_find])) or badarg('speed', ' is not a valid attack rate')
	return arg_find
end

function speed_bucket(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	if bucket_speed_map[arg] then
		arg = bucket_speed_map[arg]
	else
		arg = nil
	end
	return arg
end

function restrictionarg(arg)
	if paramtest.is_empty(arg) then
		return nil
	end
	return restriction_map[string.lower(arg)]
end

function iddisp(id)
	if infobox.isDefined(id) then
		return string.gsub(id, ', *', ', ')
	end
	return nil
end

function idbucket(id)
	if infobox.isDefined(id) then
		if string.lower(tostring(id)) == 'no' then
			return nil
		end
		local r = string.gsub(id, ', *', infobox.splitpoint)
		return r
	end
	return nil
end

function optionarg(arg, arg_old)
	if not infobox.isDefined(arg) and infobox.isDefined(arg_old) then
		arg = arg_old
	end
	if infobox.isDefined(arg) then
		if string.lower(arg) == 'none' or string.lower(arg) == 'examine' then
			return 'Examine'
		end
		local has_examine = false
		local ret = {}
		for x in mw.text.gsplit(arg, ',') do
			table.insert(ret, mw.text.trim(x))
			has_examine = has_examine or (string.find(x, 'Examine') ~= nil)
		end
		if not has_examine then
			table.insert(ret, 'Examine')
		end
		local ret_str = table.concat(ret, ', ')
		ret_str = mw.ustring.gsub(ret_str, '%[*[Ww]alk [Hh]ere%]*', '[[Walk here|Walk here]]')
		ret_str = mw.ustring.gsub(ret_str, '%[*[Ee]xamine%]*', 'Examine')
		return ret_str
	end
	return nil
end

function optionbucket(arg, arg_old)
	if not infobox.isDefined(arg) and infobox.isDefined(arg_old) then
		arg = arg_old
	end
	if infobox.isDefined(arg) then
		if string.lower(arg) == 'none' or string.lower(arg) == 'examine' then
			return 'Examine'
		end
		local r = string.gsub(arg, ',%s*', infobox.splitpoint)
		r = mw.ustring.gsub(r, '%[*[Ww]alk [Hh]ere%]*', 'Walk here')
		r = mw.ustring.gsub(r, '%[*[Ee]xamine%]*', 'Examine')
		if not r:find('Examine') then
			r = r .. infobox.splitpoint .. 'Examine'
		end
		return r
	end
	return nil
end

function make_chisel_links(id, name)
	local link1 = 'https://chisel.weirdgloop.org/bestiary/'
	local link2 = 'https://chisel.weirdgloop.org/gazproj/mrnd'
	if infobox.isDefined(id) then
		local ids = mw.text.split(id, infobox.splitpoint)
		link1 = link1 .. table.concat(ids, '%20')
		local id1 = tonumber(ids[1])
		if id1 then
			if #ids == 1 then
				link2 = string.format('%s?q=%s-%s&h=%s', link2, id1 - 15, id1 + 15, id1)
			else
				for i, j in ipairs(ids) do
					if i == 1 then
						link2 = string.format('%s?q=%s&h=%s', link2, j, j)
					else
						link2 = link2 .. '&q=' .. j
					end
				end
			end
		else
			link2 = string.format('%s?q=%s', link2, ids[1])
		end
	else
		local _name = name:gsub(' ', '%%20')
		link1 = link1 .. _name
		link2 = string.format('%s?q=%s', link2, _name)
	end
	return string.format('[%s bestiary]&nbsp;&bull;&nbsp;[%s MRND]', link1, link2)
end

-- red ERR span with title hover for explanation
function badarg(argname, argmessage)
	argname = argname or '(unknown)'
	argmessage = argmessage or '(empty)'
	return '<span ' ..
		'title="The parameter «' .. argname .. '» ' .. argmessage .. '" ' ..
		'style="color:red; font-weight:bold; cursor:help; border-bottom:1px dotted red;">' ..
		'ERR</span>'
end

function sizearg(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	arg = tonumber(arg)
	if arg == nil then
		return nil
	end

	local arg2 = math.floor(arg)
	if arg ~= arg2 or arg <= 1 then
		return nil
	end

	return arg
end

function sizedisp(arg)
	if not infobox.isDefined(arg) then
		return nil
	end

	return string.format('%s×%s', arg, arg)
end

function dropversionparg(drop, ver)
	if infobox.isDefined(drop) then
		return drop
	elseif infobox.isDefined(ver) then
		return ver
	end

	return nil
end

function dropversionbucketparg(name, drop, ver)
	local return_string = name
	if infobox.isDefined(drop) then
		return_string = return_string .. "#" .. drop
	elseif infobox.isDefined(ver) then
		return_string = return_string .. "#" .. ver
	end
	return return_string
end

-- bucket
--[=[
		{ name = 'bucketarg', func = { name = bucketarg, params = { 'id_bucket', 'name', 'vanchor', 'level_bucket', 'size', 'examine', 'leagueRegion_raw', 'xpraw', 'thievelvl_bucket', 'members',
			'options_bucket', 'styleimg', 'styletxt', 'primarystyle_bucket', 'lpraw', 'weaknessimg', 'weaknesstxt', 'generalweakness',
			'susceptibility_bucket', 'slayercat_bucket', 'slaylvl_bucket', 'slayxp_bucket', 'assigned_by_bucket', 'restriction',
			'attack_bucket', 'magic_bucket', 'ranged_bucket', 'defence_bucket', 'max_melee_bucket', 'max_magic_bucket', 'max_ranged_bucket',
			'max_spec_bucket', 'acc_melee_bucket', 'acc_magic_bucket', 'acc_ranged_bucket', 'armour_bucket', 'aff_melee_bucket',
			'aff_magic_bucket', 'aff_ranged_bucket', 'aff_weakness_bucket', 'aggressive_bucket', 'poisonous_bucket',
			'immune_to_poison_bucket', 'immune_to_deflect_bucket', 'immune_to_stun_bucket', 'immune_to_drain_bucket', 'speed_bucket',
			'abilities_bucket', 'prayers_bucket' }, flag = 'd', dupes = true } }
--]=]
function bucketarg(id_bucket, name, vanchor, level_bucket, size, examine, leagueRegion_raw, xpraw, thievelvl_bucket, members,
				   options_bucket, styleimg, styletxt, primarystyle_bucket, lpraw, weaknessimg, weaknesstxt, generalweakness,
				   susceptibility_bucket, slayercat_bucket, slaylvl_bucket, slayxp_bucket, assigned_by_bucket, restriction,
				   attack_bucket, magic_bucket, ranged_bucket, defence_bucket, max_melee_bucket, max_magic_bucket, max_ranged_bucket,
				   max_spec_bucket, acc_melee_bucket, acc_magic_bucket, acc_ranged_bucket, armour_bucket, aff_melee_bucket,
				   aff_magic_bucket, aff_ranged_bucket, aff_weakness_bucket, aggressive_bucket, poisonous_bucket,
				   immune_to_poison_bucket, immune_to_deflect_bucket, immune_to_stun_bucket, immune_to_drain_bucket, speed_bucket,
				   abilities_bucket, prayers_bucket, dropversion_bucket)
	local toJSON = {
		id = mw.text.split(id_bucket, infobox.splitpoint),
		name = name,
		version_anchor = vanchor,
		combat_level = level_bucket,
		size = size,
		examine = examine,
		league_region = leagueRegion_raw,
		combat_experience = xpraw,
		thieving_level = thievelvl_bucket,
		is_members_only = members,
		options = mw.text.split(options_bucket or '', infobox.splitpoint),
		attack_style = mw.text.split(styleimg or '', infobox.splitpoint),
		attack_style_text = mw.text.split(styletxt or '', infobox.splitpoint),
		primary_attack_style = primarystyle_bucket,
		life_points = lpraw,
		weakness = mw.text.split(weaknessimg or '', infobox.splitpoint),
		weakness_text = mw.text.split(weaknesstxt or '', infobox.splitpoint),
		weakness_by_class = generalweakness,
		susceptible_to = mw.text.split(susceptibility_bucket or '', infobox.splitpoint),
		slayer_category = mw.text.split(slayercat_bucket or '', infobox.splitpoint),
		slayer_level = slaylvl_bucket,
		slayer_experience = slayxp_bucket,
		assigned_by = mw.text.split(assigned_by_bucket or '', infobox.splitpoint),
		location_restriction = restriction,
		attack_level = attack_bucket,
		magic_level = magic_bucket,
		ranged_level = ranged_bucket,
		defence_level = defence_bucket,
		melee_max_hit = max_melee_bucket,
		magic_max_hit = max_magic_bucket,
		ranged_max_hit = max_ranged_bucket,
		special_max_hit = max_spec_bucket,
		melee_accuracy = acc_melee_bucket,
		magic_accuracy = acc_magic_bucket,
		ranged_accuracy = acc_ranged_bucket,
		armour = armour_bucket,
		melee_affinity = aff_melee_bucket,
		magic_affinity = aff_magic_bucket,
		ranged_affinity = aff_ranged_bucket,
		weakness_affinity = aff_weakness_bucket,
		is_aggressive = aggressive_bucket,
		is_poisonous = poisonous_bucket,
		susceptible_to_poison = immune_to_poison_bucket,
		susceptible_to_deflect = immune_to_deflect_bucket,
		susceptible_to_stun = immune_to_stun_bucket,
		susceptible_to_drain = immune_to_drain_bucket,
		attack_rate = speed_bucket,
		uses_ability = mw.text.split(abilities_bucket or '', infobox.splitpoint),
		uses_prayer = mw.text.split(prayers_bucket or '', infobox.splitpoint),
		dropversion = mw.text.split(dropversion_bucket or '', infobox.splitpoint),
	}
	
	-- edit links kill the entire JSON field; strip any such keys before encoding
	for k, v in pairs(toJSON) do
		if type(v) == "table" then
			for subk, subv in ipairs(v) do
				if not infobox.isDefined(subv) then
					toJSON[k][subk] = nil
				end
			end
		elseif not infobox.isDefined(v) then
			toJSON[k] = nil
		end
	end

	return mw.text.jsonEncode(toJSON)
end

function addcategories(args, catargs)
	local ret = { 'Cache NPCs', 'Bestiary' }
	local cat_map = {
		-- Added if the parameter has content
		defined = {
			aka = 'Pages with AKA',
			leagueRegion = 'Pages with League region',
		},
		-- Added if the parameter has no content
		notdefined = {
			image = 'Needs non-player character image',
			members = 'Needs members status',
			release = 'Needs release date',
			examine = 'Needs NPC examine added',
			options = 'Needs options added',
			level = 'Needs combat level',
			experience = 'Needs XP per kill',
			primarystyle_bucket = 'Missing primary attack style',
			immune_to_stun = 'Missing stun immunity information',
			immune_to_poison = 'Missing poison immunity information',
			immune_to_deflect = 'Missing deflect immunity information',
			immune_to_drain = 'Missing drain immunity information',
			attack = 'Missing combat skill levels',
			magic = 'Missing combat skill levels',
			ranged = 'Missing combat skill levels',
			defence = 'Missing combat skill levels',
			max_necromancy = 'Needs necromancy stats added',
			acc_necromancy = 'Needs necromancy stats added',
			necromancy = 'Needs necromancy stats added',
			id = 'NPCs without ID',
			leagueRegion = 'Needs League region/Monster',
		},
		-- regex
		grep = {
			poisonous = { ['yes check%.svg'] = 'Poisonous monsters' },
			aggressive = { ['yes check%.svg'] = 'Aggressive monsters' },
			immune_to_stun = { ['is immune'] = 'Stun-immune monsters', ['is not immune'] = 'Stun-susceptible monsters' },
			immune_to_poison = { ['is immune'] = 'Poison-immune monsters', ['is not immune'] = 'Poison-susceptible monsters' },
			immune_to_deflect = { ['is immune'] = 'Deflect-immune monsters', ['is not immune'] = 'Deflect-susceptible monsters' },
			immune_to_drain = { ['is immune'] = 'Drain-immune monsters', ['is not immune'] = 'Drain-susceptible monsters' },
		},
	}

	-- Run and add mapped categories
	for n, v in pairs(cat_map.defined) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret, v)
		end
	end

	for n, v in pairs(cat_map.notdefined) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret, v)
		end
	end

	-- searches
	for n, v in pairs(cat_map.grep) do
		for m, w in pairs(v) do
			if args[n] then
				if string.find(string.lower(tostring(args[n].d) or ''), m) then
					table.insert(ret, w)
				end
				if args[n].switches then
					for _, x in ipairs(args[n].switches) do
						if string.find(string.lower(tostring(x)), m) then
							table.insert(ret, w)
						end
					end
				end
			end
		end
	end

	if args.vanchor.switches then
		local verstable = {}
		for _, v in ipairs(args.vanchor.switches) do
			if verstable[v] then
				table.insert(ret, 'Pages with a duplicate subobject name')
				break
			else
				verstable[v] = true
			end
		end
	end

	local levels = { args.level.d }
	if args.level.switches then
		for _, v in ipairs(args.level.switches) do
			if v ~= infobox.nilParam() then
				table.insert(levels, v)
			end
		end
	end

	for _, v in ipairs(levels) do
		if v == 'N/A' then
			table.insert(ret, 'Monsters with no combat level')
		elseif tonumber(v) then
			table.insert(ret, string.format('Combat level %s monsters', v))
		end
	end

	local xpmods = { args.xpmod.d }
	if args.xpmod.switches then
		for _, v in ipairs(args.xpmod.switches) do
			if v ~= infobox.nilParam() then
				table.insert(xpmods, v)
			end
		end
	end

	for _, v in ipairs(xpmods) do
		if v > 0 and v ~= standard_hp_to_xp_mod then
			table.insert(ret, 'Monsters that provide modified combat experience')
		end
	end

	if args.members.d:find('[Nn]o') then
		table.insert(ret, 'Free-to-play bestiary')
	elseif args.members.switches then
		for _, v in ipairs(args.members.switches) do
			if v:find('[Nn]o') then
				table.insert(ret, 'Free-to-play bestiary')
				break
			end
		end
	end
	if args.members.d:find('[Yy]es') then
		table.insert(ret, "Members' bestiary")
	elseif args.members.switches then
		for _, v in ipairs(args.members.switches) do
			if v:find('[Yy]es') then
				table.insert(ret, "Members' bestiary")
				break
			end
		end
	end
	if args.abilities_disp.d:find('File') then
		table.insert(ret, 'Monsters that use abilities')
	elseif args.abilities_disp.switches then
		for _, v in ipairs(args.abilities_disp.switches) do
			if v:find('File') then
				table.insert(ret, 'Monsters that use abilities')
				break
			end
		end
	end
	if args.prayers_disp.d:find('File') then
		table.insert(ret, 'Monsters that use prayers')
	elseif args.prayers_disp.switches then
		for _, v in ipairs(args.prayers_disp.switches) do
			if v:find('File') then
				table.insert(ret, 'Monsters that use prayers')
				break
			end
		end
	end
	if args.weaknesstxt.d then
		wkcats(args.weaknesstxt.d, ret)
	end
	if args.weaknesstxt.switches then
		for _, v in ipairs(args.weaknesstxt.switches) do
			if v ~= nil then
				wkcats(v, ret)
			end
		end
	end
	if args.susceptibility_bucket.d then
		wkcats(args.susceptibility_bucket.d, ret)
	end
	if args.susceptibility_bucket.switches then
		for _, v in ipairs(args.susceptibility_bucket.switches) do
			if v ~= nil then
				wkcats(v, ret)
			end
		end
	end
	if args['gender'] then
		if string.lower(args['gender'].d or '') == 'male' then
			table.insert(ret, 'Male characters')
		elseif string.lower(args['gender'].d or '') == 'female' then
			table.insert(ret, 'Female characters')
		elseif string.lower(args['gender'].d or '') == 'no' then
			table.insert(ret, 'Genderless characters')
		end
	end
	if args.assigned_by_raw.d then
		slaycats(args.assigned_by_raw.d, ret)
	end
	if args.assigned_by_raw.switches then
		for _, v in ipairs(args.assigned_by_raw.switches) do
			if v ~= nil then
				slaycats(v, ret)
			end
		end
	end

	if not args.voice.d:find('%?action=edit') and args.voice.d:find('[Yy]es') then
		table.insert(ret, 'Voice acted NPCs')
	elseif args.voice.switches then
		for _, v in ipairs(args.voice.switches) do
			if not v:find('%?action=edit') and v:find('[Yy]es') then
				table.insert(ret, 'Voice acted NPCs')
				break
			end
		end
	end

	-- Add the associated race category if matched
	local defrace = false
	local races = {}
	if type(args.race.d) == 'table' and #args.race.d > 0 then
		defrace = true
		for _, race in ipairs(args.race.d) do
			races[race] = true
		end
	end
	if args.race.switches then
		for _, v in ipairs(args.race.switches) do
			if type(v) == 'table' and #v > 0 then
				for _, race in ipairs(v) do
					races[race] = true
				end
			elseif not defrace then
				table.insert(ret, 'Needs race')
			end
		end
	end
	if next(races) then
		for race in pairs(races) do
			table.insert(ret, race_info[race].racecat)
			if race_info[race].addcat then
				for _, cat in ipairs(race_info[race].addcat) do
					table.insert(ret, cat)
				end
			end
		end
	else
		table.insert(ret, 'Needs race')
	end

	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end

	return table.concat(ret, '')
end

return p