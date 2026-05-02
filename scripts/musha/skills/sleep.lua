local M = {}

function M.IsSleeping(inst)
	return inst.sleep_on
		or inst.tiny_sleep
		or (inst.sg ~= nil and (inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("bedroll")))
end

local function SayRandomLine(inst, lines)
	if inst.components.talker == nil or lines == nil or #lines == 0 then
		return
	end
	local chance = 1 / #lines
	for i = 1, #lines - 1 do
		if math.random() < chance then
			inst.components.talker:Say(lines[i])
			return
		end
	end
	inst.components.talker:Say(lines[#lines])
end

local function GetMushaSleepRestoreBuild(inst, env, is_full)
	return env.MushaAnim.GetBuildForForm(inst, is_full and "full" or "normal")
end

local function RestoreMushaBuildAfterBerserk(inst, env)
	if not (inst.fberserk or (inst.berserks and not inst:HasTag("playerghost"))) then
		return
	end

	inst.berserks = false
	inst.fberserk = false
	env.SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
	env.SpawnPrefab("statue_transition_2").Transform:SetPosition(inst:GetPosition():Get())

	if inst:HasTag("playerghost") then
		return
	end

	local is_full = inst.components.hunger.current >= 160
	inst.strength = is_full and "full" or "normal"
	local build = GetMushaSleepRestoreBuild(inst, env, is_full)
	if build ~= nil then
		env.MushaAnim.SetBuild(inst, build)
	end
end

local function ClearMushaSkillStateForSleep(inst, env)
	if env.ShadowSkill ~= nil then
		env.ShadowSkill.ClearState(inst, inst.sneaka or inst.sneak_pang)
	else
		inst:RemoveTag("notarget")
		if inst.sneaka or inst.sneak_pang then
			inst.components.colourtweener:StartTween({ 1, 1, 1, 1 }, 0)
		end
		inst.sneaka = false
		inst.poison_sneaka = false
		inst.sneak_pang = false
	end
	if inst.wormlight == nil then
		inst.AnimState:SetBloomEffectHandle("")
	end
	inst.switch = false
	inst.active_valkyrie = false
	inst.valkyrie_turn = false
	inst.lightning_spell_cost = false
	inst:RemoveEventCallback("onhitother", env.LightningSkill.OnHitLightning)

	local weapon = inst.components.inventory:GetEquippedItem(env.EQUIPSLOTS.HANDS)
	if weapon and weapon.components.weapon and weapon:HasTag("musha_items") then
		weapon.components.weapon.stimuli = nil
	end
end

local function EnableMushaWakeLight(inst)
	inst.entity:AddLight()
	inst.Light:SetRadius(1)
	inst.Light:SetFalloff(.8)
	inst.Light:SetIntensity(.8)
	inst.Light:SetColour(150 / 255, 150 / 255, 150 / 255)
	inst.Light:Enable(true)
end

local function PlayRandomMushaWakePose(inst, include_yawn)
	if include_yawn and math.random() < 0.3 then
		inst.AnimState:PlayAnimation("yawn")
	elseif math.random() < 0.3 then
		inst.AnimState:PushAnimation("mime1", false)
	elseif math.random() < 0.3 then
		inst.AnimState:PushAnimation("mime4", false)
	else
		inst.AnimState:PushAnimation("mime3", false)
	end
end

local function PlayMushaWakeAnim(inst, is_deep_sleep)
	if inst.set_on and inst.visual_hold2 and not (inst.visual_hold and inst.visual_hold3 and inst.visual_hold4) then
		PlayRandomMushaWakePose(inst, false)
	elseif is_deep_sleep and inst.components.stamina_sleep.current >= 99 then
		PlayRandomMushaWakePose(inst, true)
	else
		inst.AnimState:PlayAnimation("yawn")
	end
end

local function StartDeepSleep(inst, env)
	RestoreMushaBuildAfterBerserk(inst, env)
	ClearMushaSkillStateForSleep(inst, env)
	inst.components.locomotor:Stop()
	inst.sg:AddStateTag("busy")

	if inst.components.temperature:GetCurrent() < 10 then
		env.MushaAnim.OverrideSymbol(inst, "swap_bedroll", "swap_bedroll_furry", "bedroll_furry")
	else
		env.MushaAnim.OverrideSymbol(inst, "swap_bedroll", "swap_bedroll_straw", "bedroll_straw")
	end

	if inst.components.health and not inst.components.health:IsDead() then
		inst.sg:GoToState("bedroll2")
		inst:DoTaskInTime(2, function(inst)
			inst.sleep_on = true
		end)
	end
end

local function StartTinySleep(inst, env)
	if inst.components.health and not inst.components.health:IsDead() then
		RestoreMushaBuildAfterBerserk(inst, env)
		ClearMushaSkillStateForSleep(inst, env)
		inst.berserks = false
		inst.fberserk = false
		if not inst:HasTag("playerghost") then
			inst.sg:GoToState("knockout")
			inst.tiny_sleep = true
		else
			inst.components.talker:Say(env.STRINGS.MUSHA_TALK_GHOST_SLEEP)
		end
	end
end

local function WakeUp(inst, env)
	if not inst.music_check and inst.sleep_on then
		inst.sleep_on = false
		inst.sg:GoToState("wakeup")
		EnableMushaWakeLight(inst)
		inst.music_armor = true
		inst:DoTaskInTime(1.5, function(inst)
			inst.Light:Enable(false)
			inst.music_armor = false
			inst.musha_press = false
			PlayMushaWakeAnim(inst, true)
		end)
	elseif not inst.music_check and inst.tiny_sleep then
		inst.tiny_sleep = false
		inst.sg:GoToState("wakeup")
		EnableMushaWakeLight(inst)
		inst.music_armor = true
		inst:DoTaskInTime(3.1, function(inst)
			inst.Light:Enable(false)
			inst.music_armor = false
			inst.musha_press = false
			PlayMushaWakeAnim(inst, false)
		end)
	elseif inst.music_check then
		inst.components.playercontroller:Enable(false)
		inst.sleep_on = false
		inst.tiny_sleep = false
		inst.sg:GoToState("wakeup")
		EnableMushaWakeLight(inst)
		if inst.wormlight == nil then
			inst.AnimState:SetBloomEffectHandle("")
		end
		inst.music_check = false
		inst.switlight = true
		inst:DoTaskInTime(2, function(inst)
			inst.components.talker:Say(env.STRINGS.MUSHA_TALK_MUSIC_READY)
			inst.sg:GoToState("play_flute2")
			inst.Light:Enable(false)
			inst.music_armor = false
			inst.music_check = false
			if inst.wormlight == nil then
				inst.AnimState:SetBloomEffectHandle("")
			end
			inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
			inst.musha_press = false
			inst.components.playercontroller:Enable(true)
		end)
	end
end

local function CanUseSleepCommand(inst)
	return not inst.writing
		and not inst.components.health:IsDead()
		and not inst.sleep_on
		and not inst:HasTag("playerghost")
		and not (inst.sg:HasStateTag("moving") or inst.sg:HasStateTag("attack"))
end

local function SayDizzyByStamina(inst, env)
	local stamina = inst.components.stamina_sleep.current
	if stamina >= 40 and not (inst.warm_on or inst.warm_tent) then
		inst.components.talker:Say(env.STRINGS.MUSHA_TALK_SLEEP_DIZZY_1)
	elseif stamina < 40 and stamina >= 25 and not (inst.warm_on or inst.warm_tent) then
		inst.components.talker:Say(env.STRINGS.MUSHA_TALK_SLEEP_DIZZY_2)
	elseif stamina < 25 and stamina >= 5 and not (inst.warm_on or inst.warm_tent) then
		inst.components.talker:Say(env.STRINGS.MUSHA_TALK_SLEEP_DIZZY_3)
	elseif stamina < 5 and not (inst.warm_on or inst.warm_tent) then
		inst.components.talker:Say(env.STRINGS.MUSHA_TALK_SLEEP_DIZZY_4)
	end
end

local function StartTinySleepSoon(inst, env)
	inst:DoTaskInTime(1, function(inst)
		StartTinySleep(inst, env)
	end)
	inst.sg:AddStateTag("busy")
end

function M.SleepingAction(inst)
	local env = M.env
	local TheWorld = env.GetWorld()
	inst.writing = false

	if CanUseSleepCommand(inst)
		and inst.components.stamina_sleep.current >= 90 then
		if TheWorld.state.isday and not inst.tiny_sleep then
			SayRandomLine(inst, {
				env.STRINGS.MUSHA_TALK_SLEEP_NO_1,
				env.STRINGS.MUSHA_TALK_SLEEP_NO_2,
				env.STRINGS.MUSHA_TALK_SLEEP_NO_3,
				env.STRINGS.MUSHA_TALK_SLEEP_NO_4,
				env.STRINGS.MUSHA_TALK_SLEEP_NO_5,
			})
		elseif TheWorld.state.isday and inst.tiny_sleep and not inst.musha_press then
			inst.musha_press = true
			WakeUp(inst, env)
		end
	elseif CanUseSleepCommand(inst)
		and inst.components.stamina_sleep.current < 90 then
		if TheWorld.state.isday and not inst.tiny_sleep then
			if inst.warm_on or inst.warm_tent then
				inst.components.talker:Say(env.STRINGS.MUSHA_TALK_SLEEP_NO_3)
			end
			SayDizzyByStamina(inst, env)
			StartTinySleepSoon(inst, env)
		elseif TheWorld.state.isday and inst.tiny_sleep and not inst.musha_press then
			inst.musha_press = true
			WakeUp(inst, env)
		end
	end

	if CanUseSleepCommand(inst)
		and not TheWorld.state.isday
		and not inst.sleep_on
		and not inst.tiny_sleep
		and not inst.nsleep
		and not (inst.warm_on or inst.warm_tent) then
		if not TheWorld.state.isnight then
			SayDizzyByStamina(inst, env)
			StartTinySleepSoon(inst, env)
		elseif TheWorld.state.isnight then
			if not inst.LightWatcher:IsInLight() then
				SayRandomLine(inst, {
					env.STRINGS.MUSHA_TALK_SLEEP_NEED_LIGHT_1,
					env.STRINGS.MUSHA_TALK_SLEEP_NEED_LIGHT_2,
					env.STRINGS.MUSHA_TALK_SLEEP_NEED_LIGHT_3,
					env.STRINGS.MUSHA_TALK_SLEEP_NEED_LIGHT_4,
					env.STRINGS.MUSHA_TALK_SLEEP_NEED_LIGHT_5,
				})
			else
				SayDizzyByStamina(inst, env)
				StartTinySleepSoon(inst, env)
			end
		end
	elseif not inst.components.health:IsDead()
		and not inst.sleep_on
		and not inst:HasTag("playerghost")
		and not (inst.sg:HasStateTag("moving") or inst.sg:HasStateTag("attack"))
		and not TheWorld.state.isday
		and not inst.tiny_sleep
		and not inst.nsleep
		and (inst.warm_on or inst.warm_tent)
		and not inst.sleep_no then
		SayRandomLine(inst, {
			env.STRINGS.MUSHA_TALK_SLEEP_GOOD_1,
			env.STRINGS.MUSHA_TALK_SLEEP_GOOD_2,
			env.STRINGS.MUSHA_TALK_SLEEP_GOOD_3,
			env.STRINGS.MUSHA_TALK_SLEEP_GOOD_4,
			env.STRINGS.MUSHA_TALK_SLEEP_GOOD,
		})
		StartDeepSleep(inst, env)
	elseif not TheWorld.state.isday
		and not inst.sleep_on
		and not inst.tiny_sleep
		and not inst.nsleep
		and (inst.warm_on or inst.warm_tent)
		and inst.sleep_no then
		SayRandomLine(inst, {
			env.STRINGS.MUSHA_TALK_SLEEP_DANGER_1,
			env.STRINGS.MUSHA_TALK_SLEEP_DANGER_2,
			env.STRINGS.MUSHA_TALK_SLEEP_DANGER_3,
			env.STRINGS.MUSHA_TALK_SLEEP_DANGER_4,
			env.STRINGS.MUSHA_TALK_SLEEP_DANGER_5,
		})
	elseif not inst.components.health:IsDead()
		and (inst.sleep_on or inst.tiny_sleep)
		and not inst.nsleep
		and not inst:HasTag("playerghost")
		and not inst.musha_press then
		inst.musha_press = true
		WakeUp(inst, env)
	elseif inst.components.health:IsDead() or inst:HasTag("playerghost") then
		inst.components.talker:Say(env.STRINGS.MUSHA_TALK_GHOST_OOOOH)
	end
end

function M.Register(env)
	M.env = env
	env.AddModRPCHandler("musha", "sleeping", M.SleepingAction)
end

return M
