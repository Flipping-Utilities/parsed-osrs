local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')

local p = {}

function p.main(frame)
	return p._main(frame:getParent().args)
end

function p._main(args)
	local pages = {}

	for _, page in ipairs(args) do
		table.insert(pages, mw.text.trim(page))
	end

	if #pages == 0 then
		return ''
	end

	local conditions = {}
	for _, page in ipairs(pages) do
		table.insert(conditions, {'page_name', page})
	end

	local responses = {}
	local cosmetics = bucket('infobox_cosmetic_override')
		.select('page_name', 'json', 'Category:Titles')
		.where(bucket.Or(unpack(conditions)))
		.run()

	for _, row in ipairs(cosmetics or {}) do
		local decoded_json = mw.text.jsonDecode(row.json or '{}')
		decoded_json.title = row['Category:Titles']
		responses[row.page_name] = decoded_json
	end

	-- Look up scenery only where a cosmetic image or title icon
	-- is not already available.
	local scenery_conditions = {}

	for _, page in ipairs(pages) do
		local key = string.gsub(page, '^%l', string.upper)
		local decoded_json = responses[key]

		if not decoded_json
			or (not decoded_json.title and not decoded_json.image) then
			table.insert(scenery_conditions, {'page_name', page})
		end
	end

	if #scenery_conditions > 0 then
		local scenery = bucket('infobox_scenery')
			.select('page_name', 'image')
			.where(bucket.Or(unpack(scenery_conditions)))
			.run()

		for _, row in ipairs(scenery or {}) do
			local decoded_json = responses[row.page_name] or {}
			local image = row.image and row.image[1]

			if not decoded_json.image and image then
				decoded_json.image = image:gsub('^[Ff]ile:', '')
			end

			responses[row.page_name] = decoded_json
		end
	end

	local gallery = {}

	for _, page in ipairs(pages) do
		local key = string.gsub(page, '^%l', string.upper)
		local decoded_json = responses[key]
		local img_text = '[[' .. page .. ']]'
		local img_link = ''
		local img_link_alt = ''

		if decoded_json then
			if decoded_json.title then
				img_text = img_text .. ' title'
				img_link = string.format(
					'[[File:Titles icon.png|200x250px|%s]]',
					img_text
				)
			else
				img_link = string.format(
					'[[File:%s|200x250px|link=%s|%s]]',
					decoded_json.image or 'Section anchor light.svg',
					page,
					img_text
				)
			end

			if decoded_json.altimage then
				img_link_alt = string.format(
					'[[File:%s|200x250px|link=%s|%s]]',
					decoded_json.altimage,
					page,
					img_text
				)
			end
		end

		table.insert(gallery, string.format([[
	<li class="gallerybox">
		<div>
			<div class="thumb">
				<div>%s%s</div>
			</div>
			<div class="gallerytext">%s</div>
		</div>
	</li>
]], img_link, img_link_alt, img_text))
	end

	if onmain() and yesno(args.bucket or true) then
		bucket('infobox_cosmetic_override').put({components = pages})
	end

	return string.format([[
<div class="cosmetic-override-gallery">
	<ul class="gallery mw-gallery-traditional">
		%s
	</ul>
</div>]], table.concat(gallery, '\n'))
end

return p