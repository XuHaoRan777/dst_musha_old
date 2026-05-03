local EggHatch = {}

local HATCH_DELAY = 24 / 30

local function GetEggBuild(egg)
    return egg ~= nil and egg._musha_hatch_build or nil
end

local function OverrideEggShell(inst, egg)
    local build = GetEggBuild(egg)
    if build ~= nil and inst ~= nil and inst.AnimState ~= nil then
        inst.AnimState:AddOverrideBuild(build)
        inst.AnimState:OverrideSymbol("egg01", build, "egg01")
    end
end

function EggHatch.FinishSpawn(inst, egg)
    if inst == nil then
        return
    end

    OverrideEggShell(inst, egg)

    if inst.sg ~= nil then
        inst.sg:GoToState("hatch")
        return
    end

    inst:DoTaskInTime(0, function(child)
        if child:IsValid()
            and child.userfunctions ~= nil
            and child.userfunctions.FollowPlayer ~= nil
        then
            child.userfunctions.FollowPlayer(child)
        end
    end)
end

function EggHatch.Play(inst, hatch_fn)
    if inst == nil
        or inst._musha_hatch_playing
        or hatch_fn == nil
        or inst.components == nil
        or inst.components.hatchable == nil
        or inst.components.hatchable.state ~= "hatch"
    then
        return
    end

    inst._musha_hatch_playing = true
    inst.components.hatchable:StopUpdating()

    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem.canbepickedup = false
    end

    if inst.SoundEmitter ~= nil then
        inst.SoundEmitter:KillSound("uncomfy")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hatch_crack")
    end

    if inst.AnimState ~= nil then
        inst.AnimState:PlayAnimation("crack")
        inst.AnimState:PushAnimation("idle_happy", false)
    end

    inst:DoTaskInTime(HATCH_DELAY, function(egg)
        if egg:IsValid() then
            hatch_fn(egg)
        end
    end)
end

return EggHatch
