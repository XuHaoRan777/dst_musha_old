local WorldPostInit = {}

local function SetHitEffectSymbol(inst, symbol)
	if inst.components.combat ~= nil then
		inst.components.combat.hiteffectsymbol = symbol
	end
end

local function AddFollowerComponent(inst)
	if inst.components.follower == nil then
		inst:AddComponent("follower")
	end
end

function WorldPostInit.Register(add_prefab_post_init, is_server)
	local function hound_hit_symbol(inst)
		if is_server then
			SetHitEffectSymbol(inst, "hound_body")
		end
	end

	add_prefab_post_init("hound", hound_hit_symbol)
	add_prefab_post_init("firehound", hound_hit_symbol)
	add_prefab_post_init("icehound", hound_hit_symbol)

	add_prefab_post_init("frog", function(inst)
		if is_server then
			SetHitEffectSymbol(inst, "frogsack")
		end
	end)

	add_prefab_post_init("hound", function(inst)
		if is_server then
			SetHitEffectSymbol(inst, "body")
		end
	end)

	add_prefab_post_init("nightstick", function(inst)
		if is_server then
			inst:AddTag("electric_weapon")
		end
	end)

	add_prefab_post_init("slurtlehole", function(inst)
		if is_server then
			inst:AddTag("no_target")
		end
	end)

	add_prefab_post_init("tentacle_pillar_arm", function(inst)
		if is_server then
			inst:AddTag("arm")
		end
	end)

	add_prefab_post_init("farm_plant_randomseed", function(inst)
		if is_server then
			AddFollowerComponent(inst)
			inst:AddTag("wild_veggie")
		end
	end)

	add_prefab_post_init("green_mushroom", function(inst)
		if is_server then
			AddFollowerComponent(inst)
			inst:AddTag("mushrooms")
		end
	end)
end

return WorldPostInit
