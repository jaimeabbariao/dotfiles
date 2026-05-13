local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

config.font = wezterm.font("PlemolJP Console NF")
config.font_size = 13

-- Treat macOS Option as Alt (mirrors ghostty's macos-option-as-alt = true)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.keys = {
	-- Pane navigation
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },

	-- shift+enter sends literal newline
	{ key = "Enter", mods = "SHIFT", action = act.SendString("\n") },

	-- Chord activators
	{
		key = "p",
		mods = "ALT",
		action = act.ActivateKeyTable({ name = "split_mode", one_shot = true, timeout_milliseconds = 1000 }),
	},
	{
		key = "r",
		mods = "ALT",
		action = act.ActivateKeyTable({ name = "resize_mode", one_shot = true, timeout_milliseconds = 1000 }),
	},
	{
		key = "t",
		mods = "ALT",
		action = act.ActivateKeyTable({ name = "tab_mode", one_shot = true, timeout_milliseconds = 1000 }),
	},
}

config.key_tables = {
	-- alt+p chord: splits
	split_mode = {
		{ key = "n", action = act.SplitPane({ direction = "Right" }) },
		{ key = "n", mods = "SHIFT", action = act.SplitPane({ direction = "Left" }) },
		{ key = "d", action = act.SplitPane({ direction = "Down" }) },
		{ key = "d", mods = "SHIFT", action = act.SplitPane({ direction = "Up" }) },
	},

	-- alt+r chord: resize
	resize_mode = {
		{ key = "l", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "h", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "j", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "k", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
		-- Note: wezterm has no built-in equalize_splits; closest is to recreate via PaneSelect/rotate.
	},

	-- alt+t chord: tabs
	tab_mode = {
		{ key = "l", action = act.ActivateTabRelative(1) },
		{ key = "h", action = act.ActivateTabRelative(-1) },
	},
}

config.use_fancy_tab_bar = false
config.tab_max_width = 100

return config
