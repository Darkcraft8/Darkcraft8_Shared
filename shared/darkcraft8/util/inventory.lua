-- Require openStarbound and access to the player table
inventory = inventory or {}

-- return a array that contain two different array one containing only the count of the item based on their itemName --
-- the other containing the count of the item based on their stringified descriptor --
inventory.normalize = function()
    local normalizedInv = {
        soft = {},
        exact = {}
    }
    local playerInfo = player.save()

    for itemName, count in pairs(playerInfo.inventory.currencies) do
        if not normalizedInv.soft[itemName] then
            normalizedInv.soft[itemName] = count
        else
            normalizedInv.soft[itemName] = normalizedInv.soft[itemName] + count
        end
    end

    for _, bagContent in pairs(playerInfo.inventory.itemBags) do 
        for slotIndex, slotCfg in ipairs(bagContent) do 
            if type(slotCfg) == "table" then
                local stringified = sb.printJson({name = slotCfg.content.name, parameters = slotCfg.content.parameters})
                
                if not normalizedInv.exact[stringified] then
                    normalizedInv.exact[stringified] = slotCfg.content.count
                else
                    normalizedInv.exact[stringified] = normalizedInv.exact[stringified] + slotCfg.content.count
                end

                if not normalizedInv.soft[slotCfg.content.name] then
                    normalizedInv.soft[slotCfg.content.name] = slotCfg.content.count
                else
                    normalizedInv.soft[slotCfg.content.name] = normalizedInv.soft[slotCfg.content.name] + slotCfg.content.count
                end
            end
        end
    end

    return normalizedInv
end

-- return true and the amount divided by the descripted count(if any)
inventory.hasItem = function(itemDescriptorOrName, exactMatch)
    local playerInv = self:normalize()
    local searchString = ""
    if exactMatch then
        if type(itemDescriptorOrName) == "table" then
            searchString = sb.printJson({name = itemDescriptorOrName.name, parameters = itemDescriptorOrName.parameters})
        else
            searchString = itemDescriptorOrName
        end
    else
        if type(itemDescriptorOrName) == "table" then
            searchString = itemDescriptorOrName.name
        else
            searchString = itemDescriptorOrName
        end
    end
    local count = 0
    local bagCount = playerInv.exact[searchString] or playerInv.soft[searchString]
    if bagCount then
        if type(itemDescriptorOrName) == "table" then
            count = bagCount / math.max((itemDescriptorOrName.count or 1), 1)
        else
            count = bagCount
        end
    end

    if count ~= 0 then
        return true, count
    else
        return false
    end
end