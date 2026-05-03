local EquipmentPostInit = {}

local BACK_VISUAL_FLAGS = {
	Bmm = "Bmm",
	BT = "BT",
	BS = "BS",
	BM = "BL",
	BL = "BL",
	WSP = "WSP",
	WSR = "WSR",
	WSB = "WSB",
	WSH = "WSH",
	WLR = "WLR",
	WLB = "WLB",
}

local PIRATE_ARMOR_FLAGS = {
	pirate = "Pirate",
	green = "Green",
	pink = "Pink",
	blue = "Blue",
	chest = "Chest",
}

local function ApplyFlag(inst, flag)
	if flag ~= nil then
		inst[flag] = true
	end
end

local function RegisterBackVisual(add_prefab_post_init, prefab, value)
	add_prefab_post_init(prefab, function(inst)
		ApplyFlag(inst, BACK_VISUAL_FLAGS[value])
	end)
end

function EquipmentPostInit.Register(config, add_prefab_post_init)
	RegisterBackVisual(add_prefab_post_init, "armor_mushaa", config.avisual_musha)
	RegisterBackVisual(add_prefab_post_init, "armor_mushab", config.avisual_princess)
	RegisterBackVisual(add_prefab_post_init, "pirateback", config.avisual_pirate)

	add_prefab_post_init("pirateback", function(inst)
		ApplyFlag(inst, PIRATE_ARMOR_FLAGS[config.avisual_pirate_armor])
	end)

	add_prefab_post_init("broken_frosthammer", function(inst)
		if config.butterfly_shield == 2 then
			inst.no_butterfly_shield = true
		end
	end)

	add_prefab_post_init("moontree_musha", function(inst)
		if config.moontree_stop == 2 then
			inst.radius_spawning = true
		elseif config.moontree_stop == 3 then
			inst.stop_spawning = true
		end
	end)

	add_prefab_post_init("mushasword_frost", function(inst)
		if config.frostblade3rd == 2 then
			inst.frostblade3rd_spear = true
		elseif config.frostblade3rd == 3 then
			inst.frostblade3rd_spear = true
			inst.frostblade3rd_spear_range = true
		end
	end)
end

return EquipmentPostInit
