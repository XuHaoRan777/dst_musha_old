local GreenwormBehavior = {}

local function IsAreaSlush(x, y, z)
    return #TheSim:FindEntities(x, y, z, 7, { "pickable" }, { "INLIMBO" }) >= 3
end

local function IsNotClaimed(x, y, z)
    return #TheSim:FindEntities(x, y, z, 30, { "worm" }) <= 1
end

function GreenwormBehavior.LookForHome(inst)
    if inst.components.knownlocations:GetLocation("home") ~= nil then
        inst.HomeTask:Cancel()
        inst.HomeTask = nil
        return
    end

    local map = TheWorld.Map
    local x, y, z = inst.Transform:GetWorldPosition()

    for i = 1, 30 do
        local s = i / 32
        local a = math.sqrt(s * 512)
        local b = math.sqrt(s) * 30
        local x1 = x + math.sin(a) * b
        local z1 = z + math.cos(a) * b

        if map:IsAboveGroundAtPoint(x1, 0, z1) and IsAreaSlush(x1, 0, z1) and IsNotClaimed(x1, 0, z1) then
            inst.components.knownlocations:RememberLocation("home", Vector3(x1, 0, z1))
            return
        end
    end
end

function GreenwormBehavior.OnAttacked(inst, data, is_worm)
    SpawnPrefab("green_leaves").Transform:SetPosition(inst:GetPosition():Get())
    if data.attacker ~= nil then
        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 40, is_worm, 3)
    end
end

return GreenwormBehavior
