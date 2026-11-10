local p = {}
local hat = require('Module:Hatnote')
local yesno = require('Module:Yesno')
local title = string.lower(mw.title.getCurrentTitle().text)
local info = { undyed = false }

local getPlusLinks, getOHPlusLinks, getMkLinks, getOHMkLinks, getUrnStageLinks;

local values = {
	['main hand'] = 'mh',
	['main-hand'] = 'mh',
	['mainhand'] = 'mh',
	['off-hand'] = 'oh',
	['offhand'] = 'oh',
	['superior'] = 'tier',
	['inferior'] = 'tier',
	['achto'] = 'tier',
	['attuned'] = 'tier',
	['enhanced'] = 'tier',
	['refined'] = 'tier',
	['augmented'] = 'augmented',
	['barrows dyed'] = 'dyed',
	['barrows'] = 'dyed',
	['shadow dyed'] = 'dyed',
	['shadow'] = 'dyed',
	['third-age dyed'] = 'dyed',
	['third-age'] = 'dyed',
	['third age dyed'] = 'dyed',
	['third age'] = 'dyed',
	['blood dyed'] = 'dyed',
	['blood'] = 'dyed',
	['ice dyed'] = 'dyed',
	['ice'] = 'dyed',
	['aurora'] = 'dyed',
	['aurora dyed'] = 'dyed',
	['soul'] = 'dyed',
	['soul dyed'] = 'dyed',
	['red'] = 'dyed',
	['orange'] = 'dyed',
	['yellow'] = 'dyed',
	['green'] = 'dyed',
	['blue'] = 'dyed',
	['purple'] = 'dyed',
	['black'] = 'dyed',
	['white'] = 'dyed',
	['pink'] = 'dyed',
	['undyed'] = 'dyed',
}

-- as above but specifically tt dyes for correct auto-parsing
local tt_dyes = {
	['barrows dyed'] = true,
	['barrows'] = true,
	['shadow dyed'] = true,
	['shadow'] = true,
	['third-age dyed'] = true,
	['third-age'] = true,
	['third age dyed'] = true,
	['third age'] = true,
	['blood dyed'] = true,
	['blood'] = true,
	['ice dyed'] = true,
	['ice'] = true,
	['aurora'] = true,
	['aurora dyed'] = true,
	['soul'] = true,
	['soul dyed'] = true,
}
local other_dyes = {
	['red'] = true,
	['orange'] = true,
	['yellow'] = true,
	['green'] = true,
	['blue'] = true,
	['purple'] = true,
	['black'] = true,
	['white'] = true,
	['pink'] = true,
	['undyed'] = true,
}
local base_types = {
	['undyed'] = true
}
local msr_oh_replace = {
	'primal',
	'elder rune',
	'bane',
	'necronium',
	'orikalkum',
	'rune',
	'adamant',
	'mithril',
	'steel',
	'iron',
	'bronze',
}
local urn_stages = {
	'(unfired)',
	'(no gem)', -- only exquisite urns
	'(no rune)',
	'(empty)',
	'', -- base (no suffix)
	'(full)'
}

function p.main(frame)
	local args = frame:getParent().args
	local links = {}
	local misc = {}
	local misc_keys = {}
	local misc_links = {}
	local ret = {}
	ret.mh = {}
	ret.oh = {}
	ret.tier = {}
	ret.augmented = {}
	ret.dyed = {}
	ret.plus = {}
	ret.ohplus = {}
	ret.mk = {}
	ret.ohmk = {}
	ret.urns = {}

	if args['max+'] then -- Smithing product + 1/+ 2/+ 3/+ 4/+ 5
		ret.maxplus = tonumber(args['max+'])
		if yesno(args.msoh) then
			ret.msoh = true
		end
	elseif args.mk then -- Fletching tier 100 product Mk. 1/Mk. 2/Mk. 3/Mk. 4/Mk. 5
		ret.maxmk = tonumber(args.mk)
		if yesno(args.msoh) then
			ret.msoh = true
		end
  elseif yesno(args.urns) then -- Pottery urns (unfired), (no rune), (empty), base, (full)
      ret.pottery = true
	end

	for key, value in pairs(args) do
		local kind, item = '', ''
		if not (key == 'max+' or key == 'mk' or key == 'msoh' or key == 'urns') then
			-- numeric key => unnamed param
			if tonumber(key) then
				-- the value is the kind and the item is "kind PAGENAME"
				kind = string.lower(value)
			else
				-- else kind is key and item is value
				kind = key
				item = value
			end

			-- apparently linebreaks aren't actually trimmed by the parser (when they really should be)????
			kind = mw.text.trim(kind)
			item = mw.text.trim(item)

			local kindlc = string.lower(kind)
			if values[kindlc] then
				links[kindlc] = p.getLink(kind, item)
			else
				table.insert(misc_keys, kind)
				misc_links[kind] = p.getLink(kind, item)
			end
		end
	end
	table.sort(misc_keys)
	for i,key in ipairs(misc_keys) do
		table.insert(misc, misc_links[key])
	end

	

	-- put links into order
	for i, v in pairs(values) do
		if links[i] then
			table.insert(ret[v], links[i])
		end
	end

	if ret.maxplus then
		ret.plus = getPlusLinks(ret.maxplus)
		if ret.msoh then
			ret.ohplus = getOHPlusLinks(ret.maxplus)
		end
	elseif ret.maxmk then
		ret.plus = getMkLinks(ret.maxmk)
		if ret.msoh then
			ret.ohplus = getOHMkLinks(ret.maxmk)
		end
	elseif ret.pottery then
		ret.tier = getUrnStageLinks()
	end

	local _ret = mw.html.create('')

	if ret.plus[1] then
		_ret:wikitext('For this item\'s upgraded variants, see ')
			:wikitext(table.concat(ret.plus, ', ') .. '. ')
			:done()
		if ret.msoh then
			local msss = 'For this item\'s off-hand variants, see '
			if info.isoffhand then
				msss = 'For this item\'s main hand variants, see '
			end
			_ret:wikitext(msss)
				:wikitext(table.concat(ret.ohplus, ', ') .. '. ')
				:done()
		end
	end

	if ret.mh[1] then
		_ret:wikitext('For this item\'s main hand variant, see ')
			:wikitext(ret.mh[1] .. '. ')
			:done()
	end

	if ret.oh[1] then
		local _slot
		if title:find('off%-?hand') then
			_slot = 'main hand'
		else
			_slot = 'off-hand'
		end
		_ret:wikitext(string.format('For this item\'s %s variant, see ', _slot))
			:wikitext(ret.oh[1] .. '. ')
			:done()
	end

	if ret.tier[1] then
		_ret:wikitext('For other variants of this item, see ')
			:wikitext(table.concat(ret.tier, ', ') .. '. ')
			:done()
	end

	if ret.augmented[1] then
		local augtext
		if title:find('augmented') then
			augtext = 'For this item\'s standard variant, see '
		else
			augtext = 'For this item\'s augmented variant, see '
		end
		_ret:wikitext(augtext)
			:wikitext(table.concat(ret.augmented) .. '. ')
			:done()
	end

	if ret.dyed[1] then
		local dyedstr = 'dyed'
		if info.undyed then
			dyedstr = '(un)dyed'
		end
		_ret:wikitext('For this item\'s ' .. dyedstr .. ' variants, see ')
			:wikitext(table.concat(ret.dyed, ', ') .. '. ')
			:done()
	end

	if misc[1] then
		_ret:wikitext('For other variants, see ')
			:wikitext(table.concat(misc, ', ') .. '. ')
			:done()
	end

	return hat._hatnote(tostring(_ret))
end

function p.getLink(kind, item)
	local base_title = mw.title.getCurrentTitle().text
	local ekzekkil = "Ek%-ZekKil"
	if string.find(base_title, ekzekkil) then
		title = base_title
	end
	local strippedtitle = string.lower(title)
	local lowerkind = string.lower(kind)
	local strippedkind = string.gsub(lowerkind, '%-', '%%-?')
	if tt_dyes[lowerkind] then
		strippedkind = '%(' .. strippedkind .. '%)'
	end

	if item == '' then
		if string.find(strippedtitle, strippedkind) ~= nil or base_types[strippedkind] then
			if tt_dyes[lowerkind] then
				item = string.gsub(title, strippedkind, '')
			else
				item = string.gsub(strippedtitle, strippedkind, '')
			end

			if lowerkind == 'off-hand' then
				kind = 'main hand'
			elseif lowerkind == 'superior' then
				kind = 'inferior'
			elseif tt_dyes[lowerkind] or other_dyes[lowerkind] then
				kind = 'undyed'
				info.undyed = true
			else
				kind = 'non-' .. kind
			end
		else
			if tt_dyes[lowerkind] then
				local replnum
				local capitalised_kind = kind
				if lowerkind ~= 'blood' and lowerkind ~= 'blood dyed' then
					if lowerkind:find('third') then
						capitalised_kind = 'Third Age'
					elseif lowerkind:find('aurora') then
						capitalised_kind = 'Aurora'
					elseif lowerkind:find('soul') then
						capitalised_kind = 'Soul'
					elseif lowerkind:find('barrows') then
						capitalised_kind = 'Barrows'
					else
						capitalised_kind = string.lower(string.sub(kind, 1, 1)) .. string.lower(string.sub(kind, 2, -1))
					end
				end
				item, replnum = string.gsub(title, '%(.*%)$', string.format('(%s)', capitalised_kind))
				if replnum == 0 then
					item = string.format('%s (%s)', item, capitalised_kind)
				end
			else
				item = kind .. ' ' .. title
			end
		end
	else
		if string.find(strippedtitle, strippedkind) ~= nil or base_types[strippedkind] then
			if tt_dyes[lowerkind] or other_dyes[lowerkind] then
				kind = 'undyed'
				info.undyed = true
			elseif lowerkind ~= 'armour' then
				kind = 'non-' .. kind
			end
		end
	end

	if lowerkind:find('hand') or lowerkind:find('augment') then
		return string.format('[[%s]]', item)
	else
		if tt_dyes[lowerkind] and kind ~= 'undyed' then
			if lowerkind ~= 'blood' and lowerkind ~= 'blood dyed' then
				if lowerkind:find('third') then
					kind = 'Third Age'
				elseif lowerkind:find('aurora') then
					kind = 'Aurora'
				elseif lowerkind:find('soul') then
					kind = 'Soul'
				elseif lowerkind:find('barrows') then
					kind = 'Barrows'
				else
					kind = string.lower(string.sub(kind, 1, 1)) .. string.lower(string.sub(kind, 2, -1))
				end
			end
		end

		return string.format('[[%s|%s]]', item, kind)
	end
end

function p.setTitle(x)
	title = x
end

function getPlusLinks(m)
	local titlens = mw.title.getCurrentTitle().fullText
	local t = titlens
	local match = { titlens:match('^(.-) %+ ?(%d+)') }
	local curr = 0
	local links = {}
	if match[1] then
		t = match[1]
		curr = tonumber(match[2])
	end
	for i = 0, m, 1 do
		if i ~= curr then
			if i == 0 then
				table.insert(links, string.format('[[%s|%s]]', t, 'base'))
			else
				table.insert(links, string.format('[[%s + %s|+%s]]', t, i, i))
			end
		end
	end
	return links
end

function getOHPlusLinks(m)
	local titlens = mw.title.getCurrentTitle().fullText:lower()
	if titlens:find(' off hand ') then
		info.isoffhand = true
	end
	local t = titlens:gsub('off hand ', '')
	if not info.isoffhand then
		for _, v in ipairs(msr_oh_replace) do
			if t:find(v) then
				t = t:gsub(v, v .. ' off hand')
				break
			end
		end
	end
	local match = { t:match('^(.-) %+ (%d+)') }
	local links = {}
	if match[1] then
		t = match[1]
	end
	for i = 0, m, 1 do
		if i == 0 then
			table.insert(links, string.format('[[%s|%s]]', t, t))
		else
			table.insert(links, string.format('[[%s + %s|+%s]]', t, i, i))
		end
	end
	return links
end

function getMkLinks(m)
	local titlens = mw.title.getCurrentTitle().fullText
	local t = titlens
	local match = { titlens:match('^(.-) Mk%. (%d+)') }
	local curr = 0
	local links = {}
	if match[1] then
		t = match[1]
		curr = tonumber(match[2])
	end
	for i = 0, m, 1 do
		if i ~= curr then
			if i == 0 then
				table.insert(links, string.format('[[%s|%s]]', t, 'base'))
			else
				table.insert(links, string.format('[[%s Mk. %s|Mk. %s]]', t, i, i))
			end
		end
	end
	return links
end

function getOHMkLinks(m)
	local titlens = mw.title.getCurrentTitle().fullText
	if titlens:find('Off%-hand ') then
		info.isoffhand = true
	end
	local t = titlens:gsub('Off%-hand ', '')
	if not info.isoffhand then
		t = 'Off-hand ' .. t:gsub("^%L", string.lower)
	end
	local match = { t:match('^(.-) Mk%. (%d+)') }
	local links = {}
	if match[1] then
		t = match[1]
	end
	for i = 0, m, 1 do
		if i == 0 then
			table.insert(links, string.format('[[%s|%s]]', t, t))
		else
			table.insert(links, string.format('[[%s Mk. %s|Mk. %s]]', t, i, i))
		end
	end
	return links
end

function getUrnStageLinks()
	local t = mw.title.getCurrentTitle().fullText

	local currentStage = ''
	local isExquisite = t:match('^(Exquisite)') ~= nil
	local match = { t:match('^(.- urn) (%([%a ]+%))') }
	if match[1] then
		t = match[1]
		currentStage = match[2]
	end
	local links = {}
	for _, v in ipairs(urn_stages) do
		if v ~= currentStage then
			if v == '' then
				table.insert(links, string.format('[[%s|%s]]', t, 'base'))
			elseif v == '(no gem)' and not isExquisite then
				-- skip stage
			else
				table.insert(links, string.format('[[%s %s|%s]]', t, v, v))
			end
		end
	end
	return links
end

return p