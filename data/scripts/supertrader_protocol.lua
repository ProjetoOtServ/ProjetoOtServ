-- Super Trader Protocol
-- Handles communication between client (OTClient) and server for blacklist management
-- This allows Ctrl+Click menu options to add/remove items from blacklist

local SuperTraderProtocol = {}

-- Protocol opcodes
SuperTraderProtocol.Opcodes = {
    ADD_TO_BLACKLIST = 0xF1,      -- Client -> Server: Add item to blacklist
    REMOVE_FROM_BLACKLIST = 0xF2, -- Client -> Server: Remove item from blacklist
    CHECK_BLACKLIST = 0xF3,       -- Client -> Server: Check if item is blacklisted
    BLACKLIST_RESPONSE = 0xF4,    -- Server -> Client: Response with blacklist status
}

-- Helper function to get player's blacklist
function SuperTraderProtocol.getPlayerBlacklist(player)
    local blacklist = player:kv():get("supertrader-blacklist") or {}
    if type(blacklist) ~= "table" then
        blacklist = {}
    end
    return blacklist
end

-- Helper function to save player's blacklist
function SuperTraderProtocol.savePlayerBlacklist(player, blacklist)
    player:kv():set("supertrader-blacklist", blacklist)
end

-- Add item to blacklist
function SuperTraderProtocol.addToBlacklist(player, itemId)
    local itemType = ItemType(itemId)
    if not itemType or itemType:getId() == 0 then
        logger.error("[SuperTraderProtocol] Invalid itemId: {}", itemId)
        return false, "Invalid item"
    end
    
    local blacklist = SuperTraderProtocol.getPlayerBlacklist(player)
    blacklist[itemId] = true
    SuperTraderProtocol.savePlayerBlacklist(player, blacklist)
    
    logger.info("[SuperTraderProtocol] Player '{}' added '{}' (ID: {}) to blacklist", 
        player:getName(), itemType:getName(), itemId)
    
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 
        string.format("[Super Trader] Added '%s' to blacklist.", itemType:getName()))
    
    return true, itemType:getName()
end

-- Remove item from blacklist
function SuperTraderProtocol.removeFromBlacklist(player, itemId)
    local itemType = ItemType(itemId)
    if not itemType or itemType:getId() == 0 then
        logger.error("[SuperTraderProtocol] Invalid itemId: {}", itemId)
        return false, "Invalid item"
    end
    
    local blacklist = SuperTraderProtocol.getPlayerBlacklist(player)
    blacklist[itemId] = nil
    SuperTraderProtocol.savePlayerBlacklist(player, blacklist)
    
    logger.info("[SuperTraderProtocol] Player '{}' removed '{}' (ID: {}) from blacklist", 
        player:getName(), itemType:getName(), itemId)
    
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 
        string.format("[Super Trader] Removed '%s' from blacklist.", itemType:getName()))
    
    return true, itemType:getName()
end

-- Check if item is blacklisted
function SuperTraderProtocol.isItemBlacklisted(player, itemId)
    local blacklist = SuperTraderProtocol.getPlayerBlacklist(player)
    return blacklist[itemId] == true
end

-- Get all blacklisted items for player
function SuperTraderProtocol.getBlacklistItems(player)
    local blacklist = SuperTraderProtocol.getPlayerBlacklist(player)
    local items = {}
    
    for itemId, _ in pairs(blacklist) do
        local itemType = ItemType(itemId)
        if itemType then
            table.insert(items, {
                id = itemId,
                name = itemType:getName(),
                clientId = itemType:getClientId()
            })
        end
    end
    
    return items
end

-- Network message handlers
-- Register protocol on player login
local function registerProtocol(player)
    -- This would be called when player logs in
    logger.debug("[SuperTraderProtocol] Registered for player '{}'", player:getName())
end

-- Make protocol available globally
_G.SuperTraderProtocol = SuperTraderProtocol

logger.info("[SuperTraderProtocol] Protocol module loaded")
