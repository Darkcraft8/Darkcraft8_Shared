require "/shared/darkcraft8/util/rectUtils.lua"
require "/shared/darkcraft8/canvas/draw.lua"

if not canvas then canvas = {} end
if not canvasStorage then canvasStorage = {} end
canvasStorage.clickCallbacks = canvasStorage.clickCallbacks or {}
canvasStorage.keyCallbacks = canvasStorage.keyCallbacks or {}

canvas.bindCanvas = function(canvasWidgetName)
    if not canvasWidgetName then return false, "no canvas widget name given" end
    canvas.setCanvas(canvasWidgetName)
    if not canvasStorage.widget then return false, "couldn't bind the given canvas" end

    _ENV[config.getParameter("canvasClickCallbacks")[canvasWidgetName]] = function(position, mouseButton, isButtonDown) 
        canvas.clickCallback(position, mouseButton, isButtonDown)
    end

    _ENV[config.getParameter("canvasKeyCallbacks")[canvasWidgetName]] = function(keyIndex, isDown)
        canvas.keyCallback(keyIndex, isDown)
    end

    return true
end

canvas.buttonUpd = function(_, dt)
    if canvasStorage.btn then 
        canvasStorage.overredBtn = nil
        if canvasStorage.btn.btnTable then
            for index, button in ipairs(canvasStorage.btn.btnTable or {}) do
                --- small quick anchor handler ---
                if button.visible ~= false then
                    local effectivePosition = button.position or {0, 0}
                    local effectiveDetectArea = button.detectArea
                    if not effectiveDetectArea then effectiveDetectArea = {0,0, root.assetJson(canvasStorage.btn.btnTable[index]["image"]["base"][1], root.assetJson(canvasStorage.btn.btnTable[index]["image"]["base"])[2])} end
                    effectivePosition = vec2.add(canvas.anchor(button.anchor), effectivePosition)

                    for index, value in ipairs(effectivePosition) do
                        if value == "<left>" then effectivePosition[index] = 0 end
                        if value == "<center>" then effectivePosition[index] = vec2.div(canvas:size(), 2)[1] end
                        if value == "<right>" then effectivePosition[index] = canvas:size()[1] end
        
                        if value == "<bottom>" then effectivePosition[index] = 0 end
                        if value == "<middle>" then effectivePosition[index] = vec2.div(canvas:size(), 2)[2] end
                        if value == "<top>" then effectivePosition[index] = canvas:size()[2] end
                    end

                    for index, value in ipairs(effectiveDetectArea) do
                        if value == "<left>" then effectiveDetectArea[index] = 0 end
                        if value == "<center>" then effectiveDetectArea[index] = vec2.div(canvas:size(), 2)[1] end
                        if value == "<right>" then effectiveDetectArea[index] = canvas:size()[1] end
        
                        if value == "<bottom>" then effectiveDetectArea[index] = 0 end
                        if value == "<middle>" then effectiveDetectArea[index] = vec2.div(canvas:size(), 2)[2] end
                        if value == "<top>" then effectiveDetectArea[index] = canvas:size()[2] end
                    end
                    ---
                    if button.centered then
                        effectiveDetectArea = rect.centerRect(effectiveDetectArea)
                    end

                    if rect.isRect(effectiveDetectArea) then
                        if rect.vec2InRect(rect.shiftByVec2(effectiveDetectArea, effectivePosition), canvas:mousePosition()) then
                            if not canvasStorage.overredBtn then canvasStorage.overredBtn = button end
                            if canvasStorage.overredBtn == button then
                                canvas:drawImage(canvasStorage.btn.btnTable[index]["image"]["hover"], effectivePosition, 1, {255, 255, 255}, false) 
                            else
                                canvas:drawImage(canvasStorage.btn.btnTable[index]["image"]["base"], effectivePosition, 1, {255, 255, 255}, false)
                            end
                        else
                            canvas:drawImage(canvasStorage.btn.btnTable[index]["image"]["base"], effectivePosition, 1, {255, 255, 255}, false)
                        end
                    end

                    if canvasStorage.debug then
                        local boolean, message = rect.isRect(effectiveDetectArea)
                        if boolean then
                            if canvasStorage.overredBtn == button then
                                canvas:drawRect(rect.shiftByVec2(effectiveDetectArea, effectivePosition), {0, 255, 0, 100})
                            else
                                canvas:drawRect(rect.shiftByVec2(effectiveDetectArea, effectivePosition), {255, 0, 0, 100})
                            end
                        else
                            sb.logError(message)
                        end
                    end
                end
            end
        end
    end
end

canvas.clickCallback = function(position, mouseButton, isButtonDown)
    --sb.logInfo("%s, %s, %s", position, mouseButton, isButtonDown)
    if isButtonDown then
        if canvasStorage.overredBtn then
            if canvasStorage.overredBtn.callback then 
                if _ENV[canvasStorage.overredBtn.callback] then
                    pcall(_ENV[canvasStorage.overredBtn.callback], canvasStorage.overredBtn.name, position, mouseButton, isButtonDown)
                    if canvasStorage.overredBtn.sounds then 
                        if canvasStorage.overredBtn.sounds.press then
                            if #canvasStorage.overredBtn.sounds.press > 0 then
                                local selectedSound = canvasStorage.overredBtn.sounds.press[util.randomIntInRange({1, #canvasStorage.overredBtn.sounds.press})]
                                if canvasStorage.debug then sb.logInfo("played sound | %s", selectedSound) end
                                pane.playSound(selectedSound)
                            end
                        end
                    end
                    return
                end
            end
        end
    end
    for _, callback in ipairs(canvasStorage.clickCallbacks or {}) do -- we stop the whole function if arg[1] ins't nil, whe break the loop if arg[2] isn't nil
        local stopFunc, breakLoop = pcall(_ENV[callback], position, mouseButton, isButtonDown)
        if stopFunc then return end
        if breakLoop then break end
    end
end

canvas.keyCallback = function(keyIndex, isDown)
    --sb.logInfo("%s, %s", keyIndex, isDown)
    if not keyboard then 
        for _, callback in ipairs(canvasStorage.keyCallbacks or {}) do 
            local stopFunc, breakLoop = pcall(_ENV[callback], keyIndex, isDown)
            if stopFunc then return end
            if breakLoop then break end
        end
    else
        local bind = keyboard:getBind(keyIndex, isDown)
        sb.logInfo("keyIndex    :  %s", keyIndex)
        sb.logInfo("isDown      : %s", isDown)
        sb.logInfo("bind        : %s", bind)
        if canvasStorage.keyCallbacks[bind] then pcall(canvasStorage.keyCallbacks[bind], keyIndex, isDown, bind) end
    end
end

--- btn ---
--  overredBtn : the name of the currently overred button
--  btnTable : Table of btn to render and|or do logic
--      {
--          "name" : "select",
--          "callback" : "select",
--          "image" : {
--              "base" : "/assetmissing.png",
--              "hover" : "/assetmissing.png",
--              "press" : "/assetmissing.png"
--          },
--          "sounds" : {
--              "base" : [],
--              "hover" : ["/inserthoverSound.ogg"],
--              "press" : ["/insertpressSound.ogg"]
--          },
--          "position" : [0,0],
--          "detectArea" : [
--              0,
--              0,
--              16,
--              16
--          ],
--          "callback" : "select"
--      }