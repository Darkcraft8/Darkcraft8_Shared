require "/scripts/vec2.lua"
local canvas = nil
local paneTempID = nil
local lastCanvasPos = {0, 0}
local startPos = {0, 0}
function sayToParentThatItOpen()
    local tooltipUtilOpen = player.getProperty("d8TooltipUtilOpen")
    if type(tooltipUtilOpen) ~= "table" then
        tooltipUtilOpen = {}
    end
    tooltipUtilOpen[paneTempID] = true
    player.setProperty("d8TooltipUtilOpen", tooltipUtilOpen)-- say that a tooltip is open
end

function shouldBeClosed()
    local tooltipUtilOpen = player.getProperty("d8TooltipUtilOpen")
    if type(tooltipUtilOpen) ~= "table" then
        return true
    else
        return not tooltipUtilOpen[paneTempID]
    end
end

function init()
    paneTempID = config.getParameter("paneTempID")
    if not paneTempID then sb.logError("paneTempID is missing") pane.dismiss() return end

    sayToParentThatItOpen()
    if pane.setPosition then
        local cursorPos = player.getProperty("d8TooltipUtilCursorPos")
        if input and interface then
            cursorPos = vec2.mul(input.mousePosition(), 1 / interface.scale()) -- input.mousePosition return the mousePosition ON Screen without the interface scaling
        end
        local offset = player.getProperty("d8TooltipUtil_offset")
        local newPos = vec2.sub(cursorPos, offset)
        pane.setPosition(newPos)
    end
end

function update(dt)
    if shouldBeClosed() then pane.dismiss() end
    if pane.setPosition then
        local cursorPos = player.getProperty("d8TooltipUtilCursorPos")
        local screenSize
        if input and interface then
            cursorPos = vec2.mul(input.mousePosition(), 1 / interface.scale())
        end
        local offset = player.getProperty("d8TooltipUtil_offset")
        local newPos = vec2.sub(cursorPos, offset)
        pane.setPosition(newPos)
    end
    
end

function uninit()

end
