local SkinDefs = require("musha/skin_defs")

SkinDefs.Register()

return CreatePrefabSkin("musha_battle_skin_none",
{
    base_prefab = "musha",
    type = "base",
    build_name_override = "musha",
    rarity = "Character",
    skin_tags = { "BASE", "MUSHA", "CHARACTER" },
    skins = { normal_skin = "musha_battle_old_full", ghost_skin = "ghost_musha_build" },
    assets =
    {
        Asset("ANIM", "anim/musha_battle_old_full.zip"),
        Asset("ANIM", "anim/ghost_musha_build.zip"),
        Asset("IMAGE", "bigportraits/musha_battle_skin_none.tex"),
        Asset("ATLAS", "bigportraits/musha_battle_skin_none.xml"),
    },
})
