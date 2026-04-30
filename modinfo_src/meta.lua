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
