local expr = mw.ext.ParserFunctions.expr
local lang = mw.language.getContentLanguage()
local p = {}

function p.DXP( frame )
	local data = frame:callParserFunction{
		name = "#dpl",
		args = {
			"",
			namespace = "",
			titlematch = "Double XP",
			include = "#Events[/{{(Cite|NamedRef).+?}}/s~@<ref>.+?</ref>@~-1]",
		},
	}
	if not( data and #data > 0 ) then
		return error("Failed to DPL [[Double XP]] events")
	end
	
	local dateFunc = data:gmatch( "(%[%[[0-9]?[0-9] [A-z]+%]%] %[%[[0-9][0-9][0-9][0-9]%]%] %([0-9]?[0-9]:[0-9][0-9]%))" )
	local startDate = string.gsub( dateFunc() or "", "[%[%]()]", "" )
	local endDate = string.gsub( dateFunc() or "", "[%[%]()]", "" )
	dateFunc() -- discard previous event's start date
	local prevEndDate = string.gsub( dateFunc() or "", "[%[%]()]", "" )
	if not( #startDate > 0 and #endDate > 0 ) then
		return error("Failed to find start and/or end date under [[Double XP#Events]]")
	end
	
	local timeNow = os.time()
	local startGood, timeStart = pcall( lang.formatDate, lang, "U", startDate )
	local endGood, timeEnd = pcall( lang.formatDate, lang, "U", endDate )
	local prevEndGood, prevTimeEnd = pcall( lang.formatDate, lang, "U", prevEndDate )
	if not( startGood and endGood ) then
		return error( "Start and/or end time for latest event is/are not valid." )
	end

	if timeNow > tonumber( timeEnd, 10 ) then
		return "''DXP counter unavailable; awaiting announcement of next event...''"
	end
	
	local header, img, colourLeft, colourRight, goal, have
	if timeNow < tonumber( timeStart, 10 ) then
		header = "Time (hours) until next DXP event: " .. startDate
		img = "Hourglass.png"
		colourLeft = "dimgray"
		colourRight = "goldenrod"
		goal = expr( string.format( "( %d - %d ) / (60*60) round 1", timeStart, prevEndGood and prevTimeEnd or timeNow ) )
		have = expr( string.format( "( %d - %d ) / (60*60) round 1", timeNow, prevEndGood and prevTimeEnd or timeNow ) )
	else
		header = "DXP time remaining (hours)"
		img = "Double XP icon.png"
		colourLeft = "green"
		colourRight = "dimgray"
		goal = expr( string.format( "( %d - %d ) / (60*60) round 1", timeEnd, timeStart ) )
		have = expr( string.format( "( %d - %d ) / (60*60) round 1", timeNow, timeStart ) )
	end
	
	return header .. "\n" .. frame:expandTemplate{
		title = "SimpleGoal",
		args = {
			Label = string.format( "[[File:%s|link=Double XP]]", img ),
			BarColor1 = colourLeft,
			BarColor2 = colourRight,
			Goal = goal,
			Have = have,
		},
	}
end

return p