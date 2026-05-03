-----------
local require = GLOBAL.require
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
local STRINGS = GLOBAL.STRINGS
local ACTIONS = GLOBAL.ACTIONS
local Vector3 = GLOBAL.Vector3
local TUNING = GLOBAL.TUNING
local TheSim = GLOBAL.TheSim
local SpawnPrefab = GLOBAL.SpawnPrefab
TECH = GLOBAL.TECH
local IsServer = GLOBAL.TheNet:GetIsServer()
local containers = require("containers")
local CompanionStates = require("musha/companions/states")
local SkillDefs = require("musha/skills/defs")
local MushaAnim = require("musha/utils/anim")
local MushaConfig = require("musha/config/config")
local LightningSkill = require("musha/skills/lightning")
local SleepSkill = require("musha/skills/sleep")
local ShadowSkill = require("musha/skills/shadow")
local MusicSkill = require("musha/skills/music")
local VisualCommands = require("musha_visual_commands")
local Config = MushaConfig.Load(GetModConfigData, TUNING)

ACTIONS.GIVE.priority = 2
ACTIONS.ADDFUEL.priority = 4
ACTIONS.USEITEM.priority = 3

local ThePlayer = GLOBAL.ThePlayer
-----------
local TheInput = GLOBAL.TheInput
-----------sleep--------
local function IsNearWriteable(inst)
	return false
end

local Mod_language = Config.modlanguage

local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local PlayerBadge = require("widgets/playerbadge")
local Badge = require("widgets/badge")


modimport("libs/env.lua")
-----------specific
--use "data/actions/pickup"
--use "data/components/inits"

modimport("scripts/prefabasset.lua")
modimport("scripts/musha_adds_recipe.lua")
-----------
--translation

if Mod_language == "korean" then
	modimport("scripts/strings_musha_ko.lua")
	STRINGS.CHARACTERS.MUSHA = require "speech_musha_ko"
elseif Mod_language == "chinese" then
	modimport("scripts/strings_musha_cn.lua")
	STRINGS.CHARACTERS.MUSHA = require "speech_musha_cn"
elseif Mod_language == "russian" then
	modimport("scripts/strings_musha_ru.lua")
	STRINGS.CHARACTERS.MUSHA = require "speech_musha_ru"
elseif Mod_language == "english" then
	modimport("scripts/strings_musha_en.lua")
	STRINGS.CHARACTERS.MUSHA = require "speech_musha_en"
else
	modimport("scripts/strings_musha_en.lua")
	STRINGS.CHARACTERS.MUSHA = require "speech_musha_en"
end

require("musha/utils/name_fallbacks").Register(STRINGS)

modimport("scripts/musha_adds_states.lua")

modimport("scripts/musha_adds_actions.lua")

modimport("scripts/musha_adds_container.lua")
require("musha/equipment/inventory_overflow").Register({
	AddComponentPostInit = AddComponentPostInit,
	AddClassPostConstruct = AddClassPostConstruct,
	AddPlayerPostInit = AddPlayerPostInit,
	AddPrefabPostInit = AddPrefabPostInit,
	GLOBAL = GLOBAL,
})

require("musha/config/postinit").Register(Config, AddPrefabPostInit, IsServer, TUNING)
require("musha/prefabs/monkey_immunity").Register({
	AddPrefabPostInit = AddPrefabPostInit,
	IsServer = IsServer,
})

modimport("scripts/mypower_musha_1.lua")
modimport("scripts/widgets/spellpower_statusdisplays.lua")
modimport("scripts/widgets/fatigue_sleep_statusdisplays.lua")
modimport("scripts/widgets/stamina_sleep_statusdisplays.lua")
modimport("scripts/difficulty_monster_dst.lua")

--active key
-- Import the lib use.
modimport("libs/use.lua")

-- Import the mod environment as our environment.
use "libs/mod_env"(env)
-- Imports to keep the keyhandler from working while typing in chat.
use "data/widgets/controls"
use "data/screens/chatinputscreen"
use "data/screens/consolescreen"
local MushaCommands = GLOBAL.require("usercommands")

require("musha/equipment/postinit").Register(Config, AddPrefabPostInit)

require("musha_info_commands").Register({
	AddModRPCHandler = AddModRPCHandler,
	STRINGS = STRINGS,
	TheSim = TheSim,
})

LightningSkill.Register({
	AddModRPCHandler = AddModRPCHandler,
	EQUIPSLOTS = GLOBAL.EQUIPSLOTS,
	IsMushaSleeping = SleepSkill.IsSleeping,
	MushaAnim = MushaAnim,
	SkillDefs = SkillDefs,
	STRINGS = STRINGS,
	TheSim = TheSim,
	GetWorld = function() return GLOBAL.TheWorld end,
	SpawnPrefab = SpawnPrefab,
})

ShadowSkill.Register({
	AddModRPCHandler = AddModRPCHandler,
	STRINGS = STRINGS,
	TheSim = TheSim,
	SpawnPrefab = SpawnPrefab,
})

SleepSkill.Register({
	AddModRPCHandler = AddModRPCHandler,
	EQUIPSLOTS = GLOBAL.EQUIPSLOTS,
	GetWorld = function() return GLOBAL.TheWorld end,
	LightningSkill = LightningSkill,
	MushaAnim = MushaAnim,
	ShadowSkill = ShadowSkill,
	SpawnPrefab = SpawnPrefab,
	STRINGS = STRINGS,
	TUNING = TUNING,
})

require("musha/skills/shield").Register({
	AddModRPCHandler = AddModRPCHandler,
	IsNearWriteable = IsNearWriteable,
	SkillDefs = SkillDefs,
	STRINGS = STRINGS,
	TheSim = TheSim,
	SpawnPrefab = SpawnPrefab,
})

MusicSkill.Register({
	AddModRPCHandler = AddModRPCHandler,
	EQUIPSLOTS = GLOBAL.EQUIPSLOTS,
	FindValidPositionByFan = FindValidPositionByFan,
	FindWalkableOffset = FindWalkableOffset,
	MushaCommands = MushaCommands,
	STRINGS = STRINGS,
	TheSim = TheSim,
	TUNING = TUNING,
	Vector3 = Vector3,
	GetWorld = function() return GLOBAL.TheWorld end,
	SpawnPrefab = SpawnPrefab,
})

require("musha/companions/commands").Register({
	AddModRPCHandler = AddModRPCHandler,
	CompanionStates = CompanionStates,
	STRINGS = STRINGS,
	MushaCommands = MushaCommands,
	TheSim = TheSim,
	SpawnPrefab = SpawnPrefab,
})

-----------------------------------------------
require("musha/world/postinit").Register(AddPrefabPostInit, IsServer)

-----------------------------------------------
VisualCommands.Register({
	AddModRPCHandler = AddModRPCHandler,
	MushaAnim = MushaAnim,
	STRINGS = STRINGS,
})

require("musha/companions/hoverinfo").Register({
	AddClassPostConstruct = AddClassPostConstruct,
	AddGlobalClassPostConstruct = AddGlobalClassPostConstruct,
	AddPrefabPostInitAny = AddPrefabPostInitAny,
	ProfileStatsSet = GLOBAL.ProfileStatsSet,
	STRINGS = STRINGS,
	TheInput = TheInput,
})

-------------------------------------------------
require("musha/world/difficulty_postinit").Register(Config, AddPrefabPostInit, IsServer, Vector3, SkillDefs)

-------
AddModCharacter("musha","FEMALE")
--table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "musha")
