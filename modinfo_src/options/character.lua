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
