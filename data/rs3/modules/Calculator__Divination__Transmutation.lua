local cleanImg = require("Module:Clean image").clean
local currency = require("Module:Currency")._amount
local geprices = mw.loadJsonData("Module:GEPrices/data.json")
require("Module:Mw.html extension")

local function coins(amt) return currency(amt, "coins") end
local function chimes(amt) return currency(amt, "chimes") end
local function fnum(x)
	if not x:find(".", 1, true) then
		x = x .. ".0"
	end
	return x
end

local p = {}

function p.main(frame)
	local function ref(text, opts)
		return frame:extensionTag{name = "ref", content = text, args = opts}
	end
	
	local query = bucket('storeline')
		.select('sold_item', 'store_sell_price', 'store_buy_price')
		.where('store_currency', 'chimes')
		.run()
	local chimePrices = {}
	
	-- process Bucket query for chime prices
	for _, stock in ipairs(query) do
		local sell = tonumber(stock.store_sell_price) or 0
		local buy = tonumber(stock.store_buy_price) or 0

		if sell or buy then
			if chimePrices[stock.sold_item] then
				chimePrices[stock.sold_item].sell = math.min(chimePrices[stock.sold_item].sell or 0, sell)
				chimePrices[stock.sold_item].buy = math.max(chimePrices[stock.sold_item].buy or 0, buy)
			else
				chimePrices[stock.sold_item] = {sell = sell, buy = buy}
			end
		end
	end
	
	query = bucket('recipe')
		.select('page_name', 'production_json')
		.where('Category:Items creatable by transmutation')
		.run()
	local data = {}

	-- process Bucket query for the Production JSON from recipes
	for _, item in ipairs(query) do
		json = mw.text.jsonDecode(item.production_json or '{}')

		-- ignore recipes that aren't for transmutation
		if json.method and json.method:find("[Tt]ransmutat") then
			local err = false
			local output = json.outputs[1]
			local itemData = {
				result = {qty = tonumber(output.quantity), name = output.name, img = nil},
				lesser = {qty = nil, name = nil, img = nil},
				energy = {qty = nil, name = nil, img = nil},
				level = json.skills[1].level or "?",
				xp = json.skills[1].experience or "?",
				quest = json.quest and #json.quest > 0 and json.quest or nil,
				prices = {result = nil, lesser = nil, energy = nil, isChimes = false},
			}
			
			-- a recipe must have at minimum product, quantity, link, and image data
			if not output.name and output.quantity and output.image then
				mw.log('ERROR: item "' .. item.page_name .. '" missing required fields')
				err = true
			else
				itemData.result.img = cleanImg{file = output.image, link = '[[' .. output.name .. ']]' }
			end
			
			-- calc assumes all levels are Diviniation levels
			if #json.skills > 0 and json.skills[1].name:lower() ~= "divination" then
				mw.log('WARN: item "' .. item.page_name .. '" transmute method skill is not Div?!')
				itemData.level = "?"
			end
			
			-- all known transmutations have a recipe with two items: a divine energy and a lesser-tier input
			if not json.materials or #json.materials ~= 2 then
				mw.log('ERROR: item "' .. item.page_name .. '" has missing/unexpected materials list')
				err = true
			else
				for _, mat in ipairs(json.materials) do
					-- assume all divine energy items have the word "energy" in their name
					local isEnergy = mat.name:find(" energy", 1, true)
					local targetTbl = isEnergy and itemData.energy or itemData.lesser
					if targetTbl.name then
						mw.log(string.format('WARN: item "%s" has multiple %s materials?', item.page_name, isEnergy and "energy" or "lesser"))
					end

					targetTbl.qty = tonumber(mat.quantity)
					targetTbl.name = mat.name
					targetTbl.img = cleanImg{file = mat.image, link = mat.name}
				end
			end

			if not err then
				-- fetch GE prices
				local p = itemData.prices
				p.result = geprices[itemData.result.name]
				p.energy = geprices[itemData.energy.name]
				p.lesser = geprices[itemData.lesser.name]
				if not (p.lesser or p.energy or p.result) then
					-- all three untradeable; check for alternate currency - chimes
					p.result = chimePrices[itemData.result.name]
					p.energy = chimePrices[itemData.energy.name]
					p.lesser = chimePrices[itemData.lesser.name]
					if not (p.lesser or p.energy or p.result) then
						-- no price data at all...?
						mw.log('WARN: item "' .. item.page_name .. '" and its materials all have no price data')
						p.result = 0
						p.energy = 0
						p.lesser = 0
					else
						-- found chimes prices; grab sell price for resulting item and buy prices for the materials
						p.result = p.result and p.result.buy
						p.energy = p.energy and p.energy.sell
						p.lesser = p.lesser and p.lesser.sell
						p.isChimes = true
					end
				end
				
				-- multiply prices by quantities
				p.result = (p.result or 0) * itemData.result.qty
				p.energy = (p.energy or 0) * itemData.energy.qty
				p.lesser = (p.lesser or 0) * itemData.lesser.qty
				
				-- store the data (this will become one row in the calculator's table)
				table.insert(data, itemData)
			end
		end
	end
	
	-- sort first by level, then by initial resource's name
	table.sort(data, function(a, b)
		if a.level ~= b.level then
			return a.level < b.level
		end
		return a.lesser.name < b.lesser.name
	end)

	-- build table headers
	local profitRef = ref("Profits and losses for tradeable items are calculated using current [[Grand Exchange]] median prices. "
		.. "For [[The Arc]] items, the calculations instead use the cheapeast shop sell and most expensive base shop buy prices (not including the commodity sell price [[Waiko Reward Shop#Upgrades|upgrade]]).")
	local ret = mw.html.create("table")
		:addClass("wikitable sortable sticky-header text-align-right align-left-2 align-left-3 align-left-4")
		:tr()
			:th{"Level", attr={rowspan="2"}}
			:th{"Initial resource", attr={rowspan="2"}}
			:th{"Energy needed", attr={rowspan="2"}}
			:th{"Result", attr={rowspan="2"}}
			:th{"XP", attr={rowspan="2"}}
			:th{"Profit or loss" .. profitRef, attr={colspan="3"}}
		:tr()
			:th("Buying all")
			:th("Buying resource")
			:th("Buying energy")

	-- build table rows
	local questRefs = {}
	for _, rowData in ipairs(data) do
		local currFn = rowData.prices.isChimes and chimes or coins
		local questRef
		if rowData.quest then
			if rowData.quest:match("^%[.+%]$") then
				-- recipe's "quest" param is of the format "[[Quest name]]"
				-- re-use a previously-generated ref for the same quest, otherwise generate a new one and store it
				questRef = questRefs[rowData.quest] or ref("Requires completion of the " .. rowData.quest .. " quest", {name=rowData.quest})
				questRefs[rowData.quest] = questRef
			else
				-- recipe's "quest" param contains something other than a linked quest name;
				-- generate a new ref and just dump it as-is into the text
				questRef = ref("Has the following quest requirement(s): " .. rowData.quest)
			end
		end
		
		ret:tr()
			-- Level
			:td(rowData.level)
			
			-- Intial resource
			:td{string.format("%d %s [[%s]]", rowData.lesser.qty, rowData.lesser.img, rowData.lesser.name),
				attr = {["data-sort-value"] = rowData.lesser.name .. " " .. rowData.lesser.qty}
			}
			
			-- Energy needed
			:td{string.format(
				"%d %s [[%s|%s]]",
				rowData.energy.qty,
				rowData.energy.img,
				rowData.energy.name,
				rowData.energy.name:gsub(" energy", "")
				),
				attr = {["data-sort-value"] = rowData.energy.name .. " " .. rowData.energy.qty}
			}
		
			-- Result
			:td{string.format(
				"%s %s [[%s]]%s",
				rowData.result.qty > 1 and tostring(rowData.result.qty) or "",
				rowData.result.img,
				rowData.result.name,
				questRef or ""
				),
				attr = {["data-sort-value"] = rowData.result.name .. " " .. rowData.result.qty}
			}
		
			-- XP
			:td(fnum(rowData.xp))
			
			-- Profit or loss
			-- Buying all
			:td(currFn(rowData.prices.result - (rowData.prices.energy + rowData.prices.lesser)))
			
			-- Buying initial resource
			:td(currFn(rowData.prices.result - rowData.prices.lesser))
			
			-- Buying energy
			:td(currFn(rowData.prices.result - rowData.prices.energy))
	end
	
	-- all done
	return tostring(ret:allDone()) .. frame:extensionTag{name="references"}
end

return p