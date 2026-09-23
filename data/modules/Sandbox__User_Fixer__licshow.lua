
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
			.join('music_file', 'track', 'music_file.page_name')
			.select('page_name', 'track', 'version', 'date', 'change', 'music.cacheid', 'music.title', 'music_file.id', 'music_file.name', 'music_file.page_name')
			.orderBy('page_name', 'asc')
			.where('music_file.name', bucket.Null())
			.limit(batchSize)
			.offset(offset)
			.run()
			
			for _, result in ipairs(batchResults) do
				
				if result.page_name and result.track ~= nil then
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
		'{| class="wikitable embed-audio-links music-tracks"',
		'! Page',
		'! id',
		'! name',
		'! date',
	}
		for _, result in ipairs(results) do
	local track = result["music_file.page_name"] or 'unknown'
	local fid = result["music_file.id"] or 'unknown'
	local id = result["music.cacheid"] or 'unknown'
	local name = result["music_file.name"] or 'unknown'
		table.insert(output, '|-')
		table.insert(output, '|[[:' .. track ..']]')
		table.insert(output, '|' .. fid)
		table.insert(output, '|' .. name)
		table.insert(output, '|' .. result.date)
	end

	table.insert(output, '|}')

	return table.concat(output, '\n')
end

return p