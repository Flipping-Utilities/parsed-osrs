local p = {}

local function getargs()
	local out = {}
	local f = mw.getCurrentFrame()
	local pa = f:getParent()
	for k,v in pairs(f.args) do
		out[k]=v
	end
	if pa then
		for k,v in pairs(pa.args) do
			out[k]=v
		end
	end
	return out
end

function p.wfe()
	local start_time = '1754542800000' -- timestamp (in miliseconds) of start time of the first event in the list below
	local data = {
		{'Spider Swarm'},
		{'Unnatural Outcrop'},
		{'Stryke the Wyrm', s=true},
		{'Demon Stragglers'},
		{'Butterfly Swarm'},
		{'King Black Dragon Rampage', s=true},
		{'Forgotten Soldiers'},
		{'Surprising Seedlings'},
		{'Hellhound Pack'},
		{'Infernal Star', s=true, d=10},
		{'Lost Souls'},
		{'Ramokee Incursion'},
		{'Displaced Energy'},
		{'Evil Bloodwood Tree', s=true, d=15}
	}
	local args = getargs()
	local t = mw.html.create('table')
	if args.float then
		t:css({
			margin='3px',
			float=args.float,
			clear=args.float
		})
	end
	t:addClass('rotation-group wikitable align-center-2 align-right-3')
		:attr({
			['data-rotation-nexttimeformat']="HH:mm",
			['data-rotation-start']=start_time,
			['data-rotation-active']='{"m":5}',
			['data-rotation-fullperiod']='{"h":14}',
			['data-rotation-itemperiod']='{"h":1}',
			['data-rotation-next-within']='{"h":1}'
		})
	local linktxt = '[[#'
	if mw.title.getCurrentTitle().fullText ~= 'Wilderness Flash Events' then
		linktxt = '[[Wilderness Flash Events#'
		t:tag('caption'):wikitext('[[Wilderness Flash Events]] Schedule')
	else
		t:tag('caption'):wikitext('Wilderness Flash Events Schedule')
	end
	
	t:tag('tr')
		:tag('th'):wikitext('Event'):done()
		:tag('th'):wikitext('Next start (UTC)'):done()
		:tag('th'):wikitext('Countdown'):done()
	for _,event in ipairs(data) do
		local tr = t:tag('tr')
		tr:addClass('rotation-item')
		if event.d then
			tr:attr('data-rotation-active', '{"m":'..tostring(event.d)..'}')
		end
		if event.s then
			tr:addClass('rotation-item-wfe-special')
		end
		tr:tag('td'):addClass('rotation-label'):wikitext('<div class="rotation-label-before"></div><div class="rotation-label-text">', linktxt, event[1], '|', event[1], ']]</div>'):done()
			:tag('td'):addClass('rotation-next-start'):done()
			:tag('td'):addClass('rotation-countdown'):done()
	end
	return tostring(t)
end

function p.wfe_next()
	local args = getargs()
	local event = args.event or args[1]
	local data = {
		-- event(lowercase) = event(title case), start time, duration
		["spider swarm"] = { "Spider Swarm", "1754542800000" },
		["unnatural outcrop"] = { "Unnatural Outcrop", "1754546400000" },
		["stryke the wyrm"] = { "Stryke the Wyrm", "1754550000000" },
		["demon stragglers"] = { "Demon Stragglers", "1754553600000" },
		["butterfly swarm"] = { "Butterfly Swarm", "1754557200000" },
		["king black dragon rampage"] = { "King Black Dragon Rampage", "1754560800000" },
		["forgotten soldiers"] = { "Forgotten Soldiers", "1754564400000" },
		["surprising seedlings"] = { "Surprising Seedlings", "1754568000000" },
		["hellhound pack"] = { "Hellhound Pack", "1754571600000" },
		["infernal star"] = { "Infernal Star", "1754575200000", 10 },
		["lost souls"] = { "Lost Souls", "1754578800000" },
		["ramokee incursion"] = { "Ramokee Incursion", "1754582400000" },
		["displaced energy"] = { "Displaced Energy", "1754586000000" },
		["evil bloodwood tree"] = { "Evil Bloodwood Tree", "1754589600000", 15 },
	}
	local ev = mw.text.trim(tostring(event):lower())
	local d = data[ev]
	if d == nil then
		error('invalid event passed: '..event)
	end
	local t = mw.html.create('table')
	t:addClass("rotation-group-wfe rotation-group wikitable"):attr({
		['data-rotation-option-sorttotop']="true",
		['data-rotation-nexttimeformat']="D MMM HH:mm:ss",
		['data-rotation-start']=d[2],
		['data-rotation-active']='{"m":'..tostring(d[3] or 5)..'}',
		['data-rotation-fullperiod']='{"h":182}',
		['data-rotation-next-within']='{"h":14}',
		['data-rotation-itemperiod']='{"h":14}',
		['data-rotation-option-attachtooltipto']='td.rotation-item-wfe'
	})
	t:tag('caption'):wikitext('Upcoming start times for '..d[1]):done()
		:tag('tr'):addClass('rotation-group-wfe-headerrow')
			:tag('th'):addClass('rotation-wfe-header'):wikitext('Next'):done()
			:tag('th'):addClass('rotation-wfe-header'):wikitext('Upcoming'):done()
			:done()
	local tr = t:tag('tr')
	tr:addClass('rotation-group-wfe-row rotation-group-container')
	for i=1,13 do
		tr:tag('td'):addClass('rotation-item-wfe rotation-item')
				:tag('span'):addClass('rotation-next-start'):done()
				:tag('span'):addClass('rotation-countdown'):done()
			:done()
	end
	return tostring(t)
end

function p.thalerdata()
	return {
		'Stealing Creation',
		'Cabbage Facepunch Bonanza',
		'Heist',
		'Soul Wars',
		'Barbarian Assault',
		'Conquest',
		'Fist of Guthix',
		'Castle Wars',
		'Pest Control',
		'Soul Wars',
		'Fishing Trawler',
		'The Great Orb Project',
		'Flash Powder Factory',
		'Stealing Creation',
		'Cabbage Facepunch Bonanza',
		'Heist',
		'Trouble Brewing',
		'Castle Wars',
		'Pest Control',
		'Soul Wars',
		'Fist of Guthix',
		'Barbarian Assault',
		'Conquest',
		'Fishing Trawler',
		'The Great Orb Project',
		'Flash Powder Factory',
		'Castle Wars',
	}, "2025-03-17 00:00:00+00", 1742169600
end
function p.thaler()
	local data, start_time = p.thalerdata()
	local args = getargs()
	
	local t = mw.html.create('table')
	if args.float then
		t:css({
			margin='3px',
			float=args.float,
			clear=args.float
		})
	end
	t:addClass("rotation-group wikitable align-center-2")
		:attr({
			['data-rotation-option-sorttotop']="true",
			['data-rotation-option-addactivefor']="true",
			['data-rotation-nexttimeformat']="D MMM",
			['data-rotation-active']='{"d":3}',
			['data-rotation-start']=start_time,
			['data-rotation-fullperiod']='{"d":'..tostring(#data * 3)..'}',
			['data-rotation-next-within']='{"d":1}',
			['data-rotation-itemperiod']='{"d":3}'
		})
	t:tag('caption'):wikitext('Minigame Spotlight Schedule')
	for i,v in ipairs(data) do
		if v == "Heist" then
			v = "Heist (minigame)"
		end
		t:tag('tr'):addClass('rotation-item')
			:tag('td'):addClass('rotation-label'):wikitext('<div class="rotation-label-before"></div><div class="rotation-label-text">', '[['..v..']]', '</div>'):done()
			:tag('td'):addClass('rotation-next-start'):done()
	end
	return tostring(t)
end

function p.thaler_next()
	local args = getargs()
	local data, _, start_time = p.thalerdata()
	local ev = args.event or args[1]
	local num = tonumber(args.num) or 3
	if ev == nil then
		error('no minigame provided')
	end
	ev = mw.text.trim(ev:lower())
	local s = mw.html.create('span'):addClass('rotation-group rotation-group-thalernext')
	s:attr({
		['data-rotation-option-sorttotop']="true",
		['data-rotation-option-addactivefor']="true",
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-active']='{"d":3}',
		['data-rotation-next-within']='{"d":0}',
		['data-rotation-itemperiod']='{"d":3}'
	})
	local numadded=0
	local fullloops=0
	local i=0
	while numadded < num do
		for _,v in ipairs(data) do
			i=i+1
			if ev == v:lower() then
				numadded=numadded+1
				s:tag('span'):addClass('rotation-item'):attr('data-rotation-start', tostring(start_time + 3*60*60*24*(i-1))..'000')
					:tag('span'):addClass('rotation-next-start'):done()
			end
		end
		if numadded == 0 then
			error('invalid minigame provided')
		end
		fullloops=fullloops+1
	end
	s:attr({['data-rotation-fullperiod']='{"d":'..tostring(#data * 3 * fullloops)..'}'})
	return tostring(s)
end

function p.castaway()
	local yn = require('Module:Yesno')
	local args = getargs()
	local starttimes = {
		'2025-09-01 00:00:00', -- always visible
		'2025-08-31 00:00:00',
		'2025-08-31 00:00:00',
		'2025-08-29 00:00:00',
		'2025-08-30 00:00:00',
		'2025-08-31 00:00:00',
		'2025-08-27 00:00:00',
		'2025-08-29 00:00:00',
		'2025-08-31 00:00:00',
		'2025-08-25 00:00:00',
	}
	local num = tonumber(args.bottle or args[1])
	if not starttimes[num] then
		error('invalid bottle provided')
	end
	local warning = ''
	if not yn(args.hidewarning) then
		warning = "<span class='rotation-castaways-warning rotation-hideuntilsetup'>Once a message in a bottle is found, and when a player walks near its spawn location while it is visible, it will always be visible, unless the message in the bottle or its treasure map is in the player's bank or backpack.</span>"
	end
	local intro = args.starttext or "This message in a bottle"
	local active = "is '''currently visible''' for <span class='rotation-countdown'></span>"
	local inactive = "was last visible <span class='rotation-prev-start'></span>. It will be visible again in <span class='rotation-countdown'></span> on <span class='rotation-next-start'></span>."
	if num == 1 then
		active = "is '''always visible'''."
	end
	local s
	if yn(args.tile) then
		s = mw.html.create('div')
		s:addClass('tile'):css('clear','left')
		if warning=='' then
			active = active..'.'
		end
	else
		s = mw.html.create('span')
	end
	s:addClass("rotation-item")
		:attr({
			['data-rotation-nexttimeformat']="D MMM",
			['data-rotation-start']=starttimes[num],
			['data-rotation-active']='{"d":1}',
			['data-rotation-fullperiod']='{"d":'..tostring(num)..'}',
			['data-rotation-next-within']='{"s":0}',
			['data-rotation-itemperiod']='{"d":'..tostring(num)..'}'
		})
		:tag('span'):addClass('rotation-showuntilsetup'):wikitext('Loading rotations...'):done()
		:tag('span'):addClass('rotation-active-text rotation-hideuntilsetup'):wikitext(intro, ' ', active):done()
		:tag('span'):addClass('rotation-inactive-text rotation-hideuntilsetup'):wikitext(intro, ' ', inactive):done()
	if warning~='' then
		s:wikitext(' ',warning)
	end
	return tostring(s)
end

function p.araxxor()
	local t = mw.html.create('table')
	t:addClass("rotation-group wikitable align-right-4 rotation-group-araxxor"):attr({
		['data-rotation-option-showonlyactive']="true",
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-start']="2025-08-21 00:00:00+00",
		['data-rotation-active']='{"d":4}',
		['data-rotation-fullperiod']='{"d":12}',
		['data-rotation-next-within']='{"d":0}',
		['data-rotation-itemperiod']='{"d":4}'
	})
	t:tag('tr'):tag('th'):attr('colspan',4):wikitext('Current Araxxor rotation on <span class="rotation-current-day"></span>')
	t:tag('tr'):tag('th'):wikitext('Path 1 (Minions)'):done()
		:tag('th'):wikitext('Path 2 (Acid)'):done()
		:tag('th'):wikitext('Path 3 (Darkness)'):done()
		:tag('th'):wikitext('Time remaining'):done()
	t:tag('tr'):addClass('rotation-item')
			:tag('td'):addClass('table-bg-green'):wikitext('Open'):done()
			:tag('td'):addClass('table-bg-green'):wikitext('Open'):done()
			:tag('td'):addClass('table-bg-grey'):wikitext('Closed'):done()
			:tag('td'):addClass('rotation-countdown'):wikitext(''):done()
		:done()
		:tag('tr'):addClass('rotation-item')
			:tag('td'):addClass('table-bg-grey'):wikitext('Closed'):done()
			:tag('td'):addClass('table-bg-green'):wikitext('Open'):done()
			:tag('td'):addClass('table-bg-green'):wikitext('Open'):done()
			:tag('td'):addClass('rotation-countdown'):wikitext(''):done()
		:done()
		:tag('tr'):addClass('rotation-item')
			:tag('td'):addClass('table-bg-green'):wikitext('Open'):done()
			:tag('td'):addClass('table-bg-grey'):wikitext('Closed'):done()
			:tag('td'):addClass('table-bg-green'):wikitext('Open'):done()
			:tag('td'):addClass('rotation-countdown'):wikitext(''):done()
		:done()
	t:tag('tr'):css({['text-align']='center', ['font-style']='italic'})
		:tag('td'):attr('colspan',4):wikitext('I died ')
			:tag('span'):addClass('rotation-showuntilsetup'):wikitext('...'):done()
			:tag('span'):addClass('rotation-item-associated rotation-hideuntilsetup'):wikitext('covered in acid and spiders.'):done()
			:tag('span'):addClass('rotation-item-associated rotation-hideuntilsetup'):wikitext('covered in a dark acid pool.'):done()
			:tag('span'):addClass('rotation-item-associated rotation-hideuntilsetup'):wikitext('covered in the dark, covered in spiders.'):done()
	return t
end

function p.araxxor_next()
	local t = mw.html.create('table')
	t:addClass("rotation-group rotation-future wikitable align-right-1 align-right-2"):attr({
		['data-option-skipactive']="true",
		['data-rotation-option-sorttotop']="true",
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-nexttimeformat-after']="HH:mm [(UTC)]",
		['data-rotation-start']="2025-08-25 00:00:00+00",
		['data-rotation-active']='{"d":4}',
		['data-rotation-fullperiod']='{"d":36}',
		['data-rotation-next-within']='{"d":0}',
		['data-rotation-itemperiod']='{"d":4}'
	})
	t:tag('tr'):tag('th'):wikitext('Start'):done()
		:tag('th'):wikitext('End'):done()
		:tag('th'):wikitext('Path 1 (Minions)'):done()
		:tag('th'):wikitext('Path 2 (Acid)'):done()
		:tag('th'):wikitext('Path 3 (Darkness)'):done()
	for i=0,8 do
			local tr=t:tag('tr')
			tr:addClass('rotation-item')
				:tag('td'):addClass('rotation-next-start'):done()
				:tag('td'):addClass('rotation-next-end'):done()
		for j=0,2 do
				tr:tag('td'):addClass('table-bg-'..(i%3==j and 'grey' or 'green')):wikitext((i%3==j and 'Closed' or 'Open')):done()
		end
	end
	return t
end

function p.araxxor_both()
	local r = p.araxxor()
	local n = p.araxxor_next()
	local d = tostring(r)..'\n<div class="mw-collapsible mw-collapsed" style="display:inline-block; clear:left;"><div style="font-weight:bold; font-style:italic;">Show/hide future rotations</div><div class="mw-collapsible-content">' .. tostring(n) ..'</div></div>'
	return d
end

function p.raven()
	local yn = require('Module:Yesno')
	local args = getargs()
	local active = "The raven is '''currently spawned'''. Time remaining: <span class='rotation-countdown'></span>"
	local inactive = "The raven was last spawned on <span class='rotation-prev-start'></span>. It will spawn again in <span class='rotation-countdown'></span> on <span class='rotation-next-start'></span>."

	local s
	if yn(args.tile) then
		s = mw.html.create('div')
		s:addClass('tile')
	else
		s = mw.html.create('span')
	end
	s:addClass("rotation-item")
		:attr({
			['data-rotation-nexttimeformat']="D MMM",
			['data-rotation-start']='2025-08-25 00:00:00',
			['data-rotation-active']='{"h":23, "m":50}',
			['data-rotation-fullperiod']='{"d":13}',
			['data-rotation-next-within']='{"s":0}',
			['data-rotation-itemperiod']='{"d":13}'
		})
		:tag('span'):addClass('rotation-showuntilsetup'):wikitext('Loading rotations...'):done()
		:tag('span'):addClass('rotation-active-text rotation-hideuntilsetup'):wikitext(active):done()
		:tag('span'):addClass('rotation-inactive-text rotation-hideuntilsetup'):wikitext(inactive):done()
	return tostring(s)
end
function p.raven_next()
	local t = mw.html.create('table')
	t:addClass("rotation-group-wfe rotation-group wikitable"):attr({
		['data-rotation-option-sorttotop']="true",
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-start']='2025-08-25 00:00:00',
		['data-rotation-active']='{"d":1}',
		['data-rotation-fullperiod']='{"d":169}',
		['data-rotation-next-within']='{"d":1}',
		['data-rotation-itemperiod']='{"d":13}',
		['data-rotation-option-attachtooltipto']='td.rotation-item-wfe'
	})
	t:tag('caption'):wikitext('Upcoming raven appearances'):done()
		:tag('tr'):addClass('rotation-group-wfe-headerrow')
			:tag('th'):addClass('rotation-wfe-header'):wikitext('Next'):done()
			:tag('th'):addClass('rotation-wfe-header'):wikitext('Upcoming'):done()
			:done()
	local tr = t:tag('tr')
	tr:addClass('rotation-group-wfe-row rotation-group-container')
	for i=1,13 do
		tr:tag('td'):addClass('rotation-item-wfe rotation-item')
				:tag('span'):addClass('rotation-next-start'):done()
				:tag('span'):addClass('rotation-countdown'):done()
			:done()
	end
	return tostring(t)
end

function p.sinkholes()
	local yn = require('Module:Yesno')
	local args = getargs()
	local s
	if yn(args.tile) then
		s = mw.html.create('div')
		s:addClass('tile')
	else
		s = mw.html.create('span')
	end
	s:addClass('rotation-item'):attr({
		['data-rotation-nexttimeformat']="HH:mm:ss [(UTC)]",
		['data-rotation-start']='2025-08-25 00:30:00',
		['data-rotation-active']='{"m":15}',
		['data-rotation-fullperiod']='{"h":1}',
		['data-rotation-next-within']='{"m":0}',
		['data-rotation-itemperiod']='{"h":1}',
	})
		:tag('span'):addClass('rotation-showuntilsetup'):wikitext('Loading rotations...'):done()
		:tag('span'):addClass('rotation-active-text rotation-hideuntilsetup'):wikitext("Sinkholes are currently '''active''' for <span class='rotation-countdown'></span>"):done()
		:tag('span'):addClass('rotation-inactive-text rotation-hideuntilsetup'):wikitext('The next sinkhole appears in <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>')
	return tostring(s)
end

function p.cache()
	local t = mw.html.create('table')
	t:addClass('rotation-group wikitable align-center-2 align-right-3'):attr({
		['data-rotation-nexttimeformat']="HH:mm:ss",
		['data-rotation-start']='2025-08-25 00:00:00',
		['data-rotation-active']='{"m":10}',
		['data-rotation-fullperiod']='{"h":12}',
		['data-rotation-next-within']='{"h":1}',
		['data-rotation-itemperiod']='{"h":1}',
	})
	
	t:tag('tr')
		:tag('th'):wikitext('Cache type'):done()
		:tag('th'):wikitext('Next start'):done()
		:tag('th'):wikitext('Countdown'):done()
	for i=0,3 do
		for j=0,2 do
			t:tag('tr'):addClass('rotation-item')
			:tag('td'):addClass('rotation-label'):wikitext('<div class="rotation-label-before"></div><div class="rotation-label-text">', j==0 and 'Boost cache' or 'Cache', '</div>'):done()
			:tag('td'):addClass('rotation-next-start'):done()
			:tag('td'):addClass('rotation-countdown')
		end
	end
	return tostring(t)
end


function p.big_chinchompa()
	local args = getargs()
	local yn = require('Module:Yesno')
	local args = getargs()
	local s
	if yn(args.tile) then
		s = mw.html.create('div')
		s:addClass('tile')
	else
		s = mw.html.create('span')
	end
	s:addClass('rotation-item'):attr({
		['data-rotation-nexttimeformat']="HH:mm:ss [(UTC)]",
		['data-rotation-start']='2025-08-25 00:30:00',
		['data-rotation-active']='{"m":20}',
		['data-rotation-fullperiod']='{"h":1}',
		['data-rotation-next-within']='{"m":0}',
		['data-rotation-itemperiod']='{"h":1}',
	})
		:tag('span'):addClass('rotation-showuntilsetup'):wikitext('Loading rotations...'):done()
		:tag('span'):addClass('rotation-active-text rotation-hideuntilsetup'):wikitext("Big Chinchompa is currently '''active''' for <span class='rotation-countdown'></span>"):done()
		:tag('span'):addClass('rotation-inactive-text rotation-hideuntilsetup'):wikitext('The next big chinchompa appears in <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>')
	return tostring(s)
end


function p.supply_run()
	local yn = require('Module:Yesno')
	local args = getargs()
	local s
	if yn(args.tile) then
		s = mw.html.create('div')
		s:addClass('tile')
	else
		s = mw.html.create('span')
	end
	s:addClass('rotation-item'):attr({
		['data-rotation-nexttimeformat']="HH:mm:ss [(UTC)]",
		['data-rotation-start']='2025-08-25 00:05:00',
		['data-rotation-active']='{"m":20}',
		['data-rotation-fullperiod']='{"h":12}',
		['data-rotation-next-within']='{"m":0}',
		['data-rotation-itemperiod']='{"h":12}',
	})
		:tag('span'):addClass('rotation-showuntilsetup'):wikitext('Loading rotations...'):done()
		:tag('span'):addClass('rotation-active-text rotation-hideuntilsetup'):wikitext("Supply runs are currently '''active''' for <span class='rotation-countdown'></span>"):done()
		:tag('span'):addClass('rotation-inactive-text rotation-hideuntilsetup'):wikitext('The next supply run occurs in <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>')
	return tostring(s)
end

function p.arcbirds_time_specific()
	local data = {
		monday={0, '[[Crested Sillago Snatcher]]', "[[Whale's Maw]]"}, --monday
		tuesday={1, '[[Shrine Ibis]]', '[[Aminishi]]'},
		wednesday={2, '[[Gongdung Peligorn]]', '[[Goshima]]'},
		thursday={3, '[[Cyclosis Cockatiel]]', '[[Cyclosis]]'},
		friday={4, '[[Titchy Tinamou]]', '[[The Islands That Once Were Turtles]]'},
		saturday={5, '[[Tuai Leit Toucan]]', '[[Tuai Leit]]'},
		sunday={6, '[[Waiko Warbler]]', '[[Waiko]]'},
		uncharted={7},
		all={8, 'bird', 'island'}
	}
	local yn = require('Module:Yesno')
	local args = getargs()
	local day = mw.text.trim(args.day or (args[1] or '')):lower()
	if not data[day] then
		error('invalid day provided')
	end
	local dn = data[day]
	if dn[1] == 7 then
		return p.arcbirds_time_specific_unch()
	end
	--if dn[1] == 8 then
	--	return p.arcbirds_time()
	--end
	local originalstart = 1756080000
	local start = originalstart
	local spawnedon = ''
	local fullperiod = '{"d":1}'
	if dn[1] ~= 8 then
		spawnedon = ' on '..dn[3]
		fullperiod = '{"d":7}'
		start = start + dn[1]*24*60*60
	end
	local tag, cl
	if yn(args.tile) then
		tag = 'div'
		cl = 'tile'
	else
		tag = 'span'
		cl = nil
	end
	local s = mw.html.create(tag)
	s:addClass('rotation-group rotation-group-arcbirds-specific'):attr({
		['data-rotation-nexttimeformat']="HH:mm:ss [(UTC)]",
		['data-rotation-active']='{"m":9,"s":57}',
		['data-rotation-fullperiod']=fullperiod,
		['data-rotation-next-within']='{"m":0}',
		['data-rotation-itemperiod']='{"m":30,"s":30,"ms":212}',
		['data-rotation-option-sorttotop']="true",
	})
		:tag(tag):addClass('rotation-showuntilsetup'):addClass(cl):wikitext('Loading rotations...'):done()
	
	for i=0,47 do
			s:tag(tag):addClass('rotation-item rotation-hideuntilsetup'):addClass(cl):attr({['data-rotation-start']=tostring(start+i*30.5*60)..'212'})
				:tag('span'):addClass('rotation-active-text'):wikitext("The "..dn[2].." is currently '''spawned'''"..spawnedon.." for <span class='rotation-countdown'></span>"):done()
				:tag('span'):addClass('rotation-inactive-text'):wikitext('The next '..dn[2]..' spawns'..spawnedon..' in <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>')
	end
	if dn[1] == 4 then
		-- titchy tinamou special, can also be on uncharted on tue/thur
		-- tues
		s:tag(tag):addClass('rotation-item rotation-hideuntilsetup'):addClass(cl):attr({['data-rotation-start']=tostring(originalstart+1*24*60*60)..'000', ['data-rotation-itemperiod']='{"d":1}', ['data-rotation-active']='{"d":1}'})
				:tag('span'):addClass('rotation-active-text'):wikitext("The "..dn[2].." ''may'' spawn on [[Uncharted Isles]] for <span class='rotation-countdown'></span>"):done()
				:tag('span'):addClass('rotation-inactive-text'):wikitext('The '..dn[2].." ''may'' spawn on [[Uncharted Isles]] starting in"..' <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>')
		-- thur
		s:tag(tag):addClass('rotation-item rotation-hideuntilsetup'):addClass(cl):attr({['data-rotation-start']=tostring(originalstart+3*24*60*60)..'000', ['data-rotation-itemperiod']='{"d":1}', ['data-rotation-active']='{"d":1}'})
				:tag('span'):addClass('rotation-active-text'):wikitext("The "..dn[2].." ''may'' spawn on [[Uncharted Isles]] for <span class='rotation-countdown'></span>"):done()
				:tag('span'):addClass('rotation-inactive-text'):wikitext('The '..dn[2].." ''may'' spawn on [[Uncharted Isles]] starting in"..' <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>')
	end
	return tostring(s)
end
function p.arcbirds_time_specific_unch()
	local yn = require('Module:Yesno')
	local args = getargs()
	local tag, cl
	if yn(args.tile) then
		tag = 'div'
		cl = 'tile'
	else
		tag = 'span'
		cl = nil
	end
	local start = 1756080000
	local s = mw.html.create(tag)
	s:addClass('rotation-group rotation-group-arcbirds-specific'):attr({
		['data-rotation-nexttimeformat']="HH:mm:ss [(UTC)]",
		['data-rotation-fullperiod']='{"d":7}',
		['data-rotation-next-within']='{"m":0}',
		['data-rotation-option-sorttotop']="true",
	})
		:tag(tag):addClass('rotation-showuntilsetup'):addClass(cl):wikitext('Loading rotations...'):done()
		s:tag(tag):addClass('rotation-item rotation-hideuntilsetup'):addClass(cl):attr({['data-rotation-start']=tostring(start-2*24*60*60)..'000', ['data-rotation-itemperiod']='{"d":4}', ['data-rotation-active']='{"d":4}'})
				:tag('span'):addClass('rotation-active-text'):wikitext("[[Fluffy Jublet]]s and [[Cocoa Macaw]]s ''may'' spawn on [[Uncharted Isles]] for <span class='rotation-countdown'></span>"):done()
				:tag('span'):addClass('rotation-inactive-text'):wikitext("[[Fluffy Jublet]]s and [[Cocoa Macaw]]s ''may'' spawn on [[Uncharted Isles]] starting in"..' <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>')
		s:tag(tag):addClass('rotation-item rotation-hideuntilsetup'):addClass(cl):attr({['data-rotation-start']=tostring(start+2*24*60*60)..'000', ['data-rotation-itemperiod']='{"d":1}', ['data-rotation-active']='{"d":1}'})
				:tag('span'):addClass('rotation-active-text'):wikitext("[[Fluffy Jublet]]s and [[Cocoa Macaw]]s ''may'' spawn on [[Uncharted Isles]] for <span class='rotation-countdown'></span>"):done()
				:tag('span'):addClass('rotation-inactive-text'):wikitext("[[Fluffy Jublet]]s and [[Cocoa Macaw]]s ''may'' spawn on [[Uncharted Isles]] starting in"..' <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>')
	return tostring(s)
end

function p.arcbirds()
	local uncha, unchb = '[[Cocoa Macaw]]<br>[[Fluffy Jublet]]', '[[Titchy Tinamou]]'
	local data = {
		{"[[Crested Sillago Snatcher]]<br>on [[Whale's Maw]]", uncha}, --monday
		{'[[Shrine Ibis]]<br>on [[Aminishi]]', unchb},
		{'[[Gongdung Peligorn]]<br>on [[Goshima]]', uncha},
		{'[[Cyclosis Cockatiel]]<br>on [[Cyclosis]]', unchb},
		{'[[Titchy Tinamou]]<br>on [[The Islands That Once Were Turtles]]', uncha},
		{'[[Tuai Leit Toucan]]<br>on [[Tuai Leit]]', uncha},
		{'[[Waiko Warbler]]<br>on [[Waiko]]', uncha}
	}
	local t = mw.html.create('table')
	t:addClass('rotation-group wikitable align-center-3 align-right-4')
		:attr({
			['data-rotation-nexttimeformat']="D MMM",
			['data-rotation-start']='2025-08-25 00:00:00',
			['data-rotation-active']='{"d":1}',
			['data-rotation-fullperiod']='{"d":7}',
			['data-rotation-itemperiod']='{"d":1}',
			['data-rotation-next-within']='{"d":1}'
		})
	t:tag('tr')
		:tag('th'):wikitext('Main Islands'):done()
		:tag('th'):wikitext('Uncharted Islands'):done()
		:tag('th'):wikitext('Next spawn (UTC)'):done()
		:tag('th'):wikitext('Countdown'):done()
	
	for _,bird in ipairs(data) do
		local tr = t:tag('tr')
		tr:addClass('rotation-item')
		tr:tag('td'):addClass('rotation-label'):wikitext('<div class="rotation-label-before"></div><div class="rotation-label-text">', bird[1], '</div>'):done()
			:tag('td'):wikitext(bird[2]):done()
			:tag('td'):addClass('rotation-next-start'):done()
			:tag('td'):addClass('rotation-countdown'):done()
	end
	return tostring(t)
end

function p.vorago()
	local data = {
		{'Ceiling collapse', 'Team Split', 'Green Bomb', 'Team Split', 'Vitalis'},
		{'Scopulus', 'Purple Bomb', 'Team Split', 'Purple Bomb', 'Vitalis'},
		{'Vitalis', 'Vitalis', 'Purple Bomb', 'Vitalis', 'Smashes'},
		{'Green Bomb', 'Green Bomb', 'Vitalis', 'Green Bomb', 'Team Split'},
		{'Team Split', 'Team Split', 'Team Split', 'Team Split', 'Purple Bomb'},
		{'The End', 'Purple Bomb', 'Smashes', 'Purple Bomb', 'Vitalis'}
	}
	local t = mw.html.create('table')
	t:addClass('rotation-group wikitable align-center-6 align-right-7')
		:attr({
			['data-rotation-nexttimeformat']="D MMM",
			['data-rotation-start']='2025-07-23 00:00:00',
			['data-rotation-active']='{"d":7}',
			['data-rotation-fullperiod']='{"d":42}',
			['data-rotation-itemperiod']='{"d":7}',
			['data-rotation-next-within']='{"d":1}'
		})
	t:tag('tr')
		:tag('th'):wikitext('Normal mode<br>rotation'):done()
		:tag('th'):attr('rowspan',7):css('width','0.25em'):done()
		:tag('th'):attr('colspan',2):wikitext('Hard mode phase 10'):done()
		:tag('th'):attr('colspan',2):wikitext('Hard mode phase 11'):done()
		:tag('th'):attr('rowspan',7):css('width','0.25em'):done()
		:tag('th'):wikitext('Next start (UTC)'):done()
		:tag('th'):wikitext('Countdown'):done()
	
	for _,rot in ipairs(data) do
		local tr = t:tag('tr')
		tr:addClass('rotation-item')
		tr:tag('td'):addClass('rotation-label'):wikitext('<div class="rotation-label-before"></div><div class="rotation-label-text">', rot[1], '</div>'):done()
			:tag('td'):wikitext(rot[2]):done()
			:tag('td'):wikitext(rot[3]):done()
			:tag('td'):wikitext(rot[4]):done()
			:tag('td'):wikitext(rot[5]):done()
			:tag('td'):addClass('rotation-next-start'):done()
			:tag('td'):addClass('rotation-countdown'):done()
	end
	return tostring(t)
end

function p.rots_data()
	local A = 'Ahrim'
	local D = 'Dharok'
	local G = 'Guthan'
	local K = 'Karil'
	local T = 'Torag'
	local V = 'Verac'
	-- Array originally from http://www.pso-clan.com/rotations.js
	return '2025-08-20 00:00:00', {
		{{D,T,V},{K,A,G}},
		{{K,T,G},{A,D,V}},
		{{K,G,V},{A,T,D}},
		{{G,T,V},{K,A,D}},
		{{K,T,V},{A,G,D}},
		{{A,G,D},{K,T,V}},
		{{K,A,D},{G,T,V}},
		{{A,T,D},{K,G,V}},
		{{A,D,V},{K,T,G}},
		{{K,A,G},{T,D,V}},
		{{A,T,G},{K,D,V}},
		{{A,G,V},{K,T,D}},
		{{K,A,T},{G,D,V}},
		{{K,A,V},{D,T,G}},
		{{A,T,V},{K,D,G}},
		{{K,D,G},{A,T,V}},
		{{D,T,G},{K,A,V}},
		{{G,D,V},{K,A,T}},
		{{K,T,D},{A,G,V}},
		{{K,D,V},{A,T,G}}
	}
end
function p.rots()
	local starttime, data = p.rots_data()
	local s = mw.html.create('div')
	s:addClass('rotation-group rotation-group-rots tile'):attr({
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-start']=starttime,
		['data-rotation-active']='{"d":1}',
		['data-rotation-fullperiod']='{"d":20}',
		['data-rotation-next-within']='{"d":1}',
		['data-rotation-itemperiod']='{"d":1}',
		['data-rotation-option-showonlyactive']="true"
	})
	local args = getargs()
	if args.float then
		s:css({
			margin='3px',
			float=args.float,
			clear=args.float
		})
	end
	s:tag('div'):addClass('rotation-showuntilsetup'):wikitext('Loading rotations...')
	for i,rot in ipairs(data) do
		local w = {}
		for j,bro in ipairs(rot[1]) do
			table.insert(w, '<span class="rotation-rots-bro">[[File:'..bro..' the Bobbled chathead.png|30x30px|link=]]&nbsp;'..bro..'</span>')
		end
		local e = {}
		for j,bro in ipairs(rot[2]) do
			table.insert(e, '<span class="rotation-rots-bro">[[File:'..bro..' the Bobbled chathead.png|30x30px|link=]]&nbsp;'..bro..'</span>')
		end
		s:tag('span'):addClass('rotation-item rotation-hideuntilsetup')
			:tag('span'):wikitext('Current rotation for <span class="rotation-current-day"></span>'):done()
			:tag('span'):addClass('rotation-rots-side rotation-rots-west'):wikitext(table.concat(w, '')):done()
			:tag('span'):addClass('rotation-rots-side rotation-rots-east'):wikitext(table.concat(e, '')):done()
			:tag('span'):addClass('rotation-countdown'):done()
	end
	return tostring(s)
end
function p.rots_next()
	local starttime, data = p.rots_data()
	local t = mw.html.create('table')
	t:addClass('rotation-group wikitable align-center-3 align-right-4'):attr({
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-start']=starttime,
		['data-rotation-active']='{"d":1}',
		['data-rotation-fullperiod']='{"d":20}',
		['data-rotation-next-within']='{"d":1}',
		['data-rotation-itemperiod']='{"d":1}',
	})
	t:tag('tr')
		:tag('th'):wikitext('West'):done()
		:tag('th'):wikitext('East'):done()
		:tag('th'):wikitext('Next'):done()
		:tag('th'):wikitext('Countdown'):done()
	for i,rot in ipairs(data) do
		t:tag('tr'):addClass('rotation-item')
			:tag('td'):addClass('rotation-label'):wikitext('<div class="rotation-label-before"></div><div class="rotation-label-text">', table.concat(rot[1], ', '), '</div>'):done()
			:tag('td'):wikitext(table.concat(rot[2], ', ')):done()
			:tag('td'):addClass('rotation-next-start'):done()
			:tag('td'):addClass('rotation-countdown'):done()
	end
	return tostring(t)
end

function p.thdnd()
	local data = {
		'Evil Tree',
		'Shooting Star',
		'Penguin Hide and Seek',
		'Circus'
	}
	local s = mw.html.create('div')
	s:addClass('rotation-group rotation-group-thdnd tile'):attr({
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-start']='2025-07-30 00:00:00',
		['data-rotation-active']='{"d":7}',
		['data-rotation-fullperiod']='{"d":28}',
		['data-rotation-next-within']='{"d":0}',
		['data-rotation-itemperiod']='{"d":7}',
		['data-rotation-option-sorttotop']='true'
	})
	for i,rot in ipairs(data) do
		s:tag('span'):addClass('rotation-item')
			:tag('div'):addClass('rotation-active-text'):attr('data-rotation-aftertext', 'Future featured D&Ds')
				:tag('div'):wikitext('Current featured D&D'):done()
				:tag('div'):wikitext('[['..rot..']]'):done()
				:tag('div'):addClass('rotation-countdown'):done()
			:done():tag('span'):addClass('rotation-inactive-text')
				:tag('span'):wikitext('[['..rot..']]'):done()
				:tag('span'):addClass('rotation-next-start'):done()
				:tag('span'):addClass('rotation-countdown'):done()
	end
	return tostring(s)
end

function p.circus_data()
	return {
		{
			name = '[[Al Kharid]]',
			text = 'Al Kharid',
			coord = '3313,3206',
			short = 'Al Kharid'
		},
		{
			name = '[[Varrock]] - north of [[Gertrude]]\'s house',
			text = 'Varrock - north of Gertrude\'s house',
			coord = '3144,3424',
			short = 'Gertrude\'s'
		},
		{
			name = '[[Seers\' Village]]',
			text = 'Seers\' Village',
			coord = '2689,3475',
			short = 'Seers\' Village'
		},
		{
			name = '[[Edgeville]]',
			text = 'Edgeville',
			coord = '3118,3504',
			short = 'Edgeville'
		},
		{
			name = '[[Draynor Village]]',
			text = 'Draynor Village',
			coord = '3098,3213',
			short = 'Draynor'
		},
		{
			name = '[[Varrock]] - east of [[Statue (Saradomin)|Saradomin Statue]], on [[King\'s Road]]',
			text = 'Varrock - east of Saradomin Statue, on King\'s Road',
			coord = '3300,3467',
			short = 'King\'s Road'
		},
		{
			name = '[[Tree Gnome Stronghold]] - south of the entrance; near the gate',
			text = 'Tree Gnome Stronghold',
			coord = '2444,3381',
			short = 'Tree Gnome'
		},
		{
			name = '[[Taverley]]',
			text = 'Taverley',
			coord = '2891,3470',
			short = 'Taverley'
		},
		{
			name = '[[Rimmington]]',
			text = 'Rimmington',
			coord = '2950,3234',
			short = 'Rimmington'
		},
		{
			name = '[[Lumbridge]]',
			text = 'Lumbridge',
			coord = '3210,3276',
			short = 'Lumbridge'
		},
		{
			name = '[[Wendlewick]]',
			text = 'Wendlewick',
			coord = '4232,3326',
			short = 'Wendlewick'
		},
		{
			name = '[[Catherby]]',
			text = 'Catherby',
			coord = '2791,3456',
			short = 'Catherby'
		},
		{
			name = '[[Falador]]',
			text = 'Falador',
			coord = '3027,3349',
			short = 'Falador'
		}
	}
end
function p.circus_list()
	local makemap = require('Module:Map/templates')._maptemp
	local ul = mw.html.create('ul')
	local data = p.circus_data()
	for i,rot in ipairs(data) do
		ul:tag('li'):wikitext(makemap({[1]=rot.coord, text=rot.text}, {type='maplink'}))
	end
	return tostring(ul)
end
function p.circus_city()
	local data = p.circus_data()
	local s = mw.html.create('span'):addClass('rotation-group rotation-group-noactivestyle'):attr({
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-start']='2026-03-25 00:00:00',
		['data-rotation-active']='{"d":7}',
		['data-rotation-fullperiod']='{"d":91}',
		['data-rotation-next-within']='{"d":0}',
		['data-rotation-itemperiod']='{"d":7}',
		['data-rotation-option-showonlyactive']='true'
	})
	for i,rot in ipairs(data) do
		s:tag('span'):addClass('rotation-item'):wikitext(rot.name)
	end
	return tostring(s)
end
function p.circus_table()
	local makemap = require('Module:Map/templates')._maptemp
	local data = p.circus_data()
	local t = mw.html.create('table'):addClass('rotation-group rotation-group-circus wikitable align-center-2'):attr({
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-start']='2026-03-25 00:00:00',
		['data-rotation-active']='{"d":7}',
		['data-rotation-fullperiod']='{"d":91}',
		['data-rotation-next-within']='{"d":0}',
		['data-rotation-itemperiod']='{"d":7}',
	})
	local maprow = t:tag('tr')
	maprow:tag('th'):wikitext('Location'):done():tag('th'):wikitext('Date')
	for i,rot in ipairs(data) do
		t:tag('tr'):addClass('rotation-item')
			:tag('td'):addClass('rotation-label'):wikitext('<div class="rotation-label-before"></div><div class="rotation-label-text">', rot.short, '</div>'):done()
			:tag('td'):addClass('rotation-next-start'):done()
		maprow:tag('td'):attr('rowspan', 14):addClass('rotation-item-associated'):wikitext(makemap({[1]=rot.coord, mtype='square', width=250, height=250}, {})):wikitext('<span>', rot.name,'</span><span class="rotation-countdown"></span>')
	end
	return tostring(t)
end
function p.circus()
	local args = getargs()
	local ty = tostring(args[1]):lower()
	if ty == 'list' then
		return p.circus_list()
	elseif ty == 'city' then
		return p.circus_city()
	else
		return p.circus_table()
	end
end

function p.icxan()
	local data = {
	    'Grotworm Lair (Port Sarim)',
		'Wizards\' Tower',
		'Nardah',
		'Slayer Tower (Canifis)',
		'Sawmill (Varrock)',
		'Draynor Manor',
		'White Wolf Mountain',
		'Skavid caves',
		'Oo\'glog',
		'Falador',
	}
	local t = mw.html.create('table')
	t:addClass('rotation-group wikitable align-center-2 align-right-3')
		:attr({
			['data-rotation-nexttimeformat']="HH:mm",
			['data-rotation-start']='2025-08-29 11:00:00',
			['data-rotation-active']='{"h":1}',
			['data-rotation-fullperiod']='{"h":10}',
			['data-rotation-itemperiod']='{"h":1}',
			['data-rotation-next-within']='{"h":1}'
		})
	t:tag('tr')
		:tag('th'):wikitext('Location'):done()
		:tag('th'):wikitext('Next start (UTC)'):done()
		:tag('th'):wikitext('Countdown'):done()
	for _,event in ipairs(data) do
		local tr = t:tag('tr')
		tr:addClass('rotation-item')
			:tag('td'):addClass('rotation-label'):wikitext('<div class="rotation-label-before"></div><div class="rotation-label-text">', event, '</div>'):done()
			:tag('td'):addClass('rotation-next-start'):done()
			:tag('td'):addClass('rotation-countdown'):done()
	end
	return tostring(t)
end

function p.edspotlight()
	local data = {
	    'Temple of Aminishi',
	    'Dragonkin Laboratory',
	    'The Shadow Reef',
	}
	local s = mw.html.create('div')
	s:addClass('rotation-group rotation-group-thdnd tile'):attr({
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-start']='2025-08-24 00:00:00',
		['data-rotation-active']='{"d":1}',
		['data-rotation-fullperiod']='{"d":6}',
		['data-rotation-next-within']='{"d":0}',
		['data-rotation-itemperiod']='{"d":1}',
		['data-rotation-option-sorttotop']='true'
	})
	for i=0,1 do --twice to show next spotlight of each
		for j,rot in ipairs(data) do
			s:tag('span'):addClass('rotation-item')
				:tag('div'):addClass('rotation-active-text'):attr('data-rotation-aftertext', 'Future Elite Dungeon spotlights')
					:tag('div'):wikitext('Current Elite Dungeon spotlight'):done()
					:tag('div'):wikitext('[['..rot..']]'):done()
					:tag('div'):addClass('rotation-countdown'):done()
				:done():tag('span'):addClass('rotation-inactive-text')
					:tag('span'):wikitext('[['..rot..']]'):done()
					:tag('span'):addClass('rotation-next-start'):done()
					:tag('span'):addClass('rotation-countdown'):done()
			
		end
	end
	return tostring(s)

end

function p.monthly(frame)
	local name = (frame and (frame:getParent() or frame).args.name) or mw.title.getCurrentTitle().text
	local data = {
		-- repeats 4 times because of leap years
		-- i'm not adding the 100- and 400-year rules
		{'2020-01-01 00:00:00', 31, 'January'},
		{'2020-02-01 00:00:00', 29, 'February'},
		{'2020-03-01 00:00:00', 31, 'March'},
		{'2020-04-01 00:00:00', 30, 'April'},
		{'2020-05-01 00:00:00', 31, 'May'},
		{'2020-06-01 00:00:00', 30, 'June'},
		{'2020-07-01 00:00:00', 31, 'July'},
		{'2020-08-01 00:00:00', 31, 'August'},
		{'2020-09-01 00:00:00', 30, 'September'},
		{'2020-10-01 00:00:00', 31, 'October'},
		{'2020-11-01 00:00:00', 30, 'November'},
		{'2020-12-01 00:00:00', 31, 'December'},
		
		{'2021-01-01 00:00:00', 31, 'January'},
		{'2021-02-01 00:00:00', 28, 'February'},
		{'2021-03-01 00:00:00', 31, 'March'},
		{'2021-04-01 00:00:00', 30, 'April'},
		{'2021-05-01 00:00:00', 31, 'May'},
		{'2021-06-01 00:00:00', 30, 'June'},
		{'2021-07-01 00:00:00', 31, 'July'},
		{'2021-08-01 00:00:00', 31, 'August'},
		{'2021-09-01 00:00:00', 30, 'September'},
		{'2021-10-01 00:00:00', 31, 'October'},
		{'2021-11-01 00:00:00', 30, 'November'},
		{'2021-12-01 00:00:00', 31, 'December'},
		
		{'2022-01-01 00:00:00', 31, 'January'},
		{'2022-02-01 00:00:00', 28, 'February'},
		{'2022-03-01 00:00:00', 31, 'March'},
		{'2022-04-01 00:00:00', 30, 'April'},
		{'2022-05-01 00:00:00', 31, 'May'},
		{'2022-06-01 00:00:00', 30, 'June'},
		{'2022-07-01 00:00:00', 31, 'July'},
		{'2022-08-01 00:00:00', 31, 'August'},
		{'2022-09-01 00:00:00', 30, 'September'},
		{'2022-10-01 00:00:00', 31, 'October'},
		{'2022-11-01 00:00:00', 30, 'November'},
		{'2022-12-01 00:00:00', 31, 'December'},
		
		{'2023-01-01 00:00:00', 31, 'January'},
		{'2023-02-01 00:00:00', 28, 'February'},
		{'2023-03-01 00:00:00', 31, 'March'},
		{'2023-04-01 00:00:00', 30, 'April'},
		{'2023-05-01 00:00:00', 31, 'May'},
		{'2023-06-01 00:00:00', 30, 'June'},
		{'2023-07-01 00:00:00', 31, 'July'},
		{'2023-08-01 00:00:00', 31, 'August'},
		{'2023-09-01 00:00:00', 30, 'September'},
		{'2023-10-01 00:00:00', 31, 'October'},
		{'2023-11-01 00:00:00', 30, 'November'},
		{'2023-12-01 00:00:00', 31, 'December'},
	}
	local s = mw.html.create('div')
		s:addClass('rotation-group rotation-group-monthlies'):attr({
			['data-rotation-nexttimeformat']="D MMM, HH:mm:ss (UTC)",
			['data-rotation-start']='2020-01-01 00:00:00',
			['data-rotation-fullperiod']='{"d":1461}',
			['data-rotation-next-within']='{"d":0}',
			['data-rotation-option-sorttotop']='true',
			['data-rotation-active'] =  '{"s":1}',
			--['data-rotation-option-show-active-only']='true'
		})
		:tag('div'):addClass('rotation-showuntilsetup tile'):wikitext('Loading rotations...'):done()
		for j,rot in ipairs(data) do
			s:tag('div'):addClass('rotation-item rotation-hideuntilsetup tile'):attr({
						['data-rotation-itemperiod'] = '{"d":'..rot[2]..'}',
						['data-rotation-start'] = rot[1]
					})
				:tag('span'):addClass('rotation-active-text'):wikitext('The next monthly reset is in <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>'):done()
				:tag('span'):addClass('rotation-inactive-text'):wikitext('The next monthly reset is in <span class="rotation-countdown"></span> at <span class="rotation-next-start"></span>'):done()
			s:newline()
		end
	return tostring(s)

end

return p