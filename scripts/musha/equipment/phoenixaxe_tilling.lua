local Tilling = {}

local OFFSETS = { -1 / 3, 0, 1 / 3 }

local function IsPhoenixAxe(inst)
	return inst ~= nil
		and inst.prefab == "mushasword4"
		and inst:HasTag("phoenix_axe")
		and inst.broken ~= true
end

local function IsEquippedBy(inst, doer, context)
	if not IsPhoenixAxe(inst) or doer == nil or doer.prefab ~= "musha" then
		return false
	end

	local inventory = doer.components ~= nil and doer.components.inventory
		or doer.replica ~= nil and doer.replica.inventory
	return inventory ~= nil and inventory:GetEquippedItem(context.equipslots.HANDS) == inst
end

local function IsInsideTile(x, z, cx, cz, tile_scale)
	local half = tile_scale * 0.5 - 0.001
	return math.abs(x - cx) <= half and math.abs(z - cz) <= half
end

local function TillNinePoints(self, pt, doer, context, native_till)
	local map = context.map
	if pt == nil or not map:IsFarmableSoilAtPoint(pt.x, pt.y or 0, pt.z) then
		return native_till(self, pt, doer)
	end

	local cx, _, cz = map:GetTileCenterPoint(pt.x, pt.y or 0, pt.z)
	local tile_scale = context.tile_scale
	local existing = context.sim:FindEntities(cx, 0, cz, tile_scale * 0.75, { "soil" }, { "INLIMBO" })
	for _, soil in ipairs(existing) do
		if soil:IsValid() and soil.prefab == "farm_soil" then
			local x, _, z = soil.Transform:GetWorldPosition()
			if IsInsideTile(x, z, cx, cz, tile_scale) then
				soil:Remove()
			end
		end
	end

	local tilled = 0
	for _, dx in ipairs(OFFSETS) do
		for _, dz in ipairs(OFFSETS) do
			local point = context.vector3(cx + dx * tile_scale, 0, cz + dz * tile_scale)
			if map:CanTillSoilAtPoint(point.x, point.y, point.z, false) then
				local soil = context.spawnprefab("farm_soil")
				if soil ~= nil then
					soil.Transform:SetPosition(point:Get())
					tilled = tilled + 1
				end
			end
		end
	end

	if tilled > 0 then
		doer:PushEvent("tilling")
	end
	return true
end

function Tilling.Attach(inst, context)
	if context.enabled ~= true or inst.components.farmtiller ~= nil then
		return
	end

	inst:AddComponent("farmtiller")
	local component = inst.components.farmtiller
	local native_till = component.Till
	component.Till = function(self, pt, doer)
		if not IsEquippedBy(inst, doer, context) or pt == nil then
			return false
		end
		if not context.map:IsFarmableSoilAtPoint(pt.x, pt.y or 0, pt.z) then
			return native_till(self, pt, doer)
		end
		return TillNinePoints(self, pt, doer, context, native_till)
	end
end

function Tilling.Detach(inst)
	if inst.components.farmtiller ~= nil then
		inst:RemoveComponent("farmtiller")
	end
end

function Tilling.Register(context)
	context.addcomponentaction("POINT", "spellcaster", function(inst, doer, pos, actions, right, target)
		local map = context.getmap()
		if not right
			or context.enabled ~= true
			or map == nil
			or not IsPhoenixAxe(inst)
			or not IsEquippedBy(inst, doer, context)
			or not map:IsFarmableSoilAtPoint(pos.x, pos.y or 0, pos.z) then
			return
		end

		if target ~= nil and target:IsValid()
			and (target:HasTag("farm_plant")
				or target.components ~= nil and (target.components.pickable ~= nil or target.components.harvestable ~= nil)) then
			return
		end

		local has_till = false
		for _, action in ipairs(actions) do
			if action == context.actions.TILL then
				has_till = true
			end
		end

		for index = #actions, 1, -1 do
			if actions[index] == context.actions.CASTSPELL then
				table.remove(actions, index)
			end
		end
		if not has_till then
			table.insert(actions, context.actions.TILL)
		end
	end)
end

return Tilling
