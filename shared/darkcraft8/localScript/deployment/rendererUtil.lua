local function hasAccessToRequiredTable()
    if not world then
        sb.logInfo("[d8SharedRendererUtil] world functions table ins't available, abandoning call")
        return false
    end

    if not world.sendEntityMessage then
        sb.logInfo("[d8SharedRendererUtil] world.sendEntityMessage function ins't available, abandoning call")
        return false
    end

    if not player then
        sb.logInfo("[d8SharedRendererUtil] player functions table ins't available, abandoning call")
        return false
    end

    return true
end

d8SharedRendererUtil = {}
d8SharedRendererUtil.addDrawable = function(drawable, priority, identifier)
    if hasAccessToRequiredTable() then
        return world.sendEntityMessage(player.id(), "d8SharedRenderer|addDrawable", drawable, priority, identifier, player.uniqueId())
    end
end

d8SharedRendererUtil.updateDrawable = function(drawable, identifier)
    if hasAccessToRequiredTable() then
        return world.sendEntityMessage(player.id(), "d8SharedRenderer|updateDrawable", drawable, identifier, player.uniqueId())
    end
end

d8SharedRendererUtil.removeDrawable = function(identifier)
    if hasAccessToRequiredTable() then
        return world.sendEntityMessage(player.id(), "d8SharedRenderer|removeDrawable", identifier, player.uniqueId())
    end
end