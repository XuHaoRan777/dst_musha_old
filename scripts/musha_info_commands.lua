local M = {}

local LEVEL_INFO = {
	{ max = 4, display = 1, next_exp = 5 },
	{ max = 9, display = 2, next_exp = 10 },
	{ max = 29, display = 3, next_exp = 30 },
	{ max = 49, display = 4, next_exp = 50 },
	{ max = 79, display = 5, next_exp = 80 },
	{ max = 124, display = 6, next_exp = 125 },
	{ max = 199, display = 7, next_exp = 200 },
	{ max = 339, display = 8, next_exp = 340 },
	{ max = 429, display = 9, next_exp = 430 },
	{ max = 529, display = 10, next_exp = 530 },
	{ max = 639, display = 11, next_exp = 640 },
	{ max = 759, display = 12, next_exp = 760 },
	{ max = 889, display = 13, next_exp = 890 },
	{ max = 1029, display = 14, next_exp = 1030 },
	{ max = 1179, display = 15, next_exp = 1180 },
	{ max = 1339, display = 16, next_exp = 1340 },
	{ max = 1509, display = 17, next_exp = 1510 },
	{ max = 1689, display = 18, next_exp = 1690 },
	{ max = 1879, display = 19, next_exp = 1880 },
	{ max = 2079, display = 20, next_exp = 2080 },
	{ max = 2289, display = 21, next_exp = 2289 },
	{ max = 2499, display = 22, next_exp = 2500 },
	{ max = 2849, display = 23, next_exp = 2850 },
	{ max = 3199, display = 24, next_exp = 3200 },
	{ max = 3699, display = 25, next_exp = 3700 },
	{ max = 4199, display = 26, next_exp = 4200 },
	{ max = 4699, display = 27, next_exp = 4700 },
	{ max = 5499, display = 28, next_exp = 5500 },
	{ max = 6999, display = 29, next_exp = 7000 },
}

local SKILL_INFO = {
	{ max = 4, power = 0, shield = 1, shadow = 0, valkyrie = 0, berserk = 0, electra = 0, critic = 0, double = 0 },
	{ max = 9, power = 0, shield = 1, shadow = 0, valkyrie = 0, berserk = 0, electra = 1, critic = 0, double = 0 },
	{ max = 29, power = 1, shield = 1, shadow = 0, valkyrie = 1, berserk = 0, electra = 1, critic = 0, double = 0 },
	{ max = 49, power = 1, shield = 1, shadow = 0, valkyrie = 1, berserk = 0, electra = 1, critic = 1, double = 0 },
	{ max = 79, power = 1, shield = 1, shadow = 1, valkyrie = 2, berserk = 0, electra = 1, critic = 1, double = 0 },
	{ max = 124, power = 1, shield = 1, shadow = 1, valkyrie = 2, berserk = 0, electra = 2, critic = 1, double = 0 },
	{ max = 199, power = 1, shield = 1, shadow = 1, valkyrie = 2, berserk = 1, electra = 2, critic = 1, double = 0 },
	{ max = 339, power = 1, shield = 1, shadow = 1, valkyrie = 3, berserk = 1, electra = 2, critic = 1, double = 0 },
	{ max = 429, power = 1, shield = 1, shadow = 1, valkyrie = 4, berserk = 1, electra = 2, critic = 1, double = 0 },
	{ max = 529, power = 2, shield = 2, shadow = 2, valkyrie = 4, berserk = 1, electra = 3, critic = 1, double = 0 },
	{ max = 639, power = 2, shield = 2, shadow = 2, valkyrie = 4, berserk = 1, electra = 3, critic = 2, double = 0 },
	{ max = 759, power = 2, shield = 2, shadow = 2, valkyrie = 4, berserk = 1, electra = 3, critic = 3, double = 0 },
	{ max = 889, power = 2, shield = 2, shadow = 2, valkyrie = 5, berserk = 1, electra = 3, critic = 3, double = 0 },
	{ max = 1029, power = 2, shield = 2, shadow = 2, valkyrie = 6, berserk = 1, electra = 3, critic = 3, double = 0 },
	{ max = 1179, power = 2, shield = 2, shadow = 3, valkyrie = 6, berserk = 1, electra = 4, critic = 3, double = 0 },
	{ max = 1339, power = 2, shield = 2, shadow = 3, valkyrie = 6, berserk = 1, electra = 4, critic = 4, double = 0 },
	{ max = 1509, power = 2, shield = 2, shadow = 3, valkyrie = 7, berserk = 1, electra = 4, critic = 4, double = 0 },
	{ max = 1689, power = 2, shield = 2, shadow = 3, valkyrie = 8, berserk = 1, electra = 4, critic = 4, double = 0 },
	{ max = 1879, power = 2, shield = 2, shadow = 3, valkyrie = 8, berserk = 2, electra = 4, critic = 4, double = 0 },
	{ max = 2079, power = 3, shield = 3, shadow = 4, valkyrie = 8, berserk = 2, electra = 4, critic = 5, double = 0 },
	{ max = 2289, power = 3, shield = 3, shadow = 4, valkyrie = 8, berserk = 2, electra = 5, critic = 5, double = 0 },
	{ max = 2499, power = 3, shield = 3, shadow = 4, valkyrie = 9, berserk = 2, electra = 5, critic = 5, double = 0 },
	{ max = 2849, power = 3, shield = 3, shadow = 4, valkyrie = 10, berserk = 2, electra = 5, critic = 5, double = 0 },
	{ max = 3199, power = 3, shield = 3, shadow = 4, valkyrie = 10, berserk = 3, electra = 5, critic = 5, double = 0 },
	{ max = 3699, power = 3, shield = 3, shadow = 5, valkyrie = 10, berserk = 3, electra = 5, critic = 6, double = 0 },
	{ max = 4199, power = 3, shield = 3, shadow = 5, valkyrie = 11, berserk = 3, electra = 5, critic = 6, double = 0 },
	{ max = 4699, power = 3, shield = 3, shadow = 5, valkyrie = 11, berserk = 3, electra = 5, critic = 7, double = 0 },
	{ max = 5499, power = 3, shield = 3, shadow = 5, valkyrie = 12, berserk = 3, electra = 5, critic = 7, double = 0 },
	{ max = 6999, power = 3, shield = 3, shadow = 5, valkyrie = 13, berserk = 3, electra = 5, critic = 7, double = 0 },
}

local MAX_SKILL_INFO = { power = 4, shield = 4, shadow = 6, valkyrie = 14, berserk = 3, electra = 5, critic = 7, double = 1 }

local function Say(inst, text)
	if inst.components ~= nil and inst.components.talker ~= nil then
		inst.components.talker:Say(text)
	end
end

local function Percent(current, min, max)
	local range = math.floor(max - min)
	if range <= 0 then
		return "0%"
	end
	return tostring(math.floor((current - min) * 100 / range)) .. "%"
end

local function GetStatusText(inst)
	local stamina = inst.components ~= nil and inst.components.stamina_sleep ~= nil and inst.components.stamina_sleep.current or 0
	local fatigue = inst.components ~= nil and inst.components.fatigue_sleep ~= nil and inst.components.fatigue_sleep.current or 0

	return {
		sleep = Percent(stamina, 0, 100),
		sleepy = Percent(fatigue, 0, 100),
		music = Percent(inst.music or 0, 0, 100),
		treasure = Percent(inst.treasure or 0, 0, 100),
	}
end

local function MarkFollowerInfo(inst, tag, env)
	if inst.components == nil or inst.components.leader == nil then
		return
	end

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = env.TheSim:FindEntities(x, y, z, 25, { tag })
	for _, follower in pairs(ents) do
		if follower.components ~= nil
			and follower.components.follower ~= nil
			and follower.components.follower.leader ~= nil
			and inst.components.leader:IsFollower(follower) then
			follower.yamcheinfo = true
		end
	end
end

local function FindLevelInfo(level)
	for _, row in ipairs(LEVEL_INFO) do
		if level <= row.max then
			return row
		end
	end
	return nil
end

local function FormatLevelInfo(inst, strings, status)
	local level = math.min(inst.level or 0, 999997000)
	local row = FindLevelInfo(level)

	if row == nil then
		return strings.MUSHA_LEVEL_LEVEL .. "30 \n[MAX]\n Extra EXP " .. (level - 7000)
			.. "\n[" .. strings.MUSHA_LEVEL_SLEEP .. "]: " .. status.sleep
			.. "   [" .. strings.MUSHA_LEVEL_TIRED .. "]: " .. status.sleepy
			.. "\n[" .. strings.MUSHA_LEVEL_MUSIC .. "]: " .. status.music
			.. "   [" .. strings.MUSHA_LEVEL_SNIFF .. "]: " .. status.treasure
	end

	return strings.MUSHA_LEVEL_LEVEL .. tostring(row.display) .. " " .. strings.MUSHA_LEVEL_EXP .. ": " .. level .. "/ " .. row.next_exp
		.. "\n[" .. strings.MUSHA_LEVEL_SLEEP .. "]: " .. status.sleep
		.. "   [" .. strings.MUSHA_LEVEL_TIRED .. "]: " .. status.sleepy
		.. "\n[" .. strings.MUSHA_LEVEL_MUSIC .. "]: " .. status.music
		.. "   [" .. strings.MUSHA_LEVEL_SNIFF .. "]: " .. status.treasure
end

function M.Info(inst)
	local env = M.env
	local strings = env.STRINGS

	inst.writing = false
	if inst.writing then
		return
	end

	local status = GetStatusText(inst)
	inst.keep_check = false
	if not inst.keep_check then
		inst.keep_check = true

		Say(inst, "[" .. strings.MUSHA_LEVEL_NEXT_LEVEL_UP .. "] " .. strings.MUSHA_LEVEL_EXP .. ":" .. (inst.level or 0)
			.. "\n[" .. strings.MUSHA_LEVEL_SLEEP .. "]: " .. status.sleep
			.. "   [" .. strings.MUSHA_LEVEL_TIRED .. "]: " .. status.sleepy
			.. "\n[" .. strings.MUSHA_LEVEL_MUSIC .. "]: " .. status.music
			.. "   [" .. strings.MUSHA_LEVEL_SNIFF .. "]: " .. status.treasure)

		MarkFollowerInfo(inst, "yamche", env)
		MarkFollowerInfo(inst, "critter", env)
		Say(inst, FormatLevelInfo(inst, strings, status))
	elseif inst.keep_check then
		inst.keep_check = false
	end

	inst:DoTaskInTime(0.5, function()
		if inst.keep_check then
			inst.keep_check = false
		end
	end)
end

local function FindSkillInfo(level)
	for _, row in ipairs(SKILL_INFO) do
		if level <= row.max then
			return row
		end
	end
	return MAX_SKILL_INFO
end

local function FormatSkillInfo(strings, row)
	return strings.MUSHA_SKILL_ACTIVE
		.. "\n[*]" .. strings.MUSHA_SKILL_SLEEP .. "[1/1]-(T)"
		.. "\n[*]" .. strings.MUSHA_SKILL_POWER .. "[" .. row.power .. "/4]-(R)"
		.. "\n[*]" .. strings.MUSHA_SKILL_SHIELD .. "[" .. row.shield .. "/4]-(C)"
		.. "\n[*]" .. strings.MUSHA_SKILL_MUSIC .. "[1/1]-(X)"
		.. "\n[*]" .. strings.MUSHA_SKILL_SHADOW .. "[" .. row.shadow .. "/6]-(G)"
		.. "\n" .. strings.MUSHA_SKILL_PASSIVE
		.. "\n[*]" .. strings.MUSHA_SKILL_VALKYR .. "[" .. row.valkyrie .. "/14] "
		.. "\n[*]" .. strings.MUSHA_SKILL_BERSERK .. "[" .. row.berserk .. "/3] "
		.. "\n[*]" .. strings.MUSHA_SKILL_ELECTRA .. "[" .. row.electra .. "/5] "
		.. "\n[*]" .. strings.MUSHA_SKILL_CRITIC .. "[" .. row.critic .. "/7] "
		.. "\n[*]" .. strings.MUSHA_SKILL_DOUBLE .. "[" .. row.double .. "/1]"
end

function M.Info2(inst)
	local strings = M.env.STRINGS

	inst.writing = false
	if inst.writing then
		return
	end

	inst.keep_check = false
	if not inst.keep_check then
		inst.keep_check = true
		Say(inst, FormatSkillInfo(strings, FindSkillInfo(math.min(inst.level or 0, 999997000))))
	elseif inst.keep_check then
		inst.keep_check = false
	end

	inst:DoTaskInTime(0.5, function()
		if inst.keep_check then
			inst.keep_check = false
		end
	end)
end

function M.Register(env)
	M.env = env
	env.AddModRPCHandler("musha", "INFO", M.Info)
	env.AddModRPCHandler("musha", "INFO2", M.Info2)
end

return M
