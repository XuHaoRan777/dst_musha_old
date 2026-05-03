local ArongLoyalty = {}

function ArongLoyalty.IsMushaOrPlayerAttacker(attacker)
    return attacker ~= nil
        and (attacker:HasTag("musha") or attacker:HasTag("player"))
end

function ArongLoyalty.ClearCombatTarget(inst)
    if inst.components.combat ~= nil then
        inst.components.combat:SetTarget(nil)
        inst.components.combat:GiveUp()
    end
end

function ArongLoyalty.ApplyPermanent(inst)
    inst._arong_permanent_loyalty = true

    if inst.components.domesticatable ~= nil then
        inst.components.domesticatable:SetMinObedience(1)
        inst.components.domesticatable:DeltaObedience(1)
        inst.components.domesticatable:PauseDomesticationDecay(true)
    end

    if inst.components.rideable ~= nil then
        inst.components.rideable:SetRequiredObedience(0)
        inst.components.rideable:SetSaddleable(true)
    end
end

return ArongLoyalty
