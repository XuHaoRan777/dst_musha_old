local ArongRiding = {}

function ArongRiding.CalculateBuckDelay(inst, is_in_mood, tendency)
    local domestication =
        inst.components.domesticatable ~= nil
        and inst.components.domesticatable:GetDomestication()
        or 0

    local moodmult = is_in_mood(inst) and TUNING.BEEFALO_BUCK_TIME_MOOD_MULT or 1

    local beardmult =
        (inst.components.beard ~= nil and inst.components.beard.bits == 0)
        and TUNING.BEEFALO_BUCK_TIME_NUDE_MULT
        or 1

    local domesticmult =
        inst.components.domesticatable:IsDomesticated()
        and 1
        or TUNING.BEEFALO_BUCK_TIME_UNDOMESTICATED_MULT

    local basedelay = Remap(domestication, 0, 1, TUNING.BEEFALO_MIN_BUCK_TIME, TUNING.BEEFALO_MAX_BUCK_TIME)

    return basedelay * moodmult * beardmult * domesticmult
end

function ArongRiding.OnBeingRidden(inst, dt, tendency)
    inst.components.domesticatable:DeltaTendency(tendency.RIDER, TUNING.BEEFALO_RIDER_RIDDEN * dt)
end

function ArongRiding.OnRiderDoAttack(inst, tendency)
    inst.components.domesticatable:DeltaTendency(tendency.ORNERY, TUNING.BEEFALO_ORNERY_DOATTACK)
end

function ArongRiding.DoRiderSleep(inst, sleepiness, sleeptime)
    inst._ridersleeptask = nil
    inst.components.sleeper:AddSleepiness(sleepiness, sleeptime)
end

function ArongRiding.OnRiderSleep(inst, data)
    inst._ridersleep = inst.components.rideable:IsBeingRidden() and {
        time = GetTime(),
        sleepiness = data.sleepiness,
        sleeptime = data.sleeptime,
    } or nil
end

return ArongRiding
