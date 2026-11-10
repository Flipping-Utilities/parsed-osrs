-- <nowiki>
local p = {}
local pt = require('Module:Paramtest')
local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local any = require('Module:Array').any
local var = mw.ext.VariablesLua
local lang = mw.getContentLanguage()
require("Module:Mw.html extension")

local membscol = {
	[true] = '[[File:P2P icon.png|30px|link=Members]]',
	[false] = '[[File:F2P icon.png|30px|link=Free-to-play]]',
}

local function dropLevels(dropType)
    local seenLevels = {}

	local curDropLevelValues = var.var("DropLevel_" .. dropType .. "_DEFAULT")
	for curDropLevel in string.gmatch(curDropLevelValues, ' *([^,]+) *') do
		seenLevels[curDropLevel] = true
	end

    local orderedLevels = {}
    for lvl, _ in pairs(seenLevels) do
        local n = tonumber(lvl)
        if n ~= nil then
            table.insert(orderedLevels, n)
        end
    end

    table.sort(orderedLevels)

    return orderedLevels
end

function p.main(frame)
	local args = frame:getParent().args

	local val
	if pt.has_content(args.Smugvalue) then
		local smugValue = tonumber(args.Smugvalue)
		if smugValue then
			val = lang:formatNum(smugValue)
		else
			val = args.Smugvalue
		end
	else
		val = frame:preprocess('Unknown <small>[{{fullurl:Template:Dungeoneering_droptable|action=edit}} edit]</small>')
	end

	local name = args.Name:gsub('|.*',''):gsub('{{!}}.*','')
	local displayname = name:gsub(' %(Dungeoneering%)', '')
	displayname = displayname:gsub(' %(item%)', '')
	local file = string.format('[[File:%s|link=%s]]', pt.default_to(args.Image, name .. '.png'), name)
	local membs = membscol[yesno(args.Members or "no")]

	local ret = mw.html.create('tr')
	ret:td {
        class = 'inventory-image',
        attr = { ['data-sort-value'] = name },
        wikitext = file,
    }

	-- item name
    ret:td {
        class = 'item-col',
        wikitext = string.format('[[%s|%s]]', name, displayname),
    }

	-- item value
    ret:td {
        class = 'ge-column',
        wikitext = val,
    }

	-- item membership value
    ret:td {
        class = 'members-column',
        wikitext = membs,
    }

	if onmain() and (args.bucket == nil or yesno(args.bucket, true)) then
		local bucket_json = {
			['Dropped item'] = name,
			['Dropped from'] = mw.title.getCurrentTitle().text,
			['Quantity High'] = 10,
			['Quantity Low'] = 1,
			['Drop Quantity'] = '1-10',
			['League region'] = var.var("LeagueRegion_DEFAULT"),
			['Rarity'] = 'Varies'
		}

		-- only accepts 'combat' or 'combat'&'slayer' currently
		local dropTypes =  { 'combat' }
		local levelsByType = {}
	
		-- Combat levels
		table.insert(levelsByType, dropLevels('combat'))

		-- Try to find Slayer levels
		local slayerLevels = dropLevels('slayer')

		-- Check if it is greater than 0 Slayer
		-- Generally, it should be the same level
		local containsSlayer = any(slayerLevels, function(v) return v ~= nil and v > 0 end)

		if containsSlayer then
			dropTypes[2] = 'slayer'
			table.insert(levelsByType, slayerLevels)
		end

        bucket_json['Drop type'] = dropTypes
		bucket_json['Drop level'] = levelsByType
		mw.logObject(bucket_json)

		bucket('dropsline').put({
			["item_name"] = name,
			["rare_drop_table"] = false,
			["drop_json"] = mw.text.jsonEncode(bucket_json)
		})
	end

	return tostring(ret)
end


return p