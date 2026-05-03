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

EquipUtils.IsBackpackLikeItem = IsBackpackLikeItem

function EquipUtils.IsSewingMannequin(owner)
    return owner ~= nil
        and (owner.prefab == "sewing_mannequin"
            or (owner.HasTag ~= nil and owner:HasTag("sewing_mannequin")))
end

function EquipUtils.CanWearMushaItem(owner)
    return owner ~= nil
        and ((owner.HasTag ~= nil and owner:HasTag("musha"))
            or EquipUtils.IsSewingMannequin(owner))
end

function EquipUtils.ShouldRejectMushaItemWearer(inst, owner)
    return inst ~= nil
        and not inst.share_item
        and owner ~= nil
        and not EquipUtils.CanWearMushaItem(owner)
        and owner.components ~= nil
        and owner.components.inventory ~= nil
end

function EquipUtils.HasSanity(owner)
    return owner ~= nil
        and owner.components ~= nil
        and owner.components.sanity ~= nil
end

function EquipUtils.HasSanityAtLeast(owner, value)
    return EquipUtils.HasSanity(owner)
        and owner.components.sanity.current >= value
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
