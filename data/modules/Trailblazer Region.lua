local p = {}
local lang = mw.getContentLanguage()

p.DEFAULT_LEAGUE = "Demonic Pacts League"

local regions = {
	misthalin = true,
	karamja = true,
	asgarnia = true,
	desert = true,
	fremennik = true,
	kandarin = true,
	morytania = true,
	tirannwn = true,
	wilderness = true,
	kourend = true,
	varlamore = true,
	general = true,
}

function p._main(region, note, link, global_highlight, league)
	if region == nil or region:lower() == "no" or region:lower() == "n/a" then
		return "None"
	end
	if league == nil or league == "" then
		league = p.DEFAULT_LEAGUE
	end
	local ret = {}
	for value in string.gmatch(region, "[^,]+") do
		-- Ampersand regions will always just show badges without text
		if string.find(value, "&") then
			local badge_result = p._badge(value, note, link, global_highlight, league)
			table.insert(ret, badge_result)
		else
			local lower = string.lower(value)
			local trimmed = lower:gsub("^%s*(.-)%s*$", "%1")
			if regions[trimmed] then
				local uc_region = lang:ucfirst(trimmed)
				local icon = p._icon(trimmed, note, link, league)
				local text
				if link == nil or link ~= 'false' then
					text = string.format('<span class="league-name">[[%s/Areas/%s|%s]]</span>', league, uc_region, uc_region)
				else
					text = uc_region
				end
				local cur_ret = highlight(string.format('%s %s', icon, text), uc_region, global_highlight)
				table.insert(ret, cur_ret)
			elseif trimmed ~= "no" and trimmed ~= "n/a" then
				table.insert(ret, value)
			end
		end
	end
	return table.concat(ret, '')
end

function highlight(s, r, global_highlight)
	r = string.lower(r)
	local highlight_class = ""
	if global_highlight ~= nil and global_highlight == 'false' then
		highlight_class = "league-no-global"
	end
	return string.format('<span class="league-region %s" data-league-area="%s">%s<span class="league-check">✓</span></span>', highlight_class, r, s)
end

function p._icon(region, note, link, league)
	if region == nil or region:lower() == "no" or region:lower() == "n/a" then
		return ""
	else
		region = lang:ucfirst(region)
	end
	if league == nil or league == "" then
		league = p.DEFAULT_LEAGUE
	end
	if note == nil then
		note = region
	end
	local label
	if link == nil or link ~= 'false' then
		label = string.format('%s/Areas/%s', league, region)
	else
		label = ''
	end
	return string.format('[[File:%s Area Badge.png|%s|link=%s]]', region, note, label)
end

function p._badge(region, note, link, global_highlight, league)
	if region == nil or region:lower() == "no" or region:lower() == "n/a" then
		return ""
	end
	if league == nil or league == "" then
		league = p.DEFAULT_LEAGUE
	end
	local highlight_class = ""
	if global_highlight ~= nil and global_highlight == 'false' then
		highlight_class = "league-no-global"
	end
	local ret = {}
	for value in string.gmatch(region, "[^,]+") do
		local lower = string.lower(value)
		-- Ampersand regions wrapped in additional badge span
		if string.find(lower, '&') then
			local ampersandRegions = {}
			local ampersandBadges = {}
			for curRegion in string.gmatch(lower, "[^&]+") do
				curRegion = curRegion:gsub("^%s*(.-)%s*$", "%1")
				if regions[curRegion] then
					table.insert(ampersandRegions, curRegion)
					local icon = p._icon(curRegion, note, link, league)
					local cur_badge = string.format('<span class="league-badge %s" data-league-area="%s">%s</span>', highlight_class, curRegion, icon)
					table.insert(ampersandBadges, cur_badge)
				end
			end
			local ampersandString = table.concat(ampersandRegions, '&')
			local innerBadgesString = table.concat(ampersandBadges, '&') 
			local cur_ret = string.format('<span class="league-badge league-badge-wrapper %s" data-league-area="%s">%s</span>',
				highlight_class, ampersandString, innerBadgesString)
			table.insert(ret, cur_ret)
		else
			local trimmed = lower:gsub("^%s*(.-)%s*$", "%1")
			if regions[trimmed] then
				local icon = p._icon(trimmed, note, link, league)
				local cur_ret = string.format('<span class="league-badge %s" data-league-area="%s">%s</span>', highlight_class, trimmed, icon)
				table.insert(ret, cur_ret)
			elseif trimmed ~= "no" and trimmed ~= "n/a" then
				table.insert(ret, value)
			end
		end
	end
	return table.concat(ret, '')
end

function p._highlightedIcon(region, note, link, global_highlight, league)
	return highlight(p._icon(region, note, link, league), region, global_highlight)
end

function p.main(frame)
	local args = frame:getParent().args
	local region = args[1]
	local note = args.note
	local link = args.link
	local global_highlight = args.global_highlight
	local frameargs = frame.args
	local league = frameargs.league
	return p._main(region, note, link, global_highlight, league)
end

function p.highlightedIcon(frame)
	local args = frame:getParent().args
	local region = args[1]
	local note = args.note
	local link = args.link
	local global_highlight = args.global_highlight
	local frameargs = frame.args
	local league = frameargs.league
	return p._highlightedIcon(region, note, link, global_highlight, league)
end

function p.icon(frame)
	local args = frame:getParent().args
	local region = args[1]
	local note = args.note
	local link = args.link
	local frameargs = frame.args
	local league = frameargs.league
	return p._icon(region, note, link, league)
end

function p.badge(frame)
	local args = frame:getParent().args
	local region = args[1]
	local note = args.note
	local link = args.link
	local global_highlight = args.global_highlight
	local frameargs = frame.args
	local league = frameargs.league
	return p._badge(region, note, link, global_highlight, league)
end

-- Shows at most 2 full chips.
-- More regions will render as badge icons without text.
function p.regionsWithSizeThreshold(arg)
	arg = arg or ''
	local ret = {}
	local comma_count = select(2, string.gsub(arg, ",", ""))
	for region in string.gmatch(arg, "[^,]+") do
		local trimmed = region:gsub("^%s*(.-)%s*$", "%1")
		if comma_count < 2 then
			table.insert(ret, p._main(trimmed))
		else
			table.insert(ret, p._badge(trimmed))
		end
	end
	return table.concat(ret, '')
end

-- Parsing function for use in infoboxes.
function p.regionsForInfobox(arg)
	if arg == nil or arg == '' or arg == 'UH OH YOU SHOULDN\'T SEE THIS!' or string.find(arg, "action=edit") then
		return nil
	end
	
	if string.lower(arg) == 'no' or string.lower(arg) == "n/a" then
		return 'N/A'
	end
	
	return p.regionsWithSizeThreshold(arg)
end

return p