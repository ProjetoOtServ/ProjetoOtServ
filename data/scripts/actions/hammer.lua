local function createWooden(position, removeId, createId, actionId)
	local woodPosition = Position(position)
	local woodenPlanks = Tile(woodPosition):getItemById(removeId)
	if woodenPlanks then
		woodenPlanks:remove()
		local woods = Game.createItem(createId, 1, position)
		if woods then
			woods:setActionId(actionId)
		end
	end
	return true
end

local settingTable = {
	[42501] = {
		position = Position(32647, 32216, 7),
		removeItem = 12183,
		createItem = 6474,
	},
	[42502] = {
		position = Position(32660, 32213, 7),
		removeItem = 12183,
		createItem = 6474,
	},
	[42503] = {
		position = Position(32644, 32183, 6),
		removeItem = 12185,
		createItem = 6473,
	},
	[42504] = {
		position = Position(32660, 32201, 7),
		removeItem = 12184,
		createItem = 6473,
	},
	[42505] = {
		position = Position(32652, 32200, 5),
		removeItem = 12185,
		createItem = 6473,
	},
}

-- Carregamento forçado da LIB se necessário (Canary fix)
if not CONSTRUCTION_SITE_ID then
    pcall(function() dofile("data/scripts/lib/construction_configs.lua") end)
end

local hammer = Action()

function hammer.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or type(target) ~= "userdata" or not target:isItem() then
		return false
	end

	if target:getId() == CONSTRUCTION_SITE_ID and target:getActionId() == CONSTRUCTION_AID then
		local p = target:getCustomAttribute("plankCurrent") or 0
		local n = target:getCustomAttribute("nailCurrent") or 0
		local originalGround = target:getCustomAttribute("originalGround")
		local pos = target:getPosition()
		
		if p > 0 then player:addItem(MATERIAL_PLANK, p) end
		if n > 0 then player:addItem(MATERIAL_NAIL, n) end
		
		target:remove()
		if originalGround then
			Game.createItem(originalGround, 1, pos)
		else
			local sTile = Tile(pos)
			if sTile and not sTile:getGround() then
				Game.createItem(103, 1, pos)
			end
		end
		
		pos:sendMagicEffect(CONST_ME_POFF)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Canteiro demolido. Materiais recuperados (100%).")
		player:sendExtendedOpcode(102, "CLOSE")
		return true
	end

	-- Caso 2: Demolindo Item Conclu\237do (50% de estorno)
	local recipe = CONSTRUCTION_RECIPES[target:getId()]
	if recipe then
		-- SEGURAN\199A: Validar posse da casa antes de demolir item conclu\237do
		local pos = target:getPosition()
		local tile = Tile(pos)
		local house = tile:getHouse()
		if not house or (house:getOwnerGuid() ~= player:getGuid() and player:getGroup():getId() < 3) then
			player:sendCancelMessage("Voc\234 n\227o tem permiss\227o para demolir estruturas nesta propriedade.")
			return true
		end

		local pRefund = math.floor(recipe.planks * 0.5)
		local nRefund = math.floor(recipe.nails * 0.5)
		local originalGround = target:getCustomAttribute("originalGround")
		
		if pRefund > 0 then player:addItem(MATERIAL_PLANK, pRefund) end
		if nRefund > 0 then player:addItem(MATERIAL_NAIL, nRefund) end
		
		-- Remove da persistência de memória de terreno
		PersistenceManager.removeItem(pos)
		
		-- Lógica Especial: Demolição Sincronizada de Escadas (Subida/Descida)
		local targetId = target:getId()
		if targetId == 433 or targetId == 1948 then
			local otherPos = Position(pos.x, pos.y, (targetId == 433 and pos.z + 1 or pos.z - 1))
			local otherTile = Tile(otherPos)
			if otherTile then
				local otherId = (targetId == 433 and 1948 or 433)
				local otherItem = otherTile:getItemById(otherId)
				if otherItem then
					local otherOriginalGround = otherItem:getCustomAttribute("originalGround")
					
					PersistenceManager.removeItem(otherPos)
					otherItem:remove()
					
					if otherOriginalGround then
						Game.createItem(otherOriginalGround, 1, otherPos)
					else
						-- Fallback: Se não houver registro, coloca Dirt (103) para evitar vácuo
						local oTile = Tile(otherPos)
						if oTile and not oTile:getGround() then
							Game.createItem(103, 1, otherPos)
						end
					end
					
					otherPos:sendMagicEffect(CONST_ME_POFF)
				end
			end
			
			-- Teleporta o jogador para baixo se ele estiver demolindo a escada em que está (Descida 433)
			if targetId == 433 then
				player:teleportTo(otherPos)
				otherPos:sendMagicEffect(CONST_ME_TELEPORT)
			end
		end

		target:remove()
		
		-- Restauração de Solo (com Fallback para Dirt 103)
		if originalGround then
			Game.createItem(originalGround, 1, pos)
		else
			local tTile = Tile(pos)
			if tTile and not tTile:getGround() then
				Game.createItem(103, 1, pos)
			end
		end

		pos:sendMagicEffect(CONST_ME_BLOCKHIT)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Estrutura demolida. Materiais estornados (50%).")
		return true
	end

	-- Adicionar demoli\231\227o de parede pronta depois, se necess\225rio
	-- ...

	-- Lay down the wood
	local targetActionId = target:getActionId()
	local position = Position(32571, 31508, 9)
	local tile = Tile(position)
	if targetActionId == 40021 and tile:getItemById(4597) then
		if player:getItemCount(5901) >= 3 and player:getItemCount(953) >= 3 then
			player:removeItem(5901, 3)
			player:removeItem(953, 3)
			player:say("KLING KLONG!", TALKTYPE_MONSTER_SAY)
			tile:getItemById(295):remove()
			tile:getItemById(291):remove()
			Game.createItem(5770, 1, position):setActionId(40021)
		end
		return true
		-- Lay down the rails
	elseif targetActionId == 40021 and tile:getItemById(5770) then
		if player:getItemCount(9114) >= 1 and player:getItemCount(9115) >= 2 and player:getItemCount(953) >= 3 then
			player:removeItem(9114, 1)
			player:removeItem(9115, 2)
			player:removeItem(953, 3)
			player:say("KLING KLONG!", TALKTYPE_MONSTER_SAY)
			Game.createItem(7122, 1, position)
		end
		return true
	end

	-- Rottin wood and maried quest
	if player:getStorageValue(Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.RottinStart) < 6 then
		local setting = settingTable[target:getActionId()]
		if setting then
			local woodenPosition = Position(setting.position)
			local woodenItem = Tile(woodenPosition):getItemById(settingTable.removeItem)
			if woodenItem then
				woodenItem:remove()
				Game.createItem(setting.createItem, 1, setting.position)
				addEvent(createWooden, 2 * 60 * 1000, setting.position, setting.removeItem, setting.createItem, setting)
			end

			player:setStorageValue(Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.RottinStart, player:getStorageValue(Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.RottinStart) + 1)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You fixed this broken wall.")
			return true
		end
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You already fixed many broken walls today.")
		return true
	end
	return false
end

hammer:id(3460)
hammer:register()
