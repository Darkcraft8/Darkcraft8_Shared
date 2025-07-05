require "/scripts/vec2.lua"
require "/shared/darkcraft8/d8ToolTipUtil/scriptedTooltip/base.lua"
local _init = init
local _update = update
local _uninit = uninit
function init()
    if _init then _init() end
    for _, cfg in pairs(config.getParameter("itemSlotList", {})) do -- set itemIcon Slot
        widget.setItemSlotItem(cfg.path .. ".itemIcon", cfg.item)
    end
end

local countTimer = 0
function update(dt)
    if _update then _update(dt) end

    if countTimer > 0 then countTimer = countTimer - dt return end
    countTimer = 0.1
    for _, cfg in pairs(config.getParameter("itemSlotList", {})) do
        local path = cfg.path
        local item = cfg.item
        local countString = itemCount(cfg.item)
        widget.setText(cfg.path .. ".count", countString)
    end
end

function uninit()
    if _uninit then _uninit() end
end

function itemCount(descriptor)
    local countString = ""
    local itemCount = 1
    if type(descriptor) == "table" then
        itemCount = descriptor.count or 1
    end
    if itemCount > 0 then
        if config.getParameter("mimicRecipeTooltip", false) then
            local itemPlayerCount = 0
            if type(descriptor) == "table" then
                itemPlayerCount = player.hasCountOfItem({
                    name = (descriptor.name or descriptor.item or descriptor.itemName),
                    count = 1,
                    parameters = descriptor.parameters
                }, config.getParameter("matchInputParameters", false))
            else
                itemPlayerCount = player.hasCountOfItem(descriptor, config.getParameter("matchInputParameters", false))  
            end
            if itemPlayerCount >= itemCount then
                countString = "^green;" .. itemPlayerCount .. "/" .. itemCount
            else
                countString = "^red;" .. itemPlayerCount .. "/" .. itemCount
            end
        else
            countString = tostring(itemCount)
        end
    else
        countString = ""
    end

    return countString
end