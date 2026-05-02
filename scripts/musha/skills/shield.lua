local M = {}

local function shield_go(inst, env)
	local SkillDefs = env.SkillDefs
	local STRINGS = env.STRINGS
	local SpawnPrefab = env.SpawnPrefab

	if inst.components.health == nil or inst.components.health:IsDead() or inst.activec0 then
		return
	end

	local shield = SkillDefs.GetActiveShieldLevel(inst.level)
	if shield == nil or not inst[shield.unlock_flag] then
		return
	end

	local fx = SpawnPrefab("forcefieldfxx")
	inst.on_sparkshield = true

	inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/raise")
	inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/pop")
	if fx ~= nil then
		fx.entity:SetParent(inst.entity)
		if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
			fx.Transform:SetScale(2, 2, 2)
		else
			fx.Transform:SetScale(0.8, 0.8, 0.8)
		end
		fx.Transform:SetPosition(0, 0.2, 0)
	end

	local fx_hitanim = function()
		if fx ~= nil and fx:IsValid() then
			fx.AnimState:PlayAnimation("hit")
			fx.AnimState:PushAnimation("idle_loop")
		end
	end

	if fx ~= nil then
		fx:ListenForEvent("blocked", fx_hitanim, inst)
	end

	inst.activec0 = true
	inst[shield.ready_flag] = true
	inst:DoTaskInTime(12, function()
		if fx ~= nil and fx:IsValid() then
			fx:RemoveEventCallback("blocked", fx_hitanim, inst)
		end

		if inst:IsValid() then
			if fx ~= nil and fx:IsValid() then
				if fx.kill_fx ~= nil then
					fx.kill_fx(fx)
				else
					fx:Remove()
				end
			end

			inst.components.talker:Say(STRINGS[shield.cooldown_string])
			inst.on_sparkshield = false

			inst:DoTaskInTime(shield.cooldown, function()
				if inst:IsValid() then
					inst.activec0 = false
					inst[shield.ready_flag] = false
					inst.casting = false
				end
			end)
		end
	end)
end

local function shield_ready(inst, env)
	local shield = env.SkillDefs.GetActiveShieldLevel(inst.level)
	if shield ~= nil and not inst.activec0 and not inst[shield.ready_flag] then
		inst.components.talker:Say(env.STRINGS.MUSHA_TALK_SHIELD_FULL)
		env.SpawnPrefab("sparks").Transform:SetPosition(inst:GetPosition():Get())
		inst[shield.ready_flag] = true
	end
end

local function on_shield_act(inst, env)
	local SkillDefs = env.SkillDefs
	local STRINGS = env.STRINGS
	local TheSim = env.TheSim
	local SpawnPrefab = env.SpawnPrefab

	inst.writing = env.IsNearWriteable(inst)
	if inst.writing then
		return
	end

	if inst:HasTag("playerghost") then
		inst.components.talker:Say(STRINGS.MUSHA_TALK_GHOST_OOOOH)
		return
	end

	if inst.components.health == nil or inst.components.health:IsDead() then
		return
	end

	if inst._musha_shield_ready_fn == nil then
		inst._musha_shield_ready_fn = function(player)
			shield_ready(player, env)
		end
		inst:ListenForEvent("hungerdelta", inst._musha_shield_ready_fn)
	end

	local shield = SkillDefs.GetActiveShieldLevel(inst.level)
	SkillDefs.ForEachActiveShieldLevel(function(def)
		inst[def.unlock_flag] = def == shield
	end)

	if inst.activec0 then
		SkillDefs.ForEachActiveShieldLevel(function(def)
			inst[def.unlock_flag] = false
		end)
		if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
			inst.sg:GoToState("repelled")
		else
			inst.sg:GoToState("mindcontrolled_pst")
		end
		if not SkillDefs.HasMana(inst, "active_shield") then
			inst.components.talker:Say(STRINGS.MUSHA_TALK_NEED_SPELLPOWER.."\n("..SkillDefs.GetManaCost("active_shield")..")")
		end
		return
	end

	if not SkillDefs.HasMana(inst, "active_shield") then
		inst.components.talker:Say(STRINGS.MUSHA_TALK_NEED_SPELLPOWER.."\n("..SkillDefs.GetManaCost("active_shield")..")")
		return
	end

	if not inst.casting
		and (inst.components.rider == nil or not inst.components.rider:IsRiding())
		and not inst.sg:HasStateTag("moving")
		and not inst.sg:HasStateTag("attack") then
		inst.casting = true
		inst.on_sparkshield = true
	end

	local shocking_self = SpawnPrefab("musha_spin_fx")
	if shocking_self then
		shocking_self.Transform:SetPosition(inst:GetPosition():Get())
		local follower = shocking_self.entity:AddFollower()
		follower:FollowSymbol(inst.GUID, inst.components.combat.hiteffectsymbol, 0, 0, 0.5)
	end

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 10)
	for _, v in pairs(ents) do
		if inst.components.sanity
			and v:IsValid()
			and v.entity:IsVisible()
			and v.components.health
			and not v.components.health:IsDead()
			and not (v:HasTag("berrythief") or v:HasTag("bird") or v:HasTag("butterfly"))
			and not v:HasTag("groundspike")
			and not v:HasTag("player")
			and not v:HasTag("companion")
			and not v:HasTag("stalkerminion")
			and not v:HasTag("structure")
			and v.components.combat ~= nil
			and (v.components.combat.target == inst or v:HasTag("monster") or v:HasTag("burn")) then
			SpawnPrefab("sparks").Transform:SetPosition(v:GetPosition():Get())
			local shocking = SpawnPrefab("musha_spin_fx")
			if shocking then
				shocking.Transform:SetPosition(v:GetPosition():Get())
				local follower = shocking.entity:AddFollower()
				follower:FollowSymbol(v.GUID, v.components.combat.hiteffectsymbol, 0, 0, 0.5)
			end

			if v.components.locomotor and not v:HasTag("ghost") then
				v.components.locomotor:StopMoving()
				if v:HasTag("spider") and not v:HasTag("spiderqueen") then
					v.sg:GoToState("hit_stunlock")
				else
					v.sg:GoToState("hit")
				end
			end
			v.components.health:DoDelta(-20)

			if v.components.combat and not v:HasTag("companion") then
				v.components.combat:SuggestTarget(inst)
			end
		end
	end

	shield_go(inst, env)
	SkillDefs.SpendMana(inst, "active_shield")
end

function M.Register(env)
	env.AddModRPCHandler("musha", "on_shield_act", function(inst)
		on_shield_act(inst, env)
	end)
end

return M
