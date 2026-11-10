--[[
This object will be the same throughout each page even in seperate #invokes
(Scribunto tries very hard to isolate Lua interpreters, with a seperate _G
and cloning every builtin package so each session gets a fresh copy,
but mw.uri has a local variable that it sets the metatable to that isn't cloned
because it's not a property of the package)
]]
local persistant = getmetatable(mw.uri.new())
local store
do
	local key = '__store#Module:Break Isolation'
	store = rawget(persistant, key)
	if not store then
		store = {
			by_module = {},
			function_cache = {},
			nil_marker = {},
		}
		rawset(persistant, key, store)
	end
end

local p = {}

--[[
Using this module does *not* prevent caching of invocations / templates,
since Scribunto does not think the isolation can be broken. Call this function
to prevent caching.
]]
function p.prevent_caching()
	mw.getCurrentFrame():callParserFunction{ name = '#var', args = { '__var_to_prevent_caching#Module:Break Isolation' } }
	p.prevent_caching = function() end
end

--[[
Call with the name of a module to get a persistant object for that module

Subsequent calls with the same name will return the same object, even
across different #invokes
]]
function p.get_module_store(module_name)
	store.by_module[module_name] = store.by_module[module_name] or {}
	return store.by_module[module_name]
end

--[[
Given the name of a module, returns a "cache" decorator that, given a name
and a function, will return a function that will memoise the results of that
function. This cache will persist across different invocations.

Only use this with pure functions where the arguments are strings, integers, nil
or boolean only. Supports any number of arguments, but note that `f(1)` and
`f(1, nil)` will have different cache values (extra arguments are *not* ignored)

Supports any results, but note that if the result is cached, it will be calling
the function from the first invocation context where it is cached. Will return
a clone of the cached result every time to prevent modification
]]
function p.cache_functions(module_name)
	store.function_cache[module_name] = store.function_cache[module_name] or {
		functions = {},
		cached_results = {}
	}
	return function(f_name, f)
		store.function_cache[module_name].cached_results[f_name] = store.function_cache[module_name].cached_results[f_name] or {}
		local cache = store.function_cache[module_name].cached_results[f_name]
		store.function_cache[module_name].functions[f_name] = store.function_cache[module_name].functions[f_name] or function(...)
			local cache_for_args = cache
			local arg = { ..., n = select('#', ...) }
			for i=1, arg.n do
				local t = type(arg[i])
				if t ~= 'number' and t ~= 'string' and t ~= 'nil' and t ~= 'boolean' then
					error(('Cached function %s %s called with unsupported type %s'):format(module_name, f_name, t))
				end
				cache[t] = cache[t] or {}
				cache_for_args = cache[t]
				if t ~= 'nil' then
					cache[t][arg[i]] = cache[t][arg[i]] or {}
					cache_for_args = cache[t][arg[i]]
				end
			end
			local cached_answer = cache_for_args.result
			if cached_answer == nil then
				cached_answer = f(...)
				if cached_answer == nil then
					cached_answer = store.nil_marker
				end
				cache_for_args.result = cached_answer
			end
			if cached_answer == store.nil_marker then
				cached_answer = nil
			end
			return mw.clone(cached_answer)
		end
		return store.function_cache[module_name].functions[f_name]
	end
end

return p