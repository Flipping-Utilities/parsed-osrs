require("strict")
require('Module:Mw.html extension')
local getArgs = require("Module:Arguments").getArgs

local data = mw.loadData('Module:Thieving chance calculator/data')
local p = {}

local function make_table(rows, headers, center_cols)
	local ret = mw.html.create('table')
		:addClass('wikitable sortable sticky-header')
		:addClass('autosort=2,a')
	for _, col in ipairs(center_cols or {}) do
		ret:addClass(string.format('align-center-%d', col))
	end

	local headerRow = ret:tr()
	for _, h in ipairs(headers) do
		headerRow:th():wikitext(h)
	end

	for _, row in ipairs(rows) do
		local tr = ret:tr()
		for _, cell in ipairs(row) do
			local td = tr:td()
			if type(cell) == 'table' then
				td:wikitext(cell.text):addClass(cell.class or ''):attr(cell.attr or {})
			else
				td:wikitext(cell)
			end
		end
	end

	return tostring(ret)
end

function p.main(frame)
	return p._main(getArgs(frame))
end

function p._main(args)
	local headers = {"NPC", "Level", "XP", "Stun time", "Damage"}
	local targets = {}
	for _, t in ipairs(data) do
		local target = {
			"[[File:" .. t["image"] .. ".png|16px]] [[" .. t["name"] .. "]]",
			t["level"],
			t["xp"],
			"", -- TODO
			"", -- TODO
		}
		table.insert(targets, target)
	end
	return make_table(targets, headers, { #headers })
end

return p