    {
        name = "modlanguage",
        label = T("游戏内语言", "In-game Language"),
        hover = T(
            "影响游戏内文本，不会实时切换当前配置页面。配置页面会跟随客户端语言自动显示中文或英文。",
            "Controls in-game text. This does not live-switch the current config screen; the config screen follows the client locale."
        ),
        options = {
            {description = T("自动", "Auto"), data = "auto"},
            {description = "English", data = "english"},
            {description = "한글", data = "korean"},
            {description = "中文", data = "chinese"},
            {description = "русский", data = "russian"},
        },
        default = "auto",
    },
