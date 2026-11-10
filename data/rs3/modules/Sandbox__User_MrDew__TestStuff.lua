local debug = require("Module:Debug")
local profiler = debug.newProfiler()

local coins1 = profiler:setHook(require("Module:Currency")._coins, "coins1")
local coins2 = profiler:setHook(require("Module:Coins")._amount, "coins2")

local p = {}

function p.test()
    for i = 1, 10000 do
    	local _ = coins1(tostring(i))
	end

    for i = 1, 10000 do
    	local _ = coins2(tostring(i))
	end
    
    profiler:report()
end

function p.bigtext(frame)
	local args = frame:getParent().args
	mw.log("Test: " .. frame:preprocess(args[1]))
end

return p