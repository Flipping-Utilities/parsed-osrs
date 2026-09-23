local p = {}

local params = require('Module:Paramtest')
local yesno = require('Module:Yesno')
local var = mw.ext.VariablesLua

function p.main(frame)
    local args = frame:getParent().args

    -- Params and defaults
    local name, levels, spawns, members, slayerlevel, slayerxp, killrequirement, wildernesslevel, killgp, krystiliataskgp = params.defaults{
        {args.name or args.Name, ''},
        {args.levels or args.Levels, ''},
        {args.spawns or args.Spawns, ''},
        {args.members or args.Members, ''},
        {args.slayerlevel or args.SlayerLevel, ''},
        {args.slayerxp or args.SlayerXP, ''},
        {args.killrequirement or args.KillRequirement, ''},
        {args.wildernesslevel or args.WildernessLevel, ''},
        {args.killgp or args.KillGP, ''},
        {args.krystiliataskgp or args.KrystiliaTaskGP, ''}
    }
    
    local displayname = params.default_to(args.displayname or args.DisplayName,name)
    local image = 'File:' .. params.default_to(args.image or args.Image, name .. '.png')
    local showmembers = var.var('ShowMembers', 'no')
    local showslayer = var.var('ShowSlayer', 'no')
    local showkillrequirement = var.var('ShowKillRequirement', 'no')
    local showwildernesslevel = var.var('ShowWildernessLevel', 'no')
    local showkrystiliataskgp = var.var('ShowKrystiliaTaskGP', 'no')

    local ret = mw.html.create('tr'):css('text-align','center')
    ret:tag('td'):css('height', '64px'):wikitext(mw.ustring.format('[[%s|link=%s|64x64px]]', image, name))
    ret:tag('td'):css('text-align','left'):wikitext(mw.ustring.format('[[%s|%s]]', name, displayname))
    if yesno(showmembers) then
    	ret:tag('td'):wikitext(yesno(members) and '[[File:Member icon.png|center|link=Members|alt=Members]]' or '[[File:Free-to-play icon.png|center|link=Free-to-play|alt=Free-to-play]]'):done()
    end
    ret:tag('td'):wikitext(levels):done()
    if yesno(showslayer) then
    	if slayerlevel == '' then
    		ret:tag('td'):attr('data-sort-value', '0'):wikitext('N/A'):done()
    	else
    		ret:tag('td'):wikitext(slayerlevel):done()
    	end
		
		if slayerxp == '' then
    		ret:tag('td'):attr('data-sort-value', '0'):wikitext('N/A'):done()
    	else
    		ret:tag('td'):wikitext(slayerxp):done()
		end
    end
    if yesno(showkillrequirement) then
		ret:tag('td'):wikitext(killrequirement):done()
	end
    ret:tag('td'):wikitext(spawns):done()
    if yesno(showwildernesslevel) then
		ret:tag('td'):wikitext(wildernesslevel):done()
    end
	if yesno(showkrystiliataskgp) then
		ret:tag('td'):wikitext(krystiliataskgp):done()
		ret:tag('td'):wikitext(killgp):done()
	end
    
    return tostring(ret)
end

return p