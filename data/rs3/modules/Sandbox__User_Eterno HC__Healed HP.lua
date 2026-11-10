local p = {}

function p.main(frame)
	local args = frame.args
	local base_heal = args.base_heal or args[1]
	local hp_percent_heal = args.hp_percent_heal or args[2]
	local hp = args.hp or args[3]

	if not hp or hp == '' then
		return '<span class="error">No HP value provided.</span>'
	end
	if not base_heal or base_heal == '' then
		return '<span class="error">No base heal value provided.</span>'
	end
	if not hp_percent_heal or hp_percent_heal == '' then
		return '<span class="error">No HP percent value provided.</span>'
	end

	base_heal = tonumber(base_heal)
	hp_percent_heal = tonumber(hp_percent_heal)
	hp = tonumber(hp)
	
	local healed_hp = base_heal + (hp * (hp_percent_heal/100))
	local powerburst_healed_hp = base_heal + ((hp * 2) * (hp_percent_heal/100))

	return (
		'<span> With ' .. tostring(hp) .. ' HP, this heals </span><br>' ..
		'<span> &emsp; Base: <b>' .. tostring(healed_hp) .. ' HP</b></span><br>' ..
		'<span> &emsp; With Powerburst of Vitality: <b>' .. tostring(powerburst_healed_hp) .. ' HP</b></span>' 
	)
end

return p