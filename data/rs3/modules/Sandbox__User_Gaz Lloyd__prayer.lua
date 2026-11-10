local league = require('Module:LeagueRegion')
local p = {}

local function makeTable()
	local ret = mw.html.create('table')
	ret:addClass('wikitable sortable')
	ret:tag('tr')
		:tag('th')
			:wikitext('Item')
		:done():tag('th')
			:wikitext('Class')
		:done():tag('th')
			:wikitext('Prayer')
		:done():tag('th')
			:wikitext('Regions')
		:done()
	:done()
	return ret
end

local function plink(page, images)
	local img = ''
	if images and #images > 0 then
		img = '[['..images[#images]..'|link='..page..']]&nbsp;'
	else
		img = '[[File:'..page..'.png|link='..page..']]&nbsp;'
	end
	return img .. '[['..page..']]'
end
	

function p.main(frame)
	local b = bucket('infobox_bonuses').join('infobox_item', 'infobox_bonuses.page_name_sub', 'infobox_item.page_name_sub').select('infobox_bonuses.page_name_sub', 'infobox_bonuses.prayer_bonus', 'infobox_bonuses.equipment_slot', 'infobox_bonuses.combat_class', 'infobox_item.league_region', 'infobox_item.image').where('infobox_bonuses.prayer_bonus', '>', 0).where(bucket.Not('Category:Dyed equipment')).where(bucket.Not('Category:Augmented items')).orderBy('infobox_bonuses.prayer_bonus', 'desc').limit(5000).run()
	--mw.logObject(b)
	local tables = {}
	for i,v in pairs(b) do
		local t = tables[v['infobox_bonuses.equipment_slot']]
		if not t then
			t = makeTable()
			tables[v['infobox_bonuses.equipment_slot']] = t
		end
		t:newline():tag('tr')
			:tag('td')
				:wikitext(plink(v['infobox_bonuses.page_name_sub'], v['infobox_item.image']))
			:done():tag('td')
				:wikitext(v['infobox_bonuses.combat_class'])
			:done():tag('td')
				:wikitext(v['infobox_bonuses.prayer_bonus'])
			:done():tag('td')
				:wikitext(league._compact(v['infobox_item.league_region'], 'Equilibrium League'))
			:done()
		:done()
	end
	local out = {}
	for s,t in pairs(tables) do
		table.insert(out, '\n=='..s..'==')
		table.insert(out, tostring(t))
	end
	return table.concat(out, '\n')
end

return p