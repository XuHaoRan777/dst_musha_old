return {
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
}
