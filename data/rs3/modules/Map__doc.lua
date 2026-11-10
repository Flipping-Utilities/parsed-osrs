{{External|os|dw}}
{{documentation}}
Generates instances of interactive maps (maps and maplinks). Map id's are available at [[RuneScape:Map/mapIDs]]. Please use [[Module:Map/sandbox]] for testing.

'''Template invocation handlers have been moved to the [[Module:Map/templates]] submodule.'''

Jump to [[#Helper_functions|helper functions]].

==Per map arguments==
used with <code>createMap</code> function.
* <code>x</code> - X coordinate for map center
* <code>y</code> - Y coordinate for map center
* <code>width</code> - Width of mapframe (defaults to 300) in pixels
* <code>height</code> - Height of mapframe (defaults to 300) in pixels
* <code>mapID</code> - mapID, see [[RuneScape:Map/mapIDs]] (defaults to 28 surface)
* <code>plainTiles</code> - Use plain tiles
* <code>mapVersion</code> - Use a different set of map tiles than the current ones
* <code>plane</code> - map plane (defaults to 0)
* <code>zoom</code> - Zoom level (defaults to 2)
* <code>group</code> - Group for features (all features in same group on same page appear on each others maps)
* <code>show</code> - Allows showing groups in addition to the group set above, or if no group is set, show only the groups listed. A single group, or comma separated list of group names
* <code>text</code> - Text to display for maplink
* <code>caption</code> - Caption
* <code>etype</code> - ''maplink'' or ''mapframe''
* <code>features</code> - String of the map features to generate. See bellow for possible values.
* <code>pins</code> - A table (array) of pins. For arguments per pin see bellow.
* <code>jagexCoords</code> - Use to centre point based features on tiles, (adds 0.5 to x and y coords).
* <code>nopreprocess</code> - Giving any value will return the actual maplink/mapframe code (element and json)

==Per pin arguments==
Used with <code>parseArgs</code> function
* <code>x</code> - X coordinate for map center
* <code>y</code> - Y coordinate for map center
* <code>title</code> - Title for the pin (tooltip text and at top of description)
* <code>description</code> - Description for the pin (may contain wikitext)
* <code>icon</code> - String of pin type to use, one of: <code>greyPin, redPin, greenPin, bluePin, cyanPin, magentaPin, yellowPin</code>
* <code>iconWikiLink</code> - Wiki image to use as a marker, is case sensitive and spaces must be replaced by <code>_</code>(underscore). '''If this is specified iconSize must also be given'''
* <code>iconSize</code> - x,y dimension in pixels for marker icon
** <code>iconSizeX</code> - x dimension in pixels for marker icon
** <code>iconSizeY</code> - y dimension in pixels for marker icon
* <code>iconAnchor</code> - x,y offset in pixels of map point to image (from top right corner of image, positive down and right)
** <code>iconAnchorX</code> - x offset in pixels of map point to image (from right side of image, positive to right)
** <code>iconAnchorY</code> - y offset in pixels of map point to image (from top of image, positive down)
* <code>popupAnchor</code> - x,y offset in pixels of popup (description) anchor to image anchor (down and to right is positive)
** <code>popupAnchorX</code> - x offset in pixels of popup (description) anchor to image anchor (to right is positive)
** <code>popupAnchorY</code> - y offset in pixels of popup (description) anchor to image anchor (down is positive)

==Possible <code>features</code> strings==
<div style="columns: 2;">
* ''none''
* ''square'' or ''rectangle''
* ''polygon''
* ''line'' or ''lines''
* ''circle''
* ''pin'' or ''pins''
* ''dot'' or ''dots'' or ''circlemarker''
* ''pin-polygon'' or ''pins-polygon''
* ''pin-line'' or ''pins-line''
* ''pin-circle'' or ''pins-circle''
* ''dot-polygon'' or ''dots-polygon''
* ''dot-line'' or ''dots-line''

</div>
==Possible Styles==
See [[RuneScape:Map]] for more information on styling map features. [[RuneScape:Map/Style args]] contains the possible style arguments and which feature types they apply too and their use.

<div style="columns: 2;">
===Pin===
* <code>title</code>
* <code>description</code>
* <code>icon</code>
* <code>iconWikiLink</code>
* <code>iconSize</code>
* <code>iconAnchor</code>
* <code>popupAnchor</code>

===Dot / SquareDot===
* <code>title</code>
* <code>description</code>
* <code>fill</code>

===Polygon (square/rectangle) / circle===
* <code>title</code>
* <code>description</code>
* <code>stroke</code>
* <code>stroke-opacity</code>
* <code>stroke-width</code>
* <code>fill</code>
* <code>fill-opacity</code>

===Line===
* <code>title</code>
* <code>description</code>
* <code>stroke</code>
* <code>stroke-opacity</code>
* <code>stroke-width</code>

===Text===
* <code>label</code>
* <code>title</code>
* <code>description</code>
* <code>direction</code>
* <code>class</code>
</div>

==Helper functions==
{{Helper module|name=Map
|fname1=parseArgs(args, ptype)
|ftype1=table, string
|fuse1=Parses unnamed arguments into points. Returns the arguments given with a <code>pins</code> table and <code>pin_count, x_range, y_range, squareX, squareY</code> if not otherwise specified.
* Arguments are strings in the format <code>x,y</code> or <code>x:#,y:#,plane:#...</code>. For arguments per pin see [[Module:Map]].
* <code>ptype</code> is the pin type (used to generate descriptions).
|fname2=createMap(args)
|ftype2=table
|fuse2=Creates a map or maplink for the args. Returns the preprocessed <code><nowiki><maplink></nowiki></code> or <code><nowiki><map></nowiki></code> tag. For poossible arguments see [[Module:Map]].
|fname3=featSquare(args, opts)
|ftype3=table, table
|fuse3=Creates the json for a square, to be used within the FeatureCollection json. Args are: <code>{x=#, y=#, [squareX=#], [squareY=#], [r=#], [styles], [jagexCoords=boolean]}</code>. Opts are: <code>{mapID=#, plane=#}</code>.
|fname4=featPolygon(args, opts)
|ftype4=table, table
|fuse4=Generates the json for a single polygon from the given points (to be used within the FeatureCollection json). Args are: <code>{pins={}, [styles]}</code> where pins are <code>{x=#, y=#}</code>. Opts are: <code>{mapID=#, plane=#}</code>.
|fname5=featComplPolygon(args, opts, coords)
|ftype5=table, table, table
|fuse5=Generates the json for a complex polygon (can have cutouts etc) from the given points (to be used within the FeatureCollection json). Args are: <code>{[styles]}</code>. Opts are: <code>{mapID=#, plane=#}</code>. Coords are nested tables, the first nested table is the outer bounds, the following tables are cutouts (or filled regions within cutouts) and coordinates are unkeyed: <code><nowiki>{ {{x,y}, {x,y}, {x,y}...}, {{x,y}, {x,y}, {x,y}...}... }</nowiki></code>.
|fname6=featLine(args, opts)
|ftype6=table, table
|fuse6=Generates the json for a line from the given points (to be used within the FeatureCollection json). Args are: <code>{pins={}, [close=boolean], [styles]}</code> where pins are <code>{x=#, y=#}</code>. Opts are: <code>{mapID=#, plane=#}</code>.
|fname7=featCircle(args, opts)
|ftype7=table, table
|fuse7=Generates the json for a circle (to be used within the FeatureCollection json). Args are: <code>{x=#, y=#, [r=#], [styles], [jagexCoords=boolean]}</code>, opts are: <code>{mapID=#, plane=#}</code>.
|fname8=featPin(args, opts, pin)
|ftype8=table, table, table
|fuse8=Generates the json for a single pin (to be used within the FeatureCollection json). Args are: <code>{[styles], [jagexCoords=boolean]}</code>, opts are: <code>{mapID=#, plane=#}</code>, pin is <code>{x=#, y=#, [desc=string]}</code>
|fname9=featIcon(args, opts, pin)
|ftype9=table, table, table
|fuse9=Generates the json for a single pin using a predefined icon from [[Module:Map/icons]] (to be used within the FeatureCollection json). Args are: <code>{icon=string, [styles], [jagexCoords=boolean]}</code>, opts are: <code>{mapID=#, plane=#}</code>, pin is <code>{x=#, y=#, [desc=string]}</code>
|fname10=featDot(args, opts, pin)
|ftype10=table, table, table
|fuse10=Generates the json for a single dot (to be used within the FeatureCollection json). Dots are circles but like normal pins the scale with zoom. Args are: <code>{[r=#], [styles], [jagexCoords=boolean]}</code>, opts are: <code>{mapID=#, plane=#}</code>, pin is <code>{x=#, y=#, [desc=string]}</code>
|fname11=featSqDot(args, opts, pin)
|ftype11=table, table, table
|fuse11=Generates the json for a single square dot (to be used within the FeatureCollection json). Square dots are squares but like normal pins the scale with zoom. Args are: <code>{[styles], [jagexCoords=boolean]}</code>, opts are: <code>{mapID=#, plane=#}</code>, pin is <code>{x=#, y=#, [desc=string]}</code>
}}