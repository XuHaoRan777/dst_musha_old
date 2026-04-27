return {
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
}
