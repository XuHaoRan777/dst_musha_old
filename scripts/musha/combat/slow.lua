-- Target-owned, transient combat effects. Musha sources share one speed modifier.
local M = {}
local SPEED_KEY = "musha_combat_slow"
local DEFINITIONS = {
    lightning = { slow = 0.95, duration = 15 },
    passive_lightning = { slow = 0.95, duration = 4 },
    poison = { slow = 0.85, duration = 9 },
    frost = { slow = 0.85, duration = 4 },
    phoenixaxe = { slow = 0.35, duration = 10 },
}

local function IsProtected(target)
    if target:HasTag("player") or target:HasTag("companion")
        or target:HasTag("yamche") or target:HasTag("yamcheb")
        or target:HasTag("arongb") or target:HasTag("Arongb")
        or target:HasTag("dall") or target.musha_migration_companion then
        return true
    end
    local follower = target.components.follower
    return follower ~= nil and follower.leader ~= nil
        and follower.leader:HasTag("musha")
end

local function IsAlive(target)
    return target ~= nil and target:IsValid() and target.components ~= nil
        and target.components.health ~= nil and not target.components.health:IsDead()
end

local function Cancel(task)
    if task ~= nil then
        task:Cancel()
    end
end

local function RemoveFx(fx)
    if fx ~= nil and fx:IsValid() then
        fx:Remove()
    end
end

local function UpdateSpeed(target, state)
    local locomotor = target.components.locomotor
    if locomotor == nil then
        return
    end
    local strongest = 0
    for _, effect in pairs(state.effects) do
        strongest = math.max(strongest, effect.slow)
    end
    if strongest > 0 then
        locomotor:SetExternalSpeedMultiplier(target, SPEED_KEY, 1 - strongest)
    else
        locomotor:RemoveExternalSpeedMultiplier(target, SPEED_KEY)
    end
end

local function Detach(target, state)
    if target._musha_combat_slow == state then
        target._musha_combat_slow = nil
    end
    target:RemoveEventCallback("death", state.on_end)
    target:RemoveEventCallback("onremove", state.on_end)
end

local function Dispose(target, effect)
    Cancel(effect.expiry)
    Cancel(effect.tick)
    RemoveFx(effect.fx)
    if effect.on_clear ~= nil then
        effect.on_clear(target)
    end
end

local function ClearAll(target, state)
    if target._musha_combat_slow ~= state then
        return
    end
    local effects = state.effects
    state.effects = {}
    Detach(target, state)
    UpdateSpeed(target, state)
    for _, effect in pairs(effects) do
        Dispose(target, effect)
    end
end

function M.Remove(target, kind)
    local state = target ~= nil and target._musha_combat_slow or nil
    local effect = state ~= nil and state.effects[kind] or nil
    if effect == nil then
        return
    end
    -- Detach first: a cleanup callback must never find an expiring effect active.
    state.effects[kind] = nil
    if next(state.effects) == nil then
        Detach(target, state)
    end
    UpdateSpeed(target, state)
    Dispose(target, effect)
end

function M.IsActive(target, kind)
    local state = target ~= nil and target._musha_combat_slow or nil
    return state ~= nil and state.effects[kind] ~= nil
end

function M.Apply(target, kind, options)
    local definition = DEFINITIONS[kind]
    options = options or {}
    if definition == nil or not IsAlive(target) or target.ismastersim == false
        or IsProtected(target)
        or (target.components.locomotor == nil and not options.allow_stationary) then
        -- Rejected applications do not take ownership of caller-created FX.
        return false
    end

    local duration = options.duration or definition.duration
    if duration <= 0 then
        return false
    end
    local slow = math.max(0, math.min(0.95, options.slow or definition.slow))
    local boss = target:HasTag("epic") or target:HasTag("giant")
    if boss then
        slow = slow * 0.5
        duration = duration * 0.5
    end

    local state = target._musha_combat_slow
    if state == nil then
        state = { effects = {} }
        state.on_end = function() ClearAll(target, state) end
        target._musha_combat_slow = state
        target:ListenForEvent("death", state.on_end)
        target:ListenForEvent("onremove", state.on_end)
    end
    local effect = state.effects[kind]
    if effect == nil then
        effect = { slow = slow, duration = duration }
        state.effects[kind] = effect
    else
        effect.slow = math.max(effect.slow, slow)
        effect.duration = math.max(effect.duration, duration)
        Cancel(effect.expiry)
    end

    if options.fx ~= nil and options.fx ~= effect.fx then
        RemoveFx(effect.fx)
        effect.fx = options.fx
    end
    if options.on_clear ~= nil then
        effect.on_clear = options.on_clear
    end
    if options.on_tick ~= nil and (effect.on_tick == nil
        or (options.tick_strength or 0) >= (effect.tick_strength or 0)) then
        effect.on_tick = options.on_tick
        effect.tick_strength = options.tick_strength or 0
    end
    -- Refresh expiry without postponing the next damage tick on every hit.
    effect.expiry = target:DoTaskInTime(effect.duration, function()
        if target._musha_combat_slow == state and state.effects[kind] == effect then
            M.Remove(target, kind)
        end
    end)
    if effect.tick == nil and effect.on_tick ~= nil and options.tick_period ~= nil
        and options.tick_period > 0 then
        effect.tick = target:DoPeriodicTask(options.tick_period, function()
            if target._musha_combat_slow ~= state or state.effects[kind] ~= effect then
                return
            end
            if not IsAlive(target) or IsProtected(target) then
                ClearAll(target, state)
                return
            end
            effect.on_tick(target)
        end)
    end
    UpdateSpeed(target, state)
    return true
end

return M
