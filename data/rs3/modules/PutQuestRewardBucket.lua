require('strict')
local commas = require('Module:Addcommas')
local onmain = require('Module:Mainonly').on_main

local currentTitle = mw.title.getCurrentTitle()
local function onQuickGuide()
    return currentTitle.subpageText == "Quick guide"
end

local p = {}

local function extractXpRewardTags(rewards) 
	local xpRewards = {}
	-- attributes outputted by [[Template:Skill xp]]
	for skill, xp, bonus in string.gmatch(rewards or '', 'class="xpreward" data%-skill="([a-zA-Z %-]+)" data%-xp="([0-9A-Za-z%.]+)" data%-bonus="([a-z]+)"') do
		if bonus == "true" then
			bonus = true
		else 
			bonus = false
		end
	    table.insert(xpRewards, { skill = skill, xp = xp, bonus = bonus })
	end
	return xpRewards
end

local function extractXpRewardTables(rewards)
	local xpRewards = extractXpRewardTags(rewards)
	
	local rewardsSkills = {}
	local rewardsAmounts = {}
	for _, xpReward in ipairs(xpRewards) do
		local xp = xpReward.xp
		if tonumber(xp) ~= nil then
			xp = commas._add(xpReward.xp)
		end
		local rewardAmount = string.format("%s:%s", xpReward.skill, xp)
		if xpReward.bonus then
			rewardAmount = rewardAmount .. ' bonus experience'
		else
			rewardAmount = rewardAmount .. ' experience'
		end
		
		table.insert(rewardsSkills, xpReward.skill)
		table.insert(rewardsAmounts, rewardAmount)
	end
	
	return rewardsSkills, rewardsAmounts
end

local function writeBucket(args)
	if not onmain() or onQuickGuide() then
		return
	end
	
	local questPoints = tonumber(args.qp or 0)
	local rewards = args.rewards
	local postRewards = args['post quest']
	local music = args.music
	
    local rewardsSkills, rewardsAmounts = extractXpRewardTables(rewards)
    local postRewardsSkills, postRewardsAmounts = extractXpRewardTables(postRewards or '')
	
	for i = 1, #postRewardsSkills do
		rewardsSkills[#rewardsSkills + 1] = postRewardsSkills[i]
		rewardsAmounts[#rewardsAmounts + 1] = postRewardsAmounts[i]
	end
	
	local data = {
		["quest_points"] = questPoints,
		["rewards"] = rewards,
		["post_rewards"] = postRewards,
		["music"] = music,
		["rewards_skill"] = rewardsSkills,
		["rewards_skill_xp"] = rewardsAmounts
	}
	
	bucket('quest_rewards').put(data)
end

function p._main(args)
	writeBucket(args)
end

function p.main(frame)
	local args = frame:getParent().args
	
	return p._main(args)
end

return p