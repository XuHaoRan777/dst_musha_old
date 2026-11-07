package.path = "scripts/?.lua;" .. package.path

local Slow = require("musha/combat/slow")
local SPEED_KEY = "musha_combat_slow"
local tests = 0

local function equal(actual, expected, message)
    assert(actual == expected, string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)))
end

local function near(actual, expected, message)
    assert(math.abs(actual - expected) < 0.000001,
        string.format("%s: expected %.6f, got %.6f", message, expected, actual))
end

local function count(values)
    local n = 0
    for _ in pairs(values) do n = n + 1 end
    return n
end

local function new_target(tags)
    local inst = { valid = true, dead = false, tags = {}, listeners = {}, tasks = {}, now = 0, components = {} }
    for _, tag in ipairs(tags or {}) do inst.tags[tag] = true end
    function inst:IsValid() return self.valid end
    function inst:HasTag(tag) return self.tags[tag] == true end
    function inst:ListenForEvent(event, fn)
        self.listeners[event] = self.listeners[event] or {}
        self.listeners[event][fn] = true
    end
    function inst:RemoveEventCallback(event, fn)
        if self.listeners[event] ~= nil then self.listeners[event][fn] = nil end
    end
    function inst:PushEvent(event)
        local snapshot = {}
        for fn in pairs(self.listeners[event] or {}) do snapshot[#snapshot + 1] = fn end
        for _, fn in ipairs(snapshot) do fn(self) end
    end
    function inst:Kill()
        self.dead = true
        self:PushEvent("death")
    end
    function inst:Remove()
        self.valid = false
        self:PushEvent("onremove")
    end
    local function schedule(delay, fn, period)
        local task = { at = inst.now + delay, fn = fn, period = period, cancelled = false }
        function task:Cancel() self.cancelled = true end
        inst.tasks[#inst.tasks + 1] = task
        return task
    end
    function inst:DoTaskInTime(delay, fn) return schedule(delay, fn) end
    function inst:DoPeriodicTask(period, fn) return schedule(period, fn, period) end
    function inst:Advance(seconds)
        local stop = self.now + seconds
        while true do
            local next_task
            for _, task in ipairs(self.tasks) do
                if not task.cancelled and task.at <= stop
                    and (next_task == nil or task.at < next_task.at) then
                    next_task = task
                end
            end
            if next_task == nil then break end
            self.now = next_task.at
            if next_task.period == nil then next_task.cancelled = true end
            next_task.fn(self)
            if next_task.period ~= nil and not next_task.cancelled then
                next_task.at = self.now + next_task.period
            end
        end
        self.now = stop
    end
    function inst:ActiveTasks(periodic)
        local n = 0
        for _, task in ipairs(self.tasks) do
            if not task.cancelled and (periodic == nil or (task.period ~= nil) == periodic) then n = n + 1 end
        end
        return n
    end
    inst.components.health = { IsDead = function() return inst.dead end }
    local locomotor = { groundspeedmultiplier = 0.73, modifiers = {} }
    function locomotor:SetExternalSpeedMultiplier(source, key, multiplier)
        self.modifiers[source] = self.modifiers[source] or {}
        self.modifiers[source][key] = multiplier
    end
    function locomotor:RemoveExternalSpeedMultiplier(source, key)
        if self.modifiers[source] ~= nil then
            self.modifiers[source][key] = nil
            if next(self.modifiers[source]) == nil then self.modifiers[source] = nil end
        end
    end
    inst.components.locomotor = locomotor
    function inst:Multiplier()
        local modifiers = self.components.locomotor.modifiers[self]
        return modifiers ~= nil and modifiers[SPEED_KEY] or 1
    end
    return inst
end

local function new_fx()
    local fx = { valid = true, removed = 0 }
    function fx:IsValid() return self.valid end
    function fx:Remove() self.valid = false; self.removed = self.removed + 1 end
    return fx
end

local function test(name, fn)
    fn()
    tests = tests + 1
    print("PASS " .. name)
end

test("different sources select strongest and fall back as each expires", function()
    local target = new_target()
    assert(Slow.Apply(target, "poison", { duration = 9 }))
    assert(Slow.Apply(target, "frost", { duration = 4 }))
    assert(Slow.Apply(target, "lightning", { duration = 2 }))
    near(target:Multiplier(), 0.05, "strongest multiplier")
    equal(count(target.components.locomotor.modifiers[target]), 1, "one shared modifier")
    target:Advance(2.1)
    near(target:Multiplier(), 0.15, "fall back to frost")
    target:Advance(2)
    near(target:Multiplier(), 0.15, "fall back to poison")
    target:Advance(13)
    near(target:Multiplier(), 1, "all effects expired")
    equal(target._musha_combat_slow, nil, "state released")
    equal(target:ActiveTasks(), 0, "no tasks remain")
    equal(count(target.listeners.death), 0, "death listener removed")
    equal(count(target.listeners.onremove), 0, "remove listener removed")
end)

test("ordinary cap and negative slow clamp", function()
    local target = new_target()
    Slow.Apply(target, "phoenixaxe", { slow = 0.99 })
    near(target:Multiplier(), 0.05, "ordinary 95 percent cap")
    Slow.Remove(target, "phoenixaxe")
    Slow.Apply(target, "phoenixaxe", { slow = -1 })
    near(target:Multiplier(), 1, "negative slow cannot speed up")
end)

test("epic and giant halve slow strength and duration for all sources", function()
    local expected = { poison = 0.575, frost = 0.575, lightning = 0.525, passive_lightning = 0.525 }
    local durations = { poison = 9, frost = 4, lightning = 15, passive_lightning = 4 }
    for _, tag in ipairs({ "epic", "giant" }) do
        for kind, multiplier in pairs(expected) do
            local target = new_target({ tag })
            assert(Slow.Apply(target, kind))
            near(target:Multiplier(), multiplier, tag .. " " .. kind)
            target:Advance(durations[kind] * 0.5 - 0.01)
            assert(Slow.IsActive(target, kind), "boss effect remains until half duration")
            target:Advance(0.02)
            equal(Slow.IsActive(target, kind), false, "boss effect expires at half duration")
            near(target:Multiplier(), 1, "boss speed restored at half duration")
        end
        local target = new_target({ tag })
        Slow.Apply(target, "phoenixaxe", { slow = 0.35, duration = 10 })
        near(target:Multiplier(), 0.825, "axe boss strength halved")
        target:Advance(4)
        Slow.Apply(target, "phoenixaxe", { slow = 0.6, duration = 20 })
        near(target:Multiplier(), 0.7, "custom axe slow is halved")
        Slow.Apply(target, "lightning")
        near(target:Multiplier(), 0.525, "stronger boss source replaces rather than multiplies")
        target:Advance(9.99)
        assert(Slow.IsActive(target, "phoenixaxe"), "refreshed axe lasts half custom duration")
        near(target:Multiplier(), 0.7, "expired lightning falls back to axe")
        target:Advance(0.02)
        equal(Slow.IsActive(target, "phoenixaxe"), false, "custom duration halved once on refresh")
        near(target:Multiplier(), 1, "refreshed boss effects fully expire")
        Slow.Apply(target, "phoenixaxe", { slow = 0.99 })
        near(target:Multiplier(), 0.525, "ordinary cap applied before boss halving")
    end
end)

test("refresh preserves strength and duration without stale expiry", function()
    local target = new_target()
    local cleared = 0
    Slow.Apply(target, "phoenixaxe", { slow = 0.6, duration = 10, on_clear = function() cleared = cleared + 1 end })
    target:Advance(8)
    Slow.Apply(target, "phoenixaxe", { slow = 0.35, duration = 2 })
    near(target:Multiplier(), 0.4, "weaker refresh retains stronger slow")
    target:Advance(2.1)
    assert(Slow.IsActive(target, "phoenixaxe"), "original expiry must not clear refreshed effect")
    equal(cleared, 0, "refresh does not clear")
    target:Advance(7.8)
    assert(Slow.IsActive(target, "phoenixaxe"), "longer original duration retained from refresh")
    target:Advance(0.2)
    equal(Slow.IsActive(target, "phoenixaxe"), false, "refreshed effect expires")
    equal(cleared, 1, "clear exactly once")
end)

test("repeated hits do not postpone or multiply damage ticks", function()
    local target = new_target()
    local damage = 0
    for _ = 1, 8 do
        Slow.Apply(target, "poison", { tick_period = 3, tick_strength = 4,
            on_tick = function() damage = damage + 4 end })
        target:Advance(0.5)
    end
    equal(damage, 4, "damage occurs during continuous hits")
    equal(target:ActiveTasks(true), 1, "one periodic damage task per kind")
    equal(target:ActiveTasks(false), 1, "one expiry task per kind")
    target:Advance(2.1)
    equal(damage, 8, "original tick phase retained")
end)

test("stronger damage callback wins across different attackers", function()
    local target = new_target()
    local damage = 0
    local function apply(strength)
        Slow.Apply(target, "lightning", { tick_period = 2, tick_strength = strength,
            on_tick = function() damage = damage + strength end })
    end
    apply(2)
    target:Advance(1)
    apply(8)
    target:Advance(1.1)
    equal(damage, 8, "stronger callback used at original tick")
    apply(2)
    target:Advance(2)
    equal(damage, 16, "weak refresh cannot replace stronger damage")
    equal(target:ActiveTasks(true), 1, "multiple attackers share damage task")
end)

test("refresh replaces FX and cleanup owns only current FX", function()
    local target = new_target()
    local first, second = new_fx(), new_fx()
    Slow.Apply(target, "frost", { fx = first })
    Slow.Apply(target, "frost", { fx = second })
    equal(first.removed, 1, "old FX removed on replacement")
    equal(second.removed, 0, "new FX remains active")
    Slow.Remove(target, "frost")
    Slow.Remove(target, "frost")
    equal(first.removed, 1, "old FX not removed twice")
    equal(second.removed, 1, "current FX removed once")
end)

test("death and removal cancel all tasks and release owned effects", function()
    for _, event in ipairs({ "death", "onremove" }) do
        local target = new_target()
        local first, second = new_fx(), new_fx()
        local cleared, ticks = 0, 0
        Slow.Apply(target, "lightning", { fx = first, tick_period = 2,
            on_tick = function() ticks = ticks + 1 end, on_clear = function() cleared = cleared + 1 end })
        Slow.Apply(target, "frost", { fx = second, on_clear = function() cleared = cleared + 1 end })
        if event == "death" then target:Kill() else target:Remove() end
        equal(target._musha_combat_slow, nil, event .. " state removed")
        equal(target:ActiveTasks(), 0, event .. " tasks cancelled")
        equal(count(target.listeners.death), 0, event .. " death listener released")
        equal(count(target.listeners.onremove), 0, event .. " remove listener released")
        equal(cleared, 2, event .. " each effect cleaned")
        equal(first.removed + second.removed, 2, event .. " both FX removed")
        near(target:Multiplier(), 1, event .. " modifier released")
        target:Advance(20)
        equal(ticks, 0, event .. " damage cannot run after cleanup")
    end
end)

test("other mod modifiers and terrain multiplier survive cleanup", function()
    local target, source = new_target(), {}
    local locomotor = target.components.locomotor
    locomotor:SetExternalSpeedMultiplier(source, "other_mod", 0.8)
    locomotor:SetExternalSpeedMultiplier(target, "other_effect", 1.2)
    Slow.Apply(target, "frost")
    Slow.Remove(target, "frost")
    near(locomotor.modifiers[source].other_mod, 0.8, "other source preserved")
    near(locomotor.modifiers[target].other_effect, 1.2, "other key on same source preserved")
    near(locomotor.groundspeedmultiplier, 0.73, "terrain value never overwritten")
end)

test("protected, invalid, dead and client targets are rejected without owning FX", function()
    local targets = { new_target({ "player" }), new_target({ "companion" }), new_target({ "yamche" }) }
    local follower = new_target()
    follower.components.follower = { leader = new_target({ "musha" }) }
    targets[#targets + 1] = follower
    local migration = new_target(); migration.musha_migration_companion = true
    targets[#targets + 1] = migration
    local dead = new_target(); dead.dead = true; targets[#targets + 1] = dead
    local invalid = new_target(); invalid.valid = false; targets[#targets + 1] = invalid
    local client = new_target(); client.ismastersim = false; targets[#targets + 1] = client
    for _, target in ipairs(targets) do
        local fx = new_fx()
        equal(Slow.Apply(target, "frost", { fx = fx }), false, "application rejected")
        equal(target._musha_combat_slow, nil, "no state created")
        equal(target:ActiveTasks(), 0, "no tasks created")
        equal(fx.removed, 0, "caller still owns rejected FX")
    end
    equal(Slow.Apply(nil, "frost"), false, "nil target rejected")
    equal(Slow.Apply(new_target(), "unknown"), false, "unknown effect rejected")
end)

test("stationary axe target retains auxiliary effect and timed cleanup", function()
    local target, fx = new_target(), new_fx()
    target.components.locomotor = nil
    equal(Slow.Apply(target, "frost"), false, "ordinary stationary target rejected")
    local cleared = 0
    assert(Slow.Apply(target, "phoenixaxe", { allow_stationary = true, duration = 2,
        fx = fx, on_clear = function() cleared = cleared + 1 end }))
    assert(Slow.IsActive(target, "phoenixaxe"), "auxiliary effect remains active")
    target:Advance(2.1)
    equal(cleared, 1, "stationary auxiliary callback cleared")
    equal(fx.removed, 1, "stationary FX removed")
    equal(target:ActiveTasks(), 0, "stationary timer cleaned")
end)

test("damage callback killing target cleans reentrantly", function()
    local target, fx = new_target(), new_fx()
    local ticks, cleared = 0, 0
    Slow.Apply(target, "lightning", { fx = fx, tick_period = 2,
        on_tick = function(v) ticks = ticks + 1; v:Kill() end,
        on_clear = function(v)
            equal(Slow.IsActive(v, "lightning"), false, "effect detached before callback")
            cleared = cleared + 1
        end })
    target:Advance(20)
    equal(ticks, 1, "only lethal tick runs")
    equal(cleared, 1, "lethal tick cleans once")
    equal(target:ActiveTasks(), 0, "lethal tick cancels future tasks")
    equal(fx.removed, 1, "lethal tick removes FX")
    near(target:Multiplier(), 1, "lethal tick removes multiplier")
end)

-- Exercise the public lightning entry points with target-owned scheduling only.
local Lightning = require("musha/skills/lightning")
local function noop() end

local function new_combat_target(tags)
    local target = new_target(tags)
    target.damage, target.stops, target.hits = 0, 0, 0
    function target:RemoveTag(tag) self.tags[tag] = nil end
    function target:GetPosition() return { Get = function() return 0, 0, 0 end } end
    target.Transform = { GetWorldPosition = function() return 0, 0, 0 end }
    target.AnimState = { SetBloomEffectHandle = noop }
    target.SoundEmitter = { PlaySound = noop }
    target.entity = { IsVisible = function() return true end }
    target.components.health.DoDelta = function(_, delta) target.damage = target.damage - delta end
    target.components.combat = { hiteffectsymbol = "body", SetRange = noop, SuggestTarget = noop }
    target.components.inventory = { GetEquippedItem = function() return nil end }
    target.components.talker = { Say = noop }
    target.components.locomotor.StopMoving = function() target.stops = target.stops + 1 end
    target.sg = { GoToState = function(_, state) target.hits = target.hits + 1; target.last_state = state end }
    return target
end

local function register_lightning(targets)
    local spawned = {}
    local env = {
        -- Deliberately no TheWorld/GetWorld: no effect may schedule world tasks.
        AddModRPCHandler = noop,
        EQUIPSLOTS = { HANDS = "hands" },
        STRINGS = { MUSHA_TALK_GRRR = "lightning" },
        IsMushaSleeping = function() return false end,
        TheSim = { FindEntities = function() return targets or {} end },
        SkillDefs = {
            GetLightningLevel = function() return { damage = 10 } end,
            HasMana = function() return true end,
            SpendMana = noop,
        },
        SpawnPrefab = function(prefab)
            local fx = new_fx()
            fx.Transform = { SetPosition = noop, SetScale = noop }
            fx.entity = { AddFollower = function() return { FollowSymbol = noop } end }
            spawned[prefab] = fx
            return fx
        end,
    }
    Lightning.Register(env)
    return spawned
end

test("on-hit lightning delays slow then stops target-owned DOT at expiry", function()
    local target, caster = new_combat_target({ "burn" }), new_combat_target({ "musha", "player" })
    local spawned = register_lightning()
    Lightning.OnHitLightning(caster, { target = target })
    equal(target.damage, 10, "initial charged lightning damage remains")
    target:Advance(0.29)
    equal(Slow.IsActive(target, "lightning"), false, "slow waits for delayed hit")
    target:Advance(0.02)
    assert(Slow.IsActive(target, "lightning"), "delayed hit joins unified slow")
    near(target:Multiplier(), 0.05, "delayed hit uses lightning multiplier")
    equal(target:HasTag("burn"), false, "delayed hit consumes lightning mark")
    equal(target.damage, 35, "delayed direct damage remains")
    target:Advance(2)
    equal(target.damage, 43, "one lightning damage tick")
    target:Advance(13.1)
    equal(Slow.IsActive(target, "lightning"), false, "lightning expires")
    equal(target:ActiveTasks(), 0, "no delayed or periodic target tasks remain")
    equal(spawned.debuff_short.removed, 1, "debuff FX expires")
    local damage = target.damage
    target:Advance(20)
    equal(target.damage, damage, "damage cannot resume after expiry")
end)

test("on-hit lightning cannot apply delayed slow to a dead target", function()
    local target, caster = new_combat_target({ "burn" }), new_combat_target({ "musha", "player" })
    register_lightning()
    Lightning.OnHitLightning(caster, { target = target })
    target:Kill()
    target:Advance(1)
    equal(target.damage, 10, "no delayed damage after death")
    equal(Slow.IsActive(target, "lightning"), false, "no delayed slow after death")
    equal(target:ActiveTasks(), 0, "dead target creates no effect tasks")
end)

test("berserk lightning damages bosses without forcing movement or hit states", function()
    local epic = new_combat_target({ "monster", "burn", "epic" })
    local giant = new_combat_target({ "monster", "burn", "giant" })
    local ordinary = new_combat_target({ "monster", "burn" })
    local caster = new_combat_target({ "musha", "player" })
    caster.berserk = true
    register_lightning({ epic, giant, ordinary })
    Lightning.LightningAction(caster)
    for _, target in ipairs({ epic, giant }) do
        equal(target.damage, 30, "boss direct damage remains")
        equal(target.stops, 0, "boss movement not forced")
        equal(target.hits, 0, "boss state not forced")
        near(target:Multiplier(), 0.525, "boss lightning slow halved")
        target:Advance(2.1)
        equal(target.damage, 32, "boss still receives one DOT tick")
        target:Advance(5.5)
        equal(target.damage, 36, "boss DOT follows the restored seven-second duration")
        near(target:Multiplier(), 1, "boss lightning expires after half of fifteen seconds")
    end
    equal(ordinary.damage, 30, "ordinary direct damage remains")
    equal(ordinary.stops, 1, "ordinary movement reaction retained")
    equal(ordinary.last_state, "hit", "ordinary hit reaction retained")
    near(ordinary:Multiplier(), 0.05, "ordinary lightning slow remains stronger")
end)

test("ghost lightning preserves damage without forcing boss spider or hound states", function()
    local targets = {}
    for _, boss_tag in ipairs({ "epic", "giant" }) do
        for _, species in ipairs({ "spider", "hound" }) do
            targets[#targets + 1] = new_combat_target({ "monster", boss_tag, species })
        end
    end
    targets[#targets + 1] = new_combat_target({ "monster", "spider" })
    targets[#targets + 1] = new_combat_target({ "monster", "hound" })
    local caster = new_combat_target({ "musha", "player", "playerghost" })
    caster.components.stamina_sleep = { current = 0 }
    caster.components.sanity = { current = 0 }
    caster.components.leader = { IsFollower = function() return false end }
    caster.sg.HasStateTag = function() return false end
    register_lightning(targets)
    Lightning.env.STRINGS.MUSHA_TALK_GHOST_REVENGE = "ghost lightning"
    Lightning.env.TheSim.FindEntities = function(_, x, y, z, radius, required_tags)
        -- Companion synchronization must not see the combat targets as Yamche.
        return required_tags == nil and targets or {}
    end
    Lightning.LightningAction(caster)
    for _, target in ipairs(targets) do
        equal(target.damage, 10, "ghost lightning direct damage remains")
        if target:HasTag("epic") or target:HasTag("giant") then
            equal(target.hits, 0, "boss ghost-lightning hit state not forced")
        else
            equal(target.hits, 1, "ordinary ghost-lightning hit reaction retained")
            equal(target.last_state, target:HasTag("spider") and "hit_stunlock" or "hit",
                "ordinary species-specific reaction retained")
        end
        target:Advance(3.1)
        equal(target.ghost_spark, false, "ghost lightning cooldown mark expires")
    end
end)

print(string.format("combat slow tests passed (%d cases)", tests))
