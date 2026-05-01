return {
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
}
