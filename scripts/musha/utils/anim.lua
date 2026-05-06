local MushaAnim = {}

local FORM_BUILDS =
{
    full =
    {
        default = "musha",
        set2 = "musha_full_k",
        set3 = "musha_old",
        set4 = "musha_full_sw2",
    },
    normal =
    {
        default = "musha_normal",
        set2 = "musha_normal_k",
        set3 = "musha_normal_old",
        set4 = "musha_normal_sw2",
    },
    valkyrie =
    {
        default = "musha_battle",
        set2 = "musha_battle_k",
        set3 = "musha_battle_old",
        set4 = "musha_battle_sw2",
    },
    berserk =
    {
        default = "musha_hunger",
        set2 = "musha_hunger_k",
        set3 = "musha_hunger_old",
        set4 = "musha_hunger_sw2",
    },
}

local SKIN_FORM_BUILDS =
{
    musha_none =
    {
        full = "musha",
        normal = "musha_normal",
        valkyrie = "musha_battle",
        berserk = "musha_hunger",
    },
    musha_battle_skin_none =
    {
        full = "musha_battle_old_full",
        normal = "musha_battle_old",
        valkyrie = "musha_battle_old",
        berserk = "musha_hunger_old",
    },
    musha_old_skin_none =
    {
        full = "musha_old",
        normal = "musha_normal_old",
        valkyrie = "musha_battle_old",
        berserk = "musha_hunger_old",
    },
}

local DEFAULT_BUILD_FORMS =
{
    musha = "full",
    musha_normal = "normal",
    musha_battle = "valkyrie",
    musha_hunger = "berserk",
}

local function HasAnimState(inst)
    return inst ~= nil and inst.AnimState ~= nil and (inst.IsValid == nil or inst:IsValid())
end

local function GetSelectedSkinName(inst)
    if inst ~= nil and inst.components ~= nil and inst.components.skinner ~= nil then
        local skin_name = inst.components.skinner.skin_name
        if skin_name ~= nil and skin_name ~= "" then
            return skin_name
        end
    end

    return "musha_none"
end

local function GetSkinDefaultBuild(inst, form)
    local skin_builds = SKIN_FORM_BUILDS[GetSelectedSkinName(inst)] or SKIN_FORM_BUILDS.musha_none
    return skin_builds[form]
end

local function UsesDefaultVisualSet(inst)
    if inst == nil or inst.visual_cos then
        return true
    end

    if inst.change_visual then
        return false
    end

    if not inst.set_on and not inst.visual_hold and not inst.visual_hold2 and not inst.visual_hold3 and not inst.visual_hold4 then
        return true
    end

    return inst.set_on and inst.visual_hold and not (inst.visual_hold2 and inst.visual_hold3 and inst.visual_hold4)
end

local function ResolveDefaultBuild(inst, build)
    local form = DEFAULT_BUILD_FORMS[build]
    if form ~= nil and UsesDefaultVisualSet(inst) then
        return GetSkinDefaultBuild(inst, form) or build
    end

    return build
end

function MushaAnim.SetBuild(inst, build)
    if HasAnimState(inst) and build ~= nil then
        build = ResolveDefaultBuild(inst, build)
        inst.AnimState:SetBuild(build)
        inst.musha_current_build = build
        return true
    end
    return false
end

function MushaAnim.SetBuildLater(inst, build, delay)
    if inst == nil or build == nil then
        return
    end
    inst:DoTaskInTime(delay or 0, function()
        MushaAnim.SetBuild(inst, build)
    end)
end

function MushaAnim.GetBuildForForm(inst, form)
    local builds = FORM_BUILDS[form]
    if builds == nil then
        return nil
    end

    if inst == nil or inst.visual_cos then
        return GetSkinDefaultBuild(inst, form) or builds.default
    end

    if inst.change_visual then
        return nil
    end

    if not inst.set_on and not inst.visual_hold and not inst.visual_hold2 and not inst.visual_hold3 and not inst.visual_hold4 then
        return GetSkinDefaultBuild(inst, form) or builds.default
    elseif inst.set_on and inst.visual_hold and not (inst.visual_hold2 and inst.visual_hold3 and inst.visual_hold4) then
        return GetSkinDefaultBuild(inst, form) or builds.default
    elseif inst.set_on and inst.visual_hold2 and not (inst.visual_hold and inst.visual_hold3 and inst.visual_hold4) then
        return builds.set2
    elseif inst.set_on and inst.visual_hold3 and not (inst.visual_hold and inst.visual_hold2 and inst.visual_hold4) then
        return builds.set3
    elseif inst.set_on and inst.visual_hold4 and inst.visual_hold and inst.visual_hold2 and inst.visual_hold3 then
        return builds.set4
    end
end

function MushaAnim.ApplyFormBuild(inst, form)
    return MushaAnim.SetBuild(inst, MushaAnim.GetBuildForForm(inst, form))
end

function MushaAnim.GetCurrentForm(inst)
    if inst == nil then
        return "normal"
    elseif inst.strength == "berserk" or inst.berserk or inst.fberserk or inst.berserks then
        return "berserk"
    elseif inst.strength == "valkyrie" or inst.valkyrie then
        return "valkyrie"
    elseif inst.strength == "full" then
        return "full"
    end

    local hunger = inst.components ~= nil and inst.components.hunger or nil
    if hunger ~= nil and hunger.current ~= nil and hunger.current >= 160 then
        return "full"
    end

    return "normal"
end

function MushaAnim.ApplyCurrentFormBuild(inst)
    return MushaAnim.ApplyFormBuild(inst, MushaAnim.GetCurrentForm(inst))
end

function MushaAnim.ApplyCurrentFormBuildLater(inst, delay)
    if inst ~= nil then
        inst:DoTaskInTime(delay or 0, function()
            if inst:IsValid() and not inst:HasTag("playerghost") then
                MushaAnim.ApplyCurrentFormBuild(inst)
            end
        end)
    end
end

function MushaAnim.ApplyHeldSymbol(inst, symbol_build, symbol_name)
    if not HasAnimState(inst) or symbol_build == nil or symbol_name == nil then
        return false
    end

    inst.AnimState:OverrideSymbol("swap_object", symbol_build, symbol_name)
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")
    return true
end

function MushaAnim.OverrideSymbol(inst, symbol, symbol_build, symbol_name)
    if not HasAnimState(inst) or symbol == nil or symbol_build == nil or symbol_name == nil then
        return false
    end

    inst.AnimState:OverrideSymbol(symbol, symbol_build, symbol_name)
    return true
end

function MushaAnim.ApplyFrostHammerSymbol(inst, is_boosted)
    return MushaAnim.ApplyHeldSymbol(inst, is_boosted and "swap_frosthammer2" or "swap_frosthammer", "frosthammer")
end

function MushaAnim.AddOverrideBuilds(inst, builds)
    if not HasAnimState(inst) or builds == nil then
        return
    end

    for _, build in ipairs(builds) do
        inst.AnimState:AddOverrideBuild(build)
    end
end

return MushaAnim
