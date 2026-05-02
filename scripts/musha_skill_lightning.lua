local M = {}

local function GetWorld(env)
	return env.GetWorld ~= nil and env.GetWorld() or env.TheWorld
end

local function SpawnAt(env, prefab, target, scale)
	local fx = env.SpawnPrefab(prefab)
	if fx ~= nil and target ~= nil then
		if scale ~= nil then
			fx.Transform:SetScale(scale, scale, scale)
		end
		fx.Transform:SetPosition(target:GetPosition():Get())
	end
	return fx
end

local function SpawnSpinFx(env, inst, target, play_sound)
	local shocking = env.SpawnPrefab("musha_spin_fx")
	if shocking ~= nil and target ~= nil then
		shocking.Transform:SetPosition(target:GetPosition():Get())
		local follower = shocking.entity:AddFollower()
		if target.components.combat ~= nil then
			if play_sound then
				inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
			end
			follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0.5)
		end
	end
end

local function SpawnSelfSpinFx(env, inst)
	local shocking = env.SpawnPrefab("musha_spin_fx")
	if shocking ~= nil then
		shocking.Transform:SetPosition(inst:GetPosition():Get())
		local follower = shocking.entity:AddFollower()
		follower:FollowSymbol(inst.GUID, inst.components.combat.hiteffectsymbol, 0, 0, 0.5)
	end
end

local function ClearShadowVisual(inst)
	if inst.wormlight == nil then
		inst.AnimState:SetBloomEffectHandle("")
	end
	if inst.in_shadow then
		inst.components.colourtweener:StartTween({ 1, 1, 1, 1 }, 0)
		inst.in_shadow = false
	end
end

local function ClearValkyrieLightning(inst, env, play_fx, refund)
	inst.components.combat:SetRange(2)
	inst:RemoveEventCallback("onhitother", M.OnHitLightning)
	ClearShadowVisual(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
	if play_fx then
		env.SpawnPrefab("sparks").Transform:SetPosition(inst:GetPosition():Get())
	end
	inst.switch = false
	inst.active_valkyrie = false
	if refund and inst.lightning_spell_cost then
		env.SkillDefs.RestoreMana(inst, "valkyrie_lightning_refund")
	end
	inst.lightning_spell_cost = false
end

local function ApplyDelayedSlow(env, inst, target, direct_damage, shocked_damage, dot_damage)
	target:DoTaskInTime(0.3, function(target)
		if target == nil or not target:IsValid() or target.components.health == nil or target.components.health:IsDead() then
			return
		end

		SpawnAt(env, "shock_fx", target)
		SpawnAt(env, "lightning2", target)
		target:DoTaskInTime(0.4, function(target)
			if target ~= nil and target:IsValid() then
				SpawnAt(env, "shock_fx", target)
				SpawnAt(env, "groundpoundring_fx", target, 0.3)
			end
		end)

		target.slow = true
		if not target:HasTag("slow") then
			target:AddTag("slow")
		end
		target.burn = false
		target.bloom = false
		target:RemoveTag("burn")
		if not target:HasTag("lightninggoat") then
			target.AnimState:SetBloomEffectHandle("")
			target.bloom = false
		end

		if not target:HasTag("slow") then
			return
		end

		SpawnSpinFx(env, inst, target, false)
		if not target.shocked then
			target.components.health:DoDelta(direct_damage)
		else
			SpawnAt(env, "explode_small", target)
			target.components.health:DoDelta(shocked_damage)
			target.shocked = false
		end

		local debuff = SpawnAt(env, "debuff_short", target)
		if debuff ~= nil and target:HasTag("slow") then
			local follower = debuff.entity:AddFollower()
			if not target:HasTag("cavedweller") and target.components.combat ~= nil then
				follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, -50, 0.5)
			else
				follower:FollowSymbol(target.GUID, "body", 0, -50, 0.5)
			end
			GetWorld(env):DoPeriodicTask(2, function()
				if target:IsValid() and target:HasTag("slow") and not target.components.health:IsDead() then
					target.components.health:DoDelta(dot_damage)
				end
			end)
		end

		GetWorld(env):DoTaskInTime(15, function()
			if target:IsValid() and target.components.locomotor ~= nil then
				target.components.locomotor.groundspeedmultiplier = 1
				target.slow = false
				target:RemoveTag("slow")
				if debuff ~= nil and debuff:IsValid() then
					debuff:Remove()
				end
			end
		end)
	end)
end

local function IsLightningTarget(inst, target)
	return target ~= nil
		and target:IsValid()
		and target.entity:IsVisible()
		and target.components.health ~= nil
		and not target.components.health:IsDead()
		and not target.ghost_spark
		and not (target:HasTag("berrythief") or target:HasTag("bird") or target:HasTag("butterfly"))
		and not target:HasTag("groundspike")
		and not target:HasTag("player")
		and not target:HasTag("stalkerminion")
		and not target:HasTag("structure")
		and target.components.combat ~= nil
		and (target.components.combat.target == inst
			or target:HasTag("monster")
			or target:HasTag("burn")
			or target:HasTag("werepig")
			or target:HasTag("frog"))
end

local function StopAndHitTarget(target)
	if target.components.locomotor ~= nil and not target:HasTag("ghost") then
		target.components.locomotor:StopMoving()
		if target.sg ~= nil then
			if target:HasTag("spider") and not target:HasTag("spiderqueen") then
				target.sg:GoToState("hit_stunlock")
			else
				target.sg:GoToState("hit")
			end
		end
	end
end

local function SuggestTarget(inst, target)
	if target.components.combat ~= nil and not target:HasTag("companion") then
		target.components.combat:SuggestTarget(inst)
	end
end

function M.OnHitLightning(inst, data)
	local other = data ~= nil and data.target or nil
	if other == nil
		or other:HasTag("smashable")
		or other:HasTag("shadowminion")
		or other:HasTag("alignwall") then
		return
	end

	inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close")
	inst.lightning_spell_cost = false
	local lightning = other.components.health ~= nil and M.env.SkillDefs.GetLightningLevel(inst.level) or nil
	if lightning ~= nil then
		if inst.loud_1 or inst.loud_2 or inst.loud_3 then
			SpawnAt(M.env, "lightning", other)
		end
		SpawnAt(M.env, "lightning2", other)
		SpawnAt(M.env, "shock_fx", other)
		SpawnAt(M.env, "firering_fx", other, 0.6)
		other.components.health:DoDelta(-lightning.damage)
		SpawnSpinFx(M.env, inst, other, true)
		inst.components.combat:SetRange(2)
		other.burn = false
		ClearShadowVisual(inst)
		inst.switch = false
		inst:RemoveEventCallback("onhitother", M.OnHitLightning)

		if inst.frost and other.components.freezable ~= nil then
			other.components.freezable:AddColdness(lightning.frost)
			other.components.health:DoDelta(-lightning.frost_damage)
		elseif inst.fire and other.components.burnable ~= nil then
			other.components.burnable:Ignite()
			other.components.health:DoDelta(-lightning.fire_damage)
		end
	end

	if other:HasTag("burn") then
		ApplyDelayedSlow(M.env, inst, other, -25, -50, -8)
	end

	if other.components.burnable ~= nil and other.components.burnable:IsBurning() then
		other.components.burnable:Extinguish()
	end

	local weapon = inst.components.inventory:GetEquippedItem(M.env.EQUIPSLOTS.HANDS)
	if weapon ~= nil and weapon.components.weapon ~= nil and weapon:HasTag("musha_items") then
		weapon.components.weapon.stimuli = nil
	end

	if inst.switch and inst.frosthammer2 then
		M.env.MushaAnim.ApplyFrostHammerSymbol(inst, true)
	elseif not inst.switch and inst.frosthammer2 then
		M.env.MushaAnim.ApplyFrostHammerSymbol(inst, false)
	end
end

local function BerserkLightning(inst, env)
	inst.components.talker:Say(env.STRINGS.MUSHA_TALK_GRRR)
	SpawnAt(env, "stalker_shield_musha", inst, 0.5)
	SpawnSelfSpinFx(env, inst)

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = env.TheSim:FindEntities(x, y, z, 10)
	for _, target in pairs(ents) do
		if env.SkillDefs.HasMana(inst, "berserk_chain_lightning", false)
			and IsLightningTarget(inst, target)
			and target.components.locomotor ~= nil then
			env.SkillDefs.SpendMana(inst, "berserk_chain_lightning")
			target.ghost_spark = true
			if inst.loud_1 or inst.loud_2 then
				SpawnAt(env, "lightning", target)
			else
				SpawnAt(env, "lightning2", target)
			end
			inst:DoTaskInTime(0.6, function()
				if target:IsValid() then
					SpawnAt(env, "lightning2", target)
				end
			end)

			if target:HasTag("burn") and target.components.combat ~= nil then
				SpawnAt(env, "explode_small", target)
				if not target:HasTag("slow") then
					target:AddTag("slow")
				end

				if target:HasTag("slow") then
					if not target.shocked then
						target.components.health:DoDelta(-30)
					else
						SpawnAt(env, "explode_small", target)
						target.components.health:DoDelta(-45)
						SpawnSpinFx(env, inst, target, false)
						target.shocked = false
					end

					local debuff = SpawnAt(env, "debuff_short", target)
					if debuff ~= nil and target:HasTag("slow") then
						local follower = debuff.entity:AddFollower()
						if not target:HasTag("cavedweller") then
							follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, -50, 0.5)
						else
							follower:FollowSymbol(target.GUID, "body", 0, -50, 0.5)
						end
						GetWorld(env):DoPeriodicTask(2, function()
							if target:IsValid() and target:HasTag("slow") and not target.components.health:IsDead() then
								target.components.health:DoDelta(-2)
							end
						end)
					end
					GetWorld(env):DoTaskInTime(15, function()
						if target:IsValid() and target.components.locomotor ~= nil then
							target.components.locomotor.groundspeedmultiplier = 1
							target.slow = false
							target:RemoveTag("slow")
							if debuff ~= nil and debuff:IsValid() then
								debuff:Remove()
							end
						end
					end)
				end
			else
				target.components.health:DoDelta(-25)
			end

			StopAndHitTarget(target)
			SuggestTarget(inst, target)
			target:DoTaskInTime(3, function(target)
				if target:IsValid() then
					target.ghost_spark = false
				end
			end)
		end
	end
end

local function GhostLightning(inst, env)
	inst.components.talker:Say(env.STRINGS.MUSHA_TALK_GHOST_REVENGE)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = env.TheSim:FindEntities(x, y, z, 10)
	for _, target in pairs(ents) do
		if IsLightningTarget(inst, target)
			and not (inst.components.rider ~= nil and inst.components.rider:IsRiding())
			and not inst.sg:HasStateTag("moving")
			and not inst.sg:HasStateTag("attack") then
			target.ghost_spark = true
			SpawnAt(env, "lightning2", target)
			if target.ghost_spark then
				SpawnSpinFx(env, inst, target, true)
			end
			target.components.health:DoDelta(-10)
			if target.sg ~= nil then
				if target:HasTag("spider") and not target:HasTag("spiderqueen") then
					target.sg:GoToState("hit_stunlock")
				elseif target:HasTag("hound") then
					target.sg:GoToState("hit")
				end
			end
			target:DoTaskInTime(3, function(target)
				if target:IsValid() then
					target.ghost_spark = false
				end
			end)
		end
	end
end

local function SyncYamcheLightning(inst, env)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = env.TheSim:FindEntities(x, y, z, 40, { "yamcheb" })
	for _, yamche in pairs(ents) do
		if inst.components.leader:IsFollower(yamche) and not inst.switch then
			yamche.yamche_lightning = false
		elseif inst.components.leader:IsFollower(yamche) and inst.switch then
			yamche.yamche_lightning = true
		end
	end
end

local function RefreshWeaponStimuli(inst, env)
	local weapon = inst.components.inventory:GetEquippedItem(env.EQUIPSLOTS.HANDS)
	if inst.switch and weapon ~= nil and weapon.components.weapon ~= nil then
		weapon.components.weapon.stimuli = "electric"
	elseif not inst.switch and weapon ~= nil and weapon.components.weapon ~= nil and not weapon:HasTag("electric_weapon") then
		weapon.components.weapon.stimuli = nil
	end
end

function M.LightningAction(inst)
	local env = M.env
	inst.writing = false
	local started_valkyrie_this_call = false

	if not inst.writing and env.IsMushaSleeping(inst) and not inst:HasTag("playerghost") then
		inst.components.talker:Say(env.STRINGS.MUSHA_TALK_NEED_SLEEPY)
		inst.components.combat:SetRange(2)
		inst:RemoveEventCallback("onhitother", M.OnHitLightning)
		inst.switch = false
		inst.active_valkyrie = false
		inst.valkyrie_turn = false
		return
	end

	if inst.sneaka then
		if not inst.poison_sneaka then
			if inst.components.sanity.current > 10 then
				inst.components.talker:Say(env.STRINGS.MUSHA_TALK_READY_POISON)
				inst.components.sanity:DoDelta(-25)
				inst.poison_sneaka = true
				local poison_sneaka = env.SpawnPrefab("shadowbomb_r")
				if poison_sneaka ~= nil then
					poison_sneaka.entity:SetParent(inst.entity)
					poison_sneaka.Follower:FollowSymbol(inst.GUID, "headbase", -5, -225, 0.5)
				end
			elseif inst.components.sanity.current <= 25 then
				inst.components.talker:Say(env.STRINGS.MUSHA_TALK_NEED_SANITY)
			end
		else
			inst.components.talker:Say(env.STRINGS.MUSHA_TALK_CANCEL_POISON)
			inst.poison_sneaka = false
			inst.components.sanity:DoDelta(25)
		end
	elseif not inst.writing and inst.berserk then
		BerserkLightning(inst, env)
	elseif not inst.writing and not inst.berserk then
		if inst.components.stamina_sleep.current >= 20
			and inst.components.sanity.current >= 0
			and not inst.components.health:IsDead()
			and not inst.active_valkyrie
			and not inst.switch
			and inst.valkyrie_on then
			inst.active_valkyrie = true
			inst.lightning_spell_cost = false
			started_valkyrie_this_call = true
		elseif (inst.components.stamina_sleep.current < 20 or inst.components.sanity.current <= 0)
			and not inst.active_valkyrie
			and inst.valkyrie_on then
			inst.components.talker:Say(env.STRINGS.MUSHA_TALK_GRRR)
			if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
				inst.sg:GoToState("repelled")
			else
				inst.sg:GoToState("mindcontrolled_pst")
			end
			ClearValkyrieLightning(inst, env, false, false)
		elseif inst.components.sanity.current <= 0 and inst.active_valkyrie and inst.valkyrie_on then
			inst.components.talker:Say(env.STRINGS.MUSHA_TALK_NEED_SANITY)
			if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
				inst.sg:GoToState("repelled")
			else
				inst.sg:GoToState("mindcontrolled_pst")
			end
			ClearValkyrieLightning(inst, env, true, false)
		end

		if inst.components.stamina_sleep.current >= 20
			and not inst.switch
			and inst.components.sanity.current > 0
			and not inst.components.health:IsDead()
			and not inst:HasTag("playerghost")
			and not (inst.vl1 or inst.vl2 or inst.vl3 or inst.vl4 or inst.vl5 or inst.vl6 or inst.vl7 or inst.vl8)
			and inst.valkyrie_on
			and env.SkillDefs.HasMana(inst, "valkyrie_lightning_start") then
			env.SkillDefs.SpendMana(inst, "valkyrie_lightning_start")
			inst.lightning_spell_cost = true
			inst.components.combat:SetRange(10, 12)
			inst:ListenForEvent("onhitother", M.OnHitLightning)
			inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
			env.SpawnPrefab("sparks").Transform:SetPosition(inst:GetPosition():Get())
			SpawnAt(env, "groundpoundring_fx", inst, 0.3)
			if not inst.sneak_pang then
				inst:DoTaskInTime(2, function(inst)
					if inst.switch then
						inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
					end
				end)
			end
			inst.switch = true
			SpawnSelfSpinFx(env, inst)
		elseif not started_valkyrie_this_call
			and not inst.switch
			and inst.active_valkyrie
			and not inst.components.health:IsDead()
			and not (inst.vl1 or inst.vl2 or inst.vl3 or inst.vl4 or inst.vl5 or inst.vl6 or inst.vl7 or inst.vl8)
			and inst.valkyrie_on then
			ClearValkyrieLightning(inst, env, true, false)
		elseif not inst.switch
			and not inst.components.health:IsDead()
			and (inst.vl1 or inst.vl2 or inst.vl3 or inst.vl4 or inst.vl5 or inst.vl6 or inst.vl7 or inst.vl8)
			and inst.valkyrie_on then
			ClearValkyrieLightning(inst, env, true, true)
		elseif inst.switch and not inst.components.health:IsDead() and inst.valkyrie_on then
			ClearValkyrieLightning(inst, env, true, true)
		elseif not inst.switch
			and inst.components.sanity.current <= 0
			and not inst.components.health:IsDead()
			and not inst:HasTag("playerghost")
			and inst.valkyrie_on then
			inst.components.talker:Say(env.STRINGS.MUSHA_TALK_NEED_SANITY)
		elseif inst:HasTag("playerghost") then
			GhostLightning(inst, env)
		end

		if not inst.valkyrie_on and not inst:HasTag("playerghost") then
			inst.components.talker:Say(env.STRINGS.MUSHA_TALK_NEED_EXP.."\n[REQUIRE]: level 3")
		end

		SyncYamcheLightning(inst, env)
		RefreshWeaponStimuli(inst, env)
	end

	if inst.switch and inst.frosthammer2 then
		env.MushaAnim.ApplyFrostHammerSymbol(inst, true)
	elseif not inst.switch and inst.frosthammer2 then
		env.MushaAnim.ApplyFrostHammerSymbol(inst, false)
	end
end

function M.Register(env)
	M.env = env
	env.AddModRPCHandler("musha", "Lightning_a", M.LightningAction)
end

return M
