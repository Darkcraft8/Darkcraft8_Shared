local function hasAccessToRequiredTable()
    if not world then
        sb.logWarn("[d8SharedRendererUtil] world functions table ins't available, abandoning call")
        return false
    end

    if not world.sendEntityMessage then
        sb.logWarn("[d8SharedRendererUtil] world.sendEntityMessage function ins't available, abandoning call")
        return false
    end

    if not player then
        sb.logWarn("[d8SharedRendererUtil] player functions table ins't available, abandoning call")
        return false
    end
    
    if not world.entityExists(player.id()) then
        sb.logWarn("[d8SharedRendererUtil] player entity not initialised/doesn't exist, abandoning call")
        return false
    end

    return true
end

d8SharedRendererUtil = {}
d8SharedRendererUtil.addDrawable = function(drawable, priority, identifier)
    if hasAccessToRequiredTable() then
        local rpcDrawable = world.sendEntityMessage(player.id(), "d8SharedRenderer|addDrawable", drawable, priority, identifier, player.uniqueId())
        local rpcResult = false
        if rpcDrawable then
            if rpcDrawable:finished() then
                rpcResult = rpcDrawable:result()
            end
        end
        return rpcResult
    end
end

d8SharedRendererUtil.updateDrawable = function(drawable, identifier)
    if hasAccessToRequiredTable() then
        local rpcDrawable = world.sendEntityMessage(player.id(), "d8SharedRenderer|updateDrawable", drawable, identifier, player.uniqueId())
        local rpcResult = false
        if rpcDrawable then
            if rpcDrawable:finished() then
                rpcResult = rpcDrawable:result()
            end
        end
        return rpcResult
    end
end

d8SharedRendererUtil.removeDrawable = function(identifier)
    if hasAccessToRequiredTable() then
        local rpcDrawable = world.sendEntityMessage(player.id(), "d8SharedRenderer|removeDrawable", identifier, player.uniqueId())
        local rpcResult = false
        if rpcDrawable then
            if rpcDrawable:finished() then
                rpcResult = rpcDrawable:result()
            end
        end
        return rpcResult
    end
end

d8SharedRendererUtil.hasDrawable = function(identifier)
    if hasAccessToRequiredTable() then
        local rpcDrawable = world.sendEntityMessage(player.id(), "d8SharedRenderer|hasDrawable", identifier, player.uniqueId())
        local rpcResult = false
        if rpcDrawable then
            if rpcDrawable:finished() then
                rpcResult = rpcDrawable:result()
            end
        end
        return rpcResult
    end
end

