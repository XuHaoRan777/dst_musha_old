local function HasCombinedStatus(knownmodindex)
    if knownmodindex == nil then
        return false
    end

    local combined_status_mod = knownmodindex:GetModActualName("Combined Status")
    return combined_status_mod ~= nil and knownmodindex:IsModEnabledAny(combined_status_mod)
end

return HasCombinedStatus
