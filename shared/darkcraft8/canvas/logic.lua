require "/shared/darkcraft8/util/rectUtils.lua"
require "/shared/darkcraft8/canvas/draw.lua"

local prevClick = {}
local diffClick = function(click, prevClick)
    if click["MouseLeft"] ~= prevClick["MouseLeft"] then return true, click["MouseLeft"], 0 end
    if click["MouseMiddle"] ~= prevClick["MouseMiddle"] then return true, click["MouseMiddle"], 1 end
    if click["MouseRight"] ~= prevClick["MouseRight"] then return true, click["MouseRight"], 2 end
    if click["MouseFourth"] ~= prevClick["MouseFourth"] then return true, click["MouseFourth"], 3 end
    if click["MouseFifth"] ~= prevClick["MouseFifth"] then return true, click["MouseFifth"], 4 end
end
canvasStorage.clickCallbacks = canvasStorage.clickCallbacks or {}
canvasStorage.keyCallbacks = canvasStorage.keyCallbacks or {}
canvas.bindCanvas = function(self, canvasWidgetName, canvasUserData)
    if not canvasWidgetName then return false, "no canvas widget name given" end
    canvas:setCanvas(canvasUserData or canvasWidgetName)
    if not canvasStorage.widget then return false, "couldn't bind the given canvas" end

    _ENV[config.getParameter("canvasClickCallbacks")[canvasWidgetName]] = function(position, mouseButton, isButtonDown) 
        canvas:clickCallback(position, mouseButton, isButtonDown)
    end

    _ENV[config.getParameter("canvasKeyCallbacks")[canvasWidgetName]] = function(keyIndex, isDown)
        canvas:keyCallback(keyIndex, isDown)
    end

    return true
end

canvas.buttonUpd = function(self, dt, simulateMouseClickDetection)
    if canvasStorage.btn then 
        canvasStorage.overredBtn = nil
        if canvasStorage.btn.btnTable then
            local click = {}
            if simulateMouseClickDetection then
                if input then
                    if input.mouse then
                        click = {
                            MouseLeft = input.mouse("MouseLeft"),
                            MouseMiddle = input.mouse("MouseMiddle"),
                            MouseRight = input.mouse("MouseRight"),
                            MouseFourth = input.mouse("MouseFourth"),
                            MouseFifth = input.mouse("MouseFifth")
                        }
                    end
                end
            end
            for index, button in pairs(canvasStorage.btn.btnTable or {}) do
                --- small quick anchor handler ---
                if button.visible ~= false then
                    local effectivePosition = button.position or {0, 0}
                    local effectiveDetectArea = button.detectArea
                    if not effectiveDetectArea then effectiveDetectArea = {0,0, root.imageSize(canvasStorage.btn.btnTable[index]["image"]["base"])[1], root.imageSize(canvasStorage.btn.btnTable[index]["image"]["base"])[2]} end
                    effectivePosition = vec2.add(canvas:anchor(button.anchor), effectivePosition)

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
                    effectiveDetectArea = rect.scale(effectiveDetectArea, 1 + (button.zoom or 0))
                    ---
                    if button.centered then
                        effectiveDetectArea = rect.centerRect(effectiveDetectArea)
                    end
                    local btnCfg = canvasStorage.btn.btnTable[index]
                    effectiveDetectArea = rect.scale(effectiveDetectArea, (btnCfg.scale or 1))
                    if canvasStorage.pressedButton == button.name then
                        canvas:drawImage(btnCfg["image"]["pressed"] or "/assetmissing.png", effectivePosition, btnCfg.scale or 1, {255, 255, 255}, btnCfg.centered or false) 
                    elseif rect.isRect(effectiveDetectArea) then
                        if rect.vec2InRect(rect.shiftByVec2(effectiveDetectArea, effectivePosition), canvas:mousePosition()) then
                            if not button.disabled then
                                canvasStorage.overredBtn = button
                                if compare(canvasStorage.overredBtn, button) then
                                    canvas:drawImage(btnCfg["image"]["hover"] or "/assetmissing.png", effectivePosition, btnCfg.scale or 1, {255, 255, 255}, btnCfg.centered or false) 
                                else
                                    canvas:drawImage(btnCfg["image"]["base"] or "/assetmissing.png", effectivePosition, btnCfg.scale or 1, {255, 255, 255}, btnCfg.centered or false)
                                end
                            else
                                if not canvasStorage.overredBtn then canvasStorage.overredBtn = button else canvasStorage.overredBtn.tooltipCfg = button.tooltipCfg end
                            end
                        else
                            if not button.disabled then
                                canvas:drawImage(btnCfg["image"]["base"] or "/assetmissing.png", effectivePosition, btnCfg.scale or 1, {255, 255, 255}, btnCfg.centered or false)
                            end
                        end

                        if button.disabled then
                            canvas:drawImage(btnCfg["image"]["disabled"] or btnCfg["image"]["base"], effectivePosition, btnCfg.scale or 1, {255, 255, 255}, btnCfg.centered or false)
                        end
                    end
                    if not button.disabled then
                        if canvasStorage.debug then
                            local boolean, message = rect.isRect(effectiveDetectArea)
                            if boolean then
                                if canvasStorage.overredBtn == button then
                                    canvas:drawRect(rect.shiftByVec2(effectiveDetectArea, effectivePosition), {0, 255, 0, 25})
                                else
                                    canvas:drawRect(rect.shiftByVec2(effectiveDetectArea, effectivePosition), {255, 0, 0, 25})
                                end
                            else
                                sb.logError(message)
                            end
                        end
                    end
                end
            end
            if simulateMouseClickDetection then
                local diffClickBtnState, buttonState, buttonType = diffClick(click, prevClick)
                if diffClickBtnState then
                    canvas:clickCallback(canvas:mousePosition(), buttonType, buttonState)
                end
            end
            prevClick = click
            if canvas:mousePosition() == nil then canvasStorage.pressedButton = nil end
        end
    end
end

canvas.clickCallback = function(self, position, mouseButton, isButtonDown)
    --sb.logInfo("%s, %s, %s", position, mouseButton, isButtonDown)
    --sb.logInfo("%s", canvasStorage.overredBtn)
    if isButtonDown then
        if canvasStorage.overredBtn then
            if (not canvasStorage.overredBtn.disabled) or canvasStorage.overredBtn.doCallbackWhenDisabled then
                canvasStorage.pressedButton = copy(canvasStorage.overredBtn.name)
                if (mouseButton == 0) or (mouseButton == true)then
                    if canvasStorage.overredBtn.callback then 
                        if _ENV[canvasStorage.overredBtn.callback] then
                            local reA, reB = pcall(_ENV[canvasStorage.overredBtn.callback], table.unpack(canvasStorage.overredBtn.args or {}))--canvasStorage.overredBtn.name, position, mouseButton, isButtonDown)
                            if canvasStorage.debug or (reA == false) then sb.logInfo("pcall result : %s %s, debug mode: %s", reA, reB, canvasStorage.debug) elseif reA then
                                _ENV[canvasStorage.overredBtn.callback](table.unpack(canvasStorage.overredBtn.args or {}))
                            end
                            return
                        end
                    end
                end
                
                if canvasStorage.overredBtn.sounds then 
                    if canvasStorage.overredBtn.sounds.press then
                        if #canvasStorage.overredBtn.sounds.press > 0 then
                            local selectedSound = canvasStorage.overredBtn.sounds.press[util.randomIntInRange({1, #canvasStorage.overredBtn.sounds.press})]
                            --if canvasStorage.debug then sb.logInfo("played sound | %s", selectedSound) end
                            pane.playSound(selectedSound)
                        end
                    end
                end
            else
                if canvasStorage.overredBtn.sounds then 
                    if canvasStorage.overredBtn.sounds.disabled then
                        if #canvasStorage.overredBtn.sounds.disabled > 0 then
                            local selectedSound = canvasStorage.overredBtn.sounds.disabled[util.randomIntInRange({1, #canvasStorage.overredBtn.sounds.disabled})]
                            --if canvasStorage.debug then sb.logInfo("played sound | %s", selectedSound) end
                            pane.playSound(selectedSound)
                        end
                    end
                end
                return
            end
        end
    else
        canvasStorage.pressedButton = nil
    end
    for _, callback in ipairs(canvasStorage.clickCallbacks or {}) do -- we stop the whole function if arg[1] ins't nil, whe break the loop if arg[2] isn't nil
        local stopFunc, breakLoop = pcall(_ENV[callback], position, mouseButton, isButtonDown)
        if stopFunc then return end
        if breakLoop then break end
    end
end

canvas.keyCallback = function(self, keyIndex, isDown)
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