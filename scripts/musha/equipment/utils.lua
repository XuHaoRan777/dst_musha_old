local EquipUtils = {}

local EXTRA_BACK_SLOT_NAMES =
{
    "BACK",
    "PACK",
    "BACKPACK",
    "BAG",
}

EquipUtils.EXTRA_BACK_SLOT_NAMES = EXTRA_BACK_SLOT_NAMES

local function IsBackpackLikeItem(item)
    return item ~= nil
        and ((item.components ~= nil and item.components.container ~= nil)
            or (item.HasTag ~= nil and item:HasTag("backpack")))
end

function EquipUtils.GetEquippedExtraBackpack(owner)
    local inventory = owner ~= nil and owner.components ~= nil and owner.components.inventory or nil
    if inventory == nil then
        return nil
    end

    for _, slot_name in ipairs(EXTRA_BACK_SLOT_NAMES) do
        local slot = EQUIPSLOTS[slot_name]
        local item = slot ~= nil and inventory:GetEquippedItem(slot) or nil
        if IsBackpackLikeItem(item) then
            return item
        end
    end

    return nil
end

function EquipUtils.HasEquippedExtraBackpack(owner)
    return EquipUtils.GetEquippedExtraBackpack(owner) ~= nil
end

function EquipUtils.ShouldAutoOpenArmorContainer(owner)
    return not EquipUtils.HasEquippedExtraBackpack(owner)
end

return EquipUtils
