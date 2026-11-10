local p = {}

local morseDict = {
  A = ".-",   B = "-...", C = "-.-.", D = "-..",  E = ".",    F = "..-.", G = "--.",
  H = "....", I = "..",   J = ".---", K = "-.-",  L = ".-..", M = "--",   N = "-.",
  O = "---",  P = ".--.", Q = "--.-", R = ".-.",  S = "...",  T = "-",    U = "..-",
  V = "...-", W = ".--",  X = "-..-", Y = "-.--", Z = "--..",
  ["0"] = "-----", ["1"] = ".----", ["2"] = "..---", ["3"] = "...--", ["4"] = "....-",
  ["5"] = ".....", ["6"] = "-....", ["7"] = "--...", ["8"] = "---..", ["9"] = "----."
}

-- takes a plain string
function p._translate(message)
	assert(message and message ~= '', 'No message provided')

	local messageParts = {}
	for ch in mw.ustring.upper(message):gmatch(".") do
		if ch == " " then
			messageParts[#messageParts + 1] = "/"   -- word separator
		elseif morseDict[ch] then
			messageParts[#messageParts + 1] = morseDict[ch]
		end
		-- unknown characters are skipped
	end

	return '"' .. message .. '" (<code>' .. table.concat(messageParts, ' ') .. '</code>)'
end

-- {{Morse}} entrance: called via {{#invoke:Morse|translate}}
function p.translate(frame)
	local args = frame:getParent().args
	return p._translate(args[1])
end

return p