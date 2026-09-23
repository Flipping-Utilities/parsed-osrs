local p = {}

function p.main(frame)
    local args = frame:getParent().args
    if not args['text1'] then
    	return ''
    end
    
    local cur = args['text1']..'='..args['item1']
    
    local i = 2
    while args['text'..i] do
    	cur = cur..'|-|'..args['text'..i]..'='..args['item'..i]
    	i = i + 1
    end
    
    local res = frame:callParserFunction{ name = '#tag', args = { 'Tabber', cur } }
    
    return '<div class="multi-infobox">'..res..'</div>'
end

return p