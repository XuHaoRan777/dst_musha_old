local Config = {}

local function ReadConfig(get_config, name, default)
	local value = get_config(name)
	if value == nil then
		return default
	end
	return value
end

function Config.Load(get_config, tuning)
	local config = {
		badge_type = ReadConfig(get_config, "badge_type"),
		difficult_over = ReadConfig(get_config, "difficultover"),
		difficult_health = ReadConfig(get_config, "difficulthealth"),
		difficult_damage = ReadConfig(get_config, "difficultdamage"),
		difficult_damage_range = ReadConfig(get_config, "difficultdamage_range"),
		difficult_sanity = ReadConfig(get_config, "difficultsanity"),
		death_penalty = ReadConfig(get_config, "deathPenalty"),
		loud_lightning = ReadConfig(get_config, "loudlightning"),
		avisual_musha = ReadConfig(get_config, "avisual_musha"),
		avisual_princess = ReadConfig(get_config, "avisual_princess"),
		avisual_pirate = ReadConfig(get_config, "avisual_pirate"),
		avisual_pirate_armor = ReadConfig(get_config, "avisual_pirate_armor"),
		butterfly_shield = ReadConfig(get_config, "on_butterfly_shield"),
		moontree_stop = ReadConfig(get_config, "stop_spawning"),
		frostblade3rd = ReadConfig(get_config, "frostblade3rd"),
		pirateback_slot = ReadConfig(get_config, "pirateback_slot", "auto"),
		diet = ReadConfig(get_config, "dietmusha"),
		dislike = ReadConfig(get_config, "favoritemusha"),
		princess_taste = ReadConfig(get_config, "princess_taste"),
		difficult_tired = ReadConfig(get_config, "difficulttired"),
		difficult_sleep = ReadConfig(get_config, "difficultsleep"),
		difficult_music = ReadConfig(get_config, "difficultmusic"),
		difficult_sniff = ReadConfig(get_config, "difficultysniff"),
		difficult_mana = ReadConfig(get_config, "difficultmana"),
		bodyguard_wilson = ReadConfig(get_config, "bodyguardwilson"),
		modlanguage = ReadConfig(get_config, "modlanguage", "english"),
		keys = {
			KEY = ReadConfig(get_config, "key", 108),
			KEY2 = ReadConfig(get_config, "key2", 114),
			KEY3 = ReadConfig(get_config, "key3", 99),
			KEY4 = ReadConfig(get_config, "key4", 120),
			KEY5 = ReadConfig(get_config, "key5", 107),
			KEY6 = ReadConfig(get_config, "key6", 122),
			KEY7 = ReadConfig(get_config, "key7", 112),
			KEY15 = ReadConfig(get_config, "key15", 111),
			KEY8 = ReadConfig(get_config, "key8", 118),
			KEY9 = ReadConfig(get_config, "key9", 98),
			KEY11 = ReadConfig(get_config, "key11", 103),
			KEY12 = ReadConfig(get_config, "key12", 116),
			KEY13 = ReadConfig(get_config, "key13", 282),
			KEY14 = ReadConfig(get_config, "key14", 283),
			KEY16 = ReadConfig(get_config, "key16", 285),
		},
	}

	if config.modlanguage == nil or config.modlanguage == "auto" then
		config.modlanguage = "english"
	end

	tuning.MUSHA_PIRATEBACK_SLOT = config.pirateback_slot
	tuning.MUSHA = config.keys

	return config
end

return Config
