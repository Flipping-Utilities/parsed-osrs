-- <nowiki>
--------------------------
-- Module for [[Template:Infobox Credits]]
------------------------
local p = {}

-- "imports"
local onmain = require('Module:Mainonly').on_main
local infobox = require('Module:Infobox')

local TH_COLSPAN = 4
local TD_COLSPAN = 7
local FULL_COLSPAN = TH_COLSPAN + TD_COLSPAN

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	ret:defineParams{
		{ name = 'name', func = 'name' },
		
		-- Developers
		{ name = 'developer', func = 'has_content' }, -- Developer
		{ name = 'design', func = 'has_content' }, -- Design
		{ name = 'designreview', func = 'has_content' }, -- Design review
		{ name = 'writing', func = 'has_content' }, -- Writing
		{ name = 'editing', func = 'has_content' }, -- Editing
		{ name = 'codereview', func = 'has_content' }, -- Code review
		{ name = 'conversion', func = 'has_content' }, -- Conversion
		{ name = 'techsupport', func = 'has_content' }, -- Technical Support
		{ name = 'engine', func = 'has_content' }, -- Engine
		{ name = 'bugfixes', func = 'has_content' }, -- Bug Fixes
		{ name = 'devother', func = { name = parseCredit, params = { 'devother' } } }, -- Custom
		
		-- Graphics
		{ name = 'artdirector', func = 'has_content' }, -- Art Director
		{ name = 'ui', func = 'has_content' }, -- UI
		{ name = 'characters', func = 'has_content' }, -- Characters
		{ name = 'environment', func = 'has_content' }, -- Environments
		{ name = 'animation', func = 'has_content' }, -- Animation
		{ name = 'graphics', func = 'has_content' }, -- Graphics
		{ name = 'concept', func = 'has_content' }, -- Concept
		{ name = 'modelling', func = 'has_content' }, -- Modelling
		{ name = 'graphicsother', func = { name = parseCredit, params = { 'graphicsother' } } }, -- Custom
		
		-- QA
		{ name = 'qahead', func = 'has_content' }, -- Head of QA
		{ name = 'qalead', func = 'has_content' }, -- Lead QA
		{ name = 'coretest', func = 'has_content' }, -- Core
		{ name = 'releasetest', func = 'has_content' }, -- Release
		{ name = 'qa', func = 'has_content' }, -- Quality assurance
		{ name = 'qaother', func = { name = parseCredit, params = { 'qaother' } } }, -- Custom
		
		-- Audio
		{ name = 'composition', func = 'has_content' }, -- Composition
		{ name = 'voiceacting', func = 'has_content' }, -- Voice Acting
		{ name = 'audio', func = 'has_content' }, -- Audio
		{ name = 'audioother', func = { name = parseCredit, params = { 'audioother' } } }, -- Custom
		
		-- Localisation
		{ name = 'german', func = 'has_content' }, -- German
		{ name = 'french', func = 'has_content' }, -- French
		{ name = 'ptbr', func = 'has_content' }, -- Brazilian-Portuguese
		{ name = 'locother', func = { name = parseCredit, params = { 'locother' } } }, -- Custom
		
		-- Other
		{ name = 'walkthrough', func = 'has_content' }, -- Walkthrough
		{ name = 'questhelp', func = 'has_content' }, -- Quest Help
		{ name = 'wiki', func = 'has_content' }, -- Wiki
		{ name = 'knowledgebase', func = 'has_content' }, -- Knowledge Base
		{ name = 'other', func = { name = parseCredit, params = { 'other' } } }, -- Custom
	}

	ret:setMaxButtons(4)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)
	
	ret:defineLinks({ hide = true })

	ret:defineName('Infobox Credits')
	ret:addClass('infobox-credits left-info')
	ret:css( 'width', '450px' )

	ret:addButtonsCaption()

	-- PARAMETER: name
	ret:addRow{
		{ tag = 'argh', content = 'name', colspan = FULL_COLSPAN, class = 'infobox-header' }
	}

	-- Developers header
	if ret:paramDefined('developer') or ret:paramDefined('design') or ret:paramDefined('designreview') or ret:paramDefined('writing') or ret:paramDefined('editing') or ret:paramDefined('codereview') or 
	ret:paramDefined('conversion') or ret:paramDefined('techsupport') or ret:paramDefined('engine') or ret:paramDefined('bugfixes') or ret:paramDefined('devother') then
		ret:addRow{
			{ tag = 'th', content = 'Developers', colspan = FULL_COLSPAN, class = 'infobox-subheader' }
		}
		ret:pad(FULL_COLSPAN)
	end

	-- PARAMETER: developer
	if ret:paramDefined('developer') then
		ret:addRow{
			{ tag = 'th', content = 'Developer', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'developer', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: design
	if ret:paramDefined('design') then
		ret:addRow{
			{ tag = 'th', content = 'Design', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'design', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: designreview
	if ret:paramDefined('designreview') then
		ret:addRow{
			{ tag = 'th', content = 'Design review', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'designreview', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: writing
	if ret:paramDefined('writing') then
		ret:addRow{
			{ tag = 'th', content = 'Writing', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'writing', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: editing
	if ret:paramDefined('editing') then
		ret:addRow{
			{ tag = 'th', content = 'Editing', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'editing', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: codereview
	if ret:paramDefined('codereview') then
		ret:addRow{
			{ tag = 'th', content = 'Code review', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'codereview', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: conversion
	if ret:paramDefined('conversion') then
		ret:addRow{
			{ tag = 'th', content = 'Conversion', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'conversion', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: techsupport
	if ret:paramDefined('techsupport') then
		ret:addRow{
			{ tag = 'th', content = 'Technical support', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'techsupport', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: engine
	if ret:paramDefined('engine') then
		ret:addRow{
			{ tag = 'th', content = 'Engine', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'engine', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: devother
	if ret:paramDefined('devother') then
		for k, v in pairs(ret:param('devother')) do
			ret:addRow{
				{ tag = 'th', content = v['role'], colspan = TH_COLSPAN },
				{ tag = 'td', content = v['credit'], colspan = TD_COLSPAN }
			}
		end
	end
	
	-- Graphics header
	if ret:paramDefined('artdirector') or ret:paramDefined('ui') or ret:paramDefined('characters') or ret:paramDefined('environment') or ret:paramDefined('animation') or 
	ret:paramDefined('graphics') or ret:paramDefined('concept') or ret:paramDefined('modelling') or ret:paramDefined('graphicsother') then
		ret:pad(FULL_COLSPAN)
		ret:addRow{
			{ tag = 'th', content = 'Art and graphics', colspan = FULL_COLSPAN, class = 'infobox-subheader' }
		}
		ret:pad(FULL_COLSPAN)
	end
	
	-- PARAMETER: artdirector
	if ret:paramDefined('artdirector') then
		ret:addRow{
			{ tag = 'th', content = 'Art director', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'artdirector', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: ui
	if ret:paramDefined('ui') then
		ret:addRow{
			{ tag = 'th', content = 'UI', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'ui', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: characters
	if ret:paramDefined('characters') then
		ret:addRow{
			{ tag = 'th', content = 'Characters', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'characters', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: environment
	if ret:paramDefined('environment') then
		ret:addRow{
			{ tag = 'th', content = 'Environments', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'environment', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: animation
	if ret:paramDefined('animation') then
		ret:addRow{
			{ tag = 'th', content = 'Animation', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'animation', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: graphics
	if ret:paramDefined('graphics') then
		ret:addRow{
			{ tag = 'th', content = 'Graphics', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'graphics', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: concept
	if ret:paramDefined('concept') then
		ret:addRow{
			{ tag = 'th', content = 'Concept', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'concept', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: modelling
	if ret:paramDefined('modelling') then
		ret:addRow{
			{ tag = 'th', content = 'Modelling', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'modelling', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: graphicsother
	if ret:paramDefined('graphicsother') then
		for k, v in pairs(ret:param('graphicsother')) do
			ret:addRow{
				{ tag = 'th', content = v['role'], colspan = TH_COLSPAN },
				{ tag = 'td', content = v['credit'], colspan = TD_COLSPAN }
			}
		end
	end
	
	-- Quality Assurance header
	if ret:paramDefined('qahead') or ret:paramDefined('qalead') or ret:paramDefined('coretest') or ret:paramDefined('releasetest') or ret:paramDefined('qa') or ret:paramDefined('qaother') then
		ret:pad(FULL_COLSPAN)
		ret:addRow{
			{ tag = 'th', content = 'Quality assurance', colspan = FULL_COLSPAN, class = { 'infobox-subheader' } }
		}
		ret:pad(FULL_COLSPAN)
	end
	
	-- PARAMETER: qahead
	if ret:paramDefined('qahead') then
		ret:addRow{
			{ tag = 'th', content = 'Head of QA', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'qahead', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: qalead
	if ret:paramDefined('qalead') then
		ret:addRow{
			{ tag = 'th', content = 'Lead QA', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'qalead', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: coretest
	if ret:paramDefined('coretest') then
		ret:addRow{
			{ tag = 'th', content = 'Core', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'coretest', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: releasetest
	if ret:paramDefined('releasetest') then
		ret:addRow{
			{ tag = 'th', content = 'Release', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'releasetest', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: leadtest
	if ret:paramDefined('leadtest') then
		ret:addRow{
			{ tag = 'th', content = 'Lead tester', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'leadtest', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: qa
	if ret:paramDefined('qa') then
		ret:addRow{
			{ tag = 'th', content = 'Quality assurance', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'qa', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: qaother
	if ret:paramDefined('qaother') then
		for k, v in pairs(ret:param('qaother')) do
			ret:addRow{
				{ tag = 'th', content = v['role'], colspan = TH_COLSPAN },
				{ tag = 'td', content = v['credit'], colspan = TD_COLSPAN }
			}
		end
	end
	
	-- Audio header
	if ret:paramDefined('composition') or ret:paramDefined('voiceacting') or ret:paramDefined('audio') or ret:paramDefined('audioother') then
		ret:pad(FULL_COLSPAN)
		ret:addRow{
			{ tag = 'th', content = 'Audio', colspan = FULL_COLSPAN, class = 'infobox-subheader' }
		}
		ret:pad(FULL_COLSPAN)
	end
	
	-- PARAMETER: composition
	if ret:paramDefined('composition') then
		ret:addRow{
			{ tag = 'th', content = 'Composition', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'composition', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: voiceacting
	if ret:paramDefined('voiceacting') then
		ret:addRow{
			{ tag = 'th', content = 'Voice acting', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'voiceacting', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: audio
	if ret:paramDefined('audio') then
		ret:addRow{
			{ tag = 'th', content = 'Audio', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'audio', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: audioother
	if ret:paramDefined('audioother') then
		for k, v in pairs(ret:param('audioother')) do
			ret:addRow{
				{ tag = 'th', content = v['role'], colspan = TH_COLSPAN },
				{ tag = 'td', content = v['credit'], colspan = TD_COLSPAN }
			}
		end
	end
	
	-- Localisation header
	if ret:paramDefined('german') or ret:paramDefined('french') or ret:paramDefined('ptbr') or ret:paramDefined('locother') then
		ret:pad(FULL_COLSPAN)
		ret:addRow{
			{ tag = 'th', content = 'Localisation', colspan = FULL_COLSPAN, class = 'infobox-subheader' }
		}
		ret:pad(FULL_COLSPAN)
	end
	
	-- PARAMETER: german
	if ret:paramDefined('german') then
		ret:addRow{
			{ tag = 'th', content = 'German', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'german', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: french
	if ret:paramDefined('french') then
		ret:addRow{
			{ tag = 'th', content = 'French', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'french', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: ptbr
	if ret:paramDefined('ptbr') then
		ret:addRow{
			{ tag = 'th', content = 'Brazilian-<br />Portuguese', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'ptbr', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: locother
	if ret:paramDefined('locother') then
		for k, v in pairs(ret:param('locother')) do
			ret:addRow{
				{ tag = 'th', content = v['role'], colspan = TH_COLSPAN },
				{ tag = 'td', content = v['credit'], colspan = TD_COLSPAN }
			}
		end
	end
	
	-- Other header
	if ret:paramDefined('walkthrough') or ret:paramDefined('questhelp') or ret:paramDefined('wiki') or ret:paramDefined('knowledgebase') or ret:paramDefined('other') then
		ret:pad(FULL_COLSPAN)
		ret:addRow{
			{ tag = 'th', content = 'Other', colspan = FULL_COLSPAN, class = 'infobox-subheader' }
		}
		ret:pad(FULL_COLSPAN)
	end
	
	-- PARAMETER: walkthrough
	if ret:paramDefined('walkthrough') then
		ret:addRow{
			{ tag = 'th', content = 'Walkthrough', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'walkthrough', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: questhelp
	if ret:paramDefined('questhelp') then
		ret:addRow{
			{ tag = 'th', content = 'Quest help', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'questhelp', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: wiki
	if ret:paramDefined('wiki') then
		ret:addRow{
			{ tag = 'th', content = 'Wiki', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'wiki', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: knowledgebase
	if ret:paramDefined('knowledgebase') then
		ret:addRow{
			{ tag = 'th', content = 'Knowledge Base', colspan = TH_COLSPAN },
			{ tag = 'argd', content = 'knowledgebase', colspan = TD_COLSPAN }
		}
	end
	
	-- PARAMETER: other
	if ret:paramDefined('other') then
		for k, v in pairs(ret:param('other')) do
			ret:addRow{
				{ tag = 'th', content = v['role'], colspan = TH_COLSPAN },
				{ tag = 'td', content = v['credit'], colspan = TD_COLSPAN }
			}
		end
	end
	ret:pad(FULL_COLSPAN)
	
	ret:finish()
	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function parseCredit(str)
	local ret = {}
	for u in mw.text.gsplit(str, '%s*;%s*') do
		local v = mw.text.split(u, '%s*:%s*')
		local role = v[1]
		local credit = v[2]
		if role and credit then
			table.insert(ret, { ['role'] = role, ['credit'] = credit })
		end
	end
	return ret
end

function addcategories(args, catargs)
	function is_def(x, y)
		y = y or 'd'
		if infobox.isDefined(x) then
			return infobox.isDefined(x[y])
		end
		return false
	end
	
	local ret = {}
	
	local cat_map = {
		-- Added if the parameter has content
		defined = {
		},
		-- Added if the parameter has no content
		notdefined = {
		},
	}
	
	-- Run and add mapped categories
	for n, v in pairs(cat_map.defined) do
		if catargs[n] and catargs[n].one_defined then
			table.insert(ret,v)
		end
	end
	for n, v in pairs(cat_map.notdefined) do
		if catargs[n] and catargs[n].all_defined == false then
			table.insert(ret,v)
		end
	end
	
	-- combine table and format category wikicode
	for i, v in ipairs(ret) do
		if (v ~= '') then
			ret[i] = string.format('[[Category:%s]]', v)
		end
	end

	return table.concat(ret, '')
end

return p
-- </nowiki>