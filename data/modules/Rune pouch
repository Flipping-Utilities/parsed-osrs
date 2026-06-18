local p = {}

local trim = mw.text.trim

-- Get a rune's name, and the quantity to display 
function p._getItem(str)
	backSlash, _ = str:find('\\')
	if(backSlash) then
		itemName = str:sub(0, backSlash - 1)
		amountOfItem = tonumber(str:sub(backSlash + 1)) or 1
		if(amountOfItem < 1) then
			amountOfItem = 1
		elseif(amountOfItem > 16000) then
			amountOfItem = 16000
		end
	return itemName, amountOfItem
	else
		return str, 1
	end
end

-- Get page alignement setting
function p._getAlign(align)
	if(align == nil) then
		return 'storage-left'
	elseif(align:lower() == 'center') then
		return 'storage-center'
	elseif(align:lower() == 'left') then
		return 'storage-left'
	elseif(align:lower() == 'right') then
		return 'storage-right'
	else
		return 'storage-left'
	end
end

-- Build the table
function p._makeTable(runesTable, alignClass)
	local ret = mw.html.create('table')
		:addClass('runepouchtable')
		:addClass(alignClass)
	if runesTable[4][1] ~= '' then
		ret:addClass('divinerunepouch')
	end
	local retRow = ret:tag('tr')
	for i = 1, 4, 1 do
		local td = retRow:tag('td')
		if(runesTable[i][1] ~= '') then
			if(i == 2) or (runesTable[4][1] ~= '' and i == 3) then
				td:wikitext(string.format('[[File:%s.png|link=%s|32x32px|frameless]]', runesTable[i][1], runesTable[i][1]))
					:addClass('middle-rune')
			else
				td:wikitext(string.format('[[File:%s.png|link=%s|32x32px|frameless]]', runesTable[i][1], runesTable[i][1]))
			end
			if(runesTable[i][2] > 1) then
				td:tag('span')
					:addClass('inv-quantity-text')
					:wikitext(runesTable[i][2])
			end
		elseif(i == 2) then
			td:wikitext('')
				:addClass('middle-rune')
		end
	end
	return ret
end

function p.main(frame)
	local args = frame:getParent().args
    return p._main(args)
end

function p._main(args)
	local runes = {}
	for i = 1, 4, 1 do
		local item, amount = "", 1
		if(args[i] ~= nil) then
			args[i] = trim(args[i])
			item, amount = p._getItem(args[i]:sub(1,1):upper()..args[i]:sub(2):lower())
		end
		runes[i] = {item, amount}
	end

	return p._makeTable(runes, p._getAlign(args.align))
end

return p