-- <nowiki>
--
-- implements [[Template:Form calculator]]
--    for generating form calculators
-- [[RuneScape:Calculators/Form calculators]]
-- j
-- performs some minor checks on the input; the JavaScript still does most of it, though
--

local pt = require('Module:Paramtest')
local hascontent = pt.has_content
local defto = pt.default_to

-- possible parameter types
local param_types = {string = true, article = true, number = true, int = true, select = true, buttonselect = true, combobox = true, check = true, toggleswitch = true, togglebutton = true, hs = true, rsn = true, group = true, fixed = true, hidden = true, semihidden = true}

local p = {}

-- helper functions
local function type_check(arg)
    if hascontent(arg) and param_types[arg] then
        return arg
    else
        return 'string'
    end
end

local function process_param(args, conf, num)
    local param = args['param' .. num]
    local label = defto(args['label' .. num], param)
    local type = type_check(args['type' .. num])
    local default = defto(args['default' .. num], '')
    local range = defto(args['range' .. num], '')
    local toggles = defto(args['toggles' .. num], '')
    local help = defto(args['help' .. num], '')
    
    --for clarity, do this here
    local str = param .. '|' .. label .. '|' .. default .. '|' .. type .. '|' .. range .. '|' .. toggles .. '|' .. help
    
    conf:wikitext('param = ' .. str .. '\n')
end

local function process_field(args, conf, num)
    local field = args['field' .. num]

    conf:wikitext(field .. '\n')
end

local function makeHTable(args, form, result)
    return mw.html.create('table')
            :cssText(args.tablecss)
            :tag('tr')
                :tag('td')
                    :attr('id', form)
            		:cssText(args.tableformcss)
                    :wikitext(p._jsnotice(args))
                :done()
                :tag('td')
                    :css('width', '10px')
                :done()
                :tag('td')
                    :attr('id', result)
            		:cssText(args.tableresultcss)
                    :wikitext(p._resnotice(args))
                :done()
            :done()
end

local function makeVTable(args, form, result)
    return mw.html.create('table')
            :addClass('wikitable calctable')
            :cssText(args.tablecss)
            :tag('tr')
                :tag('th')
                    :wikitext('Calculator')
                :done()
            :done()
            :tag('tr')
                :tag('td')
                    :attr('id', form)
        			:cssText(args.tableformcss)
                    :wikitext(p._jsnotice(args))
                :done()
            :done()
            :tag('tr')
                :tag('th')
                    :wikitext('Result')
                :done()
            :done()
            :tag('tr')
                :tag('td')
                    :attr('id', result)
            		:cssText(args.tableresultcss)
                    :wikitext(p._resnotice(args))
                :done()
            :done()
end

--used internally but can also be an entry point
function p.jsnotice(frame)
	return p._jsnotice(frame:getParent().args)
end
function p._jsnotice(args)
    local page = mw.title.getCurrentTitle()
    if args.forminit then
        return args.forminit
    else
        return 'The calculator form will appear here soon. You will need JavaScript enabled.'
    end
end

--used internally but can also be an entry point
function p.resnotice(frame)
	return p._resnotice(frame:getParent().args)
end
function p._resnotice(args)
    if args.resultinit then
        return args.resultinit
    else
        return 'The result will appear here when you submit the form.'
    end
end

--main entry for constructing a calculator
function p.main(frame)
	return p._main(frame:getParent().args)
end
function p._main(args)
    local template, form, result
    local modu, moduf = nil,nil
    local err = ''
    if hascontent(args.module) then
    	modu = args.module
    	if hascontent(args.modulefunc) then
    		moduf = args.modulefunc
    	end
    else
	    if hascontent(args.template) then
	        template = args.template
	        modu = nil
	    else
	        err = 'No template/module specified<br />'
	    end
	end
    
    if hascontent(args.form) then
        form = args.form
    else
        err = err .. 'No form ID specified<br />'
    end
    
    if hascontent(args.result) then
        result = args.result
    else
        err = err .. 'No result ID specified<br />'
    end
    
    local cat = ''
    -- if the category is not overridden AND [the page param is missing OR the page param = the title]
    if defto(args.cat, 'yes') ~= 'no' and (not hascontent(args.page) or mw.text.trim(args.page):gsub('_', ' ') == mw.title.getCurrentTitle().prefixedText) then
        cat = '[[Category:Form calculators]]'
    end
    
    if err ~= '' then
        if cat ~= '' then
            cat = cat .. '[[Category:Form calculator errors]]'
        end
        return '<span class="error">'.."'''Fatal error(s) found in form definition:'''<br />" .. err .. '</span>' .. cat
    end
    
    local conf = mw.html.create('div')
    local s = ''
    if modu ~= nil then
    	s = 'module = ' .. modu
    	if moduf ~= nil then
    		s = s .. '\n' .. 'modulefunc = ' .. moduf
    	end
    else
    	s = 'template = ' .. template
    end
    conf:addClass('hidden jcConfig')
        :wikitext('\n')
        :wikitext(s .. '\n')
        :wikitext('form = ' .. form .. '\n')
        :wikitext('result = ' .. result .. '\n')
        :done()
    
    if hascontent(args.autosubmit) then
    	conf:wikitext('autosubmit='..args.autosubmit..'\n')
    end
    if hascontent(args.name) then
    	conf:wikitext('name='..args.name..'\n')
    end
    
    if hascontent(args.suggestns) then
        --check ns stuff
        for i,v in pairs(mw.text.split(args.suggestns, ',', true)) do
            if not mw.site.namespaces(tonumber(v)) then
                err = err .. 'Invalid namespace(s) detected in suggestns<br />'
                break
            end
        end
        
        conf:wikitext('suggestns = ' .. args.suggestns)
    end
    
    local i = 1
    while true do
        if hascontent(args['param' .. i]) then
            process_param(args, conf, i)
        elseif hascontent(args['field' .. i]) then
            process_field(args, conf, i)
        else
            break
        end
        i = i + 1
    end
    
    local outtype = defto(args.outputtype, 'none')
    local out
    if outtype == 'none' or outtype == '0' then
        out = ''
    elseif outtype == 'basic' or outtype == '1'  then
        out = '\n\n<div id="'..form..'">'..p._jsnotice(args)..'</div>\n<div id="'..result..'">'..p._resnotice(args)..'</div>'
    elseif outtype == 'verticaltable' then
        out = makeVTable(args, form, result)
    elseif outtype == 'horizontaltable' then
        out = makeHTable(args, form, result)
    end
    
    if err ~= '' then
        err = '<span class="error">' .. "'''Minor error(s) found in form definition:'''<br />" .. err .. '</span>'
    end
    
    return tostring(conf) .. tostring(err) .. tostring(out) .. tostring(cat)
end

return p

-- </nowiki>