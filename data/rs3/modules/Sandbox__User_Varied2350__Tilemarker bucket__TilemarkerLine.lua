local p = {}

local params = require('Module:Paramtest')
local yesno = require('Module:Yesno')
local preview = require('Module:Sandbox/User:Varied2350/Tilemarkers bucket/Tilemarkers map')._main

function p.main(frame)
	-- parse args
	local args = frame:getParent().args
	
	-- passthrough to Tilemarkers preview and grab relevant information and for
	-- writing to bucket
	
	--format response
	local ret = mw.html.create('tr')
		:css('text-align', 'center')
	
	-- Title
	ret:tag('td')
	
	-- Location
	ret:tag('td')
		:wikitext(args.location)
	
	-- Description
	ret:tag('td')
		:wikitext(args.description)
	
	-- Tags
	ret:tag('td')
		:wikitext(args.tags)
	
	-- League Region
	ret:tag('td')
		:wikitext(args.leagueRegion)
	
	-- Author
	ret:tag('td')
		:wikitext(args.author)
	
	-- Preview / TM2 Code
	ret:tag('td')
		:node(preview(args))
		
	return ret
end

return p