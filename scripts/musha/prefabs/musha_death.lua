local MushaDeath = {}

local DEATH_PENALTIES = {
    { min = 1, max = 5, value = 1, text = " -1" },
    { min = 5, max = 10, value = 3, text = " -3 " },
    { min = 10, max = 30, value = 6, text = " -6 " },
    { min = 30, max = 50, value = 9, text = " -9 " },
    { min = 50, max = 80, value = 12, text = " -12 " },
    { min = 80, max = 125, value = 16, text = " -16 " },
    { min = 125, max = 200, value = 20, text = " -20 " },
    { min = 200, max = 340, value = 24, text = " -24 " },
    { min = 340, max = 430, value = 28, text = " -28 " },
    { min = 430, max = 530, value = 32, text = " -32 " },
    { min = 530, max = 640, value = 37, text = " -37 " },
    { min = 640, max = 760, value = 42, text = " -42 " },
    { min = 760, max = 890, value = 47, text = " -47 " },
    { min = 890, max = 1030, value = 52, text = " -52 " },
    { min = 1030, max = 1180, value = 57, text = " -57 " },
    { min = 1180, max = 1340, value = 63, text = " -63 " },
    { min = 1340, max = 1510, value = 69, text = " -69 " },
    { min = 1510, max = 1690, value = 75, text = " -75 " },
    { min = 1690, max = 1880, value = 81, text = " -81 " },
    { min = 1880, max = 2080, value = 87, text = " -87 " },
    { min = 2080, max = 2290, value = 94, text = " -94 " },
    { min = 2290, max = 2500, value = 111, text = " -111 " },
    { min = 2500, max = 2850, value = 118, text = " -118 " },
    { min = 2850, max = 3200, value = 125, text = " -125 " },
    { min = 3200, max = 3700, value = 132, text = " -132 " },
    { min = 3700, max = 4200, value = 140, text = " -140 " },
    { min = 4200, max = 4700, value = 150, text = " -150 " },
    { min = 4700, max = 5500, value = 160, text = " -160 " },
    { min = 5500, max = 7000, value = 170, text = " -170 " },
    { min = 7000, value = 200, text = " -200 " },
}

local function FindPenalty(level)
    for _, row in ipairs(DEATH_PENALTIES) do
        if level >= row.min and (row.max == nil or level < row.max) then
            return row
        end
    end
end

function MushaDeath.ApplyPenalty(inst, levelexp, strings)
    if inst.no_panalty then
        return
    end

    local penalty = FindPenalty(inst.level or 0)
    if penalty == nil then
        return
    end

    inst.level = inst.level - penalty.value
    inst:DoTaskInTime(4.5, function()
        inst.components.talker:Say(strings.MUSHA_DEATH_PENALTY .. penalty.text)
    end)
    levelexp(inst)
end

return MushaDeath
