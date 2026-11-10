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
			if not obtained and v[4] then
				return v[3]..' '..v[4]
			end
			return v[3]
		end
	end
	return ''
end

function p.main(frame)
	local args = frame.args
	return p.calc(args.kills, args.enh, args.armour)
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

function distr(chance, kc, obtained)
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
	
	return pLessThanObtained, pExactlyObtained, pMoreThanObtained
end

function p.calc(kc, enh, armour)
	
	kc = tonumber(kc)
	if not kc or kc == 0 then
		return "Gotta beat the dog to get the goods"
	end
	
	enh = tonumber(enh) or 0
	armour = tonumber(armour) or 0
	
	-- calc the chances of getting enh and 5 or 6 armour seeds 
	local pEnhNone = 0.0
	local pEnhSome = 0.0
	_,pEnhNone,pEnhSome = distr(1/400,kc,0)
	
	local pArmLow = 0.0
	local pArmFive = 0.0
	local pArmFull = 0.0
	pArmLow,pArmFive,pArmFull = distr(1/50,kc,5)
	local pArmPartial = 1 - pArmLow
	
	-- chances of bowfa + 5 or 6 armour seeds
	local pPartial = pEnhSome * pArmPartial
	local pFull = pEnhSome * pArmFull
	
	local hasFull = (enh>0) and (armour>5)
	local hasPartial = (enh>0) and (armour==5)
	
	
	local flavour = flavourText(pFull * 100, hasFull)
	
	local progressText =""
	if hasFull
	then
		progressText = "have completed your full Bowfa kit! Congrats!"
	elseif hasPartial
	then
		progressText = "have a partial Bowfa kit, but still need your helmet. Still pretty good!"
	else
		progressText = "still need " .. (enh==0 and "your '''Enh''' seed " or "") .. ((enh==0 and armour<6) and "and " or "") .. (armour<6 and string.format("'''%s Armour seed%s'''", 6-armour,(6-armour>1 and "s" or "")) or "") .. "."
	end
	
	local introText = string.format("You defeated the corrupted gauntlet '''%s''' times, and %s\n", kc, progressText)
	
	local probabilitiesText = string.format("\nAt that many completions, '''%s%.2f%%''' of players will have their full set complete,\n", (pFull<0.5 and "only " or ""), pFull*100)
	probabilitiesText = probabilitiesText .. string.format("\nAnd '''%.2f%%''' of players have a Bowfa with at least 5/6 armour seeds.\n\n\n", pPartial*100)
	
	return introText .. probabilitiesText .. flavour
end

return p