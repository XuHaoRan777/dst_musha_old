require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/musha_oven.zip"),
	Asset("ANIM", "anim/musha_oven_open.zip"),
	Asset("ANIM", "anim/ui_chest_3x3.zip"),
}

local prefabs =
{
    "musha_ovenfire",
	"musha_ovenfire_cold",
    "collapse_small",
}    

local function cooked(inst)

	local container = inst.components.container

	if not inst.on_cold then
		for i = 1, container:GetNumSlots() do
	        local item = container:GetItemInSlot(i)
	     	if item then 
	     		local replacement = nil 
				if item.components.cookable or item.prefab == "log" then 
				inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel") 
						local fx = SpawnPrefab("collapse_small")
					local pos = Vector3(inst.Transform:GetWorldPosition())
					fx.Transform:SetScale(0.5, 0.5, 0.5)
				fx.Transform:SetPosition(pos:Get())
	
        local fx2 = SpawnPrefab("small_puff")
        fx2.entity:SetParent(inst.entity)
	    fx2.Transform:SetPosition(0, 3, 0)
		
				end
				
		     	if item.components.cookable then 
		     		replacement = item.components.cookable:GetProduct()
		     	elseif item.prefab == "log" then 
		     		replacement = "charcoal"
					
		      elseif item.components.burnable and item.prefab ~= "log" then
		     		replacement = "ash"				
		     	end  
		     	if replacement then 
	     			local stacksize = 1 
	     			if item.components.stackable then 
	     				stacksize = item.components.stackable:StackSize()
	     			end 
	     			local newprefab = SpawnPrefab(replacement)
	     			if newprefab.components.stackable then 
	     				newprefab.components.stackable:SetStackSize(stacksize)
	     			end 
	     			container:RemoveItemBySlot(i)
	     			item:Remove()
	     			container:GiveItem(newprefab, i)
	     		end 
		     end 
		end 
		return false 
	end 
	if inst.on_cold then
		for i = 1, container:GetNumSlots() do
	        local item = container:GetItemInSlot(i)
	     	if item then 
	     		local replacement = nil 
				if item.prefab == "watermelon" or item.prefab == "butter" or item.prefab == "cave_banana" then 
				inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter") 
						local fx = SpawnPrefab("collapse_small")
					local pos = Vector3(inst.Transform:GetWorldPosition())
					fx.Transform:SetScale(0.5, 0.5, 0.5)
				fx.Transform:SetPosition(pos:Get())
				end
				
		     	if item.prefab == "watermelon" then 
		     		replacement = "watermelonicle"
				elseif item.prefab == "butter" then 
		     		replacement = "icecream"
				elseif item.prefab == "cave_banana" then 
		     		replacement = "bananapop"	
						     	end  
		     	if replacement then 
	     			local stacksize = 1 
	     			if item.components.stackable then 
	     				stacksize = item.components.stackable:StackSize()
	     			end 
	     			local newprefab = SpawnPrefab(replacement)
	     			if newprefab.components.stackable then 
	     				newprefab.components.stackable:SetStackSize(stacksize)
	     			end 
	     			container:RemoveItemBySlot(i)
	     			item:Remove()
	     			container:GiveItem(newprefab, i)
	     		end 
		     end 
		end 
		return false 
	end 
	end
	
local function update_door_visual(inst)
	local container = inst.components.container
	inst.AnimState:SetBuild((inst.burning or (container ~= nil and container:IsOpen())) and "musha_oven_open" or "musha_oven")
end

local function onopen(inst)
	update_door_visual(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/icebox_open")
end

local function onclose(inst)
	if inst.burning then
		cooked(inst)
	end
	update_door_visual(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/icebox_close")
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	local ash = SpawnPrefab("ash")
	ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
	inst:Remove()
end

local function OnHaunt(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_RARE and
        inst.components.fueled ~= nil and
        not inst.components.fueled:IsEmpty() then
        inst.components.fueled:DoDelta(TUNING.MED_FUEL)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

local function onhit(inst, worker)
	inst.components.container:DropEverything()
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle")
end

local function onignite(inst)
	inst.burning = true
	inst.components.machine.ison = true
	if inst.on_cold then
		inst:AddTag("fridge")
	end
	update_door_visual(inst)
	if not inst.components.cooker then
		inst:AddComponent("cooker")
	end
end

local function set_mode(inst, cold)
	local burnable = inst.components.burnable
	burnable:Extinguish()
	-- Keep the component during loading; only replace its extinguished FX recipe.
	burnable.fxdata = {}
	inst.on_cold = cold
	inst.on_fire = not cold
	burnable:AddBurnFX(cold and "musha_ovenfire_cold" or "musha_ovenfire", Vector3(0, 0, 0))
	-- The mouth is opaque even in the open build, so the flame must render in front.
	-- Keep the authored position/scale and leave the shared forge FX unchanged.
	burnable:OverrideBurnFXFinalOffset(1)
end

local function turnon(inst)
	if inst._loading_oven then
		return
	end
	set_mode(inst, not inst.on_cold)
	if not inst.components.fueled:IsEmpty() then
		inst.components.burnable:Ignite()
		inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
		inst.components.talker:Say(inst.on_cold and "[[Cold Fire]]\nCooler Box-(On)" or "[[Warm Fire]]\nOven-(On)")
	end
end

local function turnoff(inst)
	if not inst._loading_oven then
		inst.components.burnable:Extinguish()
	end
end

local function onextinguish(inst)
	inst.burning = false
	inst.components.machine.ison = false
	inst:RemoveTag("fridge")
	update_door_visual(inst)
	if inst.components.cooker then
		inst:RemoveComponent("cooker")
	end
end

local function onsave(inst, data)
	data.on_cold = inst.on_cold == true
	data.burning = inst.burning == true
end

local function onpreload(inst)
	-- Machine:OnLoad calls TurnOn/TurnOff; loading must not advance the fire mode.
	inst._loading_oven = true
end

local function onload(inst, data)
	local cold = data ~= nil and data.on_cold
	if cold == nil then
		-- Older saves used machine.ison to mean cold fire, not power.
		cold = data ~= nil and data.machine ~= nil and data.machine.ison == true
	end
	local burning = data == nil or data.burning ~= false
	set_mode(inst, cold == true)
	if burning and not inst.components.fueled:IsEmpty() then
		inst.components.burnable:Ignite()
		inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
	else
		onextinguish(inst)
		inst.components.fueled:StopConsuming()
	end
	inst._loading_oven = nil
	update_door_visual(inst)
end

local function fn(Sim)

   local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .3)

    inst:AddTag("campfire")
    inst:AddTag("structure")
   inst:AddTag("wildfireprotected")
   
    inst.AnimState:SetBank("chiminea")
    inst.AnimState:SetBuild("musha_oven")
    inst.AnimState:PlayAnimation("idle", false)    
    inst.MiniMapEntity:SetIcon( "musha_oven.tex" )

    -- Advertise machine actions to clients; authoritative components are server-only.
    inst:AddTag("enabled")

	inst:AddComponent("talker")
    inst.components.talker.fontsize = 30
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(1, 1, 1, 1)
    inst.components.talker.offset = Vector3(0,-500,0)
    inst.components.talker.symbol = "swap_object"

	   inst.entity:SetPristine()

   	if not TheWorld.ismastersim then
		inst:DoTaskInTime(0, function()
			inst.replica.container:WidgetSetup("chest_yamche5")
		end)
		return inst
	end
	inst:AddComponent("machine")
	inst.components.machine.turnonfn = turnon
	inst.components.machine.turnofffn = turnoff
	inst.components.machine.cooldowntime = 0

	inst:AddComponent("burnable")
	inst.components.burnable:AddBurnFX("musha_ovenfire", Vector3(0, 0, 0))
	inst.components.burnable:OverrideBurnFXFinalOffset(1)
	inst.on_cold = false
	inst.on_fire = true
	inst:ListenForEvent("onextinguish", onextinguish)
	inst:ListenForEvent("onignite", onignite)
	-------------------------
 	inst:AddComponent("container")  
    inst.components.container:WidgetSetup("chest_yamche5")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    
      -------------------------
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)    

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.FIREPIT_FUEL_MAX
    inst.components.fueled.accepting = true
    
    inst.components.fueled:SetSections(5)
    inst.components.fueled.bonusmult = 5
    inst.components.fueled.ontakefuelfn = 
	function() inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")  
	local fx2 = SpawnPrefab("small_puff")
        fx2.entity:SetParent(inst.entity)
	    fx2.Transform:SetPosition(0, 3, 0)
		end
    inst.components.fueled.rate = 0.5

    inst.components.fueled:SetUpdateFn( function()
        if inst.components.burnable and inst.components.fueled then
            inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
        end
    end)
        
    inst.components.fueled:SetSectionCallback( function(section, oldsection)
        if inst._loading_oven then
            return
        end
        if section == 0 then
            inst.components.burnable:Extinguish()
            inst.components.machine.ison = false
        elseif oldsection == 0 and not inst.components.machine:IsOn() then
            -- Fuel was added after depletion: resume the saved fire mode without toggling it.
            inst.components.machine.ison = true
            inst.components.burnable:Ignite()
            inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
            inst.components.talker:Say(inst.on_cold and "[[Cold Fire]]\nCooler Box-(On)" or "[[Warm Fire]]\nOven-(On)")
        elseif inst.components.machine:IsOn() then
            if not inst.components.burnable:IsBurning() then
                inst.components.burnable:Ignite()
            end
            
            inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
            
        end
    end)
    inst.components.machine.ison = true
    inst.components.fueled:InitializeFuelLevel(TUNING.FIREPIT_FUEL_START)    

    inst.OnPreLoad = onpreload
    inst.OnSave = onsave
    inst.OnLoad = onload
    
    -----------------------------

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    -----------------------------   
    -----------------------------
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        local sec = inst.components.fueled:GetCurrentSection()
        if not inst.burning or sec == 0 then
            return "OUT"
        elseif sec <= 4 then
            local t = {"EMBERS","LOW","NORMAL","HIGH"}
            return t[sec]
        end
    end
    
    inst:ListenForEvent( "onbuilt", function()
        inst.AnimState:PlayAnimation("place")
        inst.AnimState:PushAnimation("idle",false)
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end)
    
    return inst
end

return Prefab( "common/objects/musha_oven", fn, assets, prefabs),
		MakePlacer( "common/musha_oven_placer", "chiminea", "musha_oven", "preview" ) 
