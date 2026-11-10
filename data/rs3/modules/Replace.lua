-- <pre>
-- A module to allow substitution of regex replace functions

local p = {}

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

-- a : string
-- b : search
-- c : replace
function p._main(args)
	local a =  mw.text.decode(args[1])
	local b = mw.text.decode(args[2] or '')
	local c = mw.text.decode(args[3] or '')

	-- let us use real regex stuff
	b = mw.ustring.gsub(b,'\\','%')
				:gsub('%*%?','-')
				:gsub('¦','|')

	c = mw.ustring.gsub(c,'$(%d)','%%%1')

	local ret = ''
	-- test for alteration, and find an apprporiate set if necessary
	-- alteration currently only works for groups
	-- it also only works for 1 level of alteration
	-- e.g. (foo|ba(z|r)) will fail
	-- other operations inside alteration groups should work fine
	-- e.g. (foo|ba[rz]) will be fine

	-- looks for unescaped | within parentheses, where the last parenthesis isn't escaped
	-- characters inside cannot be unescaped parentheses, as it finds the first unescaped one to close the capture
	-- as such, that will cause unwanted results for nested captures
	-- may need to be refined
	if string.find(b,'%(.-%f[%%|][^)]-[^%%]%)') then
		ret = p.alterationGroups(a,b,c)

	-- perform basic replacements
	else
		ret = mw.ustring.gsub(a,b,c)
	end

	-- trim whitespace
	ret = mw.text.trim(ret)

	-- condense whitespace
	ret = mw.ustring.gsub(ret,'  +',' ')

	-- fix problems with the pipe trick
	-- May no longer apply now that we are using Bucket?
	ret = mw.ustring.gsub(ret,'%| %]%]','|]]')

	return ret
end

-- trying to emulate regex's alteration in pattern matches
-- only works on unnested groups, but supports up to 9
-- any number of alterations works
-- requires the string being matched against (tst)
-- will return the first combination found that works against tst
-- if we have '(a|b)(c|d|e)(f|g)', tests are performed in this order:
-- acf, acg, adf, adg, aef, aeg, bcf, bcg, bdf, bdg, bef, beg
-- if no group works, the final combination is returned
-- neither result works anyway
function p.alterationGroups(tst,reg,repl)
	-- create 2 sets of captures to use
	-- one for storage, the other for manipulation
	local captures,_captures = {},{}

	-- string to hold pattern match
	local s = reg
	mw.log(s)
	mw.log('---')

	-- convert parentheses into full width for temp parsing
	s = mw.ustring.gsub(s,'%%%(','（')
	s = mw.ustring.gsub(s,'%%%)','）')

	-- string to use for string.format in tests
	-- convert %s to %$ for temp parsing
	local _sform = mw.ustring.gsub(s,'%%s','%%$')

	-- matches any set of parentheses that isn't started with a %
	_sform = string.gsub(_sform,'%f[(%%](%b())','(%%s)')

	-- convert full width back to escaped
	_sform = _sform:gsub('（','%%('):gsub('）','%%)')

	-- double up % since string.format is bitchy
	_sform = _sform:gsub('%%([^s])','%%%%%1')

	-- turn $ back to s
	_sform = _sform:gsub('%%%%%$','%%%%s')

	-- finds all parenthetical groups that aren't begun with a %
	-- add to table of manipulate-able capture
	for v in string.gmatch(s,'%f[(%%](%b())') do
		-- match to remove parentheses
		table.insert(captures,string.match(v,'^%((.+)%)$'))
	end

	-- convert each capture into a table
	-- split by alteration character
	for _, v in ipairs(captures) do
		table.insert(_captures,mw.text.split(v,'|'))
	end

	-- table of all possible combinations used for the formatting
	local groupstouse = {}

	-- recursive function
	local function addtogroups(x,stor)
		-- for all in the set
		for _, v in ipairs(_captures[x]) do
			-- temporary storage
			local _stor = {}

			-- deep copy because fuck lua
			for _, u in ipairs(stor or {}) do
				table.insert(_stor,u)
			end

			-- add current pattern to storage
			table.insert(_stor,v)

			-- if there's a next group, run func on those
			if _captures[x+1] then
				addtogroups(x+1,_stor)

			-- otherwise just add this to the master table
			else
				for i, u in ipairs(_stor) do
					_stor[i] = string.format('(%s)',u)
				end

				table.insert(groupstouse,_stor)
			end
		end
	end

	-- run recursive func
	addtogroups(1)

	local formatted
	-- replaced stuff
	local _tst = tst

	-- holds original string
	local tst2 = {mw.ustring.codepoint(tst,1,999999999999999999999)}

	-- check each possible group
	for i, v in ipairs(groupstouse) do

		-- format current groups to check
		formatted = mw.ustring.format(_sform,unpack(v))
		--local
		-- if a match is found, use those groups
		-- replace formatted
		-- use higher numbered characters to avoid parsing of replaced value
		local s,e = mw.ustring.find(_tst,formatted)
		while s do
			-- change all characters in the range of the match to unicode characters
			-- uses a unicode character that holds the index of pattern in groupstouse
			-- located at 4000 + i * 1000
			_tst = mw.text.split(_tst,'')
			for x=s,e do
				_tst[x] = mw.ustring.char(4000+1000*i)
			end
			
			_tst = table.concat(_tst)
			s,e = mw.ustring.find(_tst,formatted,e+1)
		end
		-- logging results
		mw.log(table.concat(v,' -- ')..' : '..formatted)
	end

	-- turn test string into table of unicode indices
	_tst = {mw.ustring.codepoint(_tst,1,99999999999999999)}

	-- combines table.concat and mw.ustring.char
	-- turn only a subset of the table into characters
	local function byteconcat(tbl,start,_end)
		local ret = {}
		start = start or 1
		_end = _end or #tbl
		for x = start,_end do
			table.insert(ret,mw.ustring.char(tbl[x]))
		end
		return table.concat(ret)
	end

	-- start and end indices
	local s,e = 1,111111111111111111111111

	-- while a start point exists
	while s do
		s = nil
		local ch = 0

		-- find first index of a unicode character 5000 or higher
		-- these indicate an area to replace
		for i, v in ipairs(_tst) do
			if v > 4999 then
				s = i
				ch = v
				break
			end
		end

		-- no start point means we're done
		if not s then
			break
		end

		-- index of the group set
		local groupmatch = ch / 1000 - 4

		-- find the end point
		e = s
		while ch == _tst[e+1] do
			e = e + 1
		end

		-- replace these characters with the index
		for x=s,e do
			_tst[x] = groupmatch
		end

		-- strings to reform the new return string
		local _tst1,_tst2,_tst3

		-- form strings from the found indices
		_tst1 = byteconcat(_tst,1,s-1)
		_tst2 = byteconcat(tst2,s,e)
		_tst3 = byteconcat(_tst,e+1)
		local tstsize = mw.ustring.len(_tst2)

		-- do replacement
		_tst2 = mw.ustring.gsub(_tst2,table.concat(groupstouse[groupmatch]),repl)

		-- fill tst2 with dummy characters to match the proper length
		tstsize = mw.ustring.len(_tst2) - tstsize

		if tstsize > 0 then
			for x=s+1,tstsize+s do
				table.insert(tst2,x,99)
			end
		end

		-- re-concatenate the strings
		_tst = table.concat{_tst1,_tst2,_tst3}

		-- turn newest string into table
		_tst = {mw.ustring.codepoint(_tst,1,99999999999999999)}
	end

	-- return finished string
	return byteconcat(_tst)
end

return p