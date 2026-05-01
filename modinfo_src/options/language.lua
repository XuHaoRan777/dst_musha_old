return {
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
}
