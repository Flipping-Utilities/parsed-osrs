-- This module processes data for [[Module:IPAc-en]]. It is intended to be
-- loaded with mw.loadData.

local PRONUNCIATION_MODULE = 'Module:IPAc-en/pronunciation'
local PHONEME_MODULE = 'Module:IPAc-en/phonemes'

local function makeData(oldData)
	local newData = {}
	for i, old in ipairs(oldData) do
		local new = {}
		for k, v in pairs(old) do
			if k ~= 'aliases' and k ~= 'code' then
				new[k] = v
			end
		end
		newData[old.code] = new
		if old.aliases then
			for i, alias in ipairs(old.aliases) do
				newData[alias] = new
			end			
		end
	end
	return newData
end

local function main()
	local pronunciation = makeData(require(PRONUNCIATION_MODULE))
	local phonemes = makeData(require(PHONEME_MODULE))

	-- Check that no pronunciation keys are also contained in the phonemes
	-- data. This would cause silent, hard-to-debug errors if it went
	-- unchecked, so  make it cause a big red error message instead.
	for id in pairs(pronunciation) do
		if phonemes[id] then
			error(string.format(
				"duplicate ID '%s' found in %s and %s",
				id,
				PRONUNCIATION_MODULE,
				PHONEME_MODULE
			))
		end
	end

	return {
		pronunciation = pronunciation,
		phonemes = phonemes,
	}
end

return main()