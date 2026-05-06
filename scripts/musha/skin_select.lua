local M = {}

local CHARACTER_NAME = "musha"

local MUSHA_SKINS =
{
    musha = true,
    musha_none = true,
    musha_battle_skin_none = true,
    musha_old_skin_none = true,
}

local networking_patch_registered = false
local skin_filter_patch_registered = false
local old_get_affinity_filter_for_hero = nil

local function Contains(list, value)
    if list == nil then
        return false
    end

    for i = 1, #list do
        if list[i] == value then
            return true
        end
    end

    return false
end

local function RemoveValue(list, value)
    if list == nil then
        return
    end

    for i = #list, 1, -1 do
        if list[i] == value then
            table.remove(list, i)
        end
    end
end

local function IsMushaSkin(name)
    return type(name) == "string" and MUSHA_SKINS[name] == true
end

local function RegisterLoadoutPatch(env)
    local add_class_post_construct = env.AddClassPostConstruct
    local global = env.GLOBAL
    if add_class_post_construct == nil or global == nil then
        return
    end

    add_class_post_construct("widgets/widget", function(self)
        if type(global.DST_CHARACTERLIST) ~= "table" then
            return
        end

        if self.name == "LoadoutSelect" then
            if not Contains(global.DST_CHARACTERLIST, CHARACTER_NAME) then
                table.insert(global.DST_CHARACTERLIST, CHARACTER_NAME)
            end
        elseif self.name == "LoadoutRoot" then
            RemoveValue(global.DST_CHARACTERLIST, CHARACTER_NAME)
        end
    end)
end

local function RegisterOwnershipPatch(global)
    local inventory = global ~= nil and global.TheInventory or nil
    if inventory == nil then
        return
    end

    local mt = getmetatable(inventory)
    local index = mt ~= nil and mt.__index or nil
    if type(index) ~= "table" or index._musha_skin_ownership_patch then
        return
    end

    index._musha_skin_ownership_patch = true

    local old_check_ownership = index.CheckOwnership or inventory.CheckOwnership
    if old_check_ownership ~= nil then
        index.CheckOwnership = function(self, name, ...)
            if IsMushaSkin(name) then
                return true
            end

            return old_check_ownership(self, name, ...)
        end
    end

    local old_check_client_ownership = index.CheckClientOwnership or inventory.CheckClientOwnership
    if old_check_client_ownership ~= nil then
        index.CheckClientOwnership = function(self, userid, name, ...)
            if IsMushaSkin(name) then
                return true
            end

            return old_check_client_ownership(self, userid, name, ...)
        end
    end
end

local function CalledFromNetworking(global)
    local debug_lib = global ~= nil and global.debug or debug
    if debug_lib == nil or debug_lib.getinfo == nil then
        return false
    end

    for i = 2, 100 do
        local info = debug_lib.getinfo(i, "S")
        if info == nil then
            break
        elseif type(info.source) == "string" and info.source:match("^scripts/networking.lua") then
            return true
        end
    end

    return false
end

local function RegisterNetworkingPatch(global)
    if global == nil or global.ExceptionArrays == nil or networking_patch_registered then
        return
    end

    local old_exception_arrays = global.ExceptionArrays
    networking_patch_registered = true

    global.ExceptionArrays = function(ta, tb, ...)
        local result = old_exception_arrays(ta, tb, ...)
        if CalledFromNetworking(global) and type(result) == "table" and not Contains(result, CHARACTER_NAME) then
            table.insert(result, CHARACTER_NAME)
        end
        return result
    end
end

local function RegisterSkinnerRefresh(env)
    local add_component_post_init = env.AddComponentPostInit
    local musha_anim = env.MushaAnim
    if add_component_post_init == nil or musha_anim == nil then
        return
    end

    add_component_post_init("skinner", function(self)
        if self.inst == nil or self.inst.prefab ~= CHARACTER_NAME or self._musha_skin_refresh_patch then
            return
        end

        self._musha_skin_refresh_patch = true
        local old_set_skin_mode = self.SetSkinMode
        if old_set_skin_mode == nil then
            return
        end

        self.SetSkinMode = function(skinner, ...)
            local result = old_set_skin_mode(skinner, ...)
            local inst = skinner.inst
            if inst ~= nil and inst.prefab == CHARACTER_NAME and not inst.change_visual then
                musha_anim.ApplyCurrentFormBuildLater(inst, 0)
            end
            return result
        end
    end)
end

local function RegisterSkinFilterPatch(global)
    if global == nil or global.GetAffinityFilterForHero == nil or skin_filter_patch_registered then
        return
    end

    old_get_affinity_filter_for_hero = global.GetAffinityFilterForHero
    skin_filter_patch_registered = true
    global.GetAffinityFilterForHero = function(herocharacter, ...)
        if herocharacter == CHARACTER_NAME then
            return function(item_key)
                return IsMushaSkin(item_key)
            end
        end

        return old_get_affinity_filter_for_hero(herocharacter, ...)
    end
end

function M.Register(env)
    RegisterLoadoutPatch(env)
    RegisterOwnershipPatch(env.GLOBAL)
    RegisterNetworkingPatch(env.GLOBAL)
    RegisterSkinnerRefresh(env)
    RegisterSkinFilterPatch(env.GLOBAL)
end

return M
