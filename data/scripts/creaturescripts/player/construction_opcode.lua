local constructionOpcode = CreatureEvent("ConstructionOpcode")

-- Carregamento forçado da LIB se necessário (Canary fix)
if not CONSTRUCTION_SITE_ID then
    pcall(function() dofile("data/scripts/lib/construction_configs.lua") end)
end

-- Helper para enviar status da obra ao cliente
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

    local buffer = string.format("%s|%d|%d|%d|%d|%d|%d|%d", 
        targetName, pCurrent, pNeeded, nCurrent, nNeeded, pos.x, pos.y, pos.z)
    
    player:sendExtendedOpcode(102, buffer)
end

function constructionOpcode.onExtendedOpcode(player, opcode, buffer)
    -- Opcode 101: Posicionamento inicial
    if opcode == 101 then
        print("[Construction] Opcode 101 recebido de " .. player:getName() .. ": " .. tostring(buffer))
        
        local parts = buffer:split(",")
        if #parts < 4 then return true end

        local itemId = tonumber(parts[1])
        local pos = Position(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))

        local recipe = CONSTRUCTION_RECIPES[itemId]
        if not recipe then return true end

        local tile = Tile(pos)
        if not tile or tile:hasProperty(CONST_PROP_BLOCKSOLID) then
            player:sendCancelMessage("Posi\231\227o inv\225lida ou bloqueada.")
            return true
        end

        local house = tile:getHouse()
        if not house or (house:getOwnerGuid() ~= player:getGuid() and player:getGroup():getId() < 3) then
            player:sendCancelMessage("Voc\234 s\243 pode construir na sua pr\243pria propriedade.")
            return true
        end

        local site = Game.createItem(CONSTRUCTION_SITE_ID, 1, pos)
        if site then
            site:setActionId(CONSTRUCTION_AID)
            site:setCustomAttribute("constructionTarget", itemId)
            
            -- Salva o piso original para restaura\231\227o
            local ground = tile:getGround()
            if ground then
                site:setCustomAttribute("originalGround", ground:getId())
            end

            site:setCustomAttribute("plankNeeded", recipe.planks)
            site:setCustomAttribute("plankCurrent", 0)
            site:setCustomAttribute("nailNeeded", recipe.nails)
            site:setCustomAttribute("nailCurrent", 0)
            
            local desc = string.format("Projeto: %s\nMateriais requeridos:\n- Wooden Planks: 0 / %d\n- Nails: 0 / %d", recipe.name, recipe.planks, recipe.nails)
            site:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, desc)
            
            pos:sendMagicEffect(CONST_ME_POFF)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Canteiro de obras posicionado.")
        end
        return true

    -- Opcode 103: Adicionar Material via UI (Suporta Pilhas)
    elseif opcode == 103 then
        print("[Construction] Opcode 103 recebido: " .. tostring(buffer))
        local parts = buffer:split(",")
        if #parts < 5 then 
            print("[Construction] Erro: Buffer incompleto (#parts=" .. #parts .. ")")
            return true 
        end

        local materialId = tonumber(parts[1])
        local count = tonumber(parts[2]) or 1
        local pos = Position(tonumber(parts[3]), tonumber(parts[4]), tonumber(parts[5]))
        
        local tile = Tile(pos)
        if not tile then 
            print("[Construction] Erro: Tile n\227o encontrado em " .. tostring(pos))
            return true 
        end

        local site = nil
        for _, item in ipairs(tile:getItems()) do
            if item:getId() == CONSTRUCTION_SITE_ID then
                site = item
                break
            end
        end

        if not site then
            print("[Construction] Erro: Canteiro n\227o encontrado no tile " .. tostring(pos))
            player:sendCancelMessage("Canteiro de obras n\227o encontrado.")
            return true
        end

        -- Valida\231\227o de material e quantidade
        local playerItemCount = player:getItemCount(materialId)
        if playerItemCount <= 0 then
            print("[Construction] Erro: Player " .. player:getName() .. " n\227o tem item " .. materialId)
            player:sendCancelMessage("Voc\234 n\227o possui o material necess\225rio.")
            return true
        end

        local attrPrefix = (materialId == MATERIAL_PLANK) and "plank" or "nail"
        local needed = site:getCustomAttribute(attrPrefix .. "Needed") or 0
        local current = site:getCustomAttribute(attrPrefix .. "Current") or 0

        if current < needed then
            local remaining = needed - current
            local toConsume = math.min(count, remaining)
            toConsume = math.min(toConsume, playerItemCount) -- Garante que n\227o consome mais do que o jogador tem

            player:removeItem(materialId, toConsume)
            current = current + toConsume
            site:setCustomAttribute(attrPrefix .. "Current", current)
            
            pos:sendMagicEffect(CONST_ME_HITAREA)
            
            -- Atualiza descri\231\227o
            local pNeeded = site:getCustomAttribute("plankNeeded") or 0
            local pCurrent = site:getCustomAttribute("plankCurrent") or 0
            local nNeeded = site:getCustomAttribute("nailNeeded") or 0
            local nCurrent = site:getCustomAttribute("nailCurrent") or 0
            local targetId = site:getCustomAttribute("constructionTarget")
            local recipe = CONSTRUCTION_RECIPES[targetId]
            
            local desc = string.format("Projeto: %s\nMateriais requeridos:\n- Wooden Planks: %d / %d\n- Nails: %d / %d", 
                recipe and recipe.name or "Obra", pCurrent, pNeeded, nCurrent, nNeeded)
            site:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, desc)

            -- Atualiza a UI
            sendConstructionStatus(player, site)
        else
            player:sendCancelMessage("Este projeto n\227o precisa de mais materiais deste tipo.")
        end
        return true

    -- Opcode 104: Finalizar Constru\231\227o (Bot\227o Construir)
    elseif opcode == 104 then
        local parts = buffer:split(",")
        if #parts < 3 then return true end

        local pos = Position(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]))
        local tile = Tile(pos)
        if not tile then return true end

        local site = nil
        for _, item in ipairs(tile:getItems()) do
            if item:getId() == CONSTRUCTION_SITE_ID then
                site = item
                break
            end
        end

        if not site then
            player:sendCancelMessage("Canteiro de obras n\227o encontrado.")
            return true
        end

        local pNeeded = site:getCustomAttribute("plankNeeded") or 0
        local pCurrent = site:getCustomAttribute("plankCurrent") or 0
        local nNeeded = site:getCustomAttribute("nailNeeded") or 0
        local nCurrent = site:getCustomAttribute("nailCurrent") or 0
        local targetId = site:getCustomAttribute("constructionTarget")

        if pCurrent >= pNeeded and nCurrent >= nNeeded then
            local originalGround = site:getCustomAttribute("originalGround")
            site:remove()
            local finishedItem = Game.createItem(targetId, 1, pos)
            if finishedItem then
                if originalGround then
                    finishedItem:setCustomAttribute("originalGround", originalGround)
                end
                
                -- Persistência de Memória de Terreno
                PersistenceManager.saveItem(finishedItem, player:getGuid())

                -- Lógica Especial para Ladder Up (1948): Criar saída e descida automática
                if targetId == 1948 then
                    local upPos = Position(pos.x, pos.y, pos.z - 1)
                    local landingPos = Position(pos.x, pos.y + 1, pos.z - 1)
                    
                    -- Captura ground original da saída
                    local landingTile = Tile(landingPos)
                    local landingGround = landingTile and landingTile:getGround()
                    
                    -- Cria o piso de madeira (Wooden Floor 408) 1 sqm ao sul no andar de cima
                    local floor = Game.createItem(408, 1, landingPos)
                    if floor then 
                        if landingGround then floor:setCustomAttribute("originalGround", landingGround:getId()) end
                        PersistenceManager.saveItem(floor, player:getGuid()) 
                    end
                    
                    -- Captura ground original da descida
                    local upTile = Tile(upPos)
                    local upGround = upTile and upTile:getGround()

                    -- Cria a escada de descida (Ladder Down 433) no mesmo tile da subida, mas no andar de cima
                    local ladderDown = Game.createItem(433, 1, upPos)
                    if ladderDown then 
                        if upGround then ladderDown:setCustomAttribute("originalGround", upGround:getId()) end
                        PersistenceManager.saveItem(ladderDown, player:getGuid()) 
                    end
                    
                    landingPos:sendMagicEffect(CONST_ME_POFF)
                    upPos:sendMagicEffect(CONST_ME_POFF)
                end

                -- Lógica Especial para Ladder Down (433): Criar subida automática
                if targetId == 433 then
                    local downPos = Position(pos.x, pos.y, pos.z + 1)
                    
                    -- Captura ground original da subida
                    local downTile = Tile(downPos)
                    local downGround = downTile and downTile:getGround()

                    -- Cria a escada de subida (Ladder Up 1948) no mesmo tile, andar abaixo
                    local ladderUp = Game.createItem(1948, 1, downPos)
                    if ladderUp then 
                        if downGround then ladderUp:setCustomAttribute("originalGround", downGround:getId()) end
                        PersistenceManager.saveItem(ladderUp, player:getGuid()) 
                    end
                    
                    downPos:sendMagicEffect(CONST_ME_POFF)
                end
                
                pos:sendMagicEffect(CONST_ME_MAGIC_GREEN)
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Constru\231\227o conclu\237da com sucesso!")
            end
        else
            player:sendCancelMessage("Materiais insuficientes para concluir a obra.")
        end
        return true
    end

    return false
end

constructionOpcode:type("extendedopcode")
constructionOpcode:register()
