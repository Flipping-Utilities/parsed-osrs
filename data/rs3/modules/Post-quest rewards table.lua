require('strict')
local p = {}

function p.main(frame)
	local args = frame:getParent().args
	local header = 'Quest'
	local query = bucket('quest_rewards')
		.select('page_name', 'post_rewards')
		.where('post_rewards', '!=', bucket.Null())
		.orderBy('page_name', 'asc')
		
	if args.type and args.type == 'miniquests' then
		header = 'Miniquest'
		query.where('Category:Miniquests')
	else
		query.where('Category:Quests')
	end
	
	local data = query.run()
	
	local tbl = mw.html.create('table')
		:addClass('wikitable sortable lighttable sticky-header')
	
	local tr = tbl:tag('tr')
	tr:tag('th'):wikitext(header)
	tr:tag('th'):wikitext('Rewards')
	
	for _, row in pairs(data) do
		tr = tbl:tag('tr')
		
		tr:tag('td'):wikitext('[[' .. row.page_name .. ']]')
		tr:tag('td'):wikitext('\n' .. row.post_rewards .. '\n')
	end
	
	return tbl
end

return p