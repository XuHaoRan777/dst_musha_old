package.path = "scripts/?.lua;" .. package.path

local callbacks = {}
local function AddComponentAction(actiontype, component, fn)
	callbacks[#callbacks + 1] = { actiontype = actiontype, component = component, fn = fn, modname = "test-mod" }
end

local Tilling = require("musha/equipment/phoenixaxe_tilling")
local TILL = {}
local CASTSPELL = {}
local map = {}
function map:IsFarmableSoilAtPoint() return true end
function map:GetTileCenterPoint() return 0, 0, 0 end
function map:CanTillSoilAtPoint(x, _, z)
	return not (math.abs(x) < 0.001 and math.abs(z + 4 / 3) < 0.001)
end

local function entity(prefab, x, z)
	local inst = { prefab = prefab, x = x, z = z, valid = true, tags = {} }
	function inst:IsValid() return self.valid end
	function inst:HasTag(tag) return self.tags[tag] == true end
	function inst:Remove() self.valid = false end
	inst.Transform = { GetWorldPosition = function() return inst.x, 0, inst.z end }
	return inst
end

local old_inside = entity("farm_soil", 0, 0)
local old_near_edge = entity("farm_soil", 1.99, 0)
local old_adjacent = entity("farm_soil", 2.01, 0)
local entities = { old_inside, old_near_edge, old_adjacent }
local sim = { spawned = {} }
function sim:FindEntities() return entities end

local context = {
	enabled = true,
	map = map,
	sim = sim,
	vector3 = function(x, y, z)
		return { x = x, y = y, z = z, Get = function(self) return self.x, self.y, self.z end }
	end,
	spawnprefab = function(prefab)
		local soil = entity(prefab, 0, 0)
		soil.Transform.SetPosition = function(_, x, _, z) soil.x, soil.z = x, z end
		sim.spawned[#sim.spawned + 1] = soil
		return soil
	end,
	tile_scale = 4,
	equipslots = { HANDS = "hands" },
	actions = { TILL = TILL, CASTSPELL = CASTSPELL },
	addcomponentaction = AddComponentAction,
	getmap = function() return map end,
}

local owner = { prefab = "musha", components = { inventory = {} }, events = {} }
local axe
function owner.components.inventory:GetEquippedItem() return axe end
function owner:PushEvent(event) self.events[event] = (self.events[event] or 0) + 1 end

axe = {
	prefab = "mushasword4",
	pick = true,
	components = { inventoryitem = { owner = owner } },
	tags = { phoenix_axe = true },
}
function axe:HasTag(tag) return self.tags[tag] == true end
function axe:AddComponent(name)
	assert(name == "farmtiller")
	self.components.farmtiller = {
		Till = function(_, pt)
			if not map:CanTillSoilAtPoint(pt.x, pt.y, pt.z, false) then return false end
			local soil = entity("farm_soil", pt.x, pt.z)
			sim.spawned[#sim.spawned + 1] = soil
			return true
		end,
	}
end
function axe:RemoveComponent(name) self.components[name] = nil end

Tilling.Attach(axe, context)
Tilling.Register(context)
local result = axe.components.farmtiller:Till({ x = 0, y = 0, z = 0 }, owner)
assert(result == true, "farm tile action should succeed")
assert(not old_inside.valid and not old_near_edge.valid, "old soil inside the target tile should be cleared")
assert(old_adjacent.valid, "soil in the neighboring tile should be preserved")
assert(#sim.spawned == 8, "one blocked grid coordinate should be skipped")
assert(owner.events.tilling == 1, "one batch should emit one tilling event")

local registered = callbacks[1]
assert(registered.actiontype == "POINT" and registered.component == "spellcaster")
assert(registered.modname == "test-mod", "registration should use the mod-scoped API wrapper")
local actions = { CASTSPELL }
registered.fn(axe, owner, { x = 0, y = 0, z = 0 }, actions, true, nil)
assert(#actions == 1 and actions[1] == TILL, "farm soil should replace summon with till action")

local crop = { components = { pickable = {} } }
function crop:IsValid() return true end
function crop:HasTag() return false end
actions = { CASTSPELL }
registered.fn(axe, owner, { x = 0, y = 0, z = 0 }, actions, true, crop)
assert(#actions == 1 and actions[1] == CASTSPELL, "crop interactions should not be replaced")

local other_action = {}
actions = { other_action, CASTSPELL }
registered.fn(axe, owner, { x = 0, y = 0, z = 0 }, actions, true, nil)
assert(#actions == 2 and actions[1] == other_action and actions[2] == TILL,
	"other native actions should survive while summon changes to till")

print("PASS phoenix axe tilling grid, reset bounds, blocked spots, event count, and action routing")
