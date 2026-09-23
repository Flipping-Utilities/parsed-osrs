-- <nowiki>
---@class rgba
local rgba = {}
local libraryUtil = require( 'Module:libraryUtil' )
local max = math.max
local min = math.min
local floor = math.floor
local abs = math.abs

local checkRgbaClass = libraryUtil.makeCheckClassFunction( 'Module:Rgba' , 'rgba', rgba, 'rgba object' )

local function clip( val, lower, upper )
    return min( upper, max( lower, val ) )
end

local function round( num, d )
    d = 10^( d or 0 )
    return floor( num*d + 0.5 ) / d
end

local function RGBtoHSL( r, g, b )
    local M = max( r, g, b )
    local m = min( r, g, b )
    local C = M - m
    local L = (M + m) / 2 / 255
    local H, S

    if M == m then
        H = 0
    elseif M == r then
        H = 60 * (g - b)/C
    elseif M == g then
        H = 60 * (2 + (b - r)/C)
    elseif M == b then
        H = 60 * (4 + (r - g)/C)
    end

    H = H % 360

    if M == m then
        S = 0
    else
        S = C / (255 - abs( M + m - 255 ))
    end

    return H, S, L
end

local function HSLtoRGB( H, S, L )
    local C = (1 - abs( 2*L - 1 )) * S
    local bin = H / 60
    local X = C * (1 - abs( (bin % 2) - 1 ))
    local r, g, b, m

    if 0 <= bin and bin <= 1 then
        r = C
        g = X
        b = 0
    elseif 1 <= bin and bin < 2 then
        r = X
        g = C
        b = 0
    elseif 2 <= bin and bin < 3 then
        r = 0
        g = C
        b = X
    elseif 3 <= bin and bin < 4 then
        r = 0
        g = X
        b = C
    elseif 4 <= bin and bin < 5 then
        r = X
        g = 0
        b = C
    elseif 5 <= bin and bin < 6 then
        r = C
        g = 0
        b = X
    end

    m = L - C/2

    r = (r + m) * 255
    g = (g + m) * 255
    b = (b + m) * 255

    return r, g, b
end

---@param red number | string
---@param green number
---@param blue number
---@param alpha number
---@return rgba
function rgba.new( red, green, blue, alpha )
    libraryUtil.checkTypeMulti( 'Module:Rgba.new', 1, red, {'number', 'string'} )
    libraryUtil.checkType( 'Module:Rgba.new', 2, green, 'number', true )
    libraryUtil.checkType( 'Module:Rgba.new', 3, blue, 'number', true )
    libraryUtil.checkType( 'Module:Rgba.new', 4, alpha, 'number', true )

    if type( red ) == 'string' then
        red, green, blue, alpha = red:match( '#(%x%x)(%x%x)(%x%x)(%x?%x?)' )

        if red == nil then
            error( 'Malformed rgba hex code', 2 )
        end

        red = tonumber( red, 16 )
        green = tonumber( green, 16 )
        blue = tonumber( blue, 16 )
        alpha = tonumber( alpha or 'ff', 16 ) / 255
    end

    local obj = {
        red = clip( round( red or 0 ), 0, 255 ),
        green = clip( round( green or 0 ), 0, 255 ),
        blue = clip( round( blue or 0 ), 0, 255 ),
        alpha = clip( alpha or 1, 0, 1 )
    }

    return setmetatable( obj, rgba )
end

---@param alpha number
---@return rgba
function rgba:fade( alpha )
    checkRgbaClass( self, 'fade' )
    libraryUtil.checkType( 'rgab.fade', 1, alpha, 'number' )

    return rgba.new( self.red, self.green, self.blue, alpha )
end

---@param val number
---@return rgba
function rgba:lighten( val )
    checkRgbaClass( self, 'lighten' )
    libraryUtil.checkType( 'rgab.lighten', 1, val, 'number' )

    val = clip( val, 0, 1e99 )

    local H, S, L = RGBtoHSL( self.red, self.green, self.blue )
    L = clip( L * val, 0, 1 )
    local r, g, b = HSLtoRGB( H, S, L )

    return rgba.new( r, g, b, self.a )
end

---@param val number
---@return rgba
function rgba:darken( val )
    checkRgbaClass( self, 'darken' )
    libraryUtil.checkType( 'rgab.darken', 1, val, 'number' )
    return self:lighten( 1/val )
end

---@param deg number
---@return rgba
function rgba:hueRotate( deg )
    checkRgbaClass( self, 'hueRotate' )
    libraryUtil.checkType( 'rgab.hueRotate', 1, deg, 'number' )

    local H, S, L = RGBtoHSL( self.red, self.green, self.blue )
    H = (H + deg) % 360
    local r, g, b = HSLtoRGB( H, S, L )

    return rgba.new( r, g, b, self.a )
end

---@param val number
---@return rgba
function rgba:saturate( val )
    checkRgbaClass( self, 'saturate' )
    libraryUtil.checkType( 'rgab.saturate', 1, val, 'number' )

    local H, S, L = RGBtoHSL( self.red, self.green, self.blue )
    S = clip( S * val, 0, 1 )
    local r, g, b = HSLtoRGB( H, S, L )

    return rgba.new( r, g, b, self.a )
end

---@return rgba
function rgba:clone()
    checkRgbaClass( self, 'clone' )
    return rgba.new( self.red, self.green, self.blue, self.alpha )
end

rgba.__index = rgba
rgba.__tostring = function( self )
    return string.format( 'rgba(%s,%s,%s,%s)', self.red, self.green, self.blue, self.alpha )
end
rgba.__concat = function( x, y )
    return tostring( x ) .. tostring( y )
end

return rgba
-- </nowiki>