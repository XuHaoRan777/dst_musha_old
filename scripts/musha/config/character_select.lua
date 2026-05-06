local M = {}

local STARTING_ITEMS =
{
    "glowdust",
    "glowdust",
}

local function CopyStartingItems()
    return
    {
        STARTING_ITEMS[1],
        STARTING_ITEMS[2],
    }
end

function M.Register(tuning)
    if type(tuning) ~= "table" then
        return
    end

    tuning.MUSHA_HEALTH = 80
    tuning.MUSHA_HUNGER = 200
    tuning.MUSHA_SANITY = 80

    tuning.GAMEMODE_STARTING_ITEMS = tuning.GAMEMODE_STARTING_ITEMS or {}
    tuning.GAMEMODE_STARTING_ITEMS.DEFAULT = tuning.GAMEMODE_STARTING_ITEMS.DEFAULT or {}
    tuning.GAMEMODE_STARTING_ITEMS.DEFAULT.MUSHA = CopyStartingItems()

    tuning.STARTING_ITEM_IMAGE_OVERRIDE = tuning.STARTING_ITEM_IMAGE_OVERRIDE or {}
    tuning.STARTING_ITEM_IMAGE_OVERRIDE.glowdust =
    {
        atlas = "images/inventoryimages/glowdust.xml",
        image = "glowdust.tex",
    }
end

return M
