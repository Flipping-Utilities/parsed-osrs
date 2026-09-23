local utils = require('Module:Sandbox/User:Oo00oo00oO/utils')
utils.debug.updateLogConfigSetting('LEVEL', utils.debug.LOG_LEVEL.ALL)
local dpl = require("Module:DPLlua")

local p = {}

--- StoreReport
--- Generates a shop report from OSRS Wiki shop pages.
---
--- The module expects a shop page name as frame argument 1.
--- It extracts:
--- * Infobox Shop location
--- * Infobox Shop members status
--- * StoreTableHead price modifiers
--- * StoreLine items belonging to each StoreTableHead
---
--- Output is wiki table rows only.

------------------------------------------------------------
-- Filter handling
------------------------------------------------------------
p.configSetup = {
	allowMembers = {
		default = true,
		flags = {
			[true] = {"mems","members"},
			[false] = {"f2p", "f2pOnly"}
		}
	},
	includeItems = {
		default = true,
		flags = {
			[false] = {"noItems"},
			[true] = {"items"}
		}
	}
}

--- Generate configuration from invocation arguments
---
---@param inputArgs table
---@return table

function p.generateConfig(inputArgs)
	local function normalizeStr(str)
		if str == nil then return nil end
		return string.lower(utils.trim(tostring(str)))
	end
	local function normalizeStrs (inputVals)
		if type(inputVals) ~= "table" then
			return  normalizeStrs( {inputVals}) 
		end
		local ret = {}
		for i, v in ipairs(inputVals) do
			table.insert(ret, normalizeStr(v))
		end
		return ret
	end
	
	local function hasValue(arr, val)
		if arr == nil or val == nil then return false end
		for index, value in ipairs(arr) do
			if value == val then
				return true
			end
		end
		return false
	end

	local inputs = {}
	local n = 1
	local formattedRaw = utils.extractArgs(inputArgs) or {}
	for key,value in pairs(formattedRaw) do
		local argName = nil
		local argVal = nil
		if type(key) == "number" and key == n then
			argName = normalizeStr(value)
			argVal = normalizeStr(true)
			n = n + 1
		else
			argName = normalizeStr(key)
			argVal = normalizeStr(value)
		end
		inputs[argName] = argVal
	end

	local config = {}
	for key, info in pairs(p.configSetup) do
		for flagResult, flagKeys in pairs(info.flags) do
			local flagMatchers = normalizeStrs(flagKeys)
			local found = false
			for inputK, inputV in pairs(inputs) do
				if hasValue(flagMatchers, inputK) then
					found = true
					break
				end
			end
			if found then
				config[key] = flagResult
				break
			end
		end
		if config[key] == nil and info.default ~= nil then
			config[key] = info.default
		end
	end
	return config
end

--- Determine whether a shop should be included.
---
---@param shopInfo table
---@param config table
---@return boolean
function p.includeShop(shopInfo, config)

	local isMembers = string.lower(shopInfo.members or "") == "yes"
	return config.allowMembers or not isMembers
end

--- Filter items based on membership.
---@param items table
---@param config table
---@return table
function p.filterItems(items, config)
	local output = {}
	for _, item in ipairs(items) do
		if (not item.members or config.allowMembers) then
			table.insert(output, item.name)
		end
	end
	return output
end

------------------------------------------------------------
-- Utility functions
------------------------------------------------------------

--- Convert a template block into key/value arguments.
---
--- Example:
--- {{Template
--- |foo=bar
--- |baz=qux
--- }}
---
---@param block string
---@return table
local function parseTemplateArgs(block)

	local args = {}

	for key,value in block:gmatch("|%s*([^=|]+)%s*=%s*([^|}]+)") do
		args[utils.trim(key)] = utils.trim(value)
	end

	return args
end


--- Find all occurrences of a template.
---
---@param text string
---@param template string
---@return table
local function findTemplates(text, template)

	local result = {}

	local pattern =
		"{{%s*"
		.. template
		.. "(.-)}}"

	for block in text:gmatch(pattern) do

		table.insert(
			result,
			parseTemplateArgs(block)
		)

	end

	return result
end


--- Convert multiplier values into percentages.
---
--- OSRS shop multipliers are stored as tenths of a percent.
--- Example:
--- 1200 -> 120%
---
---@param value string|number|nil
---@return string
local function multiplierToPercent(value)

	local number = tonumber(value)

	if not number then
		return "100%"
	end

	return (number / 10) .. "%"

end


------------------------------------------------------------
-- Shop parsing
------------------------------------------------------------

--- Parse shop metadata.
---@param text string
---@return table
local function parseShopInfo(text)

	local info =
		findTemplates(
			text,
			"Infobox Shop"
		)[1]
		or {}

	return {
		location = info.location or "Unknown",
		members = info.members or "No"
	}

end


--- Parse stock groups.
---
--- Unlike searching StoreLine globally, this walks through the
--- page in order so each item remains attached to the correct
--- StoreTableHead.
---
---@param text string
---@return table
local function parseStockGroups(text)

	local groups = {}
	local current = nil
	
	for template in text:gmatch("{{.-}}") do
		----------------------------------------------------
		-- New stock table
		----------------------------------------------------

		if template:match("^{{%s*StoreTableHead") then
			local args = parseTemplateArgs(template:match("StoreTableHead(.*)"))
			current = {
				tab = args.tab or args.name or "Default",
				sell = multiplierToPercent(args.sellmultiplier),
				buy = multiplierToPercent(args.buymultiplier),
				delta = multiplierToPercent(args.delta),
				items = {}
			}
			table.insert(groups, current)

		----------------------------------------------------
		-- Stock item
		----------------------------------------------------

		elseif template:match("^{{%s*StoreLine") then
			if current then
				local args = parseTemplateArgs(template:match("StoreLine(.*)"))
				local item = args.item or args.name
				if item and item ~= "" then
					table.insert(current.items, {name = item, members = string.lower(args.members or "") == "yes"})
				end
			end
		end
	end


	--------------------------------------------------------
	-- Fallback for shops without StoreTableHead
	--------------------------------------------------------

	if #groups == 0 then
		groups[1] = {
			tab = "Default",
			sell = "100%?",
			buy = "100%?",
			delta = "0%?",
			items = {}
		}
	end

	return groups
end


------------------------------------------------------------
-- Output
------------------------------------------------------------

--- Generate a single table row.
---@param title mw.title
---@param info table
---@param group table
---@return string
local function makeRow(title, info, group, config)
	local items = p.filterItems(group.items, config)
	return table.concat(
		{
			"|-\n",
			"|", title.text, "\n",
			"|", info.location, "\n",
			"|", info.members, "\n",
			"|", group.tab, "\n",
			"|", group.sell, "\n",
			"|", group.buy, "\n",
			"|", group.delta, "\n",
			"|", table.concat(items, "<br>"), "\n"
		}
	)

end


------------------------------------------------------------
-- Entry point
------------------------------------------------------------

--- Main module entry point.
---
--- Runs DPL internally to retrieve all shop pages.
--- Each returned page is then parsed for:
--- * Infobox Shop
--- * StoreTableHead
--- * StoreLine
---
---@param frame frame
---@return string
function p.main(frame)
	local config = p.generateConfig(frame)

	--------------------------------------------------------
	-- Query all shop pages
	--------------------------------------------------------
	local rows = {}
	local hasMore = true
	local offset = 0
	local maxPerPage = 500
	while hasMore do
		local shops = dpl.ask{
			namespace = "",
			category = "Shops",
			ordermethod = "title",
			include = "%0",
			offset = offset,
			count = maxPerPage
		}
		--------------------------------------------------------
		-- Process each shop page
		--------------------------------------------------------
		for _, shop in ipairs(shops) do
			-- DPL returns:
			-- {
			--   title = "Shop name",
			--   include = {
			--      ["%0"] = "page text"
			--   }
			-- }
			local pageName = shop.title
			local title = mw.title.new(pageName)
			if title then
				local text = title:getContent()
				if text then
					local info = parseShopInfo(text)
					if p.includeShop(info, config) then
						local groups = parseStockGroups(text)
						for _, group in ipairs(groups) do
							table.insert(rows, makeRow(title, info, group, config))
						end
					-- else note that we are skipping the shop bc it does not meet criteria.
					end
				end
			end
		end
		offset = offset + #shops
		hasMore = #shops <= 1 and hasMore
	end
	
	return table.concat(rows, "\n")

end

return p