require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"
require "/shared/darkcraft8/canvas/base.lua"

if not canvas then canvas = {} end
if not canvasStorage then canvasStorage = {} end
canvasStorage.camPos = {0, 0}
canvasStorage.nextCamPos = {0, 0}
canvasStorage.camZoom = 1

--- particle system ---
-- Exemple
--  particleCfg = {
--      position = {0, 0},
--      velocity = {0, 1}, -- both init and current velocity
--      targetVelocity = {0, 1},
--      targetVelocityStrength = {0, 1},
--      image = "/assetmissing.png?crop=0;0;1;1?replace=ffffff00;ffffff60?border=5;f0f0f050;ffffff10",
--      timeToLive = 2,
--      timeToDestroy = 2,
--      origin = "center"
--      variant = {
--          velocity = {10, 0},
--          position = {3, 6},
--          timeToDestroy = 2.5,
--          rotation = 180
--      },
--      destructionKind = "fade",
--      color = {255, 255, 255, 255},
--      persistent = false
--  }
canvas.addParticles = function(_particleCfgs)
    for _, particleCfg in ipairs(_particleCfgs) do 
        canvas.addParticle(particleCfg)
    end
end
canvas.addParticle = function(_particleCfg)
    if not canvasStorage.particle then canvasStorage.particle = {} end
    if _particleCfg then
        local particleCfg = copy(_particleCfg)
        local index = 0
        local newIndex = 1
        while canvasStorage.particle[newIndex] do -- fetch unused index
            newIndex = newIndex + 1
        end
        if newIndex < 1000 then
            local posOffset = canvas.anchor(particleCfg.origin)
            particleCfg.position = vec2.add(particleCfg.position, posOffset)
            -- Variant --- should change so that it check for the type instead of a specific name
            for param, value in pairs(particleCfg.variant) do 
                if type(value) == "number" then
                    particleCfg[param] = (particleCfg[param] or 0) + util.randomInRange({-value, value})
                elseif type(value) == "table" then
                    for index, _value in ipairs(value) do 
                        particleCfg[param][index] = (particleCfg[param][index] or 0) + util.randomInRange({-_value, _value})
                    end
                end
            end
            particleCfg.ogScale = copy(particleCfg.scale) or 1
            if particleCfg.destructionKind == "twinkle" then particleCfg.scale = 0 end
            --
            canvasStorage.particle[newIndex] = particleCfg
        end
    end
end

canvas.removeParticle = function(index) table.remove(canvasStorage.particle, index) end
canvas.clearParticles = function() canvasStorage.particle = {} end
canvas.updateParticle = function(particleCfg, index)    
    if particleCfg.velocity then
        if particleCfg.targetVel[1] ~= particleCfg.velocity[1] then
            local progress = math.min(1.0, 1 - util.clamp(math.abs((particleCfg.targetVel[1] - particleCfg.velocity[1])), 0, 0.99))
            particleCfg.velocity[1] = interp.sin((progress * particleCfg.targetVelStrength[1]) / 1.25, particleCfg.velocity[1], particleCfg.targetVel[1])
        end
        if particleCfg.targetVel[2] ~= particleCfg.velocity[2] then
            local progress = math.min(1.0, 1 - util.clamp(math.abs((particleCfg.targetVel[2] - particleCfg.velocity[2])), 0, 0.99))
            particleCfg.velocity[2] = interp.sin((progress * particleCfg.targetVelStrength[2]) / 1.25, particleCfg.velocity[2], particleCfg.targetVel[2])
        end

        local effectiveVelocity = vec2.mul(particleCfg.velocity, script.updateDt())
        particleCfg.position = vec2.add(particleCfg.position, effectiveVelocity)
    end
    if particleCfg.rotationSpeed then 
        particleCfg.rotation = particleCfg.rotation + (particleCfg.rotationSpeed * script.updateDt())
    end

    local shouldRemove = function(particleCfg)
        local visible = canvas.isVisible(particleCfg.image, particleCfg.position)
        local remove = false
        if particleCfg.position[1] < 0 or particleCfg.position[2] < 0 or particleCfg.position[1] > canvas:size()[1] or particleCfg.position[2] > canvas:size()[2] then
            remove = true
        end
        if not particleCfg.startTime then particleCfg.startTime = particleCfg.timeToLive end
        if not particleCfg.desctructionTime then particleCfg.desctructionTime = (particleCfg.timeToDestroy or 1) end
        
        if canvasStorage.debug then
            if particleCfg.destructionKind == "twinkle" then
                local text = "scale : " .. math.floor(particleCfg.scale)
                local textPositioning = {
                    position = vec2.add(particleCfg.position, {0, 10}),
                    horizontalAnchor = "mid", -- left, mid, right
                    verticalAnchor = "mid", -- top, mid, bottom
                    wrapWidth = nil -- wrap width in pixels or nil
                }
                canvas:drawText(text, textPositioning, 4, {255, 255, 255})
            end
        end
        particleCfg.timeToLive = (particleCfg.timeToLive or 1) - script.updateDt() 
        if particleCfg.timeToLive > 0 then                    
            if particleCfg.destructionKind == "twinkle" then
                local scale = (particleCfg.scale or scale)
                if scale ~= particleCfg.ogScale then
                    local progress = math.min(1.0, particleCfg.startTime - particleCfg.timeToLive, 1)
                    scale = interp.sin(progress, scale, particleCfg.ogScale)
                    particleCfg.scale = scale
                else
                    particleCfg.timeToLive = 0
                end
            end
        else -- add destroy behavior
            local speed = (61 - particleCfg.desctructionTime) * script.updateDt()
            if particleCfg.destructionKind == "twinkle" then
                local scale = (particleCfg.scale or scale)
                if scale ~= 0 then
                    local progress = math.min(1.0, 1 - util.clamp(math.abs(( 0 - scale )), 0, 0.99))
                    scale = interp.sin((progress / (particleCfg.desctructionTime + 1) ) / 1.25, scale, 0)
                    particleCfg.scale = scale
                end
            elseif particleCfg.destructionKind == "fade" then
                local color = ((particleCfg.color or color)[4] or 255)
                if color ~= 0 then
                    local progress = math.min(1.0, 1 - util.clamp(math.abs(( 0 - color )), 0, 0.99))
                    color = interp.sin((progress / (particleCfg.desctructionTime + 1) ) / 1.25, color, 0)
                    particleCfg.color[4] = color
                end
            elseif particleCfg.destructionKind == "shrink" then
                local scale = (particleCfg.scale or scale)
                if scale ~= 0 then
                    local progress = math.min(1.0, 1 - util.clamp(math.abs(( 0 - scale )), 0, 0.99))
                    scale = interp.sin((progress / (particleCfg.desctructionTime + 1) ) / 1.25, scale, 0)
                    particleCfg.scale = scale
                end
            elseif particleCfg.destructionKind == "shrinkAndFade" then
                local scale = (particleCfg.scale or scale)
                if scale ~= 0 then
                    local progress = math.min(1.0, 1 - util.clamp(math.abs(( 0 - scale )), 0, 0.99))
                    scale = interp.sin((progress / (particleCfg.desctructionTime + 1) ) / 1.25, scale, 0)
                    particleCfg.scale = scale
                end

                local color = ((particleCfg.color or color)[4] or 255)
                if color ~= 0 then
                    local progress = math.min(1.0, 1 - util.clamp(math.abs(( 0 - color )), 0, 0.99))
                    color = interp.sin((progress / (particleCfg.desctructionTime + 1) ) / 1.25, color, 0)
                    particleCfg.color[4] = color
                end

            elseif particleCfg.destructionKind == "growAndFade" then
                local scale = (particleCfg.scale or scale)
                if scale ~= particleCfg.ogScale * 2 then
                    local progress = math.min(1.0, 1 - util.clamp(math.abs(( 0 - scale )), 0, 0.99))
                    scale = interp.sin((progress / particleCfg.desctructionTime ) / 1.25, scale, 0)
                    particleCfg.scale = scale
                end

                local color = ((particleCfg.color or color)[4] or 255)
                if color ~= 0 then
                    local progress = math.min(1.0, 1 - util.clamp(math.abs(( 0 - color )), 0, 0.99))
                    color = interp.sin((progress / (particleCfg.desctructionTime + 1) ) / 1.25, color, 0)
                    particleCfg.color[4] = color
                end
            elseif particleCfg.destructionKind == "grow" then
                local scale = (particleCfg.scale or scale)
                if scale ~= particleCfg.ogScale * 2 then
                    local progress = math.min(1.0, 1 - util.clamp(math.abs(( 0 - scale )), 0, 0.99))
                    scale = interp.sin((progress / particleCfg.desctructionTime ) / 1.25, scale, 0)
                    particleCfg.scale = scale
                end
            elseif particleCfg.destructionKind == "particle" then
                canvas.addParticle(particleCfg.particleCfg)
            end
        end

        if (particleCfg.timeToLive or 1) + (particleCfg.timeToDestroy or 1) <= 0 then remove = true end
        if not particleCfg.persistent then if not visible then remove = true end end
        return remove
    end

    if shouldRemove(particleCfg) then
        if index then
            canvasStorage.particle[index] = false
            coroutine.resume(coroutine.create(function(index) canvas.removeParticle(index) end), index)
        end
        return false
    else
        return particleCfg
    end
end

canvas.shouldRender = function()

end

canvas.drawParticles = function() -- a small premade function to draw particles
    if not canvasStorage.particle then return end
    if #canvasStorage.particle == 0 then return end

    for i = 0, #canvasStorage.particle do 
        local particleCfg = canvasStorage.particle[i]
        if particleCfg then            
            local color = {255, 255, 255, 255}
            local scale = 1

            local particleCfg = canvas.updateParticle(particleCfg, i)
            if particleCfg then
                if canvasStorage.debug then
                    local text = "tTL : " .. math.floor(particleCfg.timeToLive)
                    local textPositioning = {
                        position = vec2.add(particleCfg.position, {0, 6}),
                        horizontalAnchor = "mid", -- left, mid, right
                        verticalAnchor = "mid", -- top, mid, bottom
                        wrapWidth = nil -- wrap width in pixels or nil
                    }
                    canvas:drawText(text, textPositioning, 4, {255, 255, 255})
                end
                canvas:drawImageDrawable(particleCfg.image or "/assetmissing.png", canvas.translateFromCamera(particleCfg.position, 0, particleCfg.parallax or 0), particleCfg.scale or scale, particleCfg.color or color, particleCfg.rotation or 0)
                canvasStorage.particle[i] = particleCfg
            end
        end
    end
    if canvasStorage.debug then
        local text = "  Particle Number | " .. #canvasStorage.particle
        local textPositioning = {
            position = {2, -6},
            horizontalAnchor = "left", -- left, mid, right
            verticalAnchor = "mid", -- top, mid, bottom
            wrapWidth = nil -- wrap width in pixels or nil
        }
        textPositioning.position = vec2.add(textPositioning.position, canvas.anchor("topLeft"))
        canvas:drawText(text, textPositioning, 7, {255, 255, 255})
    end
end

--- util ---
canvas.anchor = function(anchor)
    if type(anchor) == "string" then
        if anchor == "none"          then return {0, 0}                                            end
        if anchor == "bottomLeft"    then return {0, 0}                                            end
        if anchor == "bottomRight"   then return {canvas:size()[1], 0}                             end
        if anchor == "topLeft"       then return {0, canvas:size()[2]}                             end
        if anchor == "topRight"      then return canvas:size()                                     end
        if anchor == "centerBottom"  then return {vec2.div(canvas:size(), 2)[1], 0}                end
        if anchor == "centerTop"     then return {vec2.div(canvas:size(), 2)[1], canvas:size()[2]} end
        if anchor == "centerLeft"    then return {0, vec2.div(canvas:size(), 2)[2]}                end
        if anchor == "centerRight"   then return {canvas:size()[1], vec2.div(canvas:size(), 2)[2]} end
        if anchor == "center"        then return vec2.div(canvas:size(), 2)                        end
        return {0, 0}
    end
end

canvas.isVisible = function(image, position)
    local visiblePos = rect.zero()
    visiblePos[3] = visiblePos[3] + root.imageSize(image)[1]
    visiblePos[4] = visiblePos[4] + root.imageSize(image)[2]
    visiblePos = rect.shiftByVec2(visiblePos, position)
    -- Left
    if (visiblePos[1] > 0 and visiblePos[1] < canvas:size()[1]) then return true end
    -- Right
    --sb.logInfo("Right %s", not (visiblePos[3] > canvas:size()[1] and visiblePos[3] < 0) )
    if (visiblePos[3] > canvas:size()[1] and visiblePos[3] < 0) then return true end
    -- Bottom
    if (visiblePos[2] > 0 and visiblePos[2] < canvas:size()[2]) then return true end
    -- Top
    --sb.logInfo("Top %s", not (visiblePos[4] > canvas:size()[2] and visiblePos[4] < 0) )
    if (visiblePos[4] > canvas:size()[2] and visiblePos[4] < 0) then return true end

    
end

canvas.translateFromCamera = function(position, zoom, parallax)
    local position, zoom, parallax = position, (zoom or canvasStorage.camZoom), parallax
    if not parallax then parallax = 1 end
    local parallaxPercent = (parallax / (1 + zoom))
    local parallaxStr = 1 - parallaxPercent

    local effectivePosition = {0, 0}
    local cameraPos = canvasStorage.camPos or {0, 0}
    if parallaxStr ~= 1 then
        effectivePosition = vec2.mul(cameraPos, parallaxStr)
    else
        effectivePosition = cameraPos
    end
    
    return vec2.add(position, effectivePosition)
end

canvas.cameraDrag = function()
    -- Simple Camera Drag System --
    if canvasStorage.dragCam then 
        canvasStorage.dragNew = canvas:mousePosition()
        local newPos = {0,0}
        if canvasStorage.dragPrev then
            if canvasStorage.dragNew[1] ~= canvasStorage.dragPrev[1] then
                newPos[1] = canvasStorage.dragNew[1] - canvasStorage.dragPrev[1]
            end

            if canvasStorage.dragNew[2] ~= canvasStorage.dragPrev[2] then
                newPos[2] = canvasStorage.dragNew[2] - canvasStorage.dragPrev[2]
            end
        end
        canvasStorage.nextCamPos = vec2.add(canvasStorage.nextCamPos, newPos)
        canvasStorage.dragPrev = canvasStorage.dragNew
    else
        canvasStorage.dragPrev = nil
    end
end

canvas.linearTransitionToNextCamPos = function(_, camSpeed)
    -- Linear Transition from current Camera position to the next --
    if not vec2.eq(canvasStorage.nextCamPos, canvasStorage.camPos) then
        local dist = vec2.sub(canvasStorage.camPos, canvasStorage.nextCamPos)
        dist = vec2.mul(dist, (camSpeed or 1) * script.updateDt())
        local newPos = vec2.sub(canvasStorage.camPos, dist)
        if (math.abs(dist[1]) < 0.005 and math.abs(dist[2]) < 0.005) then
            newPos = canvasStorage.nextCamPos
        end
        canvasStorage.camPos = newPos
    end
end