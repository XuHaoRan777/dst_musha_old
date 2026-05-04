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

function EquipUtils.ApplyEquipSymbol(owner, inst, symbol, build, source_symbol)
    if owner == nil or owner.AnimState == nil then
        return
    end

    local skin_build = inst ~= nil and inst.GetSkinBuild ~= nil and inst:GetSkinBuild() or nil
    local source = source_symbol or symbol

    if skin_build ~= nil and skin_build ~= "" then
        owner.AnimState:OverrideItemSkinSymbol(symbol, skin_build, source, inst.GUID, build or source)
    else
        owner.AnimState:OverrideSymbol(symbol, build or source, source)
    end
end

function EquipUtils.ClearEquipSymbol(owner, symbol)
    if owner ~= nil and owner.AnimState ~= nil then
        owner.AnimState:ClearOverrideSymbol(symbol)
    end
end

function EquipUtils.ClearEquipTalker(item)
    if item ~= nil
        and item.components ~= nil
        and item.components.talker ~= nil
        and item.components.talker.ShutUp ~= nil
    then
        item.components.talker:ShutUp()
    end
end

function EquipUtils.GetTalkerGroup(item)
    local equippable = item ~= nil and item.components ~= nil and item.components.equippable or nil
    if equippable == nil then
        return nil
    end

    return equippable.equipslot
end

function EquipUtils.GetOwnerTalkerState(owner)
    if owner == nil then
        return nil
    end

    if owner._musha_talker_state == nil then
        owner._musha_talker_state = {}
    end

    return owner._musha_talker_state
end

function EquipUtils.PrepareEquipTalker(item, owner)
    local group = EquipUtils.GetTalkerGroup(item)
    local state = EquipUtils.GetOwnerTalkerState(owner)
    if group == nil or state == nil then
        return
    end

    local active = state[group]
    if active ~= nil and active ~= item then
        EquipUtils.ClearEquipTalker(active)
    end

    state[group] = item
end

function EquipUtils.ReleaseEquipTalker(item, owner)
    local group = EquipUtils.GetTalkerGroup(item)
    local state = owner ~= nil and owner._musha_talker_state or nil
    if group ~= nil and state ~= nil and state[group] == item then
        state[group] = nil
    end
    EquipUtils.ClearEquipTalker(item)
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
