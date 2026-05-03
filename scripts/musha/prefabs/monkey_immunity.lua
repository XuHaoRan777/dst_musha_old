local MonkeyImmunity = {}

local MONKEY_CURSE = "MONKEY"

local function IsMonkeyCurseItem(item, curse)
	if item == nil then
		return curse == MONKEY_CURSE
	end

	if item.prefab == "cursed_monkey_token" or item:HasTag("monkey_token") then
		return true
	end

	if item.components ~= nil and item.components.curseditem ~= nil then
		return item.components.curseditem.curse == MONKEY_CURSE
	end

	return false
end

local function ClearMonkeyCurseState(inst)
	if inst.components == nil then
		return
	end

	inst.monkeyfeet = nil
	inst.monkeyhands = nil
	inst.monkeytail = nil

	if inst._trymonkeyannouncetask ~= nil then
		inst._trymonkeyannouncetask:Cancel()
		inst._trymonkeyannouncetask = nil
	end

	if inst._trymonkeychangetask ~= nil then
		inst._trymonkeychangetask:Cancel()
		inst._trymonkeychangetask = nil
	end

	if inst.components.skinner ~= nil then
		inst.components.skinner:ClearMonkeyCurse("MONKEY_CURSE_1")
		inst.components.skinner:ClearMonkeyCurse("MONKEY_CURSE_2")
		inst.components.skinner:ClearMonkeyCurse("MONKEY_CURSE_3")
	end

	inst:RemoveTag("MONKEY_CURSE_1")
	inst:RemoveTag("MONKEY_CURSE_2")
	inst:RemoveTag("MONKEY_CURSE_3")
end

local function WrapCursable(inst)
	local cursable = inst.components ~= nil and inst.components.cursable or nil
	if cursable == nil or inst._musha_monkey_curse_wrapped then
		return
	end

	local old_apply = cursable.ApplyCurse
	local old_is_cursable = cursable.IsCursable
	local old_force = cursable.ForceOntoOwner

	cursable.ApplyCurse = function(self, item, curse)
		local itemcurse = curse
		if item ~= nil and item.components ~= nil and item.components.curseditem ~= nil then
			itemcurse = item.components.curseditem.curse
		end

		if itemcurse == MONKEY_CURSE then
			return false
		end

		return old_apply(self, item, curse)
	end

	cursable.IsCursable = function(self, item)
		if IsMonkeyCurseItem(item) then
			return false
		end

		return old_is_cursable(self, item)
	end

	cursable.ForceOntoOwner = function(self, item)
		if IsMonkeyCurseItem(item) then
			return
		end

		return old_force(self, item)
	end

	inst._musha_monkey_curse_wrapped = true
end

local function RemoveExistingMonkeyCurse(inst)
	local cursable = inst.components ~= nil and inst.components.cursable or nil
	if cursable ~= nil and (cursable.curses.MONKEY or 0) > 0 then
		cursable:RemoveCurse(MONKEY_CURSE, cursable.curses.MONKEY, true)
	end

	ClearMonkeyCurseState(inst)
end

function MonkeyImmunity.Register(deps)
	local add_prefab_post_init = deps.AddPrefabPostInit
	local is_server = deps.IsServer

	add_prefab_post_init("musha", function(inst)
		if not is_server then
			return
		end

		WrapCursable(inst)

		inst:DoTaskInTime(0, function()
			if inst:IsValid() then
				RemoveExistingMonkeyCurse(inst)
			end
		end)

		inst:ListenForEvent("monkeycursehit", function()
			if inst:IsValid() then
				RemoveExistingMonkeyCurse(inst)
			end
		end)
	end)
end

return MonkeyImmunity
