local M = {}

local function GetSafeHoverName(target)
	if target == nil then
		return nil
	end

	local ok, name = pcall(target.GetDisplayName, target)
	if ok and name ~= nil and name ~= "" then
		return name
	end

	if target.components ~= nil and target.components.named ~= nil and target.components.named.name ~= nil then
		return target.components.named.name
	end

	local strings = M.env ~= nil and M.env.STRINGS or nil
	if target.prefab ~= nil and strings ~= nil and strings.NAMES ~= nil then
		return strings.NAMES[string.upper(target.prefab)]
	end

	return nil
end

local function Percent(current, min, max)
	local range = math.floor(max - min)
	if range <= 0 then
		return 0
	end
	return math.floor((current - min) * 100 / range)
end

local function GetHealthText(inst)
	if inst.components == nil or inst.components.health == nil then
		return nil
	end

	local health = inst.components.health
	local health_text = tostring(Percent(health.currenthealth, health.minhealth, health.maxhealth)) .. "%"
	if inst.components.hungerinfo ~= nil and inst.components.hunger ~= nil then
		local hunger = inst.components.hunger
		return "[" .. health_text .. "/" .. tostring(Percent(hunger.current, hunger.hungerrate, hunger.max)) .. "%]"
	end
	return "[" .. health_text .. "]"
end

local function UpdateHealthInfo(inst)
	if inst.components ~= nil and inst.components.healthinfo_copy ~= nil then
		local text = GetHealthText(inst)
		if text ~= nil then
			inst.components.healthinfo_copy:SetText(text)
		end
	end
end

local function RegisterHealthReplicaPatch(env)
	env.AddClassPostConstruct("components/health_replica", function(self)
		local old_SetCurrent = self.SetCurrent

		self.SetCurrent = function(self, current)
			if self.inst.components ~= nil
				and self.inst.components.health ~= nil
				and self.inst.components.healthinfo_copy ~= nil
				and (self.inst:HasTag("yamche") or self.inst:HasTag("arongbaby")) then
				UpdateHealthInfo(self.inst)
			end

			if old_SetCurrent ~= nil then
				old_SetCurrent(self, current)
			elseif self.classified ~= nil then
				self.classified:SetValue("currenthealth", current)
			end
		end
	end)
end

local function RegisterHoverPatch(env)
	local TheInput = env.TheInput
	local show_delay = env.SHOW_DELAY or 10

	env.AddGlobalClassPostConstruct("widgets/hoverer", "HoverText", function(self)
		self.OnUpdate = function(self)
			local controller = self.owner.components ~= nil and self.owner.components.playercontroller or nil
			local using_mouse = controller ~= nil and controller:UsingMouse()
			if using_mouse ~= self.shown then
				if using_mouse then
					self:Show()
				else
					self:Hide()
				end
			end

			if not self.shown then
				return
			end

			local str = nil
			if self.isFE == false then
				str = self.owner.HUD.controls:GetTooltip() or (controller ~= nil and controller:GetHoverTextOverride() or nil)
			else
				str = self.owner:GetTooltip()
			end

			local secondarystr = nil
			local lmb = nil
			if not str and self.isFE == false then
				lmb = controller ~= nil and controller:GetLeftMouseAction() or nil
				if lmb then
					str = lmb:GetActionString()
					if lmb.target and lmb.invobject == nil and lmb.target ~= lmb.doer then
						local name = GetSafeHoverName(lmb.target)
						if name then
							local adjective = lmb.target:GetAdjective()
							if adjective then
								str = str .. " " .. adjective .. " " .. name
							else
								str = str .. " " .. name
							end

							if lmb.target.replica.stackable ~= nil and lmb.target.replica.stackable:IsStack() then
								str = str .. " x" .. tostring(lmb.target.replica.stackable:StackSize())
							end

							if lmb.target.components.inspectable and lmb.target.components.inspectable.recordview and lmb.target.prefab then
								if env.ProfileStatsSet ~= nil then
									env.ProfileStatsSet(lmb.target.prefab .. "_seen", true)
								end
							end
						end
					end

					if lmb.target
						and lmb.target ~= lmb.doer
						and lmb.target.components
						and lmb.target.components.healthinfo_copy
						and lmb.target.components.healthinfo_copy.text ~= "" then
						local name = GetSafeHoverName(lmb.target) or ""
						str = str or ""
						local i = string.find(str, " " .. name, nil, true)
						if i ~= nil and i > 1 then
							str = string.sub(str, 1, i - 1)
						end
						str = str .. " " .. name .. " " .. lmb.target.components.healthinfo_copy.text
					end
				end

				local rmb = controller ~= nil and controller:GetRightMouseAction() or nil
				if rmb then
					secondarystr = env.STRINGS.RMB .. ": " .. rmb:GetActionString()
				end
			end

			if str then
				if self.strFrames == nil then
					self.strFrames = 1
				end

				if self.str ~= self.lastStr then
					self.lastStr = self.str
					self.strFrames = show_delay
				else
					self.strFrames = self.strFrames - 1
					if self.strFrames <= 0 then
						if lmb and lmb.target and lmb.target:HasTag("player") then
							self.text:SetColour(lmb.target.playercolour)
						else
							self.text:SetColour(1, 1, 1, 1)
						end
						self.text:SetString(str)
						self.text:Show()
					end
				end
			else
				self.text:Hide()
			end

			if secondarystr then
				self.secondarytext:SetString(secondarystr)
				self.secondarytext:Show()
			else
				self.secondarytext:Hide()
			end

			local changed = (self.str ~= str) or (self.secondarystr ~= secondarystr)
			self.str = str
			self.secondarystr = secondarystr
			if changed then
				local pos = TheInput:GetScreenPosition()
				self:UpdatePosition(pos.x, pos.y)
			end
		end
	end)
end

local function RegisterYamcheInfo(env)
	env.AddPrefabPostInitAny(function(inst)
		if inst.components.healthinfo_copy == nil and inst:HasTag("yamche") then
			inst:AddComponent("healthinfo_copy")
			if inst.components.hungerinfo == nil then
				inst:AddComponent("hungerinfo")
			end

			inst:DoPeriodicTask(0.2, function(inst)
				if inst.components.health ~= nil and inst.components.hunger ~= nil then
					UpdateHealthInfo(inst)
				end
			end)
		end
	end)
end

local function RegisterArongInfo(env)
	env.AddPrefabPostInitAny(function(inst)
		if inst.components.healthinfo_copy == nil and inst:HasTag("arongbaby") then
			inst:AddComponent("healthinfo_copy")
			UpdateHealthInfo(inst)
		end
	end)
end

function M.Register(env)
	RegisterHealthReplicaPatch(env)
	RegisterHoverPatch(env)
	RegisterYamcheInfo(env)
	RegisterArongInfo(env)
end

return M
