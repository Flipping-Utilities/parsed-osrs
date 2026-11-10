local p = {};

function p.split(str, pattern, plain)
	local res = {};
	local startIndex = 1;

	while true do
		local i, j = mw.ustring.find(str, pattern, startIndex, plain);
		if i then
			table.insert(res, mw.ustring.sub(str, startIndex, i - 1))
			startIndex = j + 1
		else
			table.insert(res, mw.ustring.sub(str, startIndex))
			break
		end
	end

	return res
end

return p;