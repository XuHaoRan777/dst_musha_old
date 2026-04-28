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

return SkillDefs
