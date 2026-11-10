local p = {}

local invmodule = require('Module:Inventory')
local equipmodule = require('Module:Equipment')
local pouchmodule = require('Module:Rune pouch')
local spellmodule = require('Module:Spells')
local static = require('Module:Static')

local slotarray = {
	'head',
	'cape',
	'neck',
	'ammo',
	'ammo2',
	'weapon',
	'ammoquantity',
	'ammo2quantity',
	'weaponquantity',
	'torso',
	'legs',
	'shield',
	'gloves',
	'boots',
	'ring'}

local loadoutmap = {
	[1] = 'head',
	[2] = 'ammo2',
	[4] = '1',
	[5] = '2',
	[6] = '3',
	[7] = '4',
	[8] = 'cape',
	[9] = 'neck',
	[10] = 'ammo',
	[12] = '5',
	[13] = '6',
	[14] = '7',
	[15] = '8',
	[16] = 'weapon',
	[17] = 'torso',
	[18] = 'shield',
	[20] = '9',
	[21] = '10',
	[22] = '11',
	[23] = '12',
	[25] = 'legs',
	[28] = '13',
	[29] = '14',
	[30] = '15',
	[31] = '16',
	[32] = 'gloves',
	[33] = 'boots',
	[34] = 'ring',
	[36] = '17',
	[37] = '18',
	[38] = '19',
	[39] = '20',
	[40] = 'rune1',
	[41] = 'rune2',
	[42] = 'rune3',
	[43] = 'rune4',
	[44] = '21',
	[45] = '22',
	[46] = '23',
	[47] = '24',
	[52] = '25',
	[53] = '26',
	[54] = '27',
	[55] = '28',
}

function p._cleanItem(item)
	if item ~= nil then
		local cleaned = mw.text.trim(item)
		if cleaned ~= '' then
			cleaned = cleaned:gsub("^%l", string.upper)
			if string.match(cleaned, "^([^;\\]*)[;\\]") ~= nil then
				cleaned = string.match(cleaned, "^([^;\\]*)[;\\]")
			end
			return cleaned
		end
	end
end

function p._getID(name)
	name = name or '' --Name cannot be null or else the where query errors
	local result = mw.ext.bucket("infobox_item").select("item_id").where("item_name", name).orderBy("item_id", "asc").run()
	
	if #result == 0 then
		result = mw.ext.bucket("infobox_item").select("item_id").where("page_name", name).orderBy("item_id", "asc").run()
	end
	
	if not result[1] then
		mw.log("No IDs found for item: " .. name )
		return nil
	end

	for _, res in ipairs(result) do
		if res["item_id"] and tonumber(res["item_id"][1]) then
			return(res["item_id"][1])
		end
	end
	
	mw.log("No numerical IDs found for item: " .. name )
	return nil
end

function p.renderTable(equipment, inventory, pouch, spells, loadoutstr)
	local tbl = mw.html.create('table')
    local row = mw.html.create('tr')
    row:tag('td'):wikitext(tostring(equipment)):done():tag('td'):wikitext(tostring(inventory)):done()
    tbl:node(row)
    row = mw.html.create('tr')
    row:tag('td'):wikitext(tostring(spells)):done():tag('td'):wikitext(tostring(pouch)):done()
    tbl:node(row)
    
    if (loadoutstr) then
    	row = mw.html.create('tr'):attr('style', 'text-align:center')
    	row:tag('td'):wikitext(tostring('<code class="loadout-code" style="display:none">'..loadoutstr..'</code>')):attr('colspan', '2'):done()
    	tbl:node(row)
    end
    return tbl
end

function p.renderStacked(equipment, inventory, pouch, spells, loadoutstr)
	local ret = mw.html.create('div')
		:css('text-align', 'center')
		:tag('div'):wikitext(tostring(equipment)):done()
		:tag('div'):wikitext(tostring(inventory)):done()
		:tag(''):wikitext(tostring(spells)):done()
		:tag(''):wikitext(tostring(pouch)):done()
	
	if loadoutstr then
		ret:tag(''):wikitext(tostring('<code class="loadout-code" style="display:none;">'..loadoutstr..'</code>')):done()
	end
	return ret
end

function p.main(frame)
    local args = frame:getParent().args
    return p._main(args)
end

function p._main(args)
	local renderempty
	if args['renderempty'] ~= nil and args['renderempty'] == 'false' then
		mw.log('renderempty = false')
		renderempty = false
	else 
		mw.log('renderempty = true')
		renderempty = true
	end
	local align = args['align'] or 'center'
	local itemsdict = {align = 'center'}
	local hasinv = false
    for i=1,28 do
    	itemsdict[i] = mw.text.trim(args[i] or '')
    	hasinv = itemsdict[i] and itemsdict[i] ~= '' or hasinv
    end
    local inventory = (hasinv or renderempty) and invmodule._main(itemsdict,'inventory') or ''
    
    local equipdict = {align = 'center'}
    local hasequip = false
    for _, slot in ipairs(slotarray) do
    	if args[slot] then
    		equipdict[slot] = mw.text.trim(args[slot])
    		hasequip = true
		end
	end
    local equipment = (hasequip or renderempty) and equipmodule._main(equipdict) or ''
    
    local pouchdict = {
    	align = 'center',
    }
    local hasrune = false
    for i = 1, 4 do
    	local val = mw.text.trim(args['rune'..i] or '')
    	pouchdict[i] = val
    	
    	if val ~= '' then
    		mw.log('hasrune: ' .. val)
    		hasrune = true
    	end
    end
    local pouch
    if (hasrune or renderempty) then
    	pouch = pouchmodule._main(pouchdict)
    else
    	pouch = ''
    end
    
    local spelldict = {
    	align = 'center',
    }
    local hasspell = false;
    for i = 1, 5 do
    	local val = mw.text.trim(args['spell'..i] or '')
    	spelldict[i] = val
    	
    	if val ~= '' then
    		mw.log('hasspell: ' .. val)
    		hasspell = true
    	end
    end
    local spells = (hasspell or renderempty) and spellmodule._main(spelldict) or ''
    
    -- This section creates the loadout section if there is a loadoutname provided
    local loadoutstr
    if args['loadoutname'] then
    	local lookupdict = static.lookups or {}
    	local icon = p._getID(p._cleanItem(args['loadouticon'])) or '9593'
		loadoutstr = 'banktags,1,'..args['loadoutname']..','..icon..',layout'
		
		for slot, item in pairs(loadoutmap) do
			if p._cleanItem(args[item]) then
				local cleanitem = p._cleanItem(args[item])
				if lookupdict[cleanitem] ~= nil then
					loadoutstr = loadoutstr..','..tostring(slot)..','..tostring(lookupdict[cleanitem])
				else
					local id = p._getID(mw.text.trim(cleanitem))
					if id ~= nil then
						lookupdict[cleanitem] = id
						loadoutstr = loadoutstr..','..tostring(slot)..','..tostring(lookupdict[cleanitem])
					end
				end
			end
		end
		static.lookups = lookupdict
	end
	
	local ret
    
    if not args['display'] or args['display'] == 'table' then
    	ret = p.renderTable(equipment, inventory, pouch, spells, loadoutstr, align)
    else
    	ret = p.renderStacked(equipment, inventory, pouch, spells, loadoutstr, align)
    end
    
    if align == 'left' then
    	ret
    		:css('float', 'left')
    		:css('clear', 'left')
    		:css('margin-right', '15px')
    elseif align == 'center' then
    	ret
    		:css('margin-left', 'auto')
    		:css('margin-right', 'auto')
    elseif align == 'right' then
    	ret
    		:css('float', 'right')
    		:css('clear', 'right')
    		:css('margin-left', '15px')
    elseif align == 'inline' then
    	ret
    		:css('display', 'inline-block')
    end
    
    return ret
end

return p