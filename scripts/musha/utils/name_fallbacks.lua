local M = {}

local function set_name(strings, key, value)
	if strings ~= nil and strings.NAMES ~= nil and strings.NAMES[key] == nil then
		strings.NAMES[key] = value
	end
end

local function set_names(strings, keys, value)
	for _, key in ipairs(keys) do
		set_name(strings, key, value)
	end
end

function M.Register(strings)
	if strings == nil or strings.NAMES == nil then
		return
	end

	set_names(strings, {
		"ARONG",
		"ARONG_BABY",
		"ARONG_CARRY",
	}, "Arong")
	set_names(strings, {
		"AROM",
		"AROM_CARRY",
	}, "Arom")
	set_name(strings, "ARONG_DOG", "Arong")

	set_names(strings, {
		"MUSHA_SMALL",
		"MUSHA_SMALL_SUPER",
		"MUSHA_TEEN",
		"MUSHA_TEENR1",
		"MUSHA_TEENR2",
		"MUSHA_TEENR3",
		"MUSHA_TEENR4",
		"MUSHA_TEENICE",
		"MUSHA_TALL",
		"MUSHA_TALL2",
		"MUSHA_TALL3",
		"MUSHA_TALL4",
		"MUSHA_TALL5",
		"MUSHA_TALLR1",
		"MUSHA_TALLR2",
		"MUSHA_TALLR3",
		"MUSHA_TALLR4",
		"MUSHA_TALLRICE",
		"MUSHA_TALLRR1",
		"MUSHA_TALLRR2",
		"MUSHA_TALLRR3",
		"MUSHA_TALLRR4",
		"MUSHA_TALLRR5",
		"MUSHA_TALLRRICE",
		"MUSHA_TALLRRR1",
		"MUSHA_TALLRRR2",
		"MUSHA_TALLRRR3",
		"MUSHA_TALLRRR4",
		"MUSHA_TALLRRR5",
		"MUSHA_TALLRRRICE",
		"MUSHA_TALLRRRR1",
		"MUSHA_TALLRRRR2",
		"MUSHA_TALLRRRR3",
		"MUSHA_TALLRRRR4",
		"MUSHA_TALLRRRR5",
		"MUSHA_TALLRRRR6",
		"MUSHA_TALLRRRRICE",
		"MUSHA_TALLRRRRR1",
		"MUSHA_TALLRRRRR2",
		"MUSHA_TALLRRRRR3",
		"MUSHA_TALLRRRRR4",
		"MUSHA_TALLRRRRR5",
		"MUSHA_TALLRRRRR6",
		"MUSHA_TALLRRRRRICE",
		"MUSHA_RP1",
		"MUSHA_RP2",
		"MUSHA_RP3",
		"MUSHA_RP4",
		"MUSHA_RP5",
		"MUSHA_RP6",
		"MUSHA_RP7",
		"MUSHA_RPICE",
	}, "Yamche")

	set_names(strings, {
		"MUSHA_SPORE",
		"MUSHA_SPORE2",
		"MUSHA_SPORE_FIRE",
	}, "Musha Spore")

	set_names(strings, {
		"APPLE_BERRY",
		"MUSHA_BERRY",
	}, "Berry Bush")
	set_names(strings, {
		"MUSHA_BULB",
		"MUSHA_BULB_DOUBLE",
	}, "Light Flower")
	set_names(strings, {
		"GREEN_FERN",
		"LIGHT_FERN",
		"MUSHA_FERN",
	}, "Fern")

	set_names(strings, {
		"MUSHA_EGG_COOKED",
		"MUSHA_EGG_COOKED1",
		"MUSHA_EGG_COOKED2",
		"MUSHA_EGG_COOKED3",
		"MUSHA_EGG_COOKED8",
		"MUSHA_EGG_COOKEDS1",
		"MUSHA_EGG_COOKEDS2",
		"MUSHA_EGG_COOKEDS3",
		"MUSHA_EGG_RANDOM_COOKED",
		"MUSHA_EGG_ARONG_COOKED",
	}, "Cooked Egg")

	set_name(strings, "COMMON/INVENTORY/BOWM", strings.NAMES.BOWM or "Blade-Bow")
	set_name(strings, "COMMON/INVENTORY/TUNACAN", strings.NAMES.TUNACAN or "Tuna")
	set_name(strings, "COMMON/INVENTORY/TUNACAN_MUSHA", strings.NAMES.TUNACAN_MUSHA or "Tuna")
	set_name(strings, "COMMON/OBJECTS/FORGE_MUSHA", strings.NAMES.FORGE_MUSHA or "Musha's Forge")
	set_name(strings, "COMMON/OBJECTS/TENT_MUSHA", strings.NAMES.TENT_MUSHA or "Musha's Tent")
	set_name(strings, "COMMON/SHADOWMUSHA", strings.NAMES.SHADOWMUSHA or "Musha's Shadow")
	set_name(strings, "COMMON/ASSASIN_WILSON", strings.NAMES.ASSASIN_WILSON or "Wilsoon")
end

return M
