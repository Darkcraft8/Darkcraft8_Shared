keyboard = {} -- util for keyboard related usage in canvas

function keyboard:updateCurrentBinds()
    local keyBindCfg = root.assetJson("/shared/darkcraft8/canvas/keyID.config")
    local paneBind = config.getParameter("canvasKeyBinds")
    self.keyIndex = keyBindCfg["keyIndex"]
    --player.setProperty("keyboard_keyboardType", "azerty")
    if paneBind then
        keyboard.canvasBinds = paneBind["default"][keyboard.type or player.getProperty("keyboard_keyboardType") or "qwerty"]
    else
        keyboard.canvasBinds = keyBindCfg["canvasKeyBinds"]["default"][keyboard.type or player.getProperty("keyboard_keyboardType") or "qwerty"]
    end
    --self:debug_getBinds()
end

function keyboard:binds()
    local keyBindCfg = root.assetJson("/shared/darkcraft8/canvas/keyID.config")
    local playerBind = player.getProperty("keyboard_playerBinds") or {}
    local binds = keyBindCfg["canvasKeyBinds"]["default"]
    for key, bind in pairs(keyBindCfg["canvasKeyBinds"]["list"]) do 
        binds[key] = bind
    end

    return binds
end

function keyboard:getBind(keyIndex, isDown)
    return keyboard.canvasBinds[self.keyIndex[tostring(keyIndex)]]
end

function keyboard:debug_getBinds()
    sb.logInfo("keyboard_keyboardType %s", player.getProperty("keyboard_keyboardType") or "qwerty")
    sb.logInfo("canvasBinds %s", keyboard.canvasBinds)
end

function keyboard:debug_getBind(keyIndex, isDown)
    if isDown then
        sb.logInfo("[keyboard:debug_getBind]\n keyIndex %s,\n isDown %s,\n self.keyIndex[keyIndex] %s,\n current Bind %s", keyIndex, isDown, self.keyIndex[tostring(keyIndex)], keyboard.canvasBinds[self.keyIndex[tostring(keyIndex)]] or self.default[self.keyIndex[tostring(keyIndex)]])
    end
end

-- openStarboundCompact --
function keyboard:oSb_keyHeld()
    local isKeyHeld = input.keyHeld
end

-- input.keyHeld(keyName, modNames)