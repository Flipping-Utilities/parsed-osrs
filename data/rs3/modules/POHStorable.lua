require('Module:Mw.html extension')
local plinkt = require("Module:Plink")._plinkt
local hc = require('Module:Paramtest').has_content
local yn = require('Module:Yesno')

local p = {}

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

local function search_arg(args, i)
    local matroot = 'item'..i
    local matimg = matroot..'img'
    local matname = matroot..'name'
    
	if args[matroot] then
		return {
			link = args[matroot],
			pic = args[matimg] or args[matroot],
			name = args[matname] or args[matroot],
		}
	else
		return nil
	end
end

local function search_args(args)
	local items = {}
	local i = 1
	
	while i do
		local item = search_arg(args, tostring(i))
		if item then
			items[i] = {}
			items[i][1] = item
			local alti = 1
			while alti do
			    local altitem = search_arg(args, tostring(i)..'alt'..tostring(alti))
				if altitem then
					items[i][alti + 1] = altitem
				else
					alti = nil
					break
				end

				alti = alti + 1
			end

			i = i + 1
		else
			i = nil
			break
		end
	end
	
	return items
	
end

function p._main(args)
	local items = search_args(args)
	if #items == 0 then
	    -- create table
	    return mw.html.create()
	    	-- create text
	        :node(p.create_text(args, items))
	else
		-- create table
		return mw.html.create()
			-- create text
		    :node(p.create_text(args, items))
		    -- create table
			:node(p.create_table(items))
	end

end

function p.create_text(args, items)
	local name = args.name or mw.title.getCurrentTitle().fullText
	local text
	if args.type == 'easy treasure chest' then
		text = 'It can be stored in the easy-level section of a [[treasure chest]] in the [[player-owned house]][[Category:Items that can be stored in the easy treasure chest]]'
	elseif args.type == "medium treasure chest" then
		text = 'It can be stored in the medium-level section of a [[treasure chest]] in the [[player-owned house]][[Category:Items that can be stored in the medium treasure chest]]'
	elseif args.type == "hard treasure chest" then
		text = 'It can be stored in the hard-level section of a [[treasure chest]] in the [[player-owned house]][[Category:Items that can be stored in the hard treasure chest]]'
	elseif args.type == "elite treasure chest" then
		text = 'It can be stored in the elite-level section of a [[treasure chest]] in the [[player-owned house]][[Category:Items that can be stored in the elite treasure chest]]'
	elseif args.type == "master treasure chest" then
		text = 'It can be stored in the master-level section of a [[treasure chest]] in the [[player-owned house]][[Category:Items that can be stored in the master treasure chest]]'
	elseif args.type == "fancy dress box" then
		text = 'It can be stored in a [[fancy dress box]] in the [[player-owned house]][[Category:Items that can be stored in the fancy dress box]]'
	elseif args.type == "armour case" then
		text = 'It can be stored in an [[armour case]] in the [[player-owned house]][[Category:Items that can be stored in the armour case]]'
	elseif args.type == "magic wardrobe" then
		text = 'It can be stored in a [[magic wardrobe]] in the [[player-owned house]][[Category:Items that can be stored in the magic wardrobe]]'
	elseif args.type == "cape store" then
		text = 'It can be stored on a [[cape store]] in the [[player-owned house]][[Category:Items that can be stored on a cape store]]'
	else
		return mw.html.create('p'):wikitext('Invalid parameter provided for POH storage container type')
	end
	
	text = text..'[[Category:Items that can be stored in the player-owned house]]'
	
	if #items == 0 then
		text = text..'.'
	else
		text = text..' requiring all items from its set:'
	end
	
	return mw.html.create('p'):wikitext(text)
end

function p.create_table(items)
	local Max_item_alts = 1
	for i=1,#items do
		Max_item_alts = math.max(Max_item_alts, #items[i])
	end
	
	local nullval = mw.html.create('td')
		:addClass('table-na')
		:attr({colspan=2})
		:wikitext('-')
	:done()
	
	local tab = mw.html.create('table')
		:addClass('wikitable mw-collapsible mw-collapsed'):css("min-width", "250px")
		:tag('tr')
		    :tag('th')
	            :attr({colspan=Max_item_alts * 2})
	            :wikitext('Storage set')
	        :done()
	    :done()
	    
	-- Only create Item headers if it is ambiguous what the headers would refer to
	if Max_item_alts >= 2 then
	    local tabheader = mw.html.create('tr'):tag('th')
	        :attr({colspan=2})
	        :wikitext('Item')
	    :done()
	    
	    if Max_item_alts == 2 then
	    	-- If only 1 alt, do not put a # on it, i.e. only specify if it is ambiguous which alt item the header would refer to
	    	tabheader:tag('th')
	    		:attr({colspan=2})
	    		:wikitext('Alt Item')
	    	:done()
	    else
	    	for i=2,Max_item_alts do
	    		tabheader:tag('th')
	    			:attr({colspan=2})
	    			:wikitext('Alt Item '..tostring((i - 1)))
	    		:done()
	    	end
	    end
	    
	    tab:node(tabheader):done()
	end
	
	

	
	for i=1,#items do
		local row = tab:tag('tr')
		for alti=1,#items[i] do
			local item_plinkt = items[i][alti] and plinkt(_,items[i][alti]) or nullrow
			row:node(item_plinkt)
		end
		for nullrowi=#items[i]+1,Max_item_alts do
			row:node(nullval)
		end
		row:done()
	end

	return tab

end

return p