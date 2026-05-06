-- construction_site.lua
-- Lógica de aplicação de materiais e demolição

local MATERIAL_PLANK = 5300
local MATERIAL_NAIL = 953
local TOOL_HAMMER = 3460
local CONSTRUCTION_SITE_ID = 23398

-- Tabela de Receitas (Resultado -> {planks, nails})
local CONSTRUCTION_RECIPES = {
    [356] = { planks = 10, nails = 5 },  -- Dirt Wall
    [357] = { planks = 10, nails = 5 },  -- Stone Wall
    [408] = { planks = 5, nails = 2 },   -- Wood Floor
    [409] = { planks = 5, nails = 2 },   -- Marble Floor
    [2474] = { planks = 8, nails = 12 }, -- Wooden Coffin
    [2582] = { planks = 4, nails = 4 },  -- Chair
    -- Framework walls
    [1281] = { planks = 7, nails = 16 },
    [1282] = { planks = 7, nails = 16 },
    [1284] = { planks = 7, nails = 16 },
    [1286] = { planks = 7, nails = 16 },
    [1287] = { planks = 7, nails = 16 }
}

local constructionAction = Action()

function constructionAction.onUse(player, item, ...)
    local args = {...}
    
    local mapPosition = nil
    local targetItem = nil

    -- Varre os argumentos para encontrar o que precisamos (Posição ou Item)
    for i, arg in ipairs(args) do
        if type(arg) == "table" then
            if arg.x and arg.x > 0 and arg.x < 65535 then
                mapPosition = arg
            elseif arg.uid and arg.uid > 0 then
                targetItem = Item(arg.uid)
            end
        elseif type(arg) == "userdata" then
            if arg.isItem and arg:isItem() then
                targetItem = arg
            end
        end
    end

    local constructionSite = nil
    -- 1. Tenta pelo item direto (userdata ou compat table)
    if targetItem and targetItem:getId() == CONSTRUCTION_SITE_ID and targetItem:getCustomAttribute("constructionTarget") then
        constructionSite = targetItem
    end

    -- 2. Fallback: Procura no chão da coordenada encontrada
    if not constructionSite and mapPosition then
        local tile = Tile(mapPosition)
        if tile then
            local items = tile:getItems()
            if items then
                for _, i in ipairs(items) do
                    if i:getId() == CONSTRUCTION_SITE_ID and i:getCustomAttribute("constructionTarget") then
                        constructionSite = i
                        break
                    end
                end
            end
        end
    end

    if not constructionSite then
        return false
    end

    local targetId = constructionSite:getCustomAttribute("constructionTarget")
    if not targetId then return false end

    -- Lógica de aplicação de materiais
    if item:getId() == MATERIAL_PLANK or item:getId() == MATERIAL_NAIL then
        local attrPrefix = (item:getId() == MATERIAL_PLANK) and "plank" or "nail"
        local needed = constructionSite:getCustomAttribute(attrPrefix .. "Needed") or 0
        local current = constructionSite:getCustomAttribute(attrPrefix .. "Current") or 0
        
        if current < needed then
            current = current + 1
            constructionSite:setCustomAttribute(attrPrefix .. "Current", current)
            item:remove(1)
            
            player:sendTextMessage(MESSAGE_STATUS_SMALL, string.format("%s consumido. Falta %d para concluir.", item:getName(), (needed - current)))
            constructionSite:getPosition():sendMagicEffect(CONST_ME_HITAREA)

            -- Atualiza a descrição dinâmica
            local pNeeded = constructionSite:getCustomAttribute("plankNeeded") or 0
            local pCurrent = constructionSite:getCustomAttribute("plankCurrent") or 0
            local nNeeded = constructionSite:getCustomAttribute("nailNeeded") or 0
            local nCurrent = constructionSite:getCustomAttribute("nailCurrent") or 0
            
            local targetName = ItemType(targetId):getName()
            local desc = string.format("Projeto: %s\nMateriais requeridos:\n- Wooden Planks: %d / %d\n- Nails: %d / %d", targetName, pCurrent, pNeeded, nCurrent, nNeeded)
            constructionSite:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, desc)

            -- Verifica se concluiu a obra
            if pCurrent >= pNeeded and nCurrent >= nNeeded then
                local pos = constructionSite:getPosition()
                constructionSite:remove()
                local finishedItem = Game.createItem(targetId, 1, pos)
                if finishedItem then
                    pos:sendMagicEffect(CONST_ME_MAGIC_GREEN)
                    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Construção concluída!")
                end
            end
        else
            player:sendCancelMessage("Este material já foi totalmente suprido para esta construção.")
        end
        return true
    end

    -- Lógica do Martelo (Demolição)
    if item:getId() == TOOL_HAMMER then
        -- Caso 1: Demolindo Canteiro de Obras (100% de estorno)
        if constructionSite:getId() == CONSTRUCTION_SITE_ID then
            local pCurrent = constructionSite:getCustomAttribute("plankCurrent") or 0
            local nCurrent = constructionSite:getCustomAttribute("nailCurrent") or 0
            
            if pCurrent > 0 then player:addItem(MATERIAL_PLANK, pCurrent) end
            if nCurrent > 0 then player:addItem(MATERIAL_NAIL, nCurrent) end
            
            constructionSite:remove()
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Canteiro de obras removido. Materiais estornados (100%).")
            return true
        end

        -- Caso 2: Demolindo Item Concluído (50% de estorno)
        local recipe = CONSTRUCTION_RECIPES[constructionSite:getId()]
        if recipe then
            local pRefund = math.floor(recipe.planks * 0.5)
            local nRefund = math.floor(recipe.nails * 0.5)
            
            if pRefund > 0 then player:addItem(MATERIAL_PLANK, pRefund) end
            if nRefund > 0 then player:addItem(MATERIAL_NAIL, nRefund) end
            
            constructionSite:remove()
            constructionSite:getPosition():sendMagicEffect(CONST_ME_BLOCKHIT)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Estrutura demolida. Materiais estornados (50%).")
            return true
        end
    end

    return false
end

-- Registro robusto
constructionAction:id(MATERIAL_PLANK, MATERIAL_NAIL, TOOL_HAMMER)
constructionAction:aid(60000)
constructionAction:register()

