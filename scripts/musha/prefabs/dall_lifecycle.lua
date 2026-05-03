local DallLifecycle = {}

local DALL_PLANT_TAG = "dall_plant"
local DALL_DRAKE_TAG = "dall_drake"
local DALL_PLANT_LIMIT = 15

function DallLifecycle.CountPlants(inst)
    local radius = inst.radius_spawning and 5 or 30
    local x, y, z = inst.Transform:GetWorldPosition()
    local count = 0
    local ents = TheSim:FindEntities(x, y, z, radius, { DALL_PLANT_TAG })
    for _, plant in pairs(ents) do
        if plant.dall_owner == nil or plant.dall_owner == inst then
            count = count + 1
        end
    end
    return count
end

function DallLifecycle.CanSpawnPlant(inst)
    return DallLifecycle.CountPlants(inst) < DALL_PLANT_LIMIT
end

function DallLifecycle.MarkPlant(inst, plant)
    if plant then
        plant:AddTag(DALL_PLANT_TAG)
        plant.dall_owner = inst
        if plant.components and plant.components.follower then
            plant.components.follower:SetLeader(inst)
        end
        if inst.components and inst.components.leader and plant.components and plant.components.follower then
            inst.components.leader:AddFollower(plant)
        end
    end
    return plant
end

function DallLifecycle.IsPlant(inst, plant)
    if not plant or not plant:IsValid() then
        return false
    end
    if plant.dall_owner == inst then
        return true
    end
    return (plant.dall_owner == nil and plant:HasTag(DALL_PLANT_TAG))
        or (plant.components
            and plant.components.follower
            and plant.components.follower.leader == inst)
end

function DallLifecycle.SpawnPlant(inst, prefab, x, y, z, force)
    if not force and not DallLifecycle.CanSpawnPlant(inst) then
        return nil
    end
    local plant = SpawnPrefab(prefab)
    if plant then
        plant.Transform:SetPosition(x, y, z)
        DallLifecycle.MarkPlant(inst, plant)
    end
    return plant
end

function DallLifecycle.SpawnRestPlant(inst, x, y, z, force)
    if math.random() < 0.5 then
        local moonbush = DallLifecycle.SpawnPlant(inst, "moonbush", x, y, z, force)
        if moonbush then
            moonbush.AnimState:PlayAnimation("shake")
        end
    else
        local moonlight = DallLifecycle.SpawnPlant(inst, "moonlight_plant", x, y, z, force)
        if moonlight then
            moonlight.AnimState:PlayAnimation("grow")
        end
    end
end

function DallLifecycle.MarkDrake(inst, drake)
    if drake then
        drake:AddTag(DALL_DRAKE_TAG)
        drake.dall_owner = inst
        if drake.components and drake.components.follower then
            drake.components.follower:SetLeader(inst)
        end
        if inst.components and inst.components.leader then
            inst.components.leader:AddFollower(drake)
        end
        drake.slave = true
        drake.exit = false
    end
    return drake
end

function DallLifecycle.IsDrake(inst, drake)
    if not drake or not drake:IsValid() then
        return false
    end
    if drake.dall_owner == inst then
        return true
    end
    return drake.components
        and drake.components.follower
        and drake.components.follower.leader == inst
end

function DallLifecycle.CountDrakes(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 100, { DALL_DRAKE_TAG })
    local count = 0
    for _, drake in pairs(ents) do
        if DallLifecycle.IsDrake(inst, drake) and not drake.inst_in then
            count = count + 1
        end
    end
    return count
end

function DallLifecycle.RemoveDrakeForMigration(inst, drake)
    if not DallLifecycle.IsDrake(inst, drake) or drake.inst_in then
        return false
    end
    if drake.components and drake.components.follower then
        drake.components.follower:SetLeader(nil)
    end
    drake.inst_in = true
    drake:Remove()
    return true
end

function DallLifecycle.RemoveDrakesForMigration(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 100, { DALL_DRAKE_TAG })
    for _, drake in pairs(ents) do
        DallLifecycle.RemoveDrakeForMigration(inst, drake)
    end
end

function DallLifecycle.RestoreDrake(inst, drake)
    if not DallLifecycle.IsDrake(inst, drake) or drake.inst_in then
        return false
    end
    local x, y, z = drake.Transform:GetWorldPosition()
    if drake.components and drake.components.follower then
        drake.components.follower:SetLeader(nil)
    end
    drake.inst_in = true
    SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
    SpawnPrefab("green_leaves").Transform:SetPosition(x, y, z)
    DallLifecycle.SpawnRestPlant(inst, x, y, z, true)
    drake:Remove()
    return true
end

function DallLifecycle.RestoreDrakes(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 100, { "moondrake" })
    for _, drake in pairs(ents) do
        DallLifecycle.RestoreDrake(inst, drake)
    end
end

function DallLifecycle.SpawnDrake(inst, x, y, z)
    local drake = SpawnPrefab("moonnutdrake")
    if drake then
        drake.Transform:SetPosition(x, y, z)
        DallLifecycle.MarkDrake(inst, drake)
        if drake.sg then
            drake.sg:GoToState("enter")
        end
    end
    return drake
end

function DallLifecycle.SpawnMigrationDrakes(inst)
    local count = inst.pending_migration_drakes or 0
    inst.pending_migration_drakes = nil
    if count <= 0 or inst.sleep_on then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    for i = 1, count do
        local angle = math.random() * 2 * math.pi
        local radius = 2 + math.random() * 2
        DallLifecycle.SpawnDrake(inst, x + math.cos(angle) * radius, y, z + math.sin(angle) * radius)
    end
end

function DallLifecycle.RegisterTasks(inst, callbacks)
    inst.on_follow = inst:DoPeriodicTask(0, callbacks.on_follow)
    inst.on_sleep = inst:DoPeriodicTask(5, callbacks.on_sleep)
    inst.summon_check = inst:DoPeriodicTask(1, callbacks.summon_check)
    inst.summon_drake = inst:DoPeriodicTask(25, callbacks.summon_drake)
    inst.summon_1 = inst:DoPeriodicTask(75, callbacks.summon_bush)
    inst.summon_2 = inst:DoPeriodicTask(100, callbacks.summon_carrot)
    inst.summon_3 = inst:DoPeriodicTask(300, callbacks.summon_dusk)
    inst.summon_4 = inst:DoPeriodicTask(150, callbacks.summon_night)
end

return DallLifecycle
