local p = {}

local buildMap = require('Module:Map').buildMap
local noticeBoardLocations = require('Module:BountyTaskLine').noticeBoardLocations
local scp = require('Module:SCP')._main

local lang = mw.language.getContentLanguage()

function p.main(frame)
	local args = frame:getParent().args

	if args['monster'] ~= nil then
		return byMonster(frame, args['monster'])
	elseif args['location'] ~= nil then
		return byLocation(frame, args['location'])
	end
end

function ucfirst(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

function sortMonster(a, b)
	if a['item'] ~= b['item'] then
		return a['item'] < b['item']
	elseif a['qty'] ~= b['qty'] then
		return a['qty'] < b['qty']
	elseif a['level'] ~= b['level'] then
		return a['level'] < b['level']
	elseif a['notice_board'] ~= b['notice_board'] then
		return a['notice_board'] < b['notice_board']
	else
		return a['task_id'] < b['task_id']
	end
end

function byMonster(frame, monster)
	local header = mw.html.create('tr')
		:tag('th'):wikitext(scp('Sailing') .. '<br>Level'):done()  -- 1
		:tag('th'):wikitext(scp('Sailing') .. '<br>XP'):done()  -- 2
		:tag('th'):wikitext('Notice board'):done()  -- 3
		:tag('th'):wikitext('Bounty'):attr('colspan', 2):done()  -- 4 and 5
		:tag('th'):wikitext('Item<br>qty'):done()  -- 6
		:tag('th'):wikitext('Item<br>rarity'):done()  -- 7
		:tag('th'):wikitext('Map'):done()  -- 8

	local outTable = mw.html.create('table')
		:addClass('wikitable lighttable sortable align-center-1 align-center-2 align-center-6 align-center-7')
		:node(header)

	local data = bucket('bountytaskline')
		.select('level', 'xp', 'notice_board', 'item', 'qty', 'rarity', 'task_id', 'monster_alt', 'guaranteed')
		.where('monster', monster)
		.run()
	table.sort(data, sortMonster)

	local level, xp, noticeBoard, item, itemShortName, qty, rarity, monsterAlt, guaranteed
	for i, result in ipairs(data) do
		level = result['level']
		xp = tonumber(result['xp']) ~= nil and lang:formatNum(result['xp']) or 'Unknown'
		noticeBoard = result['notice_board']
		item = result['item']
		qty = result['qty']
		rarity = result['rarity']
		monsterAlt = result['monster_alt']
		guaranteed = result['guaranteed']

		itemShortName = ucfirst(string.gsub(item, monsterAlt .. ' ', ''))

		local mapArgs = {
			['type'] = 'maplink',
			['mtype'] = 'pin',
			['icon'] = 'greenPin',
			['x'] = noticeBoardLocations[noticeBoard][1],
			['y'] = noticeBoardLocations[noticeBoard][2],
			['title'] = string.format('%s (%s)', noticeBoard, itemShortName),
			['zoom'] = 1
		}

		local noticeBoardText = string.format('[[%s]]', noticeBoard)
		if guaranteed then
			noticeBoardText = noticeBoardText .. frame:expandTemplate{title='Template:Efn', args={'The task is guaranteed to appear on this notice board.', name='guaranteed'}}
		end

		outTable:node(mw.html.create('tr')
			:tag('td'):wikitext(level):done()
			:tag('td'):wikitext(xp):done()
			:tag('td'):wikitext(noticeBoardText):done()
			:tag('td'):addClass('plinkt-image inventory-image'):wikitext(string.format('[[File:%s.png|link=%s]]', item, item)):done()
			:tag('td'):addClass('plinkt-link'):wikitext(string.format('[[%s|%s]]', item, itemShortName)):done()
			:tag('td'):wikitext(qty):done()
			:tag('td'):wikitext(rarity):done()
			:tag('td'):wikitext(buildMap(mapArgs)):done()
		)
	end

	return tostring(outTable) .. '\n' .. frame:expandTemplate{title='Template:Notelist'}
end

function sortLocation(a, b)
	if a['level'] ~= b['level'] then
		return a['level'] < b['level']
	elseif a['qty'] ~= b['qty'] then
		return a['qty'] < b['qty']
	elseif a['item'] ~= b['item'] then
		return a['item'] < b['item']
	else
		return a['task_id'] < b['task_id']
	end
end

function loadMonsterSpawns(monster)
	local data = bucket('locline')
		.select('coordinates')
		.where('page_name', monster)
		.run()

	local spawns = {}
	for _, row in ipairs(data) do
		if row['coordinates'] ~= nil then  -- LocLines should never be empty, but alas
			for _, coords in ipairs(row['coordinates']) do
				table.insert(spawns, coords)
			end
		end
	end
	return spawns
end

function byLocation(frame, location)
	local header = mw.html.create('tr')
		:tag('th'):wikitext(scp('Sailing') .. '<br>Level'):done()  -- 1
		:tag('th'):wikitext(scp('Sailing') .. '<br>XP'):done()  -- 2
		:tag('th'):wikitext('Monster'):done()  -- 3
		:tag('th'):wikitext('Bounty'):attr('colspan', 2):done()  -- 4 and 5
		:tag('th'):wikitext('Item<br>qty'):done()  -- 6
		:tag('th'):wikitext('Item<br>rarity'):done()  -- 7
		:tag('th'):wikitext('Map'):done()  -- 8

	local outTable = mw.html.create('table')
		:addClass('wikitable lighttable sortable align-center-1 align-center-2 align-center-6 align-center-7')
		:node(header)

	local data = bucket('bountytaskline')
		.select('level', 'xp', 'monster', 'item', 'qty', 'rarity', 'monster_alt', 'task_id', 'guaranteed')
		.where('notice_board', location)
		.run()
	table.sort(data, sortLocation)

	local level, xp, monster, item, itemShortName, qty, rarity, monsterAlt
	for i, result in ipairs(data) do
		level = result['level']
		xp = tonumber(result['xp']) ~= nil and lang:formatNum(result['xp']) or 'Unknown'
		monster = result['monster']
		monsterAlt = result['monster_alt']
		item = result['item']
		qty = result['qty']
		rarity = result['rarity']
		guaranteed = result['guaranteed']

		itemShortName = ucfirst(string.gsub(item, monsterAlt .. ' ', ''))

		local noticeBoardX = noticeBoardLocations[location][1]
		local noticeBoardY = noticeBoardLocations[location][2]
		local mapArgs = {
			['type'] = 'maplink',
			['mtype'] = 'pin',
			['group'] = string.format('bounty%d', i),
			['zoom'] = -1,
			['x'] = noticeBoardX,
			['y'] = noticeBoardY,
			['icon'] = 'redPin',
			['title'] = monsterAlt
		}

		local monsterText = string.format('[[%s|%s]]', monster, monsterAlt)
		if guaranteed then
			monsterText = monsterText .. frame:expandTemplate{title='Template:Efn', args={'This task is guaranteed to appear on the notice board.', name='guaranteed'}}
		end

		local numSpawns = 0
		for j, monsterSpawns in ipairs(loadMonsterSpawns(monster)) do
			numSpawns = numSpawns + 1
			mapArgs[j] = monsterSpawns
		end
		mapArgs[numSpawns + 1] = string.format('icon:greenPin,title:Notice board,x:%d,y:%d', noticeBoardX, noticeBoardY)

		outTable:node(mw.html.create('tr')
			:tag('td'):wikitext(level):done()
			:tag('td'):wikitext(xp):done()
			:tag('td'):wikitext(monsterText):done()
			:tag('td'):addClass('plinkt-image inventory-image'):wikitext(string.format('[[File:%s.png|link=%s]]', item, item)):done()
			:tag('td'):addClass('plinkt-link'):wikitext(string.format('[[%s|%s]]', item, itemShortName)):done()
			:tag('td'):wikitext(qty):done()
			:tag('td'):wikitext(rarity):done()
			:tag('td'):wikitext(buildMap(mapArgs)):done()
		)
	end

	return tostring(outTable) .. '\n' .. frame:expandTemplate{title='Template:Notelist'}
end

return p