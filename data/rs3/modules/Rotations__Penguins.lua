-- <nowiki>
require("strict")
require("Module:Mw.html extension")
local purge = require("Module:Purge")._purge
local rsrandom = require("Module:Rotations/RsRandom")

local p = {}

local data = mw.loadData("Module:Rotations/Penguins/data")
local one_point, two_point, well_order, ghost, well_description
	= data.one_point, data.two_point, data.well_order, data.ghost, data.well_description

-- "regular" penguins turn into pumpkins in October and into snowmen in December
local function check_disguise(tbl)
	local date = os.date("*t")
	local ret = {}
	for k, v in pairs(tbl) do
		ret[k] = v
	end
	if date.month == 4 then
		ret.disguise = "Easter egg"
	elseif date.month == 10 then
		ret.disguise = "Pumpkin"
	elseif date.month == 12 then
		ret.disguise = "Snowman"
	end
	return ret
end

local function wednesday(runedate)
	return math.floor(runedate / 7) * 7
end

function p.get_for_runedate(_runedate)
	local purge_link = not _runedate and purge("wrong?")
	local runedate = wednesday(_runedate or rsrandom.runeDate_today())
	local table_data = {}
	local slotData
	for i = 0, 4 do
		slotData = one_point[rsrandom.nextInt(2^32 + runedate + i, 37) + 1]
		table.insert(table_data, check_disguise(slotData))
	end
	for i = 0, 4 do
		slotData = two_point[rsrandom.nextInt(2^32 + runedate + i, 34) + 1]
		table.insert(table_data, check_disguise(slotData))
	end

	table.insert(table_data, ghost)
	
	slotData = two_point[rsrandom.nextInt(2^32 + runedate + 6, 34) + 1]
	table.insert(table_data, check_disguise(slotData))

	local well_location = well_order[rsrandom.nextInt(2^32 + runedate + 4, 37) + 1]
	table.insert(table_data, well_description[well_location])
	
	local lang = mw.getContentLanguage()

	local pengTable = mw.html.create("table")
		:addClass("wikitable align-right-5")
		:attr("id", "pengLocations")
		:tag("caption")
			:wikitext("For the week beginning: " .. lang:formatDate("j F", "27 February 2002 + " .. runedate .. " days"))
			:wikitextIf(purge_link, purge_link and " " .. purge_link)
		:done()
		:tr()
			:th("No.")
			:th("Spawn area")
			:th("Requirement")
				:addClass("pengToggle")
			:done()
			:th("Type")
			:th("[[Penguin points]]")
			:th("Map<br>(click to enlarge)")
				:addClass("pengToggle")
			:done()
		:done()
	
	local refS = mw.getCurrentFrame():extensionTag{name = "ref", group = "s", content = "This penguin requires [[Some Like It Cold]]."}	
	local refB = mw.getCurrentFrame():extensionTag{name = "ref", group = "s", content = "This penguin requires [[Back to the Freezer]]."}
	local total_pts = 0;
	for i, v in ipairs(table_data) do
		total_pts = total_pts + v.points
		pengTable:tr()
			:td()
				:wikitext(i)
				:wikitextIf(i == 11, refS)
				:wikitextIf(i == 12, refB)
			:done()
			:td(v.location)
			:td(v.requirement)
			:td(v.disguise)
			:td(v.points)
			:IF(v.map == "N/A")
				:na()
			:ELSE()
				:td(v.map)
			:END()
		:done()
	end

	pengTable:tr()
		:addClass("nohighlight")
		:th()
			:css("border-right", "none")
		:done()
		:th()
			:css("border-left", "none")
			:css("border-right", "none")
		:done()
		:th()
			:css("border-left", "none")
			:css("border-right", "none")
			:addClass("pengToggle")
		:done()
		:th("Total")
			:css("text-align", "right")
			:css("border-left", "none")
		:done()
		:td(total_pts)
			:css("text-align", "right")
		:done()
		:th()
			:addClass("pengToggle")
		:done()
	:done()

	return pengTable:allDone()
end

function p.main(frame)
	local args = frame:getParent().args
	local runedate = tonumber(args[1])
	
	return p.get_for_runedate(runedate)
end

return p