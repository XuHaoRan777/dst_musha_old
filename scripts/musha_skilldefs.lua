local SkillDefs = {}

local LIGHTNING_LEVELS =
{
    { max = 430, damage = 40, frost = 1.5, frost_damage = 5, fire_damage = 15 },
    { max = 1880, damage = 60, frost = 2, frost_damage = 10, fire_damage = 30 },
    { max = 6999, damage = 80, frost = 2.5, frost_damage = 15, fire_damage = 45 },
    { damage = 100, frost = 3, frost_damage = 20, fire_damage = 60 },
}

local MANA_REGEN_BY_CONFIG =
{
    dmana_veasy = 5,
    dmana_easy = 3,
    dmana_normal = 2,
    dmana_hard = 1,
    dmana_hardcore = 1,
}

local ACTIVE_SHIELD_LEVELS =
{
    {
        max = 430,
        cooldown = 90,
        ready_flag = "timec1",
        unlock_flag = "shield_level1",
        cooldown_string = "MUSHA_TALK_SHIELD_COOL_90",
    },
    {
        max = 1880,
        cooldown = 80,
        ready_flag = "timec2",
        unlock_flag = "shield_level2",
        cooldown_string = "MUSHA_TALK_SHIELD_COOL_80",
    },
    {
        max = 7000,
        cooldown = 70,
        ready_flag = "timec3",
        unlock_flag = "shield_level3",
        cooldown_string = "MUSHA_TALK_SHIELD_COOL_70",
    },
    {
        cooldown = 60,
        ready_flag = "timec4",
        unlock_flag = "shield_level4",
        cooldown_string = "MUSHA_TALK_SHIELD_COOL_60",
    },
}

local MANA_COSTS =
{
    frost_wind = 15,
    power_attack_required = 5,
    power_attack_cost = 3,
    lightning_book = 10,
    berserk_chain_lightning = 1,
    valkyrie_lightning_start = 9,
    valkyrie_lightning_refund = 6,
    valkyrie_passive_lightning = 1,
    active_shield = 30,
    electric_shield = 2,
    forcefield = 5,
    frosthammer_boost = 2,
    frost_tentacle = 25,
}

function SkillDefs.GetLightningLevel(level)
    level = level or 0
    for _, def in ipairs(LIGHTNING_LEVELS) do
        if def.max == nil or level <= def.max then
            return def
        end
    end
end

function SkillDefs.GetManaRegenForConfig(config)
    return MANA_REGEN_BY_CONFIG[config] or 1
end

function SkillDefs.GetManaRegen(inst)
    if inst.musha_mana_regen ~= nil then
        return inst.musha_mana_regen
    end
    if inst.dmana_veasy then
        return MANA_REGEN_BY_CONFIG.dmana_veasy
    elseif inst.dmana_easy then
        return MANA_REGEN_BY_CONFIG.dmana_easy
    elseif inst.dmana_normal then
        return MANA_REGEN_BY_CONFIG.dmana_normal
    elseif inst.dmana_hard or inst.dmana_hardcore then
        return 1
    end
    return 1
end

function SkillDefs.GetManaCost(key)
    return MANA_COSTS[key] or 0
end

function SkillDefs.HasMana(inst, key, inclusive)
    local spellpower = inst ~= nil and inst.components ~= nil and inst.components.spellpower or nil
    if spellpower == nil then
        return false
    end

    local cost = SkillDefs.GetManaCost(key)
    if inclusive == false then
        return spellpower.current > cost
    end
    return spellpower.current >= cost
end

function SkillDefs.SpendMana(inst, key, overtime)
    local spellpower = inst ~= nil and inst.components ~= nil and inst.components.spellpower or nil
    if spellpower == nil then
        return false
    end

    local cost = SkillDefs.GetManaCost(key)
    if cost <= 0 then
        return true
    end

    spellpower:DoDelta(-cost, overtime)
    return true
end

function SkillDefs.RestoreMana(inst, key)
    local spellpower = inst ~= nil and inst.components ~= nil and inst.components.spellpower or nil
    if spellpower == nil then
        return false
    end

    local cost = SkillDefs.GetManaCost(key)
    if cost <= 0 then
        return true
    end

    spellpower:DoDelta(cost)
    return true
end

function SkillDefs.GetActiveShieldLevel(level)
    level = level or 0
    for _, def in ipairs(ACTIVE_SHIELD_LEVELS) do
        if def.max == nil or level < def.max then
            return def
        end
    end
end

function SkillDefs.ForEachActiveShieldLevel(fn)
    for _, def in ipairs(ACTIVE_SHIELD_LEVELS) do
        fn(def)
    end
end

return SkillDefs
