local p = {}

function p.maize_maze()
    local daycurrent = os.time()
    local daystart = os.time{year = 2026, month = 10, day = 12}
    local dayend = os.time{year = 2026, month = 11, day = 2}
    local seconds_in_day = 24 * 60 * 60
    local daysleft = math.ceil(os.difftime(dayend, daycurrent) / seconds_in_day)

    if daycurrent >= dayend then
        return ''
    end

	local start = 1
	local limit = 6
	local fullperiod = math.min(limit, daysleft)
    if daysleft < 6 then
    	local rotation = (math.floor(os.difftime(daycurrent, daystart) / seconds_in_day) % 3) + 1
    	daystart = daystart + rotation * seconds_in_day
        start = rotation + 1
        limit = rotation + daysleft
    end

	local data = {
        -- 1st
	    "Phosphosseous",
	    "Skaraxxi",
	    "Solak-o'-lantern",
        -- 2nd
	    "Phosphosseous",
	    "Skaraxxi",
	    "Solak-o'-lantern",
        -- 3rd
	    "Phosphosseous",
	    "Skaraxxi",
	    "Solak-o'-lantern",
	}
	local s = mw.html.create('div')
	s:addClass('rotation-group rotation-group-thdnd tile'):attr({
		['data-rotation-nexttimeformat']="D MMM",
		['data-rotation-start']=os.date('!%Y-%m-%d 00:00:00', daystart),
		['data-rotation-active']='{"d":1}',
		['data-rotation-fullperiod']='{"d":'..fullperiod..'}',
		['data-rotation-next-within']='{"d":0}',
		['data-rotation-itemperiod']='{"d":1}',
		['data-rotation-option-sorttotop']='true'
	})

    for i=start,limit do
        local item = s:tag('span'):addClass('rotation-item')
            local active = item:tag('div'):addClass('rotation-active-text')
            if daysleft > 1 then
                active:attr('data-rotation-aftertext', 'Future illusion')
            end

            active:tag('div'):wikitext('Current illusion'):done()
                :tag('div'):wikitext('[['..data[i]..']]'):done()
                :tag('div'):addClass('rotation-countdown'):done()

            item:tag('span'):addClass('rotation-inactive-text')
                :tag('span'):wikitext('[['..data[i]..']]'):done()
                :tag('span'):addClass('rotation-next-start'):done()
                :tag('span'):addClass('rotation-countdown'):done()
    end

    return tostring(s)
end

return p