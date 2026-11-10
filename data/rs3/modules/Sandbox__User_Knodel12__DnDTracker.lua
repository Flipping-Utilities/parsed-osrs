local p = {}

local activities = {
	{ "Anima Islands", "Daily reset", "Members", "" },
	{ "Agoroth", "Weekly reset (Wednesday)", "Free-to-play and members", "" },
	{ "Balthazar Beauregard's Big Top Bonanza", "Weekly reset (Wednesday)", "Members", "" },
	{ "Big Chinchompa", "Daily reset; event every 30 minutes", "Members", "" },
	{ "Bork", "Daily reset", "Members", "" },
	{ "Champion's Challenge", "Weekly rematches; champions unlock permanently", "Members", "Track champion unlocks separately if desired." },
	{ "Court Cases", "One-time cases; no reset", "Members", "" },
	{ "Deep Sea Fishing events", "Random events; no fixed reset", "Members", "Includes the Travelling Merchant; see its row below for stock visits." },
	{ "Demon Flash Mob", "Hourly spawns; no personal reset", "Members", "" },
	{ "Effigy Incubator", "Monthly reset", "Members", "" },
	{ "Evil Tree", "Daily reset; spawns every 2 hours", "Free-to-play and members", "" },
	{ "Familiarisation", "Weekly reset (Wednesday)", "Members", "" },
	{ "Fish Flingers", "Daily ticket reset; games repeat", "Members", "" },
	{ "Giant Oyster", "Monthly reset", "Free-to-play and members", "Members-only rewards; check the guide for access details." },
	{ "Goblin raids", "Every 30 minutes; no personal reset", "Free-to-play and members", "" },
	{ "Goebie Supply Runs", "Daily reset; runs every 12 hours", "Members", "" },
	{ "God Statues", "Monthly reset", "Members", "" },
	{ "Guthixian Cache", "Daily reward reset; event hourly", "Members", "Daily experience cap applies." },
	{ "Herby Werby", "Weekly reset (Wednesday)", "Members", "" },
	{ "Jadinko hunting", "Weekly reset (Wednesday)", "Members", "" },
	{ "Meg", "Weekly reset (Wednesday)", "Members", "" },
	{ "Memory of Nomad", "Weekly reset (Wednesday)", "Members", "" },
	{ "Penguin Hide and Seek", "Weekly reset (Wednesday)", "Members", "" },
	{ "Phoenix Lair", "Daily reset", "Members", "" },
	{ "Premier Vault", "Monthly reset", "Premier members", "" },
	{ "Rune Goldberg Machine", "Daily reset", "Members", "" },
	{ "Runesphere", "Daily reward reset; event every few hours", "Members", "Daily reward cap applies." },
	{ "Rush of Blood", "Weekly reset (Wednesday); practice unlimited", "Members", "" },
	{ "Shooting Star", "Daily reward reset; event every 2 hours", "Free-to-play and members", "" },
	{ "Sinkholes", "Daily reset; event every 30 minutes", "Members", "" },
	{ "Skeletal Horror", "Weekly reset (Wednesday)", "Members", "" },
	{ "Tears of Guthix", "Weekly reset (Wednesday)", "Members", "Requires a quest point or 100,000 total experience since the last visit." },
	{ "The Pit", "Random; no personal reset", "Members", "" },
	{ "Treasure Trails", "Repeatable; no fixed reset", "Members", "Track clue tiers or collection goals separately if desired." },
	{ "Travelling Merchant", "Daily stock reset", "Members", "Accessed through [[Deep Sea Fishing]]." },
	{ "Troll Invasion", "Monthly reset", "Members", "" },
	{ "Wilderness Flash Events", "Daily reward reset; events hourly", "Members", "" },
	{ "Wilderness Warbands", "Daily reset; camps every 7 hours, up to 3 daily", "Members", "" },
	{ "Wisps of the Grove", "Weekly reset (Wednesday)", "Members", "" },
}

function p.render(frame)
	local out = {
		'{| class="wikitable sortable" id="dnd-tracker"',
		'! This period !! Activity !! Schedule !! Next reset !! Access !! Notes',
	}
	for _, activity in ipairs(activities) do
		local name, schedule, access, notes = unpack(activity)
		table.insert(out, '|-')
		table.insert(out, '| || [[' .. name .. ']] || ' .. schedule .. ' || || ' .. access .. ' || ' .. notes)
	end
	table.insert(out, '|}')
	return table.concat(out, '\n')
end

return p