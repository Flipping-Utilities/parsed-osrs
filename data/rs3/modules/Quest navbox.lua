-- <nowiki>
-- Implements {{Quest navbox}}

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

	local seriesoverride = (isNotEmptyOrNil(args['series override']) and args['series override'] or '')
	local seriesline = (isNotEmptyOrNil(seriesoverride) and seriesoverride or getSeriesLine(args))
	if isNotEmptyOrNil(seriesline) then
		nArgs['style' .. groupnr] = 'text-align:center;'
		nArgs['group' .. groupnr] = seriesline
		groupnr = groupnr + 1
	end

	local npcs_cat = (isNotEmptyOrNil(args['npcs category']) and args['npcs category'] or '')
	groupnr = showGroup(nArgs, args, 'npcs', 'Characters', groupnr, npcs_cat)

	local enemies_cat = (isNotEmptyOrNil(args['enemies category']) and args['enemies category'] or '')
	groupnr = showGroup(nArgs, args, 'enemies', 'Enemies', groupnr, enemies_cat)

	local items_cat = (isNotEmptyOrNil(args['items category']) and args['items category'] or '')
	groupnr = showGroup(nArgs, args, 'items', 'Items', groupnr, items_cat)

	local scenery_cat = (isNotEmptyOrNil(args['scenery category']) and args['scenery category'] or '')
	groupnr = showGroup(nArgs, args, 'scenery', 'Scenery', groupnr, scenery_cat)

	local rewards_cat = (isNotEmptyOrNil(args['rewards category']) and args['rewards category'] or '')
	groupnr = showGroup(nArgs, args, 'rewards', 'Rewards', groupnr, rewards_cat)

	local locations_cat = (isNotEmptyOrNil(args['locations category']) and args['locations category'] or '')
	groupnr = showGroup(nArgs, args, 'locations', 'Locations', groupnr, locations_cat)

	local music_cat = (isNotEmptyOrNil(args['music category']) and args['music category'] or '')
	groupnr = showGroup(nArgs, args, 'music', 'Music', groupnr, music_cat)

	local relatedline = getRelated(args)
	if isNotEmptyOrNil(relatedline) then
		nArgs['gtitle' .. groupnr] = (isNotEmptyOrNil(args['related title']) and args['related title'] or 'Miscellaneous')

		if string.match(string.lower(relatedline), "navbox") then
			nArgs['gtype' .. groupnr] = 'subgroup'
		end

		nArgs['group' .. groupnr] = relatedline
		groupnr = groupnr + 1
	end

	groupnr = showGroup(nArgs, args, 'historic', getHistoricTitle(args), groupnr)

	local cats = ''
	if string.lower(nArgs.doc) == 'yes' then
		cats = frame:expandTemplate { title = 'Ctg', args = { args.name } }
		local templatecats = (isNotEmptyOrNil(categories(args)) and categories(args) or '')
		cats = cats ..
			(isNotEmptyOrNil(templatecats) and frame:expandTemplate { title = 'Template only', args = { templatecats } } or '')
	end

	-- Preventing unwanted documentation from [[Module:Navbox]]
	nArgs.doc = 'no'

	return navbox(nArgs) .. cats
end

function getHistoricTitle(args)
	local historictitle = ''

	if string.lower(args['former or replacement'] or '') == 'former' then
		historictitle = 'Replaced by'
	elseif string.lower(args['former or replacement'] or '') == 'replacement' then
		historictitle = 'Former version'
	else
		--do nothing
	end

	return historictitle
end

function getRelated(args)
	local related = ''

	related = (isNotEmptyOrNil(args.related) and args.related or '')

	if string.lower(args['achievement'] or '') == 'no' then
		--do nothing
	elseif isNotEmptyOrNil(args['achievement']) then
		related = related .. (isNotEmptyOrNil(related) and '\n' or '') .. ' * [[' ..
			args['achievement'] .. '|Achievement]]'
	elseif string.lower(args['achievement'] or '') == 'yes' then
		related = related ..
			(isNotEmptyOrNil(related) and '\n' or '') .. ' * [[' .. args.name .. ' (achievement)|Achievement]]'
	else
		related = related ..
			(isNotEmptyOrNil(related) and '\n' or '') .. ' * [[' .. args.name .. ' (achievement)|Achievement]]'
	end

	if string.lower(args['quick guide'] or '') == 'no' then
		--do nothing
	else
		related = related .. (isNotEmptyOrNil(related) and '\n' or '') ..
			' * [[' .. args.name .. '/Quick guide|Quick guide]]'
	end

	if string.lower(args.transcript or '') == 'no' then
		--do nothing
	else
		related = related .. (isNotEmptyOrNil(related) and '\n' or '') .. ' * [[Transcript:' ..
			args.name .. '|Transcript]]'
	end

	if string.lower(args.journal or '') == 'no' then
		--do nothing
	else
		related = related ..
			(isNotEmptyOrNil(related) and '\n' or '') .. ' * [[Transcript:' .. args.name .. '/Journal|Quest journal]]'
	end

	return related
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

function getSeriesLine(args)
	local series = ''

	if isNotEmptyOrNil(args.series) then
		series = getSeries(args.series, args['series number'], args.subquestnumber, args.subquest)
	end

	if isNotEmptyOrNil(args.series2) then
		series = series .. ' &bull; ' .. getSeries(args.series2, args['series2 number'], '', '')
	end

	if isNotEmptyOrNil(args.series3) then
		series = series .. ' &bull; ' .. getSeries(args.series3, args['series3 number'], '', '')
	end

	return series
end

function startsWith(str, start)
	str = str:lower():gsub("%[",""):gsub("%]","")
	start = start:lower()
	return str:sub(1, start:len()) == start
end

function getSeries(series, snumber, subquestnumber, subquest)
	local seriesstring = ''
	local localsubquest = subquest or ''

	local the = startsWith(series, 'the') and '' or 'the ';

	if isNotEmptyOrNil(snumber) then
		seriesstring = '<i>Part ' .. snumber .. ' of ' .. the .. series .. '</i>'
	elseif isNotEmptyOrNil(subquestnumber) then
		local sq = ''

		if subquestnumber == 'first' then
			sq = 'Initial'
		elseif subquestnumber == 'final' then
			sq = 'Final'
		end

		seriesstring = '<i>' .. sq .. ' subquest of ' .. series .. '</i>'
	elseif string.lower(localsubquest) == 'yes' then
		seriesstring = '<i>A subquest of ' .. series .. '</i>'
	else
		seriesstring = '<i>Related to ' .. the .. series .. '</i>'
	end

	return seriesstring
end

function categories(args)
	local cats = ''
	local namewithoutarticle = string.match(args.name, 'The (.+)') or
		string.match(args.name, 'An? (.+)') or
		args.name

	if string.lower(args.miniquest or '') == 'yes' then
		cats = '[[Category:Miniquest templates|' .. namewithoutarticle .. ']]'
	elseif string.lower(args.subquest or '') == 'yes' then
		cats = '[[Category:Subquest templates|' .. namewithoutarticle .. ']]'
	elseif string.lower(args['former or replacement'] or '') == 'former' then
		cats = '[[Category:Historic quest templates|' .. namewithoutarticle .. ']]'
	else
		cats = '[[Category:Quest templates|' .. namewithoutarticle .. ']]'
	end

	return cats
end

function isNotEmptyOrNil(s)
	local bool = false
	bool = (s ~= nil and s ~= '')
	return bool
end

return p
-- </nowiki>