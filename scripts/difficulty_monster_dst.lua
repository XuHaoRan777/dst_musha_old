local Difficult = GetModConfigData("difficultover")
local IsServer = GLOBAL.TheNet:GetIsServer()

local function Tune(name, multiplier)
	return function()
		return TUNING[name] * multiplier
	end
end

local function Fixed(value)
	return function()
		return value
	end
end

local function Value(value)
	return type(value) == "function" and value() or value
end

local function ApplyMonsterDifficulty(inst, spec)
	if not IsServer or inst.components.health == nil then
		return
	end

	if spec.tag ~= nil then
		inst:AddTag(spec.tag)
	end

	if spec.health ~= nil then
		inst.components.health:SetMaxHealth(Value(spec.health))
	end

	local combat = inst.components.combat
	if combat ~= nil then
		if spec.damage ~= nil then
			combat:SetDefaultDamage(Value(spec.damage))
		end
		if spec.attack_period ~= nil then
			combat:SetAttackPeriod(Value(spec.attack_period))
		end
		if spec.range ~= nil then
			spec.range(combat)
		end
	end

	local locomotor = inst.components.locomotor
	if locomotor ~= nil then
		if spec.runspeed ~= nil then
			locomotor.runspeed = Value(spec.runspeed)
		end
		if spec.walkspeed ~= nil then
			locomotor.walkspeed = Value(spec.walkspeed)
		end
	end
end

local function RegisterSet(specs)
	for _, spec in ipairs(specs) do
		local current = spec
		AddPrefabPostInit(current.prefab, function(inst)
			ApplyMonsterDifficulty(inst, current)
		end)
	end
end

local default_tags = {
	{ prefab = "deerclops", tag = "giant1x" },
	{ prefab = "bearger", tag = "giant1x" },
	{ prefab = "dragonfly", tag = "giant1x" },
	{ prefab = "moose", tag = "giant1x" },
	{ prefab = "toadstool", tag = "giant1x" },
	{ prefab = "beequeen", tag = "giant1x" },
	{ prefab = "antlion", tag = "giant1x" },
	{ prefab = "stalker", tag = "giant1x" },
	{ prefab = "stalker_atrium", tag = "giant1x" },
	{ prefab = "mossling", tag = "small_giant1x" },
	{ prefab = "spiderqueen", tag = "small_giant1x" },
	{ prefab = "warg", tag = "small_giant1x" },
	{ prefab = "leif", tag = "small_giant1x" },
	{ prefab = "spat", tag = "small_giant1x" },
}

local monster_sets = {
	monster2x = {
		{ prefab = "deerclops", tag = "giant2x", health = Tune("DEERCLOPS_HEALTH", 2), damage = Tune("DEERCLOPS_DAMAGE", 2), attack_period = 2.75 },
		{ prefab = "bearger", tag = "giant2x", health = Tune("BEARGER_HEALTH", 2), damage = Tune("DEERCLOPS_DAMAGE", 2), attack_period = 2.75 },
		{ prefab = "dragonfly", tag = "giant2x", health = Tune("DRAGONFLY_HEALTH", 2), damage = Tune("DEERCLOPS_DAMAGE", 2), attack_period = 2.25 },
		{ prefab = "moose", tag = "giant2x", health = Tune("MOOSE_HEALTH", 2), damage = Tune("DEERCLOPS_DAMAGE", 2), attack_period = 2.75 },
		{ prefab = "mossling", tag = "small_giant2x", health = Tune("MOSSLING_HEALTH", 2), damage = Tune("DEERCLOPS_DAMAGE", 1.5) },
		{ prefab = "toadstool", tag = "giant2x", health = Tune("TOADSTOOL_HEALTH", 2.2) },
		{ prefab = "beequeen", tag = "giant2x", health = Tune("BEEQUEEN_HEALTH", 2) },
		{ prefab = "spider", tag = "monster2x", health = Tune("SPIDER_HEALTH", 2) },
		{ prefab = "spider_warrior", tag = "monster2x", health = Tune("SPIDER_WARRIOR_HEALTH", 2) },
		{ prefab = "spiderqueen", tag = "small_giant2x", health = Tune("SPIDERQUEEN_HEALTH", 2) },
		{ prefab = "spider_hider", tag = "monster2x", health = Tune("SPIDER_HIDER_HEALTH", 2) },
		{ prefab = "spider_spitter", tag = "monster2x", health = Tune("SPIDER_SPITTER_HEALTH", 2) },
		{ prefab = "spider_dropper", tag = "monster2x", health = Tune("SPIDER_WARRIOR_HEALTH", 2) },
		{ prefab = "hound", tag = "monster2x", health = Tune("HOUND_HEALTH", 2) },
		{ prefab = "firehound", tag = "monster2x", health = Tune("FIREHOUND_HEALTH", 2) },
		{ prefab = "icehound", tag = "monster2x", health = Tune("ICEHOUND_HEALTH", 2) },
		{ prefab = "warg", tag = "small_giant2x", health = Tune("WARG_HEALTH", 2) },
		{ prefab = "tentacle", tag = "monster2x", health = Tune("TENTACLE_HEALTH", 2), damage = Tune("TENTACLE_DAMAGE", 1.5) },
		{ prefab = "rook", tag = "monster2x", health = Tune("ROOK_HEALTH", 2), damage = Tune("ROOK_DAMAGE", 1.5) },
		{ prefab = "minotaur", tag = "monster2x", health = Tune("MINOTAUR_HEALTH", 2), damage = Tune("MINOTAUR_DAMAGE", 1.5) },
		{ prefab = "bishop", tag = "monster2x", health = Tune("BISHOP_HEALTH", 2), damage = Tune("BISHOP_DAMAGE", 1.2) },
		{ prefab = "tallbird", tag = "monster2x", health = Tune("TALLBIRD_HEALTH", 2) },
		{ prefab = "leif", tag = "small_giant2x", health = Tune("LEIF_HEALTH", 2) },
		{ prefab = "spat", tag = "small_giant2x", health = Tune("SPAT_HEALTH", 2) },
		{ prefab = "birchnutdrake", tag = "monster2x", health = Fixed(100) },
		{ prefab = "merm", tag = "monster2x", health = Tune("MERM_HEALTH", 4) },
		{ prefab = "bat", tag = "monster2x", health = Tune("BAT_HEALTH", 2) },
		{ prefab = "monkey", tag = "monster2x", health = Tune("MONKEY_HEALTH", 2) },
		{ prefab = "walrus", tag = "monster2x", health = Tune("WALRUS_HEALTH", 2) },
		{ prefab = "eyeplant", tag = "monster2x", health = Tune("EYEPLANT_HEALTH", 2) },
		{ prefab = "antlion", tag = "giant2x", health = Tune("ANTLION_HEALTH", 2.2) },
		{ prefab = "stalker", tag = "giant2x", health = Tune("STALKER_HEALTH", 2) },
		{ prefab = "stalker_atrium", tag = "giant2x", health = Tune("STALKER_ATRIUM_HEALTH", 2) },
	},
	monster3x = {
		{ prefab = "deerclops", tag = "giant3x", health = Tune("DEERCLOPS_HEALTH", 3), damage = Tune("DEERCLOPS_DAMAGE", 2.5), attack_period = 2.6 },
		{ prefab = "bearger", tag = "giant3x", health = Tune("BEARGER_HEALTH", 3), damage = Tune("BEARGER_DAMAGE", 2.5), attack_period = 2.6, range = function(combat) combat:SetRange(TUNING.BEARGER_ATTACK_RANGE, TUNING.BEARGER_MELEE_RANGE) end },
		{ prefab = "dragonfly", tag = "giant3x", health = Tune("DRAGONFLY_HEALTH", 3), damage = Tune("DRAGONFLY_DAMAGE", 2.5), attack_period = 2.1 },
		{ prefab = "moose", tag = "giant3x", health = Tune("MOOSE_HEALTH", 3), damage = Tune("MOOSE_DAMAGE", 2.5), attack_period = 2.6 },
		{ prefab = "mossling", tag = "small_giant3x", health = Tune("MOSSLING_HEALTH", 3), damage = Tune("MOSSLING_DAMAGE", 2.5) },
		{ prefab = "toadstool", tag = "giant3x", health = Tune("TOADSTOOL_HEALTH", 3.3) },
		{ prefab = "beequeen", tag = "giant3x", health = Tune("BEEQUEEN_HEALTH", 3) },
		{ prefab = "spider", tag = "monster3x", health = Tune("SPIDER_HEALTH", 4), damage = Tune("SPIDER_DAMAGE", 1.5), attack_period = 2.75 },
		{ prefab = "spider_warrior", tag = "monster3x", health = Tune("SPIDER_WARRIOR_HEALTH", 4), damage = Tune("SPIDER_WARRIOR_DAMAGE", 1.5), attack_period = function() return 3.75 + math.random() * 2 end },
		{ prefab = "spiderqueen", tag = "small_giant3x", health = Tune("SPIDERQUEEN_HEALTH", 4), damage = Tune("SPIDERQUEEN_DAMAGE", 1.5), attack_period = 2.75 },
		{ prefab = "spider_hider", tag = "monster3x", health = Tune("SPIDER_HIDER_HEALTH", 4), damage = Tune("SPIDER_HIDER_DAMAGE", 1.5), attack_period = 2.75 },
		{ prefab = "spider_spitter", tag = "monster3x", health = Tune("SPIDER_SPITTER_HEALTH", 4), damage = Tune("SPIDER_SPITTER_DAMAGE_MELEE", 1.5), attack_period = function() return 4.75 + math.random() * 2 end },
		{ prefab = "spider_dropper", tag = "monster3x", health = Tune("SPIDER_WARRIOR_HEALTH", 4), damage = Tune("SPIDER_WARRIOR_DAMAGE", 1.5), attack_period = function() return 2.75 + math.random() * 2 end },
		{ prefab = "hound", tag = "monster3x", health = Tune("HOUND_HEALTH", 4), damage = Tune("HOUND_DAMAGE", 1.5), attack_period = 1.75 },
		{ prefab = "firehound", tag = "monster3x", health = Tune("FIREHOUND_HEALTH", 4), damage = Tune("FIREHOUND_DAMAGE", 1.5), attack_period = 1.75 },
		{ prefab = "icehound", tag = "monster3x", health = Tune("ICEHOUND_HEALTH", 4), damage = Tune("ICEHOUND_DAMAGE", 1.5), attack_period = 1.75 },
		{ prefab = "warg", tag = "small_giant3x", health = Tune("WARG_HEALTH", 4), damage = Tune("WARG_DAMAGE", 1.5), attack_period = 2.75 },
		{ prefab = "tentacle", tag = "monster3x", health = Tune("TENTACLE_HEALTH", 4), damage = Tune("TENTACLE_DAMAGE", 2) },
		{ prefab = "rook", tag = "monster3x", health = Tune("ROOK_HEALTH", 4), damage = Tune("ROOK_DAMAGE", 2) },
		{ prefab = "minotaur", tag = "monster3x", health = Tune("MINOTAUR_HEALTH", 4), damage = Tune("MINOTAUR_DAMAGE", 2) },
		{ prefab = "bishop", tag = "monster3x", health = Tune("BISHOP_HEALTH", 4), damage = Tune("BISHOP_DAMAGE", 1.6) },
		{ prefab = "tallbird", tag = "monster3x", health = Tune("TALLBIRD_HEALTH", 4), damage = Tune("TALLBIRD_DAMAGE", 1.5), attack_period = 1.75 },
		{ prefab = "leif", tag = "small_giant3x", health = Tune("LEIF_HEALTH", 4), damage = Tune("LEIF_DAMAGE", 1.5) },
		{ prefab = "spat", tag = "small_giant3x", health = Tune("SPAT_HEALTH", 4), damage = Tune("SPAT_PHLEGM_DAMAGE", 1.25) },
		{ prefab = "birchnutdrake", tag = "monster3x", health = Fixed(150), damage = 10 },
		{ prefab = "merm", tag = "monster3x", health = Tune("MERM_HEALTH", 4), damage = Tune("MERM_DAMAGE", 1.5) },
		{ prefab = "bat", tag = "monster3x", health = Tune("BAT_HEALTH", 4), damage = Tune("BAT_DAMAGE", 1.5) },
		{ prefab = "monkey", tag = "monster3x", health = Tune("MONKEY_HEALTH", 4) },
		{ prefab = "walrus", tag = "monster3x", health = Tune("WALRUS_HEALTH", 4), runspeed = 6, walkspeed = 2 },
		{ prefab = "eyeplant", tag = "monster3x", health = Tune("EYEPLANT_HEALTH", 4), damage = Tune("EYEPLANT_DAMAGE", 1.5) },
		{ prefab = "antlion", tag = "giant3x", health = Tune("ANTLION_HEALTH", 3.3) },
		{ prefab = "stalker", tag = "giant3x", health = Tune("STALKER_HEALTH", 3) },
		{ prefab = "stalker_atrium", tag = "giant3x", health = Tune("STALKER_ATRIUM_HEALTH", 3) },
	},
	monster4x = {
		{ prefab = "deerclops", tag = "giant4x", health = Tune("DEERCLOPS_HEALTH", 5), damage = Tune("DEERCLOPS_DAMAGE", 3), attack_period = 2.3 },
		{ prefab = "bearger", tag = "giant4x", health = Tune("BEARGER_HEALTH", 5), damage = Tune("BEARGER_DAMAGE", 3), attack_period = 2.3, range = function(combat) combat:SetRange(TUNING.BEARGER_ATTACK_RANGE, TUNING.BEARGER_MELEE_RANGE) end },
		{ prefab = "dragonfly", tag = "giant4x", health = Tune("DRAGONFLY_HEALTH", 5), damage = Tune("DRAGONFLY_DAMAGE", 3), attack_period = 1.8 },
		{ prefab = "moose", tag = "giant4x", health = Tune("MOOSE_HEALTH", 5), damage = Tune("MOOSE_DAMAGE", 3), attack_period = 2.3 },
		{ prefab = "mossling", tag = "small_giant4x", health = Tune("MOSSLING_HEALTH", 5), damage = Tune("MOSSLING_DAMAGE", 3) },
		{ prefab = "toadstool", tag = "giant4x", health = Tune("TOADSTOOL_HEALTH", 5.5) },
		{ prefab = "beequeen", tag = "giant4x", health = Tune("BEEQUEEN_HEALTH", 4) },
		{ prefab = "spider", tag = "monster4x", health = Tune("SPIDER_HEALTH", 6), damage = Tune("SPIDER_DAMAGE", 2), attack_period = 2.5 },
		{ prefab = "spider_warrior", tag = "monster4x", health = Tune("SPIDER_WARRIOR_HEALTH", 6), damage = Tune("SPIDER_WARRIOR_DAMAGE", 2), attack_period = function() return 3.5 + math.random() * 2 end },
		{ prefab = "spiderqueen", tag = "small_giant4x", health = Tune("SPIDERQUEEN_HEALTH", 6), damage = Tune("SPIDERQUEEN_DAMAGE", 2), attack_period = 2.5 },
		{ prefab = "spider_hider", tag = "monster4x", health = Tune("SPIDER_HIDER_HEALTH", 6), damage = Tune("SPIDER_HIDER_DAMAGE", 2), attack_period = 2.5 },
		{ prefab = "spider_spitter", tag = "monster4x", health = Tune("SPIDER_SPITTER_HEALTH", 6), damage = Tune("SPIDER_SPITTER_DAMAGE_MELEE", 2), attack_period = function() return 4.5 + math.random() * 2 end },
		{ prefab = "spider_dropper", tag = "monster4x", health = Tune("SPIDER_WARRIOR_HEALTH", 6), damage = Tune("SPIDER_WARRIOR_DAMAGE", 2), attack_period = function() return 3.5 + math.random() * 2 end },
		{ prefab = "hound", tag = "monster4x", health = Tune("HOUND_HEALTH", 6), damage = Tune("HOUND_DAMAGE", 2), attack_period = 1.5 },
		{ prefab = "firehound", tag = "monster4x", health = Tune("FIREHOUND_HEALTH", 6), damage = Tune("FIREHOUND_DAMAGE", 2), attack_period = 1.5 },
		{ prefab = "icehound", tag = "monster4x", health = Tune("ICEHOUND_HEALTH", 6), damage = Tune("ICEHOUND_DAMAGE", 2), attack_period = 1.5 },
		{ prefab = "warg", tag = "small_giant4x", health = Tune("WARG_HEALTH", 6), damage = Tune("WARG_DAMAGE", 2), attack_period = 2.5 },
		{ prefab = "tentacle", tag = "monster4x", health = Tune("TENTACLE_HEALTH", 6), damage = Tune("TENTACLE_DAMAGE", 2.5) },
		{ prefab = "rook", tag = "monster4x", health = Tune("ROOK_HEALTH", 6), damage = Tune("ROOK_DAMAGE", 3) },
		{ prefab = "minotaur", tag = "monster4x", health = Tune("MINOTAUR_HEALTH", 6), damage = Tune("MINOTAUR_DAMAGE", 2.5) },
		{ prefab = "bishop", tag = "monster4x", health = Tune("BISHOP_HEALTH", 6), damage = Tune("BISHOP_DAMAGE", 2) },
		{ prefab = "tallbird", tag = "monster4x", health = Tune("TALLBIRD_HEALTH", 6), damage = Tune("TALLBIRD_DAMAGE", 2), attack_period = 1.5 },
		{ prefab = "leif", tag = "small_giant4x", health = Tune("LEIF_HEALTH", 6), damage = Tune("LEIF_DAMAGE", 2) },
		{ prefab = "spat", tag = "small_giant4x", health = Tune("SPAT_HEALTH", 6), damage = Tune("SPAT_PHLEGM_DAMAGE", 1.5) },
		{ prefab = "birchnutdrake", tag = "monster4x", health = Fixed(200), damage = 15 },
		{ prefab = "merm", tag = "monster4x", health = Tune("MERM_HEALTH", 6), damage = Tune("MERM_DAMAGE", 2) },
		{ prefab = "bat", tag = "monster4x", health = Tune("BAT_HEALTH", 6), damage = Tune("BAT_DAMAGE", 2) },
		{ prefab = "walrus", tag = "monster4x", health = Tune("WALRUS_HEALTH", 6), runspeed = 8, walkspeed = 2 },
		{ prefab = "monkey", tag = "monster4x", health = Tune("MONKEY_HEALTH", 6) },
		{ prefab = "eyeplant", tag = "monster4x", health = Tune("EYEPLANT_HEALTH", 6), damage = Tune("EYEPLANT_DAMAGE", 2) },
		{ prefab = "antlion", tag = "giant4x", health = Tune("ANTLION_HEALTH", 5.5) },
		{ prefab = "stalker", tag = "giant4x", health = Tune("STALKER_HEALTH", 5) },
		{ prefab = "stalker_atrium", tag = "giant4x", health = Tune("STALKER_ATRIUM_HEALTH", 5) },
	},
}

RegisterSet(monster_sets[Difficult] or default_tags)
