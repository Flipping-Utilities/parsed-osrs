--[[
------------------------------------------------------------------------------------
--                               TableTools                                       --
--                                                                                --
-- MediaWiki-Specific Table Utilities                                             --
-- This module provides MediaWiki-specific table operations. For general array   --
-- operations (map, filter, uniq, compact, etc.), use Array.lua instead.         --
--                                                                                --
-- This is a meta-module, meant to be called from other Lua modules, and should  --
-- not be called directly from #invoke.                                           --
------------------------------------------------------------------------------------
--]]

local libraryUtil = require('libraryUtil')

---@class TableTools
local p = {}

-- Define often-used variables and functions.
local floor = math.floor
local infinity = math.huge
local checkType = libraryUtil.checkType
local checkTypeMulti = libraryUtil.checkTypeMulti

--[[
------------------------------------------------------------------------------------
-- Type checking
------------------------------------------------------------------------------------
--]]

---Check if a value is a positive integer
---@param num any # Value to check
---@return boolean isPositiveInteger # Whether the value is a positive integer
function p.isPositiveInteger(num)
    return type(num) == 'number' and num >= 1 and floor(num) == num and num < infinity
end

---Check if a value is NaN (Not a Number)
---@param num any # Value to check  
---@return boolean isNaN # Whether the value is NaN
function p.isNan(num)
    return type(num) == 'number' and tostring(num) == '-nan'
end

---Check if a table is a proper array (consecutive integer keys starting from 1)
---@param t table # Table to check
---@return boolean isArray # Whether the table is an array
function p.isArray(t)
    checkType("isArray", 1, t, "table")
    
    local maxKey = 0
    local keyCount = 0
    
    for key, _ in pairs(t) do
        keyCount = keyCount + 1
        if type(key) ~= 'number' or key < 1 or floor(key) ~= key then
            return false
        end
        if key > maxKey then
            maxKey = key
        end
    end
    
    -- Array must have consecutive keys from 1 to maxKey
    return keyCount == maxKey
end

---Check if a table is empty
---@param t table Table to check
---@return boolean isEmpty Whether the table is empty
function p.isEmpty(t)
    checkType("isEmpty", 1, t, "table")
    return next(t) == nil
end

--[[
------------------------------------------------------------------------------------
-- Table length ops
------------------------------------------------------------------------------------
--]]

---Get length of a sparse table (highest numeric index)
---@param t table Table to measure
---@return integer length Length of the table
function p.length(t)
    checkType('length', 1, t, 'table')

    local length = 0
    while t[length + 1] ~= nil do
        length = length + 1
    end
    return length
end

---Get total number of key-value pairs in a table
---For arrays, use Array.len() instead for better performance
---@param t table Table to count
---@return integer size Number of key-value pairs
function p.size(t)
    checkType('size', 1, t, 'table')
    
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

--[[
------------------------------------------------------------------------------------
-- Cloning
------------------------------------------------------------------------------------
--]]

---Internal recursive function for deep copying
---@param orig any # Original value to copy
---@param includeMetatable boolean # Whether to include metatables
---@param already_seen table<table, table> # Cache to prevent infinite recursion
---@return any copy # Deep copy of the original value
local function _deepCopy(orig, includeMetatable, already_seen)
    if type(orig) ~= "table" then
        return orig
    end

    local copy = already_seen[orig]
    if copy ~= nil then
        return copy
    end

    copy = {}
    already_seen[orig] = copy
    
    for orig_key, orig_value in pairs(orig) do
        copy[_deepCopy(orig_key, includeMetatable, already_seen)] = 
            _deepCopy(orig_value, includeMetatable, already_seen)
    end

    if includeMetatable then
        local mt = getmetatable(orig)
        if mt ~= nil then
            setmetatable(copy, _deepCopy(mt, true, already_seen))
        end
    end

    return copy
end

---Create a deep copy of a table with MediaWiki-specific metatable handling
---@param orig any # Original value to copy
---@param noMetatable? boolean # If true, don't copy metatables (default: false)
---@param already_seen? table<table, table> # Internal cache for recursion prevention
---@return any copy # Deep copy of the original value
function p.deepCopy(orig, noMetatable, already_seen)
    checkType("deepCopy", 3, already_seen, "table", true)
    return _deepCopy(orig, not noMetatable, already_seen or {})
end

--[[
------------------------------------------------------------------------------------
-- Numerical key functions
------------------------------------------------------------------------------------
--]]

---Get all positive integer keys from a table, sorted
---@param t table # Table to extract numeric keys from
---@return integer[] numericKeys # Sorted array of positive integer keys
function p.numKeys(t)
    checkType('numKeys', 1, t, 'table')
    
    local nums = {}
    
    for key, _ in pairs(t) do
        if p.isPositiveInteger(key) then
            nums[#nums + 1] = key
        end
    end
    
    table.sort(nums)
    return nums
end

---Extract numeric keys from string keys with given prefix/suffix pattern
---@param t table # Table to search
---@param prefix? string # Prefix pattern (default: empty)
---@param suffix? string # Suffix pattern (default: empty)  
---@return integer[] affixedNumbers # Sorted array of extracted numbers
function p.affixNums(t, prefix, suffix)
    checkType('affixNums', 1, t, 'table')
    checkType('affixNums', 2, prefix, 'string', true)
    checkType('affixNums', 3, suffix, 'string', true)

    local function cleanPattern(s)
        return s:gsub('([%(%)%%%.%[%]%*%+%-%?%^%$])', '%%%1')
    end

    local clean_prefix = cleanPattern(prefix or "")
    local clean_suffix = cleanPattern(suffix or "")
    local pattern = '^' .. clean_prefix .. '([1-9]%d*)' .. clean_suffix .. '$'

    local nums = {}
    for key, _ in pairs(t) do
        if type(key) == 'string' then
            local num = mw.ustring.match(key, pattern)
            if num then
                nums[#nums + 1] = tonumber(num)
            end
        end
    end
    
    table.sort(nums)
    return nums
end

---Convert a table with numbered keys into a more structured format
---@param t table Input table with mixed keys
---@param compress? boolean Whether to compress the result array (default: false)
---@return table structuredData Table organized by numeric indices
function p.numData(t, compress)
    checkType('numData', 1, t, 'table')
    checkType('numData', 2, compress, 'boolean', true)

    local ret = {}

    for key, value in pairs(t) do
        local prefix, num = mw.ustring.match(tostring(key), '^([^0-9]*)([1-9][0-9]*)$')
        local number = tonumber(num)

        if number then
            local subtable = ret[number] or {}
            if prefix == '' then
                prefix = 1
            end
            subtable[prefix] = value
            ret[number] = subtable
        else
            local subtable = ret.other or {}
            subtable[key] = value
            ret.other = subtable
        end
    end

    if compress then
        -- Simple compression by removing nil gaps
        local compressed = {}
        local other = ret.other
        ret.other = nil

        local compressIndex = 1
        for dataIndex = 1, math.huge do
            if ret[dataIndex] then
                compressed[compressIndex] = ret[dataIndex]
                compressIndex = compressIndex + 1
            elseif compressIndex > 1 then
                -- No more consecutive elements
                break
            end
        end

        compressed.other = other
        ret = compressed
    end

    return ret
end

--[[
------------------------------------------------------------------------------------
-- Sparse table operations
------------------------------------------------------------------------------------
--]]

---Concatenate values from a sparse table (skipping nils)
---@param t table Sparse table to concatenate
---@param sep? string Separator string (default: empty string)
---@param i? integer Start index (optional)
---@param j? integer End index (optional)
---@return string concatenated Concatenated string
function p.sparseConcat(t, sep, i, j)
    checkType('sparseConcat', 1, t, 'table')
    checkType('sparseConcat', 2, sep, 'string', true)
    checkType('sparseConcat', 3, i, 'number', true)
    checkType('sparseConcat', 4, j, 'number', true)

    local list = {}
    local listIndex = 0

    for _, v in p.sparseIpairs(t) do
        listIndex = listIndex + 1
        list[listIndex] = tostring(v)
    end

    return table.concat(list, sep or "", i, j)
end

---Remove nil values from sparse array while preserving order
---@param t table Sparse array to compress  
---@return table compressedArray Array with nil values removed
function p.compressSparseArray(t)
    checkType('compressSparseArray', 1, t, 'table')

    local result = {}
    local resultIndex = 1

    for dataIndex = 1, math.huge do
        if t[dataIndex] ~= nil then
            result[resultIndex] = t[dataIndex]
            resultIndex = resultIndex + 1
        elseif resultIndex > 1 then
            -- No more consecutive elements found
            break
        end
    end

    return result
end

--[[
------------------------------------------------------------------------------------
-- Specialised iterators
------------------------------------------------------------------------------------
--]]

---Iterator for sparse arrays (arrays with gaps)
---@param t table Sparse table to iterate over
---@return function iterator Iterator function that returns key, value
function p.sparseIpairs(t)
    checkType('sparseIpairs', 1, t, 'table')

    local nums = p.numKeys(t)
    local index = 0
    local limit = #nums

    return function ()
        index = index + 1
        if index <= limit then
            local key = nums[index]
            return key, t[key]
        else
            return nil, nil
        end
    end
end

---Iterator for ordered pairs (keys sorted by type, then value)
---@param t table Table to iterate over
---@return function iterator Iterator function that returns key, value
function p.opairs(t)
    checkType('opairs', 1, t, 'table')

    local orderedKeys = {}
    local keyIndex = 1

    for key in pairs(t) do
        orderedKeys[keyIndex] = key
        keyIndex = keyIndex + 1
    end

    local function sortFunc(lhs, rhs)
        if type(lhs) == type(rhs) then
            return lhs < rhs
        else
            local order = {
                number = 1,
                string = 2,
                table = 3,
                ['function'] = 4,
            }
            return order[type(lhs)] < order[type(rhs)]
        end
    end

    table.sort(orderedKeys, sortFunc)

    local iterIndex = 0
    return function()
        iterIndex = iterIndex + 1
        local key = orderedKeys[iterIndex]
        if key ~= nil then
            return key, t[key]
        else
            return nil, nil
        end
    end
end

---Iterator for string keys only
---@param t table Table to iterate over
---@return function iterator Iterator function that returns key, value
---@return table state Iterator state (the table itself)
---@return nil initial Iterator initial state (nil)
function p.spairs(t)
    checkType('spairs', 1, t, 'table')

    local function iter(tbl, currentKey)
        local nextKey, nextVal = next(tbl, currentKey)
        while nextKey ~= nil and type(nextKey) ~= "string" do
            nextKey, nextVal = next(tbl, nextKey)
        end
        return nextKey, nextVal
    end

    return iter, t, nil
end

---Iterator for ordered string pairs (string keys only, sorted)
---@param t table Table to iterate over
---@return function iterator Iterator function that returns key, value
function p.ospairs(t)
    checkType('ospairs', 1, t, 'table')

    local orderedKeys = {}
    local keyIndex = 1

    for key in pairs(t) do
        if type(key) == "string" then
            orderedKeys[keyIndex] = key
            keyIndex = keyIndex + 1
        end
    end

    table.sort(orderedKeys)

    local iterIndex = 0
    return function()
        iterIndex = iterIndex + 1
        local key = orderedKeys[iterIndex]
        if key ~= nil then
            return key, t[key]
        else
            return nil, nil
        end
    end
end

---Default comparison function for sorting keys
---@param item1 any First item to compare
---@param item2 any Second item to compare
---@return boolean isLess Whether item1 should come before item2
local function defaultKeySort(item1, item2)
    local type1, type2 = type(item1), type(item2)
    if type1 ~= type2 then
        return type1 < type2
    else
        return item1 < item2
    end
end

---Convert table keys to a sorted list
---@param t table Table whose keys to extract
---@param keySort? function|boolean Sort function or false to disable sorting
---@param checked? boolean Internal parameter for recursion
---@return any[] keysList List of table keys
function p.keysToList(t, keySort, checked)
    if not checked then
        checkType('keysToList', 1, t, 'table')
        checkTypeMulti('keysToList', 2, keySort, { 'function', 'boolean', 'nil' })
    end

    local list = {}
    local listIndex = 1

    for key, _ in pairs(t) do
        list[listIndex] = key
        listIndex = listIndex + 1
    end

    if keySort ~= false then
        local sortFunction = type(keySort) == 'function' and keySort or defaultKeySort
        table.sort(list, sortFunction)
    end

    return list
end

---Iterator that traverses table in sorted key order
---@param t table Table to iterate over
---@param keySort? function Custom key sorting function
---@return function iterator Iterator function that returns key, value
function p.sortedPairs(t, keySort)
    checkType('sortedPairs', 1, t, 'table')
    checkType('sortedPairs', 2, keySort, 'function', true)

    local list = p.keysToList(t, keySort, true)

    local iterIndex = 0
    return function()
        iterIndex = iterIndex + 1
        local key = list[iterIndex]
        if key ~= nil then
            return key, t[key]
        else
            return nil, nil
        end
    end
end

---Iterator that traverses table sorted by values
---@param t table Table to iterate over
---@param valueSort? fun(a: any, b: any): boolean Custom value sorting function (compares table values)
---@return function iterator Iterator function that yields index, key, value
---@return table state Iterator state (internal elements array)
---@return integer index Iterator initial index (0)
function p.sortedPairsByValue(t, valueSort)
    checkType('sortedPairsByValue', 1, t, 'table')
    checkType('sortedPairsByValue', 2, valueSort, 'function', true)
    
    local elements = {}
    for k, v in pairs(t) do
        table.insert(elements, {key = k, value = v})
    end

    local sortFunc = valueSort or function(a, b) 
        return tostring(a) < tostring(b)
    end
    
    table.sort(elements, function(lhs, rhs) 
        return sortFunc(lhs.value, rhs.value) 
    end)

    local function iterator(elements, i)
        i = i + 1
        if elements[i] ~= nil then
            return i, elements[i].key, elements[i].value
        end
        return nil
    end
    
    return iterator, elements, 0
end

--[[
------------------------------------------------------------------------------------
-- Set operations
------------------------------------------------------------------------------------
--]]

---Create a reverse mapping from array values to their indices
---@param array table Array to invert
---@return table<any, integer> invertedMap Map from values to indices
function p.invert(array)
    checkType("invert", 1, array, "table")
    
    local map = {}
    for idx, item in ipairs(array) do
        map[item] = idx
    end
    return map
end

---Convert an array to a set (values become keys with true values)
---@param t table Array to convert to set
---@return table<any, true> set Set representation of the array
function p.listToSet(t)
    checkType("listToSet", 1, t, "table")
    
    local set = {}
    for _, item in ipairs(t) do
        set[item] = true
    end
    return set
end

--[[
------------------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------------------
--]]

---Get the first key-value pair from a table
---@param t table Table to get first pair from
---@return any|nil key First key or nil if empty
---@return any|nil value First value or nil if empty
function p.first(t)
    checkType("first", 1, t, "table")
    local key, value = next(t)
    return key, value
end

---Count elements that match a predicate function
---@param t table Table to search
---@param predicate function Function that returns true for matching elements
---@return integer count Number of matching elements
function p.count(t, predicate)
    checkType("count", 1, t, "table")
    checkType("count", 2, predicate, "function")
    
    local count = 0
    for key, value in pairs(t) do
        if predicate(value, key) then
            count = count + 1
        end
    end
    return count
end

---Check if all elements in a table match a predicate
---@param t table Table to check
---@param predicate function Function that returns true for matching elements
---@return boolean allMatch Whether all elements match the predicate
function p.all(t, predicate)
    checkType("all", 1, t, "table")
    checkType("all", 2, predicate, "function")
    
    for key, value in pairs(t) do
        if not predicate(value, key) then
            return false
        end
    end
    return true
end

---Check if any element in a table matches a predicate
---@param t table Table to check
---@param predicate function Function that returns true for matching elements
---@return boolean anyMatch Whether any element matches the predicate
function p.any(t, predicate)
    checkType("any", 1, t, "table")
    checkType("any", 2, predicate, "function")
    
    for key, value in pairs(t) do
        if predicate(value, key) then
            return true
        end
    end
    return false
end

---Find the first element that matches a predicate
---@param t table Table to search
---@param predicate function Function that returns true for matching elements
---@return any|nil key Key of first matching element or nil
---@return any|nil value Value of first matching element or nil
function p.find(t, predicate)
    checkType("find", 1, t, "table")
    checkType("find", 2, predicate, "function")
    
    for key, value in pairs(t) do
        if predicate(value, key) then
            return key, value
        end
    end
    return nil, nil
end

---Get all keys from a table
---@param t table Table to get keys from
---@return any[] keys Array of all keys
function p.keys(t)
    checkType("keys", 1, t, "table")

    local keys = {}
    local keyIndex = 1
    for key, _ in pairs(t) do
        keys[keyIndex] = key
        keyIndex = keyIndex + 1
    end
    return keys
end

---Get all values from a table
---@param t table Table to get values from
---@return any[] values Array of all values
function p.values(t)
    checkType("values", 1, t, "table")

    local values = {}
    local valueIndex = 1
    for _, value in pairs(t) do
        values[valueIndex] = value
        valueIndex = valueIndex + 1
    end
    return values
end

return p