local p = {}

local CARD_WIDTH = "128px"
local IMAGE_SIZE = "50px"
local IMAGE_HEIGHT = "78px"

-- Card colors
local BLUE_DARK = "#234a70"
local BLUE = "#356b9e"
local BLUE_LIGHT = "#c5d7e6"
local BLUE_LIGHTER = "#b3c9dc"
local BLUE_BORDER = "#102b43"

local GOLD = "#d4af37"

local function is_true(value)
	if value == true then
		return true
	end

	if type(value) == "string" then
		value = mw.text.trim(value):lower()

		return value == "yes"
			or value == "true"
			or value == "1"
	end

	return false
end

local function is_empty(value)
	if value == nil then
		return true
	end

	if type(value) == "string" then
		local text = mw.text.trim(value)

		if text == "" then
			return true
		end

		if text:lower():sub(1, 4) == "null" then
			return true
		end
	end

	return false
end

local function normalize_image(image)
	if is_empty(image) then
		return nil
	end

	image = mw.text.trim(tostring(image))

	-- Remove File: if Bucket supplied it.
	image = image:gsub("^File:", "")
	image = image:gsub("^file:", "")

	return image
end

local function build_membership_star(data)
	if is_true(data.members) then
		return mw.getCurrentFrame():preprocess('{{Members|yes}}')
	end

	return mw.getCurrentFrame():preprocess('{{Members|no}}')
end

local function build_mes(text, colour)
	if is_empty(text) then
		return ""
	end

	local escaped = tostring(text)
	escaped = escaped:gsub("|", "{{!}}")

	return
		'<span style="display:inline-block;">'
		.. mw.getCurrentFrame():preprocess(
			'{{mes|' .. escaped
			.. '|colour=' .. colour
			.. '|shadow=no'
			.. '}}'
		)
		.. '</span>'
end

local function build_name(data)
	local name = data.name or "Unnamed"

	return
		'<div style="min-height:17px;'
		.. 'box-sizing:border-box;'
		.. 'padding:2px 2px;'
		.. 'margin:0 0 2px 0;'
		.. 'border-radius:4px;'
		.. 'background:' .. BLUE_DARK .. ';'
		.. 'border:1px solid #102b43;'
		.. 'text-align:center;">'
		.. build_mes(name, "#ffffff")
		.. '</div>'
end

local function build_image(data)
	if is_empty(data.name) then
		return ""
	end

	local image = data.name .. " detail.png"
	local link = data.link or data.name or ""

	return
		'<div style="height:' .. IMAGE_HEIGHT .. ';'
		.. 'position:relative;'
		.. 'display:flex;'
		.. 'align-items:center;'
		.. 'justify-content:center;'
		.. 'box-sizing:border-box;'
		.. 'margin:2px;'
		.. 'border-radius:4px;'
		.. 'background:linear-gradient(to bottom, '
		.. '#b3c9dc 0%, #a4bdd3 100%);'
		.. 'border:1px solid #789ab6;">'

		-- Item image
		.. '[[File:' .. image
		.. '|' .. IMAGE_SIZE
		.. '|link=' .. link
		.. '|alt=' .. data.name
		.. '|class=noviewer]]'

		-- Membership star
		.. '<span style="position:absolute;'
		.. 'top:2px;'
		.. 'right:3px;'
		.. 'line-height:1;'
		.. 'transform:scale(0.7);'
		.. 'transform-origin:top right;">'
		.. build_membership_star(data)
		.. '</span>'

		.. '</div>'
end

local function build_tradeable_square(data)
	if not is_true(data.tradeable) then
		return ""
	end

	return
		'<span title="Tradeable" '
		.. 'style="display:inline-block;'
		.. 'width:12px;'
		.. 'height:12px;'
		.. 'background:' .. GOLD .. ';'
		.. 'border:1px solid #987d20;'
		.. 'border-radius:2px;'
		.. 'box-shadow:0 1px 1px rgba(0,0,0,0.3);">'
		.. '</span>'
end

local function build_quest_square(data)
	if is_empty(data.quest) then
		return ""
	end

	local quest = tostring(data.quest):lower()

	if quest == "no" or quest == "none" then
		return ""
	end

	return
		'<span title="Requires a quest" '
		.. 'style="display:inline-block;'
		.. 'width:12px;'
		.. 'height:12px;'
		.. 'background:#3f82bd;'
		.. 'border:1px solid #285b87;'
		.. 'border-radius:2px;'
		.. 'box-shadow:0 1px 1px rgba(0,0,0,0.3);">'
		.. '</span>'
end

local function build_flags(data)
	return
		'<div style="height:23px;'
		.. 'box-sizing:border-box;'
		.. 'display:flex;'
		.. 'align-items:center;'
		.. 'justify-content:center;'
		.. 'gap:8px;'
		.. 'margin:2px;'
		.. 'border-radius:4px;'
		.. 'background:' .. BLUE .. ';'
		.. 'border:1px solid ' .. BLUE_BORDER .. ';'
		.. 'box-shadow:inset 0 1px 0 rgba(255,255,255,0.15);">'
		.. build_tradeable_square(data)
		.. build_quest_square(data)
		.. '</div>'
end

local function build_examine(data)
	local examine = data.examine

	if is_empty(examine) then
		examine = "No examine text."
	end

	return
		'<div style="min-height:48px;'
		.. 'box-sizing:border-box;'
		.. 'margin:2px;'
		.. 'padding:5px 6px;'
		.. 'border-radius:4px;'
		.. 'background:linear-gradient(to bottom, '
		.. '#c5d7e6 0%, #b3c9dc 100%);'
		.. 'border:1px solid #789ab6;'
		.. 'text-align:center;'
		.. 'overflow-wrap:anywhere;">'
		.. build_mes(examine, "#172b3d")
		.. '</div>'
end

function p.render(frame)
	data = frame.args or {}
	return p.render_card(data)
end

function p.render_card(data)
	local card =
		'<div style="display:inline-flex;'
		.. 'vertical-align:top;'
		.. 'flex-direction:column;'
		.. 'width:' .. CARD_WIDTH .. ';'
		.. 'height:auto;'
		.. 'margin:2px;'
		.. 'padding:2px;'
		.. 'box-sizing:border-box;'
		.. 'border:2px solid ' .. BLUE_BORDER .. ';'
		.. 'border-radius:6px;'
		.. 'background:' .. BLUE .. ';'
		.. 'box-shadow:0 2px 3px rgba(0,0,0,0.35);">'

		-- Name
		.. build_name(data)

		-- Image
		.. build_image(data)

		-- Tradeable / quest indicators
		.. build_flags(data)

		-- Examine
		.. build_examine(data)

		.. '</div>'

	return card
end

return p