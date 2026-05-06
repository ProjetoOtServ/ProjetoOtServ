-- persistence_manager.lua
-- Gerencia o salvamento e carregamento de itens persistentes (Construções)

PersistenceManager = {}

function PersistenceManager.saveItem(item, ownerId)
    if not item or not item:isItem() then return false end
    
    local pos = item:getPosition()
    local itemId = item:getId()
    local attributes = "" -- Podemos serializar atributos customizados aqui se necessário
    
    -- Verifica se já existe um registro para esta posição para evitar duplicatas
    db.asyncQuery(string.format("DELETE FROM `construction_persistence` WHERE `x` = %d AND `y` = %d AND `z` = %d", pos.x, pos.y, pos.z))
    
    -- Insere o novo registro
    local query = string.format(
        "INSERT INTO `construction_persistence` (`item_id`, `x`, `y`, `z`, `owner_id`, `attributes`) VALUES (%d, %d, %d, %d, %d, %s)",
        itemId, pos.x, pos.y, pos.z, ownerId or 0, db.escapeString(attributes)
    )
    
    db.asyncQuery(query)
    
    -- Marca o item no jogo para referência rápida
    item:setCustomAttribute("persistent", 1)
    item:setCustomAttribute("construction_owner", ownerId or 0)
    
    -- Adiciona o atributo de Store para o ícone visual (conforme pedido: "como na store")
    item:setAttribute(ITEM_ATTRIBUTE_STORE, os.time())
    
    return true
end

function PersistenceManager.removeItem(pos)
    if not pos then return false end
    db.asyncQuery(string.format("DELETE FROM `construction_persistence` WHERE `x` = %d AND `y` = %d AND `z` = %d", pos.x, pos.y, pos.z))
    return true
end

function PersistenceManager.loadAll()
    local resultId = db.storeQuery("SELECT * FROM `construction_persistence`")
    if resultId ~= false then
        local count = 0
        repeat
            local itemId = result.getNumber(resultId, "item_id")
            local x = result.getNumber(resultId, "x")
            local y = result.getNumber(resultId, "y")
            local z = result.getNumber(resultId, "z")
            local ownerId = result.getNumber(resultId, "owner_id")
            
            local pos = Position(x, y, z)
            local tile = Tile(pos)
            if tile then
                -- Remove item existente no topo se for construção (evita sobreposição no reload)
                local topItem = tile:getTopVisibleThing()
                if topItem and topItem:isItem() and topItem:getId() == itemId then
                    topItem:remove()
                end
                
                local newItem = Game.createItem(itemId, 1, pos)
                if newItem then
                    newItem:setCustomAttribute("persistent", 1)
                    newItem:setCustomAttribute("construction_owner", ownerId)
                    newItem:setAttribute(ITEM_ATTRIBUTE_STORE, os.time())
                    count = count + 1
                end
            end
        until not result.next(resultId)
        result.free(resultId)
        print(string.format("[PersistenceManager] Loaded %d constructed items from database.", count))
    end
end
