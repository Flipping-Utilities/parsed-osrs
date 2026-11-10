-- <nowiki>
-- Module for [[Template:Infobox Item]]
-- Test changes using [[Module:Infobox Item/sandbox]] [[Template:Infobox Item/sandbox]]
local p = {}

-- "imports"

local infobox = require('Module:Infobox')
local onmain = require('Module:Mainonly').on_main
local paramtest = require('Module:Paramtest')
local commas = require('Module:Addcommas')._add
local exchange = require('Module:Exchange')
local chart = require('Module:ExchangeData')._chart
local yesno = require('Module:Yesno')
local editbutton = require('Module:Edit button')
local userError = require('Module:User error')
local formatCalcvalue = require('Module:Calcvalue formatter').main
local storearg, tradeablearg, disassemblyarg, disassemblybucketarg, weightarg, weightargraw
local calcvalParse, calcvalbucket, calcvalbucketNowiki, calcvalPretty, estvaluearg, estvalueeval, estvaluepretty
local optionscheckargs, optionsdisparg
local gemwarg, gemwnamearg, gemwpricearg, gemwpagearg, exchangearg, geparg, gemwgrapharg, buylimitarg, buylimitbucketarg
local exgvaluearg, valraw, valuearg, volumearg, gemwdisp, deathstatusarg, ikodarg, reclaimvaluearg, keptondeatharg
local gemwalchablearg, gemwalchmultiplierarg, alchablearg, multiplierarg, alchvaluesraw, alchvalues
local yesnodisp, removaldisp, restrictionarg, restrsurfarg, iddisp, idbucket, make_chisel_links, bucketarg, addVersionAnchorVars, addcategories, image_bucket, pageimagearg
local badarg, plural, killRoundingError
local leaguesArg

local var = mw.ext.VariablesLua

local death_map = {
	allowed = {
		reclaimable = 'reclaimable',
		never = 'never',
		always = 'always',
		alwaysinclwild = 'alwaysinclwild',
		dropped = 'dropped',
		safe = 'safe',
		gemwdegrade = 'gemwdegrade',
	},
	strings = {
		reclaimable = 'reclaimable', --extra processing so no nice string
		never = 'Always lost',
		always = 'Always kept outside [[Skull (status)|dangerous area]]',
		alwaysinclwild = 'Always kept',
		dropped = 'Dropped on death',
		safe = 'Always a safe death',
		gemwdegrade = nil, --intentional nil
	},
}

-- location restriction
local restriction_map = {
	surface = 'surface',
	dungeoneering = 'dungeoneering',
	dg = 'dungeoneering',
	daemonheim = 'dungeoneering',
	quest = 'quest',
	minigame = 'minigame',
	activity = 'minigame',
	beta = 'removed',
	gone = 'removed',
	removed = 'removed',
	limited = 'limited',
	['time limited'] = 'limited',
	th = 'microtransaction',
	sof = 'microtransaction',
	['treasure hunter'] = 'microtransaction',
	['squeal of fortune'] = 'microtransaction',
	cache = 'cache',
}

local lowercase_only_versions = {
	charged = true,
	uncharged = true,
	new = true,
	worn = true,
	normal = true,
	bonus = true,
	unbound = true,
	unsealed = true,
}

local function checkVersion(version, equipable)
	if (not paramtest.has_content(version)) then
		return nil;
	end

	if (yesno(equipable) and type(version) == "string") then
		local lc = string.lower(version);
		if (lc ~= version and lowercase_only_versions[lc]) then
			return error('Version \"' .. version .. '\" must be lowercase (\"' .. lc .. '\")');
		end
	end

	return version;
end

local function bucketbool(val)
	if yesno(val) then
		return true
	end
	return false
end

-- Main function called with invokes
function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	-- Parameter definitions
	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'aka', func = 'has_content' },
		{ name = 'image', func = pageimagearg },
		{ name = 'image_bucket', func = { name = image_bucket, params = { 'image' }, flag = 'p' } },

		-- release and removal
		-- removal only shown if it exists
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'removaldisp', func = { name = removaldisp, params = { 'removal' } }, dupes = true },

		{ name = 'members', func = 'has_content' },
		{ name = 'examine', func = 'has_content' },
		{ name = 'quest', func = 'has_content' },
		-- leagues
		{ name = 'leagueRegion', func = leaguesArg },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },


		{ name = 'tradeable', func = tradeablearg },
		{ name = 'tradeablebucket', func = { name = yesno, params = { 'tradeable', false }, flag = { 'd', 'r' } } },
		{ name = 'equipable', func = 'has_content' },

		{ name = 'vanchor', func = { name = checkVersion, params = { 'version', 'equipable' }, flag = { 'p', 'd' } } },

		-- bankable; only show if "No"; default to "Yes"
		{ name = 'bankable', func = { name = 'has_content', params = { 'bankable', 'Yes' }, flag = { 'd', 'r' } } },
		{ name = 'bankabledisp', func = { name = yesnodisp, params = { 'bankable', 'no' }, flag = { 'd', 'r' } }, dupes = true },
		{ name = 'bankablebucket', func = { name = bucketbool, params = { 'bankable', false }, flag = { 'd', 'r' } }, dupes = true },

		-- stacksinbank; only show if "No"; default to "Yes"
		{ name = 'stacksinbank', func = { name = 'has_content', params = { 'stacksinbank', 'Yes' }, flag = { 'd', 'r' } } },
		{ name = 'stacksinbankdisp', func = { name = yesnodisp, params = { 'stacksinbank', 'no' }, flag = { 'd', 'r' } }, dupes = true },
		{ name = 'stacksinbankbucket', func = { name = bucketbool, params = { 'stacksinbank', false }, flag = { 'd', 'r' } }, dupes = true },

		-- gimstorage; only show if "Yes"; default to "No"
		{ name = 'gimstorage', func = { name = 'has_content', params = { 'gimstorage', 'No' }, flag = { 'd', 'r' } } },
		{ name = 'gimstoragedisp', func = { name = yesnodisp, params = { 'gimstorage', 'yes' }, flag = { 'd', 'r' } }, dupes = true },
		{ name = 'gimstoragebucket', func = { name = bucketbool, params = { 'gimstorage', false }, flag = { 'd', 'r' } }, dupes = true },

		-- lendable; only show if "Yes"; default to "No"
		{ name = 'lendable', func = { name = 'has_content', params = { 'lendable', 'No' }, flag = { 'd', 'r' } } },
		{ name = 'lendabledisp', func = { name = yesnodisp, params = { 'lendable' } }, dupes = true },
		{ name = 'lendablebucket', func = { name = bucketbool, params = { 'lendable', false }, flag = { 'd', 'r' } }, dupes = true },

		{ name = 'stackable', func = 'has_content' },
		{ name = 'stackablebucket', func = { name = bucketbool, params = { 'stackable', false }, flag = { 'd', 'r' } }, dupes = true },
		{ name = 'disassembly', func = disassemblyarg },
		{ name = 'disassemblybucket', func = { name = disassemblybucketarg, params = { 'disassembly' }, flag = 'p' } },

		-- edible; only show if "Yes"; default to "No"
		{ name = 'edible', func = { name = 'has_content', params = { 'edible', 'No' }, flag = { 'd', 'r' } } },
		{ name = 'edibledisp', func = { name = yesnodisp, params = { 'edible' } }, dupes = true },
		{ name = 'noteable', func = { name = 'has_content', params = { 'noteable', 'No' }, flag = { 'd', 'r' } } },
		{ name = 'noteabledisp', func = { name = yesnodisp, params = { 'noteable' } }, dupes = true },
		{ name = 'noteablebucket', func = { name = bucketbool, params = { 'noteable', true }, flag = { 'd', 'r' }, dupes = true } },
		{ name = 'destroy', func = 'has_content' },
		{ name = 'store', func = storearg },

		-- options
		{ name = 'options', func = { name = optionscheckargs, params = { 'options', 'actions' } } },
		{ name = 'optionsdisp', func = { name = optionsdisparg, params = { 'options', 'options_ground', 'options_equipped', 'options_bank', 'options_currency_pouch' }, flag = 'd' }, dupes = true },
		{ name = 'options_ground', func = { name = optionscheckargs, params = { 'options_ground', 'actions_ground' } } },
		{ name = 'options_equipped', func = { name = optionscheckargs, params = { 'options_equipped', 'actions_equipped' } } },
		{ name = 'options_bank', func = { name = optionscheckargs, params = { 'options_bank', 'actions_bank' } } },
		{ name = 'options_currency_pouch', func = { name = optionscheckargs, params = { 'options_currency_pouch', 'actions_currency_pouch' } } },

		-- gemw prices
		-- only displayed if they exist
		--dupes must exist for individual prices to have them display properly
		{ name = 'gemw', func = { name = gemwarg, params = { 'exchange', 'tradeable' }, flag = { 'p', 'd' } } },
		{ name = 'gemwname', func = { name = gemwnamearg, params = { 'name', 'gemwname' } } },
		{ name = 'gemwprice', func = { name = gemwpricearg, params = { 'gemw', 'gemwname' }, flag = { 'd', 'd' } }, dupes = true },
		{ name = 'gemwpage', func = { name = gemwpagearg, params = { 'gemwprice', 'gemwname' } } },
		{ name = 'exchange', func = { name = exchangearg, params = { 'gemwprice', 'gemwname' }, flag = { 'd', 'd' } }, dupes = true },
		{ name = 'gep', func = { name = geparg, params = { 'gemwprice' }, flag = { 'd' } }, dupes = true },
		{ name = 'graph', func = { name = gemwgrapharg, params = { 'gemwprice', 'gemwname' } }, dupes = true },
		{ name = 'buylimit', func = { name = buylimitarg, params = { 'gemwprice', 'gemwname' } }, dupes = true },
		{ name = 'buylimitbucket', func = { name = buylimitbucketarg, params = { 'buylimit' } }, dupes = true },
		{ name = 'exgvalue', func = { name = exgvaluearg, params = { 'gemwprice', 'gemwname' } }, dupes = true },
		{ name = 'val', func = { name = valraw, params = { 'value', 'exgvalue' }, flag = { 'p', 'd' } }, dupes = true },
		{ name = 'value', func = { name = valuearg, params = { 'val', 'convert' }, flag = { 'd', 'p' } } },
		{ name = 'volume', func = { name = volumearg, params = { 'gemwprice', 'gemwname' } }, dupes = true },
		{ name = 'realtime', func = { name = realtimearg, params = { 'gemwprice', 'gemwname' } }, dupes = true },

		-- used for both exchange and graphs
		{ name = 'gemwdisp', func = { name = gemwdisp, params = { 'gemwprice' } }, dupes = true },
		{ name = 'deathstatus', func = { name = deathstatusarg, params = { 'kept' }, flag = 'p' } },
		{ name = 'ikodvalue', func = { name = ikodarg, params = { 'deathstatus', 'ikod', 'val', 'gemwprice' }, flag = { 'd', 'p', 'd', 'd' } } },
		{ name = 'reclaimvalue', func = { name = reclaimvaluearg, params = { 'ikodvalue', 'reclaim' }, flag = { 'd', 'p' } } },
		{ name = 'kept', func = { name = keptondeatharg, params = { 'deathstatus', 'ikodvalue', 'reclaimvalue' }, flag = { 'd', 'd', 'd' } } },

		-- alchemy
		{ name = 'gemwalchable', func = { name = gemwalchablearg, params = { 'gemwprice', 'gemwname' } }, dupes = true },
		{ name = 'gemwalchmultiplier', func = { name = gemwalchmultiplierarg, params = { 'gemwprice', 'gemwname' } }, dupes = true },
		{ name = 'alchable', func = { name = alchablearg, params = { 'alchable', 'high', 'low', 'gemwalchable' }, flag = { 'p', 'p', 'p', 'd' } }, dupes = true },
		{ name = 'alchmultiplier', func = 'numbers' },
		{ name = 'alchmultiplier_final', func = { name = multiplierarg, params = { 'alchmultiplier', 'gemwalchmultiplier' }, flag = { 'p', 'd' } } },
		{ name = 'highraw', func = { name = alchvaluesraw, params = { 'val', 'high', 'alchmultiplier_final', 1, 'alchable' }, flag = { 'd', 'p', 'd', 'r', 'd' } } },
		{ name = 'lowraw', func = { name = alchvaluesraw, params = { 'val', 'low', 'alchmultiplier_final', 2 / 3, 'alchable' }, flag = { 'd', 'p', 'd', 'r', 'd' } } },
		{ name = 'high', func = { name = alchvalues, params = { 'val', 'high', 'alchmultiplier_final', 1, 'alchable' }, flag = { 'd', 'p', 'd', 'r', 'd' } } },
		{ name = 'low', func = { name = alchvalues, params = { 'val', 'low', 'alchmultiplier_final', 2 / 3, 'alchable' }, flag = { 'd', 'p', 'd', 'r', 'd' } } },

		-- calcvalue (value for items not on the GE)
		{ name = 'calcvalue', func = { name = calcvalParse, params = { 'calcvalue' }, flag = { 'p' } }, dupes = true },
		{ name = 'calcvalue_bucket', func = { name = calcvalbucket, params = { 'calcvalue' }, flag = { 'p' } }, dupes = true },
		{ name = 'calcvalue_bucket_nowiki', func = { name = calcvalbucketNowiki, params = { 'calcvalue' }, flag = { 'p' } }, dupes = true },
		{ name = 'calcvalue_pretty', func = { name = calcvalPretty, params = { 'calcvalue' }, flag = { 'p' } }, dupes = true },

		-- estvalue (estimated market value of items not listed on the GE and with no creation cost)
		{ name = 'estvalue', func = { name = estvaluearg, params = { 'estvalue' }, flag = { 'd' } }, dupes = true },
		{ name = 'estvalue_eval', func = { name = estvalueeval, params = { 'estvalue' }, flag = { 'd' } }, dupes = true },
		{ name = 'estvalue_pretty', func = { name = estvaluepretty, params = { 'estvalue' }, flag = { 'd' } }, dupes = true },

		{ name = 'weight', func = weightarg },
		{ name = 'weightraw', func = { name = weightargraw, params = { 'weight' }, flag = 'p' } },

		{ name = 'restriction', func = restrictionarg },
		{ name = 'restrictionsurface', func = { name = restrsurfarg, params = { 'restriction', 'restriction', 'quest' }, flag = { 'd', 'p', 'd' } } },
		-- not used; only for categories
		{ name = 'configname', func = 'has_content' },
		{ name = 'id', func = { name = iddisp, params = { 'id' }, flag = 'p' } },
		{ name = 'histid', func = { name = iddisp, params = { 'histid' }, flag = 'p' } },
		{ name = 'id_bucket', func = { name = idbucket, params = { 'id' }, flag = 'p' } },
		{ name = 'histid_bucket', func = { name = idbucket, params = { 'histid' }, flag = 'p' } },
		{ name = 'chisel_links', func = { name = make_chisel_links, params = { 'id_bucket', 'name' }, flag = 'd' } },
		{ name = 'hist_chisel_links', func = { name = make_chisel_links, params = { 'histid_bucket', 'name' }, flag = { 'd' } } },
		{ name = 'rscid', func = 'numbers' },
		{ name = 'bucketarg', func = { name = bucketarg, params = {
			'name', 'version', 'id', 'histid', 'members', 'release', 'removal', 'examine', 'quest', 'destroy', 'restriction', 'leagueRegion_raw', -- strings
			'deathstatus', 'ikodvalue', 'reclaimvalue',                                                                                  -- death
			'tradeable', 'equipable', 'bankable', 'stacksinbank', 'gimstorage', 'lendable', 'stackable', 'disassembly', 'edible', 'noteable', -- generally boolean or tri-lean
			'val', 'high', 'low', 'weightraw',                                                                                           -- numbers
			'gemw', 'gemwname', 'buylimit',                                                                                              -- gemw
		}, flag = 'd' } },
	}

	ret:setMaxButtons(7)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)

	-- parameter linkings for hidden rows
	ret:linkParams {
		{ 'removal', 'removaldisp' },
		{ 'exchange', 'gemwdisp' },
		{ 'graph', 'gemwdisp' },
		{ 'volume', 'gemwdisp' },
		{ 'buylimit', 'gemwdisp' },
		{ 'bankable', 'bankabledisp' },
		{ 'stacksinbank', 'stacksinbankdisp' },
		{ 'gimstorage', 'gimstoragedisp' },
		{ 'lendable', 'lendabledisp' },
		{ 'edible', 'edibledisp' },
	}

	ret:defineLinks()

	ret:useBucket('infobox_item', {
		id_bucket = 'item_id',
		histid_bucket = 'item_id_historical',
		vanchor = 'version_anchor',
		name = 'item_name',
		image_bucket = 'image',
		examine = 'examine',
		val = 'value',
		highraw = 'high_alchemy_value',
		lowraw = 'low_alchemy_value',
		weightraw = 'weight',
		members = 'is_members_only',
		tradeablebucket = 'tradeable',
		stackablebucket = 'stackable',
		bankablebucket = 'bankable',
		stacksinbankbucket = 'stacks_in_bank',
		lendablebucket = 'lendable',
		disassemblybucket = 'disassembleable',
		noteablebucket = 'noteable',
		gemwpage = 'exchange_page',
		buylimitbucket = 'buy_limit',
		restriction = 'location_restriction',
		deathstatus = 'kept_on_death',
		calcvalue_bucket = 'calculated_value',
		estvalue = 'estimated_market_value',
		leagueRegion_raw = 'league_region',
	})
	ret:useBucket('item_id', {
		id_bucket = 'id',
	})

	ret:addButtonsCaption()

	ret:defineName('Infobox Item')
	ret:addClass('infobox-item')

	ret:addRow {
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '60' },
	}
		:pad(60)

	ret:addRow {
		{ tag = 'argd', content = 'image', class = 'infobox-image inventory-image infobox-full-width-content', colspan = '60' },
	}
		:pad(60)

		:addRow {
			{ tag = 'th', content = 'Release', colspan = '20' },
			{ tag = 'argd', content = 'release', colspan = '40' },
		}

	if ret:paramDefined('removal') then
		ret:addRow {
			{ tag = 'th', content = 'Removal', colspan = '20' },
			{ tag = 'argd', content = 'removal', colspan = '40' },
		}
	end

	if ret:paramDefined('aka') then
		ret:addRow {
			{ tag = 'th', content = '[[Slang dictionary|AKA]]', colspan = '20' },
			{ tag = 'argd', content = 'aka', colspan = '40' },
		}
	end

	ret:addRow {
		{ tag = 'th', content = '[[Members]]', colspan = '20' },
		{ tag = 'argd', content = 'members', colspan = '40' },
	}

		:addRow {
			{ tag = 'th', content = '[[Quest items|Quest item]]', colspan = '20' },
			{ tag = 'argd', content = 'quest', colspan = '40' },
		}


	if ret:paramDefined('leagueRegion', 'all') then
		local leagues = require('Module:LeagueRegion')
		ret:addRow {
			{ tag = 'th', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] region', colspan = '20',
				css = { ['vertical-align'] = 'middle' },
			},
			{ tag = 'argd', content = 'leagueRegion', colspan = '40',
				css = { ['vertical-align'] = 'middle' },
			},
			meta = { addClass = 'leagues-global-flag' },
		}
	end

	ret:pad(60)
		:addRow {
			{ tag = 'th', content = 'Properties', class = 'infobox-subheader', colspan = '60' },
		}
		:pad(60)

		:addRow {
			{ tag = 'th', content = '[[Items#Tradeability|Tradeable]]', colspan = '20' },
			{ tag = 'argd', content = 'tradeable', colspan = '40' },
		}

	if ret:paramGrep('bankable', 'no') then
		ret:addRow {
			{ tag = 'th', content = '[[Bank]]able', colspan = '20' },
			{ tag = 'argd', content = 'bankable', colspan = '40' },
		}
	end

	if ret:paramGrep('stacksinbank', 'no') then
		ret:addRow {
			{ tag = 'th', content = 'Stacks in bank', colspan = '20' },
			{ tag = 'argd', content = 'stacksinbank', colspan = '40' },
		}
	end
	if ret:paramGrep('gimstorage', 'yes') then
		ret:addRow {
			{ tag = 'th', content = '[[Group Ironman Mode#Group Ironman Storage|GIM storage]]', colspan = '20' },
			{ tag = 'argd', content = 'gimstorage', colspan = '40' },
		}
	end

	if ret:paramGrep('lendable', 'yes') then
		ret:addRow {
			{ tag = 'th', content = '[[Item Lending|Lendable]]', colspan = '20' },
			{ tag = 'argd', content = 'lendable', colspan = '40' },
		}
	end

	ret:addRow {
		{ tag = 'th', content = '[[Equipment|Equipable]]', colspan = '20' },
		{ tag = 'argd', content = 'equipable', colspan = '40' },
	}

		:addRow {
			{ tag = 'th', content = '[[Stackable items|Stackable]]', colspan = '20' },
			{ tag = 'argd', content = 'stackable', colspan = '40' },
		}

		:addRow {
			{ tag = 'th', content = '[[Disassemble|Disassembly]]', colspan = '20' },
			{ tag = 'argd', content = 'disassembly', colspan = '40' },
		}

		:addRow {
			{ tag = 'th', content = '[[Note|Noteable]]', colspan = '20' },
			{ tag = 'argd', content = 'noteable', colspan = '40' },
		}

	if ret:paramGrep('edible', 'yes') then
		ret:addRow {
			{ tag = 'th', content = '[[Food|Edible]]', colspan = '20' },
			{ tag = 'argd', content = 'edible', colspan = '40' },
		}
	end

	ret:addRow {
		{ tag = 'th', content = '[[Destroy (option)|Destroy]]', colspan = '20' },
		{ tag = 'argd', content = 'destroy', css = { ['max-width'] = '200px' }, colspan = '40' },
	}

	ret:addRow {
		{ tag = 'th', content = '[[Examine]]', colspan = '20' },
		{ tag = 'argd', content = 'examine', colspan = '40' },
	}

	if ret:paramGrep('optionsdisp', true) then
		local options_help = '<sup class="hover-text noprint" style="border: 0;" title="Options shown on the item when right-clicked or long-pressed.">[?]</sup>'

		ret:pad(60)
			:addRow {
				{ tag = 'th', content = 'Options ' .. options_help, class = 'infobox-subheader', colspan = '60' },
			}
			:pad(60)
		if yesno(ret:param('options'), true) ~= false then
			ret:addRow {
				{ tag = 'th', content = '[[Backpack]]', colspan = '20' },
				{ tag = 'argd', content = 'options', colspan = '40' },
			}
		end
		if ret:paramDefined('options_ground') or ret:paramDefined('actions_ground') then
			ret:addRow {
				{ tag = 'th', content = 'On ground', colspan = '20' },
				{ tag = 'argd', content = 'options_ground', colspan = '40' },
			}
		end
		if ret:paramDefined('options_equipped') or ret:paramDefined('actions_equipped') then
			ret:addRow {
				{ tag = 'th', content = '[[Worn Equipment|Equipped]]', colspan = '20' },
				{ tag = 'argd', content = 'options_equipped', colspan = '40' },
			}
		end
		if ret:paramDefined('options_bank') or ret:paramDefined('actions_bank') then
			local bank_options_help = '<sup class="hover-text noprint" style="border: 0;" title="In the backpack section of the bank interface, excluding all variants of the &quot;deposit&quot; option and the &quot;examine&quot; option.">[?]</sup>'
			ret:addRow {
				{ tag = 'th', content = '[[Bank]]' .. bank_options_help, colspan = '20' },
				{ tag = 'argd', content = 'options_bank', colspan = '40' },
			}
		end
		if ret:paramDefined('options_currency_pouch') or ret:paramDefined('actions_currency_pouch') then
			ret:addRow {
				{ tag = 'th', content = '[[Currency pouch]]', colspan = '20' },
				{ tag = 'argd', content = 'options_currency_pouch', colspan = '40' },
			}
		end
	end

	ret:pad(60)
		:addRow {
			{ tag = 'th', content = 'Values', class = 'infobox-subheader', colspan = '60' },
		}
		:pad(60)

	ret:addRow {
		{ tag = 'th', content = '[[Value]]', colspan = '20' },
		{ tag = 'argd', content = 'value', colspan = '40' },
	}

	-- If any are alchable, add both rows, otherwise add a single "no alch" row
	local anyalchable = ret:paramGrep('alchable', true)
	if anyalchable == true then
		ret:addRow {
			{ tag = 'th', content = '[[High Level Alchemy|High alch]]', colspan = '20' },
			{ tag = 'argd', content = 'high', colspan = '40' },
		}
			:addRow {
				{ tag = 'th', content = '[[Low Level Alchemy|Low alch]]', colspan = '20' },
				{ tag = 'argd', content = 'low', colspan = '40' },
			}
	else
		ret:addRow {
			{ tag = 'th', content = '[[Items#Alchemy|Alchemy]]', colspan = '20' },
			{ tag = 'td', content = 'Not alchemisable', colspan = '40' },
		}
	end

	ret:addRow {
		{ tag = 'th', content = '[[Items Kept on Death|On death]]', colspan = '20' },
		{ tag = 'argd', content = 'kept', colspan = '40' },
	}

		:addRow {
			{ tag = 'th', content = '[[Weight]]', colspan = '20' },
			{ tag = 'argd', content = 'weight', colspan = '40' },
		}
		:pad(60)

	-- Include GE section if we have any exchange prices
	local anygemw = ret:paramGrep('gemwprice', function(price) return price > 0 end)
	if anygemw == true then
		ret
			:addRow {
				{ tag = 'th', content = '[[Grand Exchange]]', class = 'infobox-subheader', colspan = '60' },
			}
			:pad(60)

			:addRow {
				{ tag = 'th', content = '[[RuneScape:Grand Exchange Market Watch|Exchange]]', colspan = '20' },
				{ tag = 'argd', content = 'exchange', colspan = '40' },
			}

			:addRow {
				{ tag = 'th', content = '[[Grand Exchange#Trade restrictions|Buy limit]]', colspan = '20' },
				{ tag = 'argd', content = 'buylimit', colspan = '40' },
			}

			:addRow {
				{ tag = 'th', content = '[[Grand Exchange#Volume|Volume]]', colspan = '20' },
				{ tag = 'argd', content = 'volume', colspan = '40' },
			}
			:pad(20)
			:addRow {
				{ tag = 'argd', content = 'realtime', class = 'infobox-full-width-content', colspan = '60' },
			}
			:addRow {
				{ tag = 'argd', content = 'graph', colspan = '60', css = { ['text-align'] = 'center', ['padding'] = '0' } },
			}
	end

	ret
		:addRow {
			{ tag = 'th', content = 'Advanced data', class = 'infobox-subheader', colspan = '60' },
			meta = { addClass = 'advanced-data' },
		}
		:pad(60, 'advanced-data')

		:addRow {
			{ tag = 'th', content = 'Config name', colspan = '20' },
			{ tag = 'argd', content = 'configname', colspan = '40' },
			meta = { addClass = 'advanced-data' },
		}

		:addRow {
			{ tag = 'th', content = 'Item ID', colspan = '20' },
			{ tag = 'argd', content = 'id', colspan = '40' },
			meta = { addClass = 'advanced-data' },
		}

	ret:addRow {
		{ tag = 'th', content = 'Links', colspan = '20' },
		{ tag = 'argd', content = 'chisel_links', colspan = '40' },
		meta = { addClass = 'advanced-data' },
	}

	local has_histid = ret:paramDefined('histid', 'all')
	if has_histid then
		ret:addRow {
			{ tag = 'th', content = 'Historical ID', colspan = '20' },
			{ tag = 'argd', content = 'histid', colspan = '40' },
			meta = { addClass = 'advanced-data' },
		}
		ret:addRow {
			{ tag = 'th', content = 'Historical Links', colspan = '20' },
			{ tag = 'argd', content = 'hist_chisel_links', colspan = '40' },
			meta = { addClass = 'advanced-data' },
		}
	end

	ret:pad(60, 'advanced-data')

	if ret:paramDefined('calcvalue') then
		ret
			:addRow {
				{ tag = 'th', content = 'Calculated value', class = 'infobox-subheader', colspan = '60' },
				meta = { addClass = 'advanced-data' },
			}
			:pad(60, 'advanced-data')

		ret:addRow {
			{ tag = 'th', content = 'Parsed', colspan = '20' },
			{ tag = 'argd', content = 'calcvalue', colspan = '40', css = { ['line-break'] = 'revert' } },
			meta = { addClass = 'advanced-data' },
		}
			:addRow {
				{ tag = 'th', content = 'Bucket', colspan = '20' },
				{ tag = 'argd', content = 'calcvalue_bucket_nowiki', colspan = '40' },
				meta = { addClass = 'advanced-data' },
			}
			:addRow {
				{ tag = 'th', content = 'Formatted', colspan = '20' },
				{ tag = 'argd', content = 'calcvalue_pretty', colspan = '40', css = { ['line-break'] = 'revert' } },
				meta = { addClass = 'advanced-data' },
			}

		ret:pad(60, 'advanced-data')
	end

	if ret:paramDefined('estvalue') then
		ret
			:addRow {
				{ tag = 'th', content = 'Estimated market value', class = 'infobox-subheader', colspan = '60' },
				meta = { addClass = 'advanced-data' },
			}
			:pad(60, 'advanced-data')

		ret:addRow {
			{ tag = 'th', content = 'Evaluated', colspan = '20' },
			{ tag = 'argd', content = 'estvalue_eval', colspan = '40', css = { ['line-break'] = 'revert' } },
			meta = { addClass = 'advanced-data' },
		}
			:addRow {
				{ tag = 'th', content = 'Expression', colspan = '20' },
				{ tag = 'argd', content = 'estvalue', colspan = '40' },
				meta = { addClass = 'advanced-data' },
			}
			:addRow {
				{ tag = 'th', content = 'Formatted', colspan = '20' },
				{ tag = 'argd', content = 'estvalue_pretty', colspan = '40', css = { ['line-break'] = 'revert' } },
				meta = { addClass = 'advanced-data' },
			}

		ret:pad(60, 'advanced-data')
	end

	ret:addVersionBasedVars('ItemInfo_gep', 'vanchor', 'gep')
	addVersionAnchorVars(ret:param('vanchor', 's'))

	ret:addVersionBasedVars('LeagueRegion', 'dropversion', 'leagueRegion_raw')

	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(ret, a1, a2))
	end

	return ret:tostring()
end

function optionsdisparg(options, options_ground, options_equipped, options_bank, options_currency_pouch)
	-- if options="no" and other options aren't defined or no options defined, hide
	if (yesno(options, true) == false
			and not (infobox.isDefined(options_ground)
				or infobox.isDefined(options_equipped)
				or infobox.isDefined(options_bank)
				or infobox.isDefined(options_currency_pouch)))
		or not (infobox.isDefined(options)
			or infobox.isDefined(options_ground)
			or infobox.isDefined(options_equipped)
			or infobox.isDefined(options_bank)
			or infobox.isDefined(options_currency_pouch)
		) then
		return nil
	end

	-- else show
	return true
end

function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end

-- Store price
function storearg(store)
	-- remove any commas
	store = string.gsub(store or '', ',', '')

	-- no for not sold
	if string.lower(store) == 'no' then
		return 'Not sold'
	else
		store = tonumber(store, 10)
	end

	if type(store) == 'number' then
		return store
	else
		return nil
	end
end

-- tradeable
-- tradeablearg(value)
function tradeablearg(v)
	v = string.lower(v or '')
	if v == 'yes' or v == 'no' then
		v = mw.text.split(v, '')
		v[1] = string.upper(v[1])
		return table.concat(v, '')
	elseif v == 'restricted' then
		return '[[Restricted trade items|Restricted]]'
	else
		return nil
	end
end

-- disassembly
-- disassemblyarg(yes/no)
local allowed_disassembly = {
	yes = 'true',
	no = 'false',
	restricted = 'restricted',
	na = 'N/A',
	['n/a'] = 'N/A',
	discontinued = 'N/A',
	irrelevant = 'N/A',
}
function disassemblyarg(d)
	d = string.lower(d or '')
	d = allowed_disassembly[d]
	if d == 'true' then
		return '[[#DisassemblyT|Yes]]' -- Unique anchor ID created by {{Disassembly}}
	elseif d == 'false' then
		return 'No'
	elseif d == 'restricted' then
		return '[[:Category:Location restricted disassembly|Restricted]]'
	elseif d == 'N/A' then
		return 'N/A'
	else
		return nil
	end
end

-- disassemblybucketarg(yes/no)
function disassemblybucketarg(d)
	d = string.lower(d or '')
	return allowed_disassembly[d]
end

-- value
-- separate number storage for operation
-- pulls the exchange value first, and prefers that if it exists
-- valraw(value, exchange value)
function valraw(v, ex)
	if type(ex) == 'number' then
		return ex
	else
		return tonumber(string.gsub(v or '', ',', ''), 10)
	end
end

-- value
-- valuearg(value, convert)
-- actual value already parsed
function valuearg(v, c)
	-- replace commas and turn into a number
	if paramtest.has_content(c) then
		c = string.gsub(c, ',', '')
		c = tonumber(c, 10)
	else
		c = nil
	end

	v = tonumber(v, 10)

	-- if both are defined, show both, value first
	if v and c then
		return string.format('%s<br/><b>Cash out:</b><br/>%s', plural('coin', v), plural('coin', c))
		-- if only value is defined, show just that
	elseif v and not c then
		return plural('coin', v)
		-- if only convert is defined, show just that
		-- may need to change this so that value is requested
	elseif c and not v then
		return string.format('<b>Cash out:</b><br/>%s', plural('coin', c))
	else
		return nil
	end
end

-- ge alchable boolean
-- gemwalchablearg(gemw price, name)
-- uses the already fetched ge price to operate
-- values less than 1 are used for parsing instructions
function gemwalchablearg(g, n)
	if type(g) ~= 'number' then
		g = tonumber(g, 10) or 0
	end

	-- 0 for not sold an
	-- -1 for error
	-- call to hide the graph
	if g == 0 or g == -1 then
		return '-'
		-- all other numbers
	elseif g > 0 then
		local ret = exchange._alchable(n)
		if ret == nil then
			return '-'
		elseif ret == false then
			return 'false' --not very good at handling false
		else
			return true
		end
		-- not a number = nil
		-- shouldn't be used, but it's a fallback
	else
		return '-'
	end
end

-- ge alch multiplier
-- gemwalchmultiplierarg(gemw price, name)
-- uses the already fetched ge price to operate
-- values less than 1 are used for parsing instructions
function gemwalchmultiplierarg(g, n)
	if type(g) ~= 'number' then
		g = tonumber(g, 10) or 0
	end

	-- 0 for not sold an
	-- -1 for error
	-- call to hide the graph
	if g == 0 or g == -1 then
		return '-'
		-- all other numbers
	elseif g > 0 then
		local ret = exchange._alchmultiplier(n)
		if ret == nil then
			return '-'
		else
			return ret
		end
		-- not a number = nil
		-- shouldn't be used, but it's a fallback
	else
		return '-'
	end
end

-- Alchables
-- alchablearg(alchable, high, low)
function alchablearg(a, h, l, ex)
	if ex == true then
		return true
	elseif ex == 'false' then
		return 'false'
	end
	-- not alchable if both are false, or if "alchable" is false
	if string.lower(a or '') == 'no' then
		return 'false'
	elseif string.lower(h or '') == 'no' and string.lower(l or '') == 'no' then
		return 'false'
	else
		return true
	end
end

-- alch multiplier arg
-- only accepts numbers
-- defaults to .6
function multiplierarg(v, ex)
	if type(ex) == 'number' then
		return ex
	end
	return tonumber(v) or 0.6
end

-- high/low alch
-- alchvalues(value, override value, multiplier, alchable)
-- actual value already parsed
-- value, template param, alch multiplier, override multiplier, not alchable bool
function alchvalues(v, _p, a, m, n)
	-- if you can't alch it, return this
	-- used in the case of 1 version being alchable and the other not
	if not infobox.isDefined(n) or n == 'false' then
		return 'Not alchemisable'
	end
	-- remove commas and turn into a number
	v = tonumber(v, 10)
	if paramtest.has_content(_p) then
		_p = string.gsub(_p, ',', '')
		_p = tonumber(_p, 10)
	else
		_p = nil
	end

	-- return override always
	if type(_p) == 'number' then
		return plural('coin', _p)
	end

	-- otherwise try the value and multiply it
	if v then
		local r = math.floor(killRoundingError(v * m * a))
		-- both high and low alch have a lower bound of one coin
		r = math.max(r, 1)
		return plural('coin', r)
	end

	return nil
end

-- alchvaluesraw(value, override value, multiplier, alchable)
-- actual value already parsed
-- value, template param, alch multiplier, override multiplier, not alchable bool
function alchvaluesraw(v, _p, a, m, n)
	-- if you can't alch it, return nil
	if not infobox.isDefined(n) or n == 'false' then
		return nil
	end
	-- remove commas and turn into a number
	v = tonumber(v, 10)
	if paramtest.has_content(_p) then
		_p = string.gsub(_p, ',', '')
		_p = tonumber(_p, 10)
	else
		_p = nil
	end

	-- return override always
	if type(_p) == 'number' then
		return _p
	end
	-- otherwise try the value and multiply it
	if v then
		local r = math.floor(killRoundingError(v * m * a))
		-- both high and low alch have a lower bound of one coin
		r = math.max(r, 1)
		return r
	end

	return nil
end

function estvaluearg(code)
	if not infobox.isDefined(code) then
		return nil
	end

	return mw.text.unstripNoWiki(code)
end

function estvalueeval(code)
	if not infobox.isDefined(code) then
		return nil
	end

	if tonumber(code) then
		return plural('coin', code)
	end

	local val = mw.getCurrentFrame():preprocess(code)
	local val_number = tonumber(val)
	if val_number then
		val_number = math.floor(val_number * 100 + 0.5) / 100
	else
		return userError('Cannot evaluate "' .. val .. '" as a number', "Erroneous parameter");
	end

	return plural('coin', val_number)
end

function estvaluepretty(code)
	if not infobox.isDefined(code) then
		return nil
	end

	return formatCalcvalue(code)
end

-- calcvalue (calculated value for items not sold on GE)
function calcvalbucket(calcval)
	if tonumber(calcval) then
		return calcval
	end
	local str = string.gsub(string.gsub(calcval, '{', '{{'), '}', '}}')
	str = string.gsub(str, '¦', '|')
	return str
end

function calcvalbucketNowiki(calcval)
	return calcvalbucket(calcval)
		:gsub("{", "&#123;")
		:gsub("|", "&#124;")
		:gsub("}", "&#125;")
end

function calcvalParse(calcval)
	if tonumber(calcval) then
		return plural('coin', calcval)
	end
	local val = calcvalbucket(calcval)
	if not infobox.isDefined(calcval) or not infobox.isDefined(val) then
		return nil
	end
	val = mw.getCurrentFrame():preprocess(val)
	if tonumber(val) then
		val = math.floor(val * 100 + 0.5) / 100
	else
		return userError('Cannot parse "' .. val .. '" as a number', "Erroneous parameter");
	end
	return plural('coin', val)
end

function calcvalPretty(calcval)
	if tonumber(calcval) then
		return calcval
	end
	return formatCalcvalue(calcvalbucket(calcval))
end

-- weight
-- weightarg(weight)
function weightarg(w)
	if paramtest.has_content(w) then
		-- replace all "kg" and spaces here
		w = string.gsub(w or '', '[kg ]', '')
		local _w = w:lower()
		if _w == 'no' or _w == 'n/a' then
			return 'N/A'
		end
		-- replace hyphen with minus sign
		w = string.gsub(w, '-', '&minus;')


		-- use non-breaking spaces and html entities for display
		-- still necessary to convert the "kg" to html?
		return string.format('%s&nbsp;&#107;&#103;', w)
	end
	return nil
end

-- weightargraw(weight)
function weightargraw(w)
	if paramtest.has_content(w) then
		-- replace all "kg" and spaces here
		w = string.gsub(w or '', '[kg ]', '')
		return tonumber(w)
	end
	return nil
end

-- add formatted "placeholder" texts
-- if the there is empty options in some version
function optionscheckargs(arg, arg_old)
	if not paramtest.has_content(arg) and paramtest.has_content(arg_old) then
		arg = arg_old
	end
	if paramtest.has_content(arg) then
		local lowarg = string.lower(arg)
		if lowarg == '-' or lowarg == 'no' or lowarg == 'none' then
			return "<i>None</i>"
		elseif lowarg == 'n/a' then
			return "<i>N/A</i>"
		else
			return arg
		end
	else
		return editbutton("'''?''' (edit)")
	end
end

-- on ge or not
-- only accepts "gemw"
-- gemwarg(exchange,tradeable)
function gemwarg(exchange_arg, tradeable_arg)
	local g = string.lower(exchange_arg or '')
	return tradeable_arg == 'Yes' and g == 'gemw'
end

-- gemw names
-- gemwnamearg(name, override name)
function gemwnamearg(n, a)
	-- return override
	if a and a:find('%S') then
		return string.gsub(a, '</?span>', '')
		-- otherwise use the "name" parameter
	elseif n and n:find('%S') then
		return string.gsub(n, '</?span>', '')
		-- default to page name
	else
		return mw.title.getCurrentTitle().fullText
	end
end

-- separate thing to hold all the prices as raw numbers
-- gemwpricearg(gemw, name)
function gemwpricearg(g, n)
	if g == true then
		local modl = exchange
		-- return price if page is found
		-- -1 for errors
		if modl._exists(n) then
			return tonumber(modl._price(n, nil, nil, nil, -1), 10) or -1
		else
			return -1
		end
		-- 0 for no price
	else
		return 0
	end
end

-- gemwpricearg(gemw price, name)
-- exchange page name for bucket
-- uses the already fetched ge price to operate
-- values less than 1 are used for parsing instructions
function gemwpagearg(g, n)
	if type(g) ~= 'number' then
		g = tonumber(g, 10) or 0
	end
	if g < 1 then
		return nil
	else
		return 'Exchange:' .. n
	end
end

-- split items with multiple images for Bucket (e.g. [[File:Arrow 1.png]] [[File:Arrow 2.png]])
function image_bucket(arg)
	local _img = {}
	for i in string.gmatch(arg, "[Ff]ile:.-%.png") do
		table.insert(_img, i)
	end
	if #_img == 0 then
		return nil
	end
	return table.concat(_img, '&&SPLITPOINT&&')
end

-- Mark the infobox image as the page image (search and preview thumbnail),
-- but only when the article shows no detail image and has no manual choice
local page_content
function pageimagearg(img)
	if not (img and img:find('%S')) then
		return nil
	end
	if page_content == nil then
		page_content = (mw.title.getCurrentTitle():getContent() or ''):lower()
	end
	if page_content:find('[ _]detail') or page_content:find('[ _]equipped') or page_content:find('class%s*=%s*pageimage') then
		return img
	end
	-- add the class to the first file link only
	return (img:gsub('(%[%[[Ff]ile:[^%]]-)%]%]', '%1|class=pageimage]]', 1))
end

-- exchange display
-- exchangearg(gemw price, name)
-- uses the already fetched ge price to operate
-- values less than 1 are used for parsing instructions
function exchangearg(g, n)
	if type(g) ~= 'number' then
		g = tonumber(g, 10) or 0
	end
	-- 0 for not sold
	if g == 0 then
		return '<span class="infobox-quantity" data-val-each="0">Not sold</span>'
		-- -1 for no page found
	elseif g == -1 then
		return badarg('exchange', 'was set to «gemw» but no page was found for «' .. n .. '».')
		-- all other numbers
	elseif g > 0 then
		-- plural done in format because we need a span around the value
		local lnk = ' ([[Exchange:' .. n .. '|info]])'
		return string.format('<span class="infobox-quantity" data-val-each="%s"><span class="infobox-quantity-replace">%s</span> coin%s%s</span>', g, commas(g), g > 1 and 's' or '', lnk)
		-- not a number = nil
		-- shouldn't be used, but it's a fallback
	else
		return 0
	end
end

function geparg(g)
	if type(g) ~= 'number' then
		g = tonumber(g, 10) or 0
	end
	-- 0 for not sold
	if g < 0 then
		return nil
	elseif g > 0 then
		return g
	else
		return nil
	end
end

-- ge graphs
-- gemwgrapharg(gemw price, name)
-- uses the already fetched ge price to operate
-- values less than 1 are used for parsing instructions
function gemwgrapharg(g, n)
	if type(g) ~= 'number' then
		g = tonumber(g, 10) or 0
	end

	-- 0 for not sold an
	-- -1 for error
	-- call to hide the graph
	if g == 0 or g == -1 then
		return 'No data to display'
		-- all other numbers
	elseif g > 0 then
		return chart { n, size = 'small' }
		-- not a number = nil
		-- shouldn't be used, but it's a fallback
	else
		return nil
	end
end

-- ge buy limits
-- buylimitarg(gemw price, name)
-- uses the already fetched ge price to operate
-- values less than 1 are used for parsing instructions
function buylimitarg(g, n)
	if type(g) ~= 'number' then
		g = tonumber(g, 10) or 0
	end

	-- 0 for not sold an
	-- -1 for error
	-- call to hide the graph
	if g == 0 or g == -1 then
		return '-'
		-- all other numbers
	elseif g > 0 then
		local ret = exchange._limit(n)
		if ret == nil then
			return '-'
		else
			return commas(ret)
		end
		-- not a number = nil
		-- shouldn't be used, but it's a fallback
	else
		return nil
	end
end

function buylimitbucketarg(b)
	if type(b) == 'string' then
		b = b:gsub(',', '')
	end
	if tonumber(b) then
		return tonumber(b)
	end
	return infobox.donotsetbucket
end

function volumearg(gemwprice, name)
	-- 0 for not sold, -1 for error
	if gemwprice <= 0 then
		return '-'
	end

	local ret = exchange._volume(name)
	if ret == nil then
		return '-'
	end
	return commas(ret)
end

function realtimearg(gemwprice, gemwname)
	if gemwprice <= 0 then
		return '-'
	end

	local gemw_id = exchange._itemId(gemwname)

	return '<div class="realtime-prices plainlinks">[https://prices.runescape.wiki/rs/item/' .. gemw_id .. ' <span class="cdx-button realtime-ge-openbtn" style="font-size:inherit;min-height:0;padding:3px 12px">View real-time prices</span>]</div>'
end

-- ge value
-- exgvaluearg(gemw price, name)
-- uses the already fetched ge price to operate
-- values less than 1 are used for parsing instructions
function exgvaluearg(g, n)
	if type(g) ~= 'number' then
		g = tonumber(g, 10) or 0
	end

	-- 0 for not sold an
	-- -1 for error
	-- call to hide the graph
	if g == 0 or g == -1 then
		return '-'
		-- all other numbers
	elseif g > 0 then
		local ret = exchange._value(n)
		if ret == nil then
			return '-'
		else
			return ret
		end
		-- not a number = nil
		-- shouldn't be used, but it's a fallback
	else
		return '-'
	end
end

-- class names based on value
-- gemwdisp(price)
function gemwdisp(price)
	if price == 0 then
		return ''
	else
		return 'infobox-cell-shown'
	end
end

-- Shows if the param matches the alt
-- alt defaults to yes
-- Everything else = hide
function yesnodisp(arg, alt)
	arg = string.lower(arg or '')
	alt = string.lower(alt or 'yes')
	if arg == alt then
		return 'infobox-cell-shown'
	else
		return ''
	end
end

-- Shows if has a date
function removaldisp(arg)
	if string.find(arg or '', '%[%[') then
		return 'infobox-cell-shown'
	else
		return ''
	end
end

-- death
-- deathstatusarg(death)
function deathstatusarg(d)
	d = string.lower(d or '')
	return death_map.allowed[d]
end

-- ikodarg(deathstatus, ikod, val, gemwprice)
function ikodarg(d, ikod, v, g)
	if d == 'reclaimable' then
		v = tonumber(v)
		local i
		-- replace commas and convert to number
		if paramtest.has_content(ikod) then
			i = string.gsub(ikod, ',', '')
			i = tonumber(i, 10)
		else
			i = nil
		end

		-- if i is defined, show that value
		if i then
			return i
			-- test geprice next
		elseif (tonumber(g, 10) or 0) > 0 then
			i = tonumber(g, 10)
			-- test value next
		elseif v then
			-- value can be 0, but in ikod it is shown as 1 at minimuim
			i = math.max(v, 1)
		end
		return i
	end
	return -1
end

-- reclaimvaluearg(ikodvalue, reclaim)
function reclaimvaluearg(i, _r)
	i = tonumber(i or -1) or -1
	if i >= 0 then
		local r

		-- test for overridden reclaim
		if paramtest.has_content(_r) then
			_r = string.gsub(_r, ',', '')
			r = tonumber(_r)
		end

		-- if no number, use formula
		if not r then
			-- limit r to be in the range [100, 2^31 - 1]
			r = math.min(math.max(i * .001, 100), 2 ^ 31 - 1)
		end

		r = math.floor(killRoundingError(r))
		return r
	end
	return -1
end

-- keptondeatharg(deathstatus, ikod, reclaimvalue)
function keptondeatharg(d, ikod, r)
	if d == 'reclaimable' then
		local ret = { 'Reclaimable' }
		local i
		-- replace commas and convert to number
		if paramtest.has_content(ikod) then
			i = string.gsub(ikod, ',', '')
			i = tonumber(i, 10)
		else
			i = nil
		end
		if i then
			table.insert(ret, string.format('<b>Value:</b> %s', commas(i)))
		end

		table.insert(ret, string.format('<b>Reclaim:</b> %s', commas(r)))

		return table.concat(ret, '<br>')
	else
		return death_map.strings[d]
	end
end

-- red ERR span with title hover for explanation
function badarg(argname, argmessage)
	return '<span ' ..
		'title="The parameter «' .. argname .. '» ' .. argmessage .. '" ' ..
		'style="color:red; font-weight:bold; cursor:help; border-bottom:1px dotted red;">' ..
		'ERR</span>'
end

-- plural
-- returns number with the word
function plural(arg, n, alt)
	local _n = commas(tonumber(n, 10) or 1)
	if tonumber(n, 10) == 1 then
		return string.format('%s %s', _n, arg)
	elseif alt then
		return string.format('%s %s', _n, alt)
	else
		return string.format('%s %ss', _n, arg)
	end
end

-- Does exactly what's on the tin
function killRoundingError(n)
	return math.floor(n * 1000 + 0.0000099) / 1000
end

function restrictionarg(arg)
	if paramtest.is_empty(arg) then
		return nil
	end
	return restriction_map[string.lower(arg)]
end

function restrsurfarg(cleaned)
	if infobox.isDefined(cleaned) then
		return nil
	end
	return restriction_map.surface
end

function iddisp(id)
	if infobox.isDefined(id) then
		if id:lower() ~= 'no' and id:lower() ~= 'none' then
			local r = string.gsub(id, ', *', ', ')
			return r
		elseif id:lower() == 'no' then
			return 'None'
		end
	end
	return nil
end

function idbucket(id)
	if infobox.isDefined(id) and id:lower() ~= 'no' and id:lower() ~= 'none' then
		local r = string.gsub(id, ', *', infobox.splitpoint)
		return r
	end
	return nil
end

function make_chisel_links(id, name)
	local link1 = 'https://chisel.weirdgloop.org/gazproj/mrid'
	local link2 = 'https://chisel.weirdgloop.org/gazproj/recipe/'
	if infobox.isDefined(id) then
		local ids = mw.text.split(id, infobox.splitpoint)
		local id1 = tonumber(ids[1])
		if id1 then
			if #ids == 1 then
				link1 = string.format('%s?q=%s-%s&h=%s', link1, id1 - 15, id1 + 15, id1)
				link2 = link2 .. id1
			else
				for i, j in ipairs(ids) do
					if i == 1 then
						link1 = string.format('%s?h=%s&q=%s', link1, j, j)
						link2 = link2 .. j
					else
						link1 = link1 .. '&q=' .. j
					end
				end
			end
		else
			link1 = string.format('%s?q=%s', link1, ids[1])
			link2 = link2 .. ids[1]
		end
	else
		local _name = name:gsub(' ', '%%20')
		link1 = string.format('%s?q=%s', link1, _name)
		link2 = nil
	end
	if link2 then
		return string.format('[%s MRID]&nbsp;&bull;&nbsp;[%s recipe]', link1, link2)
	else
		return string.format('[%s MRID]', link1)
	end
end

-- bucket JSON
function bucketarg(name, version, id, histid, members, release, removal, examine, quest, destroy, restriction, leaguesregion, deathstatus, ikodvalue, reclaimvalue, tradeable, equipable, bankable, stacksinbank, gimstorage, lendable, stackable, disassembly, edible, noteable, value, high, low, weight, gemw, gemwname, buylimit)
	local toJSON = {
		name = name,
		version = version,
		id = id,
		histid = histid,
		members = string.lower(tostring(members) or ''),
		examine = examine,
		death = deathstatus,
		destroy = destroy,
		tradeable = string.lower(tostring(tradeable) or ''),
		equipable = string.lower(tostring(equipable) or ''),
		bankable = string.lower(tostring(bankable) or ''),
		gimstorage = string.lower(tostring(gimstorage) or ''),
		stacksinbank = string.lower(tostring(stacksinbank) or ''),
		lendable = string.lower(tostring(lendable) or ''),
		stackable = string.lower(tostring(stackable) or ''),
		edible = string.lower(tostring(edible) or ''),
		noteable = string.lower(tostring(noteable) or ''),
		value = value,
		weight = weight,
		leaguesregion = leaguesregion and string.lower(tostring(leaguesregion)) or nil,
	}

	local w
	if high == 'Not alchemisable' then
		toJSON.highalch = false
	else
		w = high:gsub(',', ''):gsub('coins?', '')
		toJSON.highalch = tonumber(w) or false
	end
	if low == 'Not alchemisable' then
		toJSON.lowalch = false
	else
		w = low:gsub(',', ''):gsub('coins?', '')
		toJSON.highalch = tonumber(w) or false
	end

	if toJSON.tradeable == 'yes' and gemw then
		toJSON.gemw = { name = gemwname }
		if buylimit ~= '-' then
			w = buylimit:gsub(',', '')
			toJSON.gemw.limit = tonumber(w)
		end
	else
		toJSON.gemw = false
	end

	if disassembly:find('[Yy]es') then
		toJSON.disassembly = 'yes'
	elseif disassembly:find('restricted') then
		toJSON.disassembly = 'restricted'
	else
		toJSON.disassembly = string.lower(tostring(disassembly) or '')
	end

	if paramtest.is_empty(restriction) and tostring(restriction):find('action=edit') then
		toJSON.restriction = restriction_map.surface
	else
		toJSON.restriction = restriction
	end

	local rel, upd, rem, updr
	rel, upd = release:match('(.-) %(%[%[Update:(.-)|Update%]%]%)')
	if rel == nil then
		rel = release:match('(.-) %(Update unknown%)')
	end
	if rel then
		toJSON.release_date = rel:gsub('%[', ''):gsub('%]', '')
		if upd then
			toJSON.release_update_post = upd
		end
	end

	rem, updr = removal:match('(.-) %(%[%[Update:(.-)|Update%]%]%)')
	if rem == nil then
		rem = removal:match('(.-) %(Update unknown%)')
	end
	if rem then
		toJSON.removal_date = rem:gsub('%[', ''):gsub('%]', '')
		if updr then
			toJSON.removal_update_post = updr
		end
	end

	for k, v in pairs(toJSON) do
		if v == '' or (type(v) == 'string' and string.find(v, 'action=edit')) then
			toJSON[k] = nil
		end
	end

	return mw.text.jsonEncode(toJSON)
end

function addVersionAnchorVars(vanchors)
	for k, v in ipairs(vanchors) do
		var.vardefine('ItemInfo_version_' .. k, v)
	end
end

-- Categories
-- oman this is still blatant copy pasta
function addcategories(ibox, args, catargs)
	local ret = { 'Items' }
	local cat_map = {
		-- Added if the parameter has content
		defined = {
			aka = 'Pages with AKA',
			alchmultiplier = 'Has Alchemy Multiplier',
			-- calcvalue = 'Pages with deprecated parameters',
			estvalue = 'Items with an estimated market value',
			histid = "Items with historical IDs",
			store = "Pages with deprecated parameters",
			seller = "Pages with deprecated parameters",
			currency = "Pages with deprecated parameters",
			tooltip = "Pages with deprecated parameters",
			leagueRegion = "Pages with League region",
		},
		-- Added if the parameter has no content
		notdefined = {
			image = 'Needs image',
			members = 'Needs members status',
			release = 'Needs release date',
			examine = 'Needs item examine added',
			level = 'Needs combat level',
			weight = 'Needs weight added',
			value = 'Items missing value',
			quest = 'Items missing quest',
			destroy = 'Missing destroy text',
			kept = 'Items missing death info',
			disassembly = 'Items missing disassembly info',
			options = 'Needs options added',
			configname = 'Needs config name',
		},
		-- Parameters that have text
		-- map a category to a value
		grep = {
			members = { yes = 'Members\' items', no = 'Free-to-play items' },
			stackable = { yes = 'Stackable items' },
			lendable = { yes = 'Lendable items' },
			equipable = { yes = 'Equipable items' },
			gimstorage = { yes = 'Group Ironman storage' },
			gemw = { ['true'] = 'Grand Exchange items' },
			exchange = { ['but no page was found for'] = 'Exchange page not found' },
			tradeable = { yes = 'Tradeable items', no = 'Untradeable items', restricted = 'Restricted trade items' },
			bankable = { no = 'Unbankable items' },
			disassembly = { yes = 'Items that can be disassembled', no = 'Items that cannot be disassembled', restricted = 'Location restricted disassembly', ['n/a'] = 'Items with N/A disassembly' },
			kept = { ['always lost'] = 'Items that are never kept on death', ['always kept outside'] = 'Items that are always kept outside the Wilderness on death', reclaimable = 'Items that are reclaimable on death' },
			restriction = { ['minigame'] = 'Minigame items' },
		},
	}

	-- Run and add mapped categories

	-- defined categories
	for n, v in pairs(cat_map.defined) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret, v)
		end
	end

	-- undefined categories
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

	-- quest items
	-- just look for a link
	if string.lower(args.quest.d) == 'yes' then
		table.insert(ret, 'Items missing quest')
	elseif args.quest.d:find('%[%[') then
		table.insert(ret, 'Quest items')
	elseif args.quest.switches then
		for _, v in ipairs(args.quest.switches) do
			if string.lower(v) == 'yes' then
				table.insert(ret, 'Items missing quest')
			elseif v:find('%[%[') then
				table.insert(ret, 'Quest items')
				break
			end
		end
	end

	-- extra func for death
	-- searching for 'always kept' would match more than what we want
	if args.kept.d == 'Always kept' then
		table.insert(ret, 'Items that are always kept on death')
	elseif args.kept.switches then
		for _, v in ipairs(args.kept.switches) do
			if v == 'Always kept' then
				table.insert(ret, 'Items that are always kept on death')
				break
			end
		end
	end
	-- ids. RSC items have no id, and historical items shouldn't flag missing ids either
	if not (catargs.id.all_defined or catargs.rscid.all_defined or catargs.histid.all_defined) then
		table.insert(ret, 'Items without ID')
	end

	-- alchemy
	-- non alchable
	if args.alchable.d ~= true then
		table.insert(ret, 'Items that cannot be alchemised')
	elseif args.alchable.switches then
		for _, v in ipairs(args.alchable.switches) do
			if v ~= true then
				table.insert(ret, 'Items that cannot be alchemised')
				break
			end
		end
	end

	-- gemw
	-- if item is both (not untradeable) and (not GEMW) then add Non-GE items
	if not args.gemw.d and string.lower(args.tradeable.d) ~= 'no' then
		table.insert(ret, 'Non-GE items')
	end
	-- switches; if tradeable switches exist, if gemwX and tradeableX are as above, add Non-GE items
	--						if no switches, gemwX and tradeable (default)
	if args.gemw.switches then
		if args.tradeable.switches then
			for i, v in ipairs(args.gemw.switches) do
				local gemw_switch = v
				if gemw_switch == infobox.nilParam() then
					gemw_switch = args.gemw.d
				end

				local tradeable_switch = args.tradeable.switches[i]
				if tradeable_switch == infobox.nilParam() then
					tradeable_switch = args.tradeable.d
				end

				if not gemw_switch and string.lower(tradeable_switch) ~= 'no' then
					table.insert(ret, 'Non-GE items')
				end
			end
		else
			for _, v in ipairs(args.gemw.switches) do
				if not v and string.lower(args.tradeable.d) ~= 'no' then
					table.insert(ret, 'Non-GE items')
				end
			end
		end
	end

	local limit = string.gsub(tostring(args.buylimit.d), ',', '')
	if tonumber(limit) then
		if tonumber(limit) < 1000 then
			table.insert(ret, 'Low buy limit')
		else
			table.insert(ret, 'High buy limit')
		end
	end
	if args.buylimit.switches then
		for i, _ in ipairs(args.buylimit.switches) do
			limit = string.gsub(tostring(args.buylimit.switches[i] or args.buylimit.d), ',', '')
			if tonumber(limit) then
				if tonumber(limit) < 1000 then
					table.insert(ret, 'Low buy limit')
				else
					table.insert(ret, 'High buy limit')
				end
			end
		end
	end

	-- special addition for location restriction
	-- if everything is the same then add to the base page as well
	-- only matters if is a switchfo
	if ibox.switchfo then
		if not catargs.restriction.one_defined then
			-- no restriction set == all of them are surface
		else
			if args.restriction.switches then
				local val = args.restriction.switches[1] or args.restriction.d or restriction_map.surface
				local all_the_same = true
				for _, v in ipairs(args.restriction.switches) do
					local curr = v or args.restriction.d or restriction_map.surface
					if val ~= curr then
						all_the_same = false
						break
					end
				end
				if not all_the_same then
					table.insert(ret, 'Items with mixed restrictions')
				end
			end
		end
	end

	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		ret[i] = string.format('[[Category:%s]]', v)
	end

	return table.concat(ret, '')
end

return p
--</nowiki>