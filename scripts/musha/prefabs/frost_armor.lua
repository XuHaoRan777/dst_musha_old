local FrostArmor = {}
local EquipUtils = require("musha/equipment/utils")

function FrostArmor.OnBlocked(owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

function FrostArmor.OnOpen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
end

function FrostArmor.OpenContainer(inst, owner)
    if inst.components.container ~= nil and owner ~= nil then
        inst.components.container:Open(owner)
    end
end

function FrostArmor.CloseContainer(inst, owner)
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end

function FrostArmor.RefreshContainer(inst, owner)
    if EquipUtils.ShouldAutoOpenArmorContainer(owner) then
        FrostArmor.OpenContainer(inst, owner)
    else
        FrostArmor.CloseContainer(inst, owner)
    end
end

function FrostArmor.OnClose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
end

function FrostArmor.SanityCost(inst, owner)
    if not inst.components.heater and inst.shield then
        inst:AddComponent("heater")
    end
    if owner.components.sanity and inst.shield then
        owner.components.sanity:DoDelta(-1, false)
        inst.components.heater:SetThermics(false, true)
        inst.components.heater.equippedheat = -2
        inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    end
end

function FrostArmor.ConsumeFuel(inst)
    if not inst.broken and inst.shield then
        inst.components.fueled:DoDelta(-20000)
    end
    if inst.broken and inst.shield then
        inst.components.fueled:DoDelta(0)
    end
end

function FrostArmor.StartShield(inst, owner)
    if inst.shield and not inst.broken then
        inst.components.talker:Say(STRINGS.MUSHA_ITEM_SHIELD .. "\n" .. STRINGS.MUSHA_ARMOR .. "(100)\n" .. STRINGS.MUSHA_ITEM_COOL)
        inst.components.armor:InitCondition(99999999999999999999999999999999999999999999999999, 1)
        if inst.consume then
            inst.consume:Cancel()
            inst.consume = nil
        end
        inst.consume = inst:DoPeriodicTask(1, function() FrostArmor.ConsumeFuel(inst, owner) end)
    elseif inst.shield and inst.broken then
        inst.components.talker:Say(STRINGS.MUSHA_ITEM_SHIELD_BROKEN .. "\n" .. STRINGS.MUSHA_ARMOR .. "(0)")
        inst.components.armor:InitCondition(99999999999999999999999999999999999999999999999999, 0)
        if inst.consume then
            inst.consume:Cancel()
            inst.consume = nil
        end
    end
end

function FrostArmor.StopShield(inst, upgrade_armor)
    if inst.shield then
        inst.shield = false
        upgrade_armor(inst)
        if inst.consume then
            inst.consume:Cancel()
            inst.consume = nil
        end
    end
    if inst.components.heater then
        inst:RemoveComponent("heater")
    end
end

function FrostArmor.StopUsingShield(inst, data)
    local hat = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if hat and not (data.statename == "shell_idle" or data.statename == "shell_hit" or data.statename == "shell_enter") then
        inst.shield = false
        hat.components.useableitem:StopUsingItem()
    end
end

return FrostArmor
