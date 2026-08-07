local FrostHammerMode = {}

local TENTACLE_LEVEL = 2200

FrostHammerMode.TENTACLE_LEVEL = TENTACLE_LEVEL

function FrostHammerMode.GetAreaDamage(strength, is_frost_hammer, boost)
    if strength == "berserk" then
        return is_frost_hammer and not boost and 4 or 2.5, 0.5
    elseif is_frost_hammer then
        return boost and 1.5 or 2, 0.5
    end

    return 0, 0
end

function FrostHammerMode.SyncCombatArea(owner, weapon)
    if owner == nil or owner.components == nil or owner.components.combat == nil then
        return
    end

    if weapon ~= nil
        and (weapon.components == nil
            or weapon.components.equippable == nil
            or not weapon.components.equippable:IsEquipped()) then
        return
    end

    local combat = owner.components.combat
    local is_frost_hammer = weapon ~= nil
        and not weapon.broken
        and weapon:HasTag("frost_hammer")
    local area_range, area_multiplier = FrostHammerMode.GetAreaDamage(
        owner.strength,
        is_frost_hammer,
        weapon ~= nil and weapon.boost == true)

    local hit_check = owner.strength == "berserk" and combat.areahitcheckfn or nil
    combat:SetAreaDamage(area_range, area_multiplier, hit_check)
end

function FrostHammerMode.SyncTentacleSpell(inst, summon_fn)
    if inst == nil or inst.components == nil then
        return
    end

    local enabled = summon_fn ~= nil
        and inst.boost == true
        and not inst.broken
        and (inst.level or 0) >= TENTACLE_LEVEL

    if enabled then
        if inst.components.spellcaster == nil then
            inst:AddComponent("spellcaster")
        end
        inst.components.spellcaster:SetSpellFn(summon_fn)
        inst.components.spellcaster.canuseonpoint = true
    elseif inst.components.spellcaster ~= nil then
        inst:RemoveComponent("spellcaster")
    end
end

return FrostHammerMode
