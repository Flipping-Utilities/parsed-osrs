local exchVolume = require("Module:Exchange")._volume
local addcommas = require("Module:Addcommas")._add
local yesno = require("Module:Yesno")
local p = {}

function p.volume(frame)
    local pargs = frame:getParent().args
    return p._volume(pargs[1], pargs[","])
end

function p._volume(item, commas)
	commas = yesno(commas or true)
    local volume = exchVolume(item, 0)

    -- don't try to add commas to special "%LAST_UPDATE*" entries
    if item and item:match("^%%LAST_UPDATE") then
    	commas = false
	end

    return commas and addcommas(volume) or volume
end

return p