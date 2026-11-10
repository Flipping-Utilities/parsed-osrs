-- <nowiki>
-- Implements {{Location navbox}}

local p = {}
local navbox = require('Module:Navbox')._navbox

function p.main(frame)
	local args = frame:getParent().args
	local groupnr = 1

	local nArgs = {}
	nArgs.doc = (isNotEmptyOrNil(args.doc) and args.doc or 'yes')
	nArgs.footer = args.footer
	nArgs.title = (isNotEmptyOrNil(args.title) and args.title or '[[' .. args.name .. ']]')
	nArgs.name = args.name

	if (isNotEmptyOrNil(args.region) and args.region) then
		nArgs['style' .. groupnr] = 'text-align:center;'
		nArgs['group' .. groupnr] = '<i>Location within ' .. args.region .. '</i>'
		groupnr = groupnr + 1
	end

	if (isNotEmptyOrNil(args.subtitle) and args.subtitle) then
		nArgs['style' .. groupnr] = 'text-align:center;'
		nArgs['group' .. groupnr] = args.subtitle
		groupnr = groupnr + 1
	end

	local npcs_cat = (isNotEmptyOrNil(args['npcs category']) and args['npcs category'] or '')
	groupnr = showGroup(nArgs, args, 'npcs', 'Characters', groupnr, npcs_cat)

	local enemies_cat = (isNotEmptyOrNil(args['enemies category']) and args['enemies category'] or '')
	groupnr = showGroup(nArgs, args, 'enemies', 'Enemies', groupnr, enemies_cat)

	local rewards_cat = (isNotEmptyOrNil(args['rewards category']) and args['rewards category'] or '')
	groupnr = showGroup(nArgs, args, 'rewards', 'Rewards', groupnr, rewards_cat)

	local shops_cat = (isNotEmptyOrNil(args['shops category']) and args['shops category'] or '')
	groupnr = showGroup(nArgs, args, 'shops', 'Shops', groupnr, shops_cat)

	local features_cat = (isNotEmptyOrNil(args['features category']) and args['features category'] or '')
	groupnr = showGroup(nArgs, args, 'features', 'Features', groupnr, features_cat)

	local scenery_cat = (isNotEmptyOrNil(args['scenery category']) and args['scenery category'] or '')
	groupnr = showGroup(nArgs, args, 'scenery', 'Scenery', groupnr, scenery_cat)
	
	local items_cat = (isNotEmptyOrNil(args['items category']) and args['items category'] or '')
	groupnr = showGroup(nArgs, args, 'items', 'Items', groupnr, items_cat)

	local music_cat = (isNotEmptyOrNil(args['music category']) and args['music category'] or '')
	groupnr = showGroup(nArgs, args, 'music', 'Music', groupnr, music_cat)

	local quests_cat = (isNotEmptyOrNil(args['quests category']) and args['quests category'] or '')
	groupnr = showGroup(nArgs, args, 'quests', 'Quests', groupnr, quests_cat)

	local related_cat = (isNotEmptyOrNil(args['related title']) and args['related title'] or '')
	groupnr = showGroup(nArgs, args, 'related', 'Related', groupnr, related_cat)

	local cats = ''
	if string.lower(nArgs.doc) == 'yes' then
		cats = frame:expandTemplate { title = 'Ctg', args = { args.name } }
		local templatecats = '[[Category:Location templates|' .. args.name .. ']]'
		cats = cats ..
			(isNotEmptyOrNil(templatecats) and frame:expandTemplate { title = 'Template only', args = { templatecats } } or '')
	end

	-- Preventing unwanted documentation from [[Module:Navbox]]
	nArgs.doc = 'no'

	return navbox(nArgs) .. cats
end

function showGroup(nArgs, args, groupname, title, groupnr, cat)
	if isNotEmptyOrNil(args[groupname]) then
		nArgs['gtitle' .. groupnr] = (isNotEmptyOrNil(args[groupname .. ' title']) and args[groupname .. ' title'] or title)

		if string.match(string.lower(args[groupname]), "navbox") then
			nArgs['gtype' .. groupnr] = 'subgroup'
		end

		if isNotEmptyOrNil(cat) then
			nArgs['g' .. groupnr .. 'cat1'] = cat
		end

		nArgs['group' .. groupnr] = args[groupname]
		groupnr = groupnr + 1
	end
	return groupnr
end

function isNotEmptyOrNil(s)
	local bool = false
	bool = (s ~= nil and s ~= '')
	return bool
end

return p
-- </nowiki>