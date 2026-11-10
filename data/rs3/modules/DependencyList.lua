require("strict")
local p = {}
local libraryUtil = require('libraryUtil')
local arr = require('Module:Array')
local yn = require('Module:Yesno')
local param = require('Module:Paramtest')
local dpl = require('Module:DPLlua')
local tooltip = require('Module:Tooltip')
local COLLAPSE_LIST_LENGTH_THRESHOLD = 5
local MAX_DYNAMIC_REQUIRE_LIST_LENGTH = 30
local dynamicRequireListQueryCache = {}

local builtins = {
	["libraryUtil"] = {
		link = "mw:Special:MyLanguage/Extension:Scribunto/Lua reference manual#libraryUtil",
		categories = {},
	},
	["bit32"] = {
		link = "mw:Special:MyLanguage/Extension:Scribunto/Lua reference manual#bit32",
		categories = {},
	},
	["strict"] = {
		link = "mw:Special:MyLanguage/Extension:Scribunto/Lua reference manual#strict",
		categories = { "[[Category:Strict mode modules]]" },
	},
}

-- Used in case 'require( varName )' is found. Attempts to find a string value stored in 'varName'.
local function substVarValue( moduleContent, varName )
	local res = moduleContent:match( varName .. '%s*=%s*(%b""%s-%.*)' ) or moduleContent:match( varName .. "%s*=%s*(%b''%s-%.*)" ) or ''
	if res:find( '^(["\'])[Mm]odule:[%S]+%1' ) and not res:find( '%.%.' ) and not res:find( '%%%a' ) then
		return mw.text.trim( res )
	else
		return ''
	end
end

local function extractModuleName( capture, moduleContent )
	capture = capture:gsub( '^%(%s*(.-)%s*%)$', '%1' )

	if capture:find( '^(["\']).-%1$' ) then -- Check if it is already a pure string
		return capture
	elseif capture:find( '^[%a_][%w_]*$' ) then -- Check if if is a single variable
		return substVarValue( moduleContent, capture )
	end

	return capture
end

local function formatPageName( str )
	local name = mw.text.trim(str)
		:gsub( '^(["\'])(.-)%1$', '%2' ) -- Only remove quotes at start and end of string if both are the same type
		:gsub( '_', ' ' )
		:gsub( '^.', string.upper )
		:gsub( '^([^:]-:)(.)', function(a,b) return a..string.upper(b) end )

	return name
end

local function formatModuleName( str, allowBuiltins )
	if allowBuiltins then
		local name = mw.text.trim(str)
			-- Only remove quotes at start and end of string if both are the same type
			:gsub('^(["\'])(.-)%1$', '%2')

		if builtins[name] then
			return name
		end
	end

	local module = formatPageName( str )

	if not string.find( module, '^[Mm]odule:' ) then
		module = 'Module:' .. module
	end

	return module
end

local function multiGmatch( str, ... )
	local generators = {}
	for i, pat in ipairs( { ... } ) do
		generators[i] = string.gmatch( str, pat )
	end
	local function nextCaptures()
		local captures = { generators[1]() }
		if #captures > 0 then
			return unpack( captures )
		elseif #generators > 1 then
			table.remove( generators, 1 )
			return nextCaptures()
		end
	end
	return nextCaptures
end

local function isDynamicPath( str )
	return string.find( str, '%.%.' ) or string.find( str, '%%%a' )
end

-- Used in case a construct like 'require( "Module:wowee/" .. isTheBest )' is found.
-- Will return a list of pages which satisfy this pattern where 'isTheBest' can take any value.
local function getDynamicRequireList( query )
	if query:find( '%.%.' ) then
		query = mw.text.split( query, '..', true )
		query = arr.map( query, function(x) return (x:match('^%s*[\'\"](.-)[\'\"]%s*$') or '%') end )
		query = table.concat( query )
	else
		local _, _query = query:match( '(["\'])(.-)%1' )
		query = _query:gsub( '%%%a', '%%' ) -- Replace lua string.format specifiers with a dpl wildcard
	end
	query = query:gsub( '^[Mm]odule:', '' )

	query = mw.language.getContentLanguage():ucfirst( query )
	if query:find( '^Exchange/' ) or query:find( '^Data/' ) then
		return { 'Module:' .. query }   -- This format will later be used by formatDynamicQueryLink()
	end

	if dynamicRequireListQueryCache[ query ] then
		return dynamicRequireListQueryCache[ query ]
	end

	local list = dpl.ask{
		namespace = 'Module',
		titlematch = query,
		nottitlematch = '%/doc|'..query..'/%',
		distinct = 'strict',
		ordermethod = 'title',
		count = MAX_DYNAMIC_REQUIRE_LIST_LENGTH + 1,
		skipthispage = 'no',
		allowcachedresults = true,
		cacheperiod = 604800 -- One week
	}

	if #list > MAX_DYNAMIC_REQUIRE_LIST_LENGTH then
		list = { 'Module:' .. query }
	end

	dynamicRequireListQueryCache[ query ] = list

	return list
end

--- Returns a list of modules loaded and required by module 'moduleName'.
local function getRequireLists( moduleContent )
	local requireList = arr{}
	local loadDataList = arr{}
	local extraCategories = arr{}

	local function getList( list, patterns )
		for match in multiGmatch( moduleContent, unpack( patterns ) ) do
			match = mw.text.trim( match )
			local name = extractModuleName( match, moduleContent )

			if isDynamicPath( name ) then
				list:insert( getDynamicRequireList( name ), true )
			elseif name ~= '' then
				name = formatModuleName( name, true )
				table.insert( list, name )

				if builtins[name] then
					extraCategories = extraCategories:insert( builtins[name].categories, true )
				end
			end
		end
	end

	local requirePatterns = {
		'require%s*(%b())',
		'require%s*((["\'])%s*[Mm]odule:.-%2)',
		'pcall%s*%(%s*require%s*,([^%),]+)'
	}

	local loadDataPatterns = {
		'mw%.loadData%s*(%b())',
		'mw%.loadData%s*((["\'])%s*[Mm]odule:.-%2)',
		'pcall%s*%(%s*mw%.loadData%s*,([^%),]+)',
		'mw%.loadJsonData%s*(%b())',
		'mw%.loadJsonData%s*((["\'])%s*[Mm]odule:.-%2)',
		'pcall%s*%(%s*mw%.loadJsonData%s*,([^%),]+)'
	}

	getList( requireList, requirePatterns )
	getList( loadDataList, loadDataPatterns )

	requireList = requireList:unique()
	loadDataList = loadDataList:unique()
	extraCategories = extraCategories:unique()
	table.sort( requireList )
	table.sort( loadDataList )
	table.sort( extraCategories )

	return {
		require = requireList,
		loadData = loadDataList,
		extraCategories = extraCategories,
	}
end

local function insertTemplateStyle( styleName, templateStylesList )
	styleName = formatPageName( styleName )
	if not styleName:find( ':' ) then
		styleName = "Template:" .. styleName
	end
	if isDynamicPath(styleName) then
		templateStylesList:insert( getDynamicRequireList( styleName ), true )
	else
		templateStylesList:insert( styleName )
	end
end

local function extractTemplateStyles( pageContent, templateStylesList )
	for _, styleName in string.gmatch( pageContent, '<[Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee][Ss][Tt][Yy][Ll][Ee][Ss]%s+[Ss][Rr][Cc]=(["\'])(.-)%1' ) do
		styleName = formatPageName( styleName )
		if styleName ~= '' then
			insertTemplateStyle( styleName, templateStylesList )
		end
	end
end

local function recursiveGMatch( str, pat )
	local list = {}
	local i = 0
	repeat
		for match in string.gmatch( list[i] or str, pat ) do
			table.insert( list, match )
		end
		i =  i + 1
	until i > #list or i > 100

	i = 0
	return function()
		i = i + 1
		return list[i]
	end
end

local function formatTemplate( name )
	if name:find( ':' ) then
		local ns = name:match( '^(.-):' )
		if arr.contains( {'', 'template', 'calculator', 'user'}, ns:lower() ) then
			return name
		elseif ns == ns:upper() then
			return ns -- Probably a magic word
		end
	else
		if name:match( '^%u+$' ) or name == '!' then
			return name -- Probably a magic word
		else
			return 'Template:'..name
		end
	end
end

local function getUsedTemplatesList( moduleContent )
	local usedTemplateList = arr{}
	local templateStylesList = arr{}

	for preprocess in string.gmatch( moduleContent, ':preprocess%s*(%b())' ) do
		for template in recursiveGMatch( preprocess, '{(%b{})}' ) do
			local name = string.match( template, '{(.-)[|{}]' )
			if name ~= '' then
				usedTemplateList:insert( formatTemplate( name ) )
			end
		end

		extractTemplateStyles( preprocess, templateStylesList )
	end

	for capture in string.gmatch( moduleContent, 'expandTemplate%s*%(?%s*{%s*title%s*=%s*((["\'])%s*.-%2)' ) do
		local name = formatPageName( capture )
		if name ~= '' then
			usedTemplateList:insert( formatTemplate( name ) )
		end
	end

	for _, capture in multiGmatch(
		moduleContent,
		'extensionTag%s*%(%s*'
			.. '(["\'])[Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee][Ss][Tt][Yy][Ll][Ee][Ss]%1%s*,'
			.. '.-,'
			.. '%s*{%s*src%s*=%s*((["\'])%s*.-%3)',
		'extensionTag%s*%(?%s*{%s*'
            .. 'name%s*=%s*(["\'])[Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee][Ss][Tt][Yy][Ll][Ee][Ss]%1'
            .. '.-'
            .. 'args%s*=%s*{%s*src%s*=%s*((["\'])%s*.-%3)'
	) do
		local name = formatPageName( capture )
		if name ~= '' then
			insertTemplateStyle( name, templateStylesList )
		end
	end

	usedTemplateList = usedTemplateList:unique()
	templateStylesList = templateStylesList:unique()
	table.sort( usedTemplateList )
	table.sort( templateStylesList )

	return {
		usedTemplateList = usedTemplateList,
		templateStylesList = templateStylesList,
	}
end

-- Returns all dependencies of the template found on page 'pageName'
local function getTemplateDependencyList( pageName )
	local pageContent = mw.title.new( pageName ):getContent()
	local invokeList = {}
	local templateStylesList = arr{}

	assert( pageContent, string.format( 'Failed to retrieve text content of page "%s"', pageName ) )

	for moduleName, funcName in string.gmatch( pageContent, '{{[{|safeubt:}]-#[Ii]nvoke:([^|]+)|([^}|]+)[^}]*}}' ) do
		moduleName = formatModuleName( moduleName )
		funcName = mw.text.trim( funcName )
		if string.find( funcName, '^{{{' ) then
			funcName = funcName ..  '}}}'
		end
		table.insert( invokeList, {moduleName=moduleName, funcName=funcName} )
	end

	-- For form calcs invoking the module directly
	for config in multiGmatch( pageContent, '<[pd][ri][ev]%s+class%s*=%s*["\']jcConfig["\'](.-)</[pd][ri][ev]>', '{{[Ff]orm calculator%s*|(.+)}}' ) do
		local moduleName = string.match( config, 'module%s*=%s*(.-)[\n|]' )
		if param.has_content( moduleName ) then
			moduleName = formatModuleName( moduleName )
			local funcName = string.match( config, 'modulefunc%s*=%s*(.-)[\n|]' ) or 'main'
			table.insert( invokeList, {moduleName=moduleName, funcName=funcName} )
		end
	end

	extractTemplateStyles( pageContent, templateStylesList )

	invokeList = arr.unique( invokeList, function(x) return (x.moduleName .. '#' .. x.funcName) end )
	templateStylesList = templateStylesList:unique()
	table.sort( invokeList, function(x, y) return (x.moduleName .. '#' .. x.funcName) < (y.moduleName .. '#' .. y.funcName) end )
	table.sort( templateStylesList )

	return {
		invokeList = invokeList,
		templateStylesList = templateStylesList,
	}
end

-- Returns a list with module and function names used in all '{{#Invoke:moduleName|funcName}}' found on page 'templateName'.
local function getInvokeCallList( pageName )
	return getTemplateDependencyList( pageName ).invokeList
end

local function getInvokedByList( moduleName )
	local whatTemplatesLinkHere = dpl.ask( {
		namespace = 'Template|Calculator',
		linksto = moduleName,
		distinct = 'strict',
		ordermethod = 'title',
		allowcachedresults = true,
		cacheperiod = 604800 -- One week
	} )

	local function lcfirst( str )
		return string.gsub( str, '^[Mm]odule:.', string.lower )
	end

	local invokedByList = {}

	for _, templateName in ipairs( whatTemplatesLinkHere ) do
		local invokeList = getInvokeCallList( templateName )

		for _, invokeData in ipairs( invokeList ) do
			if lcfirst( invokeData.moduleName ) == lcfirst( moduleName ) then
				table.insert( invokedByList, { templateName=templateName, funcName=invokeData.funcName } )
			end
		end
	end

	return invokedByList
end

local function messageBoxUnused()
	local html = mw.html.create( 'table' ):addClass( 'messagebox obsolete plainlinks' )
	html:tag( 'td' )
		:attr( 'width', '40xp' )
		:wikitext( '[[File:Iron full helm detail old.png|center|30px|link=]]' )
	:done()
	:tag( 'td' )
		:wikitext( "'''This module is unused.'''" )
		:tag( 'div' )
			:css{ ['font-size']='0.85em', ['line-height']='1.45em' }
			:wikitext( 'This module is neither invoked by a template nor required/loaded by another module. If this is in error, make sure to add <code>{{[[Template:Documentation|Documentation]]}}</code>/<code>{{[[Template:No documentation|No&nbsp;documentation]]}}</code> to the calling template\'s or parent\'s module documentation.' )
		:done()
	:done()

	return tostring( html )
end

local function collapseList( list, id, listType )
	local text = string.format( '%d %s', #list, listType )
	local button = tooltip._span{ name=id, alt=text }
	list = arr.map( list, function(x) return '\n# '..x end )
	local content = tooltip._div{ name=id, content='\n'..table.concat( list )..'\n\n' }

	return { tostring( button ) .. tostring( content ) }
end

-- Creates a link to [[Special:Search]] showing all pages found by getDynamicRequireList() in case it found more than MAX_DYNAMIC_REQUIRE_LIST_LENGTH pages.
-- Input query uses DPL % wildcards like 'Module:Wowee/%' or 'Module:Wowee/%/data'
local function formatDynamicQueryLink( query )
	local prefix = query:match( '^([^/]+)' )
	local linkText = query:gsub( '%%', '&lt; ... &gt;' )

	query = query:gsub( '^Module:',  '' )

	query = query:gsub( '([^/]+)/?', function ( match )
		if match == '%' then
			return '\\/[^\\/]+'
		else
			return '\\/"' .. match .. '"'
		end
	end )

	query = query:gsub( '^\\/', '' )

	query = string.format(
		'intitle:/%s%s/i -intitle:/%s\\/""/i -intitle:doc prefix:"%s"',
		query,
		query:find( '"$' ) and '' or '""',
		query,
		prefix
	)

	return string.format( '<span class="plainlinks">[%s %s]</span>', tostring( mw.uri.fullUrl( 'Special:Search', { search = query } ) ), linkText )
end

local function formatModuleLinks( pages )
	local links = arr{}

	for _, moduleName in ipairs(pages) do
		if moduleName:find( '%%' ) then
			links:insert( formatDynamicQueryLink( moduleName ) )
		elseif builtins[moduleName] then
			links:insert( '[[' .. builtins[moduleName].link .. '|' .. moduleName .. ']]' )
		else
			links:insert( '[[' .. moduleName .. ']]' )
		end
	end

	return links
end

local function formatTemplateLinks( pages )
	local links = arr{}

	for _, templateName in ipairs(pages) do
		if string.find( templateName, ':' ) then -- Real templates are prefixed by a namespace, magic words are not
			links:insert( '[['..templateName..']]' )
		else
			links:insert( "'''&#123;&#123;"..templateName.."&#125;&#125;'''" ) -- Magic words don't have a page so make them bold instead
		end
	end

	return links
end

local function formatTemplateStyleLinks( pages, dynamic )
	local links = arr{}

	for _, stylesName in ipairs( pages ) do
		if dynamic and stylesName:find( '%%' ) then
			links:insert( formatDynamicQueryLink( stylesName ) )
		else
			links:insert( '[[' .. stylesName .. ']]' )
		end
	end

	return links
end

--- @param callerName string
--- @param templateStylesList string[]
--- @param forModule? boolean
--- @return string
local function formatTemplateStylesList( callerName, templateStylesList, forModule )
	templateStylesList = formatTemplateStyleLinks( templateStylesList, forModule )
	local res = {}

	if #templateStylesList > COLLAPSE_LIST_LENGTH_THRESHOLD then
		templateStylesList = collapseList( templateStylesList, 'templateStyles', 'styles' )
	end

	for _, item in ipairs( templateStylesList ) do
		table.insert( res, string.format(
			"<div class='seealso'>'''%s''' uses styles from %s using [[mw:Special:MyLanguage/Help:TemplateStyles|TemplateStyles]].</div>",
			callerName,
			item
		) )
	end

	return table.concat( res )
end

local function formatInvokeCallList( templateName, invokeList )
	local res = {}

	for _, item in ipairs( invokeList ) do
		table.insert( res, string.format(
			"<div class='seealso'>'''%s''' invokes function '''%s''' in [[%s]] using [[RuneScape:Lua|Lua]].</div>",
			templateName,
			item.funcName,
			item.moduleName
		) )
	end

	return table.concat( res )
end

local function formatInvokedByList( moduleName, invokedByList )
	for i, invoke in ipairs( invokedByList ) do
		invokedByList[i] = string.format( "function '''%s''' is invoked by [[%s]]", invoke.funcName, invoke.templateName )
	end

	table.sort( invokedByList)

	local res = {}

	if #invokedByList > COLLAPSE_LIST_LENGTH_THRESHOLD then
		table.insert( res, string.format(
			"<div class='seealso'>'''%s''' is invoked by %s.</div>",
			moduleName,
			collapseList( invokedByList, 'invokedBy', 'templates' )[1]
		) )
	else
		for _, item in ipairs( invokedByList ) do
			table.insert( res, string.format(
				"<div class='seealso'>'''%s's''' %s.</div>",
				moduleName,
				item
			) )
		end
	end

	return table.concat( res )
end

local function formatRequiredByList( moduleName, requiredByLists )
	local requiredByList = formatModuleLinks( requiredByLists.require )
	local loadedByList = formatModuleLinks( requiredByLists.loadData )

	if #requiredByList > COLLAPSE_LIST_LENGTH_THRESHOLD then
		requiredByList = collapseList( requiredByList, 'requiredBy', 'modules' )
	end

	if #loadedByList > COLLAPSE_LIST_LENGTH_THRESHOLD then
		loadedByList = collapseList( loadedByList, 'loadedBy', 'modules' )
	end

	local res = {}

	for _, requiredByModuleName in ipairs( requiredByList ) do
		table.insert( res, string.format(
			"<div class='seealso'>'''%s''' is required by %s.</div>",
			moduleName,
			requiredByModuleName
		) )
	end

	for _, loadedByModuleName in ipairs( loadedByList ) do
		table.insert( res, string.format(
			"<div class='seealso'>'''%s''' is loaded by %s.</div>",
			moduleName,
			loadedByModuleName
		) )
	end

	return table.concat( res )
end

local function formatImportList( currentPageName, moduleList, id, message )
	moduleList = formatModuleLinks( moduleList )

	if #moduleList > COLLAPSE_LIST_LENGTH_THRESHOLD then
		moduleList = collapseList( moduleList, id, 'modules' )
	end

	local res = arr.map( moduleList, function( moduleName )
		return '<div class="seealso">' .. string.format( message, currentPageName, moduleName ) .. '</div>'
	end )

	return table.concat( res )
end

local function formatUsedTemplatesList( currentPageName, usedTemplateList )
	usedTemplateList = formatTemplateLinks( usedTemplateList )
	local res = {}

	if #usedTemplateList > COLLAPSE_LIST_LENGTH_THRESHOLD then
		usedTemplateList = collapseList( usedTemplateList, 'usedTemplates', 'templates' )
	end

	for _, templateName in ipairs( usedTemplateList ) do
		table.insert( res, string.format(
			"<div class='seealso'>'''%s''' transcludes %s using <samp>frame:preprocess()</samp> or <samp>frame:expandTemplate()</samp>.</div>",
			currentPageName,
			templateName
		) )
	end

	return table.concat( res )
end

local function setBucketFields( requireLists )
	if mw.title.getCurrentTitle().subpageText ~= 'doc' and (#requireLists.require > 0 or #requireLists.loadData > 0) then
		bucket( 'dependency_list' ).put{
			require = requireLists.require,
			load_data = requireLists.loadData
		}
	end
end

local function getRequiredByLists( currentPageName )
	local requiredByListRaw = bucket( 'dependency_list' ).select( 'page_name' ).where( 'require', currentPageName ).run()
	local loadedByListRaw = bucket( 'dependency_list' ).select( 'page_name' ).where( 'load_data', currentPageName ).run()
	local requiredByList = {}
	local loadedByList = {}

	for _, bucketItem in ipairs( requiredByListRaw ) do
		table.insert( requiredByList, bucketItem.page_name )
	end
	for _, bucketItem in ipairs( loadedByListRaw ) do
		table.insert( loadedByList, bucketItem.page_name )
	end

	requiredByList = arr.unique( requiredByList )
	loadedByList = arr.unique( loadedByList )
	table.sort( requiredByList )
	table.sort( loadedByList )

	return {
		require = requiredByList,
		loadData = loadedByList
	}
end

local function templateDependencyList( currentPageName, addCategories )
	local dependencyList = getTemplateDependencyList( currentPageName )
	local res = arr{}

	res:insert( formatInvokeCallList( currentPageName, dependencyList.invokeList ) )
	res:insert( formatTemplateStylesList( currentPageName, dependencyList.templateStylesList ) )

	if addCategories then
		if #dependencyList.templateStylesList > 0 then
			res:insert( '[[Category:Templates using TemplateStyles]]' )
		end
		if #dependencyList.invokeList > 0 then
			res:insert( '[[Category:Lua-based templates]]' )
		end
	end

	return table.concat( res )
end

local function moduleDependencyList( currentPageName, addCategories, isUsed )
	local moduleContent = mw.title.new( currentPageName ):getContent()
	assert( moduleContent, string.format( 'Failed to retrieve text content of page "%s"', currentPageName ) )
	moduleContent = moduleContent:gsub( '%-%-%[(=-)%[.-%]%1%]', '' ):gsub( '%-%-[^\n]*', '' ) -- Strip comments

	local requireLists = getRequireLists( moduleContent )
	local usedTemplateList = getUsedTemplatesList( moduleContent )
	local requiredByLists = getRequiredByLists( currentPageName )
	local invokedByList = getInvokedByList( currentPageName )

	setBucketFields( requireLists )

	local res = arr{}

	res:insert( formatInvokedByList( currentPageName, invokedByList ) )
	res:insert( formatImportList( currentPageName, requireLists.require, 'require', "'''%s''' requires %s." ) )
	res:insert( formatImportList( currentPageName, requireLists.loadData, 'loadData', "'''%s''' loads data from %s." ) )
	res:insert( formatUsedTemplatesList( currentPageName, usedTemplateList.usedTemplateList ) )
	res:insert( formatTemplateStylesList( currentPageName, usedTemplateList.templateStylesList, true ) )
	res:insert( formatRequiredByList( currentPageName, requiredByLists ) )

	if addCategories then
		res:insert( requireLists.extraCategories, true )

		if #usedTemplateList.templateStylesList > 0 then
			res:insert( '[[Category:Modules using TemplateStyles]]' )
		end
		if #requireLists.require > 0 then
			res:insert( '[[Category:Modules requiring modules]]' )
		end
		if #requireLists.loadData > 0 then
			res:insert( '[[Category:Modules using data]]' )
		end
		if #requiredByLists.require > 0 then
			res:insert( '[[Category:Modules required by modules]]' )
		end
		if #requiredByLists.loadData > 0 then
			res:insert( '[[Category:Module data]]' )
		end
		if #invokedByList > 0 then
			res:insert( '[[Category:Template invoked modules]]' )
		end
	end

	if
		not (
			yn( isUsed )
			or currentPageName:lower():find( 'sandbox' )
			or #requiredByLists.require > 0
			or #requiredByLists.loadData > 0
			or #invokedByList > 0
		)
	then
		table.insert( res, 1, messageBoxUnused() )

		if addCategories then
			res:insert( '[[Category:Unused modules]]' )
		end
	end

	return table.concat( res )
end

function p.main( frame )
	local args = frame:getParent().args
	return p._main( args[1], args.category, args.isUsed )
end

function p._main( currentPageName, addCategories, isUsed )
	libraryUtil.checkType( 'Module:RequireList._main', 1, currentPageName, 'string', true )
	libraryUtil.checkTypeMulti( 'Module:RequireList._main', 2, addCategories, {'boolean', 'string', 'nil'} )
	libraryUtil.checkTypeMulti( 'Module:RequireList._main', 3, isUsed, {'boolean', 'string', 'nil'} )

	local title = mw.title.getCurrentTitle()

	-- Leave early if not in module, template or calculator namespace or if module is part of exchange or data groups
	if param.is_empty( currentPageName ) and (
		( not arr.contains( {'Module', 'Template', 'Calculator'}, title.nsText ) ) or
		( title.nsText == 'Module' and ( arr.contains( {'Exchange', 'Exchange historical', 'Data'}, title.text:match( '^(.-)/' ) ) ) )
	) then
		return ''
	end

	currentPageName = param.default_to( currentPageName, title.fullText )
	currentPageName = string.gsub( currentPageName, '/[Dd]oc$', '' )
	currentPageName = formatPageName( currentPageName )

	if (addCategories == nil) then
		addCategories = title.subpageText~='doc'
	end
	addCategories = yn(addCategories)

	if currentPageName:find( '^Template:' ) or currentPageName:find( '^Calculator:' ) then
		return templateDependencyList( currentPageName, addCategories )
	end

	return moduleDependencyList( currentPageName, addCategories, isUsed )
end

return p