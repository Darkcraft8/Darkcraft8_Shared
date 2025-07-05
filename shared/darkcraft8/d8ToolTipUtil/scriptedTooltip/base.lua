require "/scripts/vec2.lua"
local canvas = nil
local lastCanvasPos = {0, 0}
local startPos = {0, 0}
function init()
    if pane.setPosition then
        local cursorPos = player.getProperty("d8TooltipUtilCursorPos")
        if input then
            cursorPos = vec2.mul(input.mousePosition(), 0.5)
        end
        local offset = player.getProperty("d8TooltipUtil_offset")
        local newPos = vec2.sub(cursorPos, offset)
        pane.setPosition(newPos)
    end
    
    player.setProperty("d8TooltipUtilOpen", true)-- say that a tooltip is open
end

function update(dt)
    if not player.getProperty("d8TooltipUtilOpen") then pane.dismiss() end
    if pane.setPosition then
        local cursorPos = player.getProperty("d8TooltipUtilCursorPos")
        local screenSize
        if input then
            cursorPos = vec2.mul(input.mousePosition(), 0.5)
        end
        local offset = player.getProperty("d8TooltipUtil_offset")
        local newPos = vec2.sub(cursorPos, offset)
        pane.setPosition(newPos)
    end
    
end

function uninit()

end
