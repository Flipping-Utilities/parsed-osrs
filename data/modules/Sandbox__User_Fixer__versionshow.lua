
local p = {}

function p.musicpage()
	return p.print()
end

function p.fetchResults()
	local results = {}
	local batchSize = 5000
	local offset = 0
	
	while true do
		local batchResults = bucket('music_versions')
			.join('music', 'page_name', 'music.page_name')
			.select('page_name', 'track', 'version', 'date', 'change', 'music.cacheid', 'music.title')
			.orderBy('page_name', 'asc')
			.limit(batchSize)
			.offset(offset)
			.run()
			
			for _, result in ipairs(batchResults) do
				
				if result.page_name ~= nil then
					table.insert(results, result)
				end
			end
			
			offset = offset + batchSize
			
			if #batchResults < batchSize then
				break;
			end

	end
	
	return results
end
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
function p.print(bucketName, thingName)
	local results = p.fetchResults(bucketName)
	local output = {
		'<br>',
		'{| class="wikitable sortable embed-audio-links music-tracks"',
		'! Page',
		'! id',
		'! version',
		'! change',
		'! date',
	}
		for _, result in ipairs(results) do
	local changelog = result.change or 'N/A'
	local track = result.track or 'unknown'
	local id = result["music.cacheid"] or 'unknown'
	local title = result["music.title"] or 'unknown'
	local date = result.date or 'N/A'
		table.insert(output, '|-')
		table.insert(output, '|[[' .. result.page_name.. '|' .. title ..']]')
		table.insert(output, '|' .. id)
		table.insert(output, '|' .. result.version)
		table.insert(output, '|' .. changelog)
		table.insert(output, '|' .. date)
	end

	table.insert(output, '|}')

	return table.concat(output, '\n')
end

return p