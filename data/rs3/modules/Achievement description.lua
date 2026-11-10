require("strict")
local yn = require("Module:Yesno")
local getArgs = require("Module:Arguments").getArgs

local p = {}

function p.main(frame)
	local name = frame:getParent().args[1] or ''
	local data = bucket('achievement')
		.select('json')
		.where('page_name', name)
		.limit(1)
		.run()
	if data ~= nil and #data == 1 then
		if data[1].json ~= nil then
			return mw.text.jsonDecode(data[1].json).description
		end
	end
	return ''
end

function p.line(frame)
	local name = getArgs(frame)[1] or ''
	local link = p._link(name, true)
	if link ~= nil then
		return link
	else
		return "No achievement found named '''" .. name .. "'''. [[Category:Erroneous parameter]]"
	end
end

function p.link(frame)
	local args = getArgs(frame)
	local name = args[1] or ""
	local withScore = yn(args.score)

	return p._link(name, { withScore = withScore })
		or ("[[" .. name .. "]]")
end

function p.achievementID(frame)
	local name = getArgs(frame)[1] or ""
	return p._achievementID(name) or ""
end

function p.achievementName(frame)
	local id = getArgs(frame)[1] or ""
	return p._achievementName(id) or ""
end

local function loadData(name)
	local data = bucket('achievement')
		.select('page_name', 'json')
		.where('page_name', name)
		.limit(1)
		.run()
	if data ~= nil and #data == 1 then
		local achievementJSON = data[1].json
		if (achievementJSON ~= nil) then
			return data[1], mw.text.jsonDecode(achievementJSON)
		end
	end
	return data, nil
end

local function loadDataById(id)
	local data = bucket('achievement')
		.select('page_name', 'json')
		.where('id', id)
		.limit(1)
		.run()
	if data ~= nil and #data == 1 then
		local achievementJSON = data[1].json
		if (achievementJSON ~= nil) then
			return data[1], mw.text.jsonDecode(achievementJSON)
		end
	end
	return data, nil
end

local function parseLinkOpts(opts)
	local withDescription, withScore
	if (type(opts) == "boolean") then
		withDescription = opts
		opts = nil
	elseif (opts) then
		withDescription	= opts.withDescription
		withScore   	= opts.withScore
	end
	
	return withDescription, withScore
end

function p._link(name, ...)
	local withDescription, withScore = parseLinkOpts(...)
	local data, json = loadData(name)
	if not json then
		return nil
	end

	local unlinkedpage = data.page_name

	local ret = mw.html.create("span")
		:attr("data-achievement-id", json.id or unlinkedpage)
		:wikitext("[[", unlinkedpage, "|", json.name, "]]")

	if (withDescription or withScore) then
		ret:wikitext( " ([[File:RuneScore.png|link=RuneScore|16px]] ", json.score )
		if json["combat score"] and json["combat score"] ~= "" then
			ret:wikitext( ", [[File:Combat Mastery icon.png|22x22px|link=Combat Mastery achievements#CombatScore]] ", json["combat score"] )
		end
		ret:wikitext( ")" )
	end
	if withDescription then
		ret:wikitext(" – ", json.description)
	end

	return tostring(ret)
end

function p._achievementID(name)
	local data, json = loadData(name)
	if not json then
		return nil -- not an achievement page
	end

	local unlinkedpage = data.page_name
	return json.id or unlinkedpage
end

function p._achievementName(id)
	local data, json = loadDataById(id)
	if not json then
		return nil -- not an achievement page
	end

	local unlinkedpage = data.page_name
	return unlinkedpage
end

function p._tableCell(name)
	local data, json = loadData(name)
	if not json then
		return nil -- not an achievement page
	end

	local unlinkedpage = data.page_name
	return {
		"[[" .. unlinkedpage .. "|" .. json.name .. "]]",
		attr = { "data-rowid", json.id or unlinkedpage },
	}
end

return p