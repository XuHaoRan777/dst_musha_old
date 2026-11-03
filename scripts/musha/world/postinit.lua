local WorldPostInit = {}
local GenerateTreasure = require("messagebottletreasures").GenerateTreasure

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

local GROUND_BOSS_TREASURE_PREFABS = {
	"klaus",
	"minotaur",
	"eyeofterror",
	"twinofterror1",
	"twinofterror2",
	"alterguardian_phase3",
	"stalker_atrium",
}

local function IsMushaKiller(inst, data)
	local killer = data ~= nil and (data.afflicter or data.attacker) or nil
	if killer == nil and inst.components.health ~= nil then
		killer = inst.components.health.causeofdeath
	end

	for _ = 1, 4 do
		if killer == nil or not killer:IsValid() then
			return false
		end
		if killer:HasTag("musha") then
			return true
		end

		local components = killer.components
		local nextkiller = components ~= nil and components.projectile ~= nil and components.projectile.owner or nil
		if nextkiller == nil and components ~= nil and components.complexprojectile ~= nil then
			nextkiller = components.complexprojectile.attacker
		end
		if nextkiller == nil then
			nextkiller = killer.owner or killer.attacker
		end
		if nextkiller == killer then
			return false
		end
		killer = nextkiller
	end

	return false
end

local function SpawnGroundBossTreasure(inst, data)
	if inst.musha_ground_treasure_spawned then
		return
	end

	if inst.prefab == "stalker_atrium" and (inst.atriumdecay or inst.cavedecay) then
		return
	end

	if inst.prefab == "klaus" and (inst.IsUnchained == nil or not inst:IsUnchained()) then
		return
	end
	if not IsMushaKiller(inst, data) then
		return
	end

	inst.musha_ground_treasure_spawned = true
	local x, _, z = inst.Transform:GetWorldPosition()
	local angle = math.random() * 2 * PI
	local radius = 1.5 + math.random() * 1.5
	if TheWorld ~= nil and TheWorld.ismastersim then
		local spot = SpawnPrefab("musha_treasure2")
		if spot ~= nil then
			spot.Transform:SetPosition(x + math.cos(angle) * radius, 0, z + math.sin(angle) * radius)
			spot:SetTreasureHunt()
		end
	end
end

local function SpawnSunkenBossTreasure(inst)
	if inst.musha_sunken_treasure_spawned then
		return
	end
	inst.musha_sunken_treasure_spawned = true

	local angle = math.random() * 2 * PI
	local radius = 3 + math.random() * 2
	local x, _, z = inst.Transform:GetWorldPosition()
	local treasure = GenerateTreasure(Vector3(x + math.cos(angle) * radius, 0, z + math.sin(angle) * radius), "sunkenchest")
	if treasure ~= nil and treasure:IsValid() and treasure.components.submersible ~= nil then
		treasure.components.submersible:Submerge()
	end
end

function WorldPostInit.Register(add_prefab_post_init, is_server)
	if is_server then
		for _, prefab in ipairs(GROUND_BOSS_TREASURE_PREFABS) do
			add_prefab_post_init(prefab, function(inst)
				inst:ListenForEvent("death", SpawnGroundBossTreasure)
			end)
		end

		for _, prefab in ipairs({ "crabking", "malbatross" }) do
			add_prefab_post_init(prefab, function(inst)
				inst:ListenForEvent("death", SpawnSunkenBossTreasure)
			end)
		end
	end

	local function hound_hit_symbol(inst)
		if is_server then
			SetHitEffectSymbol(inst, "hound_body")
		end
	end

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
