local config = {
    aid = 65535,
    bossName = "Demon",
    bossSpawn = Position(29102, 32177, 9),

    -- item da parede/barreira que fecha a sala
    wallItemId = 1026,

    -- paredes que fecham
    closeWalls = {
        Position(29106, 32178, 9),
        Position(29106, 32179, 9),
    },

    -- chamas roxas físicas
    flameItemId = 31160,
    flamePositions = {
        Position(29085, 32174, 9),
        Position(29086, 32174, 9),
        Position(29087, 32174, 9),
        Position(29088, 32174, 9),
        Position(29089, 32174, 9),
        Position(29090, 32174, 9),
        Position(29091, 32174, 9),
        Position(29092, 32174, 9),
        Position(29096, 32174, 9),
        Position(29097, 32174, 9),
        Position(29098, 32174, 9),
        Position(29099, 32174, 9),
        Position(29100, 32174, 9),
        Position(29101, 32174, 9),
        Position(29102, 32174, 9),
        Position(29103, 32174, 9),

        Position(29085, 32181, 9),
        Position(29086, 32181, 9),
        Position(29087, 32181, 9),
        Position(29088, 32181, 9),
        Position(29089, 32181, 9),
        Position(29090, 32181, 9),
        Position(29091, 32181, 9),
        Position(29092, 32181, 9),
        Position(29096, 32181, 9),
        Position(29097, 32181, 9),
        Position(29098, 32181, 9),
        Position(29099, 32181, 9),
        Position(29100, 32181, 9),
        Position(29101, 32181, 9),
        Position(29102, 32181, 9),
        Position(29103, 32181, 9),
    },

    flameEffect = CONST_ME_PURPLEENERGY,

    -- drop garantido
    rewardItemId = 3555, -- Golden Boots

    -- fala ao morrer
    bossDeathMessage = "Eu estava fraco, acabei de lutar contra minha mulher para ela lavar a louça, e ela é tão grande quanto eu",

    -- teleport de saída
    teleportItemId = 1387,

    -- TROQUE esta posição pela saída real da hunt
    exitToPos = Position(29107, 32178, 9),

    -- tempo para remover o portal, em ms
    teleportDuration = 5 * 60 * 1000
}

local roomActive = false
local currentBossId = 0
local triggerPos = nil

local function samePos(a, b)
    return a and b and a.x == b.x and a.y == b.y and a.z == b.z
end

local function removeFlames()
    for _, pos in ipairs(config.flamePositions) do
        local tile = Tile(pos)
        if tile then
            local flame = tile:getItemById(config.flameItemId)
            if flame then
                flame:remove()
            end
        end
        pos:sendMagicEffect(CONST_ME_POFF)
    end
end

local function createFlames()
    for _, pos in ipairs(config.flamePositions) do
        local tile = Tile(pos)
        if tile and not tile:getItemById(config.flameItemId) then
            Game.createItem(config.flameItemId, 1, pos)
        end
        pos:sendMagicEffect(config.flameEffect)
    end
end

local function ignitePurpleFlames(times, delay)
    for i = 0, times - 1 do
        addEvent(createFlames, i * delay)
    end
end

local function closeRoom()
    for _, pos in ipairs(config.closeWalls) do
        local tile = Tile(pos)
        if tile and not tile:getItemById(config.wallItemId) then
            Game.createItem(config.wallItemId, 1, pos)
        end
        pos:sendMagicEffect(CONST_ME_MAGIC_RED)
    end
end

local function openRoom()
    for _, pos in ipairs(config.closeWalls) do
        local tile = Tile(pos)
        if tile then
            local wall = tile:getItemById(config.wallItemId)
            if wall then
                wall:remove()
            end
        end
        pos:sendMagicEffect(CONST_ME_POFF)
    end

    removeFlames()
end

local function removeExitTeleport()
    if not triggerPos then
        return
    end

    local tile = Tile(triggerPos)
    if not tile then
        return
    end

    local tp = tile:getItemById(config.teleportItemId)
    if tp then
        tp:remove()
        triggerPos:sendMagicEffect(CONST_ME_POFF)
    end
end

local function createExitTeleport()
    if not triggerPos then
        return
    end

    removeExitTeleport()

    local tp = Game.createItem(config.teleportItemId, 1, triggerPos)
    if tp and tp:isTeleport() then
        tp:setDestination(config.exitToPos)
        triggerPos:sendMagicEffect(CONST_ME_TELEPORT)
        addEvent(removeExitTeleport, config.teleportDuration)
    end
end

local bossDeath = CreatureEvent("purpleBossRoomDeath")

function bossDeath.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    if creature:getId() ~= currentBossId then
        return true
    end

    if config.bossDeathMessage and config.bossDeathMessage ~= "" then
        creature:say(config.bossDeathMessage, TALKTYPE_MONSTER_SAY)
    end

    if corpse then
        corpse:addItem(config.rewardItemId, 1)
    else
        Game.createItem(config.rewardItemId, 1, creature:getPosition())
    end

    roomActive = false
    currentBossId = 0

    openRoom()
    createExitTeleport()

    if killer and killer:isPlayer() then
        killer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "O boss morreu, a sala foi aberta e o portal de saída apareceu.")
    end
    return true
end

bossDeath:register()

local stepTrap = MoveEvent()

function stepTrap.onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player then
        return true
    end

    -- se o portal de saída estiver no mesmo sqm, não ativa a trap de novo
    local tile = Tile(position)
    if tile and tile:getItemById(config.teleportItemId) then
        return true
    end

    if roomActive then
        player:teleportTo(fromPosition)
        fromPosition:sendMagicEffect(CONST_ME_POFF)
        position:sendMagicEffect(CONST_ME_POFF)
        player:sendCancelMessage("A sala já está em uso.")
        return true
    end

    removeExitTeleport()

    roomActive = true
    triggerPos = Position(position.x, position.y, position.z)

    ignitePurpleFlames(3, 250)
    closeRoom()

    local boss = Game.createMonster(config.bossName, config.bossSpawn, true, true)
    if not boss then
        roomActive = false
        openRoom()
        player:sendCancelMessage("Não foi possível criar o boss.")
        return true
    end

    currentBossId = boss:getId()
    boss:registerEvent("purpleBossRoomDeath")

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "As chamas roxas se acendem e a sala se fecha!")
    return true
end

stepTrap:aid(config.aid)
stepTrap:register()