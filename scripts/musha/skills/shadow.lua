local M = {}

local SNEAK_LEVELS =
{
	{ min = 50, max = 429, label = "LV1", attack_label = "LV(1)", damage = 300, frozen_damage = 150 },
	{ min = 430, max = 1029, label = "LV2", attack_label = "LV(2)", damage = 400, frozen_damage = 200 },
	{ min = 1030, max = 1879, label = "LV3", attack_label = "LV(3)", damage = 500, frozen_damage = 250 },
	{ min = 1880, max = 3199, label = "LV4", attack_label = "LV(4)", damage = 600, frozen_damage = 300 },
	{ min = 3200, max = 6999, label = "LV5", attack_label = "LV(5)", damage = 700, frozen_damage = 350 },
	{ min = 7000, label = "LV6", attack_label = "LV(6)", damage = 800, frozen_damage = 400 },
}

local INVALID_SNEAK_TARGET_TAGS =
{
	"no_target",
	"structure",
	"wall",
	"pillarretracting",
	"tentacle_pillar",
	"arm",
	"shadow",
}

local function GetSneakLevel(level)
	for i = 1, #SNEAK_LEVELS do
		local def = SNEAK_LEVELS[i]
		if level >= def.min and (def.max == nil or level < def.max) then
			return def
		end
	end
end

local function HasAnyTag(inst, tags)
	for i = 1, #tags do
		if inst:HasTag(tags[i]) then
			return true
		end
	end
	return false
end

local function HasStateTag(inst, tag)
	return inst ~= nil and inst.sg ~= nil and inst.sg:HasStateTag(tag)
end

local function Say(inst, text)
	if inst.components.talker ~= nil then
		inst.components.talker:Say(text)
	end
end

local function SanityDelta(inst, value)
	if inst.components.sanity ~= nil then
		inst.components.sanity:DoDelta(value)
	end
end

local function ResetColour(inst)
	if inst.components.colourtweener ~= nil then
		inst.components.colourtweener:StartTween({ 1, 1, 1, 1 }, 0)
	end
end

local function SetShadowColour(inst)
	if inst.components.colourtweener ~= nil then
		inst.components.colourtweener:StartTween({ 0.1, 0.1, 0.1, 1 }, 0)
	end
end

local function SetPreparingShadowColour(inst)
	if inst.components.colourtweener ~= nil then
		inst.components.colourtweener:StartTween({ 0.3, 0.3, 0.3, 1 }, 0)
	end
end

local function SetCombatRange(inst, range)
	if inst.components.combat ~= nil then
		inst.components.combat:SetRange(range)
	end
end

local function SpawnAttachedFx(env, prefab, inst, scale, z)
	local fx = env.SpawnPrefab(prefab)
	if fx ~= nil then
		fx.entity:SetParent(inst.entity)
		if scale ~= nil then
			fx.Transform:SetScale(scale, scale, scale)
		end
		fx.Transform:SetPosition(0, 0, z or 0.5)
	end
	return fx
end

local function SpawnTargetFx(env, prefab, target, scale_x, scale_y, scale_z)
	local fx = env.SpawnPrefab(prefab)
	if fx ~= nil and target ~= nil then
		fx.Transform:SetPosition(target.Transform:GetWorldPosition())
		if scale_x ~= nil then
			fx.Transform:SetScale(scale_x, scale_y or scale_x, scale_z or scale_x)
		end
	end
	return fx
end

local function CanDamageTarget(target)
	return target ~= nil
		and target.components.health ~= nil
		and not target.components.health:IsDead()
end

local function DamageTarget(target, amount)
	if CanDamageTarget(target) then
		target.components.health:DoDelta(-amount)
	end
end

local function ClearEvents(inst)
	inst:RemoveEventCallback("onhitother", M.OnSneakAttack)
	inst:RemoveEventCallback("attacked", M.OnSneakDiscovered)
end

function M.ClearState(inst, reset_colour, keep_poison)
	if reset_colour then
		ResetColour(inst)
	end
	inst:RemoveTag("notarget")
	inst.sneak_pang = false
	inst.sneaka = false
	if not keep_poison then
		inst.poison_sneaka = false
	end
	inst.in_shadow = false
	ClearEvents(inst)
end

local function StopSneak(inst, reset_colour, keep_poison)
	M.ClearState(inst, reset_colour, keep_poison)
	SetCombatRange(inst, 2)
end

local function Unhide(inst, env, text, poison_refund)
	SanityDelta(inst, 50)
	Say(inst, text)
	if poison_refund and inst.poison_sneaka then
		SanityDelta(inst, 10)
	end
	StopSneak(inst, true)
end

local function SpawnPoisonSneakResult(inst, env, target)
	if not inst.poison_sneaka then
		return
	end

	inst.poison_sneaka = false
	if target.components.health ~= nil and not target.components.health:IsDead() and target.components.combat ~= nil then
		local shadowbomb = env.SpawnPrefab("shadowbomb")
		if shadowbomb ~= nil then
			shadowbomb.entity:SetParent(target.entity)
			local follower = shadowbomb.entity:AddFollower()
			if not target:HasTag("cavedweller") then
				follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, -200, 0.5)
			else
				follower:FollowSymbol(target.GUID, "body", 0, -200, 0.5)
			end
		end
	else
		local cloud = env.SpawnPrefab("sporecloud2")
		if cloud ~= nil then
			cloud.Transform:SetPosition(target:GetPosition():Get())
			cloud:FadeInImmediately()
		end
	end
end

local function FinishSneakAttack(inst, env, target, failed)
	if failed then
		SpawnTargetFx(env, "splash", target)
	else
		SpawnTargetFx(env, "statue_transition", target, 0.5, 4, 0.5)
		SpawnTargetFx(env, "explode_small", target)
	end
	StopSneak(inst, true, true)
end

local function IsInvalidSneakTarget(target)
	return HasAnyTag(target, INVALID_SNEAK_TARGET_TAGS) and target.components.locomotor ~= nil
end

local function IsAttackableSneakTarget(target)
	return not HasAnyTag(target, INVALID_SNEAK_TARGET_TAGS) and target.components.locomotor ~= nil
end

function M.ClearHostileTargets(inst)
	if not inst.sneaka then
		return
	end

	if inst.active_valkyrie or inst.switch then
		SetCombatRange(inst, 2)
		inst.switch = false
	end

	local env = M.env
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = env.TheSim:FindEntities(x, y, z, 12)
	for _, target in pairs(ents) do
		if target.components.health ~= nil
			and not target.components.health:IsDead()
			and target.components.combat ~= nil
			and target.components.combat.target == inst
			and not (target:HasTag("berrythief")
				or target:HasTag("prey")
				or target:HasTag("bird")
				or target:HasTag("butterfly")) then
			target.components.combat.target = nil
		end
	end
end

function M.OnSneakAttack(inst, data)
	local env = M.env
	local target = data ~= nil and data.target or nil
	if target == nil
		or target:HasTag("smashable")
		or target:HasTag("shadowminion")
		or target:HasTag("alignwall") then
		return
	end

	if not inst.sneaka and inst.sneak_pang then
		Unhide(inst, env, env.STRINGS.MUSHA_TALK_SNEAK_UNHIDE, true)
	elseif inst.sneaka and inst.sneak_pang and IsInvalidSneakTarget(target) then
		Unhide(inst, env, env.STRINGS.MUSHA_TALK_SNEAK_NO_TARGET, true)
	elseif inst.sneaka and inst.sneak_pang and IsAttackableSneakTarget(target) then
		local level = GetSneakLevel(inst.level)
		if level == nil then
			return
		end

		if not (HasStateTag(target, "attack") and HasStateTag(target, "shield") and HasStateTag(target, "moving"))
			and not HasStateTag(target, "frozen") then
			SanityDelta(inst, 50)
			ResetColour(inst)
			Say(inst, env.STRINGS.MUSHA_TALK_SNEAK_SUCCESS.."\n"..level.attack_label)
			DamageTarget(target, level.damage)
			inst.switch = false
			SetCombatRange(inst, 2)
			FinishSneakAttack(inst, env, target)
		elseif HasStateTag(target, "frozen") then
			SanityDelta(inst, 50)
			ResetColour(inst)
			Say(inst, env.STRINGS.MUSHA_TALK_SNEAK_SUCCESS.."\n"..env.STRINGS.MUSHA_TALK_SNEAK_FROZEN)
			DamageTarget(target, level.frozen_damage)
			FinishSneakAttack(inst, env, target)
		elseif (HasStateTag(target, "attack") or HasStateTag(target, "shield") or HasStateTag(target, "moving"))
			and not HasStateTag(target, "frozen") then
			ResetColour(inst)
			Say(inst, env.STRINGS.MUSHA_TALK_SNEAK_FAILED)
			FinishSneakAttack(inst, env, target, true)
		end

		SpawnPoisonSneakResult(inst, env, target)
	end
end

function M.OnSneakDiscovered(inst)
	local env = M.env
	if inst.sneak_pang then
		ResetColour(inst)
		M.ClearState(inst, false)
		SpawnAttachedFx(env, "statue_transition_2", inst, 1.2, 0.5)
		Say(inst, env.STRINGS.MUSHA_TALK_SNEAK_ATTACKED)
	end
end

local function FailSneak(inst, env, text)
	Say(inst, text)
	if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
		inst.sg:GoToState("repelled")
	else
		inst.sg:GoToState("mindcontrolled_pst")
	end
end

local function SaySneakLevel(inst, env, level)
	if level ~= nil then
		Say(inst, env.STRINGS.MUSHA_TALK_SNEAK_HIDE.."("..level.label..")")
	end
end

function M.HideIn(inst)
	local env = M.env
	inst.writing = false
	if inst.writing or inst.tiny_sleep or inst.sleep_on then
		return
	end

	if inst.level < 50 then
		FailSneak(inst, env, env.STRINGS.MUSHA_TALK_SNEAK_NEED_EXP)
		return
	end

	if not inst.sneak_pang
		and inst.components.sanity.current >= 50
		and inst.components.stamina_sleep.current >= 30 then
		local level = GetSneakLevel(inst.level)
		SaySneakLevel(inst, env, level)
		SanityDelta(inst, -50)
		inst.sneak_pang = true
		SetPreparingShadowColour(inst)
		SpawnAttachedFx(env, "statue_transition_2", inst, 1.2, 0.5)

		inst:DoTaskInTime(4, function(inst)
			if inst.sneak_pang then
				inst.sneaka = true
				Say(inst, env.STRINGS.MUSHA_TALK_SNEAK_SHADOW)
				local fx = env.SpawnPrefab("stalker_shield_musha")
				if fx ~= nil then
					fx.Transform:SetScale(0.5, 0.5, 0.5)
					fx.Transform:SetPosition(inst:GetPosition():Get())
				end
				if not inst:HasTag("notarget") then
					inst:AddTag("notarget")
				end
				env.SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
				SetShadowColour(inst)
				inst.in_shadow = true
				M.ClearHostileTargets(inst)
			end
		end)

		ClearEvents(inst)
		inst:ListenForEvent("onhitother", M.OnSneakAttack)
		inst:ListenForEvent("attacked", M.OnSneakDiscovered)
	elseif not inst.sneak_pang
		and inst.components.sanity.current < 50
		and inst.components.stamina_sleep.current >= 30 then
		FailSneak(inst, env, env.STRINGS.MUSHA_TALK_NEED_SANITY)
	elseif not inst.sneak_pang
		and inst.components.sanity.current > 50
		and inst.components.stamina_sleep.current < 30 then
		FailSneak(inst, env, env.STRINGS.MUSHA_TALK_NEED_SLEEPY)
	elseif not inst.sneak_pang
		and inst.components.sanity.current < 50
		and inst.components.stamina_sleep.current < 30 then
		FailSneak(inst, env, env.STRINGS.MUSHA_TALK_NEED_SLEEP)
	elseif inst.sneak_pang then
		Say(inst, env.STRINGS.MUSHA_TALK_SNEAK_UNHIDE)
		ResetColour(inst)
		SpawnAttachedFx(env, "statue_transition_2", inst, 1.2, 0.5)
		SanityDelta(inst, 50)
		StopSneak(inst, false)
	end
end

function M.Register(env)
	M.env = env
	env.AddModRPCHandler("musha", "shadows", M.HideIn)
end

return M
