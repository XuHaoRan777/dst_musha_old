return {
    {
        name = "modlanguage",
        label = T("Mod 语言", "Mod Language"),
        hover = LanguageHover(),
        options = {
            {description = "English", data = "english"},
            {description = "한글", data = "korean"},
            {description = "中文", data = "chinese"},
            {description = "русский", data = "russian"},
        },
        default = "english",
    },
}
