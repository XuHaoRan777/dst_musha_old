local CompanionStates = {}

function CompanionStates.IsCommandable(companion, opts)
    if companion == nil
        or companion.components == nil
        or companion.components.follower == nil then
        return false
    end

    if opts ~= nil and opts.can_command ~= nil then
        return opts.can_command(companion)
    end

    return true
end

function CompanionStates.FindClosest(owner, tag, radius, predicate)
    local x, y, z = owner.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius or 25, {tag})
    local closest = nil
    local closest_distsq = nil

    for _, ent in pairs(ents) do
        if predicate == nil or predicate(ent) then
            local distsq = owner:GetDistanceSqToInst(ent)
            if closest == nil or distsq < closest_distsq then
                closest = ent
                closest_distsq = distsq
            end
        end
    end

    return closest
end

function CompanionStates.FindCommandable(owner, tag, radius, opts)
    return CompanionStates.FindClosest(owner, tag, radius, function(companion)
        return CompanionStates.IsCommandable(companion, opts)
    end)
end

function CompanionStates.FindOwned(owner, tag, radius)
    return CompanionStates.FindClosest(owner, tag, radius, function(companion)
        return companion.components ~= nil
            and companion.components.follower ~= nil
            and owner.components ~= nil
            and owner.components.leader ~= nil
            and (companion.components.follower.leader == owner
                or owner.components.leader:IsFollower(companion))
    end)
end

function CompanionStates.HasOwned(owner, tag, radius)
    if owner.components == nil or owner.components.leader == nil then
        return false
    end

    return owner.components.leader:CountFollowers(tag) > 0
        or CompanionStates.FindOwned(owner, tag, radius) ~= nil
end

function CompanionStates.SetFollowing(owner, companion, tag, opts)
    if owner.components == nil
        or owner.components.leader == nil
        or not CompanionStates.IsCommandable(companion, opts) then
        return false
    end

    if companion.components.follower.leader ~= owner then
        companion.components.follower:SetLeader(owner)
    end

    if not owner.components.leader:IsFollower(companion)
        and owner.components.leader:CountFollowers(tag) == 0 then
        owner.components.leader:AddFollower(companion)
    end

    if opts ~= nil and opts.on_follow ~= nil then
        opts.on_follow(owner, companion)
    end

    if opts ~= nil and opts.migrate_with_owner then
        CompanionStates.AttachMigrationPet(owner, companion)
    end

    return true
end

function CompanionStates.SetResting(owner, companion, tag, opts)
    if owner.components == nil
        or owner.components.leader == nil
        or companion == nil
        or companion.components == nil
        or companion.components.follower == nil then
        return false
    end

    if opts ~= nil and opts.migrate_with_owner then
        CompanionStates.DetachMigrationPet(owner, companion)
    end

    if owner.components.leader:IsFollower(companion) then
        owner.components.leader:RemoveFollowersByTag(tag)
    end

    companion.components.follower:SetLeader(nil)

    if opts ~= nil and opts.on_rest ~= nil then
        opts.on_rest(owner, companion)
    end

    return true
end

function CompanionStates.AttachMigrationPet(owner, companion)
    if owner.components == nil
        or owner.components.petleash == nil
        or companion == nil
        or not companion:IsValid() then
        return false
    end

    if not owner.components.petleash:IsPet(companion)
        and not owner.components.petleash:AttachPet(companion) then
        return false
    end

    companion.musha_migration_companion = true
    companion.persists = false
    return true
end

function CompanionStates.DetachMigrationPet(owner, companion)
    if owner.components == nil
        or owner.components.petleash == nil
        or companion == nil then
        return false
    end

    if owner.components.petleash:IsPet(companion) then
        owner.components.petleash:DetachPet(companion)
    end

    companion.musha_migration_companion = nil
    companion.persists = true
    return true
end

return CompanionStates
