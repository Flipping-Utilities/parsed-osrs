--<nowiki>
-- essentially the inverse of [[Module:Questreq]], though with the option of expanding into other types of reqs (eg achievements - will need bucket work for those though)
local quests = mw.loadData('Module:Questreq/data')
local p = {}
local yesno = require('Module:Yesno')

local function clearPrefix(name)
	return name:gsub('^Full:', ''):gsub('^Partial:', ''):gsub('^Follows:', ''):gsub('^Misc:', '')
end

local function _sortFunc(a, b)
	local _a, _b
	_a = clearPrefix(tostring(a)):lower()
	_b = clearPrefix(tostring(b)):lower()
	return _a < _b
end

local function getQuests(q)
	local qs = {}
	q = clearPrefix(tostring(q)):lower()
	for k, v in pairs(quests) do
		for _, l in ipairs(v) do
			local _l = clearPrefix(l):lower()
			if q == _l then
				table.insert(qs, k)
				break
			end
		end
	end
	if #qs == 0 then
		return nil
	end
	table.sort(qs, _sortFunc)
	return qs
end

local function listIndirectQuests(nestedQuests)
	local _nested = {}

	for k, _ in pairs(nestedQuests) do
		-- remove duplicate 'Full completion of X/Partial X' if X is already listed
		-- usually applies to early quests that are required a lot
		-- e.g. Desert Treasure is required for Children of Mah in several ways, some of which are direct requirements
		-- (Desert Treasure -> The Temple at Senntisten -> The Light Within -> Children of Mah)
		-- and some are through 'Full completion' requirements
		-- (Desert Treasure -> The Temple at Senntisten -> Ritual of the Mahjarrat -> Koschei's Troubles -> Full:Children of Mah)
		-- listing both is confusing so remove full/partial requirements if the quest is just normally listed
		if k:find('^Full:') or k:find('^Partial:') or k:find('^Follows:') then
			local _k = clearPrefix(k)
			if not nestedQuests[_k] then
				table.insert(_nested, k)
			end
		else
			table.insert(_nested, k)
		end
	end

	table.sort(_nested, _sortFunc)

	return _nested
end

function p._getQuests(q, getNested)
	--[=[
	-- preserves nesting structure
	-- saving here in case we want it, but not used
	function nest(_q)
		local nqs = getQuests(_q)
		local r = nil
		if nqs ~= nil then
			r = nqs
			for i,v in ipairs(nqs) do
				table.insert(nqs, nest(v))
			end
		end
		return r
	end
	--]=]
	-- does not preserve structure
	local nestedQuests = {}
	local nestedComprehensionQuests = {}
	local function nest(_q, delegateQuests)
		local nqs = getQuests(_q)
		local r = nil
		if nqs ~= nil then
			r = nqs

			for _, v in ipairs(nqs) do
				if v:find('^Follows:') then
					delegateQuests = nestedComprehensionQuests
				end

				if not delegateQuests[v] then
					delegateQuests[v] = true
					nest(v, delegateQuests)
				end
			end
		end
		return r
	end

	local qs = getQuests(q)
	if qs == nil then
		return nil
	end

	if not getNested then
		return qs
	end

	nest(q, nestedQuests)

	-- unmark the direct requirements
	for _, v in ipairs(qs) do
		nestedQuests[v] = nil
	end

	local indirectQuests = listIndirectQuests(nestedQuests)
	local indirectComprehension = listIndirectQuests(nestedComprehensionQuests)

	return qs, indirectQuests, indirectComprehension
end

function displayName(v, quick)
	local repl, page
	v, repl = string.gsub(v, '^Full:', '')
	if repl > 0 then
		page = quick and string.format('%s/Quick_guide', v) or v
		if quick and not mw.title.new(page).exists then
			page = v
		end
		return string.format('* [[%s|%s]] (full completion)', page, v)
	end

	-- doubt this will ever happen but here's support for it anyway
	v, repl = string.gsub(v, '^Partial:', '')
	if repl > 0 then
		page = quick and string.format('%s/Quick_guide', v) or v
		if quick and not mw.title.new(page).exists then
			page = v
		end
		return string.format('* [[%s|%s]] (partial completion)', page, v)
	end

	v, repl = string.gsub(v, '^Follows:', '')
	if repl > 0 then
		page = quick and string.format('%s/Quick_guide', v) or v
		if quick and not mw.title.new(page).exists then
			page = v
		end
		return string.format('* [[%s|%s]] (full comprehension)', page, v)
	end

	v, repl = string.gsub(v, '^Misc:', '')
	if repl > 0 then
		return string.format('* %s', v)
	end

	page = quick and string.format('%s/Quick_guide', v) or v
	if quick and not mw.title.new(page).exists then
		page = v
	end
	return string.format('* [[%s|%s]]', page, v)
end

function p._quests(q, noindirect, quick)
	if not quests[q] then
		return string.format('"%s" is not a recognised quest name.[[Category:Quest name not recognised]]', q)
	end
	local qs, indirqs, indirectComprehension = p._getQuests(q, not yesno(noindirect))

	if quick == nil then
		quick = string.find(mw.title.getCurrentTitle().text, 'Quick guide')
	else
		quick = yesno(quick)
	end

	local ret = {}
	if qs == nil or #qs == 0 then
		table.insert(ret, string.format('%s is not currently required for any quests or miniquests.', q))
	else
		table.insert(ret, string.format('%s is directly required for the following quests/miniquests:', q))
		for _, v in ipairs(qs) do
			table.insert(ret, displayName(v, quick))
		end
		if indirqs and #indirqs > 0 then
			table.insert(ret, '')
			table.insert(ret,
				'<div style="margin:0.5em 0"><div class="mw-collapsible mw-collapsed" style="display:inline-block;">It is therefore an indirect requirement for the following quests and miniquests: <div class="mw-collapsible-content">')
			for _, v in ipairs(indirqs) do
				table.insert(ret, displayName(v, quick))
			end
			table.insert(ret, '</div></div></div>')
		end
		if indirectComprehension and #indirectComprehension > 0 then
			table.insert(ret, '')
			table.insert(ret,
				'<div style="margin:0.5em 0"><div class="mw-collapsible mw-collapsed" style="display:inline-block;">It is therefore an indirect comprehension requirement for the following quests and miniquests: <div class="mw-collapsible-content">')
			for _, v in ipairs(indirectComprehension) do
				table.insert(ret, displayName(v, quick))
			end
			table.insert(ret, '</div></div></div>')
		end
	end

	return table.concat(ret, '\n')
end

function p.quests(frame)
	local args = frame:getParent().args
	local q = args[1] or mw.title.getCurrentTitle().text
	return p._quests(q, args.noindirect, args.quick)
end

return p
--</nowiki>