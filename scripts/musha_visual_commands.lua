local M = {}

local HOLD_FLAGS =
{
	"visual_hold",
	"visual_hold2",
	"visual_hold3",
	"visual_hold4",
	"full_hold",
	"normal_hold",
	"valkyrie_hold",
	"berserk_hold",
	"hold_old1",
	"hold_old2",
	"hold_old3",
	"hold_old4",
	"hold_old5",
	"hold_old6",
	"hold_old7",
	"hold_old8",
	"full_k_hold",
	"normal_k_hold",
	"valkyrie_k_hold",
	"berserk_k_hold",
}

local FORM_FLAGS =
{
	"musha_full",
	"musha_normal",
	"musha_battle",
	"musha_hunger",
}

local function Say(inst, text)
	if inst.components.talker ~= nil then
		inst.components.talker:Say(text)
	end
end

local function SetFlags(inst, fields, value)
	for i = 1, #fields do
		inst[fields[i]] = value
	end
end

local function ResetHoldFlags(inst)
	SetFlags(inst, HOLD_FLAGS, false)
	inst.set_on = false
	inst.willow = false
	inst.wigfred = false
	inst.change_visual = false
end

local function ResetFormFlags(inst)
	SetFlags(inst, FORM_FLAGS, false)
end

local function GetMushaCurrentForm(inst)
	if inst.strength == "berserk" or inst.berserk or inst.fberserk or inst.berserks then
		return "berserk"
	elseif inst.strength == "valkyrie" or inst.valkyrie then
		return "valkyrie"
	elseif inst.strength == "full" or (inst.components ~= nil and inst.components.hunger ~= nil and inst.components.hunger.current >= 160) then
		return "full"
	end

	return "normal"
end

local function ApplyCurrentFormBuild(inst, env)
	local build = env.MushaAnim.GetBuildForForm(inst, GetMushaCurrentForm(inst))
	if build ~= nil then
		env.MushaAnim.SetBuild(inst, build)
	end
end

local function MakeFlags(overrides)
	local flags = {}
	for i = 1, #HOLD_FLAGS do
		flags[HOLD_FLAGS[i]] = false
	end
	for key, value in pairs(overrides) do
		flags[key] = value
	end
	return flags
end

local function MatchFlags(inst, flags)
	for i = 1, #HOLD_FLAGS do
		local key = HOLD_FLAGS[i]
		if (inst[key] == true) ~= (flags[key] == true) then
			return false
		end
	end
	return true
end

local function ApplyFlags(inst, flags)
	for i = 1, #HOLD_FLAGS do
		local key = HOLD_FLAGS[i]
		inst[key] = flags[key] == true
	end
end

local ALL_AUTOS = MakeFlags({
	visual_hold = true,
	visual_hold2 = true,
	visual_hold3 = true,
	visual_hold4 = true,
})

local ALL_TRUE = MakeFlags({
	visual_hold = true,
	visual_hold2 = true,
	visual_hold3 = true,
	visual_hold4 = true,
	full_hold = true,
	normal_hold = true,
	valkyrie_hold = true,
	berserk_hold = true,
	hold_old1 = true,
	hold_old2 = true,
	hold_old3 = true,
	hold_old4 = true,
	hold_old5 = true,
	hold_old6 = true,
	hold_old7 = true,
	hold_old8 = true,
	full_k_hold = true,
	normal_k_hold = true,
	valkyrie_k_hold = true,
	berserk_k_hold = true,
})

local VISUAL_STATES =
{
	{
		message = "Change Appearance\nCancel(O)key\nVisual:[Auto] SET 1",
		set_on = true,
		flags = MakeFlags({ visual_hold = true }),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Auto] SET 2",
		set_on = true,
		flags = MakeFlags({ visual_hold2 = true }),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Auto] SET 3",
		set_on = true,
		flags = MakeFlags({ visual_hold3 = true }),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Auto] SET 4",
		set_on = true,
		flags = ALL_AUTOS,
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Full]",
		build = "musha",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Normal]",
		build = "musha_normal",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Valkyrie]",
		build = "musha_battle",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Berserk]",
		build = "musha_hunger",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 1]",
		build = "musha_old",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old3 = true, hold_old4 = true, hold_old5 = true,
			hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 2]",
		build = "musha_normal_old",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old4 = true, hold_old5 = true,
			hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 3]",
		build = "musha_battle_old",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old5 = true,
			hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 4]",
		build = "musha_hunger_old",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 5]",
		build = "musha_full_sw2",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 6]",
		build = "musha_normal_sw2",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 7]",
		build = "musha_battle_sw2",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old7 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 8]",
		build = "musha_hunger_sw2",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old7 = true, hold_old8 = true,
			normal_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 9]",
		build = "musha_full_k",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, valkyrie_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 10]",
		build = "musha_normal_k",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, berserk_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 11]",
		build = "musha_battle_k",
		flags = MakeFlags({
			visual_hold = true, visual_hold2 = true, visual_hold3 = true, visual_hold4 = true,
			full_hold = true, normal_hold = true, valkyrie_hold = true, berserk_hold = true,
			hold_old1 = true, hold_old2 = true, hold_old3 = true, hold_old4 = true,
			hold_old5 = true, hold_old6 = true, hold_old7 = true, hold_old8 = true,
			full_k_hold = true, normal_k_hold = true, valkyrie_k_hold = true,
		}),
	},
	{
		message = "Change Appearance\nCancel(O)key \nVisual:[Change Appearance 12]",
		build = "musha_hunger_k",
		flags = ALL_TRUE,
	},
}

local function ApplyVisualState(inst, env, state)
	Say(inst, state.message)
	inst.set_on = state.set_on == true
	ApplyFlags(inst, state.flags)
	if state.build ~= nil then
		env.MushaAnim.SetBuild(inst, state.build)
	end
end

local function FindCurrentVisualStateIndex(inst)
	for i = 1, #VISUAL_STATES do
		if MatchFlags(inst, VISUAL_STATES[i].flags) then
			return i
		end
	end
end

function M.ResetVisual(inst)
	local env = M.env
	inst.writing = false
	if inst.writing or inst.visual_cos then
		return
	end

	ResetFormFlags(inst)
	inst.visual_cos = true
	Say(inst, env.STRINGS.MUSHA_VISUAL_BASE)
	inst.soundsname = "willow"
	ResetHoldFlags(inst)
	inst.visual_cos = false

	if not inst:HasTag("playerghost") then
		ApplyCurrentFormBuild(inst, env)
	end
end

function M.VisualHuman(inst)
	inst.writing = false
	if not inst.writing and not inst:HasTag("playerghost") then
		ApplyCurrentFormBuild(inst, M.env)
	end
end

function M.CycleVisual(inst)
	local env = M.env
	inst.writing = false
	if inst.writing or inst:HasTag("playerghost") or inst.visual_cos then
		return
	end

	ResetFormFlags(inst)
	if not inst.willow and not inst.wigfred then
		inst.change_visual = true
		inst.willow = true
		Say(inst, "[Visual] : Willow \nCancel(O)key")
		env.MushaAnim.SetBuild(inst, "willow")
		inst.wigfred = false
		return
	elseif inst.willow and not inst.wigfred then
		inst.change_visual = true
		inst.willow = true
		Say(inst, "[Visual] : Wigfred \nCancel(O)key")
		env.MushaAnim.SetBuild(inst, "wathgrithr")
		inst.wigfred = true
		return
	end

	inst.change_visual = false
	local current_index = FindCurrentVisualStateIndex(inst) or 0
	local next_state = VISUAL_STATES[current_index + 1]
	if next_state ~= nil then
		ApplyVisualState(inst, env, next_state)
	else
		Say(inst, "[Visual Hold - Off] \nVisual:[Auto]")
		ResetHoldFlags(inst)
		ApplyCurrentFormBuild(inst, env)
	end
end

function M.Register(env)
	M.env = env
	env.AddModRPCHandler("musha", "visual_cos", M.ResetVisual)
	env.AddModRPCHandler("musha", "visual_human", M.VisualHuman)
	env.AddModRPCHandler("musha", "visual_hold", M.CycleVisual)
end

return M
