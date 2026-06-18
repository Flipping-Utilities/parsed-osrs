-- <nowiki>
local dpl = {}
local libraryUtil = require( 'libraryUtil' )
local hasContent = require( 'Module:Paramtest' ).has_content
local checkType = libraryUtil.checkType
local checkTypeForNamedArg = libraryUtil.checkTypeForNamedArg

dpl.pipe = '¦'
local dataContentMarker = '`#@@#`'
local allIncludedParamNames = {}

-- Custom function for splitting a string because mw.text.split() is waaay too slow
local function split( str, pattern, plain )
	local res = {}
	local continue = true
	local startIndex = 1

	while continue do
		local i, j = string.find( str, pattern, startIndex, plain )
		if i then
			table.insert( res, string.sub( str, startIndex, i-1 ) )
			startIndex = j + 1
		else
			table.insert( res, string.sub( str, startIndex ) )
			continue = false
		end
	end

	return res
end

-- Also custom function for speed
local function trim( str )
	return (string.gsub( str, '^%s+', '' ):gsub( '%s+$', '' ))
end

local function mergeItem( tbl, key, item )
	if type( tbl[key] ) == 'table' and type( item ) == 'table' then
		for k in pairs( tbl[key] ) do
			mergeItem( tbl[key], k, item[k] )
		end
	elseif type( tbl[key] ) == 'table' then
		table.insert( tbl[key], item )
	else
		tbl[key] = { tbl[key], item }
	end
end

local escapeChars = {
	['{'] = '&#123;',
	['}'] = '&#125;',
	['['] = '&#91;',
	[']'] = '&#93;',
	['|'] = '&#124;',
	['-'] = '&#8208;'
}
local function escape( str )
	return (string.gsub( str, '[{}%[%]|%-]', escapeChars ))
end

local unEscapeChars = {
	['&#123;'] = '{',
	['&#125;'] = '}',
	['&#91;'] = '[',
	['&#93;'] = ']',
	['&#124;'] = '|',
	['&#8208;'] = '-'
}
local function unEscape( str )
	return (string.gsub( str, '&#%d+;', unEscapeChars ))
end

local function fixCurlyBrackets( str )
	-- the \226\157\180\181 are used to match ❴ (U+2774) and ❵ (U+2775) wich are 3 bytes long (UTF-8) so
	-- we can't use them directly inside [] patterns. Ustring would fix this but it's way too slow.
	return (string.gsub( str, '\226\157[\180\181]', { ['❴'] = '{', ['❵'] = '}' } ))
end

local function removeFormattingSettings( query )
	local toRemove = {
		'mode',
		'table',
		'tablerow',
		'tablesortcol',
		'headingmode',
		'headingcount',
		'listattr',
		'itemattr',
		'hlistattr',
		'hitemattr',
		'userdateformat',
		'shownamespace',
		'escapelinks',
		'titlemaxlength',
		'replaceintitle',
		'columns',
		'rows',
		'rowsize',
		'rowcolformat',
		'resultsheader',
		'resultsfooter',
		'oneresultheader',
		'oneresultfooter',
		'noresultsheader',
		'suppresserrors',
		'noresultsfooter',
		'format',
		'groupMultiTemplateResults'
	}

	for _, k in ipairs( toRemove ) do
		query[k] = nil
	end
end

local function formatInclude( query )
	checkTypeForNamedArg( 'Module:DPLlua.ask', 'include', query, 'string' )
	query = split( query, ',', true )
	local includedParamNames = {}
	local sectionAttributes = {}

	for i = 1, #query do
		if query[i]:match( '%b{}' ) then -- Check if we are including a template
			local templateName, extra = query[i]:match( '{(.-)[¦|}](.*)' )
			if hasContent( extra ) then
				local phantomTemplateName = extra:match( '^(.-)}' ) or extra:match( '^[./].+' )
				local phantomTemplatePrefix = extra:match( '^(.-)}' ) and '' or templateName
				local params = extra:gsub( '^.-}', '' ):gsub( '^[./].+', '' ):gsub( ':%-', '' )
				local sur = hasContent( phantomTemplateName ) and ('¦' .. phantomTemplatePrefix .. phantomTemplateName) or ''
				query[i] = string.format( '{%s%s}%s', templateName, sur, params )

				if hasContent( phantomTemplateName ) then
					table.insert( includedParamNames, { name=phantomTemplatePrefix..phantomTemplateName, isTemplate=true, hasPhantomTemplate=true } )
					table.insert( sectionAttributes, { hasPhantomTemplate=true } )
				else
					for param in params:gmatch( ':([^:]*)' ) do
						param = trim( param )
						table.insert( includedParamNames, { name=templateName, isTemplate=true, param=param } )
					end
					table.insert( sectionAttributes, { hasPhantomTemplate=false } )
				end
			else
				query[i] = string.format( '{%s¦DPLlua helper}', templateName ) -- Use a helper template to get all the parameters of our included template
				table.insert( includedParamNames, { name=templateName, isTemplate=true, includeAll=true } )
				table.insert( sectionAttributes, { hasPhantomTemplate=false } )
			end
		else
			table.insert( includedParamNames, { name=trim( query[i] ) } )
			table.insert( sectionAttributes, { hasPhantomTemplate=false } )
		end
	end

	return table.concat( query, ',' ), includedParamNames, sectionAttributes
end

local function formatDpl( query )
	local queries = {}
	local count = query.count or 500
	local offset = query.offset or 0
	local usesInclude = false
	local includedParamNames = {}
	local sectionAttributes
	query.count = nil
	query.offset = nil

	-- Use table format so we can place dataContentMarkers around each included parameter. The secseparator
	-- is needed to add dataContentMarkers when a phantom template is used
	local dplStringInclude =
[=[
{{#dpl:
|noresultsheader=@@
|count=%s
|offset=%s
|%s
|table=,
|listseparators=,\n¦-\n¦[[%%PAGE%%¦]],,
|tablerow=%s
|secseparators=%s
}}]=]

	-- Table format requires an include statement so we use format instead.
	-- This is also a lot faster than adding an empty include statement
	local dplStringNoInclude =
[=[
{{#dpl:
|noresultsheader=@@
|count=%s
|offset=%s
|%s
|format=,¦-¦[[%%PAGE%%¦]],,
}}]=]

	-- Auto generate more than one dpl if count > 500
	-- The results of these are later combined
	for i = 1, math.ceil( count / 500 ) do
		local params = {}

		for k, v in pairs( query ) do
			if k == 'include' then
				v, includedParamNames, sectionAttributes = formatInclude( v )
				usesInclude =  true
			end

			if type( v ) == 'table' then
				for _, x in ipairs( v ) do
					table.insert( params, k .. '=' .. tostring( x ):gsub( '|', '¦' ) )
				end
			else
				table.insert( params, k .. '=' .. tostring( v ):gsub( '|', '¦' ) )
			end
		end

		if usesInclude then
			local secseparators = ''
			for _, v in ipairs( sectionAttributes ) do
				if v.hasPhantomTemplate then
					-- Phantom templates need this because they ignore tablerow formatting
					secseparators = secseparators .. '¶¦' .. dataContentMarker .. ',' .. dataContentMarker .. ','
				else
					secseparators = secseparators .. '¶¦,,'
				end
			end

			table.insert( queries, string.format(
				dplStringInclude,
				count > 500 and 500 or count,
				offset,
				table.concat( params, '\n|' ),
				string.rep( dataContentMarker..'%%'..dataContentMarker..',', #includedParamNames ),
				secseparators
			) )
		else
			table.insert( queries, string.format(
				dplStringNoInclude,
				count > 500 and 500 or count,
				offset,
				table.concat( params, '\n|' )
			) )
		end

		count = count - 500
		offset = offset + 500
	end

	table.insert( allIncludedParamNames, includedParamNames )
	return table.concat( queries )
end

local function toTable( query, groupMultiTemplateResults )
	local includedParamNames = table.remove( allIncludedParamNames, 1 )
	local usesInclude = #includedParamNames > 0
	local res = {}

	query = query:gsub( '<p>Extension:DynamicPageList .-</p>', function(item) res.error = item; return '' end )

	if query:find( '^@@' ) then -- @@ is used when no result is found
		return res
	end

	if usesInclude then
		query = query:gsub( dataContentMarker..'(.-)'..dataContentMarker, escape )
	end

	query = trim( query )
	query = split( query, '|-', true ) -- Results of the returned pages are separated by |-

	for _, v in ipairs( query ) do
		if hasContent( v ) and not v:find( '^@@' ) then
			v = trim( v )
			local title = v:match( '^|%[%[(.-)|' )
			local rawDataList = v:match( '^|.-|.-|(.*)' ) -- This is everything after the title

			if not usesInclude then
				if title and title ~= '' then
					table.insert( res, title )
				end
			else
				-- When multiple includes are used (e.g. include={Template1},{Template2} or include={Template}:1:2) their results are separated by a pipe
				rawDataList = split( rawDataList, '|', true )
				local cleanedDataList = {}

				for _incIndex, dataItem in ipairs( rawDataList ) do
					local incIndex = ((_incIndex - 1) % #includedParamNames) + 1 -- Needed in case the same template appears multiple times on the same page
					dataItem = unEscape( dataItem )
					dataItem = trim( dataItem )

					if includedParamNames[ incIndex ].isTemplate and includedParamNames[ incIndex ].includeAll then -- Check if we included a full template
						-- When we include an entire template we use the %ARGS% parameter supplied by dpl.
						-- However all | characters are repaced with §, e.g.:
						-- §namelessParam
						-- §param = text [[wowee§link text]]
						-- §param2 = text {{something§something else}}
						dataItem = dataItem:gsub( '\127\'"`UNIQ%-%-nowiki%-%x+%-QINU`"\'\127', function(item) return '<nowiki>' .. item .. '</nowiki>' end )
						dataItem = mw.text.unstripNoWiki( dataItem ) -- Unstrip nowiki so we can clean their content
						dataItem = fixCurlyBrackets( dataItem ) -- When using the %ARGS% dpl parameter, curly brackets are replaced with ❴ (U+2774) and ❵ (U+2775)
						dataItem = dataItem:gsub( '%b{}', function(x) return x:gsub( '§', '|' ) end ) -- Restore pipe characters inside links and templates
						dataItem = dataItem:gsub( '%b[]', function(x) return x:gsub( '§', '|' ) end )
						dataItem = dataItem:gsub( '<nowiki>(.-)</nowiki>', function(x) return mw.getCurrentFrame():extensionTag( 'nowiki', x ) end ) -- Restrip nowiki
						local _dataItem = {}

						if dataItem ~= '' then
							dataItem = split( dataItem:sub( 3 ), '§' ) -- The sub(3) removes the first § at the start. § is 2 bytes wide so start at index 3

							for i, item in ipairs( dataItem ) do
								if item:find( '=' ) then -- Check if the parameter is named or unnamed
									local param, value = item:match( '^%s*(.-)%s*=%s*(.-)%s*$' )
									_dataItem[ param ] = value
								else
									table.insert( _dataItem, trim( item ) )
								end
							end
						end

						dataItem = _dataItem
					end

					local dataListIndex = groupMultiTemplateResults and 1 or math.ceil( _incIndex / #includedParamNames )
					if
						includedParamNames[ incIndex ].isTemplate and
						not includedParamNames[ incIndex ].includeAll and
						not includedParamNames[ incIndex ].hasPhantomTemplate
					then -- This means there was an include in the form 'include = {template}:param'
						local templateName = includedParamNames[ incIndex ].name
						local paramName = includedParamNames[ incIndex ].param
						paramName = tonumber( paramName ) or paramName -- Keep as string if tonumber fails
						cleanedDataList[ dataListIndex ] = cleanedDataList[ dataListIndex ] or {}
						cleanedDataList[ dataListIndex ][ templateName ] = cleanedDataList[ dataListIndex ][ templateName ] or {}
						
						if groupMultiTemplateResults and _incIndex > #includedParamNames then
							mergeItem( cleanedDataList[ dataListIndex ][ templateName ], paramName, dataItem )
						else
							cleanedDataList[ dataListIndex ][ templateName ][ paramName ] = dataItem
						end
					else
						local templateName = includedParamNames[ incIndex ].name
						cleanedDataList[ dataListIndex ] = cleanedDataList[ dataListIndex ] or {}
						
						if groupMultiTemplateResults and _incIndex > #includedParamNames then
							mergeItem( cleanedDataList[ dataListIndex ], templateName, dataItem )
						else
							cleanedDataList[ dataListIndex ][ templateName ] = dataItem
						end
					end
				end

				if title and title ~= '' then
					for _, v in ipairs( cleanedDataList ) do
						table.insert( res, { title=title, include=v } )
					end
				end
			end
		end
	end

	return res
end

-- Accepts a series of tables each containig the settings for a dpl query.
-- Combinig multiple dpl queries yields better performance than doing them sequentially
function dpl.ask( ... )
	local formatTime = os.clock()
	local queries = { ... }
	local wantsGrouping = {}

	for i = 1, #queries do
		checkType( 'Module:DPLlua.ask', i, queries[i], 'table' )
		table.insert( wantsGrouping, queries[i].groupMultiTemplateResults or false )
		removeFormattingSettings( queries[i] )
		queries[i] = formatDpl( queries[i] )
	end
	formatTime = os.clock() - formatTime

	local DPLtime = os.clock()
	queries = table.concat( queries, '$@µ@$' )
	queries = mw.getCurrentFrame():preprocess( queries )
	queries = split( queries, '$@µ@$', true )
	DPLtime = os.clock() - DPLtime

	for i = 1, #queries do
		local parseTime = os.clock()
		queries[i] = toTable( queries[i], wantsGrouping[i] )
		parseTime = os.clock() - parseTime
		queries[i]['DPL time'] = DPLtime
		queries[i]['Parse time'] = math.floor( (formatTime + parseTime) * 1e5 ) / 1e5 -- os.clock() has a resolution of 10µs
	end

	return unpack( queries )
end

-- function dpl.test()
-- 	local time = os.clock()

	-- local a, b = dpl.ask({
	--     namespace = 'Module',
	--     linksto = 'Module:Chart data',
	--     distinct = 'strict',
	--     ordermethod = 'title',
	--     nottitlematch = '%/doc¦%sandbox%¦Exchange/%¦Exchange historical/%¦Chart data',
	-- 	ignorecase = 'true',
	-- 	allowcachedresults = false
	-- },{
	--     namespace = 'Module',
	--     linksto = 'Module:Enum',
	--     distinct = 'strict',
	--     ordermethod = 'title',
	-- 	nottitlematch = '%/doc¦%sandbox%¦Exchange/%¦Exchange historical/%¦Enum',
	--     ignorecase = 'true',
	-- 	allowcachedresults = false
	-- })
	-- mw.logObject(a)
	-- mw.logObject(b)

	-- local a, b = dpl.ask({
	--     namespace = 'Module',
	--     linksto = 'Module:Chart data',
	--     distinct = 'strict',
	--     ordermethod = 'title',
	--     nottitlematch = '%/doc¦%sandbox%¦Exchange/%¦Exchange historical/%¦Chart data',
	--     ignorecase = 'true',
	-- 	allowcachedresults = false
	-- },{
	-- 	namespace = '',
	-- 	ignorecase = 'true',
	-- 	uses = 'Template:Infobox Recipe',
	-- 	count = 50,
	-- 	include = '{Infobox Recipe},{Infobox Item}',
	-- 	allowcachedresults = false
	-- })
	-- mw.logObject(a)
	-- mw.logObject(b)

	-- local a = dpl.ask{
	-- 	namespace = '',
	-- 	uses = 'Template:Infobox Recipe',
	-- 	include = '{Infobox Recipe}:skill:name,{Infobox Item}:update,{Infobox Item|test}',
	-- 	count = 50,
	-- 	ordermethod = 'title',
	-- }
	-- mw.logObject(a)

	-- local q = dpl.ask{
	-- 	uses = "Template:Collections table",
	-- 	category = "Archaeology collections",
	-- 	-- include = "{Infobox Collection}:reward,{Collections table}:1:2:3:4:5:6:7:8:9:10:11:12:13:14:15",
	-- 	include = "{Infobox Collection}:reward,{Collections table}",
	-- 	count = 100
	-- }
	-- mw.logObject(q)
	
	-- local q = dpl.ask{
	-- 	namespace = "",
	-- 	uses = "Template:Infobox Spell",
	-- 	notcategory = {"Removed content", "Removed spells"},
	-- 	nottitlematch = {"Enchant Crossbow Bolt", "Storm of Armadyl"},
	-- 	include = "{Infobox Spell}",
	-- }
	-- mw.logObject(q)

-- 	local list = dpl.ask{
-- 		namespace = 'Template',
-- 		uses = 'Template:Navbox',
-- 		ordermethod = 'title',
-- 		include = '{Navbox}:gtitle1:gtitle2',
-- 		count = 1,
-- 		offset = 3
-- 	}
-- 	mw.logObject(list)

-- 	local list = dpl.ask{
-- 		namespace = 'User',
-- 		titlematch = 'CephHunter/Sandbox/test1',
-- 		include = '{User:CephHunter/Sandbox/test2|User:CephHunter/Sandbox/test3},{User:CephHunter/Sandbox/test3}:1',
-- 	}
-- 	mw.logObject(list)

-- 	mw.logObject(dpl.ask{
-- 		namespace = 'User',
-- 		ignorecase = 'true',
-- 		titlematch = 'CephHunter/Sandbox/test1',
-- 		include = '{User:CephHunter/Sandbox/test2}'
-- 	})

-- 	mw.logObject(dpl.ask{
-- 		namespace = 'Module',
-- 		uses = 'Template:Helper module',
-- 		titlematch = '%/doc',
-- 		nottitlematch = 'Exchange/%|Exchange historical/%|Sandbox/%',
-- 		ordermethod = 'title',
-- 		include = '{Helper module}, {Helper module}:example',
-- 		count = 1,
-- 		offset = 13
-- 	})

-- 	mw.logObject(dpl.ask{
--         namespace = 'Module',
--         titlematch = 'Chart data|Absorbative calculator',
--         nottitlematch = 'Exchange/%|Exchange historical/%|Sandbox/%|%/doc|DPLlua%',
--         ordermethod = 'title',
--         include = '%0'
-- 	})

-- 	mw.logObject(dpl.ask{
--         uses = 'Template:Collections table',
--         include = '{Collections table}',
--         count = 5
-- 	})

-- 	mw.log(os.clock()-time)
-- end

return dpl
-- </nowiki>