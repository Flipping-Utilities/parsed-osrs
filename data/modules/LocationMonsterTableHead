local p = {}

local params = require('Module:Paramtest')
local yesno = require('Module:Yesno')
local var = mw.ext.VariablesLua

function p.main(frame)
	local args = frame:getParent().args
    local showmembers, showslayer, showkillrequirement, showwildernesslevel, showkrystiliataskgp = params.defaults{
        { args.showmembers or args.ShowMembers, 'no' },
        { args.showslayer or args.ShowSlayer, 'no' },
        { args.showkillrequirement or args.ShowKillRequirement, 'no' },
        { args.showwildernesslevel or args.ShowWildernessLevel, 'no' },
        { args.showkrystiliataskgp or args.ShowKrystiliaTaskGP, 'no' }
    }
    
    var.vardefine('ShowMembers', showmembers)
    var.vardefine('ShowSlayer', showslayer)
    var.vardefine('ShowKillRequirement', showkillrequirement)
    var.vardefine('ShowWildernessLevel', showwildernesslevel)
    var.vardefine('ShowKrystiliaTaskGP', showkrystiliataskgp)
	
    local ret = mw.html.create('')
    ret:tag('tr')
    ret:tag('th'):attr('colspan', 2):wikitext('Monster'):done()
    if yesno(showmembers) then
    	ret:tag('th'):wikitext('Members'):done()
    end
    ret:tag('th'):wikitext('Levels'):done()
    if yesno(showslayer) then
    	ret:tag('th'):wikitext('Slayer level'):done()
    	ret:tag('th'):wikitext('Slayer XP'):done()
    end
    if yesno(showkillrequirement) then
		ret:tag('th'):wikitext('Kill requirement'):done()
	end
    ret:tag('th'):attr('data-sort-type', 'number'):wikitext('Spawns'):done()
    if yesno(showwildernesslevel) then
		ret:tag('th'):wikitext('Wilderness level'):done()
    end
	if yesno(showkrystiliataskgp) then
		ret:tag('th'):wikitext('Average gold per kill (GE)<br/>Krystilia task'):done()
		ret:tag('th'):wikitext('Average gold per kill (GE)<br/>Non-Krystilia task or no task'):done()
	end
    ret:done()
    return '<table class="wikitable sortable" style="text-align:center;">' .. tostring(ret)
end

return p