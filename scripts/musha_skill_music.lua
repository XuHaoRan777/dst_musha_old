local M = {}

local PLANTS_RANGE = 1
local MAX_PLANTS = 18
local PLANTFX_TAGS = { "wormwood_plant_fx" }

local function GetWorld(env)
	return env.GetWorld ~= nil and env.GetWorld() or env.TheWorld
end

local function Say(inst, text)
	if inst.components.talker ~= nil then
		inst.components.talker:Say(text)
	end
end

local function SetTalkerColour(inst, colour)
	if inst.components.talker ~= nil then
		inst.components.talker.colour = colour
	end
end

local function SpawnAt(env, prefab, pos)
	local inst = env.SpawnPrefab(prefab)
	if inst ~= nil and pos ~= nil then
		inst.Transform:SetPosition(pos:Get())
	end
	return inst
end

local function SpawnAtEntity(env, prefab, target)
	local inst = env.SpawnPrefab(prefab)
	if inst ~= nil and target ~= nil then
		inst.Transform:SetPosition(target:GetPosition():Get())
	end
	return inst
end

local function FollowOwner(item, owner)
	if item ~= nil and item.components.follower ~= nil then
		item.Transform:SetPosition(owner:GetPosition():Get())
		item.components.follower:SetLeader(owner)
	end
end

function M.EggHunt(inst)
	local env = M.env
	if inst.yamche_egg_hunted then
		return
	end

	local pos = inst:GetPosition()
	local offset = env.FindWalkableOffset(pos, math.random() * 2 * math.pi, math.random(5, 10), 10)
	if offset ~= nil then
		local spawn_pos = pos + offset
		local hidden_egg = SpawnAt(env, "musha_hidden_egg", spawn_pos)
		SpawnAt(env, "small_puff", spawn_pos)
		SpawnAt(env, "shovel", spawn_pos)
		if hidden_egg ~= nil then
			hidden_egg:SetTreasureHunt()
		end
		inst.yamche_egg_hunted = true
		inst:DoTaskInTime(0.5, function(inst)
			Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_FIRST)
			inst:DoTaskInTime(2, function(inst)
				Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_YAMCHE)
			end)
		end)
	else
		Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_FAILED)
		inst.treasure = inst.treasure + 95
	end
end

local function SpawnTreasure(env, pos, offset)
	local spawn_pos = pos + offset
	local treasure = SpawnAt(env, "musha_treasure2", spawn_pos)
	if treasure ~= nil then
		treasure:SetTreasureHunt()
	end
	SpawnAt(env, "musha_spore", spawn_pos)
	return spawn_pos
end

local function SpawnGuardPlants(env, pos, offset, guard1, guard2, guard3, worm_chance)
	if math.random() < worm_chance and guard1 ~= nil then
		local gworm = SpawnAt(env, "greenworm", pos + offset + guard1)
		if gworm ~= nil and gworm.sg ~= nil then
			gworm.sg:GoToState("lure_enter")
		end
	end
	if math.random() < 0.5 and guard2 ~= nil then
		SpawnAt(env, "green_apple_plant", pos + offset + guard2)
	end
	if math.random() < 0.25 and guard3 ~= nil then
		SpawnAt(env, "green_apple_plant", pos + offset + guard3)
	end
end

local function ClearTreasureFlags(inst)
	if inst.treasure1 or inst.treasure2 or inst.treasure3 then
		inst.treasure1 = false
		inst.treasure2 = false
		inst.treasure3 = false
	end
end

function M.TreasureHunt(inst)
	local env = M.env
	if not inst.yamche_egg_hunted then
		M.EggHunt(inst)
		return
	end

	local pos = inst:GetPosition()
	local offset1 = env.FindWalkableOffset(pos, math.random() * 800 * math.pi, math.random(900, 1000), 500)
	local offset2 = env.FindWalkableOffset(pos, math.random() * 200 * math.pi, math.random(250, 300), 180)
	local offset3 = env.FindWalkableOffset(pos, math.random() * 3 * math.pi, math.random(25, 30), 18)
	local guard1 = env.FindWalkableOffset(pos, math.random() * math.pi, math.random(1, 3), 1)
	local guard2 = env.FindWalkableOffset(pos, math.random() * math.pi, math.random(1, 2), 2)
	local guard3 = env.FindWalkableOffset(pos, math.random() * math.pi, math.random(1, 1), 3)

	if math.random() < 0.5 and offset1 ~= nil then
		inst.treasure1 = true
		inst:DoTaskInTime(1, function(inst)
			Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_FAR)
		end)
		SpawnTreasure(env, pos, offset1)
		SpawnGuardPlants(env, pos, offset1, guard1, guard2, guard3, 0.5)
	elseif math.random() < 0.6 and not inst.treasure1 and offset2 ~= nil then
		inst.treasure2 = true
		inst:DoTaskInTime(1, function(inst)
			Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_MED)
		end)
		SpawnTreasure(env, pos, offset2)
		SpawnGuardPlants(env, pos, offset2, guard1, guard2, guard3, 0.55)
	elseif not inst.treasure1 and not inst.treasure2 and offset3 ~= nil then
		inst.treasure3 = true
		inst:DoTaskInTime(0.5, function(inst)
			Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_NEAR)
		end)
		SpawnTreasure(env, pos, offset3)
		SpawnGuardPlants(env, pos, offset3, guard1, guard2, guard3, 0.5)
	elseif not inst.treasure1 and not inst.treasure2 and not inst.treasure3 then
		Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_FAILED)
		inst.treasure = inst.treasure + 90
	end

	ClearTreasureFlags(inst)
end

function M.OnTreasureHunt(inst)
	local env = M.env
	if inst.components.playercontroller == nil then
		return
	end

	inst.components.playercontroller:Enable(false)
	Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_SNIFF)

	local item = inst.components.inventory:GetEquippedItem(env.EQUIPSLOTS.HANDS)
	if item ~= nil then
		inst.sg:GoToState("talk")
		inst.components.inventory:Unequip(env.EQUIPSLOTS.HANDS, true)
		inst.components.inventory:GiveItem(item)
	end

	inst:DoTaskInTime(1.5, function(inst)
		inst.components.playercontroller:Enable(false)
		inst.sg:GoToState("peertelescope2")
		SetTalkerColour(inst, env.Vector3(1, 0.85, 0.7, 1))
		Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_FOUND)
		inst:DoTaskInTime(3, function(inst)
			inst.components.playercontroller:Enable(false)
			inst.sg:GoToState("map")
			SetTalkerColour(inst, env.Vector3(1, 0.85, 0.7, 1))
			Say(inst, env.STRINGS.MUSHA_TALK_TREASURE_MARK)
			inst:DoTaskInTime(3.5, function(inst)
				inst.components.playercontroller:Enable(true)
				SetTalkerColour(inst, env.Vector3(1, 1, 1, 1))
				M.TreasureHunt(inst)
			end)
		end)
	end)
end

local function PlantTick(inst)
	local env = M.env
	local TheWorld = GetWorld(env)
	if inst.sg:HasStateTag("ghostbuild") or inst.components.health:IsDead() or not inst.entity:IsVisible() then
		return
	end

	local t = inst.components.bloomness.timer
	local chance = TheWorld.state.isspring and 1
		or t <= env.TUNING.WORMWOOD_BLOOM_PLANTS_WARNING_TIME_LOW and 1 / 3
		or t <= env.TUNING.WORMWOOD_BLOOM_PLANTS_WARNING_TIME_MED and 2 / 3
		or 1

	if chance < 1 and math.random() > chance then
		return
	end

	if inst:GetCurrentPlatform() ~= nil then
		return
	end

	local x, y, z = inst.Transform:GetWorldPosition()
	if #env.TheSim:FindEntities(x, y, z, PLANTS_RANGE, PLANTFX_TAGS) < MAX_PLANTS then
		local map = TheWorld.Map
		local pt = env.Vector3(0, 0, 0)
		local offset = env.FindValidPositionByFan(
			math.random() * 2 * math.pi,
			math.random() * PLANTS_RANGE,
			3,
			function(offset)
				pt.x = x + offset.x
				pt.z = z + offset.z
				return map:CanPlantAtPoint(pt.x, 0, pt.z)
					and #env.TheSim:FindEntities(pt.x, 0, pt.z, .5, PLANTFX_TAGS) < 3
					and map:IsDeployPointClear(pt, nil, .5)
					and not map:IsPointNearHole(pt, .4)
			end
		)
		if offset ~= nil then
			local plant = env.SpawnPrefab("wormwood_plant_fx")
			plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)
			local rnd = math.random()
			inst.plantpool = { 1, 2, 3, 4 }
			rnd = table.remove(inst.plantpool, math.clamp(math.ceil(rnd * rnd * #inst.plantpool), 1, #inst.plantpool))
			table.insert(inst.plantpool, rnd)
			plant:SetVariation(rnd)
		end
	end
end

local function StartPerformance(inst, env, first_state)
	if inst.components.playercontroller == nil then
		return false
	end

	inst.components.playercontroller:Enable(false)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.sg:GoToState(first_state or "play_flute2")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
	inst.entity:AddLight()
	inst.Light:SetRadius(0.5)
	inst.Light:SetFalloff(.75)
	inst.Light:SetIntensity(.1)
	inst.Light:SetColour(90 / 255, 90 / 255, 90 / 255)
	inst.music_armor = true
	inst.nsleep = true
	inst.start_music = false
	if inst.components.sanityaura ~= nil then
		inst.components.sanityaura.aura = env.TUNING.SANITYAURA_HUGE * 5
	end
	return true
end

local function FinishAura(inst, env, lightorb)
	inst.components.playercontroller:Enable(true)
	inst.AnimState:SetBloomEffectHandle("")
	inst.Light:Enable(true)
	FollowOwner(lightorb, inst)
	inst.small_light = true
	inst.lightaura = true
	inst.moondrake_on = true
	inst.sg:GoToState("play_horn2")
	inst.nsleep = false
	SpawnAtEntity(env, "statue_transition_2", inst)
	if inst.components.sanityaura ~= nil then
		inst.components.sanityaura.aura = env.TUNING.SANITYAURA_HUGE
	end
	if inst.components.sanity ~= nil then
		inst.components.sanity:DoDelta(10)
	end
	inst.music_armor = false
end

local function ScheduleAuraEnd(inst, env)
	inst:DoTaskInTime(180, function(inst)
		inst.small_light = false
		inst.lightaura = false
		inst.moondrake_on = false
		inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
		SpawnAtEntity(env, "statue_transition_2", inst)
		if inst.components.sanityaura ~= nil then
			inst.components.sanityaura.aura = 0
		end
		inst.Light:SetRadius(0.5)
		inst:DoTaskInTime(5, function(inst)
			inst.Light:Enable(false)
			inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
			if inst.planttask ~= nil then
				inst.planttask:Cancel()
				inst.planttask = nil
			end
		end)
	end)
end

function M.MusicAct1(inst)
	local env = M.env
	local lightorb = env.SpawnPrefab("musha_spore2")
	local hounds = env.SpawnPrefab("ghosthound")
	if not StartPerformance(inst, env) then
		return
	end

	inst:DoTaskInTime(3, function(inst)
		inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
		inst.sg:GoToState("play_flute2")
		inst:DoTaskInTime(3, function(inst)
			SpawnAtEntity(env, "balloonparty_confetti_cloud", inst)
			inst.sg:GoToState("enter_onemanband")
			inst:DoTaskInTime(3, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
				inst.sg:GoToState("play_flute2")
				inst:DoTaskInTime(3, function(inst)
					FinishAura(inst, env, lightorb)
					if hounds ~= nil then
						hounds.Transform:SetPosition(inst:GetPosition():Get())
						hounds.followdog = true
					end
					ScheduleAuraEnd(inst, env)
				end)
			end)
		end)
	end)
end

function M.MusicAct2(inst)
	local env = M.env
	local lightorb = env.SpawnPrefab("musha_spore2")
	local shadow = env.SpawnPrefab("shadowmusha")
	if not StartPerformance(inst, env) then
		return
	end

	inst:DoTaskInTime(3, function(inst)
		inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
		inst.sg:GoToState("play_flute2")
		inst:DoTaskInTime(3, function(inst)
			SpawnAtEntity(env, "balloonparty_confetti_cloud", inst)
			inst.sg:GoToState("enter_onemanband")
			inst:DoTaskInTime(3, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
				inst.sg:GoToState("play_flute2")
				inst:DoTaskInTime(3, function(inst)
					inst.sg:GoToState("enter_onemanband")
					inst:DoTaskInTime(3, function(inst)
						FinishAura(inst, env, lightorb)
						if shadow ~= nil then
							shadow.Transform:SetPosition(inst:GetPosition():Get())
							shadow.followdog = true
						end
						ScheduleAuraEnd(inst, env)
					end)
				end)
			end)
		end)
	end)
end

local function SpawnDelayedTentacle(inst, env, tentacle, x, y, z, offset, delay)
	inst:DoTaskInTime(delay, function()
		if tentacle ~= nil then
			tentacle.Transform:SetPosition(x + offset.x, y + offset.y, z + offset.z)
			SpawnAtEntity(env, "statue_transition", tentacle)
			tentacle.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
		end
	end)
end

function M.MusicAct3(inst)
	local env = M.env
	local angle = math.random(1, 360)
	local offsets = {}
	for i = 1, 6 do
		offsets[i] = env.FindWalkableOffset(inst:GetPosition(), angle * env.DEGREES, math.random(2, 8), 30, false, false)
		if offsets[i] == nil then
			return
		end
	end

	local tentacles = {}
	for i = 1, 6 do
		tentacles[i] = env.SpawnPrefab("tentacle_frost")
	end
	local lightorb = env.SpawnPrefab("musha_spore2")
	if not StartPerformance(inst, env) then
		return
	end

	inst:DoTaskInTime(3, function(inst)
		inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
		inst.sg:GoToState("play_flute2")
		inst:DoTaskInTime(3, function(inst)
			SpawnAtEntity(env, "balloonparty_confetti_cloud", inst)
			inst.sg:GoToState("enter_onemanband")
			inst:DoTaskInTime(3, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
				inst.sg:GoToState("play_flute2")
				inst:DoTaskInTime(3, function(inst)
					inst.sg:GoToState("enter_onemanband")
					inst:DoTaskInTime(3, function(inst)
						FinishAura(inst, env, lightorb)
						local x, y, z = inst.Transform:GetWorldPosition()
						if tentacles[1] ~= nil then
							tentacles[1].Transform:SetPosition(x + offsets[1].x, y + offsets[1].y, z + offsets[1].z)
							SpawnAtEntity(env, "statue_transition", tentacles[1])
							inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
						end
						for i = 2, 6 do
							SpawnDelayedTentacle(inst, env, tentacles[i], x, y, z, offsets[i], (i - 1) * 3)
						end
						ScheduleAuraEnd(inst, env)
					end)
				end)
			end)
		end)
	end)
end

local function StartPlantTask(inst)
	if inst.planttask == nil then
		inst.planttask = inst:DoPeriodicTask(.25, PlantTick)
	end
end

local function PlayMusic(inst, env)
	inst.start_music = true
	inst.music = inst.music * 0
	inst.switlight = false
	if math.random() < 0.5 then
		Say(inst, env.STRINGS.MUSHA_TALK_MUSIC_TYPE.."1")
		M.MusicAct1(inst)
	elseif math.random() < 0.3 then
		Say(inst, env.STRINGS.MUSHA_TALK_MUSIC_TYPE.."2")
		M.MusicAct2(inst)
	elseif math.random() < 0.15 then
		Say(inst, env.STRINGS.MUSHA_TALK_MUSIC_TYPE.."3")
		M.MusicAct3(inst)
	else
		Say(inst, env.STRINGS.MUSHA_TALK_MUSIC_TYPE.."4")
		M.MusicAct1(inst)
	end
	StartPlantTask(inst)
end

function M.BuffAction(inst)
	local env = M.env
	inst.writing = false
	if inst.writing then
		return
	end

	if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
		env.MushaCommands.RunTextUserCommand("sad", inst, false)
		Say(inst, env.STRINGS.MUSHA_TALK_MUSIC_RIDE)
		return
	end

	env.MushaCommands.RunTextUserCommand("dance", inst, false)
	if inst.treasure_sniffs then
		M.OnTreasureHunt(inst)
		inst.treasure = inst.treasure * 0
		inst.treasure_sniffs = false
	elseif not inst.treasure_sniffs then
		if inst.switlight
			and not inst.sleep_on
			and not inst.components.health:IsDead()
			and not inst:HasTag("playerghost")
			and not inst.start_music then
			PlayMusic(inst, env)
		elseif not inst.switlight
			and not inst.sleep_on
			and not inst.components.health:IsDead()
			and not inst:HasTag("playerghost") then
			if inst.music < 100 then
				Say(inst, env.STRINGS.MUSHA_TALK_NEED_SLEEP)
			elseif inst.music >= 100 then
				Say(inst, env.STRINGS.MUSHA_TALK_MUSIC_READY)
				inst.switlight = true
			end
		elseif inst.components.health:IsDead() or inst:HasTag("playerghost") then
			Say(inst, env.STRINGS.MUSHA_TALK_GHOST_MUSIC)
		end
	end
end

function M.Register(env)
	M.env = env
	env.DEGREES = env.DEGREES or (math.pi / 180)
	env.AddModRPCHandler("musha", "buff", M.BuffAction)
end

return M
