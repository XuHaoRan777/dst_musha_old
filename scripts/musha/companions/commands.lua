local CompanionCommands = {}

local DALL_TAG = "dall"
local DALL_RADIUS = 25
local ARONG_TAG = "Arongb"
local ARONG_RADIUS = 25
local YAMCHE_TAG = "yamcheb"
local YAMCHE_RADIUS = 25

local function IsNearWriteable(inst, the_sim)
	return false
end

local function IsAlivePlayer(inst)
	return inst.components ~= nil
		and inst.components.health ~= nil
		and not inst.components.health:IsDead()
		and not inst:HasTag("playerghost")
end

local function Say(inst, line)
	if inst.components ~= nil and inst.components.talker ~= nil and line ~= nil then
		inst.components.talker:Say(line)
	end
end

local function RunEmote(commands, emote, owner)
	if commands ~= nil and emote ~= nil then
		commands.RunTextUserCommand(emote, owner, false)
	end
end

local function SetOwnerFollowState(owner, state_name, legacy_name, value)
	owner[state_name] = value
	owner[legacy_name] = value
end

local function RegisterDall(deps)
	local CompanionStates = deps.CompanionStates
	local STRINGS = deps.STRINGS
	local MushaCommands = deps.MushaCommands
	local TheSim = deps.TheSim

	local DALL_COMPANION = {
		migrate_with_owner = true,
		can_command = function(dall)
			return dall.components ~= nil and dall.components.follower ~= nil
		end,
		on_follow = function(owner, dall)
			dall.yamche = true
			dall.sleep_on = false
			dall.dall_command_follow = true
			Say(owner, STRINGS.MUSHA_TALK_ORDER_DALL_FOLLOW)
			RunEmote(MushaCommands, "happy", owner)
		end,
		on_rest = function(owner, dall)
			dall.yamche = true
			dall.sleep_on = true
			dall.dall_command_follow = false
			if dall.RestoreDallDrakes ~= nil then
				dall:RestoreDallDrakes()
			end
			Say(owner, STRINGS.MUSHA_TALK_ORDER_DALL_STAY)
		end,
	}

	local function update(inst)
		local dall = inst.follow_dall
			and CompanionStates.FindCommandable(inst, DALL_TAG, DALL_RADIUS, DALL_COMPANION)
			or (CompanionStates.FindOwned(inst, DALL_TAG, DALL_RADIUS)
				or CompanionStates.FindCommandable(inst, DALL_TAG, DALL_RADIUS, DALL_COMPANION))

		if dall == nil then
			return
		end

		if dall.onsleep then
			Say(inst, STRINGS.MUSHA_TALK_ORDER_DALL_SLEEPY)
		elseif inst.follow_dall then
			CompanionStates.SetFollowing(inst, dall, DALL_TAG, DALL_COMPANION)
		else
			CompanionStates.SetResting(inst, dall, DALL_TAG, DALL_COMPANION)
		end
	end

	local function order(inst)
		if IsNearWriteable(inst, TheSim) then
			return
		end

		local commandable_dall = CompanionStates.FindCommandable(inst, DALL_TAG, DALL_RADIUS, DALL_COMPANION)
		local has_dall_follower = CompanionStates.HasOwned(inst, DALL_TAG, DALL_RADIUS)

		if commandable_dall ~= nil and not has_dall_follower and IsAlivePlayer(inst) then
			SetOwnerFollowState(inst, "follow_dall", "dall_follow", true)
			update(inst)
		elseif has_dall_follower and IsAlivePlayer(inst) then
			SetOwnerFollowState(inst, "follow_dall", "dall_follow", false)
			update(inst)
		elseif commandable_dall == nil and not inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_ORDER_DALL_LOST)
		elseif commandable_dall ~= nil and not has_dall_follower and inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_GHOST_FOLLOW)
			SetOwnerFollowState(inst, "follow_dall", "dall_follow", true)
			update(inst)
		elseif has_dall_follower and inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_GHOST_STAY)
			SetOwnerFollowState(inst, "follow_dall", "dall_follow", false)
			update(inst)
		elseif commandable_dall == nil and inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_GHOST_OOOOH)
		end
	end

	deps.AddModRPCHandler("musha", "dall", order)
end

local function RegisterArong(deps)
	local CompanionStates = deps.CompanionStates
	local STRINGS = deps.STRINGS
	local MushaCommands = deps.MushaCommands
	local TheSim = deps.TheSim

	local ARONG_COMPANION = {
		migrate_with_owner = true,
		can_command = function(arong)
			return arong.components ~= nil and arong.components.follower ~= nil
		end,
		on_follow = function(owner, arong)
			Say(owner, STRINGS.MUSHA_TALK_ORDER_ARONG_FOLLOW)
			RunEmote(MushaCommands, "happy", owner)
			arong.yamche = true
			arong.mount = true
			arong.command_sleep = false
			arong.force_sleep = false
			arong.idle_sleep = false
			arong.sleep_on = false
			arong.follow = true
		end,
		on_rest = function(owner, arong)
			Say(owner, STRINGS.MUSHA_TALK_ORDER_ARONG_STAY)
			arong.yamche = true
			arong.active_hunt = false
			arong.mount = false
			arong.command_sleep = true
			arong.force_sleep = false
			arong.sleep_on = true
			arong.follow = false
		end,
	}

	local function update(inst)
		local arong = inst.follow_arong
			and CompanionStates.FindCommandable(inst, ARONG_TAG, ARONG_RADIUS, ARONG_COMPANION)
			or (CompanionStates.FindOwned(inst, ARONG_TAG, ARONG_RADIUS)
				or CompanionStates.FindCommandable(inst, ARONG_TAG, ARONG_RADIUS, ARONG_COMPANION))

		if arong == nil then
			return
		end

		if inst.follow_arong then
			CompanionStates.SetFollowing(inst, arong, ARONG_TAG, ARONG_COMPANION)
		else
			CompanionStates.SetResting(inst, arong, ARONG_TAG, ARONG_COMPANION)
		end
	end

	local function order(inst)
		if IsNearWriteable(inst, TheSim) then
			return
		end

		local commandable_arong = CompanionStates.FindCommandable(inst, ARONG_TAG, ARONG_RADIUS, ARONG_COMPANION)
		local has_arong_follower = CompanionStates.HasOwned(inst, ARONG_TAG, ARONG_RADIUS)

		if commandable_arong ~= nil and not has_arong_follower and IsAlivePlayer(inst) then
			SetOwnerFollowState(inst, "follow_arong", "arong_follow", true)
			update(inst)
		elseif has_arong_follower and IsAlivePlayer(inst) then
			SetOwnerFollowState(inst, "follow_arong", "arong_follow", false)
			update(inst)
		elseif commandable_arong == nil and not inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_ORDER_ARONG_LOST)
		elseif commandable_arong ~= nil and not has_arong_follower and inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_GHOST_FOLLOW)
			SetOwnerFollowState(inst, "follow_arong", "arong_follow", true)
			update(inst)
		elseif has_arong_follower and inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_GHOST_STAY)
			SetOwnerFollowState(inst, "follow_arong", "arong_follow", false)
			update(inst)
		elseif commandable_arong == nil and inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_GHOST_OOOOH)
		end
	end

	deps.AddModRPCHandler("musha", "arong", order)
end

local function RegisterYamcheFollow(deps)
	local CompanionStates = deps.CompanionStates
	local STRINGS = deps.STRINGS
	local MushaCommands = deps.MushaCommands
	local TheSim = deps.TheSim

	local YAMCHE_COMPANION = {
		can_command = function(yamche)
			return yamche ~= nil
				and yamche.components ~= nil
				and yamche.components.follower ~= nil
				and not yamche.house
				and not yamche.hat
				and not yamche.picked
		end,
		on_follow = function(owner, yamche)
			if yamche.MiniMapEntity ~= nil then
				yamche.MiniMapEntity:SetIcon("")
			end
			yamche.yamche = true
			yamche.sleepn = false
			yamche.fightn = false
			yamche.slave = true
		end,
		on_rest = function(owner, yamche)
			yamche.sleepn = true
			yamche.yamche = true
			yamche.fightn = true
			yamche.active_hunt = false
			yamche.slave = false
			if yamche.MiniMapEntity ~= nil then
				yamche.MiniMapEntity:SetIcon("musha_small.txt")
			end
			if yamche.components.sleeper ~= nil and not yamche.components.sleeper:IsAsleep() then
				yamche.components.sleeper:AddSleepiness(3, 10)
			end
			if yamche.pick1 then
				Say(yamche, STRINGS.MUSHA_TALK_ORDER_YAMCHE_GATHER_STOP)
				yamche.pick1 = false
				yamche.working_food = false
			end
		end,
	}

	local function find_commandable(inst)
		return CompanionStates.FindCommandable(inst, YAMCHE_TAG, YAMCHE_RADIUS, YAMCHE_COMPANION)
	end

	local function find_owned(inst)
		return CompanionStates.FindOwned(inst, YAMCHE_TAG, YAMCHE_RADIUS)
	end

	local function update(inst)
		local yamche = inst.follow and find_commandable(inst) or (find_owned(inst) or find_commandable(inst))
		if yamche == nil then
			return
		end

		if inst.follow then
			CompanionStates.SetFollowing(inst, yamche, YAMCHE_TAG, YAMCHE_COMPANION)
		else
			CompanionStates.SetResting(inst, yamche, YAMCHE_TAG, YAMCHE_COMPANION)
		end
	end

	local function order(inst)
		if IsNearWriteable(inst, TheSim) or inst.hat or inst.house then
			return
		end

		local commandable_yamche = find_commandable(inst)
		local owned_yamche = find_owned(inst)
		local has_yamche_follower = inst.components.leader:CountFollowers(YAMCHE_TAG) > 0

		if commandable_yamche ~= nil and commandable_yamche.components.follower.leader == inst then
			has_yamche_follower = true
		end
		if owned_yamche ~= nil then
			has_yamche_follower = true
		end

		if not has_yamche_follower and commandable_yamche ~= nil and IsAlivePlayer(inst) then
			Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_FOLLOW)
			RunEmote(MushaCommands, "happy", inst)
			SetOwnerFollowState(inst, "follow", "yamche_follow", true)
			update(inst)
		elseif has_yamche_follower and IsAlivePlayer(inst) then
			Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_STAY)
			SetOwnerFollowState(inst, "follow", "yamche_follow", false)
			update(inst)
		elseif commandable_yamche == nil and not inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_LOST)
		elseif not has_yamche_follower and commandable_yamche ~= nil and inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_GHOST_FOLLOW)
			SetOwnerFollowState(inst, "follow", "yamche_follow", true)
			update(inst)
		elseif has_yamche_follower and inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_GHOST_STAY)
			SetOwnerFollowState(inst, "follow", "yamche_follow", false)
			update(inst)
		elseif commandable_yamche == nil and inst:HasTag("playerghost") then
			Say(inst, STRINGS.MUSHA_TALK_GHOST_OOOOH)
		end
	end

	deps.AddModRPCHandler("musha", "yamche", order)
end

local function RegisterYamcheBattle(deps)
	local STRINGS = deps.STRINGS
	local TheSim = deps.TheSim

	local function order(inst)
		if IsNearWriteable(inst, TheSim) then
			return
		end

		local x, y, z = inst.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 25, { "yamche" })
		for _, v in pairs(ents) do
			if not inst.components.leader:IsFollower(v) and v:HasTag(YAMCHE_TAG) and not inst:HasTag("playerghost") and inst.components.leader:CountFollowers(YAMCHE_TAG) == 0 then
				Say(inst, STRINGS.MUSHA_TALK_ORDER_ARONG_SLEEPY)
			elseif v.components.follower and v.components.follower.leader and inst.components.leader:IsFollower(v) and not v.peace and not v.active_hunt and not v.defense and not inst:HasTag("playerghost") and not inst.berserks and not inst.fberserk then
				v.yamche = true
				if v:HasTag(YAMCHE_TAG) then
					Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_HUNT)
					Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_OFFENSE)
					v.peace = false
					v.active_hunt = true
					v.defense = false
					v.crazyness = false
				end
			elseif v.components.follower and v.components.follower.leader and inst.components.leader:IsFollower(v) and not v.peace and v.active_hunt and not v.defense and inst.components.leader:IsFollower(v) and not inst:HasTag("playerghost") and not inst.berserks and not inst.fberserk then
				v.yamche = true
				if v:HasTag(YAMCHE_TAG) then
					Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_RETREAT)
					Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_AVOID)
					v.peace = true
					v.active_hunt = false
					v.defense = true
					v.crazyness = true
				end
			elseif v.components.follower and v.components.follower.leader and inst.components.leader:IsFollower(v) and v.peace and not v.active_hunt and v.defense and inst.components.leader:IsFollower(v) and not inst:HasTag("playerghost") and not inst.berserks and not inst.fberserk then
				v.yamche = true
				if v:HasTag(YAMCHE_TAG) then
					Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_PROTECT)
					Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_DEFFENSE)
					v.peace = false
					v.active_hunt = false
					v.defense = false
					v.crazyness = false
				end
			elseif v.components.follower and v.components.follower.leader and v.peace and inst.components.leader:IsFollower(v) and not inst:HasTag("playerghost") and (inst.berserks or inst.fberserk) then
				Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_BERSERK)
				v.yamche = true
				if v:HasTag(YAMCHE_TAG) then
					Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_AVOID)
					v.peace = true
					v.active_hunt = false
					v.defense = true
					v.crazyness = true
				end
			elseif v.components.follower and v.components.follower.leader and not v.peace and inst.components.leader:IsFollower(v) and inst:HasTag("playerghost") and not inst.berserks and not inst.fberserk then
				v.yamche = true
				if v:HasTag(YAMCHE_TAG) then
					Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_GHOST)
					Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_AVOID)
					v.peace = true
					v.active_hunt = false
					v.defense = true
					v.crazyness = false
				end
			elseif v.components.follower and v.components.follower.leader and v.peace and inst.components.leader:IsFollower(v) and inst:HasTag("playerghost") and not inst.berserks and not inst.fberserk then
				Say(inst, STRINGS.MUSHA_TALK_GHOST_OOOOHHHH)
				v.yamche = true
				if v:HasTag(YAMCHE_TAG) then
					Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_DEFFENSE)
					v.peace = false
					v.active_hunt = false
					v.defense = false
					v.crazyness = false
				end
			end
		end
	end

	deps.AddModRPCHandler("musha", "yamche2", order)
end

local function SayYamcheInventoryState(v, strings, active_text, active_cost, rest_cost)
	if not v.light_on then
		Say(v, strings.MUSHA_TALK_ORDER_YAMCHE_REST .. "\n" .. strings.MUSHA_TALK_ORDER_YAMCHE_HUNGRY .. rest_cost)
	else
		Say(v, active_text .. "\n" .. strings.MUSHA_TALK_ORDER_YAMCHE_HUNGRY .. active_cost)
	end
end

local function RegisterYamcheGather(deps)
	local STRINGS = deps.STRINGS
	local TheSim = deps.TheSim
	local SpawnPrefab = deps.SpawnPrefab
	local MushaCommands = deps.MushaCommands

	local function order(inst)
		if IsNearWriteable(inst, TheSim) then
			return
		end

		local x, y, z = inst.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 25, { YAMCHE_TAG })
		for _, v in pairs(ents) do
			if not v.removinv then
				if v.components.follower and v.components.follower.leader and inst.components.leader:IsFollower(v) and not inst:HasTag("playerghost") and v.level1 then
					Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_LEVEL1)
					v.yamche = true
				elseif not v.level1 and v.components.follower and v.components.follower.leader and inst.components.leader:IsFollower(v) and not inst:HasTag("playerghost") and v.components.container and v.item_max_full then
					v.working_food = false
					v.pick1 = false
					v.drop = true
					v.item_1 = false
					v.item_ready_drop = false
					Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_SHOWME)
					v.yamche = true

					SpawnPrefab("dr_warm_loop_2").Transform:SetPosition(v:GetPosition():Get())
					SayYamcheInventoryState(v, STRINGS, STRINGS.MUSHA_TALK_ORDER_YAMCHE_LIGHT, "(x8)", "(x1)")
				elseif not v.level1 and v.components.follower and v.components.follower.leader and inst.components.leader:IsFollower(v) and not v.pick1 and not inst:HasTag("playerghost") and not v.item_max_full then
					Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_GATHER)
					RunEmote(MushaCommands, "cheer", inst)
					v.working_food = true
					v.pick1 = true
					v.drop = false
					v.yamche = true

					if not v.light_on then
						Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_STUFF .. "\n" .. STRINGS.MUSHA_TALK_ORDER_YAMCHE_HUNGRY .. "(x6)")
					else
						Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_LIGHT .. "+" .. STRINGS.MUSHA_TALK_ORDER_YAMCHE_STUFF .. "\n" .. STRINGS.MUSHA_TALK_ORDER_YAMCHE_HUNGRY .. "(x14)")
					end
				elseif not v.level1 and v.components.follower and v.components.follower.leader and inst.components.leader:IsFollower(v) and v.pick1 and not inst:HasTag("playerghost") and not v.item_max_full then
					Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_GATHER_STOP)
					v.working_food = false
					v.pick1 = false
					v.drop = true
					v.yamche = true
					SayYamcheInventoryState(v, STRINGS, STRINGS.MUSHA_TALK_ORDER_YAMCHE_LIGHT, "(x8)", "(x1)")
				elseif not v.level1 and not inst.components.leader:IsFollower(v) and not inst:HasTag("playerghost") and inst.components.leader:CountFollowers(YAMCHE_TAG) == 0 then
					Say(inst, STRINGS.MUSHA_TALK_ORDER_YAMCHE_EGG)
				elseif v.components.follower and v.components.follower.leader and inst.components.leader:IsFollower(v) and not v.pick1 and inst:HasTag("playerghost") then
					Say(inst, STRINGS.MUSHA_TALK_GHOST_GATHER)
					v.working_food = true
					v.pick1 = true
					v.drop = false
					v.yamche = true

					if not v.light_on then
						Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_STUFF .. "\n" .. STRINGS.MUSHA_TALK_ORDER_YAMCHE_HUNGRY .. "(x6)")
					else
						Say(v, STRINGS.MUSHA_TALK_ORDER_YAMCHE_LIGHT .. "+" .. STRINGS.MUSHA_TALK_ORDER_YAMCHE_STUFF .. "\n" .. STRINGS.MUSHA_TALK_ORDER_YAMCHE_HUNGRY .. "(x14)")
					end
				elseif not v.level1 and v.components.follower and v.components.follower.leader and inst.components.leader:IsFollower(v) and v.pick1 and inst:HasTag("playerghost") then
					Say(inst, STRINGS.MUSHA_TALK_GHOST_STOP)
					v.working_food = false
					v.pick1 = false
					v.drop = true
					SayYamcheInventoryState(v, STRINGS, STRINGS.MUSHA_TALK_ORDER_YAMCHE_LIGHT, "(x8)", "(x1)")
				end
			end
		end

		local critters = TheSim:FindEntities(x, y, z, 25, { "critter" })
		for _, v in pairs(critters) do
			if v.components.follower.leader and inst.components.leader:IsFollower(v) and v.components.container ~= nil and v.critter_musha and inst.components.leader:CountFollowers(YAMCHE_TAG) == 0 then
				if v.components.container:IsFull() then
					if v.components.locomotor ~= nil then
						v.components.locomotor:StopMoving()
					end
					RunEmote(MushaCommands, "annoyed", inst)
					v.AnimState:PlayAnimation("distress")
					v.components.machine:TurnOff()
					v.working_on = false
					v.item_ready_drop = false
					v.working_food = false
					v.pick1 = false
					v.collect_off = true
				elseif not v.pick1 and not v.working_food then
					if v.components.container ~= nil then
						v.components.container:Close()
						v.collect_work = true
					end

					Say(inst, STRINGS.CRITTER_GATHERING)
					RunEmote(MushaCommands, "cheer", inst)
					v.components.machine:TurnOn()
					v.working_on = true
					v.item_ready_drop = true
					if v.components.locomotor ~= nil then
						v.components.locomotor:StopMoving()
					end
					if math.random(1, 2) == 1 then
						v.sg:GoToState("playful")
					else
						v.AnimState:PlayAnimation("emote_nuzzle")
					end

					v.item_ready_drop = true
					v.working_food = true
					v.pick1 = true
				elseif v.pick1 or v.working_food then
					if v.components.container ~= nil then
						v.collect_work = false
					end

					Say(inst, STRINGS.CRITTER_STOP_GATHER)
					v.components.machine:TurnOff()
					v.working_on = false

					if v.components.locomotor ~= nil then
						v.components.locomotor:StopMoving()
					end
					if v.prefab == "critter_lamb" then
						v.AnimState:PlayAnimation("distress")
						v.SoundEmitter:PlaySound("dontstarve/creatures/together/sheepington/yell")
					else
						v.sg:GoToState("emote_cute")
					end

					v.item_ready_drop = false
					v.working_food = false
					v.pick1 = false
				end
			elseif v.components.follower.leader and inst.components.leader:IsFollower(v) and v.components.container ~= nil and v.critter_musha and inst.components.leader:CountFollowers(YAMCHE_TAG) >= 1 then
				v.follow_yamche = true
			end
		end
	end

	deps.AddModRPCHandler("musha", "yamche3", order)
end

function CompanionCommands.Register(deps)
	RegisterDall(deps)
	RegisterArong(deps)
	RegisterYamcheFollow(deps)
	RegisterYamcheBattle(deps)
	RegisterYamcheGather(deps)
end

return CompanionCommands
