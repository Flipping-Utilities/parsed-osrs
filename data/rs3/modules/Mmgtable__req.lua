local skill_pics = mw.loadData('Module:Skill clickpic/data')
local quests = mw.loadData('Module:Questreq/data')
local pt = require('Module:Paramtest')
local yn = require('Module:Yesno')

-- variant of [[Module:Skill clickpic]]
local function skillclickpic(skill,level,icon,txt,imgsize)
	if type(skill) == 'string' and skill_pics[skill:lower()] then
		file = skill_pics[skill:lower()]
	else
		return nil
	end
	local pic = file.image
	local text = ''
	if pt.has_content(icon) then
		pic = icon
	end
	if pt.has_content(txt) then
		text = '&nbsp;[['..file.link..'|'..txt..']]'
	end
	local size = '21x21px'
	if pt.has_content(imgsize) then
		size = imgsize
	end
	local ret = '[[File:'..pic..'.png|'..size..'|link='..(file.link or '')..'|alt='..(file.link or '')..']]'..text
	if level then
		ret = level..'&nbsp;'..ret
	end
	return ret
end
-- variant of {{ilink}}
local function questlink(quest, icon, txt, imgsize)
	if not (type(quest) == 'string' and quests[quest]) then
		return nil
	end
	local pic = quest..' icon'
	local text = quest
	if pt.has_content(icon) then
		pic = icon
	end
	if pt.has_content(txt) then
		text = txt
	end
	local size = '29x29px'
	if pt.has_content(imgsize) then
		size = imgsize
	end
	local ret = '[[File:'..pic..'.png|link='..quest..'|'..size..']]&nbsp;[['..text..']]'
	return ret
end

local function plink(item, num, icon, txt)
	local link = item
	local img = item
	local text = item
	if pt.has_content(icon) then
		img = icon
	end
	if pt.has_content(txt) then
		text = txt
	end
	local size = '25x25px'
	if pt.has_content(imgsize) then
		size = imgsize
	end
	local ret = '[[File:'..img..'.png|'..size..'|link='..item..']]&nbsp;[['..item..'|'..text..']]'
	if num ~= 1 then
		ret = num .. '&nbsp;×%nbsp;'..ret
	end
	return ret
end

local p = {}

local reqstrengths = {
	optional = true,
	recommended = true,
	required = true
}

function p.main(frame)
	local args = frame:getParent().args
	local reqimp = args.required or ''
	if not reqstrengths[reqimp:lower()] then
		reqimp = 'required'
	end
	local reqimpstr = ''
	if reqimp ~= 'required' and not reqimphide then
		reqimpstr = ' '..reqimp
	end
	if tostring(args[1]):lower() == 'or' then
		local reqimp = args.required or ''
		if not reqstrengths[reqimp:lower()] then
			reqimp = ''
			reqimpstr = ''
		end
		local mmgimp = ''
		if reqimp ~= '' then
			mmgimp = ' data-mmg-imp="'..reqimp..'"'
		end
		return '<span class="mmg-req mmg-req-or"'..mmgimp..'>'..args[2]..reqimpstr..'</span>'
	end
	local reqtype = args.req or args[1]
	local reqnum = tonumber(args.level) or tonumber(args.num) or tonumber(args[2]) or 1
	local reqimp = args.required or ''
	local reqimphide = yn(args.hide_reqtxt)
	local reqnote = args.reqnote
	if pt.has_content(reqnote) then
		reqnote = ' '..reqnote
	else
		reqnote = ''
	end
	-- is it a skill?
	local imgsize = args.size
	local linkpic = args.pic
	local linktxt = args.txt
	local ret = skillclickpic(reqtype, reqnum, linkpic, linktxt, imgsize)
	if ret ~= nil then
		return '<span class="mmg-req mmg-skill" data-mmg-skill="'..reqtype:lower()..'" data-mmg-level="'..reqnum..'" data-mmg-imp="'..reqimp..'">'..ret..reqimpstr..reqnote..'</span>'
	end
	-- is it a quest?
	ret = questlink(reqtype, linkpic, linktxt, imgsize)
	if ret ~= nil then
		return '<span class="mmg-req mmg-quest" data-mmg-quest="'..reqtype..'" data-mmg-imp="'..reqimp..'">'..ret..reqimpstr..reqnote..'</span>'
	end
	-- its an item
	ret = plink(reqtype, reqnum, linkpic, linktxt, imgsize)
	return '<span class="mmg-req mmg-item" data-mmg-item="'..reqtype..'" data-mmg-num="'..reqnum..'" data-mmg-imp="'..reqimp..'">'..ret..reqimpstr..reqnote..'</span>'
end

return p