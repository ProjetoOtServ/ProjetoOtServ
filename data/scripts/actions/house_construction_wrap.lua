--[[
    House Construction Materials - Wrap/Unwrap System
    Allows players to wrap and unwrap construction materials in their houses
]]

-- IDs que NAO estao em ranges de outros scripts (evita warnings de duplicata)
local CONSTRUCTION_MATERIALS = {
    -- Floors (pisos) - IDs unicos
    floors = {
        408, 409, 410, 415, 416, 417, 418, 421, 422, 423, 424, 425,
        436, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449,
        450, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462,
        463, 464, 479, 481, 486, 487, 488, 489, 490, 491, 492, 493,
        494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504
    },
    -- Walls (paredes) - IDs unicos  
    walls = {
        356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367,
        373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384,
        478, 480, 920, 921, 1112, 1113, 1114, 1115, 1116, 1117, 1118,
        1119, 1120, 1121, 1122, 1270, 1271, 1272, 1273, 1274, 1275,
        1276, 1277, 1278, 1279, 1280, 1356, 1357, 1358, 1359, 1360,
        1361, 1362, 1363, 1364, 1450, 1451, 1452, 1453, 1454, 1455,
        1456, 1457, 1458, 1459, 1460, 1461, 1462, 1463, 1464
    },
    -- Stairs (escadas) - IDs fora dos ranges padrao
    stairs = {
        566, 567, 855, 856, 1947, 1958, 1977, 1978, 
        4823, 4824, 4825, 4826, 5081, 5257, 5258, 5259, 
        7881, 7888, 8657, 8658, 8690, 8932
    },
    -- Roofs (telhados)
    roofs = {
        1152, 1153, 1154, 1155, 1157, 1158, 1159, 1160, 1161, 1162,
        1163, 1164, 1165, 1166, 1167, 1168, 1169, 1170, 1171, 1172,
        1173, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182,
        1183, 1184, 1185, 1186, 1187, 1188, 1189, 1190, 1191, 1192,
        1193, 1194, 1195, 1196
    },
    -- Windows (janelas)
    windows = {
        1465, 1471, 1481, 1486, 1499, 1500, 1734, 1735, 1736, 1737,
        1738, 1739, 1740, 1741, 1742, 1743, 1744, 1745, 1746, 1747
    },
    -- Pillars (pilastras) - removidos 7058, 7059
    pillars = {
        2152, 2153, 2188, 2190, 2255, 2256, 2257, 2258, 2263, 2264,
        2289, 2290, 5025, 5307, 6412, 6775, 6986
    },
    -- Doors (portas) - removidas todas as que estao em ranges (1632-1657)
    -- Nao incluimos portas aqui pois ja tem scripts padrao para elas
}

-- Helper function to check if an item ID is a construction material
local function isConstructionMaterial(itemId)
    for category, ids in pairs(CONSTRUCTION_MATERIALS) do
        if table.contains(ids, itemId) then
            return true, category
        end
    end
    return false, nil
end

-- Helper function to get all construction item IDs as a flat list
local function getAllConstructionIds()
    local allIds = {}
    for category, ids in pairs(CONSTRUCTION_MATERIALS) do
        for _, id in ipairs(ids) do
            table.insert(allIds, id)
        end
    end
    return allIds
end

-- Action: Wrap construction material
local wrapAction = Action()

function wrapAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local itemId = item:getId()
    
    -- Check if this is a construction material
    local isConstruction, category = isConstructionMaterial(itemId)
    if not isConstruction then
        return false
    end
    
    -- Check if player is in a house
    local tile = Tile(fromPosition)
    if not tile then
        player:sendCancelMessage("You can only wrap construction materials inside a house.")
        return true
    end
    
    local house = tile:getHouse()
    if not house then
        player:sendCancelMessage("You can only wrap construction materials inside a house.")
        return true
    end
    
    -- Check if player is the house owner
    if house:getOwner() ~= player:getGuid() then
        player:sendCancelMessage("You can only wrap construction materials in your own house.")
        return true
    end
    
    -- Check if the item is on the ground (not in backpack)
    local parent = item:getParent()
    if not parent or parent:isItem() then
        player:sendCancelMessage("You must place the item on the ground to wrap it.")
        return true
    end
    
    -- Create decoration kit
    local inbox = player:getStoreInbox()
    if not inbox then
        player:sendCancelMessage("Could not access your store inbox.")
        return true
    end
    
    local kit = inbox:addItem(ITEM_DECORATION_KIT, 1)
    if not kit then
        player:sendCancelMessage("Could not create wrap kit. Make sure you have space in your store inbox.")
        return true
    end
    
    -- Configure the kit
    local itemType = ItemType(itemId)
    local itemName = itemType:getName()
    
    kit:setCustomAttribute("unWrapId", itemId)
    kit:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "You bought this item in the Store.\nUnwrap it in your own house to create a <" .. itemName .. ">.")
    kit:setAttribute(ITEM_ATTRIBUTE_STORE, systemTime())
    
    -- Remove the original item
    item:remove(1)
    
    -- Send success message
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The " .. itemName .. " has been wrapped and sent to your store inbox.")
    player:sendUpdateContainer(inbox)
    
    return true
end

-- Register for all construction item IDs
local allIds = getAllConstructionIds()
wrapAction:id(unpack(allIds))
wrapAction:register()

print("[House Construction] Wrap system loaded with " .. #allIds .. " construction item types.")
