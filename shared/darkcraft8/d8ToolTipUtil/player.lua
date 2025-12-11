-- maybe expend this ?... currently only used to reset d8TooltipUtil open state
function init()
    closePlayerTooltips()
end

function closePlayerTooltips()
    player.setProperty("d8TooltipUtilOpen", {})-- say if a tooltip is open
end