local function IsMushaCompanion(picker)
	return picker ~= nil and
		(picker:HasTag("yamcheb") or picker.critter_musha)
end

local function SpawnCompanionProductLoot(pickable, picker, SpawnPrefab)
	local container = picker.components.container
	local lootdropper = pickable.inst.components.lootdropper
	local position = pickable.inst:GetPosition()
	local loot

	if pickable.droppicked and lootdropper ~= nil then
		position.y = position.y + (pickable.dropheight or 0)
		if pickable.use_lootdropper_for_product then
			lootdropper:DropLoot(position)
		else
			for _ = 1, pickable.numtoharvest or 1 do
				lootdropper:SpawnLootPrefab(pickable.product, position)
			end
		end
	elseif pickable.use_lootdropper_for_product and lootdropper ~= nil then
		loot = {}
		for _, prefab in ipairs(lootdropper:GenerateLoot()) do
			local item = lootdropper:SpawnLootPrefab(prefab)
			if item ~= nil then
				table.insert(loot, item)
			end
		end

		if #loot > 0 then
			picker:PushEvent("picksomething", { object = pickable.inst, loot = loot })
		end

		for _, item in ipairs(loot) do
			if item.components.inventoryitem ~= nil then
				container:GiveItem(item, nil, position)
			else
				item.Transform:SetPosition(position:Get())
			end
		end
	elseif pickable.product ~= nil then
		loot = SpawnPrefab(pickable.product)
		if loot ~= nil then
			if loot.components.inventoryitem ~= nil then
				loot.components.inventoryitem:InheritWorldWetnessAtTarget(pickable.inst)
			end
			if pickable.numtoharvest > 1 and loot.components.stackable ~= nil then
				loot.components.stackable:SetStackSize(pickable.numtoharvest)
			end
			picker:PushEvent("picksomething", { object = pickable.inst, loot = loot })
			if loot.components.inventoryitem ~= nil then
				container:GiveItem(loot, nil, position)
			else
				loot.Transform:SetPosition(position:Get())
			end
		end
	end

	return loot
end

local function Register(AddComponentPostInit, SpawnPrefab)
	AddComponentPostInit("pickable", function(pickable)
		local SpawnProductLoot = pickable.SpawnProductLoot
		pickable.SpawnProductLoot = function(self, picker)
			if IsMushaCompanion(picker) then
				local container = picker.components.container
				if container ~= nil and (self.product ~= nil or self.use_lootdropper_for_product) then
					return SpawnCompanionProductLoot(self, picker, SpawnPrefab)
				end
				return nil
			end

			return SpawnProductLoot(self, picker)
		end
	end)
end

return {
	Register = Register,
}
