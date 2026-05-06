local M = {}

local SKINS =
{
    "musha_none",
    "musha_battle_skin_none",
    "musha_old_skin_none",
}

function M.Register()
    if type(PREFAB_SKINS) ~= "table" then
        return
    end

    PREFAB_SKINS["musha"] = SKINS
end

return M
