local assets =
{
    Asset("ANIM", "anim/mushroom_spore_blue.zip"),
    Asset("ANIM", "anim/mushroom_spore_red.zip"),
}

local prefabs =
{
    "firesplash_fx",
    "firering_fx",
    "deer_fire_burst",
    "sparks",
}

local RETARGET_DIST = 12
local KEEP_TARGET_DIST = 18
local EXPLOSION_RADIUS = 5
local EXPLOSION_DAMAGE = 35
local TAUNT_RADIUS = 10
local TAUNT_PERIOD = 4
local OWNER_MAX_DIST = 50
local PERISH_TIME = 180

local function GetLeader(inst)
    local follower = inst.components.follower
    return follower ~= nil and follower.leader or inst._owner
end

local function IsAlive(ent)
    return ent ~= nil
        and ent:IsValid()
        and ent.components ~= nil
        and ent.components.health ~= nil
        and not ent.components.health:IsDead()
end

local function IsProtectedTarget(target)
    return target:HasTag("player")
        or target:HasTag("companion")
        or target:HasTag("musha")
        or target:HasTag("yamche")
        or target:HasTag("yamcheb")
        or target:HasTag("wall")
        or target:HasTag("structure")
        or target:HasTag("INLIMBO")
        or target:HasTag("stalkerminion")
        or target:HasTag("shadowminion")
        or target:HasTag("smashable")
        or target:HasTag("alignwall")
end

local function IsValidTarget(inst, target)
    return IsAlive(target)
        and target ~= inst
        and target.components.combat ~= nil
        and not IsProtectedTarget(target)
end

local function SpawnFireFx(target, scale)
    if target == nil or not target:IsValid() then
        return
    end

    local fx = SpawnPrefab("firesplash_fx")
    if fx ~= nil then
        fx.Transform:SetScale(scale or 0.4, scale or 0.4, scale or 0.4)
        fx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function HasOwnerCombatReason(inst, target)
    if not IsValidTarget(inst, target) then
        return false
    end

    local leader = GetLeader(inst)
    local target_combat = target.components.combat
    local leader_combat = leader ~= nil and leader.components ~= nil and leader.components.combat or nil

    return target_combat.target == inst
        or target_combat.target == leader
        or (leader_combat ~= nil and leader_combat.target == target)
end

local function HasExplosionReason(inst, target)
    if not IsValidTarget(inst, target) then
        return false
    end

    return HasOwnerCombatReason(inst, target)
        or target:HasTag("monster")
        or target:HasTag("werepig")
        or target:HasTag("frog")
end

local function RetargetFn(inst)
    return FindEntity(inst, RETARGET_DIST, function(target)
        return HasOwnerCombatReason(inst, target)
    end, { "_combat", "_health" }, { "INLIMBO", "player", "companion", "wall", "structure" })
end

local function KeepTargetFn(inst, target)
    if not IsValidTarget(inst, target) then
        return false
    end

    local leader = GetLeader(inst)
    return inst:IsNear(target, KEEP_TARGET_DIST)
        or (leader ~= nil and leader:IsValid() and leader:IsNear(target, KEEP_TARGET_DIST))
end

local function BeginRemove(inst, pushdeath)
    if inst._removing then
        return
    end

    inst._removing = true
    inst.persists = false
    if inst.taunttask ~= nil then
        inst.taunttask:Cancel()
        inst.taunttask = nil
    end
    if pushdeath then
        inst:PushEvent("death")
    end
    inst:DoTaskInTime(3, inst.Remove)
end

local function Explode(inst, pushdeath)
    if inst._exploded then
        BeginRemove(inst, pushdeath)
        return
    end

    inst._exploded = true

    local x, y, z = inst.Transform:GetWorldPosition()
    local ring = SpawnPrefab("firering_fx")
    if ring ~= nil then
        ring.Transform:SetScale(0.7, 0.7, 0.7)
        ring.Transform:SetPosition(x, y, z)
    end
    local burst = SpawnPrefab("deer_fire_burst")
    if burst ~= nil then
        burst.Transform:SetPosition(x, y, z)
    end

    local targets = TheSim:FindEntities(x, y, z, EXPLOSION_RADIUS, { "_combat", "_health" }, { "INLIMBO", "player", "companion", "wall", "structure" })
    for _, target in ipairs(targets) do
        if HasExplosionReason(inst, target) then
            SpawnFireFx(target, 0.5)
            target.components.combat:GetAttacked(inst, EXPLOSION_DAMAGE)
        end
    end

    BeginRemove(inst, pushdeath)
end

local function OnPerish(inst)
    Explode(inst, true)
end

local function OnDeath(inst)
    Explode(inst, false)
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if IsValidTarget(inst, attacker) then
        inst.components.combat:SetTarget(attacker)
        SpawnFireFx(attacker, 0.4)
    end

    if inst.components.health ~= nil and inst.components.health:GetPercent() <= 0.2 then
        Explode(inst, true)
    end
end

local function OnAttack(inst, target)
    SpawnFireFx(target, 0.35)
end

local function ProtectLeader(inst)
    local leader = GetLeader(inst)
    if not IsAlive(leader) or leader:HasTag("playerghost") then
        BeginRemove(inst, true)
        return
    end

    if not inst:IsNear(leader, OWNER_MAX_DIST) then
        BeginRemove(inst, true)
        return
    end

    local leader_combat = leader.components.combat
    if leader_combat ~= nil and HasOwnerCombatReason(inst, leader_combat.target) then
        inst.components.combat:SetTarget(leader_combat.target)
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x, y, z, TAUNT_RADIUS, { "_combat", "_health" }, { "INLIMBO", "player", "companion", "wall", "structure" })
    for _, target in ipairs(targets) do
        if IsValidTarget(inst, target) and target.components.combat.target == leader then
            target.components.combat:SuggestTarget(inst)
            SpawnFireFx(target, 0.3)
        end
    end
end

local function OnNear(inst)
    if inst.components.locomotor ~= nil then
        inst.components.locomotor.walkspeed = 2
    end
end

local function OnFar(inst)
    if inst.components.locomotor ~= nil then
        inst.components.locomotor.walkspeed = 6
    end
end

local function OnLoad(inst)
    inst.persists = false
    inst.Light:Enable(true)
    inst.DynamicShadow:Enable(true)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1, 0.5)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("mushroom_spore")
    inst.AnimState:SetBuild("mushroom_spore_red")
    inst.AnimState:PlayAnimation("flight_cycle", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.DynamicShadow:Enable(false)
    inst.DynamicShadow:SetSize(0.8, 0.5)

    inst.Light:SetColour(250 / 255, 190 / 255, 185 / 255)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetFalloff(0.65)
    inst.Light:SetRadius(3.2)
    inst.Light:Enable(false)

    inst:AddTag("musha_light")
    inst:AddTag("musha_fire_spore")
    inst:AddTag("companion")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true

    function inst:SetFireSporeOwner(owner)
        if owner ~= nil and owner:IsValid() then
            inst._owner = owner
            inst.components.follower:SetLeader(owner)
        end
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = 2

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(6, 7)
    inst.components.playerprox:SetOnPlayerNear(OnNear)
    inst.components.playerprox:SetOnPlayerFar(OnFar)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(PERISH_TIME)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(OnPerish)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL

    if TheWorld.state.iswinter then
        inst:AddTag("HASHEATER")
        inst:AddComponent("heater")
        inst.components.heater.heat = 20
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(140)
    inst.components.health:SetAbsorptionAmount(0.4)
    inst.components.health:SetAbsorptionAmountFromPlayer(1)
    inst.components.health.fire_damage_scale = 0

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(18)
    inst.components.combat:SetAttackPeriod(2.5)
    inst.components.combat:SetRange(2)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve/common/fireOut")
    inst.components.combat.onhitotherfn = OnAttack

    MakeHauntablePerish(inst, 0.5)

    inst:SetStateGraph("SGmushaspore_fire")
    inst:SetBrain(require("brains/musha_sporebrain_fire"))

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)
    inst.taunttask = inst:DoPeriodicTask(TAUNT_PERIOD, ProtectLeader)
    inst:DoTaskInTime(0, ProtectLeader)

    inst.OnLoad = OnLoad

    return inst
end

return Prefab("musha_spore_fire", fn, assets, prefabs)
