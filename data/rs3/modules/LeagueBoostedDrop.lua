local p = {}
local pt = require('Module:Paramtest')
local hc = pt.has_content
local dt = pt.default_to
local lang = mw.language.getContentLanguage()
local var = mw.ext.VariablesLua

local rarity_class = {
	{ 1, 'table-bg-blue' },
	{ 1/25, 'table-bg-green' },
	{ 1/99.99, 'table-bg-yellow' },
	{ 1/999.99, 'table-bg-orange' },
	{ 1/9999999, 'table-bg-red' }
}

local function get_rarity_class(val)
	for i,v in ipairs(rarity_class) do
		curr = v
		if val >= v[1] then
			break
		end
	end
	return curr[2]
end

local function sigfig(n, f)
	f = math.floor(f-1)
	if n == 0 then return 0 end
	local m = math.floor(math.log10(n))
	local v = n / (10^(m-f))
	v = math.floor(v) * 10^(m-f)
	return v
end

local function commas(n)
	if tonumber(n) then
		return lang:formatNum(tonumber(n))
	else
		return n
	end
end

local function expr(t)
	t = t:gsub(',', '')
	local err, val = pcall(mw.ext.ParserFunctions.expr, t)
	if err then
		return tonumber(val)
	else
		return false
	end
end

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

function p._main(args)
	local Image = args['image']			-- only used if Name is blank, or wish to override default image. Can provide multiple images comma-delimited
	local Name = args['name']			-- name of item or drop
	local OptName = args['optname'] 	-- intended to be used when links are formatted differently, e.x. when they are multiple sources
	local Source = args['source']		-- source of drop
	local OptSource = args['optsource'] -- intended to be used when links are formatted differently, e.x. when they are multiple sources
	local Rarity = {args['rarity']}		-- base rarity of drop
	local Tiers = args['tiers']			-- Optional parameter to determine quantity of rarity tiers to create on table row, including base rarity (default is 3)
	local Columns = args['columns']		-- Optional parameter to create a total number of columns if greater than Tiers
	local Unfloored = args['unfloored'] -- Optional parameter to prevent rarity from being floored after the multiplier is applied

	local rv1, rv2 = string.match(Rarity[1]:gsub(',',''), '([%d%.]+)/([%d%.]+)')
	if rv1 and rv2 then
		Rarity[1] = rv1/rv2
	else
		Rarity[1] = expr(Rarity)
	end

	local TotalTiers = tonumber(Tiers) or 3
	local TotalColumns = tonumber(Columns) or 0
	
	for index = 2, TotalTiers do
		local Multi = args["multi"..index-1] -- Optional change to tier rarity multiplier, default to tier number
		Rarity[index] = Rarity[1] * (Multi or index)
	end
	
	local rare_class = {}	-- assign colors for rarity
	local rare_text = {}
	for index, rarity in ipairs(Rarity) do
		local Denominator = sigfig((1/Rarity[index] + 0.001), 5)
		if Unfloored ~= nil then
			if Denominator <= 1.001 then
				rare_text[index] = "Always"
				rare_class[index] = get_rarity_class(1)
			else
				rare_text[index] = '1/' .. commas(string.format('%.1f', Denominator))
				rare_class[index] = get_rarity_class(1/Denominator)
			end
		elseif math.floor(Denominator) <= 1 then
			rare_text[index] = "Always"
			rare_class[index] = get_rarity_class(1)
		else
			rare_text[index] = '1/' .. commas(math.floor(Denominator))
			rare_class[index] = get_rarity_class(1/math.floor(Denominator))
		end
	end
	
	--Use Name as image link, or Image exactly as written
	if Image == nil then
		Image = mw.ustring.format('[[File:%s.png]]', Name)
	else
		local temp = ''
		for img in string.gmatch(Image, ' *([^,]+) *') do
			temp = temp .. mw.ustring.format('[[File:%s.png]]', img)
		end
		Image = temp
	end
	
	--Use Name as link, or OptName exactly as written
	Name = Name and mw.ustring.format('[[%s]]', Name) or OptName
	
	--Use Source as link, or OptSource exactly as written if Source is empty
	Source = Source and mw.ustring.format('[[%s]]', Source) or OptSource
	
	--Set DropsLine var if a <ref> was used in the source text
	if Source:match('UNIQ%-%-ref') ~= nil then
		var.vardefine('_refs_used_', 'true')
	end
	
	--create rows for table	
	local ret = mw.html.create('tr')
		:tag('td')
			:addClass('inventory-image')
			:wikitext(Image)
		:done()
		:tag('td')
			:css('text-align','left')
			:addClass('item-col')
			:wikitext(Name)
		:done()
		:tag('td')
			:css('text-align','center')
			:addClass('source-col')
			:wikitext(Source)
		:done()
	for index = 1, TotalTiers do
		ret = ret
			:tag('td')
				:addClass(rare_class[index])
				:wikitext(rare_text[index])
				:attr('data-sort-value',1/Rarity[index])
			:done()
	end
	for index = TotalTiers + 1, TotalColumns do
		ret = ret
			:tag('td')
				:addClass('table-na nohighlight')
				:css('text-align','center')
				:wikitext("N/A")
				:attr('data-sort-value',0)
			:done()
	end
	return tostring(ret)
end

function p.simple(frame)
	return p._simple(frame:getParent().args)
end
function p._simple(args)
	local names = {}
	local namestr = ''
	if hc(args.optname) then
		namestr = args.optname
	else
		if hc(args.name) then
			namestr = ''
			local spl = mw.text.split(args.name, ';')
			for i, n in ipairs(spl) do
				local name = mw.text.trim(n)
				if name ~= '' then
					if name == '<br>' then
						namestr = namestr .. '<br>'
						table.insert(names, '<br>')
					elseif #name > 0 then
						table.insert(names, name)
						namestr = namestr .. '[['..name..']]'
						if i < #spl then
							namestr = namestr .. ', '
						end
					end
				end
			end
		end
	end
	local image
	if hc(args.optimage) then
		image = args.optimage
	else
		local iter
		if hc(args.image) then
			iter = mw.text.split(args.image, ';')
		else
			iter = names
		end
		image = ''
		for i, name in ipairs(iter) do
			img = mw.text.trim(name)
			if img == '<br>' then
				image = image .. '<br>'
			elseif #img > 0 then
				image = image .. '[[File:'..img..'.png|link='..img..']]'
				if i < #iter then
					image = image .. ' '
				end
			end
		end
	end
	local source = ''
	if hc(args.optsource) then
		source = args.optsource
	else
		if hc(args.source) then
			local spl = mw.text.split(args.source, ';')
			for i, n in ipairs(spl) do
				local name = mw.text.trim(n)
				if name ~= '' then
					if name == '<br>' then
						source = source .. '<br>'
					elseif #name > 0 then
						source = source .. '[['..name..']]'
						if i < #spl then
							source = source .. ', '
						end
					end
				end
			end
		end
	end
	local notes = dt(args.notes, '')

	--create rows for table	
	local ret = mw.html.create('tr')
		:tag('td')
			:addClass('inventory-image')
			:wikitext(image)
		:done()
		:tag('td')
			:addClass('item-col')
			:wikitext(namestr)
		:done()
		:tag('td')
			:addClass('source-col')
			:wikitext(source)
		:done()
		:tag('td')
			:addClass('source-col')
			:wikitext(notes)
		:done()
	return tostring(ret)
end

return p