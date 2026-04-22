local hirelingSkill = TalkAction("/hirelingskill")

function hirelingSkill.onSay(player, words, param)
	if param == "" then
		player:sendCancelMessage("Command params required: /hirelingskill <playername>, [add|remove|check], [skillname]")
		player:sendCancelMessage("Skills: banker, cooking, steward, trader, supertrader")
		return true
	end

	local params = param:split(",")
	if #params < 3 then
		player:sendCancelMessage("Usage: /hirelingskill <playername>, [add|remove|check], [skillname]")
		return true
	end

	local targetName = params[1]:trim()
	local action = params[2]:trim():lower()
	local skillName = params[3]:trim():lower()

	local target = Player(targetName)
	if not target then
		player:sendCancelMessage("Player '" .. targetName .. "' not found.")
		return true
	end

	-- Validate skill name
	local validSkills = {
		["banker"] = true,
		["cooking"] = true,
		["cooker"] = true,
		["steward"] = true,
		["trader"] = true,
		["supertrader"] = true,
		["super trader"] = true
	}

	if not validSkills[skillName] then
		player:sendCancelMessage("Invalid skill name. Valid skills: banker, cooking, steward, trader, supertrader")
		return true
	end

	-- Normalize skill names
	if skillName == "cooker" then skillName = "cooking" end
	if skillName == "super trader" then skillName = "supertrader" end

	local skillScoped = target:kv():scoped("hireling-skills")

	if action == "check" then
		local hasSkill = skillScoped:get(skillName) or false
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Player " .. targetName .. " has skill '" .. skillName .. "': " .. tostring(hasSkill))
		
		-- Show all skills
		local allSkills = { "banker", "cooking", "steward", "trader", "supertrader" }
		local skillList = {}
		for _, skill in ipairs(allSkills) do
			if skillScoped:get(skill) then
				table.insert(skillList, skill)
			end
		end
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "All unlocked skills: " .. (#skillList > 0 and table.concat(skillList, ", ") or "none"))
		
	elseif action == "add" then
		skillScoped:set(skillName, true)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Added hireling skill '" .. skillName .. "' to player " .. targetName)
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have unlocked the " .. skillName:gsub("^%l", string.upper) .. " hireling skill!")
		
	elseif action == "remove" then
		skillScoped:set(skillName, nil)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Removed hireling skill '" .. skillName .. "' from player " .. targetName)
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your " .. skillName:gsub("^%l", string.upper) .. " hireling skill has been removed.")
		
	else
		player:sendCancelMessage("Invalid action. Use: add, remove, or check")
	end

	return true
end

hirelingSkill:separator(",")
hirelingSkill:groupType("gamemaster")
hirelingSkill:register()
