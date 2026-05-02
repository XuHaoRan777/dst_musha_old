local function ChatPostConstruct(inst)
	function inst:OnBecomeActive()
		inst._base.OnBecomeActive(inst)

		inst.chat_edit:SetFocus()
		inst.chat_edit:SetEditing(true)
		TheFrontEnd:LockFocus(true)
	end

	function inst:OnBecomeInactive()
		inst._base.OnBecomeInactive(inst)

		if inst.chat_edit ~= nil then
			inst.chat_edit:SetEditing(false)
		end
		TheFrontEnd:LockFocus(false)

    	if inst.runtask ~= nil then
        	inst.runtask:Cancel()
        	inst.runtask = nil
    	end
	end

	return inst
end


AddClassPostConstruct("screens/chatinputscreen", ChatPostConstruct)
