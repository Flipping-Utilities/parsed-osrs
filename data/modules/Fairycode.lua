local p = {}

--[[ fairy code -> location description
	All words in a title appear in the fairy ring interface, either in the 
	travel log, or below the current dialled code. The search in that interface 
	can find location based on words from either place. 
	When the travel log and below the dialled code have significantly different 
	text, put both separated by a dash.
]]
local locations = {
	-- A locations
	--AIP
	AIQ = "Asgarnia: Mudskipper Point",
	AIR = "Islands: South-east of Ardougne",
	AIS = "Varlamore: Auburn Valley",
	AJP = "Varlamore: Avium Savannah",
	AJQ = "Dungeons: Cave south of Dorgesh-Kaan",
	AJR = "Fremennik Province: Fremennik Slayer Cave",
	AJS = "Islands: Penguins near Miscellania.",
	AKP = "Kharidian Desert: Necropolis",
	AKQ = "Kandarin: Piscatoris Hunter area",
	AKR = "Great Kourend: Hosidius Vinery",
	AKS = "Feldip Hills: Jungle Hunter area",
	ALP = "Fremennik Province: (Island) Lighthouse",
	ALQ = "Morytania: Haunted Woods east of Canifis",
	ALR = "Other Realms: Abyssal Area",
	ALS = "Kandarin: McGrubor's Wood",
	
	-- B Locations
	BIP = "Islands: River Salve - South-west of Mort Myre",
	BIQ = "Kharidian Desert: Near the Kalphite Hive",
	--BIR
	BIS = "Kandarin: Ardougne Zoo - Unicorns",
	BJP = "Islands: Isle of Souls",
	--BJQ
	BJR = "Other Realms: Realm of the Fisher King",
	BJS = "Islands: Near Zul-Andra",
	BKP = "Feldip Hills: South of Castle Wars",
	BKQ = "Other Realms: Enchanted Valley",
	BKR = "Morytania: Mort Myre Swamp, south of Canifis",
	BKS = "Other Realms: Zanaris",
	BLP = "Dungeons: Mor Ul Rek - TzHaar area",
	BLQ = "Other Realms: Yu'biusk",
	BLR = "Kandarin: Legends' Guild",
	BLS = "Kebos Lowlands: South of Mount Quidamortem",
	
	-- C Locations
	CIP = "Islands: Miscellania",
	CIQ = "Kandarin: North-west of Yanille",
	CIR = "Kebos Lowlands: South of Mount Karuulm - North-east of the Farming Guild",
	CIS = "Great Kourend: North of the Arceuus Library",
	--CJP
	CJQ = "Islands: The Great Conch",
	CJR = "Kandarin: Sinclair Mansion",
	--CJS
	CKP = "Other Realms: Cosmic entity's plane",
	CKQ = "Varlamore: Aldarin",
	CKR = "Karamja: South of Tai Bwo Wannai Village",
	CKS = "Morytania: Canifis",
	CLP = "Islands: South of Draynor island",
	--CLQ
	CLR = "Islands: Ape Atoll",
	CLS = "Islands: Hazelmere's home",
	
	-- D Locations
	DIP = "Other Realms: (Sire Boss) Abyssal Nexus",
	DIQ = "Player-owned house", -- This is only the text below the dialled code. Update it to combine all words from travel log and below the dialled code.
	DIR = "Other Realms: Gorak's Plane",
	DIS = "Misthalin: Wizards' Tower",
	DJP = "Kandarin: Tower of Life",
	--DJQ
	DJR = "Great Kourend: Chasm of Fire",
	--CJS
	DKP = "Karamja: Gnome Glider - South of Musa Point",
	--DKQ
	DKR = "Misthalin: Edgeville, Grand Exchange",
	DKS = "Fremennik Province: Polar Hunter area",
	DLP = "Islands: Grimstone",
	DLQ = "Kharidian Desert: North of Nardah",
	DLR = "Islands: Poison Waste south of Isafdar",
	DLS = "Dungeons: Myreque hideout under The Hollows"
}

function escape_special_characters_to_html(str)
	local escaped_str = ""
	for i = 1, #str, 1 do
		local chr = string.sub(str,i,1)
		local escaped_chr = (string.match(chr,"%a")) and chr or string.format("&#%s;",string.byte(str,i)) -- preserve letters, but replace all other characters by the html &#{dec}; type escaped character
		escaped_str = escaped_str .. escaped_chr
	end
	return escaped_str
end


-- {{Fairycode}} entrance
function p.code(frame)
	local args = frame:getParent().args
	
	mw.logObject(args)
	local code = args[1]
	
	return p._code(code)
end

-- Module entrance
function p._code(code)
	assert(code, 'No fairycode provided')
	
	local first = string.upper( string.sub(code, 1, 1) )
	local second = string.upper( string.sub(code, 2, 2) )
	local third = string.upper( string.sub(code, 3, 3) )
	if first == '' or second == '' or third == '' then error('Missing one or more code letters') end
	
	local location_title = locations[string.upper(code)]
	
	local formattedCode
	if (location_title == nil) then -- fallback to un-annotated fairy code if its a new code missing from the above dictionary
		formattedCode = string.format(
			'<span class="fairycode"><b>%s</b><b>%s</b><b>%s</b></span>', 
			first, second, third
		)
	else
		local title_escaped = escape_special_characters_to_html(location_title)
		local aria_label_escaped = escape_special_characters_to_html(
			string.format(
				"%s %s %s, %s", -- the three letters are spaced out so screen readers will read separately
				first, second, third, location_title
			)
		) 
		formattedCode = string.format(
			'<abbr title="%s" aria-label="%s" tabindex="0"><span class="fairycode"><b>%s</b><b>%s</b><b>%s</b></span></abbr>',
			title_escaped, aria_label_escaped, first, second, third
		)
	end
	
	return formattedCode
end

return p