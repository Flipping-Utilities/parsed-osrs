require('Module:Mw.html extension')
local slayer_assignments = require('Module:Slayer_assignments')

local slayerMasters = {
	['Turael'] = { chathead = 'turael chathead', link = 'Turael'},
	['Jacquelyn'] = { chathead = 'jacquelyn chathead', link  = 'Jacquelyn'},
	['Mazchna'] = { chathead = 'mazchna chathead', link = 'Mazchna'},
	['Vannaka'] = { chathead = 'vannaka chathead', link = 'Vannaka'},
	['Chaeldar'] = { chathead = 'chaeldar chathead', link = 'Chaeldar'},
	['Sumona'] = { chathead = 'sumona chathead', link = 'Sumona'},
	['Duradel'] = { chathead = 'duradel chathead', link = 'Duradel'},
	['Kuradal'] = { chathead = 'kuradal chathead', link = 'Kuradal'},
	['Morvran'] = { chathead = 'morvran chathead', link = 'Morvran'},
	['Mandrith'] = { chathead = 'mandrith chathead', link = 'Mandrith'},
	['Laniakea'] = { chathead = 'laniakea chathead', link = 'Laniakea'},
	['Raptor'] = { chathead = 'the Raptor chathead', link = 'The Raptor'},
}

local slayerMastersOrder = {
	'Turael',
	'Jacquelyn',
	'Raptor',
	'Vannaka',
	'Mazchna',
	'Chaeldar',
	'Sumona',
	'Duradel',
	'Kuradal',
	'Morvran',
	'Laniakea',
	'Mandrith',
}

local combat_level = '[[File:Combat swords.png|24px|link=Combat level]]'
local slayerSCP = '[[File:Slayer.png|24px|link=Slayer]]'

local p = {}

local noAssigners = mw.html.create('table')
	:addClass('wikitable')
	:tr()
		:td('This category is not currently assigned by any Slayer Master.')
	:allDone()

function p.main(frame)
    local args = frame.args
    local cat = args[1]

    local t = mw.html.create('table')
    :addClass('wikitable align-center-2')
    :tr()
        :th('Master')
        :th('Task amounts')
        :th('Unlock requirements')
        :th('Weighting')

    count = 0

    for _,master in ipairs(slayerMastersOrder) do
        local task_size = slayer_assignments.getAmounts(master,cat)
        local weight = slayer_assignments.getWeight(master,cat)
        local reqs = slayer_assignments.getReqs(master,cat)

        local reqs_string = p.format_unlock_reqs(reqs)

        if next(task_size) ~= nil then
            count = count + 1
            t:tr()
                :td(string.format('[[File:%s.png|30px|link=%s]]',slayerMasters[master].chathead,slayerMasters[master].link)..' [['..slayerMasters[master].link..']]')
                :td(p.format_task_size(task_size))
                :td(reqs_string)
                :td(weight)
        end
    end

    if count == 0 then
        return noAssigners
    end

    return t:allDone()
end

function p.format_task_size(task_size)
	return (task_size['min']..'-'..task_size['max'])
end

function p.format_unlock_reqs(reqs)
	
	local ret = ''
	local comma = ''
	
	if reqs.combat ~= nil then
		if reqs.combat ~= 0 then
			ret = ret .. combat_level .. ' ' .. reqs.combat
		end
	end
	if reqs.slayer ~= nil then
		if reqs.slayer ~= 0 then
			if ret ~= '' then
				comma = ','
			end
				
			ret = ret .. comma .. ' ' .. slayerSCP .. ' ' .. reqs.slayer
		end
	end
	if reqs.other ~= nil then
		if ret ~= '' then
				comma = ','
		end
		ret = ret .. comma .. ' ' .. reqs.other
	end
	
	if ret == '' then
		ret = 'None'
	end
			
	return ret
end

return p