require("Module:Mw.html extension")
local autoround = require("Module:Mmgtable").autoround
local _coins = require("Module:Currency")._amount

local p = {}

local function loadData(title, anchor)
	local pageName = "Money making guide/" .. title
	local b = bucket("money_making_guide").select("json")
	if anchor then
		b.where("page_name_sub", pageName .. "#" .. anchor)
	else
		b.where("page_name", pageName)
	end

	return b.run()
end

local function addtblrow(row, page, price, skill, version, other, quest, experience, obsolete)
	local mmgString = "[[Money making guide/" .. page .. "|" .. page .. "]]"
	local otherRequirements = ""
	if version ~= nil and version ~= "" then
		mmgString = "[[Money making guide/" .. page .. "#" .. version .. "|" .. page .. " (" .. version .. ")]]"
	end
	
	if experience == nil then
		experience = "None"
	end
	if skill == nil then
		skill = "None"
	end
	
	if (other == nil or other == "None" or other == "") and (quest == nil or quest == "None" or quest == "") then
	    otherRequirements = "None"
	elseif other == nil or other == "None" or other == "" then
	    otherRequirements = quest
	elseif quest == nil or quest == "None" or quest == "" then
	    otherRequirements = other
	else
	    otherRequirements = other .. "\n" .. quest
	end

	row:tag("tr")
		:attrIf(obsolete, "title", "This guide is obsolete. See the article for more details")
		:cssIf(obsolete, {
			["background"] = "var(--table-na-background)",
			["color"] = "var(--table-na-color)"
		})
		:tag("td")
			:wikitextIf(obsolete, "† ")
			:wikitext(mmgString)
			:done()
		:tag("td")
			:tag("span")
				:addClass("coins")
				:wikitext(_coins(autoround(price), "coins"))
				:done()
			:done()
		:tag("td")
			:addClass("plainlist")
			:wikitext("\n" .. skill)
			:done()
		:tag("td")
			:addClass("plainlist")
			:wikitext("\n" .. otherRequirements)
			:done()
		:done()
end

function p._main(args)
	local tbl = mw.html.create("table"):addClass("wikitable sortable align-right-2")
	local cats = ""
	local normalmmg, recurringmmg = false, false
	local normalrows, recurringrows = mw.html.create(""), mw.html.create("")
	local numMethods = 0
 
	for i, _ in ipairs(args) do
		local normalisedArg = args[i]:gsub("_", " ")
		local splitArg = mw.text.split(normalisedArg, "%#")
		local title, anchor = splitArg[1], splitArg[2]
		
		local rawJson = loadData(title, anchor)
		if type(rawJson) ~= "table" then
			rawJson = {rawJson}
		end
		if #rawJson == 0 then
			mw.log("Mmgsection found no matching MMGs for: " .. normalisedArg)
			tbl:wikitext("[[Category:Pages with an incorrect Mmgsection value]]")
		end
 
		for _, row in ipairs(rawJson) do
			local data = mw.text.jsonDecode(row.json)
			local obsolete = row.obsolete
 
			numMethods = numMethods + 1
 
			if not data.recurrence then
				if not normalmmg then
					normalmmg = true
				end
 
				local prices = data.prices.default_value or data.prices.value
 
				addtblrow(normalrows, title, prices, data.skill, data.version, data.other, data.quest, data.experience, obsolete)
 
				if obsolete then
					cats = cats .. "[[Category:Pages with obsolete money making guides listed]]"
				end
 
			else
				if not recurringmmg then
					recurringmmg = true
				end
 
				addtblrow(recurringrows, title, data.prices.value, data.skill, data.version, data.other, data.quest, data.experience, obsolete)
 
				if obsolete then
					cats = cats .. "[[Category:Pages with obsolete money making guides listed]]"
				end
			end
		end
	end

	
	if normalmmg then
		tbl:tag("tr")
			:tag("th")
				:wikitext("Method")
			:done()
			:tag("th")
				:wikitext("Hourly profit")
			:done()
			:tag("th")
				:wikitext("Skills")
			:done()
			:tag("th")
				:wikitext("Other requirements")
			:done()
			-- :tag("th")
			-- 	:wikitext("Experience")
			-- :done()
		:done()
		:node(normalrows)
	end
	
	if recurringmmg then
		tbl:tag("tr")
			:tag("th")
				:wikitext("Method")
			:done()
			:tag("th")
				:wikitext("Profit per instance")
			:done()
			:tag("th")
				:wikitext("Skills")
			:done()
			:tag("th")
				:wikitext("Other requirements")
			:done()
			-- :tag("th")
			-- 	:wikitext("Experience")
			-- :done()
		:done()
		:node(recurringrows)
	end
	
	if numMethods == 0 then
		return "No [[money making guide]]s available for " .. (args.mobname or mw.title.getCurrentTitle().text) .. "."
	end
	
	local str = string.format("<p>The following [[money making guide]]%s %s available for %s:</p>",
		(numMethods >= 2 and "s" or ""),
		(numMethods >= 2 and "are" or "is"),
		(args.mobname or mw.title.getCurrentTitle().text)
		)
	
	return str .. tostring( tbl ) .. cats
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

return p