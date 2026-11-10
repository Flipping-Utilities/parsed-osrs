local perks = mw.loadData('Module:Perks/data')
local yn = require('Module:Yesno')
local hc = require('Module:Paramtest').has_content
local split = require('Module:StringUtil').split

local allowed_ranks = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
	['1'] = 1,
	['2'] = 2,
	['3'] = 3,
	['4'] = 4,
	['5'] = 5,
	['6'] = 6
}

local p = {}

function p.main(frame)
	return p._main(frame:getParent().args)
end

function p._main(args)
	local perk = args[1]
	if not hc(perk) then
		return 'Please specify a perk'
	end
	
	perk = mw.text.trim(perk:lower():gsub(' %(perk%)', ''))
	local perkinfo = perks[perk]
	if not perkinfo then
		return args[1]..' is an invalid perk'
	end
	local ret = mw.html.create('')
	local span = ret:tag('span')
	span:addClass('perk-link')
	if yn(args.bg) == false then
		span:addClass('perk-link-nobg')
	end
	
	local img = perkinfo.name
	if hc(args.pic) then
		img = args.pic
	end
	local page = perkinfo.name
	
	span:wikitext(string.format('[[File:%s.png|25x25px|link=%s|%s]]', img, page, page))
	
	local rank = allowed_ranks[args.rank] or allowed_ranks[args[2]]
	if rank then
		span:tag('span')
				:addClass('perk-link-rank')
				:wikitext(string.format('[[File:Perk rank %s.png|25x25px|link=%s]]', rank, page))
	end
	
	if yn(args.link) ~= false then
		local txt
		if hc(args.txt) then
			txt = args.txt
		else
			local nicename = perkinfo.name:gsub(' %(perk%)', '')
			if rank then
				txt = nicename .. ' ' .. rank
			else
				txt = nicename
			end
		end
		
		ret:wikitext(string.format('[[%s|%s]]', page, txt))
	end
	return tostring(ret)
end
	
function parsePerk(ps)
	_, _, perk, rank = string.find(ps, "(.*[a-zA-Z]) ?%[?(%d*%-?%d*)%]?$")
	return mw.text.trim(perk:lower()), rank
end

function p.multi(frame)
	invokeArgs = frame.args
	templateArgs = frame:getParent().args
	args = {
		perks = invokeArgs.perks or templateArgs.perks or templateArgs[1],
		sep = invokeArgs.sep,
	}
	return p._multi(args)
end

function p._multi(args)
	local perklist = args.perks or args[1]
	if not hc(perklist) then
		return "Please specify a list of perks"
	end
	
	sep = args.sep or args[2] or " "
	links = {}
	for _, ps in ipairs(split(perklist, ',', true)) do
		perk, rank = parsePerk(ps)
		if perk == nil then
			return "'" .. ps .. "' is not a validly formatted perk"
		end
		table.insert(links, p._main({perk, rank=rank}))
	end
	return table.concat(links, sep)
end

return p