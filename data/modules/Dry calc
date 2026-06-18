local p = {}

function expr(x)
	x = tostring(x)
	x = x:gsub(",", "")
	local expr_good, expr_val = pcall(mw.ext.ParserFunctions.expr, x)
	if expr_good then
		return tonumber(expr_val)
	end
	return nil
end

function flavourText(x, obtained)
	local flavourTexts = {
		{ -1, 1, "You are some sort of sentient water being you're so not-dry. How'd you even do this?" },
		{ 1, 10, "You're a higher % water than a watermelon.", "Or you would be if you had gotten any drops. But you didn't." },
		{ 10, 20, "Only ironmen can be this lucky.", "But you got no drops, so I guess you're not an ironman." },
		{ 20, 30, "🥄 Spooned 🥄", "j/k you got no drops" },
		{ 30, 40, "Your friends will be jealous.", "...If you got any drops." },
		{ 40, 49, "You're quite the lucker aren't you.", "Or not, since you got no drops." },
		{ 49, 51, "A perfect mix of dry and undry, as all things should be." },
		{ 51, 61, 'Nothing interesting happens.', "Over half of your friends would have got a drop by now, though." },
		{ 61, 65, "An unenlightened being would say 'but 1/x over x kills means I should get it', but you know better now." },
		{ 65, 73, 'Nothing interesting happens.', "Not even any drops." },
		{ 73, 74, "😂😂😂" },
		{ 74, 85, "oof" },
		{ 85, 90, "A national emergency has been declared in your drop log." },
		{ 90, 95, "Right, time to post on reddit." },
		{ 95, 99, "You after being this dry: [[File:Skeleton (level 21, 1).png|link=Skeleton|80x80px]]" },
		{ 99, 99.5, "You are so dry you have collapsed into the dry singularity. The dryularity, if you will." },
		{ 99.5, 99.9, "The vacuum of space has more activity than your drop log." },
		{ 99.9, 99.99, "Wow that's so rare! Seems like it's bugged. We tweeted @JagexAsh for you, we're sure he'll get to the bottom of it in the next 24 hours." },
		{ 99.99, 1000, "Did you forget to talk to [[Oziach]]?" }
	}
	for i, v in ipairs(flavourTexts) do
		if x >= v[1] and x < v[2] then
			if obtained == 0 and v[4] then
				return v[3]..' '..v[4]
			end
			return v[3]
		end
	end
	return ''
end

function p.main(frame)
	local args = frame.args
	return p.calc(args.chance, args.kills, args.dropped)
end

function p.binomDist(p,n,k)
	-- calculates P(B<k) and P(B=k) for B binomially distributed with probability p and n tries
	-- uses log to prevent overflow/underflow issues
	local logPNot = math.log(1.0-p)
	local logPDiff = math.log(p)-logPNot
	local logPX = n*logPNot -- start at 0 drops in n kc
	local pCumulative = 0.0
	
	for x=1,k
	do
		pCumulative = pCumulative + math.exp(logPX)
		logPX = logPX + math.log(n-x+1.0) - math.log(x) + logPDiff
	end
	return pCumulative, math.exp(logPX)
end

function p.calc(chanceTxt, kc, obtained)
	local chance = expr(chanceTxt)
	if not chance then
		return 'Looks like there was an error with your input chance, try typing it in again'
	else
		if chance > 1 then
			chance = 1 / chance
			chanceTxt = string.format("1/%s", chanceTxt)
		elseif chance <= 0 then
			return "You put your chance at 0 or negative, how you gonna get that drop?"
		end
	end
	
	kc = tonumber(kc)
	if not kc or kc == 0 then
		return "You ain't killed anything you crazy fool"
	end
	obtained = tonumber(obtained) or 0
	
	if kc < obtained then
		return 'More items dropped than things killed? how?'
	end
	
	-- calculate P(D<obtained), P(D=obtained) and P(D>obtained) for D Binominally-distributed(kc,chance)
	local pLessThanObtained = 0.0
	local pExactlyObtained = 0.0
	local pMoreThanObtained = 0.0
	
	if obtained < kc/2
	then
		pLessThanObtained, pExactlyObtained = p.binomDist(chance, kc, obtained)
		pMoreThanObtained = 1.0 - pLessThanObtained - pExactlyObtained
	else
		pMoreThanObtained, pExactlyObtained = p.binomDist(1.0-chance, kc, kc-obtained)
		pLessThanObtained = 1.0 - pMoreThanObtained - pExactlyObtained
	end
	
	local flavour = flavourText(pMoreThanObtained * 100, obtained)
	if kc == 1 and obtained == 1
	then
		flavour = "Perfect drop rate."
	end
	local introText = string.format("You killed %s monsters for an item with a %s (%.6f%% or 1/%0.2f) drop chance. You had a:\n",
		kc, chanceTxt, 100 * chance, 1/chance)
	local probabilitiesText = string.format("* %.8f%% chance (1/%.2f) of getting exactly %s drops,\n",
		100*pExactlyObtained, 1/pExactlyObtained, obtained)
	if obtained > 0
	then
		probabilitiesText = probabilitiesText .. string.format("* %.8f%% chance (1/%.2f) of getting fewer than %s drops,\n",
			100*pLessThanObtained, 1/pLessThanObtained, obtained)
	end
	if obtained < kc
	then
		probabilitiesText = probabilitiesText .. string.format("* %.8f%% chance (1/%.2f) of getting more than %s drops,\n",
			100*pMoreThanObtained, 1/pMoreThanObtained, obtained)
	end
	return introText .. probabilitiesText .. flavour
end

return p