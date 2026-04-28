local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local ACTIONS = GLOBAL.ACTIONS
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local SkillDefs = require("musha_skilldefs")
local PerformPreviewBufferedActionIfAvailable
local GetSpellpowerCurrent
local HasManaForAction
local AddActionOnce
local CanShowPowerAttack
local AddMushaSceneActions

local targets = {  "pigman", "bunnyman", "perd", "spider", "spider_warrior", "spiderqueen", "spider_spitter", "spider_dropper", "frog", "monkey", "bat", "hound", "firehound", "icehound", "warg", "tentacle", "walrus", "merm", "knight", "rook", "minotaur", "bishop", "krampus", "mossling", "tallbird", "deerclopse", "bearger", "dragonfly", "moose", "spat", "birchnutdrake", "deerclops", "toadstool", "beequeen", "klaus", "stalker", "antlion", "beefalo", 
"character", "eyeofterror", "twinofterror1", "twinofterror2", "stalker_forest", "stalker", "stalker_atrium", "ancient_herald", "leif", "leif_sparse", "lordfruitfly", "fruitfly", "pugalisk", "treeguard",
}



for k,v in pairs(targets) do
	AddPrefabPostInit(v,function(inst)
		if GLOBAL.TheWorld.ismastersim then
			inst:AddComponent("mypower_musha")
		end
	end)
end

-- Adds Actions ------------------------------
--[[ACTIONS.BOOK22.strfn = function(act)
	local targ = act.target or act.invobject

	if targ:HasTag("musha") then
		STRINGS.ACTIONS.BOOK22 = (STRINGS.MUSHA_MYPOWER_FROST_WIND)
		return 
	else
		STRINGS.ACTIONS.BOOK22 = (STRINGS.MUSHA_MYPOWER_FROST_WIND)
		return 
	end	
end]]

AddAction("BOOK22", STRINGS.MUSHA_MYPOWER_FROST_WIND, function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("musha") and act.target.components.mypower_musha ~= nil and SkillDefs.HasMana(act.doer, "frost_wind", false) then
		act.target.components.mypower_musha:Boook(act.doer)
		SkillDefs.SpendMana(act.doer, "frost_wind")
		return true
	else
		return false
	end
end)

AddAction("POWERATTACK", STRINGS.MUSHA_MYPOWER_SMITE, function(act)
	local doer = act.doer
	local target = act.target
	local weapon = doer ~= nil and doer.components ~= nil and doer.components.inventory ~= nil and doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
	if doer ~= nil and target ~= nil and target ~= doer and doer:HasTag("player") and doer.components.mypower_musha and weapon ~= nil and weapon.components.weapon ~= nil and (target:HasTag("character") or target:HasTag("pig") or target:HasTag("monster") or target:HasTag("animal")) then
		if SkillDefs.HasMana(doer, "power_attack_required", false) then
			doer.components.mypower_musha:Lightning(target)
			doer.components.combat:SetAreaDamage(3.5, 1)
			doer.components.combat:DoAttack(target)
		else
			doer.components.combat:SetAreaDamage(0, 0)
			doer.components.combat:DoAttack(target)
		end
			if not doer.berserk then
			doer.components.combat:SetAreaDamage(0, 0)
			end
		return true
	else
		if doer ~= nil and doer.components ~= nil and doer.components.combat ~= nil and not doer.berserk then
		doer.components.combat:SetAreaDamage(0, 0)
		end
		return false
	end
	
end)


-- Component mypower_musha ---------------------

function AddActionOnce(actions, action)
	for _, existing in ipairs(actions) do
		if existing == action then
			return
		end
	end
	table.insert(actions, action)
end

function CanShowPowerAttack(inst, doer)
	return inst ~= nil
		and doer ~= nil
		and inst ~= doer
		and doer:HasTag("musha")
		and (inst:HasTag("character") or inst:HasTag("pig") or inst:HasTag("monster") or inst:HasTag("animal"))
end

function AddMushaSceneActions(inst, doer, actions, right)
	if right then
		if CanShowPowerAttack(inst, doer) then
			AddActionOnce(actions, ACTIONS.POWERATTACK)
		end	
		if inst:HasTag("musha") and inst == doer then
			AddActionOnce(actions, ACTIONS.BOOK22)
		end
		
	end
end

AddComponentAction("SCENE", "mypower_musha", AddMushaSceneActions)
AddComponentAction("SCENE", "combat", AddMushaSceneActions)
AddComponentAction("SCENE", "health", AddMushaSceneActions)


-- Stategraph ----------------------------
local FRAMES = GLOBAL.FRAMES
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local SpawnPrefab = GLOBAL.SpawnPrefab

function PerformPreviewBufferedActionIfAvailable(inst)
    local buffaction = inst:GetBufferedAction()
    if buffaction ~= nil and buffaction.preview_cb ~= nil then
        inst:PerformPreviewBufferedAction()
        return true
    end
    return false
end

function GetSpellpowerCurrent(inst)
	if inst == nil then
		return nil
	end

	if inst.components ~= nil and inst.components.spellpower ~= nil then
		return inst.components.spellpower.current
	end

	if inst._currentspellpowerperc ~= nil and inst._spellpowermax ~= nil then
		return inst._currentspellpowerperc:value() * inst._spellpowermax:value()
	end
end

function HasManaForAction(inst, key, inclusive)
	local current = GetSpellpowerCurrent(inst)
	if current == nil then
		return false
	end

	local cost = SkillDefs.GetManaCost(key)
	if inclusive == false then
		return current > cost
	end
	return current >= cost
end

local book22 = GLOBAL.State(
		{
        name = "book22",
        tags = { "doing", "busy", "notalking" },

        onenter = function(inst)
		--[[if inst.components.playercontroller then
		inst.components.playercontroller:Enable(false)
		end]]
		if not SkillDefs.HasMana(inst, "frost_wind", false) then
			if inst.components.talker ~= nil then
				inst.components.talker:Say(STRINGS.MUSHA_TALK_NEED_SPELLPOWER)
			end
			inst:ClearBufferedAction()
			inst.sg:GoToState("idle")
			return
		end

		 inst.components.locomotor:Stop()

			if inst.components.health and not inst.components.health:IsDead() then	
				inst.active_skill = true
			end
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("book", true)
		
            inst.AnimState:Show("ARM_normal")
            inst.components.inventory:ReturnActiveActionItem(inst.bufferedaction ~= nil and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil)
		inst.sg:SetTimeout(3)   
   
		end,

        timeline =
        {
            TimeEvent(0, function(inst)
                local fxtoplay = inst.components.rider ~= nil and inst.components.rider:IsRiding() and "book_fx_mount" or "book_fx"
                local fx = SpawnPrefab(fxtoplay)
                fx.entity:SetParent(inst.entity)
                fx.Transform:SetPosition(0, 0.2, 0)
                inst.sg.statemem.book_fx = fx
            end),

            TimeEvent(28 * FRAMES, function(inst)
			local fx_1 = SpawnPrefab("stalker_shield_musha")
			fx_1.Transform:SetScale(0.5, 0.5, 0.5)
			fx_1.Transform:SetPosition(inst:GetPosition():Get())
                inst.SoundEmitter:PlaySound("dontstarve/common/use_book_light")
            end),

            TimeEvent(54 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/use_book_close")
				inst.sg:RemoveStateTag("busy")
            end),

            TimeEvent(58 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/book_spell")
                inst:PerformBufferedAction()
                inst.sg.statemem.book_fx = nil
            end),
        },

		 events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
	
		ontimeout = function(inst)
		inst.sg:RemoveStateTag("doing")
		inst.sg:RemoveStateTag("notalking")
		inst:ClearBufferedAction()
	
            if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
			end
        end,
	
        onexit = function(inst)
			--inst.components.playercontroller:Enable(true)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end
            if inst.sg.statemem.book_fx then
                inst.sg.statemem.book_fx:Remove()
                inst.sg.statemem.book_fx = nil
            end
			if inst.bufferedaction == inst.sg.statemem.action then
			inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
			
        end,
    }
	)

local book22_c = GLOBAL.State(
    {
        name = "book22_c",
        tags = { "doing", "busy", "notalking" },

        onenter = function(inst)
		--[[if inst.components.playercontroller then
		inst.components.playercontroller:Enable(false)
		end]]
		inst.components.locomotor:Stop()
		--if inst.replica.health ~= nil and not inst.replica.health:IsDead() then
			
		--end
		-------- --------
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("action_uniqueitem_lag", false)
	      --inst.AnimState:PushAnimation("book", false)
            PerformPreviewBufferedActionIfAvailable(inst)
            inst.sg:SetTimeout(2.5)   
			
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                local fxtoplay = inst.replica.rider ~= nil and inst.replica.rider:IsRiding() and "book_fx_mount" or "book_fx"
                local fx = SpawnPrefab(fxtoplay)
                fx.entity:SetParent(inst.entity)
                fx.Transform:SetPosition(0, 0.2, 0)
                inst.sg.statemem.book_fx = fx
            end),

            TimeEvent(28 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/use_book_light")
            end),

            TimeEvent(54 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/use_book_close")
				inst.sg:RemoveStateTag("busy")
            end),

            TimeEvent(58 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/book_spell")
                inst:PerformBufferedAction()
                inst.sg.statemem.book_fx = nil
            end),
        },
       events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
		
		onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,
		
		ontimeout = function(inst)
            inst:ClearBufferedAction()
            if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
            end
        end,

        onexit = function(inst)
			--inst.components.playercontroller:Enable(true)
            if inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end
            if inst.sg.statemem.book_fx then
                inst.sg.statemem.book_fx:Remove()
                inst.sg.statemem.book_fx = nil
            end
			if inst.bufferedaction == inst.sg.statemem.action then
			inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
        end,
    }
	)
	

	AddStategraphState("wilson", book22)
	AddStategraphState("wilson_client", book22_c)
	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BOOK22, "book22"))
	AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BOOK22, "book22_c"))
	
--attack
	

local Lightning = GLOBAL.State(
{ 
			name = "Lightning",
			tags = { "prehammer", "attack", "notalking", "abouttoattack", "autopredict", "doing", "busy" },

	
onenter = function(inst)

            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local weapon = inst.components.combat and inst.components.combat:GetWeapon()
            if target == nil or equip == nil or weapon == nil then
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                return
            end

			inst.f_attack = true
			--inst:DoTaskInTime(1.6, function(inst) inst.f_attack = false end )
			--shield --------

		-------- --------			
			local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
			if target ~= nil and target.components.locomotor ~= nil then
			target.components.locomotor:Stop()
			end
            inst.components.locomotor:Stop()
		
		local has_power_mana = SkillDefs.HasMana(inst, "power_attack_required", false)
		if weapon and not inst.components.rider:IsRiding() then

				if has_power_mana then
				inst.AnimState:PlayAnimation("pickaxe_pre")
				
				if inst.components.health ~= nil and not inst.components.health:IsDead() then	
					inst.active_skill = true
				if not inst.sneak_pang then		
			inst.components.colourtweener:StartTween({0.3,0.3,0.3,1}, 0)
				end
				end
				
				
		--[[if inst:HasTag("musha") and inst.components.health and not inst.components.health:IsDead() and not inst.light_shield then
		
			inst.components.health:SetAbsorptionAmount(1)
			inst.light_shield = true
		
		local fx = SpawnPrefab("forcefieldfxx")
        fx.entity:SetParent(inst.entity)
		if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
		fx.Transform:SetScale(2, 2, 2)
		else
		fx.Transform:SetScale(0.8, 0.8, 0.8)
		end
        fx.Transform:SetPosition(0, 0.2, 0)
        local fx_hitanim = function()
            fx.AnimState:PlayAnimation("hit")
            fx.AnimState:PushAnimation("idle_loop")
			end
        fx:ListenForEvent("blocked", fx_hitanim, inst)
			inst:DoTaskInTime( 3, function()
			inst.light_shield = false
			inst.f_attack = false
            fx:RemoveEventCallback("blocked", fx_hitanim, inst)
			inst.active_skill = false
			
	if not inst.on_sparkshield and inst.berserk and inst.berserk_armor_1 and not inst.music_armor then
	inst.components.health:SetAbsorptionAmount(0.15)
	elseif not inst.on_sparkshield and inst.berserk and inst.berserk_armor_2 and not inst.music_armor then
	inst.components.health:SetAbsorptionAmount(0.3)	
	elseif not inst.on_sparkshield and inst.berserk and inst.berserk_armor_3 and not inst.music_armor then
	inst.components.health:SetAbsorptionAmount(0.45)
	elseif not inst.on_sparkshield and inst.valkyrie and not (inst.valkyrie_armor_1 or inst.valkyrie_armor_2 or inst.valkyrie_armor_3 or inst.valkyrie_armor_4) and not inst.music_armor then
	inst.components.health:SetAbsorptionAmount(0.1)
	elseif not inst.on_sparkshield and inst.valkyrie and inst.valkyrie_armor_1 and not inst.music_armor then
	inst.components.health:SetAbsorptionAmount(0.1)
	elseif not inst.on_sparkshield and inst.valkyrie and inst.valkyrie_armor_2 and not inst.music_armor then
	inst.components.health:SetAbsorptionAmount(0.2)	
	elseif not inst.on_sparkshield and inst.valkyrie and inst.valkyrie_armor_3 and not inst.music_armor then
	inst.components.health:SetAbsorptionAmount(0.25)	
	elseif not inst.on_sparkshield and inst.valkyrie and inst.valkyrie_armor_4 and not inst.music_armor then
	inst.components.health:SetAbsorptionAmount(0.3)
	else
	inst.components.health:SetAbsorptionAmount(0)
	end
				
			inst.casting = false
            if inst:IsValid() then
            fx.kill_fx(fx) end
			end)
		end]]
				
				else
				inst.sg.statemem.normal_powerattack_fallback = true
				inst.AnimState:PlayAnimation("atk_pre")
				inst.AnimState:PushAnimation("atk", false)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
				end	
				
				cooldown = math.max(cooldown, 6 * FRAMES)
                    if has_power_mana then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_icestaff")
                    end
                    --inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
					
		elseif inst.components.rider:IsRiding() then
            local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
                if equip ~= nil and (equip.components.projectile ~= nil or equip:HasTag("rangedweapon")) then
                    inst.AnimState:PlayAnimation("player_atk_pre")
                    inst.AnimState:PushAnimation("player_atk", false)
                    inst.SoundEmitter:PlaySound(
                        (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                        (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                        "dontstarve/wilson/attack_weapon",
                        nil, nil, true
                    )
                    cooldown = math.max(cooldown, 13 * FRAMES)
                else
                    inst.AnimState:PlayAnimation("atk_pre")
                    inst.AnimState:PushAnimation("atk", false)
                    DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
                    cooldown = math.max(cooldown, 16 * FRAMES)
                end		
					
            else
				inst.sg.statemem.slow = true
                inst.AnimState:PlayAnimation("punch")
                --inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end
				inst.sg.statemem.cooldown = cooldown
				--inst.sg:SetTimeout(cooldown)
			    PerformPreviewBufferedActionIfAvailable(inst)
		end,
		timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
				if not inst.components.rider:IsRiding() then
                inst.sg:RemoveStateTag("prehammer")
				end
            end),
			TimeEvent(8 * FRAMES, function(inst)
				if inst.sg.statemem.normal_powerattack_fallback then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                    return
				end
                if inst.components.rider:IsRiding() then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
		},
					
		ontimeout = function(inst)
		if not inst.components.rider:IsRiding() then
		inst:ClearBufferedAction()
		inst.sg:RemoveStateTag("prehammer")
		elseif inst.components.rider:IsRiding() then
		inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
		end
        end,
		
        events =
        {
		
			EventHandler("equip", function(inst) 
			if inst.components.rider:IsRiding() then
			inst.sg:GoToState("idle") end 
			end),
			
            EventHandler("unequip", function(inst)  
			if not inst.components.rider:IsRiding() then
			inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_pst")
			inst.AnimState:PushAnimation("pickaxe_lag", false)
            inst.sg:GoToState("idle", true) 
			inst.f_attack = false
			end
			end),
			
			EventHandler("animqueueover", function(inst)
			if inst.components.rider:IsRiding() then
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
			end	
            end),
			
            EventHandler("animover", function(inst)
			if not inst.components.rider:IsRiding() then
                if inst.AnimState:AnimDone() then
					if inst.sg.statemem.normal_powerattack_fallback then
						inst.sg:GoToState("idle")
						return
					end
                    inst.sg:GoToState("attacking2")
					inst.sg:SetTimeout(inst.sg.statemem.cooldown or 0)
                end
			end	
            end),
		
        },
	
        onexit = function(inst)
		if inst.components.rider:IsRiding() then
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
		end	
		if inst.components.health ~= nil and not inst.components.health:IsDead() then	
			inst.active_skill = false
				if not inst.sneak_pang then		
			inst.components.colourtweener:StartTween({1,1,1,1}, 0)
				end
			end
        end,
    	
    })
	
local powerup2 = GLOBAL.State(
{
        name = "powerup2",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
		inst.casting = true
	        if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
			
		if inst:HasTag("musha") then
					--shield --------
	local x,y,z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, 20, {"player"})
	for k,v in pairs(ents) do	
		if v and v.components.combat and (v.components.combat.target ~= inst) and v.components.health and not v.components.health:IsDead() then
		v.active_skill = true
	
		v.SoundEmitter:PlaySound("dontstarve/creatures/chester/raise")
		local fx = SpawnPrefab("forcefieldfxx")

        fx.entity:SetParent(v.entity)
		if v.components.rider ~= nil and v.components.rider:IsRiding() then
		fx.Transform:SetScale(2, 2, 2)
		else
		fx.Transform:SetScale(0.8, 0.8, 0.8)
		end
        fx.Transform:SetPosition(0, 0.2, 0)
        local fx_hitanim = function()
            fx.AnimState:PlayAnimation("hit")
            fx.AnimState:PushAnimation("idle_loop")
			end
        fx:ListenForEvent("blocked", fx_hitanim, v)
			v:DoTaskInTime( 5, function()
			
            fx:RemoveEventCallback("blocked", fx_hitanim, v)
			v.active_skill = false
			inst.casting = false
            if v:IsValid() then
            fx.kill_fx(fx) end
			end)
		end	
		end
		end
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)
            inst.components.locomotor:Stop()
		PerformPreviewBufferedActionIfAvailable(inst)
            --Spawn an effect on the player's location
            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local colour = staff ~= nil and staff.fxcolour or { 1, 1, 1 }

            inst.sg.statemem.stafffx = SpawnPrefab(inst.components.rider:IsRiding() and "staffcastfx_mount" or "staffcastfx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx.Transform:SetRotation(inst.Transform:GetRotation())
            inst.sg.statemem.stafffx:SetUp(colour)

            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)

            if staff ~= nil and staff.components.aoetargeting ~= nil and staff.components.aoetargeting.targetprefab ~= nil then
                local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil and buffaction.pos ~= nil then
                    inst.sg.statemem.targetfx = SpawnPrefab(staff.components.aoetargeting.targetprefab)
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx.Transform:SetPosition(buffaction.pos:Get())
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end

            inst.sg.statemem.castsound = staff ~= nil and staff.castsound or "dontstarve/wilson/use_gemstaff"
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent(53 * FRAMES, function(inst)
                if inst.sg.statemem.targetfx ~= nil then
                    if inst.sg.statemem.targetfx:IsValid() then
                        (inst.sg.statemem.targetfx.KillFX or inst.sg.statemem.targetfx.Remove)(inst.sg.statemem.targetfx)
                    end
                    inst.sg.statemem.targetfx = nil
                end
				inst.components.playercontroller:Enable(true)
                inst.sg.statemem.stafffx = nil --Can't be cancelled anymore
                inst.sg.statemem.stafflight = nil --Can't be cancelled anymore
                --V2C: NOTE! if we're teleporting ourself, we may be forced to exit state here!
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
					inst:ClearBufferedAction()
                end
            end),
        },

        onexit = function(inst)
		inst.casting = false
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                (inst.sg.statemem.targetfx.KillFX or inst.sg.statemem.targetfx.Remove)(inst.sg.statemem.targetfx)
            end
			
			inst:ClearBufferedAction()
			inst.sg.statemem.action = nil
        end,
    }
)
local powerup_c = GLOBAL.State(
{
        name = "powerup_c",
        tags = { "doing", "busy", "canrotate" },

		 onenter = function(inst)
		 inst.casting = true
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff_lag", false)
            PerformPreviewBufferedActionIfAvailable(inst)
            inst.sg:SetTimeout(3)
        end,

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
			inst.sg.statemem.action = nil
			inst.casting = false
        end,
		
       --[[ onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)
            inst.components.locomotor:Stop()
		PerformPreviewBufferedActionIfAvailable(inst)
         
            local staff = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local colour = staff ~= nil and staff.fxcolour or { 1, 1, 1 }
            local rider = inst.replica.rider

            inst.sg.statemem.stafffx = SpawnPrefab(rider ~= nil and rider:IsRiding() and "staffcastfx_mount" or "staffcastfx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx.Transform:SetRotation(inst.Transform:GetRotation())
           
            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            
            if staff ~= nil and staff.components.aoetargeting ~= nil and staff.components.aoetargeting.targetprefab ~= nil then
                local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil and buffaction.pos ~= nil then
                    inst.sg.statemem.targetfx = SpawnPrefab(staff.components.aoetargeting.targetprefab)
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx.Transform:SetPosition(buffaction.pos:Get())
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end

            inst.sg.statemem.castsound = staff ~= nil and staff.castsound or "dontstarve/wilson/use_gemstaff"
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent(53 * FRAMES, function(inst)
                if inst.sg.statemem.targetfx ~= nil then
                    if inst.sg.statemem.targetfx:IsValid() then
                        (inst.sg.statemem.targetfx.KillFX or inst.sg.statemem.targetfx.Remove)(inst.sg.statemem.targetfx)
                    end
                    inst.sg.statemem.targetfx = nil
                end
                inst.sg.statemem.stafffx = nil 
                inst.sg.statemem.stafflight = nil 
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
					inst:ClearBufferedAction()
                end
            end),
        },

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                (inst.sg.statemem.targetfx.KillFX or inst.sg.statemem.targetfx.Remove)(inst.sg.statemem.targetfx)
            end
			
			inst:ClearBufferedAction()
			inst.sg.statemem.action = nil
        end,]]
    }
)
	AddStategraphState("wilson", powerup2)
	AddStategraphState("wilson_client", powerup_c)
	
local attack_frosthammer22 = GLOBAL.State(

	{
        name = "attacking2",
        tags = { "prehammer", "attack", "notalking", "abouttoattack", "autopredict", "doing" },

        onenter = function(inst)
			
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if target == nil or equip == nil then
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                return
            end
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
                cooldown = math.max(cooldown, 16 * FRAMES)
            elseif equip ~= nil --[[and equip:HasTag("frost_hammer")]] then
				inst.AnimState:PlayAnimation("pickaxe_loop")
				local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
                if weapon and weapon:HasTag("phoenix_axe") then
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_firestaff", nil, nil, true)
				else
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_icestaff", nil, nil, true)
				end
                cooldown = math.max(cooldown, 13 * FRAMES)
            else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                cooldown = math.max(cooldown, 24 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)

            if target ~= nil then
                inst.components.combat:BattleCry()
                if target:IsValid() then
                    inst:FacePoint(target:GetPosition())
                    inst.sg.statemem.attacktarget = target
                end
            end
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("prehammer")
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        ontimeout = function(inst)
		inst.sg:RemoveStateTag("prehammer")
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
			inst.f_attack = false
			if inst.bufferedaction == inst.sg.statemem.action then
			inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") 
			inst.f_attack = false
			end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") 
			inst.f_attack = false
			end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
					inst.f_attack = false
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
				inst.f_attack = false
            end
			if inst.bufferedaction == inst.sg.statemem.action then
			inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
        end,
    }
	)

	-------client
local Lightning2 = GLOBAL.State(
{ 
			name = "Lightning2",
			tags = { "prehammer", "attack", "notalking", "abouttoattack", "autopredict", "doing", "busy" },

	
			onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local weapon = inst.replica.combat and inst.replica.combat:GetWeapon()
			if target == nil or equip == nil or weapon == nil then
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle")
				return
			end

			inst.f_attack = true
			inst:DoTaskInTime(1.6, function(inst) inst.f_attack = false end )
            --inst.replica.combat:SetTarget(target)
            --inst.replica.combat:StartAttack()
			local cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
            if inst.replica.combat ~= nil then
                inst.replica.combat:StartAttack()
            end
			
            inst.components.locomotor:Stop()
			local rider = inst.replica.rider
			
			if rider ~= nil and rider:IsRiding() then
			local cooldown = 0
            if inst.replica.combat ~= nil then
                inst.replica.combat:StartAttack()
                cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
            end
			
                if equip ~= nil and (equip:HasTag("rangedweapon") or equip:HasTag("projectile")) then
                    inst.AnimState:PlayAnimation("player_atk_pre")
                    inst.AnimState:PushAnimation("player_atk", false)
                    inst.SoundEmitter:PlaySound(
                        (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                        (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                        "dontstarve/wilson/attack_weapon",
                        nil, nil, true
                    )
                    if cooldown > 0 then
                        cooldown = math.max(cooldown, 13 * FRAMES)
                    end
                else
                    inst.AnimState:PlayAnimation("atk_pre")
                    inst.AnimState:PushAnimation("atk", false)
                    DoMountSound(inst, rider:GetMount(), "angry")
                    if cooldown > 0 then
                        cooldown = math.max(cooldown, 16 * FRAMES)
                    end
                end
				
			else
            local has_power_mana = HasManaForAction(inst, "power_attack_required", false)
            if weapon and (rider == nil or not rider:IsRiding()) then
                if has_power_mana then
                inst.AnimState:PlayAnimation("pickaxe_pre")
				--inst.AnimState:PushAnimation("pickaxe_lag", false)
				cooldown = math.max(cooldown, 6 * FRAMES)
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_icestaff")
                    --inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                else
				inst.sg.statemem.normal_powerattack_fallback = true
				inst.AnimState:PlayAnimation("atk_pre")
				inst.AnimState:PushAnimation("atk", false)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
				cooldown = math.max(cooldown, 6 * FRAMES)
                end

            else
				inst.sg.statemem.slow = true
                inst.AnimState:PlayAnimation("punch")
                --inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end
				--inst.sg:SetTimeout(cooldown)
			    inst.sg.statemem.cooldown = cooldown
			    PerformPreviewBufferedActionIfAvailable(inst)
		end	
        end,
		
		timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
			local rider = inst.replica.rider
			if rider == nil or not rider:IsRiding() then
                inst.sg:RemoveStateTag("prehammer")
				end
            end),
			
			 TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.normal_powerattack_fallback then
                    PerformPreviewBufferedActionIfAvailable(inst)
                    inst.sg:RemoveStateTag("abouttoattack")
                    return
                end
                local rider = inst.replica.rider
				if rider ~= nil and rider:IsRiding() then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
		},
		ontimeout = function(inst)
		--inst:ClearBufferedAction()
		local rider = inst.replica.rider
		if rider ~= nil and rider:IsRiding() then
		inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
		else
		inst.sg:RemoveStateTag("prehammer")
		end
        end,
		
        events =
        {
            EventHandler("unequip", function(inst) 
			local rider = inst.replica.rider
			if rider == nil or not rider:IsRiding() then
			inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_pst")
			inst.AnimState:PushAnimation("pickaxe_lag", false)
            inst.sg:GoToState("idle", true) 
			inst.f_attack = false
			end
			end),
			
            EventHandler("animover", function(inst)
			local rider = inst.replica.rider
			if rider == nil or not rider:IsRiding() then
                if inst.AnimState:AnimDone() then
					if inst.sg.statemem.normal_powerattack_fallback then
						inst.sg:GoToState("idle")
						return
					end
                    inst.sg:GoToState("attacking2_c")
					inst.sg:SetTimeout(inst.sg.statemem.cooldown or 0)
                end
			end	
            end),
			
			EventHandler("animqueueover", function(inst)
			local rider = inst.replica.rider
			if rider ~= nil and rider:IsRiding() then
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
			end	
            end),
			
        },
		
		onexit = function(inst)
		local rider = inst.replica.rider
		if rider ~= nil and rider:IsRiding() then
            if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
                inst.replica.combat:CancelAttack()
            end
		end	
        end,
		
    })
	
local attack_frosthammer22_c = GLOBAL.State(

	{
        name = "attacking2_c",
        tags = { "prehammer", "attack", "notalking", "abouttoattack", "autopredict", "doing" },

        onenter = function(inst)
		
            local buffaction = inst:GetBufferedAction()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if buffaction == nil or buffaction.target == nil or equip == nil then
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                return
            end
            local cooldown = inst.replica.combat ~= nil and inst.replica.combat:MinAttackPeriod() + .5 * FRAMES or 0
            if inst.replica.combat ~= nil then
                inst.replica.combat:StartAttack()
                --cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
            end
            inst.components.locomotor:Stop()
            local rider = inst.replica.rider
            if rider ~= nil and rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, rider:GetMount(), "angry")
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 16 * FRAMES)
                end
             elseif equip ~= nil --[[and equip:HasTag("frost_hammer")]] then
                inst.AnimState:PlayAnimation("pickaxe_loop")
				--inst.AnimState:PushAnimation("atk", false)
                local weapon = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if weapon and weapon:HasTag("phoenix_axe") then
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_firestaff", nil, nil, true)
				else
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_icestaff", nil, nil, true)
				end
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 13 * FRAMES)
                end
				if inst.components.playercontroller then
				inst.components.playercontroller:Enable(false)
				end
            else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 24 * FRAMES)
                end
            end
			
				--inst.sg:SetTimeout(cooldown)
			    PerformPreviewBufferedActionIfAvailable(inst)
							
            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                PerformPreviewBufferedActionIfAvailable(inst)
				--inst.sg:SetTimeout(TIMEOUT)
                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                end
            end

            if cooldown > 0 then
                inst.sg:SetTimeout(cooldown)
            end
			
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
			inst.sg:RemoveStateTag("prehammer")
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
            end),
            
        },

        ontimeout = function(inst)
		inst:ClearBufferedAction()
		inst.sg:RemoveStateTag("prehammer")
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
			inst.f_attack = false
			if inst.bufferedaction == inst.sg.statemem.action then
			inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
					--inst.AnimState:PushAnimation("pickaxe_lag", false)
					inst.sg:GoToState("idle", true)
					inst.f_attack = false
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
                inst.replica.combat:CancelAttack()
				inst.f_attack = false
            end
			if inst.bufferedaction == inst.sg.statemem.action then
			inst:ClearBufferedAction()
			end
			inst.sg.statemem.action = nil
        end,
    }
	
	)

--power attack
AddStategraphState("wilson", Lightning)
AddStategraphState("wilson", attack_frosthammer22)
AddStategraphState("wilson_client", Lightning2)
AddStategraphState("wilson_client", attack_frosthammer22_c)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.POWERATTACK, "Lightning"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.POWERATTACK, "Lightning2"))

ACTIONS.POWERATTACK.str = STRINGS.MUSHA_MYPOWER_SMITE
ACTIONS.BOOK22.str = STRINGS.MUSHA_MYPOWER_FROST_WIND
