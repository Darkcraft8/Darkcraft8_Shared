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
    --sb.logInfo("building extra item functions")
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
        if not root.getItemIcon then
            root.getItemIcon = function (item, fullPath)
                local cfg = root.itemConfig(item)
                local configParameter = function(paramName, defaultValue)
                    return cfg.parameters[paramName] or cfg.config[paramName] or defaultValue
                end
                local colorOptions = configParameter("colorOptions")
                local colorDirective = ""
                local inventoryIcon = configParameter("inventoryIcon", configParameter("codexIcon"))
                if colorOptions then
                    colorDirective = "?replace"
                    for a, b in pairs(colorOptions[configParameter("colorIndex", 1)]) do 
                        colorDirective = colorDirective .. "=" .. a .. ";" .. b
                    end
                end
                if type(inventoryIcon) == "table" then
                    for index, icon in pairs(inventoryIcon or {}) do 
                        if fullPath then
                            if not (string.find(icon["image"], "/") == 1) then -- isn't absolute
                                inventoryIcon[index]["image"] = cfg.directory .. icon["image"]
                            end
                        end
                        if colorOptions then
                            inventoryIcon[index]["image"] = inventoryIcon[index]["image"] .. colorDirective
                        end
                    end
                elseif type(inventoryIcon) == "string" then
                    if fullPath then
                        if not (string.find(inventoryIcon, "/") == 1) then -- isn't absolute
                            inventoryIcon = cfg.directory .. inventoryIcon
                        end
                    end
                    if colorOptions then
                        inventoryIcon = inventoryIcon .. colorDirective
                    end
                else
                    inventoryIcon = root.assetJson("/items/defaultparameters.config").missingIcon
                end
                return inventoryIcon
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