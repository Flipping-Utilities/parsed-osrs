local p = {}

local string = string
local commas = require('Module:Addcommas')._add
local dropsLine = require('Module:DropsLine')

function p.main(frame)
	local args = frame:getParent().args
	local type = args.type
	local rarity = args.rarity
	local altrarity = args.altrarity
	local altraritydash = args.altraritydash
	local raritynotes = args.raritynotes ~= nil and args.raritynotes ~= '' and args.raritynotes or nil
	local f2p = args.f2p ~= nil and args.f2p ~= '' and frame:expandTemplate{ title='(m)' } or nil
	local skill = args.skill ~= nil and args.skill ~= '' and args.skill or nil
	local reward = args.reward ~= nil and args.reward ~= '' and args.reward or nil
	local noteoverride = args.noteoverride ~= nil and args.noteoverride ~= '' and args.noteoverride or nil
	local approx = args.approx ~=nil and args.approx ~= '' and args.approx or nil
	local bucketarg = args.bucket
	
	local dtype = 'combat'
	if skill ~= nil then
		dtype = string.lower(skill)
	elseif reward ~= nil then
		dtype = 'reward'
	end
	
	local adjusted = getAdjustedRarity(rarity, altrarity)
	local ret = mw.html.create('tr')
	local altnote = altrarity ~= nil and adjusted ~= nil and string.format('%s%s', altraritydash ~= nil and '–' or '; ', adjusted.alt) or ''
	
	local note
	local refnote
	if noteoverride ~= nil then
		note = noteoverride
		local overrideFrame = frame:extensionTag{ name = 'ref', content = note, args = { group = 'd' } }
		refnote = overrideFrame
	elseif type ~= 'beginner' and adjusted ~=nil then
		note = string.format('The %s clue scroll drop rate increases to %s%s after unlocking the [[%s Combat Achievements]] rewards tier.', type, adjusted.original, altnote, type, type)
		local achievementFrame = frame:extensionTag{ name = 'ref', content = note, args = { group = 'd' } }
		refnote =  achievementFrame
	end
	
	if noteoverride == nil then
		local scrollBoxNote = string.format('Clue scrolls will drop as [[scroll box]]es after the completion of [[X Marks the Spot]].')
		local scrollBoxNoteFrame = frame:extensionTag{ name = 'ref', content = scrollBoxNote, args = { name = 'box', group = 'd' }}
		if refnote == nil then
			refnote = scrollBoxNoteFrame
		else
			refnote = refnote .. scrollBoxNoteFrame
		end
	end
	
	if raritynotes ~= nil then
		if refnote == nil then
			refnote = raritynotes
		else
			refnote = refnote .. raritynotes
		end
	end
	local dropsLine_args = {
		name = string.format('Clue scroll (%s)', type),
		quantity = '1',
		rarity = rarity,
		altrarity = altrarity,
		altraritydash = altraritydash,
		raritynotes = refnote,
		citation = args.citation,
		namenotes = f2p,
		gemw = 'no',
		bucketarg = bucketarg,
		approx = approx
	}
	local dropsLine_frameArgs = {
		dtype = dtype,
	}
	return dropsLine._main(dropsLine_args, dropsLine_frameArgs)
end

function getAdjustedRarity(rarity, altrarity)
	local modifier = 0.05
	local rv1, rv2 = string.match(rarity, '([%d%.]+)/([%d%.]+)')
	--Return early if rarity is "Always", "Rare", etc.
	if tonumber(rv1) == nil or tonumber(rv2) == nil then
		return nil
	end
	local arv1, arv2
	local adjustedrarity, adjustedaltrarity
	if altrarity then
		arv1, arv2 = string.match(altrarity, '([%d%.]+)/([%d%.]+)')
		if tonumber(arv1) > 1 then
			local reduced = arv2 / arv1
			adjustedaltrarity = string.format('%s/%s', 1, commas(math.floor((reduced - (reduced * modifier)))))
		else
			adjustedaltrarity = string.format('%s/%s', arv1, commas(math.floor((arv2 - (arv2 * modifier)))))
		end
	end
	
	if tonumber(rv1) > 1 then
		local reduced = rv2 / rv1
		adjustedrarity = string.format('%s/%s', 1, commas(math.floor((reduced - (reduced * modifier)))))
	else
		adjustedrarity = string.format('%s/%s', rv1, commas(math.floor((rv2 - (rv2 * modifier)))))
	end
	
	return { original = adjustedrarity, alt = adjustedaltrarity }
end

return p