local function ConsolePostConstruct(inst)

	function inst:OnBecomeActive()
		inst._base.OnBecomeActive(inst)
		TheFrontEnd:ShowConsoleLog()

		inst.console_edit:SetFocus()
		inst.console_edit:SetEditing(true)
		inst:ToggleRemoteExecute(true)
		TheFrontEnd:LockFocus(true)
	end

	function inst:OnBecomeInactive()
		inst._base.OnBecomeInactive(inst)

    	if inst.runtask ~= nil then
        	inst.runtask:Cancel()
        	inst.runtask = nil
    	end
	end

	return inst
end

AddClassPostConstruct("screens/consolescreen", ConsolePostConstruct)
