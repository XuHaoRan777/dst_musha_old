local MushaSave = {}

local function SafeNumber(value, fallback)
    if type(value) == "number" then
        return value
    end
    return fallback
end

function MushaSave.OnPreLoad(inst, data, callbacks)
    if data == nil then
        return
    end

    if data.yamche_egg_hunted ~= nil then
        inst.yamche_egg_hunted = true
    end
    if data.arong_egg_hunted ~= nil then
        inst.arong_egg_hunted = true
    end
    if data.treasure ~= nil then
        inst.treasure = data.treasure
        if callbacks ~= nil and callbacks.treasure_hunt ~= nil then
            callbacks.treasure_hunt(inst)
        end
    end
    if data.count_w ~= nil then
        inst.count_w = data.count_w
        if callbacks ~= nil and callbacks.count_wil ~= nil then
            callbacks.count_wil(inst)
        end
    end
    if data.music ~= nil then
        inst.music = data.music
        if callbacks ~= nil and callbacks.fullcharged_music ~= nil then
            callbacks.fullcharged_music(inst)
        end
    end

    local level = SafeNumber(data.level, nil)
    if level ~= nil then
        inst.level = level
        if callbacks ~= nil and callbacks.levelexp ~= nil then
            callbacks.levelexp(inst)
        end
        if data.health and data.health.health and inst.components ~= nil and inst.components.health ~= nil then
            inst.components.health.currenthealth = data.health.health
        end
        if data.sanity and data.sanity.current and inst.components ~= nil and inst.components.sanity ~= nil then
            inst.components.sanity.current = data.sanity.current
        end
        if inst.components ~= nil and inst.components.health ~= nil then
            inst.components.health:DoDelta(0)
        end
        if inst.components ~= nil and inst.components.sanity ~= nil then
            inst.components.sanity:DoDelta(0)
        end
    end
end

function MushaSave.OnSave(inst, data)
    if data == nil then
        return
    end

    local level = SafeNumber(inst.level, 0)
    data.level = level > 0 and level or nil
    data.music = SafeNumber(inst.music, nil)
    data.count_w = SafeNumber(inst.count_w, nil)
    data.treasure = SafeNumber(inst.treasure, nil)
    data.yamche_egg_hunted = inst.yamche_egg_hunted or nil
    data.arong_egg_hunted = inst.arong_egg_hunted or nil
end

return MushaSave
