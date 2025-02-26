require("/shared/darkcraft8/canvas/keyboard.lua")
-- Infinished, Extremely WIP and prettymuch doesn't do Anything
local binds = {}
function init()
    keyboard:getBinds()
    binds = root.assetJson("/shared/darkcraft8/canvas/keyID.config:canvasKeyBinds.list")
    keyIndex = root.assetJson("/shared/darkcraft8/canvas/keyID.config:keyIndex")
    table.sort(keyIndex, sort)

    for i = 0, 127 do 
        if keyIndex[tostring(i)] then
            local name = keyIndex[tostring(i)]
            local bind = keyboard.canvasBinds[keyIndex[tostring(i)]] or keyboard.default[keyIndex[tostring(i)]]
            local id = widget.addListItem("bind.list")
            local path = "bind.list" .. "." .. id

            widget.setText(path .. ".keyLbl", name)
            widget.setText(path .. ".nameLbl", (bind or "^gray;nil^reset;"))
            widget.setData(path, {
                key = name,
                bind = bind
            })
        end
    end
end

function selectBinds()
    
    widget.focus("hidenCanvas")
end

function canvasKeyEvent(keyIndex, isDown)
    local bind = keyboard:getBind(keyIndex, isDown)
    sb.logInfo("%s, %s, %s", keyIndex, isDown, bind)
end

function sort(a, b)
    return a > b
end

function close() pane.dismiss() end