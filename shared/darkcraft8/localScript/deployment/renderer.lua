-- Rewrite of the local renderer

require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

d8SharedRenderer = {}
d8SharedRendererStorage = {
    drawableList = {}
}

local _init = init
local _update = update
local _teleportOut = teleportOut
local _uninit = uninit

function init()
    if _init then _init() end
    if d8SharedRenderer.init then d8SharedRenderer.init() end
end
function update(dt)
    if _update then _update(dt) end
    if d8SharedRenderer.update then d8SharedRenderer.update(dt) end
end
function teleportOut()
    if _teleportOut then _teleportOut() end
end
function uninit()
    if _uninit then _uninit() end
    if d8SharedRenderer.uninit then d8SharedRenderer.uninit() end
end

local function d8SharedRendererSort(a, b)
    return (a.priority or 0) > (b.priority or 0)
end

d8SharedRenderer.init = function()
    message.setHandler("d8SharedRenderer|addDrawable", function(_, isLocal, drawable, priority, identifier, playerUuid)
        if isLocal then
            -- Checks to see if all the required part are present
                if not drawable then
                    sb.logWarn("[d8SharedRenderer] addDrawable didn't receive a drawable")
                    return false
                elseif not identifier then
                    sb.logWarn("[d8SharedRenderer] addDrawable didn't receive an identifier")
                    return false
                elseif type(drawable) ~= "table" then
                    sb.logWarn("[d8SharedRenderer] addDrawable receive a drawable of type %s, expected type table", type(drawable))
                    return false
                elseif type(identifier) ~= "string" then
                    sb.logWarn("[d8SharedRenderer] addDrawable receive an identifier of type %s, expected type string", type(identifier))
                    return false
                elseif not playerUuid then
                    sb.logWarn("[d8SharedRenderer] addDrawable didn't receive an playerUuid")
                    return false
                end

            if not d8SharedRendererStorage.drawableList[playerUuid] then d8SharedRendererStorage.drawableList[playerUuid] = {} end
            d8SharedRendererStorage.drawableList[playerUuid][identifier] = {
                priority = priority or 0,
                drawable = drawable
            }

            table.sort(d8SharedRendererStorage.drawableList[playerUuid], d8SharedRendererSort)
            return true
        end
    end)

    message.setHandler("d8SharedRenderer|removeDrawable", function(_, isLocal, identifier, playerUuid)
        if isLocal then
            -- Checks to see if all the required part are present
                if not identifier then
                    sb.logWarn("[d8SharedRenderer] removeDrawable didn't receive an identifier")
                    return false
                elseif not playerUuid then
                    sb.logWarn("[d8SharedRenderer] removeDrawable didn't receive an playerUuid")
                    return false
                end

            if d8SharedRendererStorage.drawableList[playerUuid] then -- whe skip this part if there isn't any drawable list for this playerUuid
                d8SharedRendererStorage.drawableList[playerUuid][identifier] = nil
                table.sort(d8SharedRendererStorage.drawableList, d8SharedRendererSort)
                return true
            end
        end
    end)

    message.setHandler("d8SharedRenderer|updateDrawable", function(_, isLocal, drawable, identifier, playerUuid)
        if isLocal then
            -- Checks to see if all the required part are present
                if not identifier then
                    sb.logWarn("[d8SharedRenderer] updateDrawable didn't receive an identifier")
                    return false
                elseif not playerUuid then
                    sb.logWarn("[d8SharedRenderer] updateDrawable didn't receive an playerUuid")
                    return false
                elseif not d8SharedRendererStorage.drawableList[playerUuid] then
                    sb.logWarn("[d8SharedRenderer] updateDrawable couldn't find a drawable list for %s, pls use addDrawable to add or set a drawable", playerUuid)
                    return false
                elseif not d8SharedRendererStorage.drawableList[playerUuid][identifier] then
                    sb.logWarn("[d8SharedRenderer] updateDrawable couldn't find a drawable identified as %s in %s, pls use addDrawable to add or set a drawable", identifier, playerUuid)
                    return false
                end

            d8SharedRendererStorage.drawableList[playerUuid][identifier].drawable = drawable
            table.sort(d8SharedRendererStorage.drawableList, d8SharedRendererSort)

            return true
        end
    end)

    message.setHandler("d8SharedRenderer|hasDrawable", function(_, isLocal, identifier, playerUuid)
        if isLocal then
            -- Checks to see if all the required part are present
                if not identifier then
                    return false
                elseif not playerUuid then
                    return false
                elseif not d8SharedRendererStorage.drawableList[playerUuid] then
                    return false
                elseif not d8SharedRendererStorage.drawableList[playerUuid][identifier] then
                    return false
                end
            return true
        end
    end)
end

d8SharedRenderer.update = function(dt)
    if d8SharedRendererStorage.drawableList[player.uniqueId()] then
        for id, cfg in pairs(d8SharedRendererStorage.drawableList[player.uniqueId()] or {}) do   
            local drawableType = d8SharedRenderer.drawableType(cfg.drawable)
            if drawableType == "drawable" then
                localAnimator.addDrawable(cfg.drawable, "ForegroundOverlay-1")
            elseif drawableType == "progressBar" then
                local drawable = d8SharedRenderer.prepareProgressBar(cfg.drawable)
                localAnimator.addDrawable(drawable.back, "ForegroundOverlay-1")
                localAnimator.addDrawable(drawable.fill, "ForegroundOverlay-1")
            end
        end
    end
end

d8SharedRenderer.uninit = function()
    d8SharedRendererStorage.drawableList = {} -- reset the drawableLists
end

d8SharedRenderer.drawableType = function(drawable)
    if type(drawable) == "string" then return "image" end
    if drawable.image and drawable.position then
        return "drawable"
    elseif drawable.percent then
        return "progressBar"
    end
end

d8SharedRenderer.prepareProgressBar = function(drawable)
    local finishedDrawables = {
        back = {
            image = "/interface/emptybar.png",
            position = drawable.position or {0, 0},
            scale = drawable.scale or 1,
            fullbright = drawable.fullbright,
            rotation = drawable.rotation,
            transformation = drawable.transformation,
            centered = drawable.centered,
            mirrored = drawable.mirrored,
            color = drawable.color
        },
        fill = {
            image = "/interface/energybar.png",
            position = drawable.position or {0, 0},
            scale = drawable.scale or 1,
            fullbright = drawable.fullbright,
            rotation = drawable.rotation,
            transformation = drawable.transformation,
            centered = drawable.centered or false,
            mirrored = drawable.mirrored,
            color = drawable.color or {0, 255, 0, 255}
        }
    }
    local percent = drawable.percent
    if drawable.texture then
        if drawable.texture.back then
            finishedDrawables.back.image = drawable.texture.back
        end
        if drawable.texture.fill then
            finishedDrawables.fill.image = drawable.texture.fill
        end
    end
    local fillImageSize = root.imageSize(finishedDrawables.fill.image)
    finishedDrawables.fill.image = finishedDrawables.fill.image .. string.format("?crop=%s;%s;%s;%s", 0, 0, fillImageSize[1] * percent, fillImageSize[2])
    finishedDrawables.fill.position = vec2.sub(finishedDrawables.fill.position, {fillImageSize[1] / 8, 0})
    return finishedDrawables
end