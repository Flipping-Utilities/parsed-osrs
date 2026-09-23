--[[
{{Helper module
|name = Tables
|fname1 = _row(row, elts, header)
|ftype1 = mw.html object, table/string, boolean
|fuse1 = Adds <code>td</code> or <code>th</code> cells to the html object with the cells data specified by <code>elts</code>. If <code>header</code> = <code>true</code> then all cells added will have the <code>th</code> tag.
|fname2 = _table(table, data)
|ftype2 = mw.html object, table
|fuse2 = Adds <code>tr</code> rows and <code>td</code>/<code>th</code> cells to the html object, the data for the rows and cells is specified by <code>data</code>.
}}
-- ]]
local p = {}

function p._row( row, elts, header )
    local _tag = header and 'th' or 'td'
    local ret = {}
    for _, v in ipairs(elts) do
        if type(v) == 'table' then
            table.insert(ret,row:tag(_tag):wikitext(v.text):attr(v.attr or {}):addClass(v.class or ""):css(v.css or {}):done())
        else
            table.insert(ret,row:tag(_tag):wikitext(v):done())
        end
    end
    row:done()
    return unpack(ret)
end

function p._table(table, data)
    for _, rowdata in ipairs(data) do
    	if rowdata ~= false then
	        row = table:tag('tr')
	        for _, v in ipairs(rowdata) do
	            if not v then
	            else
	                row:tag(v.tag or 'td'):wikitext(v.text):attr(v.attr or {}):addClass(v.class or ""):css(v.css or {}):done()
	            end
	        end
	        row:done()
        end
    end
end

return p