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
