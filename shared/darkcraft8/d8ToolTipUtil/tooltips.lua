require "/scripts/util.lua"
require "/scripts/vec2.lua"

D8Tooltip = {} -- I wouldn't be supprised if this util become my most used one when released
local interfaceCanvas
local tooltipRadius
local paneTempID = nil
local currenciesConfig
function D8Tooltip:scriptTipOpen()
    local tooltipUtilOpen = player.getProperty("d8TooltipUtilOpen")
    if type(tooltipUtilOpen) ~= "table" then
        tooltipUtilOpen = {}
    end
    tooltipUtilOpen[paneTempID] = true
    player.setProperty("d8TooltipUtilOpen", tooltipUtilOpen)-- say that a tooltip is open
end

function D8Tooltip:scriptTipClosed()
    local tooltipUtilOpen = player.getProperty("d8TooltipUtilOpen")
    if type(tooltipUtilOpen) ~= "table" then
        tooltipUtilOpen = {}
    end
    tooltipUtilOpen[paneTempID] = false
    player.setProperty("d8TooltipUtilOpen", tooltipUtilOpen)-- say that a tooltip is closed or should close
end

function D8Tooltip:init(self, customIDString)
    -- add an invisible/hidden textLabel to get the size of the whole string with the current font
    paneTempID = customIDString or sb.makeUuid()
    D8Tooltip:scriptTipClosed()

    if widget or pane then
        if not widget.getSize("D8Tooltip_LblWidget".."_".."default") then
            local lblWidget = {
                type = "label",
                position = {-100, -100},
                hAnchor = "mid",
                vAnchor = "mid",
                wrapWidth = root.assetJson("/shared/darkcraft8/d8ToolTipUtil/tooltip.config").text.descriptionLabel.wrapWidth,
                zlevel = 1
            }
            pane.addWidget(lblWidget, "D8Tooltip_LblWidget".."_".."default")
        end
    end
    --
end

function D8Tooltip:update(dt)
    if self.tooltipCo then
        local status, message = coroutine.resume(self.tooltipCo)
    end
    if input then
        if player.getProperty("d8TooltipUtilOpen") then
            local mousePos = vec2.mul(input.mousePosition(), 1 / interface.scale())
            local paneSize = pane.getSize()
            local panePos = pane.getPosition()
            local paneRect = {
                panePos[1],
                panePos[2],
                vec2.add(panePos, paneSize)[1],
                vec2.add(panePos, paneSize)[2]
            }
            local inPane = function(_rect, _mousePos)
                if not ( (_rect[1] <= _mousePos[1]) and (_rect[3] >= _mousePos[1]) ) then return false end
                if not ( (_rect[2] <= _mousePos[2]) and (_rect[4] >= _mousePos[2]) ) then return false end
                return true
            end

            local dist = function (_vectorA, _vectorB)
                if #_vectorA == #_vectorB then
                    local x, y = (_vectorA[1] - _vectorB[1]), (_vectorA[2] - _vectorB[2])
                    local dist = math.sqrt( (x * x) + (y * y))
                    
                    return dist
                end
            end
            if not tooltipRadius then
                local temp = root.assetJson("/interface.config")
                tooltipRadius = temp.tooltip.radius
            end

            local outOfRadius = (dist(mousePos, D8Tooltip.oldMousePosition or {0, 0}) > tooltipRadius) -- disabled
            if (not inPane(paneRect, mousePos)) then
                D8Tooltip:scriptTipClosed()
            end
        end
    end
    if not mouseInPane then
        D8Tooltip:scriptTipClosed()
    end
    mouseInPane = false
end

function D8Tooltip:uninit()
    local tooltipUtilOpen = player.getProperty("d8TooltipUtilOpen")
    if type(tooltipUtilOpen) ~= "table" then
        tooltipUtilOpen = {}
    end
    tooltipUtilOpen[paneTempID] = nil
    player.setProperty("d8TooltipUtilOpen", tooltipUtilOpen)-- remove the temporary id from the list to keep the player save file small
end

function D8Tooltip:cursorOverride(mousePosition)-- simple check to close any scripted tooltip pane, made with vanilla behavior in mind
    mouseInPane = true
    if self.oldMousePosition and not pane.setPosition then
        local diff = vec2.sub(self.oldMousePosition or {0, 0}, mousePosition)
        if math.abs(diff[1]) > 5 or math.abs(diff[2]) > 5 then
            D8Tooltip:scriptTipClosed()
        end
    end
end

function D8Tooltip:getStringSize(stringText, wrapWidth, fontSize, customName)
    if not widget.getSize("D8Tooltip_LblWidget".."_".."customName" or "default") then
        local lblWidget = {
            type = "label",
            position = {-100, -100},
            hAnchor = "mid",
            vAnchor = "mid",
            wrapWidth = wrapWidth,
            fontSize = fontSize,
            zlevel = 1
        }
        pane.addWidget(lblWidget, "D8Tooltip_LblWidget".."_".."customName" or "default")
    end
    widget.setText("D8Tooltip_LblWidget".."_".."customName" or "default", stringText)
    local stringTextSize = widget.getSize("D8Tooltip_LblWidget".."_".."customName" or "default")
    widget.setText("D8Tooltip_LblWidget".."_".."customName" or "default", "")
    return stringTextSize
end

function D8Tooltip:text(tooltipText)
    if tooltipText then
        local tooltip = root.assetJson("/shared/darkcraft8/d8ToolTipUtil/tooltip.config").text
        
        local borderSize = 1
        local borderColor = config.getParameter("tooltipCfg.borderColor", "FFFFFFff")

        local stringTextSize = D8Tooltip:getStringSize(tooltipText, tooltip.descriptionLabel.wrapWidth)
        local stringLength = string.len(string.gsub(tooltipText, '%^[^^.*;]*;', ''))
        local imageLength = 4
        local imageHeight = 4
        local imageTexturePath = "/interface/rightBarTooltipBg.png?crop;1;1;2;2?scalenearest=%s;%s?border=%s;%s;%s"
        if config.getParameter("tooltipCfg.backgroundColor") then
            imageTexturePath = imageTexturePath .. "?replace;000000a8="..config.getParameter("tooltipCfg.backgroundColor")
        end
        local extendedLength = imageLength + stringTextSize[1]--(1 + borderSize) + (4.25 * (stringLength))
        local extendedHeight = imageHeight + stringTextSize[2]
        
        tooltip["background"]["fileBody"] = string.format(imageTexturePath, extendedLength, extendedHeight, borderSize, borderColor, borderColor)
        tooltip.descriptionLabel.value = tooltipText
        tooltip.descriptionLabel.position[1] = (extendedLength * 0.5) + (borderSize)
        tooltip.descriptionLabel.position[2] = (extendedHeight * 0.5) + (borderSize)
        return tooltip
    end
    
    return
end
-- older sibling to scriptedItemList that doesn't open a scripted pane... got a visual update, should look extremely close to vanilla
function D8Tooltip:itemList(itemList, override)
    require "/shared/darkcraft8/util/item.lua"
    local vanillaConfig = root.assetJson("/interface/craftingtooltip/craftingtooltip.config")
    local tooltip = {
        panefeature = {
            type = "panefeature",
            offset = {-5, 0}
        },
        background = {
            type = "background",
            fileHeader = vanillaConfig.background.stretchSet["end"] or "/interface/craftingtooltip/header.png",
            fileBody = vanillaConfig.background.stretchSet["inner"] or "/interface/craftingtooltip/body.png",
            fileFooter = vanillaConfig.background.stretchSet["begin"] or "/interface/craftingtooltip/footer.png"
        },
        title = vanillaConfig.title or {
            type = "label",
            position = {76, 33}, -- Height of itemList is added to this y position
            hAnchor = "mid",
            vAnchor = "top",
            wrapWidth = 116,
            value = "INGREDIENTS"
        },
        itemList = {
            type = "layout",
            layoutType = "basic",
            rect = {0, 21, 145, 22}, -- Max Height should be increased based on the amount of items
            position = {0, 0},
            children = {
            }
        }
    }
    
    local pathTemplate = "itemList.children" .. ""
    local listTemplate = {
        type = "layout",
        layoutType = "basic",
        rect = {0, 0, 145, 22}, -- both Height should be increased based on the amount of item descriptor
        children = {
            backgroundImg = vanillaConfig.itemList.schema.listTemplate.background or {
                type = "image",
                file = "/interface/craftingtooltip/listitem.png",
                position = {1, 0},
                zlevel = -1
            },
            itemName = vanillaConfig.itemList.schema.listTemplate.itemName or {
                type = "label",
                position = {27, 11},
                hAnchor = "left",
                vAnchor = "mid",
                wrapWidth = 66,
                lineSpacing = 1.0,
                value = "Pootis Bird"
            },
            itemRarity = {
                type = "image",
                position = vanillaConfig.itemList.schema.listTemplate.itemIcon.position or {4, 2},
                file = "/interface/inventory/itemborder"
            },
            itemIcon = {
                type = "image",
                position = vec2.add(vanillaConfig.itemList.schema.listTemplate.itemIcon.position or {4, 2}, {9, 9}),
                zlevel = 1,
                centered = true,
                minSize = {0, 0},
                maxSize = {18, 18}
            }, 
            count = vanillaConfig.itemList.schema.listTemplate.count or {
                type = "label",
                position = {117, 7},
                hAnchor = "right",
                value = "404"
            }
        }
    }
    --sb.logInfo("listTemplate %s", sb.printJson(listTemplate, 1))
    tooltip.title.value = override.title or vanillaConfig.title.value or "ITEM"
    local numberOfItem = 0
    local currencyInputs = {}
    local itemName = function(itemDescriptor)
        if type(itemDescriptor) == "string" then return itemDescriptor end
        return itemDescriptor.item or itemDescriptor.name or itemDescriptor.itemName or itemDescriptor[1]
    end

    if itemList.input then
        if not currenciesConfig then currenciesConfig = root.assetJson("/currencies.config") end
        currencyInputs = copy(itemList.currencyInputs)
        itemList = copy(itemList.input)
        for currency, amount in pairs(currencyInputs) do 
            local representativeItem = currenciesConfig[currency]["representativeItem"]
            local added = false
            for index, descriptor in pairs(itemList or {}) do
                if itemName(descriptor) == representativeItem then
                    added = true
                    itemList[index] = {
                        name = itemName(descriptor),
                        count = (descriptor.count or descriptor[2]) + amount,
                        parameters = descriptor.parameters or descriptor[3]
                    }
                    break
                end
            end
            if not added then
                table.insert(itemList, {
                    name = currency,
                    count = amount
                })
            end
        end
    end

    for index, descriptor in ipairs(itemList) do
        local cfg = root.itemConfig(descriptor)
        local name = descriptor
        local itemCount = 1
        if type(descriptor) == "table" then
            name = index .. "|" .. (descriptor.name or descriptor.item or descriptor.itemName)
            itemCount = descriptor.count or 1
        else
            name = index .. "|" .. name
        end
        tooltip.itemList.children[name] = copy(listTemplate)
        local configParameter = function(paramName, defaultValue)
            return cfg.parameters[paramName] or cfg.config[paramName] or defaultValue
        end
        tooltip.itemList.children[name]["children"]["itemName"]["value"] = configParameter("shortdescription")
        if override.mimicRecipeTooltip then
            local itemPlayerCount = 0
            if type(descriptor) == "table" then
                itemPlayerCount = player.hasCountOfItem({
                    name = (descriptor.name or descriptor.item or descriptor.itemName),
                    count = 1,
                    parameters = cfg.parameters
                }, override.matchInputParameters)
            else
                itemPlayerCount = player.hasCountOfItem(descriptor, override.matchInputParameters)  
            end
            if itemPlayerCount >= itemCount then
                tooltip.itemList.children[name]["children"]["count"]["value"] = "^green;" .. itemPlayerCount .. "/" .. itemCount
            else
                tooltip.itemList.children[name]["children"]["count"]["value"] = "^red;" .. itemPlayerCount .. "/" .. itemCount
            end
        else
            tooltip.itemList.children[name]["children"]["count"]["value"] = tostring(itemCount)
            if tonumber(tooltip.itemList.children[name]["children"]["count"]["value"]) <= 0 then tooltip.itemList.children[name]["children"]["count"]["visible"] = false end
        end
        tooltip.itemList.children[name]["children"]["itemRarity"]["file"] = string.format("/interface/inventory/itemborder%s.png", string.lower(configParameter("rarity")))
        local invIcon = root.getItemIcon(descriptor, true)
        if type(invIcon) == "table" then
            tooltip.itemList.children[name]["children"]["itemIcon"]["file"] = nil
            tooltip.itemList.children[name]["children"]["itemIcon"]["drawables"] = invIcon
        else
            tooltip.itemList.children[name]["children"]["itemIcon"]["file"] = invIcon
        end
        --[[
        local inventoryIcon = configParameter("inventoryIcon") or configParameter("codexIcon")
        local colorOptions = configParameter("colorOptions")
        local colorDirective = ""
        if colorOptions then
            colorDirective = "?replace"
            for a, b in pairs(colorOptions[configParameter("colorIndex", 1)]) do 
                colorDirective = colorDirective .. "=" .. a .. ";" .. b
            end
        end
        if type(inventoryIcon) == "table" then
            tooltip.itemList.children[name]["children"]["itemIcon"]["file"] = nil
            tooltip.itemList.children[name]["children"]["itemIcon"]["drawables"] = copy(inventoryIcon)
            for index, icon in pairs(tooltip.itemList.children[name]["children"]["itemIcon"]["drawables"] or {}) do 
                if (string.find(icon["image"], "/") == 1) then
                    tooltip.itemList.children[name]["children"]["itemIcon"]["drawables"][index]["image"] = icon["image"]
                else -- isn't absolute
                    tooltip.itemList.children[name]["children"]["itemIcon"]["drawables"][index]["image"] = cfg.directory .. icon["image"]
                end
                if colorOptions then
                    tooltip.itemList.children[name]["children"]["itemIcon"]["drawables"][index]["image"] = tooltip.itemList.children[name]["children"]["itemIcon"]["drawables"][index]["image"] .. colorDirective
                end
            end
        elseif type(inventoryIcon) == "string" then
            if (string.find(inventoryIcon, "/") == 1) then
                tooltip.itemList.children[name]["children"]["itemIcon"]["file"] = inventoryIcon
            else -- isn't absolute
                tooltip.itemList.children[name]["children"]["itemIcon"]["file"] = cfg.directory .. inventoryIcon
            end
            if colorOptions then
                tooltip.itemList.children[name]["children"]["itemIcon"]["file"] = tooltip.itemList.children[name]["children"]["itemIcon"]["file"] .. colorDirective
            end
        else
            sb.logInfo("missing icon for %s", name)
            tooltip.itemList.children[name]["children"]["itemIcon"]["file"] = root.assetJson("/items/defaultparameters.config").missingIcon
        end
        ]]
        tooltip.itemList.children[name]["rect"][2] = (22 * (#itemList - (numberOfItem + 1)))
        tooltip.itemList.children[name]["rect"][4] =  22 + (22 * (#itemList - (numberOfItem + 1)))
        numberOfItem = numberOfItem + 1
    end
    local bodyHeight = (22 * numberOfItem)
    tooltip.background.fileBody = tooltip.background.fileBody .. "?scalenearest=1;" .. 2 + bodyHeight -- 38
    tooltip.title.position[2] = tooltip.title.position[2] + (-1 + bodyHeight)
    tooltip.itemList.rect[4] = tooltip.itemList.rect[4] + (24 * numberOfItem)
    return tooltip
end
-- create and open a scripted pane instead of creating a normal tooltip
-- this func create a item list... can be told to mimic the recipe ingredient(s) list of the vanilla crafting pane(s)
function D8Tooltip:scriptedItemList(itemList, mousePosition, override, backgroundImage)
    local hideVanilla = {
        background = {
            type = "background",
            fileBody = "/assetmissing.png"
        }
    }
    if player.getProperty("d8TooltipUtilOpen")[paneTempID] then return hideVanilla end -- stop the creation of a new pane if one is already open
    local vanillaConfig = root.assetJson("/interface/craftingtooltip/craftingtooltip.config")
    local override = override or {}
    local tooltip = root.assetJson("/shared/darkcraft8/d8ToolTipUtil/tooltip.config").scriptedItemList
    tooltip.gui.title = vanillaConfig.title

    local pathTemplate = "itemList.children" .. ""
    local listTemplate = {
        type = "layout",
        layoutType = "basic",
        rect = {0, 0, 145, 22}, -- both Height should be increased based on the amount of item descriptor
        children = {
            backgroundImg = vanillaConfig.itemList.schema.listTemplate.background,
            itemName = vanillaConfig.itemList.schema.listTemplate.itemName,
            itemIcon = {
                type = "itemslot",
                position = {4, 2},
                zlevel = 1,
                showCount = false, 
                callback = "null"
            },
            count = vanillaConfig.itemList.schema.listTemplate.count
        }
    }
    tooltip.gui.title.value = override.title or vanillaConfig.title.value or "ITEM"

    if not backgroundImage then
        tooltip.gui.background.fileHeader = vanillaConfig.background.stretchSet["end"] or "/interface/craftingtooltip/header.png"
        tooltip.gui.background.fileBody = vanillaConfig.background.stretchSet.inner or "/interface/craftingtooltip/body.png"
        tooltip.gui.background.fileFooter = vanillaConfig.background.stretchSet.begin or "/interface/craftingtooltip/footer.png"
    else
        tooltip.gui.background.fileHeader = backgroundImage.stretchSet["end"] or "/interface/craftingtooltip/header.png"
        tooltip.gui.background.fileBody = backgroundImage.stretchSet.inner or "/interface/craftingtooltip/body.png"
        tooltip.gui.background.fileFooter = backgroundImage.stretchSet.begin or "/interface/craftingtooltip/footer.png"
    end
    
    local numberOfItem = 0
    local currencyInputs = {}
    local itemName = function(itemDescriptor)
        if type(itemDescriptor) == "string" then return itemDescriptor end
        return itemDescriptor.item or itemDescriptor.name or itemDescriptor.itemName or itemDescriptor[1]
    end

    if itemList.input then
        if not currenciesConfig then currenciesConfig = root.assetJson("/currencies.config") end
        currencyInputs = copy(itemList.currencyInputs)
        itemList = copy(itemList.input)
        for currency, amount in pairs(currencyInputs) do 
            local representativeItem = currenciesConfig[currency]["representativeItem"]
            local added = false
            for index, descriptor in pairs(itemList or {}) do
                if itemName(descriptor) == representativeItem then
                    added = true
                    itemList[index] = {
                        name = itemName(descriptor),
                        count = (descriptor.count or descriptor[2]) + amount,
                        parameters = descriptor.parameters or descriptor[3]
                    }
                    break
                end
            end
            if not added then
                table.insert(itemList, {
                    name = currency,
                    count = amount
                })
            end
        end
    end

    for index, descriptor in pairs(itemList or {}) do
        if itemName(descriptor) then
            local cfg = root.itemConfig(descriptor)
            local name = descriptor
            local itemCount = 1
            if type(descriptor) == "table" then
                local itemName = itemName(descriptor)
                if not itemName then sb.logInfo("itemName not found for %s", descriptor) end
                name = index .. "|" .. itemName
                itemCount = descriptor.count or descriptor[2] or 1
            else
                name = index .. "|" .. name
            end
            tooltip.gui.itemList.children[name] = copy(listTemplate)

            tooltip.gui.itemList.children[name]["children"]["itemName"]["value"] = (cfg.parameters.shortdescription or cfg.config.shortdescription)
            
            if itemCount > 0 then
                if override.mimicRecipeTooltip then
                    local itemPlayerCount = 0
                    if type(descriptor) == "table" then
                        itemPlayerCount = player.hasCountOfItem({
                            name = itemName(descriptor),
                            count = 1,
                            parameters = cfg.parameters
                        }, override.matchInputParameters)
                    else
                        itemPlayerCount = player.hasCountOfItem(descriptor, override.matchInputParameters)  
                    end
                    if itemPlayerCount >= itemCount then
                        tooltip.gui.itemList.children[name]["children"]["count"]["value"] = "^green;" .. itemPlayerCount .. "/" .. itemCount
                    else
                        tooltip.gui.itemList.children[name]["children"]["count"]["value"] = "^red;" .. itemPlayerCount .. "/" .. itemCount
                    end
                else
                    tooltip.gui.itemList.children[name]["children"]["count"]["value"] = tostring(itemCount)
                end
            else
                tooltip.gui.itemList.children[name]["children"]["count"]["value"] = ""
            end

            tooltip.itemSlotList[name] = {
                path = "itemList." .. name,
                item = descriptor
            }
            tooltip.mimicRecipeTooltip = override.mimicRecipeTooltip
            tooltip.matchInputParameters = override.matchInputParameters
            tooltip.gui.itemList.children[name]["rect"][2] = (22 * (#itemList - (numberOfItem + 1)))
            tooltip.gui.itemList.children[name]["rect"][4] =  22 + (22 * (#itemList - (numberOfItem + 1)))


            numberOfItem = numberOfItem + 1
            if itemCount == 0 and override.mimicRecipeTooltip then
                tooltip.gui.itemList.children[name] = nil
                numberOfItem = numberOfItem - 1
            end
        end
    end
    local bodyHeight = (22 * numberOfItem)
    tooltip.gui.background.fileBody = tooltip.gui.background.fileBody .. "?scalenearest=1;" .. 2 + bodyHeight -- 38
    tooltip.gui.title.position[2] = tooltip.gui.title.position[2] + (-1 + bodyHeight)
    tooltip.gui.itemList.rect[4] = tooltip.gui.itemList.rect[4] + (24 * numberOfItem)

    if not self.tooltipCo then
        local mousePosition = vec2.mul(input.mousePosition(), 1 / interface.scale())
        tooltip.gui.panefeature.offset = mousePosition
        local offset = {0,0}
        offset = vec2.add(offset, root.imageSize(tooltip.gui.background.fileFooter))
        offset = vec2.add(offset, root.imageSize(tooltip.gui.background.fileBody))
        if vec2.sub(tooltip.gui.panefeature.offset, {-10, offset[2] - 10})[2] > 0 then
            if not pane.setPosition then
                tooltip.gui.panefeature.offset = vec2.sub(tooltip.gui.panefeature.offset, {-10, offset[2] - 10})
            else
                tooltip.gui.panefeature.offset = {0, 0}
                player.setProperty("d8TooltipUtil_offset", {-10, offset[2]})
            end
        else -- has part under the screen
            offset[2] = offset[2] - math.abs(vec2.sub(tooltip.gui.panefeature.offset, {-10, offset[2]})[2])
            if not pane.setPosition then
                tooltip.gui.panefeature.offset = vec2.sub(tooltip.gui.panefeature.offset, {-10, offset[2]})
            else
                tooltip.gui.panefeature.offset = {0, 0}
                player.setProperty("d8TooltipUtil_offset", {-10, (offset[2])})
            end
        end
        
        self.tooltipCo = self:prepareScriptedTooltip(tooltip, mousePosition)
        D8Tooltip.oldMousePosition = mousePosition
    end
    return hideVanilla
end

-- cursorOverride is given the mousePosition in the screen instead of the pane allowing coders to get the screenPosition of the cursor
local _cursorOverride = cursorOverride -- incase someone load the script after init/the cursorOverride function
function cursorOverride(mousePosition)
    D8Tooltip:cursorOverride(mousePosition)
    if not vec2.eq((self.mousePosition or {0, 0}), mousePosition) then self.mousePosition = mousePosition end --sb.logInfo("new mousePosition = %s", self.mousePosition)
    if _cursorOverride then return _cursorOverride(mousePosition) end
end

-- prepare the coroutine for the openning of the scripted Tooltip Pane
function D8Tooltip:prepareScriptedTooltip(tooltip, mousePosition) 
    local co = coroutine.create(function(tooltip, mousePosition)
        local tooltip, mousePosition = tooltip, mousePosition
        D8Tooltip:scriptTipClosed() -- failsafe
        coroutine.yield()

        if not tooltip.paneTempID then tooltip.paneTempID = paneTempID end
        player.interact("ScriptPane", tooltip)
        self.tooltipCo = nil
    end)
    coroutine.resume(co, tooltip, mousePosition)
    return co
end
