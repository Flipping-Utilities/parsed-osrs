--------------------------
-- Module for [[Template:Infobox Person]]
--------------------------
local p = {}

-- "imports"
local onmain = require('Module:Mainonly').on_main
local yesno = require('Module:Yesno')
local paramtest = require('Module:Paramtest')
local infobox = require('Module:Infobox')
local cleanimg = require('Module:Clean image').clean
local editbutton = require('Module:Edit button')
local edit = editbutton("'''?''' (edit)")

local team_map = {
	admin = { link = '[[Leadership Team|Leadership]]', cat = 'Leadership Team' },
	adse = { link = '[[Analytics, Data Science, and Engineering Team|Analytics, Data Science, and Engineering]]', cat = 'Analytics, Data Science, and Engineering Team' },
	artist = { link = '[[Art & Graphics Team|Art & Graphics]]', cat = 'Art and Graphics Team' },
	audio = { link = '[[Audio Team|Audio]]', cat = 'Audio Team' },
	cdev = { link = '[[Content Development Team|Content Development]]', cat = 'Content Development Team' },
	cm = { link = '[[Community Management Team|Community Management]]', cat = 'Community Management Team' },
	ct = { link = '[[Central Technology Team|Central Technology]]', cat = 'Central Technology Team' },
	edev = { link = '[[Engine Development Team|Engine Development]]', cat = 'Engine Development Team' },
	extd = { link = 'External Development', cat = '' },
	design = { link = '[[Game Design Team|Game Design]]', cat = 'Game Design Team' },
	et = { link = '[[Episodic Team|Episodic]]', cat = 'Episodic Team' },
	infra = { link = '[[Infrastructure Team|Infrastructure]]', cat = 'Infrastructure Team' },
	it = { link = '[[Corporate IT Team|Corporate IT]]', cat = 'Corporate IT Team' },
	le = { link = '[[Live Events Team|Live Events]]', cat = 'Live Events Team' },
	loc = { link = '[[Localisation Team|Localisation]]', cat = 'Localisation Team' },
	mkt = { link = '[[Marketing Team|Marketing]]', cat = 'Marketing Team' },
	ninja = { link = '[[Ninja Team|Ninja]]', cat = 'Ninja Team' },
	plugin = { link = '[[Plugin Support Team|Plugin Support]]', cat = 'Plugin Support Team' },
	qa = { link = '[[Quality Assurance Team|Quality Assurance]]', cat = 'Quality Assurance Team' },
	sm = { link = '[[Social Media Team|Social Media]]', cat = 'Social Media Team' },
	support = { link = '[[Player Support Team|Player Support]]', cat = 'Player Support Team' },
	system = { link = '[[System Engineering Team|System Engineering]]', cat = 'System Engineering Team' },
	video = { link = '[[Video Team|Video]]', cat = 'Video Team' },
	web = { link = '[[Web Team|Web]]', cat = 'Web Team' },

    -- primarily for Mod North
    ['strategy & m&a'] = { link = 'Strategy & M&A' },

	_aliases = {
		art = "artist",
		composers = "audio",
		cs = "support",
		engine = "edev",
		ps = "support",
		service = "support",
	},
}

local project_map = {
	ummo = { link = 'Unannounced MMO', cat = 'Unannounced MMO employees' },
	chronicle = { link = '<i>[[Chronicle: RuneScape Legends]]</i>', cat = 'Chronicle employees' },
	rs = { link = '<i>[[RuneScape]]</i>', cat = 'RuneScape employees' },
	osrs = { link = '<i>[[Old School RuneScape]]</i>', cat = 'Old School RuneScape employees' },
	mobile = { link = '<i>[[RuneScape Mobile]]</i>', cat = 'RuneScape Mobile employees' },
	tu = { link = '<i>[[Jagex#Transformers Universe|Transformers Universe]]</i>', cat = 'Transformers Universe employees' },
	sd = { link = '<i>[[Jagex#MechScape and Stellar Dawn|Stellar Dawn]]</i>', cat = 'Stellar Dawn employees' },
	bnl = { link = '<i>[[Jagex#Block N Load|Block N Load]]</i>', cat = 'Block N Load employees' },
	wol = { link = '<i>[[Jagex#War of Legends|War of Legends]]</i>', cat = 'War of Legends employees' },
	fo = { link = '<i>[[Jagex#FunOrb|FunOrb]]</i>', cat = 'FunOrb employees' },
	vh = { link = '<i>Void Hunters</i>', cat = 'Void Hunters employees' },
	er = { link = '<i>8Realms</i>', cat = '8Realms employees' },
	ia = { link = '<i>[[RuneScape Idle Adventures|RuneScape: Idle Adventures]]</i>', cat = 'RuneScape Idle Adventures employees' },
	ht = { link = '<i>[[Jagex#Herotopia|Herotopia]]</i>', cat = 'Herotopia employees' },
	dw = { link = '<i>[[RuneScape - Dragonwilds|RuneScape: Dragonwilds]]</i>', cat = 'RuneScape: Dragonwilds employees' };

    -- primarily for Mod North
    corporate = { link = 'Corporate' }
}

local region_map = {
	french = 'French Localisation Team',
	german = 'German Localisation Team',
	ptbr = 'Portuguese-Brazilian Localisation Team',
	spanish = 'Spanish Localisation Team',
}

function p.main(frame)
	local args = frame:getParent().args
	local ret = infobox.new(args)

	ret:defineParams{
		{ name = 'name', func = 'name' },
		{ name = 'image', func = imgarg },
		{ name = 'occupation', func = 'has_content' },
		{ name = 'website', func = 'has_content' },
		{ name = 'jagex', func = { name = isJagex, params = { 'jagex' }, flag = { 'd' } } },
		{ name = 'role', func = 'has_content' },
		{ name = 'team', func = 'has_content' },
		{ name = 'team_links', func = { name = lookupmultiarg, params = { team_map, 'team', 'link' }, flag = { 'r', 'd', 'r' } } },
		{ name = 'region', func = 'has_content' },
		{ name = 'project', func = 'has_content' },
		{ name = 'project_links', func = { name = lookupmultiarg, params = { project_map, 'project', 'link' }, flag = { 'r', 'd', 'r' } } },
		{ name = 'employed', func = 'has_content' },
		{ name = 'left', func = 'has_content' },
		{ name = 'employment_dates', func = { name = employmentDates, params = { 'employed', 'left' }, flag = { 'd', 'd' } } },
		{ name = 'twitter', func = { name = twitter, params = { 'twitter' }, flag = { 'd' } } },
		{ name = 'reddit', func = { name = reddit, params = { 'reddit' }, flag = { 'd' } } },
		{ name = 'artstation', func = { name = artstation, params = { 'artstation' }, flag = { 'd' } } },
		{ name = 'sketchfab', func = { name = sketchfab, params = { 'sketchfab' }, flag = { 'd' } } },
		{ name = 'artgram', func = { name = artgram, params = { 'artgram' }, flag = { 'd' } } },
		{ name = 'twitch', func = { name = twitch, params = { 'twitch' }, flag = { 'd' } } },
		{ name = 'has_social', func = { name = hasSocial, params = { 'twitter', 'reddit', 'artstation', 'sketchfab', 'artgram', 'twitch' }, flag = { 'd', 'd', 'd', 'd', 'd' } } },
		{ name = 'bucketarg', func = { name = bucketarg, params = {
				'name', 'image', 'jagex', 'role', 'team', 'region', 'project', 'employed', 'left', 'employment_dates'
			}, flag = 'd' } }
	}

	ret:useBucket('infobox_person', {
		bucketarg = 'json',
	})

	ret:setMaxButtons(4)
	ret:create()
	ret:cleanParams()
	ret:customButtonPlacement(true)
	
	ret:defineLinks()

	ret:defineName('Infobox Person')
	ret:addClass('infobox-person')

	ret:addButtonsCaption()

	-- PARAMETER: name
	if ret:paramGrep('jagex', true) then
		ret:addRow{
			{ tag = 'th', content = '[[File:Jagex moderator crown.png|link=]] '..name(ret:param('name')), class='infobox-header', colspan = '20' }
		}
	else
		ret:addRow{
			{ tag = 'argh', content = 'name', class='infobox-header', colspan = '20' }
		}
	end

	-- PARAMETER: image
	ret:addRow{
		{ tag = 'argd', content = 'image', class = 'infobox-image infobox-full-width-content', colspan = '20' }
	}
	:pad(20)

	-- PARAMETER: occupation
	if ret:paramDefined('occupation') then
		ret:addRow{
			{ tag = 'th', content = 'Occupation', colspan = '8' },
			{ tag = 'argd', content = 'occupation', colspan = '12' }
		}
	end
	
	-- PARAMETER: website
	if ret:paramDefined('website') then
		ret:addRow{
			{ tag = 'th', content = 'Website', colspan = '8' },
			{ tag = 'argd', content = 'website', colspan = '12' }
		}
	end

	if ret:paramGrep('jagex', true) then
		ret:pad(20)
		:addRow{
			{ tag = 'th', content = 'Jagex', class='infobox-subheader', colspan = '20' }
		}
		:pad(20)
		
		-- PARAMETER: role
		ret:addRow{
			{ tag = 'th', content = 'Role', colspan = '8' },
			{ tag = 'argd', content = 'role', colspan = '12' }
		}
		
		-- PARAMETER: team
		ret:addRow{
			{ tag = 'th', content = 'Team', colspan = '8' },
			{ tag = 'argd', content = 'team_links', colspan = '12' }
		}
		
		-- PARAMETER: project
		ret:addRow{
			{ tag = 'th', content = 'Project', colspan = '8' },
			{ tag = 'argd', content = 'project_links', colspan = '12' }
		}
		
		-- PARAMETER: employment_dates
		ret:addRow{
			{ tag = 'th', content = 'Employed', colspan = '8' },
			{ tag = 'argd', content = 'employment_dates', colspan = '12' }
		}
	end
	
	if ret:paramGrep('has_social', true) then
		ret:pad(20)
		:addRow{
			{ tag = 'th', content = 'Social', class='infobox-subheader', colspan = '20' }
		}
		:pad(20)
		
		-- PARAMETER: twitter
		if ret:paramDefined('twitter') then
			ret:addRow{
				{ tag = 'th', content = 'X', colspan = '8' },
				{ tag = 'argd', content = 'twitter', colspan = '12' }
			}
		end
		
		-- PARAMETER: reddit
		if ret:paramDefined('reddit') then
			ret:addRow{
				{ tag = 'th', content = 'Reddit', colspan = '8' },
				{ tag = 'argd', content = 'reddit', colspan = '12' }
			}
		end
		
		-- PARAMETER: artstation
		if ret:paramDefined('artstation') then
			ret:addRow{
				{ tag = 'th', content = 'ArtStation', colspan = '8' },
				{ tag = 'argd', content = 'artstation', colspan = '12' }
			}
		end
		
		-- PARAMETER: sketchfab
		if ret:paramDefined('sketchfab') then
			ret:addRow{
				{ tag = 'th', content = 'Sketchfab', colspan = '8' },
				{ tag = 'argd', content = 'sketchfab', colspan = '12' }
			}
		end
		
		-- PARAMETER: artgram
		if ret:paramDefined('artgram') then
			ret:addRow{
				{ tag = 'th', content = 'Artgram', colspan = '8' },
				{ tag = 'argd', content = 'artgram', colspan = '12' }
			}
		end
		
		-- PARAMETER: twitch
		if ret:paramDefined('twitch') then
			ret:addRow{
				{ tag = 'th', content = 'Twitch', colspan = '8' },
				{ tag = 'argd', content = 'twitch', colspan = '12' }
			}
		end
	end
	ret:pad(20)

	ret:finish()
	if onmain() then
		local a1 = ret:param('all')
		local a2 = ret:categoryData()
		ret:wikitext(addcategories(a1, a2))
	end
	return ret:tostring()
end

function p.map_doc(frame)
	local ospairs = require("Module:TableTools").ospairs
	local name = string.lower(frame.args[1] or "")
	local map
	local cat_links = false
	
	if name == "team" then
		map = team_map
	elseif name == "project" then
		map = project_map
	elseif name == "region" then
		map = region_map
		cat_links = true
	else
		error("Invalid mapping name given: '" .. name .. "'")
	end
	
	local out = {}
	for code, data in ospairs(map) do
		if code ~= "_aliases" then
			table.insert(out, string.format(
				"* <code>%s</code> - %s",
				code,
				cat_links and ("[[:Category:" .. data .. "]]") or data.link
			))
		end
	end
	
	return table.concat(out, "\n")
end

function imgarg(arg)
	if infobox.isDefined(arg) then
		return cleanimg{ file = arg, width = 300 }
	end
	return nil
end

function name(arg)
	return string.match(arg or '','%S') and arg or nil
end

function lookuparg(t, c, y)
	local arg = t[string.lower(c or '')]
	if arg then
		if y ~= nil and y ~= '' then
			return arg[y]
		else
			return arg
		end
	end
	return nil
end

function lookupmultiarg(t, c, y, r)
	r = r or false
	local out = {}
	if not infobox.isDefined(c) then
		return nil
	end
	c = string.lower(c)
	for i in mw.text.gsplit(c, ',') do
		i = mw.text.trim(i)
		local arg = t[i]
		if not arg and t._aliases and t._aliases[i] then
			arg = t[t._aliases[i]]
		end
		
		if arg then
			table.insert(out, arg[y])
		end
	end
	if #out == 0 then
		return nil
	end
	if r then
		return out
	end
	return table.concat(out, '<br>')
end

function isJagex(arg)
	if infobox.isDefined(arg) then
		if yesno(arg) then
			return true
		end
	end
	return false
end

function employmentDates(employed, left)
	if not infobox.isDefined(employed) and not infobox.isDefined(left) then
		return edit	
	end
	
	local out = {}
	local dates = getEmploymentDates(employed, left)
	local maxArgs = math.max(#dates.employed, #dates.left)
	for i = 1, maxArgs, 1 do
		local e = dates.employed[i] or 'Unknown'
		local l = dates.left[i]
		local separator = ' ─ '
		
		-- If this is the latest set of dates don't set to left to unknown
		if i == maxArgs and infobox.isDefined(e) and not infobox.isDefined(l) then
			l = ''
			separator = ''
		end
    	table.insert(out, e..separator..l )
	end
	return table.concat(out, '<br>')
end

function getEmploymentDates(employed, left)
	local out = {
		employed = {},
		left = {}
	}
	for i in mw.text.gsplit(employed, ',') do
		table.insert(out.employed, mw.text.trim(i))
	end
	for i in mw.text.gsplit(left, ',') do
		table.insert(out.left, mw.text.trim(i))
	end
	return out
end

function hasSocial(twitter, reddit, artstation, sketchfab, twitch)
	if infobox.isDefined(twitter) or infobox.isDefined(reddit) or infobox.isDefined(artstation) or infobox.isDefined(sketchfab) or infobox.isDefined(twitch) then
		return true
	end
	return false
end

function twitter(arg)
	if infobox.isDefined(arg) then
		return '[https://www.twitter.com/'..arg..' @'..arg..']'
	end
	return nil
end

function reddit(arg)
	if infobox.isDefined(arg) then
		return '[https://www.reddit.com/u/'..arg..' u/'..arg..']'
	end
	return nil
end

function artstation(arg)
	if infobox.isDefined(arg) then
		return '[https://www.artstation.com/'..arg..' '..arg..']'
	end
	return nil
end

function sketchfab(arg)
	if infobox.isDefined(arg) then
		return '[https://sketchfab.com/'..arg..' '..arg..']'
	end
	return nil
end

function artgram(arg)
	if infobox.isDefined(arg) then
		return '[https://www.artgram.co/'..arg..' '..arg..']'
	end
	return nil
end

function twitch(arg)
	if infobox.isDefined(arg) then
		return '[https://www.twitch.tv/'..arg..' '..arg..']'
	end
	return nil
end

function cleanDate(val)
	val = mw.text.killMarkers(val)
	val = string.gsub(val, '[%[%]]', '')
	return val
end

-- bucket JSON
function bucketarg(name, image, jagex, role, team, region, project, employed, left, employment_dates)
	local toJSON = {
		name = name,
		image = image,
		jagex = string.lower(tostring(jagex) or ''),
		role = mw.text.killMarkers(role),
		team = string.lower(tostring(team) or ''),
		region = string.lower(tostring(region) or ''),
		project = string.lower(tostring(project) or ''),
		employment_dates = mw.text.killMarkers(employment_dates),
		employed = cleanDate(employed),
		left = cleanDate(left)
	}
	for k,v in pairs(toJSON) do
		if v == '' or (type(v) == 'string' and string.find(v,'action=edit')) then
			toJSON[k] = nil
		end
	end
	--mw.logObject(toJSON)
	return mw.text.jsonEncode(toJSON)
end

function addcategories(args, catargs)
	local ret = { 'People' }
	
	local cat_map = {
		-- Added if the parameter has content
		defined = {
			twitter = 'People with a Twitter handle',
			reddit = 'People with a Reddit handle',
			artstation = 'People with an ArtStation handle',
			sketchfab = 'People with a Sketchfab handle',
			artgram = 'People with an Artgram handle',
		},
		-- Added if the parameter has no content
		notdefined = {
			image = 'Needs person image',
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
	
	local title = string.gsub( mw.title.getCurrentTitle().fullText, 'Mod ', '')
	
	-- Add the associated team category if matched
	if args['team'] then
		local cats = lookupmultiarg(team_map, args['team'].d, 'cat', true)
		if cats then
			for _, v in pairs(cats) do
				if v == team_map['loc'].cat and args['region'] then
					local locCat = lookuparg(region_map, args['region'].d )
					if locCat then
						table.insert(ret, locCat..'|'..title)
					end
					table.insert(ret, v..'|'..title)
				elseif v ~= '' then
					table.insert(ret, v..'|'..title)
				end
			end
		end
	end
	
	-- Add the associated project category if matched
	if args['project'] then
		local cats = lookupmultiarg(project_map, args['project'].d, 'cat', true)
		if cats then
			for _, v in pairs(cats) do
				table.insert(ret, v..'|'..title)
			end
		end
	end

	-- Add the associated category based on employment dates
	if args['employed'] or args['left'] then
		local dates = getEmploymentDates(args['employed'].d or '', args['left'].d or '')
		if args['employed'].d:find('%?action=edit') and args['left'].d:find('%?action=edit') then
			table.insert(ret, 'Needs Jagex employee employment dates|'..title)
		elseif args['left'].d:find('%?action=edit') then
			table.insert(ret, 'Current Jagex employees|'..title)
		elseif #dates.employed > #dates.left then
			table.insert(ret, 'Current Jagex employees|'..title)
		else
			table.insert(ret, 'Former Jagex employees|'..title)
		end
	end
	
	-- Add the associated categories for jagex staff
	if args['jagex'] and args['jagex'].d then
		table.insert(ret, 'Jagex employees|'..title)
		if args['role'].d:find('%?action=edit') then
			table.insert(ret, 'Needs Jagex employee role|'..title)
		end
		if args['team'].d:find('%?action=edit') then
			table.insert(ret, 'Needs Jagex employee team|'..title)
		end
		if args['project'].d:find('%?action=edit') then
			table.insert(ret, 'Needs Jagex employee project|'..title)
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