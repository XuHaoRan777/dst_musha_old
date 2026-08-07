package.path = "scripts/?.lua;" .. package.path

local loaded, FrostHammerMode = pcall(require, "musha/equipment/frosthammer_mode")
assert(loaded, "frosthammer mode helper must load: " .. tostring(FrostHammerMode))

local function assert_equal(actual, expected, message)
    assert(actual == expected, string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)))
end

local function assert_area(strength, is_frost_hammer, boost, expected_radius, expected_multiplier)
    local radius, multiplier = FrostHammerMode.GetAreaDamage(strength, is_frost_hammer, boost)
    assert_equal(radius, expected_radius, strength .. " area radius")
    assert_equal(multiplier, expected_multiplier, strength .. " area multiplier")
end

assert_area("normal", false, false, 0, 0)
assert_area("normal", true, false, 2, 0.5)
assert_area("normal", true, true, 1.5, 0.5)
assert_area("full", true, true, 1.5, 0.5)
assert_area("valkyrie", true, true, 1.5, 0.5)
assert_area("berserk", true, false, 4, 0.5)
assert_area("berserk", true, true, 2.5, 0.5)
assert_area("berserk", false, false, 2.5, 0.5)

local function new_hammer(level, boost, broken)
    local inst =
    {
        level = level,
        boost = boost,
        broken = broken,
        components = {},
        removed = nil,
    }

    function inst:AddComponent(name)
        assert_equal(name, "spellcaster", "component added")
        self.components.spellcaster =
        {
            SetSpellFn = function(component, fn)
                component.spell = fn
            end,
        }
    end

    function inst:RemoveComponent(name)
        self.removed = name
        self.components[name] = nil
    end

    return inst
end

local summon_fn = function()
end

local combat_owner =
{
    strength = "normal",
    components =
    {
        combat =
        {
            areahitcheckfn = nil,
            SetAreaDamage = function(self, radius, multiplier, hit_check)
                self.radius = radius
                self.multiplier = multiplier
                self.hit_check = hit_check
            end,
        },
    },
}

local combat_weapon =
{
    boost = true,
    components =
    {
        equippable =
        {
            IsEquipped = function()
                return true
            end,
        },
    },
    HasTag = function(_, tag)
        return tag == "frost_hammer"
    end,
}
FrostHammerMode.SyncCombatArea(combat_owner, combat_weapon)
assert_equal(combat_owner.components.combat.radius, 1.5, "boosted hammer area radius refresh")
assert_equal(combat_owner.components.combat.multiplier, 0.5, "boosted hammer area multiplier refresh")

combat_weapon.broken = true
FrostHammerMode.SyncCombatArea(combat_owner, combat_weapon)
assert_equal(combat_owner.components.combat.radius, 0, "broken hammer area radius refresh")
assert_equal(combat_owner.components.combat.multiplier, 0, "broken hammer area multiplier refresh")

combat_weapon.broken = false
combat_weapon.components.equippable.IsEquipped = function()
    return false
end
combat_owner.components.combat.radius = 7
combat_owner.components.combat.multiplier = 0.7
FrostHammerMode.SyncCombatArea(combat_owner, combat_weapon)
assert_equal(combat_owner.components.combat.radius, 7, "stored hammer must not change area damage")
assert_equal(combat_owner.components.combat.multiplier, 0.7, "stored hammer must not change area multiplier")

local active = new_hammer(2200, true, false)
FrostHammerMode.SyncTentacleSpell(active, summon_fn)
assert(active.components.spellcaster ~= nil, "eligible release mode must add spellcaster")
assert_equal(active.components.spellcaster.spell, summon_fn, "tentacle spell callback")
assert_equal(active.components.spellcaster.canuseonpoint, true, "point casting enabled")

active.boost = false
FrostHammerMode.SyncTentacleSpell(active, summon_fn)
assert_equal(active.removed, "spellcaster", "preserved mode removes spellcaster")

local missing_callback = new_hammer(2200, true, false)
FrostHammerMode.SyncTentacleSpell(missing_callback, nil)
assert(missing_callback.components.spellcaster == nil, "missing summon callback must not enable spellcaster")

local underleveled = new_hammer(2199, true, false)
FrostHammerMode.SyncTentacleSpell(underleveled, summon_fn)
assert(underleveled.components.spellcaster == nil, "underleveled hammer must not gain tentacle spell")

local broken = new_hammer(3000, true, true)
FrostHammerMode.SyncTentacleSpell(broken, summon_fn)
assert(broken.components.spellcaster == nil, "broken hammer must not gain tentacle spell")

print("frosthammer mode tests passed")
