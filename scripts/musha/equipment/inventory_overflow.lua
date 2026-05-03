local FrostArmorVisibility = {}

local EquipUtils = require("musha/equipment/utils")
local G = nil

local function IsFrostArmor(item)
	return item ~= nil and item.prefab == "broken_frosthammer"
end

local function GetEquippedFrostArmor(owner)
	local inventory = owner ~= nil and owner.components ~= nil and owner.components.inventory or nil
	if inventory == nil then
		return nil
	end
	local bodyitem = inventory:GetEquippedItem(G.EQUIPSLOTS.BODY)
	return IsFrostArmor(bodyitem) and bodyitem or nil
end

local function IsOpenableContainer(item)
	return item ~= nil
		and item.components ~= nil
		and item.components.container ~= nil
end

local function OpenContainer(item, owner)
	if IsOpenableContainer(item) and owner ~= nil then
		item.components.container:Open(owner)
	end
end

local function CloseContainer(item, owner)
	if IsOpenableContainer(item) then
		item.components.container:Close(owner)
	end
end

local function CloseFrostArmor(owner)
	CloseContainer(GetEquippedFrostArmor(owner), owner)
end

local function IsEquippedExtraBackpackOpen(owner)
	local inventory = owner ~= nil and owner.components ~= nil and owner.components.inventory or nil
	local backpack = EquipUtils.GetEquippedExtraBackpack(owner)
	return inventory ~= nil
		and inventory.opencontainers ~= nil
		and backpack ~= nil
		and inventory.opencontainers[backpack] ~= nil
end

local function OpenFrostArmorIfNoOpenBackpack(owner)
	if owner == nil or IsEquippedExtraBackpackOpen(owner) then
		return
	end
	OpenContainer(GetEquippedFrostArmor(owner), owner)
end

local function IsExtraBackSlot(eslot)
	for _, slot_name in ipairs(EquipUtils.EXTRA_BACK_SLOT_NAMES) do
		if G.EQUIPSLOTS[slot_name] ~= nil and G.EQUIPSLOTS[slot_name] == eslot then
			return true
		end
	end
	return false
end

local function IsEquippedExtraBackpack(owner, item, eslot)
	return item ~= nil
		and EquipUtils.IsBackpackLikeItem(item)
		and (IsExtraBackSlot(eslot) or EquipUtils.GetEquippedExtraBackpack(owner) == item)
end

local function WatchPlayer(owner)
	if owner == nil or owner._musha_frost_visibility_watched then
		return
	end
	owner._musha_frost_visibility_watched = true

	owner:ListenForEvent("equip", function(inst, data)
		if data ~= nil and IsEquippedExtraBackpack(inst, data.item, data.eslot) then
			CloseFrostArmor(inst)
		elseif data ~= nil and IsFrostArmor(data.item) then
			inst:DoTaskInTime(0, OpenFrostArmorIfNoOpenBackpack)
		end
	end)

	owner:ListenForEvent("unequip", function(inst, data)
		if data ~= nil and (IsExtraBackSlot(data.eslot) or EquipUtils.IsBackpackLikeItem(data.item)) then
			inst:DoTaskInTime(0, OpenFrostArmorIfNoOpenBackpack)
		end
	end)

	owner:ListenForEvent("opencontainer", function(inst, data)
		if data ~= nil and EquipUtils.GetEquippedExtraBackpack(inst) == data.container then
			CloseFrostArmor(inst)
		end
	end)

	owner:ListenForEvent("closecontainer", function(inst, data)
		if data ~= nil and EquipUtils.GetEquippedExtraBackpack(inst) == data.container then
			inst:DoTaskInTime(0, OpenFrostArmorIfNoOpenBackpack)
		end
	end)
end

function FrostArmorVisibility.Register(env)
	G = env.GLOBAL

	env.AddPlayerPostInit(function(inst)
		if G.TheWorld ~= nil and G.TheWorld.ismastersim then
			WatchPlayer(inst)
		end
	end)
end

return FrostArmorVisibility
