require "/scripts/vec2.lua"
local canvas = nil
function init()
    if interface then
        if interface.bindCanvas then
            canvas = interface.bindCanvas("d8Tooltip")
        end
    end
    if pane.setPosition then
        local cursorPos = player.getProperty("d8TooltipUtilCursorPos")
        if canvas then
            cursorPos = canvas:mousePosition()
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
        if canvas then
            cursorPos = canvas:mousePosition()
        end
        local offset = player.getProperty("d8TooltipUtil_offset")
        local newPos = vec2.sub(cursorPos, offset)
        pane.setPosition(newPos)
    end
end

function uninit()

end
