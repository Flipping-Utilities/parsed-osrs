-- Throwaway helper for confirming bucket and field names.
--   {{#invoke:Sandbox/Prince_Caleb/bucket peek|peek|bucket=drops|page=Gnome}}
-- Delete this module once the planner is working.
local p = {}

function p.peek(frame)
	local a = frame.args
	local name = a.bucket or 'drops'
	local page = a.page or 'Gnome'

	local ok, rows = pcall(function()
		return bucket(name).where('page_name', page).limit(5).run()
	end)
	if not ok then
		return "'''Query failed:''' <code>" .. mw.text.nowiki(tostring(rows)) .. '</code>'
	end
	if not rows or #rows == 0 then
		return "No rows for '''" .. page .. "''' in bucket <code>" .. name .. '</code>.'
	end

	local out = { "Bucket <code>" .. name .. "</code>, page '''" .. page .. "''', " ..
		#rows .. ' row(s). Field names and first values:', '{| class="wikitable"', '! Field !! Value' }
	local keys = {}
	for k in pairs(rows[1]) do keys[#keys + 1] = tostring(k) end
	table.sort(keys)
	for _, k in ipairs(keys) do
		out[#out + 1] = '|-'
		out[#out + 1] = '| <code>' .. k .. '</code> || ' .. mw.text.nowiki(tostring(rows[1][k]))
	end
	out[#out + 1] = '|}'
	return table.concat(out, '\n')
end

return p