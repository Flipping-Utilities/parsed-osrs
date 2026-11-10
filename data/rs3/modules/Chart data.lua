---@class chart
local chart = {}

---@class dataSet
local dataSet = {}

local libraryUtil = require( 'Module:libraryUtil' )
local rgba = require( 'Module:Rgba' )
local isEmpty = require( 'Module:Paramtest' ).is_empty
local arr = require( 'Module:Array' )
local colors = require( 'Module:Chart data/Colors' )
local checkType = libraryUtil.checkType
local checkTypeMulti = libraryUtil.checkTypeMulti

---@alias xyData table<string, number>
---@alias xyDataSet xyData[]
---@alias dataArr number[]
---@alias options table<string, string|number|boolean|table>

---@param val any
---@param default any
---@return any
local function default( val, default )
    if val == nil or (type( val ) == 'string' and isEmpty( val )) then
        return default
    else
        return val
    end
end

---@param obj chart | dataSet
---@param options options
local function defaultOptions( obj, options )
     local function _setOptions( tbl, options )
        for k, v in pairs( options ) do
            if type( v ) == 'table' and type( tbl[k] ) == 'table' then
                _setOptions( tbl[k], v )
            else
                tbl[k] = default( tbl[k], v )
            end
        end
    end

    _setOptions( obj, options )
end

local function stripNonChartJsVariables( tbl )
    local stripVarNames = {
        colorPalette = true,
        backgroundAlpha = true,
        hoverLightenValue = true,
        hoverSaturateValue = true,
        hoverAlpha = true,
        widthVal = true,
        heightVal = true,
        flippedXY = true,
        parent = true
    }

    local function _strip( tbl )
        for k, v in pairs( tbl ) do
            if stripVarNames[k] then
                tbl[k] = nil
            elseif type( v ) == 'table' then
                _strip( v )
            end
        end
    end

    _strip( tbl )
end

---@param tbl table
---@param seen table | nil @Only for internal use
local function stripInvalidValues( tbl, seen )
    seen = seen or {}
    seen[tbl] = true

    for k, v in pairs( tbl ) do
        if type( k ) == 'table' or type( k ) == 'function' then
            tbl[k] = nil
        elseif type( v ) == 'function' then
            tbl[k] = nil
        elseif seen[v] then
            tbl[k] = nil
        elseif type( v ) == 'table' then
            local mt = getmetatable( v )
            if mt and mt.__tostring and mt ~= arr then
                tbl[k] = tostring( v )
            else
                stripInvalidValues( v, seen )
            end
        end
    end

    setmetatable( tbl, nil )
end


-- =====================
--      Chart class
-- =====================
local checkChartClass = libraryUtil.makeCheckClassFunction( 'Module:Chart data' , 'chart', chart, 'chart object' )
chart.rgba = rgba
chart.colorPalettes = {}
for _, colorPalette in ipairs(colors) do
	chart.colorPalettes[colorPalette.name] = arr.map(colorPalette, rgba.new)
end

function chart.main( frame )
    return chart._main( (frame:getParent() or frame).args )
end

---@param args table
---@return string
function chart._main( args )
    checkType( 'Module:Chart_data._main', 1, args, 'table' )

    local data = args

    if not data.isChartObj then
        local moduleName = args.dataModule or args[1]
        local funcName = args['function'] or args[2]

        if isEmpty( moduleName ) then
            error( 'Data module was not provided or is empty' )
        end

        if moduleName:find( '[Mm]odule:' ) == nil then
            moduleName = 'Module:' .. moduleName
        end

        if funcName then
            data = require( moduleName )[ funcName ]( args )

            assert( type( data )=='table', string.format(
                "Error: function '%s' from module '%s' returned an invalid type (table expected, got %s)",
                funcName, moduleName, type( data ) ) )

            if data.isChartObj and not data.isFinished then
                data:finish()
            end
        else
            data = mw.loadData( moduleName )
        end
    end

    local width = args.width or data.width or 'min(540px, 100%, 100vw - 2em)'
    local height = args.height or data.height or 'min(400px, 100vh - 2em)'
    local minWidth = args.minWidth or args.min_width or data.minWidth or '300px'
    local minHeight = args.minHeight or args.min_height or data.minHeight or '300px'

    return string.format(
        '<div class="rsw-chartjs rsw-chartjs-config tile" style="position:relative; margin:1em 0; width:%s; height:%s; min-width:%s; min-height:%s; max-width:unset;%s"><pre>%s</pre></div>',
        width,
        height,
        minWidth,
        minHeight,
        data.resizable and ' resize:both; overflow:hidden; padding:0 5px 5px 0;' or '',
        mw.text.jsonEncode( data )
    )
end

---@param ys number[]
---@param xs number[] | nil
---@return xyDataSet
function chart.convertToXYFormat( ys, xs )
    checkType( 'Module:Chart_data.convertToXYFormat', 1, ys, 'table' )
    checkType( 'Module:Chart_data.convertToXYFormat', 2, xs, 'table', true )

    xs = xs or {}
    local ret = {}

    for i,v in ipairs( ys ) do
        table.insert( ret, { x=(xs[i] or i), y=v } )
    end

    return ret
end

---@param func function
---@param start_x number
---@param end_x number
---@param step number?
---@return xyDataSet
function chart.generateXYFromFunc( func, start_x, end_x, step )
    checkType( 'Module:Chart_data.generateXYFromFunc', 1, func, 'function' )
    checkType( 'Module:Chart_data.generateXYFromFunc', 2, start_x, 'number' )
    checkType( 'Module:Chart_data.generateXYFromFunc', 3, end_x, 'number' )
    checkType( 'Module:Chart_data.generateXYFromFunc', 4, step, 'number',  true )

    step = step or 1
    local ret = {}

    for i = start_x, end_x, step do
        table.insert( ret, { x=i, y=func( i ) } )
    end

    return ret
end

---@param low_chance number
---@param high_chance number
---@param start_level number
---@param end_level number
---@return xyDataSet
function chart.jagexInterpolation( low_chance, high_chance, start_level, end_level )
    checkType( 'Module:Chart_data.jagexInterpolation', 1, low_chance, 'number' )
    checkType( 'Module:Chart_data.jagexInterpolation', 2, high_chance, 'number' )
    checkType( 'Module:Chart_data.jagexInterpolation', 3, start_level, 'number' )
    checkType( 'Module:Chart_data.jagexInterpolation', 4, end_level, 'number' )

    local function interpolate( x )
        return math.floor( ( (99-x)*low_chance + (x-1)*high_chance ) / 98 )
    end

    return chart.generateXYFromFunc( interpolate, start_level, end_level )
end

---@param setup options
---@return chart
function chart.newChart( setup )
    checkType( 'Module:Chart_data.newChart', 1, setup, 'table', true )
    local obj = setup or {}

    if obj.type == 'bar' then
        defaultOptions( obj, {
            options = {
                fill = true,
                backgroundAlpha = 0.4,
                hoverLightenValue = 0.95,
                hoverAlpha = 0.5,
                hoverSaturateValue = 1,
                scales = {
                    x = { -- This is used for horizontal bar graphs
                        ticks = {
                            beginAtZero = true
                        }
                    },
                    y = {
                        ticks = {
                            beginAtZero = true
                        }
                    }
                }
            }
        } )
    elseif obj.type == 'bubble' then
        defaultOptions( obj, {
            options = {
                fill = true,
                backgroundAlpha = 0.4,
                hoverLightenValue = 0.95,
                hoverAlpha = 0.5,
                hoverSaturateValue = 1
            }
        } )
    elseif obj.type == 'radar' then
        defaultOptions( obj, {
            options = {
                scale = {
                    ticks = {
                        showLabelBackdrop = false,
                        z = 1
                    }
                }
            }
        } )
    elseif obj.type == 'pie' or obj.type == 'doughnut' then
        defaultOptions( obj, {
            options = {
                fill = true,
                backgroundAlpha = 0.8,
                hoverLightenValue = 0.95,
                hoverAlpha = 0.9,
                hoverSaturateValue = 1
            }
        } )
    elseif obj.type == 'polarArea' then
        defaultOptions( obj, {
            options = {
                fill = true,
                backgroundAlpha = 0.5,
                hoverLightenValue = 0.95,
                hoverAlpha = 0.6,
                hoverSaturateValue = 1,
                scale = {
                    ticks = {
                        showLabelBackdrop = false,
                        z = 1
                    }
                }
            }
        } )
    end

    defaultOptions( obj, {
        isChartObj = true,
        type = 'scatter',
        widthVal = 540,
        heightVal = 400,
        minWidth = 300,
        minHeight = 300,
        resizable = true,
        data = {
            datasets = {}
        },
        options = {
            fill = false,
            colorPalette = chart.colorPalettes.qualitative,
            backgroundAlpha = 0.3,
            hoverLightenValue = 0.95,
            hoverAlpha = 0.5,
            hoverSaturateValue = 1,
            maintainAspectRatio = false,
            title = {
                font = {
                    size = 18
                }
            },
            tooltips = {
                intersect = false
            },
        }
    } )

    setmetatable( obj, chart )

    obj:setDimensions( obj.widthVal, obj.heightVal, obj.minWidth, obj.minHeight, obj.resizable )

    return obj
end

---@vararg xyDataSet | dataArr
---@return chart
function chart:addDataSets( ... )
    checkChartClass( self, 'addDataSets' )
    local sets = { ... }

    for i, set in ipairs( sets ) do
        checkType( 'chart.addDataSets', i, set, 'table' )

        if not arr.contains( self.data.datasets, set, false ) then
            table.insert( self.data.datasets, set )
        end
    end

    return self
end

---@param labels string
---@return chart
function chart:addDataLabels( labels )
    checkChartClass( self, 'addDataLabels' )
    checkType( 'Module:Chart_data.addDataLabels', 1, labels, 'table' )

    self.data.labels = default( self.data.labels, {} )

    for _, label in ipairs( labels ) do
        table.insert( self.data.labels, label )
    end

    return self
end

---@param width number | string
---@param height number | string | nil
---@param minWidth number | string | nil
---@param minHeight number | string | nil
---@param resizable boolean | nil
---@return chart
function chart:setDimensions( width, height, minWidth, minHeight, resizable )
    checkChartClass( self, 'setDimensions' )
    checkTypeMulti( 'chart.setDimensions', 1, width, {'number', 'string'} )
    checkTypeMulti( 'chart.setDimensions', 2, height, {'number', 'string', 'nil'} )
    checkTypeMulti( 'chart.setDimensions', 3, minWidth, {'number', 'string', 'nil'} )
    checkTypeMulti( 'chart.setDimensions', 4, minHeight, {'number', 'string', 'nil'} )
    checkType( 'chart.setDimensions', 5, resizable, 'boolean', true )

    if type( width ) == 'number' then
        self.widthVal = width
        self.width = width .. 'px'
    elseif type( width ) == 'string' then
        self.width = width
        self.widthVal = tonumber( width:match( '%d+' ) )

        if type( self.widthVal ) ~= 'number' then
            error( "bad argument #1 to 'chart.setDimensions' (input doesn't contain a number)", 2 )
        end
    else
        self.widthVal = nil
        self.width = ''
    end

    if type( height ) == 'number' then
        self.heightVal = height
        self.height = height .. 'px'
    elseif type( height ) == 'string' then
        self.height = height
        self.heightVal = tonumber( height:match( '%d+' ) )

        if type( self.heightVal ) ~= 'number' then
            error( "bad argument #2 to 'chart.setDimensions' (input doesn't contain a number)", 2 )
        end
    else
        self.heightVal = nil
        self.height = ''
    end

    if type( minWidth ) == 'number' then
        self.minWidth = minWidth .. 'px'
    elseif type( minWidth ) == 'string' then
        self.minWidth = minWidth
    end

    if type( minHeight ) == 'number' then
        self.minHeight = minHeight .. 'px'
    elseif type( minHeight ) == 'string' then
        self.minHeight = minHeight
    end

    self.resizable = default( resizable, self.resizable )

    if arr.contains( {'pie', 'doughnut', 'radar', 'polarArea'}, self.type ) then
        self.height = self.width
        self.minHeight = self.minWidth
        self.options.aspectRatio = 1
    else
        if self.widthVal and self.heightVal then
            self.options.aspectRatio = self.widthVal / self.heightVal
        elseif self.widthVal then
            self.height = self.width
            self.options.aspectRatio = 1
        else
            self.options.aspectRatio = 1
        end
    end

	self.width = string.format( 'min(%s, 100%%, 100vw - 2em)', self.width )
    self.height = string.format( 'min(%s, 100vh - 2em)', self.height )

    return self
end

---@param text string | table | nil
---@param position string | nil
---@return chart
function chart:setTitle( text, position )
    checkChartClass( self, 'setTitle' )
    checkTypeMulti( 'chart.setTitle', 1, text, {'string', 'table', 'nil'} )
    checkType( 'chart.setTitle', 1, position, 'string', true )

    self:setOptions{
        title = {
            display = text and true or false,
            text = text,
            position = position or 'top'
        }
    }

    return self
end

---@param label string | nil
---@return chart
function chart:setXLabel( label )
    checkChartClass( self, 'setXLabel' )
    checkType( 'chart.setXLabel', 1, label, 'string', true )

    if arr.contains( {'line', 'bar', 'bubble', 'scatter'}, self.type ) then
        self:setOptions{
            scales = {
                x = {
                    scaleLabel = {
                        display = label and true or false,
                        labelString = label
                    }
                }
            }
        }
    end

    return self
end

---@param label string | nil
---@return chart
function chart:setYLabel( label )
    checkChartClass( self, 'setYLabel' )
    checkType( 'chart.setYLabel', 1, label, 'string', true )

    if arr.contains( {'line', 'bar', 'bubble', 'scatter'}, self.type ) then
        self:setOptions{
            scales = {
                y = {
                    scaleLabel = {
                        display = label and true or false,
                        labelString = label
                    }
                }
            }
        }
    end

    return self
end

---@param min number | nil
---@param max number | nil
---@param step number | nil
---@return chart
function chart:setXLimits( min, max, step )
    checkChartClass( self, 'setXLimits' )
    checkType( 'chart.setXLimits', 1, min, 'number', true )
    checkType( 'chart.setXLimits', 2, max, 'number', true )
    checkType( 'chart.setXLimits', 3, step, 'number', true )

    if arr.contains( {'bubble', 'scatter'}, self.type ) then
        self:setOptions{
            scales = {
                x = {
                    min = min,
                    max = max,
                    ticks = {
                        stepSize = step
                    }
                }
            }
        }
    end

    return self
end

---@param min number | nil
---@param max number | nil
---@param step number | nil
---@return chart
function chart:setYLimits( min, max, step )
    checkChartClass( self, 'setYLimits' )
    checkType( 'chart.setYLimits', 1, min, 'number', true )
    checkType( 'chart.setYLimits', 2, max, 'number', true )
    checkType( 'chart.setYLimits', 3, step, 'number', true )

    if arr.contains( {'line', 'bar', 'bubble', 'scatter'}, self.type ) then
        self:setOptions{
            scales = {
                y = {
                    min = min,
                    max = max,
                    ticks = {
                        stepSize = step
                    }
                }
            }
        }
    end

    return self
end

---@param format string
---@return chart
function chart:setYFormat( format )
    checkChartClass( self, 'setYFormat' )
    checkType( 'chart.setYFormat', 1, format, 'string', true )

    self:setOptions{
        scales = {
            y = {
                ticks = {
                    format = format
                }
            }
        }
    }

    return self
end

---@param format string
---@return chart
function chart:setXFormat( format )
    checkChartClass( self, 'setXFormat' )
    checkType( 'chart.setXFormat', 1, format, 'string', true )

    self:setOptions{
        scales = {
            x = {
                ticks = {
                    format = format
                }
            }
        }
    }

    return self
end

---@param min number | nil
---@param max number | nil
---@param step number | nil
---@return chart
function chart:setRadialLimits( min, max, step )
    checkChartClass( self, 'setRadialLimits' )
    checkType( 'chart.setRadialLimits', 1, min, 'number', true )
    checkType( 'chart.setRadialLimits', 2, max, 'number', true )
    checkType( 'chart.setRadialLimits', 3, step, 'number', true )

    if arr.contains( {'radar', 'polarArea'}, self.type ) then
        self:setOptions{
            scale = {
                min  = min,
                max = max,
                ticks = {
                    stepSize = step
                }
            }
        }
    end

    return self
end

---@param type string | nil
---@return chart
function chart:setXAxisType( type )
    checkChartClass( self, 'setXAxisType' )
    checkType( 'chart.setXAxisType', 1, type, 'string', true )

    if arr.contains( {'bar', 'bubble', 'line', 'scatter'}, self.type ) then
        self:setOptions{
            scales = {
                x = {
                    type = type,
                    ticks = {
                        format = {
                            maximumSignificantDigits = (type == 'logarithmic') and 3 or nil
                        }
                    }
                }
            }
        }
    end

    return self
end

---@param type string | nil
---@return chart
function chart:setYAxisType( type )
    checkChartClass( self, 'setYAxisType' )
    checkType( 'chart.setYAxisType', 1, type, 'string', true )

    if arr.contains( {'bar', 'bubble', 'line', 'scatter'}, self.type ) then
        self:setOptions{
            scales = {
                y = {
                    type = type,
                    ticks = {
                        format = {
                            maximumSignificantDigits = (type == 'logarithmic') and 3 or nil
                        }
                    }
                }
            }
        }
    end

    return self
end

---@param val boolean
---@return chart
function chart:showLegend( val )
    checkChartClass( self, 'showLegend' )
    checkType( 'chart.showLegend', 1, val, 'boolean' )

    self:setOptions{
        legend = {
            display = val
        }
    }

    return self
end

---@param format string
---@return chart
function chart:setTooltipFormat( format )
    checkChartClass( self, 'setTooltipFormat' )
    checkType( 'chart.setTooltipFormat', 1, format, 'string', true )

    self:setOptions{
        tooltips = {
        	format = format
        }
    }

    return self
end

---@param count number
---@return chart
function chart:setDatasetsPerGroup( count )
    checkChartClass( self, 'setDatasetsPerGroup' )
    checkType( 'chart.setDatasetsPerGroup', 1, count, 'number', true )

    self:setOptions{
        datasetsPerGroup = count
    }

    return self
end

---@return chart
function chart:flipXY()
    checkChartClass( self, 'flipXY' )

    if self.type == 'bar' then
        self:setXAxisType( 'linear' )
            :setYAxisType( 'category' )
            :setOptions{
                scales = {
                    x = {
                        offset = false,
                        gridLines = {
                            offsetGridLines = false
                        }
                    }
                }
            }

        self.flippedXY = true

        for _, v in ipairs( self.data.datasets ) do
            v.indexAxis = 'y'
        end
    end

    return self
end

---@param options options
---@return chart
function chart:setOptions( options )
    checkChartClass( self, 'setOptions' )
    checkType( 'chart.setOptions', 1, options, 'table' )

    local function _setOptions( tbl, options )
        for k, v in pairs( options ) do
            if type( v ) == 'table' and type( tbl[k] ) == 'table' then
                _setOptions( tbl[k], v )
            else
                tbl[k] = v
            end
        end
    end

    _setOptions( self.options, options )

    return self
end

---@return string | table
function chart:finish()
    checkChartClass( self, 'finish' )

    for i, set in ipairs( self.data.datasets ) do
        if (self.options.colorPalette or set.colorPalette) and
            self.options.backgroundAlpha and
            self.options.hoverLightenValue and
            self.options.hoverSaturateValue and
            self.options.hoverAlpha
        then
            if type(set.baseColor) == 'string' then
                set.color = rgba.new(set.baseColor)
            end
            if type(set.color) == 'string' then
                set.color = rgba.new(set.color)
            end
            set.color = set.color or set.baseColor -- [[MediaWiki:Gadget-Charts-core.js]] uses baseColor instead of just color
            set.baseColor = set.color

            if arr.contains( {'bar', 'pie', 'doughnut', 'polarArea'}, self.type ) then
                if set.color and not set.colorPalette then
                    set.borderColor = tostring( set.color )
                    set.hoverBorderColor = tostring( set.color:lighten( set.hoverLightenValue or self.options.hoverLightenValue )
                                                              :saturate( set.hoverSaturateValue or self.options.hoverSaturateValue ) )

                    set.backgroundColor = tostring( set.color:fade( set.backgroundAlpha or self.options.backgroundAlpha ) )
                    set.hoverBackgroundColor = tostring( set.color:lighten( set.hoverLightenValue or self.options.hoverLightenValue )
                                                                  :saturate( set.hoverSaturateValue or self.options.hoverSaturateValue )
                                                                  :fade( set.hoverAlpha or self.options.hoverAlpha ) )
                else
                    set.borderColor = {}
                    set.hoverBorderColor = {}
                    set.backgroundColor = {}
                    set.hoverBackgroundColor = {}

                    local palette = default( set.colorPalette, self.options.colorPalette )

                    for j = 1, #set.data do
                        local currentColor = palette[j] or rgba.new(0, 0, 0)
                        table.insert( set.borderColor, tostring( currentColor ) )
                        table.insert( set.hoverBorderColor,
                                      tostring( currentColor:lighten( set.hoverLightenValue or self.options.hoverLightenValue )
                                                         :saturate( set.hoverSaturateValue or self.options.hoverSaturateValue ) ) )

                        table.insert( set.backgroundColor, tostring( currentColor:fade( set.backgroundAlpha or self.options.backgroundAlpha ) ) )
                        table.insert( set.hoverBackgroundColor,
                                      tostring( currentColor:lighten( set.hoverLightenValue or self.options.hoverLightenValue )
                                                         :saturate( set.hoverSaturateValue or self.options.hoverSaturateValue )
                                                         :fade( set.hoverAlpha or self.options.hoverAlpha ) ) )
                    end
                end
            else
                local currentDatasetGroupIndex = i
                if self.options.datasetsPerGroup then
                	currentDatasetGroupIndex = math.modf((i-1)/self.options.datasetsPerGroup)+1
                end
                local palette = set.colorPalette or self.options.colorPalette
                local currentColor = set.color or palette[currentDatasetGroupIndex] or rgba.new(0, 0, 0)
                set.borderColor = set.borderColor or currentColor

                if not set.hoverBorderColor then
                    set.hoverBorderColor = set.borderColor:lighten( set.hoverLightenValue or self.options.hoverLightenValue )
                                                          :saturate( set.hoverSaturateValue or self.options.hoverSaturateValue )
                end

                set.backgroundColor = set.backgroundColor or currentColor:fade( set.backgroundAlpha or self.options.backgroundAlpha )

                if not set.hoverBackgroundColor then
                    set.hoverBackgroundColor = set.backgroundColor:lighten( set.hoverLightenValue or self.options.hoverLightenValue )
                                                                  :saturate( set.hoverSaturateValue or self.options.hoverSaturateValue )
                                                                  :fade( set.hoverAlpha or self.options.hoverAlpha )
                end

                set.fill = default( default( set.fill, self.options.fill ), false )
            end
        end
    end

    stripNonChartJsVariables( self )
    stripInvalidValues( self )
    self.isFinished =  true

    return self
end

---@return string
function chart:tostring()
    checkChartClass( self, 'tostring' )
    self:finish()
    return chart._main( self )
end

function chart:debug()
    checkChartClass( self, 'debug' )
    local temp = chart.__tostring  -- Prevent chart from being turned into a json
    chart.__tostring = nil
    mw.logObject( self )
    chart.__tostring = temp
end

chart.__index = chart
chart.__tostring = chart.tostring
chart.__concat = function( x, y )
    return tostring( x ) .. tostring( y )
end

-- =======================
--      DataSet class
-- =======================
local checkDataSetClass = libraryUtil.makeCheckClassFunction( 'Module:Chart data', 'dataSet', dataSet, 'dataSet object' )

---@param setup options
---@return dataSet
function chart:newDataSet( setup )
    checkChartClass( self, 'newDataSet' )
    checkType( 'chart.newDataSet', 1, setup, 'table', true )
    local obj = setup or {}

    if self.type == 'scatter'  then
        obj.showLine = default( obj.showLine, true )
        obj.pointRadius = default( obj.pointRadius, 0 )
    end

    if self.type == 'bar' then
        obj.borderWidth = default( obj.borderWidth, 1 )

        if self.flippedXY then
            obj.indexAxis = 'y'
        end
    end

    obj.data = default( obj.data, {} )
    obj.clip = 5
    obj.parent = self

    self:addDataSets( obj )

    return setmetatable( obj, dataSet )
end

---@param data xyDataSet | dataArr
---@return dataSet
function dataSet:addData( data )
    checkDataSetClass( self, 'addData' )
    checkType( 'dataSet.addData', 1, data, 'table' )

    for _, v in ipairs( data ) do
        table.insert( self.data, v )
    end

    return self
end

---@param data xyData | number
---@return dataSet
function dataSet:addDataPoint( data )
    checkDataSetClass( self, 'addDataPoint' )
    checkTypeMulti( 'dataSet.addDataPoint', 1, data, {'table', 'number'} )
    table.insert( self.data, data )

    return self
end

---@param options options
---@return dataSet
function dataSet:setOptions( options )
    checkDataSetClass( self, 'setOptions' )
    checkType( 'dataSet.setOptions', 1, options, 'table' )

    local function _setOptions( tbl, options )
        for k, v in pairs( options ) do
            if type( v ) == 'table' and type( tbl[k] ) == 'table' then
                _setOptions( tbl[k], v )
            else
                tbl[k] = v
            end
        end
    end

    _setOptions( self, options )

    return self
end

---@return chart
function dataSet:done()
    checkDataSetClass( self, 'done' )
    return self.parent
end

dataSet.__index = dataSet

return chart