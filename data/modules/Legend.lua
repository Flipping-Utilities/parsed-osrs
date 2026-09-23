local p = {}

function p.main(frame)
    local args = frame:getParent().args
    local backgroundColor = args[1] or 'transparent'
    local text = args.text or ''
    local caption = args.caption or ''
    
    local container = mw.html.create('div')
        :css({
        	['display'] = 'inline-flex',
        	['align-items'] = 'center',
        	['page-break-inside'] = 'avoid',
        	['break-inside'] = 'avoid-column',
        	['margin-top'] = '0.2em'
        })
    
    local colorBox = container:tag('span')
        :css({
			['background-color'] = backgroundColor or 'transparent',
			['min-width'] = text ~= '' and 'auto' or '1.25em',
            ['height'] = text ~= '' and 'auto' or '1.25em',
            ['display'] = 'inline-flex',
            ['justify-content'] = 'center',
            ['align-items'] = 'center',
            ['padding'] = text ~= '' and '0.2em 0.2em' or '0',
            ['border'] = '1px solid var(--body-dark)',
            ['margin-right'] = '0.5em',
        })
        :wikitext(text)
    
    container:tag('span')
        :wikitext(caption)
    
    return tostring(container)
end

return p