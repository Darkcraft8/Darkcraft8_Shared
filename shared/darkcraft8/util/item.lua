-- because sometime config.getParameter is drunk --
local function item_getParameter(variable, defaultValue) -- return the value of the variable in "parameters" or nil otherwise
    local itemCfg = item.descriptor()
    if not itemCfg then return defaultValue end
    return itemCfg["parameters"][variable] or defaultValue
end

local function item_getConfig(variable, defaultValue) -- return the value of the variable in "config" or nil otherwise
    local itemCfg = root.itemConfig(item.descriptor())
    if not itemCfg then return defaultValue end
    return itemCfg["config"][variable] or defaultValue
end

local function root_getParameter(itemDescriptorOrName, variable, defaultValue) -- return the value of the variable in "parameters" or nil otherwise
    local itemCfg = root.createItem(itemDescriptorOrName)
    if not itemCfg then return defaultValue end
    return itemCfg["parameters"][variable] or defaultValue
end

local function root_getConfig(itemDescriptorOrName, variable, defaultValue) -- return the value of the variable in "config" or nil otherwise
    local itemCfg = root.itemConfig(itemDescriptorOrName)
    if not itemCfg then return defaultValue end
    return itemCfg["config"][variable] or defaultValue
end

function D8Shared_BuildItemFunction()
    if root then
        if not root.getItemParameter then
            root.getItemParameter = function (itemDescriptorOrName, variable, defaultValue)
                return root_getParameter(itemDescriptorOrName, variable, defaultValue)
            end
        end
        if not root.getItemConfig then
            root.getItemConfig = function (itemDescriptorOrName, variable, defaultValue)
                return root_getConfig(itemDescriptorOrName, variable, defaultValue)
            end
        end
        if not root.getItemVariable then
            root.getItemVariable = function (itemDescriptorOrName, variable, defaultValue)
                return root_getParameter(itemDescriptorOrName, variable, root_getConfig(itemDescriptorOrName, variable, defaultValue))
            end
        end
    end

    if item then
        if not item.getItemParameter then
            item.getItemParameter = function (variable, defaultValue)
                return item_getParameter(variable, defaultValue)
            end
        end
        if not item.getItemConfig then
            item.getItemConfig = function (variable, defaultValue)
                return item_getConfig(variable, defaultValue)
            end
        end
        if not item.getItemVariable then
            item.getItemVariable = function (variable, defaultValue)
                return item_getParameter(variable, item_getConfig(variable, defaultValue))
            end
        end
    end
end

D8Shared_BuildItemFunction()