local split = require("Module:StringUtil").split;
local ustr = mw.ustring;

local p = {};

function p.parseTemplateParams(template)
	local sections = split(mw.text.trim(template), "%s*|%s*");
	local params = {};

	for _, v in ipairs(sections) do
		if ustr.find(v, "=") then
			local name, value = ustr.match(v, "^(.-)%s*=%s*(.-)$");
			params[name] = value;
		else
			table.insert(params, v);
		end
	end

	return params;
end

function p.marker(n)
	return "\127$" .. n .. "$\127";
end

function p.recursiveTemplateMatch(value)
	local templateList = {};
	local markerCount = 1;

	local function recursiveTemplateMatchImpl(v)
		v = ustr.gsub(v, "{(%b{})}", recursiveTemplateMatchImpl);
		v = v:gsub("^{", ""):gsub("}$", "");
		local marker = p.marker(markerCount);
		markerCount = markerCount + 1;
		templateList[marker] = v;
		return marker
	end

	recursiveTemplateMatchImpl(value);

	return templateList, markerCount - 1;
end

return p;