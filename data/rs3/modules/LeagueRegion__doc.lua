{{Documentation}}

==League Region Helper==
 This is the helper module for the Leagues Gadget. It is generally a param on infoboxes and Locs ([[Module:locLine]]) to be dropped in [[bucket:dropsline]] (when relevant) and querried ([[Module:Get drop info]] and [[Module:shop locations list]] to be displayed on item pages
 For all displayed text/column/rows/cells add <code>class = leagues-global-flag</code>

==Usage==
 Display league region badges:
   {{t|LRIcon|Global}} -> {{LRIcon|Global}}
 Badge + text:
   {{t|LeagueRegion|Global}} -> {{LeagueRegion|Global}}
===Formatting tables===
 Add column with:
 <code>| class="leagues-global-flag" | {{t|CurrentLeague}}</code>
 Add each row with:
 <code>| class="leagues-global-flag" | {{t|LRIcon|Morytania}}</code> or {{
t|LeagueRegion|Morytania}}

===Current league name===
 <code><nowiki>{{#invoke:LeagueRegion|getDefaultLeague}}</nowiki></code> or {{t|CurrentLeague}} -> <code>{{#invoke:LeagueRegion|getDefaultLeague}}</code> or {{CurrentLeague}}
===Adding leagueRegion to infobox===
====Template-side Infoboxes==== 
''Modify the '''colspan''' to fit the rest of the infobox''
 <code><nowiki>{{#if:{{{leagueRegion|}}}|
{{!}}- class="leagues-global-flag"
! style="vertical-align: middle;" colspan="8" {{!}} [[{{#invoke:LeagueRegion|getDefaultLeague}}|League]] region
{{!}} style="vertical-align: middle;" colspan="12" {{!}} {{LeagueRegion|{{{leagueRegion}}}}}{{Mainonly|[[Category:Pages with League region]]}}
}}</nowiki></code>