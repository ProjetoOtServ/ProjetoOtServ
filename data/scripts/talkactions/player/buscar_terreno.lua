local buscarTerreno = TalkAction("!buscaterreno")

-- Tabela global para armazenar jogadores com o modo de busca ativo
if not BuscarTerrenoData then
	BuscarTerrenoData = {}
end

function buscarTerreno.onSay(player, words, param)
	local guid = player:getGuid()
	local paramLower = param:lower():trim()
	
	if paramLower == "on" then
		BuscarTerrenoData[guid] = {
			active = true,
			lastCheck = 0
		}
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Modo de busca de terrenos ATIVADO. Casas disponiveis serao destacadas conforme voce se aproxima.")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		return true
	elseif paramLower == "off" then
		BuscarTerrenoData[guid] = nil
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Modo de busca de terrenos DESATIVADO.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	else
		local status = BuscarTerrenoData[guid] and BuscarTerrenoData[guid].active and "ATIVADO" or "DESATIVADO"
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Comando: !buscaterreno [on/off]. Status atual: " .. status)
		return true
	end
end

buscarTerreno:separator(" ")
buscarTerreno:groupType("normal")
buscarTerreno:register()

-- GlobalEvent para verificar periodicamente e mostrar efeitos
local terrenoHighlighter = GlobalEvent("TerrenoHighlighter")

function terrenoHighlighter.onThink(interval)
	local currentTime = os.time()
	
	for guid, data in pairs(BuscarTerrenoData) do
		if data.active then
			-- Verifica a cada 2 segundos
			if currentTime - data.lastCheck >= 2 then
				data.lastCheck = currentTime
				
				local player = Player(guid)
				if player then
					checkAndHighlightHouses(player)
				else
					-- Jogador nao existe mais, remove da lista
					BuscarTerrenoData[guid] = nil
				end
			end
		end
	end
	
	return true
end

function checkAndHighlightHouses(player)
	local playerPos = player:getPosition()
	local houses = Game.getHouses()
	
	for _, house in pairs(houses) do
		-- So mostra casas sem dono (getOwnerGuid() == 0)
		if house:getOwnerGuid() == 0 then
			local houseEntry = house:getExitPosition()
			
			-- RANGE 17 SQM: Verifica se o jogador esta perto da entrada (em qualquer andar)
			local distanceX = math.abs(playerPos.x - houseEntry.x)
			local distanceY = math.abs(playerPos.y - houseEntry.y)
			local distanceZ = math.abs(playerPos.z - houseEntry.z)
			
			-- Verifica distancia horizontal (X/Y) e permite ate 2 andares de diferenca
			if distanceX <= 17 and distanceY <= 17 and distanceZ <= 2 then
				-- Verifica se o jogador esta em algum tile da casa (em qualquer andar)
				if playerIsInHouseRange(player, house) then
					-- Jogador esta dentro ou proximo da casa em algum andar
					highlightHouseBordersAtPlayerZ(player, house, playerPos)
					
					-- Mostra efeito especial na entrada apenas se estiver no mesmo andar
					if playerPos.z == houseEntry.z then
						houseEntry:sendMagicEffect(CONST_ME_MAGIC_GREEN)
					end
				end
			end
		end
	end
end

-- Verifica se o jogador esta em algum andar da casa
function playerIsInHouseRange(player, house)
	local playerPos = player:getPosition()
	local tiles = house:getTiles()
	
	-- Verifica se existe algum tile da casa no andar do jogador
	for _, tile in pairs(tiles) do
		local tilePos = tile:getPosition()
		if tilePos.z == playerPos.z then
			return true
		end
	end
	
	return false
end

-- Destaca as bordas da casa no andar ATUAL do jogador
function highlightHouseBordersAtPlayerZ(player, house, playerPos)
	local tiles = house:getTiles()
	local playerZ = playerPos.z
	
	-- Encontra os limites da casa APENAS no andar do jogador
	local minX, maxX = 99999, -99999
	local minY, maxY = 99999, -99999
	local hasTilesAtThisZ = false
	
	-- Primeiro passo: calcular os limites da casa no andar atual
	for _, tile in pairs(tiles) do
		local tilePos = tile:getPosition()
		if tilePos.z == playerZ then
			hasTilesAtThisZ = true
			if tilePos.x < minX then minX = tilePos.x end
			if tilePos.x > maxX then maxX = tilePos.x end
			if tilePos.y < minY then minY = tilePos.y end
			if tilePos.y > maxY then maxY = tilePos.y end
		end
	end
	
	-- Se nao ha tiles da casa neste andar, nao mostra nada
	if not hasTilesAtThisZ then
		return
	end
	
	-- Segundo passo: aplicar efeitos apenas nas bordas no andar do jogador
	local effectCount = 0
	local maxEffects = 50
	
	for _, tile in pairs(tiles) do
		if effectCount >= maxEffects then break end
		
		local tilePos = tile:getPosition()
		
		-- So processa tiles no andar do jogador
		if tilePos.z == playerZ then
			local distToPlayerX = math.abs(playerPos.x - tilePos.x)
			local distToPlayerY = math.abs(playerPos.y - tilePos.y)
			
			-- So mostra efeitos em tiles proximos ao jogador (campo de visao)
			if distToPlayerX <= 7 and distToPlayerY <= 5 then
				-- Verifica se esta na borda
				local isBorder = (tilePos.x == minX or tilePos.x == maxX or 
				                  tilePos.y == minY or tilePos.y == maxY)
				
				if isBorder then
					tilePos:sendMagicEffect(CONST_ME_HOLYAREA)
					effectCount = effectCount + 1
				end
			end
		end
	end
end

terrenoHighlighter:interval(1000) -- Verifica a cada 1 segundo
terrenoHighlighter:register()

-- CreatureEvent para limpar dados quando o jogador desloga
local logoutCleanup = CreatureEvent("BuscarTerrenoLogout")

function logoutCleanup.onLogout(player)
	local guid = player:getGuid()
	if BuscarTerrenoData[guid] then
		BuscarTerrenoData[guid] = nil
	end
	return true
end

logoutCleanup:register()
