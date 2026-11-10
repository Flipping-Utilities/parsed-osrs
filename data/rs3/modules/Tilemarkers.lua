local p = {}

local bit32 = require('bit32')
local bitor = bit32.bor
local bitand = bit32.band
local lshift = bit32.lshift
local rshift = bit32.rshift

---replacing //
---@param x number
---@param by number
---@return integer
local function floordiv(x, by)
    return math.floor(x / by)
end

---
-- The following codes are extracted from https://github.com/PrettyRS/tilemarkers/blob/main/src/preset_codec.lua
-- @author J3sven
--
-- Modified to be compatible with the wiki Lua environment
--
-- start preset_codec.lua
---
local TOKEN_PREFIX = "TM2"
local BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local BASE64_VALUES = {}
local MAX_TILES = 100000
local MAX_NAME_BYTES = 128
local MAX_LABEL_BYTES = 128
local DICTIONARY_FLAG = 0x10
local MORTON_COORDINATES_FLAG = 0x20
local PREFIX_DICTIONARY_FLAG = 0x40

for index = 1, #BASE64_ALPHABET do
    BASE64_VALUES[BASE64_ALPHABET:sub(index, index)] = index - 1
end

local function base64Decode(source)
    if source == "" or #source % 4 == 1 then
        return nil, "Invalid preset token."
    end
    local result = {}
    local index = 1
    while index <= #source do
        local available = math.min(4, #source - index + 1)
        local combined = 0
        for offset = 0, available - 1 do
            local value = BASE64_VALUES[source:sub(index + offset, index + offset)]
            if value == nil then
                return nil, "Preset token contains unsupported characters."
            end
            combined = bitor(combined, lshift(value, (18 - offset * 6)))
        end
        result[#result + 1] = string.char(bitand(rshift(combined, 16), 0xFF))
        if available >= 3 then
            result[#result + 1] = string.char(bitand(rshift(combined, 8), 0xFF))
        end
        if available == 4 then
            result[#result + 1] = string.char(bitand(combined, 0xFF))
        end
        index = index + 4
    end
    return table.concat(result)
end

local function zigzagDecode(value)
    return value % 2 == 0 and floordiv(value, 2) or -floordiv((value + 1), 2)
end

---@param source string
---@return { source:string, position: integer }
local function newReader(source)
    return { source = source, position = 1 }
end

local function readBytes(reader, length)
    if length < 0 or reader.position + length - 1 > #reader.source then
        return nil
    end
    local value = reader.source:sub(reader.position, reader.position + length - 1)
    reader.position = reader.position + length
    return value
end

---@param reader { source:string, position: integer }
---@return integer|nil
local function readByte(reader)
    local value = reader.source:byte(reader.position)
    if value ~= nil then
        reader.position = reader.position + 1
    end
    return value
end


local function readVaruint(reader)
    local value = 0
    local shift = 0
    for _ = 1, 9 do
        local byte = readByte(reader)
        if byte == nil then
            return nil
        end
        value = bitor(value, lshift(bitand(byte, 0x7F), shift))
        if bitand(byte, 0x80) == 0 then
            return value
        end
        shift = shift + 7
    end
    return nil
end

---@param reader { source:string, position: integer }
---@return integer|nil
local function readUInt32(reader)
    local first = readByte(reader)
    local second = readByte(reader)
    local third = readByte(reader)
    local fourth = readByte(reader)
    if fourth == nil then return nil end
    return bitor(lshift(first, 24), lshift(second, 16), lshift(third, 8), fourth)
end

local function mortonDecode(value)
    local x = 0
    local z = 0
    for bit = 0, 13 do
        z = bitor(z, lshift(bitand(rshift(value, (bit * 2)), 1), bit))
        x = bitor(x, lshift(bitand(rshift(value, (bit * 2 + 1)), 1), bit))
    end
    return x, z
end

local function readCoordinates(reader, level, count, tiles)
    local encodedX = readVaruint(reader)
    local encodedZ = readVaruint(reader)
    if encodedX == nil or encodedZ == nil then
        return false
    end
    local x = zigzagDecode(encodedX)
    local z = zigzagDecode(encodedZ)
    tiles[#tiles + 1] = { x = x, z = z, level = level }

    for _ = 2, count do
        local code = readByte(reader)
        if code == nil then
            return false
        end
        local deltaX
        local deltaZ
        if code < 0x80 then
            deltaX = 0
            deltaZ = code + 1
        elseif code < 0xC0 then
            deltaX = 1
            deltaZ = code - 0xA0
        elseif code == 0xC0 then
            deltaX = readVaruint(reader)
            local encodedDeltaZ = readVaruint(reader)
            if deltaX == nil or encodedDeltaZ == nil then
                return false
            end
            deltaZ = zigzagDecode(encodedDeltaZ)
        else
            return false
        end
        x = x + deltaX
        z = z + deltaZ
        tiles[#tiles + 1] = { x = x, z = z, level = level }
    end
    return true
end

local function readMortonCoordinates(reader, level, count, tiles)
    local morton = readVaruint(reader)
    if morton == nil or morton > 0x0FFFFFFF then
        return false
    end
    local x, z = mortonDecode(morton)
    tiles[#tiles + 1] = { x = x, z = z, level = level }
    for _ = 2, count do
        local delta = readVaruint(reader)
        if delta == nil or morton + delta > 0x0FFFFFFF then
            return false
        end
        morton = morton + delta
        x, z = mortonDecode(morton)
        tiles[#tiles + 1] = { x = x, z = z, level = level }
    end
    return true
end

---@param token string
---@return {  name: string, tiles: { label: string, fill: integer, fillColour: integer, outlineColour: integer, outlineThickness: integer, outlineCornersOnly: boolean, level: integer, x: integer, z: integer } }|nil, string|nil
function p.decodeCodec(token)
    if type(token) ~= "string" or token:sub(1, #TOKEN_PREFIX) ~= TOKEN_PREFIX then
        return nil, "Expected a TM2 preset token."
    end
    local binary, decodeError = base64Decode(token:sub(#TOKEN_PREFIX + 1))
    if binary == nil then
        return nil, decodeError
    end

    local reader = newReader(binary)
    local flags = readByte(reader)
    if flags == nil or bitand(flags, 0x80) ~= 0
        or bitand(flags, PREFIX_DICTIONARY_FLAG) ~= 0
        and bitand(flags, DICTIONARY_FLAG) == 0 then
        return nil, "Invalid preset token header."
    end
    local levelMask = bitand(flags, 0x0F)
    local usesDictionary = bitand(flags, DICTIONARY_FLAG) ~= 0
    local usesMortonCoordinates = bitand(flags, MORTON_COORDINATES_FLAG) ~= 0
    local usesPrefixDictionary = bitand(flags, PREFIX_DICTIONARY_FLAG) ~= 0
    local nameLength = readVaruint(reader)
    if nameLength == nil or nameLength > MAX_NAME_BYTES then
        return nil, "Invalid preset name length."
    end
    local name = readBytes(reader, nameLength)
    if name == nil then
        return nil, "Invalid preset token contents."
    end

    local tiles = {}
    for level = 0, 3 do
        if bitand(levelMask, lshift(1, level)) ~= 0 then
            local count = readVaruint(reader)
            if count == nil or count < 1 or #tiles + count > MAX_TILES
                or not (usesMortonCoordinates
                    and readMortonCoordinates(reader, level, count, tiles)
                    or not usesMortonCoordinates
                    and readCoordinates(reader, level, count, tiles)) then
                return nil, "Invalid tile data in preset token."
            end
        end
    end

    local styleCount = readVaruint(reader)
    if styleCount == nil or styleCount > #tiles
        or (#tiles > 0 and styleCount < 1) then
        return nil, "Invalid style dictionary in preset token."
    end
    local styles = {}
    for index = 1, styleCount do
        local outlineColour = readUInt32(reader)
        local fillColour = readUInt32(reader)
        local styleFlags = readByte(reader)
        local thickness = readByte(reader)
        if outlineColour == nil or fillColour == nil or styleFlags == nil
            or bitand(styleFlags, 0xF0) ~= 0
            or bitand(styleFlags, 0x05) == 0x05 or bitand(styleFlags, 0x0A) == 0x0A
            or thickness == nil or thickness > 100
        then
            return nil, "Invalid tile style in preset token."
        end
        local fill
        if bitand(styleFlags, 0x04) == 0 then
            fill = bitand(styleFlags, 1) ~= 0
        end
        local outlineCornersOnly
        if bitand(styleFlags, 0x08) == 0 then
            outlineCornersOnly = bitand(styleFlags, 2) ~= 0
        end
        styles[index] = {
            outlineColour = outlineColour,
            fillColour = fillColour,
            fill = fill,
            outlineCornersOnly = outlineCornersOnly,
            outlineThickness = thickness / 10,
        }
    end

    local labelledTiles = {}
    for _, tile in ipairs(tiles) do
        local metadata = readVaruint(reader)
        if metadata == nil then return nil, "Truncated preset token." end
        local styleIndex = rshift(metadata, 1)
        local style = styles[styleIndex + 1]
        if style == nil then return nil, "Invalid tile style index." end
        tile.outlineColour = style.outlineColour
        tile.fillColour = style.fillColour
        tile.fill = style.fill
        tile.outlineCornersOnly = style.outlineCornersOnly
        tile.outlineThickness = style.outlineThickness
        if bitand(metadata, 1) ~= 0 then
            labelledTiles[#labelledTiles + 1] = tile
        end
    end

    if usesDictionary then
        local dictionaryCount = readVaruint(reader)
        if dictionaryCount == nil or dictionaryCount < 1
            or dictionaryCount > #labelledTiles then
            return nil, "Invalid label dictionary in preset token."
        end
        local dictionary = {}
        local previousDictionaryLabel = ""
        for index = 1, dictionaryCount do
            if usesPrefixDictionary then
                local prefixLength = readVaruint(reader)
                local suffixLength = readVaruint(reader)
                if prefixLength == nil or prefixLength > #previousDictionaryLabel
                    or suffixLength == nil
                    or prefixLength + suffixLength < 1
                    or prefixLength + suffixLength > MAX_LABEL_BYTES then
                    return nil, "Invalid tile label in preset token."
                end
                local suffix = readBytes(reader, suffixLength)
                if suffix == nil then
                    return nil, "Truncated preset token."
                end
                dictionary[index] = previousDictionaryLabel:sub(1, prefixLength) .. suffix
                previousDictionaryLabel = dictionary[index]
            else
                local labelLength = readVaruint(reader)
                if labelLength == nil or labelLength < 1 or labelLength > MAX_LABEL_BYTES then
                    return nil, "Invalid tile label in preset token."
                end
                dictionary[index] = readBytes(reader, labelLength)
                if dictionary[index] == nil then
                    return nil, "Truncated preset token."
                end
            end
        end
        for _, tile in ipairs(labelledTiles) do
            local labelIndex = readVaruint(reader)
            if labelIndex == nil or labelIndex >= dictionaryCount then
                return nil, "Invalid label dictionary index in preset token."
            end
            tile.label = dictionary[labelIndex + 1]
        end
    else
        for _, tile in ipairs(labelledTiles) do
            local labelLength = readVaruint(reader)
            if labelLength == nil or labelLength < 1 or labelLength > MAX_LABEL_BYTES then
                return nil, "Invalid tile label in preset token."
            end
            tile.label = readBytes(reader, labelLength)
            if tile.label == nil then
                return nil, "Truncated preset token."
            end
        end
    end

    if reader.position <= #reader.source then
        return nil, "Unexpected data at the end of preset token."
    end

    return { name = name, tiles = tiles }
end

---
-- end preset_codec.lua
---

return p