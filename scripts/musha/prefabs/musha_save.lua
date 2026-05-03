local MushaSave = {}

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
        callbacks.treasure_hunt(inst)
    end
    if data.count_w ~= nil then
        inst.count_w = data.count_w
        callbacks.count_wil(inst)
    end
    if data.music ~= nil then
        inst.music = data.music
        callbacks.fullcharged_music(inst)
    end

    if data.level ~= nil then
        inst.level = data.level
        callbacks.levelexp(inst)
        if data.health and data.health.health then
            inst.components.health.currenthealth = data.health.health
        end
        if data.sanity and data.sanity.current then
            inst.components.sanity.current = data.sanity.current
        end
        inst.components.health:DoDelta(0)
        inst.components.sanity:DoDelta(0)
    end
end

function MushaSave.OnSave(inst, data)
    if data ~= nil and data.level then
        data.level = inst.level:GetSaveRecord()
    end

    data.level = inst.level > 0 and inst.level or nil
    data.music = inst.music or nil
    data.count_w = inst.count_w or nil
    data.treasure = inst.treasure or nil
    data.yamche_egg_hunted = inst.yamche_egg_hunted or nil
    data.arong_egg_hunted = inst.arong_egg_hunted or nil
end

return MushaSave
