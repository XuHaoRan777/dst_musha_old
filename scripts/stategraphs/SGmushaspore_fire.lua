require("stategraphs/commonstates")

local events =
{
    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg.statemem.wantstomove = true
                    inst.sg:GoToState("moving")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end
    end),
    EventHandler("doattack", function(inst)
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("attack")
        end
    end),
    EventHandler("attacked", function(inst)
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("death", function(inst)
        if not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death")
        end
    end),
}

local states =
{
    State{
        name = "moving",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("flight_cycle", true)
        end,
    },

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()
            if not inst.AnimState:IsCurrentAnimation("idle_flight_loop") then
                inst.AnimState:PlayAnimation("idle_flight_loop", true)
            end
            inst.sg:SetTimeout(0.25)
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.wantstomove then
                inst.sg:GoToState("moving")
            else
                inst.sg:GoToState("idle")
            end
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("idle_flight_loop")

            local target = inst.components.combat.target
            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
            end
            inst.sg:SetTimeout(12 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("cough_out")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy", "dead" },

        onenter = function(inst)
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.AnimState:PlayAnimation("land")
        end,

        timeline =
        {
            TimeEvent(45 * FRAMES, function(inst)
                inst.Light:Enable(false)
                inst.DynamicShadow:Enable(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:Remove()
            end),
        },
    },

    State{
        name = "takeoff",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("cough_out")
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst.Light:Enable(true)
                inst.DynamicShadow:Enable(true)
                inst.SoundEmitter:PlaySound("dontstarve/cave/mushtree_tall_spore_land")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

CommonStates.AddFrozenStates(states)

return StateGraph("musha_spore_fire", states, events, "takeoff")
