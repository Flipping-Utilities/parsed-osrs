--------------------------
-- Module for {{Infobox Shop}}
------------------------
local p = {}

local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean

local imgarg, iconarg, typearg, maparg, mapdisp, addcategories, typebucketarg, pluralbucketarg
local namebucketarg, membersarg, locationarg, ownerarg, salespersonarg, shopversionparg, bucketarg, leaguesArg

--[=[
	Shop types are the name of the minimap icon they are labeled with, as listed on [[Icon]];
	the icons included here fall under the "Shops / Trading" category, with some additions.

	Shop type values are used in:
	- the "icon" parameter, formatted as [[File:<type name> map icon.png]]
	- the "type" parameter, formatted as [[<type plural>|<type name>]]
	- page category, formatted as [[Category:<type plural>]]
--]=]
local types = {
	general = { name = 'General store' },
	amulet = { name = 'Amulet shop' },
	apothecary = { name = 'Apothecary', plural = 'Apothecaries' },
	archery = { name = 'Archery shop' },
	armour = { name = 'Armour shop' }, -- unofficial type
	axe = { name = 'Axe shop' },
	candle = { name = 'Candle shop' },
	chainmail = { name = 'Chainmail shop' },
	clothes = { name = 'Clothes shop' },
	construction = { name = 'Construction shop' }, -- unofficial type
	cookery = { name = 'Cookery shop' },
	crafting = { name = 'Crafting shop' },
	divination = { name = 'Divination shop', icon = 'Divination Tutor map icon' },
	dungeoneering = { name = 'Dungeoneering shop' },     -- unofficial type
	event = { name = 'Events', plural = 'Event shops' }, -- unofficial type
	farming = { name = 'Farming shop' },
	fishing = { name = 'Fishing shop' },
	food = { name = 'Food shop' },
	fur = { name = 'Fur trader' },
	gem = { name = 'Gem shop' },
	gravestone  = { name = 'Gravestone exchange', plural = 'Gravestone exchange', icon = 'Gravestone shop map icon', category = 'Gravestones' },
	hairdresser = { name = 'Hairdresser', plural = 'Hairdresser (shop)', category = 'Makeovers' },
	helmet = { name = 'Helmet shop' },
	herbalist = { name = 'Herbalist' },
	holiday = { name = 'Holiday event', plural = 'Holiday event shops' }, -- unofficial type
	hunter = { name = 'Hunter shop' },
	jewellery = { name = 'Jewellery shop' },
	kebab = { name = 'Kebab seller' },
	mace = { name = 'Mace shop' },
	magic = { name = 'Magic shop' },
	mattock = { name = 'Mattock shop' },
	minigame = { name = 'Minigames', plural = 'Minigame shops' }, -- unofficial type
	mining = { name = 'Mining shop' },
	pet = { name = 'Pet shop' },
	platebody = { name = 'Platebody shop' },
	platelegs = { name = 'Platelegs shop' },
	plateskirt = { name = 'Plateskirt shop' },
	pub = { name = 'Pub' },
	scimitar = { name = 'Scimitar shop' },
	shield = { name = 'Shield shop' },
	silk = { name = 'Silk trader' },
	silver = { name = 'Silver shop' },
	skillcape = { name = 'Skillcape shop' }, -- unofficial type
	slayer = { name = 'Slayer shop' },       -- unofficial type
	spice = { name = 'Spice shop' },
	staff = { name = 'Staff shop' },
	stonemason = { name = 'Stonemason' },
	summoning = { name = 'Summoning shop' },
	sword = { name = 'Sword shop' },
	tannery = { name = 'Crafting shop', icon = 'Tannery map icon' },
	team = { name = 'Team cape' },                                       -- unofficial type
	th = { name = 'Treasure Hunter', plural = 'Treasure Hunter shops' }, -- unofficial type
	toys = { name = 'Toy shop' },                                        -- unofficial type
	vambrace = { name = 'Vambrace exchange' },
	vegetable = { name = 'Vegetable store' },
	weapon = { name = 'Weapon shop' } -- unofficial type
}

-- Main function called with invokes
function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	ret:defineParams {
		{ name = 'name', func = 'name' },
		{ name = 'name_bucket', func = { name = namebucketarg, params = { 'name' }, flag = { 'p' } } },
		{ name = 'image', func = { name = imgarg, params = { 'image', 'imageext', 'imageint' }, flag = { 'd', 'd', 'd' } } },
		{ name = 'release', func = 'release' },
		{ name = 'removal', func = 'removal' },
		{ name = 'members', func = { name = membersarg, params = { 'members' }, flag = { 'p' } } },
		{ name = 'icon', func = { name = iconarg, params = { 'type', 'icon' }, flag = { 'd', 'd' } } },
		{ name = 'typebucket', func = { name = typebucketarg, params = { 'type' }, flag = { 'd' } } },
		{ name = 'pluralbucket', func = { name = pluralbucketarg, params = { 'type' }, flag = { 'd' } } },
		{ name = 'type', func = typearg },
		{ name = 'locationbucket', func = { name = locationarg, params = { 'location' }, flag = { 'p' } } },
		{ name = 'location', func = 'has_content' },
		{ name = 'leagueRegion', func = leaguesArg },
		{ name = 'leagueRegion_raw', func = { name = 'has_content', params = { 'leagueRegion' }, flag = 'p' } },
		{ name = 'owner', func = 'has_content' },
		{ name = 'ownerbucket', func = { name = ownerarg, params = { 'owner' }, flag = { 'p' } } },
		{ name = 'salesperson', func = { name = salespersonarg, params = { 'salesperson' }, flag = { 'p' } } },
		{ name = 'requirements', func = 'has_content' },
		{ name = 'requirementsbucket', func = 'has_content' },
		{ name = 'map', func = { name = maparg, params = { 'map', 'intmap' }, flag = { 'd', 'd' } } },
		{ name = 'mapdisp', func = { name = mapdisp, params = { 'map', 'intmap' }, flag = { 'd', 'd' } }, dupes = true },
		{ name = 'shopversion', func = { name = shopversionparg, params = { 'shopversion', 'version' }, flag = 'd' } },
		{ name = 'bucketarg', func = { name = bucketarg, params = {
			'name_bucket', 'members', 'pluralbucket', 'locationbucket', 'ownerbucket', 'requirementsbucket', 'leagueRegion_raw',
			flag = 'd' } } }
	}

	ret:defineLinks()

	ret:create()
	ret:cleanParams()

	ret:useBucket('infobox_shop', {
		members = 'is_members_only',
		locationbucket = 'location',
		ownerbucket = 'owner',
		bucketarg = 'json',
		typebucket = 'type',
		leagueRegion_raw = 'league_region',
	})

	ret:customButtonPlacement(true)
	ret:addButtonsCaption()

	ret:defineName('Infobox Shop')

	-- PARAMETER: name
	ret:addRow {
		{ tag = 'argh', content = 'name', class = 'infobox-header', colspan = '20' }
	}

	-- PARAMETER: image
	ret:addRow {
		{ tag = 'argd', content = 'image', class = 'infobox-image infobox-full-width-content', colspan = '20' }
	}
		:pad(20)

	-- PARAMETER: release
	ret:addRow {
		{ tag = 'th', content = 'Release', colspan = '8' },
		{ tag = 'argd', content = 'release', colspan = '12' }
	}

	-- PARAMETER: removal
	if ret:paramDefined('removal') then
		ret:addRow {
			{ tag = 'th', content = 'Removal', colspan = '8' },
			{ tag = 'argd', content = 'removal', colspan = '12' }
		}
	end

	-- PARAMETER: members
	ret:addRow {
		{ tag = 'th', content = '[[Members]]', colspan = '8' },
		{ tag = 'argd', content = 'members', colspan = '12' }
	}

	-- PARAMETER: icon
	if not (args['icon'] and string.lower(args['icon']) == 'no') then
		ret:addRow {
			{ tag = 'th', content = '[[Icon|Minimap icon]]', colspan = '8' },
			{ tag = 'argd', content = 'icon', colspan = '12' }
		}
	end

	-- PARAMETER: type
	ret:addRow {
		{ tag = 'th', content = 'Shop type', colspan = '8' },
		{ tag = 'argd', content = 'type', colspan = '12' }
	}

	-- PARAMETER: location
	ret:addRow {
		{ tag = 'th', content = 'Location', colspan = '8' },
		{ tag = 'argd', content = 'location', colspan = '12' }
	}
	mw.log(ret:param('salesperson'))
	
	-- PARAMETER: leagueRegion
	if ret:paramDefined('leagueRegion', 'all') then
		local leagues = require('Module:LeagueRegion')
		ret:addRow{
			{ tag = 'th', content = '[[' .. leagues.DEFAULT_LEAGUE .. '|League]] region', colspan = '8',
				css = { ['vertical-align'] = 'middle' }
			},
			{ tag = 'argd', content = 'leagueRegion', colspan = '12',
				css = { ['vertical-align'] = 'middle' }
			},
			meta = { addClass = 'leagues-global-flag' }
		}
	end

	-- PARAMETER: owner
	ret:addRow {
		{ tag = 'th', content = ret:param('salesperson') and 'Salesperson' or 'Owner', colspan = '8' },
		{ tag = 'argd', content = 'owner', colspan = '12' }
	}
		:pad(20)

	-- PARAMETER: map
	local map_defined = ret:paramGrep('mapdisp', function(x) return (x or 'false') ~= 'false' end)
	if map_defined == true then
		ret
			:addRow {
				{ tag = 'th', content = 'Map', class = 'infobox-subheader', colspan = '20' }
			}
			:addRow {
				{ tag = 'argd', content = 'map', class = 'infobox-image infobox-full-width-content', colspan = '20' } }
	end

	-- Save vars for use by later templates
	ret:addVersionBasedVars('ShopInfo_location', 'shopversion', 'location')
	ret:addVersionBasedVars('ShopInfo_members', 'shopversion', 'members')
	ret:addVersionBasedVars('ShopInfo_LeagueRegion', 'shopversion', 'leagueRegion_raw')
	ret:finish()

	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function bucketarg(name_bucket, members, pluralbucket, locationbucket, ownerbucket, requirementsbucket, leagueRegion_raw)
	local toJSON = {
		name = name_bucket,
		members = members,
		plural = pluralbucket,
		location = locationbucket,
		owner = ownerbucket,
		requirements = requirementsbucket,
		league_region = leagueRegion_raw
	}
	for k, v in pairs(toJSON) do
		if v == '' or (type(v) == 'string' and string.find(v, 'action=edit')) then
			toJSON[k] = nil
		end
	end

	return mw.text.jsonEncode(toJSON)
end

function imgarg(image, imageext, imageint)
	if infobox.isDefined(imageext) and infobox.isDefined(imageint) then
		local ext = cleanimg { file = imageext, width = 300, height = 300 }
		local int = cleanimg { file = imageint, width = 300, height = 300 }

		local ret = '{{Switch infobox|text1=Exterior|item1=' .. ext .. '|text2=Interior|item2=' .. int .. '}}'
		return mw.getCurrentFrame():preprocess(ret)
	elseif infobox.isDefined(imageext) then
		return cleanimg { file = imageext, width = 300, height = 300 }
	elseif infobox.isDefined(image) then
		return cleanimg { file = image, width = 300, height = 300 }
	end
	return nil
end

function leaguesArg(region)
	if region ~= nil and region ~= '' then
		local leagues = require('Module:LeagueRegion')
		return leagues.regionsForInfobox(region)
	end
end

function namebucketarg(arg)
	if not infobox.isDefined(arg) then
		arg = mw.title.getCurrentTitle().text
	end
	return arg
end

function locationarg(arg)
	if infobox.isDefined(arg) then
		return mw.text.unstrip(arg)
	end
	return nil
end

function ownerarg(arg)
	if infobox.isDefined(arg) then
		return arg
	end
	return nil
end

function salespersonarg(arg)
	if infobox.isDefined(arg) then
		return yesno(arg)
	end
	return false
end

function membersarg(arg)
	if infobox.isDefined(arg) then
		return yesno(arg) and 'Yes' or 'No'
	end
	return nil
end

function iconarg(type, icon)
	-- if "icon" param is specified, override auto map icon with user input
	if infobox.isDefined(icon) then
		return icon
	end
	-- if "type" param is specified, use that value to automatically get the corresponding map icon
	if infobox.isDefined(type) then
		local typ = types[type]
		if typ ~= nil then
			if typ['icon'] ~= nil then
				return '[[File:' .. typ['icon'] .. '.png]]'
			elseif typ['name'] ~= nil then
				return '[[File:' .. typ['name'] .. ' map icon.png]]'
			end
		end
		
		return '<i class="text-red">Invalid icon ([[Template:Infobox Shop#icon|help]]).</i>'
	end
	return nil
end

function typearg(arg)
	if infobox.isDefined(arg) then
		local typ = types[arg]
		if types[arg] ~= nil then
			-- if plural form of shop type is specified
			local ret, cat
			if typ['plural'] ~= nil then
				ret = '[[' .. typ['plural'] .. '|' .. typ['name'] .. ']]'
				cat = '[[Category:' .. typ['plural'] .. ']]'
				-- if no plural specified, just add "s" to the end
			else
				ret = '[[' .. typ['name'] .. 's|' .. typ['name'] .. ']]'
				cat = '[[Category:' .. typ['name'] .. 's]]'
			end
			if typ['category'] ~= nil then
				cat = '[[Category:' .. typ['category'] .. ']]'
			end
			return ret .. cat
			-- otherwise, fall back to user input with no categorisation
		else
			return arg
		end
	end
	return nil
end

function pluralbucketarg(arg)
	if infobox.isDefined(arg) then
		if types[arg] ~= nil then
			local nowikitype = types[arg]['name']
			-- if plural form of shop type is specified
			if types[arg]['plural'] ~= nil then
				return types[arg]['plural']
				-- if no plural specified, just add "s" to the end
			else
				return nowikitype .. 's'
			end
			-- otherwise, fall back to user input with no categorisation
		else
			return arg .. 's'
		end
	end
	return nil
end

function typebucketarg(arg)
	if infobox.isDefined(arg) then
		if types[arg] ~= nil then
			return types[arg]['name']
		else
			return arg
		end
	end
	return nil
end

function maparg(map, intmap)
	if infobox.isDefined(intmap) then
		map = intmap
	end
	if infobox.isDefined(map) then
		local low = string.lower(map)
		if yesno(low) == false or low == 'none' then
			return "''No map to display.''"
		elseif string.find(low, '.png') then
			return cleanimg { file = map, width = 250 }
		else
			return map
		end
	else
		return nil
	end
end

function mapdisp(map, intmap)
	if infobox.isDefined(intmap) then
		map = intmap
	end
	if infobox.isDefined(map) then
		local yn_map = map == "''No map to display.''"
		if yn_map then
			return 'false'
		else
			return 'true'
		end
	else
		return 'false'
	end
end

function shopversionparg(shop, ver)
	if infobox.isDefined(shop) then
		return shop
	elseif infobox.isDefined(ver) then
		return ver
	end

	return nil
end

function addcategories(args, catargs)
	local ret = { 'Shops' }

	local cat_map = {
		-- Added if the parameter has content
		defined = {
			leagueRegion = 'Pages with League region',
		},
		-- Add the associated category if the parameter doesn't have content
		notdefined = {
			image = 'Needs shop image',
			members = 'Needs members status',
			release = 'Needs release date',
			update = 'Needs update added',
			removalupdate = 'Needs removal update added',
			type = 'Needs shop type',
			map = 'Needs map',
			leagueRegion = 'Needs League region',
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

	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end

	return table.concat(ret, '')
end

return p