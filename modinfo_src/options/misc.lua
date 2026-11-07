return {
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
    ConfigOption(
        "phoenixaxe_tilling",
        "凤凰斧九宫格耕地",
        "Phoenix Axe 3x3 Tilling",
        "开启后，凤凰斧镐形态在农田地皮右键时重置本格耕地并生成九宫格；作物或障碍所在位置会跳过。其他地面仍可召唤火精灵。",
        "When enabled, right-clicking farm soil with the Phoenix Axe pick form resets tilling in that tile and creates a 3x3 grid. Positions blocked by crops or obstacles are skipped. Other ground still summons the fire spirit.",
        {
            {description = T("开启", "On", "켜기", "Вкл."), data = "on"},
            {description = T("关闭", "Off", "끄기", "Выкл."), data = "off"},
        },
        "off",
        "불사조 도끼 3x3 밭갈이",
        "Вспашка 3×3 Фениксовым топором",
        "활성화하면 불사조 도끼 곡괭이 형태로 농장 타일을 우클릭할 때 해당 타일을 초기화하고 3x3으로 경작합니다. 작물이나 장애물이 있는 칸은 건너뜁니다. 다른 지형에서는 화염 정령을 소환합니다.",
        "После включения щелчок правой кнопкой по фермерской почве киркой-Фениксом заново вспашет участок сеткой 3×3. Клетки с растениями или препятствиями будут пропущены. На другой местности по-прежнему вызывается огненный дух."
    ),
}
