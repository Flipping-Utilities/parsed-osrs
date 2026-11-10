-- for comparing numbers but leaving trailing zeros so sorts are cleaner
local addcommas = require("Module:Addcommas")._add
local p = {}

function p.main(frame)
	local args = frame:getParent().args
	local n = args[1]
	n = string.gsub(n, ',', '')
	n = tonumber(n, 10)
	if not n then
		local good, val = pcall(mw.ext.ParserFunctions.expr, args[1])
		if good then
			n = tonumber(val, 10)
		end
		if not good or not n then
			return 'Value is not a number or a valid expression'
		end
	end

	local round = args.round or args[2]
	-- I don't think commas matter; we're not going to allow more than 10 probably
	round = tonumber(round, 10)
	if not round then
		return 'Rounding is not a number'
	end

	return p.round(n, round, args[3] or args["commas"])
end

-- rounds a number and then adds trailing zeros
-- only after the decimal point
-- negative rounding implies numbers before the decimal point are removed
-- but that can be done with #expr
-- this is meant for padding, which #expr can't do
function p.round(n, r, commas)
	n = tonumber(n,10)
	r = tonumber(r,10)
	local sign = n >= 0 and 1 or -1

	if not (n and r) then
		return '--'
	end

	r = math.floor(r)
	if r < 1 then
		n = math.floor(n)
		return commas and addcommas(n) or n
	end

	-- get decimal parts
	n = tostring(n)
	n = mw.text.split(n,'%.')

	local int,dec = n[1],n[2]

	if not dec then
		dec = 0
	end

	-- round the decimal part
	dec = '0.' .. dec
	dec = tonumber(dec,10)

	local rexp = 10 ^ r

	dec = math.floor(dec * rexp + 0.5) / rexp

	-- increment int portion if dec rounded up to 1
	if dec == 1 then
		int = tostring(tonumber(int) + sign)
		dec = 0
	end

	if dec > 0 then
		dec = tostring(dec) .. string.rep('0',r)

		-- cut down to desired round
		-- start at 3 because of "0.x"
		dec = string.sub(dec,3,2+r)
	else
		dec = string.rep('0',r)
	end

	-- recombine
	n = string.format('%s.%s', commas and addcommas(int) or int, dec)

	return n
end

function p.mainsf(frame)
	local args = frame:getParent().args
	local n = args[1]
	n = string.gsub(n, ',', '')
	n = tonumber(n, 10)
	if not n then
		local good, val = pcall(mw.ext.ParserFunctions.expr, args[1])
		if good then
			n = tonumber(val, 10)
		else
			return 'Value is not a number or a valid expression'
		end
	end

	local round = args.round or args[2]
	-- I don't think commas matter; we're not going to allow more than 10 probably
	round = tonumber(round, 10)
	if not round then
		return 'Rounding is not a number'
	end

	return p.sigfig(n, round, args[3] or args["commas"])
end
function p.sigfig(n, f, commas)
	f = math.floor(f-1)
	if n == 0 then return 0 end
	local m = math.floor(math.log10(n))
	local v = n / (10^(m-f))
	-- floor(x + 0.5) is standard rounding to one decimal place
	v = math.floor(v+0.5) * 10^(m-f)
	if commas then
		return addcommas(v)
	end
	return v
end


return p