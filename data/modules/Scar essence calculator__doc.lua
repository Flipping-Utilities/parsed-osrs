{{Documentation}}
This module powers [[Calculator:Scar essence mine]], which works out the materials needed to craft a given number of runes using runic extracts from the [[Scar essence mine]]. It is called from [[Calculator:Scar essence mine/Template]] and reads its inputs from that template's parameters.

== Usage ==
<code><nowiki>{{#invoke:Scar essence calculator|main}}</nowiki></code>

{| class="wikitable"
! Parameter !! Description
|-
| <code>Rune_Input</code> || The rune to craft, for example <code>Air rune</code>. Shows a prompt if empty or unrecognised.
|-
| <code>Amount_Input</code> || Number of runes wanted.
|-
| <code>Level_Input</code> || [[Runecraft]] level, used for the base runes per essence. Defaults to 99.
|-
| <code>Outfit_Input</code> || Number of [[Raiments of the Eye]] pieces worn, from 0 to 4.
|-
| <code>Lantern_Input</code> || [[Abyssal lantern]] logs: <code>None</code>, <code>Willow/Redwood</code>, <code>Blisterwood</code> or <code>Magic</code>.
|}

== Calculations ==
* Runes per essence is the base rate at the player's level multiplied by (1 + outfit bonus + lantern bonus), plus the extract's bonus runes. The outfit gives 10% per piece (60% with all four) and the lantern gives 5%, 10% or 20% (blisterwood applies to blood runes only). These bonuses apply to base runes only, and the random round-up on the outfit is averaged.
* Essence needed is the requested amount divided by runes per essence, rounded up. The crafted total includes the overflow.
* One extract is needed per essence, except sunfire runes, which need one twisted extract per base rune crafted. Coins are the extract price multiplied by the number of extracts.
* Each pure essence costs 2 tainted essence and each extract costs 1. A [[tainted essence chunk]] is worth 5 tainted essence, and the total is rounded up.
* Sunfire runes also need one fire rune and one [[sunfire splinters|sunfire splinter]] per essence. Aether runes need one soul rune per essence and one [[aether catalyst]] per rune crafted, including bonus runes.
* Combination runes need one elemental rune per essence, from either of the two types that make the rune. [[Binding necklace|Binding necklaces]] are assumed to be used, so the calculator does not list them.