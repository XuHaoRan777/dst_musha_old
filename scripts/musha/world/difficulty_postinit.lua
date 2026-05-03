local DifficultyPostInit = {}

local function SetConfigFlag(inst, value, flags)
	local flag = flags[value]
	if flag ~= nil then
		inst[flag] = true
	end
end

function DifficultyPostInit.Register(config, add_prefab_post_init, is_server, vector3, skill_defs)
	add_prefab_post_init("musha", function(inst)
		if is_server then
			inst.loud_1 = config.loud_lightning == "loud1"
			inst.loud_2 = config.loud_lightning == "loud2"
			inst.loud_3 = config.loud_lightning == "loud3"
		end
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server and config.death_penalty == "off" then
			inst.no_panalty = true
		end
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server then
			inst.No_Sleep_Princess = config.badge_type == 0
		end
	end)

	local never_eat_prefabs = {
		"powcake",
		"mandrake",
		"cookedmandrake",
		"spoiled_food",
	}
	for _, prefab in ipairs(never_eat_prefabs) do
		add_prefab_post_init(prefab, function(inst)
			if is_server then
				inst:AddTag("no_edible")
			end
		end)
	end

	add_prefab_post_init("musha", function(inst)
		inst.components.talker.fontsize = 26
		inst.components.talker.colour = vector3(0.75, 0.9, 1, 1)
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server then
			SetConfigFlag(inst, config.difficult_health, {
				easy = "easyh",
				normal = "normalh",
				hard = "hardh",
				hardcore = "hardcoreh",
			})
		end
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server then
			local flags = {
				newbie = { "newbied", 1.5 },
				sveasy = { "sveasyd", 1.25 },
				veasy = { "seasyd", 1 },
				easy = { "easyd", 0.75 },
				normal = { "normald", 0.55 },
				hard = { "hardd", 0.4 },
				hardcore = { "hardcored", 0.25 },
			}
			local data = flags[config.difficult_damage]
			if data ~= nil then
				inst[data[1]] = true
				inst.components.combat.damagemultiplier = data[2]
			end
		end
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server then
			SetConfigFlag(inst, config.difficult_damage_range, {
				veasy = "veasy",
				easy = "easy",
				normal = "normalr",
				hard = "hardr",
				hardcore = "hardcorer",
			})
		end
	end)

	local range_weapons = {
		"boomerang",
		"blowdart_sleep",
		"blowdart_fire",
		"blowdart_pipe",
		"blowdart_walrus",
		"blowdart_poison",
		"blowdart_yellow",
	}
	for _, prefab in ipairs(range_weapons) do
		add_prefab_post_init(prefab, function(inst)
			if is_server then
				inst:AddTag("range_weapon")
			end
		end)
	end

	add_prefab_post_init("musha", function(inst)
		if is_server then
			SetConfigFlag(inst, config.difficult_tired, {
				dtired_veasy = "dtired_veasy",
				dtired_easy = "dtired_easy",
				dtired_normal = "dtired_normal",
				dtired_hard = "dtired_hard",
				dtired_hardcore = "dtired_hardcore",
			})
		end
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server then
			SetConfigFlag(inst, config.difficult_sleep, {
				dsleep_veasy = "dsleep_veasy",
				dsleep_easy = "dsleep_easy",
				dsleep_normal = "dsleep_normal",
				dsleep_hard = "dsleep_hard",
				dsleep_hardcore = "dsleep_hardcore",
			})
		end
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server then
			SetConfigFlag(inst, config.difficult_music, {
				dmusic_veasy = "dmusic_veasy",
				dmusic_easy = "dmusic_easy",
				dmusic_normal = "dmusic_normal",
				dmusic_hard = "dmusic_hard",
				dmusic_hardcore = "dmusic_hardcore",
			})
		end
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server then
			inst.musha_mana_regen = skill_defs.GetManaRegenForConfig(config.difficult_mana)
			SetConfigFlag(inst, config.difficult_mana, {
				dmana_veasy = "dmana_veasy",
				dmana_easy = "dmana_easy",
				dmana_normal = "dmana_normal",
				dmana_hard = "dmana_hard",
				dmana_hardcore = "dmana_hardcore",
			})
		end
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server then
			SetConfigFlag(inst, config.difficult_sniff, {
				easy = "dsniff_easy",
				normal = "dsniff_normal",
				hard = "dsniff_hard",
				hardcore = "dsniff_hardcore",
			})
		end
	end)

	add_prefab_post_init("musha", function(inst)
		if is_server then
			SetConfigFlag(inst, config.difficult_sanity, {
				newbie = "newbies",
				easy = "easys",
				normal = "normals",
				hard = "hards",
				hardcore = "hardcores",
			})
		end
	end)
end

return DifficultyPostInit
