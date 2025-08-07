-- maybe ?
function init()
    closePlayerTooltips()
end

function closePlayerTooltips()
    local tooltipUtilOpen = player.getProperty("d8TooltipUtilOpen")
    if type(tooltipUtilOpen) ~= "table" then
        tooltipUtilOpen = {}
    end
    tooltipUtilOpen[player.uniqueId()] = false
    player.setProperty("d8TooltipUtilOpen", tooltipUtilOpen)-- say that a tooltip is open
end