local getArgs = require("Module:Arguments").getArgs;
local coins = require('Module:Currency')._amount
local parseTemplateParams = require("Module:TemplateUtil").parseTemplateParams;
local parseMultiplier = require("Module:PriceUtil").parseMultiplier;

local p = {}

function p.main(frame)
	local args = getArgs(frame);
	local item = args['item'] or args[1]
	local img = false
	if args['image'] or args[2] then
		img = true
	end

	if args['set'] then
		local val = p._set( args['set'] )
        if args['output'] then
            return val
        else
            return
        end
	end

	if args['expr'] then
		return p._expr( args['expr'] )
	end

	return p._get(item, img)
end

function p.price(frame)
	local args = getArgs(frame);
	local item = args[1];
	local multi = parseMultiplier(args[2]) or 1;

	return p._get(item, false, multi);
end

function p._get(item, img, multi)
	local calcval
	local res = bucket('infobox_item')
		.select('calculated_value')
		.where(bucket.Or({'page_name', item}, {'item_name', item})) -- Sometimes the input is the page name, sometimes its the item name.
		.where(bucket.Not({'calculated_value', bucket.Null()}))
		.limit(1)
		.run()
	if res and res[1] then
		calcval = res[1]['calculated_value']
	end
	if not calcval then
		error('No calculated value could be found for: '..item)
	end

	local price
	if tonumber(calcval) then
		price = tonumber(calcval)
	else
		local x = calcval
			:gsub('{{[Cc]alcvalue%|([^}]+)}}', p._get)
			:gsub("{{[Cc]VP%|([^}]+)}}", function (template)
				return p.price(parseTemplateParams(template));
			end)
			:gsub("{{[Cc]VTotal%|([^}]+)}}", function (template)
				return require("Module:CVTotal").simple(parseTemplateParams(template));
			end)
		price = mw.getCurrentFrame():preprocess("{{#expr: " ..x.." }}")
		if tonumber(price) then
			price = math.floor(price * 100 + 0.5) / 100
		else
			mw.logObject(
				{ calcval = calcval, x = x, price = price },
				"[[Module:Calcvalue]]._get:"
			);
			error('Error preprocessing calculated value: '..calcval)
		end
	end

	if type(multi) == "number" then
		price = multi * price;
	end

	if img then
		return coins(price, 'coins')
	end
	return price
end

function p._set(val)
	local ret
    local calculated
	if tonumber(val) then
		ret = val
		mw.log('Fixed value: '..ret)
        calculated = val
	else
		if val:find("`UNIQ--nowiki", 1, true) then
			ret = mw.text.unstripNoWiki(val)
		else
			local str = string.gsub( string.gsub(val, '{', '{{'), '}', '}}')
			ret = string.gsub(str, '¦', '|')
		end
		mw.log( 'Wikitext: '..ret )
        calculated = mw.getCurrentFrame():preprocess(ret)
		mw.log( 'Resulting value: '.. calculated )
	end

	bucket('infobox_item').put({
		['item_name'] = mw.title.getCurrentTitle().fullText,
		['calculated_value'] = ret
	})

	return calculated
end

function p._expr(val)
	local ret
    local calculated
	if tonumber(val) then
		ret = val
		mw.log('Fixed value: '..ret)
        calculated = val
	else
		local str = string.gsub( string.gsub(val, '{', '{{'), '}', '}}')
		ret = string.gsub(str, '¦', '|')
		mw.log( 'Wikitext: '..ret )
		ret = string.gsub(str, '¦', '|')
        calculated = mw.getCurrentFrame():preprocess(ret)
		mw.log( 'Resulting value: '.. calculated )
	end

	return calculated
end

return p