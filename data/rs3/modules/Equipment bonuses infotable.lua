	-- <nowiki>
local p = {}
local infobox = require('Module:Infobox')
local yesno = require("Module:Yesno")
local Exchange = require("Module:Exchange")._price_simple
local Coins = require("Module:Coins")._amount
local AddCommas = require("Module:Addcommas")._add
local skillClickpic = require("Module:Skill clickpic")._main
local onmain = require("Module:Mainonly").on_main
local editbutton = require('Module:Edit button')
local edit = editbutton("'''?''' (edit)")

local imagearg, imageargmain, imageargalt

-- Accepted rowTypes
local rowTypes = {
    melee = "[[File:Melee-icon.png|x26px|link=Melee]] [[Melee]]",
    ['melee icon'] = "[[File:Melee-icon.png|x26px|link=Melee]]",
    ranged = "[[File:Ranged-icon.png|x26px|link=Ranged]] [[Ranged]]",
    ['ranged icon'] = "[[File:Ranged-icon.png|x26px|link=Ranged]]",
    magic = "[[File:Magic-icon.png|x26px|link=Magic]] [[Magic]]",
    ['magic icon'] = "[[File:Magic-icon.png|x26px|link=Magic]]",
    necromancy = "[[File:Necromancy-icon.png|x26px|link=Necromancy]] [[Necromancy]]",
    ['necromancy icon'] = "[[File:Necromancy-icon.png|x26px|link=Necromancy]]",
    hybrid = "[[File:Combat swords.png|x26px|link=Armour#Hybrid]] [[Armour#Hybrid|Hybrid]]",
    ['hybrid icon'] = "[[File:Combat swords.png|x26px|link=Armour#Hybrid]]",
    all = "[[File:Combat swords.png|x26px|link=Armour#All]] [[Armour#All|All]]",
    ['all icon'] = "[[File:Combat swords.png|x26px|link=Armour#All]]",
    ['prevents attack'] = "Prevents attack",
    none = " - "
}

-- Accepted headerTypes
local headerTypes = {
    melee = "[[File:Attack.png|x34px|link=Melee]]<br>Item",
    ranged = "[[File:Ranged.png|x34px|link=Ranged]]<br>Item",
    magic = "[[File:Magic.png|x34px|link=Magic]]<br>Item",
    necromancy = "[[File:Necromancy.png|x34px|link=Necromancy]]<br>Item",
    hybrid = "[[File:Combat swords.png|x34px|link=Armour#Hybrid]]<br>Item",
    all = "[[File:Combat swords.png|x34px|link=Armour#All]]<br>Item",
    mixed = "Item",
    none = "Item"
}

-- Accepted weapon styles
local styles = {
    stab = "'''Stab'''",
    stabbing = "'''Stab'''",
    crush = "'''Crush'''",
    crushing = "'''Crush'''",
    slash = "'''Slash'''",
    slashing = "'''Slash'''",
    arrow = "'''Arrow'''",
    arrows = "'''Arrow'''",
    bolt = "'''Bolt'''",
    bolts = "'''Bolt'''",
    thrown = "'''Thrown'''",
    spell = "'''Spell-<br>casting'''",
    spells = "'''Spell-<br>casting'''",
    ['spell-casting'] = "'''Spell-<br>casting'''",
    necromancy = "'''Necromancy'''",
    none = "'''None'''"
}

-- Row args that are summed and displayed in the totals row (if present)
local totalArgs = {
	dmg = 0,
	armour = 0,
	life = 0,
	prayer = 0,
	strength = 0,
	ranged = 0,
	magic = 0,
	necromancy = 0,
    abilDmg = 0,
}

-- Images used for slot display
local slot_images = {
	head = '[[File:Head slot.png|link=Head slot]]',
	ammo = '[[File:Ammo slot.png|link=Ammunition slot]]',
	neck = '[[File:Neck slot.png|link=Neck slot]]',
	back = '[[File:Back slot.png|link=Back slot]]',
	['main hand weapon'] = '[[File:Main hand slot.png|link=Main hand slot]]',
	['2h weapon'] = '[[File:2h slot.png|link=Two-handed slot]]',
	torso = '[[File:Torso slot.png|link=Torso slot]]',
	['off-hand'] = '[[File:Off-hand slot.png|link=Off-hand slot]]',
	['off-hand weapon'] = '[[File:Off-hand slot.png|link=Off-hand slot]]',
	legs = '[[File:Legs slot.png|link=Legs slot]]',
	hands = '[[File:Gloves slot.png|link=Hands slot]]',
	feet = '[[File:Feet slot.png|link=Feet slot]]',
	ring = '[[File:Ring slot.png|link=Ring slot]]',
	aura = '[[File:Aura slot.png|link=Aura slot]]',
	pocket = '[[File:Pocket slot.png|link=Pocket slot]]',
	sigil = '[[File:Sigil slot.png|link=Sigil slot]]',
	e = 'None'
}

local function isnotempty(s)
    return not (s == nil or s == "")
end

local function isempty(s)
	return not isnotempty(s)
end

local function cleanItemName(argstable, isBucket)
	local pattern = isBucket and "%[%[([^|%]]+)" or "%[%[([^|#%]]+)"

	return (argstable.ge and (argstable.ge:match(pattern) or argstable.ge))
        or (argstable.name and (argstable.name:match(pattern) or argstable.name))
end

function imagearg(f)
	local height = 250
	if not infobox.isDefined(f) then
		return nil
	end
	f = tostring(f)
	if string.lower(f) == 'no' then
		return nil
	end
	f = f:gsub('[Ff]ile:',''):gsub('{{!}}','|')
	f = mw.text.split(f, '|')[1]
	if mw.title.new(f, 'File').exists == true then
		return string.format('[[File:%s|x%spx|frameless|alt=%s: %s equipped by a player]]', f, height, f, mw.title.getCurrentTitle().text)
	else
		local g = f:gsub('%.png',''):gsub(' equipped','')
		return string.format('[[File:%s|x%spx|frameless|alt=Missing image for %s – help by uploading one!]][[Category:Needs equipped image]]', f, height, g)
	end
end
function imageargmain(i, m, f)
	if not infobox.isDefined(i) then
		if infobox.isDefined(m) then
			return imagearg(m)
		end
		return edit
	end
	return imagearg(i)
end
function imageargalt(i, m, f)
	if not infobox.isDefined(i) then
		if infobox.isDefined(f) then
			return imagearg(f)
		end
		return edit
	end
	return imagearg(i)
end

function p.main(frame)
    local frameargs = frame:getParent().args
    local htmltable = mw.html.create("table") -- The output of this module
    local tblrow
    local tblcell
    local totalPrice = 0                      -- Sum of the individual prices
    local totalspanrange = 6                  -- Minimum spanrange of the label in case the totals parameter is used (attr + style cols)
    local imageRowsSpan = 2                   -- Row span counter (including 2 header rows)
    local imageCells = {}                     -- Image table cell(s)
    local bucketmismatch = false                 -- Template data disagrees with Bucket data
    local bucketerror = false                    -- Error occurred while retrieving bucket data
    local totalsmismatch = false              -- Template data for totals row disagrees with auto-calc'd sum

    -- Create the tabel header
    --[[Parameters used (variable type)     [note]
        class / type    (string)            [@mandatory]
        noinv           (yes/no)            [@optional, default is no, if yes the rowspan of the class header is 1 otherwise its 2]
        skill           (string)            [@optional, accepted values are those for Module:Skill clickpic]
        skill2          (string)            [@optional, accepted values are those for Module:Skill clickpic]
        noweapon        (yes/no)            [@optional, default is no, if yes hides the weapons stats]
        nostyle			(yes/no)			[@optional, default is no, if yes hides the style bonuses]
        noattr			(yes/no)			[@optional, default is no, if yes hides the attribute bonuses]
        nosumstats      (yes/no)            [@optional, default is no, if yes will not automatically sum stat values to display in totals row]
        price           (ge/number/string)  [@optional, ge is the the string "ge", ge and number are preferred so it adds to the totalprice]
        image           (string)            [@optional, image is given by the form "image name.png"]
        image2          (string)            [@optional]
        image3          (string)            [@optional]
        rows            (number)            [@optional, only affects image, image2, and image3]
        tot             (number)            [@optional, only affects image, image2, and image3]
        sortable        (yes/no)            [@optional]
        typeicon        (yes/no)            [@optional, default is no, if yes will force rows' "type" values to only show icons]
		showmembers		(yes/no)			[@optional]
		showdegradable  (yes/no)			[@optional]
		showtier        (yes/no)			[@optional]
		showreqs        (yes/no)			[@optional]
    ]]

    htmltable
        :addClass("wikitable sticky-header infotableBonuses")
        :css("text-align", "center")

        -- Make first header row
        tblrow = htmltable:tag("tr")

            -- Set the header class
            tblcell = tblrow:tag("th")
                :attr("rowspan", "2")
                :wikitext(headerTypes[string.lower(frameargs.class or frameargs.type or "")] or ("''Type Unknown<br><small>[" .. tostring(mw.uri.fullUrl( mw.title.getCurrentTitle().prefixedText, "action=edit")) .. " edit]</small>''"))
                :attr("data-sort-type", "text")
                if not yesno(frameargs.noinv) then
                    tblcell
                        :attr("colspan", "2")
                end

			if yesno(frameargs.showmembers) then
				tblrow
					:tag("th")
						:attr("rowspan", "2")
                        :wikitext("Members")
				totalspanrange = totalspanrange + 1
			end
			if yesno(frameargs.showtier) then
				tblrow
					:tag("th")
						:attr("rowspan", "2")
                        :wikitext("[[Equipment tier|Tier]]")
				totalspanrange = totalspanrange + 1
			end
			if yesno(frameargs.showreqs) then
				tblrow
					:tag("th")
						:attr("rowspan", "2")
                        :wikitext("Reqs")
				totalspanrange = totalspanrange + 1
			end

            -- Add extra type column if the header class is mixed
            if string.lower(frameargs.class or frameargs.type or "") == "mixed" then
                tblrow
                    :tag("th")
                        :attr("rowspan", "2")
                        :attr("data-sort-type", "text")
                        :wikitext("Type")
                    :done()
                totalspanrange = totalspanrange + 1
            end

            -- Add extra skill column
            if isnotempty(frameargs.skill) then
				local skill_th = tblrow:tag("th")
                skill_th
                        :attr("rowspan", "2")
                        :attr("data-sort-type", "number")
				if not yesno(frameargs.skill) then
					-- Not a 'yes' value
					skill_th
                        	:css("vertical-align", "bottom")
							:wikitext(skillClickpic(frameargs.skill or ""))
                            :tag("br")
                            :done()
				end
				skill_th
                        :tag("span")
                            :css("font-size", "90%")
                            :wikitext("Level")
                        :done()
                    :done()
                totalspanrange = totalspanrange + 1
            end

            -- Add extra skill2 column
            if isnotempty(frameargs.skill2) then
                tblrow
                    :tag("th")
                        :attr("rowspan", "2")
                        :attr("data-sort-type", "number")
                        :css("vertical-align", "bottom")
                        :wikitext(skillClickpic(frameargs.skill2 or ""))
                            :tag("br")
                            :done()
                        :tag("span")
                            :css("font-size", "90%")
                            :wikitext("Level")
                        :done()
                    :done()
                totalspanrange = totalspanrange + 1
            end

            -- Show/hide weapon stats
            if not yesno(frameargs.noweapon) then
                tblrow
                    :tag("th")
                        :attr("title", "Attacking style")
                        :attr("rowspan", "2")
                        :wikitext("Style")
                    :done()
                    :tag("th")
                        :attr("title", "Equipment slot")
                        :attr("rowspan", "2")
                        :wikitext("Slot")
                    :done()
                    :tag("th")
                        :attr("title", "Weapon attack range")
                        :attr("data-sort-type", "number")
                        :attr("rowspan", "2")
                        :wikitext("Range")
                    :done()
                    :tag("th")
                        :attr("title", "Weapon accuracy")
                        :attr("data-sort-type", "number")
                        :attr("rowspan", "2")
                        :wikitext("Acc")
                    :done()
                    :tag("th")
                        :attr("title", "Weapon ability damage")
                        :attr("data-sort-type", "number")
                        :attr("rowspan", "2")
                        :wikitext("[[Ability damage]]")
                    :done()
                totalspanrange = totalspanrange + 6
            end

            -- Add atribute columns
            if not yesno(frameargs.noattr) then
	            tblrow
	                :tag("th")
	                    :attr("colspan", "3")
	                    :attr("title", "Determines their character's endurance determined by their armour rating, life point boost, and prayer bonus")
	                    :wikitext("Attribute")
	                :done()
	        end

            -- Add style bonuses columns
			if not yesno(frameargs.nostyle) then
				tblrow
					:tag("th")
						:attr("colspan", "4")
						:wikitext("Style&nbsp;bonus")
					:done()
            end

            -- Add price column
            if yesno(frameargs.price) then
                tblrow
                    :tag("th")
                        :attr("rowspan", "2")
                        :attr("data-sort-type", "number")
                        :wikitext("Price")
                    :done()
                totalspanrange = totalspanrange + 1
            end

			if yesno(frameargs.showdegradable) then
				tblrow
					:tag("th")
						:attr("rowspan", "2")
                        :wikitext("Degrades")
				totalspanrange = totalspanrange + 1
			end

            -- Add image column
            if frameargs.image ~= 'no' and (isnotempty(frameargs.image) or isnotempty(frameargs.image2) or isnotempty(frameargs.image3) or isnotempty(frameargs.maleimage) or isnotempty(frameargs.femaleimage) or isnotempty(frameargs.altimage)) then
	            table.insert(imageCells, tblrow
	                :tag("th")
	                    :addClass('unsortable')
	                    :css("width", "125px")
	                    :css("vertical-align", "center")
	                    :wikitext(imageargmain(frameargs.image, frameargs.maleimage, frameargs.femaleimage))
                )
                tblrow:done()

	            -- Add image2 comlumn
	            table.insert(imageCells, tblrow
	                :tag("th")
	                    :addClass('unsortable')
	                    :css("width", "125px")
	                    :css("vertical-align", "center")
	                    :wikitext(imageargalt(frameargs.image2, frameargs.maleimage, frameargs.femaleimage))
                )
                tblrow:done()

	            -- Add image3 comlumn
	            if isnotempty(frameargs.image3) or isnotempty(frameargs.altimage) then
	                table.insert(imageCells, tblrow
	                    :tag("th")
	                        :attr("rowspan", tostring(2 + tonumber(frameargs.rows or imageRowsSpan) + tonumber(frameargs.tot or 0)))
	                        :addClass('unsortable')
	                        :css("width", "125px")
	                        :css("text-align", "center")
	                        :css("vertical-align", "center")
	                        :wikitext(imagearg(frameargs.altimage or frameargs.image3))
                    )
                    tblrow:done()
	            end
			end

        -- Make second header row
        tblrow = htmltable:tag("tr")

            -- Add attribute and style bonuses columns
            if not yesno(frameargs.noattr) then
	            tblrow
	                :tag("th")
						:attr("data-sort-type", "number")
	                    :wikitext(skillClickpic("Defence"))
	                :done()
	                :tag("th")
						:attr("data-sort-type", "number")
	                    :wikitext(skillClickpic("Constitution"))
	                :done()
	                :tag("th")
						:attr("data-sort-type", "number")
	                    :wikitext(skillClickpic("Prayer"))
	                :done()
	            :done()
	        end
            if not yesno(frameargs.nostyle) then
	            tblrow
	                :tag("th")
						:attr("data-sort-type", "number")
	                    :wikitext("[[File:Attack-icon.png|20px|link=Melee]]")
	                :done()
	                :tag("th")
						:attr("data-sort-type", "number")
	                    :wikitext("[[File:Ranged-icon.png|20px|link=Ranged]]")
	                :done()
	                :tag("th")
						:attr("data-sort-type", "number")
	                    :wikitext("[[File:Magic-icon.png|20px|link=Magic]]")
	                :done()
	                :tag("th")
						:attr("data-sort-type", "number")
	                    :wikitext("[[File:Necromancy-icon.png|20px|link=Necromancy]]")
	                :done()
	            :done()
            end
        	if yesno(frameargs.noattr) or yesno(frameargs.nostyle) then
        		-- prevent mw-empty-elt from hiding the row and messing up the layout
        		tblrow:tag('th'):css('display','none')
        	end

        -- sortable
        if yesno(frameargs.sortable) then
            htmltable:addClass("sortable")
        end
    -- Header ends here

    -- Table rows are created here
    --[[Parameters used     (variable type)     [note]
            [all paramerers are @optional]
        totals          (yes/no)            [Default is no]
        label           (string)            [Only has an effect if totals is used]
        ge              (string)
        image           (string)            [Only works if the ge parameter is not used]
        name            (string)            [Only works if the ge parameter is not used]
        bucketname      (string)            [Override the name used in the Bucket query for stats]
        type            (string)            [Default is "-"]
        level/skill     (number/string)     [Default is "-"]
        level2/skill2   (number/string)     [Default is "-"]
        style           (string)            [Default is "-"]
        dmg             (number)            [Default is "-"]
        acc             (number)            [Default is "-"]
        armour          (number)            [Default is "-"]
        life            (number)            [Default is "-"]
        prayer          (number)            [Default is "-"]
        strength        (number)            [Default is "-"]
        ranged          (number)            [Default is "-"]
        magic           (number)            [Default is "-"]
        necromancy      (number)            [Default is "-"]
        price           (ge/number/string)  [ge only works if the ge parameter is used. ge and number are preferred if the totals prameter is used]
        priceimage      (string)            [can be used incase the ge parameter is not used but you want the price to add to the totalprice]
        dontaddtototal  (yes/no)            [default is no]
        nocoinstotals   (yes/no)            [default is no]
        ref             (string)
    ]]
    local argstables = {}
    local replacedrows = {}
    for rownum, j in ipairs(frameargs) do     -- Iterate in order over all frameargs with a integer key
        -- Parse the framearg j into a table of rowargs, j = {{Equipment bonuses inforow}}
        argstables[rownum] = {}
        local argstable = argstables[rownum]
        for argduo in j:gmatch("!(.-)!") do
            local argname = argduo:match("&(.-)&")
            local argvalue = argduo:match( "µ(.-)µ")
            if argvalue == "" then
                argvalue = nil
            end
            argstable[argname] = argvalue
        end

        -- Set up rowarg mapping to bucket fields
        if not (yesno(argstable.totals) or yesno(frameargs.bucket) or yesno(argstable.bucket)) then
			local bucketprops = {}

			bucketprops["type"] = "class"
			if yesno(frameargs.level) or yesno(frameargs.showreqs) then
				bucketprops["skill"] = "requirements"
			end
			if yesno(frameargs.showtier) then
				bucketprops["tier"] = "tier"
			end
			if not yesno(frameargs.noweapon) then
				bucketprops["style"] = "style"
				bucketprops["dmg"] = "damage"
				bucketprops["acc"] = "accuracy"
                bucketprops["abilDmg"] = "ability_damage"
                bucketprops["abilDmgDisp"] = "ability_damage_note"
                bucketprops["attackRange"] = "attack_range"
                bucketprops["slot"] = "slot"
			end
			if not yesno(frameargs.noattr) then
				bucketprops["armour"] = "armour"
				bucketprops["life"] = "lp"
				bucketprops["prayer"] = "prayer"
			end
			if not yesno(frameargs.nostyle) then
				bucketprops["strength"] = "strength"
				bucketprops["ranged"] = "ranged"
				bucketprops["magic"] = "magic"
				bucketprops["necromancy"] = "necromancy"
			end
			if yesno(frameargs.showdegradable) then
				bucketprops["degradable"] = "charges"
			end

			local bucketname = argstable.bucketname or cleanItemName(argstable, true)
			if isempty(bucketname) then
				mw.log("EQ Infotable Bucket error: Empty item name for row #" .. rownum)
				bucketerror = true
			else
				mw.log(bucketname)
				local t1 = os.clock()
				local result = bucket('infobox_bonuses')
					.select('page_name', 'page_name_sub', 'infobox_bonuses.json', 'infobox_item.is_members_only', 'infobox_item.item_name')
					.join('infobox_item', 'infobox_bonuses.page_name', 'infobox_item.page_name')
					.where(bucket.Or({'page_name', bucketname}, {'page_name_sub', bucketname}))
					-- .limit(10)
					.run()

				local t2 = os.clock()
				mw.log(string.format('EQ Infotable Bucket: %d, time: %.3f ms.', #result, (t2 - t1) * 1000))

				if #result == 0 then
					mw.log("EQ Infotable Bucket error: Ask failed for item:"..bucketname)
					bucketerror = true
				else
					-- prioritise results:
					--  1) Bucket (sub)object title or "Is variant of" match
					--  2) item name match
					--  3) first result (fallback)
					local resultNum
					do
						local fallbackResultNum
						for i = 1, #result do
							if result[i]["page_name_sub"] == bucketname then
								resultNum = i
								break
							elseif (fallbackResultNum == nil
								and result[i]["page_name"] == bucketname) then
								fallbackResultNum = i
							end
						end
						resultNum = resultNum or fallbackResultNum or 1
					end

					argstable.members = yesno(result[resultNum]["infobox_item.is_members_only"])
					if result[resultNum]["infobox_bonuses.json"] then
						result = mw.text.jsonDecode(result[resultNum]["infobox_bonuses.json"])
					end
					argstable.skill = argstable.skill or result.requirements

					for argname, propname in pairs(bucketprops) do
                        if tonumber(result[propname]) ~= nil then
                            result[propname] = tonumber(result[propname])
                        end

						if argstable[argname] == nil and result[propname] ~= 0 then
							argstable[argname] = result[propname]
						elseif argstable[argname] ~= nil and result[propname] ~= 0 then
							-- Only flag mismatches of numerical values if they differ by >= 1.0
							-- Allows rounding/truncation of decimal values to not flag
							-- This seems to have been a common practice when composing the
							-- older Infotables; remove if accurate values w/ decimals are preferred
							if (type(result[propname]) == "number" and math.abs(tonumber(argstable[argname]) - result[propname]) >= 1) or
							   (type(result[propname]) == "string" and not (argname == "style" or argname == "level") and result[propname]:lower() ~= argstable[argname]:lower() ) or
							   (argname == "style" and styles[string.lower(result[propname] or "")] ~= styles[argstable[argname]:lower()]) then
								bucketmismatch = true
								mw.log("EQ Infotable bucket warning: Row mismatch for parameter: " .. argname)
								mw.log("    Item name: " .. bucketname)
								mw.log("    Template value: " .. argstable[argname])
								mw.log("    bucket value: " .. (result[propname] or ""))
							end
						end
					end
				end
			end
		end

		-- Track number of rows for image spans
		imageRowsSpan = imageRowsSpan + 1

        -- Special processings for totals rows
        if yesno(argstable.totals) then
			-- Add extra row if the totals + label parameters are used
			if isnotempty(argstable.label) then
				imageRowsSpan = imageRowsSpan + 1
	            tblrow = htmltable:tag("tr")
	                :addClass("attribute-total sortbottom")
	                tblcell = tblrow:tag("th")
	                    :attr("rowspan", "2")
	                    :wikitext("Totals" .. ((argstable.ref and (" " .. argstable.ref)) or ""))
	                    if not yesno(frameargs.noinv) then
	                        tblcell
	                            :attr("colspan","2")
	                    end

	            tblrow
	                :tag("th")
	                    :attr("colspan", totalspanrange)
	                    :wikitext(argstable.label)
	                :done()
            end

            if not yesno(frameargs.nosumstats) then
	            -- Default totals args to their corresponding sum if not specified
	            for arg, sum in pairs(totalArgs) do
					if sum ~= 0 then
						if isempty(argstable[arg]) then
							argstable[arg] = sum
						elseif tonumber(argstable[arg]) ~= sum then
							totalsmismatch = true
							mw.log("EQ Infotable totals mismatch for parameter: " .. arg)
							mw.log("    Template: " .. argstable[arg])
							mw.log("    Calculated: " .. sum)
						end
					end
				end

				-- Default acc column to max value
				argstable.acc = 0
				for k = 1, rownum - 1 do
					if not replacedrows[k] and isempty(argstables[k].totals) then
						argstable.acc = math.max(argstable.acc, tonumber(argstables[k].acc) or 0)
					end
				end

				-- Default skill level columns to max values
				if isnotempty(frameargs.skill) or isnotempty(frameargs.skill2) then
					argstable.skill = 0
					argstable.skill2 = 0

					for k = 1, rownum - 1 do
						if not replacedrows[k] and isempty(argstables[k].totals) then
							local rowSkill = string.match(argstables[k].skill or argstables[k].level or "", "%d+")
							local rowSkill2 = string.match(argstables[k].skill2 or argstables[k].level2 or "", "%d+")
							argstable.skill = math.max(argstable.skill, tonumber(rowSkill) or 0)
							argstable.skill2 = math.max(argstable.skill2, tonumber(rowSkill2) or 0)
						end
					end
				end
			end
        else
	        -- Support replacing previous rows with the current row's stats when summing totals
	        if isnotempty(argstable.replacerow) then
				local replacenum = tonumber(argstable.replacerow)
				if replacenum == nil or replacenum < 1 or replacenum >= rownum or isnotempty(argstables[replacenum].totals) then
					mw.log("EQ Infotable error: Invalid replacerow value for item: " .. cleanItemName(argstable))
					mw.log("    replacerow="..replacenum.."; rownum="..rownum.."; numrows="..#frameargs)
				else
					local replacedargs = argstables[replacenum]
					replacedrows[replacenum] = true

					-- Subtract replaced row's additions to the totals
					for arg, sum in pairs(totalArgs) do
						local argNum = tonumber(replacedargs[arg])
						if argNum ~= nil then
							totalArgs[arg] = sum - argNum
						end
					end

					-- Price is handled separately; subtract it if it's a number (from GE or as given)
					local argPrice = tonumber(replacedargs.price)
					if argPrice ~= nil then
						totalPrice = totalPrice - argPrice
					end
				end
			end
			if not yesno(frameargs.nosumstats) and not yesno(argstable.dontaddtototal) then
				-- Non-totals row; add totals args to their corresponding sum if a numerical value is specified
				for arg, sum in pairs(totalArgs) do
					local argNum = tonumber(argstable[arg])
					if argNum ~= nil then
						totalArgs[arg] = sum + argNum
					end
				end
			end
		end

        -- Create a new inforow
        tblrow = htmltable:tag("tr")

            -- Special handling for a totals row
            if yesno(argstable.totals) then
                tblrow
                    :addClass("attribute-total sortbottom")

	            -- Add the totals text cell (if not already added above due to requested label)
	            if isempty(argstable.label) then
	                tblcell = tblrow:tag("th")
	                    :wikitext("Totals" .. ((argstable.ref and (" " .. argstable.ref)) or ""))
	                    if not yesno(frameargs.noinv) then
	                        tblcell
	                            :attr("colspan","2")
	                    end
                end
            else
				-- Italicise rows that will not add to the total stats
				if isnotempty(argstable.dontaddtototal) then
					tblrow:css("font-style", "italic")
				end

	            -- Add the item image and name cells
	            if isnotempty(argstable.ge) then
					local itemLink = argstable.ge:match("^%[%[") and argstable.ge or ("[[" .. argstable.ge .. "]]")
					local itemName = cleanItemName(argstable)
	                tblrow
	                    :tag("td")
	                        :wikitext("[[File:" .. itemName .. ".png|link=" .. itemName .. "]]")
	                        :addClass("inventory-image")
	                    :done()
	                    :tag("td")
	                        :css("text-align", "left")
	                        :wikitext(itemLink .. ((argstable.ref and (" " .. argstable.ref)) or ""))
	                    :done()
	            elseif isnotempty(argstable.image) then
	                tblrow
	                    :tag("td")
	                        :wikitext(argstable.image:find("[[File:", 1, true) and argstable.image or ("[[File:" .. argstable.image .. "]]"))
	                    :done()
	                if isnotempty(argstable.name) then
	                    tblrow
	                        :tag("td")
	                            :css("text-align", "left")
	                            :wikitext(argstable.name .. ((argstable.ref and (" " .. argstable.ref)) or ""))
	                        :done()
	                end
	            elseif isnotempty(argstable.name) then
	                tblrow
	                    :tag("td")
	                        :css("text-align", "left")
	                        :wikitext(argstable.name .. ((argstable.ref and (" " .. argstable.ref)) or ""))
	                    :done()
	            end
            end

            -- add members column
			if yesno(frameargs.showmembers) then
				local val = argstable.members and "[[File:P2P icon.png|30px|link=Members]]" or "[[File:F2P icon.png|30px|link=Free-to-play]]"
				if yesno(argstable.totals) then
					val = "-"
				end
				tblrow
					:tag("td")
						:attr("data-sort-value", argstable.members and 1 or 0)
						:wikitext(val)
			end
            -- add members column
			if yesno(frameargs.showtier) then
				local val = argstable.tier
				if yesno(argstable.totals) then
					val = "-"
				end
				tblrow
					:tag("td")
						:attr("data-sort-value", val)
						:wikitext(val)
			end
			if yesno(frameargs.showreqs) then
				local val = argstable.skill
				if yesno(argstable.totals) then
					val = "-"
				end
				tblrow
					:tag("td")
						:wikitext(val)
			end

            -- Add the type cell incase the header class is mixed
            if string.lower(frameargs.class or frameargs.type or "") == "mixed" then
				local argType = string.lower(argstable.type or "")
				if yesno(frameargs.typeicon) and isnotempty(argType) and not argType:match(" icon$") then
					argType = argType .. " icon"
				end

                tblrow
                    :tag("td")
	                    :css("text-align", "left")
                        :wikitext(rowTypes[argType] or argstable.type or "-")
                    :done()
            end

            -- Add the skill cell
            if isnotempty(frameargs.skill) then
				local skillArg = argstable.level or argstable.skill
                tblrow
                    :tag("td")
                        :wikitext(skillArg or "-")
                        :attr("data-sort-value", skillArg or 0)
                    :done()
            end

            -- Add the skill2 cell
            if isnotempty(frameargs.skill2) then
				local skill2Arg = argstable.level2 or argstable.skill2
                tblrow
                    :tag("td")
                        :wikitext(skill2Arg or "-")
                        :attr("data-sort-value", skill2Arg or 0)
                    :done()
            end

            -- Show/hide weapon stats
            if not yesno(frameargs.noweapon) then
                tblrow
                    :tag("td")
                        :addClass("attribute-value")
                        :wikitext(styles[string.lower(argstable.style or "")] or argstable.style or "-")
                    :done()
                    :tag("td")
                        :addClass("attribute-value")
                        :wikitext(slot_images[string.lower(argstable.slot or "")] or argstable.slot or "-")
                    :done()
                    :tag("td")
                        :addClass("attribute-value")
                        :wikitext(argstable.attackRange or "-")
                        :attr("data-sort-value", argstable.attackRange or 0)
                    :done()
                    :tag("td")
                        :wikitext(argstable.acc or "-")
                        :attr("data-sort-value", argstable.acc or 0)
                    :done()
                    :tag("td")
                        :wikitext(argstable.abilDmgDisp or argstable.abilDmg or "-")
                        :attr("data-sort-value", argstable.abilDmg or 0)
                    :done()
            end

            -- Add atribute and style bonuses cells
            if not yesno(frameargs.noattr) then
	            tblrow
	                :tag("td")
	                    :addClass("attribute-value")
	                    :wikitext(argstable.armour or "-")
	                :done()
	                :tag("td")
	                    :addClass("attribute-value")
	                    :wikitext(argstable.life or "-")
	                :done()
	                :tag("td")
	                    :addClass("attribute-value")
	                    :wikitext(argstable.prayer or "-")
	                :done()
	            :done()
	        end
            if not yesno(frameargs.nostyle) then
				tblrow
	                :tag("td")
	                    :wikitext(argstable.strength or "-")
	                    :attr("data-sort-value", argstable.strength or 0)
	                :done()
	                :tag("td")
	                    :wikitext(argstable.ranged or "-")
	                    :attr("data-sort-value", argstable.ranged or 0)
	                :done()
	                :tag("td")
	                    :wikitext(argstable.magic or "-")
	                    :attr("data-sort-value", argstable.magic or 0)
	                :done()
	                :tag("td")
	                    :wikitext(argstable.necromancy or "-")
	                    :attr("data-sort-value", argstable.necromancy or 0)
	                :done()
				:done()
            end
            -- Add price cell
            if yesno(frameargs.price) then

                -- Total price
                if (yesno(argstable.totals) and argstable.price == nil) or string.lower(argstable.price or "") == "total" then
                    if isnotempty(argstable.priceimage) then
                        tblrow
                            :tag("td")
                                :css("text-align", "right")
                                :wikitext((argstable.priceimage and ("[[File:" .. argstable.priceimage .. "]] ")) or "")
                                :tag("span")
                                    :addClass("coins coins-pos")
                                    :wikitext(AddCommas(totalPrice))
                                :done()
                            :done()
                    else
                        tblrow
                            :tag("td")
                                :css("text-align", "right")
                                :wikitext(Coins(totalPrice, false))
                            :done()
                    end

                -- GE price, this is the default value if no price parameter was given
                elseif argstable.price == nil or string.lower(argstable.price or "") == "ge" then
                    -- Check if the item exist on the GE
                    local itemName = cleanItemName(argstable)
                    local gePrice = Exchange(itemName)
                    if gePrice then
                    	argstable.price = gePrice
                        if not yesno(argstable.dontaddtototal) then
                            totalPrice = totalPrice + argstable.price
                        end
                        tblrow
                            :tag("td")
                                :css("text-align", "right")
                                :wikitext(Coins(argstable.price, false))
                            :done()
                    elseif string.lower(argstable.price or "") == "ge" then
                        tblrow
                            :tag("td")
                                :tag("span")
                                    :css("color", "red")
                                    :wikitext("Item does not exist on the [[Grand Exchange|")
                                        :tag("span")
                                            :css("color", "darkred")
                                            :wikitext("Grand Exchange")
                                        :done()
                                    :wikitext("]]")
                                :done()
                            :done()
                    else
                        tblrow
                            :tag("td")
                                :wikitext("-")
                            :done()
                    end

                -- If the price parameter is just a number
                elseif tonumber(argstable.price) ~= nil then
                    if not yesno(argstable.dontaddtototal) then
                        totalPrice = totalPrice + tonumber(argstable.price)
                    end
                    if argstable.priceimage == nil then
                        tblrow
                            :tag("td")
                                :css("text-align", "right")
                                :wikitext(Coins(tonumber(argstable.price)))
                            :done()
                    else
                        tblrow
                            :tag("td")
                                :css("text-align", "right")
                                :wikitext((argstable.priceimage and ("[[File:" .. argstable.priceimage .. "]] ")) or "")
                                :tag("span")
                                    :addClass("coins coins-pos")
                                    :wikitext(AddCommas(tonumber(argstable.price)))
                                :done()
                            :done()
                    end

                -- If the price parameter is a non recognized value
                else
                    tblrow
                        :tag("td")
                            :css("text-align", "right")
                            :wikitext(argstable.price)
                        :done()
                end
            end

			if yesno(frameargs.showdegradable) then
				local val = isnotempty(argstable.degradable) and "[[File:Yes check.svg|20px|link=]]" or "[[File:X mark.svg|20px|link=]]"
				if yesno(argstable.totals) then
					val = "-"
				end
				tblrow
					:tag("td")
						:attr("data-sort-value", isnotempty(argstable.degradable) and 1 or 0)
						:wikitext(val)
			end
        -- Inforow ends here
    end

    -- Finalise rowspans for image cell(s)
    for _, cell in ipairs(imageCells) do
		cell:attr("rowspan", tostring(imageRowsSpan))
	end

    -- Table is complete here
    local retval = tostring(htmltable)

    -- Various tracking cats to monitor errors/incorrect values
    if onmain() then
		local cats = ""
	    if bucketerror then
			-- cats = cats .. "[[Category:Pages with script errors]]"
		end
		if bucketmismatch then
			cats = cats .. "[[Category:Pages with eq infotables using values that differ from bucket]]"
		end
		if totalsmismatch then
			cats = cats .. "[[Category:Pages with eq infotables having incorrect totals]]"
		end
		if frameargs.image ~= 'no' then
			if not infobox.isDefined(frameargs.maleimage) then
				cats = cats .. "[[Category:Needs male equipped image]]"
			end
			if not infobox.isDefined(frameargs.femaleimage) then
				cats = cats .. "[[Category:Needs female equipped image]]"
			end
		end

		retval = retval .. cats
	end

    return retval
end

return p
-- </nowiki>