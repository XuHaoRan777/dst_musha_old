require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/wander"

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 10
local MAX_WANDER_DIST = 8

local MushasporebrainFire = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower.leader or inst._owner
end

function MushasporebrainFire:OnStart()
    local root = PriorityNode(
    {
        ChaseAndAttack(self.inst, 8, 12),
        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        Wander(self.inst, function()
            local leader = GetLeader(self.inst)
            return leader ~= nil and leader:GetPosition() or nil
        end, MAX_WANDER_DIST),
    }, 0.5)

    self.bt = BT(self.inst, root)
end

return MushasporebrainFire
