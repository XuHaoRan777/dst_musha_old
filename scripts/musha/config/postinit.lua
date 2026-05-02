local ConfigPostInit = {}

local function AddFuel(inst, fuelvalue)
	if inst.components.fuel == nil then
		inst:AddComponent("fuel")
	end
	inst.components.fuel.fuelvalue = fuelvalue
	inst.components.fuel.fueltype = "CHEMICAL"
	inst:AddTag("elements")
end

local function SetFlag(inst, flag)
	if flag ~= nil then
		inst[flag] = true
	end
end

function ConfigPostInit.Register(config, add_prefab_post_init, is_server, tuning)
	add_prefab_post_init("musha", function(inst)
		if is_server and config.bodyguard_wilson == 1 then
			inst.no_bodyguard = true
		end
	end)

	if config.princess_taste == "princess" then
		add_prefab_post_init("musha", function(inst)
			if is_server then
				inst.princess_taste = true
			end
		end)
	end

	local dislike_flags = {
		dis_meat = "dis_meat_taste",
		dis_veggie = "dis_veggie_taste",
	}
	if dislike_flags[config.dislike] ~= nil then
		add_prefab_post_init("musha", function(inst)
			if is_server then
				SetFlag(inst, dislike_flags[config.dislike])
			end
		end)
	end

	local diet_flags = {
		normal = "normal_taste",
		meat = "meat_taste",
		veggie = "veggie_taste",
	}
	if diet_flags[config.diet] ~= nil then
		add_prefab_post_init("musha", function(inst)
			if is_server then
				SetFlag(inst, diet_flags[config.diet])
			end
		end)
	end

	add_prefab_post_init("tentacle_pillar_arm", function(inst)
		if is_server then
			inst:AddTag("no_exp")
		end
	end)

	add_prefab_post_init("icecream", function(inst)
		if is_server then
			inst:AddTag("icecream")
		end
	end)

	local large_fuel_items = {
		"goldnugget",
		"thulecite",
	}
	for _, prefab in ipairs(large_fuel_items) do
		add_prefab_post_init(prefab, function(inst)
			AddFuel(inst, tuning.LARGE_FUEL)
		end)
	end

	local ore_fuel_items = {
		"rocks",
		"flint",
		"marble",
		"moonrocknugget",
		"thulecite_pieces",
		"boneshard",
	}
	for _, prefab in ipairs(ore_fuel_items) do
		add_prefab_post_init(prefab, function(inst)
			AddFuel(inst, tuning.MED_LARGE_FUEL)
		end)
	end

	local small_fuel_items = {
		"stinger",
		"spidergland",
		"houndstooth",
		"snakeskin",
		"slurtle_shellpieces",
		"silk",
	}
	for _, prefab in ipairs(small_fuel_items) do
		add_prefab_post_init(prefab, function(inst)
			AddFuel(inst, tuning.SMALL_FUEL)
		end)
	end

	add_prefab_post_init("musha", function(inst)
		if inst:HasTag("musha") and not inst.ghostenabled then
			inst.yamche_egg_hunted = true
		end
	end)
end

return ConfigPostInit
