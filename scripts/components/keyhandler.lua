local KeyHandler = Class(function(self, inst)
	self.inst = inst
	if TheInput ~= nil then
		self.handler = TheInput:AddKeyHandler(function(key, down) self:OnRawKey(key, down) end )
	end
end)

function KeyHandler:OnRemoveFromEntity()
	if self.handler ~= nil then
		self.handler:Remove()
		self.handler = nil
	end
end

function KeyHandler:IsLocalPlayer()
	return ThePlayer ~= nil and self.inst == ThePlayer
end

function KeyHandler:IsTextInputActive()
	if TheFrontEnd == nil or TheFrontEnd.GetActiveScreen == nil then
		return false
	end

	local screen = TheFrontEnd:GetActiveScreen()
	return screen ~= nil and (screen.chat_edit ~= nil or screen.console_edit ~= nil)
end

function KeyHandler:OnRawKey(key, down)
	if not self:IsLocalPlayer() or self:IsTextInputActive() or (IsPaused ~= nil and IsPaused()) then
		return
	end

	local player = ThePlayer
	if key and not down then
		player:PushEvent("keypressed", {inst = self.inst, player = player, key = key})
	elseif key and down then
		player:PushEvent("keydown", {inst = self.inst, player = player, key = key})
	end
end

function KeyHandler:AddActionListener(Namespace, Key, Action)
	self.inst:ListenForEvent("keypressed", function(inst, data)
		if data == nil or data.inst ~= ThePlayer or data.key ~= Key then
			return
		end

		local rpc = MOD_RPC ~= nil and MOD_RPC[Namespace] ~= nil and MOD_RPC[Namespace][Action] or nil
		if rpc == nil then
			return
		end

		if TheWorld ~= nil and TheWorld.ismastersim then
			local handlers = MOD_RPC_HANDLERS ~= nil and MOD_RPC_HANDLERS[Namespace] or nil
			local fn = handlers ~= nil and handlers[rpc.id] or nil
			if fn ~= nil then
				inst:PushEvent("keyaction"..Namespace..Action, { Namespace = Namespace, Action = Action, Fn = fn })
			end
		elseif SendModRPCToServer ~= nil then
			SendModRPCToServer(rpc)
		end
	end)

	if TheWorld ~= nil and TheWorld.ismastersim then
      self.inst:ListenForEvent("keyaction"..Namespace..Action, function(inst, data)
          if data == nil or data.Action ~= Action or data.Namespace ~= Namespace or data.Fn == nil then
              return
          end
          
          data.Fn(inst)
      end, self.inst) 
    end
end

return KeyHandler
