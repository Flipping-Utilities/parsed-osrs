{{Documentation}}

{{APIDoc
|funcName = invoke_main
|funcDesc = The main entry point for the calculator template. Should only be called via <code>{{#invoke}}</code> outside of a module.
|arg1 = frame
|type1 = [https://www.mediawiki.org/wiki/Extension:Scribunto/Lua_reference_manual#frame-object frame object]
|desc1 = The frame object automatically passed via <code>{{#invoke}}</code>.
|returnType = string
|returnDesc = A fully rendered html table containing the calculator response data.
}}
{{APIDoc
|funcName = _main
|funcDesc = The main entry point for other modules.
|arg1 = args
|type1 = table
|desc1 = Any argument used in [[Module:Hunter Rumours]].
|returnType = string
|returnDesc = A fully rendered html table containing the calculator response data.
}}