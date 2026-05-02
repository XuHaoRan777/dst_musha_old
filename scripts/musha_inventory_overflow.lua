local InventoryOverflow = {}

local EquipUtils = require("musha_equiputils")
local G = nil
local debuglib = nil

local CLASSIFIED_OVERFLOW_FUNCTIONS =
{
	"Has",
	"UseItemFromInvTile",
	"ControllerUseItemOnItemFromInvTile",
	"ControllerUseItemOnSelfFromInvTile",
	"ControllerUseItemOnSceneFromInvTile",
	"ReceiveItem",
	"RemoveIngredients",
}

local CLASSIFIED_MOVE_FUNCTIONS =
{
	"MoveItemFromAllOfSlot",
	"MoveItemFromHalfOfSlot",
	"MoveItemFromCountOfSlot",
}

local function SetUpvalue(fn, name, new_value)
	if fn == nil or debuglib == nil then
		return false
	end

	local index = 1
	while true do
		local upvalue_name = debuglib.getupvalue(fn, index)
		if upvalue_name == name then
			debuglib.setupvalue(fn, index, new_value)
			return true
		elseif upvalue_name == nil then
			return false
		end
		index = index + 1
	end
end

local function IsContainerFull(container)
	if container == nil then
		return true
	end
	if container.IsFull ~= nil then
		return container:IsFull()
	end
	if container.GetNumSlots ~= nil and container.GetItemInSlot ~= nil then
		for slot = 1, container:GetNumSlots() do
			if container:GetItemInSlot(slot) == nil then
				return false
			end
		end
		return true
	end
	return false
end

local function GetStackable(item)
	return item ~= nil
		and ((item.components ~= nil and item.components.stackable)
			or (item.replica ~= nil and item.replica.stackable))
		or nil
end

local function ContainerAcceptsStacks(container)
	return container.AcceptsStacks == nil or container:AcceptsStacks()
end

local function CanStackContainerItem(container, slotitem, item)
	local stackable = GetStackable(slotitem)
	return stackable ~= nil
		and ContainerAcceptsStacks(container)
		and stackable.CanStackWith ~= nil
		and stackable:CanStackWith(item)
		and (stackable.IsFull == nil or not stackable:IsFull())
end

local function CanContainerTakeItem(container, item)
	if container == nil or item == nil then
		return false
	end
	if container.CanTakeItemInSlot == nil or container.GetNumSlots == nil then
		return not IsContainerFull(container)
	end
	for slot = 1, container:GetNumSlots() do
		local slotitem = container.GetItemInSlot ~= nil and container:GetItemInSlot(slot) or nil
		if slotitem ~= nil and CanStackContainerItem(container, slotitem, item) then
			return true
		elseif slotitem == nil and container:CanTakeItemInSlot(item, slot) then
			return true
		end
	end
	return false
end

local function IsFrostArmor(item)
	return item ~= nil and item.prefab == "broken_frosthammer"
end

local function IsOpenServerContainer(inventory, item)
	return inventory ~= nil
		and inventory.opencontainers ~= nil
		and item ~= nil
		and item.components ~= nil
		and item.components.container ~= nil
		and inventory.opencontainers[item] ~= nil
end

local function IsAvailableServerContainer(inventory, item)
	return IsOpenServerContainer(inventory, item)
		and not IsContainerFull(item.components.container)
end

local function GetOpenServerContainer(inventory, item)
	return IsOpenServerContainer(inventory, item) and item.components.container or nil
end

local function IsOpenReplicaContainer(item)
	return item ~= nil
		and item.replica ~= nil
		and item.replica.container ~= nil
		and item.replica.container.opener ~= nil
end

local function IsAvailableReplicaContainer(item)
	return IsOpenReplicaContainer(item)
		and not IsContainerFull(item.replica.container)
end

local function GetServerOverflowContainer(inventory)
	if inventory.ignoreoverflow then
		return
	end

	if inventory.inst ~= nil and inventory.inst:HasTag("player") then
		local backitem = EquipUtils.GetEquippedExtraBackpack(inventory.inst)
		if IsAvailableServerContainer(inventory, backitem) then
			return backitem.components.container
		end

		local bodyitem = inventory:GetEquippedItem(G.EQUIPSLOTS.BODY)
		if IsFrostArmor(bodyitem) and IsAvailableServerContainer(inventory, bodyitem) then
			return bodyitem.components.container
		end
	end
end

local function GetServerFrostArmorContainer(inventory)
	if inventory == nil or inventory.inst == nil or not inventory.inst:HasTag("player") then
		return nil
	end
	local bodyitem = inventory:GetEquippedItem(G.EQUIPSLOTS.BODY)
	return IsFrostArmor(bodyitem) and GetOpenServerContainer(inventory, bodyitem) or nil
end

local function GetServerBackpackContainer(inventory)
	if inventory == nil or inventory.inst == nil or not inventory.inst:HasTag("player") then
		return nil
	end
	return GetOpenServerContainer(inventory, EquipUtils.GetEquippedExtraBackpack(inventory.inst))
end

local function GetClassifiedEquippedItem(classified, equipslot)
	if classified.GetEquippedItem ~= nil then
		return classified.GetEquippedItem(classified, equipslot)
	end
end

local function GetReplicaEquippedItem(inventory, slot_name)
	local slot = G.EQUIPSLOTS[slot_name]
	return slot ~= nil and inventory ~= nil and inventory.GetEquippedItem ~= nil and inventory:GetEquippedItem(slot) or nil
end

local function GetReplicaExtraBackpack(inventory)
	for _, slot_name in ipairs(EquipUtils.EXTRA_BACK_SLOT_NAMES) do
		local item = GetReplicaEquippedItem(inventory, slot_name)
		if item ~= nil and item.replica ~= nil and item.replica.container ~= nil then
			return item
		end
	end
end

local function GetReplicaFrostArmor(inventory)
	local bodyitem = GetReplicaEquippedItem(inventory, "BODY")
	return IsFrostArmor(bodyitem) and bodyitem or nil
end

local function GetClassifiedOverflowContainer(classified)
	for _, slot_name in ipairs(EquipUtils.EXTRA_BACK_SLOT_NAMES) do
		local slot = G.EQUIPSLOTS[slot_name]
		if slot ~= nil then
			local backitem = GetClassifiedEquippedItem(classified, slot)
			if IsAvailableReplicaContainer(backitem) then
				return backitem.replica.container
			end
		end
	end

	local bodyitem = GetClassifiedEquippedItem(classified, G.EQUIPSLOTS.BODY)
	if IsFrostArmor(bodyitem) and IsAvailableReplicaContainer(bodyitem) then
		return bodyitem.replica.container
	end
end

local function RedirectServerDestination(inventory, item, container)
	if inventory == nil
		or item == nil
	then
		return container
	end

	local backpack = EquipUtils.GetEquippedExtraBackpack(inventory.inst)
	local frostarmor = inventory:GetEquippedItem(G.EQUIPSLOTS.BODY)
	if backpack ~= nil
		and backpack ~= container
		and IsFrostArmor(container)
		and IsOpenServerContainer(inventory, backpack)
		and CanContainerTakeItem(backpack.components.container, item)
	then
		return backpack
	end

	if backpack ~= nil
		and backpack == container
		and IsFrostArmor(frostarmor)
		and IsOpenServerContainer(inventory, frostarmor)
		and not CanContainerTakeItem(backpack.components.container, item)
		and CanContainerTakeItem(frostarmor.components.container, item)
	then
		return frostarmor
	end

	return container
end

local function RedirectClassifiedDestination(classified, item, container)
	if classified == nil
		or item == nil
		or not IsFrostArmor(container)
	then
		return container
	end

	for _, slot_name in ipairs(EquipUtils.EXTRA_BACK_SLOT_NAMES) do
		local slot = G.EQUIPSLOTS[slot_name]
		if slot ~= nil then
			local backitem = GetClassifiedEquippedItem(classified, slot)
			if backitem ~= nil
				and backitem ~= container
				and IsOpenReplicaContainer(backitem)
				and CanContainerTakeItem(backitem.replica.container, item)
			then
				return backitem
			end
		end
	end

	return container
end

local function IsWritableOpenContainer(inst)
	return inst ~= nil
		and inst.replica ~= nil
		and inst.replica.container ~= nil
		and (inst.replica.container.IsReadOnlyContainer == nil or not inst.replica.container:IsReadOnlyContainer())
end

local function HasOtherWritableOpenContainer(inventory, backpack, frostarmor)
	if inventory == nil or inventory.GetOpenContainers == nil then
		return false
	end
	for opencontainer in pairs(inventory:GetOpenContainers()) do
		if opencontainer ~= backpack
			and opencontainer ~= frostarmor
			and IsWritableOpenContainer(opencontainer)
		then
			return true
		end
	end
	return false
end

local function GetPreferredShiftClickContainer(inventory, item)
	if inventory == nil or item == nil then
		return nil
	end

	local backpack = GetReplicaExtraBackpack(inventory)
	local frostarmor = GetReplicaFrostArmor(inventory)
	if frostarmor == nil or HasOtherWritableOpenContainer(inventory, backpack, frostarmor) then
		return nil
	end

	if backpack ~= nil
		and backpack ~= frostarmor
		and IsOpenReplicaContainer(backpack)
		and CanContainerTakeItem(backpack.replica.container, item)
	then
		return backpack
	end

	if IsOpenReplicaContainer(frostarmor) and CanContainerTakeItem(frostarmor.replica.container, item) then
		return frostarmor
	end
end

local function ShouldPreferFrostArmor(inventory, item, slot)
	if inventory == nil
		or item == nil
		or slot ~= nil
		or inventory.inst == nil
		or not inventory.inst:HasTag("player")
	then
		return false
	end

	if inventory.IsFull ~= nil and not inventory:IsFull() then
		return false
	end

	local backpack = GetServerBackpackContainer(inventory)
	if CanContainerTakeItem(backpack, item) then
		return false
	end

	return CanContainerTakeItem(GetServerFrostArmorContainer(inventory), item)
end

local function TryGiveToFrostArmor(inventory, item, slot, src_pos)
	local frost_container = GetServerFrostArmorContainer(inventory)
	if CanContainerTakeItem(frost_container, item) then
		return frost_container:GiveItem(item, slot, src_pos)
	end
	return false
end

local function IsValidInventoryItem(item)
	return item ~= nil
		and item.IsValid ~= nil
		and item:IsValid()
		and item.components ~= nil
		and item.components.inventoryitem ~= nil
end

local function PatchInventory(inventory, force)
	if inventory == nil then
		return
	end
	if not force
		and inventory._musha_overflow_get_wrapper ~= nil
		and inventory.GetOverflowContainer == inventory._musha_overflow_get_wrapper
		and inventory._musha_overflow_give_wrapper ~= nil
		and inventory.GiveItem == inventory._musha_overflow_give_wrapper
	then
		return
	end

	local old_get_overflow_container = inventory._musha_overflow_original_get or inventory.GetOverflowContainer
	local old_give_item = inventory._musha_overflow_original_give or inventory.GiveItem
	local old_move_all = inventory._musha_overflow_original_move_all or inventory.MoveItemFromAllOfSlot
	local old_move_half = inventory._musha_overflow_original_move_half or inventory.MoveItemFromHalfOfSlot
	local old_move_count = inventory._musha_overflow_original_move_count or inventory.MoveItemFromCountOfSlot

	inventory._musha_overflow_original_get = old_get_overflow_container
	inventory._musha_overflow_original_give = old_give_item
	inventory._musha_overflow_original_move_all = old_move_all
	inventory._musha_overflow_original_move_half = old_move_half
	inventory._musha_overflow_original_move_count = old_move_count

	local get_wrapper = function(self_inner)
		local container = GetServerOverflowContainer(self_inner)
		if container ~= nil then
			return container
		end

		if old_get_overflow_container ~= nil then
			local fallback = old_get_overflow_container(self_inner)
			if fallback ~= nil and not IsContainerFull(fallback) then
				return fallback
			end
		end
	end

	local give_wrapper = function(self_inner, item, slot, src_pos, ...)
		if IsValidInventoryItem(item) and ShouldPreferFrostArmor(self_inner, item, slot) then
			local result = TryGiveToFrostArmor(self_inner, item, slot, src_pos)
			if result then
				return result
			end
		end

		local result = old_give_item(self_inner, item, slot, src_pos, ...)
		if result then
			return result
		end

		if IsValidInventoryItem(item) then
			return TryGiveToFrostArmor(self_inner, item, slot, src_pos)
		end
		return result
	end

	local move_all_wrapper = function(self_inner, slot, container, ...)
		local item = self_inner.GetItemInSlot ~= nil and self_inner:GetItemInSlot(slot) or nil
		if old_move_all ~= nil then
			return old_move_all(self_inner, slot, RedirectServerDestination(self_inner, item, container), ...)
		end
	end

	local move_half_wrapper = function(self_inner, slot, container, ...)
		local item = self_inner.GetItemInSlot ~= nil and self_inner:GetItemInSlot(slot) or nil
		if old_move_half ~= nil then
			return old_move_half(self_inner, slot, RedirectServerDestination(self_inner, item, container), ...)
		end
	end

	local move_count_wrapper = function(self_inner, slot, container, count, ...)
		local item = self_inner.GetItemInSlot ~= nil and self_inner:GetItemInSlot(slot) or nil
		if old_move_count ~= nil then
			return old_move_count(self_inner, slot, RedirectServerDestination(self_inner, item, container), count, ...)
		end
	end

	inventory._musha_overflow_get_wrapper = get_wrapper
	inventory._musha_overflow_give_wrapper = give_wrapper
	inventory.GetOverflowContainer = get_wrapper
	inventory.GiveItem = give_wrapper
	inventory.MoveItemFromAllOfSlot = move_all_wrapper
	inventory.MoveItemFromHalfOfSlot = move_half_wrapper
	inventory.MoveItemFromCountOfSlot = move_count_wrapper
end

local function PatchInventoryClassified(classified)
	if classified == nil or classified._musha_overflow_patched then
		return
	end

	classified._musha_overflow_patched = true
	for _, fn_name in ipairs(CLASSIFIED_OVERFLOW_FUNCTIONS) do
		if type(classified[fn_name]) == "function" then
			SetUpvalue(classified[fn_name], "GetOverflowContainer", GetClassifiedOverflowContainer)
		end
	end

	classified.GetOverflowContainer = GetClassifiedOverflowContainer

	for _, fn_name in ipairs(CLASSIFIED_MOVE_FUNCTIONS) do
		local old_fn = classified[fn_name]
		if type(old_fn) == "function" then
			classified[fn_name] = function(inst, slot, container, ...)
				local item = inst.GetItemInSlot ~= nil and inst:GetItemInSlot(slot) or nil
				return old_fn(inst, slot, RedirectClassifiedDestination(inst, item, container), ...)
			end
		end
	end
end

local function PatchInvSlot(InvSlot)
	if InvSlot == nil or InvSlot._musha_overflow_trade_patched then
		return
	end

	InvSlot._musha_overflow_trade_patched = true
	local old_trade_item = InvSlot.TradeItem
	InvSlot.TradeItem = function(self, stack_mod, ...)
		local character = self.owner
		local inventory = character ~= nil and character.replica ~= nil and character.replica.inventory or nil
		local container = self.container
		local slot_number = self.num
		local container_item = container ~= nil
			and container == inventory
			and (container.IsReadOnlyContainer == nil or not container:IsReadOnlyContainer())
			and container:GetItemInSlot(slot_number)
			or nil

		local dest_inst = GetPreferredShiftClickContainer(inventory, container_item)
		if dest_inst ~= nil then
			if stack_mod
				and container_item.replica ~= nil
				and container_item.replica.stackable ~= nil
				and container_item.replica.stackable:IsStack()
			then
				container:MoveItemFromHalfOfSlot(slot_number, dest_inst)
			elseif container_item.replica ~= nil
				and container_item.replica.inventoryitem ~= nil
				and container_item.replica.inventoryitem:IsLockedInSlot()
			then
				G.TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
				return true
			else
				container:MoveItemFromAllOfSlot(slot_number, dest_inst)
			end
			G.TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
			return true
		end

		return old_trade_item(self, stack_mod, ...)
	end
end

function InventoryOverflow.Register(env)
	G = env.GLOBAL
	debuglib = G.debug

	env.AddComponentPostInit("inventory", function(self)
		PatchInventory(self, false)
	end)

	env.AddPlayerPostInit(function(inst)
		if G.TheWorld ~= nil and G.TheWorld.ismastersim then
			inst:DoTaskInTime(0, function()
				PatchInventory(inst.components ~= nil and inst.components.inventory or nil, true)
			end)
			inst:DoTaskInTime(1, function()
				PatchInventory(inst.components ~= nil and inst.components.inventory or nil, true)
			end)
		end
	end)

	env.AddPrefabPostInit("inventory_classified", function(inst)
		inst:DoTaskInTime(0, function()
			PatchInventoryClassified(inst)
		end)
	end)

	if env.AddClassPostConstruct ~= nil then
		env.AddClassPostConstruct("widgets/invslot", PatchInvSlot)
	end
end

InventoryOverflow._private =
{
	GetServerOverflowContainer = GetServerOverflowContainer,
	GetClassifiedOverflowContainer = GetClassifiedOverflowContainer,
}

return InventoryOverflow
