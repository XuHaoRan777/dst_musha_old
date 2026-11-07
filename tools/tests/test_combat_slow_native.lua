-- Use run_native_combat_slow.py: native Lua methods, stubbed engine entity/Physics.
local native_root = assert(arg[1], "missing extracted DST scripts directory")
package.path = native_root .. "/?.lua;scripts/?.lua;" .. package.path
require("class")
TheWorld = { ismastersim = true }
TUNING = { WILSON_WALK_SPEED = 4, WILSON_RUN_SPEED = 6, DEFAULT_LOCOMOTOR_HOP_DISTANCE = 4 }
local LocoMotor = require("components/locomotor")
local Slow = require("musha/combat/slow")

local function near(actual, expected, message)
    assert(math.abs(actual - expected) < 0.000001,
        string.format("%s: expected %.6f, got %.6f", message, expected, actual))
end

local function target(boss)
    local inst = { components = {}, tags = {}, listeners = {}, tasks = {}, speed = 0 }
    function inst:IsValid() return true end
    function inst:IsAsleep() return false end
    function inst:IsInLimbo() return false end
    function inst:AddTag(tag) self.tags[tag] = true end
    function inst:HasTag(tag) return self.tags[tag] == true end
    function inst:StartUpdatingComponent() end
    function inst:PushEvent() end
    function inst:ListenForEvent(event, fn, source)
        self.listeners[fn] = { event = event, source = source }
    end
    function inst:RemoveEventCallback(event, fn, source) self.listeners[fn] = nil end
    function inst:DoTaskInTime(delay, fn)
        local task = { delay = delay, fn = fn }
        function task:Cancel() self.cancelled = true end
        self.tasks[#self.tasks + 1] = task
        return task
    end
    inst.Physics = {
        SetMotorVel = function(_, x, y, z) inst.speed = x end,
        GetMotorSpeed = function() return inst.speed end,
    }
    inst.components.health = { IsDead = function() return false end }
    inst.components.locomotor = LocoMotor(inst)
    -- Dragonfly and other flyers disable the native terrain multiplier.
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    if boss then inst:AddTag("epic") end
    return inst, inst.components.locomotor
end

local cases = 0
local function test(name, fn)
    fn()
    cases = cases + 1
    print("PASS native " .. name)
end

test("all slow sources reach walk/run Physics motor speeds", function()
    for _, boss in ipairs({ false, true }) do
        for kind, slow in pairs({ lightning = .95, passive_lightning = .95,
            poison = .85, frost = .85, phoenixaxe = .35 }) do
            local inst, loco = target(boss)
            local multiplier = 1 - slow * (boss and .5 or 1)
            assert(Slow.Apply(inst, kind))
            near(loco:GetExternalSpeedMultiplier(inst, "musha_combat_slow"), multiplier, kind .. " modifier")
            loco:WalkForward(true)
            near(inst.speed, 4 * multiplier, kind .. " walk motor")
            loco:RunForward(true)
            near(inst.speed, 6 * multiplier, kind .. " run motor")
            Slow.Remove(inst, kind)
            loco:RunForward(true)
            near(inst.speed, 6, kind .. " cleared run motor")
        end
    end
end)

test("an already moving target changes speed on native OnUpdate", function()
    local inst, loco = target(true)
    loco:WalkForward(true)
    near(inst.speed, 4, "initial motor")
    Slow.Apply(inst, "lightning")
    -- Do not restart walking: exercise native per-frame motor recalculation.
    loco:OnUpdate(1 / 30)
    near(inst.speed, 2.1, "moving boss slowed next update")
    local expiry = inst.tasks[1]
    near(expiry.delay, 7.5, "boss lightning half duration")
    expiry.fn()
    loco:OnUpdate(1 / 30)
    near(inst.speed, 4, "moving boss restored on expiry")
end)

test("dragonfly spawning acceleration composes with slow and survives cleanup", function()
    local inst, loco = target(true)
    loco:SetExternalSpeedMultiplier(inst, "spawning", 1.4)
    loco:WalkForward(true)
    near(inst.speed, 5.6, "accelerated baseline")
    Slow.Apply(inst, "phoenixaxe", { slow = .6, duration = 20 })
    loco:OnUpdate(1 / 30)
    near(inst.speed, 3.92, "1.4 times 0.7 is 0.98 of base speed")
    near(loco:GetSpeedMultiplier(), .98, "native total multiplier")
    Slow.Apply(inst, "poison")
    loco:OnUpdate(1 / 30)
    near(inst.speed, 3.22, "stronger poison replaces axe without stacking")
    Slow.Remove(inst, "phoenixaxe")
    loco:OnUpdate(1 / 30)
    near(inst.speed, 3.22, "poison remains after axe removal")
    Slow.Remove(inst, "poison")
    loco:OnUpdate(1 / 30)
    near(inst.speed, 5.6, "cleanup preserves native acceleration")
    near(loco:GetExternalSpeedMultiplier(inst, "spawning"), 1.4, "spawning key preserved")
end)

test("ground speed recalculation cannot erase Musha external slow", function()
    local inst, loco = target(false)
    loco.groundspeedmultiplier = 1.3
    Slow.Apply(inst, "frost")
    loco:RunForward(true)
    near(inst.speed, 6 * 1.3 * .15, "road and slow multiply")
    loco.groundspeedmultiplier = 1
    loco:OnUpdate(1 / 30)
    near(inst.speed, 6 * .15, "terrain reset retains slow")
    Slow.Remove(inst, "frost")
    near(loco:GetSpeedMultiplier(), 1, "no lingering speed modifier")
end)

print(string.format("native combat slow tests passed (%d cases; engine stubs, not an in-game test)", cases))
