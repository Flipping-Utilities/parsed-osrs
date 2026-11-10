local p = {}
local commas = require('Module:Addcommas')._add

--
-- From Wikipedia:Module:Math
--
-- @param value {number} Original value
-- @param precision {number} Decimal places
-- @return {number} Number rounded to precision
--
local function round( value, precision )
	local rescale = math.pow( 10, precision or 0 );
	return math.floor( value * rescale + 0.5 ) / rescale;
end

--
-- Split the given quantity range into a table of quantities
--
-- @param range {string} Quantity range
-- @return {table} Table of quantities
--
local function splitString( range )
    local t = {}
    for str in string.gmatch( range, "([^-]+)" ) do
           table.insert( t, str )
    end
    return t
end

--
-- Calculate the median
--
-- @param numlist {table} Table of numbers
-- @return {number} Median number
--
local function median( numlist )
    table.sort( numlist )
    if #numlist %2 == 0 then 
    	return ( numlist[#numlist / 2] + numlist[#numlist /2 + 1] ) / 2 
    end
    return numlist[math.ceil( #numlist / 2 )]
end

--
-- Calculaate the average
--
-- @param numlist {table} Table of numbers
-- @return {number} Average number
--
local function average( numlist )
  local sum = 0
  for _,v in pairs( numlist ) do -- Get the sum of all numbers in numlist
    sum = sum + v
  end
  return sum / #numlist
end

--
-- Returns a singluar or plural based on quantity
--
-- @param value {number} Original value
-- @param singular {number} Singular text
-- @param plural {number} Plural text
-- @return {number} Number rounded to precision
--
local function plural( quantity, singular, plural )
	if quantity == 1 then
		return singular
	else
		return plural or singular..'s'
	end
end

--
-- Calculate a confidence range
--
-- @param count {number} Drop count
-- @param total {number} Total drops count
-- @return {string, number, number} Confidence range text, lower end, upper end
--
local function confRange( count, total )
	if total == 0 then
		return 0
	end
	count = count / 1 --drop amount
	local _z = 1.64485
	local zsq = _z * _z
	local _p = count / total
	local n1 = 2 * total * _p + zsq
	local n2 = _z * math.sqrt( zsq + ( 4 * total * _p * ( 1 - _p ) ) )
	local _d = 2 * ( total + zsq )
	local _l = ( 100 / _d ) * ( n1 - n2 )
	local _u = ( 100 / _d ) * ( n1 + n2 )
	local rnd
	if _l < 1 then
		rnd = 1
	else
		rnd = 0
	end
	local _lr = round( _l, rnd )
	local _ur = round( _u, rnd )
	if _lr == _ur then
		return _lr..'%', _lr, _lr
	else
		return _lr..'–'.._ur..'%', _lr, _ur
	end
end

--
-- Get the runefont css colour
--
-- @param quantity {number} Item stack quantity
-- @return {string} Runefont css colour
--
local function runefontColour( quantity )
	if quantity < 100000 then
		return 'yellow'
	elseif quantity < 10000000 then
		return 'white'
	else
		return 'lightgreen'
	end
end

--
-- Get the number of charms dropped by a given monster
--
-- @param monster {string} The monster to check
-- @return {number|nil} Number of charms dropped if found, nil otherwise
--
function getCharmsDropped( monster )
	local data = bucket('charm_drops')
		.select('quantity')
		.where('page_name_sub', monster)
		.limit(1)
		.run()
	if #data > 0 then
		return data[1].quantity	
	end
end

--
-- Map redirects to their correct pages
--
local pageRedirects = {
    
}

--
-- Makes sure first letter of page name is uppercase
-- Automatically handles any redirects
--
-- @param pageName {string} Page name to validate
-- @return {string} Validated page name
--
local function checkTitle( pageName )
    -- upper case first letter to make sure we can find a valid page name
    pageName = mw.ustring.gsub( pageName, '&#0?39;', "'" )
    pageName = mw.ustring.gsub( pageName, '_', ' ' )
    pageName = mw.ustring.gsub( pageName, '  +', ' ' )
    pageName = mw.text.split( pageName, '' )
    pageName[1] = mw.ustring.upper( pageName[1] )
    pageName = table.concat( pageName )

    -- automatically handle redirects
    if pageRedirects[pageName] ~= nil then
        pageName = pageRedirects[pageName]
    end

    return pageName
end

-- 
-- Fill in optionals from schema based on `value.page`.
-- This fills in `value.icon`, `value.label`, `value.placeholder`,
-- and `value.info` based on the value in `value.page`. Pluralizations
-- come from `value.plural` or by appending "s" to `value.page`.
--
-- @param value {table} An entry in `schema.fields` which is not the total or evidence entry.
-- @returns {table} `value` with any missing optional fields filled in.
-- 
local function normalizeSchemaEntry( value )
	if value.page == nil then
		-- page is required
		return value
	end
	
	local function merge( a, b )
	    local result = {}
	    for k, v in pairs( a ) do result[k] = v end
	    for k, v in pairs( b ) do result[k] = v end
	    return result
	end
	
	local plural = value.plural or (value.page .. "s")
	local defaults = {
		["icon"] = string.format("%s.png", value.page),
		["label"] = plural,
		["placeholder"] = string.format('# %s', plural),
		["info"] = string.format("The number of %s you received", plural)
	}
	
	return merge( defaults, value )
end

--
-- Simple mw.loadData wrapper used to access data located on module subpages
--
-- @param moduleType {string} Module type - Schema or Data
-- @param page {string} Page to retrieve data for
-- @return {table} Table of page data
--
local function load( moduleType, page )
    page = checkTitle( page )

	local noErr, ret
	if (moduleType == "Data") then
		noErr, ret = pcall(mw.loadData, "Module:Data/" .. page)
	elseif (moduleType == "Schema") then
		noErr, ret = pcall(mw.loadData, "Module:Schema/" .. page)
	end

    if noErr then
        return ret
    end
	
	return nil
end

--
-- Converts a schema into json
--
-- @param frame {template} Template calling onto module
-- @return {string} Json string of chosen schema passed in from template
--
function p.toJSON( frame )
	local args = frame:getParent().args
	return p._toJSON( args )
end

function p._toJSON( args )
	if args[1] == nil or args[1] == '' then 
		return '' 
	end
	
	local schema = load( 'Schema', args[1] )
	return mw.text.jsonEncode( schema )
end

--
-- Generates an add to log link
--
-- @param frame {template} Template calling onto module
-- @return {string} The link
--
function p.submissionLink( frame )
	local args = frame:getParent().args
	return p._submissionLink( args )
end

function p._submissionLink( args )
	local schemaType = args.schema or mw.title.getCurrentTitle().text
	local page = args.page or mw.title.getCurrentTitle().text
	local quantity = tonumber( args.quantity ) or 1
	local text = args.text or 'Add data to the log'
	local url = tostring( mw.uri.fullUrl( mw.title.getCurrentTitle().fullText, { action = 'view', logEdit = 'true' } ) )
	local link = '<div class="datatable" data-schema="'..schemaType..'" data-quantity="'..quantity..'" data-page="'..page..'">['..url..' '..text..'] (requires JavaScript)</div>'
	return link
end

--
-- Entry point to aggregate the data
--
-- @param frame {template} Template calling onto module
-- @return {table} Aggregated data
--
function p.aggregate( frame )
	local args = frame:getParent().args
	return p._aggregate( args )
end

function p._aggregate( args )
	local view = string.lower( args.view ) or 'percent'
	local schemaType = args.schema or mw.title.getCurrentTitle().text
	local page = args.page or mw.title.getCurrentTitle().text
	local quantity = tonumber( args.quantity ) or 1
	local schema = load( 'Schema', schemaType )
	local data = load( 'Data', page )
	local field = args.schemaField
	local hasNothingDrop = (args.hasNothingDrop or ''):lower() == 'yes'
	local version = args.version or ''
	local bucket = args.bucket or ''
	
	-- Set up categories
	local ns = mw.title.getCurrentTitle().namespace
	local categories = ''
	if ns == 0 then
		categories = categories..'[[Category:User submitted data]]'
	end
	
	-- Aggregated using the selected method
	if view == 'percent' then
		return tostring( p.percentileTable( schemaType, schema, page, quantity, data, hasNothingDrop ) )..categories
	elseif view == 'drops' then
		return p.dropsTable( schemaType, schema, page, quantity, data, hasNothingDrop, version, bucket )..categories
	elseif view == 'singlepercent' then
		return p.singlePercent( schema, quantity, data, field )
	elseif view == 'slimpercent' then
		return p.slimPercent( schemaType, schema, page, quantity, data )
	elseif view == 'submissions' then
		return p.submissions( schema, data )
	elseif view == 'charmlog' then
		return p.charmlog( schema, page, data )
	elseif view == 'charmqty' then
		return getCharmsDropped( monster )
	else
		return 'View not recognised. Valid views are "percent", "drops", "singlepercent", "submissions", and "charmlog".'	
	end
end	

--
-- Calculate the percentage chance of a single item being received
--
-- @param schema {table} The schema for the module
-- @param quantity {number} Quantity of items dropped in one go - i.e 2 for Waterfiend (Ghorrock), 5 for Vorago
-- @param data {table} The existing submissions
-- @param field {field} The schema field to calculate on
-- @return {string} The percentage chance
function p.singlePercent( schema, quantity, data, field )
	
	-- Set up the counts
	local counts = {}
	counts['total'] = 0
	counts[field] = 0
	
	-- Iterate the data and add up the total and field counts
	for index, entry in pairs( data ) do
		for key, value in pairs( schema.fields ) do
			if value.name == 'total' or value.name == field then
				counts[value.name] = counts[value.name] + ( entry[value.name] / ( value.quantity or 1 ) )
			end
		end
	end
	
	-- Calculate the percentage
	local percent = math.floor( 1000 * ( counts[field] / ( counts['total'] * quantity ) ) + 0.5 ) / 10
	return percent..'%'
end

--
-- Build the table to show all submissions for a module
--
-- @param schema {table} The schema for the module
-- @param data {table} The existing submissions
-- @return {table} Table containing each submission
--
function p.submissions( schema, data )
	-- Create the table
	local ret_table = mw.html.create( 'table' ):addClass( 'wikitable' ):addClass( 'sortable' )
			:tag( 'tr' )
	
	-- Load the headers from the schema		
	for key, value in pairs( schema.fields ) do
		ret_table:tag( 'th' ):wikitext( value.label ):done()
	end
	
	-- Add the username and timestamp headers
	ret_table:tag( 'th' ):wikitext( 'Username' ):done()
	ret_table:tag( 'th' ):wikitext( 'Timestamp' ):done()
	
	-- Load the data
	for index, entry in pairs( data ) do
		ret_table:tag( 'tr' )
		for key, value in pairs( schema.fields ) do
			ret_table:tag( 'td' ):wikitext( entry[value.name] ):done()
		end
		-- Add the username and timestamp data
		ret_table:tag( 'td' ):wikitext( '[[Special:Contributions/'..entry['username']..'|'..entry['username']..']]' ):done()
		ret_table:tag( 'td' ):wikitext( entry['timestamp'] ):done()
	end
	
	return ret_table:done()
end

--
-- Build the table to show confidence ranges for each drop
--
-- @param schemaType {string} The data schema type
-- @param schema {table} The data schema
-- @param page {string} The page the data module relates to
-- @param quantity {number} Quantity of items dropped in one go - i.e 2 for Waterfiend (Ghorrock), 5 for Vorago
-- @param data {table} Existing submissions
-- @param hasNothingDrop {boolean} Does the table have a nothing drop
-- @return {table} Aggregated data
--
function p.percentileTable( schemaType, schema, page, quantity, data, hasNothingDrop )	
	local counts = {}
	
	-- Create the table
	local ret_table = mw.html.create( 'table' ):addClass( 'wikitable' ):addClass( 'datatable' ):attr('data-schema', schemaType ):attr('data-quantity', quantity ):attr( 'data-page', page ):attr( 'data-nothing', tostring(hasNothingDrop) )
			:tag( 'tr' )
			
	-- Load the headers from the schema
	local totalColumns = 1
	ret_table:tag( 'th' ):css( { ['min-width'] = '40px' } ):wikitext( 'Nothing' ):done()
	for key, value in pairs( schema.fields ) do
		if value.name ~= 'evidence' and value.name ~= 'level' then
			value = normalizeSchemaEntry( value )
			counts[value.name] = 0
			if value.name ~= 'total' then
				totalColumns = totalColumns + 1
				local valQty = (string.lower(schemaType) == 'charms') and quantity or value.quantity
				
				-- Temp fix - display all runefont in default yellow
				local item = '<div style="position:relative">'..
								'<span style="pointer-events:none;position:absolute;margin-top:-7px;margin-left:-3px;font-weight:400;font-family: \'RuneScape Small\';color:'..runefontColour( 1 )..';font-size:16px;text-shadow:#000 1px 1px;">'..valQty..'</span>'..
								'[[File:'..value.icon..'|link='..value.page..']]'..
								'</div>'
				
				ret_table:tag( 'th' ):css( { ['min-width'] = '40px' } ):wikitext( item ):done()
			end
		end	
	end
	
	local total = 0
	if data ~= nil then
		-- Calculate the total counts
		for index, entry in pairs( data ) do
			for key, value in pairs( schema.fields ) do
				if value.name ~= 'evidence' and value.name ~= 'level' then
					local amounts = splitString( value.quantity or 1 )
					local quant = average( amounts )
					local entryAmount = entry[value.name] or 0
					counts[value.name] = counts[value.name] + ( entryAmount / quant )
				end
			end
		end
		
		-- Calculate the nothing count
		counts['nothing'] = counts['total'] * quantity
		for key, value in pairs( counts ) do
			if key ~= 'total' and key ~= 'nothing' then
				counts['nothing'] = counts['nothing'] - value	
			end
		end
		
		-- Add the percentages or no data row
		ret_table:tag( 'tr' ):done()
		total = counts['total']
		if total == 0 then
			ret_table:tag( 'td' )
				:attr( 'colspan', totalColumns )
				:css({ ['text-align'] = 'left' } )
				:wikitext( 'There is currently no data for '..page..'.<br>Please help the wiki by submitting some.' )
			:done()
		else
			local nothingRange = confRange( counts['nothing'] / quantity, total )
			ret_table:tag( 'td' ):css( { ['text-align'] = 'center' } ):wikitext( nothingRange ):attr('title', commas( counts['nothing'] ) ):done()
			for key, value in pairs( schema.fields ) do
				if value.name ~= 'total' and value.name ~= 'evidence' and value.name ~= 'level' then
					local count = counts[value.name]
					local range = confRange( count / quantity, total )
					ret_table:tag( 'td' ):css( { ['text-align'] = 'center' } ):wikitext( range ):attr('title', commas( count ) ):done()
				end
			end
		end
	end
	
	-- Add the info to the bottom of the table
	ret_table:tag( 'tr' ):done()
	if data == nil then
		ret_table:tag( 'td' )
			:attr( 'colspan', totalColumns )
			:css( { ['text-align'] = 'left' } )
			:wikitext( 'Log data appears to be missing for '..page..'.<br>If you believe this is an error, please contact an administrator.' )
		:done()
	else
		local url = tostring( mw.uri.fullUrl( mw.title.getCurrentTitle().fullText, { action = 'view', logEdit = 'true' } ) )
		ret_table:tag( 'td' )
			:attr( 'colspan', totalColumns )
			:css( { ['font-size'] = 'smaller', ['text-align'] = 'left', ['line-height'] = '15px' } )
			:wikitext( 'Represents a 90% confidence range based on a sample of '..commas( total )..' '..schema.sample..'.<br>'..
				quantity..' '..plural( quantity, 'item is', 'items are' )..' dropped at a time.<br>'..
				'['..url..' Add data to the log] (requires JavaScript).' )
		:done()
	end

	return ret_table:done()
end

--
-- Build the table using the DropsLine template to show drop quantities and rarities
--
-- @param schemaType {string} The data schema type
-- @param schema {table} The data schema
-- @param page {string} The page the data module relates to
-- @param totalRolls {number} Number of items rolled in one go - i.e 2 for Waterfiend (Ghorrock), 5 for Vorago
-- @param data {table} Existing submissions
-- @param hasNothingDrop {boolean} Does the table have a nothing drop
-- @param version {string} Name to use for versioned drops table (if any)
-- @param bucket {string} no = don't save to bucket
-- @return {table} Aggregated data
--
function p.dropsTable( schemaType, schema, page, totalRolls, data, hasNothingDrop, version, bucket )
	local counts = {}
	local retVal = '';
	mw.log(hasNothingDrop)
	-- Set up the total to begin
	counts['total'] = 0
	
	-- Add the drops table head template
	local url = tostring( mw.uri.fullUrl( mw.title.getCurrentTitle().fullText, { action = 'view', logEdit = 'true' } ) )
	retVal = '{{DataTableHead|schemaType='..schemaType..'|quantity='..totalRolls..'|page='..page..'|hasNothingDrop='..tostring(hasNothingDrop)..'|version='..version..'|bucket='..bucket..'}}'
	
	if data ~= nil then
		
		for key, value in pairs( schema.fields ) do
			if value.name ~= 'evidence' and value.name ~= 'level' then
				counts[value.name] = 0
			end
		end
		
		-- Calculate the total counts
		for index, entry in pairs( data ) do
			for key, value in pairs( schema.fields ) do
				if value.name ~= 'evidence' and value.name ~= 'level' and value.type == 'number' then
					local amounts = splitString( value.quantity or 1 )
					local quant = average( amounts )
					local entryAmount = entry[value.name] or 0
					counts[value.name] = counts[value.name] + ( entryAmount / quant )
				end
			end
		end
		
		-- Add each drops line
		for key, value in pairs( schema.fields ) do
			if value.name ~= 'evidence' and value.name ~= 'total' and value.name ~= 'level' and value.type == 'number' then
				local rarity = round( counts[value.name] ) .. '/' .. (counts['total'] * ( value.rolls or totalRolls ))
				
				-- Is the item noted
				local quantity = value.quantity
				if value.noted == true then
					quantity = quantity..' (noted)'
				end
				
				-- Fill in optional fields
				value = normalizeSchemaEntry( value )
				
				-- Set up the notes
				local nameNotes = value.nameNotes or ''
				local rarityNotes = value.rarityNotes or ''
				local citations = value.citations or ''
				
				-- Use the override rarity if we have one otherwise use estimated rarity if total count under threshold, or individual item count under threshold
				local isApprox = true
				if value.overrideRarity then
					rarity = value.overrideRarity
					isApprox = false
				elseif counts['total'] < 1000 or counts[value.name] == 0 then
					if value.estimatedRarity then
						-- We have an estimated rarity
						rarity = value.estimatedRarity
						rarityNotes = rarityNotes..'{{DropNote|name=estimated|Using an estimated rarity as not enough data has been submitted.}}'
						isApprox = false
					elseif counts[value.name] == 0 then
						-- We have no estimated rarity and no submissions for this item
						rarity = 'Unknown'
						rarityNotes = rarityNotes..'{{DropNote|name=unknown|No estimated rarity or submissions found for this item.}}'
						isApprox = false
					else
						-- We have no estimated rarity but we have submissions so warn user the rarity may be inaccurate
						rarityNotes = rarityNotes..'{{DropNote|name=inaccurate|Estimated rarity may be inaccurate due to a low sample size.}}'
					end
				end
				
				-- Set the rolls param
				local rolls = ( value.rolls or totalRolls ~= 1 ) and ( value.rolls or totalRolls ) or ''
				
				-- Set the approx param
				local approx = isApprox and 'yes' or ''
				
				-- Set the template we are using
				local template = schema.dropsLine or 'DropsLine'
				
				-- Output the item using the DropsLine template
				if value.name == 'triskelionFragment' then
					-- Split up triskelionFragment into each part
					rarityNotes = rarityNotes..'{{DropNote|name=triskelion|You will receive whichever fragment is next to the last crystal triskelion fragment you received.}}'
					for i = 1, 3 do
						retVal = string.format(
							"%s\n{{%s|name=%s|quantity=%s|rarity=%s|rarityNotes=%s|rolls=%s|approx=%s|bucket=%s}}",
							retVal,
							template,
							"Crystal triskelion fragment " .. i,
							quantity,
							rarity,
							rarityNotes,
							rolls,
							approx,
							value.bucket or ''
						)
					end
				else
					-- All other items
					retVal = string.format(
						"%s\n{{%s|name=%s|namenotes=%s|quantity=%s|rarity=%s|raritynotes=%s|altrarity=%s|altraritydash=%s|altvalue=%s|altcurrency=%s|image=%s|rolls=%s|approx=%s|citations=%s|bucket=%s}}",
						retVal,
						template,
						value.page,
						nameNotes,
						quantity,
						rarity,
						rarityNotes,
						value.altRarity or '',
						value.altRarityDash or '',
						value.altValue or '',
						value.altCurrency or '',
						value.icon,
						rolls,
						approx,
						citations,
						value.bucket or ''
					)
				end
			end
		end
		
		-- Add the drops table bottom
		retVal = retVal..'{{DataTableBottom|size='..counts['total']..'|sample='..schema.sample..'|link='..url..'|schema='..schemaType..'|data='..page..'}}'
	else
		-- No data found for this page so display an error and close the table
		retVal = retVal..'<tr><td colspan="7">Log data appears to be missing for '..page..'.<br>If you believe this is an error, please contact an administrator.</td></tr></table>'
	end
	return mw.getCurrentFrame():preprocess( retVal )
end

--
-- Build the table using the to display 3 columns - image, item and percentage
--
-- @param schemaType {string} The data schema type
-- @param schema {table} The data schema
-- @param page {string} The page the data module relates to
-- @param quantity {number} Quantity of items dropped in one go - i.e 2 for Waterfiend (Ghorrock), 5 for Vorago
-- @param data {table} Existing submissions
-- @return {table} Aggregated data
--
function p.slimPercent( schemaType, schema, page, quantity, data )
	local counts = {}
	
	-- Create the table
	local ret_table = mw.html.create( 'table' ):addClass( 'wikitable' ):addClass( 'datatable' ):attr('data-schema', schemaType ):attr('data-quantity', quantity ):attr( 'data-page', page )
			
	-- Load the counts
	for key, value in pairs( schema.fields ) do
		if value.name ~= 'evidence' and value.name ~= 'level' then
			counts[value.name] = 0
		end	
	end
	
	local total = 0
	if data ~= nil then
		-- Calculate the total counts
		for index, entry in pairs( data ) do
			for key, value in pairs( schema.fields ) do
				if value.name ~= 'evidence' and value.name ~= 'level' then
					local amounts = splitString( value.quantity or 1 )
					local quant = average( amounts )
					local entryAmount = entry[value.name] or 0
					counts[value.name] = counts[value.name] + ( entryAmount / quant )
				end
			end
		end
		
		-- Calculate the nothing count
		counts['nothing'] = counts['total'] * quantity
		for key, value in pairs( counts ) do
			if key ~= 'total' and key ~= 'nothing' then
				counts['nothing'] = counts['nothing'] - value	
			end
		end
		
		-- Add the percentages or no data row
		ret_table:tag( 'tr' ):done()
		total = counts['total']
		if total == 0 then
			ret_table:tag( 'td' )
				:attr( 'colspan', 3 )
				:css({ ['text-align'] = 'left' } )
				:wikitext( 'There is currently no data for '..page..'.<br>Please help the wiki by submitting some.' )
			:done()
		else
			for key, value in pairs( schema.fields ) do
				if value.name ~= 'total' and value.name ~= 'evidence' and value.name ~= 'level' then
					value = normalizeSchemaEntry( value )
					local count = counts[value.name]
					local range = confRange( count / quantity, total )
					ret_table:tag( 'tr' )
						:tag( 'td' ):wikitext( '[[File:'..value.icon..']]' ):done()
						:tag( 'td' ):wikitext( '[['..value.page..']]' ):done()
						:tag( 'td' ):wikitext( range ):done()
					:done()
				end
			end
		end
	end
	
	-- Add the info to the bottom of the table
	ret_table:tag( 'tr' ):done()
	if data == nil then
		ret_table:tag( 'td' )
			:attr( 'colspan', 3 )
			:css( { ['text-align'] = 'left' } )
			:wikitext( 'Log data appears to be missing for '..page..'.<br>If you believe this is an error, please contact an administrator.' )
		:done()
	else
		local url = tostring( mw.uri.fullUrl( mw.title.getCurrentTitle().fullText, { action = 'view', logEdit = 'true' } ) )
		ret_table:tag( 'td' )
			:attr( 'colspan', 3 )
			:css( { ['font-size'] = 'smaller', ['text-align'] = 'left', ['line-height'] = '15px' } )
			:wikitext( 'Represents a 90% confidence range based on a sample of '..commas( total )..' '..schema.sample..'.<br>'..
				quantity..' '..plural( quantity, 'item is', 'items are' )..' dropped at a time.<br>'..
				'['..url..' Add data to the log] (requires JavaScript).' )
		:done()
	end

	return ret_table:done()
end

--
-- Build the table row to show information about charms dropped by a given monster
--
-- @param schema {table} The schema for the module
-- @param page {string} The page the data module relates to
-- @param data {table} The existing submissions
-- @return {table} Table row containing the charm information
--
function p.charmlog( schema, page, data )
	if not data then
		return error('Failed to load data for monster "'..page..'"')
	end
	
	local ret_row = mw.html.create( 'tr' )
	local quantity = getCharmsDropped( page )
	local counts = {
		total = 0,
		gold = 0,
		green = 0,
		crimson = 0,
		blue = 0,
	}
	
	if not quantity then
		mw.log( 'Error asking for charms dropped; assuming 1' )
		quantity = 1
	end
	
	-- Iterate the data and add up the total and charm counts
	for _, entry in pairs( data ) do
		for key, value in pairs( counts ) do
			counts[key] = counts[key] + entry[key]
		end
	end
	
	local cr = {
		gold = { confRange( counts.gold / quantity, counts.total ) },
		green = { confRange( counts.green / quantity, counts.total ) },
		crimson = { confRange( counts.crimson / quantity, counts.total ) },
		blue = { confRange( counts.blue / quantity, counts.total ) },
	}

	-- field order (see [[Template:Charm log]]):
	-- Monster, kills logged, gold %, green %, crimson %, blue %, charms per monster
	ret_row
		:tag( 'td' ):wikitext( '[['..page..']]' ):done()
		:tag( 'td' ):wikitext( commas( counts.total ) ):done()
		:tag( 'td' ):wikitext( cr.gold[1] ):attr( 'data-sort-val', cr.gold[2] ):done()
		:tag( 'td' ):wikitext( cr.green[1] ):attr( 'data-sort-val', cr.green[2] ):done()
		:tag( 'td' ):wikitext( cr.crimson[1] ):attr( 'data-sort-val', cr.crimson[2] ):done()
		:tag( 'td' ):wikitext( cr.blue[1] ):attr( 'data-sort-val', cr.blue[2] ):done()
		:tag( 'td' ):wikitext( quantity ):done()
	
	return ret_row
end

return p