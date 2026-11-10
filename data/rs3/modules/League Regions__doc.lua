This module can be used to get regions for specific page names (page_name) while aggregating them from multiple buckets into a single column. Use the module by invoking it directly in a DPL query table like this as an example (see source code of this page):
<syntaxhighlight lang="html5">
<dpl>
  namespace = 
  uses = Template:Thieving info
  includematch = /\|\s*type\s*=\s*[pP]ickpocket/s
  includenotmatch = /\|\s*tool\s*=\s*.+[bB]lackjack/s
  category = Thievable entities
  notcategory = New Varrock
  notcategory = Thieves' Guild
  include = {Thieving info}:name:level:xp:stun:damage:
  table = class="wikitable sticky-header sortable text-align-right align-center-1 align-left-2 align-left-6 autosort=2-a",-,colspan="2" data-sort-type="string" | NPC,Level,XP,Stun time,Damage,{{CurrentLeague}}
  tablerow = {{#if:{{PROTECTIONEXPIRY:edit|File:%PAGE% icon.png}}¦data-sort-value="%PAGE%" {{plinkt¦%PAGE%¦pic=%PAGE% icon¦size=29x29}}¦{{#if:{{PROTECTIONEXPIRY:edit|File:%PAGE% chathead.png}}¦data-sort-value="%PAGE%" {{plinkt¦%PAGE%¦pic=%PAGE% chathead¦size=29x29}}¦{{NA¦¦data-sort=%PAGE%}}{{!}}{{!}}[[%PAGE%]]}}}},{{scm¦Thieving}} %%,{{#if:%%|%%|<i>unknown</i>}},{{#if:%%|%%|<i>unknown</i>}},{{#if:%%|%%|<i>unknown</i>}},{{LRIcon|{{#invoke:League Regions|main|%PAGE%|infobox_npc|infobox_monster}}}}
</dpl>
</syntaxhighlight>

Two things to add to existing tables:
1. Add a blank column to the table. In the example above, it was added with an extra `:` at the end of the include.
2. Add the module invoke to the table, specifically this line: <syntaxhighlight lang="html5">{{LRIcon|{{#invoke:League Regions|main|%PAGE%|infobox_npc|infobox_monster}}}}</syntaxhighlight>

The module takes 2 parameters:
1. The page name to aggregate league regions from.
2. The buckets to target to gather league regions from.

So Man|infobox_npc|infobox_monster would aggregate the league regions for Man from the NPC and Monster Infoboxes.