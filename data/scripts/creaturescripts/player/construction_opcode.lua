local constructionOpcode = CreatureEvent("ConstructionOpcode")

function constructionOpcode.onExtendedOpcode(player, opcode, buffer)
    if opcode ~= 101 then
        return false
    end

    print("[Construction] Opcode 101 recebido de " .. player:getName() .. ": " .. tostring(buffer))
    
    local parts = buffer:split(",")
    if #parts < 4 then
        player:sendCancelMessage("Dados de construção inválidos.")
        return true
    end

    local itemId = tonumber(parts[1])
    local x = tonumber(parts[2])
    local y = tonumber(parts[3])
    local z = tonumber(parts[4])

    if not itemId or not x or not y or not z then
        player:sendCancelMessage("Coordenadas inválidas.")
        return true
    end

    local pos = Position(x, y, z)
    local tile = Tile(pos)
    
    if not tile then
        player:sendCancelMessage("Posição inválida.")
        return true
    end

    if tile:hasProperty(CONST_PROP_BLOCKSOLID) then
        player:sendCancelMessage("Posição bloqueada. Você não pode construir em cima de paredes ou objetos sólidos.")
        return true
    end

    local house = tile:getHouse()
    if not house then
        player:sendCancelMessage("Você só pode construir dentro de uma casa. Este tile não pertence a nenhuma casa.")
        return true
    else
        if house:getOwnerGuid() ~= player:getGuid() then
            if player:getGroup():getId() < 3 then
                player:sendCancelMessage("Você só pode construir na sua própria propriedade (Dono: " .. house:getOwnerGuid() .. ").")
                return true
            end
        end
    end

    local CONSTRUCTION_RECIPES = {
        [1281] = {p = 7, n = 16},
        [1282] = {p = 7, n = 16},
        [1284] = {p = 7, n = 16},
        [1286] = {p = 7, n = 16},
        [1287] = {p = 7, n = 16}
    }

    local recipe = CONSTRUCTION_RECIPES[itemId] or {p = 10, n = 20}

    -- Cria o Canteiro de Obras (Decoration Kit ID 23398)
    local site = Game.createItem(23398, 1, pos)
    if site then
        site:setActionId(60000)
        local targetName = ItemType(itemId):getName()
        local desc = string.format("Projeto: %s\nMateriais requeridos:\n- Wooden Planks: 0 / %d\n- Nails: 0 / %d", targetName, recipe.p, recipe.n)
        
        site:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, desc)
        site:setCustomAttribute("constructionTarget", itemId)
        site:setCustomAttribute("plankNeeded", recipe.p)
        site:setCustomAttribute("plankCurrent", 0)
        site:setCustomAttribute("nailNeeded", recipe.n)
        site:setCustomAttribute("nailCurrent", 0)
        
        pos:sendMagicEffect(CONST_ME_POFF)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Canteiro de obras posicionado. Use os materiais nele para concluir.")
    else
        player:sendCancelMessage("Falha ao criar o canteiro de obras. Posição bloqueada.")
    end

    return true
end

constructionOpcode:type("extendedopcode")
constructionOpcode:register()
