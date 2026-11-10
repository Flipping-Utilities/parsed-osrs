--------------------------------------------------------------------------------
-- The built-in “[[mw:Special:MyLanguage/Extension:Scribunto/Lua reference manual#error|error]](…)” function
-- prevents the module from producing any output except, and so should
-- be reserved for fatal errors, whereas [[Module:User error]] is intended
-- for issues which shouldn't prevent the whole module from executing.
--
-- @see [[wikia:w:c:Dev:Module:User error]] for a similar module.
--------------------------------------------------------------------------------

local checkType = require("libraryUtil").checkType;

return function (message, ...)
	checkType("Module:User error", 1, message, "string");

	local result = mw.text.tag(
		"strong",
		{ class="error" },
		"Error: " .. message
	);

	local categories = {};
	for i = 1, select("#", ...) do
		local category = select(i, ...);
		checkType("Module:User error", 1 + i, category, "string", true);

		if (category and category ~= "") then
			table.insert(categories, "[[Category:" .. category .. "]]");
		end
	end

	return result .. table.concat(categories);
end;