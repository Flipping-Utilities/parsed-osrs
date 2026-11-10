local p = {}

p.data = {
	['creatures of daemonheim'] = 'Creatures of Daemonheim',
	['greater demon berserkers and ash lords'] = 'Greater demon berserkers and ash lords',
	['zemouregal\'s undead'] = 'Zemouregal\'s undead'
}

function p.disambig(name, do_link)
	local _name = name
	_name = string.lower(_name)
	_name = string.gsub(_name, ' %(slayer assignment%)', '')
	if do_link then
		local link_text = name
		local link_href
		if p.data[_name] then
			link_href = p.data[_name]
		else
			link_href = name .. ' (Slayer assignment)'
		end
		return string.format('[[%s|%s]]', link_href, link_text)
	else
		if p.data[_name] then
			return p.data[_name]
		else
			return name
		end
	end
end

return p