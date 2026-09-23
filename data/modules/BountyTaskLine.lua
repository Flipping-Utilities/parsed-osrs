local p = {}

local buildMap = require('Module:Map').buildMap

local lang = mw.language.getContentLanguage()

p.noticeBoardLocations = {
	['Aldarin'] = {1438,2969},
	['Ardougne'] = {2676,3276},
	['Brimhaven'] = {2764,3227},
	['Catherby'] = {2803,3418},
	['Civitas illa Fortis'] = {1782,3142},
	['Corsair Cove'] = {2579,2853},
	['Deepfin Point'] = {1931,2761},
	['Etceteria'] = {2617,3849},
	["Land's End"] = {1502,3407},
	['Lunar Isle'] = {2139,3884},
	['Musa Point'] = {2940,3144},
	['Port Khazard'] = {2678,3162},
	['Port Piscarilius'] = {1839,3691},
	['Port Roberts'] = {1872,3303},
	['Port Sarim'] = {3030,3197},
	['Port Tyras'] = {2146,3123},
	['Prifddinas'] = {2163,3326},
	['Red Rock'] = {2806,2511},
	['Rellekka'] = {2629,3685},
	['Ruins of Unkah'] = {3145,2828},
	['The Pandemonium'] = {3058,2985},
	['The Summer Shore'] = {3183,2368},
	["Void Knights' Outpost"] = {2659,2672}
}

function p.main(frame)
	local args = frame:getParent().args

	return _main(args)
end

function ucfirst(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

function _main(args)
	local level = tonumber(args.level)
	local xp = tonumber(args.xp)
	local noticeBoard = args.noticeBoard
	local monster = args.monster
	local monsterAlt = args.monsterAlt or monster
	local item = args.item
	local qty = args.qty
	local rarity = args.rarity
	local taskId = args.taskId
	local transcript = args.transcript
	local bucketArg = args.bucket
	local guaranteed = string.lower(args.guaranteed or '') == 'yes'

	local noticeBoardNoThe, _ = string.gsub(noticeBoard, '^The ', '')
	local monsterLower = string.lower(monsterAlt)
	local transcriptLink
	if transcript then
		transcriptLink = string.format('Transcript:%s', transcript)
	else
		transcriptLink = string.format('Transcript:%s %s bounty', noticeBoardNoThe, monsterLower)
	end

	if bucketArg == nil or bucketArg == '' then
		bucket('bountytaskline').put({
			["level"] = level,
			["xp"] = xp,
			["notice_board"] = noticeBoard,
			["monster"] = monster,
			["monster_alt"] = monsterAlt,
			["item"] = item,
			["qty"] = qty,
			["rarity"] = rarity,
			["task_id"] = taskId,
			["transcript"] = transcriptLink,
			["guaranteed"] = guaranteed
		})
	end

	local mapArgs = {
		['type'] = 'maplink',
		['mtype'] = 'pin',
		['group'] = taskId,
		['icon'] = 'greenPin',
		['x'] = p.noticeBoardLocations[noticeBoard][1],
		['y'] = p.noticeBoardLocations[noticeBoard][2],
		['title'] = 'Notice board',
		['text'] = 'Map'
	}

	local xpCommas
	if xp ~= nil then
		xpCommas = lang:formatNum(xp)
	else
		xpCommas = 'Unknown'
	end
	local itemShortName = ucfirst(string.gsub(item, monsterAlt .. ' ', ''))

	local guaranteedSvg = guaranteed and 'Yes check' or 'X mark'
	local guaranteedTxt = guaranteed and 'Yes' or 'No'

	local row = mw.html.create('tr')
		:tag('td'):wikitext(level):done()
		:tag('td'):wikitext(xpCommas):done()
		:tag('td'):wikitext(string.format('[[%s]]', noticeBoard)):done()
		:tag('td'):wikitext(string.format('[[%s|%s]]', monster, monsterAlt)):done()
		:tag('td'):addClass('plinkt-image inventory-image'):wikitext(string.format('[[File:%s.png|link=%s]]', item, item)):done()
		:tag('td'):addClass('plinkt-link'):wikitext(string.format('[[%s|%s]]', item, itemShortName)):done()
		:tag('td'):wikitext(qty):done()
		:tag('td'):wikitext(rarity):done()
		:tag('td'):wikitext(string.format('[[File:%s.svg|20px|link=|alt=%s]]', guaranteedSvg, guaranteedTxt)):done()
		:tag('td'):wikitext(buildMap(mapArgs)):done()

	return tostring(row)
end

return p