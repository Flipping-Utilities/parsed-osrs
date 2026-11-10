require('Module:Mw.html extension')
local p = {}

local mdata = mw.loadData('Module:Perks/materials')
local pdata = mw.loadData('Module:Perks/data')

local rarity_order = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Ancient = 4
}

function p.main(frame)
	local args = frame:getParent().args
	if args.historical then
		mdata = mw.loadData('Module:Perks/materials/historical')
	end
	
	local _arg = mw.text.decode(args[1] or '')
	_arg = string.lower(_arg)
	_arg = _arg:gsub('%(perk%)','')
	_arg = mw.text.trim(_arg)
	local argdata = pdata[_arg]

	if not argdata then
		return 'No perk as '..arg
	end

	local listmats = {}
    local perks_exist = false
    local ancient_perks_exist = false

	for _, v in pairs(mdata) do
        local mat_perks = v.perks and v.perks[_arg] or nil
        local mat_ancient_perks = v.ancientperks and v.ancientperks[_arg] or nil
        local mat_perks_exist = mat_perks ~= nil
        local mat_ancient_perks_exist = mat_ancient_perks ~= nil

		if mat_perks_exist or mat_ancient_perks_exist then
			table.insert(listmats, { v.name, v.rarity, mat_perks, mat_ancient_perks })
		end

        perks_exist = perks_exist or mat_perks_exist
        ancient_perks_exist = ancient_perks_exist or mat_ancient_perks_exist
	end

    function compareMats(a, b)
        local ra = rarity_order[a[2]]
        local rb = rarity_order[b[2]]
        if ra ~= rb then
            return ra < rb
        end

        return a[1] < b[1]
    end

    table.sort(listmats, compareMats)

	local ret = mw.html.create('table')
        :addClass('wikitable perklist perklist-creation')
        :IF(args.historical)
        	:tag("caption")
        	:wikitext("Historical source data")
        	:done()
    	:END()
        :tag('tr')
            :tag('th')
                :attr('colspan','2')
                :attr('rowspan','3')
                :wikitext('Material')
            :done()
            :tag('th')
                :attr('rowspan','3')
                :wikitext('Rarity')
            :done()
            :tag('th')
                :attr('colspan','14')
                :wikitext('Perk ranks with X materials')
            :done()
        :done()

    local row = ret:tag('tr')
    if perks_exist then
        row:tag('th')
                :attr('colspan','5')
                :wikitext("Standard gizmo")
            :done()
    end

    if ancient_perks_exist then
        row:tag('th')
                :attr('colspan','9')
                :addClass('perklist-ancient')
                :wikitext("[[Ancient gizmos|Ancient gizmo]]")
            :done()
        :done()
    end

    row = ret:tag('tr')
    if perks_exist then
            row:tag('th')
                :css('width','2em')
                :wikitext('1')
            :done()
            :tag('th')
                :css('width','2em')
                :wikitext('2')
            :done()
            :tag('th')
                :css('width','2em')
                :wikitext('3')
            :done()
            :tag('th')
                :css('width','2em')
                :wikitext('4')
            :done()
            :tag('th')
                :css('width','2em')
                :wikitext('5')
            :done()
    end

    if ancient_perks_exist then
            row:tag('th')
                :css('width','2em')
                :addClass('perklist-ancient')
                :wikitext('1')
            :done()
            :tag('th')
                :css('width','2em')
                :addClass('perklist-ancient')
                :wikitext('2')
            :done()
            :tag('th')
                :css('width','2em')
                :addClass('perklist-ancient')
                :wikitext('3')
            :done()
            :tag('th')
                :css('width','2em')
                :addClass('perklist-ancient')
                :wikitext('4')
            :done()
            :tag('th')
                :css('width','2em')
                :addClass('perklist-ancient')
                :wikitext('5')
            :done()
            :tag('th')
                :css('width','2em')
                :addClass('perklist-ancient')
                :wikitext('6')
            :done()
            :tag('th')
                :css('width','2em')
                :addClass('perklist-ancient')
                :wikitext('7')
            :done()
            :tag('th')
                :css('width','2em')
                :addClass('perklist-ancient')
                :wikitext('8')
            :done()
            :tag('th')
                :css('width','2em')
                :addClass('perklist-ancient')
                :wikitext('9')
            :done()
        :done()
    end

	for _, v in pairs(listmats) do
		local newrow = ret:tag('tr')
		local matname = v[1]
		newrow
			:tag('td')
				:css('padding','4px')
				:wikitext(string.format('[[File:%s.png|link=%s|center]]',matname,matname))
			:done()
			:tag('td')
				:wikitext(string.format('[[%s]]',matname))
			:done()
			:tag('td')
				:wikitext(v[2])
			:done()

            if perks_exist then
                if v[3] then
                    for _, w in ipairs(v[3]) do
                        local a,b = w[1],w[2]
                        local c
                        if a == b then
                            c = a
                        else
                            c = mw.ustring.format('%s–%s',a,b)
                        end
                        local newtd = newrow:tag('td')
                        if c == 0 then
                            newtd:addClass('table-na')
                        end
                        newtd:css({ ['text-align'] = 'right' })
                                :wikitext(c)
                            :done()
                    end
                else
                    local newtd = newrow:tag('td')
                    newtd:wikitext("N/A"):attr('data-sort-value', '0'):attr('colspan', '5'):addClass("table-na nohighlight")
                end
            end

            if ancient_perks_exist then
                if v[4] then
                    for _, w in ipairs(v[4]) do
                        local a,b = w[1],w[2]
                        local c
                        if a == b then
                            c = a
                        else
                            c = mw.ustring.format('%s–%s',a,b)
                        end
                        local newtd = newrow:tag('td')
                        newtd:addClass('perklist-ancient')
                        if c == 0 then
                            newtd:addClass('table-na')
                        end
                        newtd:css({ ['text-align'] = 'right' })
                                :wikitext(c)
                            :done()
                    end
                else
                    local newtd = newrow:tag('td')
                    newtd:wikitext("N/A"):attr('data-sort-value', '0'):attr('colspan', '9'):addClass("table-na nohighlight perklist-ancient")
                end
            end
		newrow:done()
	end

	return ret
end

return p