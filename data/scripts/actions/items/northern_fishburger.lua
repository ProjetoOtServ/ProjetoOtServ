local fishingCondition = Condition(CONDITION_ATTRIBUTES)
fishingCondition:setParameter(CONDITION_PARAM_SUBID, JeanPierreFishing)
fishingCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, 1)
fishingCondition:setParameter(CONDITION_PARAM_TICKS, 60 * 60 * 1000)
fishingCondition:setParameter(CONDITION_PARAM_SKILL_FISHING, 50)
fishingCondition:setParameter(CONDITION_PARAM_FORCEUPDATE, true)

local northernFishburger = Action()

function northernFishburger.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("special-foods-cooldown") then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você precisa aguardar antes de tentar novamente.")
		return true
	end

	player:feed(3600)
	player:updateSupplyTracker(item)
	player:addCondition(fishingCondition)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você se sentiu inspirado em sua pesca.")
	player:say("Smack.", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:setExhaustion("special-foods-cooldown", 10 * 60)
	item:remove(1)
	return true
end

northernFishburger:id(9088)
northernFishburger:register()
