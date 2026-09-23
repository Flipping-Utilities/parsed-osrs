local p = {}

local paramtest = require('Module:Paramtest')
local yesno = require('Module:Yesno')
local default = paramtest.default_to

-- string.lower which also accepts `nil` values without erroring
function lc(str)
	return str and string.lower(str)
end

-- array contains val
function contains(tbl, val)
	for _, item in ipairs(tbl) do
		if item == val then
			return true
		end
	end
	return false
end

-- multiply num by mul, rounded to 1 decimal
function times(num, mul)
	return math.floor((tonumber(num) or 0) * mul * 10) / 10
end

-- overwrite the arg properties listed in tbl with their associated value
function overwrite(args, tbl, rmargs)
	local newargs = {}
	-- by default, translate |version= to |bucketname= for all presets
	if paramtest.has_content(args.version) then
		tbl.bucketname = args.version
	end
	table.insert(rmargs, 'version')
	-- make a copy to work in, but omit all rmargs
	for prop, val in pairs(args) do
		if not contains(rmargs, prop) then
			newargs[prop] = val
		end
	end
	-- perform conversions
	for prop, val in pairs(tbl) do
		-- overwrite only if the destination is not already defined
		if paramtest.is_empty(args[prop]) then
			newargs[prop] = val
		end
	end
	return newargs
end

function overwrite2(args, map, labels)
	local newargs = {}
	-- by default, translate |version= to |bucketname= for all presets
	if paramtest.has_content(args.version) then
		map.version = 'bucketname'
	end
	-- make a copy to work in
	for prop, val in pairs(args) do
		local num = string.match(prop, "%d+$") or ''
		local nonum = string.gsub(prop, num..'$', '')
		local mapped = map[nonum]
		if mapped and not tonumber(mapped[#mapped]) then
			-- only add the number back if the map target doesn't already specify a switch number
			mapped = mapped .. num
		end
		if mapped then
			-- if a map exists, insert the specified value from this parameter.
			-- If the user manually set this parameter already, don't override
			newargs[mapped] = args[mapped] or val
		else
			-- not in the list to copy, so no mapping to do; simply copy it from the original
			newargs[prop] = val
		end
	end
	-- copy labels array to newargs, if not already set
	for prop, val in pairs(labels) do
		-- overwrite only if the destination is not already defined
		newargs[prop] = newargs[prop] or val
	end
	return newargs
end

function p.agility(args)
	local map = {
		level = 'skill1lvl',
		xp = 'skill1exp',
		xpnote = 'skill1note',
		failxp = 'skill2exp',
		course = 'loc',
	}
	local labels = {
		skill1name = "Agility",
		skill2label = "XP on failure",
		locname = "[[Agility course]]",
	}
	local mustargs = {
		'type',
	}
	return overwrite2(args, map, labels), mustargs
end

function p.firemaking(args)
	local map = {
		level = 'skill1lvl',
		xp = 'skill1exp',
		xpnote = 'skill1note',
	}
	local labels = {
		skill1name = "Firemaking",
		tool = "[[Tinderbox]]",
	}
	local mustargs = {
		'tool', 'type'
	}

	if lc(args.type) == 'logs' then
		-- nothing which explicitly sets bowlevel to "no":
		-- if bowlevel = no then only the main version is shown.
		if args.bowlevel == nil or yesno(args.bowlevel, true) then
			labels.version1 = "Tinderbox"
			labels.skill1note2 = "Requires [[Barbarian Firemaking]] training.<br/>"..(args.xpnote2 or args.xpnote or '')
			labels.version2 = "Bow"
			labels.tool2 = "[[Bow]]"
			map.bowlevel = 'skill1lvl2'
			-- same xp, so no xp2
			table.insert(mustargs, 'skill1lvl2') -- prevent this from assuming the value from normal burning
			if paramtest.has_content(args.pyrelevel) then
				labels.version3 = "Barbarian pyre"
				labels.skill1lvl3 = args.pyrelevel
				labels.skill1note3 = labels.skill1note2
				labels.skill2name3 = "Crafting"
				map.pyrelevel = 'skill2lvl3'
				labels.skill2exp = '-1'
				map.craftxp = 'skill2exp3'
				labels.tool3 = "[[Tinderbox]] or [[bow]], and an [[axe]]"
				labels.facility = "N/A"
				labels.facility3 = "[[Funeral Pyre (barbarian)|Barbarian funeral pyre]]"
			end
		end
	elseif lc(args.type) == 'pyre' then
		labels.facility = "[[Funeral Pyre (Mort'ton)|Mort'ton funeral pyre]]"
		labels.skill2name = "Prayer"
		labels.skill2lvl = '1'
	elseif lc(args.type) == 'light' then
		labels.skill1exp = '0'
	end
	local newargs = overwrite2(args, map, labels)
	if lc(newargs.tool) == 'no' then newargs.tool = 'N/A' end
	local types = {
		logs = 'Logs',
		pyre = '[[Pyre logs]]',
		light = '[[Light sources|Light source]]',
		other = 'Other',
	}
	newargs.type = types[lc(args.type)]
	return newargs, mustargs
end

function p.fishing(args)
	local map = {
		level = 'skill1lvl',
		xp = 'skill1exp',
		xpnote = 'skill1note',
		spot = 'facility',
		bait = 'item',
	}
	local labels = {
		skill1name = "Fishing",
		facilityname = "[[Fishing spot]]",
		itemname = 'Bait',
	}
	local mustargs = {
		'tool', 'item', 
	}
	local newargs = overwrite2(args, map, labels)
	if lc(newargs.tool) == 'no' then newargs.tool = 'N/A' end
	if lc(newargs.item) == 'no' then newargs.item = 'N/A' end
	return newargs, mustargs
end

function p.hunter(args)
	local map = {
		level = 'skill1lvl',
		xp = 'skill1exp',
		xpnote = 'skill1note',
		retaliation = 'type',
		trap = 'tool',
	}
	local labels = {
		skill1name = "Hunter",
		typename = "Retaliation",
		toolname = "Trap",
	}
	local mustargs = {
		'tool', 'type',
	}
	if paramtest.has_content(args.bait) then
		labels.itemname = "Bait"
		map.bait = 'item'
	elseif paramtest.has_content(args.container) then
		labels.itemname = "Container"
		map.container = 'item'
	end
	if string.find(lc(args.name) or '', 'impling') then
		labels.version1 = 'Net'
		labels.version2 = 'Bare-handed'
		labels.tool2 = 'None'
		labels.skill1lvl2 = args.level2 or tonumber(args.level) + 10
		if lc(args.name) ~= 'crystal impling' then
			labels.skill1label = '[[Puro Puro]] XP'
			labels.skill2label = 'Overworld XP'
			map.wildxp = 'skill2exp'
			labels.type = '[[Imp defender]]s in [[Puro Puro]]'
			table.insert(mustargs, 'skill2exp')
		end
	end
	local newargs = overwrite2(args, map, labels)
	-- default for barehanded is the specified level + 10. Due to not being a direct param value this can't be done through the normal `map` array.
	return newargs, mustargs
	
end

function p.mining(args)
	local map = {
		level = 'skill1lvl',
		xp = 'skill1exp',
		xpnote = 'skill1note',
		rock = 'facility',
	}
	local labels = {
		skill1name = "Mining",
		facilityname = "Rock",
	}
	local mustargs = {
		'tool', 'time',
	}
	return overwrite2(args, map, labels), mustargs
end

function p.prayer(args)
	local map = {
		level = 'skill1lvl',
		xp = 'skill1exp',
		xpnote = 'skill1note',
	}
	local labels = {
		skill1name = "Prayer",
	}
	-- Customisations based on the type of prayer object
	if lc(args.type) == 'bone' then
		local i = 1
		-- switch infobox with different ways to offer bones
		if lc(args.burying) ~= "no" then
			labels['version'..i] = "Burying"
			labels['skill2label'..i] = "[[Bonecrusher]] <sup>([[Morytania Hard Diary|Hard Diary]])</sup>"
			if lc(args.bonecrusher) == 'no' then
				labels['skill2exp'..i] = -1
			else
				labels['skill2exp'..i] = times(args.xp, 0.5) or nil
			end
			labels['facility'..i] = "N/A"
			i = i + 1
		end
		if lc(args.altar) ~= "no" then
			labels['version'..i] = "Gilded/Chaos altar"
			labels['skill1exp'..i] = times(args.xp, 3.5) or nil
			labels['skill2label'..i] = "No [[burners]]"
			labels['skill2exp'..i] = times(args.xp, 2.5) or nil
			labels['facility'..i] = "[[Gilded altar]], [[Chaos altar (Wilderness)|Wilderness chaos altar]]"
			i = i + 1
		end
		if lc(args.sinister) ~= "no" then
			labels['version'..i] = "Sinister Offering"
			labels['skill2name'..i] = "Magic"
			labels['skill2lvl'..i] = 92
			labels['skill1exp'..i] = times(args.xp, 3) or nil
			labels['skill2exp'..i] = 180
			labels['facility'..i] = "[[Sinister Offering]]"
			i = i + 1
		end
		if lc(args.ectofuntus) ~= "no" then
			labels['version'..i] = "Ectofuntus"
			labels['skill1label'..i] = "[[Prayer|Prayer XP]] <br /><sup>(w/ [[Bucket of slime]])</sup>"
			labels['skill1exp'..i] = times(args.xp, 4) or nil
			labels['skill2exp'..i] = -1
			labels['type'..i] = "Bonemeal"
			labels['facility'..i] = "[[Ectofuntus]]"
			i = i + 1
		end
		if lc(args.libation) ~= "no" then
			labels['version'..i] = "Libation bowl"
			labels['skill1lvl'..i] = 30
			labels['skill2label'..i] = "<sup>w/ [[jug of blessed sunfire wine|Jug of blessed sunfire wine]]</sup>"
			if args.shardQty then
				labels['skill1label'..i] = "[[Prayer|Prayer XP]] <sup>(per bone)<br />w/ [[jug of blessed wine|Jug of blessed wine]]</sup>"
				labels['skill1exp'..i] = times(args.shardQty, 5) or nil
				labels['skill2exp'..i] = times(args.shardQty, 6) or nil
			else
				labels['skill1label'..i] = "[[Prayer|Prayer XP]] <sup>(per shard)<br />w/ [[jug of blessed wine|Jug of blessed wine]]</sup>"
				labels['skill1exp'..i] = 5
				labels['skill2exp'..i] = 6
			end
			labels['type'..i] = "Blessed bone shards"
			labels['facility'..i] = "[[Libation bowl]]"
			i = i + 1
		end
	elseif lc(args.type) == 'bonemeal' then
		labels.item = "[[Bucket of slime]]"
		labels.facility = "[[Ectofuntus]]"
	elseif lc(args.type) == 'fossil' then
		labels.facility = "[[Strange Machine]]"
	elseif lc(args.type) == 'ashes' then
		labels.version1 = "Scattering"
		labels.skill2label1 = "-"
		labels.skill2exp1 = -1 -- negative xp hides this cell
		labels.facility1 = "N/A"
		labels.version2 = "Demonic Offering"
		labels.skill2name2 = "Magic"
		labels.skill2lvl2 = 84
		labels.skill1exp2 = times(args.xp, 3) or nil
		labels.skill2exp2 = 175
		labels.facility2 = "[[Demonic Offering]]"
	elseif lc(args.type) == 'spectral' then
		labels.tool = "[[Ectoplasmator]]"
	end
	local mustargs = {
		'type',
	}
	local newargs = overwrite2(args, map, labels)
	local types = {
		bone = 'Bones',
		bonemeal = '[[Bonemeal]]',
		fossil = '[[Enriched bone]]',
		offer = 'Offering',
		ashes = '[[Demonic ashes]]',
		reanimated = 'Reanimated [[ensouled head]]',
		spectral = '[[Spectral (attribute)|Spectral creature]]',
		other = 'Other',
	}
	newargs.type = types[lc(args.type)]
	return newargs, mustargs
end

function p.thieving(args)
	local map = {
		level = 'skill1lvl',
		xp = 'skill1exp',
		xpnote = 'skill1note',
	}
	local labels = {
		skill1name = "Thieving",
		toolname = "Tool",
	}
	local mustargs = {
	}
	if lc(args.type) == 'stall' then
		table.insert(mustargs, 'time')
		labels['timename'] = 'Restock time'
	end
	return overwrite2(args, map, labels), mustargs
end

function p.woodcutting(args)
	local map = {
		level = 'skill1lvl',
		xp = 'skill1exp',
		xpnote = 'skill1note',
		tree = 'facility',
	}
	local labels = {
		skill1name = "Woodcutting",
		facilityname = "Tree",
	}
	local mustargs = {
		'tool', 'time',
	}
	mw.logObject({map, labels, mustargs})
	return overwrite2(args, map, labels), mustargs
end

function p.sailing(args)
	local map = {
		level = 'skill1lvl',
		xp = 'skill1exp',
		xpnote = 'skill1note'
	}
	local labels = {
		skill1name = "Sailing",
		toolname = "Tool",
		facilityname = "Facility",
	}
	local mustargs = {
	}
	if (string.find(lc(args.name) or '', 'shipwreck')) then
		labels.skill1label = 'Salvaging XP'
	elseif (string.find(lc(args.name) or '', 'salvage')) then
		labels.skill1label = 'Sorting XP'
	end
	mw.logObject({map, labels, mustargs})
	return overwrite2(args, map, labels), mustargs
end

return p