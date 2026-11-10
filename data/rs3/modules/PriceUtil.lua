--------------------------------------------------------------------------------
-- Helper module for various price templates.
--
-- Based on common code of [[Module:Exchange]], [[Module:Calcvalue]]
-- and [[Module:Component costs]].
--
-- @module priceUtil
-- @alias  p
--------------------------------------------------------------------------------
-- require("strict");
local p = {};

local expr = mw.ext.ParserFunctions.expr;
function p.parseMultiplier(multi)
	do
		local result = tonumber(multi);
		if (result ~= nil) then
			return result;
		end
	end

    -- indicated someone is trying to pass an equation as a mulitplier
    -- known use cases are fractions, but pass it to #expr to make sure
    -- it's handled correctly
	if (multi ~= nil and mw.ustring.find(multi, "[/*+-]")) then
		return tonumber(expr(multi));
	end

	return nil;
end

return p;