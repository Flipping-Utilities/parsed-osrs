-- <pre>
local p = {}

local htnmlext = require('Module:Mw.html extension')
local yesno = require ("Module:Yesno")
local lang = mw.getContentLanguage()
local min = math.min
local max = math.max
local floor = math.floor

function p.main(frame)
	local invokeArgs = frame.args
    local args = frame:getParent().args
    
    return p._main( invokeArgs, args )
end

function onOff(value)
	return value and 1 or 0
end

function p._main(invokeArgs,args)
	--args
	--fCrit damage modifiers
	local pvmorpvp = args.pvmorpvp
	local level = tonumber(args.level) or 0
	local baseDamage = tonumber(args.baseDamage) or 0
	local smokeCloud = args.smokeCloud
	--unlocks
	local enchantmentHeroism = yesno(args.enchantmentHeroism) or false
	local enchantmentMetaphysics = yesno(args.enchantmentMetaphysics) or false
	local enchantmentShadows = yesno(args.enchantmentShadows) or false
	--fCrit probability modifiers
	local activePrayer = args.prayer
	local bitingRank = tonumber(args.biting) or 0
	local level20biting = yesno(args.level20biting) or false
	local pocket = args.pocket
	local ring = args.ring or args.ringNecromancy 
	local ringChampions = tonumber(args.ringChampions) or 0
	local ringChannellers = tonumber(args.ringChannellers) or 0
	local ringStalkers = tonumber(args.ringChannellers) or 0
	local forcedAbility = args.forcedAbility
	local abilConcBlast = tonumber(args.abilityConcentratedBlast) or 0
	local abilGConcBlast = tonumber(args.abilityGreaterConcentratedBlast) or 0
	local abilRunicCharge = yesno(args.abilityRunicCharge) or false
	local familiar = yesno(args.familiar) or false
	local surgingStorm = yesno(args.surgingStorm) or false
	local scroll = yesno(args.scroll) or false
	local ammunition = yesno(args.ammunition) or false
	local corbicula = args.corbicula
	local setEffect = args.setEffect
	local warpriestOfTuska = tonumber(args.warpriestOfTuska) or 0
    
    --calculate forced, natural, total crit probabilities
    local fCritProb = calculateForcedCriticalHitProbability(enchantmentHeroism,enchantmentMetaphysics,enchantmentShadows,activePrayer,bitingRank,level20biting,pocket,ring,ringChampions,ringChannellers,forcedAbility,abilConcBlast,abilGConcBlast,abilRunicCharge,familiar,scroll,ammunition,corbicula,setEffect,warpriestOfTuska)
    
    local critStrikeDamageValue = calculateCritStrikeDamage(pvmorpvp,level,smokeCloud,enchantmentHeroism,enchantmentMetaphysics,enchantmentShadows,ring,ringChampions,ringChannellers,surgingStorm)
    local critStrikeDamage = min(30000,(1-fCritProb/100)*baseDamage + (fCritProb/100)*baseDamage*(1+critStrikeDamageValue/100))
    local effectiveIncrease = (critStrikeDamage - baseDamage)/baseDamage * 100
	
	critStrikeDamageValue = floor(critStrikeDamageValue*100 + 0.5)/100
	fCritProb = floor(fCritProb*100 + 0.5)/100
	effectiveIncrease = floor(effectiveIncrease*100 + 0.5)/100

	if(fCritProb < 0 or fCritProb > 100) then
		return 'ERROR: out of bounds'
	end

	return 'Critical strike damage: ' .. critStrikeDamageValue .. '%' .. '<br>' .. 'Critical strike chance: ' .. fCritProb .. '%' .. '<br>' .. 'Damage increase: ' .. effectiveIncrease .. '%'
end

function calculateCritStrikeDamage(pvmpvp,lvl,sc,eHeroism,eMetaphysics,eShadows,r,rChampions,rChannellers,surgingStorm)
	--base crit damage from level and pvm/pvp
	critDamage = 10
	if(lvl>=90) then critDamage = 50
	elseif(lvl>=80) then critDamage = 45
	elseif(lvl>=70) then critDamage = 40
	elseif(lvl>=60) then critDamage = 35
	elseif(lvl>=50) then critDamage = 30
	elseif(lvl>=40) then critDamage = 25
	elseif(lvl>=30) then critDamage = 20
	elseif(lvl>=20) then critDamage = 15
	end
	if(pvmpvp=="PvP") then critDamage = critDamage/5 end
	--modifiers
	if(r=="Champion's ring" and eHeroism==true) then
		critDamage = critDamage + rChampions*1.5	
	elseif(r=="Channeller's ring" and eMetaphysics==true) then
		critDamage = critDamage + rChannellers*2.5
	elseif(r=="Stalker's ring" and eShadows==true) then
		critDamage = critDamage + 3
	end
	if(sc=="6%") then
		critDamage = critDamage + 6
	elseif(sc=="15%") then
		critDamage = critDamage + 15
	end
	if(surgingStorm) then
		critDamage = critDamage + ((15 + 30) / 2)
	end
	
	return critDamage
end

function calculateForcedCriticalHitProbability(eHeroism,eMetaphysics,eShadows,aPrayer,bRank,lv20b,pocketSlot,ringSlot,rChampions,rChannellers,fAbil,conc,gconc,runic,fam,scroll,ammo,corbi,setEff,tuska)
	--forced crit probabilities are addititve.
	local fCritChance = 10 --base crit chance 10%
	
	--set effect
	if(setEff == "Tuska's Might (Sliske's Parody)") then 
		fCritChance = fCritChance + 6
	elseif(setEff == "Tumeken's Resplendence") then
		fCritChance = fCritChance + 7.5
	elseif(setEff == "Elite tectonic") then 
		fCritChance = fCritChance + 6
	elseif(setEff == "Tectonic") then 
		fCritChance = fCritChance + 3
	elseif(setEff == "Tuska's Might (Warpriest of Tuska)") then
		fCritChance = fCritChance + tuska
	elseif(setEff == "Dracolich") then
		fCritChance = fCritChance + 20
	elseif(setEff == "Elite Dracolich") then
		fCritChance = fCritChance + 40
	end
	
	--active prayer
	if(aPrayer == "Eclipsed Soul") then
		fCritChance = fCritChance + 4
	end
	
	--biting
	fCritChance = fCritChance + (bRank*2 * ( 1 + 0.1*onOff(lv20b) ))
		
	--pocket
	if(pocketSlot == "Erethdor's grimoire") then
		fCritChance = fCritChance + 12
	elseif(pocketSlot == "Chaotic grimoire") then
		fCritChance = fCritChance + 7
	end
	
	--rings
	if(ringSlot == "Reaver's ring") then
		fCritChance = fCritChance + 5
	elseif(ringSlot == "Channeller's ring") then
		fCritChance = fCritChance + 4*rChannellers
	elseif(ringSlot == "Stalker's ring") then
		fCritChance = fCritChance + 3
		if(eShadows) then
			fCritChance = fCritChance + 1
		end
	elseif(ringSlot == "Champion's ring") then
		fCritChance = fCritChance + 3
		if(eHeroism) then
			fCritChance = fCritChance + 1
		end
	end
	
	--familiar
	if(fam) then
		fCritChance = fCritChance + 1
	end
	if(scroll) then
		fCritChance = fCritChance + 5
	end
	
	--ammunition
	if(ammo) then
		fCritChance = fCritChance + 3
	end
	
	--corbicula (only affects meteor strike)
	if(corbi == "+20%") then
		fCritChance = fCritChance + 20
	elseif(corbi == "+40%") then
		fCritChance = fCritChance + 40
	end
	
	--abilities (should be placed at the end of fcrit because of gfury)
	
	local runicChargeModifier = 0
	if (runic) then 
		runicChargeModifier = 10 
	end
	
	if(fAbil == "Fury") then
		fCritChance = fCritChance + 25
	elseif(fAbil == "Greater Fury") then
		fCritChance = 100
	elseif(fAbil == "Concentrated Blast") then
		fCritChance = fCritChance + (5+runicChargeModifier)*conc
	elseif(fAbil == "Greater Concentrated Blast") then
		fCritChance = fCritChance + (7+runicChargeModifier)*gconc
	end
	
	--return forced crit chance (max of 100%)
	return min(100,fCritChance)
end

return p