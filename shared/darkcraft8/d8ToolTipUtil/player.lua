-- maybe expend this ?... currently only used to reset d8TooltipUtil open state
function init()
    closePlayerTooltips()
end

function closePlayerTooltips()
    local tooltipUtilOpen = player.getProperty("d8TooltipUtilOpen")
    if type(tooltipUtilOpen) ~= "table" then
        tooltipUtilOpen = {}
    end
    tooltipUtilOpen[player.uniqueId()] = false
    player.setProperty("d8TooltipUtilOpen", tooltipUtilOpen)-- say if a tooltip is open
end