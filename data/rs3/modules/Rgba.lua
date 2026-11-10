---@class rgba
local rgba = {}
local libraryUtil = require( 'Module:libraryUtil' )
local max = math.max
local min = math.min
local floor = math.floor
local abs = math.abs

local checkRgbaClass = libraryUtil.makeCheckClassFunction( 'Module:Rgba' , 'rgba', rgba, 'rgba object' )

-- All named css colors
local namedColors = {
    aliceblue = '#f0f8ff',
    antiquewhite = '#faebd7',
    aqua = '#00ffff',
    aquamarine = '#7fffd4',
    azure = '#f0ffff',
    beige = '#f5f5dc',
    bisque = '#ffe4c4',
    black = '#000000',
    blanchedalmond = '#ffebcd',
    blue = '#0000ff',
    blueviolet = '#8a2be2',
    brown = '#a52a2a',
    burlywood = '#deb887',
    cadetblue = '#5f9ea0',
    chartreuse = '#7fff00',
    chocolate = '#d2691e',
    coral = '#ff7f50',
    cornflowerblue = '#6495ed',
    cornsilk = '#fff8dc',
    crimson = '#dc143c',
    cyan = '00ffff',
    darkblue = '#00008b',
    darkcyan = '#008b8b',
    darkgoldenrod = '#b8860b',
    darkgray = '#a9a9a9',
    darkgreen = '#006400',
    darkgrey = '#a9a9a9',
    darkkhaki = '#bdb76b',
    darkmagenta = '#8b008b',
    darkolivegreen = '#556b2f',
    darkorange = '#ff8c00',
    darkorchid = '#9932cc',
    darkred = '#8b0000',
    darksalmon = '#e9967a',
    darkseagreen = '#8fbc8f',
    darkslateblue = '#483d8b',
    darkslategray = '#2f4f4f',
    darkslategrey = '#2f4f4f',
    darkturquoise = '#00ced1',
    darkviolet = '#9400d3',
    deeppink = '#ff1493',
    deepskyblue = '#00bfff',
    dimgray = '#696969',
    dimgrey = '#696969',
    dodgerblue = '#1e90ff',
    firebrick = '#b22222',
    floralwhite = '#fffaf0',
    forestgreen = '#228b22',
    fuchsia = '#ff00ff',
    gainsboro = '#dcdcdc',
    ghostwhite = '#f8f8ff',
    gold = '#ffd700',
    goldenrod = '#daa520',
    gray = '#808080',
    green = '#008000',
    greenyellow = '#adff2f',
    grey = '#808080',
    honeydew = '#f0fff0',
    hotpink = '#ff69b4',
    indianred = '#cd5c5c',
    indigo = '#4b0082',
    ivory = '#fffff0',
    khaki = '#f0e68c',
    lavender = '#e6e6fa',
    lavenderblush = '#fff0f5',
    lawngreen = '#7cfc00',
    lemonchiffon = '#fffacd',
    lightblue = '#add8e6',
    lightcoral = '#f08080',
    lightcyan = '#e0ffff',
    lightgoldenrodyellow = '#fafad2',
    lightgray = '#d3d3d3',
    lightgreen = '#90ee90',
    lightgrey = '#d3d3d3',
    lightpink = '#ffb6c1',
    lightsalmon = '#ffa07a',
    lightseagreen = '#20b2aa',
    lightskyblue = '#87cefa',
    lightslategray = '#778899',
    lightslategrey = '#778899',
    lightsteelblue = '#b0c4de',
    lightyellow = '#ffffe0',
    lime = '#00ff00',
    limegreen = '#32cd32',
    linen = '#faf0e6',
    magenta = '#ff00ff ',
    maroon = '#800000',
    mediumaquamarine = '#66cdaa',
    mediumblue = '#0000cd',
    mediumorchid = '#ba55d3',
    mediumpurple = '#9370db',
    mediumseagreen = '#3cb371',
    mediumslateblue = '#7b68ee',
    mediumspringgreen = '#00fa9a',
    mediumturquoise = '#48d1cc',
    mediumvioletred = '#c71585',
    midnightblue = '#191970',
    mintcream = '#f5fffa',
    mistyrose = '#ffe4e1',
    moccasin = '#ffe4b5',
    navajowhite = '#ffdead',
    navy = '#000080',
    oldlace = '#fdf5e6',
    olive = '#808000',
    olivedrab = '#6b8e23',
    orange = '#ffa500',
    orangered = '#ff4500',
    orchid = '#da70d6',
    palegoldenrod = '#eee8aa',
    palegreen = '#98fb98',
    paleturquoise = '#afeeee',
    palevioletred = '#db7093',
    papayawhip = '#ffefd5',
    peachpuff = '#ffdab9',
    peru = '#cd853f',
    pink = '#ffc0cb',
    plum = '#dda0dd',
    powderblue = '#b0e0e6',
    purple = '#800080',
    rebeccapurple = '#663399',
    red = '#ff0000',
    rosybrown = '#bc8f8f',
    royalblue = '#4169e1',
    saddlebrown = '#8b4513',
    salmon = '#fa8072',
    sandybrown = '#f4a460',
    seagreen = '#2e8b57',
    seashell = '#fff5ee',
    sienna = '#a0522d',
    silver = '#c0c0c0',
    skyblue = '#87ceeb',
    slateblue = '#6a5acd',
    slategray = '#708090',
    slategrey = '#708090',
    snow = '#fffafa',
    springgreen = '#00ff7f',
    steelblue = '#4682b4',
    tan = '#d2b48c',
    teal = '#008080',
    thistle = '#d8bfd8',
    tomato = '#ff6347',
    turquoise = '#40e0d0',
    violet = '#ee82ee',
    wheat = '#f5deb3',
    white = '#ffffff',
    whitesmoke = '#f5f5f5',
    yellow = '#ffff00',
    yellowgreen = '#9acd32',
}

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
---@param alpha? number
---@return rgba
function rgba.new( red, green, blue, alpha )
    libraryUtil.checkTypeMulti( 'Module:Rgba.new', 1, red, {'number', 'string'} )
    libraryUtil.checkType( 'Module:Rgba.new', 2, green, 'number', true )
    libraryUtil.checkType( 'Module:Rgba.new', 3, blue, 'number', true )
    libraryUtil.checkType( 'Module:Rgba.new', 4, alpha, 'number', true )

    if type( red ) == 'string' then
        local color = red
        local colorName = string.match(color, '^%w+$')

        if colorName then
            color = namedColors[colorName]
            assert(color ~= nil, 'Unknown color "' .. colorName .. '"')
        end

        red, green, blue, alpha = color:match( '#(%x%x)(%x%x)(%x%x)(%x?%x?)' )

        if red == nil then
            error( 'Malformed rgba hex code', 2 )
        end

        red = tonumber( red, 16 )
        green = tonumber( green, 16 )
        blue = tonumber( blue, 16 )
        alpha = (alpha and #alpha == 2) and (tonumber( alpha, 16 ) / 255) or 1
    end

    ---@class rgba
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