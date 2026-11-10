-- <nowiki>
local p = {}

local subjects = {
	chathead			= { h = 100, w = 175 },
	["inventory item"]	= { h =  35, w = 175, class = "pixelated" },
	status				= { h =  27, w = 175, class = "pixelated" },
	dii					= { h = 100, w = 175 },
	equipped			= { h = 200, w = 200 },
	scenery				= { h = 200, w = 300 },
	npc					= { h = 200, w = 200 },
	icon				= { h =  50, w = 175 },
	emote				= { h = 200, w = 175 },
	location			= { h = 150, w = 300 },
	interface			= { h = 200, w = 200 },

	default				= { h = 200, w = 200 },
}

function p.main( frame )
	local args = frame:getParent().args
	local heights = args.heights or 200
	local widths = args.widths or 200
	local subject = string.lower( args.subject or "" )
	if subject ~= "status" then
		subject = string.gsub( subject, "s$", "", 1 )
	end
	local subject_params = subjects[subject] or {}
	local guLines = {}
	local invalid_subject = ( subjects[subject] == nil )
	local cat = ""
	if invalid_subject then
		cat = "[[Category:Graphical updates with invalid subject]]"
	end
	
	if subject ~= nil and subject ~= '' then
		cat = cat .. "[[Category:Graphical updates with subject "..subject.."]]"
	end
	
	for _, v in ipairs( args ) do
		table.insert( guLines, v )
	end
	if #guLines == 0 then
		error( "No graphical updates provided" )
	end
	
	local gargs = {
		mode = "nolines",
		heights = subject_params.h or heights or subjects["default"].h,
		widths = subject_params.w or widths or subjects["default"].w,
	}
	if subject_params.class then
		gargs.class = "gallery-" .. subject_params.class
	end

	local gallery = frame:extensionTag{
		name = "gallery",
		args = gargs,
		content = table.concat( guLines, "\n" )
	}
	local gallery_type = "gu-gallery-"
	if subject == "" or invalid_subject then
		if args.heights == nil then
			gallery_type = gallery_type .. "misc"
		else 
			gallery_type = gallery_type .. "custom"
		end
	elseif subject == "inventory item" then
		gallery_type = gallery_type .. "inventory-item"
	else
		gallery_type = gallery_type .. subject
	end
	
	return '<div class="graphical-update-gallery ' .. gallery_type ..'">' .. gallery .. "</div>" .. cat
end

function p.subjectTable()
	require("Module:Mw.html extension")
	local opairs = require("Module:TableTools").opairs
	
	local ret = mw.html.create("table")
		:addClass( "wikitable align-right-2 align-right-3" )
		:tr()
			:th( "Subject" )
			:th( "Width" )
			:th( "Height" )
			:th( "Class" )
	
	for subj, data in opairs( subjects ) do
		ret:tr()
			:td( "<code>" .. subj .. "</code>" )
			:td( data.w )
			:td( data.h )
			:IF( data.class )
				:td( data.class and "gallery-" .. data.class )
			:ELSE()
				:na()
			:END()
	end
	
	return ret:allDone()
end

function p.subjectPlainList()
	local opairs = require("Module:TableTools").opairs
	local ret = {}
	
	for subj, _ in opairs( subjects ) do
		if subj ~= "default" then
			table.insert( ret, subj )
		end
	end
	
	return '"' .. table.concat( ret, '", "' ) .. '"'
end

return p
-- </nowiki>