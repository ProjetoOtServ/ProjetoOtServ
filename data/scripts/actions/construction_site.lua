-- construction_site.lua
-- Lógica de aplicação de materiais e demolição

local constructionAction = Action()

-- Carregamento forçado da LIB se necessário (Canary fix)
if not CONSTRUCTION_SITE_ID then
    pcall(function() dofile("data/scripts/lib/construction_configs.lua") end)
end

-- Função para atualizar o cliente via Opcode 102 (Status da Obra)
local function sendConstructionStatus(player, site)
    local targetId = site:getCustomAttribute("constructionTarget")
    if not targetId then return end

    local pNeeded = site:getCustomAttribute("plankNeeded") or 0
    local pCurrent = site:getCustomAttribute("plankCurrent") or 0
    local nNeeded = site:getCustomAttribute("nailNeeded") or 0
    local nCurrent = site:getCustomAttribute("nailCurrent") or 0
    
    local recipe = CONSTRUCTION_RECIPES[targetId]
    local targetName = recipe and recipe.name or ItemType(targetId):getName()
    local pos = site:getPosition()

    -- Payload: Name|P_Cur|P_Ned|N_Cur|N_Ned|X|Y|Z
    local buffer = string.format("%s|%d|%d|%d|%d|%d|%d|%d", 
        targetName, pCurrent, pNeeded, nCurrent, nNeeded, pos.x, pos.y, pos.z)
    
    player:sendExtendedOpcode(102, buffer)
end

function constructionAction.onUse(player, item, ...)
    local args = {...}
    
    local targetItem = nil
    for i, arg in ipairs(args) do
        if type(arg) == "userdata" and arg.isItem and arg:isItem() then
            targetItem = arg
            break
        end
    end

    local constructionSite = nil
    if item:getId() == CONSTRUCTION_SITE_ID then
        constructionSite = item
    elseif targetItem and targetItem:getId() == CONSTRUCTION_SITE_ID then
        constructionSite = targetItem
    end

    if not constructionSite then
        return false
    end

    -- SEGURANÇA: Validar posse da casa
    local pos = constructionSite:getPosition()
    local tile = Tile(pos)
    local house = tile:getHouse()
    
    local playerGuid = player:getGuid()
    local ownerGuid = house and house:getOwnerGuid() or 0
    
    if not house or ownerGuid ~= playerGuid then
        if player:getGroup():getId() < 3 then
            player:sendCancelMessage("Voc\234 n\227o tem permiss\227o para gerenciar esta propriedade.")
            return true
        end
    end

    -- Envia o status para o cliente abrir o Gerenciador (Opcode 102)
    sendConstructionStatus(player, constructionSite)
    return true
end

-- Registro por ActionID (60000)
-- O menu modal é disparado ao dar "Use" (Right Click) no canteiro
constructionAction:aid(CONSTRUCTION_AID)
constructionAction:register()

