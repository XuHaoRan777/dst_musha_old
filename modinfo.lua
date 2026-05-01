local CONFIG_LANG = locale == "zh" or locale == "zhr" or locale == "zht"

local function T(zh, en)
    return CONFIG_LANG and zh or en
end

name = T("[DST]Musha：重构维护版", "[DST]Musha: Refined Edition")
version = "T 14.2.4"
description = T(
    "[ 独立维护版 | 版本 : T 14.2.4 ]\n-------------------------\n基于 Musha 的重构维护版本，保留原玩法逻辑，整理配置结构并改善兼容性。\n配置页面会根据客户端语言自动显示中文或英文。\n\n[ 信息 ]\n状态-(L)   技能-(K)   外观切换-(F5)   外观重置-(O)\n[ 主动技能 ]\n闪电/女武神-(R)   暗影-(G)   护盾-(C)\n音乐/嗅探-(X)   睡眠/醒来-(T)\n[ Yamche ] 跟随-(Z)   战斗-(V)   采集-(B)\n[ Arong ] 跟随-(F1)   [ Dall ] 跟随-(F2)\n\n原作者: eunmanaz@naver.com",
    "[ Maintained Fork | Version : T 14.2.4 ]\n-------------------------\nA refined maintenance edition of Musha. Original gameplay logic is preserved while configuration structure and compatibility are cleaned up.\nThe config page follows the client language automatically.\n\n[ Information ]\nStat-(L)   Skill-(K)   Visual Cycle-(F5)   Visual Reset-(O)\n[ Active Skills ]\nLightning/Valkyrie-(R)   Shadow-(G)   Shield-(C)\nMusic/Sniff-(X)   Sleep/Wakeup-(T)\n[ Yamche ] Follow-(Z)   Battle-(V)   Gather-(B)\n[ Arong ] Follow-(F1)   [ Dall ] Follow-(F2)\n\nOriginal author: eunmanaz@naver.com"
)
author = "Sunnyyyyholic / Maintained Fork"
--version_compatible = ""
--forumthread = "http://forums.kleientertainment.com/files/file/529-puppy-princess-full-version/"
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10
priority = 0.11

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

all_clients_require_mod = true
client_only_mod = false
server_only_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"musha"}

local function ConfigOption(name, label_zh, label_en, hover_zh, hover_en, options, default)
    return {
        name = name,
        label = T(label_zh, label_en),
        hover = T(hover_zh, hover_en),
        options = options,
        default = default,
    }
end

local KEY_OPTIONS = {
    {description = "TAB", data = 9},
    {description = "KP_PERIOD", data = 266},
    {description = "KP_DIVIDE", data = 267},
    {description = "KP_MULTIPLY", data = 268},
    {description = "KP_MINUS", data = 269},
    {description = "KP_PLUS", data = 270},
    {description = "KP_ENTER", data = 271},
    {description = "KP_EQUALS", data = 272},
    {description = "MINUS", data = 45},
    {description = "EQUALS", data = 61},
    {description = "SPACE", data = 32},
    {description = "ENTER", data = 13},
    {description = "ESCAPE", data = 27},
    {description = "HOME", data = 278},
    {description = "INSERT", data = 277},
    {description = "DELETE", data = 127},
    {description = "END", data = 279},
    {description = "PAUSE", data = 19},
    {description = "PRINT", data = 316},
    {description = "CAPSLOCK", data = 301},
    {description = "SCROLLOCK", data = 302},
    {description = "RSHIFT", data = 303},
    {description = "LSHIFT", data = 304},
    {description = "RCTRL", data = 305},
    {description = "LCTRL", data = 306},
    {description = "RALT", data = 307},
    {description = "LALT", data = 308},
    {description = "ALT", data = 400},
    {description = "CTRL", data = 401},
    {description = "SHIFT", data = 402},
    {description = "BACKSPACE", data = 8},
    {description = "PERIOD", data = 46},
    {description = "SLASH", data = 47},
    {description = "LEFTBRACKET", data = 91},
    {description = "BACKSLASH", data = 92},
    {description = "RIGHTBRACKET", data = 93},
    {description = "TILDE", data = 96},
    {description = "A", data = 97},
    {description = "B", data = 98},
    {description = "C", data = 99},
    {description = "D", data = 100},
    {description = "E", data = 101},
    {description = "F", data = 102},
    {description = "G", data = 103},
    {description = "H", data = 104},
    {description = "I", data = 105},
    {description = "J", data = 106},
    {description = "K", data = 107},
    {description = "L", data = 108},
    {description = "M", data = 109},
    {description = "N", data = 110},
    {description = "O", data = 111},
    {description = "P", data = 112},
    {description = "Q", data = 113},
    {description = "R", data = 114},
    {description = "S", data = 115},
    {description = "T", data = 116},
    {description = "U", data = 117},
    {description = "V", data = 118},
    {description = "W", data = 119},
    {description = "X", data = 120},
    {description = "Y", data = 121},
    {description = "Z", data = 122},
    {description = "F1", data = 282},
    {description = "F2", data = 283},
    {description = "F3", data = 284},
    {description = "F4", data = 285},
    {description = "F5", data = 286},
    {description = "F6", data = 287},
    {description = "F7", data = 288},
    {description = "F8", data = 289},
    {description = "F9", data = 290},
    {description = "F10", data = 291},
    {description = "F11", data = 292},
    {description = "F12", data = 293},
    {description = "UP", data = 273},
    {description = "DOWN", data = 274},
    {description = "RIGHT", data = 275},
    {description = "LEFT", data = 276},
    {description = "PAGEUP", data = 280},
    {description = "PAGEDOWN", data = 281},
    {description = "0", data = 48},
    {description = "1", data = 49},
    {description = "2", data = 50},
    {description = "3", data = 51},
    {description = "4", data = 52},
    {description = "5", data = 53},
    {description = "6", data = 54},
    {description = "7", data = 55},
    {description = "8", data = 56},
    {description = "9", data = 57},
}

local function KeyOption(name, label_zh, label_en, hover_zh, hover_en, default)
    return ConfigOption(name, label_zh, label_en, hover_zh, hover_en, KEY_OPTIONS, default)
end

local ON_OFF_OPTIONS = {
    {description = T("开启", "ON"), data = "on"},
    {description = T("关闭", "OFF"), data = "off"},
}

local ENABLE_DISABLE_OPTIONS = {
    {description = T("禁用", "Disable"), data = 0},
    {description = T("启用", "Enable"), data = 1},
}

local YES_NO_OPTIONS = {
    {description = T("否", "No"), data = 0},
    {description = T("是", "Yes"), data = 1},
}

local EASY_NORMAL_OPTIONS = {
    {description = T("简单", "Easy"), data = "easy"},
    {description = T("普通", "Normal"), data = "normal"},
}

local EASY_TO_HARDCORE_OPTIONS = {
    {description = T("简单", "Easy"), data = "easy"},
    {description = T("普通", "Normal"), data = "normal"},
    {description = T("困难", "Hard"), data = "hard"},
    {description = T("硬核", "Hardcore"), data = "hardcore"},
}

local BACKPACK_VISUAL_OPTIONS = {
    {description = T("无", "None"), data = "off"},
    {description = T("背包-迷你", "Pack-Mini"), data = "Bmm"},
    {description = T("背包-极小", "Pack-Tiny"), data = "BT"},
    {description = T("背包-小", "Pack-Small"), data = "BS"},
    {description = T("背包-中", "Pack-Med"), data = "BM"},
    {description = T("背包-大", "Pack-Large"), data = "BL"},
    {description = T("小翅膀-粉", "Wing-S-pink"), data = "WSP"},
    {description = T("小翅膀-红", "Wing-S-red"), data = "WSR"},
    {description = T("小翅膀-蓝", "Wing-S-blue"), data = "WSB"},
    {description = T("小翅膀-混合", "Wing-S-hybrid"), data = "WSH"},
    {description = T("大翅膀-红", "Wing-L-red"), data = "WLR"},
    {description = T("大翅膀-蓝", "Wing-L-blue"), data = "WLB"},
}

configuration_options =
{
    {
        name = "modlanguage",
        label = T("游戏内语言", "In-game Language"),
        hover = T(
            "影响游戏内文本。配置页面会跟随客户端语言自动显示中文或英文。",
            "Controls in-game text. The config screen follows the client locale."
        ),
        options = {
            {description = "English", data = "english"},
            {description = "한글", data = "korean"},
            {description = "中文", data = "chinese"},
            {description = "русский", data = "russian"},
        },
        default = "english",
    },
    KeyOption(
        "key",
        "信息：等级",
        "Information: Level",
        "显示当前等级。",
        "Show current level.",
        108
    ),
    KeyOption(
        "key5",
        "信息：技能",
        "Information: Skill",
        "显示当前技能。",
        "Show current skills.",
        107
    ),
    KeyOption(
        "key2",
        "主动：闪电与女武神",
        "Active: Lightning and Valkyrie",
        "释放强力闪电和女武神技能。",
        "Cast Power Lightning and Valkyrie skills.",
        114
    ),
    KeyOption(
        "key11",
        "潜行与偷袭",
        "Hide and Sneak Attack",
        "进入暗影隐藏并刺杀敌人。",
        "Hide in shadow and assassinate enemies.",
        103
    ),
    KeyOption(
        "key3",
        "主动：护盾",
        "Active: Shield",
        "释放火花护盾法术。",
        "Cast Spark Shield spell.",
        99
    ),
    KeyOption(
        "key4",
        "主动：演奏",
        "Active: Performance",
        "演奏并召唤。",
        "Perform and summon.",
        120
    ),
    KeyOption(
        "key12",
        "主动：睡眠",
        "Active: Sleep",
        "睡眠或醒来。",
        "Sleep or wake up.",
        116
    ),
    KeyOption(
        "key7",
        "按住切换外观",
        "Hold to Change Visual",
        "切换 Musha 的外观。",
        "Change Musha's appearance.",
        286
    ),
    KeyOption(
        "key15",
        "重置按住外观",
        "Reset Hold Visual",
        "恢复为基础外观。",
        "Return to base appearance.",
        111
    ),
    KeyOption(
        "key6",
        "Yamche 命令：跟随/停留",
        "Yamche Order: Follow or Stay",
        "命令 Yamche 跟随、停留或撤退。",
        "Command Yamche to follow, stay, or retreat.",
        122
    ),
    KeyOption(
        "key8",
        "Yamche 命令：战斗",
        "Yamche Order: Battle",
        "命令 Yamche 狩猎、防守或回避。",
        "Command Yamche to hunt, guard, or avoid.",
        118
    ),
    KeyOption(
        "key9",
        "Yamche 命令：采集",
        "Yamche Order: Gathering",
        "命令 Yamche 采集物品。",
        "Command Yamche to gather items.",
        98
    ),
    KeyOption(
        "key10",
        "Musha 睡眠徽章",
        "Musha Sleep Badge",
        "开启或关闭睡眠徽章。",
        "Turn the sleep badge on or off.",
        110
    ),
    KeyOption(
        "key13",
        "Arong 命令：跟随/停留",
        "Arong Order: Follow or Stay",
        "控制伙伴 Arong。",
        "Control companion Arong.",
        282
    ),
    KeyOption(
        "key14",
        "Dall 命令：跟随/停留",
        "Dall Order: Follow or Stay",
        "控制伙伴 Dall。",
        "Control companion Dall.",
        283
    ),
    ConfigOption(
        "difficultmana",
        "难度：魔力",
        "Difficulty: Mana",
        "调整魔力恢复难度。",
        "Adjust mana regeneration difficulty.",
        {
            {description = T("非常简单", "Very Easy"), data = "dmana_veasy"},
            {description = T("简单", "Easy"), data = "dmana_easy"},
            {description = T("普通", "Normal"), data = "dmana_normal"},
            {description = T("困难", "Hard"), data = "dmana_hard"},
            {description = T("硬核", "Hardcore"), data = "dmana_hardcore"},
        },
        "dmana_normal"
    ),
    ConfigOption(
        "difficultysniff",
        "难度：嗅探",
        "Difficulty: Sniff",
        "调整宝藏嗅探难度。",
        "Adjust treasure sniffing difficulty.",
        EASY_TO_HARDCORE_OPTIONS,
        "normal"
    ),
    ConfigOption(
        "difficulttired",
        "难度：疲劳",
        "Difficulty: Tired",
        "调整疲劳系统难度。",
        "Adjust tiredness difficulty.",
        {
            {description = T("非常简单", "Very Easy"), data = "dtired_veasy"},
            {description = T("简单", "Easy"), data = "dtired_easy"},
            {description = T("普通", "Normal"), data = "dtired_normal"},
            {description = T("困难", "Hard"), data = "dtired_hard"},
            {description = T("硬核", "Hardcore"), data = "dtired_hardcore"},
        },
        "dtired_normal"
    ),
    ConfigOption(
        "difficultsleep",
        "难度：睡眠",
        "Difficulty: Sleep",
        "调整睡眠时恢复的睡眠值。",
        "Adjust how much Sleep regenerates while sleeping.",
        {
            {description = T("非常简单", "Very Easy"), data = "dsleep_veasy"},
            {description = T("简单", "Easy"), data = "dsleep_easy"},
            {description = T("普通", "Normal"), data = "dsleep_normal"},
            {description = T("困难", "Hard"), data = "dsleep_hard"},
            {description = T("硬核", "Hardcore"), data = "dsleep_hardcore"},
        },
        "dsleep_normal"
    ),
    ConfigOption(
        "difficultmusic",
        "难度：音乐",
        "Difficulty: Music",
        "调整睡眠时恢复的音乐值。",
        "Adjust how much Music regenerates while sleeping.",
        {
            {description = T("非常简单", "Very Easy"), data = "dmusic_veasy"},
            {description = T("简单", "Easy"), data = "dmusic_easy"},
            {description = T("普通", "Normal"), data = "dmusic_normal"},
            {description = T("困难", "Hard"), data = "dmusic_hard"},
            {description = T("硬核", "Hardcore"), data = "dmusic_hardcore"},
        },
        "dmusic_normal"
    ),
    ConfigOption(
        "difficultover",
        "难度：敌人",
        "Difficulty: Enemy",
        "调整敌人强度。",
        "Adjust enemy power.",
        {
            {description = T("默认", "Default"), data = "monster1x"},
            {description = T("困难", "Hard"), data = "monster2x"},
            {description = T("硬核", "Hardcore"), data = "monster3x"},
            {description = T("地狱", "Hell"), data = "monster4x"},
        },
        "monster1x"
    ),
    ConfigOption(
        "difficulthealth",
        "难度：状态",
        "Difficulty: Status",
        "调整 Musha 的生命值和精神值。",
        "Adjust Musha health and sanity.",
        EASY_TO_HARDCORE_OPTIONS,
        "normal"
    ),
    ConfigOption(
        "difficultdamage",
        "难度：近战",
        "Difficulty: Melee",
        "调整 Musha 基础近战伤害。",
        "Adjust Musha basic melee damage.",
        {
            {description = T("新手", "Newbie"), data = "newbie"},
            {description = T("超简单", "Super Easy"), data = "sveasy"},
            {description = T("非常简单", "Very Easy"), data = "veasy"},
            {description = T("简单(75)", "Easy(75)"), data = "easy"},
            {description = T("普通(55)", "Normal(55)"), data = "normal"},
            {description = T("困难(40)", "Hard(40)"), data = "hard"},
            {description = T("硬核(25)", "Hardcore(25)"), data = "hardcore"},
        },
        "normal"
    ),
    ConfigOption(
        "difficultdamage_range",
        "难度：远程",
        "Difficulty: Range",
        "调整 Musha 基础远程伤害。",
        "Adjust Musha basic ranged damage.",
        {
            {description = T("非常简单(250)", "Very Easy(250)"), data = "veasy"},
            {description = T("简单(175)", "Easy(175)"), data = "easy"},
            {description = T("普通(125)", "Normal(125)"), data = "normal"},
            {description = T("困难(75)", "Hard(75)"), data = "hard"},
            {description = T("硬核(50)", "Hardcore(50)"), data = "hardcore"},
        },
        "normal"
    ),
    ConfigOption(
        "difficultsanity",
        "难度：精神",
        "Difficulty: Sanity",
        "调整 Musha 精神恢复。",
        "Adjust Musha sanity regeneration.",
        {
            {description = T("新手", "Newbie"), data = "newbie"},
            {description = T("简单", "Easy"), data = "easy"},
            {description = T("普通", "Normal"), data = "normal"},
            {description = T("困难", "Hard"), data = "hard"},
            {description = T("硬核", "Hardcore"), data = "hardcore"},
        },
        "normal"
    ),
    ConfigOption(
        "difficultrecipe",
        "难度：配方",
        "Difficulty: Recipe",
        "调整 Musha 物品配方难度。",
        "Adjust Musha item recipe difficulty.",
        EASY_NORMAL_OPTIONS,
        "normal"
    ),
    ConfigOption(
        "craftgems",
        "宝石配方",
        "Craft Gem Recipe",
        "添加宝石制作配方。",
        "Adds gem crafting recipes.",
        {
            {description = T("禁用", "Disable"), data = "off"},
            {description = T("添加配方", "Adds Recipe"), data = "color"},
        },
        "color"
    ),
    ConfigOption(
        "deathPenalty",
        "死亡惩罚",
        "Death Penalty",
        "死亡时降低经验。",
        "Decrease EXP from death.",
        ON_OFF_OPTIONS,
        "on"
    ),
    ConfigOption(
        "smartmusha",
        "知识",
        "Knowledge",
        "调整科技加成。",
        "Adjust science bonus.",
        {
            {description = T("普通(+0)", "Normal(+0)"), data = "normal"},
            {description = T("聪明(+1)", "Smart(+1)"), data = "smart"},
            {description = T("天才(+2)", "Genius(+2)"), data = "verysmart"},
        },
        "normal"
    ),
    ConfigOption(
        "princess_taste",
        "小猪或公主",
        "Piggy or Princess",
        "公主：饥饿值高于 90% 时不能随意进食。\n小猪：可以随时进食。",
        "Princess: She cannot freely eat when hunger is above 90%.\nPiggy: She can always eat.",
        {
            {description = T("小猪", "Piggy"), data = "normal"},
            {description = T("公主", "Princess"), data = "princess"},
        },
        "princess"
    ),
    ConfigOption(
        "dietmusha",
        "可食用食物类型",
        "Edible Food Type",
        "设置她可以吃的食物类型。无论此选项如何，饥饿值低于 0 时都可以吃所有食物。",
        "Set the food types she can eat. Regardless of this option, she can eat all food types when hunger is below 0.",
        {
            {description = T("全部", "Both"), data = "normal"},
            {description = T("仅肉类", "Only Meat"), data = "meat"},
            {description = T("仅素食", "Only Veggie"), data = "veggie"},
        },
        "normal"
    ),
    ConfigOption(
        "favoritemusha",
        "讨厌的食物类型",
        "Disliked Food Type",
        "设置讨厌的食物类型，食用后会受到精神惩罚。无论此选项如何，她喜欢咖啡苹果，不喜欢吃蝴蝶。",
        "Set disliked food types that apply a sanity penalty. Regardless of this option, she likes caffeine apple and dislikes eating butterflies.",
        {
            {description = T("普通", "Normal"), data = "normal"},
            {description = T("讨厌肉类", "Dislike Meat"), data = "dis_meat"},
            {description = T("讨厌素食", "Dislike Veggie"), data = "dis_veggie"},
        },
        "normal"
    ),
    ConfigOption(
        "bodyguardwilson",
        "Wilson",
        "Wilson",
        "保镖 Wilson，拥有随机技能。",
        "Bodyguard Wilson with random skill.",
        {
            {description = T("启用", "Enable"), data = 0},
            {description = T("禁用", "Disable"), data = 1},
        },
        0
    ),
    ConfigOption(
        "shareitems",
        "共享物品",
        "Share Items",
        "允许其他角色使用 Musha 的装备。",
        "Allow other characters to use Musha's gears.",
        YES_NO_OPTIONS,
        0
    ),
    ConfigOption(
        "avisual_musha",
        "Musha 背包外观",
        "Musha Backpack Visual",
        "改变背部外观。",
        "Change back visual.",
        BACKPACK_VISUAL_OPTIONS,
        "Bmm"
    ),
    ConfigOption(
        "avisual_princess",
        "公主背包外观",
        "Princess Backpack Visual",
        "改变背部外观。",
        "Change back visual.",
        BACKPACK_VISUAL_OPTIONS,
        "WSP"
    ),
    ConfigOption(
        "avisual_pirate",
        "海盗背包外观",
        "Pirate Backpack Visual",
        "改变背部外观。",
        "Change back visual.",
        BACKPACK_VISUAL_OPTIONS,
        "BL"
    ),
    ConfigOption(
        "avisual_pirate_armor",
        "海盗护甲部件",
        "Pirate Armor Parts",
        "改变海盗护甲外观。",
        "Change Pirate Armor visual.",
        {
            {description = T("胸甲", "Chest"), data = "chest"},
            {description = T("海盗", "Pirate"), data = "pirate"},
            {description = "Musha", data = "green"},
            {description = T("公主", "Princess"), data = "pink"},
            {description = T("冰霜", "Frost"), data = "blue"},
        },
        "pirate"
    ),
    ConfigOption(
        "musha_incontainer",
        "护甲可放入容器",
        "Compact Armor",
        "Musha 的护甲可以放入容器。",
        "Musha's armor can go in containers.",
        ENABLE_DISABLE_OPTIONS,
        1
    ),
    ConfigOption(
        "incontainer",
        "普通背包可放入容器",
        "Compact Normal Backpack",
        "基础背包可以放入容器。",
        "Base backpacks can go in containers.",
        ENABLE_DISABLE_OPTIONS,
        0
    ),
    ConfigOption(
        "pirateback_slot",
        "海盗箱子装备栏",
        "Pirate Chest Slot",
        "自动：优先使用额外背包栏，依次检测 BACK、PACK、BACKPACK、BAG；没有额外槽位时回退身体栏。\n身体栏：始终作为护甲装备。\n额外背包栏：优先使用额外背包栏，没有时回退身体栏。",
        "Auto: prefer extra backpack slots in this order: BACK, PACK, BACKPACK, BAG; fallback to body slot when unavailable.\nBody: always equip as armor.\nExtra Backpack: prefer extra backpack slots and fallback to body slot when unavailable.",
        {
            {description = T("自动", "Auto"), data = "auto"},
            {description = T("身体栏", "Body"), data = "body"},
            {description = T("额外背包栏", "Extra Backpack"), data = "extra"},
        },
        "auto"
    ),
    ConfigOption(
        "frostblade3rd",
        "冰霜之刃：第三阶段强化",
        "Frost Blade: 3rd Booster",
        "仅外观：改变第三阶段强化的冰霜之刃外观。\n外观+范围：同时改变外观和强化武器范围。",
        "Visual Only: change Frost Blade visual for the 3rd boost.\nVisual + Range: change visual and boost weapon range.",
        {
            {description = T("普通", "Normal"), data = 1},
            {description = T("长矛外观", "Spear Visual"), data = 2},
            {description = T("外观+范围", "Visual + Range"), data = 3},
        },
        3
    ),
    ConfigOption(
        "on_butterfly_shield",
        "冰霜护甲：护盾形态",
        "Frost Armor: Shield Form",
        "使用鼠标右键切换蝴蝶形态。",
        "Use butterfly form with the right mouse button.",
        {
            {description = T("开启", "On"), data = 1},
            {description = T("关闭", "Off"), data = 2},
        },
        1
    ),
    ConfigOption(
        "stop_spawning",
        "Dall：仆从",
        "Dall: Servant",
        "不生成：月树 Dall 停止生成仆从和植物。\n小范围：植物在较小范围内召唤。",
        "No Spawn: Moontree Dall stops spawning servants and plants.\nSmall Radius: plants are summoned in a small radius.",
        {
            {description = T("默认", "Default"), data = 1},
            {description = T("小范围", "Small Radius"), data = 2},
            {description = T("不生成", "No Spawn"), data = 3},
        },
        1
    ),
    ConfigOption(
        "loudlightning",
        "响亮闪电特效",
        "Loud Lightning Effect",
        "推荐单人游戏使用。\n选项1：强力闪电 R 键特效。\n选项2：强力闪电和召唤闪电 R 键特效。\n选项3：所有闪电技能特效，包括被动女武神闪电。",
        "Recommended for single play.\nOption1: effect with Power Lightning (R key).\nOption2: effect with Power and Call Lightning (R key).\nOption3: effect with all Lightning skills, including passive Valkyrie lightning.",
        {
            {description = T("默认", "Default"), data = "off"},
            {description = T("选项1", "Option1"), data = "loud1"},
            {description = T("选项2", "Option2"), data = "loud2"},
            {description = T("选项3", "Option3"), data = "loud3"},
        },
        "off"
    ),
} 
